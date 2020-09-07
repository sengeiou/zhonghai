//
//  KDNotificationChannelCenter.h
//  kdweibo
//
//  Created by Gil on 15/12/1.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const KDNotificationChannelNewMessage;
extern NSString *const KDNotificationChannelExternalNewMessage;
extern NSString *const KDHasExitGroupNotification;
extern NSString *const KDNotificationChannelChangeCompanyInfo;
extern NSString *const KDNotificationRelationNewMessage;
extern NSString *const KDHasMessageDelNotification;

@interface KDNotificationChannelCenter : NSObject

+ (instancetype)defaultCenter;

- (void)startChannel;
- (void)closeChannel;

- (BOOL)isWebSocketChannel;
- (BOOL)isPollingChannel;

//登出
- (void)logout:(NSString *)error
          data:(id)data;

@end
