//
//  KDStyle.m
//  kdweibo
//
//  Created by Gil on 15/7/1.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDStyle.h"


@implementation KDStyle

+ (void)setupStyple {
    //setup status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    
    //setup nav
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"nav_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 21, 0, 21)] forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : FC1, NSFontAttributeName : FS1}];

    
    //setup nav item
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : FC5, NSFontAttributeName : FS3} forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : FC7, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
//    返回按钮的修改在文件UIViewController+NavigationStyle.h
//    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav_btn_back_light_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav_btn_back_light_press"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 0)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonTitlePositionAdjustment:UIOffsetMake(3, 0) forBarMetrics:UIBarMetricsDefault];
    
    //setup tabbar
    [[UITabBar appearance] setBarStyle:UIBarStyleBlack];
    [[UITabBar appearance] setTintColor:FC5];
    [[UITabBar appearance] setBackgroundImage:[[UIImage imageNamed:@"toolbar_tab_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24, 0, 24)]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : FC1, NSFontAttributeName : FS8} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : FC5, NSFontAttributeName : FS8} forState:UIControlStateSelected];
    

    
    //setup searchbar
    [[UISearchBar appearance] setBarTintColor:[UIColor kdBackgroundColor1]];
    [[UISearchBar appearance] setBarStyle:UIBarStyleBlack];
    [[UISearchBar appearance] setBackgroundImage:[UIImage imageWithColor:FC6] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UISearchBar appearance] setImage:[UIImage imageNamed:@"search_bar_btn_search"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [[UISearchBar appearance] setImage:[UIImage imageNamed:@"search_bar_btn_search_highlight"]forSearchBarIcon:UISearchBarIconSearch state:UIControlStateHighlighted];
    [[UISearchBar appearance] setImage:[UIImage imageNamed:@"search_bar_btn_clear"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    UIImage *backgroundImage = [UIImage imageNamed:@"search_bar_textfield"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width * 0.5 topCapHeight:backgroundImage.size.height * 0.5];
    [[UISearchBar appearance] setSearchFieldBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [[UISearchBar appearance] setSearchTextPositionAdjustment:UIOffsetMake([NSNumber kdDistance2], 0)];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSFontAttributeName : FS6, NSForegroundColorAttributeName : FC1}];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:FC5} forState:UIControlStateNormal];

    
    //UITextField的光标颜色可以用这个控制
    [[UITextField appearance] setTintColor:FC5];
}

@end
