//
//  AppHeaderView.m
//  kdweibo
//
//  Created by 王 松 on 13-11-26.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDAppHeaderView.h"

#import "SMPageControl.h"

#import "KDTileView.h"

#import "KDAppHeaderViewDataSource.h"

@interface KDAppHeaderView () <UIScrollViewDelegate>

@property (nonatomic, retain) KDTileView *tileView;

@property (nonatomic, retain) SMPageControl *pageControl;

@property (nonatomic, retain) KDAppHeaderViewDataSource *dataSource;

@property (nonatomic, retain) UIButton *actionButton;

@end

@implementation KDAppHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = MESSAGE_BG_COLOR;
    
    _shouldCycelImages = YES;
    
    _dataSource  = [[KDAppHeaderViewDataSource alloc] init];
    _tileView    = [[KDTileView alloc] initWithFrame:CGRectZero style:KDTileViewStyleGridPage cellWidth:CGRectGetWidth(self.frame) paddingWidth:0.0f];
    _pageControl = [[SMPageControl alloc] initWithFrame:CGRectZero];
    _actionButton = [UIButton buttonWithType:UIButtonTypeCustom] ;//retain];
    
    _tileView.dataSource     = _dataSource;
    _tileView.delegate       = self;
    
    _pageControl.indicatorMargin = 6.0;
    _pageControl.pageIndicatorTintColor = RGBACOLOR(210.0, 210.0, 210.0, 0.5);
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    
    _pageControl.numberOfPages = [_dataSource numberOfColumnsAtTileView:self.tileView];
    _pageControl.currentPage = 0;
    
    CGSize size = [_pageControl sizeForNumberOfPages:ImageCount];
    
    _pageControl.frame = CGRectMake((CGRectGetWidth(self.frame) - size.width) / 2.f, CGRectGetHeight(self.frame) - size.height - 10.f, size.width, size.height);
    
//    [_actionButton setImage:[UIImage imageNamed:@"video_delete.png"] forState:UIControlStateNormal];
//    _actionButton.frame = CGRectMake(0.0f, 0.0f, 25.f, 25.f);
    
    [self addSubview:_tileView];
    [self addSubview:_pageControl];
//    [self addSubview:_actionButton];
    
    [self setTimer];

}

- (void)setTimer
{
    [NSTimer scheduledTimerWithTimeInterval:5. target:self selector:@selector(cycleImages:) userInfo:nil repeats:YES];
}

- (void)cycleImages:(NSTimer *)timer
{
    if (!self.shouldCycelImages) {
        [timer invalidate];
    }
    NSInteger nextPage = self.pageControl.currentPage + 1;
    if (nextPage >= ImageCount) {
        nextPage = 0;
    }
    [self.tileView scrollToColumn:nextPage];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _tileView.frame = self.bounds;
    CGPoint center = self.center;
    center.x = CGRectGetWidth(self.frame) - CGRectGetWidth(_actionButton.frame) - 20.f;
    _actionButton.center = center;
}

- (void)addCloseTarget:(id)target action:(SEL)action
{
    [self.actionButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -
#pragma mark UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = floor(scrollView.contentOffset.x / scrollView.bounds.size.width);
    if(_pageControl.currentPage != index){
        _pageControl.currentPage = index;
    }
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_actionButton);
    //KD_RELEASE_SAFELY(_tileView);
    //KD_RELEASE_SAFELY(_pageControl);
    //KD_RELEASE_SAFELY(_dataSource);
    //[super dealloc];
}


@end
