//
//  KDLineMaker.m
//  kdweibo
//
//  Created by Darren Zheng on 15/8/14.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDLineMaker.h"

@implementation KDLineMaker

+ (UIView *)lineWithOrigin:(CGPoint)point
{
    UIView *viewLine = [UIView new];
    viewLine.frame = CGRectMake(point.x, point.y, ScreenFullWidth, 0.5);
    viewLine.backgroundColor = [UIColor kdDividingLineColor];
    return viewLine;
}

@end
