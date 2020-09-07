//
//  KDWisdomRadarController.m
//  kdweibo
//
//  Created by Tan Yingqi on 14-4-30.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDWisdomRadarController.h"

@interface KDWisdomRadarController ()
@property (nonatomic,retain)UIImageView *backgroundImageView;
@property (nonatomic,retain)UIButton *okBtn;
@property (nonatomic,retain)UIButton *refuseBtn;
@property (nonatomic,retain)UIScrollView *scrollView;
@end

@implementation KDWisdomRadarController
@synthesize backgroundImageView = backgroundImageVeiw_;
@synthesize okBtn = okBtn_;
@synthesize refuseBtn = refuseBtn_;
@synthesize scrollView = scrollView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.navigationItem.title = ASLocalizedString(@"智慧雷达");
    [self.view setBackgroundColor:RGBCOLOR(237, 237, 237)];
    
    scrollView_ = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView_];
    scrollView_.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + 10);
   
    scrollView_.showsVerticalScrollIndicator = NO;
    
    backgroundImageVeiw_ = [[UIImageView alloc ] initWithImage:[UIImage imageNamed:@"discover_wisdom_radar_bg"]];
    [backgroundImageVeiw_ sizeToFit];
    
    
    backgroundImageVeiw_.center = CGPointMake(CGRectGetMidX(scrollView_.bounds),CGRectGetHeight(scrollView_.bounds) * 0.3);
    
    [scrollView_ addSubview:backgroundImageVeiw_];
    
    CGRect rect = backgroundImageVeiw_.bounds;
    rect.size.height = 40;
    rect.origin.x = CGRectGetMinX(backgroundImageVeiw_.frame);
    rect.origin.y = CGRectGetMaxY(backgroundImageVeiw_.frame) + 30;
    
    okBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
    okBtn_.frame = rect;
    [okBtn_ setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [okBtn_ setTitle:ASLocalizedString(@"KDWisdomRadarController_okBtn_title")forState:UIControlStateNormal];
    okBtn_.titleLabel.textAlignment = NSTextAlignmentCenter;
    okBtn_.titleLabel.font = [UIFont systemFontOfSize:15.0];
    okBtn_.layer.cornerRadius = 5.0f;
    okBtn_.layer.masksToBounds = YES;
    [okBtn_ setBackgroundColor:UIColorFromRGB(0x20c000)];
    [okBtn_ addTarget:self action:@selector(okBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView_  addSubview:okBtn_];
    
    

    rect.origin.y = CGRectGetMaxY(okBtn_.frame) + 30;
    refuseBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
    refuseBtn_.frame = rect;
    [refuseBtn_ setTitle:ASLocalizedString(@"KDWisdomRadarController_refuseBtn_title")forState:UIControlStateNormal];
     refuseBtn_.titleLabel.textAlignment = NSTextAlignmentCenter;
    [refuseBtn_ setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [refuseBtn_ setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    refuseBtn_.titleLabel.font = [UIFont systemFontOfSize:15.0];
    refuseBtn_.layer.cornerRadius = 5.0f;
    refuseBtn_.layer.borderWidth = 0.2f;
    refuseBtn_.layer.borderColor = UIColorFromRGB(0xa9a9a9).CGColor;
    refuseBtn_.layer.masksToBounds = YES;
    [refuseBtn_ setBackgroundColor:[UIColor whiteColor]];
    [refuseBtn_ addTarget:self action:@selector(refuseBtnTapped:) forControlEvents:UIControlEventTouchUpInside];

    [scrollView_ addSubview:refuseBtn_];
    
    [self performSelector:@selector(print) withObject:nil afterDelay:2];
    
}

- (void)print {
    DLog(@"srollView.frame = %@",NSStringFromCGRect(scrollView_.frame));
}
- (void)okBtnTapped:(id)sender {
    UIAlertView *alerterView = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDWisdomRadarController_alert_msg")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
    [alerterView show];
//    [alerterView release];
    
}

- (void)refuseBtnTapped:(id)sender {
    UIAlertView *alerterView = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDWisdomRadarController_alert_msg")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
    [alerterView show];
//    [alerterView release];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(backgroundImageVeiw_);
    //KD_RELEASE_SAFELY(okBtn_);
    //KD_RELEASE_SAFELY(refuseBtn_);
    //KD_RELEASE_SAFELY(scrollView_);
    //[super dealloc];
}
@end
