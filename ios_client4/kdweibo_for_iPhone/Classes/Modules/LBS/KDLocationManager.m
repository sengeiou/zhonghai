//
//  KDLocationManager.m
//  kdweibo
//
//  Created by Tan yingqi on 13-3-12.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDLocationManager.h"
#import "KDSignInLogManager.h"
#import <AMapSearchKit/AMapSearchAPI.h>

#define LOCATION_TIMES  1
#define MAX_RETRY_COUNT  1
#define TIME_OUT 25
#define REVERSE_GEO_TIME_OUT 25
NSString *const KDErrorDomin = @"com.kdweibo.error";
NSString *const KDNotificationLocationInit = @"KDNotificationLocationInit";
NSString *const KDNotificationLocationSuccess = @"KDNotificationLocationSuccess";
NSString *const KDNotificationLocationFailed = @"KDNotificationLocationFailed";
NSString *const KDNotificationLocationStart = @"KDNotificationLocationStart";
NSString *const KDNotificationLocationOffsetCoor = @"KDNotificationLocationOffsetCoor";
NSString *const KDNotificationLocationPOISuccess = @"KDNotificationLocationPOISuccess";
NSString *const KDNotificationLocationPOIFailure = @"KDNotificationLocationPOIFailure";
NSString *const KDNotificationLocationPoiStart = @"KDNotificationLocationPoiStart";

static KDLocationManager *globalLocationManager_ = nil;

@interface KDLocationManager () <CLLocationManagerDelegate, AMapSearchDelegate, MAMapViewDelegate> {
    BOOL locating_;
    BOOL disableLocating_;
    NSInteger reverseGeoRetryCount;
    BOOL GaoDeSearchErrorHappend_;
    NSInteger locatingTimes;
}

@property(nonatomic, strong) AMapSearchAPI *mapSearch;
@property(nonatomic, strong) NSArray *locationDataArray;
@property(nonatomic, strong) KDLocationData *currentData;
@property(nonatomic, strong) CLLocation *bestEffortAtLocation;

@property(nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) CLLocationManager *cllocationManager;
@end

@implementation KDLocationManager
@synthesize mapSearch = mapSearch_;
@synthesize currentData = currentData_;
@synthesize bestEffortAtLocation = bestEffortAtLocation_;

@synthesize locationDataArray = locationDataArray_;
@synthesize locationType = locationType_;
@synthesize mapView = mapView_;

+ (KDLocationManager *)globalLocationManager {
    if (globalLocationManager_ == nil) {
        globalLocationManager_ = [[KDLocationManager alloc] init];
        
    }
    return globalLocationManager_;
}


- (id)init {
    self = [super init];
    if (self) {
        reverseGeoRetryCount = 0;
        locationType_ = KDLocationTypeNormal;
        [self startInitMapSearch];
    }
    return self;
}

- (BOOL)isLocating {
    return locating_;
}

- (void)startLocating {
    
    //不加这段容易崩溃
    if(self.mapView)
    {
        self.mapView.showsUserLocation = NO;
        self.mapView.delegate = nil;
        self.mapView = nil;
    }
    
    locating_ = YES;
    disableLocating_ = NO;
    
    if (self.bestEffortAtLocation != nil) {
        self.bestEffortAtLocation = nil;
    }
    
    
    locatingTimes = 0;
    [self sendStartingNotifiation];
    [self performSelector:@selector(locatingTimeOut) withObject:nil afterDelay:TIME_OUT];
    self.mapView = [[MAMapView alloc] init];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        if(!self.cllocationManager){
            self.cllocationManager = [[CLLocationManager alloc] init];
            [self.cllocationManager requestWhenInUseAuthorization];
        }
    }
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.showsUserLocation = YES;
}


- (void)startInitMapSearch {
    disableLocating_ = NO;
    self.mapSearch = [[AMapSearchAPI alloc] initWithSearchKey: GAODE_MAP_KEY_IPHONE Delegate:self];
}

- (void)stopUpdatingLocation {
    if (locating_) {
        locating_ = NO;
        self.mapView.showsUserLocation = NO;
        self.mapView.delegate = nil;
        self.mapView = nil;
    }
}

- (void)disableLocating {
    disableLocating_ = YES;
    if (locating_) {
        [self stopUpdatingLocation];
    }
}

- (void)locatingTimeOut {
    if (self.bestEffortAtLocation != nil) {
        [self doOffsetSearch:self.bestEffortAtLocation.coordinate];
        return;
    }
    
    NSError *error = [NSError errorWithDomain:KDErrorDomin code:KDLocationErrorLocatingTimeOut userInfo:@{NSLocalizedDescriptionKey : ASLocalizedString(@"定位超时"), NSLocalizedFailureReasonErrorKey : ASLocalizedString(@"定位失败")}];
    [self locatingFailed:error];
}

- (void)locatingFailed:(NSError *)error {
    [self stopUpdatingLocation];
    [self sendFailedNotification:error failedType:KDSignInFailedTypeLocation];
}

- (void)sendFailedNotification:(NSError *)error failedType:(NSString *)failedType {
    if (self.locationType == KDLocationTypeGetPoiArray) {
        NSDictionary *dict = nil;
        if ([failedType isEqualToString:KDSignInFailedTypePOIError]) {
            dict = @{@"error" : error, @"failedType" : failedType, @"currentData" : self.currentData};
        } else {
            dict = @{@"error" : error, @"failedType" : failedType};
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationLocationPOIFailure object:self userInfo:dict];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationLocationFailed object:self userInfo:@{@"error" : error, @"failedType" : failedType}];
    }
}

- (void)sendStartingNotifiation {
    if (self.locationType == KDLocationTypeGetPoiArray) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationLocationPoiStart object:self userInfo:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationLocationStart object:self userInfo:nil];
    }
}

- (void)POIEmpyErrorHappend {
    NSError *error = [NSError errorWithDomain:KDErrorDomin code:KDLocationErrorReverseGeocodingEmpty userInfo:@{NSLocalizedDescriptionKey : ASLocalizedString(@"POI为空"), NSLocalizedFailureReasonErrorKey : ASLocalizedString(@"返回周边信息失败")}];
    [self sendFailedNotification:error failedType:KDSignInFailedTypePOIError];
}

- (void)offsetSearchDidFailed {
    NSError *error = [NSError errorWithDomain:KDErrorDomin code:KDLocationErrorCodeGaoDeSearch userInfo:@{NSLocalizedDescriptionKey : ASLocalizedString(@"纠偏信息为空"), NSLocalizedFailureReasonErrorKey : ASLocalizedString(@"定位失败")}];
    [self sendFailedNotification:error failedType:KDSignInFailedTypeLocation];
    
}

//公共方法，在签到时供外部调用
- (void)doReverseGeocodingSearch {
    if (currentData_ && !disableLocating_) {
        reverseGeoRetryCount = 0;
        [self searchReGeocode:currentData_];
    }
}

//纠偏(2.4.2 开始取消纠偏)
- (void)doOffsetSearch:(CLLocationCoordinate2D)coordinate {
    if (!disableLocating_) {
        
        self.currentData = [KDLocationData locationDataByCoordiante:coordinate];
        if (locationType_ == KDLocationTypeNormal || locationType_ == KDLocationTypeGetPoiArray) { //如果是一般的定位（非签到）立即获取poi
            [self searchReGeocode:currentData_];
        } else { //如果是签到，仅返回纠偏后的经纬
            [self sendOffsetCoordinateNotification:@[currentData_]];
        }
    }
}

///发送纠偏后的坐标（仅签到）
- (void)sendOffsetCoordinateNotification:(NSArray *)array {
    NSDictionary *info = @{@"OffsetLocationArray" : array};
    [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationLocationOffsetCoor object:self userInfo:info];
}

// 反地理位置编码(主要获取省、市)
- (void)searchReGeocode:(KDLocationData *)locationData {
    if (disableLocating_) {
        return;
    }
    CLLocationCoordinate2D coordinate = locationData.coordinate;
    
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.searchType = AMapSearchType_ReGeocode;
    regeoRequest.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeoRequest.radius = 10000;
    regeoRequest.requireExtension = YES;
    
    [mapSearch_ AMapReGoecodeSearch:regeoRequest];
    
    
    [self performSelector:@selector(reverseGeocodingDidTimeOut) withObject:nil afterDelay:REVERSE_GEO_TIME_OUT];
}


//开始获取POI
- (void)doPOISearch:(KDLocationData *)locationData {
    if (!disableLocating_) {
        DLog(@"开始获取POI");
        CLLocationCoordinate2D coordinate = locationData.coordinate;
        AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
        
        request.searchType          = AMapSearchType_PlaceAround;
        request.location            = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        
        request.types = @[@"汽车服务",@"汽车销售",@"汽车维修",@"摩托车服务",@"餐饮服务",@"购物服务",@"生活服务",@"体育休闲服务",@"医疗保健服务",@"住宿服务",@"风景名胜",@"商务住宅",@"政府机构及社会团体",@"科教文化服务",@"交通设施服务",@"金融保险服务",@"金融保险服务",@"公司企业",@"道路附属设施",@"地名地址信息",@"公共设施"];
        /* 按照距离排序. */
        request.sortrule            = 1;
        request.requireExtension    = YES;
        request.offset              = 60;
        request.radius              = 1000;
        [mapSearch_ AMapPlaceSearch:request];
        
        [self performSelector:@selector(reverseGeocodingDidTimeOut) withObject:nil afterDelay:REVERSE_GEO_TIME_OUT];
    }
}


//获取POI成功并发通知
- (void)searchingPOISuccess:(NSArray *)array {
    NSDictionary *info = @{@"locationArray" : array};
    if (self.locationType == KDLocationTypeGetPoiArray) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationLocationPOISuccess object:self userInfo:info];
    } else
        [[NSNotificationCenter defaultCenter] postNotificationName:KDNotificationLocationSuccess object:self userInfo:info];
}

- (void)reverseGeocodingDidTimeOut {
    reverseGeoRetryCount = 0;
    NSError *error = [NSError errorWithDomain:KDErrorDomin code:KDLocationErrorGeocodingTimeOut userInfo:@{NSLocalizedDescriptionKey : ASLocalizedString(@"获取POI超时"), NSLocalizedFailureReasonErrorKey : ASLocalizedString(@"返回周边信息失败")}];
    [self sendFailedNotification:error failedType:KDSignInFailedTypePOIError];
}

#pragma mark -
#pragma mark MAMapViewDelegate Method

/*!
 @brief 位置或者设备方向更新后，会调用此函数
 @param mapView 地图View
 @param userLocation 用户定位信息(包括位置与设备方向等数据)
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation NS_AVAILABLE(NA, 4_0) {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locatingTimeOut) object:nil];
    if (disableLocating_) {
        return;
    }
    if (userLocation.coordinate.latitude == 0.00000 && userLocation.coordinate.longitude == 0.0000) {
        return;
    }
    
    self.bestEffortAtLocation = userLocation.location;
    
    if (locatingTimes++ < LOCATION_TIMES) {
        [self performSelector:@selector(locatingTimeOut) withObject:nil afterDelay:TIME_OUT];
        return;
    }
    
    dispatch_queue_t stopLocationQueue = dispatch_queue_create("stopQueue", nil);
    dispatch_async(stopLocationQueue, ^{
        [self stopUpdatingLocation];
    });
    
    [self doOffsetSearch:self.bestEffortAtLocation.coordinate];
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error NS_AVAILABLE(NA, 4_0) {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locatingTimeOut) object:nil];
    if (self.bestEffortAtLocation != nil) {
        [self doOffsetSearch:self.bestEffortAtLocation.coordinate];
        return;
    }
    
    NSError *theError = error;
    if (error) {
        if ([theError code] == 0) {
            theError = [NSError errorWithDomain:KDErrorDomin code:KDLocationErrorSystemError userInfo:@{NSLocalizedDescriptionKey : ASLocalizedString(@"定位暂时不可用"), NSLocalizedFailureReasonErrorKey : ASLocalizedString(@"定位失败")}];
        }
    } else {
        theError = [NSError errorWithDomain:KDErrorDomin code:KDLocationErrorUnknow userInfo:@{NSLocalizedDescriptionKey : ASLocalizedString(@"定位暂时不可用"), NSLocalizedFailureReasonErrorKey : ASLocalizedString(@"定位返回错误为空")}];
    }
    [self locatingFailed:theError];
}


#pragma mark -
#pragma mark AMapSearchDelegate Method

/*!
 @brief 逆地理编码 查询回调函数
 @param request 发起查询的查询选项(具体字段参考AMapReGeocodeSearchRequest类中的定义)
 @param response 查询结果(具体字段参考AMapReGeocodeSearchResponse类中的定义)
 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reverseGeocodingDidTimeOut) object:nil];
    if (disableLocating_) { //用户取消定位
        return;
    }
    NSString *result;
    if (response.regeocode.formattedAddress && ![response.regeocode.formattedAddress isEqualToString:@""]) {
        
        result = [NSString stringWithFormat:@"%@", response.regeocode.formattedAddress];
        self.currentData.name = result;
        self.currentData.address = result;
    } else {
        result = [NSString stringWithFormat:@"%@%@%@%@", response.regeocode.addressComponent.province, response.regeocode.addressComponent.city, response.regeocode.addressComponent.district, response.regeocode.addressComponent.streetNumber.street];
        if (!((result == nil) || [result isEqualToString:@""])) {
            
            self.currentData.name = result;
            self.currentData.address = result;
        }
    }
    
    self.currentData.province = response.regeocode.addressComponent.province;
    self.currentData.city = response.regeocode.addressComponent.city;
    self.currentData.district = response.regeocode.addressComponent.district;
    self.currentData.street = response.regeocode.addressComponent.streetNumber.street;
    
    reverseGeoRetryCount = 0;
    [self doPOISearch:currentData_];
    
}


/*!
 @brief POI 查询回调函数
 @param request 发起查询的查询选项(具体字段参考AMapPlaceSearchRequest类中的定义)
 @param response 查询结果(具体字段参考AMapPlaceSearchResponse类中的定义)
 */
/* POI 搜索回调. */
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reverseGeocodingDidTimeOut) object:nil];
    
    if (disableLocating_) { //用户取消定位
        return;
    }
    
    //    [self POIEmpyErrorHappend];
    //    return ;
    
    
    //重试
    if (response.pois.count == 0) {
        if (reverseGeoRetryCount < MAX_RETRY_COUNT) {
            [self doPOISearch:self.currentData];
            reverseGeoRetryCount++;
        } else {
            reverseGeoRetryCount = 0;
            [self POIEmpyErrorHappend];
        }
        return;
    }
    
    reverseGeoRetryCount = 0;
    
    NSMutableArray *theResult = [NSMutableArray arrayWithCapacity:response.pois.count];
    
    __block KDLocationData *data;
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        data = [KDLocationData locationDataByMapPOI:obj];
        data.province = self.currentData.province;
        data.city = self.currentData.city;
        data.district = self.currentData.district;
        [theResult addObject:data];
        
    }];
    
    if (!KD_IS_BLANK_STR(self.currentData.name)) {
        [theResult insertObject:self.currentData atIndex:0];
    }
    
    if ([theResult count] > 0) {
        
        reverseGeoRetryCount = 0;
        [self searchingPOISuccess:theResult];
    }
    else {
        if (reverseGeoRetryCount < MAX_RETRY_COUNT) {
            [self doPOISearch:self.currentData];
            reverseGeoRetryCount++;
        } else {
            reverseGeoRetryCount = 0;
            [self POIEmpyErrorHappend];
        }
    }
    
}

/*!
 @brief 通知查询成功或失败的回调函数
 @param searchRequest 发起的查询
 @param errInfo 错误信息
 */

- (void)search:(id)searchRequest error:(NSString *)errInfo {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reverseGeocodingDidTimeOut) object:nil];
    
    if (disableLocating_) { //用户取消定位
        return;
    }
    
    if (!KD_IS_BLANK_STR(self.currentData.name)) {
        NSMutableArray *theResult = [NSMutableArray array];
        [theResult insertObject:self.currentData atIndex:0];
        [self searchingPOISuccess:theResult];
    } else {
        NSString *errorMeg = errInfo;
        if (!errorMeg) {
            errorMeg = ASLocalizedString(@"高德返回POI时出错");
        }
        NSError *error = [NSError errorWithDomain:KDErrorDomin code:KDLocationErrorReverseGeocodingEmpty userInfo:@{NSLocalizedDescriptionKey : errorMeg, NSLocalizedFailureReasonErrorKey : ASLocalizedString(@"返回周边信息失败")}];
        [self sendFailedNotification:error failedType:KDSignInFailedTypePOIError];
    }
    
}


- (void)setClDefineCurrentData:(CLLocation *)locationData {
    if (locationData) {
        currentData_ = [KDLocationData locationDataByCoordiante:locationData.coordinate];
    }
}

@end
