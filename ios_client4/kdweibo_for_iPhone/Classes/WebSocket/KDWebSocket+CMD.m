//
//  KDWebSocket+CMD.m
//  kdweibo
//
//  Created by Gil on 15/12/3.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDWebSocket+CMD.h"
#import "XTSetting.h"

static NSString *const KDWebSocketCMDMessage = @"message";
static NSString *const KDWebSocketCMDMessageRead = @"messageRead";
static NSString *const KDWebSocketCMDAddressbook = @"addressbook";
static NSString *const KDWebSocketCMDmCloudParam = @"mCloudParam";
static NSString *const KDWebSocketCMDPubAcctChange = @"pubAcctChange";
static NSString *const KDWebSocketCMDAppSub = @"appSub";
static NSString *const KDWebSocketCMDExitGroup = @"exitGroup";
static NSString *const KDWebSocketCMDExtSystemMsg = @"extSystemMsg";
static NSString *const KDWebSocketCMDAuth = @"auth";
static NSString *const KDWebSocketCMDExtMessage = @"extMessage";
static NSString *const KDWebSocketCMDExtMessageRead = @"extMessageRead";
static NSString *const KDWebSocketCMDExitExtGroup = @"exitExtGroup";
static NSString *const KDWebSocketCMDRegisteredPush = @"registeredPush";
static NSString *const KDWebSocketCMDKickOut = @"kickOut";      //修改密码秒退
static NSString *const KDWebSocketCMDLightAppUpdate = @"lightAppUpdate";//重新拉取应用列表、群应用也要更新

static NSString *const KDWebSocketCMDTodoDelMsg = @"todomessageDel";  //待办新增删除

static NSString *const KDWebSocketCMDCleanData = @"clearData";  //待办新增删除

@implementation KDWebSocket (CMD)

#pragma mark - 发指令 -

- (NSString *)getCmd:(NSString *)cmd {
    return [self getCmd:cmd lastUpdateTime:nil];
}

- (NSString *)getCmd:(NSString *)cmd lastUpdateTime:(NSString *)lastUpdateTime {
    if (cmd.length == 0) {
        return nil;
    }
    
    NSString *result = [NSString stringWithFormat:@"{\"cmd\":\"%@\",\"type\":\"query\"}", cmd];
    if (lastUpdateTime.length > 0) {
        result = [NSString stringWithFormat:@"{\"cmd\":\"%@\",\"type\":\"query\",\"lastUpdateTime\":\"%@\"}", cmd, lastUpdateTime];
    }
    return result;
}

- (NSString *)getCmd:(NSString *)cmd userId:(NSString *)userId lastUpdateTime:(NSString *)lastUpdateTime {
    if (cmd.length == 0) {
        return nil;
    }
    
    NSString *result = [NSString stringWithFormat:@"{\"cmd\":\"%@\",\"type\":\"query\"}", cmd];
    if (lastUpdateTime.length > 0) {
        result = [NSString stringWithFormat:@"{\"cmd\":\"%@\",\"type\":\"query\",\"lastUpdateTime\":\"%@\"}", cmd, lastUpdateTime];
    }
    if (userId.length > 0) {
        result = [NSString stringWithFormat:@"{\"cmd\":\"%@\",\"type\":\"query\",\"lastUpdateTime\":\"%@\",\"userId\":\"%@\"}", cmd, lastUpdateTime,userId];
    }
    return result;
}

- (void)queryAll {
    [self queryMessage];
    [self queryMessageRead];
    [self queryAddressbook];
    [self querymCloudParam];
    [self querymAppSub];
    [self queryExitGroup];
    [self queryExtSystemMsg];
    [self querymPubAcctChange];
    [self queryTodoDelMsg];
    [self queryAppListChange];
    [self queryCleanData];
}

- (void)queryMessage {
    [self sendMessage:[self getCmd:KDWebSocketCMDMessage]];
}

- (void)queryMessageRead {
    [self sendMessage:[self getCmd:KDWebSocketCMDMessageRead]];
}

- (void)queryAddressbook {
    [self sendMessage:[self getCmd:KDWebSocketCMDAddressbook]];
}

- (void)querymCloudParam {
    [self sendMessage:[self getCmd:KDWebSocketCMDmCloudParam]];
}

- (void)querymAppSub {
    [self sendMessage:[self getCmd:KDWebSocketCMDAppSub]];
}

- (void)queryExitGroup {
    [self sendMessage:[self getCmd:KDWebSocketCMDExitGroup]];
}

- (void)queryExtSystemMsg {
    [self sendMessage:[self getCmd:KDWebSocketCMDExtSystemMsg]];
}

- (void)querymPubAcctChange {
    [self sendMessage:[self getCmd:KDWebSocketCMDPubAcctChange lastUpdateTime:[XTSetting sharedSetting].pubAcctUpdateTime]];
}

- (void)queryTodoDelMsg {
//    if ([XTSetting sharedSetting].msgLastDelUpdateTime != nil || [XTSetting sharedSetting].msgLastDelUpdateTime.length > 0) {
         [self sendMessage:[self getCmd:KDWebSocketCMDTodoDelMsg userId:[BOSConfig sharedConfig].user.userId lastUpdateTime:[XTSetting sharedSetting].msgLastDelUpdateTime]];
//    }else
//    {
//        [self sendMessage:[self getCmd:KDWebSocketCMDTodoDelMsg lastUpdateTime:[[NSDate date] dz_stringValue]]];
//    }
   
}
- (void)queryAppListChange {
    [self sendMessage:[self getCmd:KDWebSocketCMDLightAppUpdate lastUpdateTime:[XTSetting sharedSetting].appListUpdateTime]];
}

- (void)queryCleanData{
    [self sendMessage:[self getCmd:KDWebSocketCMDCleanData lastUpdateTime:[XTSetting sharedSetting].lastClearDataUpdateTime]];
}
#pragma mark - 处理指令 -

- (void)handle:(id)message needRecord:(BOOL)needRecord {
    __weak KDWebSocket *selfInBlock = self;
    
    dispatch_async(self.handleQueue, ^{
        if (![message isKindOfClass:[NSString class]]) {
            return;
        }
        
        id result = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (![result isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        NSString *cmd = result[@"cmd"];
        
        if (![cmd isKindOfClass:[NSString class]]) {
            return;
        }
        
        if (cmd.length == 0) {
            return;
        }
        
        if (needRecord) {
            //除了踢出指令，其他指令都会存下来，以便业务处理失败后可以再次执行
            if (![cmd isEqualToString:KDWebSocketCMDAuth]) {
                [selfInBlock.cmdMap setObject:message forKey:cmd];
            }
        }
        
        if ([cmd isEqualToString:KDWebSocketCMDAuth]) {
            id errorCode = result[@"errorCode"];
            if (errorCode && [errorCode intValue] == 2) {
                NSString *error = result[@"error"];
                id data = result[@"data"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelLogout:error:data:)]) {
                        [selfInBlock.delegate notificationChannelLogout:selfInBlock
                                                                  error:error
                                                                   data:data];
                    }
                });
            }
        }
        else if ([cmd isEqualToString:KDWebSocketCMDMessage]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelNewMessage:lastUpdateTime:)]) {
                    [selfInBlock.delegate notificationChannelNewMessage:selfInBlock lastUpdateTime:result[@"lastUpdateTime"]];
                }
            });
        }
        else if ([cmd isEqualToString:KDWebSocketCMDMessageRead]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelMessageReadStatus:lastUpdateTime:)]) {
                    [selfInBlock.delegate notificationChannelMessageReadStatus:selfInBlock lastUpdateTime:result[@"lastUpdateTime"]];
                }
            });
        }
        else if ([cmd isEqualToString:KDWebSocketCMDExitGroup]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelExitGroup:lastUpdateTime:)]) {
                    [selfInBlock.delegate notificationChannelExitGroup:selfInBlock lastUpdateTime:result[@"lastUpdateTime"]];
                }
            });
        }
        else if ([cmd isEqualToString:KDWebSocketCMDExtMessage]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelExternalNewMessage:lastUpdateTime:)]) {
                    [selfInBlock.delegate notificationChannelExternalNewMessage:selfInBlock lastUpdateTime:result[@"lastUpdateTime"]];
                }
            });
        }
        else if ([cmd isEqualToString:KDWebSocketCMDExtMessageRead]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelExternalMessageReadStatus:lastUpdateTime:)]) {
                    [selfInBlock.delegate notificationChannelExternalMessageReadStatus:selfInBlock lastUpdateTime:result[@"lastUpdateTime"]];
                }
            });
        }
        else if ([cmd isEqualToString:KDWebSocketCMDExitExtGroup]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelExternalExitGroup:lastUpdateTime:)]) {
                    [selfInBlock.delegate notificationChannelExternalExitGroup:selfInBlock lastUpdateTime:result[@"lastUpdateTime"]];
                }
            });
        }
        else if ([cmd isEqualToString:KDWebSocketCMDAddressbook]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelAddressBookChange:lastUpdateTime:)]) {
                    [selfInBlock.delegate notificationChannelAddressBookChange:selfInBlock lastUpdateTime:result[@"lastUpdateTime"]];
                }
            });
        }
        else if ([cmd isEqualToString:KDWebSocketCMDAppSub]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelApplicationChange:lastUpdateTime:)]) {
                    [selfInBlock.delegate notificationChannelApplicationChange:selfInBlock lastUpdateTime:result[@"lastUpdateTime"]];
                }
            });
        }
        else if ([cmd isEqualToString:KDWebSocketCMDmCloudParam]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelmCloudParamChange:lastUpdateTime:)]) {
                    [selfInBlock.delegate notificationChannelmCloudParamChange:selfInBlock lastUpdateTime:result[@"lastUpdateTime"]];
                }
            });
        }
        else if ([cmd isEqualToString:KDWebSocketCMDPubAcctChange]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelPubAcctChange:lastUpdateTime:pubAcctIds:)]) {
                    [selfInBlock.delegate notificationChannelPubAcctChange:selfInBlock lastUpdateTime:result[@"lastUpdateTime"] pubAcctIds:result[@"pubAcctIds"]];
                }
            });
        }
        else if ([cmd isEqualToString:KDWebSocketCMDExtSystemMsg]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelExtSystemMsg:msgFromSystem:)]) {
                    [selfInBlock.delegate notificationChannelExtSystemMsg:selfInBlock msgFromSystem:result[@"msgFromSystem"]];
                }
            });
        }
        else if ([cmd isEqualToString:KDWebSocketCMDRegisteredPush]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelRegisteredPush:data:)]) {
                    [selfInBlock.delegate notificationChannelRegisteredPush:selfInBlock data:result[@"data"]];
                }
            });
        }
        else if ([cmd isEqualToString:KDWebSocketCMDKickOut]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationKickOut:lastUpdateTime:)]) {
                    [selfInBlock.delegate notificationKickOut:selfInBlock lastUpdateTime:result[@"lastUpdateTime"]];
                }
            });
        }
        //待办删除指令
        else if ([cmd isEqualToString:KDWebSocketCMDTodoDelMsg]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationTodoDel:hasMsgDel:)]) {
                    [selfInBlock.delegate notificationTodoDel:selfInBlock lastUpdateTime:result[@"lastUpdateTime"]];
                }
            });
        }
        else if ([cmd isEqualToString:KDWebSocketCMDLightAppUpdate]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelReloadAppList:data:)]) {
                    [selfInBlock.delegate notificationChannelReloadAppList:selfInBlock data:result[@"lastUpdateTime"]];
                }
            });
        }else if ([cmd isEqualToString:KDWebSocketCMDCleanData]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfInBlock.delegate && [selfInBlock.delegate respondsToSelector:@selector(notificationChannelCleanData:type:lastUpdateTime:)]) {
                    [selfInBlock.delegate notificationChannelCleanData:selfInBlock type:result[@"dataType"] lastUpdateTime:result[@"lastUpdateTime"]];
                }
            });
        }

        
    });
}

- (void)handle:(id)message {
    [self handle:message needRecord:YES];
}

@end
