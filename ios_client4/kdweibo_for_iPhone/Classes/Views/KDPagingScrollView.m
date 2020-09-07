//
//  KDPagingScrollView.m
//  kdweibo
//
//  Created by 王 松 on 13-6-5.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDPagingScrollView.h"
#import "KDPhotoOriginView.h"

@interface KDPagingScrollView () <UIScrollViewDelegate>

@property (retain, nonatomic) NSMutableSet *recycledPages;
@property (retain, nonatomic) NSMutableSet *visiblePages;

@end

@implementation KDPagingScrollView {
    NSUInteger _currentPagingIndex;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_recycledPages);
    //KD_RELEASE_SAFELY(_visiblePages);
    //[super dealloc];
}

- (void)setupView {
    self.pagingEnabled = YES;
    self.backgroundColor = [UIColor blackColor];
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    
    // it is very important to auto resize
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _recycledPages = [[NSMutableSet alloc] init];
    _visiblePages  = [[NSMutableSet alloc] init];
    
}

#pragma mark - Calculations for Size and Positioning
#pragma mark -

#define PADDING  4

- (CGRect)frameForPagingScrollView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect pageFrame = self.bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (self.bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    
    assert(self.pagingViewDelegate != nil);
    NSUInteger count = [self.pagingViewDelegate pagingScrollViewPagingViewCount:self];
    
    return CGSizeMake(self.bounds.size.width * count, self.bounds.size.height);
}

- (CGPoint)scrollPositionForIndex:(NSUInteger)index {
    CGFloat x = self.bounds.size.width * index;
    return CGPointMake(x, 0);
}

- (NSUInteger)currentPagingIndex {
    NSUInteger index = (NSUInteger)(ceil((self.contentOffset.x - 10.0f) / self.bounds.size.width));
    return index;
}

- (void)configurePage:(UIView *)page forIndex:(NSUInteger)index {
    
    if (self.pagingViewDelegate != nil) {
        [self.pagingViewDelegate pagingScrollView:self preparePageViewForDisplay:page forIndex:index];
    }
    
    page.frame = [self frameForPageAtIndex:index];
    page.tag = index;
}

- (void)tilePages {
    if (self.suspendTiling) {
        // tiling during rotation causes odd behavior so it is best to suspend it
        return;
    }
    
    NSUInteger count = [self.pagingViewDelegate pagingScrollViewPagingViewCount:self];
    
    // Calculate which pages are visible
    CGRect visibleBounds = self.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, (int)count - 1);
    
    // Recycle no-longer-visible pages
    for (UIView *page in self.visiblePages) {
        NSUInteger index = page.tag;
        if (index < firstNeededPageIndex || index > lastNeededPageIndex) {
            [self.recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [self.visiblePages minusSet:self.recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            UIView *page = [self dequeueRecycledPage:index];
            [self configurePage:page forIndex:index];
            [self addSubview:page];
            [self.visiblePages addObject:page];
        }
    }
}

#pragma mark - Reuse Queue
#pragma mark -

- (UIView *)dequeueRecycledPage:(NSUInteger)index {
    UIView *page = nil;
    
    if (self.pagingViewDelegate != nil) {
        for (UIView *recycledPage in self.recycledPages) {
            if ([recycledPage isKindOfClass:[self.pagingViewDelegate pagingScrollView:self classForIndex:index]]) {
                page = recycledPage;
                break;
            }
        }
        if (page != nil) {
            if ([page respondsToSelector:@selector(prepareForReuse)]) {
                [page performSelector:@selector(prepareForReuse)];
            }
            [self.recycledPages removeObject:page];
        }
        else {
            page = [self.pagingViewDelegate pagingScrollView:self pageViewForIndex:index];
        }
    }
    
    return page;

}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    BOOL foundPage = NO;
    for (UIView *page in self.visiblePages) {
        NSUInteger pageIndex = page.tag;
        if (pageIndex == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

#pragma mark - Public Implementation
#pragma mark -

- (UIView *)visiblePageView {
    NSUInteger index = [self currentPagingIndex];
    for (UIView *pageView in self.visiblePages) {
        NSUInteger pageIndex = pageView.tag;
        if (pageIndex == index) {
            return pageView;
        }
    }
    
    return nil;
}

- (void)displayPagingViewAtIndex:(NSUInteger)index {
    _currentPagingIndex = index;
    
    self.contentSize = [self contentSizeForPagingScrollView];
    [self setContentOffset:[self scrollPositionForIndex:index] animated:NO];
    
    [self tilePages];
}

- (void)resetDisplay {
    self.contentSize = [self contentSizeForPagingScrollView];
    [self setContentOffset:[self scrollPositionForIndex:_currentPagingIndex] animated:NO];
    
    for (UIView *pageView in self.visiblePages) {
        NSUInteger index = pageView.tag;
        pageView.frame = [self frameForPageAtIndex:index];
    }
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    DebugLog(@"scrollViewDidScroll");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self tilePages];
    });
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _currentPagingIndex = [self currentPagingIndex];
    NSUInteger count = [self.pagingViewDelegate pagingScrollViewPagingViewCount:self];
    if (_currentPagingIndex >= count) {
        _currentPagingIndex = count - 1;
    }
    [self.pagingViewDelegate pagingScrollView:self didScrollToIndex:_currentPagingIndex];
}

@end

