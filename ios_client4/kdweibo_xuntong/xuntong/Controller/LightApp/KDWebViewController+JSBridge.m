//
//  KDWebViewController+JSBridge.m
//  kdweibo
//
//  Created by Gil on 14-10-20.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDWebViewController+JSBridge.h"
#import "BOSConfig.h"
#import "KDLinkInviteConfig.h"
#import "XTShareManager.h"
#import "XTPersonDetailViewController.h"
#import "XTChooseContentViewController.h"
#import "NSDictionary+Additions.h"
#import "KDSheet.h"
#import "NSData+Base64.h"
#import "KDSignInViewController.h"
#import "KDInviteColleaguesViewController.h"
#import "XTFileDetailViewController.h"
#import "FileModel.h"
#import "KDChooseOrganizationViewController.h"
#import "XTOrgTreeDataModel.h"
#import "XTQRLoginViewController.h"
#import "XTSetting.h"

#import "KDWeiboAppDelegate.h"
#import "KDLocationView.h"
#import "KDLocationOptionViewController.h"
#import "KDLocationManager.h"
#import "KDLocationData.h"

#include <objc/runtime.h>
#import "KDApplicationViewController.h"
#import "KDWebViewController+JSCreatePop.h"
#import "KDJSBridgeTask.h"
//#import "KDChooseConfigModel.h"
//#import "KDChooseManager.h"
#import "XTShareView.h"

#import "NSObject+KDSafeObject.h"
#import "KDSignatureViewController.h"
#import "UIImage+fixOrientation.h"
#import "KDSignInFeedbackViewController.h"
#import "KDCustomAudioManager.h"
#import "KDFileDownloadManager.h"
#import "KDSignInLocationManager+Alert.h"
#import "URL+MCloud.h"

//A.wang js桥createGroupByPhone
#import "ContactClient.h"
#import "XTForwardDataModel.h"

#define Success @"success"
#define ErrorMessage @"error"
#define ErrorCode @"errorCode"
#define Data @"data"

#define JS_GetAdminOpenId	@"getAdminOpenId"
#define JS_GetHealthData	@"getHealthData"
#define JS_PreviewImage     @"previewImage"
#define JS_Defback          @"defback"
#define JS_AppRevision           @"iAppRevision"

static NSDictionary *lightAppProperty = nil;
static NSArray *socialShareWays = nil;

@interface KDWebViewController () <XTChooseContentViewControllerDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,XTMyFilesViewControllerJSBridgeDelegate,KDChooseOrganizationViewControllerJSBridgeDelegate,XTQRScanViewControllerDelegate,XTQRScanViewControllerJSBridgeDelegate,KDLocationOptionViewControllerDelegate,MJPhotoBrowserDelegate,XTShareViewDelegate,KDSignatureViewControllerDelegate,KDChooseDepartmentViewControllerDelegate,UIDocumentPickerDelegate>

@property (nonatomic, assign) int callbackId;
@property (nonatomic, strong) NSString *appUrl;
@property (nonatomic, strong) KDUserHelper *userHelper;
@property (nonatomic, assign) BOOL selectPictureNotAllowEdit;//fetchAvatar->AllowEdit->NO, selectPic->NotAllow->YES

@property (nonatomic, strong) NSArray *locationDataArray;
@property (nonatomic, strong) KDLocationData *currentLocationData;
@property (nonatomic, strong) KDLocationView *locationView;

@property (strong, nonatomic) NSMutableDictionary *callbackIds;
@property (nonatomic, assign) int personInfoCallbackId;

@property (nonatomic, assign) BOOL bGoMultiVoiceAfterCreateGroup;

@property (nonatomic, strong) NSString *imageFunc;//图片相关的方法（fetchAvatar、selectPic）

//A.wang js桥createGroupByPhone
@property (nonatomic, strong) ContactClient *createChatClient;


@property (nonatomic, strong) XTForwardDataModel *forwardDM;

@property (nonatomic, strong) MBProgressHUD *progressHud;
@property (nonatomic, strong) NSDictionary *news;
@property (nonatomic, strong) NSString *groupName;
@end

@implementation KDWebViewController (JSBridge)

//A.wang js桥createGroupByPhone
- (void)getPersonsIdsDidRecieve:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        return;
    }
    
    if (result.data && result.success) {
        NSArray *resultPersons = result.data;
        NSMutableArray *persons = [NSMutableArray array];
        NSMutableArray *personIds = [NSMutableArray array];
        for (NSDictionary *personDic in resultPersons) {
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:personDic];
            [persons addObject:person];
            [personIds addObject:person.personId];
        }
        if(persons.count>0){
            if(self.news.count>0){
                PersonSimpleDataModel *person = [persons firstObject];
                NSString *photoUrl = @"";
                if(photoUrl.length == 0)
                    photoUrl = person.photoUrl;
                if(photoUrl.length == 0)
                    photoUrl = [NSString stringWithFormat:@"%@pubacc/public/images/default_public.png",MCLOUD_IP_FOR_PUBACC];
                NSDictionary *dic = @{@"shareType" : @(3),
                                      @"appName" : [self.news objectForKey:@"appName"],
                                      @"title" : [self.news objectForKey:@"title"],
                                      @"content" :[[self.news objectForKey:@"content"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]],
                                      @"thumbUrl" : photoUrl,
                                      @"webpageUrl" : [self.news objectForKey:@"webpageUrl"]};
                if(((NSString *)[self.news objectForKey:@"appId"]).length != 0)
                {
                    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [tempDic setObject:[self.news objectForKey:@"appId"] forKey:@"appId"];
                    dic = tempDic;
                }
                
                MessageShareNewsDataModel *shareData = [[MessageShareNewsDataModel alloc] initWithDictionary:dic];
                
                MessageParamDataModel *param = [[MessageParamDataModel alloc] init];
                param.type = MessageTypeShareNews;
                param.paramObject = shareData;
                param.paramString = [NSJSONSerialization stringWithJSONObject:dic];
                
                self.forwardDM = [[XTForwardDataModel alloc] initWithDictionary:nil];
                self.forwardDM.forwardType = ForwardMessageShareNews;
                self.forwardDM.title = [self.news objectForKey:@"title"];
                self.forwardDM.contentString = [[self.news objectForKey:@"content"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
                self.forwardDM.paramObject = param;
                
                
            }
            
            if (self.createGroupChatClient == nil) {
                self.createGroupChatClient = [[ContactClient alloc] initWithTarget:self action:@selector(createGroupChatDidReceived:result:)];
            }
             
                //self.progressHud.labelText = ASLocalizedString(@"正在创建群组...");
                //self.progressHud.mode = MBProgressHUDModeIndeterminate;
                //self.progressHud.margin = 20;
                //self.progressHud.dimBackground = NO;
                //[self.progressHud show:YES];
           
            // 需要修改的地方
            [self.createGroupChatClient creatGroupWithUserIds:personIds groupName:self.groupName];
           
           
            
            
            //NSDictionary *personDic = [persons firstObject];
           // PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:personDic];
            //if (person) {
                //XTChatViewController *chatVC = [[XTChatViewController alloc] initWithParticipant:person];
                //chatVC.hidesBottomBarWhenPushed = YES;
                //[self.navigationController pushViewController:chatVC animated:YES];
           // }
        }else {
             //需要修改的地方
            //[self.progressHud setLabelText:ASLocalizedString(@"无法找到员工")];
            //[self.progressHud setMode:MBProgressHUDModeText];
            //self.progressHud.margin = 20;
            //self.progressHud.dimBackground = NO;
            //[self.progressHud hide:YES afterDelay:1.0];
            return;
        }
    }
}

- (void)createGroupChatDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        if (result.error.length > 0) {
            [self.progressHud setLabelText:result.error];
        }
        else
        {
            [self.progressHud setLabelText:ASLocalizedString(@"创建失败")];
        }
        [self.progressHud setMode:MBProgressHUDModeText];
        self.progressHud.margin = 20;
        self.progressHud.dimBackground = NO;
        [self.progressHud hide:YES afterDelay:1.0];
        
        return;
    }
    
    GroupDataModel *groupDM = [[GroupDataModel alloc] initWithDictionary:result.data];
    groupDM.isNewGroup = YES;
    
    //[self.progressHud removeFromSuperview];
    //self.progressHud = nil;
    
    //拼接一个grouplist 用于会话组查询参与人ID 706
    //GroupListDataModel *groupList = [[GroupListDataModel alloc]init];
    //groupList.list = [[NSMutableArray alloc] initWithArray:@[groupDM]];
    //[[XTDataBaseDao sharedDatabaseDaoInstance]insertUpdatePrivateGroupList:groupList];
    
    //[self setupTabBeforetimelineToChat];
    
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:groupDM pubAccount:nil mode:ChatPrivateMode];
    chatViewController.isForward = YES;
    chatViewController.forwardDM = self.forwardDM;
    chatViewController.hidesBottomBarWhenPushed = YES;
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:chatViewController animated:YES];
    //});
    //[[KDWeiboAppDelegate getAppDelegate].timelineViewController toChatViewControllerWithGroup:groupDM withMsgId:nil];
    
}

#pragma mark - property
-(BOOL)selectPictureNotAllowEdit {
    return [objc_getAssociatedObject(self, @selector(selectPictureNotAllowEdit)) boolValue];
}

-(void)setSelectPictureNotAllowEdit:(BOOL)selectPictureNotAllowEdit {
    objc_setAssociatedObject(self, @selector(selectPictureNotAllowEdit), [NSNumber numberWithBool:selectPictureNotAllowEdit], OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)bGoMultiVoiceAfterCreateGroup {
    return [objc_getAssociatedObject(self, @selector(bGoMultiVoiceAfterCreateGroup)) boolValue];
}

-(void)setBGoMultiVoiceAfterCreateGroup:(BOOL)bGoMultiVoiceAfterCreateGroup {
    objc_setAssociatedObject(self, @selector(bGoMultiVoiceAfterCreateGroup), [NSNumber numberWithBool:bGoMultiVoiceAfterCreateGroup], OBJC_ASSOCIATION_ASSIGN);
}

- (int)callbackId {
    return [objc_getAssociatedObject(self, @selector(callbackId)) intValue];
}

- (void)setCallbackId:(int)callbackId {
    objc_setAssociatedObject(self, @selector(callbackId), [NSNumber numberWithInt:callbackId], OBJC_ASSOCIATION_ASSIGN);
}

- (int)personInfoCallbackId {
    return [objc_getAssociatedObject(self, @selector(personInfoCallbackId)) intValue];
}


- (void)setPersonInfoCallbackId:(int)personInfoCallbackId {
    objc_setAssociatedObject(self, @selector(personInfoCallbackId), [NSNumber numberWithInt:personInfoCallbackId], OBJC_ASSOCIATION_ASSIGN);
}
//回调ids
- (NSMutableDictionary *)callbackIds {
    return objc_getAssociatedObject(self, @selector(callbackIds));
}

- (void)setCallbackIds:(NSMutableDictionary *)callbackIds {
    objc_setAssociatedObject(self, @selector(callbackIds), callbackIds, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)appUrl {
    return objc_getAssociatedObject(self, @selector(appUrl));
}

- (void)setAppUrl:(NSString *)appUrl {
    objc_setAssociatedObject(self, @selector(appUrl), appUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)groupName {
    return objc_getAssociatedObject(self, @selector(groupName));
}

- (void)setGroupName:(NSString *)groupName {
    objc_setAssociatedObject(self, @selector(groupName), groupName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KDUserHelper *)userHelper {
    return objc_getAssociatedObject(self, @selector(userHelper));
}

- (void)setUserHelper:(KDUserHelper *)userHelper {
    objc_setAssociatedObject(self, @selector(userHelper), userHelper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSArray *)locationDataArray {
    return objc_getAssociatedObject(self,@selector(locationDataArray));
}

- (void)setLocationDataArray:(NSArray *)locationDataArray{
    objc_setAssociatedObject(self, @selector(locationDataArray), locationDataArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)news {
    return objc_getAssociatedObject(self,@selector(news));
}

- (void)setNews:(NSDictionary *)news{
    objc_setAssociatedObject(self, @selector(news), news, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (KDLocationData *)currentLocationData {
    return objc_getAssociatedObject(self,@selector(currentLocationData));
}

- (void)setCurrentLocationData:(KDLocationData *)currentLocationData{
    objc_setAssociatedObject(self, @selector(currentLocationData), currentLocationData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XTForwardDataModel *)forwardDM {
    return objc_getAssociatedObject(self,@selector(forwardDM));
}

- (void)setForwardDM:(XTForwardDataModel *)forwardDM{
    objc_setAssociatedObject(self, @selector(forwardDM), forwardDM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)setLocationView:(KDLocationView *)locationView
{
    objc_setAssociatedObject(self, @selector(locationView), locationView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



-(KDLocationView *)locationView
{
    return objc_getAssociatedObject(self,@selector(locationView));
    
}
- (NSString *)imageFunc {
    return objc_getAssociatedObject(self, @selector(imageFunc));
}

- (void)setImageFunc:(NSString *)imageFunc {
    objc_setAssociatedObject(self, @selector(imageFunc), imageFunc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ContactClient *)createChatClient {
    return objc_getAssociatedObject(self, @selector(createChatClient));
}

- (void)setCreateChatClient:(ContactClient *)createChatClient {
    objc_setAssociatedObject(self, @selector(createChatClient), createChatClient, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - js bridge

- (void)executeJSBridge:(NSString *)url {
    NSArray *components = [url componentsSeparatedByString:@":"];
    if ([components count] >= 4) {
        //功能
        NSString *function = (NSString *)[components objectAtIndex:1];
        //回调方法ID
        int callbackId = [((NSString *)[components objectAtIndex:2])intValue];
        //参数
        NSString *argsAsString = [(NSString *)[components objectAtIndex:3] stringByReplacingPercentEscapesUsingEncoding : NSUTF8StringEncoding];
        NSDictionary *args = nil;
        if (argsAsString.length > 0) {
            args = [NSJSONSerialization JSONObjectWithData:[argsAsString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        }
        [self handleCall:function callbackId:callbackId args:args];
    }
}

- (void)handleCall:(NSString *)functionName callbackId:(int)callbackId args:(NSDictionary *)args {
    self.callbackId = callbackId;
    if (!self.callbackIds) {
        self.callbackIds = [NSMutableDictionary dictionary];
    }
    
    if ([functionName isEqualToString:@"hideOptionMenu"]) {
        [self setOptionMenu:YES];
    }
    else if ([functionName isEqualToString:@"showOptionMenu"]) {
        [self setOptionMenu:NO];
    }
    
    else if ([functionName isEqualToString:@"hideWebViewTitle"]) {
        self.title = @"";
    }
    else if ([functionName isEqualToString:@"closePop"]) {
        self.optionMenuButton.hidden = YES;
    }
    else if ([functionName isEqualToString:@"createPop"]) {
        KDJSBridgeTask *task = [[KDJSBridgeTask alloc] initWithCallbackId:callbackId functionName:functionName args:args];
        self.createPopTask = task;
        [self createPop];
    }
    else if ([functionName isEqualToString:@"setWebViewTitleBar"]) {
        [self setWebViewTitleBar:args];
    }
    else if ([functionName isEqualToString:@"setWebViewTitle"]) {
        
        if(self.abortUseWebTitle)
            return;
        
        NSString *title = [args objectForKey:@"title"];
        if ([title isKindOfClass:[NSString class]]) {
            self.title = title;
        }
    }
    
    else if ([functionName isEqualToString:@"gotoApp"]) {
        NSString *url = [args objectForKey:@"data"];
        if (url.length == 0) {
            [self returnResult:callbackId args:@{ Success: @"false", ErrorCode:@"1", ErrorMessage:ASLocalizedString(@"KDUserHelper_Error"), Data:@"" }];
            return;
        }
        
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]]) {
            if ([url rangeOfString:@"url="].location == NSNotFound) {
                [self returnResult:callbackId args:@{Success : @"false", ErrorCode : @"1", ErrorMessage : @"JSBridge_Tip_1", Data : @""}];
            }
            else {
                self.appUrl = url;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationViewController_tips_1") message:ASLocalizedString(@"JSBridge_Tip_3") delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel") otherButtonTitles:ASLocalizedString(@"Global_Sure"), nil];
                alertView.tag = 0x91;
                [alertView show];
            }
        }
    }
    else if ([functionName isEqualToString:@"getPersonInfo"]) {
        self.personInfoCallbackId = callbackId;
        UserDataModel *user = [BOSConfig sharedConfig].user;
        //先判断cloudpassport
        if ([XTSetting sharedSetting].cloudpassport.length > 0) {
            [self getPersonInfoCallBack:callbackId];
        }else
        {
         __weak KDWebViewController *selfInBlock = self;
         if (self.userHelper == nil)
            self.userHelper = [[KDUserHelper alloc] init];
        [self.userHelper getCloudPassportWith:user.wbUserId
                                    completion: ^(BOOL success, NSString *cloudPassport, NSString *error) {
                                        if (success) {
                                            [XTSetting sharedSetting].cloudpassport = cloudPassport;
                                            [[XTSetting sharedSetting] saveSetting];
                                            [selfInBlock getPersonInfoCallBack:selfInBlock.personInfoCallbackId]; //passPort:cloudPassport];
                                        }

                                    }];
        }
    }
    
    else if ([functionName isEqualToString:@"getNetworkType"]) {
        KDReachabilityStatus reachabilityStatus = [KDReachabilityManager sharedManager].reachabilityStatus;
        NSString *networkType = @"unknow";
        if (reachabilityStatus == KDReachabilityStatusReachableViaWiFi) {
            networkType = @"wifi";
        }
        else if (reachabilityStatus == KDReachabilityStatusReachableViaWWAN) {
            networkType = @"edge";
        }
        else if (reachabilityStatus== KDReachabilityStatusNotReachable) {
            networkType = @"fail";
        }
        
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:networkType, @"network_type", nil];
        NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, data, Data, nil];
        [self returnResult:callbackId args:argDic];
    }
    
    else if ([functionName isEqualToString:@"share"]) {
        
        NSString *groupId = args[@"params"][@"groupId"];
        if (![groupId isKindOfClass:[NSNull class]] && groupId.length > 0) {
            // 会话组跳到轻应用，分享到会话组
            XTShareStartView *shareView = [[XTShareStartView alloc] initWithShareData:[[XTShareDataModel alloc] initWithDictionary:args]];
            shareView.delegate = self;
            //shareView.shareTextField.delegate = self;
            GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:groupId];
            shareView.group = group;
            shareView.person = nil;
            
            if (!self.secondWindow) {
                self.secondWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                
                [self.secondWindow makeKeyAndVisible];
            }
            [KDPopup showHUDCustomView:shareView desc:@"" inView:self.secondWindow].dimBackground = YES;
        }
        
        if (![XTShareManager shareWithDictionary:args]) {
            NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"参数不正确"), ErrorMessage, @"1", ErrorCode, nil];
            [self returnResult:callbackId args:argDic];
        }
    }
    
    //A.wang js桥createGroupByPhone
    else if ([functionName isEqualToString:@"createGroupByPhone"]) {
        if (self.openSystemClient == nil) {
            self.openSystemClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getPersonsIdsDidRecieve:result:)];
        }
        NSArray *phones = [args objectForKey:@"phones"];
        [self.openSystemClient getPersonsByCounts:phones eid:[BOSConfig sharedConfig].user.eid token:[BOSConfig sharedConfig].user.token];
        if([args objectForKey:@"news"]){
        self.news =[[NSDictionary alloc] init];
         self.news =[args objectForKey:@"news"];
            
        }else{
            self.news = [[NSDictionary alloc] init];
        }
        self.groupName = [args objectForKey:@"grouName"];
        
    }
    else if ([functionName isEqualToString:@"fileDownloadParams"]) {
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:[BOSConnect userAgent], @"User-Agent",[BOSConfig sharedConfig].user.token, @"openToken" ,[NSString stringWithFormat:@"%@%@", [[KDWeiboServicesContext defaultContext] serverBaseURL], @"/docrest/doc/user/downloadfile"], @"downloadUrl",[BOSConfig sharedConfig].user.eid, @"networkId",nil];
        NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, data, Data, nil];
        
        [self returnResult:callbackId args:argDic];
        
    }else if ([functionName isEqualToString:@"selectPicFileAndFile"]) {
        
        [self fetchAvatar:callbackId functionName:functionName];
        
    }
    else if ([functionName isEqualToString:@"switchCompany"]) {
        NSString *eid = [args objectForKey:@"eid"];
        if (eid.length == 0) {
            NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"参数不正确"), ErrorMessage, @"1", ErrorCode, nil];
            [self returnResult:callbackId args:argDic];
        }
        else {
            [self dismissSelf];
            
            [[KDWeiboAppDelegate getAppDelegate] changeToCompany:eid finished: ^(BOOL finished) {
                if (!finished) {
                    NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"切换失败"), ErrorMessage, @"1", ErrorCode, nil];
                    [self returnResult:callbackId args:argDic];
                }
            }];
        }
    }
    
    else if ([functionName isEqualToString:@"personInfo"]) {
        __weak KDWebViewController *selfInBlock = self;
        if (self.userHelper == nil)
            self.userHelper = [[KDUserHelper alloc] init];

        [self.userHelper exchangePersonWithOid:[args objectForKey:@"openId"]
                                    completion: ^(BOOL success, NSArray *persons, NSString *error) {
                                        if (success) {
                                            PersonSimpleDataModel *person = [persons firstObject];
                                            if (person) {
                                                XTPersonDetailViewController *personVC = [[XTPersonDetailViewController alloc] initWithSimplePerson:person with:[person isPublicAccount]];
                                                personVC.hidesBottomBarWhenPushed = YES;
                                                [selfInBlock.navigationController pushViewController:personVC animated:YES];
                                            }
                                        }
                                        else {
                                            NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, error, ErrorMessage, @"1", ErrorCode, nil];
                                            [selfInBlock returnResult:callbackId args:argDic];
                                        }
                                    }];
    }
    
    else if ([functionName isEqualToString:@"chat"]) {
        //由于选人界面目前不支持默认选中多人，则此处暂时不支持多人
        NSString *groupId = [args objectForKey:@"groupId"];
        
        //直接打开群组
        if(groupId)
        {
            self.groupId = groupId;
            GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:groupId];
            
            if (group != nil && [group chatAvailable]) {
                NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, nil];
                [self returnResult:callbackId args:argDic];
                
                //先移除
                UIViewController *presentingViewController = self.presentingViewController;
                if(presentingViewController)
                    [self dismissSelf];
                
                [[KDWeiboAppDelegate getAppDelegate].timelineViewController toChatViewControllerWithGroup:group withMsgId:nil];
            }
            else
            {
                //接口获取
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPubTimeLineGroupTable:) name:@"reloadPubTimeLineGroupTable" object:nil];
                [((KDWeiboAppDelegate *)([UIApplication sharedApplication].delegate)).timelineViewController getGroupList];
            }

            return;
        }
        
        
        __weak KDWebViewController *selfInBlock = self;
        if (self.userHelper == nil) {
            self.userHelper = [[KDUserHelper alloc] init];
        }
        [self.userHelper exchangePersonWithOid:[args objectForKey:@"openId"]
                                    completion: ^(BOOL success, NSArray *persons, NSString *error) {
                                        if (success) {
                                            PersonSimpleDataModel *person = [persons firstObject];
                                            if (person) {
                                                XTChatViewController *chatVC = [[XTChatViewController alloc] initWithParticipant:[persons firstObject]];
                                                chatVC.hidesBottomBarWhenPushed = YES;
                                                [selfInBlock.navigationController pushViewController:chatVC animated:YES];
                                            }
                                        }
                                        else {
                                            NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, error, ErrorMessage, @"1", ErrorCode, nil];
                                            [selfInBlock returnResult:callbackId args:argDic];
                                        }
                                    }];
    }
    else if ([functionName isEqualToString:@"close"]) {
        [self dismissSelf];
    }
    else if ([functionName isEqualToString:@"closeWebView"]) {
        [self dismissSelf];
    }
    else if ([functionName isEqualToString:@"selectPerson"]) {
        BOOL isMult = [[args objectForKey:@"isMulti"]boolValue];
        NSInteger pType = [[args objectForKey:@"pType"] integerValue];
        XTChooseContentViewController *chooseViewController = [[XTChooseContentViewController alloc]initWithType:XTChooseContentJSBridgeSelectPerson isMult:isMult];
        if (pType) {
            chooseViewController.pType = pType;
        }
        chooseViewController.delegate = self;
        UINavigationController *navigationViewController = [[UINavigationController alloc]initWithRootViewController:chooseViewController];
        [self presentViewController:navigationViewController animated:YES completion:nil];
//        UINavigationController *navigationViewController = [[UINavigationController alloc]initWithRootViewController:chooseViewController];
//        navigationViewController.delegate = [KDNavigationManager sharedNavigationManager];
//        [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:navigationViewController animated:YES completion:nil];
    }
    else if ([functionName isEqualToString:@"fetchAvatar"]) {
        [self fetchAvatar:callbackId functionName:functionName];
    }
    
    else if ([functionName isEqualToString:@"joinBandCallback"]) {
        if ([[BOSConfig sharedConfig].user.token length] > 0) {
            
            BOOL success = [args boolForKey:@"success"];
            if (success) {
                
                NSString *eid = [[args objectNotNSNullForKey:@"data"] stringForKey:@"eId"];
                if ([eid isKindOfClass:[NSNumber class]]) {
                    eid = [NSString stringWithFormat:@"%ld", (long)[eid integerValue]];
                }
                
                if (eid.length == 0) {
                    NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"参数不正确"), ErrorMessage, @"1", ErrorCode, nil];
                    [self returnResult:callbackId args:argDic];
                    
                    [self dismissSelf];
                }
                else{
                    [self dismissSelf];
                    
                    [[KDWeiboAppDelegate getAppDelegate] changeToCompany:eid finished: ^(BOOL finished) {
                        if (!finished) {
                            NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"切换失败"), ErrorMessage, @"1", ErrorCode, nil];
                            [self returnResult:callbackId args:argDic];
                        }
                    }];
                    
                }
            }
            else{
                NSInteger errcode = [args integerForKey:@"errorCode"];
                
                if (errcode == 2050) {
                    
                    [self dismissSelf];
                    
                    [[KDWeiboAppDelegate getAppDelegate].sideMenuViewController presentLeftMenuViewController];
                    
                    [(KDLeftTeamMenuViewController *)[[[KDWeiboAppDelegate getAppDelegate] sideMenuViewController] leftMenuViewController] showNetWorkList];
                }
                else{
                    [self dismissSelf];
                }
            }
            
        }
        else {
            [self.navigationController dismissViewControllerAnimated:YES completion: ^{
                BOOL success = [args boolForKey:@"success"];
                if (success) {
                    [[KDLinkInviteConfig sharedInstance] inviteFinished];
                }
                else {
                    NSInteger errcode = [args integerForKey:@"errorCode"];
                    //待审核
                    if (errcode == 2051 && errcode == 2055) {
                        [[KDLinkInviteConfig sharedInstance] waitForCheck:[args objectNotNSNullForKey:@"data"]];
                    }
                    else if (errcode == 2050) {
                        [[KDLinkInviteConfig sharedInstance] inviteFinished];
                    }
                    else {
                        [[KDLinkInviteConfig sharedInstance] cancelInvite];
                    }
                }
            }];
        }
    }
    else if ([functionName isEqualToString:@"socialShare"]) {
        self.callbackIds[functionName] = @(callbackId);
        
        NSString *shareWay = [args objectForKey:@"shareWay"];
        NSDictionary *shareContent = [args objectForKey:@"shareContent"];
        
        if (shareWay.length == 0 || ![shareContent isKindOfClass:[NSDictionary class]] || [shareContent count] == 0) {
            return;
        }
        
        if (socialShareWays == nil) {
            socialShareWays = @[@"sms", @"wechat", @"moments", @"qq", @"qzone", @"weibo", @"buluo"];
        }
        __block KDSheetShareWay sheetShareWay = KDSheetShareWayNone;
        [socialShareWays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([shareWay rangeOfString:obj].location != NSNotFound) {
                sheetShareWay = sheetShareWay | (1 << idx);
            }
        }];
        //分享类型，目前可取值1（文本）、2（图片）、3（多媒体）
        int shareType = [[args objectForKey:@"shareType"] intValue];
        
        if (shareType == 0 || shareType > 3) {
            shareType = 1;
        }
        
        if (shareType == 1) {
            NSString *text = shareContent[@"text"];
            
            if (text.length == 0) {
                return;
            }
            self.sheet = [[KDSheet alloc] initTextWithShareWay:sheetShareWay text:text viewController:self];
        }
        else if (shareType == 2) {
            NSString *imageData = shareContent[@"imageData"];
            
            if (imageData.length == 0) {
                return;
            }
            self.sheet = [[KDSheet alloc] initImageWithShareWay:sheetShareWay imageData:[NSData dataFromBase64String:imageData] viewController:self];
        }
        else if (shareType == 3) {
            NSString *title = shareContent[@"title"];
            NSString *description = shareContent[@"description"];
            NSString *thumbData = shareContent[@"thumbData"];
            NSString *webpageUrl = shareContent[@"webpageUrl"];
            
            if ((title.length + description.length) == 0 || thumbData.length == 0) {
                return;
            }
            self.sheet = [[KDSheet alloc] initMediaWithShareWay:sheetShareWay title:title description:description thumbData:[NSData dataFromBase64String:thumbData] webpageUrl:webpageUrl viewController:self];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoteDidSucc:) name:KD_NOTE_SHARE_DID_SUCC object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoteDidFail:) name:KD_NOTE_SHARE_DID_FAIL object:nil];
        
        [self.sheet share];

        }
    
    else if([functionName isEqualToString:@"localFunction"]){
        
        if (self.functionViewController) {
            return;
        }
        
        NSString *name = [args objectForKey:@"name"];
        if (name.length == 0) {
            return;
        }
        if ([name isEqualToString:@"signin"]) {
            self.functionViewController = [[KDSignInViewController alloc] init];
            [self.navigationController pushViewController:self.functionViewController animated:YES];
        }
        else if ([name isEqualToString:@"createChat"]) {
            XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentCreate];
            contentViewController.delegate = self;
            self.functionViewController = [[UINavigationController alloc] initWithRootViewController:contentViewController];
            [self presentViewController:self.functionViewController animated:YES completion:nil];
        }
        else if ([name isEqualToString:@"createChatWithUsers"]) {
            
            if([args objectForKey:@"userIds"]){
                NSArray *personIds = [args objectForKey:@"userIds"];
                NSString *groupName = [args objectForKey:@"groupName"];
                if (personIds.count == 0 || groupName.length == 0) {
                    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:@"userId不能为空"delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
                    [alertView show];
                    NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, @"userId或groupName不能为空", ErrorMessage, @"1", ErrorCode, nil];
                    [self returnResult:self.callbackId args:argDic];
                    return ;
                }
                [self createChatWithUserIds:personIds groupName:groupName];
            }else{
                __weak __typeof(self) ws = self;
                NSArray *oIds = [args objectForKey:@"openIds"];
                NSString *groupName = [args objectForKey:@"groupName"];
                if (oIds.count == 0 || groupName.length == 0) {
                    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:@"userId不能为空"delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
                    [alertView show];
                    NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, @"userId或groupName不能为空", ErrorMessage, @"1", ErrorCode, nil];
                    [self returnResult:self.callbackId args:argDic];
                    return ;
                }
                NSString *oidsStr = @"";
                for (NSInteger i = 0; i < oIds.count; i++) {
                    oidsStr = [oidsStr stringByAppendingString:[NSString stringWithFormat:i==0?@"%@":@",%@",oIds[i]]];
                }
                [KDPopup showHUDInView:self.view];
                [ws.userHelper exchangePersonsWithOids:oidsStr completion:^(BOOL success, NSArray *persons, NSString *error) {
                    [KDPopup hideHUDInView:ws.view];
                    NSMutableArray *personIds = [NSMutableArray array];
                    [persons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        PersonSimpleDataModel *person = obj;
                        [personIds addObject:person.personId];
                    }];
                    [ws createChatWithUserIds:personIds groupName:groupName];
                }];
            }
            

        }
        else if ([name isEqualToString:@"invite"]) {
            if ([[BOSSetting sharedSetting] isIntergrationMode]) {
                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"JSBridge_Tip_7")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
                [alertView show];
                return ;
                
            }
            KDInviteColleaguesViewController *inviteVC = [[KDInviteColleaguesViewController alloc] init];
            inviteVC.hasBackBtn = YES;
            inviteVC.bShouldDismissOneLayer = YES;
            self.functionViewController = [[UINavigationController alloc] initWithRootViewController:inviteVC];
            [self presentViewController:self.functionViewController animated:YES completion:nil];
        }
        else if ([name isEqualToString:@"createvoicemeeting"]) {
            [self createvoicemeeting:args];
        }
        else {
            UIViewController *vc = [[NSClassFromString(name) alloc] init];
            if (vc) {
                NSString *switchType = [args objectForKey:@"switch"];
                if (switchType && [switchType isEqualToString:@"present"]) {
                    self.functionViewController = [[UINavigationController alloc] initWithRootViewController:vc];
                    [self presentViewController:self.functionViewController animated:YES completion:nil];
                }
                else {
                    self.functionViewController = vc;
                    [self.navigationController pushViewController:self.functionViewController animated:YES];
                }
            }
        }
    }
    //选择文件
    else if([functionName isEqualToString:@"selectFile"]){
        if (self.functionViewController) {
            return;
        }
        XTMyFilesViewController *fileListVC = [[XTMyFilesViewController alloc] init];
        fileListVC.hidesBottomBarWhenPushed = YES;
        fileListVC.fromType = 0;
        fileListVC.fromJSBridge = YES;
        fileListVC.fromViewController = self;
        fileListVC.JSBridgeDelegate = self;
        
        self.functionViewController = fileListVC;
        [self.navigationController pushViewController:self.functionViewController animated:YES];
    }
    //文件详情
    else if([functionName isEqualToString:@"showFile"]){
        if (self.functionViewController) {
            return;
        }
        
        NSMutableDictionary *dict = [NSMutableDictionary new];
        id ID = args[@"fileId"];
        
        if (ID && ![ID isKindOfClass:[NSNull class]]) {
            [dict setObject:ID forKey:@"id"];
        }
        
        id appId = args[@"publicAccountId"];
        
        if (appId && ![appId isKindOfClass:[NSNull class]]) {
            [dict setObject:appId forKey:@"appId"];
        }
        
        id Name = args[@"fileName"];
        
        if (Name && ![Name isKindOfClass:[NSNull class]]) {
            [dict setObject:Name forKey:@"fileName"];
        }
        id Ext = args[@"fileExt"];
        
        if (Ext && ![Ext isKindOfClass:[NSNull class]]) {
            [dict setObject:Ext forKey:@"fileExt"];
        }
        id Time = args[@"fileTime"];
        
        if (Time && ![Time isKindOfClass:[NSNull class]]) {
            [dict setObject:Time forKey:@"uploadDate"];
        }
        
        id Size = args[@"fileSize"];
        
        if (Size && ![Size isKindOfClass:[NSNull class]]) {
            [dict setObject:Size forKey:@"length"];
        }
        
        id fileDownloadUrl = args[@"fileDownloadUrl"];
        
        if (fileDownloadUrl && ![fileDownloadUrl isKindOfClass:[NSNull class]]) {
            [dict setObject:fileDownloadUrl forKey:@"fileDownloadUrl"];
        }
        
        id autoOpen = ([args[@"autoOpen"] isKindOfClass:[NSNull class]]?nil:args[@"autoOpen"]);
        BOOL isReadOnly = [args boolForKey:@"isReadOnly"];
        FileModel *fileModel = [[FileModel alloc] initWithDictionary:dict];
        
        BOOL bgDownload = [args boolForKey:@"bgDownload"];
        //静默下载
        if(bgDownload)
        {
            __weak __typeof(self) ws = self;
            [[KDFileDownloadManager shareManager] downloadFile:fileModel result:^(BOOL success) {
                NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:(success?@"true":@"false"), Success, nil];
                [ws returnResult:callbackId args:argDic];
            }];
            return;
        }
        

        XTFileDetailViewController *filePreviewVC = [[XTFileDetailViewController alloc] initWithFile:fileModel];
        filePreviewVC.hidesBottomBarWhenPushed = YES;
        filePreviewVC.isFromJSBridge = YES;
        filePreviewVC.isReadOnly = isReadOnly;
        filePreviewVC.needDownLoadWhenViewWillAppear =([autoOpen boolValue]?XTFileDetailButtonType_open:XTFileDetailButtonType_default);
        self.functionViewController = filePreviewVC;
//        [self.navigationController pushViewController:self.functionViewController animated:YES completion:nil];
        [self.navigationController pushViewController:self.functionViewController animated:YES];
    }
    //选择部门
    else if ([functionName isEqualToString:@"selectOrg"]) {
        if (self.functionViewController) {
            return;
        }
//        KDChooseDepartmentViewController *ctr = [[KDChooseDepartmentViewController alloc] init];
//        ctr.delegate = self;
//        ctr.fromType = KDChooseDepartmentVCFromType_JSBridge;
//        ctr.isMulti = [[args objectForKey:@"isMulti"] boolValue];
//        self.functionViewController = ctr;
//        [self.navigationController pushViewController:self.functionViewController animated:YES];
        
        KDChooseOrganizationViewController *org = [[KDChooseOrganizationViewController alloc] initWithOrgId:@"" isForCurrentUser:NO];
        [org.selectedPersonsView removeFromSuperview];
        org.blockCurrentUser = YES;
        org.adduserType = label_session_adduser_type_organization;
        org.JSBridgeType = selectOrg;
        org.JSBridgeDelegate = self;
        org.isMult = [[args objectForKey:@"isMulti"] boolValue];
        self.functionViewController = org;
        [self.navigationController pushViewController:self.functionViewController animated:YES];
    }
    //选择图片
    else if ([functionName isEqualToString:@"selectPic"]) {
//        self.selectPictureNotAllowEdit = YES;
//        [self takePhoto];
        [self selectPic:args callbackId:callbackId functionName:functionName];
    }
    //唤起扫一扫
    else if ([functionName isEqualToString:@"scanQRCode"]) {
        int needResult = [[args objectForKey:@"needResult"] intValue];
        if (needResult == 0)
        {
            [self scanQRCoderWithNeedResult:0];
        }
        else if (needResult == 1)
        {
            [self scanQRCoderWithNeedResult:1];
        }
    }
    //提供给第三方的借口，支持黑名单白名单和多选
    else if ([functionName isEqualToString:@"selectDepts"]) {
        if (self.functionViewController) {
            return;
        }
        KDChooseOrganizationViewController *org = [[KDChooseOrganizationViewController alloc] initWithOrgId:@"" isForCurrentUser:NO];
        [org.selectedPersonsView removeFromSuperview];
        org.blockCurrentUser = YES;
        org.adduserType = label_session_adduser_type_organization;
        org.JSBridgeType = selectDepts;
        org.JSBridgeDelegate = self;
        org.isMult = [[args objectForKey:@"isMulti"] boolValue];   //JSON中的文字是true & false
        org.blackList = [NSMutableArray arrayWithArray:[args objectForKey:@"blacklist"]];
        org.whiteList = [NSMutableArray arrayWithArray:[args objectForKey:@"whitelist"]];
        self.functionViewController = org;
        [self.navigationController pushViewController:self.functionViewController animated:YES];
    }
    //提供给第三方的借口，支持黑名单白名单和多选
    else if ([functionName isEqualToString:@"selectPersons"]) {
        BOOL isMult = [[args objectForKey:@"isMulti"] boolValue];
        NSInteger pType = [[args objectForKey:@"pType"] integerValue];
        NSArray *mobiles = [args objectForKey:@"mobiles"]; // 要被选中人的账号
        NSArray *selectedOids = [args objectForKey:@"selected"]; // 要被选中人的oid
        
        XTChooseContentViewController *chooseViewController = [[XTChooseContentViewController alloc]initWithType:XTChooseContentJSBridgeSelectPersons isMult:isMult];
        chooseViewController.delegate = self;
        if (pType) {
            chooseViewController.pType = pType;
        }
        chooseViewController.blackList = [NSMutableArray arrayWithArray:[args objectForKey:@"blacklist"]];
        chooseViewController.whiteList = [args objectForKey:@"whitelist"];
        if (selectedOids != nil && ![selectedOids isKindOfClass:[NSNull class]] && selectedOids.count != 0) {
            chooseViewController.selectedOids = selectedOids;
        } else {
            if (mobiles != nil && ![mobiles isKindOfClass:[NSNull class]] && mobiles.count != 0) {
                chooseViewController.selectedMobiles = mobiles;
            }
        }
        UINavigationController *navigationViewController = [[UINavigationController alloc]initWithRootViewController:chooseViewController];
        [self presentViewController:navigationViewController animated:YES completion:nil];
    }//获取位置
    else if ([functionName isEqualToString:@"getCurrentPosition"])
    {
        if (self.isGetingCurrentLocation) {
            return;
        }
        self.isGetingCurrentLocation = YES;
        //[locationView_ startLocating];
        //[[KDLocationManager globalLocationManager] setDelegate:self];
        //        首先移除通知  再添加通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationSuccess object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationFailed object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationInit object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationStart object:nil];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidSucess:) name:KDNotificationLocationSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFailed:) name:KDNotificationLocationFailed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidInit:) name:KDNotificationLocationInit object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidstart:) name:KDNotificationLocationStart object:nil];
        
        
        [[KDLocationManager globalLocationManager] setLocationType:KDLocationTypeNormal];
        [[KDLocationManager globalLocationManager] startLocating];
    }
    else if ([functionName isEqualToString:@"getExistApps"])//获取已添加app列表
    {
        NSMutableArray *array = [KDApplicationViewController getShowAppIDArrForJs];
        NSMutableArray *newArray = [NSMutableArray array];
        
        if([array isKindOfClass:[NSArray class]])
        {
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                NSString *appClientId = obj;
                if(appClientId.length>2)
                {
                    NSString *appId = [appClientId substringToIndex:appClientId.length-2];
                    [newArray addObject:appId];
                }
            }];
        }
        
        NSString *appIds = @"";
        if(array)
        {
            appIds = [newArray componentsJoinedByString:@","];
        }
        NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, @{@"appIds":appIds}, Data, nil];
        [self returnResult:callbackId args:argDic];
    }
    else if ([functionName isEqualToString:@"getCurrentLatLon"])
    {
        [self getLocation:callbackId];
        
//        BOOL isSuccess = YES;
//        float appLatitude = self.appLocation.coordinate.latitude;
//        float appLongitude = self.appLocation.coordinate.longitude;
//        
//        if (appLatitude == 0 && appLongitude == 0) {
//            isSuccess = NO;
//        }
//        
//        NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys: isSuccess?@"true":@"false", Success, @"0", ErrorCode, @{@"latitude": [NSNumber numberWithFloat:appLatitude], @"longitude": [NSNumber numberWithFloat:appLongitude]}, Data, nil];
//        [self returnResult:callbackId args:argDic];
    }
    else if ([functionName isEqualToString:@"addCloudApp"])//添加app
    {
        NSLog(@"addCloudApp");
        KDAppDataModel *appDM = [[KDAppDataModel alloc] init];
        appDM.appClientID = [NSString stringWithFormat:@"%@11",[args objectForKey:@"appid"]];
        appDM.appID = [args objectForKey:@"appid"];
        appDM.appLogo = [NSString stringWithFormat:@"%@%@",[[BOSSetting sharedSetting] getAppstoreurl],[args objectForKey:@"appicourl"]];
        appDM.downloadURL = [args objectForKey:@"appadress"];
        appDM.webURL = [args objectForKey:@"appadress"];
        appDM.appName = [args objectForKey:@"appname"];
        appDM.appType = KDAppTypeYunApp;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddApp" object:nil userInfo:@{@"appDM":appDM,@"isYunApp":@(YES)}];
        
//        //保存到本地,并重取数据
//        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:appDM, @"appDM", nil];
//        NSNotification *notification = [NSNotification notificationWithName:@"Personal_App_Add" object:nil userInfo:dic];
//        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success ,nil];
        [self returnResult:callbackId args:argDic];
    }
    else if ([functionName isEqualToString:@"openCloudApp"])//打开app
    {
        NSLog(@"openCloudApp");
        KDAppDataModel *appDM = [[KDAppDataModel alloc] init];
        appDM.appClientID = [NSString stringWithFormat:@"%@11",[args objectForKey:@"appid"]];
        appDM.appID = [args objectForKey:@"appid"];
        appDM.appLogo = [NSString stringWithFormat:@"%@%@",[[BOSSetting sharedSetting] getAppstoreurl],[args objectForKey:@"appicourl"]];
        appDM.downloadURL = [args objectForKey:@"appadress"];
        appDM.webURL = [args objectForKey:@"appadress"];
        appDM.appName = [args objectForKey:@"appname"];
        appDM.appType = KDAppTypeYunApp;

        //打开app
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:appDM, @"appDM", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openCloudApp" object:dic];
        
        NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success ,nil];
        [self returnResult:callbackId args:argDic];
    }
    else if ([functionName isEqualToString:@"getAdminOpenId"])
    {
        
        [self getAdminOpenId:callbackId functionName:functionName];
        
    }
    else if([functionName isEqualToString:@"getHealthData"])
    {
        
//         [self getHealthData:callbackId functionName:functionName];
        
    }
    else if ([functionName isEqualToString:@"previewImage"])
    {
        [self previewImage:callbackId functionName:functionName args:args];
    }
    else if ([functionName isEqualToString:@"defback"])
    {
        [self defback:callbackId functionName:functionName];
    }
    else if ([functionName isEqualToString:@"hideKeyboard"])
    {
        //隐藏输入法
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    }
    else if ([functionName isEqualToString:@"iAppRevision"])
    {
        [self showAppRevision:callbackId functionName:functionName args:args];
    }
    else if ([functionName isEqualToString:@"getMessageById"])
    {
        NSString *msgId = args[@"msgId"];
        if([msgId isKindOfClass:[NSNull class]] || msgId == nil)
        {
            NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success ,nil];
            [self returnResult:callbackId args:argDic];
            return;
        }
        
        NSDictionary *dic = [[XTDataBaseDao sharedDatabaseDaoInstance] queryMsgDicWithMsgId:msgId];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success ,jsonStr,Data,nil];
        [self returnResult:callbackId args:argDic];
    }
    else if ([functionName isEqualToString:@"startSignFeedback"]) {
        [self startSignFeedback:callbackId functionName:functionName args:args];
    }
    else if ([functionName isEqualToString:@"rotateUI"]) {
        [self rotateUI:callbackId functionName:functionName args:args];
    }
    //录音相关
    else if ([functionName isEqualToString:@"startRecord"]) {
        [self startRecord:callbackId functionName:functionName args:args];
    }
    else if ([functionName isEqualToString:@"stopRecord"]) {
        [self stopRecord:callbackId functionName:functionName args:args];
    }
    else if ([functionName isEqualToString:@"playVoice"]) {
        [self playVoice:callbackId functionName:functionName args:args];
    }
    else if ([functionName isEqualToString:@"pauseVoice"]) {
        [self pauseVoice:callbackId functionName:functionName args:args];
    }
    else if ([functionName isEqualToString:@"stopVoice"]) {
        [self stopVoice:callbackId functionName:functionName args:args];
    } else if ([functionName isEqualToString:@"getDeviceInfo"]) {
        [self getDeviceInfo:callbackId args:args];
    }

}

#pragma mark - 音频文件
- (void)startRecord:(int)callbackId functionName:(NSString *)funcName args:args {
    BOOL returnMD5 = [args boolForKey:@"returnBase64"];
    self.webView.canScroll = NO;
    __weak __typeof(self) weakSelf = self;
    [KDCustomAudioManager customAudioManager].returnBase64 = returnMD5;
    [[KDCustomAudioManager customAudioManager] startRecordComplete:^(BOOL success, NSString *errorCode, NSString *error, NSDictionary *data) {
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        [args setValue:[NSString stringWithFormat:@"%@",success? @"true":@"false"] forKey:Success];
        [args setValue:kd_safeString(errorCode) forKey:ErrorCode];
        [args setValue:kd_safeString(error) forKey:ErrorMessage];
        [args setValue:data forKey:@"data"];
        [weakSelf returnResult:callbackId args:args];
        weakSelf.webView.canScroll = YES;
    }];
}

- (void)stopRecord:(int)callbackId functionName:(NSString *)funcName args:args{
    self.webView.canScroll = YES;
     BOOL returnMD5 = [args boolForKey:@"returnBase64"];
    __weak __typeof(self) weakSelf = self;
    [KDCustomAudioManager customAudioManager].returnBase64 = returnMD5;
    [[KDCustomAudioManager customAudioManager]stopRecordComplete:^(BOOL success, NSString *errorCode, NSString *error, NSDictionary *data) {
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        [args setValue:[NSString stringWithFormat:@"%@",success? @"true":@"false"] forKey:Success];
        [args setValue:kd_safeString(errorCode) forKey:ErrorCode];
        [args setValue:kd_safeString(error) forKey:ErrorMessage];
        [args setValue:data forKey:@"data"];
        [weakSelf returnResult:callbackId args:args];
    }];
}

- (void)playVoice:(int)callbackID functionName:(NSString *)functionName args:(NSDictionary *)args {
    NSString *localId = [args objectForKey:@"localId"];
    __weak __typeof(self) weakSelf = self;
    [[KDCustomAudioManager customAudioManager] playVoice:localId startBlock:^(BOOL success, NSString *errorCode, NSString *error, NSDictionary *data) {
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        [args setValue:[NSString stringWithFormat:@"%@",success? @"true":@"false"] forKey:Success];
        [args setValue:kd_safeString(errorCode) forKey:ErrorCode];
        [args setValue:kd_safeString(error) forKey:ErrorMessage];
        if (data) {
            [args setValue:data forKey:@"data"];
        }
        [weakSelf returnResult:callbackID args:args];
    } finishBlock:^(BOOL success, NSString *errorCode, NSString *error, NSDictionary *data) {
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        [args setValue:[NSString stringWithFormat:@"%@",success? @"true":@"false"] forKey:Success];
        [args setValue:kd_safeString(errorCode) forKey:ErrorCode];
        [args setValue:kd_safeString(error) forKey:ErrorMessage];
        if (data) {
            [args setValue:data forKey:@"data"];
        }
        [weakSelf returnResult:callbackID args:args];
    }];
}

- (void)pauseVoice:(int)callbackID functionName:(NSString *)functionName args:(NSDictionary *)args {
    NSString *localId = [args objectForKey:@"localId"];
    __weak __typeof(self) weakSelf = self;
    [[KDCustomAudioManager customAudioManager] pauseVoice:localId complete:^(BOOL success, NSString *errorCode, NSString *error, NSDictionary *data) {
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        [args setValue:[NSString stringWithFormat:@"%@",success? @"true":@"false"] forKey:Success];
        [args setValue:kd_safeString(errorCode) forKey:ErrorCode];
        [args setValue:kd_safeString(error) forKey:ErrorMessage];
        [weakSelf returnResult:callbackID args:args];
    }];
}

- (void)stopVoice:(int)callbackID functionName:(NSString *)functionName args:(NSDictionary *)args {
    __weak __typeof(self) weakSelf = self;
    NSString *localId = [args objectForKey:@"localId"];
    [[KDCustomAudioManager customAudioManager] stopVoice:localId complete:^(BOOL success, NSString *errorCode, NSString *error, NSDictionary *data) {
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        [args setValue:[NSString stringWithFormat:@"%@",success? @"true":@"false"] forKey:Success];
        [args setValue:kd_safeString(errorCode) forKey:ErrorCode];
        [args setValue:kd_safeString(error) forKey:ErrorMessage];
        [weakSelf returnResult:callbackID args:args];
    }];
}

-(void)createChatWithUserIds:(NSArray *)personIds groupName:(NSString *)groupName
{
    
    if ([personIds count] == 0) {
        return;
    }
    
    if (self.createChatClient == nil) {
        self.createChatClient = [[ContactClient alloc] initWithTarget:self action:@selector(createChatDidReceived:result:)];
    }
    self.progressHud.labelText = ASLocalizedString(@"正在创建群组...");
    self.progressHud.mode = MBProgressHUDModeIndeterminate;
    self.progressHud.margin = 20;
    self.progressHud.dimBackground = NO;
    [self.progressHud show:YES];
    
    [self.createChatClient creatGroupWithUserIds:personIds groupName:groupName];
}

- (void)createChatDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        if (result.error.length > 0) {
            [self.progressHud setLabelText:result.error];
        }
        else
        {
            [self.progressHud setLabelText:ASLocalizedString(@"创建失败")];
        }
        [self.progressHud setMode:MBProgressHUDModeText];
        self.progressHud.margin = 20;
        self.progressHud.dimBackground = NO;
        [self.progressHud hide:YES afterDelay:1.0];
        
        return;
    }
    
    GroupDataModel *groupDM = [[GroupDataModel alloc] initWithDictionary:result.data];
    groupDM.isNewGroup = YES;
        
    [self.progressHud removeFromSuperview];
    self.progressHud = nil;
    
    //拼接一个grouplist 用于会话组查询参与人ID 706
    GroupListDataModel *groupList = [[GroupListDataModel alloc]init];
    groupList.list = [[NSMutableArray alloc] initWithArray:@[groupDM]];
    [[XTDataBaseDao sharedDatabaseDaoInstance]insertUpdatePrivateGroupList:groupList];
    
    [self setupTabBeforetimelineToChat];
    [[KDWeiboAppDelegate getAppDelegate].timelineViewController toChatViewControllerWithGroup:groupDM withMsgId:nil];

}

#pragma mark createChat | createvoicemeeting

//- (void)createChat:(NSDictionary *)args {
//    NSDictionary *param = args[@"param"];
//    if (param && [param isKindOfClass:[NSDictionary class]]) {
//        BOOL isShowExt = [param boolForKey:@"isShowExt" defaultValue:YES];
//        [self toChooseContentView:NO isShowExt:isShowExt];
//    }
//}

-(void)reloadPubTimeLineGroupTable:(NSNotification *)noti
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadPubTimeLineGroupTable" object:nil];
    NSString *groupId = self.groupId;
    self.groupId = nil;
    if(groupId)
    {
        GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:groupId];
        
        if (group != nil) {
            NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, nil];
            [self returnResult:[self.callbackIds[@"chat"] intValue] args:argDic];
            
            //先移除
            UIViewController *presentingViewController = self.presentingViewController;
            if(presentingViewController)
                [self dismissSelf];

            [[KDWeiboAppDelegate getAppDelegate].timelineViewController toChatViewControllerWithGroup:group withMsgId:nil];
        }
        else
        {
            NSDictionary *argDic = [[NSDictionary alloc]initWithObjectsAndKeys:@"false", Success, @"找不到群组", ErrorMessage, @"1", ErrorCode, nil];
            [self returnResult:[self.callbackIds[@"chat"] intValue] args:argDic];
        }
    }
    else
    {
        NSDictionary *argDic = [[NSDictionary alloc]initWithObjectsAndKeys:@"false", Success, @"找不到群组", ErrorMessage, @"1", ErrorCode, nil];
        [self returnResult:[self.callbackIds[@"chat"] intValue] args:argDic];
    }
}

- (void)createvoicemeeting:(NSDictionary *)args {
//    NSDictionary *param = args[@"param"];
//    if (param && [param isKindOfClass:[NSDictionary class]]) {
//        BOOL isShowExt = [args boolForKey:@"isShowExt" defaultValue:YES];
        XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentCreate];
        contentViewController.delegate = self;
        self.bGoMultiVoiceAfterCreateGroup = YES;
        self.functionViewController = [[UINavigationController alloc] initWithRootViewController:contentViewController];
        [self presentViewController:self.functionViewController animated:YES completion:nil];

//    }
}
//- (void)toChooseContentView:(BOOL)bGoMultiVoiceAfterCreateGroup isShowExt:(BOOL)isShowExt {
//    if (bGoMultiVoiceAfterCreateGroup) {
////        [KDEventAnalysis event:event_app_new_voicemeeting];
////        [KDEventAnalysis event:event_app_start_voicemeeting];
//    }
//    
//    __weak __typeof(self) weakSelf = self;
//    KDChooseConfigModel *configModel = [[KDChooseConfigModel alloc] init];
//    configModel.topGroupIsExtenalGroup = isShowExt;
////    configModel.dataSources = [isShowExt ?  @[@(KDChoosePersonTopItemTypeOrganization), @(KDChoosePersonTopItemTypeGroup), @(KDChoosePersonTopItemTypeExternalFriend)] : @[@(KDChoosePersonTopItemTypeOrganization), @(KDChoosePersonTopItemTypeGroup)] mutableCopy];
//    [[KDChooseManager shareKDChooseManager] startChoosePersonsOrGroupWithGroup:nil viewController:self configModel:configModel isNeedPersons:NO isPush:NO delegate:nil complition:^(NSArray *persons, GroupDataModel *newGroup, BOOL isCreateNew) {
//        if (newGroup) {
//            XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:newGroup pubAccount:nil mode:ChatPrivateMode];
//            chatViewController.hidesBottomBarWhenPushed = YES;
//            chatViewController.bGoMultiVoiceAfterCreateGroup = bGoMultiVoiceAfterCreateGroup;
//            [weakSelf.navigationController pushViewController:chatViewController animated:YES];
//        }
//        else {
//            if ([persons count] > 0) {
//                XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:[persons firstObject]];
//                chatViewController.hidesBottomBarWhenPushed = YES;
//                chatViewController.bGoMultiVoiceAfterCreateGroup = bGoMultiVoiceAfterCreateGroup;
//                [weakSelf.navigationController pushViewController:chatViewController animated:YES];
//            }
//        }
//    }];
//}


#pragma mark - 方法(defback) -

- (void)defback:(int)callbackId functionName:(NSString *)functionName {
    self.callbackIds[functionName] = @(callbackId);
    
    [self setupLeftBarButtonItems];
}

- (BOOL)isDefBack {
    return self.callbackIds[JS_Defback] ? YES : NO;
}

- (void)defback {
    [self returnResult:[self.callbackIds[JS_Defback] intValue] args:nil];
}

- (void)resetDefback {
    [self.callbackIds removeObjectForKey:JS_Defback];
}
- (void)previewImage:(int)callbackId functionName:(NSString *)funcName args:(NSDictionary *)args {
    [self.callbackIds setObject:@(callbackId) forKey:funcName];
    NSString *currentUrl = kd_safeString([args objectForKey:@"current"]);
    NSMutableArray *images = kd_safeMutableArray([args objectForKey:@"images"]);
    NSMutableArray *urls = [[NSMutableArray alloc] initWithArray:args[@"urls"]];
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSInteger currentIndex = 0;
    
    if (images.count > 0) {
        for (NSDictionary *dict in images) {
            NSString *url = kd_safeString([dict objectForKey:@"url"]);
            NSString *orignialUrl = kd_safeString([dict objectForKey:@"orignialUrl"]);
            NSInteger size = kd_safeInteger([dict objectForKey:@"size"]);
            
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.bFullScrean = YES;
            photo.url = [NSURL URLWithString:url];
            photo.midPictureUrl = [NSURL URLWithString:url];
            photo.originUrl = [NSURL URLWithString:orignialUrl];
            photo.photoLength = [self transformedValue:size];
            photo.isOriginalPic = (orignialUrl.length>0?@"1":@"0");

            [photos addObject:photo];
            
            if (currentUrl.length > 0 && [currentUrl isEqualToString:url]) {
                currentIndex = [images indexOfObject:dict];
            }
        }
    } else {
        if (currentUrl && currentUrl.length > 0 && ![urls containsObject:currentUrl]) {
            [urls insertObject:currentUrl atIndex:0];
        }
        if (currentUrl && currentUrl.length > 0) {
            currentIndex = [urls indexOfObject:currentUrl];
        }
        for (NSString *photoUrl in urls) {
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.bFullScrean = YES;
            photo.url = [NSURL URLWithString:photoUrl];
            [photos addObject:photo];
        }
    }

    
    if (photos.count <= 0) {
        [self returnResult:self.callbackIds[JS_PreviewImage] args:@{Success : @"false", ErrorCode : @"1", ErrorMessage : @"没有图片资源", Data : @""}];
    }
    else {
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.delegate = self;
        browser.currentPhotoIndex = currentIndex;
        browser.photos = photos;
        [browser show];
        [self returnResult:self.callbackIds[JS_PreviewImage] args:@{Success : @"true", ErrorCode : @"0"}];
    }
}

- (id)transformedValue:(double)value
{
    double convertedValue = value;
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%.f%@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

//识别二维码
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser scanWithresult:(NSString *)result
{
    __weak __typeof(self) weakSelf = self;
    [[KDQRAnalyse sharedManager] execute:result callbackBlock:^(QRLoginCode qrCode, NSString *qrResult) {
        
        [photoBrowser hide];
        [[KDQRAnalyse sharedManager] gotoResultVCInTargetVC:weakSelf withQRResult:qrResult andQRCode:qrCode];
        
    }];
}


- (void)returnResult:(int)callbackId args:(NSDictionary *)resultDic {
    if (resultDic == nil) {
        resultDic = @{Success : @"false",ErrorCode : @"1", ErrorMessage : @"获取失败", Data : @""};
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *resultArrayString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [resultArrayString stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    [self.webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:[NSString stringWithFormat:@"XuntongJSBridge.handleMessageFromXT(%d,%@);", callbackId, resultArrayString] waitUntilDone:NO];
}
- (void)getAdminOpenId:(int)callbackId functionName:(NSString *)functionName {
    
    self.callbackIds[functionName] = @(callbackId);
    
    if (!self.getAdminEidClient) {
        self.getAdminEidClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getAdminEidDidReceived:result:)];
    }
    [self.getAdminEidClient getAdminEid];
}
- (void)getHealthData:(int)callbackId functionName:(NSString *)functionName {
    
    self.callbackIds[functionName] = @(callbackId);
    
}
- (void)getAdminEidDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result {
    NSArray *dataArray = nil;
    NSString *openIdstr = @"";
    
    if (result.success && result.data && [result.data isKindOfClass:[NSArray class]]) {
        dataArray = result.data;
        
        if (dataArray && dataArray.count > 0) {
            for (NSInteger index = 0; index < dataArray.count; index++) {
                if (dataArray.count != 1 && index > 0) {
                    openIdstr = [NSString stringWithFormat:@"%@,%@", openIdstr, dataArray[index]];
                }
                else {
                    openIdstr = [NSString stringWithFormat:@"%@", dataArray[index]];
                }
            }
        }
    }
    
    NSDictionary *argDic;
    
    if (openIdstr && openIdstr.length > 0) {
        argDic = @{Success : @"true", ErrorMessage : @"", ErrorCode : @"", Data : @{@"adminOpenIds" : openIdstr}};
    }
    else if (result.success) {
        argDic = @{Success : @"false", ErrorCode : @"1", ErrorMessage : @"未设置管理员", Data : @""};
    }
    else {
        argDic = @{Success : @"false", ErrorCode : @"1", ErrorMessage : @"请求错误", Data : @""};
    }
    [self returnResult:[self.callbackIds[JS_GetAdminOpenId] intValue] args:argDic];
}




#pragma mark - 方法(fetchAvatar | selectPic) -

- (void)fetchAvatar:(int)callbackId functionName:(NSString *)functionName {
    self.imageFunc = functionName;
    self.callbackIds[functionName] = @(callbackId);
    
    [self takePhoto:nil];
}

- (void)selectPic:(NSDictionary *)args callbackId:(int)callbackId functionName:(NSString *)functionName {
    self.imageFunc = functionName;
    self.callbackIds[functionName] = @(callbackId);
    
    NSString *type = [args objectForKey:@"type"];
    [self takePhoto:type];
}
#pragma mark - take photo
- (void)takePhoto:(NSString *)type {
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    if ([type isKindOfClass:[NSString class]] && type.length > 0) {
        if ([type isEqualToString:@"photo"]) {
            [self presentImagePickerController:NO];
        }
        else if ([type isEqualToString:@"camera"]) {
            [self presentImagePickerController:YES];
        }
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.delegate = self;
        
        NSUInteger cancelIndex = 1;
        [actionSheet addButtonWithTitle:ASLocalizedString(@"KDImagePickerController_Photo")];
        if (hasCamera) {
            cancelIndex++;
            [actionSheet addButtonWithTitle:NSLocalizedString(@"TAKE_PHOTO", @"")];
        }
        //A.wang 上传文件
        [actionSheet addButtonWithTitle:@"中海通文件"];
        [actionSheet addButtonWithTitle:@"本地文件"];
        
        [actionSheet addButtonWithTitle:ASLocalizedString(@"Global_Cancel")];
        
        actionSheet.cancelButtonIndex = cancelIndex;
        
        [actionSheet showInView:self.view];
    }
}

- (void)presentImagePickerController:(BOOL)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.allowsEditing = [self.imageFunc isEqualToString:@"fetchAvatar"];
    
    if (takePhoto) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // clear cached avatar if need
    
//    if ([picker isKindOfClass:[KDImagePickerViewController class]]) {
//        [self selectPhotoImagePicker:(KDImagePickerViewController *)picker DidFinishWithInfo:info];
//        return;
//    }
    
    NSDictionary *resultDic;
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (image != nil) {
        image = [image fixOrientation];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
        NSString *base64ImageString = [imageData base64EncodedString];
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:@"png", @"fileExt", base64ImageString, @"fileData", nil];
        resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, data, Data, nil];
    }
    else {
        resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"JSBridge_Tip_9"), ErrorMessage, @"1", ErrorCode, nil];
    }
    
    [self returnResult:[self.callbackIds[self.imageFunc] intValue] args:resultDic];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"JSBridge_Tip_10"), ErrorMessage, @"1", ErrorCode, nil];
    [self returnResult:self.callbackId args:argDic];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)jsBridgeActionWithTitle:(NSString *)title {
    BOOL result = YES;
    if ([title isEqualToString:ASLocalizedString(@"KDImagePickerController_Photo")]) {
        [self presentImagePickerController:NO];
    }
    else if ([title isEqualToString:ASLocalizedString(@"KDDMChatInputView_tak_photo")]) {
        [self presentImagePickerController:YES];
    }
    
    //A.wang   上传文件
    else if ([title isEqualToString:@"本地文件"]) {
        NSArray * arr=@[(__bridge NSString *) kUTTypeContent,
(__bridge NSString *) kUTTypeData,
(__bridge NSString *) kUTTypePackage,
(__bridge NSString *) kUTTypeDiskImage,
@"com.apple.iwork.pages.pages",
@"com.apple.iwork.numbers.numbers",
@"com.apple.iwork.keynote.key"];

        // 可以选择的文件类型
        UIDocumentPickerViewController  *testVC = [[UIDocumentPickerViewController  alloc] initWithDocumentTypes:arr inMode:UIDocumentPickerModeOpen];
        testVC.delegate = self;
        testVC.modalPresentationStyle = UIModalPresentationFullScreen;
        UINavigationController *navigationViewController = [[UINavigationController alloc]initWithRootViewController:testVC];
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed)];
        testVC.navigationItem.rightBarButtonItem = anotherButton;
        [self presentViewController:navigationViewController animated:YES completion:nil];
    } //A.wang   上传文件
    else if ([title isEqualToString:@"中海通文件"]) {
        if (!self.functionViewController) {
        
        XTMyFilesViewController *fileListVC = [[XTMyFilesViewController alloc] init];
        fileListVC.hidesBottomBarWhenPushed = YES;
        fileListVC.fromType = 0;
        fileListVC.fromJSBridge = YES;
        fileListVC.fromViewController = self;
        fileListVC.JSBridgeDelegate = self;
        
        self.functionViewController = fileListVC;
            RTRootNavigationController *qrScanNavController = [[RTRootNavigationController alloc] initWithRootViewController:fileListVC];
            [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:qrScanNavController animated:YES completion:nil];
            
        }
        
    }
    
    else {
        result = NO;
    }
    return result;
}
#pragma mark - method
-(void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    //获取授权
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileUrlAuthozied) {
        //通过文件协调工具来得到新的文件地址，以此得到文件保护功能
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
            //读取文件
            NSString *fileName = [newURL lastPathComponent];
            NSString *extension = [fileName pathExtension];
            
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                NSDictionary *resultDic;
                //读取出错
                resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"JSBridge_Tip_9"), ErrorMessage, @"1", ErrorCode, nil];
                [self returnResult:[self.callbackIds[self.imageFunc] intValue] args:resultDic];
                
            } else {
                //上传
                [KDFileUploader kd_uploadFiles:@{[newURL absoluteString]:fileData} completion:^(BOOL succ, NSArray<DocumentFileModel *> * _Nullable files) {
                    DocumentFileModel *file;
                    if (succ && files.count > 0) file = [files firstObject];
                    NSMutableArray *nsmarr = [NSMutableArray array];
                    NSDictionary *resultDic;
                    NSDictionary *fdata = [[NSDictionary alloc] initWithObjectsAndKeys:safeString(file.fileId), @"fileId",safeString(fileName), @"fileName",safeString(extension), @"fileExt",@(fileData.length), @"fileSize",safeString(file.uploadDate), @"fileTime",nil];
                    [nsmarr addObject:fdata];
                    
                    NSDictionary *dic = [NSDictionary dictionaryWithObject:nsmarr forKey:@"files"];
                    
                    resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, @"0", ErrorCode, dic, Data,[BOSConfig sharedConfig].user.emails, @"email", nil];
                   
                    [self returnResult:[self.callbackIds[self.imageFunc] intValue] args:resultDic];
                    
                }];
                
            }
            
            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
        [urls.firstObject stopAccessingSecurityScopedResource];
    } else {
        //授权失败
    }
}

#pragma mark - share
- (void)onNoteDidFail:(NSNotification *)note {
    NSDictionary *dic = note.userInfo;
    NSNumber *tempNumber = (NSNumber *)[dic objectForKey:@"shareWay"];
    NSUInteger tempInt = [tempNumber unsignedIntegerValue];
    
    NSString *tempString;
    
    if (tempInt == KDSheetShareWaySMS) {
        tempString = @"sms";
    }
    else if (tempInt == (KDSheetShareWayWechat | KDSheetShareWayMoment)) {
        tempString = @"wechat";
    }
    else if (tempInt == (KDSheetShareWayQQ | KDSheetShareWayQzone)) {
        tempString = @"qq";
    }
    else if (tempInt == KDSheetShareWayWeibo) {
        tempString = @"weibo";
    }
    
    NSDictionary *argDic = [NSDictionary dictionaryWithObjectsAndKeys:@"false", Success, @{@"shareType" : tempString}, Data, note.userInfo[KD_NOTE_USERINFO_KEY_ERROR], ErrorMessage, nil];
    [self returnResult:[self.callbackIds[@"socialShare"] intValue] args:argDic];
    [self removeShareObserver];
}

- (void)onNoteDidSucc:(NSNotification *)note {
    NSDictionary *dic = note.userInfo;
    NSNumber *tempNumber = (NSNumber *)[dic objectForKey:@"shareWay"];
    NSUInteger tempInt = [tempNumber unsignedIntegerValue];
    
    NSString *tempString;
    
    if (tempInt == KDSheetShareWaySMS) {
        tempString = @"sms";
    }
    else if (tempInt == (KDSheetShareWayWechat | KDSheetShareWayMoment)) {
        tempString = @"wechat";
    }
    else if (tempInt == (KDSheetShareWayQQ | KDSheetShareWayQzone)) {
        tempString = @"qq";
    }
    else if (tempInt == KDSheetShareWayWeibo) {
        tempString = @"weibo";
    }
    
    NSDictionary *argDic = [NSDictionary dictionaryWithObjectsAndKeys:@"true", Success, @{@"shareType" : tempString}, Data, nil];
    [self returnResult:[self.callbackIds[@"socialShare"] intValue] args:argDic];
    [self removeShareObserver];
}

- (void)removeShareObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KD_NOTE_SHARE_DID_SUCC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KD_NOTE_SHARE_DID_FAIL object:nil];
}

#pragma mark - selectFile
-(void)theSelectedFiles:(NSArray *)array {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (DocumentFileModel *model in array) {
        NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)model.length];
        NSString *time = [self formatWithFormatter:model.time formater:@"yyyy-MM-dd HH:mm"];
        
        NSDictionary *tempDic = @{@"fileId":model.fileId, @"fileName":model.fileName, @"fileExt":model.fileExt, @"fileTime":time, @"fileSize":length};
        
        [resultArray addObject:tempDic];
    }
    
    NSDictionary *dic = @{@"files":resultArray};
    NSDictionary *argDic = @{Success:@"true", Data:dic};
   // [self returnResult:self.callbackId args:argDic];
    [self returnResult:self.callbackId args:argDic];
       dispatch_async(dispatch_get_main_queue(), ^{
            // [NSThread sleepForTimeInterval:0.5];
            if(self.functionViewController){
                 [self.functionViewController dismissViewControllerAnimated:YES completion:^{
                 }];
             }
        });
    
}

- (NSString *) formatWithFormatter:(NSDate *) date formater:(NSString *)formater {
    if(self == nil || formater == nil)
        return nil;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formater];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

#pragma mark - selectOrg selectDepts
-(void)selectOrgArray:(NSArray *)groups
{
    NSMutableArray *orgids = [NSMutableArray array];
    for (XTOrgChildrenDataModel *model in groups)
    {
        [orgids addObject:model.orgId];
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObject:orgids forKey:@"orgids"];
    NSDictionary *argDic = [NSDictionary dictionaryWithObjectsAndKeys:@"true", Success, dic, Data, nil];
    [self returnResult:self.callbackId args:argDic];
}

-(void)selectDeptsArray:(NSArray *)groups
{
    NSMutableArray *persons = [NSMutableArray array];
    NSMutableDictionary *person;
    for (XTOrgChildrenDataModel *model in groups) {
        person = [NSMutableDictionary dictionary];
        [person setObject:model.orgId forKey:@"orgId"];
        [person setObject:model.orgName forKey:@"name"];
        [persons addObject:person];
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObject:persons forKey:@"persons"];
    NSDictionary *argDic = [NSDictionary dictionaryWithObjectsAndKeys:@"true", Success, dic, Data, nil];
    [self returnResult:self.callbackId args:argDic];
}

-(void)cancelSelect {
    NSDictionary *argDic = [NSDictionary dictionaryWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"未选择退出"), ErrorMessage, @"1", ErrorCode, nil];
    [self returnResult:self.callbackId args:argDic];
}

#pragma mark - scanQR
- (void)scanQRCoderWithNeedResult:(int)needResult
{
    //获取对摄像头的访问权限
    //    if (isAboveiOS7) {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:ASLocalizedString(@"JSBridge_Tip_14"),KD_APPNAME] delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return;
    }
    //    }
    
    [KDEventAnalysis event:event_scan_open attributes:@{label_scan_open: label_scan_open_shortcut}];
    
    XTQRScanViewController *qrScanController = [[XTQRScanViewController alloc] init];
    qrScanController.delegate = self;
    qrScanController.controller = self;
    qrScanController.isFromJSBridge = YES;
//    qrScanController.isFromJSBridgeAndNeedResult = needResult;
    if(needResult == 1){
        qrScanController.JSBridgeDelegate = self;
    }
    RTRootNavigationController *qrScanNavController = [[RTRootNavigationController alloc] initWithRootViewController:qrScanController];
    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:qrScanNavController animated:YES completion:nil];
}

- (void)qrScanViewController:(XTQRScanViewController *)controller loginCode:(int)qrLoginCode result:(NSString *)result
{
    //回调
    NSDictionary *argDic = @{Success:@"true"};
    [self returnResult:self.callbackId args:argDic];
    
    [[KDWeiboAppDelegate getAppDelegate].tabBarController dismissViewControllerAnimated:NO completion:^{
        if (qrLoginCode > 0) {
            XTQRLoginViewController *login = [[XTQRLoginViewController alloc] initWithURL:result qrLoginCode:qrLoginCode];
            login.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:login animated:YES];
        }
    }];
}

- (void)qrScanViewControllerDidCancel:(XTQRScanViewController *)controller
{
    //回调
    NSDictionary *argDic = @{Success:@"true"};
    [self returnResult:self.callbackId args:argDic];
    
    [[KDWeiboAppDelegate getAppDelegate].tabBarController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadWebViewControllerWithUrl:(NSString *)url
{
    if (url.length == 0) {
        NSDictionary *argDic = @{Success:@"false", ErrorMessage:ASLocalizedString(@"URL为空,无法唤起网页"), ErrorCode:@"1", Data:@""};
        [self returnResult:self.callbackId args:argDic];
        return;
    }
    
    //回调
    NSDictionary *argDic = @{Success:@"true"};
    [self returnResult:self.callbackId args:argDic];
    
    KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:url];
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}

-(void)theURL:(NSString *)url {
    NSDictionary *argDic = @{ Success:@"true", ErrorMessage:@"", ErrorCode:@"", Data:@{ @"qrcode_str":url}};
    [self returnResult:self.callbackId args:argDic];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0x99) {
        
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        KDCommunityManager *manager = [[KDManagerContext globalManagerContext] communityManager];
        NSMutableArray *companies = [NSMutableArray arrayWithArray:manager.joinedCommpanies];
        [companies removeObject:manager.currentCompany];
        
        [manager setJoinedCommpanies:companies];
        [manager storeCompanies];
        
        //        [[NSNotificationCenter defaultCenter] postNotificationName:KDQuitCompanyFinishedNotification object:nil userInfo:@{@"companies":companies}];
    }
    else{
        if (buttonIndex != alertView.cancelButtonIndex) {
            NSRange range = [self.appUrl rangeOfString:@"url="];
            if (range.location != NSNotFound) {
                NSString *downLoadUrl = [self.appUrl substringFromIndex:range.location + 4];
                NSRange range2 = [downLoadUrl rangeOfString:@"&"];
                if (range2.location != NSNotFound) {
                    downLoadUrl = [downLoadUrl substringToIndex:range2.location];
                }
                
                if (downLoadUrl.length == 0) {
                    return;
                }
                [self returnResult:self.callbackId args:@{ Success: @"true", ErrorMessage:@"", Data:@"" }];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downLoadUrl]];
            }
        }
    }
}
#pragma mark - XTChooseContentViewControllerDelegate

- (void)setupTabBeforetimelineToChat
{
    if ([KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex != 0) {
        [(UINavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController popToRootViewControllerAnimated:NO];
        [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex = 0;
    } else {
        [(UINavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController popToRootViewControllerAnimated:NO];
    }
}

- (void)chooseContentView:(XTChooseContentViewController *)controller group:(GroupDataModel *)group
{
    [self setupTabBeforetimelineToChat];
    [KDWeiboAppDelegate getAppDelegate].timelineViewController.bGoMultiVoiceAfterCreateGroup = self.bGoMultiVoiceAfterCreateGroup;
    [[KDWeiboAppDelegate getAppDelegate].timelineViewController toChatViewControllerWithGroup:group withMsgId:nil];
}

- (void)chooseContentView:(XTChooseContentViewController *)controller person:(PersonSimpleDataModel *)person
{
    [self setupTabBeforetimelineToChat];
    [KDWeiboAppDelegate getAppDelegate].timelineViewController.bGoMultiVoiceAfterCreateGroup = self.bGoMultiVoiceAfterCreateGroup;
    [[KDWeiboAppDelegate getAppDelegate].timelineViewController toChatViewControllerWithPerson:person];
}

/**
 *  选人结束之后调用的方法
 *  alanwong
 */
- (void)chooseContentView:(XTChooseContentViewController *)controller persons:(NSArray *)persons {
    NSDictionary *resultDic = nil;
    NSMutableArray *resultArray = [NSMutableArray array];
    for (PersonSimpleDataModel *person in persons) {
        [resultArray addObject:[self dictionaryWithPerson:person]];
    }
    if ([resultArray count] > 0) {
        NSDictionary *dataDic = [NSDictionary dictionaryWithObjectsAndKeys:resultArray, @"persons", nil];
        resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, dataDic, Data, nil];
    }
    else {
        //正常情况下，这一步不会发生的
        resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"JSBridge_Tip_16"), ErrorMessage, @"1", ErrorCode, nil];
    }
    
    [self returnResult:self.callbackId args:resultDic];
}

#pragma mark - XTChooseContentViewControllerDelegate
-(void)chooseContentView:(XTChooseContentViewController *)controller selectedPerson:(NSArray *)persons
{
    NSDictionary *resultDic = nil;
    NSMutableArray *resultArray = [NSMutableArray array];
    
    NSDictionary *tempDic;
    for (PersonSimpleDataModel *person in persons)
    {
        tempDic = [[NSDictionary alloc] initWithObjectsAndKeys:person.personId, @"personId", person.personName, @"personName", person.photoUrl, @"avatarUrl", person.oid, @"openId", nil];
        [resultArray addObject:tempDic];
    }
    
    if ([resultArray count] > 0)
    {
        NSDictionary *dataDic = [NSDictionary dictionaryWithObjectsAndKeys:resultArray, @"persons", nil];
        resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, dataDic, Data, nil];
    }
    else
    {
        resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"JSBridge_Tip_16"), ErrorMessage, @"1", ErrorCode, nil];
    }
    
    [self returnResult:self.callbackId args:resultDic];
}

-(void)chooseContentView:(XTChooseContentViewController *)controller selectedPersons:(NSArray *)persons {
    NSDictionary *resultDic = nil;
    NSMutableArray *resultArray = [NSMutableArray array];
    
    NSDictionary *tempDic;
    for (PersonSimpleDataModel *person in persons)
    {
        tempDic = [[NSDictionary alloc] initWithObjectsAndKeys:person.personId, @"personId", person.personName, @"name", person.photoUrl, @"avatarUrl",person.oid, @"openId", nil];
        [resultArray addObject:tempDic];
    }
    
    if ([resultArray count] > 0)
    {
        NSDictionary *dataDic = [NSDictionary dictionaryWithObjectsAndKeys:resultArray, @"persons", nil];
        resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, dataDic, Data, nil];
    }
    else
    {
        resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"JSBridge_Tip_16"), ErrorMessage, @"1", ErrorCode, nil];
    }
    
    [self returnResult:self.callbackId args:resultDic];
}

/**
 *  取消选人的时调用的方法
 *  alanwong
 */
- (void)cancelChoosePerson {
    NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"JSBridge_Tip_17"), ErrorMessage, @"1", ErrorCode, nil];
    [self returnResult:self.callbackId args:argDic];
}

/**
 *  把PersonSimpleDataModel数据模型中的personId、personName、photoUrl封装成Dictionary
 *
 *  @param person 目标数据模型
 *
 *  @return 输出的Dictionary
 */
- (NSDictionary *)dictionaryWithPerson:(PersonSimpleDataModel *)person {
    NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:person.personId, @"personId", person.personName, @"personName", person.photoUrl, @"avatarUrl", nil];
    return argDic;
}
#pragma mark -
#pragma mark Location notification
/////////////////////////////////////////////////////////////////////////////////////
- (void)locationDidSucess:(NSNotification *)notifcation {
    DLog(@"notificationSucess received");
    NSDictionary *info = notifcation.userInfo;
    NSArray *array = [info objectForKey:@"locationArray"];
    self.locationDataArray = array;
    self.currentLocationData = [array objectAtIndex:0];
    KDLocationOptionViewController *locationOptionViewController = [[KDLocationOptionViewController alloc] init];
    locationOptionViewController.delegate = self;
    locationOptionViewController.title = ASLocalizedString(@"JSBridge_Tip_8");
    locationOptionViewController.optionsArray = self.locationDataArray;
    locationOptionViewController.locationData = self.currentLocationData;
    //locationOptionViewController.shouldHideDeleteLocationBtn = YES;
    locationOptionViewController.shouldHideBottomView = YES;
    UINavigationController *navigationViewController = [[UINavigationController alloc]initWithRootViewController:locationOptionViewController];
    [self presentViewController:navigationViewController animated:YES completion:nil];
    
    self.isGetingCurrentLocation = NO;
}

- (void)locationDidFailed:(NSNotification *)notifcation {
    
    //返回失败
    NSDictionary *arg = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success,nil];
    [self returnResult:self.callbackId args:arg];

    [self.locationView showErrowMessage];
}

//locationInit
- (void)locationDidInit:(NSNotification *)notifcation {
    [self.locationView showInitMessag];
}
- (void)locationDidstart:(NSNotification *)notifcation {
    [self.locationView showStartMessage];
}
- (void)determineLocation:(KDLocationData *)locationData viewController:(KDLocationOptionViewController *)viewController  beginTimeInterval:(NSTimeInterval)beginTimeInterval
{
    self.currentLocationData = locationData;
    NSDictionary *argDic = [[NSDictionary alloc] initWithObjectsAndKeys:self.currentLocationData.address,@"detailAddress", [NSString stringWithFormat:@"%f",self.currentLocationData.coordinate.latitude],  @"latitude", [NSString stringWithFormat:@"%f",self.currentLocationData.coordinate.longitude], @"longitude", nil];
    NSDictionary *arg = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success,argDic,@"data",nil];
    [self returnResult:self.callbackId args:arg];
    self.isGetingCurrentLocation = NO;
}

#pragma mark - 获取定位
- (void)getLocation:(int)callbackId {
    
    __weak KDWebViewController *weakSelf = self;
//    [KDPopup showHUD:ASLocalizedString(@"正在定位") inView:self.view];
    
    if (!self.detailLocationManager) {
        self.detailLocationManager = [[KDSignInLocationManager alloc] init];
    }
    [self.detailLocationManager startLocationWithSuccessBlock:^(CLLocation *location, KDMapOperationType type) {
        [weakSelf.detailLocationManager startReGeocodeSearchWithLocation:location SuccessBlock:^(KDLocationData *locationData, KDMapOperationType type) {
//            [KDPopup hideHUDInView:weakSelf.view];
            
//            NSString *name = locationData.name ? locationData.name : @"";
//            NSString *address = locationData.address ? locationData.address : @"";
//            NSString *addressDetail = locationData.longAddress ? locationData.longAddress : address;
//            NSString *province = locationData.province ? locationData.province : @"";
//            NSString *city = locationData.city ? locationData.city : @"";
//            NSString *district = locationData.district ? locationData.district : @"";
            
            NSDictionary *args = @{Success : @"true",
                                   ErrorCode : @"0",
                                   Data : @{@"latitude" : @(locationData.coordinate.latitude),
                                            @"longitude" : @(locationData.coordinate.longitude)}};
            [weakSelf returnResult:callbackId args:args];
        } failuredBlock:^(KDLocationData *locationData, KDMapOperationType type) {
//            [KDSignInLocationManager showRegeocodeHudWithOperationType:type inView:weakSelf.view];
            double latitude = locationData ? locationData.coordinate.latitude : 0;
            double longitude = locationData ? locationData.coordinate.longitude : 0;
            NSDictionary *args = @{Success : @"false",
                                   ErrorMessage : ASLocalizedString(@"定位失败"),
                                   ErrorCode : @"1",
                                   Data : @{@"latitude" : @(latitude),
                                            @"longitude" : @(longitude)}};
            [weakSelf returnResult:callbackId args:args];
        }];
    } failuedBlock:^(CLLocation *location, KDMapOperationType type) {
//        [KDSignInLocationManager showLocationHudWithOperationType:type inView:weakSelf.view];
        NSDictionary *args = @{Success : @"false",
                               ErrorMessage : ASLocalizedString(@"定位失败"),
                               ErrorCode : @"1",
                               Data : @{@"latitude" : @(0),
                                        @"longitude" : @(0)}};
        [weakSelf returnResult:callbackId args:args];
    }];
}

#pragma mark - 方法 -

- (void)setOptionMenu:(BOOL)hidden {
    if (!hidden) {
        [self initialOptionMenuButtonWithMenuModels:nil withTitle:nil hiddenShare:YES];
    }
    else {
        self.optionMenuButton.hidden = hidden;
        self.optionMenuView.hidden = YES;
    }
}
- (void)setWebViewTitleBar:(NSDictionary *)args {
    id isShowID = args[@"isShow"];
    if (![isShowID isKindOfClass:[NSNull class]] && isShowID) {
        BOOL isShow = [isShowID boolValue];
        self.isTitleNavHidden = !isShow;
        [self.navigationController setNavigationBarHidden:!isShow];
        [self updateMasonry:!isShow];
    }
}



- (void)getPersonInfoCallBack:(int)callbackId{
    NSDictionary *argDic;
    UserDataModel *user = [BOSConfig sharedConfig].user;
    if (user && [[BOSConfig sharedConfig].user.token length] > 0) {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        if (user.emails.length > 0) {
            [data setObject:user.emails forKey:@"email"];
        }
        if (user.eid.length > 0) {
            [data setObject:user.eid forKey:@"eid"];
        }
        if (user.bizId.length > 0) {
            [data setObject:user.bizId forKey:@"bizId"];
        }
        if (user.name.length > 0) {
            [data setObject:user.name forKey:@"name"];
        }
        if (user.photoUrl.length > 0) {
            [data setObject:user.photoUrl forKey:@"photoUrl"];
        }
        [data setObject:@(user.gender) forKey:@"gender"];
        if (user.oId.length > 0) {
            [data setObject:user.oId forKey:@"openId"];
        }
        if ([BOSConfig sharedConfig].loginUser > 0) {
            [data setObject:[BOSConfig sharedConfig].loginUser forKey:@"userName"];
        }
        if([XTSetting sharedSetting].cloudpassport.length>0)
            [data setObject:[XTSetting sharedSetting].cloudpassport forKey:@"cloudpassport"];
        argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, data, Data, nil];
    }
    else if ([[KDLinkInviteConfig sharedInstance] isExistInvite]) {
        argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", Success, ASLocalizedString(@"用户信息为空"), ErrorMessage, @"1", ErrorCode, nil];
        
        if ([[KDLinkInviteConfig sharedInstance] isExistInvite]) {
            NSString *openid = [[KDLinkInviteConfig sharedInstance] openId];
            if ([openid length] > 0) {
                argDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", Success, [NSDictionary dictionaryWithObjectsAndKeys:openid, @"openId", nil], Data, nil];
            }
        }
    }
    
    [self returnResult:callbackId args:argDic];


}

#pragma mark - XTShareViewDelegate
- (void)shareView:(XTShareView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [KDPopup hideHUD];
    }
    if (buttonIndex == 2) {
        [KDPopup hideHUD];
        XTShareApplicationDataModel *application = alertView.shareData.mediaObject;
        XTShareDataModel *shareData = alertView.shareData;
        if (shareData.shareType == ShareMessageApplication) {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:safeString(application.title)  forKey:@"title"];
            [param setObject:safeString(shareData.appName) forKey:@"appName"];
            [param setObject:safeString(application.cellContent) forKey:@"content"];
            [param setObject:safeString(application.thumbData) forKey:@"thumbData"];
            [param setObject:safeString(application.thumbURL) forKey:@"thumbUrl"];
            [param setObject:application.webpageUrl forKey:@"webpageUrl"];
            [param setObject:application.lightAppId forKey:@"lightAppId"];
            [param setObject:shareData.appId forKey:@"pubAccId"];
            [param setObject:@(shareData.unreadMonitor) forKey:@"unreadMonitor"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            
            if (paramJsonData) {
                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                if (!self.sendMessageClient) {
                    self.sendMessageClient = [[ContactClient alloc] initWithTarget:self action:@selector(sendMessageDidReceived:result:)];
                }
                [self.sendMessageClient toSendMsgWithGroupID:alertView.group.groupId toUserID:nil msgType:MessageTypeShareNews content:application.title msgLent:(int)application.title.length param:paramJsonString clientMsgId:[ContactUtils uuid]];
            }
        }
    }
    
    [self releaseSecondWindow];
}
- (void)sendMessageDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result {
    if (client.hasError || !result.success || result == nil) {
        [KDPopup showHUDToast:ASLocalizedString(@"XTChatUnreadCollectionView_Send_Fail")];
        return;
    }
    [KDPopup hideHUD];
    [self releaseSecondWindow];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)releaseSecondWindow {
    if (self.secondWindow) {
        self.secondWindow.hidden = YES;
        self.secondWindow = nil;
        [[KDWeiboAppDelegate getAppDelegate].window makeKeyAndVisible];
    }
}

#pragma mark - 方法(iAppRevision) -

- (void)showAppRevision:(int)callbackId functionName:(NSString *)funcName args:(NSDictionary *)args {
    [self.callbackIds setObject:@(callbackId) forKey:funcName];
    
    BOOL addStamp = kd_safeBool([args objectForKey:@"addStamp"]);
    NSInteger signType = kd_safeInteger([args objectForKey:@"signType"]);
    NSInteger penType = kd_safeInteger([args objectForKey:@"penType"]);
    NSInteger orientation = kd_safeInteger([args objectForKey:@"orientation"]);  // 0自动，1横屏，2竖屏
    double maxWidth = kd_safeDouble([args objectForKey:@"maxWidth"]);
    double maxHeight = kd_safeDouble([args objectForKey:@"maxHeight"]);
    double webWidth = kd_safeDouble([args objectForKey:@"webWidth"]);
    double webHeight = kd_safeDouble([args objectForKey:@"webHeight"]);
    double penWidth = kd_safeDouble([args objectForKey:@"penWidth"]);
    NSString *stamp = kd_safeString([args objectForKey:@"stampString"]);
    NSString *penColor = kd_safeString([args objectForKey:@"penColor"]);
    NSString *url = kd_safeString([args objectForKey:@"url"]);
    NSString *userName = kd_safeString([args objectForKey:@"userName"]);
    NSString *recordID = kd_safeString([args objectForKey:@"recordId"]);
    NSString *fieldName = kd_safeString([args objectForKey:@"fieldName"]);
    
    if (signType >= KDSignatureTypeHandWritting && signType <= KDSignatureTypeMix) {
        KDSignatureViewController *signatureVC = [[KDSignatureViewController alloc] init];
        signatureVC.type = signType;
        signatureVC.delegate = self;
        
        signatureVC.serverURL = url;
        signatureVC.userName = userName;
        signatureVC.recordID = recordID;
        signatureVC.fieldName = fieldName;
        
        if (addStamp) {
            signatureVC.stamp = stamp;
        }
        
        if (orientation == 2) {
            signatureVC.orientation = UIInterfaceOrientationPortrait;
        } else {
            signatureVC.orientation = UIInterfaceOrientationLandscapeRight;
        }
        
        if (orientation == 0) {
            KDAppDelegate.appRevisionShouAutoRotate = YES;
        } else {
            KDAppDelegate.appRevisionShouAutoRotate = NO;
        }
        
        [signatureVC setMaxSize:CGSizeMake(maxWidth, maxHeight)];
        [signatureVC setWebSize:CGSizeMake(webWidth, webHeight)];
        [signatureVC setPenType:penType color:penColor width:penWidth];
        
        [self presentViewController:signatureVC animated:YES completion:^{ }];
    } else {
        [self returnResult:[self.callbackIds[JS_AppRevision] intValue] args:@{ Success: @"false", ErrorCode: @"1", ErrorMessage: @"不支持该签章类型", Data: @{ } }];
    }
    
}

#pragma mark - startSignFeedback
- (void)startSignFeedback:(int)callbackID functionName:(NSString *)functionName args:(NSDictionary *)args {
    NSString *signId = [args stringForKey:@"signId"];
    NSString *feedbackType = [args stringForKey:@"feedbackType"];
    NSString *exceptionFeedbackReason = [args stringForKey:@"exceptionFeedbackReason"];
    if (signId && feedbackType) {
        __weak KDWebViewController *weakSelf = self;
        
        KDSignInRecord *record = [[KDSignInRecord alloc] init];
        record.singinId = signId;
        record.exceptionType = feedbackType;
        record.exceptionFeedbackReason = exceptionFeedbackReason;
        KDSignInFeedbackViewController *feedbackViewController = [[KDSignInFeedbackViewController alloc] init];
        feedbackViewController.signInRecord = record;
        feedbackViewController.jsBridgeBlock = ^(void) {
            [weakSelf returnResult:callbackID args:@{ Success: @"true", ErrorCode: @"0", Data: @{} }];
        };
        [self.navigationController pushViewController:feedbackViewController animated:YES];
    }
    else {
        [self returnResult:callbackID args:@{ Success: @"false", ErrorCode: @"0", ErrorMessage:@"参数有误"}];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)signatureDidFinished:(NSString *)imageString imageSize:(CGSize)imageSize {
    if (imageString.length > 0) {
        [self returnResult:[self.callbackIds[JS_AppRevision] intValue] args:@{ Success: @"true", ErrorCode: @"0", Data: @{ @"bitmap": imageString, @"width": @(imageSize.width), @"height": @(imageSize.height) } }];
    }
    else {
        [self returnResult:[self.callbackIds[JS_AppRevision] intValue] args:@{ Success: @"false", ErrorCode: @"1", ErrorMessage: @"签章失败", Data: @{ } }];
    }
}

- (void)signatureDidFailed:(NSString *)errorMessage {
    if (![errorMessage isKindOfClass:[NSString class]] || errorMessage.length <= 0) {
        errorMessage = @"";
    }
    
    [self returnResult:[self.callbackIds[JS_AppRevision] intValue] args:@{ Success: @"false", ErrorCode: @"1", Data: @{}, ErrorMessage: errorMessage }];
}
#pragma clang diagnostic pop

#pragma mark - rotateUI
- (void)rotateUI:(int)callbackID functionName:(NSString *)functionName args:(NSDictionary *)args {
    NSString *orientation = [args objectForKey:@"orientation"];
    [self rotateUIWithOrientation:orientation];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self returnResult:callbackID args:@{ Success: @"true", ErrorCode: @"0", Data: @{}}];
    });
}

- (void)rotateUIWithOrientation:(NSString *)orientation {
    
    if(self.orientation == UIInterfaceOrientationPortrait && orientation.length == 0)
        return;
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        int val = UIInterfaceOrientationPortrait;
        self.useJSBridgeOrientation = YES;
        self.orientation = UIInterfaceOrientationPortrait;
        if ([orientation isEqualToString:@"landscape"] || [orientation isEqualToString:@"auto"]) {
            if([orientation isEqualToString:@"landscape"])
            {
                val = UIInterfaceOrientationLandscapeRight;
                self.orientation = UIInterfaceOrientationLandscapeRight;
            }
            else
            {
                self.orientation = NSIntegerMax;
            }
        }
        
        
        if(![orientation isEqualToString:@"auto"])
        {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
    }
}
#pragma mark -KDChooseDepartmentViewControllerDelegate
- (void)didChooseDepartmentModels:(NSArray *)models longName:(NSString *)longName
{
    NSMutableArray *orgids = [NSMutableArray array];
    for (KDChooseDepartmentModel *model in models)
    {
        [orgids addObject:model.strID];
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObject:orgids forKey:@"orgids"];
    NSDictionary *argDic = [NSDictionary dictionaryWithObjectsAndKeys:@"true", Success, @"0", ErrorCode, dic, Data, nil];
    [self returnResult:self.callbackId args:argDic];
}

#pragma mark - 获取设备信息

- (void)getDeviceInfo:(int)callbackID args:(NSDictionary *)args {
    UIDevice *device = [UIDevice currentDevice];
    
    NSString *deviceId = [UIDevice uniqueDeviceIdentifier];// 设备ID
    NSString *os = device.systemName; // 操作系统
    NSString *manufacturer = @"Apple"; // 制造商
    NSString *model = [UIDevice platform]; // 型号
    
    [self returnResult:callbackID args:@{ Success: @"true", ErrorMessage: @"", Data: @{@"deviceId": deviceId, @"os": os, @"manufacturer": manufacturer, @"model": model} }];
}
@end
