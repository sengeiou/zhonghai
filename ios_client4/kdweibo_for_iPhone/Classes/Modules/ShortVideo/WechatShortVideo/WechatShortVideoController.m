//
//  WechatShortVideoController.m
//  SCRecorderPack
//
//  Created by AliThink on 15/8/17.
//  Copyright (c) 2015年 AliThink. All rights reserved.
//

// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2015 AliThink
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "WechatShortVideoController.h"
#import "SCRecorder.h"
#import "SCRecordSessionManager.h"
#import "MBProgressHUD.h"
#import "KDCache.h"


@interface WechatShortVideoController () <SCRecorderDelegate, SCAssetExportSessionDelegate, MBProgressHUDDelegate,UIAlertViewDelegate>
//上半部
@property (strong, nonatomic) UIView *scanPreviewView;
@property (strong, nonatomic) UIView *navgationBgView;
//下半部
@property (strong, nonatomic)  UIView *operatorView;
@property (strong, nonatomic)  UIButton *captureTipBtn;
@property (strong, nonatomic)  UIView *middleTipView;
@property (strong, nonatomic)  UIView *middleOperatorRedView;
@property (strong, nonatomic)  UILabel *middleOperatorTip;
@property (strong, nonatomic)  UIButton *captureRealBtn;
@property (strong, nonatomic) SCRecorderToolsView *focusView;
@property (strong, nonatomic)  UIView *middleProgressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleProgressViewWidthConstraint;
@property (strong, nonatomic) NSTimer *exportProgressBarTimer;

@property (strong, nonatomic) MBProgressHUD *progressHUD;

@property (strong, nonatomic) UILabel *showTime;

//退出按钮
@property (strong, nonatomic) UIButton *closeBtn;
//切换摄像头
@property (strong, nonatomic) UIButton *switchBtn;

//重录
@property (strong, nonatomic) UIButton *videoRetakeBtn;
//发送
@property (strong, nonatomic) UIButton *videoConfirmBtn;



@end

@implementation WechatShortVideoController {
    BOOL captureValidFlag;
    SCRecorder *_recorder;
    SCRecordSession *_recordSession;
    NSTimer *longPressTimer;
    
    //Preview
    SCPlayer *_player;
    
    //Video filepath
    NSString *VIDEO_OUTPUTFILE;
    
    NSString *IMAGE_OUTPUTFILE;
    
    BOOL _recordFirst;
}

@synthesize delegate;

#pragma mark - Do Next Func
- (void)doNextWhenVideoSavedSuccess {
    //file path is VIDEO_OUTPUTFILE
//    [self dismissViewControllerAnimated:YES completion:^{
//        if ([self.delegate respondsToSelector:@selector(sendShortVideo:videoUrl:time:andSize:)]) {
//            [self.delegate sendShortVideo:nil videoUrl:VIDEO_OUTPUTFILE time:[NSString stringWithFormat:@"%.1f \"",CMTimeGetSeconds(_recorder.session.duration)] andSize:@"100K"];
//        }}
//     ];
}

- (IBAction)closeAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor blackColor];
    VIDEO_OUTPUTFILE =  [[[KDUtility defaultUtility] searchDirectory:KDDownloadVideosTempDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES]stringByAppendingPathComponent:[NSString stringWithFormat:@"_Video_%f.mp4", [NSDate timeIntervalSinceReferenceDate]]];
    IMAGE_OUTPUTFILE = [[[KDUtility defaultUtility] searchDirectory:KDDownloadVideosTempDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES]stringByAppendingPathComponent:[NSString stringWithFormat:@"_image_%f.png", [NSDate timeIntervalSinceReferenceDate]]];

    
    captureValidFlag = NO;
    _recordFirst = YES;
    
    [self configControlStyle];

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:ASLocalizedString(@"JSBridge_Tip_14"),KD_APPNAME] delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        alertView.tag = 20000;
        [alertView show];
        //        return;
    }else
    {
         [self configRecorder];
         [self setNormalOperatorTipStyle];
    }

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self prepareSession];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_recorder startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.focusView removeFromSuperview];
    _recorder.previewView = nil;
    [_player pause];
    _player = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_recorder stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _recorder.previewView = nil;
    [_player pause];
    _player = nil;
}


#pragma mark - View Config
- (void)configRecorder {
    _recorder = [SCRecorder recorder];
    _recorder.captureSessionPreset = AVCaptureSessionPreset640x480;//[SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    _recorder.maxRecordDuration = CMTimeMake(30 * VIDEO_MAX_TIME, 30);
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = YES;
    
    UIView *previewView = self.scanPreviewView;
    _recorder.previewView = previewView;
    CGRect rect = previewView.bounds;
    rect.origin.y += self.navgationBgView.frame.size.height;
    rect.size.height -= CGRectGetHeight(self.scanPreviewView.frame) + CGRectGetHeight(self.navgationBgView.frame);
    
    self.focusView = [[SCRecorderToolsView alloc] initWithFrame:rect];
    self.focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];
    
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"shortVideo_focus"];
    _recorder.initializeSessionLazily = NO;
    
    NSError *error;
    if (![_recorder prepare:&error]) {
        NSLog(@"Prepare error: %@", error.localizedDescription);
    }
    
    
}

- (void)configControlStyle {
    
    //拍摄区
    CGFloat width = ScreenFullWidth;
    CGFloat scanheigh = ScreenFullWidth * 4/3 ;
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"] || ScreenFullWidth == 320)
    {
        scanheigh = ScreenFullHeight - 64 - 64 ;
        width = scanheigh * 3/4 ;
    }
    self.scanPreviewView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, width, scanheigh)];
    self.scanPreviewView.center = CGPointMake(ScreenFullWidth /2, self.scanPreviewView.center.y);
    self.scanPreviewView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scanPreviewView];

    //顶部导航栏背景
    self.navgationBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenFullWidth, 64)];
    self.navgationBgView.backgroundColor = [UIColor blackColor];
    self.navgationBgView.userInteractionEnabled = YES;
    [self.view addSubview:self.navgationBgView];
    
    //关闭
    self.closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 17, 30, 30)];
    [self.closeBtn setImage:[UIImage imageNamed:@"shortVideo_close"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(quit) forControlEvents:UIControlEventTouchUpInside];
    [self.navgationBgView addSubview:self.closeBtn];
    
    //切换摄像头
    self.switchBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenFullWidth - 50, CGRectGetHeight(self.navgationBgView.frame) / 2 - 15, 40 * 0.8,30 * 0.8)];
    self.switchBtn.backgroundColor = [UIColor clearColor];
    [self.switchBtn setImage:[UIImage imageNamed:@"Switch_Camera_Button"]  forState:UIControlStateNormal];
    [self.switchBtn addTarget:self action:@selector(switchCarme) forControlEvents:UIControlEventTouchUpInside];
    [self.navgationBgView addSubview:self.switchBtn];
    
    //下方操作界面
    self.operatorView = [[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(self.scanPreviewView.frame), ScreenFullWidth, ScreenFullHeight - CGRectGetMaxY(self.scanPreviewView.frame))];
    self.operatorView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.operatorView.userInteractionEnabled = YES;
    [self.view addSubview:self.operatorView];
    
    //进度条
    self.middleProgressView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 3)];
    self.middleProgressView.backgroundColor = UIColorFromRGB(0x3CBAFF);
    [self.operatorView addSubview:self.middleProgressView];
    
   
    self.middleOperatorTip = [[UILabel alloc]initWithFrame:CGRectMake(ScreenFullWidth / 2 - 30, self.scanPreviewView.frame.size.height - 30, 60, 30)];
    self.middleOperatorTip.backgroundColor = [UIColor clearColor];
    self.middleOperatorTip.center = CGPointMake(ScreenFullWidth / 2, self.middleOperatorTip.center.y);
    self.middleOperatorTip.textColor = [UIColor whiteColor];
    self.middleOperatorTip.text = @"0 \"";
    self.middleOperatorTip.textAlignment = NSTextAlignmentCenter;
    [self.scanPreviewView addSubview:self.middleOperatorTip];
    
    self.middleOperatorRedView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_middleOperatorTip.frame)-8, 0, 10, 10)];
    self.middleOperatorRedView.center = CGPointMake(_middleOperatorRedView.center.x, _middleOperatorTip.center.y);
    self.middleOperatorRedView.backgroundColor = [UIColor redColor];
    self.middleOperatorRedView.layer.cornerRadius = 5;
    self.middleOperatorRedView.layer.masksToBounds = YES;
    //闪烁效果
    [self.middleOperatorRedView.layer addAnimation:[self opacityForever_Animation:0.5] forKey:nil];
    self.middleOperatorRedView.hidden = YES;
    [self.scanPreviewView addSubview:self.middleOperatorRedView];
    

    //拍摄按钮
    CGFloat height = self.operatorView.frame.size.height *0.7;
    
    self.captureRealBtn = [[UIButton alloc]initWithFrame:CGRectMake((ScreenFullWidth - height) / 2, (self.operatorView.frame.size.height-height)/2 , height, height)];
    [self.captureRealBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.captureRealBtn setBackgroundImage:[UIImage imageNamed:@"btn_shot_normal"] forState:UIControlStateNormal];
    [self.captureRealBtn setBackgroundImage:[UIImage imageNamed:@"btn_shot_press"] forState:UIControlEventTouchDown];
//    [self.captureRealBtn setTitle:RECORD_BTN_TITLE forState:UIControlStateNormal];
    [self.captureRealBtn addTarget:self action:@selector(captureStartTouchDownAction:) forControlEvents:UIControlEventTouchDown];
    [self.captureRealBtn addTarget:self action:@selector(captureStartTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.captureRealBtn addTarget:self action:@selector(captureStartTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.captureRealBtn addTarget:self action:@selector(captureStartDrayEnter:) forControlEvents:UIControlEventTouchDragEnter];
    [self.captureRealBtn addTarget:self action:@selector(captureStartDragExit:) forControlEvents:UIControlEventTouchDragExit];
    self.captureRealBtn.backgroundColor = [UIColor clearColor];
    [self.operatorView addSubview:self.captureRealBtn];
    
    //重录
    self.videoRetakeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.videoRetakeBtn.frame = CGRectMake(0, 0, 50, 50);
    self.videoRetakeBtn.center = CGPointMake(ScreenFullWidth / 8, self.operatorView.frame.size.height / 2);
    self.videoRetakeBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.videoRetakeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.videoRetakeBtn setTitle:@"重拍" forState:UIControlStateNormal];
    self.videoRetakeBtn.backgroundColor = [UIColor clearColor];
    [self.videoRetakeBtn addTarget:self action:@selector(removePreviewMode) forControlEvents:UIControlEventTouchUpInside];
    [self.operatorView addSubview:self.videoRetakeBtn];
    
    
    //发送
    self.videoConfirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.videoConfirmBtn.frame = CGRectMake(0, 0, 50, 50);
    self.videoConfirmBtn.center = CGPointMake(ScreenFullWidth * 7 / 8, self.operatorView.frame.size.height / 2);
    self.videoConfirmBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.videoConfirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.videoConfirmBtn setTitle:@"发送" forState:UIControlStateNormal];
    self.videoConfirmBtn.backgroundColor = [UIColor clearColor];
    [self.videoConfirmBtn addTarget:self action:@selector(saveCapture) forControlEvents:UIControlEventTouchUpInside];
    [self.operatorView addSubview:self.videoConfirmBtn];

    
    
}


#pragma mark === 永久闪烁的动画 ======
-(CABasicAnimation *)opacityForever_Animation:(float)time
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    //animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];///没有的话是均匀的动画。
    return animation;
}


- (void)prepareSession {
    if (_recorder.session == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeMPEG4;
        
        _recorder.session = session;
    }
}

- (void)initialProgressView {
    self.middleProgressViewWidthConstraint.constant = self.middleTipView.frame.size.width;
}

- (void)refreshProgressViewLengthByTime:(CMTime)duration {
    CGFloat durationTime = CMTimeGetSeconds(duration);
    NSLog(@"%d",(int)durationTime);
    self.middleOperatorTip.text = [NSString stringWithFormat:@"%d \"",(int)durationTime];
    CGFloat progressWidthConstant = durationTime / VIDEO_MAX_TIME * ScreenFullWidth ;
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.middleProgressView.frame;
        rect.size.width = progressWidthConstant;
        self.middleProgressView.frame = rect;
    } completion:^(BOOL finished) {
        
    }];
//    if (durationTime == VIDEO_MAX_TIME) {
////        self.middleOperatorTip.text = [NSString stringWithFormat:@"%f \"",VIDEO_MAX_TIME];
//        [_player pause];
//    }
}

- (void)showMiddleTipView {
    [self setNormalOperatorTipStyle];
    [self initialProgressView];
    [UIView animateWithDuration:0.2 animations:^{
        self.middleTipView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideMiddleTipView {
    [UIView animateWithDuration:0.2 animations:^{
//        self.middleTipView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showCaptureBtn {
    //cancel capture and restore the capture button
    [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        self.captureTipBtn.transform = CGAffineTransformIdentity;
        self.captureTipBtn.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideCaptureBtn {
    //scale and hidden
    [UIView animateWithDuration:0.2 animations:^{
        self.captureTipBtn.transform = CGAffineTransformMakeScale(1.5, 1.5);
        self.captureTipBtn.alpha = 0;
    } completion:^(BOOL finished) {
                
    }];
}

- (void)setNormalOperatorTipStyle {

}


- (void)captureSuccess {
    
    captureValidFlag = YES;
//    longPressTimer = nil;
}



- (void)cancelCaptureWithSaveFlag:(BOOL)saveFlag {
    [_recorder pause:^{
        if (saveFlag) {
            //Preview and save
            [self configPreviewMode];
        } else {
            //retake prepare
            SCRecordSession *recordSession = _recorder.session;
            if (recordSession != nil) {
                _recorder.session = nil;
                if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
                    [recordSession endSegmentWithInfo:nil completionHandler:nil];
                } else {
                    [recordSession cancelSession:nil];
                }
            }
            [self prepareSession];
        }
    }];
}

#pragma mark - Record finish Preview and save
- (void)configPreviewMode {
    if ([self.scanPreviewView viewWithTag:400]) {
        return;
    }

    
    [self showCaptureBtn];
    self.captureRealBtn.enabled = NO;
    
//    _player = [SCPlayer player];
//    SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
//    playerView.tag = 400;
////    playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    playerView.frame = self.scanPreviewView.bounds;
//    playerView.autoresizingMask = self.scanPreviewView.autoresizingMask;
//    [self.scanPreviewView addSubview:playerView];
//    _player.loopEnabled = YES;
//    
//    [_player setItemByAsset:_recorder.session.assetRepresentingSegments];
//    [_player play];

}

- (void)removePreviewMode {
    self.captureRealBtn.enabled = YES;
//    self.middleOperatorRedView.hidden = NO;
    self.videoConfirmBtn.enabled = YES;
    self.middleOperatorTip.text = @"0\"";
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.middleProgressView.frame;
        rect.size.width = 0;
        self.middleProgressView.frame = rect;
    } completion:^(BOOL finished) {
        
    }];

    _recordFirst = YES;
    [_player pause];
    _player = nil;
    _recorder.session = nil;
    for (UIView *subview in self.scanPreviewView.subviews) {
        if (subview.tag == 400) {
            [subview removeFromSuperview];
        }
    }
    for (UIView *subview in self.operatorView.subviews) {
        if (subview.tag == 400) {
            [subview removeFromSuperview];
        }
    }
    
    [self cancelCaptureWithSaveFlag:NO];
    [self showCaptureBtn];
}

- (void)quit
{
    if ([_recorder.session.segments count] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:ASLocalizedString(@"Giveup_Video") delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel") otherButtonTitles:ASLocalizedString(@"Global_Sure"), nil];
        
        [alertView show];
    }else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)switchCarme
{
    [_recorder switchCaptureDevices];
}
- (void)saveCapture {
    
    self.videoConfirmBtn.enabled = NO;
    if (!([_recorder.session.segments count] >0)) {
        return;
    }
    [_player pause];
    
    
    
    if ((int)CMTimeGetSeconds(_recorder.session.duration) < 2) {
        self.videoConfirmBtn.enabled = YES;
        self.progressHUD = [[MBProgressHUD alloc]initWithView:self.operatorView];
        self.progressHUD.labelText =@"录制时长不低于2秒";
        self.progressHUD.mode = MBProgressHUDModeCustomView;
        [self.operatorView addSubview:self.progressHUD];
        [self.progressHUD show:YES];
        [self.progressHUD hide:YES afterDelay:2];
        return;
    }
    
    void(^completionHandler)(NSURL *url, NSError *error) = ^(NSURL *url, NSError *error) {
        if (error == nil) {
//            [[UIApplication sharedApplication] beginIgnoringInteractionEvent];
//            UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
           
        } else {
            self.progressHUD.labelText = [NSString stringWithFormat:@"Failed to save\n%@", error.localizedDescription];
            self.progressHUD.mode = MBProgressHUDModeCustomView;
            [self.progressHUD hide:YES afterDelay:3];
        }
    };
    
    
    SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:_recorder.session.assetRepresentingSegments];
    exportSession.videoConfiguration.preset = SCPresetLowQuality;
    exportSession.audioConfiguration.preset = SCPresetLowQuality;
    exportSession.videoConfiguration.maxFrameRate = 30;
    exportSession.outputUrl = [NSURL fileURLWithPath:VIDEO_OUTPUTFILE] ;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.delegate = self;
    
    
    SCRecordSessionSegment *segment = _recorder.session.segments.firstObject;
    [self savePickedImage:[segment thumbnail]];
    
    
   
    
    CFTimeInterval time = CACurrentMediaTime();
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
//        [_player play];
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:VIDEO_OUTPUTFILE error:nil];
        NSNumber *size = [attributes objectForKey:NSFileSize];
        
        
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(sendShortVideo:urlArray:time:andSize:)]) {
                [self.delegate sendShortVideo:nil urlArray:@[IMAGE_OUTPUTFILE,VIDEO_OUTPUTFILE] time:[NSString stringWithFormat:@"%d",(int)CMTimeGetSeconds(_recorder.session.duration)] andSize:[NSString stringWithFormat:@"%d",size.intValue]];
            }
        }];

        NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
        
//        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        completionHandler(exportSession.outputUrl, exportSession.error);
    }];
}
- (void)savePickedImage:(UIImage *)image {
    
    // original image
    CGSize previewSize = CGSizeMake(800.0f, 600.0f);
    if(image.size.width > previewSize.width || image.size.height > previewSize.height){
        image = [image scaleToSize:previewSize type:KDImageScaleTypeFill];
    }
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    
    if ([self isCompressed:data]) {
        data = UIImageJPEGRepresentation(image, 0.75);
    }
    
    [[NSFileManager defaultManager] createFileAtPath:IMAGE_OUTPUTFILE contents:data attributes:nil];
    
    //
//    NSDictionary *callbackInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  [NSNumber numberWithBool:YES], @"created",
//                                  [NSNumber numberWithBool:NO], @"showedThumbnail", nil];
//    
//    [self performSelectorOnMainThread:@selector(didSavePickedImageWithInfo:) withObject:callbackInfo waitUntilDone:[NSThread isMainThread]];
    
}

- (BOOL)isCompressed:(NSData *)data
{
    float size = data.length / 1024.;
    return size > 200.f;
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    hud = nil;
}

#pragma mark - SCRecorderDelegate
- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    //update progressBar
    [self refreshProgressViewLengthByTime:recordSession.duration];
}

- (void)recorder:(SCRecorder *__nonnull)recorder didCompleteSession:(SCRecordSession *__nonnull)session {
    //confirm capture
    
    [_recorder pause];
    self.captureRealBtn.enabled = NO;
    self.middleOperatorRedView.hidden = YES;
    
//    [self hideMiddleTipView];
//    if (captureValidFlag) {
//        //preview and save video
//        [self cancelCaptureWithSaveFlag:YES];
//    } else {
//        [self cancelCaptureWithSaveFlag:NO];
//        [self showCaptureBtn];
//    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    if (error == nil) {
        self.progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WechatShortVideo_37x-Checkmark.png"]];
        self.progressHUD.mode = MBProgressHUDModeCustomView;
        [self.progressHUD hide:YES afterDelay:1];

        //return the filepath
        [self removePreviewMode];
        [self doNextWhenVideoSavedSuccess];
        
        if ([delegate respondsToSelector:@selector(finishWechatShortVideoCapture:)]) {
            [delegate finishWechatShortVideoCapture:[NSURL URLWithString:VIDEO_OUTPUTFILE]];
        }
    } else {
        self.progressHUD.labelText = [NSString stringWithFormat:@"Failed to save\n%@", error.localizedDescription];
        self.progressHUD.mode = MBProgressHUDModeCustomView;
        [self.progressHUD hide:YES afterDelay:3];
    }
}

#pragma mark - SCAssetExportSessionDelegate
- (void)assetExportSessionDidProgress:(SCAssetExportSession *)assetExportSession {
    dispatch_async(dispatch_get_main_queue(), ^{
        float progress = assetExportSession.progress;
        self.progressHUD.progress = progress;
    });
}

#pragma mark - Center Record Btn ActionEvent
- (void)captureStartDragExit:(UIButton *)captureBtn {
    [UIView transitionWithView:self.middleOperatorTip duration:0.2 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
//        [self setReleaseOperatorTipStyle];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)captureStartDrayEnter:(UIButton *)captureBtn {
    [UIView transitionWithView:self.middleOperatorTip duration:0.2 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{

    } completion:^(BOOL finished) {
        
    }];
}

- (void)captureStartTouchUpInside:(UIButton *)captureBtn {
    //confirm capture
//    [self hideMiddleTipView];
//    if (captureValidFlag) {
//        //preview and save video
//        [self cancelCaptureWithSaveFlag:YES];
//    } else {
////        [self cancelCaptureWithSaveFlag:NO];
////        [self showCaptureBtn];
    [_recorder pause];
    _middleOperatorRedView.hidden = YES;
//        self.captureRealBtn.enabled = YES;
    [self showCaptureBtn];
//    }
}

- (void)captureStartTouchUpOutside:(UIButton *)captureBtn {
    if (self.captureRealBtn.enabled) {
        [self showCaptureBtn];
    }
    [self hideMiddleTipView];
    [self cancelCaptureWithSaveFlag:NO];
}

- (void)captureStartTouchDownAction:(UIButton *)captureBtn {
    
    captureValidFlag = NO;
    _recordFirst = NO;
    if (longPressTimer) {
        [longPressTimer invalidate];
        longPressTimer = nil;
    }
    longPressTimer = [NSTimer scheduledTimerWithTimeInterval:VIDEO_VALID_MINTIME target:self selector:@selector(captureSuccess) userInfo:nil repeats:NO];

    [_recorder record];
    _middleOperatorRedView.hidden = NO;
    [self showCaptureBtn];
    [self showMiddleTipView];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 || alertView.tag == 20000) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
