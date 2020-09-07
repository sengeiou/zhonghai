//
//  UIView+WaterMark.h
//  kdweibo
//
//  Created by 张培增 on 16/1/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WaterMark)

+ (UIView *)waterMarkView:(NSString *)waterMark withFrame:(CGRect)frame;

- (void)addWaterMark:(NSString *)waterMark withFrame:(CGRect)frame;

@end
