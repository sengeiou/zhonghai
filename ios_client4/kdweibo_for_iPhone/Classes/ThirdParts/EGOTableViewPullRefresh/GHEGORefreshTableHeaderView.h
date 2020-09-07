

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	EGOOPullRefreshPulling = 0,
	EGOOPullRefreshNormal,
	EGOOPullRefreshLoading,	
} EGOPullRefreshState;

@protocol GHEGORefreshTableHeaderDelegate;
@interface GHEGORefreshTableHeaderView : UIView {
	
	id _delegate;
	EGOPullRefreshState _state;
    
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	
    
}

@property(nonatomic,assign) id <GHEGORefreshTableHeaderDelegate> delegate;

- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end
@protocol GHEGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(GHEGORefreshTableHeaderView*)view;
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(GHEGORefreshTableHeaderView*)view;
@optional
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(GHEGORefreshTableHeaderView*)view;
@end


