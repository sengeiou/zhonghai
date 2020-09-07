//
//  KDAutoWifiSignInLocationManager.h
//  kdweibo
//
//  Created by lichao_liu on 1/8/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol KDautoWifiSignInLocationManagerDelegate <NSObject>

- (void)didGetCurrentLocation:(CLLocation *)location workTimeType:(NSInteger)workTimeType;

@end
@interface KDAutoWifiSignInLocationManager : NSObject

@property (nonatomic, assign) id<KDautoWifiSignInLocationManagerDelegate> locationManagerDelegate;

+ (id)sharedLocationManager;
- (void)startLocationOperationWorkTimeType:(NSInteger)type;
- (void)stopLocationOperation;
- (BOOL)isAllowedLocation;
@end
