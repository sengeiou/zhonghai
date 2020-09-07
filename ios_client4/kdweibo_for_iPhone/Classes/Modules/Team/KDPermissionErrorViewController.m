//
//  KDPermissionErrorViewController.m
//  kdweibo
//
//  Created by AlanWong on 14-8-1.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDPermissionErrorViewController.h"

@interface KDPermissionErrorViewController ()

@end

@implementation KDPermissionErrorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = RGBCOLOR(237.f, 237.f, 237.f);
    
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_photo_permission_v3.png"]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - CGRectGetWidth(imageview.frame)) * .5, 40.f, CGRectGetWidth(imageview.frame), 40.f)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDPermissionErrorViewController_no_perm"),KD_APPNAME];
    [self.view addSubview:titleLabel];
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - CGRectGetWidth(imageview.frame)) * .5, 80.f, CGRectGetWidth(imageview.frame), 60.f)];
    detailLabel.font = [UIFont systemFontOfSize:17.f];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.numberOfLines = 2;
    detailLabel.textColor = RGBCOLOR(109.f, 109.f, 109.f);
    detailLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDPermissionErrorViewController_enter_system"),KD_APPNAME];
    [self.view addSubview:detailLabel];
    
    self.navigationItem.leftBarButtonItems = [KDCommon leftNavigationItemWithTarget:self action:@selector(dismissViewController:)];

    
    imageview.frame = CGRectMake((CGRectGetWidth(self.view.frame) - CGRectGetWidth(imageview.frame)) * .5, 160.f, CGRectGetWidth(imageview.frame), CGRectGetHeight(imageview.frame));
    [self.view addSubview:imageview];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dismissViewController:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
