//
//  KDMapViewController.m
//  kdweibo
//
//  Created by Tan YingQi on 13-3-10.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDMapViewController.h"

@interface KDMapViewController ()<MAMapViewDelegate>
{
    UIImageView *_bgImageView;
    UILabel *_locationInfo;
}

@end

@implementation KDMapViewController
@synthesize mapView = mapView_;
@synthesize obj = obj_;

- (CGFloat)latitude {
    if(obj_ && [obj_ respondsToSelector:@selector(latitude)]) {
        return [obj_ latitude];
    }
    
    return _data.latitude;
}

- (CGFloat)longitude {
    if(obj_ && [obj_ respondsToSelector:@selector(longitude)]) {
        return [obj_ longitude];
    }
    
    return _data.longitude;
}

- (NSString *)address {
    if(obj_ && [obj_ respondsToSelector:@selector(address)]) {
        return [obj_ address];
    }
    
    return _data.address;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = ASLocalizedString(@"XTChatViewController_Tip_4");
    [self setBackItem];
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectZero];// autorelease];
    
    _bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, ScreenFullHeight - 60, ScreenFullWidth, 60)];
    _bgImageView.image = [UIImage imageNamed:@"locationBg"];
    [self.mapView addSubview:_bgImageView];
    
    _locationInfo = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, _bgImageView.frame.size.width - 20, 60)];
    _locationInfo.lineBreakMode  = UILineBreakModeWordWrap;
    _locationInfo.numberOfLines = 0;
    _locationInfo.textColor = [UIColor whiteColor];
    _locationInfo.font = [UIFont systemFontOfSize:16.f];
    _locationInfo.textAlignment = NSTextAlignmentLeft;
    _locationInfo.backgroundColor = [UIColor clearColor];
    [_bgImageView addSubview:_locationInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.mapView.frame = self.view.bounds;
    
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
    
    /* Remove from view hierarchy. */
    [self.mapView removeFromSuperview];
}

- (void)back:(id)sender {
//    [self dismissSelf];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissSelf {
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setCenterRegion {
    CLLocationCoordinate2D center = {[self latitude],[self longitude]};
    if (_data != nil) {
        center = (CLLocationCoordinate2D){_data.latitude, _data.longitude};
    }
    MACoordinateSpan span = {0.004,0.004};
    
    MACoordinateRegion rrr;
    rrr.center=center;
    rrr.span=span;
    [mapView_ setRegion:rrr animated:NO];
    [mapView_ setCenterCoordinate:center];
}
- (void)addAnnotation {
    
    // MAPOI *currentPOI = [optionsArray_ objectAtIndex:0];
    
    CLLocationCoordinate2D center = {[self latitude],[self longitude]};
    if (_data != nil) {
         center = (CLLocationCoordinate2D){_data.latitude, _data.longitude};
    }
    MAPointAnnotation* placeMark=[[MAPointAnnotation alloc] init];
    placeMark.coordinate=center;
    placeMark.title = [self address];
    _locationInfo.text = [self address];
    [mapView_ addAnnotation:placeMark];
//    [placeMark release];
}

- (void)setBackItem {
    UIButton *btn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setCenterRegion];
    [self performSelector:@selector(addAnnotation) withObject:nil afterDelay:0.5];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];// autorelease];
            
            annotationView.canShowCallout            = YES;
            annotationView.animatesDrop              = YES;
            annotationView.draggable                 = YES;
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [mapView_ removeAnnotations:mapView_.annotations];
}

// for ios 5 and earlier
- (void)viewDidUnload {
    [super viewDidUnload];
    //KD_RELEASE_SAFELY(mapView_);
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(obj_);
    //KD_RELEASE_SAFELY(mapView_);
    //[super dealloc];
}
@end
