//
//  UIImage+KDV6.m
//  kdweibo
//
//  Created by Gil on 15/7/2.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "UIImage+KDV6.h"

@implementation UIImage (KDV6)

+ (UIImage *)kd_imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
	CGRect rect = CGRectMake(0, 0, 1, 1);
	// Create a 1 by 1 pixel context
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
	[color setFill];
	UIRectFill(rect);   // Fill it with your color
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size

{
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        
        UIGraphicsBeginImageContext(rect.size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context,
                                       
                                       color.CGColor);
        
        CGContextFillRect(context, rect);
        
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        return img;
}
@end
