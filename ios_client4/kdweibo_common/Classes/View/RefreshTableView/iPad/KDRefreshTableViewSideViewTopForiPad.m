//
//  KDRefreshTableViewSideViewTopForiPad.m
//  kdweibo_common
//
//  Created by shen kuikui on 12-10-26.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "KDRefreshTableViewSideViewTopForiPad.h"
#import "UIColor+KDV6.h"

@implementation KDRefreshTableViewSideViewTopForiPad

- (void)dealloc
{
    cloudImageView_ = nil;
    arrowImage_ = nil;
    lastUpdatedLabel_ = nil;
    activity_ = nil;
    
    //[super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //[self setUpView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUpViewWithFrame:frame];
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
            
            [activity_ stopAnimating];
            
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            arrowImage_.hidden = NO;
            arrowImage_.transform = CATransform3DIdentity;
            [CATransaction commit];
            
            cloudImageView_.hidden = NO;
            break;
        case KDPullRefreshPulling:
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:KD_REFRESHTABLEVIEW_FLIP_ANIMATION_DURATION];
            arrowImage_.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
            [CATransaction commit];
            
            
            break;
        case KDPullRefreshLoading:
            
            [activity_ startAnimating];
            
            cloudImageView_.hidden = YES;
            
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            arrowImage_.hidden = YES;
            [CATransaction commit];
            
            break;
        default:
            break;
    }
    
    state_ = state;
}

- (void)refreshUpdatedTime:(NSDate *)date
{
    if(date == nil)
        lastUpdatedLabel_.text = ASLocalizedString(@"UpdateTime_Never");
    else
        lastUpdatedLabel_.text = [NSString stringWithFormat:ASLocalizedString(@"UpdateTime"),FORMATEDATE(date)];
    
}

- (BOOL)isLoading
{
    return (KDPullRefreshLoading == state_);
}


- (void)setUpViewWithFrame:(CGRect)frame
{
    //set background image
    //    UIImage *backgroundImage = [UIImage imageNamed:@"refresh_background_v2.png"];
    //    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width * 0.5f topCapHeight:backgroundImage.size.height * 0.5f];
    //    UIImageView *backgroundImageView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
    //    [backgroundImageView setFrame:CGRectMake(0.0f, self.frame.size.height - backgroundImage.size.height, backgroundImage.size.width, backgroundImage.size.height)];
    //    [self addSubview:backgroundImageView];
     self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor kdBackgroundColor1];//[UIColor colorWithRed:224.0/255.0 green:222.0/255.0 blue:213.0/255.0 alpha:1.0];
    
    //set last updated time label
    lastUpdatedLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, frame.size.width, 20.0f)];
    lastUpdatedLabel_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lastUpdatedLabel_.font = [UIFont systemFontOfSize:12.0f];
    lastUpdatedLabel_.textColor = KD_REFRESHTABLEVIEW_SIDEVIEW_TEXT_COLOR;
    lastUpdatedLabel_.backgroundColor = [UIColor clearColor];
    lastUpdatedLabel_.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lastUpdatedLabel_];
//    [lastUpdatedLabel_ release];
    
    
    //set arrow image
    UIImage *arrow = [UIImage imageNamed:@"refreshArrow.png"];
    arrowImage_ = [[CALayer alloc] init];
    arrowImage_.frame = CGRectMake(100.0f, frame.size.height - 50.0f, 22, 39);
    arrowImage_.contentsGravity = kCAGravityResizeAspect;
    arrowImage_.contents = (id)arrow.CGImage;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        arrowImage_.contentsScale = [[UIScreen mainScreen] scale];
    }
#endif
    
    [[self layer] addSublayer:arrowImage_];
//    [arrowImage_ release];
    
    
    //set activity
    activity_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity_.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
    [self addSubview:activity_];
   
    
    state_ = -1;
}

- (CGFloat)respondHeight
{
    return self.frame.size.height - activity_.frame.origin.y;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
