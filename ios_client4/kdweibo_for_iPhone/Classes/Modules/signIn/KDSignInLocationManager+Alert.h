//
//  KDSignInLocationManager+Alert.h
//  kdweibo
//
//  Created by shifking on 15/11/17.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSignInLocationManager.h"
#import "KDSignInRecord.h"
@interface KDSignInLocationManager (Alert)

+ (void)showLocationAlertWithOperationType:(KDMapOperationType)type;
+ (void)showRegeocodeAlertWithOperationType:(KDMapOperationType)type;
+ (void)showSearchPOIAlertWithOperationType:(KDMapOperationType)type;


+ (void)showLocationHudWithOperationType:(KDMapOperationType)type inView:(UIView *)view;
+ (void)showRegeocodeHudWithOperationType:(KDMapOperationType)type inView:(UIView *)view;
+ (void)showSearchPOIHudWithOperationType:(KDMapOperationType)type inView:(UIView *)view;


- (void)showLocationOptionViewControllerWithLocationArray:(NSArray *)array currentLocation:(KDLocationData *)location currentController:(id)controller;

- (void)reSigninToServer:(NSString *)message locationData:(KDLocationData *)locationData failuredRecord:(KDSignInRecord *)failuredRecord block:(void (^)(BOOL success, KDSignInRecord *record, NSString *errorStr))block;
@end
