//
//  KDCustomAudioManager.h
//  kdweibo
//
//  Created by kyle on 2016/12/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^KDStartRecordBlock)(BOOL success, NSString *errorCode, NSString *error, NSDictionary *data);
typedef void(^KDStopRecordBlock)(BOOL success,  NSString *errorCode, NSString *error, NSDictionary *data);
typedef void(^KDPlayVoiceBlock)(BOOL success,  NSString *errorCode, NSString *error, NSDictionary *data);
typedef void(^KDPauseVoiceBlock)(BOOL success, NSString *errorCode, NSString *error, NSDictionary *data);
typedef void(^KDStopVoiceBlock)(BOOL success,  NSString *errorCode, NSString *error, NSDictionary *data);
typedef void(^KDUploadVoiceBlock)(BOOL success, NSString *error, NSDictionary *data);
typedef void(^KDDownloadVoiceBlock)(BOOL success, NSString *error, NSDictionary *data);

@interface KDCustomAudioManager : NSObject

@property (nonatomic, assign) BOOL isRecording;

@property (nonatomic, strong) KDStartRecordBlock    startRecordBlock;
@property (nonatomic, strong) KDStopRecordBlock     stopRecordBlock;
@property (nonatomic, strong) KDPlayVoiceBlock      startPlayBlock;
@property (nonatomic, strong) KDPlayVoiceBlock      finishPlayBlock;
@property (nonatomic, strong) KDPauseVoiceBlock     pauseVoiceBlock;
@property (nonatomic, strong) KDStopVoiceBlock      stopVoiceBlock;
@property (nonatomic, strong) KDUploadVoiceBlock    uploadVoiceBlock;
@property (nonatomic, strong) KDDownloadVoiceBlock  downloadVoiceBlock;

//录音
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, strong) AVAudioRecorder* audioRecorder;
@property (nonatomic, assign) BOOL deletedRecording;
@property (nonatomic, strong) NSString *recorderingPath;
@property (nonatomic, strong) NSString *currTimeStr;
@property (nonatomic, assign) int recordSeconds;
@property (nonatomic, assign) float realRecordSeconds;

//播放
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) NSTimeInterval currPlayTime;

@property (nonatomic, assign) BOOL returnBase64;

+ (KDCustomAudioManager *)customAudioManager;
- (void)clearData;

- (void)startRecordComplete:(KDStartRecordBlock)block;
- (void)stopRecordComplete:(KDStopRecordBlock)block;
- (void)playVoice:(NSString *)localID startBlock:(KDPlayVoiceBlock)startBlock finishBlock:(KDPlayVoiceBlock)finishBlock;
- (void)pauseVoice:(NSString *)localID complete:(KDPauseVoiceBlock)block;
- (void)stopVoice:(NSString *)localID complete:(KDStopVoiceBlock)block;
- (void)uploadVoice:(NSString *)localID complete:(KDUploadVoiceBlock)block;
- (void)downloadVoice:(NSString *)serverId complete:(KDDownloadVoiceBlock)block;

@end
