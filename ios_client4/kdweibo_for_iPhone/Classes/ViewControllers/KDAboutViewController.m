//
//  KDAboutViewController.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-19.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDAboutViewController.h"

#import "KDNotificationView.h"

#import "KDCommon.h"
#import "KDWeiboAppDelegate.h"
#import "KDAppVersionUpdates.h"

#import "KDDefaultViewControllerContext.h"
#import "KDUtility.h"
#import "KDUnderLineButton.h"
#import "KDCellAdjustForSeven.h"
#import "KDWebViewController.h"
#import "KDVersionCheck.h"
#import "KDGuideVC.h"
#import "KDReachabilityManager.h"
#import "KDLogViewController.h"

//#import "KDAnimateGuidViewController.h"
#define KD_NEW_VERSION_ICON_TAG     0x64

@interface KDAboutViewController () //<KDAnimateGuidViewDelegate>

@property(nonatomic, retain) KDAppVersionUpdates *versionUpdates;
@property (copy, nonatomic) NSDictionary *updateResult;

@property(nonatomic, retain) UITableView *tableView;

@end


@implementation KDAboutViewController

@synthesize versionUpdates=versionUpdates_;

@synthesize tableView=tableView_;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        self.title = ASLocalizedString(@"KDAboutViewController_tips_1");
//        
////        [self resetHasNewClientVersion];
//        
////        [CommenMethod addCheckVesionFinishNotification:self action:@selector(checkVersionFinishNotificaction:)];
//    }
//    
//    return self;
//}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.title = ASLocalizedString(@"KDAboutViewController_tips_1");
    }
    return self;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    
}
- (void) initView {
    
    [KDEventAnalysis event:event_settings_about_open];
    self.view.backgroundColor = [UIColor kdTableViewBackgroundColor];
    
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];// autorelease];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about_bg_v3.png"]];
    bgImageView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    bgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:bgImageView];
//    [bgImageView release];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about_logo_v3.png"]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - logoImageView.image.size.width * 0.8f ) * 0.5f , kd_StatusBarAndNaviHeight + 20.f, logoImageView.image.size.width * 0.8f, logoImageView.image.size.height * 0.8f);
    logoImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:logoImageView];
//    [logoImageView release];
    
    UILabel *productName = [[UILabel alloc] initWithFrame:CGRectZero];
    productName.backgroundColor = [UIColor clearColor];
    productName.textColor = RGBCOLOR(62, 62, 62);
    productName.text = KD_APPNAME;
    productName.font = [UIFont systemFontOfSize:18.0f];
    [productName sizeToFit];
    
//    UILabel *version = [[UILabel alloc] initWithFrame:CGRectZero];
//    version.backgroundColor = [UIColor clearColor];
//    version.textColor = FC1;
//    version.text = ASLocalizedString(@"KDAboutViewController_tips_2");
//    version.font = FS3;
//    [version sizeToFit];
    
    productName.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(productName.bounds)) * 0.5f, CGRectGetMaxY(logoImageView.frame) + 10.0f, CGRectGetWidth(productName.bounds), CGRectGetHeight(productName.bounds));
//    version.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(version.bounds)) * 0.5f, CGRectGetMaxY(productName.frame) + 2.0f, CGRectGetWidth(version.bounds), CGRectGetHeight(version.bounds));
    
    [self.view addSubview:productName];
//    [productName release];
//    [self.view addSubview:version];
//    [version release];
    
    // version info
    CGRect frame = CGRectMake(0.0, CGRectGetMaxY(productName.frame) + 15.0f, self.view.bounds.size.width, 88.0f + 43);
    UITableView *versionTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView = versionTableView;
//    [versionTableView release];
    
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.scrollEnabled = NO;
    
    tableView_.backgroundColor = [UIColor whiteColor];
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView_.backgroundView = nil;
    
    [self.view addSubview:tableView_];
    
    KDUnderLineButton *agreementBtn = [KDUnderLineButton buttonWithType:UIButtonTypeCustom];
    [agreementBtn setTitle:[NSString stringWithFormat:ASLocalizedString(@"KDAboutViewController_tips_3"),KD_APPNAME]forState:UIControlStateNormal];
    [agreementBtn setTitleColor:BOSCOLORWITHRGBA(0x1a85ff, 1.0f) forState:UIControlStateNormal];
    agreementBtn.underLineColor = BOSCOLORWITHRGBA(0x1a85ff, 1.0f);
    agreementBtn.lineSpace = 2.0f;
    [agreementBtn addTarget:self action:@selector(agreementPage:) forControlEvents:UIControlEventTouchUpInside];
    agreementBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [agreementBtn sizeToFit];
    
    agreementBtn.frame = CGRectMake((CGRectGetWidth(self.view.frame) - CGRectGetWidth(agreementBtn.bounds)) * 0.5f, CGRectGetMaxY(self.view.frame) - 46.0f - CGRectGetHeight(agreementBtn.bounds), CGRectGetWidth(agreementBtn.bounds), CGRectGetHeight(agreementBtn.bounds));
    agreementBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
//    [self.view addSubview:agreementBtn];
    
    UIImageView *copyRightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, ScreenFullHeight - 60, ScreenFullWidth - 100, 50)];
    copyRightImageView.image = [UIImage imageNamed:@"about_logo"];
    copyRightImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:copyRightImageView];
}

- (void)agreementPage:(UIButton *)btn
{
    KDWebViewController *web = [[KDWebViewController alloc] initWithUrlString:@"http://m.kdweibo.com/18zz3yq"];// autorelease];
    web.title = [NSString stringWithFormat:ASLocalizedString(@"KDAboutViewController_tips_3"),KD_APPNAME];
    [self.navigationController pushViewController:web animated:YES];
}

#pragma mark -- 判断网络连接
-(BOOL)isNetworkReachable
{
//    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if ([[KDReachabilityManager sharedManager] reachabilityStatusDescription]) {
        return YES;
    }
    
    return NO;
}

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source method

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if(cell == nil){
        cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];// autorelease];
        
        cell.textLabel.textColor = FC1;
        cell.detailTextLabel.textColor = FC2;
        cell.detailTextLabel.font = FS5;
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        cell.separatorLineInset = UIEdgeInsetsMake(0, 12, 0, 0);
    }
    
    UIView *placeholderView = [cell.contentView viewWithTag:KD_NEW_VERSION_ICON_TAG];
    
    NSString *text = nil;
    if(0 == indexPath.row){
        text = ASLocalizedString(@"VERSION");
        NSString *versionStr = [NSString stringWithFormat:@"%@(%@)",[KDCommon visibleClientVersion],[KDCommon buildNo]];;
        cell.detailTextLabel.text = versionStr;
        
        if(placeholderView != nil){
            [placeholderView removeFromSuperview]; 
        }
        cell.accessoryStyle = KDTableViewCellAccessoryStyleNone;
        
    }
    
   else if(indexPath.row == 1)
    {
        text = ASLocalizedString(@"KDAboutViewController_tips_4");
        cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
    }

    else if(indexPath.row == 2)
    {
        text = ASLocalizedString(@"CHECK_NEW_VERSION");
        
        if(hasNewVersion_ && placeholderView == nil){
            UIImage *image = [UIImage imageNamed:@"icon_newVersion.png"];
            placeholderView = [[UIImageView alloc] initWithImage:image];
            placeholderView.tag = KD_NEW_VERSION_ICON_TAG;
            
            CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:18.0]];
            placeholderView.frame = CGRectMake(size.width+10.0, (44.0-image.size.height)*0.5, image.size.width, image.size.height);
            
            [cell.contentView addSubview:placeholderView];
//            [placeholderView release];
        }
        cell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
        cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
    }
    
    cell.textLabel.text = text;
    
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1)
    {
        [KDEventAnalysis event:event_settings_newversionintroduction_open];
        KDGuideVC *guide = [[KDGuideVC alloc] init];
        CATransition* transition = [CATransition animation];
        transition.duration = 0.5;
        transition.type = kCATransitionFade;
        [self.navigationController pushViewController:guide animated:NO];
         self.navigationController.navigationBar.alpha = 0;
        __weak KDAboutViewController *weakSelf = self;
        guide.blockDidPressEnterButton = ^(KDGuideVC *guideVC)
        {
            [guideVC.navigationController.view.layer addAnimation:transition forKey:kCATransition];
            [guideVC.navigationController popViewControllerAnimated:NO];
            weakSelf.navigationController.navigationBar.alpha = 1;
        };

    }
    else if(indexPath.row == 2)
    {
//        if([self isNetworkReachable]){
            [[KDWeiboAppDelegate getAppDelegate] checkVersion:YES];
            [KDEventAnalysis event:event_settings_about_checknewversion];
            //        [KDVersionCheck checkUpdate:YES];
//        }else{
//            [KDVersionCheck checkVersionInfoVisible:YES info:NSLocalizedString(@"NO_NETWORK_CONNECTION", @"")];
//        }
    }
}


- (void)gotoLogVC {
    KDLogViewController *logVC = [[KDLogViewController alloc] init];
    [self.navigationController pushViewController:logVC animated:YES];
}

- (void)animateGuidView:(KDGuideVC *)animateGuidView scrollToLast:(BOOL)flag
{
    [animateGuidView.navigationController popViewControllerAnimated:YES];
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = RGBCOLOR(237, 237, 237);
}



#pragma mark -
#pragma mark UIAlertView delegate methods
/********* 修改版本更新的弹出********/
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.cancelButtonIndex != buttonIndex){
        [KDCommon openURLInApplication:versionUpdates_.updateURL];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];

    //KD_RELEASE_SAFELY(tableView_);
}

- (void) dealloc {
    [CommenMethod removeCheckVesionFinishNotification:self];
    
    //KD_RELEASE_SAFELY(versionUpdates_);
    //KD_RELEASE_SAFELY(_updateResult);
    
    //KD_RELEASE_SAFELY(tableView_);
    
    //[super dealloc];
}

@end
