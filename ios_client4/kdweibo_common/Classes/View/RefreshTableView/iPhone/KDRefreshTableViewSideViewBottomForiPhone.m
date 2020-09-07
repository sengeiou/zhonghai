//
//  KDRefreshTableViewSideViewBottomForiPhone.m
//  Test
//
//  Created by shen kuikui on 12-8-30.
//  Copyright (c) 2012年 shen kuikui. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "KDRefreshTableViewSideViewBottomForiPhone.h"
#import "UIColor+KDV6.h"

@implementation KDRefreshTableViewSideViewBottomForiPhone

- (void)dealloc
{
    statusLabel_ = nil;
    activity_ = nil;
    
    //[super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setUpView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUpView];
    }
    return self;
}

#pragma mark - KDRefreshTableViewSideView Methods

- (void)setStatus:(KDPullRefreshState)state
{
    if(state_ == state) return;
    
    switch (state) {
        case KDPullRefreshNormal:
            [activity_ stopAnimating];
            statusLabel_.text = NSLocalizedString(@"PULL_UP_TO_UPDATE", @"");
            break;
        case KDPullRefreshPulling:
            statusLabel_.text = NSLocalizedString(@"RELEASE_TO_UPDATE", @"");
            break;
        case KDPullRefreshLoading:
            [activity_ startAnimating];
            statusLabel_.text = ASLocalizedString(@"RecommendViewController_Load");
            break;
        default:
            break;
    }
    
    state_ = state;
}

- (BOOL)isLoading
{
    return (KDPullRefreshLoading == state_);
}

- (void)setUpView
{
    self.backgroundColor = [UIColor kdBackgroundColor1];//RGBCOLOR(237, 237, 237);
    
    //set status label
    statusLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    statusLabel_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    statusLabel_.font = [UIFont systemFontOfSize:13.0f];
    statusLabel_.textColor = KD_REFRESHTABLEVIEW_SIDEVIEW_TEXT_COLOR;
    statusLabel_.backgroundColor = [UIColor clearColor];
    statusLabel_.textAlignment = NSTextAlignmentCenter;
    [self addSubview:statusLabel_];
//    [statusLabel_ release];
    
    //set activity
    activity_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:activity_];
//    [activity_ release];
    
    state_ = -1;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [statusLabel_ sizeToFit];
    statusLabel_.frame = CGRectMake((CGRectGetWidth(self.frame) - CGRectGetWidth(statusLabel_.bounds)) * 0.5f, ([self respondHeight] - CGRectGetHeight(statusLabel_.bounds)) * 0.5f, CGRectGetWidth(statusLabel_.bounds), CGRectGetHeight(statusLabel_.bounds));
    activity_.frame = CGRectMake(CGRectGetMaxX(statusLabel_.frame) + 10.0f, ([self respondHeight] - CGRectGetHeight(activity_.bounds)) * 0.5f, CGRectGetWidth(activity_.bounds), CGRectGetHeight(activity_.bounds));
}

- (CGFloat)respondHeight
{
    return 48.0f;
}


@end
