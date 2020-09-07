//
//  BOSConnectAuthDataModel.h
//  EMPNativeContainer
//
//  Created by Gil on 13-3-20.
//  Copyright (c) 2013年 Kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOSConnectAuthDataModel : NSObject

@property (nonatomic,copy) NSString *consumerKey;//应用key
@property (nonatomic,copy) NSString *consumerSecret;
@property (nonatomic,copy) NSString *oauthToken;//认证的token
@property (nonatomic,copy) NSString *oauthTokenSecret;

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
               oauthToken:(NSString *)oauthToken
         oauthTokenSecret:(NSString *)oauthTokenSecret;

@end
