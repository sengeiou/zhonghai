//
//  UIColor+KDAddition.h
//  kdweibo
//
//  Created by DarrenZheng on 15/1/5.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

// UI颜色规范，已全局引用
// http://192.168.0.22/jira/secure/attachment/27901/a%E9%A2%9C%E8%89%B2%E8%A7%84%E8%8C%83.jpg

@interface UIColor (KDAddition)

// 白色
+ (UIColor *)KDWhiteColor;

// 浅灰
+ (UIColor *)KDLightGrayColor;

// 中灰
+ (UIColor *)KDGrayColor;

// 深灰
+ (UIColor *)KDDarkGrayColor;

// 黑色
+ (UIColor *)KDBlackColor;

// 橘色
+ (UIColor *)KDOrangeColor;

// 蓝色
+ (UIColor *)KDBlueColor;

// 浅蓝色
+ (UIColor *)KDLightBlueColor;

// 绿色
+ (UIColor *)KDGreenColor;

// 紫色
+ (UIColor *)KDPurpleColor;

// 红色
+ (UIColor *)KDRedColor;

@end
