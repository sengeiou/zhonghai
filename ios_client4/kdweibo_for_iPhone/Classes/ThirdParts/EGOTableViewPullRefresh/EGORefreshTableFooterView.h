//
//  EGORefreshTableFooterView.h
//  TableViewPull
//
//  Created by Jiandong Lai on 12-5-2.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableCommon.h"

@protocol EGORefreshTableFooterViewDelegate;

@interface EGORefreshTableFooterView : UIView {
@private
//    id<EGORefreshTableFooterViewDelegate> delegate_;
    EGOPullRefreshState state_;
    
    UILabel *statusLabel_;
    UIImageView *indicatorBGView_;
    UIActivityIndicatorView *activityView_;
}

@property (nonatomic, assign) id<EGORefreshTableFooterViewDelegate> delegate;

- (void) egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void) egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void) egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView isInsetsZero:(BOOL)isInsetsZero;

@end


@protocol EGORefreshTableFooterViewDelegate <NSObject>

- (void) egoRefreshTableFooterDidTriggerRefresh:(EGORefreshTableFooterView *)footerView;
- (BOOL) egoRefreshTableFooterDataSourceIsLoading:(EGORefreshTableFooterView *)footerView;

@end

