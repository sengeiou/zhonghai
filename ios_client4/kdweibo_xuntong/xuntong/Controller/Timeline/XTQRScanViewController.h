//
//  XTQRScanViewController.h
//  XT
//
//  Created by Gil on 13-8-23.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//#import <Decoder.h>
//#import <OverlayView.h>
#import "KDQRScanView.h"
#import "KDQRAnalyse.h"



@protocol XTQRScanViewControllerDelegate;
@protocol XTQRScanViewControllerJSBridgeDelegate;
@interface XTQRScanViewController : UIViewController <UIAlertViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, weak) id<XTQRScanViewControllerDelegate> delegate;
@property (nonatomic, weak) id<XTQRScanViewControllerJSBridgeDelegate> JSBridgeDelegate;
@property (nonatomic, assign) BOOL isFromJSBridge;
@property (nonatomic, assign) int isFromJSBridgeAndNeedResult;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, assign) BOOL isScanning;
//@property (nonatomic, strong) OverlayView *overlayView;
@property (nonatomic, strong) UILabel *instructionLabel;
@property (nonatomic, strong) NSString *qrUrl;
@property (nonatomic, weak) UIViewController *controller;

- (void)onCapture;
@end

@protocol XTQRScanViewControllerDelegate <NSObject>
@optional
- (void)qrScanViewController:(XTQRScanViewController *)controller loginCode:(int)qrLoginCode result:(NSString *)result;
- (void)qrScanViewControllerDidCancel:(XTQRScanViewController *)controller;
- (void)loadWebViewControllerWithUrl:(NSString *)url;
- (void)publicDetailControllerWithperson:(NSString *)person;
@end

@protocol XTQRScanViewControllerJSBridgeDelegate <NSObject>
@optional
-(void)theURL:(NSString *)url;
@end
