//
//  LeveyTabBar.h
//  LeveyTabBarController
//
//  Created by zhang on 12-10-10.
//  Copyright (c) 2012年 jclt. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "KDMessageButton.h"

@protocol LeveyTabBarDelegate;

@interface LeveyTabBar : UIView
{
	UIImageView *_backgroundView;
//	id<LeveyTabBarDelegate> _delegate;
	NSMutableArray *_buttons;
}
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, assign) id<LeveyTabBarDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *buttons;


- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray;
- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray titles:(NSArray *)titles;
- (void)selectTabAtIndex:(NSInteger)index;
- (void)removeTabAtIndex:(NSInteger)index;
- (void)insertTabWithImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index;
- (void)setBackgroundImage:(UIImage *)img;
- (void)showNewMessage:(BUTTON_TYPE) type show:(BOOL) isShow;
- (void)setBadgeValue:(BUTTON_TYPE) type count:(NSInteger)count;
@end
@protocol LeveyTabBarDelegate<NSObject>
@optional
- (void)tabBar:(LeveyTabBar *)tabBar didSelectIndex:(NSInteger)index;
- (void)tabBar:(LeveyTabBar *)tabBar didDoubleSelectIndex:(NSInteger)index;
- (void)tabBar:(LeveyTabBar *)tabBar didLongPressSelectIndex:(NSInteger)index;
@end
