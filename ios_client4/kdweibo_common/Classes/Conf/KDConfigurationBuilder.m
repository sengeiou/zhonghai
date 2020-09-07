//
//  KDConfigurationBuilder.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-12.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"

#import "KDConfigurationBuilder.h"
#import "KDPropertyConfiguration.h"

@interface KDConfigurationBuilder ()

@property (nonatomic, retain) KDConfigurationBase *configurationModel;

@end


@implementation KDConfigurationBuilder

@synthesize configurationModel=configurationModel_;

- (id) init {
    self = [super init];
    if(self){
        configurationModel_ = [[KDPropertyConfiguration alloc] init];
    }
    
    return self;
}


// setters

- (KDConfigurationBuilder *) setApplicationName:(NSString *)applicationName {
    configurationModel_.applicationName = applicationName;
    
    return self;
}

- (KDConfigurationBuilder *) setDebugEnabled:(BOOL)debugEnabled {
    configurationModel_.debug = debugEnabled;
    
    return self;
}

- (KDConfigurationBuilder *) setClientVersion:(NSString *)clientVersion {
    configurationModel_.clientVersion = clientVersion;
    
    return self;
}

- (KDConfigurationBuilder *) setBaseDatabaseUserVersion:(NSUInteger)baseDatabaseUserVersion {
    configurationModel_.baseDatabaseUserVersion = baseDatabaseUserVersion;
    
    return self;
}

- (KDConfigurationBuilder *) setUserAgent:(NSString *)userAgent {
    configurationModel_.userAgent = userAgent;
    
    return self;
}

// methods for http configuration

- (KDConfigurationBuilder *) setIncludeExtraHttpHeadersEnabled:(BOOL)includeExtraHttpHeadersEnabled {
    configurationModel_.includeExtraHttpHeadersEnabled = includeExtraHttpHeadersEnabled;
    
    return self;
}

- (KDConfigurationBuilder *) setRequestExtraHeaders:(NSDictionary *)requestExtraHeaders {
    configurationModel_.requestExtraHeaders = requestExtraHeaders;
    
    return self;
}

- (KDConfigurationBuilder *) setRequestHeaders:(NSDictionary *)requestHeaders {
    configurationModel_.requestHeaders = requestHeaders;
    
    return self;
}

- (KDConfigurationBuilder *) setServerBaseURL:(NSString *)serverBaseURL {
    configurationModel_.serverBaseURL = serverBaseURL;
    
    return self;
}

- (KDConfigurationBuilder *) setRestBaseURL:(NSString *)restBaseURL {
    configurationModel_.restBaseURL = restBaseURL;
    
    return self;
}

- (KDConfigurationBuilder *) setHttpConnectionTimeout:(NSUInteger)httpConnectionTimeout {
    configurationModel_.httpConnectionTimeout = httpConnectionTimeout;
    
    return self;
}

- (KDConfigurationBuilder *) setHttpRetryCount:(NSUInteger)httpRetryCount {
    configurationModel_.httpRetryCount = httpRetryCount;
    
    return self;
}

- (KDConfigurationBuilder *) setHttpRetryIntervalSeconds:(NSTimeInterval)httpRetryIntervalSeconds {
    configurationModel_.httpRetryIntervalSeconds = httpRetryIntervalSeconds;
    
    return self;
}

- (KDConfigurationBuilder *) setHttpMaxTotalConnections:(NSUInteger)httpMaxTotalConnections {
    configurationModel_.httpMaxTotalConnections = httpMaxTotalConnections;
    
    return self;
}


// oauth related setter

- (KDConfigurationBuilder *) setOAuthConsumerKey:(NSString *)oAuthConsumerKey {
    configurationModel_.oAuthConsumerKey = oAuthConsumerKey;
    
    return self;
}

- (KDConfigurationBuilder *) setOAuthConsumerSecret:(NSString *)oAuthConsumerSecret {
    configurationModel_.oAuthConsumerSecret = oAuthConsumerSecret;
    
    return self;
}

- (KDConfigurationBuilder *) setOAuthAccessToken:(NSString *)oAuthAccessToken {
    configurationModel_.oAuthAccessToken = oAuthAccessToken;
    
    return self;
}

- (KDConfigurationBuilder *) setOAuthAccessTokenSecret:(NSString *)oAuthAccessTokenSecret {
    configurationModel_.oAuthAccessTokenSecret = oAuthAccessTokenSecret;
    
    return self;
}

- (KDConfigurationBuilder *) setOAuthRequestTokenURL:(NSString *)oAuthRequestTokenURL {
    configurationModel_.oAuthRequestTokenURL = oAuthRequestTokenURL;
    
    return self;
}

- (KDConfigurationBuilder *) setOAuthAuthorizationURL:(NSString *)oAuthAuthorizationURL {
    configurationModel_.oAuthAuthorizationURL = oAuthAuthorizationURL;
    
    return self;
}

- (KDConfigurationBuilder *) setOAuthAccessTokenURL:(NSString *)oAuthAccessTokenURL {
    configurationModel_.oAuthAccessTokenURL = oAuthAccessTokenURL;
    
    return self;
}

- (id<KDConfiguration>) build {
    // make the returned object available in current autorelease pool
    return configurationModel_;
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(configurationModel_);
    
    //[super dealloc];
}

@end
