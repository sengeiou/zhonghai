//
//  KDViewPlayerController.m
//  kdweibo
//
//  Created by 王 松 on 13-7-15.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#define VideoPlaySize CGSizeMake(240, 320)

#import "KDVideoPlayerController.h"

#import "KDDownload.h"

#import "KDAttachment.h"

#import "KDDownloadManager.h"

#import "KDNotificationView.h"

#import "KDImageLoaderAdapter.h"

#import "KDWeiboServicesContext.h"

#import "KDWpsTool.h"

#import "BOSSetting.h"

@interface KDVideoPlayerController ()<KDVideoPlayerManagerDelegate, KDDownloadListener, UIGestureRecognizerDelegate>
{
    KDDownload *download;
    BOOL isLoading;
    CGFloat topY;
}

@property (nonatomic, retain) UIButton *backBtn;

@property (nonatomic, retain) KDMockDownloadListener *listener;

@property (nonatomic, retain) UIImageView *thumbnailView;

@property (nonatomic, retain) UIView *hintView;

@property (nonatomic, retain) UIProgressView *progressView;

@property (nonatomic, retain) UILabel *percentLabel;

@property (nonatomic, retain) UILabel *failureLabel;

@property (nonatomic, retain) UILabel *sizeLabel;

@property (nonatomic, retain) UILabel *timeLabel;

@property (nonatomic, assign) NSUInteger videoDuration;

@end

@implementation KDVideoPlayerController

@synthesize attachments = attachments_;
@synthesize dataId = dataId_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       //
         _listener = [[KDMockDownloadListener alloc] initWithDownloadListener:self];
        [[KDDownloadManager sharedDownloadManager] addListener:_listener];
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.userInteractionEnabled = YES;
    
    topY = 0.0f;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        topY =  [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:bgImageView];
    bgImageView.userInteractionEnabled = YES;
    bgImageView.backgroundColor =  RGBCOLOR(55.f, 59.f, 63.f);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadVideo:)];
    tap.numberOfTapsRequired = 1;
    [bgImageView addGestureRecognizer:tap];
//    [tap release];
//    [bgImageView release];
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [UIImage imageNamed:@"video_camera_back.png"];

    _backBtn.frame = CGRectMake(10.f, topY + 10.0f, 64.f, 34.f);
    [_backBtn setImage:backImage forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backToPreView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
    
    UIImage *loadingImage = [UIImage imageNamed:@"video_for_loading.png"];
    _thumbnailView = [[UIImageView alloc] initWithImage:loadingImage];
    _thumbnailView.frame = CGRectMake((self.view.frame.size.width - loadingImage.size.width) / 2.f, (self.view.frame.size.height - topY - loadingImage.size.height) / 2.f - 50.f, loadingImage.size.width, loadingImage.size.height);
    _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_thumbnailView];
    
    _failureLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 240.f) / 2.f, _thumbnailView.frame.size.height + _thumbnailView.frame.origin.y + 5.f, 240, 20)];
    _failureLabel.textAlignment = NSTextAlignmentCenter;
    _failureLabel.font = [UIFont systemFontOfSize:14.f];
    _failureLabel.textColor = [UIColor colorWithRed:240.f / 255.f green:128.f / 255.f blue:52.f / 255.f alpha:1.f];
    _failureLabel.backgroundColor = [UIColor clearColor];
    _failureLabel.text = ASLocalizedString(@"KDVideoPlayerController_failureLabel_text");
    _failureLabel.hidden = YES;
    [self.view addSubview:_failureLabel];
    
    _hintView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _thumbnailView.frame.origin.y + _thumbnailView.frame.size.height + 10.f, self.view.frame.size.width, 50.f)];
    [self.view addSubview:_hintView];
    
    _progressView =  [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.frame = CGRectMake((_hintView.frame.size.width - 240.f) / 2.f, 10.f, 240.f, 20.f);
    
    if ([_progressView respondsToSelector:@selector(setProgressImage:)]) {
        [_progressView setProgressTintColor:RGBCOLOR(0, 119.f, 255.f)];
        [_progressView setTrackTintColor:[UIColor blackColor]];
    }
    
    [_hintView  addSubview:_progressView];
    
    _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake((_hintView.frame.size.width - 220.f) / 2.f, 20, 220, 20)];
    _percentLabel.textColor = [UIColor whiteColor];
    _percentLabel.textAlignment = NSTextAlignmentCenter;
    [_hintView addSubview:_percentLabel];
    [_percentLabel setFont:[UIFont systemFontOfSize:14]];
    [_percentLabel setBackgroundColor:[UIColor clearColor]];
    
    [self showProgress:NO];
    
    CGSize videoNaturalSize = VideoPlaySize;
    CGRect playViewFrame = CGRectMake((self.view.bounds.size.width - videoNaturalSize.width) / 2., 64.f, videoNaturalSize.width, videoNaturalSize.height);
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(playViewFrame.origin.x, playViewFrame.size.height + playViewFrame.origin.y + 5.f + topY, 60.f, 20.f)];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel.font = [UIFont systemFontOfSize:18.f];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.backgroundColor = [UIColor clearColor];

    _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 120.f - playViewFrame.origin.x, playViewFrame.size.height + playViewFrame.origin.y + 5.f + topY, 120.f, 20.f)];
    _sizeLabel.textAlignment = NSTextAlignmentRight;
    _sizeLabel.font = [UIFont systemFontOfSize:18.f];
    _sizeLabel.textColor = [UIColor whiteColor];
    _sizeLabel.backgroundColor = [UIColor clearColor];

    [self.view addSubview:_timeLabel];
    [self.view addSubview:_sizeLabel];
    
    if (!self.weiboStatus && attachments_) {
        [self loadVideo:nil];
    }

}

//- (void)setAttachments:(NSArray *)attachments {
//    if (attachments_ != attachments) {
//        [attachments_ release];
//        attachments_ = [attachments retain];
//       // [self loadVideo:nil];
//        
//    }
//}


//- (void)setWeiboStatus:(KDStatus *)weiboStatus
//{
//    //KD_RELEASE_SAFELY(_localFileURL);
//    if (_weiboStatus != weiboStatus) {
//        [_weiboStatus release];
//        _weiboStatus = [weiboStatus retain];
//    }
//    [self loadVideo:nil];
//}

- (void)setLocalFileURL:(NSString *)localFileURL
{
    ////KD_RELEASE_SAFELY(_weiboStatus);
    if (_localFileURL != localFileURL) {
//        [_localFileURL release];
        _localFileURL = localFileURL;// retain];
    }
    [self startPlay:localFileURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    ////KD_RELEASE_SAFELY(_weiboStatus);
    //KD_RELEASE_SAFELY(_localFileURL);
    //KD_RELEASE_SAFELY(_thumbnailView);
    //KD_RELEASE_SAFELY(_percentLabel);
    //KD_RELEASE_SAFELY(_progressView);
    //KD_RELEASE_SAFELY(_hintView);
    //KD_RELEASE_SAFELY(download);
    //KD_RELEASE_SAFELY(_failureLabel);
    //KD_RELEASE_SAFELY(_timeLabel);
    //KD_RELEASE_SAFELY(_sizeLabel);
    [[KDDownloadManager sharedDownloadManager] removeListener:_listener];
    //KD_RELEASE_SAFELY(_listener);
    //KD_RELEASE_SAFELY(attachments_);
    //KD_RELEASE_SAFELY(dataId_);
    //[super dealloc];
    
    //将明文文件删除
    [[KDWpsTool shareInstance] removeCacheFile:download.path];
}

- (void)backToPreView:(id)sender
{
    [[KDDownloadManager sharedDownloadManager] cancleDownload:download];
    [[KDVideoPlayerManager sharedInstance] stopPlay];
    [self videoPlayFinished:nil];
}

#pragma mark
#pragma mark gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isMemberOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}


#pragma mark
#pragma mark KDVideoPlayerManager delegate

- (void)videoPlayFinished:(KDVideoPlayerManager *)player
{
    if ([self.delegate respondsToSelector:@selector(videoPlayFinished:)]) {
        [self.delegate videoPlayFinished:player];
    }else{
        if(![self.presentedViewController isBeingDismissed]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    //将明文文件删除
    [[KDWpsTool shareInstance] removeCacheFile:download.path];
}

- (void)currentTimeOfVideo:(CGFloat)seconds
{
    [self updateTimeLabel:seconds];
}

#pragma mark - KDDownloadListener
- (void)downloadProgressDidChange:(KDRequestProgressMonitor *)monitor {
    [self updateDisplayWithProgressMonitor:monitor];
}

- (void)downloadStateDidChange:(KDDownload *)aDownload {
    if([aDownload.entityId isEqualToString:self.dataId]) {
        if([aDownload isSuccess]) {
            [self showProgress:NO];
            [self startPlay:download.path];
        }
        else if ([aDownload isDownloading]) {
            [self startDownloading];
        }
        else if ([aDownload isFailed]) {
            self.failureLabel.hidden = NO;
            isLoading = NO;
            [self showProgress:NO];
        }
        else  if ([aDownload isCancled]) {
            [[KDDownloadManager sharedDownloadManager] removeListener:_listener];
        }
    }
}

- (void)showProgress:(BOOL)show
{
    _hintView.hidden = !show;
}

- (void)startDownloading {
    [_progressView setProgress:0.0f];
}

- (void)updateSizeLabel:(CGFloat)size
{
    self.sizeLabel.text = [NSString stringWithFormat:@"%dkb", (int)size / 1024];
}

- (void)updateTimeLabel:(CGFloat)time
{
    self.timeLabel.text = [NSString stringWithFormat:@"0:%02lu", _videoDuration - (int)time];
}

- (void)updateDisplayWithProgressMonitor:(KDRequestProgressMonitor *)monitor {
    float progress = [monitor finishedPercent];
    if (![monitor isUnknownResponseLength]) {
        _percentLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDVideoPlayerController_percentLabel_text"), [monitor finishedPercentAsString]];
        [_progressView setProgress:progress];
    }
    
}


- (void)loadVideo:(id)sender
{
    if (isLoading) {
        return;
    }
    isLoading = YES;
    
    //2013.11.30 By Tan Yingqi  增加attachements 属性
    //NSArray *attachments = nil;
    
    _failureLabel.hidden = YES;
//    
//    if ([_weiboStatus hasVideo]) {
//        self.attachments = _weiboStatus.attachments;
//        
//    } else if ([_weiboStatus.forwardedStatus hasVideo]) {
//        self.attachments = _weiboStatus.forwardedStatus.attachments;
//    }
//   
//    if(_weiboStatus) {
//        self.dataId = _weiboStatus.statusId;
//    }
    [KDDownload downloadsWithAttachemnts:attachments_ statusId:self.dataId finishBlock:^(NSArray *result) {
        if (result && [result count] > 0) {
            download = [result objectAtIndex:0];// retain];
            
            if(![download isSuccess]) {
                [self showProgress:YES];
                [[KDDownloadManager sharedDownloadManager] addDownload:download];
            }else {
                [self startPlay:download.path];
            }
        }
    }];
}

- (void)startPlay:(NSString *)path
{
    __weak __typeof(self) weakSelf = self;
    //尝试解密文件
    [[KDWpsTool shareInstance] decryptFile:path complectionBlock:^(BOOL success, NSData *data,NSString *fileCachePath) {
        
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileCachePath error:nil];
        NSNumber *size = [attributes objectForKey:NSFileSize];
        
        if (download && size.floatValue != download.maxByte) {
            [weakSelf showProgress:YES];
            _percentLabel.text = ASLocalizedString(@"Video_Invalid");
            
            return;
        }
        
        [weakSelf updateSizeLabel:size.floatValue];
        weakSelf.thumbnailView.hidden = YES;
        weakSelf.failureLabel.hidden = YES;
        KDVideoPlayerManager *player = [KDVideoPlayerManager sharedInstance];
        player.contentURL = [NSURL fileURLWithPath:fileCachePath];
        player.delegate = weakSelf;
        _videoDuration = [KDVideoPlayerManager secondsOfVideoOfPath:fileCachePath];
        _videoDuration = _videoDuration == 0 ? _videoDuration = 1 : _videoDuration;
        CGSize videoNaturalSize = VideoPlaySize;//[player videoNaturalSize];
        
        CGRect frame = CGRectMake((weakSelf.view.bounds.size.width - videoNaturalSize.width) / 2., topY + 64.f, videoNaturalSize.width, videoNaturalSize.height);
        
        UIView *playView = [[UIView alloc] initWithFrame:frame];//[UIScreen mainScreen].bounds];
        playView.backgroundColor = [UIColor blackColor];
        playView.tag = 10002;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(switchVideoSize:)];
        singleTap.numberOfTapsRequired = 1;
        [playView addGestureRecognizer:singleTap];
        
//        [singleTap release];
        
        [weakSelf.view addSubview:playView];
        
        [player startPlayInView:playView];
        
        //KD_RELEASE_SAFELY(playView);
        
    }];
}

- (void)switchVideoSize:(UIGestureRecognizer *)gesture
{
    KDVideoPlayerManager *player = [KDVideoPlayerManager sharedInstance];
    CGRect bounds = [UIScreen mainScreen].bounds;
    if (CGSizeEqualToSize(gesture.view.frame.size, bounds.size)) {
        CGSize videoNaturalSize = VideoPlaySize;//[player videoNaturalSize];
        CGRect frame = CGRectMake((self.view.bounds.size.width - videoNaturalSize.width) / 2., topY + 64.0f, videoNaturalSize.width, videoNaturalSize.height);
        gesture.view.frame = frame;
    }else {
        gesture.view.frame = [UIScreen mainScreen].bounds;
    }
    [player resetPlayViewBounds:gesture.view.bounds];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kKDModalViewShowNotification object:nil userInfo:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     [[NSNotificationCenter defaultCenter] postNotificationName:kKDModalViewHideNotification object:nil];
}

@end
