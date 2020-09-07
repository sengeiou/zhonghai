
//  KDSetSignInPointVC.m
//  kdweibo
//
//  Created by shifking on 15/9/18.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSetSignInPointVC.h"
#import "KDLocationData.h"
#import <MAMapKit/MAMapKit.h>
#import "KDSignPointPoiSearch.h"
#import "KDSignInPoint.h"
#import "SignInPaoPaoView.h"
#import "NSString+Operate.h"
#import "KDSignInLocationManager.h"
#import "PulsingHaloLayer.h"
#define MaxLocationtimes 3
@interface KDSetSignInPointVC ()<MAMapViewDelegate, KDSignInPointSearchDelegate, AMapSearchDelegate, UIAlertViewDelegate, KDAddOrUpdateSignInPointControllerDelegate>
{
    BOOL _haloLayerAnimationFlag;
}
@property (nonatomic, strong) MAMapView             *mapView;
@property (nonatomic, strong) SignInPaoPaoView      *paopaoView;
@property (nonatomic, strong) UIView                *searchView;
@property (nonatomic, strong) UILabel               *locateName;
@property (nonatomic, strong) UILabel               *locateAddress;
@property (nonatomic, strong) UIButton              *locationButton;

@property (nonatomic, strong) AMapSearchAPI *mapSearch;
@property (nonatomic, strong) KDSignPointPoiSearch *signInPointSearch;
@property (nonatomic, strong) CLLocationManager *cllocationManager;

@property (nonatomic, strong) KDLocationData *locationData;
@property (nonatomic, assign) CGPoint paopaoPoint;
@property (nonatomic, assign) BOOL firstLoad;

@property (assign , nonatomic) BOOL searchingGeocode;  //正在通过搜索框搜索地址

@property (strong , nonatomic) KDSignInLocationManager *locationManager;
@property (strong , nonatomic) KDSignInLocationManager *reGeocodeManager;
@property (nonatomic, strong) PulsingHaloLayer *haloLayer;

@property (assign , nonatomic) NSInteger locateTimes;
@end

@implementation KDSetSignInPointVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = ASLocalizedString(@"设置签到点");
    self.firstLoad = YES;
    _locateTimes = 0;
    self.searchingGeocode = NO;
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    CGFloat distance = [NSNumber kdDistance1]/2;
    [self setBackItem];
    self.navigationController.navigationBar.translucent = NO;

    _locationManager = [[KDSignInLocationManager alloc] init];
    _reGeocodeManager = [[KDSignInLocationManager alloc] init];
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        self.cllocationManager = [[CLLocationManager alloc] init];
        [self.cllocationManager requestWhenInUseAuthorization];
    }
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = NO;
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
    [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    [self.mapView setZoomLevel:16.1 animated:YES];
    [self.view insertSubview:self.mapView atIndex:0];
    
    [self.view addSubview:self.locationButton];
    self.locationButton.center = CGPointMake(CGRectGetMidX(self.locationButton.bounds) + 10, self.view.bounds.size.height - CGRectGetMidY(self.locationButton.bounds) - 20);
    
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(distance, distance, CGRectGetWidth(self.view.frame) - distance*2, 48)];
    _searchView.backgroundColor = UIColorFromRGB(0xffffff);
    _searchView.layer.cornerRadius = 3;
    _searchView.layer.borderWidth = 1;
    _searchView.layer.borderColor = UIColorFromRGB(0xd1d4d8).CGColor;
    [self.view addSubview:_searchView];
    
    [_searchView makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.mas_equalTo(self.view).with.offset(distance);
        make.right.mas_equalTo(self.view).with.offset(-distance);
        make.height.mas_equalTo(48);
    }];
    
    _locateName = [[UILabel alloc] initWithFrame:CGRectMake(0, distance, CGRectGetWidth(_searchView.frame), 15)];
    _locateName.font = FS4;
    _locateName.textColor = FC5;
    _locateName.textAlignment = NSTextAlignmentCenter;
    [self.searchView addSubview:_locateName];
    
    [_locateName makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_searchView);
        make.left.and.right.mas_equalTo(_searchView).with.offset(0);
        make.top.mas_equalTo(_searchView).with.offset(distance);
    }];
    
    _locateAddress = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_locateName.frame) + distance, CGRectGetWidth(_searchView.frame), 15)];
    _locateAddress.font = FS7;
    _locateAddress.textAlignment = NSTextAlignmentCenter;
    _locateAddress.textColor = FC3;
    [self.searchView addSubview:_locateAddress];
    
    [_locateAddress makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_searchView);
        make.left.and.right.mas_equalTo(_searchView).with.offset(0);
        make.top.mas_equalTo(_locateName.bottom).with.offset(distance);
    }];
    
    UIImageView *searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 12, 12)];
    searchImage.image = [UIImage imageNamed:@"search_bar_btn_search"];
    SetCenterY(searchImage.center, CGRectGetHeight(_searchView.frame)/2);
    [self.searchView addSubview:searchImage];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSearchViewAction:)];
    [self.searchView addGestureRecognizer:tap];
    
    _paopaoView = [[SignInPaoPaoView alloc] init];
    [self.view addSubview:_paopaoView];
    
    _paopaoView.hidden = YES;
    UITapGestureRecognizer *tapPaoPao = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPaoPaoViewAction:)];
    [self.paopaoView addGestureRecognizer:tapPaoPao];
    
    //显示初始化
    if(self.tempLocationData)
    {
        [self searchReGeocodeDidSuccess:self.tempLocationData];
        [self.mapView setCenterCoordinate:self.tempLocationData.coordinate animated:NO];
        [self addMapPaoPaoView];
        [self updatePaoPaoViewFrame];
        [self performSelector:@selector(delaySetSearchingGeocodeNo) withObject:nil afterDelay:0.25];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(![self locationEnable]){
        NSString *msg = [NSString stringWithFormat:ASLocalizedString(@"打开“定位服务”允许“%@”确定你的位置"),KD_APPNAME];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"定位服务不可用") message:msg delegate:self cancelButtonTitle:ASLocalizedString(@"确认") otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBackItem {
    UIButton *button = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"取消")];
    [button setImage:nil forState:UIControlStateNormal];
    [button setImage:nil forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (BOOL)locationEnable{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted){
        return NO;
    }
    return YES;
}

- (void)addMapPaoPaoView{
    if(!self.locationData) return;
    _firstLoad = NO;
    self.haloLayer = [PulsingHaloLayer layer];
    self.haloLayer.haloLayerNumber = 3;
    self.haloLayer.animationDuration = 4;
    self.haloLayer.backgroundColor = [UIColor colorWithRed:0 green:0.46 blue:0.76 alpha:1].CGColor;
    [self.mapView.superview.layer insertSublayer:self.haloLayer above:self.mapView.layer];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sign_tip_locationlock"]];
    imageView.frame = CGRectMake(0, 0, 14, 16);
    imageView.tag = 103;
    [self.view addSubview:imageView];

    _paopaoView.hidden = NO;
    [self updatePaoPaoViewFrame];
}

- (void)updatePaoPaoViewFrame {
    CGPoint currentPoint = [self.mapView convertCoordinate:self.locationData.coordinate toPointToView:self.view];
    
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:103];
    if (imageView) {
        imageView.center = CGPointMake(self.view.center.x, currentPoint.y);
        self.haloLayer.position = imageView.center;
    }
    
    CGFloat perpoint = [self.mapView metersPerPointForCurrentZoomLevel];
    self.haloLayer.radius = (self.kdistance == 0 ? 200 : self.kdistance) /perpoint;
    
    [self removeHaloLayerAnimation];
    
    CGFloat y = Y(imageView.frame) - CGRectGetHeight(_paopaoView.frame) - 4;
    CGFloat x = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(_paopaoView.frame))/2.0;
    SetFrame(_paopaoView.frame, x, y, CGRectGetWidth(_paopaoView.frame), CGRectGetHeight(_paopaoView.frame));
    self.paopaoPoint = currentPoint;

}

#pragma mark - button method -
- (void)moveToUserCurrentLocation {
    if(self.mapView.userLocation.location) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:NO];
        [self.mapView setShowsUserLocation:NO];
    }
}

#pragma mark - Notification -
- (void)searchReGeocodeDidSuccess:(KDLocationData *)location {
    self.locationData = location;
    _locateName.text = _locationData.name;
    _locateAddress.text = _locationData.address;
}

- (void)searchReGeocodeDidFailed:(KDLocationData *)location faileType:(KDMapOperationType)type {
    _locateName.text = ASLocalizedString(@"无法获取当前地址名称");
    _locateAddress.text = @"";
}


#pragma mark - Action -
- (void)tapSearchViewAction:(id)sender{
    if (!self.signInPointSearch) {
        self.signInPointSearch = [[KDSignPointPoiSearch alloc] initWithContentsController:self];
        self.signInPointSearch.signInPointSearchDelegate = self;
    }
    [self.signInPointSearch showSearchBar];
    [self.signInPointSearch.searchBar becomeFirstResponder];
    self.searchingGeocode = YES;
    [self.view sendSubviewToBack:self.mapView];
}



- (void)back:(id)sender {
    if (self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)tapPaoPaoViewAction:(id)sender{
    if (!self.locationData || self.locationData.name == nil || self.locationData.longAddress == nil) {
        return;
    }
    
    if (self.sourceType == SetSignInPointSource_addOrupdateSignInPointVC) {
        if (self.locationData && self.determineBlock) {
            self.determineBlock(self.locationData , self);
        }
        [self back:nil];
    }
    else {
        KDAddOrUpdateSignInPointController *controller = [[KDAddOrUpdateSignInPointController alloc] init];
        KDSignInPoint *signInPoint = [[KDSignInPoint alloc] init];
        signInPoint.lat = _locationData.coordinate.latitude;
        signInPoint.lng = _locationData.coordinate.longitude;
        signInPoint.positionName = _locationData.name;
        signInPoint.detailAddress = _locationData.longAddress;
        signInPoint.offset = 200;
        controller.signInPoint = signInPoint;
        controller.delegate = self;
        controller.sourceAttSetsStr = self.sourceAttSetsStr;
        controller.addOrUpdateSignInPointType = KDAddOrUpdateSignInPointType_add;
        controller.isFromSetSignInPointVC = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - KDSignInPointSearchDelegate

//签到迁移屏蔽，改成下面的代理
- (void)searchResultDidSelectedWithAMapTip:(AMapGeocode *)geocode{
    if (!geocode) {
        [KDPopup showHUDToast:ASLocalizedString(@"定位失败")];
        self.searchingGeocode = NO;
        return;
    }
    
    KDLocationData *data = [KDLocationData new];
    data.name = geocode.building;
    data.address = geocode.formattedAddress;
    data.district = geocode.district;
    data.coordinate = CLLocationCoordinate2DMake(geocode.location.latitude, geocode.location.longitude);
    self.locationData = data;
    
    [self.mapView setCenterCoordinate:self.locationData.coordinate animated:NO];
    [self searchReGeocodeWithLocationData:data];
    
    [self performSelector:@selector(delaySetSearchingGeocodeNo) withObject:nil afterDelay:0.25];
    if(_firstLoad){
        [self addMapPaoPaoView];
    }

}


- (void)didSelectCellWithAMapGeocode:(AMapGeocode *)mapGeocode name:(NSString *)name
{
    if (!mapGeocode) {
        [KDPopup showHUDToast:ASLocalizedString(@"定位失败")];
        self.searchingGeocode = NO;
        return;
    }
    
    KDLocationData *data = [KDLocationData new];
    data.name = name;
    data.address = mapGeocode.formattedAddress;
    data.district = mapGeocode.district;
    data.coordinate = CLLocationCoordinate2DMake(mapGeocode.location.latitude, mapGeocode.location.longitude);
    self.locationData = data;
    
    [self.mapView setCenterCoordinate:self.locationData.coordinate animated:NO];
    [self searchReGeocodeWithLocationData:data];
    
    [self performSelector:@selector(delaySetSearchingGeocodeNo) withObject:nil afterDelay:0.25];
    if(_firstLoad){
        [self addMapPaoPaoView];
    }
}

//保证didSelectCellWithAMapGeocode之后不会调用regionDidChangeAnimated方法，直接通过select之后的locationData来逆地址编码
- (void)delaySetSearchingGeocodeNo{
    self.searchingGeocode = NO;
}


- (void)searchReGeocodeWithLocationData:(KDLocationData *)locationData {
    if (!locationData) return ;
    __weak KDSetSignInPointVC *weak_self = self;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:_locationData.coordinate.latitude longitude:_locationData.coordinate.longitude];
    [self.reGeocodeManager startReGeocodeSearchWithLocation:location SuccessBlock:^(KDLocationData *locationData, KDMapOperationType type) {
        [weak_self searchReGeocodeDidSuccess:locationData];
    } failuredBlock:^(KDLocationData *locationData, KDMapOperationType type) {
        [weak_self searchReGeocodeDidFailed:locationData faileType:type];
    }];

}

#pragma mark - MAMapViewDelegate -

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if(self.locationData && !_searchingGeocode){
        CLLocationCoordinate2D location = [self.mapView convertPoint:self.paopaoPoint toCoordinateFromView:self.view];
        KDLocationData *locateData = [KDLocationData locationDataByCoordiante:location];
        self.locationData = locateData;
        [self searchReGeocodeWithLocationData:locateData];
        
        //屏幕距离转真实距离
        CGFloat perpoint = [self.mapView metersPerPointForCurrentZoomLevel];
        CGFloat distancex = (self.kdistance == 0 ? 200 : self.kdistance) / perpoint;
        if (distancex != self.haloLayer.radius) {
            self.haloLayer.radius = distancex;
            [self.haloLayer replicateEffectRefrence];
            self.haloLayer.animationDuration = 4;
            [self removeHaloLayerAnimation];
        }
    }
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation{
    _locateTimes ++;
    if (_locateTimes <= MaxLocationtimes && !self.tempLocationData) {
        self.locationData = [KDLocationData locationDataByCoordiante:userLocation.coordinate];
        if (_firstLoad){
            [self addMapPaoPaoView];
        }
        else {
            [self updatePaoPaoViewFrame];
            if (_locateTimes == MaxLocationtimes) {
                [self.mapView setShowsUserLocation:NO];
            }
        }
    }
}

- (void)removeHaloLayerAnimation {
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.haloLayer removeAllEffectAnimationWithDistance:self.haloLayer.radius];
    });
}

#pragma mark - KDAddOrUpdateSignInPointControllerDelegate -
- (void)addOrUpdateSignInPointSuccess:(KDSignInPoint *)signInPoint signInPointType:(KDAddOrUpdateSignInPointType)signInPointType rowIndex:(NSInteger)index {
    
    if (self.addOrUpdateSignInPointSuccessBlock) {
        self.addOrUpdateSignInPointSuccessBlock(signInPoint, signInPointType);
    }
    
}

#pragma mark - getter -
- (UIButton *)locationButton {
    if (!_locationButton) {
        _locationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _locationButton.backgroundColor = [UIColor whiteColor];
        _locationButton.layer.cornerRadius = 4;
        _locationButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        [_locationButton setImage:[UIImage imageNamed:@"map_move_userLocation"] forState:UIControlStateNormal];
        [_locationButton addTarget:self action:@selector(moveToUserCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    }
    return _locationButton;
}

@end
