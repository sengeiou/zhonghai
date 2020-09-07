//
//  KDLocationOptionViewController.m
//  kdweibo
//
//  Created by Tan yingqi on 13-2-21.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDLocationOptionViewController.h"
#import "KDAddOrUpdateSignInPointController.h"

#import "KDLocationTableViewCell.h"
#import "MJRefresh.h"
#import "KDLocationOptionSearchBar.h"

#import "KDSignInLocationManager.h"
#import "KDSignInPoint.h"

@interface KDLocationOptionViewController () <MAMapViewDelegate,KDRefreshTableViewDataSource,KDRefreshTableViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) KDLocationOptionSearchBar *searchBar;

@property (nonatomic, strong) CLLocationManager *cllocationManager;
@property (nonatomic, strong) KDSignInLocationManager *poiManager;

@property (assign, nonatomic) NSInteger pageIndex;
@property (assign, nonatomic) NSTimeInterval beginTimeInterval;


@end

@implementation KDLocationOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationStyleBlue];
    
    self.title = ASLocalizedString(@"位置选择");
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    //[self setNavigationStyle:KDNavigationStyleBlue];
    
    self.pageIndex = 0;
    
    [self setUpView];
    
    if (self.optionsArray && self.optionsArray.count >= 20) {
        self.pageIndex = 1;
        [self.tableView setBottomViewHidden:NO];
    }
    else {
        [self.tableView setBottomViewHidden:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self loadMapView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    [self.mapView setZoomLevel:16.1 animated:YES];
    _beginTimeInterval = [[NSDate date] timeIntervalSince1970];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    self.mapView.delegate = nil;
    [self.mapView removeFromSuperview];
    if (_poiManager) {
        [_poiManager stopOpration];
    }
}

#pragma mark - set up view -
- (void)setUpView {
    //tableView
    _tableView = [[KDRefreshTableView alloc] initWithFrame:CGRectMake(0, 177 + 44, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-177-64 - ( (self.shouldHideBottomView) ? 0 : 40) - 44 ) kdRefreshTableViewType:KDRefreshTableViewType_Footer style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 60;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    //mapView
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectZero];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        self.cllocationManager = [[CLLocationManager alloc] init];
        [self.cllocationManager requestWhenInUseAuthorization];
    }
    
    //searchBar
    __weak KDLocationOptionViewController *weak_self = self;
    _searchBar = [[KDLocationOptionSearchBar alloc] initWithContentsController:self locationData:self.locationData];
    _searchBar.sourceData = self.optionsArray;
    _searchBar.selectedBlock = ^(NSObject *obj , NSIndexPath *index) {
        if ([obj isKindOfClass:[KDLocationData class]]) {
            KDLocationData *location = (KDLocationData *)obj;
            if (weak_self.delegate && [weak_self.delegate respondsToSelector:@selector(determineLocation:viewController:beginTimeInterval:)]) {
                [weak_self.delegate determineLocation:location viewController:weak_self beginTimeInterval:weak_self.beginTimeInterval];
            }
            [weak_self dismissSelf];
        }
    };
    [_searchBar.searchBar setCustomPlaceholder:ASLocalizedString(@"查找附近公司、写字楼")];
    
    //backItem
    [self setBackItem];
    
    //buttomView
    if (!self.shouldHideBottomView) {
        [self setBottomView];
    }
    
    //navigationRightItem
    if (self.locationData) {
        [self setNavigationRightItem];
    }
}

- (void)loadMapView {
    self.mapView.frame = CGRectMake(0, 44, CGRectGetWidth(self.view.frame), 177 + 64);
    self.mapView.delegate = self;
    [self.view insertSubview:self.mapView atIndex:0];
}

- (void)setNavigationRightItem {
    UIButton *button = [UIButton blueBtnWithTitle:ASLocalizedString(@"确定")];
    [button addTarget:self action:@selector(whenDoneBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)setBottomView {
    UIButton *btn = [UIButton whiteBtnWithTitle:ASLocalizedString(@"找不到我的位置，使用拍照签到")];
    btn.layer.borderColor = [UIColor kdDividingLineColor].CGColor;
    btn.layer.borderWidth = 0.5;
    [btn setTitleColor:FC5 forState:UIControlStateNormal];
    [btn.titleLabel setFont:FS3];
    btn.frame = CGRectMake(0, CGRectGetMaxY(self.tableView.frame), ScreenFullWidth, 40);
    [btn addTarget:self action:@selector(whenPhotoSignInBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)addAnnotation {
    if (self.locationData) {
        CLLocationCoordinate2D center = self.locationData.coordinate;
        MAPointAnnotation *pointAnnoation = [[MAPointAnnotation alloc] init];
        pointAnnoation.coordinate = center;
        pointAnnoation.title = ASLocalizedString(@"当前位置");
        [self.mapView addAnnotations:@[pointAnnoation]];
    }
}

- (void)setTableFootView{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth, 40)];
    footView.backgroundColor = self.view.backgroundColor;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = ASLocalizedString(@"已无更多位置");
    titleLabel.font = FS7;
    titleLabel.textColor = FC3;
    
    titleLabel.frame = CGRectMake(0, 9, ScreenFullWidth, 22);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [footView addSubview:titleLabel];
    
    [self.tableView setTableFooterView:footView];
}

- (void)setBackItem {
    UIButton *button = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"取消")];
    [button setImage:nil forState:UIControlStateNormal];
    [button setImage:nil forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

#pragma mark - method -
- (void)loadMoreData:(BOOL)isLoadMore {
    if (isLoadMore) {
        self.pageIndex ++;
        __weak KDLocationOptionViewController *weakSelf = self;
        [self.poiManager doPoiSearchWithOffset:20 page:self.pageIndex radius:250 location:[[CLLocation alloc] initWithLatitude:self.locationData.coordinate.latitude longitude:self.locationData.coordinate.longitude] keyword:nil successBlock:^(NSArray *pois, KDMapOperationType type) {
            NSMutableArray *array  = [NSMutableArray new];
            if(weakSelf.optionsArray && weakSelf.optionsArray.count>0)
            {
                [array addObjectsFromArray:weakSelf.optionsArray];
            }
            if(pois && pois.count>0)
            {
                [array addObjectsFromArray:pois];
            }
            weakSelf.optionsArray = array;
            weakSelf.searchBar.sourceData = array;
            
            if (weakSelf.pageIndex*20 > weakSelf.optionsArray.count) {
                [weakSelf.tableView setBottomViewHidden:YES];
                
                [weakSelf setTableFootView];
            }
            [weakSelf.tableView finishedLoadMore];
            [weakSelf.tableView reloadData];
        } failuredBlock:^(NSArray *pois, KDMapOperationType type) {
            [weakSelf.tableView finishedLoadMore];
            [weakSelf.tableView reloadData];
            [self.tableView setBottomViewHidden:YES];
            
            [weakSelf setTableFootView];
        } isNeedReGeoCode:NO];
    }
    else {
        self.pageIndex = 1;
    }
}

- (void)back:(id)sender {
    [self dismissSelf];
}

- (void)whenDoneBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(determineLocation:
                                                             viewController:beginTimeInterval:)]) {
        [_delegate determineLocation:self.locationData viewController:self beginTimeInterval:_beginTimeInterval];
    }
    [self dismissSelf];
}

- (void)dismissSelf {
    if (self.navigationController.viewControllers.count == 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)whenPhotoSignInBtnClicked:(id)sender {
//    [KDEventAnalysis event:event_signin_rectification];
    [self dismissViewControllerAnimated:NO completion:^{
        if(self.locationOptionPhotoSignInBlock) {
            self.locationOptionPhotoSignInBlock();
        }
    }];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.optionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    KDLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KDLocationTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    KDLocationData *data = [self.optionsArray objectAtIndex:indexPath.row];
    if (data == self.locationData) {
        [cell.accessoryImageView setImage:[UIImage imageNamed:@"task_editor_finish"]];
    } else {
        [cell.accessoryImageView setImage:nil];
    }
    cell.label.text = data.name;
    cell.subLabel.text = data.longAddress;
    cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KDLocationData *data = [self.optionsArray objectAtIndex:indexPath.row];
    if(data != self.locationData){
        self.locationData = data;
        [tableView reloadData];
    }
}

#pragma mark - MAMapViewDelegate -
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = YES;
            annotationView.draggable = YES;
            
        }
        else {
            annotationView.annotation = annotation;
        }
        
        annotationView.pinColor = MAPinAnnotationColorRed;
        
        return annotationView;
    }
    
    return nil;
}

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        CLLocation *newLocation = userLocation.location;
        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        if (locationAge > 5.0) {return;}
        if (newLocation.horizontalAccuracy < 0) {return;}
        if(newLocation.horizontalAccuracy < 100){
            CLLocationCoordinate2D myCoordinate = [newLocation coordinate];
            self.mapView.showsUserLocation = NO;
            MAPointAnnotation *pointAnnoation = [[MAPointAnnotation alloc] init];
            pointAnnoation.coordinate = myCoordinate;
            pointAnnoation.title = ASLocalizedString(@"当前位置");
            [self.mapView addAnnotations:@[pointAnnoation]];
        }
    }
}

#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_tableView) {
        [_tableView kdRefreshTableViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_tableView) {
        [_tableView kdRefreshTableviewDidEndDraging:scrollView];
    }
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    [self loadMoreData:YES];
}

#pragma mark - getter -
- (KDSignInLocationManager *)poiManager {
    if (!_poiManager) {
        _poiManager = [[KDSignInLocationManager alloc] init];
    }
    return _poiManager;
}


- (void)setNavigationStyleBlue{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController.navigationBar setBarTintColor:FC5];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS1}];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"app_img_backgroud"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 21, 0, 21)] forBarMetrics:UIBarMetricsDefault];
}

@end
