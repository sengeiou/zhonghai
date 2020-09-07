//
//  KDDMLocationSelectViewController.m
//  kdweibo
//
//  Created by shen kuikui on 13-5-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDDMLocationSelectViewController.h"
#import "KDLocationManager.h"

@interface KDDMLocationSelectViewController ()
{
    UIActivityIndicatorView *indicator_; //weak
}
@end

@implementation KDDMLocationSelectViewController
@synthesize hostViewController = _hostViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidSucess:) name:KDNotificationLocationSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFailed:) name:KDNotificationLocationFailed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidInit:) name:KDNotificationLocationInit object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidstart:) name:KDNotificationLocationStart object:nil];
    }
    return self;
}

- (void)dealloc {
    [[KDLocationManager globalLocationManager] disableLocating];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //[super dealloc];
}

- (void)setRightItem {
    UIImage *image = [UIImage imageNamed:@"navigationItem_title_arrow"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    
    [button setTitle:ASLocalizedString(@"Global_Sure")forState:UIControlStateNormal];
    [button setTitleColor:RGBCOLOR(161.f, 205.f, 255.f) forState:UIControlStateDisabled];
    [button sizeToFit];
    //修正超过两个字时，显示不全bug 王松 2013-12-03
    CGFloat titltWidth = CGRectGetWidth(button.titleLabel.frame) - 5.f;
    CGFloat imageWidth = CGRectGetWidth(button.imageView.frame) + 6.f;
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, titltWidth, 0, -titltWidth)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth)];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button sizeToFit];

    [button addTarget:self action:@selector(sendLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    buttonItem.enabled = NO;
    
    //2013-12-26 song.wang
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];// autorelease];
    negativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,buttonItem, nil];
//    [buttonItem release];
}

- (void)sendLocation:(id)sender {
    if(_hostViewController && [_hostViewController respondsToSelector:@selector(sendLocation:)]) {
        [_hostViewController sendLocation:self.locationData];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showActivityIndicatorView {
    if(indicator_ == nil) {
        indicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:indicator_];
//        [indicator_ release];
        
        indicator_.center = CGPointMake(self.view.bounds.size.width * 0.5f, self.view.bounds.size.height * 0.5f);
        
        [indicator_ startAnimating];
    }
}

- (void)dismissActivityIndicatorView {
    if(indicator_) {
        [indicator_ stopAnimating];
        [indicator_ removeFromSuperview];
        indicator_ = nil;
    }
}

#pragma mark -
#pragma mark Location notification
/////////////////////////////////////////////////////////////////////////////////////
- (void)locationDidSucess:(NSNotification *)notifcation {
    [self dismissActivityIndicatorView];
    
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi

    UIBarButtonItem *item = [[self.navigationItem rightBarButtonItems] lastObject];
    item.enabled = YES;
    DLog(@"notificationSucess received");
    NSDictionary *info = notifcation.userInfo;
    NSArray *array = [info objectForKey:@"locationArray"];
    self.optionsArray = array;
    self.locationData = [array objectAtIndex:0];
    
    [self.tableView reloadData];
    //签到迁移，暂时屏蔽
//    [self setCenterRegion];
//    [self addAnnotation];
}

- (void)locationDidFailed:(NSNotification *)notifcation {
    [self dismissActivityIndicatorView];
    NSString *message = ASLocalizedString(@"KDAddOrUpdateSignInPointController_tips_41");
    NSError *error = [[notifcation userInfo] objectForKey:@"error"];
    if ([error code] == KDLocationErrorLocatingTimeOut) {
        message = ASLocalizedString(@"KDDMLocationSelectViewController_location_over");
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDDMLocationSelectViewController_retry"), nil];
    [alert show];
//    [alert release];
}


- (void)locationDidInit:(NSNotification *)notifcation {
    
}
- (void)locationDidstart:(NSNotification *)notifcation {
    [self showActivityIndicatorView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self locate];
}

- (void)locate {
    [[KDLocationManager globalLocationManager] setLocationType:KDLocationTypeNormal];
    [[KDLocationManager globalLocationManager] startLocating];
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.locationData = [self.optionsArray objectAtIndex:indexPath.row];
    [tableView reloadData];
    
}

#pragma mark - UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex != alertView.cancelButtonIndex) {
        [[KDLocationManager globalLocationManager] setLocationType:KDLocationTypeNormal];
        [[KDLocationManager globalLocationManager] startLocating];
    }
}

@end
