//
//  KDWebViewController.m
//  kdweibo
//
//  Created by Gil on 14-10-20.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDWebViewController.h"
#import "KDWebViewController+Share.h"
#import "KDWebViewController+JSBridge.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgressView+YZJ.h"
#import "NSString+Scheme.h"
#import "XTOpenSystemClient.h"
#import "BOSConfig.h"
#import "UIButton+XT.h"
#import "KDLinkInviteConfig.h"
#import "UIColor+KDV6.h"
#import "BOSUtils.h"
#import "NSString+Operate.h"
#import "KDWebViewController+JSCreatePop.h"
#import "KDWebViewController+LongPress.h"
#import "KDWaterMarkAddHelper.h"
#import "URL+MCloud.h"
#import "KDFileDownloadManager.h"

static NSString *KDWebViewLightAppScheme = @"xuntong:";

@interface KDWebViewController ()<CLLocationManagerDelegate,KDWebViewDelegate>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSURL *webUrl;
@property (nonatomic, assign) KDWebViewType type;

//@property (strong, nonatomic) NSString *pubAccId;
@property (strong, nonatomic) NSString *menuId;
@property (strong, nonatomic) NSString *appId;

@property (nonatomic, strong) KDWebView *webView;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) XTOpenSystemClient *openClient;//KDWebViewTypeParams
@property (nonatomic, strong) MCloudClient *mCloudClient;//KDWebViewTypeTicket

@property (nonatomic, strong) NJKWebViewProgressView *progressView;
//@property (nonatomic, strong) NJKWebViewProgress *progressProxy;

@property (nonatomic, strong) CLLocationManager *locationMgr;

@property (assign, nonatomic) BOOL isProgressing;//进度条状态
@property (assign, nonatomic) BOOL isLoaded;//页面状态
@property (assign, nonatomic) UIStatusBarStyle statusBarStyle;
@property (nonatomic, strong) NSURL *pageUrl;     //当前页面初始url
@property (nonatomic, strong) NSURL *currentUrl;

// 优先级最低的title，highertitle > document.title > webLowerTitle
@property (strong , nonatomic) NSString *webHigherTitle;
@property (strong , nonatomic) NSString *webLowerTitle;
@property (strong , nonatomic) NSString *documentTitle;
@property (assign, nonatomic)UIStatusBarStyle *parentVCStatusBarStyle;
@end

@implementation KDWebViewController

+ (void)initialize
{
    NSString *deviceName = [BOSUtils urlEncode:[[UIDevice currentDevice].name stringByReplacingOccurrencesOfString:@";" withString:@""]];
    NSString *os = [NSString stringWithFormat:@"%@ %@",[UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
    NSString *defaultUserAgent = [[NSString alloc] initWithFormat:@"Qing/1.0.1;%@;Apple;%@;deviceId:%@;deviceName:%@;clientId:%@;os:%@;projectCode:%@;xtUrl:%@;brand:Apple;model:%@;%@", os, [UIDevice platform], [UIDevice uniqueDeviceIdentifier], deviceName, XuntongAppClientId, os, [KDCommon getProjectCode],MCLOUD_IP_FOR_PUBACC, [UIDevice platform], [[UIWebView new] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:defaultUserAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}


- (id)initWithUrlString:(NSString *)url
{
    self = [super init];
    if (self) {
        self.orientation = UIInterfaceOrientationPortrait;
        self.parentVCStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        self.type = KDWebViewTypeNomal;
        if (url.length > 0) {
            if (![url hasPrefix:@"http"]) {
                url = [@"http://" stringByAppendingString:url];
            }
            self.url = url;
            //普通url里面带空格打不开问题
            //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            url = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                        (CFStringRef)url,
                                                                                        (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                                                        NULL,
                                                                                        kCFStringEncodingUTF8));
            self.webUrl = [NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@" "withString:@" "]];
        }
    }
    return self;
}
- (id)initWithUrlStringNotAddHttp:(NSString *)url {
    self = [super init];
    if (self) {
        self.orientation = UIInterfaceOrientationPortrait;
        self.parentVCStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        self.type = KDWebViewTypeNomal;
//        self.adminNewUserGuidePage = NO;
        if (url.length > 0) {
            self.url = url;
            self.webUrl = [NSURL URLWithString:url];
        }
    }
    return self;
}
- (id)initWithUrlString:(NSString *)url
               pubAccId:(NSString *)pubAccId
                 menuId:(NSString *)menuId
{
    self = [self initWithUrlString:url];
    if (self) {
        if (pubAccId.length > 0) {
            self.type = KDWebViewTypeParams;
            self.pubAccId = pubAccId;
        }
        if (menuId.length > 0) {
            self.menuId = menuId;
        }
    }
    return self;
}

- (id)initWithUrlString:(NSString *)url
                  appId:(NSString *)appId
{
//    self = [self initWithUrlString:url];
    if (appId.length > 0) {
        self = [self initWithUrlStringNotAddHttp:url];
    }
    else {
        self = [self initWithUrlString:url];
    }
    if (self) {
        if (appId.length > 0) {
            self.type = KDWebViewTypeTicket;
            self.appId = appId;
        }
    }
    return self;
}

- (instancetype)initWithUrlString:(NSString *)url
                         OpenUser:(OpenUser *)user
{
    self = [super init];
    if (self) {
        if (url.length > 0) {
            self.webUrl = [NSURL URLWithString:url];
        } else {
            self.wxsqUser = user;
        }
    }
    return self;
}



- (void)dealloc
{
    [[KDFileDownloadManager shareManager] cancelDownload];
   	_webView.delegate = nil;
    [_openClient cancelRequest];
    [_mCloudClient cancelRequest];
    // 退出微信社区
    if (self.wxsqUser) {
        [BuluoSDK exitCommunity];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpLocate];
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (![self canLoadUrl]) {
        [self setBackgroud:YES];
        return;
    }
    
    //网页内容webView
    [self.view addSubview:self.webView];
//    [self.webView makeConstraints:^(MASConstraintMaker *make)
//     {
//         make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
//     }];
    self.webView.frame = CGRectMake(0, 0, ScreenFullWidth, ScreenFullHeight - kd_StatusBarAndNaviHeight);
    
    self.isOriginalNavBarHidden = self.navigationController.navigationBarHidden;
    
    if (self.wxsqUser) {
        [BuluoSDK openCommunityWithOpenUser:self.wxsqUser webView:(UIWebView *)self.webView failure:^(NSError *error) {
            if (error) {
                // 授权信息异常
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:ASLocalizedString(@"KDSignatureViewController_authorized_fail") preferredStyle:UIAlertControllerStyleAlert];
                
                __weak __typeof(self) weakSelf = self;
                UIAlertAction *actionSure = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
                [alertVC addAction:actionSure];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        }];
    }
    
    //如果不设置getLightAppBlock，则在这里加载
    //否则在getLightAppBlock的set方法中加载
    // 如果是微信社区，不在这里加载，用sdk打开加载
    if(!self.getLightAppBlock && !self.wxsqUser) {
        [self loadRequest];
    }

    //长按图片链接
    [self setupLongPressEvent];
    
    
    //开启水印,轻应用先临时关闭，isLightApp
    if ((self.type == KDWebViewTypeParams || self.type == KDWebViewTypeNomal) && [[BOSSetting sharedSetting] openWaterMark:WaterMarkTypPublicAndLightApp] && !self.isLightApp)
    {
        CGRect frame = CGRectMake(0, 0, ScreenFullWidth, self.view.frame.size.height);
        [KDWaterMarkAddHelper coverOnView:self.view withFrame:frame];
    }
    else
    {
        [KDWaterMarkAddHelper removeWaterMarkFromView:self.view];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

    //左上角按钮
    
    [self setupLeftBarButtonItem];
    [self.navigationController.navigationBar addSubview:self.progressView];
    
    //修复JS不能连续两次唤醒的问题
    self.functionViewController = nil;
    
    if (self.color4NavBg.length > 0) {
        [self changeToLightAppNavStyleWithColorStr:self.color4NavBg];
    }
    else
    {
        [self setNavigationStyle:KDNavigationStyleNormal];
    }
    if (self.isOriginalNavBarHidden != self.isTitleNavHidden) {
        self.navigationController.navigationBarHidden = self.isTitleNavHidden;
    }
    if (self.isBlueNav){
        [self setNavigationStyle:KDNavigationStyleBlue];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self releaseSecondWindow];
    [KDWeiboAppDelegate getAppDelegate].tabBarController.tabBar.hidden = YES;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupLeftBarButtonItem];
    
    //不加这一段会导致选择附件返回时，title不见
    if (self.color4NavBg.length > 0) {
        [self changeToLightAppNavStyleWithColorStr:self.color4NavBg];
    }
    else
    {
        [self setNavigationStyle:KDNavigationStyleNormal];
    }
    if (self.isBlueNav){
        [self setNavigationStyle:KDNavigationStyleBlue];
    }
}


- (void)changeToLightAppNavStyleWithColorStr:(NSString *)colorStr
{
    if (self.navigationController.navigationBar.hidden) {
        return;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if(colorStr && colorStr.length==7)
    {
        NSString *color = [colorStr substringWithRange:NSMakeRange(1, colorStr.length-1)];
        [self setNavigationCustomStyleWithColor:[UIColor colorWithHexRGB:color]];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[self.view endEditing:YES];
    [self.progressView removeFromSuperview];

    if (self.isMovingFromParentViewController) {
    
        if (self.color4NavBg.length > 0) {
            [self setNavigationStyle:KDNavigationStyleNormal];
        }
        
        if (self.isOriginalNavBarHidden != self.isTitleNavHidden) {
            self.navigationController.navigationBarHidden = self.isOriginalNavBarHidden;
            //            [UIApplication sharedApplication].statusBarHidden = self.isOriginalNavBarHidden;
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    //隐藏菜单
    [self hidePlusMenu];
    [self releaseSecondWindow];
}
- (void)didEnterBackground {
//    [self stopVideo];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)canLoadUrl
{
    BOOL result = NO;
    switch (self.type) {
        case KDWebViewTypeNomal:
        {
            result = (self.url.length > 0);
            if (self.wxsqUser) {
                result = YES;
            }
        }
            break;
        case KDWebViewTypeParams:
        {
            result = (self.url.length > 0 && self.pubAccId.length > 0);
        }
            break;
        case KDWebViewTypeTicket:
        {
            result = (self.appId.length > 0);
        }
            break;
        default:
            break;
    }
    return result;
}

- (UIView *)backgroundView
{
    if (_backgroundView == nil) {
		_backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
		_backgroundView.backgroundColor = [UIColor clearColor];
        
		UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud"]];
		[bgImageView sizeToFit];
		bgImageView.center = CGPointMake(_backgroundView.bounds.size.width * 0.5f, 137.5f);
        
		[_backgroundView addSubview:bgImageView];
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(bgImageView.frame) + 15.0f, self.view.bounds.size.width, 38.0f)];
		label.numberOfLines = 0;
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:15.0f];
		label.textColor = MESSAGE_NAME_COLOR;
		label.text = ASLocalizedString(@"KDWebViewControlle_Error");
        
		[_backgroundView addSubview:label];
		[self.view addSubview:_backgroundView];
	}
    
    return _backgroundView;
}

- (void)setBackgroud:(BOOL)isLoad {
    self.backgroundView.hidden = !isLoad;
    if (self.progressView) {
        [self.progressView setProgress:1 animated:NO];
    }
    if (self.rightButton) {
        self.rightButton.hidden = YES;
    }
    self.backgroundView.hidden = !isLoad;
    
    if (self.progressView) {
        [self.progressView setProgress:1.0 animated:YES ];
    }
    self.optionMenuButton.hidden = YES;
}
- (void)setGetLightAppBlock:(GetLightAppUrlCompleteBlock)getLightAppBlock {
    _getLightAppBlock = getLightAppBlock;
//    self.navigationBarBackgroundHidden = YES;
    [self loadRequest];
}
- (void)setGetLightAppBlock:(GetLightAppUrlCompleteBlock)getLightAppBlock appId:(NSString *)appId url:(NSString *)url {
    _getLightAppBlock = getLightAppBlock;
//    self.navigationBarBackgroundHidden = YES;
    [self loadNomalRequestWithUrl:url appId:appId];
}
//普通URL直接加载，获取颜色配置
- (void)loadNomalRequestWithUrl:(NSString *)url appId:(NSString *)appId {
//    if (self.adminNewUserGuidePage) {
        if (self.getLightAppBlock) {
            [MBProgressHUD showHUDAddedTo:AppWindow animated:YES];
            [self performSelector:@selector(getLightAppURLDidTimeOut) withObject:nil afterDelay:24];
//            [self.mCloudClient getLightAppURLWithMid:[BOSConfig sharedConfig].user.eid appid:appId openToken:[BOSConfig sharedConfig].user.token urlParam:url];
            
            if (_todoMsgId == nil || _todoMsgId.length == 0 ) {
                _todoMsgId = @"";
            }
            if (_todoUserId == nil || _todoUserId.length == 0 ) {
                _todoUserId = @"";
            }
            if (_todoGroupId == nil || _todoGroupId.length == 0 ) {
                _todoGroupId = @"";
            }
            if (_todoStatus == nil || _todoStatus.length == 0 ) {
                _todoStatus = @"";
            }
            
            [self.mCloudClient getLightAppURLWithMid:[BOSConfig sharedConfig].user.eid appid:appId openToken:[BOSConfig sharedConfig].user.token groupId:_todoGroupId userId:_todoUserId msgId:_todoMsgId urlParam:url todoStatus:_todoStatus];
        }
//    }
}
#pragma mark - left & right btn

- (BOOL)isWhileNav {
    if (self.isBlueNav || (self.color4NavBg && self.color4NavBg.length > 0)) return NO;
    return YES;
}
- (void)setupLeftBarButtonItem
{
    UIButton *backBtn = (![self isWhileNav]) ?[UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"Global_GoBack")] :[UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Close") style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
    
    [closeItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[backBtn titleColorForState:UIControlStateNormal] , NSFontAttributeName:backBtn.titleLabel.font } forState:UIControlStateNormal];
    [closeItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[backBtn titleColorForState:UIControlStateHighlighted] , NSFontAttributeName:backBtn.titleLabel.font} forState:UIControlStateHighlighted];
    
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:backBtn], closeItem];
    
    //小于8.1系统 ，leftBarButtonItems 对于上面2种不同的item创建方式放置位置不一样
    if ([UIDevice currentDevice].systemVersion.doubleValue <= 8.1) {
        [backBtn setContentEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 0)];
    }

}

- (void)setupLeftBarButtonItems
{
    UIButton *backBtn = (![self isWhileNav]) ?[UIButton backBtnInBlueNavWithTitle:self.backBtnTitle] :[UIButton backBtnInWhiteNavWithTitle:self.backBtnTitle];
    
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;

}

- (void)setupRightBarButtonItem
{
   
    //设置非轻应用右上角按钮
    if (self.type != KDWebViewTypeTicket || self.personDataModel) {
//        if (self.canshare == YES) {
            [self initialOptionMenuButtonWithMenuModels:nil withTitle:nil hiddenShare:NO];
//        }
    }
}

- (void)setUpLocate {
    self.locationMgr.delegate = self;
    if ([[UIDevice currentDevice].systemVersion doubleValue] > 8.0) {
        [self.locationMgr requestWhenInUseAuthorization];
    } else {
        [self.locationMgr startUpdatingLocation];
    }
}

-(void)reloadAction:(UIButton *)btn
{
    [self.webView reload];
}


- (void)dismissSelf {
    __weak __typeof(self) weakSelf = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    [self rotateUIWithOrientation:@""];
	if ([self.navigationController.viewControllers count] == 1) { //是prensent 的方式
		[self.navigationController dismissViewControllerAnimated:YES completion:^{
            [weakSelf setNavigationStyle:KDNavigationStyleNormal];
            [[UIApplication sharedApplication] setStatusBarStyle:self.parentVCStatusBarStyle];
        }];
	}
	else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)back:(UIButton *)button
{
    //自定义了返回按钮
    if ([self isDefBack]) {
        [self defback];
        return;
    }
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        [self setupLeftBarButtonItems];
        if (self.showingMenu) {
            [self hidePlusMenu];
        }
        return;
    }
    if (self.showingMenu) {
        [self hidePlusMenu];
        [self.optionMenuView removeFromSuperview];
    }
    
    
    if ([[KDLinkInviteConfig sharedInstance] isExistInvite]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[KDLinkInviteConfig sharedInstance] cancelInvite];
        }];
        
    }
    
    if (_detailLocationManager) {
        [_detailLocationManager stopOpration];
    }
    
//    if (_hud && _hud.superview) {
//        [_hud removeFromSuperview];
//        _hud = nil;
//    }
    [self.sheet hideSheet];
    [self dismissSelf];
    
}

- (void)close:(UIButton *)btn
{
    [self dismissSelf];
}

#pragma mark - load

- (void)loadRequest
{
    switch (self.type) {
        case KDWebViewTypeNomal://普通URL直接加载
        {
            if (self.getLightAppBlock) {
                self.getLightAppBlock();
            }
            [self.webView loadRequest:[NSURLRequest requestWithURL:self.webUrl]];
        }
            break;
        case KDWebViewTypeParams:
//        {
//            if (self.getLightAppBlock) {
//                self.getLightAppBlock();
//            }
//            [self.openClient getPubAccTokenWithOpenToken:[BOSConfig sharedConfig].user.token pubAccId:self.pubAccId deviceId:[UIDevice uniqueDeviceIdentifier] menuId:self.menuId openId:[BOSConfig sharedConfig].user.oId];
//        }
//            break;
        case KDWebViewTypeTicket:
        {
            if (self.getLightAppBlock) {
                [MBProgressHUD showHUDAddedTo:AppWindow animated:YES];
                [self performSelector:@selector(getLightAppURLDidTimeOut) withObject:nil afterDelay:24];
            }
            if(self.appType == KDAppTypeYunApp)
                [self.mCloudClient getYunAppURLWithMid:[BOSConfig sharedConfig].user.eid appid:self.appId openToken:[BOSConfig sharedConfig].user.token urlParam:self.url];
            else
            {
                if (_todoMsgId == nil || _todoMsgId.length == 0 ) {
                    _todoMsgId = @"";
                }
                if (_todoUserId == nil || _todoUserId.length == 0 ) {
                    _todoUserId = @"";
                }
                if (_todoGroupId == nil || _todoGroupId.length == 0 ) {
                    _todoGroupId = @"";
                }
                if (_todoStatus == nil || _todoStatus.length == 0 ) {
                    _todoStatus = @"";
                }
                //zgbin:修复必达界面刷新后ticket失效bug,注意iWork的大写
                if ([self.url hasPrefix:@"https://iWork.coli688.com:8010/web/task/index?"]) {
                    [self.mCloudClient getLightAppURLWithMid:[BOSConfig sharedConfig].user.eid appid:self.appId openToken:[BOSConfig sharedConfig].user.token groupId:_todoGroupId userId:_todoUserId msgId:_todoMsgId urlParam:@"" todoStatus:_todoStatus];
                } else {
                    [self.mCloudClient getLightAppURLWithMid:[BOSConfig sharedConfig].user.eid appid:self.appId openToken:[BOSConfig sharedConfig].user.token groupId:_todoGroupId userId:_todoUserId msgId:_todoMsgId urlParam:self.url todoStatus:_todoStatus];
                }
                
            }
        }
            break;
        default:
            break;
    }
}

- (XTOpenSystemClient *)openClient
{
    if (_openClient == nil) {
        _openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getPubAccTokenDidReceived:result:)];
    }
    return _openClient;
}

- (MCloudClient *)mCloudClient
{
    if (_mCloudClient == nil) {
        _mCloudClient = [[MCloudClient alloc] initWithTarget:self action:@selector(getLightAppURLDidReceived:result:)];
    }
    return _mCloudClient;
}

- (CLLocationManager *)locationMgr {
    if (!_locationMgr) {
        _locationMgr = [[CLLocationManager alloc] init];
    }
    return _locationMgr;
}

- (void)getPubAccTokenDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if ([result isKindOfClass:[BOSResultDataModel class]] && result.success && result.data && [result.data isKindOfClass:[NSDictionary class]]) {

        NSDictionary *data = (NSDictionary *)result.data;
        NSString *opentoken = data[@"opentoken"];
        long long nonce = [data[@"nonce"] longLongValue];
        long long timestamp = [data[@"timestamp"] longLongValue];
        NSString *param = [NSString stringWithFormat:@"opentoken=%@&nonce=%lld&timestamp=%lld&openid=%@&eid=%@&pubaccid=%@",opentoken,nonce,timestamp,[BOSConfig sharedConfig].user.oId,[BOSSetting sharedSetting].cust3gNo,self.pubAccId];
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.url addParams:param]]]];
        
        return;
    }
    //每次请求带参数的URL之前清除本地缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    //这种模式下应该一定会有url
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.webUrl]];
}

- (void)getLightAppURLDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (self.getLightAppBlock) {
        [MBProgressHUD hideHUDForView:AppWindow animated:YES];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getLightAppURLDidTimeOut) object:nil];
    }
    
//    if (!result.success && result.errorCode == 2) {
//        [[KDNotificationChannelCenter defaultCenter] logout:result.error];
//        return;
//    }
    if (result.success && result.data && [result.data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *data = (NSDictionary *)result.data;
        NSString *url = data[@"url"];
        
        if(!self.abortUseWebTitle)
        {
            //title颜色
            NSString *titleBgColor = data[@"titleBgColor"];
            NSString *titlePbColor = data[@"titlePbColor"];
            if (!self.isBlueNav) {
                if (titleBgColor && ![titleBgColor isKindOfClass:[NSNull class]] && titleBgColor.length > 0 && ![titleBgColor isEqualToString:@"#ffffff"]) {
                    self.color4NavBg = titleBgColor;
                }else{
//                    self.navigationBarBackgroundHidden = NO;
                }
                if (titlePbColor && ![titlePbColor isKindOfClass:[NSNull class]] && titlePbColor.length > 0) {
                    self.color4processBg = titlePbColor;
                }
            }
            else if(!titleBgColor || [titleBgColor isKindOfClass:[NSNull class]] || [titleBgColor isEqualToString:@"#ffffff"])
            {
//                self.navigationBarBackgroundHidden = NO;
            }
            
        }
        
        if (self.getLightAppBlock) {
            self.getLightAppBlock();
        }

        //去除中文字符
        url = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                (CFStringRef)url,
                                                (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                NULL,
                                                kCFStringEncodingUTF8));
//        if (![url isKindOfClass:[NSNull class]] && url.length > 0) {
//            if (self.url.length == 0) {
//                self.url = url;
//                self.webUrl = [NSURL URLWithString:url];
//            }
//            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
//            return;
//        }
//        
//        if (![url isKindOfClass:[NSNull class]] && url.length > 0) {
//            if (self.url.length == 0) {
//                if (self.blockEditURL) {
//                    url = self.blockEditURL(url);
//                }
//                self.url = url;
//                self.webUrl = [NSURL URLWithString:url];
//            }
//            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
//            return;
//        }
        
        if (self.groupAppURL.length > 0) {
            NSString *ticket = data[@"ticket"];
            self.groupAppURL = [self.groupAppURL stringByAppendingString:[NSString stringWithFormat:@"&ticket=%@",ticket]];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.groupAppURL]]];
            return;
        }
        
        if (![url isKindOfClass:[NSNull class]] && url.length > 0 && self.type == KDWebViewTypeTicket) {
            if (self.url.length == 0) {
                if (self.blockEditURL) {
                    url = self.blockEditURL(url);
                }
                self.url = url;
                self.webUrl = [NSURL URLWithString:url];
            }
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        }
        if (self.type == KDWebViewTypeNomal) {
            [self.webView loadRequest:[NSURLRequest requestWithURL:self.webUrl]];
        }
        return;

    }
    else
    {
//        self.navigationBarBackgroundHidden = NO;
    }
    //
    if (self.getLightAppBlock) {
        self.getLightAppBlock();
    }
    
    if (self.url.length == 0) {
        [self setBackgroud:YES];
        return;
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.webUrl]];
}
- (void)getLightAppURLDidTimeOut {
    [_mCloudClient cancelRequest];
    _mCloudClient = nil;
    
    [MBProgressHUD hideHUDForView:AppWindow animated:YES];
//    [MBProgressHUD showError:@"加载超时" toView:AppWindow];
}

- (void)setCurrentUrl:(NSURL *)currentUrl {
    _currentUrl = currentUrl;
    //把url #号后面截掉为初始url
    if (_currentUrl) {
        NSString *string = [self getPageUrlStringWithUrlString:_currentUrl.absoluteString];
        _pageUrl = [NSURL URLWithString:string];
    }
}
#pragma mark - NJKWebViewProgressDelegate

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:YES];
}

#pragma mark - UIWebViewDelegate

- (BOOL)kdWebView:(KDWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"###########%@",requestString);
    if ([requestString hasPrefix:KDWebViewLightAppScheme]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self executeJSBridge:requestString];
        });
    }
    return YES;
}
- (void)kdWebViewDidStartLoad:(KDWebView *)webView {
    NSString *pageString = [self getPageUrlStringWithUrlString:webView.URL.absoluteString];
    //跳到新页面，清除右上角自定义桥
    if ([pageString hasPrefix:@"http"] && self.pageUrl && ![pageString isEqualToString:_pageUrl.absoluteString] && self.createPopTask) {
        self.createPopTask = nil;
        //share 有个坑 先忽略
        self.jsShareData = nil;
        self.optionMenuButton.hidden = YES;
        [self resetDefback];
    }
    self.currentUrl = webView.URL;
    [self startProgress];
}

- (void)kdWebViewDidFinishLoad:(KDWebView *)webView {
    [self finishProgress];
    self.currentUrl = webView.URL;
    if (webView.usingUIWebView && !self.abortUseWebTitle) {
        NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        [self setWebViewTitle:title leavel:KDWebViewTitleLevel_Document];
    }
    // 不能分享的公共号，去掉系统的选中文本框
    PersonSimpleDataModel *pubModel = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicAccountWithId:self.pubAccId];
    if (pubModel && !([pubModel allowInnerShare]||[pubModel allowOuterShare])) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
        [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    }
    
    //右上角按钮
    if(!self.isRigthBtnHide || self.isOnlyOpenInBrowser) {
        if ((self.personDataModel && ([self.personDataModel allowInnerShare]||[self.personDataModel allowOuterShare]))|| self.isOnlyOpenInBrowser) {
            [self setupRightBarButtonItem];
        }else{
            // 如果是公众号，但公众号不可分享，则没有右上角的按钮
        }
    }
}

- (void)kdWebView:(KDWebView *)webView didFailLoadWithError:(NSError *)error {
    [self finishProgress];
}

//- (void)kdWebView:(KDWebView *)webView observeTitleValueChange:(NSString *)title {
//    [self setWebViewTitle:title leavel:KDWebViewTitleLevel_Document];
//}
- (NSString *)getPageUrlStringWithUrlString:(NSString *)urlString {
    if ( [urlString containSubString:@"#"]) {
        NSRange rang = [urlString rangeOfString:@"#"];
        NSString *pageString = [urlString substringToIndex:rang.location];
        return pageString;
    }
    return urlString;
}

#pragma mark - Progress -

- (void)startProgress {
    if (self.isProgressing) {
        return;
    }
    self.isProgressing = YES;
    //假的进度条（3秒到70%，再3秒到80%，然后90%）
    if (!self.isLoaded) {
        __weak __typeof(self) weakSelf = self;
        self.progressView.barAnimationDuration = 3.0;
        [self.progressView setProgress:0.6 animated:YES completion:^(BOOL finished) {
            if (!weakSelf.isLoaded) {
                weakSelf.progressView.barAnimationDuration = 3.0;
                [weakSelf.progressView setProgress:0.8 animated:YES completion:^(BOOL finished) {
                    if (!weakSelf.isLoaded) {
                        weakSelf.progressView.barAnimationDuration = 4.0;
                        [weakSelf.progressView setProgress:0.9 animated:YES completion:^(BOOL finished) {
                            weakSelf.isProgressing = NO;
                        }];
                    }
                }];
            }
        }];
    }
}

- (void)finishProgress {
    self.isLoaded = YES;
    __weak __typeof(self) weakSelf = self;
    self.progressView.barAnimationDuration = 0.25;
    [self.progressView.progressBarView.layer removeAllAnimations];
    [self.progressView setProgress:0.99 animated:YES completion:^(BOOL finished) {
        [weakSelf.progressView setProgress:1.0 animated:YES completion:^(BOOL finished) {
            weakSelf.isProgressing = NO;
        }];
    }];
}
#pragma mark - UIActionSheetDelegate
//写在这是因为Share和JSBridge都会用到
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	
    if ([self shareActionWithTitle:buttonTitle]) {
        return;
    }
    
    if ([self jsBridgeActionWithTitle:buttonTitle]){
        return;
    }
    if ([self longPressShareActionWithTitle:buttonTitle actionSheet:actionSheet]) {
        return ;
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //定位的精确度(米)
        self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
        //定位服务更新频率
        self.locationMgr.distanceFilter = kCLDistanceFilterNone;
        
        //开始定位
        [self.locationMgr startUpdatingLocation];
    } else if(status == kCLAuthorizationStatusDenied) {
        //不允许定位请求
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.appLocation = [locations lastObject];
    NSLog(@"定位的位置：%f, %f", self.appLocation.coordinate.latitude, self.appLocation.coordinate.longitude);
    
    //停止定位
    [self.locationMgr stopUpdatingLocation];
}
- (NJKWebViewProgressView *)progressView {
    if (_progressView == nil) {
        CGFloat progressBarHeight = 2.f;
        CGRect barFrame = CGRectMake(0, NavigationBarHeight - progressBarHeight, self.view.bounds.size.width, progressBarHeight);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _progressView.progressBarView.backgroundColor = self.isBlueNav ? [UIColor colorWithRGB:0x46E7FF] : FC5;
        if (self.color4processBg.length > 0) {
            NSString *color = [self.color4processBg substringWithRange:NSMakeRange(1, self.color4processBg.length-1)];
            _progressView.progressBarView.backgroundColor = [UIColor colorWithHexRGB:color];
        }
        _progressView.progress = 0;
    }
    return _progressView;
}
- (KDWebView *)webView {
    if (_webView == nil) {
        _webView = [[KDWebView alloc] init];;
        _webView.backgroundColor = self.view.backgroundColor;
        _webView.delegate = self;
    }
    return _webView;
}
- (void)setWebViewTitle:(NSString *)title leavel:(KDWebViewTitleLevel)leavel {
    
    if (self.naviTitle.length > 0) {
        self.title = self.naviTitle;
        return;
    }
    
    if (!title || [title isEqualToString:@""]) return ;
    
    if (leavel == KDWebViewTitleLevel_Document) {
        self.documentTitle = title;
    }
    
    else if (leavel == KDWebViewTitleLevel_Higher) {
        self.webHigherTitle = title;
    }
    
    else if (leavel == KDWebViewTitleLevel_Lower) {
        self.webLowerTitle = title;
    }
    
    if (self.webHigherTitle) {
        self.title = self.webHigherTitle;
    }
    else if (self.documentTitle) {
        self.title = self.documentTitle;
    }
    if (leavel == KDWebViewTitleLevel_Document) {
        if (!self.title || [self.title isEqualToString:@""]) {
            self.title = self.webLowerTitle;
        }
    }
}

- (void)updateMasonry:(BOOL)isFullScreen
{
    if (isFullScreen)
    {
        self.statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        
        [self.webView updateConstraints:^(MASConstraintMaker *make)
         {
             make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(20, 0, 0, 0));
         }];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle];
        
        [self.webView updateConstraints:^(MASConstraintMaker *make)
         {
             make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(64, 0, 0, 0));
         }];
        self.view.backgroundColor = self.webView.backgroundColor;
    }
}


- (NSString *)getCurrentTitle {
    if (self.webHigherTitle && ![self.webHigherTitle isEqualToString:@""]) {
        return self.webHigherTitle;
    }
    if (self.documentTitle && ![self.documentTitle isEqualToString:@""]) {
        return self.documentTitle;
    }
    if (self.webLowerTitle && ![self.webLowerTitle isEqualToString:@""]) {
        return self.webLowerTitle;
    }
    return @"";
}

- (MessageNewsEachDataModel *)getCurrentPageShareData {
    if (self.jsShareData) {
        if (!self.jsShareData.title || [self.jsShareData.title isEqualToString:@""]) {
            self.jsShareData.title =[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        }
        
        if (!self.jsShareData.name  || [self.jsShareData.name isEqualToString:@""]) {
            self.jsShareData.name = self.currentUrl.absoluteString;
        }
        if (!self.jsShareData.text || [self.jsShareData.text isEqualToString:@""]) {
            self.jsShareData.text = [NSString stringWithFormat:@"链接地址：%@",self.jsShareData.name];
        }
        return self.jsShareData;
    }
    
    //没有通过js桥传数据
    else {
        if (_shareNewsDataModel) {
            return _shareNewsDataModel;
        }
        else {
            MessageNewsEachDataModel *model = [[MessageNewsEachDataModel alloc] init];
            model.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];//[self getCurrentTitle];
            model.url = self.currentUrl.absoluteString;
            model.text = [NSString stringWithFormat:@"链接地址：%@",self.currentUrl.absoluteString];
            return model;
        }
    }
    return nil;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (self.orientation == UIInterfaceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }
    else if(self.orientation == UIInterfaceOrientationLandscapeRight){
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.webView remakeConstraints:^(MASConstraintMaker *make)
     {
         if(self.isTitleNavHidden)
             make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(20, 0, 0, 0));
         else
             make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
     }];
}
//支持旋转
-(BOOL)shouldAutorotate
{
    return YES;
}

-(void)setOrientation:(UIInterfaceOrientation)orientation
{
    [KDWeiboAppDelegate getAppDelegate].vcOrientation = orientation;
}

-(UIInterfaceOrientation)orientation
{
    return [KDWeiboAppDelegate getAppDelegate].vcOrientation;
}

////设置样式
//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleDefault;
//}
//
////设置是否隐藏
//- (BOOL)prefersStatusBarHidden {
//    //    [super prefersStatusBarHidden];
//    return NO;
//}
//
////设置隐藏动画
//- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
//    return UIStatusBarAnimationNone;
//}

@end
