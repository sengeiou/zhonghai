//
//  KDApplicationQueryAppsHelper.m
//  kdweibo
//
//  Created by janon on 15/1/14.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//
#import "NSJSONSerialization+KDCategory.h"
#import "KDApplicationQueryAppsHelper.h"
//#import "KDURLPathManager.h"
#import "BOSConfig.h"
//#import "BOSConnect.h"
#import "URL+MCloud.h"

#import "AppsClient.h"
#import "ContactClient.h"
#import "BOSResultDataModel.h"
#import "XTSetting.h"

#import "GroupDataModel.h"
#import "RecordListDataModel.h"
#import "PersonSimpleDataModel.h"
#import "XTmenuModel.h"
#import "XTMenuEachModel.h"
#import "BOSSetting.h"
#import "KDVoiceTimer.h"
#import "NSObject+KDSafeObject.h"


@interface KDApplicationQueryAppsHelper ()
@property (nonatomic, strong) KDAppDataModel *addAppDM;
@property (nonatomic, strong) KDAppDataModel *deleteAppDM;
@property (nonatomic, strong) GroupDataModel *todoGroup;
@property (nonatomic, strong) AppsClient *postOneAppClient;
@property (nonatomic, strong) AppsClient *deleteOneAppClient;
@property (nonatomic, strong) AppsClient *checkUserDefaultClient;
@property (nonatomic, strong) AppsClient *checkUserDefaultAddClient;
@property (nonatomic, strong) AppsClient *postAllLocalAppsToWebClient;
@property (nonatomic, strong) AppsClient *makeNoteClient;
@property (nonatomic, strong) ContactClient *appendMsgClient;                        //响应needUpdate通知，将代办通知缓存本地，同时更新updatetime
@property (nonatomic, strong) ContactClient *appendToDoMsgClient;                    //收到代办状态回调通知时，首先拉取代办的消息体，以防止数据库中还没有消息实体

@property (nonatomic, strong) ContactClient *messageUnreadListClient;                //消息已读未读
@property (nonatomic ,strong) ContactClient *getUnreadCountDetailClient;             //获取消息已读未读详细信息
@property (nonatomic, strong) NSString *unreadCountGroupId;                          //消息已读未读的组ID
@property (nonatomic, strong) NSString *unreadCountMsgId;                            //消息已读未读的消息ID


@property (nonatomic, assign) BOOL isDownLoadingAllToDoMessage;
@property (nonatomic, strong) NSNumber *storeToDoStatusTime;
@property (nonatomic, strong) NSString *grouplistUpdateTime;
@property (nonatomic, strong) MCloudClient *groupTalkClient;

@property (nonatomic, assign) BOOL foldPublicAccountPressOrNot;

@property (nonatomic, strong) UIAlertView *alreadyHaveMultiVoiceAlert;               //已经存在多人语音的时候出现的alert;
@property (nonatomic, assign) BOOL groupTalkOpenOrNot;
@property (nonatomic, strong) UIAlertView *investigateAlert;

@property (nonatomic ,strong) XTOpenSystemClient *getYunSectectClient;  //获取云app secrect
@end

static NSString *const appWarnClick   = @"pubacc/statistics/appWarnClick";
static NSString *const menusClick     = @"pubacc/statistics/menusClick";
static NSString *const changePubMsg   = @"pubacc/msg/changePubMsg";

static NSString *const pubaccMsg      = @"pubacc/msg/";
static NSString *const list           = @"/list?";
static NSString *const changeOtherMsg = @"/ecLite/convers/changeMsgReadStatus.action";
static NSString *const recordTimeline = @"xuntong/ecLite/convers/recordTimeline.action";

@implementation KDApplicationQueryAppsHelper
+(KDApplicationQueryAppsHelper *)shareHelper {
    static dispatch_once_t once;
    static KDApplicationQueryAppsHelper *shareHelper;
    dispatch_once(&once, ^{
        shareHelper = [[self alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:shareHelper selector:@selector(appViewDelete:) name:@"appViewDelete" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:shareHelper selector:@selector(addOneApp:) name:@"AddApp" object:nil];
    });
    return shareHelper;
}

-(GroupDataModel *)todoGroup {
//    if (!_todoGroup) {
        _todoGroup = [[XTDataBaseDao sharedDatabaseDaoInstance] queryTodoMsgInXT];
//    }
    return _todoGroup;
}
-(ContactClient *)appendMsgClient
{
    if (!_appendMsgClient) {
        _appendMsgClient = [[ContactClient alloc]initWithTarget:self action:@selector(appendMsgClientDidReceived:result:)];
    }
    return _appendMsgClient;
}

-(ContactClient *)appendToDoMsgClient {
    if (!_appendToDoMsgClient) {
        _appendToDoMsgClient = [[ContactClient alloc]initWithTarget:self action:@selector(appendToDoMsgClientDidReceived:result:)];
    }
    return _appendToDoMsgClient;
}
-(AppsClient *)client {
    if (!_client) {
        _client = [[AppsClient alloc]initWithTarget:self action:@selector(queryAllAppsDidReceived:result:)];
    }
    return _client;
}

-(AppsClient *)KingdeeLocalAppClient {
    if (!_KingdeeLocalAppClient) {
        _KingdeeLocalAppClient = [[AppsClient alloc]initWithTarget:self action:@selector(queryAppListForKingdeeLocalDidReceived:result:)];
    }
    return _KingdeeLocalAppClient;
}

-(AppsClient *)postOneAppClient {
    if (!_postOneAppClient) {
        _postOneAppClient = [[AppsClient alloc]initWithTarget:self action:@selector(postOneAppDidReceive:result:)];
    }
    return _postOneAppClient;
}

-(AppsClient *)deleteOneAppClient {
    if (!_deleteOneAppClient) {
        _deleteOneAppClient = [[AppsClient alloc]initWithTarget:self action:@selector(deleteOneAppDidReceive:result:)];
    }
    return _deleteOneAppClient;
}

-(AppsClient *)checkUserDefaultClient {
    if (!_checkUserDefaultClient) {
        _checkUserDefaultClient = [[AppsClient alloc]initWithTarget:self action:@selector(checkUserDefaultDidReceived:result:)];
    }
    return _checkUserDefaultClient;
}

-(AppsClient *)checkUserDefaultAddClient {
    if (!_checkUserDefaultClient) {
        _checkUserDefaultClient = [[AppsClient alloc]initWithTarget:self action:@selector(checkUserDefaultAddDidReceive:result:)];
    }
    return _checkUserDefaultClient;
}

-(AppsClient *)postAllLocalAppsToWebClient {
    if (!_postAllLocalAppsToWebClient) {
        _postAllLocalAppsToWebClient = [[AppsClient alloc]initWithTarget:self action:@selector(postAllLocalAppsToWebDidReceived:result:)];
    }
    return _postAllLocalAppsToWebClient;
}

-(AppsClient *)makeNoteClient {
    if (!_makeNoteClient) {
        _makeNoteClient = [[AppsClient alloc]initWithTarget:self action:nil];
    }
    return _makeNoteClient;
}

-(MCloudClient *)groupTalkClient {
    if (!_groupTalkClient) {
        _groupTalkClient = [[MCloudClient alloc]initWithTarget:self action:@selector(groupTalkDidReceive:result:)];
    }
    return _groupTalkClient;
}

-(ContactClient *)messageUnreadListClient
{
    if (!_messageUnreadListClient) {
        _messageUnreadListClient = [[ContactClient alloc]initWithTarget:self action:@selector(messageUnreadListClientDidReceived:result:)];
    }
    return _messageUnreadListClient;
}

-(ContactClient *)getUnreadCountDetailClient
{
    if (!_getUnreadCountDetailClient)
    {
        _getUnreadCountDetailClient = [[ContactClient alloc]initWithTarget:self action:@selector(getUnreadCountDetailClientDidReceive:result:)];
    }
    return _getUnreadCountDetailClient;
}

-(XTOpenSystemClient *)getYunSectectClient
{
    if (!_getYunSectectClient) {
        _getYunSectectClient = [[XTOpenSystemClient alloc]initWithTarget:self action:@selector(getYunSectectDidReceive:result:)];
    }
    return _getYunSectectClient;
}

-(BOOL)foldPublicAccountPressOrNot {
    if (!_foldPublicAccountPressOrNot) {
        _foldPublicAccountPressOrNot = NO;
    }
    return _foldPublicAccountPressOrNot;
}
-(NSString *)grouplistUpdateTime {
    if (!_grouplistUpdateTime) {
        _grouplistUpdateTime = @"";
    }
    return _grouplistUpdateTime;
}
-(BOOL)isDownLoadingAllToDoMessage {
    if (!_isDownLoadingAllToDoMessage) {
        _isDownLoadingAllToDoMessage = NO;
    }
    return _isDownLoadingAllToDoMessage;
}
#pragma mark - XT
-(void)checkAppLastUpdateTime:(NSString *)appLastUpdateTime
{
//    id temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"PostAllLocalAppsId"];
    
//    //排除还未上传全部本地应用的情况，还未上传全部应用时，等待上传全部应用并啦一次
//    if ([temp isKindOfClass:[NSString class]] && [temp isEqualToString:@"Yes"])
//    {
//        
//        if ([XTSetting sharedSetting].appLastUpdateTime == nil)
//        {
//            [self.client queryAppList];
//            [XTSetting sharedSetting].appLastUpdateTime = appLastUpdateTime;
//            [[XTSetting sharedSetting] saveSetting];
//        }
//        
//        if ([appLastUpdateTime compare:[XTSetting sharedSetting].appLastUpdateTime] == NSOrderedDescending)
//        {
//            [self.client queryAppList];
//            [XTSetting sharedSetting].appLastUpdateTime = appLastUpdateTime;
//            [[XTSetting sharedSetting] saveSetting];
//        }
//        
//    }
}

-(void)checkMsgFromSystemWithSystemType:(NSString *)systemType Msg:(NSDictionary *)msg
{
    if ([systemType isEqualToString:@"open"])
    {
        
    }
    
    if ([systemType isEqualToString:@"pubAcct"])
    {
        
    }
}
-(void)checkMsgFromSystemPubWithArray:(NSArray *)array
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];   //这个地方只能用for循环,不能用enum迭代器
    
    NSDictionary *tempDic = nil;
    for (NSInteger i = 0; i < array.count; i++)
    {
        tempDic = array[i];
        
        if ([[tempDic objectForKey:@"system"] isEqualToString:@"pub"])
        {
            NSNumber *oldTime = [ud objectForKey:@"ToDoStatusLastUpdateTime"];
            NSNumber *newTime = [[tempDic objectForKey:@"msg"] objectForKey:@"lastUpdateTime"];
            
            id tempString = [ud objectForKey:@"TheFirstTimePullAllToDoMsg"];
            if ([tempString isKindOfClass:[NSString class]] && tempString != nil && tempString != 0)
            {
                if ([oldTime compare:newTime] == NSOrderedAscending)
                {
                    [self queryToDoStatusTypeOneWithTime:oldTime Block:^
                     {
                         NSDictionary *dic = @{@"info":@"updateTodoState"};
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"updateToDoMessageDidReceive" object:nil userInfo:dic];
                     }];
                    DLog(@"收到了代办消息状态的回调,开始获取代办的消息状态");
                    
                    [ud setObject:newTime forKey:@"ToDoStatusLastUpdateTime"];
                    [ud synchronize];
                }
            }
        }
    }
}
#pragma mark - queryAppList
-(void)queryWhenChangeWorkPlaceAndLogin
{
    id temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"PostAllLocalAppsId"];
    
    if ([temp isKindOfClass:[NSString class]] && [temp isEqualToString:@"Yes"])
    {
        [self.client queryAppList];
    }
}

-(void)queryAppsList
{
    [self.client queryAppList];
}

-(void)queryAllAppsDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    if (result == nil || ![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (result.success)
    {
        NSMutableArray *tempMutableArray = [self checkNativeAppEnsureNotDeleted];
        [self deletePersonalAppInDataBase:tempMutableArray];
        
        NSArray *array = [result.dictJSON objectForKey:@"data"];
        [self addPersonAppsFromWebIntoDataBase:array];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveNotice" object:nil];
    }
}


#pragma mark - queryAppListHelper
-(void)addPersonAppsFromWebIntoDataBase:(NSArray *)appDataModels
{
    NSMutableArray *finalArray = [NSMutableArray array];
    [appDataModels enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger i, BOOL *stop)
     {
         [finalArray addObject:[[KDAppDataModel alloc]initWithDictionaryFromWeb:dic]];
     }];
    
    NSArray *alreadyHaveArray = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonalAppList];
    [alreadyHaveArray enumerateObjectsUsingBlock:^(KDAppDataModel *model, NSUInteger i, BOOL *stop)
     {
         [finalArray addObject:model];
     }];
    
    [finalArray enumerateObjectsUsingBlock:^(KDAppDataModel *model, NSUInteger i, BOOL *stop) {
        [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonalAppDataModel:model];
    }];
    
    //    for (NSInteger i = 0; i < appDataModels.count; i++)
    //    {
    //        NSDictionary *tempDic = appDataModels[i];
    //        KDAppDataModel *model = [[KDAppDataModel alloc]initWithDictionaryFromWeb:tempDic];
    //
    //        [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonalAppDataModel:model];
    //    }
}

-(void)deletePersonalAppInDataBase:(NSMutableArray *)appIdArray
{
    for (int i = 0; i < appIdArray.count; i++)
    {
        [[XTDataBaseDao sharedDatabaseDaoInstance] deletePersonalApp:appIdArray[i]];
    }
}

-(NSMutableArray *)checkNativeAppEnsureNotDeleted
{
    
    NSMutableArray *tempMutableIdArray = [NSMutableArray array];
    NSArray *tempArray = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonalAppList];
    
    [tempArray enumerateObjectsUsingBlock:^(KDAppDataModel *model, NSUInteger i, BOOL *stop)
     {
         if (model.appType == KDAppTypeNativeKingdee && [self checkIfIsKingdeeNativeApp:model.appName])
         {
             //是本地应用，但不是这五个应用之一, 就不加到tempMutableArray里面
         }
         else
         {
             if (model.appType ==KDAppTypePublic)
             {
                 [tempMutableIdArray addObject:model.pid];
             }
             else if (model.appType == KDAppTypeLight || model.appType == KDAppTypeNativeKingdee)
             {
                 [tempMutableIdArray addObject:model.appClientID];
             }
         }
     }];
    
    return tempMutableIdArray;
}

- (BOOL)checkIfIsKingdeeNativeApp:(NSString *)string {
    
    BOOL QianDao    = [string isEqualToString:ASLocalizedString(@"KDApplicationQueryAppsHelper_sign")];
    BOOL RenWu      = [string isEqualToString:ASLocalizedString(@"KDApplicationQueryAppsHelper_task")];
    BOOL WenJian    = [string isEqualToString:ASLocalizedString(@"KDApplicationQueryAppsHelper_file")];
    BOOL BuLuo      = [string isEqualToString:ASLocalizedString(@"KDApplicationQueryAppsHelper_blog")];
    BOOL SaoYiSao   = [string isEqualToString:ASLocalizedString(@"KDApplicationQueryAppsHelper_scan")];
    
    //不是这五个中的一员，deleteAble就是No
    BOOL deleteAble = QianDao || RenWu || WenJian || BuLuo || SaoYiSao;
    
    //如果是No, 返回就是Yes, 说明这个app是金蝶的本地应用，但是是这五个应用之外的本地应用
    return !deleteAble;
}

#pragma mark - updateKingdeeLocalAppToWebWhenUpdateToV5.0.3
-(void)queryAppListForKingdeeLocal {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    id tempString = [ud objectForKey:@"WebHasKingdeeDefualt"];
    if (tempString == nil || tempString == 0) {
        [self.KingdeeLocalAppClient queryAppList];
    }
}

-(void)queryAppListForKingdeeLocalDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result {
    if (result.success) {
        NSMutableArray *tempMutableArray = [self checkNativeAppEnsureNotDeleted];
        [self deletePersonalAppInDataBase:tempMutableArray];
        
        NSArray *array = [result.dictJSON objectForKey:@"data"];
        [self addPersonAppsFromWebIntoDataBase:array];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"Yes" forKey:@"WebHasKingdeeDefualt"];
        [ud synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveNotice" object:nil];
    }
    
    self.KingdeeLocalAppClient = nil;
}

#pragma mark - addApp
-(void)addOneApp:(NSNotification *)sender {
    NSDictionary *dic = sender.userInfo;
    BOOL isYunApp = [[dic objectForKey:@"isYunApp"] boolValue];
    KDAppDataModel *appDM = [dic objectForKey:@"appDM"];
    self.addAppDM = appDM;
    if(isYunApp)
       [self.getYunSectectClient getYunAppSecrect:appDM.appID];//先获取secrect,yunApp必须等服务器添加完成才添加到本地
    else
       [self.postOneAppClient postOneApp:appDM];
}


-(void)getYunSectectDidReceive:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (result.success)
    {
        NSString *appSecret = result.data;
        //添加云app
        if(appSecret.length>0)
        {
            self.addAppDM.appSecret = appSecret;
            [self.postOneAppClient postCloudApp:self.addAppDM];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"KDApplicationQueryAppsHelper_add_fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alertView show];
    }
    self.getYunSectectClient = nil;
}


-(void)postOneAppDidReceive:(AppsClient *)client result:(BOSResultDataModel *)result {
    
    KDAppDataModel *appDM = self.addAppDM;
    if (result.success) {
        
        if(appDM.appType == KDAppTypeYunApp)
        {
            //保存到本地,并重取数据
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:appDM, @"appDM", nil];
            NSNotification *notification = [NSNotification notificationWithName:@"Personal_App_Add" object:nil userInfo:dic];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }
    else {
        if(appDM.appType!=KDAppTypeYunApp)
            [self storeAppToBeAddIntoUserDefault:self.addAppDM];
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:ASLocalizedString(@"KDApplicationQueryAppsHelper_add_fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alertView show];
        }
    }
    self.postOneAppClient = nil;
}

-(void)storeAppToBeAddIntoUserDefault:(KDAppDataModel *)appDM {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tempMutableArray;
    NSArray *tempArray;
    
    tempArray = [ud objectForKey:@"AddNetWorkNotReachable"];
    
    if (tempArray == nil || tempArray == 0) {
        
        //如果按NewWordNotReachable找不到值，创建一个数组加入当前appId
        tempMutableArray = [NSMutableArray array];
        
        if(appDM.appClientID != nil) {
            int appid = [appDM.appClientID intValue] / 100;
            [tempMutableArray addObject:[NSString stringWithFormat:@"%d", appid]];
        }
        
        if (appDM.pid != nil) {
            [tempMutableArray addObject:appDM.pid];
        }
        
    }else {
        
        //如果NSUserDefaults已经有这个被删除的应用直接return
        for (int i = 0; i < tempArray.count; i++) {
            NSString *tempString = tempArray[i];
            
            if(appDM.appClientID != nil) {
                NSString *appid = [NSString stringWithFormat:@"%d", [appDM.appClientID intValue] / 100];
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
            NSString *appid = [NSString stringWithFormat:@"%d", [appDM.appClientID intValue] / 100];
            [tempMutableArray addObject:appid];
        }
        
        if (appDM.pid != nil) {
            [tempMutableArray addObject:appDM.pid];
        }
        
    }
    
    tempArray = [NSArray arrayWithArray:tempMutableArray];
    
    [ud setObject:tempArray forKey:@"AddNetWorkNotReachable"];
    [ud synchronize];
}

#pragma mark - deleteApp
-(void)appViewDelete:(NSNotification *)sender {
    NSDictionary *dic = sender.userInfo;
    KDAppDataModel *appDM = [dic objectForKey:@"appDM"];
    
    self.deleteAppDM = appDM;
    [self.deleteOneAppClient deleteOneApp:appDM];
}

-(void)deleteOneAppDidReceive:(AppsClient *)client result:(BOSResultDataModel *)result {
    if (result.success)
    {
        [[XTDataBaseDao sharedDatabaseDaoInstance] deletePersonalApp:self.deleteAppDM.appClientID];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reLoadApplist" object:@"delete"];
        return;
    }
    else
    {
        //删除失败
        [KDPopup showHUDToast:ASLocalizedString(@"KDApplicationViewController_del_fail")];
        //[self storeAppToBeDeletedIntoUserDefault:self.deleteAppDM];
    }
    self.deleteOneAppClient = nil;
}

-(void)storeAppToBeDeletedIntoUserDefault:(KDAppDataModel *)appDM {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tempMutableArray;
    NSArray *tempArray;
    
    tempArray = [ud objectForKey:@"NetWorkNotReachable"];
    
    if (tempArray == nil || tempArray == 0) {
        
        //如果按NewWordNotReachable找不到值，创建一个数组加入当前appId
        tempMutableArray = [NSMutableArray array];
        
        if(appDM.appClientID != nil) {
            int appid = [appDM.appClientID intValue] / 100;
            [tempMutableArray addObject:[NSString stringWithFormat:@"%d", appid]];
        }
        
        if (appDM.pid != nil) {
            [tempMutableArray addObject:appDM.pid];
        }
        
    }else {
        
        //如果NSUserDefaults已经有这个被删除的应用直接return
        for (int i = 0; i < tempArray.count; i++) {
            NSString *tempString = tempArray[i];
            
            if(appDM.appClientID != nil) {
                NSString *appid = [NSString stringWithFormat:@"%d", [appDM.appClientID intValue] / 100];
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
            NSString *appid = [NSString stringWithFormat:@"%d", [appDM.appClientID intValue] / 100];
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

#pragma mark - upLoadAllLocalAppWhenUpdateToV5.0.0
-(void)postAllLocalAppsId {
    NSMutableString *tempMutableString = [NSMutableString string];
    id temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"PostAllLocalAppsId"];
    
    if (temp == nil || temp == 0)
    {
        NSArray *showAppArr = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonalAppList];
        
        int appIdFromappClientId = 0;
        KDAppDataModel *appDM;
        for (int i = 0; i < showAppArr.count; i++)
        {
            appDM = showAppArr[i];
            
            if (i == (showAppArr.count - 1))
            {
                if (appDM.appType == KDAppTypeLight || appDM.appType == KDAppTypeNativeKingdee)
                {
                    appIdFromappClientId = [appDM.appClientID intValue] / 100;
                    tempMutableString = [NSMutableString stringWithFormat:@"%@%d", tempMutableString, appIdFromappClientId];
                    
                }
                else if (appDM.appType == KDAppTypePublic)
                {
                    tempMutableString = [NSMutableString stringWithFormat:@"%@%@", tempMutableString, appDM.pid];
                }
                
            }
            else
            {
                if (appDM.appType == KDAppTypeLight || appDM.appType == KDAppTypeNativeKingdee)
                {
                    appIdFromappClientId = [appDM.appClientID intValue] / 100;
                    tempMutableString = [NSMutableString stringWithFormat:@"%@%d,", tempMutableString, appIdFromappClientId];
                }
                else if (appDM.appType == KDAppTypePublic)
                {
                    tempMutableString = [NSMutableString stringWithFormat:@"%@%@,", tempMutableString, appDM.pid];
                    
                }
            }
        }
        
        [self.postAllLocalAppsToWebClient postAllLocalApps:tempMutableString];
    }
}

-(void)postAllLocalAppsToWebDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    if (result.success)
    {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"Yes" forKey:@"PostAllLocalAppsId"];
        [ud synchronize];
        return;
    }
    self.postAllLocalAppsToWebClient = nil;
}

#pragma mark - deleteAppsWhenWithOutNetWork
-(void)checkUserDefaultForAppBeenDeletedWithoutNetWork {
    //记得这个key要换成NetWorkNotReachable
    id array = [[NSUserDefaults standardUserDefaults] objectForKey:@"NetWorkNotReachable"];
    
    if (array == nil || array == 0) {
        return;
    }
    
    NSArray *tempArray = array;
    NSMutableString *tempString = [NSMutableString string];
    
    for (int i = 0; i < tempArray.count; i++) {
        NSString *str = tempArray[i];
        DLog(@"str = %@", str);
        
        if (i == (tempArray.count - 1))
        {
            tempString = [NSMutableString stringWithFormat:@"%@%@", tempString, str];
        }
        else
        {
            tempString = [NSMutableString stringWithFormat:@"%@%@,", tempString, str];
        }
    }
    
    [self.checkUserDefaultClient deleteFromNSUserDefaultWithApps:tempString];
    
    //返回成功才去除掉NSUserDefault里面的数据, 记得key是NetWorkNotReachable
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NewWordNotReachable"];
    
}

-(void)checkUserDefaultDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result {
    if (result.success) {
        //正常情况下放开这个
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud removeObjectForKey:@"NetWorkNotReachable"];
        [ud synchronize];
    }
    self.checkUserDefaultClient = nil;
}

#pragma mark - addAppWhenWithOutNetWork
-(void)checkUserDefaultForAppBeingAddWithOutNetWork {
    //记得这个key要换成NetWorkNotReachable
    id array = [[NSUserDefaults standardUserDefaults] objectForKey:@"AddNetWorkNotReachable"];
    
    if (array == nil || array == 0) {
        return;
    }
    
    NSArray *tempArray = array;
    NSMutableString *tempString = [NSMutableString string];
    
    for (int i = 0; i < tempArray.count; i++) {
        NSString *str = tempArray[i];
        DLog(@"str = %@", str);
        
        if (i == (tempArray.count - 1)) {
            tempString = [NSMutableString stringWithFormat:@"%@%@", tempString, str];
            
        }else {
            tempString = [NSMutableString stringWithFormat:@"%@%@,", tempString, str];
        }
    }
    
    [self.checkUserDefaultAddClient postAllLocalApps:tempString];
    
    //返回成功才去除掉NSUserDefault里面的数据, 记得key是NetWorkNotReachable
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NewWordNotReachable"];
}

-(void)checkUserDefaultAddDidReceive:(AppsClient *)client result:(BOSResultDataModel *)result {
    if (result.success) {
        //正常情况下放开这个
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud removeObjectForKey:@"AddNetWorkNotReachable"];
        [ud synchronize];
    }
    self.checkUserDefaultAddClient = nil;
}

#pragma mark - pubAccountBtnClickedMakeNote
-(void)makeNoteWhenMenuBtnClickedWithGroup:(GroupDataModel *)group MenuModel:(XTmenuModel *)record {
//    PersonSimpleDataModel *person = [group firstParticipant];
//    [self makeNoteForPubAccountBtnClickedWithPubId:person.personId MenuId:record.ID];
}

-(void)makeNoteWhenMenuBtnClickedWithGroup:(GroupDataModel *)group EachModel:(XTMenuEachModel *)each {
//    PersonSimpleDataModel *person = [group firstParticipant];
//    [self makeNoteForPubAccountBtnClickedWithPubId:person.personId MenuId:each.ID];
}

-(void)makeNoteForPubAccountMsgClickedWithPubId:(NSString *)pubId MsgId:(NSString *)msgId
{
    NSString *path = MCLOUD_IP_FOR_PUBACC;
    path = [path stringByAppendingString:appWarnClick];
    NSURL *pathUrl = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pathUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:[BOSConnect userAgent] forHTTPHeaderField:@"User-Agent"];
    [request setHTTPBody:[[NSString stringWithFormat:@"pubId=%@&msgId=%@&ua=%@", pubId, msgId, [BOSConnect userAgent]] dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){}];
}

-(void)makeNoteForPubAccountBtnClickedWithPubId:(NSString *)pubId MenuId:(NSString *)menuId
{
    NSString *path = MCLOUD_IP_FOR_PUBACC;
    path = [path stringByAppendingString:menusClick];
    NSURL *pathUrl = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pathUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:[BOSConnect userAgent] forHTTPHeaderField:@"User-Agent"];
    [request setHTTPBody:[[NSString stringWithFormat:@"pubId=%@&menuId=%@&ua=%@", pubId, menuId, [BOSConnect userAgent]] dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {}];
}

#pragma mark - todoMsgStateChange
-(void)todoMsgStateChangeWithSourceMsgId:(NSString *)sourceMsgId
                                PersonId:(NSString *)personId
                               ReadState:(BOOL)readstate
                               DoneState:(BOOL)doneState
{
//    NSString *strReadState = readstate?@"true":@"false";
//    NSString *strDoneState = doneState?@"true":@"false";
//    
//    NSString *path = [[[KDURLPathManager sharedURLPathManager] baseUrl] stringByAppendingString:changePubMsg];
//    NSURL *pathUrl = [NSURL URLWithString:path];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pathUrl];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:[BOSConnect userAgent] forHTTPHeaderField:@"User-Agent"];
//    [request setHTTPBody:[[NSString stringWithFormat:@"sourceMsgId=%@&userId=%@&readStatus=%@&doneStatus=%@&ua=%@", sourceMsgId, personId, strReadState, strDoneState, [BOSConnect userAgent]] dataUsingEncoding:NSUTF8StringEncoding]];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {}];
}

-(void)todoMsgStateChangeWithmsgId:(NSString *)sourceMsgId
                          PersonId:(NSString *)personId
                         ReadState:(BOOL)readstate
                         DoneState:(BOOL)doneState
{
    
}

#pragma mark - subscribeMessageRedPointShowOrNot
-(void)setFoldPublicAccountPressYes
{
    self.foldPublicAccountPressOrNot = YES;
}

-(void)setFoldPublicAccountPressNo
{
    self.foldPublicAccountPressOrNot = NO;
}

-(BOOL)getFoldPublicAccountPressState
{
    return self.foldPublicAccountPressOrNot;
}

#pragma mark - MultiVoiceNetWork
-(void)showAlreadyHaveMultiVoiceAlert
{
    NSString *message = [NSString stringWithFormat:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips_conversatin"), self.multiVoiceTimer.groupName];
    self.alreadyHaveMultiVoiceAlert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_yes")otherButtonTitles:ASLocalizedString(@"KDApplicationQueryAppsHelper_no"), nil];
    [self.alreadyHaveMultiVoiceAlert show];
}

-(KDVoiceTimer *)multiVoiceTimer
{
    if (!_multiVoiceTimer) {
        _multiVoiceTimer = [[KDVoiceTimer alloc]init];
    }
    return _multiVoiceTimer;
}

-(void)checkGroupTalkAvailableOrNot
{
    [self.groupTalkClient getAppParamsWithCust3gNo:[BOSSetting sharedSetting].cust3gNo];
}

-(void)groupTalkDidReceive:(AppsClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError)
    {
        return;
    }
    
    if (result.success)
    {
        NSDictionary *params = result.data[@"params"];
        if (params && [params isKindOfClass:[NSDictionary class]])
        {
            NSInteger tempInt = [[params objectForKey:@"groupTalk"] integerValue];
            
            if (tempInt == 0)
            {
                self.groupTalkOpenOrNot = NO;
                DLog(@"groupTalk = %d", self.groupTalkOpenOrNot);
            }
            else if (tempInt == 1)
            {
                self.groupTalkOpenOrNot = YES;
                DLog(@"groupTalk = %d", self.groupTalkOpenOrNot);
            }
            else
            {
                self.groupTalkOpenOrNot = NO;
                DLog(@"groupTalk = %d", self.groupTalkOpenOrNot);
            }
        }
    }
}

-(BOOL)getGroupTalkStatus
{
    return self.groupTalkOpenOrNot ? YES : NO;
}

-(void)buildMultiVoiceTimerWithGroupId:(NSString *)groupid GroupName:(NSString *)groupname
{
    //在第一次进入chatViewController的时候设置好groupId,后面的join和cancel都是用这个groupId,轮训根据这个id判断是不是要开始轮训
    
    if (![groupid hasPrefix:@"XT"])
    {
        self.multiVoiceTimer.groupId = groupid;
        self.multiVoiceTimer.groupName = groupname;
    }
    else
    {
        self.multiVoiceTimer.groupId = nil;
        self.multiVoiceTimer.groupName = nil;
    }
}

-(NSString *)getMultiVoiceTimerGroupId
{
    return self.multiVoiceTimer.groupId;
}

-(void)setMultiVoiceUid:(NSInteger)uid
{
    self.multiVoiceTimer.agoraUid = uid;
}

-(NSUInteger)getMultiVoiceUid
{
    return self.multiVoiceTimer.agoraUid;
}

-(void)startMultiVoiceTimer
{
    [self.multiVoiceTimer startTimer];
}

-(void)cancelMultiVoiceTimer
{
    [self.multiVoiceTimer cancelTimer];
}

-(void)joinMultiVoiceSession
{
    [self.multiVoiceTimer join];
}

-(void)quitMultiVoiceSession
{
    [self.multiVoiceTimer quit];
    
    self.multiVoiceTimer.groupId = nil;
    self.multiVoiceTimer.groupName = nil;
    self.multiVoiceTimer.agoraUid = nil;
    self.multiVoiceTimer.count = nil;
    self.multiVoiceTimer.personArray = nil;
    self.multiVoiceTimer.lastUpdateTime = nil;
}

#pragma mark - makeNoteWhenAppClicked
-(void)makeNoteWhenAppClickedWithAppDataModel:(KDAppDataModel *)model
{
    /*if (model.appType == KDAppTypePublic)
    {
        [self.makeNoteClient makeNoteWhenAppClickedWithMid:nil Appid:model.pid PersonId:nil];
    }
    else
    {
        NSString *appId = [NSString stringWithFormat:@"%d", [model.appClientID intValue] / 100];
        [self.makeNoteClient makeNoteWhenAppClickedWithMid:nil Appid:appId PersonId:nil];
    }*/
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:self.alreadyHaveMultiVoiceAlert])
    {
        if (buttonIndex == 0)
        {
            
        }
        
        if (buttonIndex == 1)
        {
            //加上一个语音会话关闭，开启一个新的语音会话
            [self quitMultiVoiceSession];
//            [self.agoraAudio leaveChannel];
            
            DLog(@"这个地方要放入创建新会话的语句");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoNewMultiVoiceView" object:nil userInfo:nil];
        }
    }
}

#pragma mark - appendToDoMessageWhenPolling
-(void)checkAndAppendToDoMsgWithGroupList:(GroupListDataModel *)list
{
    DLog(@"收到了新的代办通知消息体,开始检测其中有没有代办通知");
    
    __block BOOL hasToDoGroupOrNot = NO;
    __block NSDictionary *dic = nil;
    [list.list enumerateObjectsUsingBlock:^(GroupDataModel *group, NSUInteger i, BOOL *stop)
     {
         if (group.groupType == GroupTypeTodo)
         {
             //先取数据
             [[NSUserDefaults standardUserDefaults]setInteger:group.notifyUnreadCount forKey:@"notifyUnreadCount"];
             [[NSUserDefaults standardUserDefaults]setInteger:group.undoCount forKey:@"undoCount"];
             [[NSUserDefaults standardUserDefaults]setInteger:group.lastIgnoreNotifyScore forKey:@"lastIgnoreNotifyScore"];
             [[XTDataBaseDao sharedDatabaseDaoInstance]updateUndoMsgWithLastIgnoreNotifyScore:[NSString stringWithFormat:@"%ld",group.lastIgnoreNotifyScore]];
             dic = [NSDictionary dictionaryWithObjectsAndKeys:group.lastMsg.todoStatus,@"todoStatus", nil];
             hasToDoGroupOrNot = YES;
             *stop = YES;
         }
     }];
    if (hasToDoGroupOrNot == YES)
    {
        //发出通知如果KDToDoViewController存在就会响应这个方法
        [[NSNotificationCenter defaultCenter] postNotificationName:@"recordToDoTimeLine" object:nil userInfo:dic];
    }
}

//-(void)recordTimeLineWithGroupToDo
//{
//    GroupDataModel *model = [[XTDataBaseDao sharedDatabaseDaoInstance] queryFullPublicGroupWithPersonId:kTodoPersonId];
//    [self.appendMsgClient getRecordTimeLineWithGroupID:model.groupId userId:nil updateTime:model.updateTime];
//}

-(void)deleteFirstPullAllToDoStatusWhenCheckWorkPlaceOrSignIn
{
    id tempString = [[NSUserDefaults standardUserDefaults] objectForKey:@"TheFirstTimePullAllToDoMsg"];
    NSString *currentUser = [NSString stringWithFormat:@"%@&%@", [BOSConfig sharedConfig].user.userId, [BOSConfig sharedConfig].user.eid];
    
    if ([tempString isKindOfClass:[NSString class]] && ![tempString isEqualToString:currentUser])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TheFirstTimePullAllToDoMsg"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
//-(void)appendMsgClientDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
//{
//    if (result.success)
//    {
//        RecordListDataModel *origionRecord = [[RecordListDataModel alloc] initWithDictionary:result.data];
//        
//        if ([self.grouplistUpdateTime compare:origionRecord.updateTime] == NSOrderedAscending || [self.grouplistUpdateTime isEqualToString:@""])
//        {
//            //插入消息表，防止有别的用途
//            [[XTDataBaseDao sharedDatabaseDaoInstance] insertToDoRecords:origionRecord.list];
//            
//            //更新时间
//            GroupDataModel *model = [[XTDataBaseDao sharedDatabaseDaoInstance] queryFullPublicGroupWithPersonId:kTodoPersonId];
//            [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithUpdateTime:origionRecord.updateTime withGroupId:model.groupId];
//            self.grouplistUpdateTime = origionRecord.updateTime;
//            
//            //状态更新完成，告知代办状态更新完成
//            NSDictionary *dic = @{@"info":@"updateTodoMessage", @"count":[NSNumber numberWithInteger:origionRecord.list.count]};
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateToDoMessageDidReceive" object:nil userInfo:dic];
//            
//            DLog(ASLocalizedString(@"跟新完代办,发送通知告知代办更新完成"));
//        }
//    }
//    
//    self.appendMsgClient = nil;
//}

//-(void)pullAndStoreAllToDoMsgInDataBase
//{
//    GroupDataModel *model = [[XTDataBaseDao sharedDatabaseDaoInstance] queryFullPublicGroupWithPersonId:kTodoPersonId];
//    
//    id tempString = [[NSUserDefaults standardUserDefaults] objectForKey:@"TheFirstTimePullAllToDoMsg"];
//    if (tempString == nil || tempString == 0)
//    {
//        DLog(ASLocalizedString(@"进入了重新安装下载代办的函数,开始下载了"));
//        self.isDownLoadingAllToDoMessage = YES;
//        
//        NSString *path = [[BOSSetting sharedSetting].url stringByAppendingString:recordTimeline];
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
//        [request setValue:[BOSConnect userAgent] forHTTPHeaderField:@"User-Agent"];
//        [request setValue:[BOSConfig sharedConfig].user.token forHTTPHeaderField:@"openToken"];
//        [request setHTTPMethod:@"POST"];
//        [request setHTTPBody:[[NSString stringWithFormat:@"userId=%@&lastUpdateTime=%@&groupId=%@&ua=%@", @"", @"", model.groupId, [BOSConnect userAgent]] dataUsingEncoding:NSUTF8StringEncoding]];
//        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
//         {
//             NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data];
//             
//             //插入下载下来的所有代办消息
//             RecordListDataModel *records = [[RecordListDataModel alloc] initWithDictionary:[result objectForKey:@"data"]];
////             [[XTDataBaseDao sharedDatabaseDaoInstance] insertRecords:records.list publicId:nil];
//             [[XTDataBaseDao sharedDatabaseDaoInstance] insertToDoRecords:records.list];
//             DLog(@"records.count = %d", records.count);
//             
//             //更新时间
//             GroupDataModel *model = [[XTDataBaseDao sharedDatabaseDaoInstance] queryFullPublicGroupWithPersonId:kTodoPersonId];
//             [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithUpdateTime:records.updateTime withGroupId:model.groupId];
//             
//
//             self.isDownLoadingAllToDoMessage = NO;
//                                     
//            NSString *alreadPull = [NSString stringWithFormat:@"%@&%@", [BOSConfig sharedConfig].user.userId, [BOSConfig sharedConfig].user.eid];
//            id temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"TheFirstTimePullAllToDoMsg"];
//            if (temp == nil || temp == 0)
//            {
//                [[NSUserDefaults standardUserDefaults] setObject:alreadPull forKey:@"TheFirstTimePullAllToDoMsg"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
//                                     
//            NSDictionary *dic = @{@"info":@"downloadAllToDo"};
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateToDoMessageDidReceive" object:nil userInfo:dic];
//
//         }];
//    
//    }
//}

//-(void)todoMsgStateChangeWithMsgId:(NSString *)msgId
//                          PersonId:(NSString *)personId
//                         ReadState:(BOOL)readstate
//{
//    NSString *strReadState = readstate?@"true":@"false";
//    
//    NSString *path = [BOSSetting sharedSetting].url;
//    path = [path stringByAppendingString:changeOtherMsg];
//    NSURL *pathUrl = [NSURL URLWithString:path];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pathUrl];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:[BOSConnect userAgent] forHTTPHeaderField:@"User-Agent"];
//    [request setHTTPBody:[[NSString stringWithFormat:@"groupId=%@&readMsgIds=%@&userId=%@&readTime=%@&fromUserId=%@", msgId, personId, strReadState, [BOSConnect userAgent]] dataUsingEncoding:NSUTF8StringEncoding]];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {}];
//}
-(void)todoMsgStateChangeWithMsgDataModel:(KDToDoMessageDataModel *) model andSourceGroupId:(NSString *)sourceGroupId
{
    NSString *bodyString = @"";
    if (sourceGroupId.length > 0) {
        bodyString = [NSString stringWithFormat:@"groupId=%@&readMsgIds=%@&userId=%@&fromUserId=%@&ua=%@&sourceGroupId=%@",model.groupId, model.msgId, [BOSConfig sharedConfig].user.userId, model.fromUserId,[BOSConnect userAgent], sourceGroupId];
    } else {
        bodyString = [NSString stringWithFormat:@"groupId=%@&readMsgIds=%@&userId=%@&fromUserId=%@&ua=%@",model.groupId, model.msgId, [BOSConfig sharedConfig].user.userId, model.fromUserId,[BOSConnect userAgent]];
    }
    NSString *path = [BOSSetting sharedSetting].url;
    path = [path stringByAppendingString:changeOtherMsg];
    NSURL *pathUrl = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pathUrl];
    [request setValue:[BOSConfig sharedConfig].user.token forHTTPHeaderField:@"openToken"];
    [request setValue:[BOSConnect userAgent] forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    }];
}

-(void)dealwithToDoStatusWithDictionary:(NSDictionary *)dic
{
    DLog(@"dic = %@",dic);
    
    NSString *queryTime = [[dic objectForKey:@"data"] objectForKey:@"queryTime"];
    [[NSUserDefaults standardUserDefaults] setObject:queryTime forKey:@"ToDoStatusLastUpdateTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSArray *otherRead = [[[dic objectForKey:@"data"] objectForKey:@"other"] objectForKey:@"read"];
    [otherRead enumerateObjectsUsingBlock:^(NSString *theIdString, NSUInteger i, BOOL *stop)
     {
         [[XTDataBaseDao sharedDatabaseDaoInstance] insertToDoStateWithSourceMsgId:theIdString ReadState:@"Yes" DoneState:@""];
     }];
    
    NSArray *otherNotRead = [[[dic objectForKey:@"data"] objectForKey:@"other"] objectForKey:@"unRead"];
    [otherNotRead enumerateObjectsUsingBlock:^(NSString *theIdString, NSUInteger i, BOOL *stop)
     {
         [[XTDataBaseDao sharedDatabaseDaoInstance] insertToDoStateWithSourceMsgId:theIdString ReadState:@"No" DoneState:@""];
     }];
    
    NSArray *pubaccRead = [[[dic objectForKey:@"data"] objectForKey:@"pubacc"] objectForKey:@"read"];
    [pubaccRead enumerateObjectsUsingBlock:^(NSString *theIdString, NSUInteger i, BOOL *stop)
     {
         [[XTDataBaseDao sharedDatabaseDaoInstance] insertToDoStateWithSourceMsgId:theIdString ReadState:@"Yes" DoneState:@""];
     }];
    
    NSArray *pubaccUnRead = [[[dic objectForKey:@"data"] objectForKey:@"pubacc"] objectForKey:@"unRead"];
    [pubaccUnRead enumerateObjectsUsingBlock:^(NSString *theIdString, NSUInteger i, BOOL *stop)
     {
         [[XTDataBaseDao sharedDatabaseDaoInstance] insertToDoStateWithSourceMsgId:theIdString ReadState:@"No" DoneState:@""];
     }];
    
}
-(void)queryToDoStatusTypeOneWithTime:(NSNumber *)time Block:(void(^)())block
{
//    NSString *path = [BOSSetting sharedSetting].url;
    NSString *path = MCLOUD_IP_FOR_PUBACC;
    path = [path stringByAppendingString:pubaccMsg];
    path = [path stringByAppendingString:[BOSConfig sharedConfig].user.userId];
    path = [path stringByAppendingString:list];
    path = [path stringByAppendingString:[NSString stringWithFormat:@"time=%@", time]];
    NSURL *pathUrl = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pathUrl];
    [request setHTTPMethod:@"GET"];
    [request setValue:[BOSConnect userAgent] forHTTPHeaderField:@"User-Agent"];
    [request setValue:[BOSConfig sharedConfig].user.token forHTTPHeaderField:@"openToken"];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:data];
         [self dealwithToDoStatusWithDictionary:tempDic];
         
         block();
     }];
}

-(void)queryToDoStatusTypeTwoWithTime:(NSNumber *)time
{
    self.storeToDoStatusTime = time;
    [self.appendToDoMsgClient getRecordTimeLineWithGroupID:self.todoGroup.groupId userId:nil updateTime:self.todoGroup.updateTime];
}

-(void)appendToDoMsgClientDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success && result.data && !client.hasError && [result isKindOfClass:[BOSResultDataModel class]])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           RecordListDataModel *records = [[RecordListDataModel alloc] initForToDoWithDictionary:result.data];
                           
                           //插入代办表
                           [[XTDataBaseDao sharedDatabaseDaoInstance] insertToDoRecords:records.list];
                           
                           //更新时间
                           GroupDataModel *model = [[XTDataBaseDao sharedDatabaseDaoInstance] queryTodoMsgInXT];
                           [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithUpdateTime:records.updateTime withGroupId:model.groupId];
                           
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              [self queryToDoStatusTypeOneWithTime:self.storeToDoStatusTime];
                                          });
                       });
    }
    
    self.appendToDoMsgClient = nil;
}

#pragma mark - MessageUnreadList
-(void)getMessageUnreadList
{
    [self.messageUnreadListClient getMessageUreadListWithLastUpdateTime:[XTSetting sharedSetting].msgLastReadUpdateTime];
}

-(void)messageUnreadListClientDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError)
    {
        return;
    }
    
    if (result.success)
    {
        NSDictionary *tempDic = result.data;
        
        NSString *msgLastReadUpdateTime = [tempDic objectForKey:@"msgLastReadUpdateTime"];
        if ([msgLastReadUpdateTime isKindOfClass:[NSString class]] && msgLastReadUpdateTime != nil)
        {
            [XTSetting sharedSetting].msgLastReadUpdateTime = msgLastReadUpdateTime;
            [[XTSetting sharedSetting] saveSetting];
        }
        
        NSArray *list = [tempDic objectForKey:@"list"];
        for (NSDictionary *dic in list)
        {
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertMessageUnreadStateWithGroupId:dic[@"groupId"]
                                                                                     MsgId:dic[@"messageId"]
                                                                               UnreadCount:dic[@"unreadUserCount"]];
            DLog(@"database msgId = %@, unread = %@", dic[@"messageId"], dic[@"unreadUserCount"]);
        }
        
        //发送通知给XTChatViewController来通知重新获取message的unreadState
        if (kd_safeArray(list).count > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"msgReadUpdate" object:nil userInfo:nil];
        }
        
    }
    
    //self.messageUnreadListClient = nil;
}

-(void)getUnreadCountDetailWithGroupId:(NSString *)groupId MsgId:(NSString *)msgId
{
    self.unreadCountGroupId = groupId;
    self.unreadCountMsgId = msgId;
    [self.getUnreadCountDetailClient getMessageUreadDetailWithGroupId:groupId MsgId:msgId];
}

-(void)getUnreadCountDetailClientDidReceive:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success)
    {
        NSDictionary *dic = result.data;
        
        NSNumber *unreadCount = dic[@"unreadUserCount"];
        NSArray *readArray = dic[@"readUsers"];
        NSArray *unreadArray = dic[@"unreadUsers"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"messageUnreadCount"
                                                            object:nil
                                                          userInfo:@{@"msgId":self.unreadCountMsgId,
                                                                     @"groupId":self.unreadCountGroupId,
                                                                     @"unreadUserCount":unreadCount,
                                                                     @"readUsers":readArray,
                                                                     @"unreadUsers":unreadArray}];
    }
}


#pragma mark - dealloc
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appViewDelete" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddApp" object:nil];
}
@end
