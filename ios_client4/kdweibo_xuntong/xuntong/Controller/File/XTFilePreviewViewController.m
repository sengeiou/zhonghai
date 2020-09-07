//
//  XTFilePreviewViewController.m
//  XT
//
//  Created by kingdee eas on 13-11-11.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTFilePreviewViewController.h"
#import "XTFileUtils.h"
#import "UIButton+XT.h"
#import "MBProgressHUD.h"
#import "XTWbClient.h"
#import "KDWpsTool.h"
#import "BOSSetting.h"
#import "KDForwardChooseViewController.h"

@interface XTFilePreviewViewController ()<UIWebViewDelegate,UIDocumentInteractionControllerDelegate, UIActionSheetDelegate, XTChooseContentViewControllerDelegate>

@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UIButton *openAsBtn;
@property(nonatomic, retain)UIDocumentInteractionController *docInteractionController;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,strong) XTWbClient *wbClient;
@property (nonatomic,copy) NSString *fileCachePath;
@end

@implementation XTFilePreviewViewController


- (id)initWithFilePath:(NSString *)path andFileExt:(NSString *)ext
{
    if (self = [super init]) {
        _filePath = [path copy];
        _fileExt = [ext copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //返回按钮
//    self.backButton = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"Global_GoBack")];
//    [self.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
//    self.navigationItem.leftBarButtonItems = @[backItem];
    UIButton *btn = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn]];
    
    if (!self.isReadOnly) {
        self.openAsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.openAsBtn setImage:[UIImage imageNamed:@"nav_btn_more_white_normal"] forState:UIControlStateNormal];
        [self.openAsBtn setImage:[UIImage imageNamed:@"navigationItem_more_press"] forState:UIControlStateHighlighted];
        //    self.openAsBtn.frame= CGRectMake(0.0, 0.0, 30,30);
        [self.openAsBtn addTarget:self action:@selector(moreOperation) forControlEvents:UIControlEventTouchUpInside];
        [self.openAsBtn sizeToFit];
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.openAsBtn];
        NSArray *rightNavigationItems;
        //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
        //2013-12-26 song.wang
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil] ;
        float width = kRightNegativeSpacerWidth;
        negativeSpacer.width = width - 5.f;
        rightNavigationItems =  @[negativeSpacer, rightItem];
        self.navigationItem.rightBarButtonItems = rightNavigationItems;
    }

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth, ScreenFullHeight)];
    _webView.userInteractionEnabled = YES;
    _webView.scalesPageToFit = YES;
    [self.view addSubview:_webView];
    
    if ([XTFileUtils isTxtExt:_fileExt]) {
        NSStringEncoding *usedEncoding = nil;
        NSError *error;
        NSString *body = [NSString stringWithContentsOfFile:_filePath usedEncoding:usedEncoding error:&error];
        if (!body) {
            body = [NSString stringWithContentsOfFile:_filePath encoding:0x80000632 error:&error];
        }
        if (!body) {
            body = [NSString stringWithContentsOfFile:_filePath encoding:0x80000631 error:&error];
        }
        if (body) {
            [self.webView loadHTMLString:body baseURL:nil];
            return;
        }
    }
    

    if(_filePath)
    {
        //非图片文件进行解密
        if(![XTFileUtils isPhotoExt:_fileExt])
        {
            __weak __typeof(self) weakSelf = self;
            [[KDWpsTool shareInstance] decryptFile:_filePath complectionBlock:^(BOOL success, NSData *data,NSString *fileCachePath) {
                
                weakSelf.fileCachePath = fileCachePath;
                if([_fileExt isEqualToString:@"txt"])
                {
                    ///编码可以解决 .txt 中文显示乱码问题
                    NSStringEncoding *enc = nil;
                    //带编码头的如utf-8等，这里会识别出来
                    NSString *body = [NSString stringWithContentsOfFile:fileCachePath usedEncoding:enc error:nil];
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

                    if(body)
                    {
                        CGRect frame = weakSelf.webView.bounds;
                        frame.origin.y = 64;
                        frame.size.height -= 64;
                        UITextView *textView = [[UITextView alloc] initWithFrame:frame];
                        textView.editable = NO;
                        [weakSelf.webView addSubview:textView];
                        [textView setText:body];
                        return;
                    }
                    
                    return;
                }
                NSURL *url = [NSURL fileURLWithPath:fileCachePath];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [weakSelf.webView loadRequest:request];
            }];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"XTFilePreviewViewController_No")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setNavigationStyle:KDNavigationStyleYellow];
}

- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)moreOperation{
    if(self.isFromJSBridge)
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"XTFilePreviewViewController_OtherApp"), nil];
        [sheet showInView:self.view.window];
    }
    else
    {
        UIActionSheet *sheet = nil;
        if([BOSSetting sharedSetting].allowMsgInnerMobileShare && [BOSSetting sharedSetting].allowMsgOuterMobileShare)
        {
            sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"KDABActionTabBar_tips_1"),ASLocalizedString(@"KDStatusDetailViewController_Forward"),ASLocalizedString(@"XTFilePreviewViewController_OtherApp"), nil];
        }
        else if([BOSSetting sharedSetting].allowMsgInnerMobileShare && ![BOSSetting sharedSetting].allowMsgOuterMobileShare)
        {
            sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"KDABActionTabBar_tips_1"),ASLocalizedString(@"KDStatusDetailViewController_Forward"), nil];
        }
        else if(![BOSSetting sharedSetting].allowMsgInnerMobileShare && [BOSSetting sharedSetting].allowMsgOuterMobileShare)
        {
            sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"KDABActionTabBar_tips_1"),ASLocalizedString(@"XTFilePreviewViewController_OtherApp"), nil];
        }
        [sheet showInView:self.view.window];
    }
}
- (BOOL)reviewWithAnotherApp {
    BOOL canReview = NO;
    NSURL *fileURL = [NSURL fileURLWithPath:self.fileCachePath];
    [self setupDocumentControllerWithURL:fileURL];
    if ([self.docInteractionController presentOpenInMenuFromBarButtonItem:[self.navigationItem.rightBarButtonItems lastObject] animated:YES]) {
        canReview = YES;
    }
    return canReview;
}

- (void)setupDocumentControllerWithURL:(NSURL *)url {
    if (self.docInteractionController == nil) {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        
    } else {
        self.docInteractionController.URL = url;
    }
}



#pragma mark - operation

- (void)stowFile{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
    hud.mode = MBProgressHUDModeText;
    [hud setLabelText:ASLocalizedString(@"XTFilePreviewViewController_Collect")];
    hud.removeFromSuperViewOnHide = YES;
    [self.view.window addSubview:hud];
    [hud show:YES];
    
    self.hud = hud;
    
    self.wbClient = [[XTWbClient alloc] initWithTarget:self action:@selector(stowFileDidReceived:result:)];
    [_wbClient stowFile:_file.fileId networkId:[BOSConfig sharedConfig].user.eid];
}
- (void)stowFileDidReceived:(XTWbClient *)client result:(BOSResultDataModel *)result{
    
    if (client.hasError) {
        [[[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTChatViewController_Tip_24")message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"好的")otherButtonTitles:nil, nil] show];
        [_hud hide:YES];
        return;
    }
    if (!result.success) {
        [[[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTChatViewController_Tip_24")message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"好的")otherButtonTitles:nil, nil] show];
        [_hud hide:YES];
    }
    else{
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FILE_DETAIL_STOW_GUIDE"]) {
            
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"FILE_DETAIL_STOW_GUIDE"];
            [_hud hide:YES];
            
            [[[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTChatViewController_Tip_20")message:ASLocalizedString(@"XTChatViewController_Tip_21")delegate:nil cancelButtonTitle:ASLocalizedString(@"KDAddOrUpdateSignInPointController_tips_32")otherButtonTitles:nil, nil] show];
        }
        else{
            [_hud setLabelText:ASLocalizedString(@"XTChatViewController_Tip_23")];
            [_hud hide:YES afterDelay:2.0];
        }
    }
    
}

- (void)shareFile
{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[_file.name,[NSString stringWithFormat:@"%d",ForwardMessageFile],[_file messageFileFromFileModel]] forKeys:@[@"message",@"forwardType",@"messageFileDM"]];
    XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:dict];
    KDForwardChooseViewController *contentViewController = [[KDForwardChooseViewController alloc] initWithCreateExtenalGroup:YES];
    contentViewController.isFromConversation = YES;
    contentViewController.hidesBottomBarWhenPushed = YES;
    contentViewController.isFromFileDetailViewController = NO;   //触发转发文件埋点
    //contentViewController.fileDetailDictionary = notify.userInfo;
    contentViewController.isMulti = YES;
    contentViewController.forwardData = @[forwardDM];
    contentViewController.delegate = self;
    contentViewController.type = XTChooseContentForward;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    if(self.navigationController.presentingViewController)
        [self.navigationController presentViewController:contentNav animated:YES completion:nil];
    else
        [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
    
    
//    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentForward];
//    contentViewController.delegate = self;
//    contentViewController.forwardData = forwardDM;
//    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
//    if(self.navigationController.presentingViewController)
//        [self.navigationController presentViewController:contentNav animated:YES completion:nil];
//    else
//        [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
}
#pragma mark - XTChooseContentViewControllerDelegate

- (void)popViewController
{
    // 从应用-我的文件进入
    [self setNavigationStyle:KDNavigationStyleNormal];
    if(self.navigationController.presentingViewController)
        [self dismissViewControllerAnimated:NO completion:nil];
    else
        [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - UIWebViewDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

#pragma mark - UIDocumentInteractionControllerDelegate

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application
{
    
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application
{
    
}

-(void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:ASLocalizedString(@"KDABActionTabBar_tips_1")]) {
        
        [self stowFile];
    }
    else if([title isEqualToString:ASLocalizedString(@"KDStatusDetailViewController_Forward")]){
    
        [self shareFile];
    }
    else if([title isEqualToString:ASLocalizedString(@"XTFilePreviewViewController_OtherApp")]){
        [self reviewWithAnotherApp];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}

-(void)dealloc
{
    //将明文文件删除
    [[KDWpsTool shareInstance] removeCacheFile:_filePath];
}
@end
