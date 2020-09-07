//
//  UIView+Blur.h
//  kdweibo_common
//
//  Created by 王 松 on 13-11-19.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum NSInteger{
    KDBorderPositionNone = 1,
    KDBorderPositionTop  = 1 << 1,
    KDBorderPositionBottom  = 1 << 2,
    KDBorderPositionRight  = 1 << 3,
    KDBorderPositionLeft  = 1 << 4,
    KDBorderPositionAll  = KDBorderPositionTop | KDBorderPositionBottom | KDBorderPositionRight | KDBorderPositionLeft
} KDBorderPosition;

@interface UIView (Blur)

/**
 *  设置模糊效果
 */
- (void)renderLayerWithView:(UIView *)superview;

/**
 *  设置模糊效果，并设置边框
 *
 *  @param superview superView
 *  @param position  边框位置
 */
- (void)renderLayerWithView:(UIView *)superview withBorder:(KDBorderPosition)position;

/**
 *  给view添加边框
 *
 *  @param position 边框位置
 */
- (void)addBorderAtPosition:(KDBorderPosition)position;

/**
 *  给view添加边框
 *
 *  @param position 边框位置
 *  @param color 边框颜色
 */
- (void)addBorderAtPosition:(KDBorderPosition)position color:(UIColor *)color;
/**
 * 移除view的所有边框
 */
- (void)removeAllBorderInView;
@end

