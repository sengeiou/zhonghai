//
//  XTColors.m
//  XT
//
//  Created by Gil on 13-8-30.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTColors.h"

@implementation XTColors

+ (UIColor *)xtColorWithRGB:(int)rgbValue
{
    return BOSCOLORWITHRGBA(rgbValue, 1.0);
}

#pragma mark - rgb colors

+ (UIColor *)f0f0f0Color
{
    return [self xtColorWithRGB:0xF0F0F0];
}
+ (UIColor *)b5b5b5Color
{
    return [self xtColorWithRGB:0xB5B5B5];
}
+ (UIColor *)cfcfcfColor
{
    return [self xtColorWithRGB:0xCFCFCF];
}

#pragma mark - xt colors

+ (UIColor *)textGrayColor
{
    return [self b5b5b5Color];
}

+ (UIColor *)lineGrayColor
{
    return [self cfcfcfColor];
}

@end
