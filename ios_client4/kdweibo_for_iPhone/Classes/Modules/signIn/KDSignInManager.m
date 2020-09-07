//
//  KDSignInManager.m
//  kdweibo
//
//  Created by AlanWong on 14-9-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDSignInManager.h"
#import "BOSConfig.h"

#define kCheckHasSetPoint @"CheckHasSetPoint"
#define kCheckedList @"CheckedList"

#define kShowWebHint @"ShowWebHint"
#define kShowedList @"ShowedList"

#define kAddressList @"AddressList"


#define KDFirstLauchNotificateAdminPromtView @"KDFirstLauchNotificateAdminPromtView"
#define KDFirstLauchAddSignInPointPromtView @"KDFirstLauchAddSignInPointPromtView"

#define KDSignInManageMarkShow @"KDSignInManageMarkShow"

@interface KDSignInManager ()
@end

@implementation KDSignInManager
+ (KDSignInManager *)signInManager {
    static KDSignInManager *signInManager = nil;
    @synchronized (self) {
        if (signInManager == nil) {
            signInManager = [[self alloc] init];
        }
    }
    return signInManager;
}

+ (void)deleteAllSignInInfo {
    [self deleteAllWebHintInfo];
}

#pragma mark -
#pragma mark 自定义地址相关

+ (void)storeAddressList:(NSArray *)addressList {
    if (addressList == nil || [addressList count] == 0) {
        [self removeFromUserDefaultWithkeyName:kAddressList];
    }
    else {
        NSMutableString *result = [NSMutableString stringWithString:addressList[0]];
        for (NSInteger i = 1; i < [addressList count]; i++) {
            [result appendString:[NSString stringWithFormat:@":::::%@", addressList[i]]];
            if (i == 2) {
                break;
            }
        }
        [self addToUserDefaultValue:result keyName:kAddressList];
    }
}

+ (NSArray *)getAddressList {
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressList];
    if (string == nil || [string length] == 0) {
        return nil;
    }
    NSArray *array = [string componentsSeparatedByString:@":::::"];
    return array;
}

+ (void)deleteAllWebHintInfo {
    NSString *listString = [[NSUserDefaults standardUserDefaults] objectForKey:kShowedList];
    if (listString == nil || [listString length] == 0) {
        return;
    }
    else {
        NSArray *array = [listString componentsSeparatedByString:@"/"];
        for (NSString *eid in array) {
            NSString *userdefaultKey = [NSString stringWithFormat:@"%@%@", kShowWebHint, eid];
            [self removeFromUserDefaultWithkeyName:userdefaultKey];
            
        }
    }
}

+ (void)addEidToShowedList:(NSString *)eid {
    NSString *listString = [[NSUserDefaults standardUserDefaults] objectForKey:kShowedList];
    if (listString == nil || [listString length] == 0) {
        [self addToUserDefaultValue:eid keyName:kShowedList];
    }
    else {
        NSString *result = [NSString stringWithFormat:@"%@/%@", listString, eid];
        [self addToUserDefaultValue:result keyName:kShowedList];
    }
}

#pragma mark -
#pragma mark - 查询是否设置签到点

+ (void)deleteAllCheckedInfo {
    NSString *listString = [[NSUserDefaults standardUserDefaults] objectForKey:kCheckedList];
    if (listString == nil || [listString length] == 0) {
        return;
    }
    else {
        NSArray *array = [listString componentsSeparatedByString:@"/"];
        for (NSString *eid in array) {
            NSString *userdefaultKey = [NSString stringWithFormat:@"%@%@", kCheckHasSetPoint, eid];
            [self removeFromUserDefaultWithkeyName:userdefaultKey];
            
        }
    }
}

+ (void)addEidToCheckedList:(NSString *)eid {
    NSString *listString = [[NSUserDefaults standardUserDefaults] objectForKey:kCheckedList];
    if (listString == nil || [listString length] == 0) {
        [self addToUserDefaultValue:eid keyName:kCheckedList];
    }
    else {
        NSString *result = [NSString stringWithFormat:@"%@/%@", listString, eid];
        [self addToUserDefaultValue:result keyName:kCheckedList];
        
    }
}

#pragma mark -
#pragma Private Method

+ (NSString *)companyEid {
    KDCommunityManager *communityManager = [[KDManagerContext globalManagerContext] communityManager];
    return communityManager.currentCompany.eid;
}

+ (void)addToUserDefaultValue:(id)value keyName:(NSString *)keyName {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:keyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeFromUserDefaultWithkeyName:(NSString *)keyName {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}


+ (void)setHasLauchNotificateAdminPromtView {
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:[KDSignInManager createKeyStrWithTitle:KDFirstLauchNotificateAdminPromtView]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isSetHasLauchNotificateAdminPromtView {
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:[KDSignInManager createKeyStrWithTitle:KDFirstLauchNotificateAdminPromtView]];
    if (num) {
        return [num boolValue];
    }
    return NO;
}

+ (void)setHasLauchAddSignInPointPromtView {
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:[KDSignInManager createKeyStrWithTitle:KDFirstLauchAddSignInPointPromtView]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isSetHasLauchAddSignInPointPromtView {
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:[KDSignInManager createKeyStrWithTitle:KDFirstLauchAddSignInPointPromtView]];
    if (num) {
        return [num boolValue];
    }
    return NO;
}

//签到点管理 在设置页面是否显示new
+ (void)setSignInPointManageSettingMarkShow {
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:[self createKeyStrWithTitle:KDSignInManageMarkShow]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isSignInPointManageSettingMarkShow {
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:[self createKeyStrWithTitle:KDSignInManageMarkShow]];
    if (num) {
        return [num boolValue];
    }
    return NO;
}

+ (NSString *)createKeyStrWithTitle:(NSString *)title {
    //    [[[BOSConfig sharedConfig] user] eid]
    return [NSString stringWithFormat:@"%@_%@", [BOSConfig sharedConfig].user.userId, title];
}


+ (NSString *)createKeyStAndEidWithTitle:(NSString *)title {
    return [NSString stringWithFormat:@"%@_%@", [[[BOSConfig sharedConfig] user] eid], title];
}

+ (void)removeUserDefaultWithKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 拍照签到数据

+ (BOOL)isFirstLauchPhotoSignIn {
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:[KDSignInManager createKeyStrWithTitle:@"isFirstLauchPhotoSignIn"]];
    if (num && ![num isKindOfClass:[NSNull class]]) {
        return [num boolValue];
    }
    return NO;
}

+ (void)setIsFirstLauchPhotoSignIn:(BOOL)isFirstLauchPhotoSignIn {
    [[NSUserDefaults standardUserDefaults] setObject:@(isFirstLauchPhotoSignIn) forKey:[KDSignInManager createKeyStrWithTitle:@"isFirstLauchPhotoSignIn"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeFirstLauchPhotoSignIn {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[KDSignInManager createKeyStrWithTitle:@"isFirstLauchPhotoSignIn"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isSignInSettingBtnClicked {
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:[KDSignInManager createKeyStrWithTitle:@"isSignInSettingBtnClicked"]];
    if (num && ![num isKindOfClass:[NSNull class]]) {
        return [num boolValue];
    }
    return NO;
}

+ (void)setIsSignInSettingBtnClicked:(BOOL)flag {
    [[NSUserDefaults standardUserDefaults] setObject:@(flag) forKey:[KDSignInManager createKeyStrWithTitle:@"isSignInSettingBtnClicked"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeIsSignInSettingBtnClicked {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[KDSignInManager createKeyStrWithTitle:@"isSignInSettingBtnClicked"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 显示签到引导 -
+ (void)setSigninGuideShow:(BOOL)showSign {
    [[NSUserDefaults standardUserDefaults] setObject:@(showSign) forKey:[self getSignInGuideKeyString]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isSigninGuideShow {
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:[self getSignInGuideKeyString]];
    if (num && ![num isKindOfClass:[NSNull class]]) {
        return [num boolValue];
    }
    return YES;
}

+ (NSString *)getSignInGuideKeyString {
    if ([BOSConfig sharedConfig].user.isAdmin) {
        return [NSString stringWithFormat:@"adminSignInGuide%@", [BOSConfig sharedConfig].user.eid];
    }
    else {
        return @"signinGuideShow";
    }
}

#pragma mark - 上次签到时间 -
+ (NSString *)lastSignInTime {
    NSString *time = [[NSUserDefaults standardUserDefaults] objectForKey:[KDSignInManager createKeyStrWithTitle:@"lastSignInTime"]];
    if (time && ![time isKindOfClass:[NSNull class]]) {
        return time;
    }
    return @"";
}


+ (void)setLastSignInTime:(NSString *)signInTime {
    [[NSUserDefaults standardUserDefaults] setObject:signInTime forKey:[KDSignInManager createKeyStrWithTitle:@"lastSignInTime"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 签到按钮提示点击标记 -
+ (void)setSignInFloatViewFlag:(BOOL)showFlag{
    [[NSUserDefaults standardUserDefaults] setObject:@(showFlag) forKey:@"KDSignInFloatViewFlag"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isSignInFloatViewHadShow{
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"KDSignInFloatViewFlag"];
    if (num && ![num isKindOfClass:[NSNull class]]) {
        return [num boolValue];
    }
    return NO;
}

#pragma mark - 进入签到首页自动签到（每天只自动签到一次）标记 -
+ (NSString *)autoSignInFlagString {
    NSString *time = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"AutoSignInFlag_%@", [BOSConfig sharedConfig].user.eid]];
    return safeString(time);
}

+ (void)setAutoSignInFlagWithString:(NSString *)str {
    [[NSUserDefaults standardUserDefaults] setObject:str forKey:[NSString stringWithFormat:@"AutoSignInFlag_%@", [BOSConfig sharedConfig].user.eid]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
