//
//  LeveyTabBar.h
//  LeveyTabBarController
//
//  Created by zhang on 12-10-10.
//  Copyright (c) 2012年 jclt. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@protocol KDProfileDetailTabBarDelegate;

@interface KDProfileDetailTabBar : UIView
{
	UIImageView *_backgroundView;
    UIView      *_bgMaskView;
//	id<KDProfileDetailTabBarDelegate> _delegate;
	NSMutableArray *_buttons;
}
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) UIView      *bgMaskView;
@property (nonatomic, assign) id<KDProfileDetailTabBarDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *buttons;

- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray;
- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray titles:(NSArray *)titles;
- (void)selectTabAtIndex:(NSInteger)index;
- (void)removeTabAtIndex:(NSInteger)index;
- (void)insertTabWithImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index;
- (void)setBackgroundImage:(UIImage *)img;

@end
@protocol KDProfileDetailTabBarDelegate<NSObject>
@optional
- (void)tabBar:(KDProfileDetailTabBar *)tabBar didSelectIndex:(NSInteger)index; 
@end
