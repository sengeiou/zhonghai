//
//  adressViewController.m
//  kdweibo
//
//  Created by mark on 8/18/14.
//  Copyright (c) 2014 www.kingdee.com. All rights reserved.
//

#import "adressViewController.h"

#import "KDLocationOptionViewController.h"
#import "KDLocationManager.h"
#import "KDLocationData.h"
#import "UIImage+Additions.h"
#import "KDPicturePickedPreviewViewController.h"

#import "KDWeiboAppDelegate.h"
#import "UIView+Blur.h"
#import "KDLocationTableViewCell.h"

@interface adressViewController () <UITableViewDataSource,UITableViewDelegate,MAMapViewDelegate>
@property(nonatomic,retain)MAMapView *mapView;

@end

@implementation adressViewController
@synthesize locationDataArray = _locationDataArray;
@synthesize currentLocationData = _currentLocationData;
@synthesize mapView = mapView_;
@synthesize tableView = tableView_;
@synthesize delegate = delegate_;
@synthesize shouldHideDeleteLocationBtn = shouldHideDeleteLocationBtn_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = ASLocalizedString(@"adressViewController_Choose");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidSucess:) name:KDNotificationLocationSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFailed:) name:KDNotificationLocationFailed object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidInit:) name:KDNotificationLocationInit object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidstart:) name:KDNotificationLocationStart object:nil];
    }
    return self;
}

- (void)dealloc
{
    //[super dealloc];
//    [_locationDataArray release];
//    [_currentLocationData release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationFailed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationInit object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationStart object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self enablesLocation];
    
    ///////////////////////////////////////
    self.view.backgroundColor = MESSAGE_BG_COLOR;
    CGRect frame = self.view.bounds;
    frame.size.height = 105;
    
    frame.origin.y = frame.size.height;
    frame.size.height = self.view.bounds.size.height - frame.size.height;
    tableView_ = [[UITableView alloc] initWithFrame:frame];
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    tableView_.rowHeight = 60;
    [self.view addSubview:tableView_];
    self.navigationItem.title = ASLocalizedString(@"adressViewController_Choose");
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectZero]; //autorelease];
    
    [self setRightItem];
}

//定位
- (void)enablesLocation {
    //[[KDLocationManager globalLocationManager] setDelegate:self];
    [[KDLocationManager globalLocationManager] setLocationType:KDLocationTypeNormal];
    [[KDLocationManager globalLocationManager] startLocating];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Location notification
////////////////////////////////////////////////////////////
- (void)locationDidSucess:(NSNotification *)notifcation {
    DLog(@"notificationSucess received");
    NSDictionary *info = notifcation.userInfo;
    NSArray *array = [info objectForKey:@"locationArray"];
    self.locationDataArray = array;
    self.currentLocationData = [array objectAtIndex:0];
}

- (void)locationDidFailed:(NSNotification *)notifcation {
    //[self.locationView showErrowMessage];
}

//locationInit
- (void)locationDidInit:(NSNotification *)notifcation {
    //[self.locationView showInitMessag];
}
- (void)locationDidstart:(NSNotification *)notifcation {
    //[self.locationView showStartMessage];
}

#pragma mark -
#pragma mark KDLocationOptionViewController delegate methods
- (void)determineLocation:(KDLocationData *)locationData viewController:(KDLocationOptionViewController *)viewController {
    self.currentLocationData = locationData;
}

- (void)deleteCurrentLocationData {
    self.currentLocationData = nil;
}

- (void)setCurrentLocationData:(KDLocationData *)currentLocationData {
    if (_currentLocationData != currentLocationData) {
//        [_currentLocationData release];
        _currentLocationData = currentLocationData;// retain];
    }
    NSLog(@"%@",_currentLocationData.name);
}


- (void)loadMapView {
    CGRect frame = self.view.bounds;
    frame.size.height = 105;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
        frame.origin.y = 0.0f;
    }
    self.mapView.frame = frame;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
}

- (void)setCenterRegion {
    if (_currentLocationData) {
        KDLocationData *data = _currentLocationData;
        CLLocationCoordinate2D center = data.coordinate;
        MACoordinateSpan span = {0.004,0.004};
        
        MACoordinateRegion rrr;
        rrr.center=center;
        rrr.span=span;
        [mapView_ setRegion:rrr animated:NO];
        [mapView_ setCenterCoordinate:center animated:YES];
    }
    
}
- (void)addAnnotation {
    
    // KDLocationData *data = [optionsArray_ objectAtIndex:0];
    if (_currentLocationData) {
        CLLocationCoordinate2D center = _currentLocationData.coordinate;
        
        MAPointAnnotation* pointAnnoation=[[MAPointAnnotation alloc] init];
        pointAnnoation.coordinate=center;
        pointAnnoation.title = ASLocalizedString(@"KDLocationOptionViewController_cur_location");
        [self.mapView addAnnotations:@[pointAnnoation]];
//        [pointAnnoation release];
    }
    
}

//- (void)removeOldAnnotations {
//    if (mapView_.annotations) {
//        [mapView_ removeAnnotations:mapView_.annotations];
//    }
//}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadMapView];
    
    //[self removeOldAnnotations];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
    
    /* Remove from view hierarchy. */
    [self.mapView removeFromSuperview];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setCenterRegion];
    [self addAnnotation];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_locationDataArray count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    KDLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[KDLocationTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];// autorelease];
        
    }
    
    KDLocationData *data = [_locationDataArray  objectAtIndex:indexPath.row];
    if (data == _currentLocationData) {
        [cell.accessoryImageView setImage:[UIImage imageNamed:@"icon_tick_blue.png"]];
    }else {
        [cell.accessoryImageView setImage:nil];
    }
    cell.label.text = data.name;
    cell.subLabel.text = data.longAddress;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    KDLocationData *data = [_locationDataArray objectAtIndex:indexPath.row];
//    if (delegate_ && [delegate_ respondsToSelector:@selector(determineLocation:
//                                                             viewController:)]) {
//        [delegate_ determineLocation:data viewController:self];
//    }
//    // [self.navigationController popViewControllerAnimated:YES];
//    [self dismissSelf];
}

- (void)dismissSelf {
    if (self.navigationController.viewControllers[0] == self) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)back:(id)sender {
    [self dismissSelf];
//    if ([self.delegate respondsToSelector:@selector(backToPreView)]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.delegate backToPreView];
//        });
//    }
}

- (void)deleteLocation:(id)sender {
//    if (delegate_ && [delegate_ respondsToSelector:@selector(deleteCurrentLocationData)]) {
//        [delegate_ deleteCurrentLocationData];
//    }
    [self dismissSelf];
}
- (void)setRightItem {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:ASLocalizedString(@"adressViewController_Send")forState:UIControlStateNormal];
    [button sizeToFit];
    //修正超过两个字时，显示不全bug 王松 2013-12-03
    CGFloat titltWidth = CGRectGetWidth(button.titleLabel.frame) - 5.f;
    CGFloat imageWidth = CGRectGetWidth(button.imageView.frame) + 6.f;
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, titltWidth, 0, -titltWidth)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth)];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button sizeToFit];
    [button addTarget:self action:@selector(deleteLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //song.wang 2013-12-26
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];// autorelease];
    negativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,buttonItem, nil];
    
//    [buttonItem release];
    
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views{
	
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier] ;//autorelease];
            
            annotationView.canShowCallout            = YES;
            annotationView.animatesDrop              = YES;
            annotationView.draggable                 =  YES;
            
        }
        else
        {
            annotationView.annotation = annotation;
        }
        
        annotationView.pinColor = MAPinAnnotationColorRed;
        
        return annotationView;
    }
    
    return nil;
}


-(NSString*)keyForMap {
    return GAODE_MAP_KEY_IPHONE;
}

@end
