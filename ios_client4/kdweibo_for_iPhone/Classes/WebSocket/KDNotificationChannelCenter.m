//
//  KDNotificationChannelCenter.m
//  kdweibo
//
//  Created by Gil on 15/12/1.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDNotificationChannelCenter.h"
#import "KDPolling.h"
#import "KDWebSocket.h"
#import "BOSSetting.h"
#import "BOSConfig.h"
#import "XTSetting.h"
#import "XTInitializationManager.h"
#import "KDApplicationQueryAppsHelper.h"
#import "KDParamFetchManager.h"
#import "KDPubAcctFetch.h"
//#import "KDExternalInitializationManager.h"
//#import "KDExternalSetting.h"
#import "ContactClient.h"
//#import "KDToDoManager.h"
//#import "KDSearchHelper.h"
#import "KDTimelineManager.h"



//新消息通知
NSString *const KDNotificationChannelNewMessage = @"KDNotificationChannelNewMessage";
//商务会话新消息通知
NSString *const KDNotificationChannelExternalNewMessage = @"KDNotificationChannelExternalNewMessage";
//退组消息同步通知
NSString *const KDHasExitGroupNotification = @"KDHasExitGroupNotification";
// 工作圈名字修改通知
NSString *const KDNotificationChannelChangeCompanyInfo = @"KDNotificationChannelChangeCompanyInfo";
//关联工作圈消息
NSString *const KDNotificationRelationNewMessage = @"KDNotificationRelationNewMessage";
// 有消息被删除（公共号有消息被撤回、代办状态）
NSString *const KDHasMessageDelNotification = @"KDHasMessageDelNotification";

@interface KDNotificationChannelCenter () <KDNotificationChannelDelegate,UIAlertViewDelegate>
@property (assign, nonatomic) BOOL longConnEnable;
@property (strong, nonatomic) KDPolling *polling;
@property (strong, nonatomic) KDWebSocket *webSocket;

@property (assign, nonatomic) BOOL insideChannel;

@property (nonatomic, strong) KDPubAcctFetch *fetcher;
@property (assign, nonatomic) BOOL isFetching;
@property (nonatomic, strong) ContactClient *getExitGroupsClient;
@property (assign, nonatomic) BOOL *isGetExitGroups;
@property (nonatomic, strong) ContactClient *getExitExtGroupsClient;
@property (assign, nonatomic) BOOL *isGetExitExtGroups;
@end

@implementation KDNotificationChannelCenter

+ (instancetype)defaultCenter {
	static dispatch_once_t pred;
	static KDNotificationChannelCenter *instance = nil;

	dispatch_once(&pred, ^{
		instance = [[KDNotificationChannelCenter alloc] init];
	});
	return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChanged:) name:KDReachabilityDidChangeNotification object:nil];
    }
    return self;
}

- (void)startChannel {
    //无网络情况下不打开
    if ([KDReachabilityManager sharedManager].reachabilityStatus == KDReachabilityStatusNotReachable) {
        return;
    }
    //未登录情况下不打开
    if ([BOSConfig sharedConfig].user.token.length == 0) {
        return;
    }
    if (self.insideChannel) {
        return;
    }
    
    self.insideChannel = YES;
    self.longConnEnable = [[BOSSetting sharedSetting] longConnEnable];
    
    //优先使用WebSocket长链接
    if (self.longConnEnable) {
        [self _startWebSocket];
        // 开启websocket的同时，也走轮训 by WHF 20170519
        [self _startPolling];
    }
    else {
        [self _startPolling];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paramsChanged:) name:kBOSSettingParamChangedNotification object:nil];
}

- (void)closeChannel {
    if (!self.insideChannel) {
        return;
    }
    
    self.insideChannel = NO;
    
    [self _cancelWebSocket];
    [self _cancelPolling];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBOSSettingParamChangedNotification object:nil];
}

- (BOOL)isWebSocketChannel {
    return ![self isPollingChannel];
}

- (BOOL)isPollingChannel {
    return self.polling && [self.polling isPolling];
}

- (void)paramsChanged:(NSNotification *)notification {
    if (self.longConnEnable != [[BOSSetting sharedSetting] longConnEnable]) {
        //通道参数变更时，切换通道
        [self closeChannel];
        [self startChannel];
    }
}

- (void)reachabilityDidChanged:(NSNotification *)notification {
    //如果程序不在前台，不做处理
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    //未登录情况下不做任何处理
    if ([BOSConfig sharedConfig].user.token.length == 0) {
        return;
    }
    
	NSDictionary *userInfo = [notification userInfo];

	if (userInfo) {
		KDReachabilityStatus reachabilityStatus = [userInfo[KDReachabilityStatusKey] intValue];

		if (reachabilityStatus == KDReachabilityStatusNotReachable) {
            //如果在通道中，断网时关闭通道
            if (self.insideChannel) {
                [self closeChannel];
            }
		}
		else {
            //如果通道是关闭的，网络连通后打开通道
            if (!self.insideChannel) {
                [self startChannel];
            }
		}
	}
}

#pragma mark - private method -

- (void)_startWebSocket {
    //未登录情况下不做任何处理
    if ([BOSConfig sharedConfig].user.token.length == 0) {
        return;
    }
    
    if (self.webSocket == nil) {
        self.webSocket = [[KDWebSocket alloc] init];
    }
    self.webSocket.delegate = self;
    
    __weak KDNotificationChannelCenter *selfInBlock = self;
    self.webSocket.successBlock = ^{
        //成功关闭polling
        // 开启websocket的同时，也走轮训 by WHF 20170519
//        [selfInBlock _cancelPolling];
    };
    self.webSocket.failedBlock = ^{
        //失败开启polling
        [selfInBlock _startPolling];
    };
    
    [self.webSocket open];
}

- (void)_cancelWebSocket {
    if (self.webSocket) {
        [self.webSocket close];
        self.webSocket.delegate = nil;
    }
}

- (void)_startPolling {
    //未登录情况下不做任何处理
    if ([BOSConfig sharedConfig].user.token.length == 0) {
        return;
    }
    
    if (self.polling == nil) {
        self.polling = [[KDPolling alloc] init];
    }
    self.polling.delegate = self;
    [self.polling startPolling];
}

- (void)_cancelPolling {
    if (self.polling) {
        [self.polling cancelPolling];
        self.polling.delegate = nil;
    }
}

- (KDPubAcctFetch *)fetcher {
    if (_fetcher == nil) {
        _fetcher = [[KDPubAcctFetch alloc] init];
    }
    return _fetcher;
}

#pragma mark - 退组信息同步 -

//获取已经退出的内部群组
- (void)getExitGroups {
    
    if (self.isGetExitGroups) {
        return;
    }
    self.isGetExitGroups = YES;
    
    if (!self.getExitGroupsClient) {
        self.getExitGroupsClient = [[ContactClient alloc] initWithTarget:self action:@selector(getExitGroupsDidReceived:result:)];
    }
    
    if ([XTSetting sharedSetting].groupExitUpdateTime.length == 0) {
        [XTSetting sharedSetting].groupExitUpdateTime = [XTSetting sharedSetting].updateTime;
    }
    [self.getExitGroupsClient getExitGroupListWithlLastUpdateTime:[XTSetting sharedSetting].groupExitUpdateTime];
}

- (void)getExitGroupsDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    self.isGetExitGroups = NO;
    
    if (result == nil) {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (result.success && [result.data isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *data = (NSDictionary *)result.data;
        id updateTime = data[@"updateTime"];
        id list = data[@"list"];
        
        NSArray *groupExitList;
        
        if (updateTime && [updateTime isKindOfClass:[NSString class]])
        {
            [XTSetting sharedSetting].groupExitUpdateTime = updateTime;
        }
        
        if (list && [list isKindOfClass:[NSArray class]])
        {
            groupExitList = (NSArray *)list;
            
            [groupExitList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                id groupId = [obj objectForKey:@"groupId"];
                if (groupId && ![groupId isKindOfClass:[NSNull class]]) {
                    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteGroupAndRecordsWithGroupId:groupId publicId:nil realDel:YES];
//                    [[XTDataBaseDao sharedDatabaseDaoInstance] setPrivateGroupListToDeleteWithGroupId:groupId];
                }
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:KDHasExitGroupNotification object:groupExitList];
        }
    }
}

//获取已经退出的外部群组
- (void)getExitExtGroups {
    
//    if (self.isGetExitExtGroups) {
//        return;
//    }
//    self.isGetExitExtGroups = YES;
//    
//    if (!self.getExitExtGroupsClient) {
//        self.getExitExtGroupsClient = [[ContactClient alloc] initWithTarget:self action:@selector(getExitExtGroupsDidReceived:result:)];
//    }
//    
//    if ([XTSetting sharedSetting].extGroupExitUpdateTime.length == 0) {
//        [XTSetting sharedSetting].extGroupExitUpdateTime = [XTSetting sharedSetting].updateTime;
//    }
//    [self.getExitExtGroupsClient getExitExtGroupListWithlLastUpdateTime:[XTSetting sharedSetting].extGroupExitUpdateTime];
}

- (void)getExitExtGroupsDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    self.isGetExitExtGroups = NO;
    
    if (result == nil) {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (result.success && [result.data isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *data = (NSDictionary *)result.data;
        id updateTime = data[@"updateTime"];
        id list = data[@"list"];
        
        NSArray *groupExitList;
        
        if (updateTime && [updateTime isKindOfClass:[NSString class]])
        {
//            [XTSetting sharedSetting].extGroupExitUpdateTime = updateTime;
        }
        
        if (list && [list isKindOfClass:[NSArray class]])
        {
            groupExitList = (NSArray *)list;
            
            [groupExitList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                id groupId = [obj objectForKey:@"groupId"];
                if (groupId && ![groupId isKindOfClass:[NSNull class]]) {
                    [[XTDataBaseDao sharedDatabaseDaoInstance] setPrivateGroupListToDeleteWithGroupId:groupId];
                }
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:KDHasExitGroupNotification object:groupExitList];
        }
    }
}

#pragma mark - KDNotificationChannelDelegate -

#pragma mark 登出
- (void)notificationChannelLogout:(id)object
                            error:(NSString *)error
                             data:(id)data {
    [self logout:error data:data];
}

- (void)logout:(NSString *)error data:(id)data {
    //保证只执行一次
    if (!self.insideChannel) {
        return;
    }
    self.insideChannel = NO;
    //A.wang 登出提醒
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    //[alert show];
    
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        id erase = data[@"erase"];
        if (erase && [erase boolValue]) {

//            [[KDLoginManager sharedManager] eraseOut];
            return;
        }
    }
    
    //token失效
    [BOSSetting sharedSetting].cust3gNo = @"";
    [[BOSSetting sharedSetting] saveSetting];
    // 退出登录并关闭websocket通道
    [[KDWeiboAppDelegate getAppDelegate] signOut];
    [self closeChannel];
    
}

#pragma mark 内部会话：新消息更新、已读状态更新、退组信息更新
- (void)notificationChannelNewMessage:(id)object
                                 flag:(BOOL)flag {
	if (flag) {
		[[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationChannelNewMessage object:nil];
	}
    //轮训和websocket同时开启 先去掉
//     [[NSNotificationCenter defaultCenter] postNotificationName:@"pubNeedUpdate" object:nil];
}
- (void)notificationChannelNewMessage:(id)object
                       lastUpdateTime:(NSString *)lastUpdateTime {
    if (lastUpdateTime && [lastUpdateTime isKindOfClass:[NSString class]]) {
        [self notificationChannelNewMessage:object flag:([lastUpdateTime compare:[XTSetting sharedSetting].updateTime] == NSOrderedDescending)];
    }
}

- (void)notificationChannelMessageReadStatus:(id)object
                                        flag:(BOOL)flag {
	if (flag) {
		[[KDApplicationQueryAppsHelper shareHelper] getMessageUnreadList];
	}
}

- (void)notificationChannelMessageReadStatus:(id)object
                              lastUpdateTime:(NSString *)lastUpdateTime {
    if (lastUpdateTime && [lastUpdateTime isKindOfClass:[NSString class]]) {
        [self notificationChannelMessageReadStatus:object flag:([lastUpdateTime compare:[XTSetting sharedSetting].msgLastReadUpdateTime] == NSOrderedDescending)];
    }
}

- (void)notificationChannelExitGroup:(id)object
                                flag:(BOOL)flag {
    if (flag) {
        [self getExitGroups];
    }
}

- (void)notificationChannelExitGroup:(id)object
                      lastUpdateTime:(NSString *)lastUpdateTime {
    if (lastUpdateTime && [lastUpdateTime isKindOfClass:[NSString class]]) {
        [self notificationChannelExitGroup:object flag:([lastUpdateTime compare:[XTSetting sharedSetting].groupExitUpdateTime] == NSOrderedDescending)];
    }
}

#pragma mark 商务会话：新消息更新、已读状态更新、退组信息更新
- (void)notificationChannelExternalNewMessage:(id)object
                                         flag:(BOOL)flag {
    if (flag) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationChannelExternalNewMessage object:nil];
    }
}
- (void)notificationChannelExternalNewMessage:(id)object
                               lastUpdateTime:(NSString *)lastUpdateTime {
//    if (lastUpdateTime && [lastUpdateTime isKindOfClass:[NSString class]]) {
//        [self notificationChannelExternalNewMessage:object flag:([lastUpdateTime compare:[KDExternalSetting sharedSetting].extGroupUpdateTime] == NSOrderedDescending)];
//    }
}

- (void)notificationChannelExternalMessageReadStatus:(id)object
                                                flag:(BOOL)flag {
    if (flag) {
        [[KDApplicationQueryAppsHelper shareHelper] getExtMessageUnreadList];
    }
}
- (void)notificationChannelExternalMessageReadStatus:(id)object
                                      lastUpdateTime:(NSString *)lastUpdateTime {
//    if (lastUpdateTime && [lastUpdateTime isKindOfClass:[NSString class]]) {
//        [self notificationChannelExternalMessageReadStatus:object flag:([lastUpdateTime compare:[KDExternalSetting sharedSetting].extMsgLastReadUpdateTime] == NSOrderedDescending)];
//    }
}

- (void)notificationChannelExternalExitGroup:(id)object
                                        flag:(BOOL)flag {
    if (flag) {
        [self getExitExtGroups];
    }
}
- (void)notificationChannelExternalExitGroup:(id)object
                              lastUpdateTime:(NSString *)lastUpdateTime {
//    if (lastUpdateTime && [lastUpdateTime isKindOfClass:[NSString class]]) {
//        [self notificationChannelExternalExitGroup:object flag:([lastUpdateTime compare:[XTSetting sharedSetting].extGroupExitUpdateTime] == NSOrderedDescending)];
//    }
}

#pragma mark 信息变更
- (void)notificationChannelAddressBookChange:(id)object
                              lastUpdateTime:(NSString *)lastUpdateTime {
    if (lastUpdateTime && [lastUpdateTime isKindOfClass:[NSString class]]) {
        if ([lastUpdateTime compare:[XTSetting sharedSetting].t9UpdateTime] == NSOrderedDescending) {
            [[XTInitializationManager sharedInitializationManager] startInitializeCompletionBlock:nil failedBlock:nil];
        }
    }
}

- (void)notificationChannelApplicationChange:(id)object
                              lastUpdateTime:(NSString *)lastUpdateTime {
//    if (lastUpdateTime && [lastUpdateTime isKindOfClass:[NSString class]]) {
//        if ([lastUpdateTime compare:[XTSetting sharedSetting].appLastUpdateTime] == NSOrderedDescending) {
//            [[KDApplicationQueryAppsHelper shareHelper] checkAppLastUpdateTime:lastUpdateTime];
//        }
//    }
}

- (void)notificationChannelmCloudParamChange:(id)object
                              lastUpdateTime:(NSString *)lastUpdateTime {
	if (lastUpdateTime && [lastUpdateTime isKindOfClass:[NSString class]]) {
		if ([lastUpdateTime compare:[XTSetting sharedSetting].paramFetchUpdateTime] == NSOrderedDescending) {
			[[KDParamFetchManager sharedParamFetchManager] startParamFetchCompletionBlock:^(BOOL success) {
				if (success) {
			        //成功后记录更新时间
					[XTSetting sharedSetting].paramFetchUpdateTime = lastUpdateTime;
				}
			}];
		}
	}
}

- (void)notificationChannelPubAcctChange:(id)object
                          lastUpdateTime:(NSString *)lastUpdateTime
                              pubAcctIds:(NSArray *)pubAcctIds {
    if (lastUpdateTime && [lastUpdateTime isKindOfClass:[NSString class]] && pubAcctIds && [pubAcctIds isKindOfClass:[NSArray class]] && [(NSArray *)pubAcctIds count] > 0) {
        if ([XTSetting sharedSetting].pubAcctUpdateTime.length == 0) {
            //第一次只更新时间，不拉人员
            [XTSetting sharedSetting].pubAcctUpdateTime = lastUpdateTime;
            [[XTSetting sharedSetting] saveSetting];
            return;
        }
        if ([lastUpdateTime compare:[XTSetting sharedSetting].pubAcctUpdateTime] == NSOrderedDescending) {
            if (self.isFetching) {
                return;
            }
            self.isFetching = YES;
            
            __weak KDNotificationChannelCenter *selfInBlock = self;
            [self.fetcher fetchWithPubAcctIds:pubAcctIds completionBlock:^(BOOL success, NSArray *pubAccts) {
                selfInBlock.isFetching = NO;
                if (success) {
                    //成功后记录更新时间
                    [XTSetting sharedSetting].pubAcctUpdateTime = lastUpdateTime;
                    [[XTSetting sharedSetting] saveSetting];
                }
            }];
        }
    }
}

- (void)notificationChannelExtSystemMsg:(id)object
                          msgFromSystem:(NSArray *)msgFromSystem {
    
	if (msgFromSystem && [msgFromSystem isKindOfClass:[NSArray class]]) {
		NSArray *systems = msgFromSystem;
		NSDictionary *tempDic = nil;

		for (NSInteger i = 0; i < [systems count]; i++) {
			tempDic = systems[i];

			if (![tempDic isKindOfClass:[NSDictionary class]]) {
				continue;
			}

			NSString *system = tempDic[@"system"];

			if (![system isKindOfClass:[NSString class]]) {
				continue;
			}

            if ([system isEqualToString:@"todo"]) {
                NSDictionary *msg = tempDic[@"msg"];
                if (![msg isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSNumber *updatetime = msg[@"updatetime"];
                if (!updatetime) {
                    continue;
                }
//                [[KDToDoManager sharedToDoManager] queryNewestNewToDoWithUpdateTime:updatetime];
            }
			else if ([system isEqualToString:@"open"]) {
				NSDictionary *msg = tempDic[@"msg"];

				if (![msg isKindOfClass:[NSDictionary class]]) {
					continue;
				}
				NSString *extContact_change_updateTime = msg[@"extContact_change_updateTime"];
                NSString *company_change_updateTime = msg[@"userNetworkChangeNotice"];
                
                if (company_change_updateTime && [company_change_updateTime isKindOfClass:[NSString class]]) {
                    
//                    if ([company_change_updateTime compare:[XTSetting sharedSetting].companyNameUpdateTime] == NSOrderedDescending){
//                        
//                        [[XTSetting sharedSetting] setCompanyNameUpdateTime:company_change_updateTime];
//                        [[XTSetting sharedSetting] saveSetting];
//                        [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationChannelChangeCompanyInfo object:nil];
//                    }
                }
                
				if (extContact_change_updateTime && [extContact_change_updateTime isKindOfClass:[NSString class]]) {
//					if ([extContact_change_updateTime compare:[KDExternalSetting sharedSetting].extPersonUpdateTime] == NSOrderedDescending) {
//						[[KDExternalInitializationManager sharedInitializationManager] startInitializeCompletionBlock:nil failedBlock:nil];
//					}
				}
			}
            else if ([system isEqualToString:@"application"]) {
                NSDictionary *msg = tempDic[@"msg"];
                
                if (![msg isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSNumber *company_opened_updatetime = msg[@"company_opened_updatetime"];
//                if ([XTSetting sharedSetting].companyOpenedAppLastUpdateTime == nil)
//                {
//                    [XTSetting sharedSetting].companyOpenedAppLastUpdateTime = [NSNumber numberWithLong:0];
//                }
//                if ([company_opened_updatetime compare:[XTSetting sharedSetting].companyOpenedAppLastUpdateTime] == NSOrderedDescending) {
//                    [[KDApplicationQueryAppsHelper shareHelper] checkCompanyOpenedAppLastUpdateTime:company_opened_updatetime];
//                }
            } else if ([system isEqualToString:@"cross_network_msg"]) {
                NSDictionary *msg = tempDic[@"msg"];
                if (![msg isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                if ([msg[@"newmsg"] boolValue]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationRelationNewMessage object:nil];
                }
            }
		}
	}
}

#pragma mark Push注册
- (void)notificationChannelRegisteredPush:(id)object data:(id)data {
#if DEBUG
    //Debug模式下不重新请求
    return;
#endif
    
    //测试包在正式环境上不重新请求
//    if (!kProductMode && [KDURLPathManager sharedURLPathManager].urlType == KDURLTypeProduction) {
//        return;
//    }
    if (data && [data boolValue]) {
//        if ([KDSearchHelper isCurrentAppRegistedRemote]) {
            [[KDManagerContext globalManagerContext].APNSManager registerForRemoteNotification];
//        }
    }
}
- (void)notificationPubAcctList:(id)object
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pubNeedUpdate" object:nil];
}

- (void)notificationKickOut:(id)object
             lastUpdateTime:(id)lastUpdateTime
{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"KDUnreadManager_alter_msg")delegate:self cancelButtonTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_16")otherButtonTitles: nil];
    [alertView show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"user_logout" object:nil];
}

//delTodoMsg 
- (void)notificationTodoDel:(id)object
                  hasMsgDel:(BOOL)hasMsgDel
{
    if (hasMsgDel) {
//        if ([lastUpdateTime compare:[XTSetting sharedSetting].msgLastDelUpdateTime] == NSOrderedDescending) {
//             //成功后记录更新时间
//             [XTSetting sharedSetting].msgLastDelUpdateTime = lastUpdateTime;
            [[NSNotificationCenter defaultCenter] postNotificationName:KDHasMessageDelNotification object:[XTSetting sharedSetting].msgLastDelUpdateTime];
//        }
    }

}

- (void)notificationTodoDel:(id)object
             lastUpdateTime:(NSString*)lastUpdateTime
{
     [[NSNotificationCenter defaultCenter] postNotificationName:KDHasMessageDelNotification object:[XTSetting sharedSetting].msgLastDelUpdateTime];
}


- (void)notificationChannelReloadAppList:(id)object
                                    data:(id)data
{
    //重新拉应用列表、群应用
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reLoadApplist" object:nil];
}

//清除数据
- (void)notificationChannelCleanData:(id)object
                                type:(NSString *)type
                      lastUpdateTime:(NSString*)lastUpdateTime
{
    if([XTSetting sharedSetting].lastClearDataUpdateTime.length!=0 && lastUpdateTime.length != 0 && [[XTSetting sharedSetting].lastClearDataUpdateTime compare:lastUpdateTime] != NSOrderedAscending)
        return;
    
    //更新本地时间
//    [[NSUserDefaults standardUserDefaults]setValue:lastUpdateTime forKey:@"lastCleanDataUpdateTime"];
    [XTSetting sharedSetting].lastClearDataUpdateTime = lastUpdateTime;
    [[XTSetting sharedSetting] saveSetting];
    //清除代办数据
    if ([type isEqualToString:@"todo"]) {
        [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllToDo];
    }else  if ([type isEqualToString:@"all"])
    {
        //清除所有 除了人员表
        [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllDataExpectPersonTabale];
        if(![[KDTimelineManager shareManager] shouldStarPagingRequest])
            [[KDTimelineManager shareManager] setFinishPageRequest];
        [[KDTimelineManager shareManager] setNumberOfPages:0];
        [XTSetting sharedSetting].updateTime = @"";
        for (int i = 0; i < [XTSetting sharedSetting].pubAccountsUpdateTimeDict.allKeys.count; i ++ ) {
           [[XTSetting sharedSetting].pubAccountsUpdateTimeDict setValue:@"" forKey:[XTSetting sharedSetting].pubAccountsUpdateTimeDict.allKeys[i]];
        }
        [[XTSetting sharedSetting] saveSetting];
        [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationChannelNewMessage object:nil];
    }
}

@end
