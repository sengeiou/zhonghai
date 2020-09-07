//
//  KDApplicationOpenHelper.m
//  kdweibo
//
//  Created by sevli on 15/10/28.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDApplicationOpenHelper.h"
//#import "KDSchema.h"
#import "NSString+Scheme.h"
#import "KDApplicationQueryAppsHelper.h"
//#import "KDApplicationCommon.h"
//#import "KDShareRepeatClient.h"
#import "KDPublicAccountCache.h"
#import "KDPubAcctFetch.h"

#import "KDTodoListViewController.h"
#import "KDSignInViewController.h"
#import "KDSignInManager.h"
#import "XTChatViewController.h"
#import "KDApplicationViewController.h"
#import "KDWebViewController.h"


//#import "KDAppOpen.h"
#import "KDLocalNotificationManager.h"
#import "BOSConfig.h"
#import "KDQuery.h"
#import "UINavigationController+JZExtension.h"
#import "NSString+Operate.h"
#import "Reachability.h"


NSString * const KDApplicationOpenTypeChat = @"chat";

NSString * const KDApplicationOpenTypeApplication = @"application";

@implementation KDApplicationOpenHelper

+ (void)goToAppWithAppDataModel:(KDAppDataModel *)appDM Controller:(UIViewController *)controller
{
    if ([appDM.appName isKindOfClass:[NSString class]] && appDM.appName.length > 0) {
        [KDEventAnalysis event:event_app_open attributes:@{label_app_open_name : appDM.appName}];
    }
    else {
        [KDEventAnalysis event:event_app_open];
    }
    [[KDApplicationQueryAppsHelper shareHelper] makeNoteWhenAppClickedWithAppDataModel:appDM];
    switch (appDM.appType)
    {
        case KDAppTypeNativeKingdee:
        {
            [self openNativeKingdeeApp:appDM Controller:controller];
        }
            break;
        case KDAppTypeLight:
        {
            [self openLightApp:appDM Controller:controller];
        }
            break;
        case KDAppTypeWeb:
        {
            [self openLightApp:appDM Controller:controller];
        }
            break;
        case KDAppTypePublic:
        {
            [self openPublicApp:appDM Controller:controller];
        }
            break;
        case KDAppTypeNativeThirdPart:
        {
            //第三方应用跳转
            if (appDM.appClientSchema.length > 0)
            {
                [self openNativeThirdPartAppWithAppDM:appDM Controller:controller];
            }
        }
            break;
        default:
            break;
    }
}

//轻应用
+ (void)openLightApp:(KDAppDataModel *)appDM Controller:(UIViewController *)controller
{
    //appID 与 appClientID的关系是 去掉后两位，因为本地库没有appID字段的临时做法。
    //NSString * appID = [NSString stringWithFormat:@"%.0f",appDM.appClientID / 100];
    
    NSString *appID = appDM.appID;
    if (appID.length == 0)
    {
        return;
    }
    
    BOOL newUserGuide = NO;
    newUserGuide = [self judgeCurrentUserIsNewUserWithAppDM:appDM];
    
    if (newUserGuide == NO) {
        KDWebViewController *applightWebVC = [[KDWebViewController alloc] initWithUrlString:@"" appId:appID];
        applightWebVC.title = appDM.appName;
        applightWebVC.hidesBottomBarWhenPushed = YES;
        __weak __typeof(applightWebVC) weak_webvc = applightWebVC;
        __weak __typeof(controller) weak_controller = controller;
        applightWebVC.getLightAppBlock = ^() {
            if(weak_webvc && !weak_webvc.bPushed){
                [weak_controller.navigationController pushViewController:weak_webvc animated:YES];
            }
        };
    }
    else {
        [self toNewUserGuideWithAppDM:appDM controller:controller];
    }
    
}


//公共号
+ (void)openPublicApp:(KDAppDataModel *)appDM Controller:(UIViewController *)controller
{
    if (!appDM.pid || [appDM.pid length] == 0) {
        return;
    }
    KDPublicAccountDataModel *person = [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:appDM.pid];
    if (person) {
        [self openFileTrans:person Controller:controller];
        return;
    }
    [MBProgressHUD showHUDAddedTo:[KDWeiboAppDelegate getAppDelegate].window animated:YES].labelText = @"加载资源...";
    KDPubAcctFetch *fetcher = [[KDPubAcctFetch alloc] init];
    [fetcher fetchWithPubAcctIds:@[appDM.pid] completionBlock:^(BOOL success, NSArray *pubAccts) {
        
        [MBProgressHUD hideAllHUDsForView:[KDWeiboAppDelegate getAppDelegate].window animated:YES];
        if (success && [pubAccts count] > 0)
        {
            [self openFileTrans:[pubAccts firstObject] Controller:controller];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"网络有问题，请检测网络连接。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

/*
 *  打开本地应用
 *
 */
+ (void)openNativeKingdeeApp:(KDAppDataModel *)appDataModel Controller:(UIViewController *)controller
{
    if ([appDataModel.appID isEqualToString:kQRScanAppId])
    {
        //扫一扫
        [self qrScan:controller];
    }
    else if([appDataModel.appID isEqualToString:kFileTransAppId])
    {
        //我的文件
        [KDEventAnalysis event:event_app_myfile];
        //文档助手打开次数
        [KDEventAnalysis event:event_app_dochelper_open];
        XTMyFilesViewController *ctr = [[XTMyFilesViewController alloc] init];
        ctr.fromType = 1;
        ctr.hidesBottomBarWhenPushed = YES;
        [controller.navigationController pushViewController:ctr animated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"APP_MAIN_DOC_New_FEATURE"];
    }
    else if([appDataModel.appID isEqualToString:kBuluoAppId])
    {
        //部落
        NSInteger count = [self buluoUnreadCount];
        NSURL *url = [NSString schemaUrlForYZJWithPath:KDSchemaPathStart params:@{@"count" : @(count)}];
        [KDAppOpen openURL:url controller:controller];
        
        //点击后清除标识
        [KDShareRepeatClient sharedClient].statusCount = 0;
        [KDShareRepeatClient sharedClient].inboxCount = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:kShareMsgCountNofitication object:nil];
    }
    else if ([appDataModel.appID isEqualToString:kTodoAppId]) //任务
    {
        UIViewController *viewController = [[KDTodoListViewController alloc] init];
        viewController.navigationBarBackgroundHidden = NO;
        [KDEventAnalysis event:event_app_tasks_open];
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.navigationBarBackgroundHidden =  YES;
        [controller.navigationController pushViewController:viewController animated:YES];
    }
    else if([appDataModel.appID isEqualToString:kSignAppId]) //签到
    {
        BOOL newUserGuide = NO;
        newUserGuide = [self judgeCurrentUserIsNewUserWithAppDM:appDataModel];
        
        if (newUserGuide == NO) {
            UIViewController *destinationController = [[KDSignInViewController alloc] init];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (![[KDLocalNotificationManager globalManager] isManagerFirstClickedSignIn] && [BOSConfig sharedConfig].user.isAdmin) {
                    [[KDLocalNotificationManager globalManager] setIsManagerFirstClickedSignIn:YES];
                    [self pushmMsgWithSource:@"funcIntro" type:1];
                }
            });
            
            [KDEventAnalysis event:event_app_signin_open];
            if (![KDSignInManager isSignInIconClicked]) {
                [KDSignInManager setIsSignInIconClicked:YES];
            }
            destinationController.hidesBottomBarWhenPushed = YES;
            destinationController.navigationBarBackgroundHidden = YES;
            [controller.navigationController pushViewController:destinationController animated:YES];
        }
        else {
            [self toNewUserGuideWithAppDM:appDataModel controller:controller];
        }
    }
    
}

//第三方应用
+ (void)openNativeThirdPartAppWithAppDM:(KDAppDataModel *)appDM Controller:(UIViewController *)currentController
{
    KDSchemeHostType t = [KDSchema openWithUrl:appDM.appClientSchema controller:currentController];
    
    if (t == KDSchemeHostType_HTTP || t == KDSchemeHostType_HTTPS || t == KDSchemeHostType_NONE || t == KDSchemeHostType_NOTURI || t == KDSchemeHostType_Unknow)
    {
        NSString *appSchema = [self getAppSchemaWithAppDataModel:appDM];
        
        if (!appSchema || [appSchema isKindOfClass:[NSNull class]] || appSchema.length == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提醒" message:@"该应用跳转链接不正确，请尝试其他应用。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        NSURL *url = [NSURL URLWithString:appSchema];
        if (!isAboveiOS9)//iOS9以下版本
        {
            if ([[UIApplication sharedApplication] canOpenURL:url]){
                [[UIApplication sharedApplication] openURL:url];
            }
            else
                [self downloadAppWithAppDataModel:appDM];
        }
        else //iOS9
        {
            BOOL canOpenUrl = [[UIApplication sharedApplication] openURL:url];
            if (!canOpenUrl) {
                [self downloadAppWithAppDataModel:appDM];
                
            }
        }
    }
}


+ (NSString *)getAppSchemaWithAppDataModel:(KDAppDataModel *)appDM
{
    NSString *appSchema = nil;
    
    if (isAboveiOS9){
        
        if (appDM.ios9Schema.length > 0){
            
            appSchema = appDM.ios9Schema;
        }
        else{
            appSchema = appDM.appClientSchema;
        }
    }
    else{
        appSchema = appDM.appClientSchema;
    }
    
    NSRange findRange = [appSchema rangeOfString:@"p?"];
    if (findRange.length)
    {
        appSchema = [appSchema substringToIndex:findRange.location];
    }
    
    return appSchema;
}

+ (void)downloadAppWithAppDataModel:(KDAppDataModel *)appDM
{
    if (appDM.downloadURL && ![appDM.downloadURL isEqual:@""]) {
        NSRange findRange = [appDM.downloadURL rangeOfString:@"itunes.apple.com"];
        if (findRange.length) {
            KDAppDownLoadAlertManager *alertManager = [KDAppDownLoadAlertManager sharedManager];
            alertManager.downLoadUrl = appDM.downloadURL;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"尚未安装该应用，你确定要安装吗？" delegate:alertManager cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提醒" message:@"该应用下载链接不正确，请尝试其他应用。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提醒" message:@"该应用尚未上架，请尝试其他应用。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}


//二维码
+ (void)qrScan:(UIViewController *)controller
{
    //获取对摄像头的访问权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"没有使用摄像头的权限，请在设备的“设置-隐私-相机”里面修改" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [KDEventAnalysis event:event_scan_open attributes:@{label_scan_open : label_scan_open_application}];
    
    XTQRScanViewController *qrScanController = [[XTQRScanViewController alloc] init];
    qrScanController.controller = controller;
    UINavigationController *qrScanNavController = [[UINavigationController alloc] initWithRootViewController:qrScanController];
    qrScanNavController.delegate = [KDNavigationManager sharedNavigationManager];
    [controller presentViewController:qrScanNavController animated:YES completion:nil];
}

//文件
+ (void)openFileTrans:(PersonSimpleDataModel *)ps Controller:(UIViewController *)controller
{
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:ps];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [controller.navigationController pushViewController:chatViewController animated:YES];
}

+ (BOOL)isApplicationViewController
{
    if ([[self currentViewController] isKindOfClass:[KDApplicationViewController class]])
    {
        return YES;
    }
    return NO;
}

+ (UIViewController *)currentViewController
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}




+ (NSInteger)buluoUnreadCount
{
    NSInteger inbox = [KDShareRepeatClient sharedClient].inboxCount;
    NSInteger unreadCount = 0;
    if (inbox > 0) {
        unreadCount = unreadCount;
    }
    else {
        unreadCount = 0;
    }
    return unreadCount;
}

//判断是否符合新用户引导
+ (BOOL)judgeCurrentUserIsNewUserWithAppDM:(KDAppDataModel *)appMd {
    BOOL newUserGuide = NO;
    if ([[BOSConfig sharedConfig].user isAdmin]) {
        NSInteger persons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryAllContactPersonsCount];
        NSString *urlString = appMd.detailURL;
        
        if (persons <= [[BOSSetting sharedSetting] getLightAppControlNumber] && urlString && ![urlString isEqualToString:@""]) {
            newUserGuide = YES;
        }
    }
    return newUserGuide;
}

//跳转到新用户引导
+ (void)toNewUserGuideWithAppDM:(KDAppDataModel *)appMd controller:(UIViewController *)controller{
    NSString *urlString = appMd.detailURL;
    if (urlString && ![urlString isEqualToString:@""]) {
        
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        KDWebViewController *applightWebVC = [[KDWebViewController alloc] initWithUrlString:urlString];
        applightWebVC.hidesBottomBarWhenPushed = YES;
        applightWebVC.adminNewUserGuidePage = YES;
        
        if (appMd.appType == KDAppTypeNativeKingdee) {
            if ([appMd.appID isEqualToString:kSignAppId] || [appMd.appID isEqualToString:kTodoAppId]) {
                //本地签到应用 或 任务应用
                applightWebVC.color4NavBg = @"#43BBFC";
                applightWebVC.color4processBg = @"#46E7FF";
            }
            else if ([appMd.appID isEqualToString:kFileTransAppId]) {
                //本地文件应用
                applightWebVC.color4NavBg = [NSString hexStringWithColor:[UIColor kdNavYellowColor]];
                applightWebVC.color4processBg = @"#FFDE58";
            }
            
            applightWebVC.navigationBarBackgroundHidden = YES;
            [controller.navigationController pushViewController:applightWebVC animated:YES];
        }
        
        else {
            __weak __typeof(applightWebVC) weak_webvc = applightWebVC;
            __weak __typeof(controller) weak_controller = controller;
            [applightWebVC setGetLightAppBlock:^{
                if(weak_webvc && !weak_webvc.bPushed){
                    [weak_controller.navigationController pushViewController:weak_webvc animated:YES];
                }
            } appId:appMd.appID url:appMd.webURL];
            
        }
    }
    
}



#pragma mark - 推送公共号消息
+ (void)pushmMsgWithSource:(NSString *)source type:(NSInteger)type {
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
    };
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"oid" stringValue:[BOSConfig sharedConfig].user.oId];
    [query setParameter:@"from" stringValue:source];
    [query setParameter:@"type" integerValue:type];
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/signId/:pushmMsg" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

+ (void)EventAnalysisForApp:(NSString *)appId
{
    if ([appId isEqualToString:kReportAppId])//工作汇报
    {
        [KDEventAnalysis event:event_app_open_report];
    }
    
    if ([appId isEqualToString:kTodoAppId])//任务
    {
        [KDEventAnalysis event:event_app_open_task];
    }
    
    if ([appId isEqualToString:kAnnouncementAppId])//公告
    {
        [KDEventAnalysis event:event_app_open_announcement];
    }
    
    if ([appId isEqualToString:kLeaveAppId])//请假
    {
        [KDEventAnalysis event:event_app_open_leave];
    }
    
    if ([appId isEqualToString:kApprovalId])//审批
    {
        [KDEventAnalysis event:event_app_open_approval];
    }
    
    if ([appId isEqualToString:kTalkmeeting])//语音会议
    {
        [KDEventAnalysis event:event_app_open_talkmeeting];
    }
}



#pragma mark -
+ (void)resetApplicationViewControllerNavigationBar
{
    if ([[(UINavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController topViewController] isKindOfClass:[KDApplicationViewController class]])
    {
        UIViewController *applicationViewController = [(UINavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController topViewController];
        [applicationViewController.navigationController.navigationBar lwb_setBackgroundImage:@"nav_bg"];
        applicationViewController.navigationBarBackgroundHidden = NO;
    }
}


#pragma mark - 打开/添加 应用逻辑
+ (void)operateApplication:(KDAppDataModel *)appDM controller:(UIViewController *)controller addComplete:(void (^)())addComplete {
    if ([self hasFavorite:appDM])
    {
        [self goToAppWithAppDataModel:appDM Controller:controller];
        [self EventAnalysisForApp:appDM.appID];
    }
    else
    {
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        if (reach.isReachable) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AddApp" object:nil userInfo:[NSDictionary dictionaryWithObject:appDM forKey:@"appDM"]];
        } else {
            [self storeAppToBeDeletedIntoUserDefault:appDM];
        }
        
        if(addComplete) {
            addComplete();
        }        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:appDM, @"appDM", nil];
        NSNotification *notification = [NSNotification notificationWithName:@"Personal_App_Add" object:nil userInfo:dic];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}



+ (BOOL)hasFavorite:(KDAppDataModel *)appDM {
    if (appDM == nil) return NO;
    BOOL hasFavorite = NO;
    NSArray *tempArr = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonalAppList];
    if (appDM.appType == KDAppTypePublic) {
        for (KDAppDataModel *appDataModel in tempArr) {
            if ([appDM.pid isEqualToString:appDataModel.pid]) {
                return YES;
            }
        }
    }
    else {
        for (KDAppDataModel *appDataModel in tempArr) {
            if ([appDM.appID isEqualToString:appDataModel.appID] || [appDM.appClientID isEqualToString:appDataModel.appClientID]) {
                return YES;
            }
        }
    }
    return hasFavorite;
}

+ (void)storeAppToBeDeletedIntoUserDefault:(KDAppDataModel *)appDM {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tempMutableArray;
    NSArray *tempArray;
    
    tempArray = [ud objectForKey:@"NetWorkNotReachable"];
    
    if (tempArray == nil || tempArray == 0) {
        
        //如果按NewWordNotReachable找不到值，创建一个数组加入当前appId
        tempMutableArray = [NSMutableArray array];
        
        if (appDM.appClientID != nil) {
            long appid = [appDM.appClientID longLongValue] / 100;
            [tempMutableArray addObject:[NSString stringWithFormat:@"%ld", appid]];
        }
        
        if (appDM.pid != nil) {
            [tempMutableArray addObject:appDM.pid];
        }
        
    } else {
        
        //如果NSUserDefaults已经有这个被删除的应用直接return
        for (int i = 0; i < tempArray.count; i++) {
            NSString *tempString = tempArray[i];
            
            if (appDM.appClientID != nil) {
                NSString *appid = [NSString stringWithFormat:@"%ld", (long)[appDM.appClientID longLongValue] / 100];
                if ([tempString isEqualToString:appid]) {
                    return;
                }
            }
            if (appDM.pid != nil) {
                if ([tempString isEqualToString:appDM.appID]) {
                    return;
                }
            }
        }
        
        tempMutableArray = [NSMutableArray arrayWithArray:tempArray];
        
        if (appDM.appClientID != nil) {
            NSString *appid = [NSString stringWithFormat:@"%ld", (long)[appDM.appClientID longLongValue] / 100];
            [tempMutableArray addObject:appid];
        }
        
        if (appDM.pid != nil) {
            [tempMutableArray addObject:appDM.pid];
        }
        
    }
    
    tempArray = [NSArray arrayWithArray:tempMutableArray];
    
    [ud setObject:tempArray forKey:@"NetWorkNotReachable"];
    [ud synchronize];
}

@end



@implementation KDAppDownLoadAlertManager

+ (id)sharedManager
{
    static dispatch_once_t onceToken = 0;
    static KDAppDownLoadAlertManager *instance = nil;
    
    dispatch_once(&onceToken, ^{
        instance = [[KDAppDownLoadAlertManager alloc] init];
    });
    
    return instance;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.downLoadUrl]];
    }
}

@end




