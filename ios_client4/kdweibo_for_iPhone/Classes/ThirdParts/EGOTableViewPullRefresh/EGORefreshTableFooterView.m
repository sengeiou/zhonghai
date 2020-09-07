//
//  EGORefreshTableFooterView.m
//  TableViewPull
//
//  Created by Jiandong Lai on 12-5-2.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "EGORefreshTableFooterView.h"


#define EGO_REFRESH_TABLE_FOOTER_VIEW_HEIGHT    48.0f

@interface EGORefreshTableFooterView ()

@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIImageView *indicatorBGView;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;

- (void) setState:(EGOPullRefreshState)state;

@end


@implementation EGORefreshTableFooterView

@synthesize delegate=delegate_;

@synthesize statusLabel=statusLabel_;
@synthesize indicatorBGView=indicatorBGView_;
@synthesize activityView=activityView_;

- (void) setupRefreshTableFooterView {
    // status label
    statusLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    statusLabel_.backgroundColor = [UIColor clearColor];
    
    statusLabel_.font = [UIFont systemFontOfSize:13.0f];
    statusLabel_.textColor = RGBCOLOR(42.0, 49.0, 56.0);
    statusLabel_.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:statusLabel_];   
    
    // indicator background image view
    UIImage *image = [UIImage imageNamed:@"footImage.png"];
    indicatorBGView_ = [[UIImageView alloc] initWithImage:image];
    indicatorBGView_.bounds = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    indicatorBGView_.hidden = YES;
    
    [self addSubview:indicatorBGView_];
    
    // activity view
    activityView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView_.bounds = CGRectMake(0.0, 0.0, 16.0f, 16.0f);
    
    [self addSubview:activityView_];
    
    [self setState:EGOOPullRefreshNormal];
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = RGBCOLOR(215.0, 220.0, 224.0);
        
        [self setupRefreshTableFooterView];
        
        [self setState:EGOOPullRefreshNormal];
    }
    
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = MIN(self.bounds.size.height, EGO_REFRESH_TABLE_FOOTER_VIEW_HEIGHT);
    
    // indicator background image view
    CGRect rect = indicatorBGView_.bounds;
    rect.origin = CGPointMake(width - rect.size.width - 10.0, (height - rect.size.height) * 0.5);
    indicatorBGView_.frame = rect;
    
    // activity view
    activityView_.frame = CGRectMake(rect.origin.x + (rect.size.width - activityView_.bounds.size.width) * 0.5, 
                                     rect.origin.y + (rect.size.height - activityView_.bounds.size.height) * 0.5, 
                                     activityView_.bounds.size.width, activityView_.bounds.size.height);
    
    CGFloat offsetX = width - rect.origin.x;
    width -= 2 * offsetX;
    
    statusLabel_.frame = CGRectMake(offsetX, 0.0, width, height);
}

- (void) setState:(EGOPullRefreshState)state {
    if(state_ != state){
        switch (state) {
            case EGOOPullRefreshPulling:
            {
                statusLabel_.text = ASLocalizedString(@"RefreshTableFootView_Pulling_update");
            }
                break;
                
            case EGOOPullRefreshNormal:
            {
                statusLabel_.text = ASLocalizedString(@"RefreshTableFootView_Normal_update");
                indicatorBGView_.hidden = YES;
                [activityView_ stopAnimating];
            }
                break;
                
            case EGOOPullRefreshLoading:
            {
                statusLabel_.text = ASLocalizedString(@"RefreshTableFootView_Loading");
                indicatorBGView_.hidden = NO;
                [activityView_ startAnimating];
            }
                break;
                
            default:
                break;
        }
        
        state_ = state;
    }
}
- (void) egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat diff = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentSize.height;
    
    if (state_ == EGOOPullRefreshLoading) {
        CGFloat offset = MAX(diff, 0);
		offset = MIN(offset, EGO_REFRESH_TABLE_FOOTER_VIEW_HEIGHT);
		scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, offset, 0.0f);
		
	} else if (scrollView.isDragging) {
		BOOL loading = NO;
		if ([delegate_ respondsToSelector:@selector(egoRefreshTableFooterDataSourceIsLoading:)]) {
			loading = [delegate_ egoRefreshTableFooterDataSourceIsLoading:self];
		}
		
    	if (state_ == EGOOPullRefreshPulling && diff < EGO_REFRESH_TABLE_FOOTER_VIEW_HEIGHT && !loading) {
			[self setState:EGOOPullRefreshNormal];
            
		} else if (state_ == EGOOPullRefreshNormal && diff > EGO_REFRESH_TABLE_FOOTER_VIEW_HEIGHT && !loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.bottom != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
	}
}

- (NSUInteger)tableViewRowInSectionZero:(UIScrollView *)scrollView
{
    UITableView * tableView = (UITableView *)scrollView;
    return [tableView numberOfRowsInSection:0];
    
}

- (void) egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    BOOL loading = NO;
	if ([delegate_ respondsToSelector:@selector(egoRefreshTableFooterDataSourceIsLoading:)]) {
		loading = [delegate_ egoRefreshTableFooterDataSourceIsLoading:self];
	}
	
    CGFloat diff = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentSize.height;
    if (diff > EGO_REFRESH_TABLE_FOOTER_VIEW_HEIGHT && !loading) {
		if ([delegate_ respondsToSelector:@selector(egoRefreshTableFooterDidTriggerRefresh:)]) {
			[delegate_ egoRefreshTableFooterDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading];
        
        
        [UIView animateWithDuration:0.25 
                         animations:^{
                             scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, EGO_REFRESH_TABLE_FOOTER_VIEW_HEIGHT, 0.0f);
                         }];
        
		[UIView commitAnimations];
	}
}


- (void) egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView isInsetsZero:(BOOL)isInsetsZero {
    if (isInsetsZero) {
        [UIView animateWithDuration:0.25 
                         animations:^{
                             scrollView.contentInset = UIEdgeInsetsZero;
                         }];
    }
    
    [self setState:EGOOPullRefreshNormal];
}


- (void) dealloc {
    delegate_ = nil;
    
    //KD_RELEASE_SAFELY(statusLabel_);
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(indicatorBGView_);
    
    //[super dealloc];
}

@end
