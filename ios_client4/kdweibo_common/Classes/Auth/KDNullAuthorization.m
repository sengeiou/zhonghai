//
//  KDNullAuthorization.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDNullAuthorization.h"

static KDNullAuthorization *SINGLETON = nil;


@implementation KDNullAuthorization

- (id) init {
    self = [super init];
    if(self){
        
    }
    
    return self;
}

+ (KDNullAuthorization *) getInstance {
    @synchronized(self){
        if(SINGLETON == nil){
            SINGLETON = [[KDNullAuthorization alloc] init];
        }
    }
    
    return SINGLETON;
}

/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDAuthorization protocol methods

- (KDAuthorizationType)getAuthorizationType {
    return KDAuthorizationTypeNone;
}

- (NSString *)getAuthorizationHeader:(KDRequestWrapper *)req {
    return nil;
}

- (BOOL)isEnabled {
    return NO;
}

- (BOOL)isEqual:(id)object {
    return SINGLETON == object;
}

- (NSString *)description {
    return @"KDNullAuthorization{SINGLETON}";
}

- (void)dealloc {
    //[super dealloc];
}

@end
