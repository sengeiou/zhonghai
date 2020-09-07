//
//  NSDate+Additions.h
//  kdweibo
//
//  Created by laijiandong
//

#import <Foundation/Foundation.h>


#define KD_DATE_ISO_8601_LONG_FORMATTER                 @"yyyy-MM-dd HH:mm"
#define KD_DATE_ISO_8601_SHORT_FORMATTER                @"yyyy-MM-dd"

#define KD_DATE_ISO_8601_LONG_NUMERIC_FORMATTER			@"yyyyMMddHHmmss"

#define KD_DATE_ASC_TIME_FORMATTER                       @"EEE MMM d HH:mm:ss ZZZZ yyyy"
#define KD_DATE_ASC_TIME_MILLION_SECONDS_FORMATTER       @"EEE MMM d HH:mm:ss.SSS ZZZZ yyyy"

#define KD_DATE_TODAY_FORMAT                            ASLocalizedString(@"NSDate+Additions_Taday")
#define KD_DATE_YESTERDAY_FORMAT                        ASLocalizedString(@"NSDate+Additions_Yestoday")
#define KD_DATE_WEEK_FORMAT                             @"EEE"
#define KD_DATE_MONTH_DAY_WEEK_FORMAT                   @"M-d EEE"
#define KD_DATE_YEAR_MONTH_DAY_WEEK_FORMAT              @"M-d EEE"
#define KD_DATE_MONTH_DAY_FORMAT                        @"M-d HH:mm"
#define KD_DATE_YEAR_MONTH_DAY_FORMAT                   @"yyyy-M-d HH:mm"
#define KD_DATE_YEAR_MONTH_DAY_SHORTFORMAY              @"yy-M-dd"
#define KD_DATE_TIME                                    @"HH:mm"
#define KD_MOUNTH_LOCAL_IDENTIFY                        @"en_US_POSIX"
#define KD_MOUNTH_BRIFE_FORMAT                          @"MM-dd HH:mm"

@interface NSDate (KD_Additions)

- (NSString *) formatWithFormatter:(NSString *)formater;
- (NSString *) formatWithDateMode:(NSDateFormatterStyle)dateStyle timeMode:(NSDateFormatterStyle)timeStyle;

// The parameter sameYear can be NULL
- (BOOL)isToday:(BOOL *)sameYear;

+ (NSString *)formatMonthOrDaySince1970:(NSTimeInterval)time;
+ (NSString *)formatMonthOrDaySince1970WithDate:(NSDate *)date;
+ (NSString *)formatDayAndWeekSince1970:(NSTimeInterval)time;

+ (NSDate *)parseDateUsingASCTimeFormatter:(NSString *)source hasMillionSeconds:(BOOL)hasMillionSeconds ;
+ (NSDate *)parseDateWithSource:(NSString *)source formatter:(NSString *)formatter;

- (NSString *)formatRelativeTime;
- (NSString *)ASCTimeString;
+ (NSDate *)today;
+ (NSCalendar *)defaultCalendr;
@end
