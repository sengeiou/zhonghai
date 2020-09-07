//
//  KDDiscoveryActionViewController.m
//  kdweibo
//
//  Created by weihao_xu on 14-4-30.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDDiscoveryActionViewController.h"

@interface KDDiscoveryActionViewController ()
@property (nonatomic, retain) UIImageView *commingSoonView;
@end

@implementation KDDiscoveryActionViewController
@synthesize commingSoonView = commingSoonView_;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = ASLocalizedString(@"运动频道");
    
    [self.view setBackgroundColor:RGBCOLOR(237, 237, 237)];
    commingSoonView_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"discover_img_app_irun"]];
    [commingSoonView_ sizeToFit];
    commingSoonView_.center = CGPointMake(self.view.center.x, 200);
    [self.view addSubview:commingSoonView_];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
