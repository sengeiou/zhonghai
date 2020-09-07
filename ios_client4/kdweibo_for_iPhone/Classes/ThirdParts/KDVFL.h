//
//  KDVFL.h
//  kdweibo
//
//  Created by Darren on 15/3/16.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDVFL : NSObject

/*
 @param target: UIViewController或者UIView
 @param variableBindings: 变量绑定别名 @["button", self.button]
 @param constraintStrings: 约束数组
 @param metrics: 参数数组 @["buttonWidth", @20]
 @param moreInfo: 补充约束，可以插入例如居中等VFL不具备的约束
 */
void setupVFL(id target, NSDictionary *variableBindings, NSArray *constraintStrings, NSDictionary *metrics, void(^moreInfo)());

// 横轴居中
void autolayoutSetCenterX(UIView *view);

// 竖轴居中
void autolayoutSetCenterY(UIView *view);


@end
