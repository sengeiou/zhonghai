//
//  NSDate+DZCategory.h
//  kdweibo
//
//  Created by Darren Zheng on 15/11/10.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DZCategory)
/**
 *  兼容 yyyy-MM-dd HH:mm:ss 和 yyyy-MM-dd HH:mm:ss.SSS
 *
 *  @return 符合特定规格的时间字符串
 */
- (NSString *)dz_stringValue;

/**
 *  判断self是否晚于anotherDate
 *
 *  @param anotherDate 传入的日期
 *
 *  @return 是否晚于
 */
- (BOOL)dz_laterThan:(NSDate *)anotherDate;
/**
 *  判断self是否晚于或等于anotherDate
 *
 *  @param anotherDate 传入的日期
 *
 *  @return 是否晚于或等于
 */
- (BOOL)dz_laterThanOrEqualTo:(NSDate *)anotherDate;
/**
 *  判断self是否早于anotherDate
 *
 *  @param anotherDate 传入的日期
 *
 *  @return 是否早于
 */
- (BOOL)dz_earlierThan:(NSDate *)anotherDate;
/**
 *  判断self是否早于或等于anotherDate
 *
 *  @param anotherDate 传入的日期
 *
 *  @return 是否早于或等于
 */
- (BOOL)dz_earlierThanOrEqualTo:(NSDate *)anotherDate;

/**
 *  判断self是否等于anotherDate
 *
 *  @param anotherDate 传入的日期
 *
 *  @return 是否等于
 */
- (BOOL)dz_sameDate:(NSDate *)anotherDate;

/**
 *  今天的日期（yyyy-MM-dd)
 *
 *  @return 今天的日期字符串
 */
+ (NSString *)dz_pureTodayDateString;
@end
