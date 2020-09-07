//
//  KDSendViewController.m
//  kdweibo
//
//  Created by wenjie_lee on 16/2/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSendViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <MAMapKit/MAPointAnnotation.h>
//#import <AMapSearchKit/AMapSearchKit.h>
#import "KDPlaceAroundTableView.h"

@interface KDSendViewController ()<MAMapViewDelegate,KDPlaceAroundTableViewDeleagate>

@property (nonatomic, strong) MAMapView            *mapView;
@property (nonatomic, strong) AMapSearchAPI        *mapSearch;

@property (nonatomic, strong) KDPlaceAroundTableView *tableview;
@property (nonatomic, strong) UIImageView          *redWaterView;
@property (nonatomic, assign) BOOL                  isMapViewRegionChangedFromTableView;

@property (nonatomic, assign) BOOL                  isLocated;

@property (nonatomic, strong) UIButton             *locationBtn;
@property (nonatomic, strong) UIImage              *imageLocated;
@property (nonatomic, strong) UIImage              *imageNotLocate;

@property (nonatomic, assign) NSInteger             searchPage;

@property (nonatomic, strong) AMapPOI              *currentPoi;

@property (nonatomic) CLLocationCoordinate2D    currentCoordinate;

@end

@implementation KDSendViewController

#pragma mark - Utility

/* 根据中心点坐标来搜周边的POI. */
- (void)searchPoiByCenterCoordinate:(CLLocationCoordinate2D )coord
{
    AMapPlaceSearchRequest*request = [[AMapPlaceSearchRequest alloc] init];
    
    request.location = [AMapGeoPoint locationWithLatitude:coord.latitude  longitude:coord.longitude];
    
    
    request.searchType          = AMapSearchType_PlaceAround;
//    request.location            = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    request.types = @[ASLocalizedString(@"汽车服务"),ASLocalizedString(@"汽车销售"),ASLocalizedString(@"汽车维修"),ASLocalizedString(@"摩托车服务"),ASLocalizedString(@"餐饮服务"),ASLocalizedString(@"购物服务"),ASLocalizedString(@"生活服务"),ASLocalizedString(@"体育休闲服务"),ASLocalizedString(@"医疗保健服务"),ASLocalizedString(@"住宿服务"),ASLocalizedString(@"风景名胜"),ASLocalizedString(@"商务住宅"),ASLocalizedString(@"政府机构及社会团体"),ASLocalizedString(@"科教文化服务"),ASLocalizedString(@"交通设施服务"),ASLocalizedString(@"金融保险服务"),ASLocalizedString(@"金融保险服务"),ASLocalizedString(@"公司企业"),ASLocalizedString(@"道路附属设施"),ASLocalizedString(@"地名地址信息"),ASLocalizedString(@"公共设施")];
    //        request.keywords = ASLocalizedString(@"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施");
    /* 按照距离排序. */
    request.sortrule            = 1;
    request.requireExtension    = YES;
    request.offset              = 60;
    request.radius              = 1000;

    
    request.sortrule = 1;
    request.page     = self.searchPage;
    
    [self.mapSearch AMapPlaceSearch:request];
}

- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;
    
    [self.mapSearch AMapReGoecodeSearch:regeo];
}

#pragma mark - MapViewDelegate

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (!self.isMapViewRegionChangedFromTableView && self.mapView.userTrackingMode == MAUserTrackingModeNone)
    {
        if (self.isLocated)
        {
//            self.isLocated = YES;
//            [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude)];
            [self searchReGeocodeWithCoordinate:self.mapView.centerCoordinate];
            [self searchPoiByCenterCoordinate:self.mapView.centerCoordinate];
            
            self.searchPage = 1;
            [self redWaterAnimimate];
            
        }
    }
    self.isMapViewRegionChangedFromTableView = NO;
}

#pragma mark - TableViewDelegate

- (void)didTableViewSelectedChanged:(AMapPOI *)selectedPoi
{
    // 防止连续点两次
    if(self.isMapViewRegionChangedFromTableView == YES)
    {
        return;
    }
    
    self.currentPoi = selectedPoi;
    self.isMapViewRegionChangedFromTableView = YES;
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(selectedPoi.location.latitude, selectedPoi.location.longitude);
    
    [self.mapView setCenterCoordinate:location animated:YES];
    
}

- (void)didPositionCellTapped:(AMapPOI *)selectedPoi
{
    // 防止连续点两次
    if(self.isMapViewRegionChangedFromTableView == YES)
    {
        return;
    }
    
    self.currentPoi = selectedPoi;
    self.isMapViewRegionChangedFromTableView = YES;
    
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    
}

- (void)didLoadMorePOIButtonTapped
{
    self.searchPage++;
    [self searchPoiByCenterCoordinate:self.mapView.centerCoordinate];
}

#pragma mark - userLocation

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (userLocation.coordinate.latitude == 0.00000 && userLocation.coordinate.longitude == 0.0000) {
        return;
    }
    if(!updatingLocation)
        return ;
    
    if (userLocation.location.horizontalAccuracy < 0)
    {
        return ;
    }
    
    // only the first locate used.
    if (!self.isLocated)
    {
        self.isLocated = YES;
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude)];
        [self searchReGeocodeWithCoordinate:self.mapView.centerCoordinate];
        [self searchPoiByCenterCoordinate:self.mapView.centerCoordinate];
        
        self.searchPage = 1;
        [self redWaterAnimimate];
        
    }
    MAAnnotationView *userAnnotationView = [self.mapView viewForAnnotation:self.mapView.userLocation];
    if(userAnnotationView)
        userAnnotationView.canShowCallout = NO;
}

- (void)mapView:(MAMapView *)mapView  didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
//    if (mode == MAUserTrackingModeNone)
//    {
        [self.locationBtn setImage:[UIImage imageNamed:@"gpsnormal"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        [self.locationBtn setImage:self.imageLocated forState:UIControlStateNormal];
//    }
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"error = %@",error);
}

#pragma mark - Handle Action

- (void)actionLocation
{
//    [self.locationBtn setImage:self.imageLocated forState:UIControlStateNormal];
    if (self.mapView.userTrackingMode == MAUserTrackingModeFollow)
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];
    }
    else
    {
        self.searchPage = 1;
        
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            // 因为下面这句的动画有bug，所以要延迟0.5s执行，动画由上一句产生
            [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
        });
    }
}

#pragma mark - Initialization

- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 63, CGRectGetWidth(self.view.bounds), self.view.bounds.size.height/2 - 84)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
//    self.mapView.rotateCameraEnabled = NO;
    self.mapView.zoomLevel = 17;
    self.mapView.showsUserLocation = YES;
    [self.view addSubview:self.mapView];
    
    self.isLocated = NO;
}

- (void)initSearch
{
    self.searchPage = 1;

    self.mapSearch = [[AMapSearchAPI alloc] initWithSearchKey:GAODE_MAP_KEY_IPHONE Delegate:nil];
    self.mapSearch.delegate = self.tableview;
}

- (void)initTableview
{
    CGRect frame = self.view.bounds;
    frame.size.height = CGRectGetHeight(self.mapView.frame);
    
    frame.origin.y = frame.size.height+64;
    self.tableview = [[KDPlaceAroundTableView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2 - 84, ScreenFullWidth, self.view.bounds.size.height/2 + 84)];
    self.tableview.delegate = self;
    
    [self.view addSubview:self.tableview];
}

- (void)initRedWaterView
{
    UIImage *image = [UIImage imageNamed:@"redPin"];
    self.redWaterView = [[UIImageView alloc] initWithImage:image];
    
    self.redWaterView.frame = CGRectMake(self.view.bounds.size.width/2-image.size.width/2, self.mapView.bounds.size.height/2-image.size.height, image.size.width, image.size.height);
    
    self.redWaterView.center =self.mapView.center;
    
    [self.view addSubview:self.redWaterView];
}

- (void)initLocationButton
{
    self.imageNotLocate = [UIImage imageNamed:@"gpsnormal"];
    
    self.locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.mapView.bounds)*0.85, CGRectGetHeight(self.mapView.bounds)*0.9 + 40, 40, 40)];
    self.locationBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.locationBtn.backgroundColor = [UIColor clearColor];
    self.locationBtn.layer.cornerRadius = 3;
    [self.locationBtn addTarget:self action:@selector(actionLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
//    [self.locationBtn setImage:self.imageNotLocate forState:uicon];
//    [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateSelected];
    [self.view addSubview:self.locationBtn];
}

/* 移动窗口弹一下的动画 */
- (void)redWaterAnimimate
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGPoint center = self.redWaterView.center;
                         center.y -= 30;
                         [self.redWaterView setCenter:center];}
                     completion:nil];
    
    [UIView animateWithDuration:0.45
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGPoint center = self.redWaterView.center;
                         center.y += 30;
                         [self.redWaterView setCenter:center];}
                     completion:nil];
}
- (void)setRightItem
{
    UIButton *button = [UIButton blueBtnWithTitle:ASLocalizedString(@"Global_Send")];
    [button setCircle];
    [button addTarget:self action:@selector(sendLocation:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItems = [NSArray
                                                   arrayWithObjects:sendItem, nil];
}
- (void)sendLocation:(id)sender
{
    KDLocationData *currentLocationData = [KDLocationData locationDataByMapPOI:self.currentPoi];
    CGFloat width = 220 ;
    CGFloat height = 150;
    CGRect inRect = CGRectMake(ScreenFullWidth/2 - 110,self.mapView.bounds.size.height / 2 - 75,width,height);
  
    //截图前把标注加上去
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(currentLocationData.coordinate.latitude, currentLocationData.coordinate.longitude);
    // 选中标注
    [self.mapView addAnnotation:annotation];
    [self.redWaterView removeFromSuperview];
    self.mapView.showsUserLocation = NO;
    currentLocationData.selfIMG = [self.mapView takeSnapshotInRect:inRect];
    if ([_delegate respondsToSelector:@selector(sendLocation:)]) {
        
        [self  dismissViewControllerAnimated:YES completion:nil];
        [_delegate sendLocation:currentLocationData];
    }
}
#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAMapPOI:) name:@"AMapPOI" object:nil];
    
    [self setBackItem];
    [self setRightItem];
    
    [self initTableview];
    
    [self initSearch];
    [self initMapView];
    
    [self initRedWaterView];
    
    [self initLocationButton];

}
- (void)setBackItem {
    UIButton *btn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn]];
}
- (void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setAMapPOI:(NSNotification *)data
{
    NSDictionary *dic = [data userInfo];
    self.currentPoi = [dic objectForKey:@"data"];
}


@end
