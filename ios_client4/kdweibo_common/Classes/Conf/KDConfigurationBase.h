//
//  KDConfigurationBase.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDConfiguration.h"

@interface KDConfigurationBase : NSObject <KDConfiguration> {
@private
    NSString *applicationName_;
    BOOL debug_;
    BOOL hasAppTutorials_;
    
    NSString *clientVersion_;
    NSUInteger baseDatabaseUserVersion_;
    NSUInteger lastBuildDate_;
    
    NSString *userAgent_;
    
    BOOL includeExtraHttpHeadersEnabled_;
    NSMutableDictionary *requestExtraHeaders_;
    NSMutableDictionary *requestHeaders_;
    
    NSString *serverBaseURL_; // kdweibo base URL
    NSString *restBaseURL_; // RESTful api base URL
    
    NSTimeInterval httpConnectionTimeout_; // in seconds
    
    NSInteger httpRetryCount_;
    NSTimeInterval httpRetryIntervalSeconds_; // in seconds
    
    NSInteger httpMaxTotalConnections_;
    
    NSString *oAuthConsumerKey_;
    NSString *oAuthConsumerSecret_;
    NSString *oAuthAccessToken_;
    NSString *oAuthAccessTokenSecret_;
    
    NSString *oAuthRequestTokenURL_;
    NSString *oAuthAuthorizationURL_;
    NSString *oAuthAccessTokenURL_;
    NSArray  *newFunctions_;
}

@property (nonatomic, retain, getter = getApplicationName) NSString *applicationName;

@property (nonatomic, assign, getter = isDebugEnabled) BOOL debug;
@property (nonatomic, assign, getter = hasAppTutorials) BOOL hasAppTutorials;

@property (nonatomic, retain, getter = getClientVersion) NSString *clientVersion;
@property (nonatomic, assign, getter = getBaseDatabaseUserVersion) NSUInteger baseDatabaseUserVersion;
@property (nonatomic, assign, getter = getLastBuildDate) NSUInteger lastBuildDate;

@property (nonatomic, retain, getter = getUserAgent) NSString *userAgent;

@property (nonatomic, assign, getter = isIncludeExtraHttpHeadersEnabled) BOOL includeExtraHttpHeadersEnabled;
@property (nonatomic, retain, getter = getRequestExtraHeaders) NSDictionary *requestExtraHeaders;
@property (nonatomic, retain, getter = getRequestHeaders) NSDictionary *requestHeaders;

@property (nonatomic, copy, getter = getServerBaseURL) NSString *serverBaseURL;
@property (nonatomic, copy, getter = getRestBaseURL) NSString *restBaseURL;

@property (nonatomic, assign, getter = getHttpConnectionTimeout) NSTimeInterval httpConnectionTimeout;

@property (nonatomic, assign, getter = getHttpRetryCount) NSInteger httpRetryCount;
@property (nonatomic, assign, getter = getHttpRetryIntervalSeconds) NSTimeInterval httpRetryIntervalSeconds;

@property (nonatomic, assign, getter = getHttpMaxTotalConnections) NSInteger httpMaxTotalConnections;

@property (nonatomic, retain, getter = getOAuthConsumerKey) NSString *oAuthConsumerKey;
@property (nonatomic, retain, getter = getOAuthConsumerSecret) NSString *oAuthConsumerSecret;
@property (nonatomic, retain, getter = getOAuthAccessToken) NSString *oAuthAccessToken;
@property (nonatomic, retain, getter = getOAuthAccessTokenSecret) NSString *oAuthAccessTokenSecret;

@property (nonatomic, retain, getter = getOAuthRequestTokenURL) NSString *oAuthRequestTokenURL;
@property (nonatomic, retain, getter = getOAuthAuthorizationURL) NSString *oAuthAuthorizationURL;
@property (nonatomic, retain, getter = getOAuthAccessTokenURL) NSString *oAuthAccessTokenURL;
@property (nonatomic, retain, getter = getNewFunctions)NSArray *newFunctions;

- (id) initWithDefaultOptions;

@end
