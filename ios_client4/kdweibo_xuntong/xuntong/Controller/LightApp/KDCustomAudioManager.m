//
//  KDCustomAudioManager.m
//  kdweibo
//
//  Created by kyle on 2016/12/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDCustomAudioManager.h"
#import "BOSAudioPlayer.h"
#import "BOSAudioRecorder.h"
#import "KDAgoraSDKManager.h"
#import "ContactUtils.h"
#include "amrFileCodec.h"

@interface KDCustomAudioManager ()<AVAudioRecorderDelegate, AVAudioPlayerDelegate, KDCloudAPIDelegate>

@property (nonatomic, strong) dispatch_queue_t audioQueue;

@property (nonatomic,strong) XTCloudClient *downLoadFileclient;

@end

@implementation KDCustomAudioManager

+ (KDCustomAudioManager *)customAudioManager {
    static dispatch_once_t onceToken;
    static KDCustomAudioManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[KDCustomAudioManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _downLoadFileclient = [[XTCloudClient alloc] init];
        _downLoadFileclient.delegate = self;
//        _audioQueue = dispatch_queue_create("com.audio.queue", NULL);
    
    }
    
    return self;
}

#pragma mark - recordAudio
- (void)startRecordComplete:(KDStartRecordBlock)block {
    _startRecordBlock = block;
    [self clearData];
    
    if (!_audioRecorder.isRecording) {
        _isRecording = YES;
        [self prepareToRecord];
        [self startRecordForDuration:60];
    } else {
        _isRecording = NO;
        [self.audioRecorder stop];
    }
}

- (void)stopRecordComplete:(KDStopRecordBlock)block {
    _stopRecordBlock = block;
    if (_audioRecorder.isRecording) {
        [self.audioRecorder stop];
    }
}

#pragma mark - playAudio
- (void)playVoice:(NSString *)localID startBlock:(KDPlayVoiceBlock)startBlock finishBlock:(KDPlayVoiceBlock)finishBlock {
    _startPlayBlock = startBlock;
    _finishPlayBlock = finishBlock;
    _pauseVoiceBlock = nil;
    _stopVoiceBlock = nil;
    NSString *filePath = [[ContactUtils recordPath] stringByAppendingPathComponent:localID];
    [self startPlayAudioWithPath:filePath];
}

- (void)pauseVoice:(NSString *)localID complete:(KDPauseVoiceBlock)block {
    _pauseVoiceBlock = block;
    NSString *filePath = [[ContactUtils recordPath] stringByAppendingPathComponent:localID];
    [self pausePlayAudioWithPath:filePath];
}

- (void)stopVoice:(NSString *)localID complete:(KDStopVoiceBlock)block {
    _stopVoiceBlock = block;
    [self stopPlayAudio];
}

#pragma mark - Record

- (NSString *)recordWAVAFilePathWithTime {
    NSString *path = [ContactUtils recordPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.caf", _currTimeStr];
    return [path stringByAppendingPathComponent:fileName];
}

- (NSString *)recordAMRFilePathWithTime {
    NSString *path = [ContactUtils recordPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.amr", _currTimeStr];
    return [path stringByAppendingPathComponent:fileName];
}

- (void)prepareToRecord {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if (err) return;
    [audioSession setActive:YES error:&err];
    err = nil;
    if (err) return;
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
}

- (BOOL)startRecord {
    return [self startRecordForDuration:0];
}

- (BOOL)checkPermission {
    __block BOOL isHasPermissopn = NO;
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            NSString * messageString =ASLocalizedString(@"获取麦克风权限失败,请到手机\"设置\"-\"隐私\"-\"麦克风\"打开云之家权限");
            [KDPopup showAlertWithTitle:nil message:messageString buttonTitles:@[ASLocalizedString(@"确定"), ASLocalizedString(@"立即设置")] onTap:^(NSInteger index) {
                if (index != 0) {
                    if(([[UIDevice currentDevice].systemVersion floatValue])>=8.0){
                        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    } else {
                        NSURL*url=[NSURL URLWithString:@"prefs:root=Privacy"];
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }
                
                if (_startRecordBlock) {
                    _startRecordBlock(NO, @"100", nil, nil);
                    _startRecordBlock = nil;
                }
            }];
            
            isHasPermissopn = NO;
        } else {
            isHasPermissopn = YES;
        }
    }];
    if (!isHasPermissopn) {
        if (_startRecordBlock) {
            _startRecordBlock(NO, @"100", nil, nil);
            _startRecordBlock = nil;
        }
    }
    
    return isHasPermissopn;
}

- (BOOL)startRecordForDuration: (NSTimeInterval) duration {
    if (![self checkPermission]) {
        return NO;
    };
    if (!_audioRecorder.recording) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([[audioSession category] isEqualToString:AVAudioSessionCategoryPlayAndRecord] ||
            [[audioSession category] isEqualToString:AVAudioSessionCategoryRecord]) {
            if ([audioSession isInputAvailable]) {
                NSError *error = nil;
                NSDictionary *recordingSettings = [self recordingSettings];
                _currTimeStr = [[NSDate date] dz_stringValue];
                _recorderingPath = [self recordWAVAFilePathWithTime];
                NSURL *fullPathURL = [NSURL fileURLWithPath:_recorderingPath];
                _audioRecorder = [[AVAudioRecorder alloc] initWithURL:fullPathURL
                                                             settings:recordingSettings
                                                                error:&error];
                _audioRecorder.delegate = self;
                _audioRecorder.meteringEnabled = YES;
                if (!error) {
                    if ([_audioRecorder prepareToRecord]) {
                        _deletedRecording = NO;
                        [self startReceivedRecordingCallBackTimer];
                        if (duration < 0.001) {
                            return [_audioRecorder record];
                        }
                        else {
                            return [_audioRecorder recordForDuration:duration];
                        }
                    }
                }
            }
        }
    }
    
    return NO;
}

- (void)stopRecord {
    if(_recordTimer){[_recordTimer invalidate]; _recordTimer=nil;}
    if (_audioRecorder.recording) {
        [_audioRecorder stop];
    }
}

- (void)stopAndDeleteRecord {
    if(_recordTimer){[_recordTimer invalidate]; _recordTimer=nil;}
    if (_audioRecorder.recording) {
        [_audioRecorder stop];
    }
    if (!_deletedRecording) {
        _deletedRecording = [_audioRecorder deleteRecording];
    }
}

- (void)enableAudioSession {
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
}

- (void)disableAudioSession {
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
}

#pragma mark - AVAudioRecorderDelegate
- (void)clearData {
    _audioRecorder.delegate = nil;
    _player.delegate = nil;
    _audioRecorder = nil;
    _currTimeStr = @"";
    _recorderingPath = @"";
    _recordSeconds = 0;
    _realRecordSeconds = 0;
}

- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if(_recordTimer){[_recordTimer invalidate]; _recordTimer=nil;}
    [self disableAudioSession];
    [_audioRecorder stop];
    if (!flag) {
        if (_startRecordBlock && !_stopRecordBlock) {
            _startRecordBlock(NO, @"200", nil, nil);
            _startRecordBlock = nil;
        }
        if (_stopRecordBlock) {
            _stopRecordBlock(NO, @"200",ASLocalizedString(@"录音失败,请重试"), nil);
            _stopRecordBlock = nil;
        }
        return;
    }
    if (_realRecordSeconds < 0.5) {
        _realRecordSeconds = 0;
        if (_recorderingPath && _recorderingPath.length > 0) {
            [[NSFileManager defaultManager] removeItemAtPath:_recorderingPath error:nil]; 
        }
        
        if (_startRecordBlock && !_stopRecordBlock) {
            _startRecordBlock(NO, @"200", nil, nil);
            _startRecordBlock = nil;
        }
        if (_stopRecordBlock) {
            _stopRecordBlock(NO, @"200", ASLocalizedString(@"录音失败,请重试"), nil);
            _stopRecordBlock = nil;
        }
        return;
    }
    NSData *cafData = [NSData dataWithContentsOfFile:_recorderingPath];
    NSString *amrFilePath = [self recordAMRFilePathWithTime];
    NSData *amrData = EncodeWAVEToAMR(cafData, 1, 16);
    [amrData writeToFile:amrFilePath atomically:YES];
    
    NSString *base64RecordString = nil;
    if (_returnBase64) {
        base64RecordString = [amrData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    }

//    [KDPopup showHUDInView:[[UIApplication sharedApplication] getTopView]];
    [KDFileUploader kd_uploadFiles:@{amrFilePath:amrData} completion:^(BOOL succ, NSArray<DocumentFileModel *> * _Nullable files) {
//        [KDPopup hideHUDInView:[[UIApplication sharedApplication] getTopView]];
        DocumentFileModel *file;
        if (succ && files.count > 0) file = [files firstObject];
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        [data setValue:amrFilePath.lastPathComponent forKey:@"localId"];
        [data setValue:@(round(_realRecordSeconds)) forKey:@"len"];
        [data setValue:safeString(file.fileId) forKey:@"fileId"];
        [data setValue:@"amr" forKey:@"format"];
        [data setValue:@(amrData.length) forKey:@"size"];
        if (_returnBase64) {
            [data setValue:safeString(base64RecordString) forKey:@"base64"];
        }
        BOOL isSuccess = succ && files.count > 0;
        NSString *errorCode = isSuccess ? @"0" : @"200";
        if (_startRecordBlock && !_stopRecordBlock) {
            _startRecordBlock(isSuccess, errorCode, nil, data);
            _startRecordBlock = nil;
        }
        if (_stopRecordBlock) {
            _stopRecordBlock(isSuccess,errorCode, nil, data);
            _stopRecordBlock = nil;
        }
        
        [self clearData];
    }];
}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    if(_recordTimer){[_recordTimer invalidate]; _recordTimer=nil;}
    [self disableAudioSession];
    _realRecordSeconds = 0;
    if (_startRecordBlock && !_stopRecordBlock) {
        _startRecordBlock(NO, @"200", nil, nil);
        _startRecordBlock = nil;
    }
    if (_stopRecordBlock) {
        _stopRecordBlock(NO, @"200", ASLocalizedString(@"录音失败,请重试"), nil);
        _stopRecordBlock = nil;
    }
    [self clearData];
}

- (void)audioRecorderReceivedRecordingCallBack:(NSTimer*)timer {
    if (_audioRecorder.recording) {
        [_audioRecorder updateMeters];
        float currentTime = _audioRecorder.currentTime;
        _realRecordSeconds = currentTime;
        if (currentTime > _recordSeconds) {
            _recordSeconds = ceilf(currentTime);
        }
    }
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    if(_recordTimer){[_recordTimer invalidate]; _recordTimer=nil;}
    [self disableAudioSession];
    [_audioRecorder stop];
    if (_realRecordSeconds < 0.5) {
        _realRecordSeconds = 0;
        [[NSFileManager defaultManager] removeItemAtPath:_recorderingPath error:nil];
        if (_startRecordBlock && !_stopRecordBlock) {
            _startRecordBlock(NO, @"200", nil, nil);
            _startRecordBlock = nil;
        }
        if (_stopRecordBlock) {
            _stopRecordBlock(NO, @"200", ASLocalizedString(@"录音失败,请重试"), nil);
            _stopRecordBlock = nil;
        }
        
        return;
    }
    
    NSData *cafData = [NSData dataWithContentsOfFile:_recorderingPath];
    NSString *amrFilePath = [self recordAMRFilePathWithTime];
    NSData *amrData = EncodeWAVEToAMR(cafData, 1, 16);
    [amrData writeToFile:amrFilePath atomically:YES];
    
//    [KDPopup showHUDInView:[[UIApplication sharedApplication] getTopView]];
    [KDFileUploader kd_uploadFiles:@{amrFilePath:amrData} completion:^(BOOL succ, NSArray<DocumentFileModel *> * _Nullable files) {
//        [KDPopup hideHUDInView:[[UIApplication sharedApplication] getTopView]];
        DocumentFileModel *file;
        if (succ && files.count > 0) file = [files firstObject];
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        [data setValue:amrFilePath.lastPathComponent forKey:@"localId"];
        [data setValue:@(round(_realRecordSeconds)) forKey:@"len"];
        [data setValue:safeString(file.fileId) forKey:@"fileId"];
        [data setValue:@"amr" forKey:@"format"];
        [data setValue:@(amrData.length) forKey:@"size"];
        BOOL isSuccess = succ && files.count > 0;
        NSString *errorCode = isSuccess ? @"0" : @"200";
        if (_startRecordBlock && !_stopRecordBlock) {
            _startRecordBlock(isSuccess, errorCode, nil, data);
            _startRecordBlock = nil;
        }
        if (_stopRecordBlock) {
            _stopRecordBlock(isSuccess, errorCode, nil, data);
            _stopRecordBlock = nil;
        }
        
        [self clearData];
    }];
}

#pragma mark - Private methods

- (void)startReceivedRecordingCallBackTimer{
    if(_recordTimer){[_recordTimer invalidate]; _recordTimer=nil;}
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                    target:self
                                                  selector:@selector(audioRecorderReceivedRecordingCallBack:)
                                                  userInfo:nil
                                                   repeats:YES];
//    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
//    [runLoop addTimer:_recordTimer forMode:NSDefaultRunLoopMode];
}

-(NSDictionary *)recordingSettings {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
            [NSNumber numberWithFloat:8000.0], AVSampleRateKey,
            [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
            [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
            [NSNumber numberWithInt:AVAudioQualityLow],AVEncoderAudioQualityKey,
            [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
            [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey, nil];
}

#pragma mark - playAudio

- (void)startPlayAudioWithPath:(NSString *)filePath {
    NSData *amrData = [NSData dataWithContentsOfFile:filePath];
    NSData *cafData = DecodeAMRToWAVE(amrData);
    
    if (!amrData) {
        if (_startPlayBlock) {
            _startPlayBlock(NO, @"1", @"本地文件不存在", @{});
        }
        return;
    }
    //停掉原来的播放
    if (_player) {
        if (_player.isPlaying) {
            [_player stop];
        }
        _player = nil;
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
    _player = [[AVAudioPlayer alloc] initWithData:cafData error:nil];
    _player.delegate = self;

    //初始化播放器
    [_player prepareToPlay];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [_player play];
    _currPlayTime = 0;
    if (_startPlayBlock) {
        _startPlayBlock(YES, @"0", nil, @{@"playStatus" : @(0)});
    }
}

- (void)pausePlayAudioWithPath:(NSString *)localId {
    [_player pause];
    [_player prepareToPlay];
    NSLog(@"%@",_player.delegate);
    _currPlayTime = _player.currentTime;
    if (_pauseVoiceBlock) {
        _pauseVoiceBlock(YES, @"0", nil, nil);
    }
}

- (void)stopPlayAudio {
    if (_player && _player.isPlaying) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        [_player stop];
        [_player prepareToPlay];
        _player.currentTime = 0;
        [self disableAudioSession];
    }
    
    _player = nil;
    if (_stopVoiceBlock) {
        _stopVoiceBlock(YES, @"0", nil, nil);
    }
}

//处理监听触发事件
-(void)proximityStateChange:(NSNotificationCenter *)notification {
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [self disableAudioSession];
    
    if (_finishPlayBlock && !_stopVoiceBlock) {
        _finishPlayBlock(YES, @"0", nil, @{@"playStatus": @(1)});
    }
    if (_stopVoiceBlock) {
        _stopVoiceBlock(YES, @"0" , nil, nil);
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError *)error {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [self disableAudioSession];
    if (_finishPlayBlock && !_stopVoiceBlock) {
        _finishPlayBlock(NO, @"-1", nil, nil);
    }
    if (_stopVoiceBlock) {
        _stopVoiceBlock(YES, @"0", nil, nil);
    }
}
- (void)audioPlayerBeginInteruption:(AVAudioPlayer*)player {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [self disableAudioSession];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    if (_pauseVoiceBlock) {
        _pauseVoiceBlock(YES, @"0", nil, nil);
    }
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {

}

#pragma mark - upload or download
//- (void)uploadVoice:(NSString *)localID complete:(KDUploadVoiceBlock)block {
//    _uploadVoiceBlock = block;
//    NSString *filePath = [[ContactUtils recordPath] stringByAppendingPathComponent:localID];
//    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
//    [KDFileUploader kd_uploadFiles:@{filePath:fileData} completion:^(BOOL succ, NSArray<DocumentFileModel *> * _Nullable files) {
//        DocumentFileModel *file = [files firstObject];
//        if (_uploadVoiceBlock) {
//            _uploadVoiceBlock(succ, nil, @{@"serverId" : file.fileId});
//        }
//    }];
//}
//
//- (void)downloadVoice:(NSString *)serverId complete:(KDDownloadVoiceBlock)block {
//    _downloadVoiceBlock = block;
//    KDFileModel *file = [[KDFileModel alloc] init];
//    file.fileId = serverId;
//    if (!file.isFinished) {
//        [_downLoadFileclient downLoadFileByFile:file];
//    } else {
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSString *path = [ContactUtils fileFilePath];
//        
//        NSString *fileName = serverId;
//        NSString *downloadPath = [path stringByAppendingPathComponent:fileName];
//        NSString *wholePath = [[ContactUtils recordPath] stringByAppendingPathComponent:fileName];
//        NSError *error = NULL;
//        if (![fileManager fileExistsAtPath:wholePath]) {
//            if ([fileManager moveItemAtPath:downloadPath toPath:wholePath error:&error] != YES) {
//                DDLogError(@"Unable to move file: %@", [error localizedDescription]);
//            }
//        }
//        if (_downloadVoiceBlock) {
//            _downloadVoiceBlock(YES, nil, @{@"localId" : fileName});
//        }
//    }
//}

#pragma mark - KDCloudAPIDelegate

//下载完成
-(void)KDCloudAPI:(XTCloudClient *)api didFinishedDownloadWithDownloadPath:(NSString *)downloadPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (downloadPath.length>0 && [fileManager fileExistsAtPath:downloadPath]) {
        NSString *fileName = [downloadPath lastPathComponent];
        NSString *wholePath = [[ContactUtils recordPath] stringByAppendingPathComponent:fileName];
        NSError *error = NULL;
        if ([fileManager moveItemAtPath:downloadPath toPath:wholePath error:&error] != YES) {
//            DDLogError(@"Unable to move file: %@", [error localizedDescription]);
        }
        if (_downloadVoiceBlock) {
            _downloadVoiceBlock(YES, nil, @{@"localId" : fileName});
        }
        return;
    }
    if (_downloadVoiceBlock) {
        _downloadVoiceBlock(YES, nil, nil);
    }
}

//请求失败
-(void)KDCloudAPI:(XTCloudClient *)api didFailedDownloadWithError:(NSError *)error {
    if (_downloadVoiceBlock) {
        _downloadVoiceBlock(NO, nil, nil);
    }
}



@end
