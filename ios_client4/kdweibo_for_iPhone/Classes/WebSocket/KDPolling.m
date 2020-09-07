//
//  KDPolling.m
//  kdweibo
//
//  Created by Gil on 15/12/1.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPolling.h"
#import "ContactClient.h"
#import "XTSetting.h"
//#import "KDExternalSetting.h"
#import "BOSConfig.h"

@interface KDPolling ()
@property (strong, nonatomic) ContactClient *needUpdateClient;

@property (weak, nonatomic) NSTimer *pollingTimer;
@end

@implementation KDPolling

- (void)dealloc {
    [_needUpdateClient cancelRequest];
    [self cancelPolling];
}

- (void)startPolling {
    if ([self isPolling]) {
        return;
    }
    
    [self checkUpdate];
    
    if (self.pollingTimer == nil) {
        self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkUpdate) userInfo:nil repeats:YES];
    }
}

- (void)cancelPolling {
    if ([self isPolling]) {
        [self.pollingTimer invalidate];
        self.pollingTimer = nil;
    }
}

- (BOOL)isPolling {
    return self.pollingTimer && [self.pollingTimer isValid];
}

#pragma mark - private method -

- (void)checkUpdate {
    if (self.needUpdateClient == nil) {
        self.needUpdateClient = [[ContactClient alloc]initWithTarget:self action:@selector(checkUpdateDidReceived:result:)];
    }
    
    //    if ([XTSetting sharedSetting].groupExitUpdateTime.length == 0) {
    //        [XTSetting sharedSetting].groupExitUpdateTime = [XTSetting sharedSetting].updateTime;
    //    }
    
    //    if ([XTSetting sharedSetting].extGroupExitUpdateTime.length == 0) {
    //        [XTSetting sharedSetting].extGroupExitUpdateTime = [XTSetting sharedSetting].updateTime;
    //    }
    [self.needUpdateClient unreadCountWithUserIds:[[KDManagerContext globalManagerContext].communityManager joinedUserIds]
                                       updatetime:[XTSetting sharedSetting].updateTime
                                pubAcctUpdateTime:[XTSetting sharedSetting].pubAcctUpdateTime
                            msgLastReadUpdateTime:[XTSetting sharedSetting].msgLastReadUpdateTime
                             msgLastDelUpdateTime:[XTSetting sharedSetting].msgLastDelUpdateTime
                          lastCleanDataUpdateTime:[XTSetting sharedSetting].lastClearDataUpdateTime];////[[NSUserDefaults standardUserDefaults]valueForKey:@"lastCleanDataUpdateTime"]];
    //    [self.needUpdateClient unreadCountWithUserIds:(NSArray *)userIds
    //                                               updatetime:(NSString *)updateTime
    //                                        pubAcctUpdateTime:(NSString *)pubAcctUpdateTime
    //                                    msgLastReadUpdateTime:(NSString *)msgLastReadUpdateTime];
    //    [self.needUpdateClient unreadCountWithUserIds:@[[BOSConfig sharedConfig].user.userId]
    //                                       updatetime:[XTSetting sharedSetting].updateTime
    //                                pubAcctUpdateTime:[XTSetting sharedSetting].pubAcctUpdateTime
    //                            msgLastReadUpdateTime:[XTSetting sharedSetting].msgLastReadUpdateTime
    //                               extGroupUpdateTime:nil//[KDExternalSetting sharedSetting].extGroupUpdateTime
    //                         extMsgLastReadUpdateTime:nil//[KDExternalSetting sharedSetting].extMsgLastReadUpdateTime
    //                              groupExitUpdateTime:nil//[XTSetting sharedSetting].groupExitUpdateTime
    //                           extGroupExitUpdateTime:nil];//;[XTSetting sharedSetting].extGroupExitUpdateTime];
}

- (void)checkUpdateDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result {
    if (result == nil) {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    
    //账号被踢出
    if (!result.success && result.errorCode == 2) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelLogout:error:data:)]) {
            [self.delegate notificationChannelLogout:self
                                               error:result.error
                                                data:result.data];
        }
        return;
    }
    
    if (result.success && [result.data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *data = (NSDictionary *)result.data;
        
        id currentData = data[[BOSConfig sharedConfig].user.userId];
        //A.wang 踢出账号
        id isKickout = data[@"isKickout"];
        if (isKickout && [isKickout boolValue]==1)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelLogout:error:data:)]) {
                [self.delegate notificationChannelLogout:self
                                                   error:result.error
                                                    data:result.data];
            }
            return;
        }
        
        
        if (currentData && [currentData isKindOfClass:[NSDictionary class]]) {

            if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelNewMessage:flag:)]) {
                [self.delegate notificationChannelNewMessage:self flag:[currentData[@"flag"] boolValue]];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelMessageReadStatus:flag:)]) {
                [self.delegate notificationChannelMessageReadStatus:self flag:[currentData[@"hasMsgRead"] boolValue]];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelExitGroup:flag:)]) {
                [self.delegate notificationChannelExitGroup:self flag:[currentData[@"hasExitGroup"] boolValue]];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelAddressBookChange:lastUpdateTime:)]) {
                [self.delegate notificationChannelAddressBookChange:self lastUpdateTime:currentData[@"addressBookLastUpdateTime"]];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelApplicationChange:lastUpdateTime:)]) {
                [self.delegate notificationChannelApplicationChange:self lastUpdateTime:currentData[@"appLastUpdateTime"]];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelmCloudParamChange:lastUpdateTime:)]) {
                [self.delegate notificationChannelmCloudParamChange:self lastUpdateTime:currentData[@"mCloudParamLastUpdateTime"]];
            }
            
            id pubAcctChange = currentData[@"pubAcctChange"];
            if (pubAcctChange && [pubAcctChange isKindOfClass:[NSDictionary class]]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelPubAcctChange:lastUpdateTime:pubAcctIds:)]) {
                    [self.delegate notificationChannelPubAcctChange:self lastUpdateTime:pubAcctChange[@"lastUpdateTime"] pubAcctIds:pubAcctChange[@"pubAcctIds"]];
                }
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelExtSystemMsg:msgFromSystem:)]) {
                [self.delegate notificationChannelExtSystemMsg:self msgFromSystem:currentData[@"msgFromSystem"]];
            }
            
            id extGroup = currentData[@"extGroup"];
            if (extGroup && [extGroup isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dictExtGroup = extGroup;
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelExternalNewMessage:flag:)]) {
                    [self.delegate notificationChannelExternalNewMessage:self flag:[dictExtGroup[@"flag"] boolValue]];
                }
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelExternalMessageReadStatus:flag:)]) {
                    [self.delegate notificationChannelExternalMessageReadStatus:self flag:[dictExtGroup[@"hasMsgRead"] boolValue]];
                }
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelExternalExitGroup:flag:)]) {
                    [self.delegate notificationChannelExternalExitGroup:self flag:[dictExtGroup[@"hasExitGroup"] boolValue]];
                }
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelRegisteredPush:data:)]) {
                [self.delegate notificationChannelRegisteredPush:self data:currentData[@"registeredPush"]];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(notificationPubAcctList:)]) {
                [self.delegate notificationPubAcctList:self];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(notificationTodoDel:hasMsgDel:)]) {
                [self.delegate notificationTodoDel:self hasMsgDel:[currentData[@"hasMsgDel"] boolValue]];
            }
            
            //重新拉应用列表
            NSString *appLastUpdateTime = currentData[@"appLastUpdateTime"];
            if (appLastUpdateTime && [appLastUpdateTime isKindOfClass:[NSString class]]) {
                if(([appLastUpdateTime compare:[XTSetting sharedSetting].appListUpdateTime] == NSOrderedDescending))
                {
                    [XTSetting sharedSetting].appListUpdateTime = appLastUpdateTime;
                    [[XTSetting sharedSetting] saveSetting];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelReloadAppList:data:)]) {
                        [self.delegate notificationChannelReloadAppList:self data:appLastUpdateTime];
                    }
                }
            }
            
            //清除数据
            NSDictionary *cleanData = data[@"clearData"];
            if (cleanData && [cleanData isKindOfClass:[NSDictionary class]]) {
                NSString *lastCleanDataUpdateTime = [XTSetting sharedSetting].lastClearDataUpdateTime;
                if([cleanData[@"lastUpdateTime"] compare:lastCleanDataUpdateTime] == NSOrderedDescending)
                {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(notificationChannelCleanData:type:lastUpdateTime:)]) {
                        [self.delegate notificationChannelCleanData:self type:cleanData[@"dataType"] lastUpdateTime:cleanData[@"lastUpdateTime"]];
                    }
                }
            }
            
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"xtUnreadCount" object:self userInfo:data];
        
        //appId:生产环境-1012244，测试环境-10175，演示-10124
        //zgbin:加第5页签
        NSArray *appCountArr = [data objectForKey:@"appCount"];
        NSString *countStr = [[NSString alloc] init];
        for (NSDictionary *dic in appCountArr) {
            if ([[dic objectForKey:@"appId"] isEqualToString:@"1012244"]) {
                countStr = [dic objectForKey:@"count"];
            }
        }
        if (countStr.length > 0) {
            int count = [countStr intValue];
            [[KDWeiboAppDelegate getAppDelegate].tabBarController.tabBar setBadgeValue:count atIndex:2];
        }
        //zgbin:end
    }
}

@end
