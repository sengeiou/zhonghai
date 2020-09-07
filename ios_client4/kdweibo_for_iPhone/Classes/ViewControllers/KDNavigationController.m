//
//  KDNavigationController.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDNavigationController.h"
#import "UINavigationBar+Additions.h"
#import "KDWeiboAppDelegate.h"

#import "CRGradientNavigationBar.h"

@interface KDNavigationController ()

@end

@implementation KDNavigationController

- (id)init {
    self = [super initWithNavigationBarClass:[CRGradientNavigationBar class] toolbarClass:nil];
    if(self) {
    }
    return self;
}
- (void)dealloc{

    [super dealloc];
}
- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithNavigationBarClass:[CRGradientNavigationBar class] toolbarClass:nil];
    if(self) {
        [self pushViewController:rootViewController animated:NO];
    }
    
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    if (isAboveiOS7) {
    UIColor *firstColor = RGBCOLOR(26.f, 133.f, 255.f);
    UIColor *secondColor = RGBCOLOR(26.f, 133.f, 255.f);
        [[CRGradientNavigationBar appearance] setBarTintGradientColors:@[firstColor, secondColor]];
        [self.navigationBar setTranslucent:NO];
//    }else {
//        if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
//            [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg"] forBarMetrics:UIBarMetricsDefault];
//        }
//        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
//            [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg"] forBarPosition:UIBarPositionTop  barMetrics:UIBarMetricsDefault];
//        }
//    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [KDWeiboAppDelegate setExtendedLayout:viewController];
    [super pushViewController:viewController animated:animated];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    for(UIViewController *vc in viewControllers) {
        [KDWeiboAppDelegate setExtendedLayout:vc];
    }
    
    [super setViewControllers:viewControllers];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    for(UIViewController *vc in viewControllers) {
        [KDWeiboAppDelegate setExtendedLayout:vc];
    }
    
    [super setViewControllers:viewControllers animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
