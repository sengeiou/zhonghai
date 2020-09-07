//
//  KWIAppDelegate.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KWIAppDelegate.h"

#import "iToast.h"

#import "NSDate+RelativeTime.h"
#import "SCPLocalKVStorage.h"


#import "KWIGlobal.h"
#import "KWIRootVCtrl.h"
#import "KWISigninVCtrl.h"

#import "MobClick.h"

#import "KDCommonHeader.h"

//#define MOBAPPKEY @"4fc436ed5270155de4000006"
// 2.0
#define MOBAPPKEY @"518c632456240b9dc30147e2"
@interface KWIAppDelegate () <UINavigationControllerDelegate, UIAlertViewDelegate> {
    struct {
        unsigned int initialized:1; // Used on lazy-load
        unsigned int isFirstGetUnreadCount:1;
        unsigned int checkedClientLatestVersion:1;
    }_flags;
}

@property(nonatomic,retain)KWISigninVCtrl *signInViewController;
@property(nonatomic,retain)UINavigationController *rootNavController;;
- (void)checkVersion;

@end

@implementation KWIAppDelegate
@synthesize window = _window;
@synthesize splitViewController = _splitViewController;
@synthesize signInViewController = signInViewController_;
@synthesize rootNavController = rootNavController_;

- (void)dealloc
{
    [_window release];
  
    [_splitViewController release];
    [fileURL release];
    [commentURL_ release];
    KD_RELEASE_SAFELY(signInViewController_);
    KD_RELEASE_SAFELY(rootNavController_);
    
    [super dealloc];
}


- (void)setupUmengAppAnalyzer {
     [MobClick startWithAppkey:MOBAPPKEY reportPolicy:BATCH channelId:nil];
}
- (NSString *)appKey {
    return MOBAPPKEY;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
   
//
//   
//    // Override point for customization after application launch.
//    KWOAuthToken *consumerToken = [KWOAuthToken tokenWithKey:KWIAppKey 
//                                                      secret:KWIAppSecret];
//    KWEngine *api = [KWEngine engineWithConsumerToken:consumerToken];
//   
//    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
//    
//    iToastSettings *settings = [iToastSettings getSharedSettings];
//    //settings.gravity = iToastGravityTop;
//    settings.duration = iToastDurationNormal;
//    
//    KWISigninVCtrl *signinVCtrl = [[[KWISigninVCtrl alloc] initWithNibName:@"KWISigninVCtrl" bundle:nil] autorelease];
//    UINavigationController *rootNavC = [[[UINavigationController alloc] initWithRootViewController:signinVCtrl] autorelease];
//    rootNavC.navigationBarHidden = YES;
//    rootNavC.delegate = self;
//    self.window.rootViewController = rootNavC;
//    
//    
//    // will remove later
//    [api clearKeychain];
//    NSString *accessKey = [SCPLocalKVStorage objectForKey:@"access_key"];
//    NSString *accessSecret = [SCPLocalKVStorage objectForKey:@"access_secret"];    
//    if (accessKey && accessSecret) {
//    //if(0) {
//        KWOAuthToken *token = [KWOAuthToken tokenWithKey:accessKey secret:accessSecret];
//        api.accessToken = token;    
//    //if ([api recieveAccessTokenfromKeychain]) {
//        
//        [rootNavC pushViewController:[KWIRootVCtrl vctrl] animated:NO];
//    } else {
//        [signinVCtrl show];
//    }
//    
//    [self.window makeKeyAndVisible];
//    
//    [self checkVersion];
//    
//    return YES;
    
    DLog(@"launched....");
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if (launchOptions != nil) {
        NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        if (url != nil && ![url isFileURL]) {
            [[KDSession globalSession] setProperty:url forKey:UIApplicationLaunchOptionsURLKey];
        }
    }
    
    // app initialization path
    [self _setupAppPath];
    
    // specific UI page for app
    [self _configureAppUI];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)_configureAppUI {
    NSURL *url = [[KDSession globalSession] propertyForKey:UIApplicationLaunchOptionsURLKey];
    if (url != nil) {
        BOOL canOpenURL = [self handleOpenURL:url launched:NO];
        // remove cached open url
        [[KDSession globalSession] setProperty:nil forKey:UIApplicationLaunchOptionsURLKey];
        
        if (canOpenURL) {
            return;
        }
    }
    
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    if ([userManager isSigned]) {
        // set user is signing flag
        [[KDSession globalSession] setProperty:[NSNumber numberWithBool:YES] forKey:KD_PROP_USER_IS_SIGNING_KEY];
        
        // connect to current community for current signed user
        KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
        [communityManager connectToCommunity:nil];
        
        // update xauth authorization for network request service
        [userManager updateAuthorizationForServicesContext];
        [userManager updateCurrentUser];
        
        [self setupMainViewControllers];
        
        [self postInit:NO];
        
        // register remote notification
        [[KDManagerContext globalManagerContext].APNSManager registerForRemoteNotification];
        
    }
    else {
       // [self showAppIntroViewController:YES];
        [self showSingInViewController];
    }
}

- (void)dismissAuthViewController {
    [self showTimelineViewController];
}


//- (UINavigationController *)
- (void)setupMainViewControllers {
    NSLog(@"setupMainVeiwController....");
    //
//    UINavigationController * rootVC =  (UINavigationController * )self.window.rootViewController;
//    if(rootVC == nil) {
//        rootVC = [[UINavigationController alloc] init];
//        self.window.rootViewController = rootVC;
//        [rootVC release];
//    }
//    [rootVC pushViewController:[KWIRootVCtrl vctrl] animated:YES];
    [[self rootNavController] pushViewController:[KWIRootVCtrl vctrl]  animated:YES];
}

- (void)showTimelineViewController {
    [self setupMainViewControllers];
    
    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    // check did connected to current community yet
    if (![[KDDBManager sharedDBManager] isConnectingWithCommunity:communityManager.currentCommunity.communityId]) {
        // connect to current community
        [[KDDBManager sharedDBManager] tryConnectToCommunity:communityManager.currentCommunity.communityId];
    }
    
    [self postInit:YES];
}
- (void)postInit:(BOOL)bLoadTimeline {
    //检查版本
    if(_flags.checkedClientLatestVersion == 0){
        _flags.checkedClientLatestVersion = 1;
        
        //[self checkVersion:NO];
        [self checkVersion];
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
- (void)_executeTasksbeforeRunning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        // clear application temporay folder
        NSString *path = [[KDUtility defaultUtility] searchDirectory:KDApplicationTemporaryDirectory
                                                        inDomainMask:KDTemporaryDomainMask needCreate:NO];
        
        NSFileManager *fm = [[NSFileManager alloc] init];
        if([fm fileExistsAtPath:path]){
            [fm removeItemAtPath:path error:NULL];
        }
        
        [fm release];
    });
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
    [self setupUmengAppAnalyzer];
    
    // #endif
    
    [self _executeTasksbeforeRunning];
    
    // setup app settings depends on current device
   // [self _setupAppSettingsDependOnDevice];
    
    // setup UI components
   // [self _setupAppUIComponent];
}

- (UINavigationController *)rootNavController {
    if (rootNavController_ == nil) {
        rootNavController_ = [[UINavigationController alloc] init];
        rootNavController_.navigationBarHidden = YES;
        rootNavController_.delegate = self;
        self.window.rootViewController = rootNavController_;
    }
    return rootNavController_;
}

- (KWISigninVCtrl *)signInViewController {
    if (signInViewController_ == nil) {
        signInViewController_ =  [[KWISigninVCtrl alloc] initWithNibName:@"KWISigninVCtrl" bundle:nil];
    }
    return signInViewController_;
}

- (void)showSingInViewController {
    if ([[[self rootNavController] viewControllers] containsObject:[self signInViewController]]) {
        [[self rootNavController] popToViewController:[self signInViewController] animated:YES];
    }else {
        self.rootNavController = nil;
        [[self rootNavController] pushViewController:[self signInViewController] animated:YES];
    }
}
// for iOS version greater than 4.2 or equals to 4.2
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    DLog(@"application opne url");
    return [self handleOpenURL:url launched:YES];
}


- (void)openWebView:(NSString*)url {
    if (url == nil) {
        return;
    }
    
    if(![url hasPrefix:@"http://"])
        url = [NSString stringWithFormat:@"http://%@", url];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (BOOL)handleOpenURL:(NSURL *)url launched:(BOOL)launched {
    KDQuery *query = [KDThirdPartAppAuthActionHandler toQueryWithOpenURL:url];
    KDThirdPartAppAuthActionHandler *handler = [[KDThirdPartAppAuthActionHandler alloc] init];
    handler.query = query;
    
    BOOL succeed = [handler execute];
    [handler release];
    
    if (succeed) {
        KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
        if ([userManager isSigned]) {
            // do sign out and navigate to auth view controller
            [self _signOut];
        }
        
        //search network_id
        NSString *queryString = [url query];
        NSString *subDomainName = [queryString searchAsURLQueryWithNeedle:@"domain_name="];
        
        // save open url query into global settings
        [[KDSession globalSession] setProperty:query forKey:KD_PROP_3RD_AUTH_QUERY_KEY];
        [[KDSession globalSession] setProperty:subDomainName forKey:KD_3RD_AUTH_DOMAIN_NAME];
        
        [self showSingInViewController];
    }
    
    return succeed;
}

// for iOS version eariler than 4.2
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self application:application openURL:url sourceApplication:nil annotation:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
     DLog(@"applicationWillResignActive...");
    id obj = [[KDSession globalSession] propertyForKey:KD_PROP_USER_IS_SIGNING_KEY];
    if (obj != nil) {
        [[KDManagerContext globalManagerContext].unreadManager stop];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    DLog(@"applicationDidBecomeActive...");
    //[[KDWeiboCore sharedKDWeiboCore] fetchUnreadCount];
    id obj = [[KDSession globalSession] propertyForKey:KD_PROP_USER_IS_SIGNING_KEY];
    if (obj != nil) {
        [[KDManagerContext globalManagerContext].unreadManager start:NO];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
   // [self saveContext];
    [[KDWeiboGlobals defaultWeiboGlobals] disconnectDatabaseConnection];

}

+(KWIAppDelegate *)getAppDelegate {
    return (KWIAppDelegate*)[UIApplication sharedApplication].delegate;
}
- (NSString *)commentURL {
    return commentURL_;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{ 
    NSLog(@"got push token: %@", deviceToken);
	[[KDManagerContext globalManagerContext].APNSManager updateWithToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

     [[KDManagerContext globalManagerContext].APNSManager didReceiveRemoteNotification:userInfo];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (animated && [viewController isMemberOfClass:KWISigninVCtrl.class]) {
        [(KWISigninVCtrl *)viewController show];
    }
}


#pragma mark - methods for version check
- (void)checkVersion {
    NSString *sourceURL = [[KDWeiboServicesContext defaultContext] serverBaseURL];
    sourceURL = [NSString stringWithFormat:@"%@%@", sourceURL, @"/res/client/ipad/ipad.json"];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            //
              KDAppVersionUpdates *versionUpdate = results;
                if(versionUpdate.version){
                        NSComparisonResult result = 0;
                        commentURL_ = [versionUpdate.commentURL retain];
                        if([KDVersion quickCompareVersionA:versionUpdate.version versionB:[KDCommon clientVersion]results:&result]){
                            if(NSOrderedDescending == result && versionUpdate.changes != nil && versionUpdate.updatePolicy != KDWeiboUpdatePolicyNot){
                                NSString* title = [NSString stringWithFormat:@"升级到%@版",versionUpdate.version];
            
                                fileURL = [versionUpdate.updateURL retain];
            
                                NSMutableString *message = [NSMutableString stringWithFormat:@"%@版新增特性\n",versionUpdate.version];
                                for(NSString* content in versionUpdate.changes){
                                    [message appendString:[NSString stringWithFormat:@"%@\n",content]];
                                }
            
                                NSString *tip = nil;
            
                                if(versionUpdate.updatePolicy == KDWeiboUpdatePolicyRecommend)
                                    tip = @"建议更新";
                                else
                                    tip = @"必须更新，否则将导致使用异常";
            
                                [message appendString:@"\n"];
                                [message appendString:tip];
            
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"升级" , nil];
                                [alert show];
                                [alert release];
                            }
                        }
                    }
        }else {
            
        }
        
    };
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/client/:checkUpdates" query:nil
                                 configBlock:^(KDServiceActionInvoker *invoker){
                                     [invoker resetRequestURL:sourceURL];
                                 }
                             completionBlock:completionBlock];
    
}

#pragma mark - UIAlertViewDelegate Methods
//设置messge的文本左对齐
- (void)willPresentAlertView:(UIAlertView *)alertView
{
    int index = 0;
    for(UIView *subView in [alertView subviews]){
        if ([subView isKindOfClass:[UILabel class]]){
            if(1 == index)
                [(UILabel *)subView setTextAlignment:UITextAlignmentLeft];
            index ++;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.cancelButtonIndex != buttonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fileURL]];
    }
}

- (void)_signOut {
    [[KDWeiboGlobals defaultWeiboGlobals] signOut];
}
@end
