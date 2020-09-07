//
//  UIViewController+Navigation.h
//  kdweibo
//
//  Created by laijiandong on 12-8-24.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

// The methods in this category use for custom navigation view conroller to push/pop target.
// Then the target (any kind sub class of UIViewController) can import some extra task before push/pop.
// For instance, The view controller can cancel requests on going when it
// pop up from current navigation view controller
//
// The sub class can override these methods and add custom implementations.
//
@interface UIViewController (KDViewControllerNavigation)

// The navigation view controller ask can pop this view controller.
// Return YES will pop it from navigation view controller, otherwise return NO. Default is YES.
// You can add logic to ask user save the job which it is not finished yet.
- (BOOL)viewControllerShouldDismiss;

// The view controller will pop from navigation view controller.
- (void)viewControllerWillDismiss;

@end
