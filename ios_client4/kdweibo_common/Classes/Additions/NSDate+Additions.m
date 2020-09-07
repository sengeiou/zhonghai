//
//  NSDate+Additions.m
//  kdweibo
//
//  Created by laijiandong
//

#import "NSDate+Additions.h"
#define TT_MINUTE 60
#define TT_HOUR   (60 * TT_MINUTE)
#define TT_DAY    (24 * TT_HOUR)
#define TT_5_DAYS (5 * TT_DAY)
#define TT_WEEK   (7 * TT_DAY)
#define TT_MONTH  (30.5 * TT_DAY)
#define TT_YEAR   (365 * TT_DAY)

@implementation NSDate (KD_Additions)

/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark format date 

- (NSString *) formatWithFormatter:(NSString *)formater {
	if(self == nil || formater == nil)
		return nil;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:formater];
	NSString *dateString = [dateFormatter stringFromDate:self];

	return dateString;
}

- (NSString *) formatWithDateMode:(NSDateFormatterStyle)dateStyle timeMode:(NSDateFormatterStyle)timeStyle {
	if(self == nil)
		return nil;
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:dateStyle];
	[formatter setTimeStyle:timeStyle];
	
	NSString *result = [formatter stringFromDate:self];

	
	return result;
}

+ (NSDateFormatter *) defaultDateFormatter {
    static NSDateFormatter *formatter = nil;
    if(formatter == nil){
        formatter = [[NSDateFormatter alloc] init];
        
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        formatter.locale = locale;

    }
    
    return formatter;
}

+ (NSCalendar *)defaultCalendr {
    static NSCalendar *defaultCalendar = nil;
    if(defaultCalendar == nil){
        defaultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    
    return defaultCalendar;
}

- (BOOL)isToday:(BOOL *)sameYear {
    NSDate *now = [NSDate date];
    
    NSCalendar *defaultCalendar = [NSDate defaultCalendr];
    
    NSCalendarUnit flags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *components1 = [defaultCalendar components:flags fromDate:self];
	NSDateComponents *components2 = [defaultCalendar components:flags fromDate:now];										
	
    if(sameYear != NULL){
        *sameYear = (components1.year == components2.year) ? YES : NO;
    }
    
    return (components1.year == components2.year && components1.month == components2.month 
            && components1.day == components2.day);
}

- (BOOL)isYesterday:(BOOL *)sameYear {
    NSDate *now = [NSDate date];
    
    NSCalendar *defaultCalendar = [NSDate defaultCalendr];
    
    NSCalendarUnit flags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *components1 = [defaultCalendar components:flags fromDate:self];
    [components1 setDay:components1.day + 1];
	NSDateComponents *components2 = [defaultCalendar components:flags fromDate:now];
	
    if(sameYear != NULL){
        *sameYear = (components1.year == components2.year) ? YES : NO;
    }
    
    return (components1.year == components2.year && components1.month == components2.month
            && components1.day == components2.day);
}

- (BOOL)isDateThisWeek{
    NSDate *start;
    NSTimeInterval extends;
    
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *today = [NSDate date];
    
    BOOL success= [cal rangeOfUnit:NSWeekCalendarUnit startDate:&start interval: &extends forDate:today];
    
    if(!success)
        return NO;
    
    NSTimeInterval dateInSecs = [self timeIntervalSinceReferenceDate];
    NSTimeInterval dayStartInSecs= [start timeIntervalSinceReferenceDate];
    
    if(dateInSecs > dayStartInSecs && dateInSecs < (dayStartInSecs+extends)){
        return YES;
    }
    else {
        return NO;
    }
}



+ (NSString *)formatMonthOrDaySince1970:(NSTimeInterval)time {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    
    return [NSDate formatMonthOrDaySince1970WithDate:date];
}

+ (NSString *)formatDayAndWeekSince1970:(NSTimeInterval)time {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    
    if (date == nil) return nil;
    
    NSDateFormatter *formatter = [NSDate defaultDateFormatter];
    
    BOOL sameYear = NO;
    if([date isToday:&sameYear]){
        [formatter setDateFormat:KD_DATE_TIME];
        
    }else if([date isYesterday:&sameYear]){
         [formatter setDateFormat:KD_DATE_YESTERDAY_FORMAT];
    } else {
        if([date isDateThisWeek]){
            [formatter setDateFormat:KD_DATE_WEEK_FORMAT];
        }else {
            [formatter setDateFormat:KD_DATE_YEAR_MONTH_DAY_SHORTFORMAY];
        }
    }
    //将周一等替换为星期一
    NSString *result = [formatter stringFromDate:date];
    result = [result stringByReplacingOccurrencesOfString:ASLocalizedString(@"NSDate+Additions_Week")withString:ASLocalizedString(@"NSDate+Additions_Weekly")];
    return result;
}

+ (NSString *)formatMonthOrDaySince1970WithDate:(NSDate *)date {
    if (date == nil) return nil;
    
    NSDateFormatter *formatter = [NSDate defaultDateFormatter];
    
    BOOL sameYear = NO;
    if([date isToday:&sameYear]){
        [formatter setDateFormat:KD_DATE_TODAY_FORMAT];
        
    } else {
        if(sameYear){
            [formatter setDateFormat:KD_DATE_MONTH_DAY_FORMAT];
            
        }else {
            [formatter setDateFormat:KD_DATE_YEAR_MONTH_DAY_FORMAT];
        }
    }
    
    return [formatter stringFromDate:date];
}


+ (NSDate *)parseDateUsingASCTimeFormatter:(NSString *)source hasMillionSeconds:(BOOL)hasMillionSeconds {
    if(source == nil) {
        return nil;
    }
    
    static NSDateFormatter *ASCTimeFormatter = nil;
    if(ASCTimeFormatter == nil){
        ASCTimeFormatter = [[NSDateFormatter alloc] init];
        
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        ASCTimeFormatter.locale = locale;

    }
    
    NSString *dateFormat = hasMillionSeconds ? KD_DATE_ASC_TIME_MILLION_SECONDS_FORMATTER : KD_DATE_ASC_TIME_FORMATTER;
    [ASCTimeFormatter setDateFormat:dateFormat];
    
    NSDate * date = [ASCTimeFormatter dateFromString:source];
    
    return date;
}

+ (NSDate *) parseDateWithSource:(NSString *)source formatter:(NSString *)formatter {
    if(source == nil) {
        return nil;
    }
    
    // If the formatter is nil, use the default ASC date format to do it
    if(formatter == nil){
        return [NSDate parseDateUsingASCTimeFormatter:source hasMillionSeconds:NO]; 
    }
    
    NSDateFormatter *dateFormatter = [NSDate defaultDateFormatter];
    [dateFormatter setDateFormat:formatter];
    
    return [dateFormatter dateFromString:source];
}


- (NSString *)formatRelativeTime
{
    NSTimeInterval elapsed = fabs([self timeIntervalSinceNow]);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];// autorelease];
    
    [formatter setDateFormat:@"YYYY"];
    NSInteger thisYear = [[formatter stringFromDate:[NSDate date]] integerValue];
    NSInteger year = [[formatter stringFromDate:self] integerValue];
    
    [formatter setDateFormat:@"dd"];
    
    NSInteger today = [[formatter stringFromDate:[NSDate date]] integerValue];
    NSInteger day = [[formatter stringFromDate:self] integerValue];
    
    //    BOOL isNeedYear = YES;
    
    if(elapsed < TT_DAY && today == day) {
        [formatter setDateFormat:ASLocalizedString(@"NSDate+Additions_Day")];
    }else {
        if(thisYear != year)
            [formatter setDateFormat:ASLocalizedString(@"NSDate+Additions_Year")];
        else
            [formatter setDateFormat:ASLocalizedString(@"NSDate+Additions_Date")];
    }
    return [formatter stringFromDate:self];
}

- (NSString *)ASCTimeString {
    NSString *string = nil;
    if(self) {
          NSDateFormatter *dateFormatter = nil;
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss.SSS ZZZ yyyy";
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.locale = locale;


           string = [dateFormatter stringFromDate:self];
    }
    return string;
}

+ (NSDate *)today {
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                     fromDate:date];
    return [cal dateFromComponents:comps];
}



@end
