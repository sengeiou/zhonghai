//
//  KDWeiboServicesFactory.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDWeiboServicesFactory.h"

#import "KDNullAuthorization.h"
#import "KDXAuthAuthorization.h"
#import "KDWeiboServicesImpl.h"

@interface KDWeiboServicesFactory ()

@property (nonatomic, retain) id<KDWeiboServices> defaultWeiboServices;

@end


@implementation KDWeiboServicesFactory

@synthesize defaultWeiboServices=defaultWeiboServices_;

- (id) init {
    self = [super init];
    if(self){
        id<KDAuthorization> authorization = [KDXAuthAuthorization xAuthorizationWithAccessToken:nil];
        defaultWeiboServices_ = [[KDWeiboServicesImpl alloc] initWithAuthorization:authorization];
    }
    
    return self;
}

- (id<KDWeiboServices>) getDefaultKDWeiboServices {
    return defaultWeiboServices_;
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(defaultWeiboServices_);
    
    //[super dealloc];
}

@end
