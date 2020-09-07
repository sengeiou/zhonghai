//
//  EMPServerClient.m
//  Public
//
//  Created by Gil on 12-4-27.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "EMPServerClient.h"
#import "URL+EMPServer.h"
#import "AlgorithmHelper.h"
#import "BOSConfig.h"
#import "BOSLogger.h"

//#import "SessionExpiredHandler.h"
//#import "KeyExpiredHandler.h"

@implementation EMPServerClient

-(id)initWithTarget:(id)target action:(SEL)action
{
    BOSConnectFlags connectFlags = {BOSConnect4DirectURL,BOSConnectNotEncryption,BOSConnectResponseAllowCompressed,BOSConnectRequestBodyNotCompressed,NO};
    self = [super initWithTarget:target action:action connectionFlags:connectFlags];
    if (self) {
        [super setBaseUrlString:[BOSSetting sharedSetting].url];
    }
    return self;
}

#pragma mark - post || get method

- (void)authTokenWithToken:(NSString *)token
               appClientId:(NSString *)appClientId
                  deviceId:(NSString *)deviceId
               deviceToken:(NSString *)deviceToken
                   langKey:(NSString *)langKey{
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
	[params setObject:[super checkNullOrNil:appClientId] forKey:@"appClientId"];
	[params setObject:[super checkNullOrNil:deviceId] forKey:@"deviceId"];
	[params setObject:[super checkNullOrNil:deviceToken] forKey:@"deviceToken"];
    [params setObject:[super checkNullOrNil:[BOSSetting sharedSetting].userName]forKey:@"userName"];
    [params setObject:[super checkNullOrNil:langKey] forKey:@"langKey"];
	[params setObject:@"1" forKey:@"deviceTokenVer"];
	[super post:EMPSERVERURL_AUTHTOKEN
	       body:params
	     header:@{ @"openToken": [super checkNullOrNil:token] }];
}



- (void)registerDeviceTokenWithToken:(NSString *)token
                         appClientId:(NSString *)appClientId
                            deviceId:(NSString *)deviceId
                         deviceToken:(NSString *)deviceToken {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
	[params setObject:[super checkNullOrNil:appClientId] forKey:@"appClientId"];
	[params setObject:[super checkNullOrNil:deviceId] forKey:@"deviceId"];
	[params setObject:[super checkNullOrNil:deviceToken] forKey:@"deviceToken"];
	[params setObject:@"1" forKey:@"deviceTokenVer"];
	[super post:EMPSERVERURL_REGISTERDEVICETOKEN
	       body:params
	     header:@{ @"openToken": [super checkNullOrNil:token] }];
}

-(void)logoutWithToken:(NSString *)token
{
    [super post:EMPSERVERURL_LOGOUT
           body:nil
         header:@{@"openToken": [super checkNullOrNil:token]}];
}

@end
