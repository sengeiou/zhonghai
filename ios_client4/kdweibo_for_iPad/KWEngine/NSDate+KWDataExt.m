//
//  NSDate+KWDataExt.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/28/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "NSDate+KWDataExt.h"

#import "NSObject+KWDataExt.h"

@implementation NSDate (KWDataExt)

+ (NSDate *)dateFromString:(NSString *)datestr
{
    if (!datestr || datestr.kwIsBlank) {
        return nil;
    }
    
    if ([datestr isKindOfClass:[NSNumber class]]) {
        return [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)datestr doubleValue] / 1000];
    }
    
    // formatter works only when with this locale
    NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.locale = enLocale;
    [fmt setDateFormat:@"E MMM d HH':'mm':'ss Z y"];
    
    NSDate *date = [fmt dateFromString:datestr];
    
    [fmt release];
    // if failed to parse, consider if it's with fractional second
    if (nil == date) {
        NSDateFormatter *fmtFS = [[NSDateFormatter alloc] init];
        fmtFS.locale = enLocale;
        [fmtFS setDateFormat:@"E MMM d HH':'mm':'ss'.'SSS Z y"];
        
        date = [fmtFS dateFromString:datestr];
        [fmtFS release];
    }
    
    return date;
}

@end
