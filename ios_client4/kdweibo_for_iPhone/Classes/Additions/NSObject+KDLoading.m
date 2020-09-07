//
//  NSObject+KDLoading.m
//  kdweibo
//
//  Created by Darren Zheng on 15/8/19.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "NSObject+KDLoading.h"

@implementation NSObject (KDLoading)

- (void)kd_showLoading;
{
    if ([self isKindOfClass:[UIView class]])
    {
        [MBProgressHUD showHUDAddedTo:AppWindow animated:YES];
    }
    
    if ([self isKindOfClass:[UIViewController class]])
    {
        [MBProgressHUD showHUDAddedTo:AppWindow animated:YES];
    }
}

- (void)kd_hideLoading
{
    if ([self isKindOfClass:[UIView class]])
    {
        [MBProgressHUD hideAllHUDsForView:AppWindow animated:YES];
    }
    
    if ([self isKindOfClass:[UIViewController class]])
    {
        [MBProgressHUD hideAllHUDsForView:AppWindow animated:YES];
    }
}

@end
