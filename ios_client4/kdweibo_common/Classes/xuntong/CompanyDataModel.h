//
//  CompanyDataModel.h
//  kdweibo
//
//  Created by Gil on 14-4-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "UserDataModel.h"

@interface CompanyDataModel : NSObject

@property (strong, nonatomic) NSString *eid;//企业id
@property (strong, nonatomic) NSString *name;//企业名称
@property (strong, nonatomic) NSString *wbNetworkId;
@property (strong, nonatomic) UserDataModel *user;
@property (assign, nonatomic) NSInteger unreadCount; //讯通面返回
@property (assign, nonatomic) NSInteger wbUnreadCount; //微博面返回

- (id)initWithDictionary:(NSDictionary *)dict;

@end
