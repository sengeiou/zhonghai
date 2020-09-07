//
//  ContactUtils.m
//  ContactsLite
//
//  Created by Gil on 12-11-14.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "ContactUtils.h"
#import "ContactConfig.h"
#import "BOSConfig.h"

@implementation ContactUtils

+ (NSString *)recordPath
{
    NSString *recordPath = [[BOSFileManager currentUserPathWithOpenId:[BOSConfig sharedConfig].user.openId] stringByAppendingPathComponent:kRecorderDirectoryName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:recordPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:recordPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return recordPath;
}

+ (NSString *)recordFilePath
{
    return [[self recordPath] stringByAppendingPathComponent:@"record_temp.caf"];
}

+ (NSString *)recordTempFilePath
{
    NSString *path = [[self recordPath] stringByAppendingPathComponent:@"temp"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)recordFilePathWithGroupId:(NSString *)groupId
{
    NSString *path = [[self recordPath] stringByAppendingPathComponent:groupId];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)fileFilePath
{
    NSString *filePath = [[BOSFileManager currentUserPathWithOpenId:[BOSConfig sharedConfig].user.openId] stringByAppendingPathComponent:kFileDirectoryName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}

+ (NSString *)fileFilePathWithFileId:(NSString *)fileId {
    NSString *filePath = [[BOSFileManager currentUserPathWithOpenId:[BOSConfig sharedConfig].user.openId] stringByAppendingPathComponent:kFileDirectoryName];
    filePath = [filePath stringByAppendingPathComponent:fileId];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}
+(NSString *)fileTempFilePath
{
    NSString *path = [[self fileFilePath] stringByAppendingPathComponent:@"temp"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+(NSString *)uuid
{
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil,puuid);
    NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL,uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

+(NSData *)XOR80:(NSData *)sourceData
{
//    int length = [sourceData length];
//    
//    Byte targetByte[length];
//    char *dataPtr = (char *) [sourceData bytes];
//    for (int x = 0; x < length; x++)
//    {
//        targetByte[x] = *(dataPtr++) ^ 0x80;
//    }
//    
//    return [NSData dataWithBytes:targetByte length:length];
    int length = (int)[sourceData length];
    NSMutableData *data = [NSMutableData new];
    char *dataPtr = (char *) [sourceData bytes];
    for (int index = 0; index < length; index++)
    {
        char resultByte = dataPtr[index] ^ 0x80;
        [data appendBytes:&resultByte length:sizeof(char)];
    }
    return data;
}

NSDateFormatter *fullDateFormatter = nil;
NSDateFormatter *shortDateFormatter = nil;
NSDateFormatter *lastDateFormatter = nil;
+(NSString *)xtDateFormatter:(NSString *)fullDateString
{
    if (fullDateString == nil || [@"" isEqualToString:fullDateString]) {
        return @"";
    }
    
    if (fullDateFormatter == nil) {
        fullDateFormatter = [[NSDateFormatter alloc] init];
    }
    if(fullDateString.length>19)
        [fullDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    else
        [fullDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
	NSDate *fullDate = [fullDateFormatter dateFromString:fullDateString];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = nil;
    NSInteger unitFlags = NSYearCalendarUnit;
    comps = [calendar components:unitFlags fromDate:fullDate];
    int fullDateYear=(int)[comps year];
    comps = [calendar components:unitFlags fromDate:[NSDate date]];
    int nowDateYear = (int)[comps year];
    
    NSString *fullShortString = [fullDateString substringToIndex:10];
    if (fullDateYear != nowDateYear) {
        return fullShortString;
    }
    
    if (shortDateFormatter == nil) {
        shortDateFormatter = [[NSDateFormatter alloc] init];
    }
    [shortDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *fullShortDate = [shortDateFormatter dateFromString:fullShortString];
    
    NSInteger dayDiff = (int)[fullShortDate timeIntervalSinceNow] / (60*60*24);
    
    if (lastDateFormatter == nil) {
        lastDateFormatter = [[NSDateFormatter alloc] init];
    }
    
    switch (dayDiff) {
        case 0:
            [lastDateFormatter setDateFormat:@"HH:mm"];
            break;
        case -1:
            [lastDateFormatter setDateFormat:ASLocalizedString(@"ContactUtils_Tip_1")];
            break;
        case -2:
            [lastDateFormatter setDateFormat:ASLocalizedString(@"ContactUtils_Tip_2")];
            break;
        default:
            [lastDateFormatter setDateFormat:@"MM-dd HH:mm"];
            break;
    }
    return [lastDateFormatter stringFromDate:fullDate];
}
+ (NSString *)xtDateFormatterAtTimeline:(NSString *)fullDateString {
    if (fullDateString == nil || [@"" isEqualToString:fullDateString]) {
        return @"";
    }
    
   	if (fullDateFormatter == nil) {
        fullDateFormatter = [[NSDateFormatter alloc] init];
    }
    [fullDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *fullDate = [fullDateFormatter dateFromString:fullDateString];
    if (!fullDate)
    {
        [fullDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        fullDate = [fullDateFormatter dateFromString:fullDateString];
    }
    
    NSDateComponents *comps = nil;
    NSInteger unitFlags = NSYearCalendarUnit;
    comps = [[NSDate defaultCalendr] components:unitFlags fromDate:fullDate];
    int fullDateYear = (int)[comps year];
    comps = [[NSDate defaultCalendr] components:unitFlags fromDate:[NSDate date]];
    int nowDateYear = (int)[comps year];
    
    NSString *fullShortString = [fullDateString substringToIndex:10];
    if (fullDateYear != nowDateYear) {
        return fullShortString;
    }
    
    if (shortDateFormatter == nil) {
        shortDateFormatter = [[NSDateFormatter alloc] init];
    }
    [shortDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *fullShortDate = [shortDateFormatter dateFromString:fullShortString];
    
    NSInteger dayDiff = (int)[fullShortDate timeIntervalSinceNow] / (60 * 60 * 24);
    
    if (lastDateFormatter == nil) {
        lastDateFormatter = [[NSDateFormatter alloc] init];
    }
    
    switch (dayDiff) {
        case 0:
            [lastDateFormatter setDateFormat:@"HH:mm"];
            break;
            
        case -1:
            [lastDateFormatter setDateFormat:ASLocalizedString(@"ContactUtils_Tip_3")];
            break;
            
        case -2:
        case -3:
        case -4:
        case -5:
        case -6:
        {
            comps = [[NSDate defaultCalendr] components:NSWeekdayCalendarUnit fromDate:fullShortDate];
            switch (comps.weekday) {
                case 1:
                {
                    [lastDateFormatter setDateFormat:ASLocalizedString(@"ContactUtils_Tip_4")];
                }
                    break;
                case 2:
                {
                    [lastDateFormatter setDateFormat:ASLocalizedString(@"ContactUtils_Tip_5")];
                }
                    break;
                case 3:
                {
                    [lastDateFormatter setDateFormat:ASLocalizedString(@"ContactUtils_Tip_6")];
                }
                    break;
                case 4:
                {
                    [lastDateFormatter setDateFormat:ASLocalizedString(@"ContactUtils_Tip_7")];
                }
                    break;
                case 5:
                {
                    [lastDateFormatter setDateFormat:ASLocalizedString(@"ContactUtils_Tip_8")];
                }
                    break;
                case 6:
                {
                    [lastDateFormatter setDateFormat:ASLocalizedString(@"ContactUtils_Tip_9")];
                }
                    break;
                case 7:
                {
                    [lastDateFormatter setDateFormat:ASLocalizedString(@"ContactUtils_Tip_10")];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
            [lastDateFormatter setDateFormat:@"MM-dd"];
            break;
    }
    return [lastDateFormatter stringFromDate:fullDate];
}

+ (NSString *)xtDateFormatterAtTimelineExYear:(NSString *)fullDateString {
    if (fullDateString == nil || [@"" isEqualToString:fullDateString]) {
        return @"";
    }
    
    NSString *fullShortString = [fullDateString substringToIndex:10];
    
    if (shortDateFormatter == nil) {
        shortDateFormatter = [[NSDateFormatter alloc] init];
    }
    [shortDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *fullShortDate = [shortDateFormatter dateFromString:fullShortString];
    
    NSInteger dayDiff = (int)[fullShortDate timeIntervalSinceNow] / (60 * 60 * 24);
    
    if (lastDateFormatter == nil) {
        lastDateFormatter = [[NSDateFormatter alloc] init];
    }
    
    NSDateComponents *comps = nil;
    
    switch (dayDiff) {
        case 0:
            [lastDateFormatter setDateFormat:@"HH:mm"];
            break;
            
        case -1:
            [lastDateFormatter setDateFormat:@"'昨天'"];
            break;
            
        case -2:
        case -3:
        case -4:
        case -5:
        case -6:
        {
            comps = [[NSDate defaultCalendr] components:NSWeekdayCalendarUnit fromDate:fullShortDate];
            switch (comps.weekday) {
                case 1:
                {
                    [lastDateFormatter setDateFormat:@"'星期日'"];
                }
                    break;
                case 2:
                {
                    [lastDateFormatter setDateFormat:@"'星期一'"];
                }
                    break;
                case 3:
                {
                    [lastDateFormatter setDateFormat:@"'星期二'"];
                }
                    break;
                case 4:
                {
                    [lastDateFormatter setDateFormat:@"'星期三'"];
                }
                    break;
                case 5:
                {
                    [lastDateFormatter setDateFormat:@"'星期四'"];
                }
                    break;
                case 6:
                {
                    [lastDateFormatter setDateFormat:@"'星期五'"];
                }
                    break;
                case 7:
                {
                    [lastDateFormatter setDateFormat:@"'星期六'"];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
            [lastDateFormatter setDateFormat:@"MM月dd日"];
            break;
    }
    
    //如果月份前面带有0，这里做下处理
    
    NSMutableString *resultString = [[lastDateFormatter stringFromDate:fullShortDate] mutableCopy];
    if ([[resultString substringToIndex:1] isEqualToString: @"0"]) {
        [resultString deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    
    return resultString;
}



+ (NSString *)formatDateString:(NSString *)strDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    if(strDate.length>19)
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    else
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
    NSDate *dateNow = [NSDate date];
    NSDate *dateTarget = [formatter dateFromString:strDate];
    
    [formatter setDateFormat:@"yyyy"];
    NSString *strYearNow = [formatter stringFromDate:dateNow];
    NSString *strYearTarget = [formatter stringFromDate:dateTarget];
    
    
    [formatter setDateFormat:@"yyyy-MM-dd"]; // 今天的比较包容时间误差
    NSComparisonResult resultDateCompare = [[formatter stringFromDate:dateNow] compare:[formatter stringFromDate:dateTarget]];
    if (resultDateCompare == NSOrderedAscending) // 未来
    {
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];// 原样输出
    }
    else
    {
        NSComparisonResult resultYearCompare = [strYearNow compare:strYearTarget];
        switch(resultYearCompare)
        {
            case NSOrderedSame: // 今年
            {
                [formatter setDateFormat:@"yyyy-MM-dd"];
                NSString *strTarget = [formatter stringFromDate:dateTarget];
                NSString *strToday = [formatter stringFromDate:dateNow];
                if ([strToday isEqualToString:strTarget])
                {
                    // 今天
//                    [formatter setTimeStyle:NSDateFormatterNoStyle];
//                    [formatter setDateStyle:NSDateFormatterShortStyle];
//                    [formatter setDoesRelativeDateFormatting:YES];
                    return ASLocalizedString(@"ContactUtils_Tip_11");
                    break;
                }
                
                NSCalendar *cal = [NSCalendar currentCalendar];
                NSDateComponents *components = [[NSDateComponents alloc] init];
                [components setDay:-1];
                NSDate *yesterday = [cal dateByAddingComponents:components toDate:dateNow options:0];
                NSString *strYesterday = [formatter stringFromDate:yesterday];
                if ([strYesterday isEqualToString:strTarget])
                {
                    // 昨天
                   // [formatter setDateFormat:ASLocalizedString(@"'ContactUtils_Tip_1")];
                    return ASLocalizedString(@"ContactUtils_Tip_12");

                    break;
                }
                
                [components setDay:-2];
                NSDate *theDayBeforeYesterday = [cal dateByAddingComponents:components toDate:dateNow options:0];
                NSString *strTheDayBeforeYesterday = [formatter stringFromDate:theDayBeforeYesterday];
                if ([strTheDayBeforeYesterday isEqualToString:strTarget])
                {
                    // 前天
                    //[formatter setDateFormat:ASLocalizedString(@""ContactUtils_Tip_2"")];
                    return ASLocalizedString(@"ContactUtils_Tip_13");

                    break;
                }
                
                // 今年,非今天/昨天/前天
                [formatter setDateFormat:ASLocalizedString(@"ContactUtils_Tip_14")];
            }
                break;
                
            case NSOrderedAscending:
                break;
                
            case NSOrderedDescending: // 往年
            {
                if (strYearNow.intValue - strYearTarget.intValue == 1)
                {
                    // 去年
                    [formatter setDateFormat:ASLocalizedString(@"ContactUtils_Tip_15")];
                }
                else
                {
                    [formatter setDateFormat:ASLocalizedString(@"ContactUtils_Tip_16")];
                }
            }
                break;
        }
    }
    
    return [formatter stringFromDate:dateTarget];
}

@end
