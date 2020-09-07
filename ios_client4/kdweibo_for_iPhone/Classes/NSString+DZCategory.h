//
//  NSString+DZCategory.h
//  kdweibo
//
//  Created by Darren on 15/7/26.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DZCategory)

// this method is for calculating the actual size for a given width on a multi-line label
- (CGSize)sizeForMaxWidth:(CGFloat)width
                     font:(UIFont *)font
            numberOfLines:(int)numberOfLines;
- (CGSize)sizeForMaxWidth:(CGFloat)width
                     font:(UIFont *)font;
- (CGSize)sizeWithFont:(UIFont *)font;
- (NSMutableDictionary *)queryComponents;
NSString *safeString(NSString *str);
- (NSString *)dz_stringByTrimmingWhitespaceAndNewlines;
/**
 *  兼容 yyyy-MM-dd HH:mm:ss 和 yyyy-MM-dd HH:mm:ss.SSS
 *
 *  @return 符合特定规格的时间NSDate
 */
- (NSDate *)dz_dateValue;
- (NSArray *)dz_rangesOfString:(NSString *)searchString;
+ (NSString *)dz_stringFileSizeWithValue:(double)dValue;
- (NSArray *)dz_forEachString;
- (NSUInteger)dz_bytes;
@end
