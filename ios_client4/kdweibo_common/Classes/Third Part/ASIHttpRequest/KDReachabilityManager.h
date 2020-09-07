//
//  KDReachabilityManager.h
//  kdweibo
//
//  Created by Gil on 15/12/10.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, KDSignInWorkTimeType) {
    KDSignInWorkTimeType_onwork,
    KDSignInWorkTimeType_offWork
};

typedef NS_ENUM (NSInteger, KDReachabilityStatus) {
	KDReachabilityStatusUnknown = -1,
	KDReachabilityStatusNotReachable = 0,
	KDReachabilityStatusReachableViaWWAN = 1,
	KDReachabilityStatusReachableViaWiFi = 2,
};

/**
 *  [notification userInfo] = 
 *
 *  {
 *      KDReachabilityStatusKey : reachabilityStatus,
 *      KDReachabilityStatusDescriptionKey : reachabilityStatusDescription
 *  }
 *
 */
FOUNDATION_EXPORT NSString *const KDReachabilityDidChangeNotification;
FOUNDATION_EXPORT NSString *const KDReachabilityStatusKey;
FOUNDATION_EXPORT NSString *const KDReachabilityStatusDescriptionKey;

@interface KDReachabilityManager : NSObject

@property (assign, nonatomic, readonly) KDReachabilityStatus reachabilityStatus;
//return WIFI、4G、3G、2G、GPRS、NONE、UNKNOWN
@property (strong, nonatomic, readonly) NSString *reachabilityStatusDescription;

+ (instancetype)sharedManager;

- (void)startMonitoring;
- (void)stopMonitoring;
- (BOOL)isReachable;

@end
