//
//  UIColor+KDAddition.m
//  kdweibo
//
//  Created by DarrenZheng on 15/1/5.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "UIColor+KDAddition.h"

@implementation UIColor (KDAddition)

// 白色
+ (UIColor *)KDWhiteColor
{
    return [self colorWithRGB:0xffffff];
}

// 浅灰
+ (UIColor *)KDLightGrayColor
{
    return [self colorWithRGB:0xededed];
}

// 中灰
+ (UIColor *)KDGrayColor
{
    return [self colorWithRGB:0xd3d3d3];
}

// 深灰
+ (UIColor *)KDDarkGrayColor
{
    return [self colorWithRGB:0x6d6d6d];
}

// 黑色
+ (UIColor *)KDBlackColor
{
    return [self colorWithRGB:0x000000];
}

// 橘色
+ (UIColor *)KDOrangeColor
{
    return [self colorWithRGB:0xfe6600];
}

// 蓝色
+ (UIColor *)KDBlueColor
{
    return [self colorWithRGB:0x2e88fc];
}

// 浅蓝色
+ (UIColor *)KDLightBlueColor
{
    return [self colorWithRGB:0x40c2ff];
}

// 绿色
+ (UIColor *)KDGreenColor
{
    return [self colorWithRGB:0x20c000];
}

// 紫色
+ (UIColor *)KDPurpleColor
{
    return [self colorWithRGB:0xb56cd9];
}

// 红色
+ (UIColor *)KDRedColor
{
    return [self colorWithRGB:0xed473b];
}

+ (UIColor *)colorWithRGB:(int)rgbValue
{
    return [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0
                           green:((float)(((rgbValue) & 0x00FF00) >> 8))/255.0
                            blue:((float)((rgbValue) & 0x0000FF))/255.0
                           alpha:1];
}

@end
