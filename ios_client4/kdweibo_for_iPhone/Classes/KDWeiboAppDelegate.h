//
//  KDWeiboAppDelegate.h
//  TwitterFon
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LoadingView.h"
#import "MTStatusBarOverlay.h"
#import "KDUnread.h"

#import <MAMapKit/MAMapKit.h>
#import "RESideMenu.h"
#import "KDLeftTeamMenuViewController.h"
#import "KDAuthViewController.h"
#import "KDServiceActionInvoker.h"
#import "XTBaseLogic.h"
#import "CompanyDataModel.h"

#import "XTTimelineViewController.h"
#import "XTContactContentViewController.h"
#import "KDApplicationViewController.h"
#import "KDDiscoveryViewController.h"

#import "WeiboSDK.h"
#import "WXApi.h"

#import "XTOpenSystemClient.h"

#if!(TARGET_IPHONE_SIMULATOR)

#import "KWOfficeApi.h"//2014.12.30添加WPS接口

#endif

//加社区后有冲突的地方屏蔽，但不知是什么原因
#define UNKNOW_HIDDEN 0

#define MAX_BAG_NUM 99

#define TIME_OUT_OF_ALTER_VIEW 60

#ifndef NSFoundationVersionNumber_iOS_6_1
#define NSFoundationVersionNumber_iOS_6_1  993.00
#endif


#define ON_NOTI_WEIBO_SHARE_SUCC    ASLocalizedString(@"KDWeiboAppDelegate_weibo_share_success")
#define ON_NOTI_WEIBO_SHARE_FAIL    ASLocalizedString(@"KDWeiboAppDelegate_weibo_share_fail")
#define ON_NOTI_WECHAT_SHARE_SUCC  ASLocalizedString(@"KDWeiboAppDelegate_wechat_success")
#define ON_NOTI_WECHAT_SHARE_FAIL  ASLocalizedString(@"KDWeiboAppDelegate_wechat_fail")

#define KDAppDelegate [KDWeiboAppDelegate getAppDelegate]

typedef enum {
    TAB_MESSAGES,
    TAB_CONTACT,
    TAB_STATUS,
    TAB_APPLICATION,
} TAB_ITEM;

typedef enum {
    Invite_From_Logined,
    Invite_From_Launched,
    Invite_From_Logining,
} Invite_From;

@class  KDCommunity;
@class LeveyTabBarController;
@class XTShareDataModel;
@class KDWebViewController;
@interface KDWeiboAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate,MTStatusBarOverlayDelegate, UIAlertViewDelegate,RESideMenuDelegate, XTBaseLogicDelegate,WeiboSDKDelegate,WXApiDelegate,UITabBarControllerDelegate
#if!(TARGET_IPHONE_SIMULATOR)
,KWOfficeApiDelegate
#endif
> {
	UIWindow*              window;
	
    MTStatusBarOverlay *overlay;
    
    struct {
        unsigned int initialized:1; // Used on lazy-load
        unsigned int isFirstGetUnreadCount:1;
        unsigned int checkedClientLatestVersion:1;
        unsigned int didLoadTeamInvitation:1;
    }_flags;
    
    KDLeftTeamMenuViewController * leftVC;
    
    XTBaseLogic *XT_;
}

@property (nonatomic, retain) UIWindow* window;
//@property (nonatomic, readonly,retain)MAMapView *mapView;
@property (nonatomic, retain) RESideMenu *sideMenuViewController;
@property(nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, retain) LeveyTabBarController * leveyTabBarController;
@property (nonatomic, readonly,retain) XTBaseLogic *XT;
@property (nonatomic, retain) XTTimelineViewController *timelineViewController;
@property (nonatomic, retain) KDWebViewController *workViewController;
@property (nonatomic, retain) XTContactContentViewController *contactViewController;
@property (nonatomic, retain) KDApplicationViewController *enteriseAppViewController;
@property (nonatomic, retain) KDDiscoveryViewController *discoveryViewController;
@property (nonatomic, assign) BOOL isLeftPresent;
@property (nonatomic, retain) XTOpenSystemClient *openClient;
//A.wang 设备唤醒时间
@property (nonatomic, retain) XTOpenSystemClient *awakeDeviceClient;
//主要用于在侧边栏个人资料里，收藏的微博进行转发、回复时的界面弹出
@property (nonatomic, retain) UIViewController *currentTopVC;

/**
 *	@brief	当前活跃的聊天窗口
 *  @discussion 如果当前未停留在聊天窗口，则 activeChatViewController = nil.
 */
@property (nonatomic, weak) XTChatViewController *activeChatViewController;
@property (nonatomic, assign) BOOL appRevisionShouAutoRotate;  // 金格签章页面是否自动旋转
@property (nonatomic, assign) UIInterfaceOrientation vcOrientation; //kdwebViewController的旋转方向

- (void)changeNetWork:(CompanyDataModel *)community;
- (void)changeNetWork:(CompanyDataModel *)community finished:(void(^)(BOOL finished))finishedBlock;

- (void)showAppIntroViewController:(BOOL)hasStageAnimation;
- (void)showAuthViewController;
- (void)dismissAuthViewController;
- (void)showTimelineViewController;

- (void)openWebView:(NSString*)url;

- (void)showLoginViewController:(NSInteger)loginType;

- (void)alert:(NSString*)title message:(NSString*)detail;
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;

- (void)postInit:(BOOL)bLoadTimeline;

-(void)popToHomeView:(UINavigationController*)navController;

+ (BOOL)isLoginUserID:(NSString*)userid;

+ (KDWeiboAppDelegate*)getAppDelegate;

//获取openUDID。
- (NSString *)openUDID;

//检查新版本
-(void)checkVersion:(BOOL)showWhatever;

- (MTStatusBarOverlay *)getOverlay;

+ (void)setExtendedLayout:(UIViewController *)viewController;

//判断是否是在公司
- (BOOL)isInCommpany;

- (BOOL)isInTeam;

- (BOOL)isInKingdeeCompany;

- (void)signOut;
- (void)clearCacheAndCookie;


//通过企业eid 切换到公司
- (void)changeToCompany:(NSString *)eid;

- (void)changeToCompany:(NSString *)eid finished:(void(^)(BOOL finished))finishedBlock;
/**
 *  判断是否设置过密码
 *
 *  @param block
 */
- (void)checkHasSetPassword:(KDServiceActionDidCompleteBlock)block;

- (UIViewController *)rootViewControllerWithTabIndex:(TAB_ITEM)index;
/**
 *  二维码扫描后，调用此方法,判断是否已经加入了某个企业
 *
 *  @param url  二维码扫描结果
 *  @return YES:已加入了某企业
 *          NO:没有。
 */
//
- (BOOL)checkJoinByURL:(NSString *)url;
- (void)setGestureLock;//判断手势解锁

- (void)setupMainViewControllers;

-(void)resetMainView;

- (void)_registerIAppRevisionWithKey:(NSString *)key;

@end
