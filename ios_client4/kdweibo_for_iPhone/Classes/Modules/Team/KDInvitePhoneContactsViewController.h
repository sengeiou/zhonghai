//
//  KDInvitePhoneContactsViewController.h
//  kdweibo
//
//  Created by shen kuikui on 13-10-24.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDInvitePhoneContactsViewController : UIViewController

@property (nonatomic, retain) NSMutableArray *invitePeople;

@property (nonatomic, assign) BOOL isNeedFilter;
@property (nonatomic, retain) NSString *invitedUrl;

@end
