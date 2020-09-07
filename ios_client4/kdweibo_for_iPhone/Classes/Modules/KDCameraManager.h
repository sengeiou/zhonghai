//
//  KDCameraManager.h
//  HHCamera_OC
//
//  Created by kingdee on 2017/10/9.
//  Copyright © 2017年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class KDCameraManager;
@protocol KDCameraManagerDelegate <NSObject>
@optional
// 1发生错误事件是，需要在对象委托上调用一些方法来处理
- (void)deviceConfigurationFailedWithError:(NSError *)error;
- (void)mediaCaptureFailedWithError:(NSError *)error;
- (void)assetLibraryWriteFailedWithError:(NSError *)error;
//
- (void)captureStillImageWithManager:(KDCameraManager *)cameraManager image:(UIImage *)image;

@end

@interface KDCameraManager : NSObject

@property (nonatomic, weak) id <KDCameraManagerDelegate> delegate;
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;

// 2 用于设置、配置视频捕捉会话
- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;

// 3 切换不同的摄像头
- (BOOL)switchCameras;
- (BOOL)canSwitchCameras;
@property (nonatomic, readonly) NSUInteger cameraCount;
@property (nonatomic, readonly) BOOL cameraSupportsTapToFocus; //聚焦
@property (nonatomic, readonly) BOOL cameraSupportsTapToExpose;//曝光

// 4 聚焦、曝光、重设聚焦、曝光的方法
- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExposureModes;

// 5 实现捕捉静态图片
- (void)captureStillImage;

@end
