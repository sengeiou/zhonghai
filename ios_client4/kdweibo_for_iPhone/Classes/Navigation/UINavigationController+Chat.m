//
//  UINavigationController+Chat.m
//  kdweibo
//
//  Created by Gil on 16/5/17.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "UINavigationController+Chat.h"

@implementation UINavigationController (Chat)

- (void)setupTimelineTab {
    if ([KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex == 0) {
        XTTimelineViewController *timeVC = (XTTimelineViewController *) ((UINavigationController *) [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController).topViewController;
        if (timeVC.searchDisplayController.active) {
            [timeVC.searchDisplayController setActive:NO];
        }
        [self setNavigationStyle:KDNavigationStyleNormal];
        [(UINavigationController *) [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController popToRootViewControllerAnimated:NO];
    }
    else {
        [self resetApplicationViewControllerNavigationBar];
        [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex = 0;
    }
}

- (void)setupAppTab {
	if ([KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex != 2) {
        [self resetApplicationViewControllerNavigationBar];
		[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex = 2;
	}
	else {
		UINavigationController *navigationController = [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController;
		[navigationController popToRootViewControllerAnimated:NO];
        [self setNavigationStyle:KDNavigationStyleNormal];
	}
}

- (void)pushToChatWithGroup:(GroupDataModel *)group
             shareDataModel:(XTShareDataModel *)shareDM
                isPopToRoot:(BOOL)isPopToRoot {
    
    if (isPopToRoot) {
        [self setupTimelineTab];
    }
    
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
    if (shareDM) {
        chatViewController.shareDataModel = shareDM;
    }
    chatViewController.hidesBottomBarWhenPushed = YES;
    if (isPopToRoot) {
        [[KDWeiboAppDelegate getAppDelegate].timelineViewController.navigationController pushViewController:chatViewController animated:YES];
    }
    else {
        [self pushViewController:chatViewController animated:YES];
    }
}

- (void)pushToChatWithPerson:(PersonSimpleDataModel *)person
              shareDataModel:(XTShareDataModel *)shareDM
                 isPopToRoot:(BOOL)isPopToRoot {
    
    if (isPopToRoot) {
        [self setupTimelineTab];
    }
    
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:person];
    if (shareDM) {
        chatViewController.shareDataModel = shareDM;
    }
    chatViewController.hidesBottomBarWhenPushed = YES;
    if (isPopToRoot) {
        [[KDWeiboAppDelegate getAppDelegate].timelineViewController.navigationController pushViewController:chatViewController animated:YES];
    }
    else {
        [self pushViewController:chatViewController animated:YES];
    }
}

- (void)pushToTodo {
    
    [self setupTimelineTab];
    
//    [[KDWeiboAppDelegate getAppDelegate].timelineViewController gotoToDoNewController];
}
- (void)resetApplicationViewControllerNavigationBar
{
    if ([[(UINavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController topViewController] isKindOfClass:[KDApplicationViewController class]])
    {
        UIViewController *applicationViewController = [(UINavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController topViewController];
        [applicationViewController setNavigationStyle:KDNavigationStyleNormal];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

@end
