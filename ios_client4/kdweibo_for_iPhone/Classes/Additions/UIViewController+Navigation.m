//
//  UIViewController+Navigation.m
//  kdweibo
//
//  Created by laijiandong on 12-8-24.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "UIViewController+Navigation.h"

@implementation UIViewController (KDViewControllerNavigation)

// The sub classes override it if need
- (BOOL)viewControllerShouldDismiss {
    return YES;
}

// The sub classes override it if need
- (void)viewControllerWillDismiss {
    // do nothing
}

// for iOS 5 and earlier
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationPortrait == toInterfaceOrientation;
}

// for iOS 6
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}


@end

