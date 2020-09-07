//
//  UIViewController+NavigationStyle.h
//  kdweibo
//
//  Created by sevli on 16/9/8.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//  Navigation 样式 --- NavigationStyle支持扩展

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    KDNavigationStyleNormal = 0,        // 白底蓝字
    KDNavigationStyleBlue,              // 蓝底白字
    KDNavigationStyleYellow,            // 黄底白字
    KDNavigationStyleClear,             // 透明底白字  起点(0,64)
    KDNavigationStyleTLClear,           // 透明底白字  起点(0,0)
    KDNavigationStyleCustom             // 自定义颜色
} KDNavigationStyle;



@interface UIViewController (NavigationStyle)

@property (nonatomic, assign) KDNavigationStyle style;

/**
 *  设置barTitle & item 样式
 *
 *  @param style style可扩展
 */
- (void)setNavigationStyle:(KDNavigationStyle)style;

/**
 *  设置bar颜色
 *
 *  @param NSString
 */
- (void)setNavigationCustomStyleWithColorStr:(NSString *)colorStr;

/**
 *  设置bar颜色
 *
 *  @param UIColor
 */
- (void)setNavigationCustomStyleWithColor:(UIColor *)color;


- (void)setDividingLineHidden:(BOOL)hidden;


@end
