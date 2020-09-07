//
//  LoginDataModel.m
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "LoginDataModel.h"

@implementation LoginDataModel
@synthesize ssoToken = _ssoToken_;
@synthesize accessToken = _accessToken_;
@synthesize loginToken = _loginToken_;
@synthesize homePage = _homePage_;

-(id)init{
    self = [super init];
    if (self) {
        _ssoToken_ = [[NSString alloc] init];
        _accessToken_ = [[NSString alloc] init];
        _loginToken_ = [[NSString alloc] init];
        _homePage_ = [[NSString alloc] init];
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id ssoToken = [dict objectForKey:@"ssoToken"];
        id accessToken = [dict objectForKey:@"accessToken"];
        id loginToken = [dict objectForKey:@"loginToken"];
        id homePage = [dict objectForKey:@"homePage"];
        
        if (![ssoToken isKindOfClass:[NSNull class]] && ssoToken) {
            self.ssoToken = ssoToken;
        }
        if (![accessToken isKindOfClass:[NSNull class]] && accessToken) {
            self.accessToken = accessToken;
        }
        if (![loginToken isKindOfClass:[NSNull class]] && loginToken) {
            self.loginToken = loginToken;
        }
        if (![homePage isKindOfClass:[NSNull class]] && homePage) {
            self.homePage = homePage;
        }
    }
    return self;
}

-(void)dealloc
{
    //BOSRELEASE_ssoToken_);
    //BOSRELEASE_accessToken_);
    //BOSRELEASE_loginToken_);
    //BOSRELEASE_homePage_);
    //[super dealloc];
}

@end
