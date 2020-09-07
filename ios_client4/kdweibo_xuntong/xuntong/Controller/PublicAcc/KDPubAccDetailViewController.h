//
//  KDPubAccDetailViewController.h
//  kdweibo
//
//  Created by wenbin_su on 15/9/15.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDPublicAccountDataModel;
@class PersonSimpleDataModel;
@class GroupDataModel;
@interface KDPubAccDetailViewController : UIViewController
- (id)initWithPubAcctId:(NSString *)pubAcctId;
- (id)initWithPubAcct:(PersonSimpleDataModel *)pubAcct;
- (id)initWithPubAcct:(PersonSimpleDataModel *)pubAcct andGroup:(GroupDataModel *)group;
@end
