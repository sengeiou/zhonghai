//
//  MWPhotoBrowser_Private.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "MWGridViewController.h"
#import "MWZoomingScrollView.h"

// Declare private methods of browser
@interface MWPhotoBrowser () {
    
    // Data
    NSUInteger _photoCount;
    NSMutableArray *_photos;
    NSMutableArray *_thumbPhotos;
    NSArray *_depreciatedPhotoData; // Depreciated
    
    // Views
    UIScrollView *_pagingScrollView;
    
    // Paging & layout
    NSMutableSet *_visiblePages, *_recycledPages;
    NSUInteger _currentPageIndex;
    NSUInteger _previousPageIndex;
    CGRect _previousLayoutBounds;
    NSUInteger _pageIndexBeforeRotation;
    
    // Navigation & controls
    UIToolbar *_toolbar;
    NSTimer *_controlVisibilityTimer;
    UIBarButtonItem *_previousButton, *_nextButton, *_actionButton, *_doneButton;
    MBProgressHUD *_progressHUD;
    UIActionSheet *_actionsSheet;
    
    // Grid
    MWGridViewController *_gridController;
    UIBarButtonItem *_gridPreviousLeftNavItem;
    UIBarButtonItem *_gridPreviousRightNavItem;
    
    // Appearance
    BOOL _previousNavBarHidden;
    BOOL _previousNavBarTranslucent;
    UIBarStyle _previousNavBarStyle;
    UIStatusBarStyle _previousStatusBarStyle;
    UIColor *_previousNavBarTintColor;
    UIColor *_previousNavBarBarTintColor;
    UIBarButtonItem *_previousViewControllerBackButton;
    UIImage *_previousNavigationBarBackgroundImageDefault;
    UIImage *_previousNavigationBarBackgroundImageLandscapePhone;
    
    // Misc
    BOOL _hasBelongedToViewController;
    BOOL _isVCBasedStatusBarAppearance;
    BOOL _statusBarShouldBeHidden;
    BOOL _displayActionButton;
    BOOL _leaveStatusBarAlone;
    BOOL _performingLayout;
    BOOL _rotating;
    BOOL _viewIsActive; // active as in it's in the view heirarchy
    BOOL _didSavePreviousStateOfNavBar;
    BOOL _skipNextPagingScrollViewPositioning;
    BOOL _viewHasAppearedInitially;
    CGPoint _currentGridContentOffset;
    
    // >>>>>>>>>>>>>>>【darren hack】<<<<<<<<<<<<<<<<<
    
    // ---------- 自定义导航栏 ----------
    UIView *viewNavigationBarBG;            // 背景灰度图片
    UIButton *buttonBack;                   // 返回按钮
    UIButton *selectedButton;               // 多选勾选框
    UILabel *labelTitle;                   // 标题，显示“2/9”
    // ---------- 自定义标签栏 ----------
    UIView *viewToolbarBG;                  // 背景灰度图片
    UIButton *buttonImageCheckbox;          // 原图勾选框，显示用，并不接受事件
    UIButton *buttonImageCheckboxLarger;    // 原图勾选框实际接收事件的按钮，范围较大
    UILabel *labelImageSize;                // 原图文本，显示图片大小
    UIButton *buttonSend;                   // 发送
    UIButton *buttonSendSum;                // 发送边上的显示总数的文本
    // ---------- Misc ----------
    BOOL bShouldUpdatePageTiles;            // 解决页面切换的刷新问题
    BOOL bHideCustomViews;                  // 是否隐藏自定义的控件，单击屏幕则切换此变量
}

// Properties
@property (nonatomic) UIActivityViewController *activityViewController;

// Layout
- (void)layoutVisiblePages;
- (void)performLayout;
- (BOOL)presentingViewControllerPrefersStatusBarHidden;

// Nav Bar Appearance
- (void)setNavBarAppearance:(BOOL)animated;
- (void)storePreviousNavBarAppearance;
- (void)restorePreviousNavBarAppearance:(BOOL)animated;

// Paging
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (MWZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index;
- (MWZoomingScrollView *)pageDisplayingPhoto:(id<MWPhoto>)photo;
- (MWZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(MWZoomingScrollView *)page forIndex:(NSUInteger)index;
- (void)didStartViewingPageAtIndex:(NSUInteger)index;

// Frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)frameForCaptionView:(MWCaptionView *)captionView atIndex:(NSUInteger)index;
- (CGRect)frameForSelectedButton:(UIButton *)selectedButton atIndex:(NSUInteger)index;

// Navigation
- (void)updateNavigation;
- (void)jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)gotoPreviousPage;
- (void)gotoNextPage;

// Grid
- (void)showGrid:(BOOL)animated;
- (void)hideGrid;

// Controls
- (void)cancelControlHiding;
- (void)hideControlsAfterDelay;
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent;
- (void)toggleControls;
- (BOOL)areControlsHidden;

// Data
- (NSUInteger)numberOfPhotos;
- (id<MWPhoto>)photoAtIndex:(NSUInteger)index;
- (id<MWPhoto>)thumbPhotoAtIndex:(NSUInteger)index;
- (UIImage *)imageForPhoto:(id<MWPhoto>)photo;
- (BOOL)photoIsSelectedAtIndex:(NSUInteger)index;
- (void)setPhotoSelected:(BOOL)selected atIndex:(NSUInteger)index;
- (void)loadAdjacentPhotosIfNecessary:(id<MWPhoto>)photo;
- (void)releaseAllUnderlyingPhotos:(BOOL)preserveCurrent;

// Actions
- (void)savePhoto;
- (void)copyPhoto;
- (void)emailPhoto;

@end

