//
//  KDWeiboAppDelegate.m
//  TwitterFon
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "KDWeiboAppDelegate.h"
#import "FriendsTimelineController.h"
#import "KDMainTimelineViewController.h"
#import "GroupViewController.h"
#import "ProfileViewController2.h"

#import "KDAuthViewController.h"
//#import "KDAppTutorialsViewController.h"

#import "KDAppVersionUpdates.h"
#import "KDVersion.h"
#import "KDWeiboGlobals.h"

#import "CommenMethod.h"

#import "KDThirdPartAppAuthActionHandler.h"

#import "KDUncaughtExceptionHandler.h"
#import "KDDefaultViewControllerContext.h"
#import "KDWeiboServicesContext.h"
#import "KDRequestDispatcher.h"

#import "KDManagerContext.h"

#import "KDUtility.h"
#import "NSString+Additions.h"

#import "KDDBManager.h"


#import "OpenUDID.h"

#import "LeveyTabBarController.h"
#import "KDSignInViewController.h"
#import "FriendsTimelineController.h"
#import "KDTodoListViewController.h"
#import "KDRecentlyColleagueViewController.h"
#import "KDApplicationViewController.h"
//#import "KDAnimateGuidViewController.h"
#import "KDGuideVC.h"
#import "KDDiscoveryViewController.h"
#import "KDWeiboLoginService.h"
#import "XTLoginService.h"
#import "BOSSetting.h"
#import "T9.h"
#import "BOSConfig.h"
#import "KDLockControl.h"
#import "KDGestureEnterViewController.h"

#import "KDSignInManager.h"
#import "MBProgressHUD+Add.h"

#import "NSString+URLEncode.h"

#import "KDSharePhoneContact.h"
#import "KDVersionCheck.h"
#import "KDLinkInviteConfig.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "KDMeVC.h"
#import "KDTimelineManager.h"
#import "XTInitializationManager.h"
#import "KDFailureSignInTask.h"
#import "KDGestureSettingViewController.h"
#import "KDApplicationQueryAppsHelper.h"
#import "KDAgoraSDKManager.h"
#import "KDWebViewExtentController.h"
#import "KDWPSFileShareManager.h"

#import "iAppRevision.h"
#import "KDSignatureViewController.h"
#import "NSString+Operate.h"

#import "BuluoSDK.h"

#import "KDAppLaunch.h"
#import "KDWpsTool.h"
#import <Bugly/Bugly.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "KDSignInRemindManager.h"



#define WARN_ALERT_FOR_RELOG 1002

#define WARN_ALERT 1000
#define UPDATE_ALERT 1001

#define KDWEIBO_SINA_APP_KEY @"3318103260"
#define KDWEIBO_QQ_APP_KEY @"1101093724"

@interface KDWeiboAppDelegate ()

@property (nonatomic, strong) UIViewController *retainViewController;

@end

@implementation KDWeiboAppDelegate

@synthesize window;
//@synthesize mapView = mapView_;
@synthesize sideMenuViewController = sideMenuViewController_;
@synthesize leveyTabBarController = leveyTabBarController_;
@synthesize XT = XT_;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    ////KD_RELEASE_SAFELY(mapView_);
    //KD_RELEASE_SAFELY(leftVC);
    //KD_RELEASE_SAFELY(sideMenuViewController_);
    //KD_RELEASE_SAFELY(leveyTabBarController_);
    //KD_RELEASE_SAFELY(_openClient);
    //    [window release];
    
    //[super dealloc];
}

//- (MAMapView *)mapView {
//    if(mapView_ == nil) {
//        mapView_ = [[MAMapView alloc] initWithFrame:self.window.bounds];
//    }
//    return mapView_;
//}
////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

-(MTStatusBarOverlay *)getOverlay
{
    return overlay;
}


- (void)registerNotificaton{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenDidExpired:) name:kKDTokenExpiredNotification object:nil];
    
}


///////////////////////////////////////////////////////////

/**
 *  启动地图服务
 *  修改人－－吴剑
 */
- (void)initLocationService {
    
    dispatch_queue_t startMAMapService = dispatch_queue_create("startMAMapService", nil);
    dispatch_async(startMAMapService, ^{
        //        [MAMapServices sharedServices].apiKey = GAODE_MAP_KEY_IPHONE;
        [AMapServices sharedServices].apiKey = GAODE_MAP_KEY_IPHONE;
        [AMapServices sharedServices].enableHTTPS = YES;
        
    });
    //    dispatch_release(startMAMapService);
}


- (void) _setupUmengAppAnalyzer {
    [KDEventAnalysis setupAnalysis];
    if(@available(iOS 8,*))
        [KDEventAnalysis setupCountlyAnalysis];
}

- (void) _checkUpdate {
    [KDVersionCheck checkUpdate:NO];
}

/**
 *  清除临时文件夹
 */
- (void)_executeTasksbeforeRunning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        // clear application temporay folder
        NSString *path = [[KDUtility defaultUtility] searchDirectory:KDApplicationTemporaryDirectory
                                                        inDomainMask:KDTemporaryDomainMask needCreate:NO];
        
        NSFileManager *fm = [[NSFileManager alloc] init];
        if([fm fileExistsAtPath:path]){
            [fm removeItemAtPath:path error:NULL];
        }
        
        //        [fm release];
    });
}

- (void)_setupAppSettingsDependOnDevice {
    // iOS 5.0
    //    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
    //        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg"] forBarMetrics:UIBarMetricsDefault];
    //    }
    //    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
    //        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg"] forBarPosition:UIBarPositionTop  barMetrics:UIBarMetricsDefault];
    //    }
    //nslog
}

- (void) _setupStatusBarOverlay {
    overlay = [MTStatusBarOverlay sharedInstance];
    overlay.animation = MTStatusBarOverlayAnimationNone;  // MTStatusBarOverlayAnimationShrink
    overlay.detailViewMode = MTDetailViewModeDetailText;
    overlay.backgroundColor = [UIColor clearColor];
    // enable automatic history-tracking and show in detail-view
    //[overlay hide];
    
    overlay.delegate = self;
}

- (void) _setupAppUIComponent {
    
    UIWindow *aWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = aWindow;
    self.window.rootViewController = [[UIViewController alloc] init];
    //    [aWindow release];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13) {
        //
    } else {
        [self _setupStatusBarOverlay];
    }
}

/**
 * the required initialization method must invoke at here
 */
- (void)_setupAppPath {
    // app flags initialization
    _flags.initialized = 1;
    _flags.isFirstGetUnreadCount = 1;
    _flags.checkedClientLatestVersion = 0;
    
    // KDInstallUncaughtExceptionHandler();
    
    // #if defined(DISTRIBUTION) || (defined(RELEASE) && KDWEIBO_UMENG_ENABLED)
    // setup umeng app analyzer
    //[self setupAppConfigure];
    [self _setupUmengAppAnalyzer];
    
    [self _registerShareInformation];
    
    //    [self _checkUpdate];
    //检查版本
    if(_flags.checkedClientLatestVersion == 0){
        _flags.checkedClientLatestVersion = 1;
        
        [self checkVersion:NO];
        
    }
    
    
    // #endif
    
    [self _executeTasksbeforeRunning];
    
    // setup app settings depends on current device
    [self _setupAppSettingsDependOnDevice];
    
    // setup UI components
    [self _setupAppUIComponent];
    
    [self initLocationService];
    
    //在更新版本后，旧版本设置的本地通知并未取消，必须手动取消
    [self cancelLocalNotification];
    
    //注册通知，当accessToken 过期的时候调用此通知
    [self registerNotificaton];
    
    [self _registerIAppRevisionWithKey:[[BOSSetting sharedSetting] copyright]];
    
    // 注册部落
    [BuluoSDK registerApp:KD_Buluo_ConsumerKey withAppSecret:KD_Buluo_ConsumerSecret];
}


- (void)cancelLocalNotification {
    if (![[KDSession globalSession] getPropertyForKey:@"cancleLocalNotification" fromMemoryCache:YES]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[KDSession globalSession] saveProperty:@(YES) forKey:@"cancleLocalNotification" storeToMemoryCache:YES];
    }
}

- (void)_setupXT
{
    if (XT_ == nil) {
        XT_ = [[XTBaseLogic alloc] init];
        XT_.delegate = self;
    }
}

//
//- (void)setupAppConfigure {
//    id obj = [[KDSession globalSession] getPropertyForKey:KD_PRO_LOCAION_USE_NOTIFICAITON fromMemoryCache:YES];
//    if (!obj) {
//        [[KDSession globalSession] saveProperty:@YES forKey:KD_PRO_LOCAION_USE_NOTIFICAITON storeToMemoryCache:YES];
//    }
//}

/**
 *  修改左右滑动
 *  修改时间 2013－11-19
 *  修改人 吴剑
 */
- (void)setupMainViewControllers {
    
    
    [[KDApplicationQueryAppsHelper shareHelper] deleteFirstPullAllToDoStatusWhenCheckWorkPlaceOrSignIn];
    
    
    if(self.timelineViewController)
        [[NSNotificationCenter defaultCenter] removeObserver:self.timelineViewController];
    
    //消息
    XTTimelineViewController *timeline = [[XTTimelineViewController alloc] init];
    timeline.tabBarItem = [[UITabBarItem alloc] initWithTitle:ASLocalizedString(@"XTTimelineViewController_Msg")image:[UIImage imageNamed:@"toolbar_btn_message_normal"] selectedImage:[UIImage imageNamed:@"toolbar_btn_message_focus"]];
    //    UINavigationController *timelineNavigation = [[UINavigationController alloc] initWithRootViewController:timeline];
    //    timelineNavigation.delegate = [KDNavigationManager sharedNavigationManager];
    UINavigationController *timelineNavigation = [[UINavigationController alloc] initWithRootViewController:timeline];
    timelineNavigation.delegate = [KDNavigationManager sharedNavigationManager];
    self.timelineViewController = timeline;
    
    //工作台
    KDWebViewExtentController *wordVC;
    UINavigationController *wordNavigation;
    if([BOSSetting sharedSetting].openWorkWithID)
    {
        NSArray *workArry = [[BOSSetting sharedSetting].openWorkWithID componentsSeparatedByString:@","];
        NSString *appId = [workArry firstObject];
        NSString *title = ASLocalizedString(@"Global_Work");
        if ([workArry count] > 1 ) {
            title = [workArry lastObject]; //
            //大于4 显示4个名字
            if (title.length > 4) {
                title = [title substringToIndex:4];
            }
        }
        wordVC = [[KDWebViewExtentController alloc] initWithUrlString:nil appId:appId];
        wordVC.title = title;
        wordVC.hidesBottomBarWhenPushed = NO;
        wordVC.isBlueNav = NO;
        wordVC.abortUseWebTitle = YES;
        wordVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:@"toolbar_btn_work_normal"] selectedImage:[UIImage imageNamed:@"toolbar_btn_work_focus"]];
        wordVC.isShowRefreshBtn = YES;
        wordNavigation = [[UINavigationController alloc] initWithRootViewController:wordVC];
        wordNavigation.delegate = [KDNavigationManager sharedNavigationManager];
        self.workViewController = wordVC;
    }
    
    //通讯录
    XTContactContentViewController *contact = [[XTContactContentViewController alloc] init];
    contact.tabBarItem = [[UITabBarItem alloc] initWithTitle:ASLocalizedString(@"XTContactContentViewController_Contact")image:[UIImage imageNamed:@"toolbar_btn_address_normal"] selectedImage:[UIImage imageNamed:@"toolbar_btn_address_focus"]];
    self.contactViewController = contact;
    UINavigationController *contactNavigation = [[UINavigationController alloc] initWithRootViewController:contact];
    contactNavigation.delegate = [KDNavigationManager sharedNavigationManager];
    self.contactViewController = contact;
    
    //应用
    KDApplicationViewController *enteriseAppViewController = [[KDApplicationViewController alloc] init];
    enteriseAppViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:ASLocalizedString(@"KDApplicationViewController_app") image:[UIImage imageNamed:@"toolbar_btn_app_normal"] selectedImage:[UIImage imageNamed:@"toolbar_btn_app_focus"]];
    UINavigationController *enteriseAppNavigaton = [[UINavigationController alloc] initWithRootViewController:enteriseAppViewController];
    enteriseAppNavigaton.delegate = [KDNavigationManager sharedNavigationManager];
    self.enteriseAppViewController = enteriseAppViewController;
    
    //发现
    KDDiscoveryViewController *discoveryViewController = [[KDDiscoveryViewController alloc] init];
    discoveryViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:ASLocalizedString(@"KDDiscoveryViewController_discovery")image:[UIImage imageNamed:@"toolbar_btn_find_normal"] selectedImage:[UIImage imageNamed:@"toolbar_btn_find_focus"]];
    UINavigationController *discoveryNavigation = [[UINavigationController alloc] initWithRootViewController:discoveryViewController];
    discoveryNavigation.delegate = [KDNavigationManager sharedNavigationManager];
    self.discoveryViewController = discoveryViewController;
    
    
    //设置tabVC
    NSMutableArray *viewControllers = [NSMutableArray array];
    [viewControllers addObject:timeline];
    //zgbin:第五页签必达调整到第三
    [viewControllers addObject:enteriseAppViewController];
    //开启了工作台才加入
    if([BOSSetting sharedSetting].openWorkWithID)
        [viewControllers addObject:wordVC];
    //zgbin:end
    //非外部人员才能显示发现
    if([BOSConfig sharedConfig].user.partnerType != 1)
        [viewControllers addObject:discoveryViewController];
    [viewControllers addObject:contact];
    
    NSMutableArray *ctrlArr = [NSMutableArray array];
    [ctrlArr addObject:timelineNavigation];
    //zgbin:第五页签必达调整到第三
    [ctrlArr addObject:enteriseAppNavigaton];
    //开启了工作台才加入
    if([BOSSetting sharedSetting].openWorkWithID)
        [ctrlArr addObject:wordNavigation];
    //zgbin:end
    //非外部人员才能显示发现
    if([BOSConfig sharedConfig].user.partnerType != 1)
        [ctrlArr addObject:discoveryNavigation];
    [ctrlArr addObject:contactNavigation];
    
    [KDNavigationManager sharedNavigationManager].tabViewControllers = viewControllers;
    self.tabBarController = [[KDTabBarController alloc] init];
    self.tabBarController.tabBar.backgroundColor = [UIColor kdBackgroundColor2];
    self.tabBarController.viewControllers = ctrlArr;
    
    
    if (!leftVC) {
        leftVC                        = [[KDLeftTeamMenuViewController alloc] init];
        sideMenuViewController_ = [[RESideMenu alloc] initWithContentViewController:self.tabBarController leftMenuViewController:leftVC rightMenuViewController:nil];
        sideMenuViewController_.delegate              = self;
    }else {
        sideMenuViewController_.contentViewController = self.tabBarController;
    }
    self.window.rootViewController    = sideMenuViewController_;
    
    [[KDNotificationChannelCenter defaultCenter] startChannel];
    if ([BOSConfig sharedConfig].user.token.length > 0) {
        //如果是首次升级到4.6.0,则重新获取下人员数据
        NSString *kdweibo_430 = [NSString stringWithFormat:@"KDWeibo_4.6.0_%@",[BOSConfig sharedConfig].user.eid];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kdweibo_430]) {
            [[XTInitializationManager sharedInitializationManager] clearInitializationFlag];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:kdweibo_430];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
}

-(void)resetMainView
{
    //[[KDApplicationQueryAppsHelper shareHelper] deleteFirstPullAllToDoStatusWhenCheckWorkPlaceOrSignIn];
    //消息
    if(self.timelineViewController)
        [[NSNotificationCenter defaultCenter] removeObserver:self.timelineViewController];
    
    XTTimelineViewController *timeline = [[XTTimelineViewController alloc] init];
    timeline.tabBarItem = [[UITabBarItem alloc] initWithTitle:ASLocalizedString(@"XTTimelineViewController_Msg")image:[UIImage imageNamed:@"toolbar_btn_message_normal"] selectedImage:[UIImage imageNamed:@"toolbar_btn_message_focus"]];
    UINavigationController *timelineNavigation = [[UINavigationController alloc] initWithRootViewController:timeline];
    timelineNavigation.delegate = [KDNavigationManager sharedNavigationManager];
    self.timelineViewController = timeline;
    
    //工作台
    KDWebViewExtentController *wordVC;
    UINavigationController *wordNavigation;
    if([BOSSetting sharedSetting].openWorkWithID)
    {
        NSArray *workArry = [[BOSSetting sharedSetting].openWorkWithID componentsSeparatedByString:@","];
        NSString *appId = [workArry firstObject];
        NSString *title = ASLocalizedString(@"Global_Work");
        if ([workArry count] > 1 ) {
            title = [workArry lastObject]; //
            //大于4 显示4个名字
            if (title.length > 4) {
                title = [title substringToIndex:4];
            }
        }
        wordVC = [[KDWebViewExtentController alloc] initWithUrlString:nil appId:appId];
        wordVC.title = title;
        wordVC.hidesBottomBarWhenPushed = NO;
        wordVC.isBlueNav = NO;
        wordVC.abortUseWebTitle = YES;
        wordVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:@"toolbar_btn_work_normal"] selectedImage:[UIImage imageNamed:@"toolbar_btn_work_focus"]];
        wordVC.isShowRefreshBtn = YES;
        wordNavigation = [[UINavigationController alloc] initWithRootViewController:wordVC];
        wordNavigation.delegate = [KDNavigationManager sharedNavigationManager];
        self.workViewController = wordVC;
    }
    
    //通讯录
    XTContactContentViewController *contact = [[XTContactContentViewController alloc] init];
    contact.tabBarItem = [[UITabBarItem alloc] initWithTitle:ASLocalizedString(@"XTContactContentViewController_Contact")image:[UIImage imageNamed:@"toolbar_btn_address_normal"] selectedImage:[UIImage imageNamed:@"toolbar_btn_address_focus"]];
    self.contactViewController = contact;
    UINavigationController *contactNavigation = [[UINavigationController alloc] initWithRootViewController:contact];
    contactNavigation.delegate = [KDNavigationManager sharedNavigationManager];
    self.contactViewController = contact;
    
    //应用
    KDApplicationViewController *enteriseAppViewController = [[KDApplicationViewController alloc] init];
    enteriseAppViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:ASLocalizedString(@"KDApplicationViewController_app") image:[UIImage imageNamed:@"toolbar_btn_app_normal"] selectedImage:[UIImage imageNamed:@"toolbar_btn_app_focus"]];
    UINavigationController *enteriseAppNavigaton = [[UINavigationController alloc] initWithRootViewController:enteriseAppViewController];
    enteriseAppNavigaton.delegate = [KDNavigationManager sharedNavigationManager];
    self.enteriseAppViewController = enteriseAppViewController;
    
    //发现
    KDDiscoveryViewController *discoveryViewController = [[KDDiscoveryViewController alloc] init];
    discoveryViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:ASLocalizedString(@"KDDiscoveryViewController_discovery")image:[UIImage imageNamed:@"toolbar_btn_find_normal"] selectedImage:[UIImage imageNamed:@"toolbar_btn_find_focus"]];
    UINavigationController *discoveryNavigation = [[UINavigationController alloc] initWithRootViewController:discoveryViewController];
    discoveryNavigation.delegate = [KDNavigationManager sharedNavigationManager];
    self.discoveryViewController = discoveryViewController;
    
    
    //设置tabVC
    NSMutableArray *viewControllers = [NSMutableArray array];
    [viewControllers addObject:timeline];
    //开启了工作台才加入
    if([BOSSetting sharedSetting].openWorkWithID)
        [viewControllers addObject:wordVC];
    [viewControllers addObject:enteriseAppViewController];
    //非外部人员才能显示发现
    if([BOSConfig sharedConfig].user.partnerType != 1)
        [viewControllers addObject:discoveryViewController];
    [viewControllers addObject:contact];
    
    NSMutableArray *ctrlArr = [NSMutableArray array];
    [ctrlArr addObject:timelineNavigation];
    //开启了工作台才加入
    if([BOSSetting sharedSetting].openWorkWithID)
        [ctrlArr addObject:wordNavigation];
    [ctrlArr addObject:enteriseAppNavigaton];
    //非外部人员才能显示发现
    if([BOSConfig sharedConfig].user.partnerType != 1)
        [ctrlArr addObject:discoveryNavigation];
    [ctrlArr addObject:contactNavigation];
    
    [KDNavigationManager sharedNavigationManager].tabViewControllers = viewControllers;
    self.tabBarController = [[KDTabBarController alloc] init];
    self.tabBarController.tabBar.backgroundColor = [UIColor kdBackgroundColor2];
    self.tabBarController.viewControllers = ctrlArr;
    
    
    leftVC = nil;
    //    sideMenuViewController_ = nil;
    //    if (!leftVC) {
    leftVC                        = [[KDLeftTeamMenuViewController alloc] init];
    //        sideMenuViewController_       = [[RESideMenu alloc] initWithContentViewController:self.tabBarController menuViewController:leftVC];
    sideMenuViewController_ = [[RESideMenu alloc] initWithContentViewController:self.tabBarController leftMenuViewController:leftVC rightMenuViewController:nil];
    //sideMenuViewController_.backgroundImage       = [UIImage imageNamed:@"toolbar_btn_message_normal"];
    sideMenuViewController_.delegate              = self;
    sideMenuViewController_.contentViewController = self.tabBarController;
    //        [sideMenuViewController_ presentLeftMenuViewController];
    sideMenuViewController_.contentViewController = self.tabBarController;
    
    //    if (!leftVC) {
    //        leftVC                        = [[KDLeftTeamMenuViewController alloc] init];
    //        //        sideMenuViewController_       = [[RESideMenu alloc] initWithContentViewController:self.tabBarController menuViewController:leftVC];
    //        sideMenuViewController_ = [[RESideMenu alloc] initWithContentViewController:self.tabBarController leftMenuViewController:leftVC rightMenuViewController:nil];
    //        //sideMenuViewController_.backgroundImage       = [UIImage imageNamed:@"toolbar_btn_message_normal"];
    //        sideMenuViewController_.delegate              = self;
    //    }else {
    //        sideMenuViewController_.contentViewController = self.tabBarController;
    //    }
    
    //    [[KDSharePhoneContact defaultContactManager]startAccessingAddressPerson];
    self.window.rootViewController    = sideMenuViewController_;
    [[KDNotificationChannelCenter defaultCenter] startChannel];
    //    //KD_RELEASE_SAFELY(friendTimelineController);
    //    //KD_RELEASE_SAFELY(dmThreadViewController);
    //    //KD_RELEASE_SAFELY(todoListViewController);
    //    //KD_RELEASE_SAFELY(personViewController);
    //    //KD_RELEASE_SAFELY(enteriseAppViewController);
    //    //KD_RELEASE_SAFELY(friendNavigaton);
    //    //KD_RELEASE_SAFELY(dmThreanNavigaton);
    //    //KD_RELEASE_SAFELY(todoListNavigaton);
    //    //KD_RELEASE_SAFELY(personNavigaton);
    //    //KD_RELEASE_SAFELY(enteriseAppNavigaton);
    
    //    if ([BOSConfig sharedConfig].user.token.length > 0) {
    //        //如果是首次升级到4.6.0,则重新获取下人员数据
    //        NSString *kdweibo_430 = [NSString stringWithFormat:@"KDWeibo_4.6.0_%@",[BOSConfig sharedConfig].user.eid];
    //        if (![[NSUserDefaults standardUserDefaults] boolForKey:kdweibo_430]) {
    //            [[XTInitializationManager sharedInitializationManager] clearInitializationFlag];
    //            [[NSUserDefaults standardUserDefaults] setBool:true forKey:kdweibo_430];
    //            [[NSUserDefaults standardUserDefaults] synchronize];
    //        }
    //    }
    
    
}

//- (void)showAppIntroViewController:(BOOL)hasStageAnimation {
//    KDAppTutorialsViewController *avc = [[KDAppTutorialsViewController alloc] initWithHasStageAnimation:hasStageAnimation];
//    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:avc];
//    [avc release];
//
//    self.window.rootViewController = nvc;
//    [nvc release];
//}

- (void)showAuthViewController {
    
    [XT_ openLoginViewController];
}
- (void)showLoginViewController:(NSInteger)loginType
{
    KDAuthViewController *avc = [[KDAuthViewController alloc] initWithLoginViewType:loginType];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:avc];
    //    [avc release];
    
    self.window.rootViewController = nvc;
    //    [nvc release];
}
- (void)showAppTutorialsViewController {
    //    KDAnimateGuidViewController * guideVC = [[KDAnimateGuidViewController alloc] initWithInApp:NO];
    //    self.window.rootViewController        = guideVC;
    KDGuideVC *guideVC = [[KDGuideVC alloc] init];
    self.window.rootViewController = guideVC;
    //    [guideVC release];
}

- (void)_configureAppUI {
    //if (isAboveiOS5) {
    //     [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    //  }
    
    NSURL *url = [[KDSession globalSession] propertyForKey:UIApplicationLaunchOptionsURLKey];
    if (url != nil) {
        
        
        BOOL canOpenURL = [self handleOpenURL:url launched:NO];
        
        // remove cached open url
        if (canOpenURL) {
            [[KDSession globalSession] setProperty:nil forKey:UIApplicationLaunchOptionsURLKey];
            return;
        }
    }
    
    [XT_ openLoginViewController];
    
}
/**
 *  处理从其他应用跳转过来的URl
 *
 *  @param url        跳转地址
 *  @param launched
 *
 *  @return 返回是否成功
 */
- (BOOL)handleOpenURL:(NSURL *)url launched:(BOOL)launched {
    // kdweibo://auth?source=haier&user_name=winters_huang%40weibo.kingdee.com&password=123456&SvnServer=58.56.128.15&SvnServerBackup=218.58.70.139&SvnParams=&SrcAppScheme=template://abcdef&ReturnCode=&url_encode=true
    DLog(@"handleOpenUrl.....%@",url);
    
    
    
    KDQuery *query = [KDThirdPartAppAuthActionHandler toQueryWithOpenURL:url];
    KDThirdPartAppAuthActionHandler *handler = [[KDThirdPartAppAuthActionHandler alloc] init];
    handler.query = query;
    
    BOOL succeed = [handler execute];
    //    [handler release];
    
    if (succeed) {
        KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
        if ([userManager isSigned]) {
            // do sign out and navigate to auth view controller
            [self signOut];
        }
        
        //search network_id
        NSString *queryString = [url query];
        NSString *subDomainName = [queryString searchAsURLQueryWithNeedle:@"domain_name="];
        
        // save open url query into global settings
        [[KDSession globalSession] setProperty:query forKey:KD_PROP_3RD_AUTH_QUERY_KEY];
        [[KDSession globalSession] setProperty:subDomainName forKey:KD_3RD_AUTH_DOMAIN_NAME];
        
        [KDWeiboLoginService thirdPartAuthorize_finishBlock:nil];
        
        //        [XT_ applicationHandleOpenURL:url];
    }
    else
    {
        [XT_ applicationHandleOpenURL:url];
    }
    
    //    succeed = [[KDAppLaunch instance] handleLaunch:url];
    //    if (!succeed) {
    //        [[KDAppLaunch instance] handleLaunchWhenLoginFinished];
    //    }
    
    return succeed;
}
- (NSString *) documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    NSLog(@"Documents directory%@", documentsDirectory);
    NSLog(@"==========================================");
    
    return documentsDirectory;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // test
//    UIWindow *aWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    UIViewController *viewController = [[UIViewController alloc] init];
//    viewController.view.backgroundColor = [UIColor greenColor];
//    self.retainViewController = viewController;
//    aWindow.rootViewController = viewController;
//    [aWindow makeKeyAndVisible];
//    self.window = aWindow;
    
    [self registerBuggly];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"AgoraGroup"];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"verson_705"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"verson_705"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllData];
    }
    NSLog(@"application didFinishLaunching...");
    [KDStyle setupStyple];
    //多语言
    [self setLangueage];
    
    // 通讯录蒙层在程序杀掉重进后重置显示标志
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kNotShowInviteHint];
    
#if!(TARGET_IPHONE_SIMULATOR)
    /// @note 注册App
    [KWOfficeApi registerApp:@"6786786E87EC16007BE5C247B7D2621E"];
    /// @note 打开调试模式
    [KWOfficeApi setDebugMode:NO];
    /// @note 设置通信端口号，默认9616
    [KWOfficeApi setPort:9616];
#endif
    
    [self documentsDirectory];
    
    if ([[KDSession globalSession] propertyForKey:KDLocalNotificationInfoKey])
    {
        [[KDSession globalSession] removePropertyForKey:KDLocalNotificationInfoKey clearCache:YES];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //    if (isAboveiOS7) {
    //        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //    }
    
    BOOL result = YES;
    // 讯通相关逻辑处理
    [self _setupXT];
    //    [XT_ launched];
    
    if (launchOptions != nil) {
        NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        if (url != nil && ![url isFileURL]) {
            //这里设置no，不重复调用 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
            result = NO;
            [[KDSession globalSession] setProperty:url forKey:UIApplicationLaunchOptionsURLKey];
            
            //是否来自邀请
            [[KDLinkInviteConfig sharedInstance] isAvailableInviteFromUrl:url];
            
        }
        
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [[KDManagerContext globalManagerContext].APNSManager didReceiveRemoteNotification:userInfo];
        
        UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localNotification) {
            [[KDSession globalSession] setProperty:@(YES) forKey:KDLocalNotificationInfoKey];
        }
        
        //xt
        [XT_ setRemoteNotificationInfo:userInfo];
    }
    
    // app initialization path
    [self _setupAppPath];
    
    // specific UI page for app
    [self _configureAppUI];
    
    
    KDAdsManager *adsManager = [KDAdsManager sharedInstance];
    
    //在子线程中初始化搜索树
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [adsManager queryAdsWithBlock:nil adsType:KDAdsLocationType_index];
        [T9 sharedInstance];
    });
    
    [self.window makeKeyAndVisible];
    
    [adsManager showAdvertisementOnView:self.window timeout:3 completetion:^{
        
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(signOut) name:@"user_logout" object:nil];
    
    
    [[KDReachabilityManager sharedManager] startMonitoring];
    
    //删除明文文件文件夹
    if([BOSConfig sharedConfig].user.openId)
        [[KDWpsTool shareInstance] removeTempFile];
    
    return result;
}


-(void)registerBuggly
{
    [Bugly startWithAppId:@"e388baa06c"];
    [Bugly setUserIdentifier:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
}


#pragma mark -
#pragma mark KDNetWork
- (void)connectNetWork{
    [[KDReachabilityManager sharedManager] startMonitoring];
}
// for iOS version greater than 4.2 or equals to 4.2
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    DLog(@"openURL-----");
    
    if ([[KDLinkInviteConfig sharedInstance] isAvailableInviteFromUrl:url]) {
        
        if ([[BOSConfig sharedConfig].user.token length] > 0) {
            
            [[KDLinkInviteConfig sharedInstance] goToInviteFormType:Invite_From_Logined];
        }
        else{
            [[KDLinkInviteConfig sharedInstance] goToInviteFormType:Invite_From_Launched];
        }
        
        return YES;
    }
    
    if ([sourceApplication isEqualToString:@"com.sina.weibo"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    else if([sourceApplication isEqualToString:@"com.tencent.xin"]){
        return [WXApi handleOpenURL:url delegate:self];
        
    }
    else if([sourceApplication isEqualToString:@"com.tencent.mqq"]){
        return [TencentOAuth HandleOpenURL:url];
    }else if ([sourceApplication isEqualToString:@"com.kingsoft.www.office.wpsoffice"] && url)
    {
        if ([url.absoluteString containSubString:@"KDWeibostartFileShare"])
        {
            //发起人发起文件共享播放后 结束回调
            KDWPSFileShareManager *fileShareManger = [KDWPSFileShareManager sharedInstance];
            NSString *accesscode = fileShareManger.accessCode;
            NSString *serverhost = fileShareManger.serverHost;
            if (accesscode && accesscode.length>0 && fileShareManger.originatorPersonId && fileShareManger.originatorPersonId.length>0)
            {
                [[KDAgoraSDKManager sharedAgoraSDKManager] sendStopShareFileChannelMessageWithAccessCode:accesscode serverHost:serverhost ? serverhost:@""];
                fileShareManger.accessCode = nil;
                fileShareManger.serverHost = nil;
                fileShareManger.originatorPersonId = nil;
                
                KDAgoraSDKManager *agoraManger = [KDAgoraSDKManager sharedAgoraSDKManager];
                if(agoraManger.agoraPersonsChangeBlock)
                {
                    agoraManger.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_fileShareFinished,nil,nil,nil);
                }
            }
        }
        else if ([url.absoluteString containSubString:@"joinFileShare"])
        {
            KDWPSFileShareManager *shareManager = [KDWPSFileShareManager sharedInstance];
            KDAgoraSDKManager *agoraManger = [KDAgoraSDKManager sharedAgoraSDKManager];
            
            if(shareManager.accessCode && shareManager.accessCode.length>0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *originPersonId = shareManager.originatorPersonId && shareManager.originatorPersonId.length>0 ? shareManager.originatorPersonId:nil;
                    if(originPersonId && [originPersonId isEqualToString:(agoraManger.currentGroupDataModel.isExternalGroup ? [BOSConfig sharedConfig].user.externalPersonId : [BOSConfig sharedConfig].user.userId)] && shareManager.accessCode)
                    {
                        //发起人是自己
                        [agoraManger sendStopShareFileChannelMessageWithAccessCode:shareManager.accessCode serverHost:shareManager.serverHost?shareManager.serverHost:@""];
                        [shareManager setAccessCode:nil serverHost:nil];
                        
                        if(agoraManger.agoraPersonsChangeBlock)
                        {
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"PPT共享播放已经结束" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            [alert show];
                            
                            agoraManger.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_fileShareFinished,nil,nil,nil);
                        }
                    }
                    
                });
            }
        }
    }
    
    
    return [self handleOpenURL:url launched:YES];
}

// for iOS version eariler than 4.2
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSRange range = [url.absoluteString rangeOfString:KD_QQ_APP_KEY];
    if (range.location != NSNotFound) {
        return [TencentOAuth HandleOpenURL:url];
    }
    return [self application:application openURL:url sourceApplication:nil annotation:nil];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [[KDManagerContext globalManagerContext].APNSManager updateWithToken:deviceToken];
    
    [XT_ registerPushToken:deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    if(err)
        [Bugly reportError:err];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if(application.applicationState != UIApplicationStateActive)
    {
        
        [[KDManagerContext globalManagerContext].APNSManager didReceiveRemoteNotification:userInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationDidReceiveRemoteNotificationKey object:nil];
        [XT_ receiveRemoteNotification:userInfo];
    }else{
        //
        if(userInfo)
        {
            if([[KDApplicationQueryAppsHelper shareHelper]getGroupTalkStatus])
            {
                
                id mode = userInfo[@"mode"];
                if(mode && ![mode isKindOfClass:[NSNull class]])
                {
                    if([mode integerValue] == KDChatModeMultiCall)
                    {
                        //存语音推送通知
                        XT_.remoteNotificationInfoCall = userInfo;
                        
                        NSString *groupId = [userInfo objectForKey:@"groupId"];
                        KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
                        if(agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel && [agoraSDKManager.currentGroupDataModel.groupId isEqualToString:groupId])
                        {
                            return;
                        }
                        if(![self.tabBarController.view viewWithTag:900001])
                        {
                            [XT_ receiveRemoteNotificationWithInActiveWithUserInfo:userInfo];
                        }
                    }
                }
            }
        }
    }
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
#if!(TARGET_IPHONE_SIMULATOR)
    [[KWOfficeApi sharedInstance] setApplicationDidEnterBackground:application];//必须使用
#endif
    
    //进入后台后
    if ([BOSConfig sharedConfig].user.token.length > 0) {
        //暂停timer
        [[KDNotificationChannelCenter defaultCenter] closeChannel];
        [[KDFailureSignInTask sharedFailureSignInTask] stopFailureSignInTask];
    }
    
    if ([BOSAudioPlayer sharedAudioPlayer].isPlaying) {
        [[BOSAudioPlayer sharedAudioPlayer] stopPlay];
    }
}

//-(void)getMCloudParams:(MCloudClient *)client result:(BOSResultDataModel *)result
//{
//    if (client.hasError)
//        return;
//
//    if(result.success)
//    {
//        if([result.data isKindOfClass:[NSDictionary class]])
//        {
//            [BOSSetting sharedSetting].params = result.data;
//            [[BOSSetting sharedSetting] saveSetting];
//            //刷新手势密码设置
//            [self setGestureLock];
//        }
//    }
//
//
//    [client release];
//}

/**
 *  接受本地通知
 *
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    //当前是默认公司或团队
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
    {
        [[KDSession globalSession] setProperty:@(YES) forKey:KDLocalNotificationInfoKey];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        UIViewController *viewController = nil;
        
        UINavigationController *navigationController = [self.tabBarController.viewControllers objectAtIndex:self.tabBarController.selectedIndex];
        if (navigationController) {
            viewController = navigationController.topViewController;
        }else{
            navigationController = [self.tabBarController.viewControllers objectAtIndex:0];
            if (navigationController) {
                viewController = navigationController.topViewController;
                if (!viewController) {
                    viewController = [navigationController.viewControllers objectAtIndex:0];
                }
            }
        }
        if (viewController) {
            if (viewController.presentedViewController)
            {
                [viewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
            }
            //            if(![viewController isKindOfClass:[KDSignInViewController class]])
            //            {
            //                KDSignInViewController *signInController = [[KDSignInViewController alloc] init];
            //                signInController.hidesBottomBarWhenPushed = YES;
            //                signInController.navigationBarBackgroundHidden = YES;
            //                signInController.isFromSignInRemindNotification = YES;
            //                [viewController.navigationController pushViewController:signInController animated:YES];
            //            }
        }else{
            [self performSelector:@selector(application:didReceiveLocalNotification:) withObject:[NSArray arrayWithObjects:application, notification, nil] afterDelay:1.5f];
        }
    }
    
    //     if([[KDSession globalSession] propertyForKey:KDLocalNotificationInfoKey]) {
    //         return;
    //     }
    // if ([[[KDManagerContext globalManagerContext] communityManager] isDefaultCommunity]) {
    
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"云之家签到")message:notification.alertBody delegate:self cancelButtonTitle:ASLocalizedString(@"忽略")otherButtonTitles:ASLocalizedString(@"前往"),nil];
    //        [alert setTag:1009];
    //        [alert show];
    //
    //        [alert release];
    
    // }else {
    //        NSString *defaultCommunityName = [[[KDManagerContext globalManagerContext] communityManager] defaultCommunityName];
    //        if (defaultCommunityName) {
    //            NSString *msg= [NSString stringWithFormat:ASLocalizedString(@"去%@签到"),defaultCommunityName];
    //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"云之家签到")message:msg delegate:self cancelButtonTitle:ASLocalizedString(@"忽略")otherButtonTitles:ASLocalizedString(@"前往"),nil];
    //            [alert setTag:2000];
    //            [alert show];
    //            [alert release];
    //        }
    // }
    
    
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application {
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // disable get unread count and only current user is signing
    //    id obj = [[KDSession globalSession] propertyForKey:KD_PROP_USER_IS_SIGNING_KEY];
    //    if (obj != nil) {
    //        [[KDManagerContext globalManagerContext].unreadManager stop];
    //    }
    
    if ( [BOSConfig sharedConfig].user.token.length > 0)
    {
        [[KDManagerContext globalManagerContext].unreadManager stop];
    }
    //记录应用进入后台的时间
    [[KDLockControl shared]setStopTime:[[NSDate date]timeIntervalSinceReferenceDate]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // active get unread count and only current user is signing
    DLog(@"applicationDidBecomeActive....");
    if ( [BOSConfig sharedConfig].user.token.length > 0)
    {
        //刷新下mcloud参数
        //        XTOpenSystemClient *client = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getMCloudParams:result:)];
        //        [client getCompanyConfiguration:[BOSConfig sharedConfig].user.eid token:[BOSConfig sharedConfig].user.token];
        
        [[KDFailureSignInTask sharedFailureSignInTask] setUpData];
        [[KDManagerContext globalManagerContext].unreadManager start:NO];
        [[KDNotificationChannelCenter defaultCenter] startChannel];
        
        if ([BOSConfig sharedConfig].deviceToken.length == 0) {
            [[KDManagerContext globalManagerContext].APNSManager registerForRemoteNotification];
        }
        
        //设备唤醒时间
        [self awakeDevice];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [XT_ command];
    if ([[KDSession globalSession] propertyForKey:KDLocalNotificationInfoKey])
    {
        [[KDSession globalSession] removePropertyForKey:KDLocalNotificationInfoKey clearCache:YES];
    }
    [self setGestureLock];
    
}

- (void)awakeDevice
{
    if (self.awakeDeviceClient == nil) {
        self.awakeDeviceClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(awakeDeviceDidReceived:result:)];// autorelease];
    }
    [self.awakeDeviceClient awakeDevice:[BOSSetting sharedSetting].userName openId:[BOSConfig sharedConfig].user.openId eid:[BOSConfig sharedConfig].user.eid];
}

- (void)awakeDeviceDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success || ![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    
    if (result.success && result.data && [result.data isKindOfClass:[NSDictionary class]]) {
        
    }
}

- (void)setGestureLock
{
    if ([[BOSSetting sharedSetting] openGesturePassword]) {
        //判断是否需要显示解锁界面
        if ([KDLockControl shared].isSetDone) {
            //5分钟内不用输入手势密码
            NSDate *nowTime = [NSDate date];
            double timeinterval = [nowTime timeIntervalSinceReferenceDate] - [[KDLockControl shared] stopTime];
            if (timeinterval > 300) {
                KDGestureEnterViewController *vc = [[KDGestureEnterViewController alloc] init];//autorelease];
                [self.window.rootViewController presentViewController:vc animated:NO completion:NULL];
            }
        }
        else
        {
            KDGestureSettingViewController *vc = [[KDGestureSettingViewController alloc] init];//autorelease];
            vc.isHideBackBtn = YES;
            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:vc];//autorelease];
            [self.window.rootViewController presentViewController:nav animated:NO completion:NULL];
        }
    }
    else
    {
        if ([KDLockControl shared].isSetDone) {
            //5分钟内不用输入手势密码
            NSDate *nowTime = [NSDate date];
            double timeinterval = [nowTime timeIntervalSinceReferenceDate] - [[KDLockControl shared] stopTime];
            if (timeinterval > 300) {
                KDGestureEnterViewController *vc = [[KDGestureEnterViewController alloc] init];//autorelease];
                [self.window.rootViewController presentViewController:vc animated:NO completion:NULL];
            }
        }
        
    }
    //
    //        //清除手势解锁信息
    //        [KDLockControl  shared].isSetDone = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //进入前台手势密码判断
    //    __weak KDWeiboAppDelegate *weak_self = self;
    //    [self showLockKeyboardWithCompleteBlock:^(BOOL success) {
    //        dispatch_after(0.25, dispatch_get_main_queue(), ^{
    //            if (isAboveiOS9 && weak_self.currentShortcutItem)
    //            {
    //                [weak_self actionWithShortcutItem:weak_self.currentShortcutItem];
    //                weak_self.currentShortcutItem = nil;
    //            }
    //
    //            if (weak_self.widgetUrl) {
    //                [weak_self handleWidgetOpenUrl:weak_self.widgetUrl];
    //            }
    //        });
    //    }];
    //
    if ([BOSConfig sharedConfig].user.token.length > 0) {
        //开启timer
        [[KDNotificationChannelCenter defaultCenter] startChannel];
        
        [[KDFailureSignInTask sharedFailureSignInTask] setUpData];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[KDWeiboGlobals defaultWeiboGlobals] disconnectDatabaseConnection];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if ([self.window.rootViewController.presentedViewController isKindOfClass:[KDSignatureViewController class]]) {
        KDSignatureViewController *signatureVC = (KDSignatureViewController *)self.window.rootViewController.presentedViewController;
        if (signatureVC.isPresented) {
            if (self.appRevisionShouAutoRotate) {
                return  UIInterfaceOrientationMaskAllButUpsideDown;
            } else {
                if (signatureVC.orientation == UIInterfaceOrientationPortrait) {
                    return UIInterfaceOrientationMaskPortrait;
                } else {
                    return UIInterfaceOrientationMaskLandscape;
                }
            }
        }
    }
    
    if(self.vcOrientation == NSIntegerMax)
        return UIInterfaceOrientationMaskAllButUpsideDown;
    else if (self.vcOrientation == UIInterfaceOrientationPortrait || self.vcOrientation == 0)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskLandscape;
    
    //    if ([self.window.rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
    //        UINavigationController *nav =  ((UINavigationController *)self.window.rootViewController.presentedViewController);
    //        if([nav.topViewController isKindOfClass:[KDWebViewController class]])
    //        {
    //            KDWebViewController *webVC = (KDWebViewController *)nav.topViewController;
    //
    //            UIViewController *preVC = webVC.presentedViewController;
    //            if(preVC)
    //            {
    //                NSLog(@"");
    //            }
    //            if (webVC.orientation == UIInterfaceOrientationPortrait) {
    //                return UIInterfaceOrientationMaskPortrait;
    //            } else if(webVC.orientation == NSIntegerMax){
    //                return UIInterfaceOrientationMaskAllButUpsideDown;
    //            }
    //            else {
    //                return UIInterfaceOrientationMaskLandscape;
    //            }
    //        }
    //    }
    
    //    if ([((UINavigationController *)self.tabBarController.selectedViewController).topViewController isKindOfClass:[KDWebViewController class]]) {
    //        KDWebViewController *webViewController = (KDWebViewController *)((UINavigationController *)self.tabBarController.selectedViewController).topViewController;
    //        if (webViewController.useJSBridgeOrientation) {
    //            if (webViewController.orientation == UIInterfaceOrientationPortrait || webViewController.orientation == UIInterfaceOrientationUnknown) {
    //                return UIInterfaceOrientationMaskPortrait;
    //            }
    //            else {
    //                return UIInterfaceOrientationMaskLandscape;
    //            }
    //        }
    //    }
    
    //    if ([((RTRootNavigationController *)self.tabBarController.selectedViewController).rt_topViewController isKindOfClass:[KDAddExtFirendByCardViewController class]]) {
    //        return UIInterfaceOrientationMaskAll;
    //    }
    
    if ([UIDevice isiPadDevice]) {
        return UIInterfaceOrientationMaskAll;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)postInit:(BOOL)bLoadTimeline
{
    //检查版本
    if(_flags.checkedClientLatestVersion == 0){
        _flags.checkedClientLatestVersion = 1;
        
        [self checkVersion:NO];
    }
    
    // reset unread count
    [[KDManagerContext globalManagerContext].unreadManager reset];
    
    BOOL delay = YES;
    if(_flags.isFirstGetUnreadCount == 1 || bLoadTimeline){
        _flags.isFirstGetUnreadCount = 0;
        delay = NO;
    }
    
    [[KDManagerContext globalManagerContext].unreadManager start:delay];
}


- (void)goToSignIn {
    KDSignInViewController *signCtr = [[KDSignInViewController alloc]init];
    RTRootNavigationController *nav = [[RTRootNavigationController alloc] initWithRootViewController:signCtr];
    //   UINavigationController *nav = [UINavigationController navigationControllerWithRoot:[KDSignInViewController class] xibOrNil:nil];
    //    //不在默认的公司或团队
    //    if (![[[KDManagerContext globalManagerContext] communityManager] isDefaultCommunity]) {
    //
    //        //将当前的modal view dismiss 掉
    //        [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    //
    //        //切换社区
    //
    //        NSString *defaultDomain = [[[KDManagerContext globalManagerContext] userManager] currentUser].domain;
    //        CompanyDataModel *community = [[[KDManagerContext globalManagerContext] communityManager] companyByDomainName:defaultDomain];
    //        [self changeNetWork:community];
    //    }
    
    [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
}

- (void)openWebView:(NSString*)url {
    if (url == nil) {
        return;
    }
    
    if(![url hasPrefix:@"http://"])
        url = [NSString stringWithFormat:@"http://%@", url];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

/**
 *  登录完成之后调用，如果有版本说明则调用，没有则调用timeline
 */
- (void)dismissAuthViewController {
    if([KDGuideVC shouldShowGuideView]) {
        [self showAppTutorialsViewController];
    }else {
        [self showTimelineViewController];
    }
    
}

- (void)showTimelineViewController {
    
    // connect to current community for current signed user
    
    CompanyDataModel *company = nil;
    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    if (Test_Environment) {
        company = [communityManager companyByDomainName:[BOSSetting sharedSetting].cust3gNo];
        if (company == nil) {
            company = [[CompanyDataModel alloc] init];// autorelease];
            company.eid = [BOSConfig sharedConfig].user.eid;
            company.wbNetworkId = [BOSConfig sharedConfig].user.wbNetworkId;
        }
    }
    [communityManager connectToCompany:company];
    
    // update xauth authorization for network request service
    
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    [userManager updateAuthorizationForServicesContext];
    [userManager updateCurrentUser:nil];//更新一下当前的user
    [userManager wake];//更新服务端登录记录
    
    [self setupMainViewControllers];
    
    [self postInit:YES];
    
    if ([BOSConfig sharedConfig].user.token.length > 0) {
        //获取应用配置
        [self getAppConfig];
    }
}

- (void)changeToCompany:(NSString *)eid {
    [self changeToCompany:eid finished:nil];
}

- (void)changeToCompany:(NSString *)eid finished:(void(^)(BOOL finished))finishedBlock {
    
    CompanyDataModel *company = [[CompanyDataModel alloc] init];
    company.eid = eid;
    [self changeNetWork:company finished:finishedBlock];
}



- (void)changeNetWork:(CompanyDataModel *)community finished:(void(^)(BOOL finished))finishedBlock {
    if(KD_IS_BLANK_STR(community.eid) || [community.eid length] <= 0){
        return;
    }
    
    if ([[KDSession globalSession] propertyForKey:KDLocalNotificationInfoKey])
    {
        [[KDSession globalSession] removePropertyForKey:KDLocalNotificationInfoKey clearCache:YES];
    }
    
    [[KDNotificationChannelCenter defaultCenter] closeChannel];
    
    [[KDManagerContext globalManagerContext].unreadManager stop];
    
    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    
    [[KDRequestDispatcher globalRequestDispatcher] removeAllRequestsInReceiveQueue];
    
    for(ASIHTTPRequest *operation in [ASIHTTPRequest sharedQueue].operations){
        [operation clearDelegatesAndCancel];
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:self.window];// autorelease];
    hud.labelText = ASLocalizedString(@"KDMeVC_change_com");
    [hud setRemoveFromSuperViewOnHide:YES];
    [self.window addSubview:hud];
    [hud show:YES];
    
    [KDEventAnalysis event:event_band_switch_open];
    
    [XTLoginService xtLoginInEId:community.eid finishBlock:^(BOOL success) {
        if (success) {
            
            [KDEventAnalysis event:event_band_switch_ok];
            
            //reset 先
            [[KDManagerContext globalManagerContext].unreadManager reset];
            
            [communityManager connectToCompany:community];
            
            [[KDManagerContext globalManagerContext].userManager updateCurrentUser:nil];
            
            [self setupMainViewControllers];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[KDFailureSignInTask sharedFailureSignInTask] stopFailureSignInTask];
                
                //电话会议登出
                if([[KDApplicationQueryAppsHelper shareHelper]getGroupTalkStatus])
                {
                    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
                    if(agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel)
                    {
                        [agoraSDKManager leaveChannel];
                        [agoraSDKManager agoraLogout];
                    }
                }
                //文件共享播放状态清除
                if([[BOSSetting sharedSetting] fileShareEnable]){
                    KDWPSFileShareManager *fileShareManager = [KDWPSFileShareManager sharedInstance];
                    fileShareManager.accessCode = nil;
                    fileShareManager.serverHost = nil;
                    fileShareManager.originatorPersonId = nil;
                }
                
                
                //切换工作圈获取启动广告内容
                [[KDAdsManager sharedInstance] clearLocalAdsWithAdsType:KDAdsLocationType_index];
                [[KDAdsManager sharedInstance] queryAdsWithBlock:nil adsType:KDAdsLocationType_index];
                
            });
            
            
            
            [[T9 sharedInstance] reloadData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
            });
            if (finishedBlock) {
                finishedBlock(YES);
            }
            
            //语音跨圈推送通知
            if(XT_.remoteNotificationInfoCall)
                [self application:[UIApplication sharedApplication] didReceiveRemoteNotification:XT_.remoteNotificationInfoCall];
            
        }else {
            hud.labelText = ASLocalizedString(@"切换工作圈失败!");
            [[KDManagerContext globalManagerContext].unreadManager start:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud hide:YES];
            });
            if (finishedBlock) {
                finishedBlock(NO);
            }
        }
        [[KDNotificationChannelCenter defaultCenter] startChannel];
        
        [[KDManagerContext globalManagerContext].unreadManager start:NO];
        
        
        
    }];
    
}
- (void)changeNetWork:(CompanyDataModel *)community {
    [self changeNetWork:community finished:nil];
    
}



//
// Common utilities
//

static UIAlertView *sAlert = nil;

- (void)alert:(NSString*)title message:(NSString*)message
{
    if (sAlert) return;
    
    sAlert = [[UIAlertView alloc] initWithTitle:title
                                        message:message
                                       delegate:self
                              cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    sAlert.tag=WARN_ALERT;
    [sAlert show];
    //    [sAlert release];
}

+ (BOOL)isLoginUserID:(NSString*)userId {
    if (userId == nil) {
        return NO;
    }
    
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    return [userManager isCurrentUserId:userId];
}

+(KDWeiboAppDelegate*)getAppDelegate
{
    return (KDWeiboAppDelegate*)[UIApplication sharedApplication].delegate;
}

- (NSString *)openUDID
{
    NSString *openUDID = [[KDSession globalSession] getPropertyForKey:KD_OPEN_UDID_KEY fromMemoryCache:YES];
    if(!openUDID || openUDID.length == 0) {
        openUDID = [OpenUDID value];
        [[KDSession globalSession] saveProperty:openUDID forKey:KD_OPEN_UDID_KEY storeToMemoryCache:YES];
    }
    
    return openUDID;
}

- (void)popToHomeView:(UINavigationController*)navController {
    [navController  popToRootViewControllerAnimated:NO];
}


//检查新版本(7.0.6)
- (void)checkVersion:(BOOL)showWhatever {
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results != nil) {
            KDAppVersionUpdates *versionUpdates = results;
            
            NSInteger buildNo = [[KDCommon buildNo] integerValue];
            if ([versionUpdates.buildNumber integerValue] > buildNo)
            {
                [KDAppVersionUpdates store:versionUpdates];
                if(versionUpdates.changes != nil){
                    [[KDDefaultViewControllerContext defaultViewControllerContext] showUpgradeAlterView:self tag:UPDATE_ALERT withVersion:versionUpdates];
                }
                
            }else
            {
                [KDVersionCheck checkVersionInfoVisible:showWhatever info:ASLocalizedString(@"Current_LastestVersion")];
            }
            
            //            [CommenMethod postCheckVesionFinishNotification];
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/client/:checkUpdates" query:nil
                                 configBlock:^(KDServiceActionInvoker *invoker){
                                     //                                     [invoker resetRequestURL:sourceURL];
                                 }
                             completionBlock:completionBlock];
}

/*
 //检查新版本
 - (void)checkVersion:(BOOL)showWhatever {
 NSString *sourceURL = [[KDWeiboServicesContext defaultContext] serverBaseURL];
 sourceURL = [NSString stringWithFormat:@"%@%@", sourceURL, @"/res/client/iphone/iphone.json"];
 
 KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
 if (results != nil) {
 KDAppVersionUpdates *versionUpdates = results;
 
 NSInteger buildNo = [[KDCommon buildNo] integerValue];
 if ([versionUpdates.buildNumber integerValue] > buildNo)
 {
 [KDAppVersionUpdates store:versionUpdates];
 if(versionUpdates.changes != nil){
 [[KDDefaultViewControllerContext defaultViewControllerContext] showUpgradeAlterView:self tag:UPDATE_ALERT withVersion:versionUpdates];
 }
 
 }else
 {
 [KDVersionCheck checkVersionInfoVisible:showWhatever info:ASLocalizedString(@"Current_LastestVersion")];
 }
 
 //            [CommenMethod postCheckVesionFinishNotification];
 }
 };
 
 [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/client/:checkUpdates" query:nil
 configBlock:^(KDServiceActionInvoker *invoker){
 [invoker resetRequestURL:sourceURL];
 }
 completionBlock:completionBlock];
 }
 */

- (void)showClickInfo {
    [[self getOverlay] postMessage:ASLocalizedString(@"→点击查看详情")duration:1.5 animated:YES];
    [self performSelector:@selector(showNewVersionForever) withObject:nil afterDelay:1.0f];
}

- (void)showNewVersionForever {
    //    KDAppVersionUpdates *versionUpdates = [[KDSession globalSession] propertyForKey:KD_VERSION_UPDATE_KEY];
    [[self getOverlay] postMessage:[NSString stringWithFormat:ASLocalizedString(@"→发现新版本")] duration:-1 animated:YES];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message {
    sAlert = [[UIAlertView alloc] initWithTitle:title
                                        message:message
                                       delegate:self
                              cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    sAlert.tag = WARN_ALERT_FOR_RELOG;
    [sAlert show];
    //    [sAlert release];
}

- (void)accessTokenDidExpired:(NSNotification *)notification {
    [self showAlertViewWithTitle:ASLocalizedString(@"认证失败！")message:ASLocalizedString(@"授权已过期，请重新登录")];
    
}
//注册新浪微博、微信、QQ等信息
-(void)_registerShareInformation{
    [WeiboSDK registerApp:KDWEIBO_SINA_APP_KEY];
    [WXApi registerApp:KD_WECHAT_APP_KEY withDescription:@"demo 2.0"];
    
}

/// 注册金格SDK
- (void)_registerIAppRevisionWithKey:(NSString *)key {
    //    [iAppRevision registerApp:@"SxD/phFsuhBWZSmMVtSjKZmm/c/3zSMrkV2Bbj5tznSkEVZmTwJv0wwMmH/+p6wLCV2xlR41ZNMtmWy2wytY5tujYgPGwp68r99JvH6kVtiArtgkdQH7aDYWU8XeVRIBCq8samDmkH1oiGIht5xEwuFMd3V+B6FuTy2aUAahAinKY+zGld1k4DgsHA/Da6OWJ+2Q9UQNdyHB2KOkm/ZIpVQ9PW1waQ44Wyx97rcHxfA6ZrJXaGett5dn6pZWrNH3Ie1HWPVA24JpzIVB9QYoOczZ6PzW00XssjUrFarnaGe0nbQTLOk6RFlLOgKOxzl2A0RqAW+NkrCEJ5meyRqSeRCtbjrCMyHGzvN32HsGB2ugSOimMBZXAWJyoNec+zKVcD2Glj6zYWgheDUwyPPfpOdEmniDQrad2QGrp4OhyH4wulfKSsWWbCTyPbOleVQenwGBxbb+c/6f8a64N4TtJA=="];
    if (key.length > 0) {
        [iAppRevision registerApp:key];
    }
    
#ifdef DEBUG
    [iAppRevision sharedInstance].debugMode = YES;
#endif
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==WARN_ALERT)
    {
        sAlert = nil;
        
    } else if(alertView.tag == WARN_ALERT_FOR_RELOG) {
        sAlert = nil;
        
        [self signOut];
        [self showAuthViewController];
    }else if (alertView.tag == 1009) {
        if (buttonIndex == 1) {
            [self goToSignIn];
        }
        
    }else if (alertView.tag == 2000) {
        if (buttonIndex == 1) {
            [self goToSignIn];
            
        }
    }
    else {
        if (alertView.cancelButtonIndex != buttonIndex) {
            KDAppVersionUpdates *versionUpdates = [KDAppVersionUpdates retrieveLatestVersionUpdates];
            [KDCommon openURLInApplication:versionUpdates.updateURL];
        }
    }
}

#pragma mark - MTStatusBarOverlay Delegate Methods
- (void)statusBarOverlayDidRecognizeGesture:(UIGestureRecognizer *)gestureRecognizer{
    
    KDAppVersionUpdates *vu = [[KDSession globalSession] propertyForKey:KD_VERSION_UPDATE_KEY];
    if(vu) {
        [[KDDefaultViewControllerContext defaultViewControllerContext] showUpgradeAlterView:self tag:UPDATE_ALERT withVersion:vu];
        [[self getOverlay] hide];
        
        [[KDSession globalSession] removePropertyForKey:KD_VERSION_UPDATE_KEY clearCache:YES];
    }
}

- (void)signOut {
    //token失效
    [BOSSetting sharedSetting].cust3gNo = @"";
    [[BOSSetting sharedSetting] saveSetting];
    
    //KD_RELEASE_SAFELY(leftVC);
    //KD_RELEASE_SAFELY(sideMenuViewController_);
    leftVC = nil;
    sideMenuViewController_ = nil;
    // stop get unread job
    [[KDNotificationChannelCenter defaultCenter] closeChannel];
    //清除签到提示的标识
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kSigninHintFlag"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SigninIssueShowed"];
    
    //清空本地签到提醒
    [KDSignInRemindManager cancelSignInRemindWithRemind:nil];
    
    [self clearCacheAndCookie];
    
    [[KDWeiboGlobals defaultWeiboGlobals] signOut];
    
    [[KDManagerContext globalManagerContext].communityManager reset];
    
    if ([[KDSession globalSession] propertyForKey:KDLocalNotificationInfoKey])
    {
        [[KDSession globalSession] removePropertyForKey:KDLocalNotificationInfoKey clearCache:YES];
    }
    
    [XT_ xtLogout];
    //清楚手势解锁信息
    [KDLockControl  shared].isSetDone = NO;
    //清除所有有关查询签到的信息
    [KDSignInManager deleteAllSignInInfo];
    
    //清除会话列表分页请求的标志,mark:文杰叫删的
    //[[KDTimelineManager shareManager]deleteCompanyInfoForPageRequest];
    
    //电话会议登出
    if([[KDApplicationQueryAppsHelper shareHelper]getGroupTalkStatus])
    {
        KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
        if(agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel)
        {
            [agoraSDKManager leaveChannel];
            [agoraSDKManager agoraLogout];
        }
    }
    // 文件共享播放状态清除
    if([[BOSSetting sharedSetting] fileShareEnable]){
        KDWPSFileShareManager *fileShareManager = [KDWPSFileShareManager sharedInstance];
        fileShareManager.accessCode = nil;
        fileShareManager.serverHost = nil;
        fileShareManager.originatorPersonId = nil;
    }
    
    
    //清除启动广告内容
    [[KDAdsManager sharedInstance] clearLocalAdsWithAdsType:KDAdsLocationType_index];
    [[KDAdsManager sharedInstance] queryAdsWithBlock:nil adsType:KDAdsLocationType_index];
    
    //清除公共号缓存
    [[KDPublicAccountCache sharedPublicAccountCache] removeAllPubAccts];
    
    //删除明文文件文件夹
    [[KDWpsTool shareInstance] removeTempFile];
}

- (void)clearCacheAndCookie
{
    //clear cache
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    //clear cookie
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setExtendedLayout:(UIViewController *)viewController
{
    if ([viewController respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        //viewController.edgesForExtendedLayout = UIRectEdgeNone;
        //        viewController.extendedLayoutIncludesOpaqueBars = YES;
        viewController.automaticallyAdjustsScrollViewInsets = NO;
        viewController.navigationController.navigationBar.translucent = YES;
        //viewController.tabBarController.tabBar.translucent = NO;
    }
}

/**
 *  是否在公司
 *
 *  @return
 */
- (BOOL)isInCommpany
{
    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    return communityManager.currentCommunity.communityType == KDCommunityTypeCompany;
}

- (BOOL)isInTeam
{
    return [[KDManagerContext globalManagerContext].communityManager isTeamDomain];
}

- (BOOL)isInKingdeeCompany
{
    if([[[KDManagerContext globalManagerContext].communityManager currentCommunity].subDomainName isEqualToString:@"kingdee.com"] || [[[KDManagerContext globalManagerContext].communityManager currentCommunity].subDomainName isEqualToString:@"weibo.kingdee.com"]) {
        return YES;
    }
    
    return NO;
}

/**
 *  是否显示同事tab页
 *
 *
 *  @return 社区 NO， 公司和团队YES
 */
- (BOOL)isShowColleague
{
    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    return communityManager.currentCommunity.communityType != KDCommunityTypeCommunity;
}

- (void)checkHasSetPassword:(KDServiceActionDidCompleteBlock)block
{
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/account/:checkHasSetPassword" query:nil
                                 configBlock:nil completionBlock:block];
}


#pragma mark -
#pragma mark RESideMenu delegate
- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    _isLeftPresent = YES;
    
    if ([menuViewController isKindOfClass:[KDLeftTeamMenuViewController class]]) {
        
        [(KDLeftTeamMenuViewController *)menuViewController groupViewWillAppear];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    }
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    //[leftVC showMenuCell];
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    _isLeftPresent = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    // [leftVC hideMenuCell];
}

#pragma mark -
#pragma mark - XTBaseLogicDelegate methods
- (BOOL)shouldShowAppTutorialsViewController
{
    if([KDGuideVC shouldShowGuideView]) {
        [self showAppTutorialsViewController];
        return YES;
    }
    return NO;
}

//- (void)showGuideViewController
//{
//    [self showAppIntroViewController:NO];
//}
- (void)showMainViewController
{
    [self showTimelineViewController];
    
    [XT_ handleEventAfterLogin];
}

- (UIViewController *)rootViewControllerWithTabIndex:(TAB_ITEM)index
{
    return [((UINavigationController *)self.tabBarController.viewControllers[index]).viewControllers firstObject];
}

#pragma mark -
#pragma mark WeiBoSDK Delegate



- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    //取消所有发送结果的提示----我大奇哥的要求
    NSUInteger  code = response.statusCode;
    
    NSString * message = nil;
    switch (code)
    {
        case WeiboSDKResponseStatusCodeSuccess:
            message = ASLocalizedString(@"KDSocialsShareManager_Share_Success");
            break;
        case WeiboSDKResponseStatusCodeUserCancel:
            message = ASLocalizedString(@"你已经取消分享！");
            break;
        case WeiboSDKResponseStatusCodeSentFail:
            message = ASLocalizedString(@"分享失败，请求发送失败！");
            break;
        case WeiboSDKResponseStatusCodeAuthDeny:
            message = ASLocalizedString(@"分享失败，授权不成功！");
            break;
        case WeiboSDKResponseStatusCodeUserCancelInstall:
            message = ASLocalizedString(@"分享失败，你已经取消安装微博客户端！");
            break;
        case WeiboSDKResponseStatusCodeUnsupport:
            message = ASLocalizedString(@"分享失败，不支持该请求！");
            break;
        case WeiboSDKResponseStatusCodeUnknown:
            message = ASLocalizedString(@"分享失败，发生未知错误！");
            break;
        default:
            break;
    }
    
    if (code == WeiboSDKResponseStatusCodeSuccess)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ON_NOTI_WEIBO_SHARE_SUCC
                                                            object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ON_NOTI_WEIBO_SHARE_FAIL
                                                            object:nil
                                                          userInfo:@{@"error":message}];
    }
    
}
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
}

#pragma mark -
#pragma mark WXApi Delegate
-(void) onReq:(BaseReq*)req
{
}

-(void) onResp:(BaseResp*)resp
{
    //取消所有发送结果的提示----我大奇哥的要求
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        
        NSString * message = nil;
        switch (resp.errCode) {
            case WXSuccess:
                message = ASLocalizedString(@"分享成功！");
                break;
            case WXErrCodeCommon:
                message = ASLocalizedString(@"分享失败，普通错误类型！");
                
                break;
            case WXErrCodeUserCancel:
                message = ASLocalizedString(@"你已经取消分享了！");
                
                break;
            case WXErrCodeSentFail:
                message = ASLocalizedString(@"分享失败，发送请求失败！");
                
                break;
                
            case WXErrCodeAuthDeny:
                message = ASLocalizedString(@"分享失败，授权失败！");
                
                break;
            case WXErrCodeUnsupport:
                message = ASLocalizedString(@"分享失败，微信不支持！");
                
                break;
                
            default:
                break;
        }
        
        if (resp.errCode == WXSuccess)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:ON_NOTI_WECHAT_SHARE_SUCC
                                                                object:nil];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:ON_NOTI_WECHAT_SHARE_FAIL
                                                                object:nil
                                                              userInfo:@{@"error":message}];
        }
    }
}

//
- (BOOL)checkJoinByURL:(NSString *)url {
    BOOL can = NO;
    if(!KD_IS_BLANK_STR(url)) {
        if ([url rangeOfString:@"kingdee_invite_eid"].location!= NSNotFound) {
            NSString *eid = [url searchAsURLQueryWithNeedle:@"kingdee_invite_eid="];
            
            if (!KD_IS_BLANK_STR(eid) && [[KDManagerContext globalManagerContext].communityManager isJoinedCompany:eid]) {
                can = YES;
                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@""
                                                                    message:ASLocalizedString(@"您已在该工作圈中！")delegate:nil
                                                          cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
                [alertView show];
                //                [alertView release];
            }
            
        }
    }
    return can;
}


#pragma mark -
#pragma mark WXApi getAppConfig
- (void)getAppConfig
{
    if (self.openClient == nil) {
        self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getAppConfigDidReceived:result:)];// autorelease];
    }
    [self.openClient getAppConfig];
}

- (void)getAppConfigDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError) {
        return;
    }
    
    if (result.success && result.data && [result.data isKindOfClass:[NSDictionary class]]) {
        [BOSSetting sharedSetting].appConfigs = result.data;
        [[BOSSetting sharedSetting] saveSetting];
    }
}

- (void)setLangueage {
    if ([BOSConfig sharedConfig].user.enableLanguage == 1) {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:AppLanguage]) {
            NSArray  *languages = [NSLocale preferredLanguages];
            NSString *language = [languages objectAtIndex:0];
            if ([language hasPrefix:@"zh-Hans"]) {
                [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
            } else if ([language hasPrefix:@"zh-TW"] || [language hasPrefix:@"zh-HK"] || [language hasPrefix:@"zh-Hant"]) {
                [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
            } else if ([language hasPrefix:@"en"]) {
                [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:AppLanguage];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
            }
        }
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
    }
}

#pragma mark - KWOfficeApiDelegate

- (void)KWOfficeApiDidReceiveData:(NSDictionary*)dict {
    
}

- (void)KWOfficeApiDidFinished {
    
}
//wps退出后台  非正常退出
- (void)KWOfficeApiDidAbort
{
    //    KDWPSFileShareManager *sharedManager = [KDWPSFileShareManager sharedInstance];
    //    [sharedManager setAccessCode:nil serverHost:nil];
}
//断开链接
- (void)KWOfficeApiDidCloseWithError:(NSError*)error
{
}

// 共享播放开启成功回调
- (void)KWOfficeApiStartSharePlayDidSuccessWithAccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost
{
    KDWPSFileShareManager *sharedManager = [KDWPSFileShareManager sharedInstance];
    [sharedManager setAccessCode:accessCode serverHost:serverHost];
}

//共享播放开启失败回调
- (void)KWOfficeApiStartSharePlayDidFailWithErrorMessage:(NSString *)errorMessage
{
}

//共享播放接入成功回调
- (void)KWOfficeApiJoinSharePlayDidSuccess
{
}
//共享播放接入失败回调
- (void)KWOfficeApiJoinSharePlayDidFailWithErrorMessage:(NSString *)errorMessage
{
    KDWPSFileShareManager *shareManager = [KDWPSFileShareManager sharedInstance];
    KDAgoraSDKManager *agoraManger = [KDAgoraSDKManager sharedAgoraSDKManager];
    
    if(shareManager.accessCode && shareManager.accessCode.length>0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *originPersonId = shareManager.originatorPersonId && shareManager.originatorPersonId.length>0 ? shareManager.originatorPersonId:nil;
            if(originPersonId && [originPersonId isEqualToString:(agoraManger.currentGroupDataModel.isExternalGroup ? [BOSConfig sharedConfig].user.externalPersonId : [BOSConfig sharedConfig].user.userId)] && shareManager.accessCode)
            {
                //发起人是自己
                [agoraManger sendStopShareFileChannelMessageWithAccessCode:shareManager.accessCode serverHost:shareManager.serverHost?shareManager.serverHost:@""];
            }
            [shareManager setAccessCode:nil serverHost:nil];
            
            if(agoraManger.agoraPersonsChangeBlock)
            {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"PPT共享播放已经结束" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                
                agoraManger.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_fileShareFinished,nil,nil,nil);
            }
        });
    }
}
@end

