//
//  KDLeftTeamMenuViewController.h
//  kdweibo
//
//  Created by gordon_wu on 13-11-18.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDUser.h"
#import "KDUnreadManager.h"
#import "RESideMenu.h"

@class KDTodoListViewController;

@interface KDLeftTeamMenuViewController : UIViewController<KDUnreadListener>
@property (nonatomic,strong) KDUser * user;

- (void) groupViewWillAppear;

- (void)showRecommendView;
- (KDTodoListViewController *)showTodoView;

- (void) showNetWorkList;
@end

