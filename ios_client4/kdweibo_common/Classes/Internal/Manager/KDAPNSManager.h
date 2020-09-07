//
//  KDAPNSManager.h
//  kdweibo_common
//
//  Created by laijiandong on 12-9-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDObject.h"

UIKIT_EXTERN NSString * const KDRemoteNotificationTypeKey;
UIKIT_EXTERN NSString * const KDRemoteNotificationIDKey;
UIKIT_EXTERN NSString * const KDRemoteNotificationDomainNameKey;

UIKIT_EXTERN NSString * const KDNotificationDidReceiveRemoteNotificationKey;
UIKIT_EXTERN NSString * const KDNotificationDidReceiveLocalNotificationKey;
UIKIT_EXTERN NSString * const KDNotificationDidReceiveRemoteDMNotificationKey;
UIKIT_EXTERN NSString * const KDNotificationDidReceiveRemoteTeamInviteNotificationKey;

@interface KDAPNSManager : KDObject {
 @private
    NSString *token_; // APNS token
}

- (void)registerForRemoteNotification;
- (void)unregisterForRemoteNotification;

- (void)updateWithToken:(NSData *)deviceToken;
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)sendProviderDeviceToken;
- (void)removeProviderDeviceToken;

@end
