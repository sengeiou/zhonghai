//
//  RefreshTableFootView.m
//  TwitterFon
//
//  Created by kingdee on 11-6-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "KDCommon.h"

#import "RefreshTableFootView.h"
#define KD_TEXT_COLOR	 [UIColor colorWithRed:42/255.0 green:49/255.0 blue:56/255.0 alpha:1.0]
#define KD_BORDER_COLOR [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface RefreshTableFootView ()

@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) UIImageView *identifierImageView;

@end


@implementation RefreshTableFootView

@synthesize delegate=delegate_;
@synthesize state=state_;

@synthesize statusLabel=statusLabel_;
@synthesize activityView=activityView_;
@synthesize identifierImageView=identifierImageView_;
@synthesize reloadingFootView = reloadingFootView_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;          
        
        statusLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 15, self.frame.size.width, 20.0f)];
        statusLabel_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        statusLabel_.font = [UIFont systemFontOfSize:13.0f];
        statusLabel_.textColor = KD_TEXT_COLOR;
        //label.shadowColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
        //label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        statusLabel_.backgroundColor = [UIColor clearColor];
        statusLabel_.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:statusLabel_];   
    
        identifierImageView_ = [[UIImageView alloc ] initWithImage:[UIImage imageNamed:@"footImage.png"]];
        identifierImageView_.frame = CGRectMake(262,9,31,31);
        identifierImageView_.hidden = YES;
        
        [self addSubview:identifierImageView_];
        
        activityView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityView_.frame = CGRectMake(269.0f,  16.0f, 16.0f, 16.0f);
        [self addSubview:activityView_];
        
        [self setState:EGOOPullRefreshNormal];
        self.backgroundColor = [UIColor colorWithRed:215/255.0 green:220/255.0 blue:224/255.0 alpha:1.0];
    }
    
    return self;
    
}

//
//  EGORefreshTableHeaderView.h
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//修改人：禚来强 iphone开发qq群：79190809 邮箱：zhuolaiqiang@gmail.com
//原文地址：http://blog.csdn.net/diyagoanyhacker/archive/2011/05/24/6441805.aspx
#pragma mark -
#pragma mark Setters


- (void)setState:(EGOPullRefreshState)state{
    
    switch (state) {
        case EGOOPullRefreshPulling:           
            statusLabel_.text = NSLocalizedString(ASLocalizedString(@"RefreshTableFootView_Pulling_load"), ASLocalizedString(@"RefreshTableFootView_Pulling_update"));
            break;
            
        case EGOOPullRefreshNormal:            
            statusLabel_.text = NSLocalizedString(ASLocalizedString(@"RefreshTableFootView_Normal_load"), ASLocalizedString(@"RefreshTableFootView_Normal_update"));
            [activityView_ stopAnimating];
            identifierImageView_.hidden = YES;
            break;
            
        case EGOOPullRefreshLoading:           
            statusLabel_.text = NSLocalizedString(ASLocalizedString(@"RefreshTableFootView_Loading"), ASLocalizedString(@"RefreshTableFootView_Loading"));
            [activityView_ startAnimating];  
            identifierImageView_.hidden = NO;
            break;
            
        default:
            break;
    }
    
    state_ = state;
}


#pragma mark -
#pragma mark ScrollView Methods

//手指屏幕上不断拖动调用此方法
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {    
    
    if (state_ == EGOOPullRefreshLoading) 
    {
        
        //CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
        //offset = MIN(offset, 60);
        scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, RefreshViewHight, 0.0f);
        
    } else if (scrollView.isDragging) 
    {
        
        BOOL loading = NO;
        if ([delegate_ respondsToSelector:@selector(egoRefreshFooterDataSourceIsLoading:)]) {
            loading = [delegate_ egoRefreshFooterDataSourceIsLoading:self];
        }
        
        if (state_ == EGOOPullRefreshPulling && scrollView.contentOffset.y + (scrollView.frame.size.height) < scrollView.contentSize.height + RefreshViewHight && scrollView.contentOffset.y > 0.0f && !loading) {
            [self setState:EGOOPullRefreshNormal];
            
        } else if (state_ == EGOOPullRefreshNormal && scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshViewHight  && !loading) {
            [self setState:EGOOPullRefreshPulling];
        }
        
        if (scrollView.contentInset.bottom != 0) {
            scrollView.contentInset = UIEdgeInsetsZero;
        }
        
    }
    
}

//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    
    BOOL _loading = NO;
    if ([delegate_ respondsToSelector:@selector(egoRefreshFooterDataSourceIsLoading:)]) {
        _loading = [delegate_ egoRefreshFooterDataSourceIsLoading:self];
    }
    
    if (scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshViewHight && !_loading) 
    {
        
        if ([delegate_ respondsToSelector:@selector(egoRefreshFooterDidTriggerRefresh:)]) {
            [delegate_ egoRefreshFooterDidTriggerRefresh:self];
        }
        
        [self setState:EGOOPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, RefreshViewHight, 0.0f);
        [UIView commitAnimations];
        
    }
    
}

//当开发者页面页面刷新完毕调用此方法，[delegate egoRefreshScrollViewDataSourceDidFinishedLoading: scrollView];
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];
    
    [self setState:EGOOPullRefreshNormal];
    
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    delegate_ = nil;
    
    //KD_RELEASE_SAFELY(statusLabel_);
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(identifierImageView_);
    
    //[super dealloc];
}


@end
