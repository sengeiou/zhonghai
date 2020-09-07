//
//  KDWebViewController.h
//  kdweibo
//
//  Created by Gil on 14-10-20.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"
#import "KDAppDataModel.h"
#import <CoreLocation/CoreLocation.h>
#import "KDWebView.h"
#import "KDPlusMenuView.h"
#import "KDSheet.h"
#import "ContactClient.h"
#import "BuluoSDK.h"
#import "BuluoObject.h"
#import "KDSignInLocationManager.h"


typedef NS_ENUM(NSInteger, KDWebViewType){
    KDWebViewTypeNomal = 0, //普通url
    KDWebViewTypeParams,    //在url后面追加参数的鉴权模式（旧）
    KDWebViewTypeTicket     //ticket鉴权模式（新）
};

/**
 *  优先级最高的title，KDWebViewTitleLevel_Higher > KDWebViewTitleLevel_Document > KDWebViewTitleLevel_Lower
 */
typedef NS_ENUM(NSInteger , KDWebViewTitleLevel){
    KDWebViewTitleLevel_Document = 0,     //通过js document.title获取的title
    KDWebViewTitleLevel_Higher,         //通过上级vc->webvc设置的self.title
    KDWebViewTitleLevel_Lower           //最低等级title，需要延迟显示
};
typedef void(^GetLightAppUrlCompleteBlock)();

@class MessageNewsEachDataModel;
@class PersonSimpleDataModel;
//@class KDWebShareDataModel;
@interface KDWebViewController : UIViewController <NJKWebViewProgressDelegate,UIActionSheetDelegate,KDWebViewDelegate>

@property (nonatomic, strong, readonly) NSURL *webUrl;
@property (nonatomic, assign, readonly) KDWebViewType type;
@property (nonatomic, assign) KDAppType appType;

@property (nonatomic, strong, readonly) KDWebView *webView;
@property (nonatomic, strong, readonly) UIButton *rightButton;

@property (strong, nonatomic, readonly) NSString *appId;
@property (assign, nonatomic) BOOL isRigthBtnHide;
@property (assign, nonatomic) BOOL isOnlyOpenInBrowser;
@property (nonatomic, strong) UIViewController *functionViewController;
@property (nonatomic, assign) BOOL isBlueNav;
@property (assign, nonatomic) BOOL isOpenWithWB;

@property (nonatomic, strong) NSString *color4NavBg;
@property (nonatomic, strong) NSString *color4processBg;

@property (nonatomic, assign) BOOL isTitleNavHidden;//修改的navbar隐藏状态
@property (nonatomic, assign) BOOL isOriginalNavBarHidden;//原始的navbar隐藏状态

@property (nonatomic, copy) NSString *(^blockEditURL)(NSString *strURL);
/**
 *  用于分享的数据,必须同时给shareNewsDataModel和personDataModel赋值，才可以进行分享转发
 *  alanwong
 */
@property (strong, nonatomic) MessageNewsEachDataModel * shareNewsDataModel;  //新闻的数据
@property (strong, nonatomic) PersonSimpleDataModel * personDataModel; //公共号的信息
@property (strong, nonatomic) NSString *pubAccId;
@property (copy, nonatomic) NSString *groupId;//扫描群租二维码使用

@property (nonatomic, strong) CLLocation *appLocation;

@property (strong , nonatomic) GetLightAppUrlCompleteBlock getLightAppBlock;

@property (nonatomic, strong) XTOpenSystemClient *getAdminEidClient;
@property (nonatomic, strong) ContactClient *sendMessageClient;

//A.wang js桥createGroupByPhone
@property (nonatomic, strong) XTOpenSystemClient *openSystemClient;
@property (nonatomic, strong) ContactClient *createGroupChatClient;

@property (nonatomic, strong) KDSheet *sheet;


@property (nonatomic, assign) BOOL abortUseWebTitle;
@property (nonatomic, copy) NSString *naviTitle; // 若有设置改属属性，webview的title就强制设为该值
@property (nonatomic, copy) NSString *fromAppName;

@property (nonatomic, assign) BOOL isGetingCurrentLocation;
@property (nonatomic, strong) UIWindow *secondWindow;
/**
 *  分享数据
 */
@property (strong , nonatomic) MessageNewsEachDataModel *shareModel;

//部分从会话界面进来的轻应用入口
@property (nonatomic, assign) BOOL isLightApp;
@property (nonatomic, strong) NSString *groupAppURL;//群应用的url

@property (nonatomic, assign) UIInterfaceOrientation orientation; //kdwebViewController的旋转方向
@property (nonatomic, assign) BOOL useJSBridgeOrientation;  // 是否使用JS桥的旋转方向

@property (nonatomic, strong) OpenUser *wxsqUser;// 微信社区帐号

@property (nonatomic, copy) NSString *todoGroupId;
@property (nonatomic, copy) NSString *todoMsgId;
@property (nonatomic, copy) NSString *todoUserId;
@property (nonatomic, copy) NSString *todoStatus;

@property (nonatomic, strong) KDSignInLocationManager *detailLocationManager;

/**
 *  普通url, type = KDWebViewTypeNomal
 *
 *  @param url 网页链接, 不能为空
 *
 *  @return
 */
- (id)initWithUrlString:(NSString *)url;

/**
 *  在url后面追加参数的鉴权模式（旧）, type = KDWebViewTypeParams
 *
 *  @param url 网页链接, 不能为空
 *  @param pubAccId 公共号ID
 *  @param menuId 菜单ID
 *
 *  @return
 */
- (id)initWithUrlString:(NSString *)url
               pubAccId:(NSString *)pubAccId
                 menuId:(NSString *)menuId;

/**
 *  ticket鉴权模式（新）, type = KDWebViewTypeTicket
 *
 *  @param url 网页链接
 *  @param appId 轻应用ID, 不能为空
 *
 *  @return
 */
- (id)initWithUrlString:(NSString *)url
                  appId:(NSString *)appId;

- (instancetype)initWithUrlString:(NSString *)url
                         OpenUser:(OpenUser *)user;

- (void)updateMasonry:(BOOL)isFullScreen;


//关闭界面
//- (void)dismissSelf;
- (void)setupRightBarButtonItem;

//关闭界面
- (void)dismissSelf;
- (void)setupLeftBarButtonItem;
- (void)setupLeftBarButtonItems;

- (BOOL)isWhileNav;
- (void)goBackDirect;

- (void)setGetLightAppBlock:(GetLightAppUrlCompleteBlock)getLightAppBlock appId:(NSString *)appId url:(NSString *)url;


/**
 *  获取当前url页面可分享数据对象
 *
 *  @return KDWebShareDataModel 类
 */
- (MessageNewsEachDataModel *)getCurrentPageShareData;

//zgbin:为了请求新的ticket,刷新界面
- (void)loadRequest;
@end
