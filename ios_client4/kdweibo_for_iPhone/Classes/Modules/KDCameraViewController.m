//
//  KDCameraViewController.m
//  HHCamera_OC
//
//  Created by kingdee on 2017/10/9.
//  Copyright © 2017年 kingdee. All rights reserved.
//

#import "KDCameraViewController.h"
#import "KDCameraManager.h"
#import "KDPreviewView.h"

#import "KDImageEditorViewController.h"
#import "UIImage+Rotate.h"

@interface KDCameraViewController ()<KDCameraManagerDelegate, KDPreviewViewDelegate, KKImageEditorDelegate>

@property (nonatomic, strong) KDCameraManager *cameraManager;
@property (nonatomic, strong) KDPreviewView *previewView;
@end

@implementation KDCameraViewController

#pragma mark - lazy load
- (KDCameraManager *)cameraManager {
    if (!_cameraManager) {
        _cameraManager = [KDCameraManager new];
        _cameraManager.delegate = self;
    }
    return _cameraManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor blackColor];
        
    }
    return self;
}

- (void)setupView {
    if ([self.cameraManager canSwitchCameras]) {
        UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        switchBtn.frame = CGRectMake(self.view.frame.size.width - 12 - 30, 34, 30, 20);
        [switchBtn setBackgroundImage:[UIImage imageNamed:@"icon_camera_switch"] forState:UIControlStateNormal];
        [switchBtn addTarget:self action:@selector(handleSwitchCamera) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:switchBtn];
    }
    
    
    self.previewView = [[KDPreviewView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64 - 120)];
    [self.view addSubview:self.previewView];
    
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.previewView.frame), self.view.frame.size.width, 120)];
    overlayView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:overlayView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(12, 40, 56, 42);
    [cancelBtn setTitle:ASLocalizedString(@"Global_Cancel") forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:cancelBtn];
    
    UIButton *captureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    captureBtn.frame = CGRectMake(self.view.frame.size.width/2 - 35, 25, 70, 70);
    [captureBtn setBackgroundImage:[UIImage imageNamed:@"camera_capture"] forState:UIControlStateNormal];
    [captureBtn addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:captureBtn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
    NSError *error;
    if ([self.cameraManager setupSession:&error]) {
        [self.previewView setSession:self.cameraManager.captureSession];
        self.previewView.delegate = self;
        [self.cameraManager startSession];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    self.previewView.tapToFocusEnabled = self.cameraManager.cameraSupportsTapToFocus;
    self.previewView.tapToExposeEnabled = self.cameraManager.cameraSupportsTapToExpose;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.cameraManager startSession];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.cameraManager stopSession];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)handleSwitchCamera {
    
    [self.cameraManager switchCameras];
    self.previewView.tapToExposeEnabled = self.cameraManager.cameraSupportsTapToExpose;
    self.previewView.tapToFocusEnabled = self.cameraManager.cameraSupportsTapToFocus;
    [self.cameraManager resetFocusAndExposureModes];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)capture {
    [self.cameraManager captureStillImage];
}

#pragma mark - KDPreviewViewDelegate
- (void)tappedToFocusAtPoint:(CGPoint)point {
    [self.cameraManager focusAtPoint:point];
}
- (void)tappedToExposeAtPoint:(CGPoint)point {
    [self.cameraManager exposeAtPoint:point];
}
- (void)tappedToResetFocusAndExposure {
    [self.cameraManager resetFocusAndExposureModes];
}

#pragma mark - KDCameraManagerDelegate
- (void)captureStillImageWithManager:(KDCameraManager *)cameraManager image:(UIImage *)image {
    
    DLog(@"image = %@", image);
    
    KDImageEditorViewController *imageEditorVC = [[KDImageEditorViewController alloc] initWithImage:[image fixOrientation] delegate:self];
    imageEditorVC.isFromCamera = YES;
//    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:imageEditorVC];
    [self presentViewController:imageEditorVC animated:NO completion:nil];
    
}

#pragma mark - KKImageEditorDelegate
- (void)imageDidFinishEdittingWithImage:(UIImage*)image {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (image) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraViewController:WithImage:)]) {
            [self.delegate cameraViewController:self WithImage:image];
        }
    }
}

@end
