//
//  KDRefreshTableViewSideViewTopForiPhone.m
//  Test
//
//  Created by shen kuikui on 12-8-29.
//  Copyright (c) 2012年 shen kuikui. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KDRefreshTableViewSideViewTopForiPhone.h"
#import "UIColor+KDV6.h"

@implementation KDRefreshTableViewSideViewTopForiPhone

- (void)dealloc
{
    //KD_RELEASE_SAFELY(lastUpdatedLabel_);
    //KD_RELEASE_SAFELY(arrowImage_);
    //KD_RELEASE_SAFELY(tipInfoLabel_);
    //KD_RELEASE_SAFELY(activity_);
    //KD_RELEASE_SAFELY(_normalText);
    //KD_RELEASE_SAFELY(_pullingText);
    
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
            if(state_ == KDPullRefreshPulling){
                [CATransaction begin];
                [CATransaction setAnimationDuration:KD_REFRESHTABLEVIEW_FLIP_ANIMATION_DURATION];
                arrowImage_.transform = CATransform3DIdentity;
                [CATransaction commit];
            }
            tipInfoLabel_.text = _normalText;
            
            [activity_ stopAnimating];
            
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            arrowImage_.hidden = NO;
            arrowImage_.transform = CATransform3DIdentity;
            [CATransaction commit];
            
            tipInfoLabel_.hidden = NO;
            
            break;
        case KDPullRefreshPulling:
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:KD_REFRESHTABLEVIEW_FLIP_ANIMATION_DURATION];
            arrowImage_.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
            [CATransaction commit];
            
            tipInfoLabel_.text = _pullingText;
            tipInfoLabel_.hidden = NO;
            break;
        case KDPullRefreshLoading:
            
            [activity_ startAnimating];
            
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            arrowImage_.hidden = YES;
            [CATransaction commit];
            
            tipInfoLabel_.hidden = YES;
            
            break;
        default:
            break;
    }
    
    state_ = state;
}

- (void)refreshUpdatedTime:(NSDate *)date
{
    if (self.showUpdataTime) {
        if(date == nil)
            lastUpdatedLabel_.text = ASLocalizedString(@"UpdateTime_Never");
        else
            lastUpdatedLabel_.text = [NSString stringWithFormat:ASLocalizedString(@"UpdateTime"),FORMATEDATE(date)];
    }else {
        lastUpdatedLabel_.text = @"";
    }
    
}

- (void)setShowUpdataTime:(BOOL)showUpdataTime
{
    _showUpdataTime = showUpdataTime;
    if (!showUpdataTime) {
         lastUpdatedLabel_.text = @"";
    }
}

- (BOOL)isLoading
{
    return (KDPullRefreshLoading == state_);
}


- (void)setUpView
{
    self.backgroundColor = [UIColor kdBackgroundColor1];//RGBCOLOR(237, 237, 237);
    
    _pullingText = ASLocalizedString(@"Release_refresh");//retain];
    
    _normalText  = ASLocalizedString(@"PullDown_refresh");//retain];
    
    _showUpdataTime= YES;
    
    //set last updated time label
    lastUpdatedLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
    lastUpdatedLabel_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lastUpdatedLabel_.font = [UIFont systemFontOfSize:12.0f];
    lastUpdatedLabel_.textColor = KD_REFRESHTABLEVIEW_SIDEVIEW_TEXT_COLOR;
    lastUpdatedLabel_.backgroundColor = [UIColor clearColor];
    lastUpdatedLabel_.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lastUpdatedLabel_];
    
    //set arrow image
    UIImage *arrow = [UIImage imageNamed:@"refresh_arrow_v3.png"];
    arrowImage_ = [[CALayer alloc] init];
    arrowImage_.frame = CGRectMake((self.frame.size.width - arrow.size.width) * 0.5f, CGRectGetMinY(lastUpdatedLabel_.frame) - arrow.size.height - 5.0f, arrow.size.width, arrow.size.height);
    arrowImage_.contentsGravity = kCAGravityResizeAspect;
    arrowImage_.contents = (id)arrow.CGImage;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        arrowImage_.contentsScale = [[UIScreen mainScreen] scale];
    }
#endif
    
    [[self layer] addSublayer:arrowImage_];
    
    //set tip info label
    tipInfoLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    tipInfoLabel_.backgroundColor = [UIColor clearColor];
    tipInfoLabel_.textColor = KD_REFRESHTABLEVIEW_SIDEVIEW_TEXT_COLOR;
    tipInfoLabel_.font = [UIFont systemFontOfSize:12.0f];
    [self addSubview:tipInfoLabel_];
    
    //set activity
    activity_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:activity_];
    
    state_ = -1;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [tipInfoLabel_ sizeToFit];
    
    lastUpdatedLabel_.frame = CGRectMake(0.0f, CGRectGetHeight(self.frame) - 30.0f, CGRectGetWidth(self.frame), 20.0f);
    
    CGSize arrowSize = arrowImage_.frame.size;
    CGSize tipSize = tipInfoLabel_.bounds.size;
    CGFloat paddingBetweenArrowAndTip = 8.0f;
    
    arrowImage_.frame = CGRectMake((CGRectGetWidth(self.frame) - paddingBetweenArrowAndTip - arrowSize.width - tipSize.width) * 0.5f, CGRectGetMinY(lastUpdatedLabel_.frame) - arrowSize.height - 5.0f, arrowSize.width, arrowSize.height);
    tipInfoLabel_.frame = CGRectMake(CGRectGetMaxX(arrowImage_.frame) + paddingBetweenArrowAndTip, CGRectGetMinY(arrowImage_.frame) + (arrowSize.height - tipSize.height) * 0.5f, tipSize.width, tipSize.height);
    activity_.frame = CGRectMake((CGRectGetWidth(self.frame) - CGRectGetWidth(activity_.bounds)) * 0.5f, CGRectGetMinY(lastUpdatedLabel_.frame) - ([self respondHeight] - (CGRectGetHeight(self.frame) - CGRectGetMinY(lastUpdatedLabel_.frame)) - CGRectGetHeight(activity_.bounds)) * 0.5f - CGRectGetHeight(activity_.bounds), CGRectGetWidth(activity_.bounds), CGRectGetHeight(activity_.bounds));
}

- (CGFloat)respondHeight
{
    return 60.0f;
}

@end
