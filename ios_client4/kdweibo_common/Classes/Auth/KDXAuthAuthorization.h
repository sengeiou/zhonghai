//
//  KDXAuthAuthorization.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDAuthorization.h"
#import "KDAuthToken.h"

@interface KDXAuthAuthorization : NSObject <KDAuthorization> {
@private
    KDAuthToken *consumerToken_;
    KDAuthToken *accessToken_;
}

@property(nonatomic, retain) KDAuthToken *consumerToken;
@property(nonatomic, retain) KDAuthToken *accessToken;

- (id)initWithAccessToken:(NSString *)token secret:(NSString *)secret;
+ (KDXAuthAuthorization *)xAuthorizationWithAccessToken:(KDAuthToken *)accessToken;

@end
