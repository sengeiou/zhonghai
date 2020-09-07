//
//  KDNavigationManager.m
//  kdweibo
//
//  Created by Gil on 15/7/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDNavigationManager.h"
#import "KDLeftTopNavBarButtonView.h"


@implementation KDNavigationManager

+ (instancetype)sharedNavigationManager {
    static dispatch_once_t pred;
    static KDNavigationManager *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[KDNavigationManager alloc] init];
    });
    return instance;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    NSInteger index = [navigationController.viewControllers indexOfObject:viewController];
    if (index >= 1) {
        UIViewController *lastViewController = navigationController.viewControllers[index - 1];
        
        //隐藏tabbar
        if([KDWeiboAppDelegate getAppDelegate].tabBarController)
            [KDWeiboAppDelegate getAppDelegate].tabBarController.tabBar.hidden = YES;
        
        
        //pop的时候不需要重新设置
        if (lastViewController.navigationItem.backBarButtonItem) {
            return;
        }
        
        NSString *title = ASLocalizedString(@"Global_GoBack");
        if (index == 1) {
            if (self.tabViewControllers && ([self.tabViewControllers indexOfObject:lastViewController] != NSNotFound)) {
                if (lastViewController.title) {
                    title = lastViewController.title;
                }
                else if (lastViewController.navigationItem.title) {
                    title = lastViewController.navigationItem.title;
                }
            }
        }
        lastViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
        
    }
    else if(index == 0 && [viewController isKindOfClass:NSClassFromString(@"KDWebViewController")] && ![viewController isKindOfClass:NSClassFromString(@"KDWebViewExtentController")]) {
        //轻应用使用present弹出来时
    }
    else
    {
        //显示tabbar
        if([KDWeiboAppDelegate getAppDelegate].tabBarController)
            [KDWeiboAppDelegate getAppDelegate].tabBarController.tabBar.hidden = NO;
        
        UIView *leftBarItemView = nil;
        KDLeftTopNavBarButtonView *aButtonView = [[KDLeftTopNavBarButtonView alloc] initWithFrame:CGRectMake(0, 0, 56, 44)] ;
        [aButtonView.button addTarget:self action:@selector(toggleLeftView:) forControlEvents:UIControlEventTouchUpInside];
        leftBarItemView = aButtonView;

        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarItemView];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;
        viewController.navigationItem.leftBarButtonItems = [NSArray
                                                            arrayWithObjects:negativeSpacer,leftBarButtonItem, nil];
        
    }
    
  

}
- (void)toggleLeftView:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hidePlusMenu" object:nil];
    [[KDWeiboAppDelegate getAppDelegate].sideMenuViewController presentLeftMenuViewController];
}



@end


@implementation UIViewController (KDNavigationManager)

- (NSString *)backBtnTitle {
    if ([self.navigationController.viewControllers count] > 1) {
        UIViewController *viewController = self.navigationController.viewControllers[[self.navigationController.viewControllers count] - 2];
        if (viewController && [KDNavigationManager sharedNavigationManager].tabViewControllers) {
            if ([[KDNavigationManager sharedNavigationManager].tabViewControllers indexOfObject:viewController] != NSNotFound) {
                if (viewController.title) {
                    return viewController.title;
                }
                if (viewController.navigationItem.title) {
                    return viewController.navigationItem.title;
                }
            }
        }
    }
    return ASLocalizedString(@"Global_GoBack");
}

@end
