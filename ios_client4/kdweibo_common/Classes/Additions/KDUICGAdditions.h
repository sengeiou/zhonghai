//
//  KDUICGAdditions.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-28.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

extern void CGContextAddRoundRect(CGContextRef context, CGRect rect, CGFloat radius);
extern void CGContextClipToRoundRect(CGContextRef context, CGRect rect, CGFloat radius);

extern void CGContextFillRoundRect(CGContextRef context, CGRect rect, CGFloat radius);
extern void CGContextDrawLinearGradientBetweenPoints(CGContextRef context, CGPoint a, CGFloat color_a[4], CGPoint b, CGFloat color_b[4]);
