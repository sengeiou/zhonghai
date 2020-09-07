//
//  RefreshTableFootView.h
//  TwitterFon
//
//  Created by kingdee on 11-6-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EGORefreshTableHeaderView.h"

#define  RefreshViewHight 48.0f

@protocol EGORefreshFootDelegate;

@interface RefreshTableFootView : UIView {
//    id<EGORefreshFootDelegate> delegate_;
    EGOPullRefreshState state_;
    
	UILabel *statusLabel_;
    UIActivityIndicatorView *activityView_;
	UIImageView *identifierImageView_;
}

//@property(nonatomic,assign) id <EGORefreshFootDelegate> delegate;
@property(nonatomic,assign) EGOPullRefreshState state;
@property(nonatomic,assign) id <EGORefreshFootDelegate> delegate;
@property(assign,nonatomic)BOOL reloadingFootView;

//- (void)setCurrentDate:(NSDate *) date;
- (void)setState:(EGOPullRefreshState)aState;
//- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
@end

@protocol EGORefreshFootDelegate <NSObject>
- (void)egoRefreshFooterDidTriggerRefresh:(RefreshTableFootView*)view;
- (BOOL)egoRefreshFooterDataSourceIsLoading:(RefreshTableFootView*)view;
@optional
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(RefreshTableFootView*)view;
@end