//
//  TeamAccountModel.m
//  kdweibo_common
//
//  Created by kingdee on 16/7/25.
//  Copyright © 2016年 kingdee. All rights reserved.
//

#import "TeamAccountModel.h"
#import "KDConfigurationContext.h"

@implementation TeamAccountModel

- (id)init {
    self = [super init];
    if (self) {
        _name = [[NSString alloc] init];
        _openToken = [[NSString alloc] init];
        _openId = [[NSString alloc] init];
        _oauth_token = [[NSString alloc] init];
        _oauth_token_secret = [[NSString alloc] init];
        _personAccountId = [NSString new];
        _photoURL = [NSString new];
        _status = 0;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id name = [dict objectForKey:@"name"];
        if (![name isKindOfClass:[NSNull class]] && name) {
            self.name = name;
        }
        id openToken = [dict objectForKey:@"openToken"];
        if (![openToken isKindOfClass:[NSNull class]] && openToken) {
            self.openToken = openToken;
        }
        id openId = [dict objectForKey:@"openId"];
        if (![openId isKindOfClass:[NSNull class]] && openId) {
            self.openId = openId;
        }
        id oauthToken = [dict objectForKey:@"oauth_token"];
        if (![oauthToken isKindOfClass:[NSNull class]] && oauthToken) {
            self.oauth_token = oauthToken;
        }
        id oauthTokenSecret = [dict objectForKey:@"oauth_token_secret"];
        if (![oauthTokenSecret isKindOfClass:[NSNull class]] && oauthTokenSecret) {
            self.oauth_token_secret = oauthTokenSecret;
        }
        id status = [dict objectForKey:@"status"];
        if (![status isKindOfClass:[NSNull class]] && status) {
            self.status = [status intValue];
        }
        id personAccountId = [dict objectForKey:@"personAccountId"];
        if (![personAccountId isKindOfClass:[NSNull class]] && personAccountId) {
            self.personAccountId = personAccountId;
        }
        id photoURL = [dict objectForKey:@"photoUrl"];
        if (![photoURL isKindOfClass:[NSNull class]] && photoURL) {
            self.photoURL = photoURL;
        }
        
    }
    return self;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(_name);
    //KD_RELEASE_SAFELY(_openToken);
    //KD_RELEASE_SAFELY(_openId);
    //KD_RELEASE_SAFELY(_oauth_token);
    //KD_RELEASE_SAFELY(_oauth_token_secret);
    //KD_RELEASE_SAFELY(_photoURL);
    //KD_RELEASE_SAFELY(_personAccountId);
    //[super dealloc];
}

@end
