//
//  KDAudioController.h
//  kdweibo_common
//
//  Created by shen kuikui on 13-5-8.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "KDDownloadManager.h"
#import "KDDMMessage.h"


UIKIT_EXTERN NSString *const KDAudioControllerAudioDurationChangedNotification;
UIKIT_EXTERN NSString *const KDAudioControllerAudioMeteringChangedNotification;
UIKIT_EXTERN NSString *const KDAudioControllerAudioStartPlayNotification;
UIKIT_EXTERN NSString *const KDAudioControllerAudioStopPlayNotification;

UIKIT_EXTERN NSString *const KDAudioControllerRecordInterruptionNotification;

UIKIT_EXTERN NSString *const KDAudioControllerAudioDurationUserInfoKey;
UIKIT_EXTERN NSString *const KDAudioControllerAudioMeteringUserInfoKey;
UIKIT_EXTERN NSString *const KDAudioControllerAudioMeteringChangedIntervalUserInfoKey;
UIKIT_EXTERN NSString *const KDAudioControllerAudioMessageIDUserInfoKey;
UIKIT_EXTERN NSString *const KDAudioControllerAudioStopInterruptUserInfoKey;

typedef void (^KDAudioDurationCalculateFinishBlock)(NSTimeInterval duration);

@interface KDAudioController : NSObject<AVAudioSessionDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, KDDownloadListener>
{
    AVAudioRecorder *_recorder;
    AVAudioPlayer   *_player;
    
    NSString        *_curFilePath;
    NSUInteger      fileIndex;
    
    KDMockDownloadListener *_mockDownloadListener;
    
    BOOL    _shouldPlay;
}
//设备是否支持录音功能。
@property (nonatomic, readonly) BOOL canRecordNow;
//是否取得录音权限，iOS7.0后有效
@property (nonatomic, readonly) BOOL recordPermissionGranted;

+ (KDAudioController *)sharedInstance;
- (Float64)durationOfAudionAtPath:(NSString *)filePath;

//开始录音，tempID应为当前短邮的ID
- (void)startRecordWithTempID:(NSString *)tempID success:(BOOL *)sucess;

//停止录音
- (void)stopRecordWithTempID:(NSString *)tempID;

//播放.播放未发送成功的
- (void)playAudioWithFilePath:(NSString *)filePath andMessageID:(NSString *)messageId;

//播放.包含网络下载功能。
- (void)playAudioForMessage:(KDDMMessage *)msg;

//停止播放
- (void)stopPlay;

//设置是否需要播放。
//使用场景：网络下载比较慢，如若正在下载，而不需要播放了，可设置此为NO，否则，即便退出界面，仍然会播放音频。
- (void)setShouldPlay:(BOOL)shouldPlay;

//发送语音成功后调用
- (void)didSendAudioWithPath:(NSString *)filePath asAttachment:(NSString *)attachmentID;

//删除某个路径下的文件
- (BOOL)deleteAudioAtPath:(NSString *)filePath;

//清除所有匿名文件。For DMPostViewController;
- (BOOL)clearAnonymousAudio;

//
- (NSString *)curFilePath;
- (CGFloat)duration;
- (BOOL)isRecording;
- (BOOL)isPlaying;

@end
