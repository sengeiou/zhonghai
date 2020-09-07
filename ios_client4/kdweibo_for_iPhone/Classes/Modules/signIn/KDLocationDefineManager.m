//
//  KDLocationDefineManager.m
//  kdweibo
//
//  Created by lichao_liu on 5/12/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDLocationDefineManager.h"
#import "KDSignInUtil.h"
@interface KDLocationDefineManager () <MAMapViewDelegate> {
    BOOL _locating;
    NSInteger _locatingTimes;
}
@property(nonatomic, strong) CLLocation *location;
@property(nonatomic, assign) NSInteger signInWorkTimeType;
@property(nonatomic, retain) MAMapView *mapView;
@property (nonatomic, strong) CLLocationManager *cllocationManager;
@end

@implementation KDLocationDefineManager


+(KDLocationDefineManager *)shareManager
{
    static KDLocationDefineManager* _shareManager;
    static dispatch_once_t onceToken = nil;
    dispatch_once(&onceToken, ^{
        _shareManager = [[KDLocationDefineManager alloc] init];
    });
    return _shareManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.mapView = [[MAMapView alloc] init];
    }
    return self;
}

- (void)startLocation {
    if (![KDSignInUtil locationServiceNotEnable]) {
        
        if(!self.mapView)
        {
            self.mapView = [[MAMapView alloc] init];
        }
        self.mapView.delegate = self;
        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        self.mapView.showsUserLocation = YES;
        
        [self performSelector:@selector(locatingTimeOut) withObject:nil afterDelay:25];
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
        {
            self.cllocationManager = [[CLLocationManager alloc] init];
            [self.cllocationManager requestWhenInUseAuthorization];
        }
        self.location = nil;
        _locating = YES;
        _locatingTimes = 0;
    }
}

#pragma mark mapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation NS_AVAILABLE(NA, 4_0) {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locatingTimeOut) object:nil];
    if (userLocation.coordinate.latitude == 0.00000 && userLocation.coordinate.longitude == 0.0000) {
        return;
    }
    self.location = userLocation.location;
    if (_locatingTimes++ < 2) {
        [self performSelector:@selector(locatingTimeOut) withObject:nil afterDelay:25];
        return;
    }
    [self didFindLocationSuccess];
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locatingTimeOut) object:nil];
    if (self.location) {
        [self didFindLocationSuccess];
    }
}

- (void)didFindLocationSuccess {
    dispatch_queue_t stopLocationQueue = dispatch_queue_create("AutoWifiSignInstopQueue", nil);
    dispatch_async(stopLocationQueue, ^{
        [self stopLocationOperation];
    });
    if (self.locationSuccessBlock) {
        self.locationSuccessBlock(self.location);
    }
}

- (void)locatingTimeOut {
    if (self.location != nil) {
        [self didFindLocationSuccess];
    }
    [self stopLocationOperation];
}

- (void)stopLocationOperation {
    if (_locating) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locatingTimeOut) object:nil];
        _locating = NO;
        _locatingTimes = 0;
        self.mapView.showsUserLocation = NO;
        self.mapView.delegate = nil;
    }
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locatingTimeOut) object:nil];
    if (userLocation.coordinate.latitude == 0.00000 && userLocation.coordinate.longitude == 0.0000) {
        return;
    }
    self.location = userLocation.location;
    if (_locatingTimes++ < 2) {
        [self performSelector:@selector(locatingTimeOut) withObject:nil afterDelay:25];
        return;
    }
    [self didFindLocationSuccess];
}

- (void)dealloc {
    if (self.mapView) {
        self.mapView.delegate = nil;
        self.mapView = nil;
    }
}
@end
