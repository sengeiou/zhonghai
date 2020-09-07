//
//  NSDate+DZCategory.m
//  kdweibo
//
//  Created by Darren Zheng on 15/11/10.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "NSDate+DZCategory.h"

@implementation NSDate (DZCategory)

- (NSString *)dz_stringValue
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *str = [formatter stringFromDate:self];
    if (!str)
    {
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        str = [formatter stringFromDate:self];
    }
    return str;
}

- (BOOL)dz_sameDate:(NSDate *)anotherDate
{
    if (!anotherDate) {
        return NO;
    }
    return [self compare:anotherDate] == NSOrderedSame;
}

- (BOOL)dz_laterThan:(NSDate *)anotherDate
{
    if (!anotherDate) {
        return NO;
    }
    return [self compare:anotherDate] == NSOrderedDescending;
}

- (BOOL)dz_laterThanOrEqualTo:(NSDate *)anotherDate
{
    if (!anotherDate) {
        return NO;
    }
    return [self compare:anotherDate] == NSOrderedDescending || [self compare:anotherDate] == NSOrderedSame;
}

- (BOOL)dz_earlierThan:(NSDate *)anotherDate
{
    if (!anotherDate) {
        return NO;
    }
    return [self compare:anotherDate] == NSOrderedAscending;
}

- (BOOL)dz_earlierThanOrEqualTo:(NSDate *)anotherDate
{
    if (!anotherDate) {
        return NO;
    }
    return [self compare:anotherDate] == NSOrderedAscending || [self compare:anotherDate] == NSOrderedSame;
}

static NSDateFormatter *formatter = nil;
+ (NSString *)dz_pureTodayDateString {
    if (!formatter) {
        formatter = [[NSDateFormatter alloc]init];
    }
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:[NSDate date]];
}

@end
