//
//  KDCameraManager.m
//  HHCamera_OC
//
//  Created by kingdee on 2017/10/9.
//  Copyright © 2017年 kingdee. All rights reserved.
//

#import "KDCameraManager.h"
#import <UIKit/UIKit.h>

@interface KDCameraManager()

@property (strong, nonatomic) dispatch_queue_t videoQueue;
@property (nonatomic, strong) AVCaptureSession *captureSession;// 捕捉会话
@property (nonatomic, weak) AVCaptureDeviceInput *activeVideoInput;//输入
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput; //ios10之后由 AVCapturePhotoOutput代替，到时候考虑一下适配
@end

@implementation KDCameraManager


#pragma mark - 用于设置、配置视频捕捉会话
- (BOOL)setupSession:(NSError **)error {
    self.captureSession = [AVCaptureSession new];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    } else {
        return NO;
    }
    
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.imageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
    
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    
    self.videoQueue = dispatch_queue_create("kingdee.VideoQueue", NULL);
    
    return YES;
}
- (void)startSession {
    if (![self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession startRunning];
        });
    }
}
- (void)stopSession {
    if ([self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}


#pragma mark - 切换不同的摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devicess = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devicess) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}
- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}
- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}
- (BOOL)switchCameras {
    if (![self canSwitchCameras]) {
        return NO;
    }
    
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (videoInput) {
        [self.captureSession beginConfiguration];
        
        [self.captureSession removeInput:self.activeVideoInput];
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            [self.captureSession addInput:self.activeVideoInput];
        }
        
        [self.captureSession commitConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
        return NO;
    }
    
    return YES;
}
- (BOOL)canSwitchCameras {
    return self.cameraCount > 1;
}
- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}


#pragma mark - 聚焦、曝光、重设聚焦、曝光的方法
- (BOOL)cameraSupportsTapToFocus {
    return [[self activeCamera] isFocusPointOfInterestSupported];
}
- (void)focusAtPoint:(CGPoint)point {
    
    AVCaptureDevice *device = [self activeCamera];
    
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusMode = AVCaptureFocusModeAutoFocus;
            device.focusPointOfInterest = point;
            [device unlockForConfiguration];
        }else{
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

- (BOOL)cameraSupportsTapToExpose {
    return [[self activeCamera] isExposurePointOfInterestSupported];
}
static const NSString *THCameraAdjustingExposureContext;
- (void)exposeAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode =AVCaptureExposureModeContinuousAutoExposure;
    
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
        
        NSError *error;
        
        //锁定设备准备配置
        if ([device lockForConfiguration:&error])
        {
            //配置期望值
            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;
            
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                //使用kvo确定设备的adjustingExposure属性的状态。
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&THCameraAdjustingExposureContext];
            }
            
            //释放该锁定
            [device unlockForConfiguration];
            
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
        
        
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (context == &THCameraAdjustingExposureContext) {
        
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        if(!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            //移除作为adjustingExposure 的self，就不会得到后续变更的通知
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&THCameraAdjustingExposureContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    
                    device.exposureMode = AVCaptureExposureModeLocked;
                    
                    [device unlockForConfiguration];
                    
                }else
                {
                    [self.delegate deviceConfigurationFailedWithError:error];
                }
            });
            
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)resetFocusAndExposureModes {
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported]&& [device isFocusModeSupported:focusMode];
    
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    BOOL canResetExposure = [device isFocusPointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    
    //捕捉设备空间左上角（0，0），右下角（1，1） 中心点则（0.5，0.5）
    CGPoint centPoint = CGPointMake(0.5f, 0.5f);
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centPoint;
        }
        
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centPoint;
            
        }
        
        [device unlockForConfiguration];
        
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
    }
}

#pragma mark - 实现捕捉静态图片
- (void)captureStillImage {
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    
    __weak KDCameraManager *weakSelf = self;
    //定义一个handler 块，会返回1个图片的NSData数据
    id handler = ^(CMSampleBufferRef sampleBuffer,NSError *error) {
        if (sampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(captureStillImageWithManager:image:)]) {
                [weakSelf.delegate captureStillImageWithManager:weakSelf image:image];
            }
        }else
        {
            NSLog(@"NULL sampleBuffer:%@",[error localizedDescription]);
        }
        
    };
    
    //捕捉静态图片
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:handler];
    
}
//获取方向值
- (AVCaptureVideoOrientation)currentVideoOrientation {
    
    AVCaptureVideoOrientation orientation;
    
    //获取UIDevice 的 orientation
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    
    return orientation;
    
    return 0;
}

@end
