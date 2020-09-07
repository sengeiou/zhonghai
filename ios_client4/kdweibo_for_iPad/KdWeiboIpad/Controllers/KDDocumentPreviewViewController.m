//
//  KDDocumentPreviewViewController.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-27.
//
//

#import "KDDocumentPreviewViewController.h"
#import "KDDownload.h"
#import "KDDownloadManager.h"
#import "KWIRootVCtrl.h"
#import "UIDevice+KWIExt.h"
#import "KDDocFullScreenViewController.h"
#import "UIImage+Additions.h"
#import <QuartzCore/QuartzCore.h>

//@interface MyWebView : UIWebView
//
//
//@end
//
//@implementation MyWebView
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    DLog(@"scrollViewWillBeginDragging");
////    if (!hidden) {
////        [self toggleHiddenNavigationBar];
////    }
//    
//}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    DLog(@"scrollViewDidScroll");
//}
//
//@end

@implementation UIWebView(CustomScroll)
- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.delegate performSelector:@selector(scrollViewDidScroll:) withObject:scrollView];
}
@end



@interface KDDocumentPreviewViewController ()<UIWebViewDelegate,UITextViewDelegate,KDDownloadListener,UIGestureRecognizerDelegate> {
    BOOL didAppear;
    BOOL shouldFullScreen_;
    BOOL _isShadowDisabled;
    CGRect orignFrame_;
    CGRect orginWebFrame_;
    UIView *selfSuperview_;
    BOOL hidden;
    BOOL isOpenAsOtherBtnSelected;
}
@property (retain, nonatomic) IBOutlet UIView *titleContainerView;

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIButton *openAsFullSecreenBtn;
@property (retain, nonatomic) IBOutlet UIButton *openOtherWayBtn;
@property (retain, nonatomic) IBOutlet UIButton *closeBtn;
@property (retain, nonatomic) IBOutlet UIView *downLoadingInfoContainerView;

@property (retain, nonatomic) IBOutlet UIImageView *fileTypeImageView;
@property (retain, nonatomic) IBOutlet UILabel *fileVolumeLabel;
@property (retain, nonatomic) IBOutlet UILabel *downloadSpeedLabel;
@property (retain, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (retain, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (retain, nonatomic) IBOutlet UILabel *failureInfoLabel;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) IBOutlet UINavigationBar *navgationbar;
@property (nonatomic, assign) KDMockDownloadListener *mockDownloadListener;
@property(nonatomic, retain)UIDocumentInteractionController *docInteractionController;
@end


@implementation KDDocumentPreviewViewController
@synthesize download = download_;
@synthesize mockDownloadListener = mockDownloadListener_;
@synthesize docInteractionController = docInteractionController_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        [dnc addObserver:self selector:@selector(_onOrientationChanged:) name:@"UIInterfaceOrientationChanged" object:nil];
        [dnc addObserver:self selector:@selector(_onOrientationWillChange:) name:@"UIInterfaceOrientationWillChange" object:nil];
        didAppear = NO;
        hidden = NO;
        isOpenAsOtherBtnSelected = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.wantsFullScreenLayout = YES;
    // Do any additional setup after loading the view from its nib.
    self.navgationbar.hidden = YES;
  
    self.webView.hidden = YES;
    self.downLoadingInfoContainerView.hidden = YES;
    self.failureInfoLabel.hidden = YES;
    UITapGestureRecognizer *grzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(webViewTapped:)];
    grzr.delegate = self;
    [self.webView addGestureRecognizer:grzr];
    [grzr release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (download_) {
        [download_ determinState];
    }
   
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
    if (shouldFullScreen_) {
        self.titleContainerView.hidden = YES;
        self.webView.frame = self.view.bounds;
       // [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self toggleHiddenNavigationBar];
     
    }else {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.titleContainerView.hidden = NO;
        CGRect frame = self.webView.frame;
        frame.origin.y = CGRectGetMaxY(self.titleContainerView.frame);
        self.webView.frame = frame;
        [self showToolBtn];
        
    }
    
    if (!didAppear) {
        didAppear = YES;
        [self handleDownload];
    }
}

- (void)showToolBtn {
    BOOL visible  = NO;
    if(download_) {
        if ([download_ isSuccess]) {
            visible = YES;
        }
    }
    self.openAsFullSecreenBtn.hidden = !visible;
    self.openOtherWayBtn.hidden = !visible;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (IBAction)openOtheWayBtnTapped:(id)sender {
    //[self openOtheWayBtnTapped:sender];
    [self  openOtherWay:sender];
}

- (IBAction)closeBtnTapped:(id)sender {
     KWIRootVCtrl *rootVC = [KWIRootVCtrl curInst];
    [rootVC onRemoveViewController:self animaion:YES];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if(!hidden) {
        [self toggleHiddenNavigationBar];
    }
}

- (void)shouldFullScreened:(BOOL)should {
    shouldFullScreen_ = should;
    if (!shouldFullScreen_ ) {
        if (isOpenAsOtherBtnSelected) {
            [self.docInteractionController dismissMenuAnimated:YES];
        }
    }
}

- (void)openOtherWay:(id)sender {
    if ([download_ isSuccess]) {
        NSURL *fileURL = [NSURL fileURLWithPath:download_.path];
        [self setupDocumentControllerWithURL:fileURL];
        if (isOpenAsOtherBtnSelected) {
            [self.docInteractionController dismissMenuAnimated:YES];
            isOpenAsOtherBtnSelected = NO;
            return;
        }
        if([sender isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)sender;
            CGRect  rect=  CGRectMake(btn.frame.origin.x, 50, [btn frame].size.width, [btn frame].size.height);
            if ([self.docInteractionController presentOpenInMenuFromRect:rect inView:self.view animated:YES]) {
                isOpenAsOtherBtnSelected = YES;
            }

        }else {
            UIBarButtonItem *btnItem = (UIBarButtonItem *)sender;
            if ([self.docInteractionController presentOpenInMenuFromBarButtonItem:btnItem animated:YES]) {
                isOpenAsOtherBtnSelected = YES;
            }
        }
                
    }
    
}

- (void)setupDocumentControllerWithURL:(NSURL *)url {
    if (self.docInteractionController == nil) {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        
    } else {
        self.docInteractionController.URL = url;
    }
}


- (void)handleDownload {
    if (download_) {
        if ([download_ isSuccess]) {
            [self preViewDownload:download_];
           
        }else {           
            [self startDownload];
        }
    }
}

- (BOOL)downloadCanOpened:(KDDownload *)download {
    BOOL can = NO;
    if (download_.path.length >0) {
        NSString *pathSuffix = [[download_.path pathExtension]lowercaseString];
        NSString *supportFormat = @"doc.docx.xls.xlsx.ppt.pptx.pdf.txt.pps.ppsx";
        NSArray *supportFormats = [supportFormat componentsSeparatedByString:@"."];
        for(NSString *f in supportFormats) {
            if([pathSuffix compare:f options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                can = YES;
                break;
            }
        }
    }
    return can;
}

- (void)preViewDownload:(KDDownload *)download {
     self.downLoadingInfoContainerView.hidden = YES;
     self.webView.hidden = NO;
     self.webView.userInteractionEnabled = YES;
    BOOL isSupported = [self downloadCanOpened:download];
    
    if(isSupported) {
        NSURL *url = [NSURL fileURLWithPath:download.path];
        NSString *postfix = [download_.path pathExtension];
        
        if([[postfix  lowercaseString] isEqualToString:@"txt"]){//处理txt文件,否则txt文件会显示乱码
            NSStringEncoding  enc = NSUTF8StringEncoding;
            NSString *body = [NSString stringWithContentsOfURL:url encoding:enc error:nil];
            if(!body){//gb2312编码后再尝试打开
                NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                body = [NSString stringWithContentsOfURL:url encoding:enc error:nil];
            }
            if(!body){//
                enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif);
                body = [NSString stringWithContentsOfURL:url encoding:enc error:nil];
            }
            if(!body){//
                enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80);
                body = [NSString stringWithContentsOfURL:url encoding:enc error:nil];
            }
            self.openAsFullSecreenBtn.hidden = NO;
            self.openOtherWayBtn.hidden = NO;
            
            UITextView *textView = [[UITextView alloc] initWithFrame:self.webView.bounds];
            textView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            textView.editable = NO;
            textView.font = [UIFont systemFontOfSize:18];
            textView.backgroundColor = [UIColor clearColor];
            textView.opaque = NO;
            textView.delegate = self;
            
            [self.webView  addSubview:textView];
            [textView release];
            textView.text = body;
        }else {
            [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        }
    }else{
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"error" ofType:@"html"]]]];
    }    
    
}

- (void)startDownload {
    [[KDDownloadManager sharedDownloadManager] addDownload:download_];
    KDMockDownloadListener *mockDownloadListener = [[[KDMockDownloadListener alloc] initWithDownloadListener:self] autorelease];
    self.mockDownloadListener = mockDownloadListener;
    [[KDDownloadManager sharedDownloadManager] addListener:mockDownloadListener];
}

- (void)downloadWillStart {
    //[self start];
    self.webView.hidden = NO;
    self.webView.userInteractionEnabled = NO;
    self.downLoadingInfoContainerView.hidden =NO;
    self.openAsFullSecreenBtn.hidden = YES;
    self.openOtherWayBtn.hidden = YES;
    self.fileNameLabel.text = download_.name;
    self.fileTypeImageView.image = [UIImage imageByFileEntension:download_.path isBig:NO];
    [self.downloadProgressView setProgress:0.0f];
    
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    KWIRootVCtrl *rootVC = [KWIRootVCtrl curInst];
    [rootVC willRotateToInterfaceOrientation:toInterfaceOrientation  duration:duration];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
   KWIRootVCtrl *rootVC = [KWIRootVCtrl curInst];
    [rootVC didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (!hidden) {
        [self.navigationController setNavigationBarHidden:NO];
    }
   
}
- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.navigationController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)replaceTootViewControllerOfNavgationCongtroller{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self capture]];
    imageView.frame = self.navigationController.view.bounds;
    imageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.navigationController.view addSubview:imageView];
    [imageView release];
}

- (void)dwonloadSuccess {
    [self showToolBtn];
    [self preViewDownload:download_];
}
- (void)downloadFaild {
    self.downLoadingInfoContainerView.hidden = YES;
    self.failureInfoLabel.hidden = NO;
    self.failureInfoLabel.text = @"下载发生错误";
    [self showToolBtn];
}
- (void)openFaild {
    self.downLoadingInfoContainerView.hidden = YES;
    self.failureInfoLabel.hidden = NO;
    self.failureInfoLabel.text = @"打开文件发生错误";
}


- (void)downloadStateDidChange:(KDDownload *)download {
    if ([download isSuccess]) {
        //
        [self dwonloadSuccess];
      
    }
    else if ([download isDownloading]) {
        
        [self downloadWillStart];
    }
    else if ([download isFailed]) {
        [self downloadFaild];
       
    }
    else  if ([download isCancled]) {
      
    }
}


- (void) updateDisplayWithProgressMonitor:(KDRequestProgressMonitor *)monitor {
    float progress = [monitor finishedPercent];
    if (![monitor isUnknownResponseLength]) {
        self.downloadSpeedLabel.text = [monitor finishedPercentAsString];
        self.fileVolumeLabel.text = [monitor finishedByteToMaxByteAsString];
        [self.downloadProgressView setProgress:progress];
    }
    
}

- (void)downloadProgressDidChange:(KDRequestProgressMonitor *)monitor {
    [self updateDisplayWithProgressMonitor:monitor];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //防止崩溃，下同。
//    if (download_.maxByte > LARGE_SIZE) {
//        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"SIZE_OVER_%dM_NOTIFICATION", nil),10];
//        [[KDNotificationView defaultMessageNotificationView] showInView:self.view
//                                                                message:message
//                                                                   type:KDNotificationViewTypeNormal];
//    }
//    backBtn_.enabled = NO;
//    openAsBtn_.enabled = NO;
//    [loadingView_ setHidden:NO];
//    self.openAsFullSecreenBtn.enabled = NO;
//    self.openOtherWayBtn.enabled = NO;
    DLog(@"startlaoding.....");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    backBtn_.enabled = YES;
//    openAsBtn_.enabled = YES;
//    [loadingView_ setHidden:YES];
//    self.openAsFullSecreenBtn.enabled = YES;
//    self.openAsFullSecreenBtn.hidden = NO;
//    self.openOtherWayBtn.hidden = NO;
//    self.openOtherWayBtn.enabled = YES;
    DLog(@"didfinished........");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

    NSLog(@"didFailLoadWithError");

    //播放视频加载插件
    if ([error code] == 204 && [[error domain] isEqualToString:@"WebKitErrorDomain"]) {
        return;
    }

//    NSLog(@"error = %@",[error description]);
//    backBtn_.enabled = YES;
//    openAsBtn_.enabled = YES;
//    [loadingView_ setHidden:YES];
//    if (![self reviewWithAnotherApp]) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EORROR_HAPPEN", @"")
//                                                            message:NSLocalizedString(@"FORMAT_UNSUPPOTED_ERROR", @"")
//                                                           delegate:nil
//                                                  cancelButtonTitle:NSLocalizedString(@"OKAY", @"")
//                                                  otherButtonTitles: nil];
//        [alertView show];
//        [alertView release];
//        
//    }
    [self openFaild];
}

- (void)dealloc {
   
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc removeObserver:self];
    [[KDDownloadManager sharedDownloadManager]removeListener:self.mockDownloadListener];
    if ([download_ isDownloading]) {
        DLog(@"cancle....");
        [[KDDownloadManager sharedDownloadManager] cancleDownload:download_];
    }
    [self.webView  loadHTMLString:@"" baseURL:nil];
    [self.webView stopLoading];
    self.webView.delegate = nil;
  
    KD_RELEASE_SAFELY(download_);
    [_webView release];
    [_openAsFullSecreenBtn release];
    [_openOtherWayBtn release];
    [_closeBtn release];
    [_downLoadingInfoContainerView release];
    [_fileTypeImageView release];
    [_fileVolumeLabel release];
    [_downloadSpeedLabel release];
    [_fileNameLabel release];
    [_downloadProgressView release];
    [_failureInfoLabel release];
    [_backgroundImageView release];
    [_titleContainerView release];
    [_navgationbar release];
    [_webView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWebView:nil];
    [self setOpenAsFullSecreenBtn:nil];
    [self setOpenOtherWayBtn:nil];
    [self setCloseBtn:nil];
    [self setDownLoadingInfoContainerView:nil];
    [self setFileTypeImageView:nil];
    [self setFileVolumeLabel:nil];
    [self setDownloadSpeedLabel:nil];
    [self setFileNameLabel:nil];
    [self setDownloadProgressView:nil];
    [self setFailureInfoLabel:nil];
    [self setBackgroundImageView:nil];
    [self setTitleContainerView:nil];
    [self setNavgationbar:nil];
    [self setWebView:nil];
    [super viewDidUnload];
}

- (void)_configBgVForCurrentOrientation
{
    if ([UIDevice isPortrait]) {
        if (_isShadowDisabled) {
            self.backgroundImageView.image = [UIImage imageNamed:@"profileBgPNoShadow.png"];
        } else {
            self.backgroundImageView.image = [UIImage imageNamed:@"profileBgP.png"];
        }
    } else {
        self.backgroundImageView.image = [UIImage imageNamed:@"profileBg.png"];
    }
    
    CGRect frame = self.backgroundImageView.frame;
    frame.size = self.backgroundImageView.image.size;
    self.backgroundImageView.frame = frame;
}

- (void)_onOrientationWillChange:(NSNotification *)note {
    if (!shouldFullScreen_) {
        NSLog(@"_onOrientTabtionWillChange....");
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
     }
}

- (void)_onOrientationChanged:(NSNotification *)note{
    if (!shouldFullScreen_) {
         NSLog(@"_onOrientationChanged....");
        [self _configBgVForCurrentOrientation];
    }
  
}

- (void)shadowOn {
    _isShadowDisabled = NO;
    [self _configBgVForCurrentOrientation];
}

- (void)shadowOff {
    _isShadowDisabled = YES;
    [self _configBgVForCurrentOrientation];
}
- (IBAction)fullScreenBtnTapped:(id)sender {
   KWIRootVCtrl *rootVC = [KWIRootVCtrl curInst];
    [rootVC fullScreening:self];
}


- (void)toggleHiddenNavigationBar {
    if (shouldFullScreen_) {
        hidden = !hidden;
        [self.navigationController setNavigationBarHidden:hidden animated:[self isViewLoaded]];
    }
    
}

- (void)webViewTapped:(UITapGestureRecognizer *)grzr {
    DLog(@"tapped:");
    [self toggleHiddenNavigationBar];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (id)data {
    return download_;
}
@end
