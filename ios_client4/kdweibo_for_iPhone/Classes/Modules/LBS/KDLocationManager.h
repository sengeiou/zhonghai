//
//  KDLocationManager.h
//  kdweibo
//
//  Created by Tan yingqi on 13-3-12.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDLocationData.h"

extern NSString *const KDNotificationLocationSuccess;
extern NSString *const KDNotificationLocationFailed;
extern NSString *const KDNotificationLocationStart;
extern NSString *const KDNotificationLocationOffsetCoor;
extern NSString *const KDErrorDomin;

extern NSString *const KDNotificationLocationPOISuccess;
extern NSString *const KDNotificationLocationPOIFailure;
extern NSString *const KDNotificationLocationPoiStart;
extern NSString *const KDNotificationLocationInit;

typedef enum {
    KDLocationErrorSystemError = 0,
    KDLocatioErrrorNetworkUnConnected = -1000,
    KDLocationErrorReverseGeocodingEmpty, //POI 为空
    KDLocationErrorCodeGaoDeSearch,
    KDLocationErrorLocatingTimeOut,
    KDLocationErrorGeocodingTimeOut, //获取POI 超时
    KDLocationErrorUnknow
} KDLocationErrorCode;

typedef enum {
    KDLocationTypeNormal,
    KDLocationTypeSignIn,
    KDLocationTypeGetPoiArray
} KDLocationType;


@interface KDLocationManager : NSObject
@property(nonatomic, assign) KDLocationType locationType;

+ (KDLocationManager *)globalLocationManager;

- (void)startLocating;

- (BOOL)isLocating;

- (void)disableLocating;

- (void)doReverseGeocodingSearch;


- (void)startInitMapSearch;

- (void)setClDefineCurrentData:(CLLocation *)locationData;
@end
