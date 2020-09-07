//
//  XTOrganizationViewController.h
//  XT
//  通讯录-组织架构
//  Created by Gil on 13-7-17.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTOrganizationViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,assign)NSInteger partnerType;

- (id)initWithOrgId:(NSString *)orgId;

//点通讯录模块点击组织架构进来的话,采用这个初始化方法
- (id)initFromAddressBookWithOrgId:(NSString *)orgId;

- (id)initWithOrgId:(NSString *)orgId isOnlySingleOrganization:(BOOL)isSingle;

@end
