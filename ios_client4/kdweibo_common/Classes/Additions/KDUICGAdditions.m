//
//  KDUICGAdditions.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-28.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDUICGAdditions.h"

void CGContextAddRoundRect(CGContextRef context, CGRect rect, CGFloat radius) {
	radius = MIN(radius, rect.size.width / 2);
	radius = MIN(radius, rect.size.height / 2);
	radius = floor(radius);
	
	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
	CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
	CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
	CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
	CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
	CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
	CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
}

void CGContextClipToRoundRect(CGContextRef context, CGRect rect, CGFloat radius) {
	CGContextBeginPath(context);
	CGContextAddRoundRect(context, rect, radius);
	CGContextClosePath(context);
	CGContextClip(context);
}


void CGContextFillRoundRect(CGContextRef context, CGRect rect, CGFloat radius) {
	CGContextBeginPath(context);
	CGContextAddRoundRect(context, rect, radius);
	CGContextClosePath(context);
	CGContextFillPath(context);
}

void CGContextDrawLinearGradientBetweenPoints(CGContextRef context, CGPoint a, CGFloat color_a[4], CGPoint b, CGFloat color_b[4]) {
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGFloat components[] = { color_a[0], color_a[1], color_a[2], color_a[3], color_b[0], color_b[1], color_b[2], color_b[3] };
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, NULL, 2);
	CGContextDrawLinearGradient(context, gradient, a, b, 0);
	CGColorSpaceRelease(colorspace);
	CGGradientRelease(gradient);
}

