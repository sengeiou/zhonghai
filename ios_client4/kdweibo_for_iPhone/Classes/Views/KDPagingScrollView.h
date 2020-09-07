//
//  KDPagingScrollView.h
//  kdweibo
//
//  Created by 王 松 on 13-6-5.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

@protocol KDPagingScrollViewDelegate;

@interface KDPagingScrollView : UIScrollView

@property (nonatomic, assign) id<KDPagingScrollViewDelegate>pagingViewDelegate;
@property (readonly, nonatomic) UIView *visiblePageView;
@property (assign) BOOL suspendTiling;

- (void)displayPagingViewAtIndex:(NSUInteger)index;
- (void)resetDisplay;

@end

@protocol KDPagingScrollViewDelegate <NSObject>

@required

- (Class)pagingScrollView:(KDPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index;
- (NSUInteger)pagingScrollViewPagingViewCount:(KDPagingScrollView *)pagingScrollView;
- (UIView *)pagingScrollView:(KDPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index;
- (void)pagingScrollView:(KDPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index;
- (void)pagingScrollView:(KDPagingScrollView *)pagingScrollView didScrollToIndex:(NSInteger)index;

@end
