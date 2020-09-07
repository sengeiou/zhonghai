//
//  NSDate+RelativeTime.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/25/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//
#define TT_MINUTE 60
#define TT_HOUR   (60 * TT_MINUTE)
#define TT_DAY    (24 * TT_HOUR)
#define TT_5_DAYS (5 * TT_DAY)
#define TT_WEEK   (7 * TT_DAY)
#define TT_MONTH  (30.5 * TT_DAY)
#define TT_YEAR   (365 * TT_DAY)

#import "NSDate+RelativeTime.h"

@implementation NSDate (RelativeTime)

- (NSString *)_localizeString:(NSString *)str
{
    return [[NSBundle mainBundle] localizedStringForKey:str value:str table:nil];
}

//- (NSString *)formatRelativeTime
//{
//    NSTimeInterval elapsed = abs([self timeIntervalSinceNow]);
//
//    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
//    
//    [formatter setDateFormat:@"YYYY"];
//    NSInteger thisYear = [[formatter stringFromDate:[NSDate date]] integerValue];
//    NSInteger year = [[formatter stringFromDate:self] integerValue];
//    
//    [formatter setDateFormat:@"dd"];
//    
//    NSInteger today = [[formatter stringFromDate:[NSDate date]] integerValue];
//    NSInteger day = [[formatter stringFromDate:self] integerValue];
//    
////    BOOL isNeedYear = YES;
//    
//    if(elapsed < TT_DAY && today == day) {
//        [formatter setDateFormat:@"'今天' HH':'mm"];
//    }else {
//        if(thisYear != year)
//            [formatter setDateFormat:@"YYYY'年'M'月'd'日' HH':'mm"];
//        else
//            [formatter setDateFormat:@"M'月'd'日' HH':'mm"];
//    }
//    return [formatter stringFromDate:self];
//}

- (NSString *)formatBuildno
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"YYYYMMdd"];
    return [formatter stringFromDate:self];
}

@end
