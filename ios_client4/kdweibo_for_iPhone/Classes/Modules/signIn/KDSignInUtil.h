//
//  KDSignInUtil.h
//  kdweibo
//
//  Created by lichao_liu on 16/1/8.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDSignInRemind.h"

@interface KDSignInUtil : NSObject

+ (UIImage *)addTextToImage:(UIImage *)img locationName:(NSString *)locationName text:(NSString *)mark deviceIsFrom:(BOOL)isDeviceRear;
+ (NSDictionary *)getCurrentWifiData;
+ (void)saveRecords:(NSArray *)records date:(NSDate *)date reload:(BOOL)reload completionBlock:(void (^)(id results))block ;
+ (NSString *)weekDayWithWeekIndex:(NSInteger)week;
+ (NSString *)generateIssueContent;
+ (BOOL)isSameDayWithOneDate:(NSDate *)date1 otherDate:(NSDate *)date2;
+ (BOOL)isSameTimeWithOneDate:(NSDate *)date1 otherDate:(NSDate *)date2;
+ (void)insertTransparentGradientWithView:(UIView *)view;
+ (BOOL)locationServiceNotEnable;


/**
 判断设备是否越狱
 
 @return YES越狱,NO非越狱
 */
+ (BOOL)isJailBreak;


/**
 获取签到设备的信息
 
 @return {deviceName:"iphone 6s", isRoot:"true|false"}
 */
+ (NSString *)getSignInDeviceInfo;

/**
 change repeatType to repeatRepresention
 
 @param repeatType
 @return repeatRepresention
 */
+ (NSString *)getRepeatRepresentionWithRepeatType:(KDSignInRemindRepeatType)repeatType;


/**
 解析签到返回的服务器数据（临时方法，等签到接口都替换成新的网络框架的时候重写KDSignInRecord类，才能干掉）
 
 @param serverData 签到接口返回的数据
 @return 解析过的签到数据
 */
+ (NSDictionary *)parseSignInServerData:(NSDictionary *)serverData;

@end
