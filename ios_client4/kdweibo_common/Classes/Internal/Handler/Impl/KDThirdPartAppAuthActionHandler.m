//
//  KDThirdPartAppAuthActionHandler.m
//  kdweibo_common
//
//  Created by laijiandong on 12-8-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDThirdPartAppAuthActionHandler.h"

#import "KDResponseWrapper.h"

#import "NSString+Additions.h"
#import "NSDictionary+Additions.h"
#import "KDReachabilityManager.h"


#define KD_3RD_AUTH_PARAM_SCHEMA    @"schema"
#define KD_3RD_AUTH_PARAM_HOST      @"host"
#define KD_3RD_AUTH_PARAM_SOURCE    @"source"
#define KD_3RD_AUTH_PARAM_TOKEN     @"third_token"
#define KD_3RD_AUTH_PARAM_USER_NAME @"user_name"
#define KD_3RD_AUTH_PARAM_PASSWORD  @"password"
#define KD_3RD_AUTH_PARAM_CALLBACK  @"callback"

@implementation KDThirdPartAppAuthActionHandler

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (BOOL)isSupportSchema:(NSString *)schema {
    if (schema == nil || [schema length] < 1) return NO;
    
    NSString *temp = [schema lowercaseString];
    
    return [@"kdweibo" isEqualToString:temp]
            || [@"kdweibo4ipad" isEqualToString:temp]
            || [@"kdweiboavailable" isEqualToString:temp];
}

- (BOOL)isSupportHost:(NSString *)host {
    if (host == nil || [host length] < 1) return NO;
    
    NSString *temp = [host lowercaseString];
    return [@"auth" isEqualToString:temp];
}

// Override
- (BOOL)validate {
    BOOL isValid = NO;
     
    NSString *schema = [super.query genericParameterForName:KD_3RD_AUTH_PARAM_SCHEMA];
    NSString *host = [super.query genericParameterForName:KD_3RD_AUTH_PARAM_HOST];
    if ([self isSupportSchema:schema] && [self isSupportHost:host]) {
        NSString *token = [super.query genericParameterForName:KD_3RD_AUTH_PARAM_TOKEN];
        NSString *username = [super.query genericParameterForName:KD_3RD_AUTH_PARAM_USER_NAME];
        if ((token != nil && [token length] > 0) || ((username != nil && [username length] > 0))) {
            isValid = YES;
        }
                              
    }
    
    return isValid;
}

// Override
- (BOOL)execute {
    BOOL done = NO;
    if ([self validate]) {
        done = YES;
    }
    
    return done;
}

+ (KDQuery *)toQueryWithOpenURL:(NSURL *)url {
    // format like -> kdweibo://auth?source=vanke&third_token=tt_param&network_id=networkid&callback=cb_parm
    KDQuery *query = [KDQuery query];
    if (url) {
        NSString *schema = [url scheme];
        NSString *host = [url host];
        
        [[query setParameter:KD_3RD_AUTH_PARAM_SCHEMA stringValue:schema]
                setParameter:KD_3RD_AUTH_PARAM_HOST stringValue:host];
        
        NSString *queryString = [url query];
        if (queryString != nil && [queryString length] > 0) {
            NSString *source = [queryString searchAsURLQueryWithNeedle:@"source="];
            NSString *token = [queryString searchAsURLQueryWithNeedle:@"third_token="];
            NSString *callback = [queryString searchAsURLQueryWithNeedle:@"callback="];
            // Basic auth
            NSString *userName = [queryString searchAsURLQueryWithNeedle:@"user_name="];
            NSString *password = [queryString searchAsURLQueryWithNeedle:@"password="];
            
            [[[[[query setParameter:KD_3RD_AUTH_PARAM_SOURCE stringValue:source]
                     setParameter:KD_3RD_AUTH_PARAM_TOKEN stringValue:token]
                     setParameter:KD_3RD_AUTH_PARAM_CALLBACK stringValue:callback]
                     setParameter:KD_3RD_AUTH_PARAM_USER_NAME stringValue:userName]
                     setParameter:KD_3RD_AUTH_PARAM_PASSWORD stringValue:password];
        }
    }
    
    return query;
}

+ (NSString *)messageForAuthorizeDidFailResponse:(KDResponseWrapper *)response canRetry:(BOOL *)canRetry {
    int statusCode = [response statusCode];
    BOOL retry = NO;
    NSString *message = nil;
    
    if (statusCode >= 400 && statusCode < 500) {
        if(statusCode == 401){
            message = NSLocalizedString(@"USERNAME_OR_PASSWORD_BROKEN", @"");
        }else {
            id obj = [response responseAsJSONObject];
            if (obj != nil && [obj isKindOfClass:[NSDictionary class]]) {
                int code = [(NSDictionary *)obj intForKey:@"code"];
                if (40111 == code || 40112 == code || 40116 == code) {
                    message = NSLocalizedString(@"AUTHORIZATION_TOKEN_DID_EXPIRED", @"");
                }
            }
        }
    }
    
    if (message == nil) {
        if (0 == statusCode) {
            BOOL isReachable =[[KDReachabilityManager sharedManager] isReachable];
            if(!isReachable) {
                message = NSLocalizedString(@"NETWORK_ERROR_UNREACHABLE", @"");
            }
        }
        
        if (message == nil) {
            message = NSLocalizedString(@"NETWORK_ERROR_OVERTIME", @"");
        }
        
        retry = YES;
    }
    
    if (canRetry != NULL) {
        *canRetry = retry;
    }
    
    return message;
}

- (void)dealloc {
    //[super dealloc];
}

@end
