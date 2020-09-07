//
//  TeamAccountModel.h
//  kdweibo_common
//
//  Created by kingdee on 16/7/25.
//  Copyright © 2016年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamAccountModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *openToken;
@property (nonatomic, copy) NSString *openId;

@property (nonatomic, copy) NSString *oauth_token;
@property (nonatomic, copy) NSString *oauth_token_secret;
@property (nonatomic, assign) int status;
@property (nonatomic, copy) NSString *personAccountId;

@property (nonatomic, strong) NSString *photoURL;

- (id)initWithDictionary:(NSDictionary *)dict;
@end
