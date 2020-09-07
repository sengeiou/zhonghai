//
//  NSString+Operate.h
//  kdweibo
//
//  Created by shifking on 15/9/19.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Operate)
- (BOOL)containSubString:(NSString *)substring;
- (NSString *)cutSubString:(NSString *)subString;
+ (NSString *)cutSubStrings:(NSArray *)subs string:(NSString *)string;

+ (UIImage *)imageWithBase64String:(NSString *)base64;
+ (NSString *)base64StringWithImage:(UIImage *)image;

//是够所有都是中文字符
+ (BOOL)isAllChineseChar:(NSString *)string;

//color转#hex
+ (NSString *)hexStringWithColor:(UIColor *)color;

//高亮
+ (NSMutableAttributedString *)attributedStringWithHtml:(NSString *)html
                                                   font:(UIFont *)font
                                              textColor:(UIColor *)textColor;
@end
