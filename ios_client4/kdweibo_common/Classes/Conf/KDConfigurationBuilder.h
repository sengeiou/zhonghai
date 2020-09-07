//
//  KDConfigurationBuilder.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-12.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDConfiguration.h"

@class KDConfigurationBase;

@interface KDConfigurationBuilder : NSObject {
@private
    KDConfigurationBase *configurationModel_;
}

// setters

- (KDConfigurationBuilder *) setApplicationName:(NSString *)applicationName;

- (KDConfigurationBuilder *) setDebugEnabled:(BOOL)debugEnabled;

- (KDConfigurationBuilder *) setClientVersion:(NSString *)clientVersion;

- (KDConfigurationBuilder *) setBaseDatabaseUserVersion:(NSUInteger)baseDatabaseUserVersion;

- (KDConfigurationBuilder *) setUserAgent:(NSString *)userAgent;

// methods for http configuration

- (KDConfigurationBuilder *) setIncludeExtraHttpHeadersEnabled:(BOOL)isIncludeExtraHttpHeadersEnabled;

- (KDConfigurationBuilder *) setRequestExtraHeaders:(NSDictionary *)requestExtraHeaders;

- (KDConfigurationBuilder *) setRequestHeaders:(NSDictionary *)requestHeaders;

- (KDConfigurationBuilder *) setServerBaseURL:(NSString *)serverBaseURL;

- (KDConfigurationBuilder *) setRestBaseURL:(NSString *)restBaseURL;

- (KDConfigurationBuilder *) setHttpConnectionTimeout:(NSUInteger)httpConnectionTimeout;

- (KDConfigurationBuilder *) setHttpRetryCount:(NSUInteger)httpRetryCount;

- (KDConfigurationBuilder *) setHttpRetryIntervalSeconds:(NSTimeInterval)httpRetryIntervalSeconds; // in seconds

- (KDConfigurationBuilder *) setHttpMaxTotalConnections:(NSUInteger)httpMaxTotalConnections;


// oauth related setter

- (KDConfigurationBuilder *) setOAuthConsumerKey:(NSString *)oAuthConsumerKey;

- (KDConfigurationBuilder *) setOAuthConsumerSecret:(NSString *)oAuthConsumerSecret;

- (KDConfigurationBuilder *) setOAuthAccessToken:(NSString *)oAuthAccessToken;

- (KDConfigurationBuilder *) setOAuthAccessTokenSecret:(NSString *)oAuthAccessTokenSecret;

- (KDConfigurationBuilder *) setOAuthRequestTokenURL:(NSString *)oAuthRequestTokenURL;

- (KDConfigurationBuilder *) setOAuthAuthorizationURL:(NSString *)oAuthAuthorizationURL;

- (KDConfigurationBuilder *) setOAuthAccessTokenURL:(NSString *)oAuthAccessTokenURL;

- (id<KDConfiguration>) build;

@end
