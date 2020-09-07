//
//  KDAutoWifiDataManager.h
//  kdweibo
//
//  Created by lichao_liu on 1/5/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  KDAutoWifiSignInOffWorkTimeCount 3
#define  KDAutoWifiSignInOnWorkTimeCount 1

#define KDAutoWifiSignInFromOnWorkTimeHour 8  //上班卡开始时间点
#define KDAutoWifiSignInToOnWorkTimeHour 10   //上班卡结束时间点
#define KDAutoWifiSignInFromOffWorkTimeHour 17
#define KDAutoWifiSignInToOffWorkTimeHour  19

@interface KDAutoWifiSignInDataManager : NSObject
@property (nonatomic, strong) NSDate *fromOnWorkTime;
@property (nonatomic, strong) NSDate *toOnWorkTime;
@property (nonatomic, strong) NSDate *fromOffWorkTime;
@property (nonatomic, strong) NSDate *toOffWorkTime;
@property (nonatomic, assign,getter=isLauchAutoWifiSignInFlag) BOOL lauchAutoWifiSignInFlag;
@property (nonatomic, assign) NSInteger countForOnWorkCount;
@property (nonatomic, assign) NSInteger countForOffWorkCount;
@property (nonatomic, strong) NSString *signInDateStr;
@property (nonatomic, strong) NSDictionary *wifiModelDict;
@property (nonatomic, assign, getter=isAutoWifiSignInOffWorkTimeFlag) BOOL autoWifiSignInOffWorkTimeFlag;
@property (nonatomic, assign) BOOL isSettingSignInPoint;
@property (nonatomic, assign) BOOL isFirstLauchAutoWifiSignIn;
@property (nonatomic, assign) BOOL isShowIntroduceSetSignInPoint;

@property (nonatomic, assign) BOOL isLauchNetWorkState;


+ (id)sharedAutoWifiSignInDataMananger;
- (void)removeAutoWifiProperty;
- (void)initData;
- (void)initDataForSetting;
- (BOOL)compareTimeWithOneTime:(NSDate *)oneTime otherTime:(NSDate *)otherTime;
- (BOOL)compareHHMMTimeWithOneTime:(NSDate *)oneTime otherTime:(NSDate *)otherTime;
- (void)showAlertWithMessage:(NSString *)message title:(NSString *)title;
- (BOOL)isTime:(NSDate *)date betwwenTimeOne:(NSDate *)dateOne andTimeTwo:(NSDate *)dateTwo;
- (BOOL)isTwoTimesInSameDayTimeOne:(NSDate *)dateOne timeTwo:(NSDate *)dateTwo;
- (NSDictionary *)getCurrentWifiData;
- (void)saveRecords:(NSArray *)records date:(NSDate *)date completionBlock:(void (^)(id results))block;
- (void)signInSuccessPlaySound;
- (BOOL)isAllowedAutoWifiSignInOnWorkTimeWithNowTime:(NSDate *)nowDate workTimeType:(NSInteger)workTimeType;
@end
