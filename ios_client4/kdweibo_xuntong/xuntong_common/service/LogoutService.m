//
//  LogoutService.m
//  Public
//
//  Created by Gil on 12-5-9.
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "LogoutService.h"
#import "EMPServerClient.h"
#import "BOSSetting.h"
#import "BOSConfig.h"

@implementation LogoutService

- (void)run
{
    if (![[BOSSetting sharedSetting].url isEqualToString:@""]) {
        if (_clientServer_ == nil) {
            _clientServer_ = [[EMPServerClient alloc] initWithTarget:self action:@selector(logoutDidReceived:result:)];
        }
        [_clientServer_ logoutWithToken:[BOSConfig sharedConfig].user.token];
    }
}

-(void)logoutDidReceived:(EMPServerClient *)client result:(BOSResultDataModel *)result
{
    //BOSRELEASE_clientServer_);
}

@end
