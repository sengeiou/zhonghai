//
//  KDSignInLocationManager.m
//  kdweibo
//
//  Created by lichao_liu on 11/11/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import "KDSignInLocationManager.h"

#import "NSString+Operate.h"

static NSInteger const KDLocationTimeOut = 25;
static NSInteger const KDLocationUpdateCount = 1;
static NSInteger const KDReGeocodeSearchtTimeOut = 25;
static NSInteger const KDDoSearchPoiTimeOut = 25;
@interface KDSignInLocationManager()<MAMapViewDelegate,AMapSearchDelegate>
{
    BOOL _isLocating;
    BOOL _isReGeocoding;
    BOOL _isPoiSearching;
}
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, copy) KDLocationBlock locationSuccessBlock;
@property (nonatomic, copy) KDLocationBlock locationFailuredBlock;

@property (nonatomic, copy) KDReGeocodeBlock reGeocodeSuccessBlock;
@property (nonatomic, copy) KDReGeocodeBlock reGeocodeFailuredBlcok;
@property(nonatomic, strong) KDLocationData *currentData;

@property (nonatomic, copy) KDPoiSearchBlock poiSearchSuccessBlock;
@property (nonatomic, copy) KDPoiSearchBlock poiSearchFailuredBlcok;
@property (nonatomic, assign) NSInteger locationCount;
@property (nonatomic, strong) AMapSearchAPI *mapSearch;
@property (nonatomic, assign) BOOL isNeedCurrentLocation;

@end

@implementation KDSignInLocationManager

- (AMapSearchAPI *)mapSearch
{
    if(!_mapSearch)
    {
        _mapSearch = [[AMapSearchAPI alloc] initWithSearchKey:GAODE_MAP_KEY_IPHONE Delegate:self];
        _mapSearch.delegate = self;
    }
    return _mapSearch;
}

- (void)startLocationWithSuccessBlock:(KDLocationBlock)locationSuccessBlock
                         failuedBlock:(KDLocationBlock)failuredBlock
{
    if(![self isLocationOperationOpen])
    {
        if(failuredBlock)
        {
            failuredBlock(nil,KDMapOperationType_locationOperationDeni);
        }
        return;
    }
    
    if(_isReGeocoding)
    {
        [self reGeocodingDidTimeOut];
    }
    if(_isPoiSearching)
    {
        [self poiSearchDidTimeOut];
    }
    
    self.locationSuccessBlock = locationSuccessBlock;
    self.locationFailuredBlock = failuredBlock;
    
    _isLocating = YES;
    self.bestLocation = nil;
    [self performSelector:@selector(locatingTimeOut) withObject:nil afterDelay:KDLocationTimeOut];
    
    self.mapView = [[MAMapView alloc] init];
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.showsUserLocation = YES;
}

- (void)startReGeocodeSearchWithLocation:(CLLocation *)location
                            SuccessBlock:(KDReGeocodeBlock)successBlock
                           failuredBlock:(KDReGeocodeBlock)failuredBlock
{
    self.currentData = nil;
    
    self.currentData = [[KDLocationData alloc] init];
    self.currentData.coordinate = location.coordinate;
    
    self.reGeocodeFailuredBlcok = failuredBlock;
    self.reGeocodeSuccessBlock = successBlock;
    if(_isLocating || _isReGeocoding || _isPoiSearching)
    {
        if(self.reGeocodeFailuredBlcok)
        {
            self.reGeocodeFailuredBlcok(nil,KDMapOperationType_operating);
        }
    }
    _isReGeocoding = YES;
    [self performSelector:@selector(reGeocodingDidTimeOut) withObject:nil afterDelay:KDReGeocodeSearchtTimeOut];
    
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    self.mapSearch = [[AMapSearchAPI alloc] initWithSearchKey:GAODE_MAP_KEY_IPHONE Delegate:self];
    self.mapSearch.delegate = self;
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeoRequest.radius = 10000;
    regeoRequest.requireExtension = YES;
    
    [self.mapSearch AMapReGoecodeSearch:regeoRequest];
}

- (void)doPoiSearchWithOffset:(CGFloat)offset
                         page:(NSInteger)page
                       radius:(CGFloat)radius
                     location:(CLLocation *)location
                      keyword:(NSString *)keyword
                 successBlock:(KDPoiSearchBlock)successBlock
                failuredBlock:(KDPoiSearchBlock)failuredBlock
              isNeedReGeoCode:(BOOL)needReGeoCode
{
    if(![self isLocationOperationOpen])
    {
        if(failuredBlock)
        {
            failuredBlock(nil,KDMapOperationType_locationOperationDeni);
        }
        return;
    }
    
    __weak KDSignInLocationManager *weakSelf = self;
    self.isNeedCurrentLocation = needReGeoCode;
    if(needReGeoCode)
    {
        [self startReGeocodeSearchWithLocation:location SuccessBlock:^(KDLocationData *locationData, KDMapOperationType type) {
            [weakSelf doPoiSearchWithOffset:offset page:page radius:radius location:location keyword:keyword successBlock:successBlock failuredBlock:failuredBlock];
        } failuredBlock:^(KDLocationData *locationData, KDMapOperationType type) {
            if(failuredBlock)
            {
                failuredBlock(nil,KDMapOperationType_error);
            }
        }];
    }else{
        [self doPoiSearchWithOffset:offset page:page radius:radius location:location keyword:keyword successBlock:successBlock failuredBlock:failuredBlock];
    }
}

- (void)doPoiSearchWithOffset:(CGFloat)offset
                         page:(NSInteger)page
                       radius:(CGFloat)radius
                     location:(CLLocation *)location
                      keyword:(NSString *)keyword
                 successBlock:(KDPoiSearchBlock)successBlock
                failuredBlock:(KDPoiSearchBlock)failuredBlock
{
    self.poiSearchFailuredBlcok = failuredBlock;
    self.poiSearchSuccessBlock = successBlock;
    if(_isPoiSearching || _isReGeocoding || _isLocating){
        if(self.poiSearchFailuredBlcok){
            self.poiSearchFailuredBlcok(nil,KDMapOperationType_operating);
        }
    }
    
    [self performSelector:@selector(poiSearchDidTimeOut) withObject:nil afterDelay:KDDoSearchPoiTimeOut];
    _isPoiSearching = YES;
    
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    
    request.searchType          = AMapSearchType_PlaceKeyword;
    request.location            = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    
    request.types = @[@"汽车服务",@"汽车销售",@"汽车维修",@"摩托车服务",@"餐饮服务",@"购物服务",@"生活服务",@"体育休闲服务",@"医疗保健服务",@"住宿服务",@"风景名胜",@"商务住宅",@"政府机构及社会团体",@"科教文化服务",@"交通设施服务",@"金融保险服务",@"金融保险服务",@"公司企业",@"道路附属设施",@"地名地址信息",@"公共设施"];
    /* 按照距离排序. */
    request.sortrule            = 1;
    request.requireExtension    = YES;
    request.offset              = offset;
    request.radius              = radius;
    [self.mapSearch AMapPlaceSearch:request];
}


#pragma mark -MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locatingTimeOut) object:nil];
    
    if (userLocation.coordinate.latitude == 0.00000 && userLocation.coordinate.longitude == 0.0000) {
        return;
    }
    self.bestLocation = userLocation.location;
    
    if (self.locationCount++ < KDLocationUpdateCount) {
        [self performSelector:@selector(locatingTimeOut) withObject:nil afterDelay:KDLocationTimeOut];
        return;
    }
    
    [self locatingTimeOut];
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locatingTimeOut) object:nil];
    [self locatingTimeOut];
}

#pragma mark searchDelegate
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reGeocodingDidTimeOut) object:nil];
    NSString *result;
    NSString *name = @"";
    _isReGeocoding = NO;
    
    if (response.regeocode.formattedAddress && ![response.regeocode.formattedAddress isEqualToString:@""]) {
        result = [NSString stringWithFormat:@"%@", response.regeocode.formattedAddress];
        AMapAddressComponent *addressComponent = response.regeocode.addressComponent;
        NSMutableArray *cusStrs = @[].mutableCopy;
        if(addressComponent.province && addressComponent.province.length>0)
        {
            [cusStrs addObject:addressComponent.province];
        }
        if(addressComponent.city && addressComponent.city.length>0)
        {
            [cusStrs addObject:addressComponent.city];
        }
        if(addressComponent.district && addressComponent.district.length>0)
        {
            [cusStrs addObject:addressComponent.district];
        }
        if(addressComponent.township && addressComponent.township.length>0)
        {
            [cusStrs addObject:addressComponent.township];
        }
        name = [NSString cutSubStrings:cusStrs string:response.regeocode.formattedAddress];
        self.currentData.name = name;
        self.currentData.address = result;
    } else {
        NSString *province = response.regeocode.addressComponent.province ? response.regeocode.addressComponent.province : @"";
        NSString *city = response.regeocode.addressComponent.city ? response.regeocode.addressComponent.city : @"";
        NSString *district = response.regeocode.addressComponent.district ? response.regeocode.addressComponent.district : @"";
        NSString *street = response.regeocode.addressComponent.streetNumber.street ? response.regeocode.addressComponent.streetNumber.street : @"";
        
        result = [NSString stringWithFormat:@"%@%@%@%@", province, city, district, street];
        if (!((result == nil) || [result isEqualToString:@""])) {
            self.currentData.name = result;
            self.currentData.address = result;
        }
    }
    
    self.currentData.province = response.regeocode.addressComponent.province;
    self.currentData.city = response.regeocode.addressComponent.city;
    self.currentData.district = response.regeocode.addressComponent.district;
    self.currentData.street = response.regeocode.addressComponent.streetNumber.street;

    if (!self.currentData.address || self.currentData.address.length == 0) {
        if (_reGeocodeFailuredBlcok) {
            self.reGeocodeFailuredBlcok (self.currentData , KDMapOperationType_error);
        }
    }
    else {
        if(self.reGeocodeSuccessBlock)
        {
            self.reGeocodeSuccessBlock(self.currentData,KDMapOperationType_success);
        }
    }
    
}

- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    _isPoiSearching = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(poiSearchDidTimeOut) object:nil];
    
    NSMutableArray *poiArray = [NSMutableArray arrayWithCapacity:response.pois.count];
    if (response.pois.count == 0) {
        if(self.poiSearchFailuredBlcok){
            if (!KD_IS_BLANK_STR(self.currentData.name)) {
                [poiArray insertObject:self.currentData atIndex:0];
            }
            self.poiSearchFailuredBlcok((poiArray.count== 1)?poiArray : nil,KDMapOperationType_empty);
        }
        return;
    }
    
    __block KDLocationData *data;
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        data = [KDLocationData locationDataByMapPOI:obj];
        data.province = self.currentData.province;
        data.city = self.currentData.city;
        data.district = self.currentData.district;
        [poiArray addObject:data];
        
    }];
    
    if(self.isNeedCurrentLocation)
    {
        if (!KD_IS_BLANK_STR(self.currentData.name)) {
            [poiArray insertObject:self.currentData atIndex:0];
        }
    }
    
    if ([poiArray count] > 0) {
        if(self.poiSearchSuccessBlock)
        {
            self.poiSearchSuccessBlock(poiArray,KDMapOperationType_success);
        }
    }
    else {
        if(self.poiSearchFailuredBlcok){
            self.poiSearchFailuredBlcok(nil,KDMapOperationType_empty);
        }
    }
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    if(_isReGeocoding)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reGeocodingDidTimeOut) object:nil];
        
        [self reGeocodingDidTimeOut];
    }else if(_isPoiSearching)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(poiSearchDidTimeOut) object:nil];
        if(self.poiSearchFailuredBlcok){
            self.poiSearchFailuredBlcok(nil,KDMapOperationType_error);
        }
        [self poiSearchDidTimeOut];
    }
}

- (void)locatingTimeOut
{
    [self stopLocation];
    if(self.bestLocation != nil)
    {
        if(self.locationSuccessBlock)
        {
            self.locationSuccessBlock(self.bestLocation,KDMapOperationType_success);
            self.locationSuccessBlock = nil;
        }
    }else{
        if(self.locationFailuredBlock)
        {
            self.locationFailuredBlock(nil,KDMapOperationType_error);
            self.locationFailuredBlock = nil;
        }
    }
    
}

- (void)reGeocodingDidTimeOut
{
    _isReGeocoding = NO;
    if(self.reGeocodeFailuredBlcok)
    {
        KDLocationData *locationData = [[KDLocationData alloc] init];
        locationData.coordinate = self.bestLocation.coordinate;
        self.reGeocodeFailuredBlcok(locationData,KDMapOperationType_error);
        self.reGeocodeFailuredBlcok = nil;
    }
    if(self.reGeocodeSuccessBlock)
    {
        self.reGeocodeSuccessBlock = nil;
    }
    [self stopSearchAction];
}

- (void)stopLocation
{
    _isLocating = NO;
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = nil;
    self.mapView = nil;
    self.locationCount = 0;
}

- (void)stopSearchAction
{
    if(_mapSearch)
    {
        _mapSearch.delegate = nil;
        _mapSearch = nil;
    }
}

- (void)poiSearchDidTimeOut
{
    _isNeedCurrentLocation = NO;
    _isPoiSearching = NO;
    if(self.poiSearchSuccessBlock)
    {
        self.poiSearchSuccessBlock = nil;
    }
    if(self.poiSearchFailuredBlcok)
    {
        self.poiSearchFailuredBlcok = nil;
    }
    [self stopSearchAction];
}

- (BOOL)isLocationOperationOpen
{
    return !([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted);
    
}

- (void)stopOpration
{
    if(_mapView)
    {
        _mapView.delegate = nil;
        _mapView = nil;
    }
    if(_mapSearch)
    {
        _mapSearch.delegate = nil;
        _mapSearch = nil;
    }
    if(self.currentData)
    {
        self.currentData = nil;
    }
    self.locationCount = 0;
    _isLocating = NO;
    _isPoiSearching = NO;
    _isReGeocoding = NO;
    _isNeedCurrentLocation = NO;
    if(self.bestLocation)
    {
        self.bestLocation = nil;
    }
}

@end
