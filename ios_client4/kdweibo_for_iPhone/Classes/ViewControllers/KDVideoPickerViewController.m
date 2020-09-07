//
//  KDVideoPickerViewController.m
//  kdweibo
//
//  Created by 王 松 on 13-7-11.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDVideoPickerViewController.h"

#import "KDVideoCaptureManager.h"

#import "KDVideoPlayerController.h"

#import "MBProgressHUD.h"

#import <AVFoundation/AVFoundation.h>

#import <QuartzCore/QuartzCore.h>

#define kMaxTime (float)30.

@interface KDVideoPickerViewController ()<KDVideoCaptureManagerDelegate, KDVideoPlayerManagerDelegate>
{
    NSTimer *timer;
}

@property (nonatomic, retain) NSString *videoPath;

@property (nonatomic, retain) KDVideoCaptureManager *videoCapture;

@property (nonatomic, retain) UIView *bottomView;

@property (nonatomic, retain) UIView *topView;

@property (nonatomic, retain) UIView *previewView;

@property (nonatomic, retain) UIView *playView;

@property (nonatomic, retain) UIButton *playButton;

@property (nonatomic, retain) UIButton *sendButton;

@property (nonatomic, retain) UIButton *saveButton;

@property (nonatomic, retain) UILabel *sizeLabel;

@property (nonatomic, retain) UILabel *timeLabel;

@property (nonatomic, retain) UILabel *hintLabel;

@property (nonatomic, retain) UIImageView *recImageView;

@property (nonatomic, retain) UILabel *recLabel;

@property (nonatomic, retain) UILabel *playTimeLabel;

@property (nonatomic, retain) UILabel *overTimeHintView;

@property (nonatomic, assign) NSUInteger videoDuration;

@property (nonatomic, retain) UIImageView *loadingView;

@property (nonatomic, retain) UIView *hudShowView;

@property (nonatomic, assign) BOOL isCancel;

@property (nonatomic, assign) BOOL recordPermissionGranted;

- (void)switchCamera:(UIButton *)sender;

- (void)toggleTorch:(UIButton *)sender;

- (void)toggleCapture:(UIButton *)sender;

- (void)stopCapture:(UIButton *)sender;

- (void)toggleTorchButton;

- (void)cancelCapture;

@end

@implementation KDVideoPickerViewController

- (id)initWithVideoPath:(NSString *)videoPath
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _videoPath = videoPath ;//retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
    [MBProgressHUD showHUDAddedTo:_hudShowView animated:NO];
//    if(isAboveiOS7) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if(granted) {
                self.recordPermissionGranted = YES;
            }else {
                self.recordPermissionGranted = NO;
            }
        }];
//    }else {
//        self.recordPermissionGranted = YES;
//    }
    [self performSelector:@selector(initComponent) withObject:nil afterDelay:0.1];
}

- (void)initComponent
{
    //init viewCapture Manager
    
    _videoCapture = [[KDVideoCaptureManager alloc] init];
    _videoCapture.delegate = self;
    _videoCapture.maxSeconds = kMaxTime;
    _videoCapture.minSeconds = 2.0f;
    [_videoCapture setupAndStartCaptureSession];
    [_videoCapture setupVideoPreviewLayer:_previewView];
    self.loadingView.hidden = YES;
    _hudShowView.hidden = YES;
    [MBProgressHUD hideAllHUDsForView:_hudShowView animated:YES];
    [self toggleTorchButton];
}

#define kTorchBtnTag (int)10001
#define kCaptureBtnTag (int)10002
#define kSwitcheBtnTag (int)10003

- (void)setupViews
{
    self.view.backgroundColor = RGBCOLOR(55.f, 59.f, 63.f);
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // init bottom viewp
    CGFloat originY = screenHeight - 90.0f;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        originY =  screenHeight - 90.0f -[UIApplication sharedApplication].statusBarFrame.size.height;
    }
    CGRect bottomRect = CGRectMake(0.0f, originY, self.view.frame.size.width, 90.0f);
    _bottomView = [[UIView alloc] initWithFrame:bottomRect];
    
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom] ;//retain];
    [_saveButton setTitle:ASLocalizedString(@"KDVideoPickerViewController_save")forState:UIControlStateNormal];
    _saveButton.frame = CGRectMake(15.0f, (bottomRect.size.height - 34.f) / 2.0f, 64.f, 34.f);
    [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveButton setTitleColor:RGBCOLOR(26.f, 133.f, 255.f) forState:UIControlStateHighlighted];
    [_saveButton addTarget:self action:@selector(saveVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    
                   _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
    [_sendButton setTitle:ASLocalizedString(@"KDVideoPickerViewController_Use")forState:UIControlStateNormal];
    _sendButton.frame = CGRectMake(bottomRect.size.width - 64.f - 15.0f, (bottomRect.size.height - 34.f) / 2.0f, 64.f, 34.f);
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendButton setTitleColor:RGBCOLOR(26.f, 133.f, 255.f) forState:UIControlStateHighlighted];
    [_sendButton addTarget:self action:@selector(sendVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *captureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [captureBtn setImage:[UIImage imageNamed:@"camera-shutter-video-default.png"] forState:UIControlStateNormal];
    [captureBtn setImage:[UIImage imageNamed:@"camera-shutter-video-default-active.png"] forState:UIControlStateHighlighted];
    [captureBtn setImage:[UIImage imageNamed:@"camera-shutter-video-default-active.png"] forState:UIControlStateSelected];
    captureBtn.frame = CGRectMake((bottomRect.size.width - 75.0f) / 2.f, (bottomRect.size.height - 75.f) / 2.f, 75.0f, 75.0f);
    [captureBtn addTarget:self action:@selector(toggleCapture:) forControlEvents:UIControlEventTouchUpInside];
    captureBtn.tag = kCaptureBtnTag;
    
    [_bottomView addSubview:captureBtn];
    [_bottomView addSubview:_saveButton];
    [_bottomView addSubview:_sendButton];
    
    [self.view addSubview:_bottomView];
    
    CGFloat topY = 0.0;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        topY =  [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    
    //init top view and preview view
    CGRect topRect = CGRectMake(0.0f, topY, self.view.frame.size.width, 44.0f);
    
    _topView = [[UIView alloc] initWithFrame:topRect];
    
    UIButton *switchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *switchImage = [UIImage imageNamed:@"camera-glyph-cameratoggle.png"];
    [switchCameraBtn setImage:switchImage forState:UIControlStateNormal];
    switchCameraBtn.frame = CGRectMake(topRect.size.width - 67.0f, (topRect.size.height - 39.f) / 2.0f, 57.f, 39.f);
    [switchCameraBtn addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
    switchCameraBtn.tag = kSwitcheBtnTag;
    
    
    UIButton *torchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *torchImage = [UIImage imageNamed:@"camera_torch.png"];
    [torchCameraBtn setImage:torchImage forState:UIControlStateSelected];
    torchCameraBtn.frame = CGRectMake(topRect.size.width - 134.f, (topRect.size.height - 39.f) / 2.0f, 57.f, 39.f);
    [torchCameraBtn setImage:[UIImage imageNamed:@"camera_torch_disabled.png"] forState:UIControlStateNormal];
    torchCameraBtn.selected = YES;
    [torchCameraBtn addTarget:self action:@selector(toggleTorch:) forControlEvents:UIControlEventTouchUpInside];
    torchCameraBtn.tag = kTorchBtnTag;
   
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [UIImage imageNamed:@"video_camera_back.png"];
    backBtn.frame = CGRectMake(10.f, (topRect.size.height - 39.f) / 2.0f, 57.f, 39.f);
    [backBtn setImage:backImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(cancelCapture) forControlEvents:UIControlEventTouchUpInside];
    
    [_topView addSubview:backBtn];
    [_topView addSubview:torchCameraBtn];
    [_topView addSubview:switchCameraBtn];
    [self.view addSubview:_topView];
    
    
    CGRect previewRect = CGRectMake((self.view.frame.size.width - 280.f) / 2. , topRect.size.height + topRect.origin.y + 10.f, 280.f, self.view.frame.size.height - topY - topRect.size.height - bottomRect.size.height - 40.0f);
    
    _previewView = [[UIView alloc] initWithFrame:previewRect];
    _previewView.layer.borderWidth = 2.f;
    _previewView.layer.borderColor = [UIColor blackColor].CGColor;
    
    _loadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_for_loading.png"]];
    _loadingView.frame = CGRectMake((_previewView.frame.size.width - _loadingView.frame.size.width) / 2.f, (_previewView.frame.size.height - _loadingView.frame.size.height) / 2.f, _loadingView.frame.size.width, _loadingView.frame.size.height);
    [_previewView addSubview:_loadingView];
    
    _hudShowView = [[UIView alloc] initWithFrame:CGRectMake((previewRect.size.width - 120.f) / 2.f, previewRect.size.height - 82.f, 120.f, 80.f)];
    _hudShowView.backgroundColor = [UIColor clearColor];
    [_previewView addSubview:_hudShowView];
    
    
    _playView = [[UIView alloc] initWithFrame:_previewView.bounds];
    _playView.hidden = YES;
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom] ;//retain];
    [_playButton setImage:[UIImage imageNamed:@"videoplay.png"] forState:UIControlStateNormal];
    _playButton.frame = CGRectMake((_playView.frame.size.width - 80.0f) / 2., (_playView.frame.size.height - 80.0f) / 2., 80.0f, 80.0f);
    [_playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    [_playView addSubview:_playButton];
    [_previewView addSubview:_playView];
    
    
    _recImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera-shutter-video-recording.png"]];
    _recImageView.frame = CGRectMake(5.0f, 5.0f, 30.0f, 30.f);
    [_previewView addSubview:_recImageView];
    
    _recLabel = [[UILabel alloc] initWithFrame:CGRectMake(_recImageView.frame.origin.x  + _recImageView.frame.size.width + 2.0f, 3.0f, 60.0f, 30.f)];
    _recLabel.backgroundColor = [UIColor clearColor];
    [_recLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [_recLabel setTextAlignment:NSTextAlignmentLeft];
    [_recLabel setTextColor:[UIColor whiteColor]];
    [_recLabel setText:@"REC"];
    [_previewView addSubview:_recLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(previewRect.size.width - 50.0f - 5.0f, 3.0f, 50.0f, 30.f)];
    _timeLabel.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5];
    _timeLabel.layer.masksToBounds = YES;
    _timeLabel.layer.cornerRadius = 10.f;
    [_timeLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [_timeLabel setTextAlignment:NSTextAlignmentCenter];
    [_timeLabel setTextColor:[UIColor whiteColor]];
    [_previewView addSubview:_timeLabel];
    
    [self.view addSubview:_previewView];
    
    _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80.f - 18.f, previewRect.size.height + previewRect.origin.y + 10.f, 80.f, 20.0f)];
    _sizeLabel.backgroundColor = [UIColor clearColor];
    [_sizeLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_sizeLabel setTextAlignment:NSTextAlignmentRight];
    [_sizeLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:_sizeLabel];
    
    _playTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.f, previewRect.size.height + previewRect.origin.y + 10.f, 80.f, 20.0f)];
    _playTimeLabel.backgroundColor = [UIColor clearColor];
    [_playTimeLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_playTimeLabel setTextAlignment:NSTextAlignmentLeft];
    [_playTimeLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:_playTimeLabel];
    
    _hintLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 220.f) / 2, previewRect.size.height + previewRect.origin.y + 5.f, 220.f, 20.0f)];
    _hintLabel.backgroundColor = [UIColor clearColor];
    [_hintLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_hintLabel setTextAlignment:NSTextAlignmentCenter];
    [_hintLabel setTextColor:[UIColor grayColor]];
    [self.view addSubview:_hintLabel];
    
    [self showHintLabel:YES];
    [self updateTimeLabel:0];
    [self showSendAndSaveButton:NO];
}

- (void)toggleCapture:(UIButton *)sender {
    if (!self.recordPermissionGranted) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDVideoPickerViewController_RecordVideo_fail")message:[NSString stringWithFormat:ASLocalizedString(@"KDVideoPickerViewController_Tips"),KD_APPNAME] delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alert show];
//        [alert release];
        return;
    }
    if (!sender.selected) {
        sender.selected = !sender.selected;
        [_videoCapture startCaptureWithOutputPath:self.videoPath];
        [self setCaptureEnable:NO];
        UIButton *switchBtn = (UIButton *)[self.topView viewWithTag:kSwitcheBtnTag];
        switchBtn.enabled = NO;
    } else {
        [self stopCapture:nil];
        sender.selected = YES;
        sender.enabled = NO;
    }
    [self showHintLabel:YES];
    [self setRECBlink:sender.selected];
}

- (void)stopCapture:(UIButton *)sender
{
    [_videoCapture stopRecording];
}

- (void)switchCamera:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [_videoCapture switchCamera];
    [self toggleTorchButton];
}

- (void)toggleTorch:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [_videoCapture toggleTorch:sender.selected];
}

- (void)playVideo
{
    KDVideoPlayerManager *player = [KDVideoPlayerManager sharedInstance];
    player.contentURL = [NSURL fileURLWithPath:self.videoPath];
    player.delegate = self;
    self.playButton.enabled = NO;
    [player startPlayInView:_playView];
    self.playTimeLabel.text = @"";
    self.playTimeLabel.hidden = NO;
}

- (void)toggleTorchButton
{
    UIButton *torchCameraBtn = (UIButton *)[_topView viewWithTag:kTorchBtnTag];
    torchCameraBtn.selected = !torchCameraBtn.selected;
    torchCameraBtn.hidden = ![_videoCapture hasTorch];
}

- (void)cancelCapture
{
    [[KDVideoPlayerManager sharedInstance] stopPlay];
    [_videoCapture pauseCaptureSession];

    [_videoCapture stopRecording];
    
    _isCancel = YES;
    if ([self.delegate respondsToSelector:@selector(videoCaptureFinished:filePath:)]) {
        [self.delegate videoCaptureFinished:!_isCancel filePath:self.videoPath];
    }
}

- (void)showSizeLabel:(BOOL)show
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoPath] && show) {
        self.sizeLabel.hidden = NO;
        self.sizeLabel.text = [self videoSize];
    }else {
        self.sizeLabel.hidden = YES;
    }
}

- (NSString *)videoSize
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.videoPath error:nil];
    NSNumber *size = [attributes objectForKey:NSFileSize];

    NSString *result = @"";
    if (size.intValue / 1024 >= 1024) {
        result = [NSString stringWithFormat:@"%.2fMB", size.floatValue / 1024. / 1024.];
    }else {
        result = [NSString stringWithFormat:@"%dKB", (int)size.intValue / 1024];
    }
    return result;
}


- (void)showHintLabel:(BOOL)show
{
    _hintLabel.hidden = !show;
     UIButton *capture = (UIButton *)[_bottomView viewWithTag:kCaptureBtnTag];
    if (capture.selected) {
        _hintLabel.text = ASLocalizedString(@"KDVideoPickerViewController_ending");
    } else {
        _hintLabel.text = ASLocalizedString(@"KDVideoPickerViewController_start");
    }
}

- (void)showPlayView:(BOOL)show
{
    _playView.hidden = !show;
}

- (void)captureFinish
{
    _videoDuration = ceil([KDVideoCaptureManager secondsOfVideoOfPath:self.videoPath]);
    _videoDuration = _videoDuration == 0 ? _videoDuration = 1 : _videoDuration;
    
    UIButton *switchBtn = (UIButton *)[self.topView viewWithTag:kSwitcheBtnTag];
    switchBtn.enabled = NO;
    UIButton *torchCameraBtn = (UIButton *)[_topView viewWithTag:kTorchBtnTag];
    torchCameraBtn.enabled =  NO;
    [self showSizeLabel:!_isCancel];
    [self showHintLabel:NO];
    [self showSendAndSaveButton:YES];
    [self setCaptureEnable:NO];
    [self setRECBlink:NO];
    [self showPlayView:YES];
    self.overTimeHintView.hidden = YES;
}

- (void)updateTimeLabel:(float)seconds
{
    int second = ceil(seconds);
    
    NSString *sSecond = second >= 10 ? [NSString stringWithFormat:@"0:%d",second] : [NSString stringWithFormat:@"0:0%d",second];
    
    [self.timeLabel setText:[NSString stringWithFormat:@"%@",sSecond]];
}

- (void)showSendAndSaveButton:(BOOL)show
{
    self.saveButton.hidden = !show;
    self.sendButton.hidden = !show;
}

- (void)setCaptureEnable:(BOOL)enable
{
    UIButton *capture = (UIButton *)[_bottomView viewWithTag:kCaptureBtnTag];
    capture.enabled = enable;
}

- (void)setRECBlink:(BOOL)blink
{
    if (blink && !timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(recBlink) userInfo:nil repeats:YES];
    }else {
        [timer invalidate];
        timer = nil;
        _recImageView.hidden = NO;
    }
}

- (void)recBlink
{
    self.recImageView.hidden = !self.recImageView.hidden;
}

- (void)saveVideo:(UIButton *)sender
{
    [[KDVideoPlayerManager sharedInstance] stopPlay];
    [_videoCapture saveVideoToAlbums:self.videoPath withBlock:^(BOOL result) {
        NSString *msg = result ? ASLocalizedString(@"保存成功"): ASLocalizedString(@"KDVideoPickerViewController_save_fail");
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setLabelText:msg];
        [hud hide:YES afterDelay:3.f];
    }];
}

- (void)sendVideo:(UIButton *)sender
{
    [[KDVideoPlayerManager sharedInstance] stopPlay];
    if ([self.delegate respondsToSelector:@selector(videoCaptureFinished:filePath:)]) {
        [self.delegate videoCaptureFinished:!_isCancel filePath:self.videoPath];
    }
}

- (void)showNoticeViewWithTime:(int)time
{
    if (!_overTimeHintView) {
        _overTimeHintView = [[UILabel alloc] initWithFrame:CGRectMake((_previewView.frame.size.width - 100.f) / 2., 40.0f, 100.0f, 40.0f)];
        _overTimeHintView.font = [UIFont boldSystemFontOfSize:18.f];
        _overTimeHintView.textAlignment = NSTextAlignmentCenter;
        _overTimeHintView.textColor = [UIColor whiteColor];
        _overTimeHintView.layer.opaque = YES;
        _overTimeHintView.layer.cornerRadius = 10.f;
        [_overTimeHintView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"video_notice_bg.png"]]];
        [_previewView addSubview:_overTimeHintView];
    }
    _overTimeHintView.hidden = NO;
    time = time >= 0 ? time : 0;
    [_overTimeHintView setText:[NSString stringWithFormat:ASLocalizedString(@"KDVideoPickerViewController_time"),time]];
}

- (void)updatePlayTimeLabel:(CGFloat)time
{
    self.playTimeLabel.text = [NSString stringWithFormat:@"0:%02lu", _videoDuration - (int)time];
}

#pragma mark
#pragma mark video capture delegate

- (void)captureManager:(KDVideoCaptureManager *)captureManager captureProgress:(CGFloat)progress
{
    [self updateTimeLabel:progress * kMaxTime];
    
    if (progress * kMaxTime > 2.) {
        [self setCaptureEnable:YES];
    }
    
    if ((progress * kMaxTime) >= 25.) {
        [self showNoticeViewWithTime:floor(kMaxTime - (progress * kMaxTime))];
    }
}

- (void)captureManager:(KDVideoCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    NSLog(@"-----------%@",error);
}

- (void)captureManagerRecordingFinished:(KDVideoCaptureManager *)captureManager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self captureFinish];
    });
}


#pragma mark RosyWriterVideoProcessorDelegate

- (void)recordingWillStart
{
	
}

- (void)recordingDidStart
{

}

- (void)recordingWillStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		// Pause the capture session so that saving will be as fast as possible.
		// We resume the sesssion in recordingDidStop:
		[_videoCapture pauseCaptureSession];
	});
}

- (void)recordingDidStop
{
	
}

#pragma mark playController delegate
- (void)videoPlayFinished:(KDVideoPlayerManager *)player
{
    self.playButton.enabled = YES;
    self.playTimeLabel.hidden = YES;
}

- (void)currentTimeOfVideo:(CGFloat)seconds
{
    [self updatePlayTimeLabel:seconds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_videoCapture);
    //KD_RELEASE_SAFELY(_videoPath);
    //KD_RELEASE_SAFELY(_bottomView);
    //KD_RELEASE_SAFELY(_topView);
    //KD_RELEASE_SAFELY(_previewView);
    //KD_RELEASE_SAFELY(_sendButton);
    //KD_RELEASE_SAFELY(_saveButton);
    //KD_RELEASE_SAFELY(_sizeLabel);
    //KD_RELEASE_SAFELY(_hintLabel);
    //KD_RELEASE_SAFELY(_recImageView);
    //KD_RELEASE_SAFELY(_timeLabel);
    //KD_RELEASE_SAFELY(_playView);
    //KD_RELEASE_SAFELY(_playButton);
    //KD_RELEASE_SAFELY(_overTimeHintView);
    //KD_RELEASE_SAFELY(_playTimeLabel);
    //KD_RELEASE_SAFELY(_loadingView);
    //KD_RELEASE_SAFELY(_hudShowView);
    
    //[super dealloc];
}

@end
