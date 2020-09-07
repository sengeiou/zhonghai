//
//  XTPubAcctUserChatListViewController.h
//  kdweibo
//
//  Created by stone on 14-5-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTPubAcctUserChatListViewController : UIViewController

- (id)initWithPubAccount:(PubAccountDataModel *)pubAccount andPerson:(PersonSimpleDataModel *)pdm;
- (id)initWithPubAccount2:(PubAccountDataModel *)pubAccount andPerson:(PersonSimpleDataModel *)pdm;
- (id)initWithPublicPerson:(PersonSimpleDataModel *)person;
@end
