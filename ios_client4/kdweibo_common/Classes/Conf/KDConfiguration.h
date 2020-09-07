//
//  KDConfiguration.h
//  kdweibo
//
//  Created by laijiandong
//

#import <Foundation/Foundation.h>

@protocol KDConfiguration <NSObject>
@required

- (NSString *)getApplicationName;

- (BOOL)isDebugEnabled;

- (BOOL)hasAppTutorials; // has upgrade app tutorials

- (NSString *)getClientVersion;

- (NSUInteger)getBaseDatabaseUserVersion;

- (NSUInteger)getLastBuildDate;

- (NSString *)getUserAgent;

// methods for http configuration

- (BOOL)isIncludeExtraHttpHeadersEnabled;

- (NSDictionary *)getRequestExtraHeaders;

- (NSDictionary *)getRequestHeaders;

- (NSString *)getServerBaseURL;

- (NSString *)getRestBaseURL;

- (NSUInteger)getHttpConnectionTimeout;

- (NSUInteger)getHttpRetryCount;

- (NSTimeInterval)getHttpRetryIntervalSeconds; // in seconds

- (NSUInteger)getHttpMaxTotalConnections;


// oauth related setter/getters

- (NSString *)getOAuthConsumerKey;

- (NSString *)getOAuthConsumerSecret;

- (NSString *)getOAuthAccessToken;

- (NSString *)getOAuthAccessTokenSecret;

- (NSString *)getOAuthRequestTokenURL;

- (NSString *)getOAuthAuthorizationURL;

- (NSString *)getOAuthAccessTokenURL;

- (NSArray *)getNewFunctions;

@end
