//
//  KDSignInRemindManager.h
//  kdweibo
//
//  Created by lichao_liu on 9/14/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDSignInRemind.h"

@interface KDSignInRemindManager : NSObject

+ (void)scheduleNotificationWithFireDate:(NSDate *)fireDate repeat:(NSCalendarUnit)repeat remind:(KDSignInRemind *)remind;
+ (void)updateSignInReminds:(NSArray *)remindArray;
+ (void)addSignInRemindNotificationWithRemind:(KDSignInRemind *)remind;
+ (void)cancelSignInRemindWithRemind:(KDSignInRemind *)remind;
+ (void)updateSignInRemindWithRemind:(KDSignInRemind *)remind;

//默认设置2个签到提醒给用户  8:30 5:30
+ (void)setNomalSignInReminds;
+ (BOOL)didNomalSignInRemindsSet;
+ (void)setNormalSignInRemindsFlag;

+ (void)setSignInRemind:(KDSignInRemind *)remind operateType:(NSInteger)operateType block:(void (^)(BOOL success, NSString *remindId))block;
+ (void)getSignInRemindListWithblock:(void (^)(BOOL success, NSArray *remindList))block;
+ (void)getSignInRemindListFromServerWithblock:(void (^)(BOOL success))block;

//旧数据同步标志
+ (BOOL)isOldSignInRemindDataFlag;
+ (void)setOldSignInRemindDataFlag;

@end
