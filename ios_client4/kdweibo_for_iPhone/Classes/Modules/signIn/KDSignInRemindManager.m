//
//  KDSignInRemindManager.m
//  kdweibo
//
//  Created by lichao_liu on 9/14/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDSignInRemindManager.h"
#import "ContactUtils.h"
//#import "KDSetSignInRemindRequest.h"
//#import "KDGetSignInRemindListRequest.h"

@implementation KDSignInRemindManager

+ (void)scheduleNotificationWithFireDate:(NSDate *)fireDate repeat:(NSCalendarUnit)repeat remind:(KDSignInRemind *)remind
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = fireDate;
    localNotif.repeatInterval = repeat;
    localNotif.alertBody = ASLocalizedString(@"别忘记要签到哦~");
    localNotif.alertAction = [NSString stringWithFormat:@"%@签到",KD_APPNAME];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.soundName = @"prompt.caf";
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:remind.remindId, @"remindId", nil];
    [localNotif setUserInfo:userInfo];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

+ (void)updateSignInRemindWithRemind:(KDSignInRemind *)remind
{
    [self cancelSignInRemindWithRemind:remind];
    
    if(remind.isRemind) {
        [self addSignInRemindNotificationWithRemind:remind];
    }
}

+ (void)cancelSignInRemindWithRemind:(KDSignInRemind *)remind
{
    NSArray *localNotificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    if (remind && remind.remindId) {
        for (UILocalNotification *localNotification in localNotificationArray) {
            if ([[localNotification.userInfo objectForKey:@"remindId"] isEqualToString:remind.remindId]) {
                [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            }
        }
    }
    // Cancel All LocalNotification
    else {
        for (UILocalNotification *localNotification in localNotificationArray) {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
    }
}

+ (void)updateSignInReminds:(NSArray *)remindArray
{
    if(remindArray && remindArray.count>0) {
        for (KDSignInRemind *remind in remindArray) {
            if(remind.isRemind) {
                [self addSignInRemindNotificationWithRemind:remind];
            }
        }
    }
}

+ (void)addSignInRemindNotificationWithRemind:(KDSignInRemind *)remind
{
    NSCalendar *calendar2 = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents2 = [calendar2 components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:[NSDate date]];
    
    NSArray *timeArray = [remind.remindTime componentsSeparatedByString:@":"];
    [dateComponents2 setHour:[timeArray[0] integerValue]];
    [dateComponents2 setMinute:[timeArray[1] integerValue]];
    
    NSDate *date = [calendar2 dateFromComponents:dateComponents2];
    
    if(KDSignInRemindRepeatNone == remind.repeatType)
    {
        if(date && [date compare:[NSDate date]] == NSOrderedAscending)
        {
            date = [date dateByAddingTimeInterval:86400];
        }
        [self scheduleNotificationWithFireDate:date repeat:NO remind:remind];
    }else if(KDSignInRemindRepeatEveryDay == (remind.repeatType&KDSignInRemindRepeatEveryDay))
    {
        [self scheduleNotificationWithFireDate:date repeat:NSCalendarUnitDay remind:remind];
    }else{
        NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:[NSDate date]];
        NSInteger weekDay = [comps weekday];
        NSInteger n = 0;
        for (NSInteger i = 0; i < 7; i++) {
            n = KDSignInRemindRepeatSun <<i;
            if ((n & remind.repeatType)== n) {
                    NSDate *fireDate = [date dateByAddingTimeInterval:86400*((i+1)- weekDay)];
                     [self scheduleNotificationWithFireDate:fireDate repeat:NSWeekCalendarUnit remind:remind];
            }
        }
    }
}


+ (void)setNomalSignInReminds
{
    [KDSignInRemindManager setNormalSignInRemindsFlag];
    
    KDSignInRemind *remind1 = [[KDSignInRemind alloc] init];
    remind1.isRemind = NO;
    remind1.remindTime = @"08:30";
    remind1.repeatType = KDSignInRemindRepeatWorkDay;
    [KDSignInRemindManager setSignInRemind:remind1 operateType:0 block:^(BOOL success, NSString *remindId) {
        if (success) {
            remind1.remindId = remindId;
            [[XTDataBaseDao sharedDatabaseDaoInstance] addSignInRemindWithRemindId:remind1.remindId isRemind:remind1.isRemind remindTime:remind1.remindTime repeatType:remind1.repeatType];
        }
    }];
    
    KDSignInRemind *remind2 = [[KDSignInRemind alloc] init];
    remind2.isRemind = NO;
    remind2.remindTime = @"17:30";
    remind2.repeatType = KDSignInRemindRepeatWorkDay;
    [KDSignInRemindManager setSignInRemind:remind2 operateType:0 block:^(BOOL success, NSString *remindId) {
        if (success) {
            remind2.remindId = remindId;
            [[XTDataBaseDao sharedDatabaseDaoInstance] addSignInRemindWithRemindId:remind2.remindId isRemind:remind2.isRemind remindTime:remind2.remindTime repeatType:remind2.repeatType];
        }
    }];
}

+ (BOOL)didNomalSignInRemindsSet
{
    NSString *signInRemindStr = [NSString stringWithFormat:@"%@_signInRemindFlag",[[[BOSConfig sharedConfig] user] eid]];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    id signInRemindNum = [userDefault objectForKey:signInRemindStr];
    if(signInRemindNum && ![signInRemindNum isKindOfClass:[NSNull class]])
    {
        return [signInRemindNum boolValue];
    }
    return NO;
}

+ (void)setNormalSignInRemindsFlag
{
    NSString *signInRemindStr = [NSString stringWithFormat:@"%@_signInRemindFlag",[[[BOSConfig sharedConfig] user] eid]];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@(YES) forKey:signInRemindStr];
    [userDefault synchronize];
}

+ (void)setSignInRemind:(KDSignInRemind *)remind operateType:(NSInteger)operateType block:(void (^)(BOOL success, NSString *remindId))block {
    
    __weak __typeof(self) weakSelf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if (results) {
            if (block)
            {
                block(YES, safeString([results objectForKey:@"data"]));
            }
        } else {
            if (block)
                block([response isValidResponse], nil);
        }
    };
    

    KDQuery *query = [KDQuery query];
    [query setParameter:@"operateType" integerValue:operateType];
    [query setParameter:@"id" stringValue:remind.remindId];
    [query setParameter:@"remindTime" stringValue:remind.remindTime];
    [query setParameter:@"isRemind" stringValue:remind.isRemind ? @"true" : @"false"];
    [query setParameter:@"remindWeekDate" intValue:remind.repeatType];
    [KDServiceActionInvoker invokeWithSender:weakSelf
                                  actionPath:@"/signId/:setRemind"
                                       query:query
                                 configBlock:nil
                             completionBlock:completionBlock];
}

+ (void)getSignInRemindListWithblock:(void (^)(BOOL success, NSArray *remindList))block {

    __weak __typeof(self) weakSelf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if (results) {
            if (block)
            {
                NSArray *array = [results objectForKey:@"data"];
                if(array == [NSNull null] || ![array isKindOfClass:[NSArray class]])
                    array = nil;
                else
                    array = [KDSignInRemind parseWithDicArray:array];
                block(YES, array);
            }
        } else {
            if (block)
                block([response isValidResponse], nil);
        
        }
    };

    [KDServiceActionInvoker invokeWithSender:weakSelf
                                  actionPath:@"/signId/:getRemindList"
                                       query:nil
                                 configBlock:nil
                             completionBlock:completionBlock];

}

+ (void)getSignInRemindListFromServerWithblock:(void (^)(BOOL success))block {
    [KDSignInRemindManager getSignInRemindListWithblock:^(BOOL success, NSArray *remindList) {
        if (success) {
            if (remindList.count > 0) {
                //后台已经有数据,不再添加默认提醒
                if (![KDSignInRemindManager didNomalSignInRemindsSet]) {
                    [KDSignInRemindManager setNormalSignInRemindsFlag];
                }
                
                //清除签到提醒
                NSArray *allRemind = [[XTDataBaseDao sharedDatabaseDaoInstance] querySignInRemind];
                if (allRemind.count > 0) {
                    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllSignInRemind];
                }
                [KDSignInRemindManager cancelSignInRemindWithRemind:nil];
                
                //添加签到提醒到本地
                [[XTDataBaseDao sharedDatabaseDaoInstance] addSignInRemindList:remindList];
                
            }
            else {
                //后台没有数据,客户端添加两个默认提醒
                if (![KDSignInRemindManager didNomalSignInRemindsSet]) {
                    [KDSignInRemindManager setNomalSignInReminds];
                }
            }
            
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                if (block) {
                    block(YES);
                }
            });
        }
        else {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                if (block) {
                    block(NO);
                }
            });
        }
    }];
}

+ (BOOL)isOldSignInRemindDataFlag {
    NSString *signInRemindStr = [NSString stringWithFormat:@"%@_oldSignInRemindDataFlag",[[[BOSConfig sharedConfig] user] eid]];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    id signInRemindNum = [userDefault objectForKey:signInRemindStr];
    if(signInRemindNum && ![signInRemindNum isKindOfClass:[NSNull class]])
    {
        return [signInRemindNum boolValue];
    }
    return NO;
}

+ (void)setOldSignInRemindDataFlag {
    NSString *signInRemindStr = [NSString stringWithFormat:@"%@_oldSignInRemindDataFlag",[[[BOSConfig sharedConfig] user] eid]];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@(YES) forKey:signInRemindStr];
    [userDefault synchronize];
}

@end
