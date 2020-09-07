//
//  KDPropertyConfiguration.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"

#import "KDPropertyConfiguration.h"


#define KD_PREF_APPNAME                                 @"kdweibo.pref.appName"
#define KD_PREF_DEBUG                                   @"kdweibo.pref.debug"
#define KD_PREF_HAS_APP_TUTORIALS                       @"kdweibo.pref.hasAppTutorials"

#define KD_PREF_BASE_DATABASE_USER_VERSION              @"kdweibo.pref.baseDatabaseUserVersion"
#define KD_PREF_LAST_BUILD_DATE                         @"kdweibo.pref.lastBuildDate"

#define KD_PREF_INCLUDE_EXTRA_HTTP_HEADERS_ENABLED      @"kdweibo.pref.includeExtraHttpHeadersEnabled"

#define KD_PREF_SERVER_BASE_URL                         @"kdweibo.pref.serverBaseURL"
#define KD_PREF_REST_BASE_URL                           @"kdweibo.pref.restBaseURL"

#define KD_PREF_HTTP_CONNECTION_TIMEOUT                 @"kdweibo.pref.httpConnectionTimeout"
#define KD_PREF_HTTP_RETRY_COUNT                        @"kdweibo.pref.httpRetryCount"
#define KD_PREF_HTTP_RETRY_INTERVAL_SECONDS             @"kdweibo.pref.httpRetryIntervalSeconds"
#define KD_PREF_MAX_TOTAL_CONNECTIONS                   @"kdweibo.pref.maxTotalConnections"

#define KD_PREF_OAUTH_REQUEST_TOKEN_URL                 @"kdweibo.pref.oAuthRequestTokenURL"
#define KD_PREF_OAUTH_AUTHORIZATION_URL                 @"kdweibo.pref.oAuthAuthorizationURL"
#define KD_PREF_OAUTH_ACCESS_TOKEN_URL                  @"kdweibo.pref.oAuthAccessTokenURL"

#define KD_PREF_LOCAL_DEVELOPMENT_REST_BASE_URL         @"kdweibo.pref.local.development.restBaseURL"
#define KD_PREF_LOCAL_DEVELOPMENT_SERVER_BASE_URL       @"kdweibo.pref.local.development.serverBaseURL"
#define KD_PREF_USE_LOCAL_URL                           @"kdweibo.pref.useLocalURL"
#define KD_PREF_NEW_FUNCTIONS_                          @"kdweibo.pref.newFunctions"


@implementation KDPropertyConfiguration

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (BOOL)notNil:(NSDictionary *)info key:(NSString *)key {
    return ([info objectForKey:key] != nil) ? YES : NO;
}

- (void)loadProperties:(NSDictionary *)info {
    if(info != nil){
        // app name
        id obj = [info objectForKey:KD_PREF_APPNAME];
        if(obj != nil){
            super.applicationName = obj;
        }
        
        // debug
        obj = [info objectForKey:KD_PREF_DEBUG];
        if(obj != nil){
            super.debug = [(NSNumber *)obj boolValue];
        }
        
        // has app tutorials
        obj = [info objectForKey:KD_PREF_HAS_APP_TUTORIALS];
        if(obj != nil){
            super.hasAppTutorials = [(NSNumber *)obj boolValue];
        }
        
        // base database user version
        obj = [info objectForKey:KD_PREF_BASE_DATABASE_USER_VERSION];
        if(obj != nil){
            super.baseDatabaseUserVersion = [(NSNumber *)obj unsignedIntegerValue];
        }
        
        // application built date at last time
        obj = [info objectForKey:KD_PREF_LAST_BUILD_DATE];
        if(obj != nil){
            super.lastBuildDate = [(NSNumber *)obj unsignedIntegerValue];
        }
        
        // include extra http headers
        obj = [info objectForKey:KD_PREF_INCLUDE_EXTRA_HTTP_HEADERS_ENABLED];
        if(obj != nil){
            super.includeExtraHttpHeadersEnabled = [(NSNumber *)obj boolValue];
        }
        
        // use local RESTful url as target
        BOOL useLocalURL = NO;
        /*
        obj = [info objectForKey:KD_PREF_USE_LOCAL_URL];
        if(obj != nil){
          useLocalURL = [(NSNumber *)obj boolValue];
        }
         */
        NSString *preference_ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"weibo_preference_ip"];
        useLocalURL = [preference_ip length]>0;
        
        if (![preference_ip hasPrefix:@"http://"] && useLocalURL) {
            preference_ip = [@"http://" stringByAppendingString:preference_ip];
        }
        
        // server base url
//        obj = [info objectForKey:(useLocalURL ? KD_PREF_LOCAL_DEVELOPMENT_SERVER_BASE_URL : KD_PREF_SERVER_BASE_URL)];
        obj = useLocalURL ? preference_ip:[info objectForKey:KD_PREF_SERVER_BASE_URL];
        if(obj != nil){
            super.serverBaseURL = obj;
            [[NSUserDefaults standardUserDefaults] setObject:obj forKey:@"SERVER_BASE_URL_WITH_HTTP"];
        }
        
        // RESTful url
        
        /*
        obj = [info objectForKey:(useLocalURL ? KD_PREF_LOCAL_DEVELOPMENT_REST_BASE_URL : KD_PREF_REST_BASE_URL)];
        if(obj != nil){
            super.restBaseURL = obj;
        }
         */
        if (obj != nil) {
            super.restBaseURL = [obj stringByAppendingString:@"/snsapi"];
        }
        
        // http connection timeout
        obj = [info objectForKey:KD_PREF_HTTP_CONNECTION_TIMEOUT];
        if(obj != nil){
            super.httpConnectionTimeout = [(NSNumber *)obj doubleValue];
        }
        
        // http retry count
        obj = [info objectForKey:KD_PREF_HTTP_RETRY_COUNT];
        if(obj != nil){
            super.httpRetryCount = [(NSNumber *)obj integerValue];
        }
        
        // http retry interval in seconds
        obj = [info objectForKey:KD_PREF_HTTP_RETRY_INTERVAL_SECONDS];
        if(obj != nil){
            super.httpRetryIntervalSeconds = [(NSNumber *)obj doubleValue];
        }
        
        // http max total connections
        obj = [info objectForKey:KD_PREF_MAX_TOTAL_CONNECTIONS];
        if(obj != nil){
            super.httpMaxTotalConnections = [(NSNumber *)obj integerValue];
        }
        
        // oath request url
        obj = [info objectForKey:KD_PREF_OAUTH_REQUEST_TOKEN_URL];
        if(obj != nil){
            super.oAuthRequestTokenURL = obj;
        }
        
        // oauth authroization url
        obj = [info objectForKey:KD_PREF_OAUTH_AUTHORIZATION_URL];
        if(obj != nil){
            super.oAuthAuthorizationURL = obj;
        }
        
        // oauth access token url
        obj = [info objectForKey:KD_PREF_OAUTH_ACCESS_TOKEN_URL];
        if(obj != nil){
            super.oAuthAccessTokenURL = obj;
        }
        obj = [info objectForKey:KD_PREF_NEW_FUNCTIONS_];
        if(obj != nil) {
            super.newFunctions = obj;
        }
        
        //new function
    }
}

- (void) deserializeWithData:(NSData *)data {
    if(data != nil){
        NSDictionary *info = nil;
        BOOL succeed = YES;
        if([NSPropertyListSerialization respondsToSelector:@selector(propertyListWithData:options:format:error:)]){
            NSError *error = nil;
            info = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
            
            if(error != nil){
                succeed = NO;
                NSLog(@"%@", [error localizedDescription]);
            }
            
        }else {
            NSString *message = nil; 
            info = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&message];
            
            if(message != nil){
                succeed = NO;
                NSLog(@"%@", message);
                //KD_RELEASE_SAFELY(message);
            }
        }
        
        if(succeed){
            [self loadProperties:info];
        }
    }
}

- (id) init {
    self = [super initWithDefaultOptions];
    if(self){
        
    }
    
    return self;
}



- (id) initWithData:(NSData *)data {
    self = [self init];
    if(self){
        [self deserializeWithData:data];
    }
    
    return self;
}

- (id) initWithPath:(NSString *)path {
    self = [self init];
    if(self){
        if(path != nil){
            NSData *data = [NSData dataWithContentsOfFile:path];
            [self deserializeWithData:data];
        }
    }
    
    return self;
}

- (void) dealloc {
    
    //[super dealloc];
}

@end

