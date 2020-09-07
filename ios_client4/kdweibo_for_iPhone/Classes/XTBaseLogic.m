//
//  XTBaseLogic.m
//  kdweibo
//
//  Created by bird on 14-4-17.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTBaseLogic.h"
#import "ContactLoginDataModel.h"
#import "ContactConfig.h"
#import "BOSSetting.h"
#import "BOSConfig.h"
#import "BOSFileManager.h"
#import "XTSetting.h"
#import "ContactClient.h"

#import "XTShareDataModel.h"
#import "ContactUtils.h"
#import "XTForwardDataModel.h"

#import "XTOpenConfig.h"
#import "BOSUtils.h"

#import "BOSConnect.h"
#import "CheckVersionService.h"
#import "CustomerLogoDownloadService.h"
#import "InstructionsService.h"
#import "LogoutService.h"
#import "BOSLogger.h"
#import "BOSFileManager.h"
#import "BOSUtils.h"
#import "BOSConfig.h"
#import "MCloudClient.h"
#import "MBProgressHUD.h"
#import "KDWeiboAppDelegate.h"
#import "CompanyDataModel.h"

#import "KDAuthViewController.h"

#import "XTShareManager.h"
#import "XTInitializationManager.h"
#import "ContactUtils.h"XT_
#import "KDLinkInviteConfig.h"

#import "KDDatabaseHelper.h"
#import "KDWeiboDAOManager.h"

#import "KDAgoraCallView.h"
#import "KDAgoraSDKManager.h"
#import "KDMultiVoiceViewController.h"
#import <objc/runtime.h>
#import "KDApplicationOpenHelper.h"

@interface XTBaseLogic () <InstructionsDelegate, MBProgressHUDDelegate, EMPLoginDelegate>
{
    //    CheckVersionService *checkVersionService;
    
    InstructionsService *instructionsService;
    
    LogoutService       *logoutService;
    
    MBProgressHUD *hud;
    
    BOOL showLogoutDesc;
}
@property (nonatomic, retain) NSDictionary *handleOpenUrlDictionary;
@property (nonatomic, retain) ContactClient *personInfoClient;
@property (retain, nonatomic) EMPServerClient *deviceTokenClient;
@property (nonatomic, readonly) UIWindow *window;
@property (nonatomic, strong) ContactClient *queryGroupInfoClient;
@property (nonatomic, strong) ContactClient *queryGroupInfoClient2;
@property (nonatomic, strong) ContactClient *queryGroupInfoClient3;

//短信
@property (nonatomic, strong) ContactClient *queryGroupInfoClient4;
@property (nonatomic, strong) NSString *msgIDFromMsg;

@end

@implementation XTBaseLogic
@synthesize remoteNotificationInfo;
@synthesize handleOpenUrlDictionary;
@synthesize window;
@synthesize delegate = delegate_;
//
//- (void)launched
//{
//    //检查版本更新
//    if (checkVersionService == nil) {
//        checkVersionService = [[CheckVersionService alloc] init];
//    }
//    [checkVersionService run];
//}

//指令
- (void)command
{
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    BOSConfig *setting = [BOSConfig sharedConfig];
    
    if (userManager.isSigned && [setting.user.token length] > 0) {
        if (instructionsService == nil) {
            instructionsService = [[InstructionsService alloc] init];
            instructionsService.delegate = self;
        }
        [instructionsService run];
    }
}

- (void)registerPushToken:(NSData *)token
{
    NSString *str = [NSString stringWithFormat:@"%@",token];
    str = [str substringFromIndex:1];
    str = [str substringToIndex:71];
    [BOSConfig sharedConfig].deviceToken = str;
    
    if (self.deviceTokenClient == nil) {
        self.deviceTokenClient = [[EMPServerClient alloc] initWithTarget:self action:@selector(registerDeviceTokenDidReceive:result:)];// autorelease];
    }
    [self.deviceTokenClient registerDeviceTokenWithToken:[BOSConfig sharedConfig].user.token appClientId:XuntongAppClientId deviceId:[UIDevice uniqueDeviceIdentifier] deviceToken:[BOSConfig sharedConfig].deviceToken];
}

- (void)registerDeviceTokenDidReceive:(EMPServerClient *)client result:(BOSResultDataModel *)result {
    if (!result.success && result.errorCode == 1007) {
        [[KDNotificationChannelCenter defaultCenter] logout:result.error data:result.data];
        return;
    }
}

- (void)receiveRemoteNotification:(NSDictionary *)userInfo
{
    __block KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    __block BOSConfig *setting = [BOSConfig sharedConfig];
    NSString *networkId = [userInfo objectForKey:@"networkId"];
    //如果是当前工作圈
    if(!KD_IS_BLANK_STR(networkId) && [networkId isEqualToString:setting.user.eid]){
        if (userManager.isSigned && [setting.user.token length] > 0) {
            
            self.remoteNotificationInfo = nil;
            
            int mode = [[userInfo objectForKey:@"mode"] intValue];
            NSString *groupId = [userInfo objectForKey:@"groupId"];
            NSString *todoPriStatus = [userInfo objectForKey:@"todoPriStatus"];
           
            BOOL containString = NO;
            
            if (!isAboveiOS8) {
                containString = [groupId rangeOfString:kTodoPersonId].length > 0 ? YES : NO;
            }else
            {
                containString = [groupId containsString:kTodoPersonId];
            }
            
            if(containString)
            {
                GroupDataModel *todogdm = [[XTDataBaseDao sharedDatabaseDaoInstance] queryTodoMsgInXT];
                if (todoPriStatus.length > 0) {
                    todogdm.todoPriStatus = todoPriStatus;
                }else{
                    todogdm.todoPriStatus = @"noti";//通知消息只是赋值
                }
                [self timelineToTodoWithGroup:todogdm];
            }
            else if (mode == ChatPrivateMode && groupId.length > 0) {
                GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:groupId];
                group.isRemoteMsg = YES;
                
                // 多此一步是为了获取公共号的state状态
                PersonSimpleDataModel *person = [group.participant firstObject];
                if ([person isPublicAccount]) {
                    person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicAccountWithId:person.personId];
                    [group.participant removeAllObjects];
                    [group.participant addObject:person];
                }
                
                if (group != nil) {
                    [self timelineToChatWithGroup:group withMsgId:nil];
                }
            }
            else if(mode == KDChatModeMultiCall && groupId.length>0)
            {
                if(self.queryGroupInfoClient == nil)
                {
                    self.queryGroupInfoClient = [[ContactClient alloc] initWithTarget:self action:@selector(queryGroupInfoClientDidReceive:result:)];
                }
                [self.queryGroupInfoClient queryGroupInfoWithGroupId:groupId];
            }else {
                //zgbin:start
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"title" message:@"bidatongzhi" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
//                [alert show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"bidaRefresh" object:nil];
                //zgbin:end
            }
            
        }
    }
    else{
        CompanyDataModel *companyModel = [[CompanyDataModel alloc] init];
        companyModel.eid = networkId;
        KDWeiboAppDelegate *appDelegate = (KDWeiboAppDelegate *)[KDWeiboAppDelegate getAppDelegate];
        [appDelegate changeNetWork:companyModel finished:^(BOOL finished) {
            if (userManager.isSigned && [setting.user.token length] > 0) {
                
                self.remoteNotificationInfo = nil;
                
                int mode = [[userInfo objectForKey:@"mode"] intValue];
                NSString *groupId = [userInfo objectForKey:@"groupId"];
                
                if([groupId containsString:kTodoPersonId])
                {
                    GroupDataModel *todogdm = [[XTDataBaseDao sharedDatabaseDaoInstance] queryTodoMsgInXT];
                    [self timelineToTodoWithGroup:todogdm];
                }
                else if (mode == ChatPrivateMode && groupId.length > 0) {
                    GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:groupId];
                    if (group != nil) {
                        [self timelineToChatWithGroup:group withMsgId:nil];
                    }
                }
                else if(mode == KDChatModeMultiCall && groupId.length>0)
                {
                    if(self.queryGroupInfoClient == nil)
                    {
                        self.queryGroupInfoClient = [[ContactClient alloc] initWithTarget:self action:@selector(queryGroupInfoClientDidReceive:result:)];
                    }
                    [self.queryGroupInfoClient queryGroupInfoWithGroupId:groupId];
                }
                
            }
        }];
   
        
        
    }
    
}

- (NSString *)commonPersonId:(GroupDataModel *)group
{
    return (group.isExternalGroup ? [BOSConfig sharedConfig].user.externalPersonId : [BOSConfig sharedConfig].user.userId);
}
- (void)handleEventAfterLogin
{
    if (self.remoteNotificationInfo) {
        [self receiveRemoteNotification:self.remoteNotificationInfo];
    } else if (self.handleOpenUrlDictionary) {
        [self receiveHandleOpenUrlNotification:self.handleOpenUrlDictionary];
        self.handleOpenUrlDictionary = nil;
    }
    [[KDNotificationChannelCenter defaultCenter] startChannel];
}

- (void)receiveRemoteNotificationWithInActiveWithUserInfo:(NSDictionary *)userInfo
{
    NSString *groupId = [userInfo objectForKey:@"groupId"];
    
    if(groupId && groupId.length>0)
    {
        GroupDataModel *group =  [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:groupId];
        //保存提示的groupid
        [[NSUserDefaults standardUserDefaults] setValue:group.groupId forKey:@"AgoraGroup"];
        
        if(group && group.mCallStatus == 1 && group.mCallCreator && ![group.mCallCreator isEqualToString:[self commonPersonId:group]])
        {
            BOOL isAddByTabBarControllerFlag = YES;
            UIViewController *topViewController = ((RTRootNavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController).topViewController;
            while (topViewController.presentedViewController)
            {
                if(isAddByTabBarControllerFlag)
                {
                    isAddByTabBarControllerFlag = NO;
                }
                topViewController = topViewController.presentedViewController;
            }
            if([topViewController isKindOfClass:[RTRootNavigationController class]])
            {
                topViewController = ((RTRootNavigationController *)topViewController).topViewController;
            }

//            UINavigationController *navController = (UINavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController;
//            UIViewController *topViewController = navController.topViewController;
//            while (topViewController.presentedViewController)
//            {
//                if(isAddByTabBarControllerFlag)
//                {
//                    isAddByTabBarControllerFlag = NO;
//                }
//                topViewController = topViewController.presentedViewController;
//            }
//            if([topViewController isKindOfClass:[UINavigationController class]])
//            {
//                topViewController = ((UINavigationController *)topViewController).topViewController;
//            }
            
            [self showMultiCallViewWithGroupDataModel:group viewController:topViewController isTabBarControllerAdd:isAddByTabBarControllerFlag];
            
            return;
        }
        
        if(self.queryGroupInfoClient2 == nil)
        {
            self.queryGroupInfoClient2 = [[ContactClient alloc] initWithTarget:self action:@selector(queryGroupInfoClientDidReceive2:result:)];
        }
        [self.queryGroupInfoClient2 queryGroupInfoWithGroupId:groupId];
    }
}
#pragma mark - logout

- (void)clearLogoutData
{
    [[BOSSetting sharedSetting] cleanUpAccount];
    
    [[BOSConfig sharedConfig] clearConfig];
    
    //删除当前登录者管理的公共号信息
    [[ContactConfig sharedConfig] clearConfig];
    
    //删除是否第一次登录标识
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserDefaults_FirstLogin];
}
- (void)logoutService
{
    //注销接口
    if (logoutService == nil) {
        logoutService = [[LogoutService alloc] init];
    }
    [logoutService run];
}
- (void)xtLogout
{
    [self logoutService];
    
    [self clearLogoutData];
    
    [self openLoginViewController];
}

#pragma mark - open url

- (BOOL)applicationHandleOpenURL:(NSURL *)url
{
    NSDictionary *result = nil;
    BOOL needLogin = [self analysisURL:url result:&result];
    
    if (!needLogin) {
        
        BOSConfig *setting = [BOSConfig sharedConfig];
        //短信通知进来 不影响原有逻辑
        NSString *recieverOpenId = [result objectForKey:@"recieverOpenId"];
        if ( recieverOpenId != nil && recieverOpenId.length > 0) {
            if (![setting.user.openId isEqualToString:recieverOpenId]) {
                return YES;
            }
        }
    
        if ([setting.user.token length]>0) {
            //应用已启动，直接处理业务
            self.handleOpenUrlDictionary = nil;
            //不同圈子切换先
            NSString *eid = [result objectForKey:@"eid"];
            if (eid.length > 0) {
                if (![setting.user.eid isEqualToString:eid]) {
                    CompanyDataModel *company = [[CompanyDataModel alloc] init];
                    company.eid = eid;
                    [[KDWeiboAppDelegate getAppDelegate] changeNetWork:company finished:^(BOOL finished) {
                        [self receiveHandleOpenUrlNotification:result];

                    }];
                }else
                {
                    [self receiveHandleOpenUrlNotification:result];
                }
            }else
            {
               [self receiveHandleOpenUrlNotification:result];
            }
            
        } else {
            //应用初次启动，需要自动登录
            self.handleOpenUrlDictionary = result;
            
            [self openLoginViewController];
        }
    }
    return YES;
}

- (BOOL)analysisURL:(NSURL *)url result:(NSDictionary **)result
{
    NSString *queryStr = [url query];
    if (queryStr.length == 0)
    {
        return NO;
    }
    
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&"];
    NSScanner *scanner = [[NSScanner alloc] initWithString:queryStr];// autorelease];
    while (![scanner isAtEnd]) {
        
        NSString *pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        
        NSRange range = [pairString rangeOfString:@"="];
        if (range.location == NSNotFound) {
            continue;
        }
        
        NSString *key = [pairString substringToIndex:range.location];
        NSString *value = [pairString substringFromIndex:range.location+1];
        if (key.length == 0)
        {
            continue;//key不能为空
        }
        if (value.length > 0) {
            value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        [pairs setObject:value forKey:[self changeKey:key]];
    }
    if ([pairs count] == 0) {
        return NO;
    }
    
    if (result) {
        *result = [NSDictionary dictionaryWithDictionary:pairs];
    }
    
    NSArray *keys = [pairs allKeys];
    if ([keys containsObject:@"cust3gNo"] && [keys containsObject:@"userName"] && ([keys containsObject:@"password"] || ([keys containsObject:@"token"] && [keys containsObject:@"token_type"]))) {
        return YES;
    }
    return NO;
}

- (NSString *)changeKey:(NSString *)key
{
    if ([@"identify" isEqualToString:key])
    {
        return @"userName";
    }
    else if ([@"third_token" isEqualToString:key])
    {
        return @"token";
    }
    return key;
}

- (void)receiveHandleOpenUrlNotification:(NSDictionary *)userInfo
{
    NSArray *allKeys = [userInfo allKeys];
    if ([allKeys containsObject:@"function"]) {
        
        NSString *function = [userInfo objectForKey:@"function"];
        if ([@"share" isEqualToString:function])
        {
            //分享
            [XTShareManager shareWithDictionary:userInfo];
        }
        else if ([@"communicate" isEqualToString:function])
        {
            //沟通
            [self getPersonInfoWithDictionary:userInfo];
        }
        
    }else if ([allKeys containsObject:@"groupId"])
    {
        //沟通
        self.msgIDFromMsg = [userInfo objectForKey:@"msgId"];
        GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:[userInfo objectForKey:@"groupId"]];
        if (group != nil ) {
             [self timelineToChatWithGroup:group withMsgId:[userInfo objectForKey:@"msgId"]];
        }else
        {
            if(self.queryGroupInfoClient4 == nil)
            {
                self.queryGroupInfoClient4 = [[ContactClient alloc] initWithTarget:self action:@selector(queryGroupInfoClientMsgDidReceive:result:)];
            }
            [self.queryGroupInfoClient4 queryGroupInfoWithGroupId:[userInfo objectForKey:@"groupId"]];
        }

    }
}

- (void)getPersonInfoWithDictionary:(NSDictionary *)result
{
    NSString *personId = [result objectForKey:@"personId"];
    if (nil == personId) {
        return;
    }
    NSString *type = [result objectForKey:@"system"];
    if (nil == type || [@"xt" isEqualToString:type]) {
        //认为是讯通自身的personId，直接从数据库中查找
        PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:personId];
        if (person) {
            [self timelineToChatWithPerson:person];
        }
        return;
    }
    
    if (self.personInfoClient == nil) {
        self.personInfoClient = [[ContactClient alloc] initWithTarget:self action:@selector(personInfoDidReceived:result:)];// autorelease];
    }
    [self.personInfoClient getPersonInfoWithPersonID:personId type:type];
}

- (void)personInfoDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success) {
        PersonDataModel *person = [[PersonDataModel alloc] initWithDictionary:result.data];// autorelease];
        [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonContacts:person];
        
        [self timelineToChatWithPerson:person];
    }
}

#pragma mark - InstructionsDelegate

-(void)instructionsDidStart:(NSString *)desc
{
    if (desc == nil || [@"" isEqualToString:desc]) {
        return;
    }
    
    if (hud == nil) {
        hud = [[MBProgressHUD alloc] initWithWindow:[KDWeiboAppDelegate getAppDelegate].window];
        hud.delegate = self;
        [[KDWeiboAppDelegate getAppDelegate].window addSubview:hud];
    }
    
    hud.mode = MBProgressHUDModeText;
    hud.labelText = desc;
    hud.delegate = self;
    [hud show:YES];
}
-(void)instructionsDidStartLogout:(NSString *)desc
{
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    BOSSetting *setting = [BOSSetting sharedSetting];
    
    if (userManager.isSigned && [setting.accessToken length]>0) {
        showLogoutDesc = YES;
        if (hud == nil) {
            hud = [[MBProgressHUD alloc] initWithWindow:[KDWeiboAppDelegate getAppDelegate].window];
            hud.delegate = self;
            [[KDWeiboAppDelegate getAppDelegate].window addSubview:hud];
        }
        [[KDWeiboAppDelegate getAppDelegate].window bringSubviewToFront:hud];
        hud.labelText = [NSString stringWithFormat:ASLocalizedString(@"XTBaseLogic_hud.labelText_doing"),desc];
    }else {
        showLogoutDesc = NO;
    }
    [[KDWeiboAppDelegate getAppDelegate] signOut];
}
-(void)instructionsDidFinishLogout:(NSString *)desc
{
    if (showLogoutDesc) {
        [[KDWeiboAppDelegate getAppDelegate].window bringSubviewToFront:hud];
        hud.labelText = [NSString stringWithFormat:ASLocalizedString(@"XTBaseLogic_hud.labelText_success"),desc];
    }
}
-(void)instructionsDidStartDataErase:(NSString *)desc
{
    if (hud == nil) {
        hud = [[MBProgressHUD alloc] initWithWindow:[KDWeiboAppDelegate getAppDelegate].window];
        hud.delegate = self;
        [[KDWeiboAppDelegate getAppDelegate].window addSubview:hud];
    }
    [[KDWeiboAppDelegate getAppDelegate].window bringSubviewToFront:hud];
    //清除xt数据 add by lee
    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllData];
    //清除weibo数据 add by lee
    [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
        id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
        [statusDAO removeAllDataFromDatabase:fmdb];
        
        return nil;
        
    } completionBlock:nil];
    hud.labelText = [NSString stringWithFormat:ASLocalizedString(@"XTBaseLogic_hud.labelText_doing"),desc];
}
-(void)instructionsDidFinishDataErase:(NSString *)desc
{
    [[KDWeiboAppDelegate getAppDelegate].window bringSubviewToFront:hud];
    hud.labelText = [NSString stringWithFormat:ASLocalizedString(@"XTBaseLogic_hud.labelText_success"),desc];
}
-(void)instructionsDidStartMessageTip:(NSString *)desc
{
    if (hud == nil) {
        hud = [[MBProgressHUD alloc] initWithWindow:[KDWeiboAppDelegate getAppDelegate].window];
        hud.delegate = self;
        [[KDWeiboAppDelegate getAppDelegate].window addSubview:hud];
    }
    hud.mode = MBProgressHUDModeText;
    hud.labelText = desc;
    hud.delegate = self;
    [[KDWeiboAppDelegate getAppDelegate].window bringSubviewToFront:hud];
    [hud show:YES];
}
-(void)instructionsDidFinishMessageTip:(NSString *)desc
{
    //none
}
-(void)instructionsMessageAlert:(NSString *)desc
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:desc delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
//    [alert release];
}
-(void)instructionsDidFinish{
    [[KDWeiboAppDelegate getAppDelegate].window bringSubviewToFront:hud];
    [hud hide:YES];
}
#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud1{
    [hud removeFromSuperview];
    hud = nil;
}

#pragma mark - UI AND CONTROLLER
- (UIWindow *)window
{
    return [KDWeiboAppDelegate getAppDelegate].window;
}

-(void)openLoginViewController
{
    [XTOpenConfig sharedConfig].loginDelegate = self;
    
    UserDataModel *user =[BOSConfig sharedConfig].user;
    //如果已经登录过，则直接进入主界面
    if ([BOSConfig sharedConfig].user.token.length > 0) {
        
        [[KDManagerContext globalManagerContext].APNSManager registerForRemoteNotification];
        
        [[XTDataBaseDao sharedDatabaseDaoInstance] setOpenId:[BOSConfig sharedConfig].user.openId eId:[BOSConfig sharedConfig].user.eid];
        [[XTSetting sharedSetting] setOpenId:[BOSConfig sharedConfig].user.openId eId:[BOSConfig sharedConfig].user.eid];
        
        if (![[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:user.userId]) {
            PersonSimpleDataModel *currentPerson = [[PersonSimpleDataModel alloc] init];
            currentPerson.personId = user.userId;
            currentPerson.personName = user.name;
            currentPerson.isAdmin = user.isAdmin;
            currentPerson.photoUrl = user.photoUrl;
            currentPerson.wbUserId = user.wbUserId;
            if (user.status == 1) {
                currentPerson.status = 3;
            }else{
                currentPerson.status = user.status;
            }
            currentPerson.oid = user.oId;
            currentPerson.orgId = user.orgId;
            currentPerson.partnerType = user.partnerType;
            
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonSimple:currentPerson];
        }
        
        //add by lee 解决登录提示该用户已注销问题
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
        
        BOOL shouldShowTutorial = NO;
        if (delegate_ && [delegate_ respondsToSelector:@selector(shouldShowAppTutorialsViewController)])
            shouldShowTutorial = [delegate_ shouldShowAppTutorialsViewController];
        
        if (!shouldShowTutorial) {
            if (delegate_ && [delegate_ respondsToSelector:@selector(showMainViewController)]) {
                [delegate_ showMainViewController];
            }
        }
        if ([[KDLinkInviteConfig sharedInstance] isExistInvite]) {
            [[KDLinkInviteConfig sharedInstance] goToInviteFormType:Invite_From_Logined];
        }
        
        /*
         NSURL *url = [[KDSession globalSession] propertyForKey:UIApplicationLaunchOptionsURLKey];
         if (url != nil) {
         if (delegate_ && [delegate_ respondsToSelector:@selector(goToInvite:)]) {
         [delegate_ performSelector:@selector(goToInvite:) withObject:url ];
         }
         [[KDSession globalSession] setProperty:nil forKey:UIApplicationLaunchOptionsURLKey];
         }
         */
        return;
        
    }
    
    //if ([BOSSetting sharedSetting].userName.length > 0) {
        //打开带登录者信息的登录界面
        //KDAuthViewController *pVC = [[KDAuthViewController alloc] initWithLoginViewType:KDLoginViewTypePhoneLoginPwd] ;//autorelease];
        //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pVC];// autorelease];
        //self.window.rootViewController = nav;
        //pVC.hidePwd = [[NSUserDefaults standardUserDefaults] boolForKey:@"isHideSMSVerify"];
    //}
    //else{
        
        KDAuthViewController *pVC = [[KDAuthViewController alloc] initWithLoginViewType:KDLoginViewTypePhoneNumInput];// autorelease];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pVC];// autorelease];
        self.window.rootViewController = nav;
   // }

}
- (void)openStarLoginViewController
{
    //“开始讯通”
    KDAuthViewController *loginViewController = [[KDAuthViewController alloc] initWithLoginViewType:KDLoginViewTypePhoneNumInput];// autorelease];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController] ;//autorelease];
    self.window.rootViewController = nav;
}

#pragma mark - delegate

//- (void)loginFailed:(BOSResultDataModel *)result
//{
//}

//- (void)loginByChangeAccount
//{
//    [BOSSetting sharedSetting].bindPhoneFlag = 0;
//    [BOSSetting sharedSetting].bindEmailFlag = 0;
//    [BOSSetting sharedSetting].showAvatarFlag = 0;
//}

- (void)loginFinished:(BOSResultDataModel *)result
{
    //登录成功获取启动广告内容
    [[KDAdsManager sharedInstance] clearLocalAdsWithAdsType:KDAdsLocationType_index];
    [[KDAdsManager sharedInstance] queryAdsWithBlock:nil adsType:KDAdsLocationType_index];
    
    
    if (result != nil) {
        
        ContactLoginDataModel *loginDM = [[ContactLoginDataModel alloc] initWithDictionary:result.data];// autorelease];
        [ContactConfig sharedConfig].publicAccountList = loginDM.extraData.pubAccount;
        [[ContactConfig sharedConfig] saveConfig];
        
        [XTSetting sharedSetting].grammarId = [loginDM extraData].grammarId;
        [XTSetting sharedSetting].orgTree = [loginDM extraData].orgTree;
        [XTSetting sharedSetting].cloudpassport = [loginDM extraData].cloudpassport;
        [[XTSetting sharedSetting] saveSetting];
        
        //如果是网络搜索,登陆成功后,强制插入自己的数据到Perspn表
        if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonSimple:loginDM.extraData.user];
        }
    }
    
    //是否第一次登录
    if ([[NSUserDefaults standardUserDefaults] objectForKey:UserDefaults_FirstLogin] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UserDefaults_FirstLogin];
    }
    
    //注册PUSH服务
    [[KDManagerContext globalManagerContext].APNSManager registerForRemoteNotification];
    
    //后台异步初始化
    [[XTInitializationManager sharedInitializationManager] startInitializeCompletionBlock:nil failedBlock:nil];
    
    //add by lee 解决登录提示该用户已注销问题
    CompanyDataModel *company = nil;
    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    if (Test_Environment) {
        company = [communityManager companyByDomainName:[BOSSetting sharedSetting].cust3gNo];
        if (company == nil) {
            company = [[CompanyDataModel alloc] init] ;//autorelease];
            company.eid = [BOSConfig sharedConfig].user.eid;
            company.wbNetworkId = [BOSConfig sharedConfig].user.wbNetworkId;
        }
    }
    [communityManager connectToCompany:company];
    
    BOOL shouldShowTutorial = NO;
    if (delegate_ && [delegate_ respondsToSelector:@selector(shouldShowAppTutorialsViewController)])
        shouldShowTutorial = [delegate_ shouldShowAppTutorialsViewController];
    
    if (!shouldShowTutorial) {
        if (delegate_ && [delegate_ respondsToSelector:@selector(showMainViewController)]) {
            [delegate_ showMainViewController];
        }
    }
}



- (void)dealloc
{
    //KD_RELEASE_SAFELY(remoteNotificationInfo);
    //KD_RELEASE_SAFELY(handleOpenUrlDictionary);
    //KD_RELEASE_SAFELY(_personInfoClient);
    
    if (logoutService)
        //KD_RELEASE_SAFELY(logoutService);
    if (instructionsService)
        //KD_RELEASE_SAFELY(instructionsService);
    //    if (checkVersionService)
    //        //KD_RELEASE_SAFELY(checkVersionService);
    if (hud)
        //KD_RELEASE_SAFELY(hud);
    [_queryGroupInfoClient cancelRequest];
    [_queryGroupInfoClient2 cancelRequest];
    [_queryGroupInfoClient3 cancelRequest];
    //[super dealloc];
}

#pragma mark - timeline to chat or choose

- (void)setupTabBeforetimelineToChat
{
    if ([KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex != 0) {
        [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex = 0;
    } else {
        UINavigationController *naviController = [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController;
        if (naviController.viewControllers.count > 1) {
            [naviController popToRootViewControllerAnimated:NO];
        }
    }
}

- (void)timelineToChatWithGroup:(GroupDataModel *)group withMsgId:(NSString *)msgId
{
    [self setupTabBeforetimelineToChat];
    [[KDWeiboAppDelegate getAppDelegate].timelineViewController toChatViewControllerWithGroup:group withMsgId:msgId.length> 0 ? msgId:nil];
}

- (void)timelineToChatWithPerson:(PersonSimpleDataModel *)person
{
    [self setupTabBeforetimelineToChat];
    [[KDWeiboAppDelegate getAppDelegate].timelineViewController toChatViewControllerWithPerson:person];
}

- (void)timelineToChooseWithShareData:(XTShareDataModel *)shareData
{
    [self setupTabBeforetimelineToChat];
    [[KDWeiboAppDelegate getAppDelegate].timelineViewController toChooseViewControllerWithShareData:shareData];
}

- (void)timelineToTodoWithGroup:(GroupDataModel *)group
{
    [self setupTabBeforetimelineToChat];
    [[KDWeiboAppDelegate getAppDelegate].timelineViewController toToDoViewControllerWithGroup:group];
}

#pragma mark - contact to organization

- (void)setupTabBeforeContactToOrganization
{
    if ([KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex == 1) {
        XTContactContentViewController *contentView = (XTContactContentViewController *)((UINavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController).topViewController;
        if (contentView.searchDisplayController.active) {
            [contentView.searchDisplayController setActive:NO];
        }
    }
    
    if ([KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex != 1) {
        [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex = 1;
    } else {
        [(UINavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController popToRootViewControllerAnimated:NO];
    }
}

- (void)contactToOrganizationWithOrgId:(NSString *)orgId
{
    [self setupTabBeforeContactToOrganization];
    [[KDWeiboAppDelegate getAppDelegate].contactViewController toOrganizationViewControllerWithOrgId:orgId andPartnerType:0];
}

//从短信获取会话组详情
- (void)queryGroupInfoClientMsgDidReceive:(ContactClient *)client result:(BOSResultDataModel *)result {
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (result.success && result.data)
    {
        GroupDataModel *groupDataModel = [[GroupDataModel alloc] initWithDictionary:result.data];
        if(groupDataModel)
        {
            GroupListDataModel *groupListDataModel = [[GroupListDataModel alloc] init];
            groupListDataModel.list = [[NSMutableArray alloc] initWithObjects:groupDataModel, nil];
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePrivateGroupList:groupListDataModel];
            
            if ([KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex != 0) {
                [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex = 0;
            } else {
                UINavigationController *navController = (UINavigationController *) [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController;
                UIViewController *topViewController = navController.topViewController;
                if(topViewController.presentedViewController)
                {
                    [topViewController dismissViewControllerAnimated:NO completion:nil];
                }
                [navController  popToRootViewControllerAnimated:NO];
            }
            GroupDataModel *groupData = [groupListDataModel.list firstObject];
            [self timelineToChatWithGroup:groupData withMsgId:self.msgIDFromMsg];
        }
    }

}

//获取会话组详情
- (void)queryGroupInfoClientDidReceive:(ContactClient *)client result:(BOSResultDataModel *)result {
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (result.success && result.data)
    {
        GroupDataModel *groupDataModel = [[GroupDataModel alloc] initWithDictionary:result.data];
        if(groupDataModel)
        {
            GroupListDataModel *groupListDataModel = [[GroupListDataModel alloc] init];
            groupListDataModel.list = [[NSMutableArray alloc] initWithObjects:groupDataModel, nil];
            if (groupDataModel.dissolveDate.length == 0) {
                [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePrivateGroupList:groupListDataModel];
            }
            
            if ([KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex != 0) {
                [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex = 0;
            } else {
                UINavigationController *navController = (UINavigationController *) [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController;
                UIViewController *topViewController = navController.topViewController;
                if(topViewController.presentedViewController)
                {
                    [topViewController dismissViewControllerAnimated:NO completion:nil];
                }
                [navController  popToRootViewControllerAnimated:NO];
            }
            [[KDWeiboAppDelegate getAppDelegate].timelineViewController showMultiCallViewWithGroupDataModel:groupDataModel];
        }
    }
}

- (void)queryGroupInfoClientDidReceive2:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (result.success && result.data)
    {
        GroupDataModel *groupDataModel = [[GroupDataModel alloc] initWithDictionary:result.data];
        if(groupDataModel)
        {
            GroupListDataModel *groupListDataModel = [[GroupListDataModel alloc] init];
            groupListDataModel.list = [[NSMutableArray alloc] initWithObjects:groupDataModel, nil];
            if (groupDataModel.dissolveDate.length == 0) {
                [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePrivateGroupList:groupListDataModel];
            }
            
            BOOL isAddByTabBarControllerFlag = YES;
            UIViewController *topViewController = ((RTRootNavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController).topViewController;
            while (topViewController.presentedViewController)
            {
                if(isAddByTabBarControllerFlag)
                {
                    isAddByTabBarControllerFlag = NO;
                }
                topViewController = topViewController.presentedViewController;
            }
            if([topViewController isKindOfClass:[RTRootNavigationController class]])
            {
                topViewController = ((RTRootNavigationController *)topViewController).topViewController;
            }

            //清除跨圈语音推送
            self.remoteNotificationInfoCall = nil;
            
            [self showMultiCallViewWithGroupDataModel:groupDataModel viewController:topViewController isTabBarControllerAdd:isAddByTabBarControllerFlag];
        }
    }
    
}

static char showMultiCalViewKey;
- (void)showMultiCallViewWithGroupDataModel:(GroupDataModel *)groupDataModel viewController:(UIViewController *)viewController isTabBarControllerAdd:(BOOL)flag
{
    __weak UIViewController *weakSelf = viewController;
    __weak XTBaseLogic *weakBlockSelf = self;
    
    __block  KDAgoraCallView *agoraCallView = [[KDAgoraCallView alloc] initWithFrame:flag? weakSelf.tabBarController.view.bounds:CGRectMake(0, 64, viewController.navigationController.view.frame.size.width, viewController.navigationController.view.frame.size.height)];
    agoraCallView.tag = KDAgoraCallViewTag;
    [agoraCallView setGroupDataModel:groupDataModel];
    agoraCallView.agoraCallViewBlock = ^(agoraCallViewOperationType type){
        if(type == agoraCallViewOperationType_answer)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AgoraCallViewAnswer" object:nil];
            if(!weakBlockSelf.queryGroupInfoClient3)
            {
                weakBlockSelf.queryGroupInfoClient3 = [[ContactClient alloc] initWithTarget:self action:@selector(queryGroupInfoClientDidReceive3:result:)];
            }
            objc_setAssociatedObject(weakBlockSelf.queryGroupInfoClient3, &showMultiCalViewKey,
                                     weakSelf,
                                     OBJC_ASSOCIATION_RETAIN);
            [weakBlockSelf.queryGroupInfoClient3 queryGroupInfoWithGroupId:groupDataModel.groupId];
        }else{
            objc_setAssociatedObject(weakBlockSelf.queryGroupInfoClient3, &showMultiCalViewKey, nil, OBJC_ASSOCIATION_RETAIN);
        }
        [agoraCallView removeFromSuperview];
        agoraCallView = nil;
    };
    if(flag)
    {
        [weakSelf.tabBarController.view addSubview:agoraCallView];
    }else{
        if(![viewController.navigationController.view viewWithTag:KDAgoraCallViewTag])
        {
            [viewController.navigationController.view addSubview:agoraCallView];
        }
    }
}

- (void)queryGroupInfoClientDidReceive3:(ContactClient *)client result:(BOSResultDataModel *)result
{
    UIViewController *resultController = (UIViewController *)objc_getAssociatedObject(self.queryGroupInfoClient3, &showMultiCalViewKey);
    
    objc_setAssociatedObject(self.queryGroupInfoClient3, &showMultiCalViewKey, nil, OBJC_ASSOCIATION_RETAIN);
    
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (result.success && result.data)
    {
        GroupDataModel *groupDataModel = [[GroupDataModel alloc] initWithDictionary:result.data];
        if(groupDataModel)
        {
            GroupListDataModel *groupListDataModel = [[GroupListDataModel alloc] init];
            groupListDataModel.list = [[NSMutableArray alloc] initWithObjects:groupDataModel, nil];
            if (groupDataModel.dissolveDate.length == 0) {
                [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePrivateGroupList:groupListDataModel];
            }
            
            if(groupDataModel && groupDataModel.mCallStatus == 1)
            {
                [[KDAgoraSDKManager sharedAgoraSDKManager] goToMultiVoiceWithGroup:groupDataModel viewController:resultController];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"XTBaseLogic_alert_msg")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
                [alert show];
            }
        }
    }
    
}
@end
