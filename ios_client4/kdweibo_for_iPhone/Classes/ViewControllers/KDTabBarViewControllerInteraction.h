//
//  KDTabBarViewControllerInteraction.h
//  kdweibo
//
//  Created by laijiandong on 12-9-18.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDUnread.h"
@protocol KDTabBarViewControllerInteraction <NSObject>
@optional

// if changed is true means the view controller did changed, in other words just tapped on same tap.
- (void)didChangeToViewController:(UIViewController *)vc actuallyChanged:(BOOL)changed;

// notify the view controller should reload data source
- (void)shouldReloadDataSource:(BOOL)forceReload;

- (void)unreadDidChanged:(KDUnread *)unread;

@end

