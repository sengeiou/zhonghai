//
//  KDWeiboGlobals.m
//  kdweibo_common
//
//  Created by laijiandong on 13-1-4.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDWeiboGlobals.h"

#import "KDSession.h"

#import "KDRequestDispatcher.h"
#import "KDDBManager.h"
#import "KDManagerContext.h"
#import "KDUtility.h"
#import "SDImageCache.h"

@implementation KDWeiboGlobals

+ (KDWeiboGlobals *)defaultWeiboGlobals {
    static KDWeiboGlobals *weiboGlobals = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        weiboGlobals = [[KDWeiboGlobals alloc] init];
    });
    
    return weiboGlobals;
}

- (void)disconnectDatabaseConnection {
    [[KDDBManager sharedDBManager] close];
}

- (void)signOut {
    // disconnect from database
    [self disconnectDatabaseConnection];
    
    // stop get unread job
    [[KDManagerContext globalManagerContext].unreadManager stop];
    [[KDManagerContext globalManagerContext].unreadManager reset];
    [[KDManagerContext globalManagerContext].unreadManager changeApplicationBadgeValue];
    
    // remove cached comunity data
    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    [communityManager cleanCommunities];
    [communityManager reset];
    
    // remove cached user data
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    [userManager cleanUserData];
    [userManager reset];
    
    // clear global session
    [[KDSession globalSession] clearSessionOnSignOut];
    
    // remove all the cached data for user at local file system
    [[KDUtility defaultUtility] removeAllCachedDataForCurrentUser];
    
    // cancel all the networks
    [[KDRequestDispatcher globalRequestDispatcher] removeAllRequests];
    
//    [[SDImageCache sharedImageCache] clearDisk];
//    [[SDImageCache sharedImageCache] clearMemory];
    
    // send request to server to disable device token
    KDAPNSManager *APNSManager = [KDManagerContext globalManagerContext].APNSManager;
    [APNSManager unregisterForRemoteNotification];
    [APNSManager removeProviderDeviceToken];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"kdweibo_refresh_date"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
