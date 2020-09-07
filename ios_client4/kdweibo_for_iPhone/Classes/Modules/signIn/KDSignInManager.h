//
//  KDSignInManager.h
//  kdweibo
//
//  Created by AlanWong on 14-9-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

/**
 *  本来目前管理签到signin的本地化信息（NSUserdefault），
 *  虽然是单列模式，但是都是使用类方法，后续可以加入实例方法进来。
 *
 */


#import <Foundation/Foundation.h>

@interface KDSignInManager : NSObject
+ (KDSignInManager *)signInManager;

/**
 *  清楚所有有关签到的信息
 */
+ (void)deleteAllSignInInfo;

+ (void)deleteAllCheckedInfo; //清除本地已经记录的有关是否查询的信息

+ (void)deleteAllWebHintInfo; //清除本地已经记录的有关提示显示的信息

//自定义签到地点相关方法
+ (NSArray *)getAddressList;

+ (void)storeAddressList:(NSArray *)addressList;

+ (void)setHasLauchNotificateAdminPromtView;

+ (BOOL)isSetHasLauchNotificateAdminPromtView;

+ (void)setHasLauchAddSignInPointPromtView;

+ (BOOL)isSetHasLauchAddSignInPointPromtView;

//签到点管理 在设置页面是否显示new
+ (void)setSignInPointManageSettingMarkShow;

+ (BOOL)isSignInPointManageSettingMarkShow;

+ (BOOL)isFirstLauchPhotoSignIn;

+ (void)setIsFirstLauchPhotoSignIn:(BOOL)isFirstLauchPhotoSignIn;

+ (BOOL)isSignInSettingBtnClicked;

+ (void)setIsSignInSettingBtnClicked:(BOOL)flag;

//是否显示签到引导
+ (void)setSigninGuideShow:(BOOL)showSign;
+ (BOOL)isSigninGuideShow;

//上次签到时间
+ (NSString *)lastSignInTime;
+ (void)setLastSignInTime:(NSString *)signInTime;

//签到按钮提示点击标记
+ (void)setSignInFloatViewFlag:(BOOL)showFlag;
+ (BOOL)isSignInFloatViewHadShow;

//进入签到首页自动签到（每天只自动签到一次）标记
+ (void)setAutoSignInFlagWithString:(NSString *)str;
+ (NSString *)autoSignInFlagString;

@end
