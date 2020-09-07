//
//  CKSlideSwitchView.m
//  ScrollviewTabDemo
//
//  Created by vike on 4/2/14.
//  Copyright (c) 2014 longversion. All rights reserved.
//

#import "CKSlideSwitchView.h"
@interface CKSlideSwitchView()<UIScrollViewDelegate>
{
    UIScrollView *_rootScrollview;
    UIScrollView *_topScrollview;
    
    BOOL _isRootScroll;
    NSInteger _selectedTabTag;
    
    BOOL _isBuildUI;
    
    UIImageView *_tabItemShadowImageView;
    NSInteger _rootScrollviewCurrentPage;
    
    
    NSInteger _tabItemCount;
    CGFloat _tabItemHeight;
    CGFloat _tabItemMargin;
    CGFloat _tabItemWidth;
    
    BOOL _isCustomSetTabItemWidth;//是否自定义tabitem的宽度
    NSInteger _firstSelectedTabItemIndex;//首次加载选择tabitem的index
    
    CGFloat _tabItemFontSize;
    BOOL  _seperatorLineImageFlag;
    
    CGFloat _shadowImageHeight;
}
@property (nonatomic, retain) NSMutableArray *rootContentViews;

@end

@implementation CKSlideSwitchView
- (NSMutableArray *)rootContentViews
{
    if(!_rootContentViews)
    {
        _rootContentViews = [NSMutableArray new];
    }
    return _rootContentViews;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self=[super initWithCoder:aDecoder])
    {
        [self initValues];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if(self =[super initWithFrame:frame])
    {
        [self initValues];
    }
    return self;
}

- (void)setTopScrollviewBackgroundImage:(UIImage *)topScrollviewBackgroundImage
{
    _topScrollviewBackgroundImage = topScrollviewBackgroundImage;
    _topScrollview.backgroundColor = [UIColor colorWithPatternImage:topScrollviewBackgroundImage];
}

- (void)setTopScrollViewBackgroundColor:(UIColor *)topScrollViewBackgroundColor
{
    _topScrollViewBackgroundColor = topScrollViewBackgroundColor;
    _topScrollview.backgroundColor = topScrollViewBackgroundColor;
}

- (void)initValues
{
    //创建顶部tab视图
    _topScrollview = [[UIScrollView alloc] init];
    _topScrollview.backgroundColor = [UIColor clearColor];
    _topScrollview.pagingEnabled = NO;
    _topScrollview.showsHorizontalScrollIndicator = NO;
    _topScrollview.showsVerticalScrollIndicator = NO;
    _topScrollview.scrollEnabled = NO;
    _topScrollview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_topScrollview];
    
    
    //创建主滚动视图
    _rootScrollview = [[UIScrollView alloc] init];
    _rootScrollview.showsVerticalScrollIndicator = NO;
    _rootScrollview.showsHorizontalScrollIndicator = NO;
    _rootScrollview.backgroundColor = [UIColor clearColor];
    _rootScrollview.delegate = self;
    _rootScrollview.autoresizingMask = UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth ;
    _rootScrollview.bounces = NO;
    _rootScrollview.pagingEnabled = YES;
    
    [self addSubview:_rootScrollview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //    if(_isBuildUI)
    //    {
    //        if(self.rootContentViews && self.rootContentViews.count>0)
    //        {
    //            //更新主视图的总宽度
    //            _rootScrollview.contentSize = CGSizeMake(self.bounds.size.width * self.rootContentViews.count, 0);
    //
    //            //更新主视图各个子视图的宽度
    //            for (int i = 0; i < [self.rootContentViews count]; i++) {
    //                UIView *listVC = self.rootContentViews[i];
    //                listVC.frame = CGRectMake(0+_rootScrollview.bounds.size.width*i, 0,
    //                                          _rootScrollview.bounds.size.width, _rootScrollview.bounds.size.height);
    //            }
    //
    //            //调整顶部滚动视图选中按钮位置
    //            UIButton *button = (UIButton *)[_topScrollview viewWithTag:_rootScrollviewCurrentPage + 100];
    //            [self adjustScrollViewContentX:button];
    //        }
    //
    //    }
    //    _isBuildUI = YES;
}

- (void)receiveDataFromDelegate
{
    _tabItemCount = [self.slideSwitchViewDelegate slideSwitchView:self numberOfTabItemForTopScrollview:_topScrollview];
    
    if(self.slideSwitchViewDelegate)
    {
        if(self.slideSwitchViewDelegate && [self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:heightOfShadowImageForTopScrollview:)])
        {
            _shadowImageHeight = [self.slideSwitchViewDelegate slideSwitchView:self heightOfShadowImageForTopScrollview:_topScrollview];
        }
        
        if([self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:heightForTabItemForTopScrollview:)])
        {
            _tabItemHeight = [self.slideSwitchViewDelegate slideSwitchView:self heightForTabItemForTopScrollview:_topScrollview];
        }
        
        if([self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:widthForTabItemForTopScrollview:)])
        {
            _tabItemWidth = [self.slideSwitchViewDelegate slideSwitchView:self widthForTabItemForTopScrollview:_topScrollview];
            _isCustomSetTabItemWidth = YES;
        }
        if([self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:fontSizeForTabItemForTopScrollview:)])
        {
            _tabItemFontSize = [self.slideSwitchViewDelegate slideSwitchView:self fontSizeForTabItemForTopScrollview:_topScrollview];
        }
        if([self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:selectedTabItemIndexForFirstStartForTopScrollview:)])
        {
            _firstSelectedTabItemIndex = [self.slideSwitchViewDelegate slideSwitchView:self selectedTabItemIndexForFirstStartForTopScrollview:_topScrollview];
        }
        
        if([self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:seperatorImageViewShowInTopScrollview:)])
        {
            _seperatorLineImageFlag = [self.slideSwitchViewDelegate slideSwitchView:self seperatorImageViewShowInTopScrollview:_topScrollview];
        }
        
        if(_tabItemFontSize == 0)
        {
            _tabItemFontSize = KFontSizeOfTabButton;
        }
        
        if( [self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:marginForTopScrollview:)])
        {
            _tabItemMargin = [self.slideSwitchViewDelegate slideSwitchView:self marginForTopScrollview:_topScrollview];
        }
    }
}

- (void)reloadData
{
    if(_topScrollview.subviews.count>0)
    {
        [_topScrollview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    if(_rootScrollview.subviews.count>0)
    {
        [_rootScrollview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    if(self.rootContentViews && self.rootContentViews.count>0)
    {
        [self.rootContentViews removeAllObjects];
    }
    [self receiveDataFromDelegate];
    if(_tabItemCount == 0)
    {
        return;
    }
    _rootScrollviewCurrentPage = _firstSelectedTabItemIndex;
    CGFloat topScrollViewWidth = self.frame.size.width;
    if (self.slideSwitchViewDelegate&&[self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:widthForTopScrollview:)]) {
        topScrollViewWidth = [self.slideSwitchViewDelegate slideSwitchView:self widthForTopScrollview:_topScrollview];
    }
    _topScrollview.frame = CGRectMake(0, 0,topScrollViewWidth, _tabItemHeight);
    _rootScrollview.frame = CGRectMake(0, _tabItemHeight, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)- _tabItemHeight);
    
    [self configRootScrollview:KScrollviewRunType_nomal];
    [self createTabItemButtons];
}

- (void)createTabItemButtons
{
    if(self.tabItemShadowImage || self.tabItemShadowColor)
    {
        _tabItemShadowImageView = [[UIImageView alloc] init];
        if(self.tabItemShadowImage)
        {
            _tabItemShadowImageView.image = self.tabItemShadowImage;
        }else{
            _tabItemShadowImageView.backgroundColor = self.tabItemShadowColor;
        }
        [_topScrollview addSubview:_tabItemShadowImageView];
    }
    
    //顶部tabbar的总长度
    CGFloat topScrollviewContentWidth = _tabItemMargin;
    //tabitem的偏移量
    CGFloat xOffset = _tabItemMargin;
    
    CGFloat width = 0;
    for (int i =0; i<_tabItemCount; i++) {
        UIButton *tabItem = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *textStr = [self.slideSwitchViewDelegate slideSwitchView:self titleForTabItemForTopScrollviewAtIndex:i];
        if(_tabItemWidth>0)
        {
            //            tabItem.frame = CGRectMake(xOffset, -64, _tabItemWidth, _tabItemHeight);
            /**
             *  布局修改 2015-9-15 by李文博
             */
            tabItem.frame = CGRectMake(xOffset, 0, _tabItemWidth, _tabItemHeight);
            
            width = _tabItemWidth;
        }
        //        else{
        //            CGSize textSize= [textStr sizeWithFont:[UIFont systemFontOfSize:_tabItemFontSize]
        //                                 constrainedToSize:CGSizeMake(_topScrollview.bounds.size.width, _tabItemHeight)
        //                                     lineBreakMode:NSLineBreakByTruncatingTail];
        //
        //            tabItem.frame = CGRectMake(xOffset, 0,  textSize.width, _tabItemHeight);
        //            width = textSize.width;
        //        }
        topScrollviewContentWidth += _tabItemMargin +width;
        xOffset += width + _tabItemMargin;
        
        [tabItem setTag:i+100];
        if(i==_firstSelectedTabItemIndex)
        {
            [self changeShadowViewFrameWithView:tabItem];
            tabItem.selected = YES;
            _selectedTabTag = i + 100;
        }
        //        tabItem.titleLabel.numberOfLines = 0;
        //        tabItem.titleLabel.textAlignment = NSTextAlignmentCenter;
        [tabItem setTitle:textStr forState:UIControlStateNormal];
        tabItem.titleLabel.font = [UIFont systemFontOfSize:_tabItemFontSize];
        if(self.tabItemTitleNormalColor)
        {
            [tabItem setTitleColor:self.tabItemTitleNormalColor forState:UIControlStateNormal];
        }
        if(self.tabItemTitleSelectedColor)
        {
            [tabItem setTitleColor:self.tabItemTitleSelectedColor forState:UIControlStateSelected];
        }
        if(self.tabItemNormalBackgroundImage)
        {
            [tabItem setBackgroundImage:self.tabItemNormalBackgroundImage forState:UIControlStateNormal];
        }
        if(self.tabItemSelectedBackgroundImage)
        {
            [tabItem setBackgroundImage:self.tabItemSelectedBackgroundImage forState:UIControlStateSelected];
        }
        [tabItem addTarget:self action:@selector(tabItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topScrollview addSubview:tabItem];
        
        if(_seperatorLineImageFlag && i!= _tabItemCount-1)
        {
            UIImageView *imgViewSepearetor = [[UIImageView alloc] init];
            
            /**
             *  布局修改 2015-9-15 by李文博
             */
            
            //             imgViewSepearetor.frame = CGRectMake(CGRectGetMaxX(tabItem.frame)+_tabItemMargin/2.0,-64 +(_tabItemHeight-14)*0.5, 0.5, 14);
            
            imgViewSepearetor.frame = CGRectMake(CGRectGetMaxX(tabItem.frame)+_tabItemMargin/2.0, 0 +(_tabItemHeight-14)*0.5, 0.5, 14);
            
            
            imgViewSepearetor.backgroundColor = [UIColor kdDividingLineColor];
            [_topScrollview addSubview:imgViewSepearetor];
            if(_tabItemMargin == 0)
            {
                topScrollviewContentWidth += 0.5;
                xOffset += 0.5;
            }
        }
    }
    if(_selectedTabTag == 0)
    {
        _selectedTabTag = 100;
    }
    _topScrollview.contentSize = CGSizeMake(topScrollviewContentWidth, 0);
    
    [self addSepLineView];
}

- (void)addSepLineView{
    if(![_topScrollview viewWithTag:300005])
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, Height(_topScrollview.frame) - 0.5, Width(_topScrollview.frame), 0.5)];
        view.backgroundColor = [UIColor kdDividingLineColor];
        view.tag = 300005;
        [_topScrollview addSubview:view];
    }
}

- (void)configRootScrollview:(KScrollviewRunType)runType
{
    if(_rootScrollview.subviews.count>0)
        [_rootScrollview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setRootScrollviewDataSource:runType];
    
    NSInteger counter = 0;
    for (UIView *contentView in self.rootContentViews) {
        CGRect rect = _rootScrollview.frame;
        rect.origin = CGPointMake(CGRectGetWidth(_rootScrollview.frame)*counter, 0);
        contentView.frame = rect;
        counter ++;
        [_rootScrollview addSubview:contentView];
    }
    //当总数为3个时  特殊处理
    if(_tabItemCount == 3 || _tabItemCount == 4)
    {
        _rootScrollview.contentSize = CGSizeMake(_tabItemCount * CGRectGetWidth(_rootScrollview.frame), CGRectGetHeight(_rootScrollview.frame));
        _rootScrollview.contentOffset = CGPointMake(_firstSelectedTabItemIndex * CGRectGetWidth(_rootScrollview.frame), 0);
    }else {
        //总页数大于小于3时
        if(_rootScrollviewCurrentPage != 0 && _rootScrollviewCurrentPage != _tabItemCount-1)
        {
            _rootScrollview.contentSize = CGSizeMake(3 * CGRectGetWidth(_rootScrollview.frame), CGRectGetHeight(_rootScrollview.frame));
        }else{
            _rootScrollview.contentSize = CGSizeMake(2 * CGRectGetWidth(_rootScrollview.frame), CGRectGetHeight(_rootScrollview.frame));
        }
        
        if(_rootScrollviewCurrentPage !=0)
        {
            [_rootScrollview setContentOffset:CGPointMake(CGRectGetWidth(_rootScrollview.frame), 0)];
        }else if(_rootScrollviewCurrentPage == 0)
        {
            _rootScrollview.contentOffset = CGPointZero;
            if(_tabItemCount <=1)
            {
                _rootScrollview.contentSize = CGSizeMake(CGRectGetWidth(_rootScrollview.frame), CGRectGetHeight(_rootScrollview.frame));
            }
        }
    }
    if(self.slideSwitchViewDelegate && [self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchViewConfigRootScrollviewSuccess)])
    {
        [self.slideSwitchViewDelegate slideSwitchViewConfigRootScrollviewSuccess];
    }
}

- (void)setRootScrollviewDataSource:(KScrollviewRunType)runType
{
    if(self.rootContentViews == nil)
    {
        self.rootContentViews = [NSMutableArray new];
    }
    //总数为3 的情况
    if(_tabItemCount == 3 || _tabItemCount == 4)
    {
        if(self.rootContentViews.count>0)
        {
            [self.rootContentViews removeAllObjects];
        }
        for (int t = 0; t<_tabItemCount; t++) {
            [self.rootContentViews addObject:[self.slideSwitchViewDelegate slideSwitchView:self viewForRootScrollViewAtIndex:t]];
        }
    }else{
        
        //总数不为3的情况
        NSInteger previousPageIndex= [self getValidNextPageIndexWithPageIndex:_rootScrollviewCurrentPage-1];
        NSInteger nextPageIndex = [self getValidNextPageIndexWithPageIndex:_rootScrollviewCurrentPage+1];
        
        switch (runType) {
            case KScrollviewRunType_nomal:
            {
                if(self.rootContentViews.count>0)
                {
                    [self.rootContentViews removeAllObjects];
                }
                if(self.slideSwitchViewDelegate && [self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:viewForRootScrollViewAtIndex:)])
                {
                    if(_rootScrollviewCurrentPage != 0)
                    {
                        [self.rootContentViews addObject:[self.slideSwitchViewDelegate slideSwitchView:self viewForRootScrollViewAtIndex:previousPageIndex]];
                    }
                    [self.rootContentViews addObject:[self.slideSwitchViewDelegate slideSwitchView:self viewForRootScrollViewAtIndex:_rootScrollviewCurrentPage]];
                    if(_rootScrollviewCurrentPage != _tabItemCount-1 &&_tabItemCount>1)
                    {
                        [self.rootContentViews addObject:[self.slideSwitchViewDelegate slideSwitchView:self viewForRootScrollViewAtIndex:nextPageIndex]];
                    }
                }
            }
                break;
                
            case KScrollviewRunType_left:
            {
                if( _tabItemCount<3)
                {
                    return;
                }
                if(self.rootContentViews && self.rootContentViews.count== 3)
                {
                    [self.rootContentViews removeObjectAtIndex:0];
                    if(_rootScrollviewCurrentPage != _tabItemCount-1)
                    {
                        [self.rootContentViews addObject:[self.slideSwitchViewDelegate slideSwitchView:self viewForRootScrollViewAtIndex:nextPageIndex]];
                    }
                }else if(self.rootContentViews && _rootScrollviewCurrentPage == 1){
                    [self.rootContentViews addObject:[self.slideSwitchViewDelegate slideSwitchView:self viewForRootScrollViewAtIndex:nextPageIndex]];
                }
            }
                break;
                
            case KScrollviewRunType_right:
            {
                if(_tabItemCount <3)
                {
                    return;
                }
                if(self.rootContentViews && self.rootContentViews.count == 3)
                {
                    [self.rootContentViews removeObjectAtIndex:2];
                    if(_rootScrollviewCurrentPage != 0)
                    {
                        [self.rootContentViews insertObject:[self.slideSwitchViewDelegate slideSwitchView:self viewForRootScrollViewAtIndex:previousPageIndex] atIndex:0];
                    }
                }else if(self.rootContentViews && _rootScrollviewCurrentPage == _tabItemCount-2){
                    [self.rootContentViews insertObject:[self.slideSwitchViewDelegate slideSwitchView:self viewForRootScrollViewAtIndex:previousPageIndex] atIndex:0];
                }
            }
                break;
            default:
                break;
        }
        
    }
    
}

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex
{
    if(currentPageIndex == -1)
    {
        return _tabItemCount - 1;
    }else if (currentPageIndex == _tabItemCount)
    {
        return 0;
    }else{
        return  currentPageIndex;
    }
}

-(void)tabItemAction:(UIButton *)sender
{
    if(sender.isSelected)
    {
        return;
    }
    else
    {
        [self adjustScrollViewContentX:sender]; //方法有问题
        
        for (UIView *btnview in _topScrollview.subviews)
        {
            if([btnview isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)btnview;
                if(btn.selected)
                {
                    btn.selected = NO;
                    break;
                }
            }
        }
        
        _selectedTabTag = sender.tag;
        sender.selected = YES;
        if(self.slideSwitchViewDelegate && [self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:currentIndex:)])
        {
            [self.slideSwitchViewDelegate slideSwitchView:self currentIndex:sender.tag - 100];
        }
        [UIView animateWithDuration:0.2 animations:^{
            [self changeShadowViewFrameWithView:sender];
        } completion:^(BOOL finished) {
            if(finished)
            {
                if(!_isRootScroll)
                {
                    NSInteger selectedIndex = sender.tag - 100;
                    
                    if(_tabItemCount == 3 || _tabItemCount == 4)
                    {
                        _rootScrollviewCurrentPage = selectedIndex;
                        [_rootScrollview setContentOffset:CGPointMake(CGRectGetWidth(_rootScrollview.frame) * _rootScrollviewCurrentPage, 0) animated:YES];
                    }
                    else
                    {
                        if(selectedIndex == _rootScrollviewCurrentPage+1)
                        {
                            _rootScrollviewCurrentPage = selectedIndex;
                            [self configRootScrollview:KScrollviewRunType_left];
                        }
                        else if(selectedIndex == _rootScrollviewCurrentPage -1)
                        {
                            _rootScrollviewCurrentPage = selectedIndex;
                            [self configRootScrollview:KScrollviewRunType_right];
                        }else{
                            _rootScrollviewCurrentPage = selectedIndex;
                            [self configRootScrollview:KScrollviewRunType_nomal];
                        }
                    }
                }
                _isRootScroll = NO;
                
            }
        }];
        
    }
}

- (void)changeShadowViewFrameWithView:(UIView *)view
{
    if(self.tabItemShadowImage || self.tabItemShadowColor)
    {
        CGFloat shadowHeight = _shadowImageHeight>0?_shadowImageHeight:CGRectGetHeight(view.frame);
        _tabItemShadowImageView.frame = CGRectMake(view.frame.origin.x,CGRectGetMaxY(view.frame)- shadowHeight, CGRectGetWidth(view.frame), shadowHeight);
    }
}
#pragma mark - uiscrollview delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == _rootScrollview)
    {
        CGFloat rootScrollviewOffsetX = scrollView.contentOffset.x;
        
        
        if(_tabItemCount == 3 || _tabItemCount == 4)
        {
            return;
        }
        if(_rootScrollviewCurrentPage != 0 && _rootScrollviewCurrentPage != _tabItemCount -1)
        {
            if(rootScrollviewOffsetX >= (2*CGRectGetWidth(scrollView.frame)))
            {
                _rootScrollviewCurrentPage = [self getValidNextPageIndexWithPageIndex:_rootScrollviewCurrentPage +1];
                [self configRootScrollview:KScrollviewRunType_left];
                [self btnChangeedThroughScrollviewChanged];
            }else if(rootScrollviewOffsetX<=0)
            {
                _rootScrollviewCurrentPage = [self getValidNextPageIndexWithPageIndex:_rootScrollviewCurrentPage -1];
                [self configRootScrollview:KScrollviewRunType_right];
                [self btnChangeedThroughScrollviewChanged];
            }
        }
        else if(_rootScrollviewCurrentPage == _tabItemCount -1){
            if(rootScrollviewOffsetX<=0)
            {
                _rootScrollviewCurrentPage = [self getValidNextPageIndexWithPageIndex:_rootScrollviewCurrentPage -1];
                [self configRootScrollview:KScrollviewRunType_right];
                [self btnChangeedThroughScrollviewChanged];
            }
        }
        else if(_rootScrollviewCurrentPage == 0)
        {
            if(rootScrollviewOffsetX >= (CGRectGetWidth(scrollView.frame)))
            {
                _rootScrollviewCurrentPage = [self getValidNextPageIndexWithPageIndex:_rootScrollviewCurrentPage +1];
                [self configRootScrollview:KScrollviewRunType_left];
                [self btnChangeedThroughScrollviewChanged];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(_rootScrollview == scrollView)
    {
        if(_tabItemCount == 3 || _tabItemCount == 4)
        {
            CGFloat pageWidth = scrollView.frame.size.width;
            int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
            _rootScrollviewCurrentPage = page;
            [self btnChangeedThroughScrollviewChanged];
        }else{
            if(_rootScrollviewCurrentPage != 0)
                [scrollView setContentOffset:CGPointMake(CGRectGetWidth(_rootScrollview.frame), 0) animated:YES];
        }
        
    }
}

//scrollview改变对应的btn颜色也改变
- (void)btnChangeedThroughScrollviewChanged
{
    if(_rootScrollviewCurrentPage +100 != _selectedTabTag)
    {
        _isRootScroll = YES;
        UIButton *tabItem = (UIButton *)[_topScrollview viewWithTag:_rootScrollviewCurrentPage+100];
        if(tabItem)
        {
            [self tabItemAction:tabItem];
        }
    }
}
/**
 *	@brief	调整顶部topscrollview的偏移量
 */
- (void)adjustScrollViewContentX:(UIButton *)sender
{//左边界
    if (_tabItemCount * _tabItemWidth <= self.frame.size.width)
    {
        return;
    }
    
    if(_topScrollview.contentOffset.x > sender.frame.origin.x)
    {
        [_topScrollview setContentOffset:CGPointMake(sender.frame.origin.x - _tabItemMargin, 0) ];
    }else if(_topScrollview.contentOffset.x + CGRectGetWidth(_topScrollview.frame) < CGRectGetMaxX(sender.frame))
    {
        [_topScrollview setContentOffset:CGPointMake(CGRectGetMaxX(sender.frame) - CGRectGetWidth(_topScrollview.frame), 0)];
    }
    
}

- (NSInteger)currentSelectedTabItemIndex
{
    return _selectedTabTag - 100;
}

- (UIView *)currentSelectedViewInRootScrollview
{
    if(self.rootContentViews && self.rootContentViews.count>0)
    {
        for (UIView *view in self.rootContentViews) {
            
            if([view isKindOfClass:[UIView class]])
            {
                if(view.tag == self.currentSelectedTabItemIndex)
                {
                    return view;
                }
            }
        }
    }
    return nil;
}



- (UIView *)findContentViewWithIndex:(NSInteger)index
{
    if(self.rootContentViews && self.rootContentViews.count>0)
    {
        for (UIView *view in self.rootContentViews)
        {
            if(view.tag == index)
            {
                return view;
                break;
            }
        }
    }
    return nil;
}
@end
