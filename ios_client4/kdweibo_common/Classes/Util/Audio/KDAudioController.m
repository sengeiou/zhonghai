//
//  KDAudioController.m
//  kdweibo_common
//
//  Created by shen kuikui on 13-5-8.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDAudioController.h"
#import "KDUtility.h"
#import "VoiceConverter.h"
#import "KDDownload.h"
#import "KDAttachment.h"
#import <CoreMedia/CoreMedia.h>

#define ANONYMOUS   @"anonymous"

NSString *const KDAudioControllerAudioDurationChangedNotification = @"kd_audio_controller_audio_duration_changed";
NSString *const KDAudioControllerAudioMeteringChangedNotification = @"kd_audio_controller_audio_metering_changed";
NSString *const KDAudioControllerAudioStartPlayNotification = @"kd_audio_controller_audio_start_play";
NSString *const KDAudioControllerAudioStopPlayNotification = @"kd_audio_controller_audio_stop_play";

NSString *const KDAudioControllerRecordInterruptionNotification = @"kd_audio_controller_record_interruption";

NSString *const KDAudioControllerAudioDurationUserInfoKey = @"kd_audio_controller_audio_duration_key";
NSString *const KDAudioControllerAudioMeteringUserInfoKey = @"kd_audio_controller_audio_metering_key";
NSString *const KDAudioControllerAudioMeteringChangedIntervalUserInfoKey = @"kd_audio_controller_audio_metering_changed_interval_key";
NSString *const KDAudioControllerAudioMessageIDUserInfoKey = @"kd_audio_controller_audio_stop_play_message_id_key";
NSString *const KDAudioControllerAudioStopInterruptUserInfoKey = @"kd_audio_controller_audio_stop_is_interrupt_key";

static KDAudioController *single = nil;

@interface KDAudioController()
{
    NSTimer *_timer;
    
    CGFloat _duration;
    NSUInteger count;
    NSString *_curMessageID;
    
    BOOL _canRecordNow;
    BOOL _recordPermissionGranted;
    
    NSString *_shouldPlayMessageID;
}

@property (nonatomic, copy) NSString *curFilePath;
@property (nonatomic, copy) KDMockDownloadListener *mockDownloadListener;
@property (nonatomic, copy) NSString *shouldPlayMessageID;
@property (nonatomic, retain) AVAudioRecorder *recorder;
@property (nonatomic, retain) AVAudioPlayer   *player;
@property (nonatomic, retain) NSTimer         *timer;
@property (nonatomic, copy) NSString *curMessageID;
@property (nonatomic, assign) BOOL canRecordNow;
@property (nonatomic, assign) BOOL recordPermissionGranted;
@end

@implementation KDAudioController

@synthesize curFilePath = _curFilePath;
@synthesize recorder = _recorder;
@synthesize shouldPlayMessageID = _shouldPlayMessageID;
@synthesize player = _player;
@synthesize mockDownloadListener = _mockDownloadListener;
@synthesize timer = _timer;
@synthesize curMessageID = _curMessageID;
@synthesize canRecordNow = _canRecordNow;
@synthesize recordPermissionGranted = _recordPermissionGranted;

- (id)init {
    self = [super init];
    
    if(self) {
        _mockDownloadListener = [[KDMockDownloadListener alloc] initWithDownloadListener:self];
        [[KDDownloadManager sharedDownloadManager] addListener:_mockDownloadListener];
        _recordPermissionGranted = YES;
        [self setAVAudioSession];
    }
    
    return self;
}

+ (KDAudioController *)sharedInstance {
    @synchronized(self) {
        if(single == nil) {
            single = [[super allocWithZone:NULL] init];
        }
    }
    
    return single;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

+ (id)copyWithZone:(NSZone *)zone {
    return self;
}

//- (NSUInteger)retainCount {
//    return NSUIntegerMax;
//}

//- (id)retain {
//    return self;
//}

//- (id)autorelease {
//    return self;
//}

//- (oneway void)release {
//    //do nothing;
//}

- (void)dealloc {
    [[KDDownloadManager sharedDownloadManager] removeListener:_mockDownloadListener];
//    [_recorder release];
//    [_player   release];
//    [_curFilePath release];
//    [_mockDownloadListener release];
//    [_shouldPlayMessageID release];
    
    if([_timer isValid]) {
        [_timer invalidate];
    }
//    [_timer release];
//    
//    [_curMessageID release];
    
    //[super dealloc];
}

#pragma mark - public methods
- (void)startRecordWithTempID:(NSString *)tempID success:(BOOL *)sucess {
    [self updateTempFileIndexForTempId:tempID];
    
    [self stopPlay];
    
    if(_recorder) {
        [_recorder stop];
        self.recorder = nil;
    }
    
    [self enableAudioSession];
    
    self.curFilePath = [self tempPathForTempID:tempID];
    NSURL *url = [NSURL URLWithString:[_curFilePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError *error = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:[self audioSettings] error:&error];
    if (error) {
        DLog(@"error = %@",[error localizedDescription]);
    }
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    
    
    if ([_recorder record]) {
        [_recorder prepareToRecord];
        *sucess = YES;
        [self startTimer];
    }else {
        *sucess = NO;
    }
    
}

//@modify-time:2013年10月17日11:41:33
//@modify-reason:语音零秒发送问题
- (void)stopRecordWithTempID:(NSString *)tempID {
    if(_recorder && [_recorder isRecording]) {
        [_recorder stop];
        [self stopTimer];
    }
    
    [self disableAudioSession];
    
    if(_duration >= 1.0f) {
        //convert wav file to amr
        [VoiceConverter wavToAmr:_curFilePath amrSavePath:[self unsendPathForTempID:tempID]];
        
        [[NSFileManager defaultManager] removeItemAtPath:_curFilePath error:NULL];
        
        self.curFilePath = [self unsendPathForTempID:tempID];
    }else {
        self.curFilePath = nil;
        [[NSFileManager defaultManager] removeItemAtPath:_curFilePath error:NULL];
    }
}

- (void)playAudioWithFilePath:(NSString *)filePath andMessageID:(NSString *)messageId{
    [VoiceConverter amrToWav:filePath wavSavePath:[self currentPlayBackFilePath]];
    
    NSURL *url = [NSURL URLWithString:[[self currentPlayBackFilePath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    if(_player) {
        [self stopPlay];
        self.player = nil;
    }
    
    [self enableAudioSession];
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    _player.delegate = self;
    
    [_player prepareToPlay];
    [self playbackStateChanged:YES];
    
    self.curMessageID = messageId;
    [[NSNotificationCenter defaultCenter] postNotificationName:KDAudioControllerAudioStartPlayNotification object:self userInfo:[NSDictionary dictionaryWithObject:_curMessageID forKey:KDAudioControllerAudioMessageIDUserInfoKey]];
    
    [_player play];
}

- (void)playAudioForMessage:(KDDMMessage *)msg {
    KDAttachment *att = [msg.attachments lastObject];
    if(att) {
        if(att.fileId == nil && att.url) {
            [self playAudioWithFilePath:att.url andMessageID:msg.messageId];
            return;
        }
    }
    
    _shouldPlay = YES;
    self.shouldPlayMessageID = msg.messageId;
    
    [KDDownload downloadsWithAttachemnts:msg.attachments
                            diretMessage:msg
                             finishBlock:^(NSArray *downloads) {
                                 KDDownload *download = [downloads lastObject];
                                 
                                 if(![download isSuccess]) {
                                     [[KDDownloadManager sharedDownloadManager] addDownload:download];
                                 }else {
                                     if(_shouldPlay && [download.entityId isEqualToString:_shouldPlayMessageID])
                                         [self playAudioWithFilePath:download.path andMessageID:msg.messageId];
                                 }
                             }];
}

- (void)stopPlay {
    if(_player && [_player isPlaying]) {
        [_player stop];
        [self playbackStateChanged:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:KDAudioControllerAudioStopPlayNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_curMessageID, KDAudioControllerAudioMessageIDUserInfoKey, @(YES), KDAudioControllerAudioStopInterruptUserInfoKey, nil]];
    }
}

- (void)setShouldPlay:(BOOL)shouldPlay {
    _shouldPlay = shouldPlay;
}

- (void)didSendAudioWithPath:(NSString *)filePath asAttachment:(NSString *)attachmentID {
    NSError *error = nil;
    if(![[NSFileManager defaultManager] moveItemAtPath:filePath toPath:[self filePathForAudioID:attachmentID] error:&error]) {
        NSLog(@"move sent file failed with error : %@", error);
    }
}

- (BOOL)deleteAudioAtPath:(NSString *)filePath {
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    
    if(!success) {
        NSLog(@"delete audio file failed with error : %@", error);
    }
    
    return success;
}

- (BOOL)clearAnonymousAudio {
    NSString *path = [[KDUtility defaultUtility] searchDirectory:KDDownloadAudioUnsend
                                                    inDomainMask:KDTemporaryDomainMask needCreate:NO];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:path];
    
    for(NSString *file in files) {
        if([file rangeOfString:ANONYMOUS].location != NSNotFound) {
            NSError *error = nil;
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
            if(!success) {
                NSLog(@"clear anonymous audio failed with error : %@", error);
                return NO;
            }
        }
    }
    
    return YES;
}

- (NSString *)curFilePath {
    return _curFilePath;
}

- (CGFloat)duration {
    return _duration;
}

- (BOOL)isRecording {
    DLog(@"_recorder = %@",_recorder);
    if(_recorder) {
        return _recorder.isRecording;
    }
    
    return NO;
}

- (BOOL)isPlaying {
    if(_player) {
        return _player.isPlaying;
    }
    
    return NO;
}

- (Float64)durationOfAudionAtPath:(NSString *)filePath {
    
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    AudioFileID fileID;
    AudioFileOpenURL((__bridge CFURLRef)fileUrl, kAudioFileReadPermission, 0, &fileID);
    Float64 outDataSize = 0;
    UInt32 propertySize = sizeof(Float64);
    AudioFileGetProperty(fileID, kAudioFilePropertyEstimatedDuration, &propertySize, &outDataSize);
    AudioFileClose(fileID);
    
    return outDataSize;
}

#pragma mark - private methods
- (void)setAVAudioSession {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
    [[AVAudioSession sharedInstance] setDelegate:self];
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            self.recordPermissionGranted = YES;
        }
        else {
            self.recordPermissionGranted = NO;
        }
    }];
    self.canRecordNow = [[AVAudioSession sharedInstance] isInputAvailable];
    
    UInt32 audioRoute = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(audioRoute), &audioRoute);
}

- (void)enableAudioSession {
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
}

- (void)disableAudioSession {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
}

- (void)playbackStateChanged:(BOOL)isPlay {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:isPlay];
    
    if(isPlay) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        [self setAudioSessionAudioRoute:YES];
    }
}

-(void)sensorStateChange:(NSNotificationCenter *)notification {
    [self setAudioSessionAudioRoute:![[UIDevice currentDevice] proximityState]];
}

- (void)setAudioSessionAudioRoute:(BOOL)isSpeaker {
    UInt32 audioRouteOverride;
    if(!isSpeaker) {
        audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    }else {
        audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    }
    
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(audioRouteOverride), &audioRouteOverride);
}

- (void)updateTempFileIndexForTempId:(NSString *)tempID {
    NSString *tempPath = [[KDUtility defaultUtility] searchDirectory:KDDownloadAudioUnsend
                                                        inDomainMask:KDTemporaryDomainMask needCreate:YES];
    
    if(!tempID) {
        tempID = ANONYMOUS;
    }
    
    for(NSUInteger index = 0;;index++) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@%lu.amr", tempPath, tempID, (unsigned long)index];
        if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            fileIndex = index;
            return;
        }
    }
}

- (NSString *)tempPathForTempID:(NSString *)tempID {
    
    if(!tempID) {
        tempID = ANONYMOUS;
    }
    
    return [[[KDUtility defaultUtility] searchDirectory:KDDownloadAudioTemp
                                           inDomainMask:KDTemporaryDomainMask needCreate:YES]
            stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%lu.wav", tempID, (unsigned long)fileIndex]];
}

- (NSString *)unsendPathForTempID:(NSString *)tempID {
    
    if(!tempID) {
        tempID = ANONYMOUS;
    }
    
    return [[[KDUtility defaultUtility] searchDirectory:KDDownloadAudioUnsend
                                           inDomainMask:KDTemporaryDomainMask needCreate:YES]
            stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%lu.amr", tempID, (unsigned long)fileIndex]];
}

- (NSString *)filePathForAudioID:(NSString *)audioID {
    assert(audioID);
    return [[[KDUtility defaultUtility] searchDirectory:KDDownloadAudio
                                           inDomainMask:KDTemporaryDomainMask needCreate:YES]
            stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr", audioID]];
}

- (NSString *)currentPlayBackFilePath {
    return [[[KDUtility defaultUtility] searchDirectory:KDDownloadAudioTemp
                                           inDomainMask:KDTemporaryDomainMask needCreate:YES]
            stringByAppendingPathComponent:@"playback.wav"];
}

- (NSDictionary *)audioSettings {
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   //                                   [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   nil];
    return recordSetting;// autorelease];
}

- (void)startTimer {
    if(_timer && [_timer isValid]) {
        [_timer invalidate];
    }
    
    _duration = 0.0f;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if(_timer && [_timer isValid])
        [_timer invalidate];
}

- (void)timerAction:(NSTimer *)timer {
    count++;
    
    if(count == 2) {
        _duration += 1.0f;
        count = 0;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KDAudioControllerAudioDurationChangedNotification object:self userInfo:[NSDictionary dictionaryWithObject:@(_duration) forKey:KDAudioControllerAudioDurationUserInfoKey]];
    }
    
    if([_recorder isRecording]) {
        [_recorder updateMeters];
        CGFloat meters = [_recorder averagePowerForChannel:0];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KDAudioControllerAudioMeteringChangedNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@(meters), KDAudioControllerAudioMeteringUserInfoKey, @(timer.timeInterval), KDAudioControllerAudioMeteringChangedIntervalUserInfoKey, nil]];
    }
}

#pragma mark - AVAudioSession Delegate Methods
- (void)inputIsAvailableChanged:(BOOL)isInputAvailable {
    self.canRecordNow = isInputAvailable;
}

#pragma mark - AVAudioRecorder Delegate Methods
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    NSLog(@"audio recorder interruption");
    [[NSNotificationCenter defaultCenter] postNotificationName:KDAudioControllerRecordInterruptionNotification object:self];
    
    [self disableAudioSession];
}

#pragma mark - AVAudioPlayer Delegate Methods

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    NSLog(@"play begin interruption");
    [self stopPlay];
    [self disableAudioSession];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    NSLog(@"play end interruption");
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    //remove temp file
    [self playbackStateChanged:NO];
    [self disableAudioSession];
    [[NSNotificationCenter defaultCenter] postNotificationName:KDAudioControllerAudioStopPlayNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_curMessageID, KDAudioControllerAudioMessageIDUserInfoKey, @(NO), KDAudioControllerAudioStopInterruptUserInfoKey, nil]];
    NSError *error;
    if(![[NSFileManager defaultManager] removeItemAtPath:[self currentPlayBackFilePath] error:&error]) {
        NSLog(@"remove temp wav file failed with error : %@", error);
    }
}

#pragma mark - KDDownloadListener Delegate Methods
- (void)downloadProgressDidChange:(KDRequestProgressMonitor *)monitor {
    
}

- (void)downloadStateDidChange:(KDDownload *)download {
    if([download isSuccess]) {
        if(_shouldPlay && [download.entityId isEqualToString:_shouldPlayMessageID])
            [self playAudioWithFilePath:download.path andMessageID:download.entityId];
    }
}

@end
