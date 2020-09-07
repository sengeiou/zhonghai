//
//  KDAuthToken.m
//  kdweibo_common
//
//  Created by laijiandong on 12-8-20.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDAuthToken.h"

#import "NSString+Additions.h"

@implementation KDAuthToken

@synthesize keyToken=keyToken_;
@synthesize secretToken=secretToken_;

- (id)init {
    self = [super init];
    if(self){
        
    }
    
    return self;
}

- (id)initWithKey:(NSString *)key secret:(NSString *)secret {
    self = [super init];
    if(self){
        keyToken_ = [key copy];
        secretToken_ = [secret copy];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self){
        keyToken_ = [[aDecoder decodeObjectForKey:@"keyToken"] copy];
        secretToken_ = [[aDecoder decodeObjectForKey:@"secretToken"] copy];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if(keyToken_ != nil){
        [aCoder encodeObject:keyToken_ forKey:@"keyToken"];
    }
    
    if(secretToken_ != nil){
        [aCoder encodeObject:secretToken_ forKey:@"secretToken"];
    }
}

- (BOOL)isValid {
    return ((keyToken_ != nil && ([keyToken_ length] > 0))
            && (secretToken_ != nil && ([secretToken_ length] > 0)));
}

+ (KDAuthToken *)authTokenWithString:(NSString *)responseString {
    KDAuthToken *authToken = nil;
    
    if(responseString == nil || [responseString length] < 1){
        // invalid response string
        return authToken;
    }
    
    NSString *token = [responseString searchAsURLQueryWithNeedle:@"oauth_token="];
    NSString *secret = [responseString searchAsURLQueryWithNeedle:@"oauth_token_secret="];
    if(token != nil && secret != nil){
        authToken = [[KDAuthToken alloc] initWithKey:token secret:secret];//;/ autorelease];
    }
    
    return authToken;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(keyToken_);
    //KD_RELEASE_SAFELY(secretToken_);
    
    //[super dealloc];
}
    
@end
