//
//  KDManagerContext.m
//  kdweibo_common
//
//  Created by laijiandong on 12-8-21.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "Kdcommon.h"
#import "KDManagerContext.h"

static KDManagerContext *managerContext_;


@interface KDManagerContext ()

@property(nonatomic, retain) KDCommunityManager *communityManager;
@property(nonatomic, retain) KDUserManager *userManager;
@property(nonatomic, retain) KDUnreadManager *unreadManager;
@property(nonatomic, retain) KDAPNSManager *APNSManager;

@end


@implementation KDManagerContext

@synthesize communityManager=communityManager_;
@synthesize userManager=userManager_;
@synthesize unreadManager=unreadManager_;
@synthesize APNSManager=APNSManager_;

- (id)init {
    self = [super init];
    if(self){
        // community manager
        communityManager_ = [[KDCommunityManager alloc] init];
        
        // user manager
        userManager_ = [[KDUserManager alloc] init];
        
        // update current community
        if(userManager_.currentUserCompanyDomain != nil){
            [communityManager_ updateCurrentCommunityWithDomain:userManager_.currentUserCompanyDomain];
        }
        
        // unread manager
        unreadManager_ = [[KDUnreadManager alloc] init];
        
        // apns manager
        APNSManager_ = [[KDAPNSManager alloc] init];
    }
    
    return self;
}

+ (KDManagerContext *)globalManagerContext {
    if(managerContext_ == nil){
        managerContext_ = [[KDManagerContext alloc] init];
    }
    
    return managerContext_;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(communityManager_);
    //KD_RELEASE_SAFELY(userManager_);
    //KD_RELEASE_SAFELY(unreadManager_);
    //KD_RELEASE_SAFELY(APNSManager_);
    
    //[super dealloc];
}

@end
