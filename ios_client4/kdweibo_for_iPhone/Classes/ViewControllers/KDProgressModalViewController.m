//
//  KDProgressModalViewController.m
//  kdweibo
//
//  Created by Tan yingqi on 8/1/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDProgressModalViewController.h"
#import "KDRequestProgressMonitor.h"
#import "KDDownloadManager.h"
#import "UIImage+Additions.h"
#import "KDWeiboAppDelegate.h"
#import "KDCommon.h"
#import "KDNotificationView.h"
#import "BOSSetting.h"
#import "KDWebViewController.h"
#import "XTFileUtils.h"
#import "KDWpsTool.h"

@interface KDProgressModalViewController ()

@property(nonatomic, retain)KDDownload *download;
@property(nonatomic, retain)UIView *backView;
@property(nonatomic, retain)UIImageView *fileTypeIconImageView;
@property(nonatomic, retain)UILabel *fileNameLabel;
@property(nonatomic, retain)KDProgressView *progressView;
@property(nonatomic, retain)UILabel *percentLabel;
@property(nonatomic, retain)UILabel *currentVolumeLabel;
@property(nonatomic, retain)UILabel *errorLabel;
@property(nonatomic, retain)UIButton *backBtn;
@property(nonatomic, retain)UIButton *openAsBtn;
@property(nonatomic, retain)UIWebView *webView;
@property(nonatomic, retain)UIView    *loadingView;
@property(nonatomic, retain)UIDocumentInteractionController *docInteractionController;

@end

@implementation KDProgressModalViewController
@synthesize backView = backView_;
@synthesize fileTypeIconImageView = fileTypeIconImageView_;
@synthesize fileNameLabel = fileNameLabel_;
@synthesize progressView = progressView_;
@synthesize percentLabel = percentLabel_;
@synthesize currentVolumeLabel = currentVolumeLabel_;
@synthesize backBtn = backBtn_;
@synthesize openAsBtn =openAsBtn_;
@synthesize webView = webView_;
@synthesize loadingView = loadingView_;
@synthesize download = download_;
@synthesize docInteractionController = docInteractionController_;
@synthesize mockDownloadListener = mockDownloadListener_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithDownload:(KDDownload *)download {
    self = [self init];
    if (self) {
        //
        self.download = download;
        isDownLoaded_ = NO;
        self.navigationItem.title = download_.name;
    }
    return self;
}

- (id)initWithDownLoadedDownload:(KDDownload *)download {
    self = [self initWithDownload:download];
    
    if(self) {
        isDownLoaded_ = YES;
    }
    
    return self;
}




- (void) setNavBarItem {
    self.backBtn = [UIButton backBtnInWhiteNavWithTitle:self.backBtnTitle];
    [backBtn_ addTarget:self action:@selector(back)  forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn_];
    self.navigationItem.leftBarButtonItems = [NSArray
                                              arrayWithObjects:backItem, nil];
    
//    [backItem release];
    
    UIImage *imageNormal = [UIImage imageNamed:@"document_link.png"];
    self.openAsBtn = [UIButton buttonWithType:UIButtonTypeCustom];

    [openAsBtn_.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [openAsBtn_ setImage:imageNormal forState:UIControlStateNormal];
    openAsBtn_.frame= CGRectMake(0.0, 0.0, imageNormal.size.width,imageNormal.size.height);
    [openAsBtn_ addTarget:self action:@selector(reviewWithAnotherApp) forControlEvents:UIControlEventTouchUpInside];
    [openAsBtn_ sizeToFit];
    UIView *v=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, openAsBtn_.frame.size.width,openAsBtn_.frame.size.height )];    
    [v addSubview:openAsBtn_];
    UIBarButtonItem *reviewDownloadedbtnItem = [[UIBarButtonItem alloc] initWithCustomView:v];// autorelease];
//    [v release];
    
     //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil] ;//autorelease];
    negativeSpacer1.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer1,reviewDownloadedbtnItem, nil];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [webView_ stopLoading];
    KDWeiboAppDelegate *appDelegate = [KDWeiboAppDelegate getAppDelegate];
    [appDelegate.window setUserInteractionEnabled:YES];
}

- (void)setupDocumentControllerWithURL:(NSURL *)url {
    if (self.docInteractionController == nil) {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
      
    } else {
        self.docInteractionController.URL = url;
    }
}

- (void)dismissSelf {
    [[KDDownloadManager sharedDownloadManager] removeListener:self.mockDownloadListener];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) back {
    if ([download_ isDownloading]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" 
                                                            message:NSLocalizedString(@"CANCLE_DOWNLOAD_WARNING",@"")
                                                            delegate:self
                                                   cancelButtonTitle:nil 
                                                  otherButtonTitles:NSLocalizedString(@"YES",@"" ),NSLocalizedString(@"NO",@"" ), nil];
        [alertView show];
//        [alertView release];
        
    }else {
        [self dismissSelf];
    }
    
    
    //将明文文件删除
    [[KDWpsTool shareInstance] removeCacheFile:download_.path];
}

- (BOOL) reviewWithAnotherApp {
    BOOL canReview = NO ;
    if ([download_ isSuccess] || isDownLoaded_) {
        NSURL *fileURL = [NSURL fileURLWithPath:download_.path];
        [self setupDocumentControllerWithURL:fileURL];
      if ([self.docInteractionController presentOpenInMenuFromBarButtonItem:[self.navigationItem.rightBarButtonItems lastObject] animated:YES])
        canReview = YES;
    }
       return canReview;
    
}

- (void)setBackgroud {
    [self.view setBounds:[UIScreen mainScreen].bounds];
    
    self.view.backgroundColor = MESSAGE_BG_COLOR;
}

- (void)setDownloadingUI {
   
    self.backView = [[UIView alloc] initWithFrame:self.view.bounds];// autorelease];
    self.backView.backgroundColor = MESSAGE_BG_COLOR;
    [self.view addSubview:backView_];
    [backView_ setHidden:YES];
    
    UIImageView *fileBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"document_file_bg"]];
    [backView_ addSubview:fileBg];
//    [fileBg release];
    fileBg.center = CGPointMake((backView_.frame.size.width - 30)/2+10, 148);
    
    
    self.fileTypeIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageByFileEntension:download_.name isBig:YES]];// autorelease];
    [backView_ addSubview:fileTypeIconImageView_];
    fileTypeIconImageView_.center = CGPointMake((backView_.frame.size.width - 30)/2+10, 148);
    
    
    self.fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, fileBg.frame.origin.y + fileBg.frame.size.height +10.f, backView_.frame.size.width - 2*15, 22)] ;//autorelease];
    [backView_ addSubview:fileNameLabel_];
    [fileNameLabel_ setLineBreakMode:NSLineBreakByTruncatingMiddle];
    fileNameLabel_ .text = [download_ name];
    fileNameLabel_.textColor = UIColorFromRGB(0x3e3e3e);
    [fileNameLabel_ setTextAlignment:NSTextAlignmentCenter];
    [fileNameLabel_ setFont:[UIFont systemFontOfSize:14.f]];
    [fileNameLabel_ setBackgroundColor:[UIColor clearColor]];
    
    self.progressView =  [[KDProgressView alloc] initWithFrame:CGRectMake(0, 0, fileNameLabel_.frame.size.width, 9.f)];// autorelease];
    [backView_  addSubview:progressView_];
    progressView_.center = CGPointMake(fileNameLabel_.frame.origin.x + fileNameLabel_.frame.size.width/2, fileNameLabel_.frame.origin.y + fileNameLabel_.frame.size.height+progressView_.frame.size.height/2 + 10);
    
    self.percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(fileNameLabel_.frame.origin.x + 5, progressView_.frame.origin.y + progressView_.frame.size.height +10, 45, 20)];// autorelease];
    [backView_ addSubview:percentLabel_];
    percentLabel_.textColor = UIColorFromRGB(0x6d6d6d);
    
    [percentLabel_ setFont:[UIFont systemFontOfSize:13]];
    [percentLabel_ setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = [self.view bounds].size.width - 15-130;
    self.currentVolumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, percentLabel_.frame.origin.y, 130, 20)];// autorelease];
    [backView_ addSubview:currentVolumeLabel_];
    [currentVolumeLabel_ setFont:[UIFont systemFontOfSize:13]];
    [currentVolumeLabel_ setBackgroundColor:[UIColor clearColor]];
    currentVolumeLabel_.textColor = UIColorFromRGB(0x6d6d6d);
    
    UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, percentLabel_.frame.origin.y + percentLabel_.frame.size.height + 5, backView_.frame.size.width - 2*15, 22)] ;//autorelease];
    self.errorLabel = errorLabel;
    [errorLabel setHidden:YES];
    errorLabel.text = @"该文件不存在或已被删除";
    errorLabel.textColor = UIColorFromRGB(0x6d6d6d);
    [errorLabel setTextAlignment:NSTextAlignmentCenter];
    [errorLabel setFont:[UIFont systemFontOfSize:13]];
    [fileNameLabel_ setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [backView_ addSubview:errorLabel];
}

- (void)setWeibView {
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, ScreenFullWidth, ScreenFullHeight-64)];// autorelease];
//    webView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    webView_.backgroundColor = [UIColor clearColor];
    webView_.delegate = self;
    [webView_ setUserInteractionEnabled:YES];
    webView_.scalesPageToFit = YES;
    
    self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(100, 180, 100, 30)];// autorelease];
    [webView_ addSubview:loadingView_];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];// autorelease];
    activityIndicatorView.center = CGPointMake(activityIndicatorView.frame.size.width/2, loadingView_.frame.size.height/2);

    [activityIndicatorView startAnimating];
    [loadingView_ addSubview:activityIndicatorView];
       
    CGFloat loadingLabelOriginX = activityIndicatorView.frame.origin.x + activityIndicatorView.frame.size.width + 8;
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(loadingLabelOriginX, (loadingView_.frame.size.height - 20)/2, loadingView_.frame.size.width -loadingLabelOriginX, 20)];// autorelease];
    [loadingLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [loadingLabel setTextColor:[UIColor grayColor]];
    [loadingLabel setText:NSLocalizedString(@"LOADING...",@"")];
    [loadingLabel setBackgroundColor:[UIColor clearColor]];
    [loadingView_ addSubview:loadingLabel];
    [loadingView_ setHidden:YES];
    
    [self.view addSubview:webView_];
}


- (void)reviewDownload:(KDDownload *)download{
    if ([download isSuccess]) {
        self.navigationItem.title = download.name;
        [webView_ setHidden:NO];
        [backView_ setHidden:YES];
        
        if(![XTFileUtils isPhotoExt:[download.path pathExtension]])
        {
            [[KDWpsTool shareInstance] encryptFile:download.path complectionBlock:^(BOOL success, NSData *data, NSString *fileCachePath) {
                [self openfile:download];
            }];
        }
        else
            [self openfile:download];
    } 
    else {
        openAsBtn_.enabled = NO;
        [[KDDownloadManager sharedDownloadManager] addDownload:download];
        KDMockDownloadListener *mockDownloadListener = [[KDMockDownloadListener alloc] initWithDownloadListener:self];// autorelease];
        self.mockDownloadListener = mockDownloadListener;
        [[KDDownloadManager sharedDownloadManager] addListener:mockDownloadListener];
    }
}

- (void)startDownloading {
    //[self start];
    [progressView_ setProgress:0.0f];
    [webView_ setHidden:YES];
    [backView_ setHidden:NO];
}


- (void) updateDisplayWithProgressMonitor:(KDRequestProgressMonitor *)monitor {
    float progress = [monitor finishedPercent];
    if (![monitor isUnknownResponseLength]) {
        percentLabel_.text = [monitor finishedPercentAsString];
        currentVolumeLabel_.text = [monitor finishedByteToMaxByteAsString];
        [progressView_ setProgress:progress];
    }
    
}


- (void)downloadStateDidChange:(KDDownload *)download {
    if ([download isSuccess]) {
        //
        [self reviewDownload:download];
    }
    else if ([download isDownloading]) {
       
        [self startDownloading];
    }
    else if ([download isFailed]) {
        [[KDNotificationView defaultMessageNotificationView] showInView:self.view.window
                                                                message:NSLocalizedString(@"DOWNLOAD_ERROR_HAPPEN",@"")
                                                                   type:KDNotificationViewTypeNormal];
        
        [self dismissSelf];
    }
    else  if ([download isCancled]) {
        [self dismissSelf]; 
    }
}

- (void)downloadProgressDidChange:(KDRequestProgressMonitor *)monitor {
    [self updateDisplayWithProgressMonitor:monitor]; 
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

- (void)openfile:(KDDownload *)download
{
    if (download.path.length == 0) {
        return;
    }
    
    BOOL isSupport = [self downloadCanOpened:download];
    if(isSupport)
    {
        __block __typeof(self) weakSelf = self;
        NSString *pathSuffix = [[download_.path pathExtension]lowercaseString];
        //调用wps打开office文档,前提是后台有设置wps参数
        if(([XTFileUtils isDocExt:pathSuffix] || [XTFileUtils isTxtExt:pathSuffix]) && [[BOSSetting sharedSetting] isWPSControlOpen])
        {
            KDWpsTool *wpsTool = [[KDWpsTool alloc] init];
            wpsTool.fileName = download.name;
            wpsTool.filePath = download.path;
            if(![wpsTool openWPSWithFile:download.path])
            {
                //打开失败处理
            }
            [KDWpsTool shareInstance].tempWPSTool = wpsTool;
//           [wpsTool release];
            [self.navigationController popViewControllerAnimated:NO];
            return;
        }

        [[KDWpsTool shareInstance] decryptFile:download.path complectionBlock:^(BOOL success, NSData *data,NSString *fileCachePath) {
            
            if([pathSuffix isEqualToString:@"txt"]){//处理txt文件,否则txt文件会显示乱码
                NSStringEncoding enc = NSUTF8StringEncoding;
                NSString *body = [NSString stringWithContentsOfFile:fileCachePath encoding:enc error:NULL];
                if(!body){//gb2312编码后再尝试打开
                    enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                    body = [NSString stringWithContentsOfFile:fileCachePath encoding:enc error:NULL];
                }
                if (!body) {
                    enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif);
                    body = [NSString stringWithContentsOfFile:fileCachePath encoding:enc error:NULL];
                }
                if (!body) {
                    enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80);
                    body = [NSString stringWithContentsOfFile:fileCachePath encoding:enc error:NULL];
                }
                
                if (body) {
                    UITextView *textView = [[UITextView alloc] initWithFrame:webView_.bounds];
                    textView.editable = NO;
                    [webView_ addSubview:textView];
//                    [textView release];
                    [textView setText:body];
                    return;
                }
            }

            [weakSelf.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:fileCachePath]]];
        }];
    }
    
    else {
        [webView_ loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"error" ofType:@"html"]]]];
    }
}

- (long long)fileSizeAtPath:(NSString *)filePath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        NSInteger fileSizes = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        return fileSizes;
    }
    return 0;
}

#pragma mark -   view lifeCycle 
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setNavBarItem];
    
    [self setBackgroud];
    [self setWeibView];
    
    if(!isDownLoaded_) {
        [self setDownloadingUI];
    }else
    {
        if([self openAttactUrlView])
            return;
        
        [webView_ setHidden:NO];
        [backView_ setHidden:YES];
        [self openfile:download_];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNavBarItem];
    
    NSArray *gestures = [self.view gestureRecognizers];
    for(UIGestureRecognizer *recog in gestures) {
        if([recog isKindOfClass:[UIPanGestureRecognizer class]]) {
            recog.enabled = NO;
        }
    }
    
    
    //假如配置了在线查看地址
    if([self openAttactUrlView])
        return;
    
    //只允许下载指定的文件格式
    NSString *pathSuffix = [[download_.path pathExtension] lowercaseString];
    if(![[BOSSetting sharedSetting] allowFileDownload:pathSuffix])
    {
        [webView_ loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"error" ofType:@"html"]]]];
        return;
    }
    
    if(!isDownLoaded_)
        [self reviewDownload:download_];
}

- (void)viewDidUnload {
    DLog(@"viewDidUnload");
   
//    KD_RELEASE_SAFELY(backView_);
//    KD_RELEASE_SAFELY(fileTypeIconImageView_);
//    KD_RELEASE_SAFELY(fileNameLabel_);
//    KD_RELEASE_SAFELY(progressView_);
//    KD_RELEASE_SAFELY(percentLabel_);
//    KD_RELEASE_SAFELY(currentVolumeLabel_);
//    KD_RELEASE_SAFELY(self.errorLabel);
//    KD_RELEASE_SAFELY(backBtn_);
//    KD_RELEASE_SAFELY(openAsBtn_);
//    KD_RELEASE_SAFELY(webView_);
//    KD_RELEASE_SAFELY(loadingView_);
     [super viewDidUnload];
    
}


//假如提供了在线查看的url，就不管本地支不支持
-(BOOL)openAttactUrlView
{
    NSString *attactUrl = [[BOSSetting sharedSetting] attachViewUrlWithId:download_.entityId];
    if(attactUrl)
    {
        KDWebViewController *webController = [[KDWebViewController alloc] initWithUrlString:attactUrl];
        webController.title = download_.name;
        webController.hidesBottomBarWhenPushed = YES;
        webController.isRigthBtnHide = YES;
        UINavigationController *navVC = self.navigationController;
        [navVC popViewControllerAnimated:NO];
        [navVC pushViewController:webController animated:NO];
//        [webController release];
        return YES;
    }
    return NO;
}


#pragma mark -   webView delegate
#define LARGE_SIZE   10*1024*1024
- (void)webViewDidStartLoad:(UIWebView *)webView {
         //防止崩溃，下同。
    if ([self downloadCanOpened:download_] && download_.maxByte > LARGE_SIZE) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"SIZE_OVER_%dM_NOTIFICATION", nil),10];
        [[KDNotificationView defaultMessageNotificationView] showInView:self.view
                                                                message:message
                                                                   type:KDNotificationViewTypeNormal];
    }
    if ([self downloadCanOpened:download_] && [self fileSizeAtPath:download_.path] == 0) {
        [self.errorLabel setHidden:NO];
        [backView_ setHidden:NO];
        [webView_ setHidden:YES];
    }
    backBtn_.enabled = NO;
    openAsBtn_.enabled = NO;
    [loadingView_ setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    backBtn_.enabled = YES;
    openAsBtn_.enabled = YES;
    [loadingView_ setHidden:YES];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    backBtn_.enabled = YES;
    openAsBtn_.enabled = YES;
    [loadingView_ setHidden:YES];
    if (![self reviewWithAnotherApp]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EORROR_HAPPEN", @"")
                                                            message:NSLocalizedString(@"FORMAT_UNSUPPOTED_ERROR", @"")
                                                           delegate:nil 
                                                  cancelButtonTitle:NSLocalizedString(@"OKAY", @"")
                                                  otherButtonTitles: nil];
        [alertView show];
//        [alertView release];
    }
}

#pragma  mark - UIAlertView delegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([download_ isDownloading]) {
            [[KDDownloadManager sharedDownloadManager] cancleDownload:download_];
        }
    }
    
}

- (void)dealloc {
    
    //将明文文件删除
    [[KDWpsTool shareInstance] removeCacheFile:download_.path];
    
    // drop webview delegate
    webView_.delegate = nil;
//    KD_RELEASE_SAFELY(backView_);
//    KD_RELEASE_SAFELY(fileTypeIconImageView_);
//    KD_RELEASE_SAFELY(fileNameLabel_);
//    KD_RELEASE_SAFELY(progressView_);
//    KD_RELEASE_SAFELY(percentLabel_);
//    KD_RELEASE_SAFELY(currentVolumeLabel_);
//    KD_RELEASE_SAFELY(self.errorLabel);
//    KD_RELEASE_SAFELY(backBtn_);
//    KD_RELEASE_SAFELY(openAsBtn_);
//    KD_RELEASE_SAFELY(webView_);
//    KD_RELEASE_SAFELY(loadingView_);
//    KD_RELEASE_SAFELY(download_);
//    KD_RELEASE_SAFELY(docInteractionController_);
    
//    [super dealloc];
}

@end
