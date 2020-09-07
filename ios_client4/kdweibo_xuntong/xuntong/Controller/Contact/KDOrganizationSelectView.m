//
//  IDOrganizationSelectView.m
//  kdweibo
//
//  Created by KongBo on 15/9/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDOrganizationSelectView.h"

#define leftPadding 8
#define space 8

@interface KDOrganizationSelectView()<KDSelectItemViewDelegate>
{
    UIScrollView *contentScrollView;
}
@end

@implementation KDOrganizationSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        contentScrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        [self addSubview:contentScrollView];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        contentScrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        [self addSubview:contentScrollView];
    }
    return self;
}


- (void)reloadData
{
    BOOL haveDataDelegate = NO;
    NSUInteger numberOfItems  = 0;
    
    if (self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(numberOfItemsInOraganizationSelectView:)]) {
        numberOfItems = [self.dataDelegate numberOfItemsInOraganizationSelectView:self];
        haveDataDelegate = YES;
    }
    
    if (self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(organiztionSelectView:itemViewAtIndex:)]) {
        haveDataDelegate &=YES;
    }
    else
    {
        haveDataDelegate = NO;
    }
    
    if (!haveDataDelegate) {
        return;
    }
    // remove subViews
    
    for (UIView *subview in contentScrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    CGFloat contentOffsetY = 0;
    for (int i = 0; i < numberOfItems; i++) {
        NSString *title = [self.dataDelegate organiztionSelectView:self itemViewAtIndex:i];
        if (i == 0) {
            KDSelectItemView *itemView = [[KDSelectItemView alloc]initWithViewStyle:SelectItemViewStyleNormalFirst viewTitle:title atIndex:i];
            itemView.delegate = self;
            
            CGSize itemViewSize = [itemView getItemViewSize];
            contentOffsetY += 8;
            itemView.frame = CGRectMake(contentOffsetY, (self.frame.size.height - itemViewSize.height) / 2, itemViewSize.width, itemViewSize.height);
            contentOffsetY += itemViewSize.width;
            [contentScrollView addSubview:itemView];
        }
        else if (i == numberOfItems - 1) {
            KDSelectItemView *itemView = [[KDSelectItemView alloc]initWithViewStyle:SelectItemViewStyleNormalLast viewTitle:title atIndex:i];
            itemView.delegate = self;
            
            CGSize itemViewSize = [itemView getItemViewSize];
            contentOffsetY += 8;
            itemView.frame = CGRectMake(contentOffsetY, (self.frame.size.height - itemViewSize.height) / 2, itemViewSize.width, itemViewSize.height);
            contentOffsetY += itemViewSize.width;
            [contentScrollView addSubview:itemView];
        }
        else
        {
            KDSelectItemView *itemView = [[KDSelectItemView alloc]initWithViewStyle:SelectItemViewStyleNormal viewTitle:title atIndex:i];
            itemView.delegate = self;
            
            CGSize itemViewSize = [itemView getItemViewSize];
            if (i == 0) {
                contentOffsetY += leftPadding;
            }
            else
            {
                contentOffsetY += 8;
            }
            itemView.frame = CGRectMake(contentOffsetY, (self.frame.size.height - itemViewSize.height) / 2, itemViewSize.width, itemViewSize.height);
            contentOffsetY += itemViewSize.width;
            
            [contentScrollView addSubview:itemView];
            
        }
    }
    
    contentScrollView.contentSize = CGSizeMake(contentOffsetY + 8, self.frame.size.height);
    
    CGFloat shouldContentOffsetY = 0;
    if (contentOffsetY + 8 < self.frame.size.width) {
        shouldContentOffsetY = -leftPadding;
    }
    else
    {
        shouldContentOffsetY = contentOffsetY + 8  - contentScrollView.frame.size.width;
    }
    [UIView animateWithDuration:0.5 animations:^{
        contentScrollView.contentOffset = CGPointMake(shouldContentOffsetY , 0);
    }];
    
}

#pragma mark -IDSelectItemViewDelegate

- (void)SelectItemView:(KDSelectItemView *)view  didSelectedAtIndex:(NSUInteger)index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(organiztionSelectView:didSelectedAtIndex:)]) {
        [self.delegate organiztionSelectView:self didSelectedAtIndex:index];
    }
}

@end
