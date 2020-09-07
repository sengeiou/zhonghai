//
//  KDAutoWifiDataManager.m
//  kdweibo
//
//  Created by lichao_liu on 1/5/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDAutoWifiSignInDataManager.h"
#import "BOSConfig.h"
#import "NSDate+Additions.h"
#import "KDReachabilityManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "KDDatabaseHelper.h"
#import "KDSigninRecordDAO.h"
#import "KDWeiboDAOManager.h"

#define KDAutoWifiPrefix            [[[BOSConfig sharedConfig] user] eid]
#define KDAutoWifiSignInDataMind    [NSString stringWithFormat:@"%@_KDAutoWifiSignInDataMind",KDAutoWifiPrefix]
#define KDAutoWifiSignInFromOnTime  [NSString stringWithFormat:@"%@_KDAutoWifiSignInFromOnTime",KDAutoWifiPrefix]
#define KDAutoWifiSignInToOnTime    [NSString stringWithFormat:@"%@_KDAutoWifiSignInToOnTime",KDAutoWifiPrefix]
#define KDAutoWifiSignInFromOffTime [NSString stringWithFormat:@"%@_KDAutoWifiSignInFromOffTime",KDAutoWifiPrefix]
#define KDAutoWifiSignInToOffTime   [NSString stringWithFormat:@"%@_KDAutoWifiSignInToOffTime",KDAutoWifiPrefix]
#define KDIsLauchWifiSignIn         [NSString stringWithFormat:@"%@_KDIsLauchWifiSignIn",KDAutoWifiPrefix]

#define KDCountForAutoWifiSignInOnWork      [NSString stringWithFormat:@"%@_KDCountForSignInOnWork",KDAutoWifiPrefix]
#define KDCountForAutoWifiSignInOffWork     [NSString stringWithFormat:@"%@_KDCountForSignInOffWork",KDAutoWifiPrefix]
#define KDAutoWifiSignInDateStr             [NSString stringWithFormat:@"%@_KDAutoWifiSignInDate",KDAutoWifiPrefix]
#define KDAutoWifiSignInWifiData            [NSString stringWithFormat:@"%@_KDAutoWifiSignInWifiData",KDAutoWifiPrefix]
#define KDAutoWifiSignInOffWorkTimeFlag     [NSString stringWithFormat:@"%@_KDAutoWifiSignInOffWorkTimeFlag",KDAutoWifiPrefix]
#define KDIsSettingSignInPoint              [NSString stringWithFormat:@"%@_KDIsSettingSignInPoint",KDAutoWifiPrefix]
#define KDIsShowIntroduceSetSignInPoint     [NSString stringWithFormat:@"%@_KDIsShowIntroduceSetSignInPoint",KDAutoWifiPrefix]
#define KDIsFirstLauchAutoWifiSignIn        [NSString stringWithFormat:@"%@_KDIsFirstLauchAutoWifiSignIn",KDAutoWifiPrefix]
@implementation KDAutoWifiSignInDataManager

+ (id)sharedAutoWifiSignInDataMananger
{
    static KDAutoWifiSignInDataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[KDAutoWifiSignInDataManager alloc] init];
    });
    return sharedManager;
}

- (void)initData
{
    NSNumber *num = [[KDSession globalSession] getPropertyForKey:KDAutoWifiSignInDataMind fromMemoryCache:YES];
    if(!num)
    {
        [self setFromOnWorkTime:[self setTimeWithHour:KDAutoWifiSignInFromOnWorkTimeHour minute:0]];
        [self setToOnWorkTime:[self setTimeWithHour:KDAutoWifiSignInToOnWorkTimeHour minute:0]];
        [self setFromOffWorkTime:[self setTimeWithHour:KDAutoWifiSignInFromOffWorkTimeHour minute:0]];
        [self setToOffWorkTime:[self setTimeWithHour:KDAutoWifiSignInToOffWorkTimeHour minute:0]];
        [self setLauchAutoWifiSignInFlag:YES];
        [[KDSession globalSession] saveProperty:@(YES) forKey:KDAutoWifiSignInDataMind storeToMemoryCache:YES];
    }
    if([self isLauchAutoWifiSignInFlag])
    {
//        [[KDReachabilityManager sharedReachabilityManager] startReachabilityIsChanged:YES];
        self.isLauchNetWorkState = YES;
    }else{
//        [[KDReachabilityManager sharedReachabilityManager] stopNotifier];
        self.isLauchNetWorkState = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if(self.lauchAutoWifiSignInFlag)
        {
//            [[KDReachabilityManager sharedReachabilityManager] startReachabilityIsChanged:NO];
            self.isLauchNetWorkState = YES;
        }
    }];
}

- (void)initDataForSetting
{
    NSNumber *num = [[KDSession globalSession] getPropertyForKey:KDAutoWifiSignInDataMind fromMemoryCache:YES];
    if(!num)
    {
        [self setFromOnWorkTime:[self setTimeWithHour:KDAutoWifiSignInFromOnWorkTimeHour minute:0]];
        [self setToOnWorkTime:[self setTimeWithHour:KDAutoWifiSignInToOnWorkTimeHour minute:0]];
        [self setFromOffWorkTime:[self setTimeWithHour:KDAutoWifiSignInFromOffWorkTimeHour minute:0]];
        [self setToOffWorkTime:[self setTimeWithHour:KDAutoWifiSignInToOffWorkTimeHour minute:0]];
        [self setLauchAutoWifiSignInFlag:YES];
        [[KDSession globalSession] saveProperty:@(YES) forKey:KDAutoWifiSignInDataMind storeToMemoryCache:YES];
    }
    
    if([self isLauchAutoWifiSignInFlag])
    {
//    [[KDReachabilityManager sharedReachabilityManager] startReachabilityIsChanged:NO];
//    [[KDReachabilityManager sharedReachabilityManager] initReachAblity];
    self.isLauchNetWorkState = YES;
    }else{
//        [[KDReachabilityManager sharedReachabilityManager] stopNotifier];
        self.isLauchNetWorkState = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if(self.lauchAutoWifiSignInFlag)
        {
//            [[KDReachabilityManager sharedReachabilityManager] startReachabilityIsChanged:NO];
            self.isLauchNetWorkState = YES;
        }
    }];

}

- (NSDate *)setTimeWithHour:(NSInteger)hour minute:(NSInteger)minute
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:[NSDate date]];
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    NSDate * date = [calendar dateFromComponents:dateComponents];
    return date;
}

- (void)setFromOnWorkTime:(NSDate *)fromOnWorkTime
{
    [[KDSession globalSession] saveProperty:fromOnWorkTime forKey:KDAutoWifiSignInFromOnTime storeToMemoryCache:YES];
}

- (NSDate *)fromOnWorkTime
{
    NSDate *date = [[KDSession globalSession] getPropertyForKey:KDAutoWifiSignInFromOnTime fromMemoryCache:YES];
    if(!date || [date isKindOfClass:[NSNull class]])
    {
        date = [self setTimeWithHour:KDAutoWifiSignInFromOnWorkTimeHour minute:0];
        [self setFromOnWorkTime:date];
    }
    return date;
}

- (void)setToOnWorkTime:(NSDate *)toOnWorkTime
{
    [[KDSession globalSession] saveProperty:toOnWorkTime forKey:KDAutoWifiSignInToOnTime storeToMemoryCache:YES];
}

- (NSDate *)toOnWorkTime
{
    NSDate *date = [[KDSession globalSession] getPropertyForKey:KDAutoWifiSignInToOnTime fromMemoryCache:YES];
    if(!date || [date isKindOfClass:[NSNull class]])
    {
        date = [self setTimeWithHour:KDAutoWifiSignInToOnWorkTimeHour minute:0];
        [self setToOnWorkTime:date];
    }
    return date;
}

- (void)setFromOffWorkTime:(NSDate *)fromOffWorkTime
{
    [[KDSession globalSession] saveProperty:fromOffWorkTime forKey:KDAutoWifiSignInFromOffTime storeToMemoryCache:YES];
}

- (NSDate *)fromOffWorkTime
{
  
    NSDate *date = [[KDSession globalSession] getPropertyForKey:KDAutoWifiSignInFromOffTime fromMemoryCache:YES];
    if(!date || [date isKindOfClass:[NSNull class]])
    {
        date = [self setTimeWithHour:KDAutoWifiSignInFromOffWorkTimeHour minute:0];
        [self setFromOffWorkTime:date];
    }
    return date;
}

- (void)setToOffWorkTime:(NSDate *)toOffWorkTime
{
    [[KDSession globalSession] saveProperty:toOffWorkTime forKey:KDAutoWifiSignInToOffTime storeToMemoryCache:YES];
}

- (NSDate *)toOffWorkTime
{
    NSDate *date =  [[KDSession globalSession] getPropertyForKey:KDAutoWifiSignInToOffTime fromMemoryCache:YES];
    if(!date || [date isKindOfClass:[NSNull class]])
    {
        date = [self setTimeWithHour:KDAutoWifiSignInToOffWorkTimeHour minute:0];
        [self setToOffWorkTime:date];
    }
    return date;
}

- (BOOL)isLauchAutoWifiSignInFlag
{
    return [[[KDSession globalSession] getPropertyForKey:KDIsLauchWifiSignIn fromMemoryCache:YES] boolValue];
}

- (void)setLauchAutoWifiSignInFlag:(BOOL)lauchAutoWifiSignInFlag
{
    [[KDSession globalSession] saveProperty:@(lauchAutoWifiSignInFlag) forKey:KDIsLauchWifiSignIn storeToMemoryCache:YES];
}

- (NSInteger)countForOffWorkCount
{
    NSNumber *num = [[KDSession globalSession] getPropertyForKey:KDCountForAutoWifiSignInOffWork fromMemoryCache:YES];
    return num && ![num isKindOfClass:[NSNull class]]? [num integerValue] : 0;
}

- (void)setCountForOffWorkCount:(NSInteger)countForOffWorkCount
{
    [[KDSession globalSession] saveProperty:@(countForOffWorkCount) forKey:KDCountForAutoWifiSignInOffWork storeToMemoryCache:YES];
}

- (NSInteger)countForOnWorkCount
{
    NSNumber *num = [[KDSession globalSession] getPropertyForKey:KDCountForAutoWifiSignInOnWork fromMemoryCache:YES];
    return num && ![num isKindOfClass:[NSNull class]]? [num integerValue] : 0;
    
}

- (void)setCountForOnWorkCount:(NSInteger)countForOnWorkCount
{
    [[KDSession globalSession] saveProperty:@(countForOnWorkCount) forKey:KDCountForAutoWifiSignInOnWork storeToMemoryCache:YES];
}

- (void)setSignInDateStr:(NSString *)signInDateStr
{
    [[KDSession globalSession] saveProperty:signInDateStr forKey:KDAutoWifiSignInDateStr storeToMemoryCache:YES];
}

- (NSString *)signInDateStr
{
    return [[KDSession globalSession] getPropertyForKey:KDAutoWifiSignInDateStr fromMemoryCache:YES];
}

- (void)setWifiModelDict:(NSDictionary *)wifiModelDict
{
    if(wifiModelDict)
    {
        [[KDSession globalSession] saveProperty:wifiModelDict forKey:KDAutoWifiSignInWifiData storeToMemoryCache:YES];
    }else{
        [[KDSession globalSession] removePropertyForKey:KDAutoWifiSignInWifiData clearCache:YES];
    }
}

- (NSDictionary *)wifiModelDict
{
    return [[KDSession globalSession] getPropertyForKey:KDAutoWifiSignInWifiData fromMemoryCache:YES];
}

- (BOOL)isAutoWifiSignInOffWorkTimeFlag
{
     NSNumber *num = [[KDSession globalSession] getPropertyForKey:KDAutoWifiSignInOffWorkTimeFlag fromMemoryCache:YES];
    if(num && ![num isKindOfClass:[NSNull class]])
    {
        return [num boolValue];
    }
    return NO;
}

- (void)setAutoWifiSignInOffWorkTimeFlag:(BOOL)autoWifiSignInOffWorkTimeFlag
{
    [[KDSession globalSession] saveProperty:@(autoWifiSignInOffWorkTimeFlag) forKey:KDAutoWifiSignInOffWorkTimeFlag storeToMemoryCache:YES];
}

- (void)setIsSettingSignInPoint:(BOOL)isSettingSignInPoint
{
     [[KDSession globalSession] saveProperty:@(isSettingSignInPoint) forKey:KDIsSettingSignInPoint storeToMemoryCache:YES];
}

- (BOOL)isSettingSignInPoint
{
    NSNumber *num = [[KDSession globalSession] getPropertyForKey:KDIsSettingSignInPoint fromMemoryCache:YES];
    if(num && ![num isKindOfClass:[NSNull class]])
    {
        return [num boolValue];
    }
    return NO;
}

- (void)setIsShowIntroduceSetSignInPoint:(BOOL)isShowIntroduceSetSignInPoint
 {
    [[KDSession globalSession] saveProperty:@(isShowIntroduceSetSignInPoint) forKey:KDIsShowIntroduceSetSignInPoint storeToMemoryCache:YES];
}

- (BOOL)isShowIntroduceSetSignInPoint
{
    NSNumber *num = [[KDSession globalSession] getPropertyForKey:KDIsShowIntroduceSetSignInPoint fromMemoryCache:YES];
    if(num && ![num isKindOfClass:[NSNull class]])
    {
        return [num boolValue];
    }
    return NO;
}

- (BOOL)isFirstLauchAutoWifiSignIn
{
   NSNumber *num = [[KDSession globalSession] getPropertyForKey:KDIsFirstLauchAutoWifiSignIn fromMemoryCache:YES];
    if(num)
    {
        return [num boolValue];
    }
    return NO;
}

- (void)setIsFirstLauchAutoWifiSignIn:(BOOL)isFirstLauchAutoWifiSignIn
{
    [[KDSession globalSession] saveProperty:@(isFirstLauchAutoWifiSignIn) forKey:KDIsFirstLauchAutoWifiSignIn storeToMemoryCache:YES];
}


- (void)removeAutoWifiProperty
{
//    [[KDReachabilityManager sharedReachabilityManager] stopReachability];
//    KDSession *session = [KDSession globalSession];
//    [session removePropertyForKey:KDAutoWifiSignInFromOnTime clearCache:YES];
//    [session removePropertyForKey:KDAutoWifiSignInToOnTime clearCache:YES];
//    [session removePropertyForKey:KDAutoWifiSignInFromOffTime clearCache:YES];
//    [session removePropertyForKey:KDAutoWifiSignInToOffTime clearCache:YES];
//    [session removePropertyForKey:KDIsLauchWifiSignIn clearCache:YES];
//    [session removePropertyForKey:KDAutoWifiSignInDataMind clearCache:YES];
//    [session removePropertyForKey:KDCountForAutoWifiSignInOffWork clearCache:YES];
//    [session removePropertyForKey:KDCountForAutoWifiSignInOnWork clearCache:YES];
//    [session removePropertyForKey:KDAutoWifiSignInDateStr clearCache:YES];
//    [session removePropertyForKey:KDAutoWifiSignInWifiData clearCache:YES];
//    [session removePropertyForKey:KDAutoWifiSignInOffWorkTimeFlag clearCache:YES];
    self.isLauchNetWorkState = NO;
//    [session removePropertyForKey:KDIsSettingSignInPoint clearCache:YES];
//    [session removePropertyForKey:KDIsShowIntroduceSetSignInPoint clearCache:YES];
//    [session removePropertyForKey:KDIsFirstLauchAutoWifiSignIn clearCache:YES];
 }

- (BOOL)compareTimeWithOneTime:(NSDate *)oneTime otherTime:(NSDate *)otherTime
{
    NSString *str1 = [oneTime formatWithFormatter:KD_DATE_TIME];
    NSString *str2 = [otherTime formatWithFormatter:KD_DATE_TIME];
    if([str1 isEqualToString:str2])
    {
        return YES;
    }
    return NO;
}

- (BOOL)compareHHMMTimeWithOneTime:(NSDate *)oneTime otherTime:(NSDate *)otherTime
{
    NSString *str1 = [oneTime formatWithFormatter:KD_DATE_TIME];
    NSString *str2 = [otherTime formatWithFormatter:KD_DATE_TIME];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:KD_DATE_TIME];
    NSDate *date1 = [dateFormatter dateFromString:str1];
    NSDate *date2 = [dateFormatter dateFromString:str2];
    NSComparisonResult result =[date1 compare:date2];
    if(result == NSOrderedAscending)
    {
        return YES;
    }else if(result == NSOrderedDescending) {
        return NO;
    }
    return YES;
    
}

- (void)showAlertWithMessage:(NSString *)message title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
    [alert show];
}

- (BOOL)isTime:(NSDate *)date betwwenTimeOne:(NSDate *)dateOne andTimeTwo:(NSDate *)dateTwo
{
    if([self compareHHMMTimeWithOneTime:dateOne otherTime:date] && [self compareHHMMTimeWithOneTime:date otherTime:dateTwo])
    {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)isTwoTimesInSameDayTimeOne:(NSDate *)dateOne timeTwo:(NSDate *)dateTwo
{
    if(NSOrderedSame ==[[self yyyymmddTime:dateOne] compare:dateTwo])
    {
        return YES;
    }
    return NO;
}



- (NSDate *)yyyymmddTime:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                     fromDate:date];
    return [cal dateFromComponents:comps];
}

- (NSDictionary *)getCurrentWifiData
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

- (void)saveRecords:(NSArray *)records date:(NSDate *)date completionBlock:(void (^)(id results))block {
    if (!date) {
        date = [NSDate date];
    }
    __block id results = nil;
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDSigninRecordDAO> signinDAO = [[KDWeiboDAOManager globalWeiboDAOManager] signinDAO];
        [signinDAO saveRecords:records withDate:date database:fmdb rollback:NULL];
        
        return results;
    } completionBlock:block];
}

- (void)signInSuccessPlaySound
{
    static NSString *soundPath = nil;
    
    static NSURL *soundURL = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        soundPath = [[NSBundle mainBundle]
                     
                     pathForResource:@"Calypso" ofType:@"caf"];
        
        soundURL = [NSURL fileURLWithPath:soundPath];
        
    });
    
    SystemSoundID soundID;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundID);
    
    AudioServicesPlaySystemSound(soundID);
}

//判断年月日是否相等
- (BOOL)isAllowedAutoWifiSignInOnWorkTimeWithNowTime:(NSDate *)nowDate workTimeType:(NSInteger)workTimeType
{
    NSString *signInDateStr = self.signInDateStr;
    if(!signInDateStr || [signInDateStr isKindOfClass:[NSNull class]])
    {
         [self setSignInDateStr:[self getYYYYMMDDDate:nowDate]];
        [self setCountForOnWorkCount:0];
        [self setCountForOffWorkCount:0];
         return YES;
    }else{
        if([signInDateStr isEqualToString:[self getYYYYMMDDDate:nowDate]])
        {
            if(workTimeType == KDSignInWorkTimeType_offWork)
            {
                return  KDAutoWifiSignInOffWorkTimeCount > self.countForOffWorkCount ? YES : NO;
            }else{
                return KDAutoWifiSignInOnWorkTimeCount > self.countForOnWorkCount ? YES : NO;
            }
        }else{
             [self setSignInDateStr:[self getYYYYMMDDDate:nowDate]];
            [self setCountForOffWorkCount:0];
            [self setCountForOnWorkCount:0];
             return YES;
        }
    }
    return YES;
}

- (NSString *)getYYYYMMDDDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date  dateByAddingTimeInterval:interval];
    
    return [dateFormatter stringFromDate:localeDate];
}
@end
