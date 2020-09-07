//
//  KDAPNSManager.m
//  kdweibo_common
//
//  Created by laijiandong on 12-9-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "KdCommon.h"
#import "KDAPNSManager.h"
#import "KDSession.h"

#import "KDManagerContext.h"
#import "KDWeiboServicesContext.h"
#import "KDConfigurationContext.h"

#import "NSDictionary+Additions.h"


NSString * const KDRemoteNotificationTypeKey = @"com.kingdee.remote_notification.type";
NSString * const KDRemoteNotificationIDKey = @"com.kingdee.remote_notification.id";
NSString * const KDRemoteNotificationDomainNameKey = @"com.kingdee.remote_notification.domain_name";

NSString * const KDNotificationDidReceiveRemoteNotificationKey = @"com.kingdee.notification.remote_notification.receive";
NSString * const KDNotificationDidReceiveLocalNotificationKey = @"com.kingdee.com.receive_local_notification";
NSString * const KDNotificationDidReceiveRemoteDMNotificationKey = @"com.kingdee.notification.remote_dm_notification.receive";
NSString * const KDNotificationDidReceiveRemoteTeamInviteNotificationKey = @"com.kingdee.notification.remote_team_invite_notification.receive";

@interface KDAPNSManager ()

@property(nonatomic, retain) NSString *token;

@end

@implementation KDAPNSManager

@synthesize token=token_;

+ (BOOL)badgeEnabled {
    return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] | UIRemoteNotificationTypeBadge;
}

+ (BOOL)alertEnabled {
    return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] | UIRemoteNotificationTypeAlert;
}

+ (BOOL)soundEnabled {
    return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] | UIRemoteNotificationTypeSound;
}

- (void)registerForRemoteNotification {
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        //iOS 10
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
        [application registerForRemoteNotifications];
    }  else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        //iOS8 - iOS10
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
        [application registerForRemoteNotifications];
    }else if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        //iOS8系统以下
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    
    /*
     
     //-- Set Notification
     if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
     {
     // iOS 8 Notifications
     [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
     
     [application registerForRemoteNotifications];
     }
     else
     {
     // iOS < 8 Notifications
     [application registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
     }*/
    
}

- (void)unregisterForRemoteNotification {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

- (void)updateWithToken:(NSData *)deviceToken {
    if (deviceToken != nil) {
        NSString *temp = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        self.token = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
    
        [self sendProviderDeviceToken];
    }
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (userInfo != nil) {
        // NSDictionary *aps = [userInfo objectNotNSNullForKey:@"aps"];
//        [[KDManagerContext globalManagerContext].unreadManager changeApplicationBadgeValue];
        
        NSDictionary *info = [userInfo objectNotNSNullForKey:@"userinfo"];
        if (info != nil && [info isKindOfClass:[NSDictionary class]]) {
             [[KDSession globalSession] setProperty:[self formatUserInfoInRemoteNotification:info] forKey:KDRemoteNotificationUserInfoKey];
        }
    }
}

- (NSDictionary *)formatUserInfoInRemoteNotification:(NSDictionary *)userInfo {
    return [NSDictionary dictionaryWithObjectsAndKeys:[userInfo stringForKey:@"n" defaultValue:@""],KDRemoteNotificationDomainNameKey,
            [userInfo stringForKey:@"t" defaultValue:@""], KDRemoteNotificationTypeKey, [userInfo stringForKey:@"i" defaultValue:@""], KDRemoteNotificationIDKey, nil];
}


//////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark send and remove provider device token

- (BOOL)isProductMode {
    BOOL productMode = YES;

#if defined (DEBUG)
    
    productMode = NO;
    
#endif

    NSLog(@"productMode is %@", productMode?@"YES":@"NO");
    return productMode;
}

- (void)sendProviderDeviceToken {
    if(token_ != nil){
        NSString *clientVersion = [KDCommon clientVersion];
        NSUInteger buildDate = [[[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance] getLastBuildDate];
        
        KDQuery *query = [KDQuery query];
        [[[[query setParameter:@"app_version" stringValue:clientVersion]
                  setParameter:@"app_buildno" integerValue:buildDate]
                  setParameter:@"device_token" stringValue:token_]
                  setParameter:@"product" booleanValue:[self isProductMode]];
        
        [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/client/:storeDevice" query:query
                                     configBlock:nil completionBlock:nil];
    }
}

- (void)removeProviderDeviceToken {
    KDQuery *query = [KDQuery query];
    [query setParameter:@"product" booleanValue:[self isProductMode]];
    
    KDServiceActionDidCompleteBlock block = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
//        NSLog(@"response string : %@", [response responseAsString]);
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/client/:removeDevice" query:query
                                 configBlock:nil completionBlock:block];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(token_);
    
    //[super dealloc];
}

@end
