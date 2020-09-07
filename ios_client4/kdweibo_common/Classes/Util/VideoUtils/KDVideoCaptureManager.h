//
//  VideoCapture.h
//  Video-Pre-research
//
//  Created by 王 松 on 13-6-6.
//  Copyright (c) 2013年 王松. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@protocol KDVideoCaptureManagerDelegate;

@interface KDVideoCaptureManager : NSObject

@property (nonatomic,assign) id <KDVideoCaptureManagerDelegate> delegate;

@property (nonatomic, assign, getter = isStarted) BOOL started;

@property(readonly, getter=isRecording) BOOL recording;

@property (nonatomic, assign) CGFloat maxSeconds;

@property (nonatomic, assign) CGFloat minSeconds;

- (void)startCaptureWithOutputPath:(NSString *)outputFileURL;

- (void)setupAndStartCaptureSession;

- (void)setupVideoPreviewLayer:(UIView *)view;

- (void)stopAndTearDownCaptureSession;

- (void)stopRecording;

- (void)pauseCaptureSession; // Pausing while a recording is in progress will cause the recording to be stopped and saved.
- (void)resumeCaptureSession;

- (BOOL)switchCamera;

- (void)autoFocusAtPoint:(CGPoint)point;

- (void)continuousFocusAtPoint:(CGPoint)point;

- (BOOL)hasTorch;

- (void)toggleTorch:(BOOL)on;

- (void)showError:(NSError*)error;

- (void)saveVideoToAlbums:(NSString *)path withBlock:(void(^)(BOOL result))block;

+ (CGFloat)secondsOfVideoOfPath:(NSString *)path;

+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

@end

@protocol KDVideoCaptureManagerDelegate <NSObject>

@optional
- (void)captureManager:(KDVideoCaptureManager *)captureManager didFailWithError:(NSError *)error;
- (void)captureManagerRecordingBegan:(KDVideoCaptureManager *)captureManager;
- (void)captureManagerRecordingFinished:(KDVideoCaptureManager *)captureManager;
- (void)captureManagerDeviceConfigurationChanged:(KDVideoCaptureManager *)captureManager;
- (void)captureManager:(KDVideoCaptureManager *)captureManager captureProgress:(CGFloat)progress;

@required
- (void)recordingWillStart;
- (void)recordingDidStart;
- (void)recordingWillStop;
- (void)recordingDidStop;

@end;
