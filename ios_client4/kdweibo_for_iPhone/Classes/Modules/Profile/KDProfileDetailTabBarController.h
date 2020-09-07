//
//  LeveyTabBarControllerViewController.h
//  LeveyTabBarController
//
//  Created by zhang on 12-10-10.
//  Copyright (c) 2012年 jclt. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "KDProfileDetailTabBar.h"
#import "KDUser.h"
@class UITabBarController;
@protocol KDProfileDetailTabBarControllerDelegate;
@interface KDProfileDetailTabBarController : UIViewController <KDProfileDetailTabBarDelegate>
{
	KDProfileDetailTabBar *_tabBar;
	UIView      *_containerView;
	UIView		*_transitionView;
//	id<KDProfileDetailTabBarControllerDelegate> _delegate;
	NSMutableArray *_viewControllers;
	NSUInteger _selectedIndex;
	
	BOOL _tabBarTransparent;
	BOOL _tabBarHidden;
    
    NSInteger animateDriect;
}
@property(nonatomic, retain) KDUser *currentUser;
@property(nonatomic, copy) NSMutableArray *viewControllers;

@property(nonatomic, readonly) UIViewController *selectedViewController;
@property(nonatomic) NSUInteger selectedIndex;

// Apple is readonly
@property (nonatomic, readonly) KDProfileDetailTabBar *tabBar;
@property(nonatomic,assign) id<KDProfileDetailTabBarControllerDelegate> delegate;


// Default is NO, if set to YES, content will under tabbar
@property (nonatomic) BOOL tabBarTransparent;
@property (nonatomic) BOOL tabBarHidden;

@property(nonatomic,assign) NSInteger animateDriect;

+ (id)profileDetailViewController;

- (id)initWithViewControllers:(NSArray *)vcs imageArray:(NSArray *)arr;

- (id)initWithViewControllers:(NSArray *)vcs imageArray:(NSArray *)arr titles:(NSArray *)titles;

- (void)hidesTabBar:(BOOL)yesOrNO animated:(BOOL)animated;

// Remove the viewcontroller at index of viewControllers.
- (void)removeViewControllerAtIndex:(NSUInteger)index;

// Insert an viewcontroller at index of viewControllers.
- (void)insertViewController:(UIViewController *)vc withImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index;

- (void)setSelectedTabIndex:(NSUInteger)selectedIndex;
@end


@protocol KDProfileDetailTabBarControllerDelegate <NSObject>
@optional
- (BOOL)tabBarController:(KDProfileDetailTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(KDProfileDetailTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;
@end

@interface UIViewController (KDProfileDetailTabBarControllerSupport)
@property(nonatomic, readonly) KDProfileDetailTabBarController *leveyTabBarController;
@end

