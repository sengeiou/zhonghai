//
//  KDAutoWifiSignInLocationManager.m
//  kdweibo
//
//  Created by lichao_liu on 1/8/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDAutoWifiSignInLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <MAMapKit/MAMapKit.h>

@interface KDAutoWifiSignInLocationManager()<MAMapViewDelegate>
{
     BOOL _locating;
    NSInteger _locatingTimes;
}
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign)  NSInteger signInWorkTimeType;
@property(nonatomic, retain)MAMapView *mapView;

@end

@implementation KDAutoWifiSignInLocationManager

+(id)sharedLocationManager
{
    static KDAutoWifiSignInLocationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[KDAutoWifiSignInLocationManager alloc] init];
        sharedManager.mapView = [[MAMapView alloc] init];
    });
    return sharedManager;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation NS_AVAILABLE(NA, 4_0) {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locatingTimeOut) object:nil];
    if(userLocation.coordinate.latitude == 0.00000&&userLocation.coordinate.longitude == 0.0000) {
        return;
    }
    self.location = userLocation.location;
    if(_locatingTimes++ < 2) {
        [self performSelector:@selector(locatingTimeOut) withObject:nil afterDelay:25];
        return;
    }
    [self didFindLocationSuccess];
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locatingTimeOut) object:nil];
    if(self.location)
    {
        [self didFindLocationSuccess];
    }
}

- (void)didFindLocationSuccess
{
    dispatch_queue_t stopLocationQueue = dispatch_queue_create("AutoWifiSignInstopQueue", nil);
    dispatch_async(stopLocationQueue, ^{
        [self stopLocationOperation];
    });
//    dispatch_release(stopLocationQueue);
    
    if(self.locationManagerDelegate && [self.locationManagerDelegate respondsToSelector:@selector(didGetCurrentLocation:workTimeType:)])
    {
        [self.locationManagerDelegate didGetCurrentLocation:self.location workTimeType:self.signInWorkTimeType];
    }
}

- (void)locatingTimeOut {
    if(self.location != nil)
    {
        [self didFindLocationSuccess];
    }
    [self stopLocationOperation];
}

- (void)startLocationOperationWorkTimeType:(NSInteger)type
{
    if(self.isAllowedLocation)
    {
        [self performSelector:@selector(locatingTimeOut) withObject:nil afterDelay:25];
        self.mapView = [[MAMapView alloc] init];
        self.mapView.delegate = self;
        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        self.mapView.showsUserLocation = YES;
        
        self.location = nil;
        self.signInWorkTimeType = type;
        _locating = YES;
        _locatingTimes = 0;
    }
}

- (void)stopLocationOperation
{
    if(_locating)
    {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locatingTimeOut) object:nil];
    _locating = NO;
    _locatingTimes = 0;
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = nil;
  
    }
}

- (BOOL)isAllowedLocation
{
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined))
    {
        return YES;
    }
    else{
        return NO;
    }
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locatingTimeOut) object:nil];
    if(userLocation.coordinate.latitude == 0.00000&&userLocation.coordinate.longitude == 0.0000) {
        return;
    }
    self.location = userLocation.location;
    if(_locatingTimes++ < 2) {
        [self performSelector:@selector(locatingTimeOut) withObject:nil afterDelay:25];
        return;
    }
    [self didFindLocationSuccess];
}
@end
