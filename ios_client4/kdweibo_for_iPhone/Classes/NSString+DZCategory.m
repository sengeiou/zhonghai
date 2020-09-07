//
//  NSString+DZCategory.m
//  kdweibo
//
//  Created by Darren on 15/7/26.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "NSString+DZCategory.h"

@implementation NSString (DZCategory)

- (CGSize)sizeForMaxWidth:(CGFloat)width
                     font:(UIFont *)font
{
    return [self sizeForMaxWidth:width font:font numberOfLines:0];
}

- (CGSize)sizeForMaxWidth:(CGFloat)width
                     font:(UIFont *)font
            numberOfLines:(int)numberOfLines
{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, numberOfLines == 0 ? CGFLOAT_MAX : [font pointSize] * (numberOfLines + 1))
                                     options:NSLineBreakByWordWrapping | NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: font}
                                     context:nil];
    rect.size.width = ceil(rect.size.width);
    rect.size.height = ceil(rect.size.height);
    return rect.size;
//    
//        UILabel *gettingSizeLabel = [[UILabel alloc] init];
//        gettingSizeLabel.font = font;
//        gettingSizeLabel.text = self;
//        gettingSizeLabel.numberOfLines = numberOfLines;
//        CGSize maximumLabelSize = CGSizeMake(width, CGFLOAT_MAX);
//        CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
//        return expectSize;
}

- (CGSize)sizeWithFont:(UIFont *)font
{
   return [self sizeWithAttributes:@{NSFontAttributeName:font}];
}
- (NSMutableDictionary *)queryComponents
{
    NSArray *queryComp = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    for (NSString *component in queryComp) {
        NSArray *subcomponents = [component componentsSeparatedByString:@"="];
        if (subcomponents.count > 1) {
            [parameters setObject:[[subcomponents objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           forKey:[[subcomponents objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    return parameters;
}

NSString *safeString(NSString *str)
{
    if ([str isKindOfClass:[NSNull class]] || str == nil) {
        return @"";
    }
    return str;
}

- (NSString *)dz_stringByTrimmingWhitespaceAndNewlines
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSDate *)dz_dateValue
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
    }
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *date = [formatter dateFromString:self];
    if (!date)
    {
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        date = [formatter dateFromString:self];
    }
    return date;
}

- (NSArray *)dz_rangesOfString:(NSString *)searchString {
    NSMutableArray *results = [NSMutableArray array];
    NSRange searchRange = NSMakeRange(0, [self length]);
    NSRange range;
    while ((range = [self rangeOfString:searchString options:0 range:searchRange]).location != NSNotFound) {
        [results addObject:[NSValue valueWithRange:range]];
        searchRange = NSMakeRange(NSMaxRange(range), [self length] - NSMaxRange(range));
    }
    return results;
}

+ (NSString *)dz_stringFileSizeWithValue:(double)dValue
{
    double convertedValue = dValue;
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    if (multiplyFactor < tokens.count) {
        return [NSString stringWithFormat:@"%.1f%@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
    } else {
        return nil;
    }
}

- (NSArray *)dz_forEachString {
    NSRange theRange = {0, 1};
    NSMutableArray * array = [NSMutableArray array];
    for ( NSInteger i = 0; i < [self length]; i++) {
        theRange.location = i;
        [array addObject:[self substringWithRange:theRange]];
    }
    return array;
}

- (NSUInteger)dz_bytes {
    int strlength = 0;
    char* p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}
@end
