//
//  UIViewController+DZCategory.m
//  kdweibo
//
//  Created by Darren Zheng on 15/8/21.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "UIViewController+DZCategory.h"

@implementation UIViewController (DZCategory)

@dynamic bPushed;

- (BOOL)bPushed
{
    return [self.navigationController.viewControllers indexOfObject:self] > 0;
}

@end
