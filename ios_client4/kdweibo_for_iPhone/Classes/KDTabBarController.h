//
//  KDTabBarController.h
//  kdweibo
//
//  Created by Gil on 15/7/2.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDTabBarControllerDelegate <NSObject>
@optional
- (void)tabBarSelectedOnce;
- (void)tabBarSelectedTwice;
@end

@interface KDTabBarController : UITabBarController
@end

@interface UITabBar (KDV6)
- (void)setBadgeValue:(int)badgeValue atIndex:(NSInteger)index;
- (void)setDotHidden:(BOOL)hidden atIndex:(NSInteger)index;
@end