//
//  BOSConnectAuthDataModel.m
//  EMPNativeContainer
//
//  Created by Gil on 13-3-20.
//  Copyright (c) 2013年 Kingdee.com. All rights reserved.
//

#import "BOSConnectAuthDataModel.h"
#import "BOSPublicConfig.h"

@implementation BOSConnectAuthDataModel

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret oauthToken:(NSString *)oauthToken oauthTokenSecret:(NSString *)oauthTokenSecret
{
    self = [self init];
    if (self) {
        _consumerKey = [consumerKey copy];
        _consumerSecret = [consumerSecret copy];
        _oauthToken = [oauthToken copy];
        _oauthTokenSecret = [oauthTokenSecret copy];
    }
    return self;
}

- (void)dealloc {
}

@end
