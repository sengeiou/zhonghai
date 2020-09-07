//
//  KDMenuView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-24.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDMenuItem.h"

@protocol KDMenuViewDelegate;

typedef void (^KDMenuViewDrawRectBlock)(CGContextRef context, CGRect rect);

@interface KDMenuView : UIView {
 @private
//    id<KDMenuViewDelegate> delegate_;
//
    UIImageView *backgroundImageView_;
    
    NSArray *menuItems_;
    
    NSMutableArray *dividers_;
    UIImage *dividerImage_;
    
    NSMutableArray *badgeViews_;
    CGPoint eachBadgeViewTROffset_; // each badge view offset from top right of each menu item
    
    KDMenuViewDrawRectBlock drawRectBlock_;
}

@property(nonatomic, assign) id<KDMenuViewDelegate> delegate;

// The array items can be NSString, UIImage, KDMenuItem and allowed all items has same type in array
@property(nonatomic, retain) NSArray *menuItems;
@property(nonatomic, retain) UIImage *dividerImage;
@property(nonatomic, assign) CGPoint eachBadgeViewTROffset;

@property (nonatomic, readonly) UIImageView *backgroundImageView;

@property(nonatomic, copy) KDMenuViewDrawRectBlock drawRectBlock;
@property(nonatomic, assign)BOOL enableMoreButton;

// initialized with the given titles.
- (id)initWithFrame:(CGRect)frame delegate:(id<KDMenuViewDelegate>)delegate titles:(NSArray *)titles;

// initialized with the given images.
- (id)initWithFrame:(CGRect)frame delegate:(id<KDMenuViewDelegate>)delegate images:(NSArray *)images;

// initialized with the given KDMenuItem.
- (id)initWithFrame:(CGRect)frame menuItems:(NSArray *)menuItems;

- (void)setBackgroundImage:(UIImage *)backgroundImage;

- (BOOL)isValidMenuIndex:(NSUInteger)index;

- (void)setMenuVisibility:(BOOL)visibility atIndex:(NSUInteger)index;
- (void)setMenuEnabled:(BOOL)enabled atIndex:(NSUInteger)index;

- (void)showBadgeValue:(NSUInteger)badgeValue atIndex:(NSUInteger)index;

- (KDMenuItem *)menuItemAtIndex:(NSUInteger)index;

- (KDMenuItem *)menuItembyTitle:(NSString *)title;

// sub-classes should override it if need
- (void)didClickAtMenuItem:(KDMenuItem *)menuItem atIndex:(NSUInteger)index;
- (BOOL)isMenuItemInMore:(NSInteger)index;
- (BOOL)isMenuItemInToolBar:(NSInteger)index;
//某些页面button高度低于view高度  王松 2013-12-31
@property (nonatomic, assign) CGFloat offSetY;
@end


@protocol KDMenuViewDelegate <NSObject>
@optional

- (void)menuView:(KDMenuView *)menuView configMenuButton:(UIButton *)button atIndex:(NSUInteger)index;
- (void)menuView:(KDMenuView *)menuView clickedMenuItemAtIndex:(NSInteger)index;

@end
