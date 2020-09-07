//
//  KDSignInUtil.m
//  kdweibo
//
//  Created by lichao_liu on 16/1/8.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSignInUtil.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "KDDatabaseHelper.h"
#import "KDSigninRecordDAO.h"
#import "KDWeiboDAOManager.h"

#define USER_APP_PATH                 @"/User/Applications/"

@implementation KDSignInUtil

+ (UIImage *)addTextToImage:(UIImage *)img locationName:(NSString *)locationName text:(NSString *)mark deviceIsFrom:(BOOL)isDeviceRear
{
    int w = img.size.width;
    int h = img.size.height;
    UIGraphicsBeginImageContext(img.size);
    [img drawInRect:CGRectMake(0, 0, w, h)];
    
    NSInteger markFont = h/40;
    UIImage *bgImage = [UIImage imageNamed:@"photoSignInBg"];
    [bgImage drawInRect:CGRectMake(0,h-4*markFont, w, 4*markFont)];
    
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:markFont],NSForegroundColorAttributeName:[UIColor whiteColor]};
    CGSize size = [mark boundingRectWithSize:CGSizeMake(w -58.5  , 0) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    CGFloat markOriginY = h - (size.height>2.2*markFont?2.5*markFont:2*markFont);//isDeviceRear ?( h -(size.height > 220 ?250 : 200)):(h- size.height);
    
    if (locationName && ![locationName isEqualToString: @""]) {
        UIImage *locationImage = [UIImage imageNamed:@"sign_tip_location_white"];
        CGFloat locationImageHeight = markFont*1.2;
        CGFloat locationImageWidth = markFont;
        [locationImage drawInRect:CGRectMake(locationImageWidth, markOriginY - locationImageHeight, locationImageWidth, locationImageHeight)];
        
        [locationName drawInRect:CGRectMake(3 * locationImageWidth, markOriginY - locationImageHeight, w - 4 * locationImageWidth, size.height) withAttributes:dict];
        
        [mark drawInRect:CGRectMake(locationImageWidth, markOriginY, w - 58.5, size.height) withAttributes:dict];
    }
    else {
        [mark drawInRect:CGRectMake((w-size.width)*0.5 > 0 ? ((w-size.width)*0.5): 0, markOriginY, w - 58.5, size.height) withAttributes:dict];
    }
    
    UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aimg;
}

+ (NSDictionary *)getCurrentWifiData
{
    NSString *wifiName = nil;
    NSString *wifiBssid = nil;
    
    NSArray *ifs = (__bridge   id)CNCopySupportedInterfaces();
    if(!ifs && ifs.count ==0)
    {
        return nil;
    }
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            wifiName = info[@"SSID"];
            wifiBssid = info[@"BSSID"];
        }
    }
    if(!wifiName || [wifiName isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    if(!wifiBssid || [wifiBssid isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return @{@"ssid":wifiName ? wifiName : [NSNull null],@"bssid":wifiBssid ? wifiBssid : [NSNull null]};
}

+ (void)saveRecords:(NSArray *)records date:(NSDate *)date reload:(BOOL)reload completionBlock:(void (^)(id results))block {
    if (!date) {
        date = [NSDate date];
    }
    __block id results = nil;
    [KDDatabaseHelper asyncInDatabase:(id) ^(FMDatabase *fmdb) {
        id <KDSigninRecordDAO> signinDAO = [[KDWeiboDAOManager globalWeiboDAOManager] signinDAO];
        [signinDAO saveRecords:records withDate:date database:fmdb rollback:NULL];
        if (reload) {
            results = [signinDAO queryRecordsWithLimit:NSUIntegerMax withDate:date database:fmdb];
        }
        return results;
    }completionBlock:block];
    
}

+ (NSString *)weekDayWithWeekIndex:(NSInteger)week
{
    switch (week) {
        case 1:
        {
            return ASLocalizedString(@"星期日");
        }
            break;
        case 2:
        {
            return  ASLocalizedString(@"星期一");
        }
            break;
        case 3:
        {
            return  ASLocalizedString(@"星期二");
        }
            break;
        case 4:
        {
            return  ASLocalizedString(@"星期三");
        }
            break;
        case 5:
        {
            return  ASLocalizedString(@"星期四");
        }
            break;
        case 6:
        {
            return  ASLocalizedString(@"星期五");
        }
            break;
        case 7:
        {
            return  ASLocalizedString(@"星期六");
        }
            break;
    }
    return  nil;
}


+ (NSString *)generateIssueContent {
    NSString *version = [KDCommon clientVersion];
    NSString *model = [[UIDevice currentDevice] model];
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *statusString = [NSString stringWithFormat:@"%@,",[KDReachabilityManager sharedManager].reachabilityStatusDescription];
    
    return [NSString stringWithFormat:@"iOS，%@ %@，%@，%@:%@", model, iosVersion, statusString, KD_APPNAME, version];
}


+ (BOOL)isSameDayWithOneDate:(NSDate *)date1 otherDate:(NSDate *)date2{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    return [comp1 day] == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year] == [comp2 year];
}

+ (BOOL)isSameTimeWithOneDate:(NSDate *)date1 otherDate:(NSDate *)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    return [comp1 hour] == [comp2 hour] &&
    [comp1 minute] == [comp2 minute];
}

//设置透明层
+ (void)insertTransparentGradientWithView:(UIView *)view {
    UIColor *colorOne = [UIColor colorWithRed:1  green:1  blue:1  alpha:0.0];
    UIColor *colorTwo = [UIColor colorWithRed:1  green:1  blue:1  alpha:1.0];
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    //crate gradient layer
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    headerLayer.frame = view.bounds;
    
    [view.layer insertSublayer:headerLayer atIndex:0];
}

+ (BOOL)locationServiceNotEnable{
    return ![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted;
}

+ (BOOL)isJailBreak {
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH]) {
        return YES;
    }
    return NO;
}

+ (NSString *)getSignInDeviceInfo {
    NSDictionary *deviceDict = @{@"deviceName": [UIDevice currentDevice].modelName,
                                 @"isRoot": [KDSignInUtil isJailBreak] ? @"true" : @"false"
                                 };
    NSData *deviceData = [NSJSONSerialization dataWithJSONObject:deviceDict];
    NSString *deviceInfo = [[NSString alloc] initWithData:deviceData encoding:NSUTF8StringEncoding];
    return deviceInfo;
}

+ (NSString *)getRepeatRepresentionWithRepeatType:(KDSignInRemindRepeatType)repeatType {
    NSString *result = nil;
    NSString *weeks[] = {ASLocalizedString(@"、周日"), ASLocalizedString(@"、周一"), ASLocalizedString(@"、周二"), ASLocalizedString(@"、周三"), ASLocalizedString(@"、周四"), ASLocalizedString(@"、周五"), ASLocalizedString(@"、周六")};
    if (repeatType == KDSignInRemindRepeatNone) {
        result = ASLocalizedString(@"永不");
    } else if (repeatType == KDSignInRemindRepeatEveryDay) {
        result = ASLocalizedString(@"每天");
    } else if (repeatType == KDSignInRemindRepeatWorkDay) {
        result = ASLocalizedString(@"工作日");
    } else {
        NSMutableString *str = [NSMutableString string];
        NSInteger n = 0;
        for (NSInteger i = 1; i < 8; i++) {
            n = KDSignInRemindRepeatSun << (i % 7);
            if ((n & repeatType) == n) {
                [str appendString:weeks[i % 7]];
            }
        }
        result = [str stringByReplacingCharactersInRange:(NSRange) {0, 1} withString:@""];
        
        result = [NSString stringWithFormat:@"%@", result];
    }
    return result;
}

+ (NSDictionary *)parseSignInServerData:(NSDictionary *)serverData {
    
    KDSignInParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDSignInParser class]];
    KDSignInRecord *record = [parser parse:serverData];
    
    NSDictionary *medal = serverData[@"medal"];
    NSDictionary *attendanceTips = serverData[@"attendanceTips"];
    NSDictionary *attendanceActivity = serverData[@"attendanceActivity"];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (record) {
        [result setObject:record forKey:@"record"];
    }
    if (medal.count > 0) {
        [result setObject:medal forKey:@"medal"];
    }
    if (attendanceTips.count > 0) {
        [result setObject:attendanceTips forKey:@"attendanceTips"];
    }
    if (attendanceActivity.count > 0) {
        [result setObject:attendanceActivity forKey:@"attendanceActivity"];
    }
    return result;
}

@end
