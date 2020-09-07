//
//  BOSAudioPlayer.m
//  ContactsLite
//
//  Created by Gil on 12-11-29.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "BOSAudioPlayer.h"
#import "BubbleTableViewCell.h"

NSString* const kNotifyAudioFinishPlaying = @"audioFinishPlaying";
NSString* const kKeyCurSpeechCell = @"currentSpeechCell";
BOOL isStopPlay = NO;//暗屏状态下，语音结束播放时关闭光感，会导致下次监听状态一直错误，加入此字段确定在亮屏状态下再关闭光感

@implementation KDCommonAudioCell



@end


@implementation BOSAudioPlayer

static BOSAudioPlayer *m_instance = nil;

+(BOSAudioPlayer *)sharedAudioPlayer
{
    @synchronized(self)
	{
		if(m_instance == nil)
		{
			m_instance=[[BOSAudioPlayer alloc] init];
		}
	}
	return m_instance;
}

-(id)init
{
    self = [super init];
    if (self) {
        _playerIdentifier = nil;
        _currentCell = nil;
    }
    return self;
}

-(void)createPlayerWithData:(NSData *)fileData identifier:(NSString *)identifier cell:(KDCommonAudioCell *)cell
{
    //切换了播放
    if (_playerIdentifier != identifier) {
        //BOSRELEASE_playerIdentifier);
        _playerIdentifier = [identifier copy];
        
        //停掉原来的播放
        if (_player) {
            [self stopPlay];
            //BOSRELEASE_player);
        }
        
        //初始化播放器的时候如下设置
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                sizeof(sessionCategory),
                                &sessionCategory);
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),
                                 &audioRouteOverride);
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //默认情况下扬声器播放
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        
        //从path路径中 加载播放器
        _player = [[AVAudioPlayer alloc] initWithData:fileData error:nil];
        _player.delegate = self;
        //初始化播放器
        [_player prepareToPlay];
        
        //切换了Cell
        if (_currentCell != cell) {
            //停掉原来Cell的动画
            if (_currentCell.voiceView.isAnimation) {
                [_currentCell.voiceView stopAnimations];
            }
            //BOSRELEASE_currentCell);
            _currentCell = cell;// retain];
        }
    }
}

- (void)enableAudioSession {
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
}

- (void)disableAudioSession {
    if([[UIDevice currentDevice] proximityState] == YES)
    {
        isStopPlay = YES;
        //播放结束时已经移除该监听，这里得重新加上
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    else
    {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
}

- (void)dealloc
{
    //BOSRELEASE_player);
    //BOSRELEASE_playerIdentifier);
    //BOSRELEASE_currentCell);
    //[super dealloc];
}

-(BOOL)isPlaying
{
    if (_player) {
        return [_player isPlaying];
    }
    return NO;
}

-(void)startPlay
{
    if (_player && ![_player isPlaying])
    {
        // 在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
        [self checkProximityStateChange];//检查当前手机是否靠近面部
        
        [_player play];
        [_currentCell.voiceView startAnimations];
    }
}

-(void)stopPlay
{
    if (_player && [_player isPlaying])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        [_player stop];
        [_player prepareToPlay];
        [self disableAudioSession];
        [_currentCell.voiceView stopAnimations];
        
        _playerIdentifier = nil;
        _player = nil;
    }
}

//处理监听触发事件
-(void)proximityStateChange:(NSNotificationCenter *)notification;
{
    [self checkProximityStateChange];
}

-(void)checkProximityStateChange
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(ASLocalizedString(@"＊＊＊＊＊＊＊＊＊＊＊＊内放＊＊＊＊＊＊＊＊＊＊＊＊＊"));
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        NSLog(ASLocalizedString(@"＊＊＊＊＊＊＊＊＊＊＊＊外放＊＊＊＊＊＊＊＊＊＊＊＊＊"));
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if(isStopPlay)
        {
            isStopPlay = NO;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    //[[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    //此处不释放session，在外部通知连读完成后再释放。
    //    [self disableAudioSession];
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:_currentCell,kKeyCurSpeechCell, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyAudioFinishPlaying object:nil userInfo:dict];
    [_currentCell.voiceView stopAnimations];
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    //[[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [self disableAudioSession];
    [_currentCell.voiceView stopAnimations];
}
- (void)audioPlayerBeginInteruption:(AVAudioPlayer*)player
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    //[[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [self disableAudioSession];
    [_currentCell.voiceView stopAnimations];
}

@end
