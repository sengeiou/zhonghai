//
//  KDXAuthAuthorization.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDXAuthAuthorization.h"

#import "KDConfigurationContext.h"

@implementation KDXAuthAuthorization

@synthesize consumerToken=consumerToken_;
@synthesize accessToken=accessToken_;

- (id)init {
    self = [super init];
    if(self){
        // consumer key and secret
        id<KDConfiguration> conf = [[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance];
        consumerToken_ = [[KDAuthToken alloc] initWithKey:[conf getOAuthConsumerKey] secret:[conf getOAuthConsumerSecret]];
    }
    
    return self;
}

- (id)initWithAccessToken:(NSString *)token secret:(NSString *)secret {
    self = [self init];
    if(self){
        accessToken_ = [[KDAuthToken alloc] initWithKey:token secret:secret];
    }
    
    return self;
}

+ (KDXAuthAuthorization *)xAuthorizationWithAccessToken:(KDAuthToken *)accessToken {
    KDXAuthAuthorization *xAuthorization = [[KDXAuthAuthorization alloc] init];// autorelease];
    xAuthorization.accessToken = accessToken;
    
    return xAuthorization;
}


/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDAuthorization protocol methods

- (KDAuthorizationType)getAuthorizationType {
    return KDAuthorizationTypeXAuth;
}

- (NSString *)getAuthorizationHeader:(KDRequestWrapper *)req {
    return nil;
}

- (BOOL)isEnabled {
    return YES;
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(consumerToken_);
    //KD_RELEASE_SAFELY(accessToken_);
    
    //[super dealloc];
}

@end
