//
//  KDConfigurationBase.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDConfigurationBase.h"

#import "KDCommon.h"




@implementation KDConfigurationBase

@synthesize applicationName=applicationName_;
@synthesize debug=debug_;
@synthesize hasAppTutorials=hasAppTutorials_;

@synthesize clientVersion=clientVersion_;
@synthesize baseDatabaseUserVersion=baseDatabaseUserVersion_;
@synthesize lastBuildDate=lastBuildDate_;

@synthesize userAgent=userAgent_;

@synthesize includeExtraHttpHeadersEnabled=includeExtraHttpHeadersEnabled_;
@synthesize requestExtraHeaders=requestExtraHeaders_;
@synthesize requestHeaders=requestHeaders_;

@synthesize serverBaseURL=serverBaseURL_;
@synthesize restBaseURL=restBaseURL_;

@synthesize httpConnectionTimeout=httpConnectionTimeout_;

@synthesize httpRetryCount=httpRetryCount_;
@synthesize httpRetryIntervalSeconds=httpRetryIntervalSeconds_;

@synthesize httpMaxTotalConnections=httpMaxTotalConnections_;

@synthesize oAuthConsumerKey=oAuthConsumerKey_;
@synthesize oAuthConsumerSecret=oAuthConsumerSecret_;
@synthesize oAuthAccessToken=oAuthAccessToken_;
@synthesize oAuthAccessTokenSecret=oAuthAccessTokenSecret_;

@synthesize oAuthRequestTokenURL=oAuthRequestTokenURL_;
@synthesize oAuthAuthorizationURL=oAuthAuthorizationURL_;
@synthesize oAuthAccessTokenURL=oAuthAccessTokenURL_;
@synthesize newFunctions = newFunctions_;

- (id) init {
    self = [super init];
    if(self){
        applicationName_ = nil;
        debug_ = NO;
        hasAppTutorials_ = NO;
        
        self.clientVersion = [KDCommon clientVersion];
        baseDatabaseUserVersion_ = 0;
        lastBuildDate_ = 0;
        
        self.userAgent = [KDCommon userAgent];
        
        includeExtraHttpHeadersEnabled_ = NO;
        requestExtraHeaders_ = nil;
        requestHeaders_ = nil;
        
        serverBaseURL_ = nil;
        restBaseURL_ = nil;
        
        httpConnectionTimeout_ = 0.0;
        
        httpRetryCount_ = 0;
        httpRetryIntervalSeconds_ = 0.0;
        
        httpMaxTotalConnections_ = 0;
        
        self.oAuthConsumerKey = KD_DEFAULT_OAUTH_CONSUMER_KEY;
        self.oAuthConsumerSecret = KD_DEFAULT_OAUTH_CONSUMER_SECRET;
        
        oAuthAccessToken_ = nil;
        oAuthAccessTokenSecret_ = nil;
        
        oAuthRequestTokenURL_ = nil;
        oAuthAuthorizationURL_ = nil;
        oAuthAccessTokenURL_ = nil;
    }
    
    return self;
}

- (id) initWithDefaultOptions {
    self = [super init];
    if(self){
        self.applicationName = KD_DEFAULT_APPNAME;
        debug_ = NO;
        hasAppTutorials_ = NO;
        
        self.clientVersion = [KDCommon clientVersion];
        baseDatabaseUserVersion_ = 0;
        
        self.userAgent = [KDCommon userAgent];
        
        includeExtraHttpHeadersEnabled_ = NO;
        requestExtraHeaders_ = nil;
        requestHeaders_ = nil;
        
        self.serverBaseURL = KD_DEFAULT_SERVER_URL;
        self.restBaseURL = KD_DEFAULT_REST_BASE_URL;
        
        httpConnectionTimeout_ = 30.0;
        
        httpRetryCount_ = 0;
        httpRetryIntervalSeconds_ = 5.0;
        
        httpMaxTotalConnections_ = 20;
        
        self.oAuthConsumerKey = KD_DEFAULT_OAUTH_CONSUMER_KEY;
        self.oAuthConsumerSecret = KD_DEFAULT_OAUTH_CONSUMER_SECRET;
        
        self.oAuthAccessToken = KD_DEFAULT_OAUTH_ACCESS_TOKEN;
        self.oAuthAccessTokenSecret = KD_DEFAULT_OAUTH_ACCESS_SECRET;
        
        self.oAuthRequestTokenURL = KD_DEFAULT_OAUTH_REQUEST_TOKEN_URL;
        self.oAuthAuthorizationURL = KD_DEFAULT_OAUTH_AUTHORIZATION_TOKEN_URL;
        self.oAuthAccessTokenURL = KD_DEFAULT_OAUTH_ACCESS_TOKEN_URL;
    }
    
    return self;
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(applicationName_);
    
    //KD_RELEASE_SAFELY(clientVersion_);
    //KD_RELEASE_SAFELY(userAgent_);
    
    //KD_RELEASE_SAFELY(requestExtraHeaders_);
    //KD_RELEASE_SAFELY(requestHeaders_);
    
    //KD_RELEASE_SAFELY(serverBaseURL_);
    //KD_RELEASE_SAFELY(restBaseURL_);
    
    //KD_RELEASE_SAFELY(oAuthConsumerKey_);
    //KD_RELEASE_SAFELY(oAuthConsumerSecret_);
    //KD_RELEASE_SAFELY(oAuthAccessToken_);
    //KD_RELEASE_SAFELY(oAuthAccessTokenSecret_);
    
    //KD_RELEASE_SAFELY(oAuthRequestTokenURL_);
    //KD_RELEASE_SAFELY(oAuthAuthorizationURL_);
    //KD_RELEASE_SAFELY(oAuthAccessTokenURL_);
    //KD_RELEASE_SAFELY(newFunctions_);
    
    //[super dealloc];
}

@end
