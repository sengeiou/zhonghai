//
//  LeveyTabBarControllerViewController.h
//  LeveyTabBarController
//
//  Created by zhang on 12-10-10.
//  Copyright (c) 2012年 jclt. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "LeveyTabBar.h"
#import "KDUnreadManager.h"
@class UITabBarController;
@protocol LeveyTabBarControllerDelegate;
@interface LeveyTabBarController : UIViewController <LeveyTabBarDelegate,KDUnreadListener>
{
	LeveyTabBar *_tabBar;
	UIView      *_containerView;
	UIView		*_transitionView;
//	id<LeveyTabBarControllerDelegate> _delegate;
	NSMutableArray *_viewControllers;
	NSUInteger _selectedIndex;
	
	BOOL _tabBarTransparent;
	BOOL _tabBarHidden;
    
    NSInteger animateDriect;
}

@property(nonatomic, copy) NSMutableArray *viewControllers;

@property(nonatomic, readonly) UIViewController *selectedViewController;
@property(nonatomic) NSUInteger selectedIndex;

//2014-4-25 by Tan yingqi 兼容迅通的消息的未读 去掉 readonly
// Apple is readonly
@property (nonatomic, retain) LeveyTabBar *tabBar;
@property(nonatomic,assign) id<LeveyTabBarControllerDelegate> delegate;


// Default is NO, if set to YES, content will under tabbar
@property (nonatomic) BOOL tabBarTransparent;
@property (nonatomic) BOOL tabBarHidden;

@property(nonatomic,assign) NSInteger animateDriect;

- (id)initWithViewControllers:(NSArray *)vcs imageArray:(NSArray *)arr;

- (id)initWithViewControllers:(NSArray *)vcs imageArray:(NSArray *)arr tiltesArray:(NSArray *)titles;

- (void)hidesTabBar:(BOOL)yesOrNO animated:(BOOL)animated;


// Remove the viewcontroller at index of viewControllers.
- (void)removeViewControllerAtIndex:(NSUInteger)index;

// Insert an viewcontroller at index of viewControllers.
- (void)insertViewController:(UIViewController *)vc withImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index;

@end


@protocol LeveyTabBarControllerDelegate <NSObject>
@optional
- (BOOL)tabBarController:(LeveyTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(LeveyTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;
- (void)tabBarSelectedOnce;
- (void)tabBarSelectedDouble;
- (void)tabBarSelectedLongPress;
@end

@interface UIViewController (LeveyTabBarControllerSupport)
@property(nonatomic, readonly) LeveyTabBarController *leveyTabBarController;
@end
