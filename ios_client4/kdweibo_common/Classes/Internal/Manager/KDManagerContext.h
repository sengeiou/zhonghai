//
//  KDManagerContext.h
//  kdweibo_common
//
//  Created by laijiandong on 12-8-21.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDCommunityManager.h"

#import "KDUserManager.h"
#import "KDUnreadManager.h"
#import "KDAPNSManager.h"

@interface KDManagerContext : NSObject {
 @private
    KDCommunityManager *communityManager_;
    KDUserManager *userManager_;
    KDUnreadManager *unreadManager_;
    KDAPNSManager *APNSManager_;
}

@property(nonatomic, retain, readonly) KDCommunityManager *communityManager;
@property(nonatomic, retain, readonly) KDUserManager *userManager;
@property(nonatomic, retain, readonly) KDUnreadManager *unreadManager;
@property(nonatomic, retain, readonly) KDAPNSManager *APNSManager;

+ (KDManagerContext *)globalManagerContext;

@end
