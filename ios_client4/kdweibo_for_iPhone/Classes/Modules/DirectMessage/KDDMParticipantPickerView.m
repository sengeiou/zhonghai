//
//  KDDMParticipantPickerView.m
//  kdweibo
//
//  Created by Tan yingqi on 12-11-21.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import  <QuartzCore/QuartzCore.h>
#import "KDCommon.h"
#import "KDDMParticipantPickerView.h"

#define NUM_ROW   3
#define NUM_COL   5
#define NUM_PER_PAGE  (NUM_ROW*NUM_COL)

@implementation KDDMParticipantPickerView
@synthesize mainScrollerView = mainScrollerView_;
@synthesize pageConrol = pageControl_;
@synthesize delegate = delegate_;
@synthesize dataSource = dataSource_;
@synthesize gridViews = gridViews_;
@synthesize viewsArray = viewsArray_;
@synthesize addButtonViews = addButtonViews_;
@synthesize deleteButtonViews = deleteButtonViews_;
@synthesize pagesNum = pagesNum_;
@synthesize gridCellNumPerPage = gridCellNumPerPage_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //[self configGridViews];
        //self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
        self.layer.borderColor =  RGBCOLOR(203.f, 203.f, 203.f).CGColor;
        self.layer.borderWidth = 0.5;
        CGRect rect = self.bounds;
        rect.origin.y = 5.f;
        rect.origin.x = 0;
        rect.size.width = rect.size.width;
        rect.size.height = rect.size.height-10;
        UIScrollView *aScrollView = [[UIScrollView alloc] initWithFrame:rect];
        aScrollView.delegate = self;
        aScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        aScrollView.pagingEnabled = YES;
        aScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:aScrollView];
        self.mainScrollerView = aScrollView;
//        [aScrollView release];
        /**
         *  修改背景色
         *  王松
         *  2013-11-19
         *
         */
        self.backgroundColor = RGBCOLOR(250.f, 250.f, 250.f);
        
        SMPageControl *aPageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0, 0, 100, 10)];
        aPageControl.currentPageIndicatorImage = [UIImage imageNamed:@"page_controller_dot_active"];
        aPageControl.pageIndicatorImage = [UIImage imageNamed:@"page_controller_dot_normal"];
        CGPoint center = self.center;
        center.y = self.bounds.size.height - aPageControl.frame.size.height/2;
        aPageControl.center = center;
        aPageControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        aPageControl.hidden = YES;
        aPageControl.hidesForSinglePage = YES;
        [self addSubview:aPageControl];
        
        self.pageConrol = aPageControl;
//        [aPageControl release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avatarNotification:) name:KDDMPaticipantGridCellAvatarDidTouched object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldDelete:) name:KDDMParticipantShouldDeleted object:nil];
        
    }
    return self;
}

- (NSMutableArray *)gridViews {
    if (gridViews_ == nil) {
        gridViews_ = [NSMutableArray arrayWithCapacity:0] ;//retain];
    }
    return gridViews_;
    
}

- (KDGridCellView *)gridCellView:(NSInteger)index {
    KDGridCellView *view = nil;
    if (index >= [self.gridViews count]) {
        view = [dataSource_ gridCellView:index];
        
        [self.mainScrollerView addSubview:view];
        [self.gridViews addObject:view];
    }else {
        view = [self.gridViews objectAtIndex:index];
    }
    return view;
}

- (KDGridCellView *)deleteButtonView:(NSInteger)index {
    
    KDGridCellView *view;
    if (index >=[self.deleteButtonViews count]) {
        view = [dataSource_  deleteButtonView];
        [self.deleteButtonViews addObject:view];
        [self.mainScrollerView addSubview:view];
    }else {
        view = [self.deleteButtonViews objectAtIndex:index];
    }
    return view;
    
}

- (KDGridCellView *)addButtonView:(NSInteger)index{
    KDGridCellView *view;
    if (index >=[self.addButtonViews count]) {
        view = [dataSource_ addButtonView];
        [self.addButtonViews addObject:view];
        [self.mainScrollerView addSubview:view];
    }else {
        view = [self.addButtonViews objectAtIndex:index];
    }
    return view;
}


- (NSMutableArray *)viewsArray {
    if (viewsArray_ == nil) {
        viewsArray_ = [NSMutableArray arrayWithCapacity:0];// retain];
    }
    [viewsArray_ removeAllObjects];
    NSInteger addCount = 0;
    NSInteger  deleCount = 0;
    NSInteger count = [dataSource_ gridCount];
    NSInteger realNumPerPage = [self realNumPerPage];
    for (NSInteger i = 0; i < count; i++) {
        //
        if ((i +1)% realNumPerPage == 0 && i!= 0) {
            //
            [viewsArray_ addObject:[self gridCellView:i]];
            if ([dataSource_ addViewEnable]) {
                [viewsArray_ addObject:[self addButtonView:addCount++]];
            }
            if ([dataSource_ deleViewEnable]) {
                [viewsArray_ addObject:[self deleteButtonView:deleCount++]];
            }
            
        }else {
            if (i == count -1) {
                [viewsArray_ addObject:[self gridCellView:i]];
                if ([dataSource_ addViewEnable]) {
                    [viewsArray_ addObject:[self addButtonView:addCount++]];
                }
                if ([dataSource_ deleViewEnable]) {
                    [viewsArray_ addObject:[self deleteButtonView:deleCount++]];
                }
            }else {
                [viewsArray_ addObject:[self gridCellView:i]];
            }
        }
        
        
    }
    return viewsArray_;
}

- (NSMutableArray *)deleteButtonViews {
    if (deleteButtonViews_ == nil) {
        deleteButtonViews_ = [NSMutableArray arrayWithCapacity:0];// retain];
    }
    return deleteButtonViews_;
}

- (NSMutableArray *)addButtonViews {
    if (addButtonViews_ == nil) {
        addButtonViews_ = [NSMutableArray arrayWithCapacity:0];// retain];
    }
    return addButtonViews_;
}


- (NSInteger)realNumPerPage {
    NSInteger p = 0;
    if ([dataSource_ addViewEnable]) {
        p++;
    }
    if ([dataSource_ deleViewEnable]) {
        p++;
    }
    return NUM_PER_PAGE - p;
    
    
}

- (NSInteger) numOfPages {
    pagesNum_ = 1;
    NSInteger count = [dataSource_ gridCount];
    if (count >0) {
        pagesNum_ = (NSInteger)ceilf((CGFloat)count / [self realNumPerPage]);
    }
    
    return pagesNum_;
    
}

- (UIView *)deleButtonView:(NSInteger)index {
    
    UIView *view;
    if (index >=[self.deleteButtonViews count]) {
        view = [dataSource_ deleteButtonView];
        [self.deleteButtonViews addObject:view];
        [self.mainScrollerView addSubview:view];
    }else {
        view = [self.deleteButtonViews objectAtIndex:index];
    }
    return view;
    
}

//- (UIView *)addButtonView:(NSInteger)index{
//    UIView *view;
//    if (index >=[self.addButtonViews count]) {
//        view = [dataSource_ addButtonView];
//        [self.addButtonViews addObject:view];
//        [self.mainScrollerView addSubview:view];
//    }else {
//        view = [self.addButtonViews objectAtIndex:index];
//    }
//    return view;
//}


- (CGFloat)realHeight {
    return [dataSource_ gridCount] >0 ?[self scrollViewHeigth] :0;
}

- (CGFloat)scrollViewHeigth {
    CGFloat height = 0;
    height = ([dataSource_  boundsOfCell].size.height +5)*[self realNumOfRows] + 10;
    
    return height;
    
}


- (CGPoint)centerWithIndex:(NSUInteger)index {
    CGFloat page = index / NUM_PER_PAGE;
    CGFloat col = (index % NUM_COL);
    CGFloat row = (index % NUM_PER_PAGE) / NUM_COL;
    
    CGFloat left = 0;
    CGFloat top = 0;
    CGPoint c = CGPointZero;
    //CGSize size = [dataSource_ sizeOfCell];
    CGRect rect = [dataSource_ boundsOfCell];
    
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGFloat colSpacing = floorf((self.mainScrollerView.bounds.size.width - (NUM_COL * width)) / (NUM_COL + 1));
    left = colSpacing + (col * colSpacing) + (col * width) + (page * self.mainScrollerView.bounds.size.width);
    top =  (row * (height +5));
    
    c = CGPointMake(left + floorf(width / 2), top + floorf(height / 2));
    
    return c;
}


- (NSInteger) realNumOfRows {
    NSInteger num = 0;
    NSInteger count = [self.viewsArray count];
    if (count >0) {
        num = (NSInteger)ceilf((float)count /NUM_COL) ;
        num = num >=NUM_ROW ?NUM_ROW:num;
    }
    
    return num;
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger numPages = [self numOfPages];
    
    CGRect rect = self.bounds;
    rect.size.width -= 12;
    rect.origin.x = 6;
    self.mainScrollerView.frame = rect;
    
    self.mainScrollerView.contentSize = CGSizeMake(self.mainScrollerView.bounds.size.width* numPages, self.mainScrollerView.bounds.size.height);
    self.pageConrol.numberOfPages = numPages;
    self.pageConrol.hidden = numPages <2;
    [self reloadCell:NO shouldReArrange:YES];
}

//重新load
- (void)reloadCell:(BOOL)animated shouldReArrange:(BOOL)should {
    if ([self.viewsArray count] >0) {
        CGFloat animateDuration = animated ? 0.5 : 0.0;
        NSUInteger i = 0;
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.viewsArray];
        for (KDGridCellView *view in array) {
            if (delegate_ && [delegate_ respondsToSelector:@selector(pickerView:willDisplayGridView:)]) {
                [delegate_ pickerView:self willDisplayGridView:view];
            }
            
            //是否重新排列
            if (should) {
                CGPoint c = [self centerWithIndex:i];
                
                CGFloat tx = c.x - floorf(view.center.x);
                CGFloat ty = c.y - floorf(view.center.y);
                // Animate (optional)
                [UIView animateWithDuration:animateDuration
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     // Transforms
                                     CGAffineTransform t = CGAffineTransformMakeTranslation(tx, ty);
                                     view.transform = t;
                                 }
                                 completion:nil];
                i++;
                
            }
            
        }
    }
    
}


#pragma mark - UIScrollViewDelegate Methods

- (void)setPage {
    NSInteger page = (self.mainScrollerView.contentOffset.x + floorf(self.mainScrollerView.bounds.size.width / 2)) / self.mainScrollerView.bounds.size.width;
    self.pageConrol.currentPage = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scroller {
    if ([scroller isEqual:self.mainScrollerView]) {
        [self setPage];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scroller {
    if ([scroller isEqual:self.mainScrollerView]) {
        [self setPage];
    }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(mainScrollerView_);
    //KD_RELEASE_SAFELY(pageControl_);
    //KD_RELEASE_SAFELY(gridViews_);
    //KD_RELEASE_SAFELY(viewsArray_);
    //KD_RELEASE_SAFELY(addButtonViews_);
    //KD_RELEASE_SAFELY(deleteButtonViews_);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
    
}

- (void)avatarNotification:(NSNotification *)notification {
    KDGridCellView *view =  (KDGridCellView *)[notification object];
    if (view && [self.gridViews containsObject:view]) {
        NSInteger index = [self.gridViews indexOfObject:view];
        DLog(@"index = %d",index);
        if (delegate_ && [delegate_ respondsToSelector:@selector(pickerView:didSelectGridAtIndex:)]) {
            [delegate_ pickerView:self didSelectGridAtIndex:index];
        }
    }else {
        DLog(@"view not null or not in gridviews");
    }
    
}

- (void)shouldDelete:(NSNotification *)notification {
    KDGridCellView *view =  (KDGridCellView *)[notification object];
    if (view && [self.gridViews containsObject:view]) {
        NSInteger index = [self.gridViews indexOfObject:view];
        DLog(@"index = %d",index);
        if (delegate_ && [delegate_ respondsToSelector:@selector(pickerView:shouldDeleteGridAtIndex:)]) {
            [delegate_ pickerView:self shouldDeleteGridAtIndex:index];
        }
    }else {
        DLog(@"view not null or not in gridviews");
    }
    
}
@end
