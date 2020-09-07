//
//  KDReachabilityManager.m
//  kdweibo
//
//  Created by Gil on 15/12/10.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDReachabilityManager.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "AFNetworkReachabilityManager.h"

NSString *const KDReachabilityDidChangeNotification = @"KDReachabilityDidChangeNotification";
NSString *const KDReachabilityStatusKey = @"KDReachabilityStatusKey";
NSString *const KDReachabilityStatusDescriptionKey = @"KDReachabilityStatusDescriptionKey";

static NSString *const KDReachabilityStatusUnknownDescription = @"UNKNOWN";
static NSString *const KDReachabilityStatusNotReachableDescription = @"NONE";
static NSString *const KDReachabilityStatusWiFiDescription = @"WIFI";
static NSString *const KDReachabilityStatus4GDescription = @"4G";
static NSString *const KDReachabilityStatus3GDescription = @"3G";
static NSString *const KDReachabilityStatus2GDescription = @"2G";
static NSString *const KDReachabilityStatusGPRSDescription = @"GPRS";

@interface KDReachabilityManager ()
@end

@implementation KDReachabilityManager

+ (instancetype)sharedManager {
	static dispatch_once_t pred;
	static KDReachabilityManager *instance = nil;

	dispatch_once(&pred, ^{
		instance = [[KDReachabilityManager alloc] init];
	});
	return instance;
}

- (id)init {
	self = [super init];

	if (self) {}
	return self;
}

- (KDReachabilityStatus)reachabilityStatus {
    
	KDReachabilityStatus reachabilityStatus = KDReachabilityStatusUnknown;

    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
	AFNetworkReachabilityStatus networkStatus = manager.networkReachabilityStatus;

	if (networkStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
		reachabilityStatus = KDReachabilityStatusReachableViaWiFi;
	}
	else if (networkStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
		reachabilityStatus = KDReachabilityStatusReachableViaWWAN;
	}
	else if (networkStatus == AFNetworkReachabilityStatusNotReachable) {
		reachabilityStatus = KDReachabilityStatusNotReachable;
	}
    
	return reachabilityStatus;
}

- (NSString *)reachabilityStatusDescription {
	NSString *reachabilityStatusDescription = KDReachabilityStatusUnknownDescription;

	switch (self.reachabilityStatus) {
		case KDReachabilityStatusNotReachable:
			reachabilityStatusDescription = KDReachabilityStatusNotReachableDescription;
			break;

		case KDReachabilityStatusReachableViaWWAN:
		{
			CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];

			if ([telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
				reachabilityStatusDescription = KDReachabilityStatusGPRSDescription;
			}
			else if ([telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
				reachabilityStatusDescription = KDReachabilityStatus2GDescription;
			}
			else if ([telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
				reachabilityStatusDescription = KDReachabilityStatus4GDescription;
			}
			else {
				reachabilityStatusDescription = KDReachabilityStatus3GDescription;
			}
		}
		break;

		case KDReachabilityStatusReachableViaWiFi:
			reachabilityStatusDescription = KDReachabilityStatusWiFiDescription;
			break;

		default:
			break;
	}
	return reachabilityStatusDescription;
}

- (void)startMonitoring {
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    __weak __typeof(self) weakSelf = self;
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDReachabilityDidChangeNotification object:nil userInfo:@{KDReachabilityStatusKey : @(weakSelf.reachabilityStatus), KDReachabilityStatusDescriptionKey : weakSelf.reachabilityStatusDescription}];
    }];
    
    [manager startMonitoring];
}

- (void)stopMonitoring {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager stopMonitoring];
}

- (BOOL)isReachable {
    return self.reachabilityStatus == KDReachabilityStatusReachableViaWWAN || self.reachabilityStatus == KDReachabilityStatusReachableViaWiFi;
}

@end
