//
//  UIButton+Factory.h
//  kdweibo
//
//  Created by AlanWong on 14/12/30.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//
//
//  UIButton的工厂化方法用来生成各种常用的Button

#import <UIKit/UIKit.h>

@interface UIButton (Factory)
/**
 *  蓝底白字圆角的按钮
 *
 */
+(UIButton *)blueRoundedButtonWithTitle:(NSString *)buttonTitle;

/**
 *  纯文字的UIBarButtonItem
 *
 */
+(UIBarButtonItem *)textBarButtonItemWithTitle:(NSString *)buttonTitle addTarget:(id)target action:(SEL)action;
@end
