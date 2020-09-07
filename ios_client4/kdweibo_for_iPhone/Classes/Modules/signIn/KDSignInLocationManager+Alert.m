//
//  KDSignInLocationManager+Alert.m
//  kdweibo
//
//  Created by shifking on 15/11/17.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSignInLocationManager+Alert.h"
#import "KDLocationOptionViewController.h"
#import "BOSSetting.h"
#import "KDSignInUtil.h"

@implementation KDSignInLocationManager (Alert)

#pragma mark - Alert
+ (void)showLocationAlertWithOperationType:(KDMapOperationType)type {
    
    if (type == KDMapOperationType_locationOperationDeni) {
        [KDLocationAlertManager showLocationAlert];
    }
    if (type == KDMapOperationType_error) {
        [self showAlertWithMessage:ASLocalizedString(@"定位失败")];
    }
}

+ (void)showRegeocodeAlertWithOperationType:(KDMapOperationType)type {
    if (type == KDMapOperationType_error) {
        [self showAlertWithMessage:ASLocalizedString(@"地址编码失败")];
    }
    
}

+ (void)showSearchPOIAlertWithOperationType:(KDMapOperationType)type {
    if (type == KDMapOperationType_empty || type == KDMapOperationType_error) {
        [self showAlertWithMessage:ASLocalizedString(@"无法获取周边地址")];
    }
}


+ (void)showAlertWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"温馨提示") message:message delegate:nil cancelButtonTitle:ASLocalizedString(@"知道了") otherButtonTitles: nil];
    [alert show];
}



#pragma mark - Hud
+ (void)showLocationHudWithOperationType:(KDMapOperationType)type inView:(UIView *)view {
    if (type == KDMapOperationType_locationOperationDeni) {
        [KDPopup hideHUDInView:view];
        [KDLocationAlertManager showLocationAlert];
    }
    if (type == KDMapOperationType_error) {
        [KDPopup showHUDToast:ASLocalizedString(@"定位失败") inView:view];
    }
}

+ (void)showRegeocodeHudWithOperationType:(KDMapOperationType)type inView:(UIView *)view {
    if (type == KDMapOperationType_error) {
        [KDPopup showHUDToast:ASLocalizedString(@"地址编码失败") inView:view];
    }
    
}

+ (void)showSearchPOIHudWithOperationType:(KDMapOperationType)type inView:(UIView *)view {
    if (type == KDMapOperationType_empty || type == KDMapOperationType_error) {
        [KDPopup showHUDToast:ASLocalizedString(@"无法获取周边地址") inView:view];
    }
}

- (void)showLocationOptionViewControllerWithLocationArray:(NSArray *)array currentLocation:(KDLocationData *)location currentController:(id)controller{
    KDLocationOptionViewController *  optionVC = [[KDLocationOptionViewController alloc] init];
    optionVC.delegate = controller;
    optionVC.title = ASLocalizedString(@"我的位置");
    optionVC.optionsArray = (array) ? array : @[];
    
    if (!location) location = [KDLocationData locationDataByCoordiante:CLLocationCoordinate2DMake(0, 0)];
    optionVC.locationData = location;
    
    optionVC.shouldHideBottomView = YES;
    optionVC.isFromSignInVC = NO;
    RTRootNavigationController *nav = [[RTRootNavigationController alloc] initWithRootViewController:optionVC];
    
    [controller presentViewController:nav animated:YES completion:nil];
}

/**外勤签到*/
- (void)reSigninToServer:(NSString *)message locationData:(KDLocationData *)locationData failuredRecord:(KDSignInRecord *)failuredRecord block:(void (^)(BOOL success, KDSignInRecord *record, NSString *errorStr))block {
    __weak KDSignInLocationManager *weakSelf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if(!weakSelf){
            return;
        }
        if (results) {
            BOOL success = [[results objectForKey:@"success"] boolValue];
            NSArray *signs = [results objectForKey:@"singIns"];
            if ([signs count] > 0) {
                KDSignInRecord *record = (KDSignInRecord *) [signs lastObject];
                
                if (block) {
                    block(success, record, nil);
                }
            } else {
                if (block) {
                    block(NO, nil, [NSString stringWithFormat:@" %@ statusCode: %ld", [response responseAsString] ?: @"", (long) [response statusCode]]);
                }
            }
        } else {
            if (block) {
                block(NO, nil, [NSString stringWithFormat:@" %@ statusCode: %ld", [response responseAsString] ?: @"", (long) [response statusCode]]);
            }
        }
    };
    
    KDSignInRecord *record = [[KDSignInRecord alloc] init];
    record.singinId = failuredRecord.singinId;
    record.latitude = locationData.coordinate.latitude;
    record.longitude = locationData.coordinate.longitude;
    record.featurename = locationData.name;
    
    NSString *featureDetail = locationData.longAddress;
    if (!KD_IS_BLANK_STR(featureDetail)) {
        NSString *featureName = record.featurename;
        
        if (!KD_IS_BLANK_STR(featureName) && ![featureName isEqualToString:featureDetail]) {
            [record setProperty:[NSString stringWithFormat:@"%@ %@", featureDetail, featureName]
                         forKey:@"featurenamedetail"];
        } else {
            [record setProperty:featureDetail
                         forKey:@"featurenamedetail"];
        }
    }
    
    record.message = message;
    KDQuery *query = [KDQuery query];
    
    NSDictionary *wifiModelDict = [KDSignInUtil getCurrentWifiData];
    if (wifiModelDict && ![wifiModelDict isKindOfClass:[NSNull class]]) {
        NSString *ssid = wifiModelDict[@"ssid"];
        NSString *bssid = wifiModelDict[@"bssid"];
        
        if (ssid && ![ssid isKindOfClass:[NSNull class]]) {
            record.ssid = ssid;
        }
        if (bssid && ![bssid isKindOfClass:[NSNull class]]) {
            record.bssid = bssid;
        }
    }
    
    record.clockInType = failuredRecord.clockInType;
    
    [query setProperty:record forKey:@"signin"];
    [query setParameter:@"org_latitude" doubleValue:failuredRecord.latitude];
    [query setParameter:@"org_longitude" doubleValue:failuredRecord.longitude];
    if (message && message.length > 0) {
        [query setParameter:@"remark" stringValue:message];
    }
    
    [query setParameter:@"deviceInfo" stringValue:[KDSignInUtil getSignInDeviceInfo]];
    
    [KDServiceActionInvoker invokeWithSender:weakSelf actionPath:@"/signId/:resign" query:query
                                 configBlock:nil completionBlock:completionBlock];
}
@end
