//
//  NSString+Operate.m
//  kdweibo
//
//  Created by shifking on 15/9/19.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "NSString+Operate.h"
#define IS_CH_SYMBOL(chr) ((int)(chr)>127)

@implementation NSString (Operate)

- (NSString *)cutSubString:(NSString *)subString{
    if (!subString) return self;
    
    NSRange range = [self rangeOfString:subString];
    if(range.location == NSNotFound){
        return self;
    }
    NSMutableString *result = [NSMutableString stringWithString:self];
    [result deleteCharactersInRange:range];
    return result;
}

- (BOOL)containSubString:(NSString *)substring{
    if (!substring) return NO;
    
    NSRange range = [self rangeOfString:substring];
    if(range.location == NSNotFound){
        return NO;
    }
    else{
        return YES;
    }

}

+ (NSString *)cutSubStrings:(NSArray *)subs string:(NSString *)string{
    NSString *temp = string;
    for(NSString *sub in subs){
        temp = [temp cutSubString:sub];
    }
    return temp;
}

+ (UIImage *)imageWithBase64String:(NSString *)base64 {
    if (!base64) return nil;
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (!imageData || imageData.length == 0) return nil;
    
    return [UIImage imageWithData:imageData];
}

+ (NSString *)base64StringWithImage:(UIImage *)image {
    if(!image) return nil;
    NSData *imageData = UIImagePNGRepresentation(image);
    return [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
}

+ (BOOL)isAllChineseChar:(NSString *)string{
    if (!string || string.length == 0) return NO;
    
    BOOL flag = YES;
    for (NSInteger i = 0 ; i < string.length ; i++) {
        unichar ch = [string characterAtIndex:i];
        if (!IS_CH_SYMBOL(ch)) {
            flag = NO;
            break;
        }
    }
    return flag;
}


+ (NSString *)hexStringWithColor:(UIColor *)color {
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }
    
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    
    return [NSString stringWithFormat:@"#%X%X%X", (int)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
    
}

+ (NSMutableAttributedString *)attributedStringWithHtml:(NSString *)html font:(UIFont *)font textColor:(UIColor *)textColor
{
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding allowLossyConversion:YES] options:options documentAttributes:nil error:nil];
    [attrString addAttributes:@{NSFontAttributeName:font} range:NSMakeRange(0, attrString.length)];
    [attrString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, attrString.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (CGColorEqualToColor(((UIColor *)value).CGColor, [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor)) {
            [attrString addAttributes:@{NSForegroundColorAttributeName:textColor} range:range];
        }
    }];
//    NSLog(@"🍎🍎%@\n🍌🍌%@",attrString.mutableString,html);
    [attrString addAttribute:NSKernAttributeName value:@(0.5f) range:NSMakeRange(0,[attrString length])];
    
    return attrString;
}


@end
