//
//  UIColor+KDV6.m
//  kdweibo
//
//  Created by Gil on 15/7/1.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "UIColor+KDV6.h"

@implementation UIColor (KDV6)

+ (UIColor *)kdTextColor1 {
    return [self colorWithRGB:0x030303];
}

+ (UIColor *)kdTextColor2 {
    return [self colorWithRGB:0x98A1A8];
}

+ (UIColor *)kdTextColor3 {
    return [self colorWithRGB:0xC2CBD0];
}

+ (UIColor *)kdTextColor4 {
    return [self colorWithRGB:0xF35959];
}

+ (UIColor *)kdTextColor5 {
    return [self colorWithRGB:0x3CBAFF];
}

+ (UIColor *)kdTextColor6 {
    return [self colorWithRGB:0xFFFFFF];
}

+ (UIColor *)kdTextColor7 {
    return [self colorWithRGB:0x308EC2];
}

+ (UIColor *)kdTextColor8 {
    return [self colorWithRGB:0xFDB933];
}

+ (UIColor *)kdTextColor9 {
    return [self colorWithRGB:0xF29F29];
}

+ (UIColor *)kdTextColor10 {
    return [self colorWithRGB:0x31D2EA];
}

+ (UIColor *)kdTableViewBackgroundColor {
    return [self colorWithRGB:0xEAEFF3];
}

+ (UIColor *)kdBackgroundColor1 {
//    return [self colorWithRGB:0xF1F4F8];
    return [self colorWithRGB:0xEAEFF3];
}

+ (UIColor *)kdBackgroundColor2 {
    return [self colorWithRGB:0xFFFFFF];
}

+ (UIColor *)kdBackgroundColor3 {
    return [self colorWithRGB:0xE7E9EB];
}

+ (UIColor *)kdBackgroundColor4 {
    return [self colorWithRGB:0xFEEEEE];
}

+ (UIColor *)kdBackgroundColor5 {
    return [self colorWithRGB:0x04142A];
}

+ (UIColor *)kdBackgroundColor6 {
    return [self colorWithRGB:0xF7F9FA];
}

+ (UIColor *)kdBackgroundColor7 {
    return [self colorWithRGB:0xF1F4F8];
}

+ (UIColor *)kdDividingLineColor {
    return [self colorWithRGB:0xEAEFF3];
}

+ (UIColor *)kdSubtitleColor {
    return [self colorWithRGB:0xF3F5F9];
}

+ (UIColor *)kdPopupColor {
    return [self colorWithRGB:0x04142A alpha:0.75];
}

+ (UIColor *)kdPopupBackgroundColor {
    return [self colorWithRGB:0x04142A alpha:0.3];
}

+ (UIColor *)kdButtonHightColor {
    return [self colorWithRGB:0xE8EEF0 alpha:0.3];
}

+ (UIColor *)colorWithRGB:(int)rgbValue {
    return [UIColor colorWithRGB:rgbValue
                           alpha:1];
}

+ (UIColor *)kdNavYellowColor {
    return [self colorWithRGB:0xF7BF28];
}

+ (UIColor *)colorWithRGB:(int)rgbValue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((float) (((rgbValue) & 0xFF0000) >> 16)) / 255.0
                           green:((float) (((rgbValue) & 0x00FF00) >> 8)) / 255.0
                            blue:((float) ((rgbValue) & 0x0000FF)) / 255.0
                           alpha:alpha];
}

+ (UIColor *)colorWithHexRGB:(NSString *)inColorString
{
    
    UIColor *result = nil;
    
    unsigned int colorCode = 0;
    
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
        
    {
        
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        
        (void) [scanner scanHexInt:&colorCode]; // ignore error
        
    }
    
    redByte = (unsigned char) (colorCode >> 16);
    
    greenByte = (unsigned char) (colorCode >> 8);
    
    blueByte = (unsigned char) (colorCode); // masks off high bits
    
    result = [UIColor
              
              colorWithRed: (float)redByte / 0xff
              
              green: (float)greenByte/ 0xff
              
              blue: (float)blueByte / 0xff
              
              alpha:1.0];
    
    return result;
    
}
+ (UIColor *)colorWithHexRGB:(NSString *)inColorString alpha:(CGFloat)alpha {
    
    UIColor *result = nil;
    
    unsigned int colorCode = 0;
    
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
        
    {
        
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        
        (void) [scanner scanHexInt:&colorCode]; // ignore error
        
    }
    
    redByte = (unsigned char) (colorCode >> 16);
    
    greenByte = (unsigned char) (colorCode >> 8);
    
    blueByte = (unsigned char) (colorCode); // masks off high bits
    
    result = [UIColor
              
              colorWithRed: (float)redByte / 0xff
              
              green: (float)greenByte/ 0xff
              
              blue: (float)blueByte / 0xff
              
              alpha:alpha];
    
    return result;
    
}


+ (UIColor *)kdBlackColor
{
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
}


+ (UIColor *)kdGradientMaleStartColor
{
    return [self colorWithRGB:0x3EB0F8];
}

+ (UIColor *)kdGradientMaleEndColor
{
    return [self colorWithRGB:0x329CF1];
}

+ (UIColor *)kdGradientFemaleStartColor
{
    return [self colorWithRGB:0xFF79B2 ];
}

+ (UIColor *)kdGradientFemaleEndColor
{
    return [self colorWithRGB:0xEC5580];
}
@end
