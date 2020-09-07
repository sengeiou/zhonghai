//
//  KDRefreshTableViewSideViewBottomForiPad.m
//  kdweibo_common
//
//  Created by shen kuikui on 12-10-26.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDRefreshTableViewSideViewBottomForiPad.h"

@implementation KDRefreshTableViewSideViewBottomForiPad

- (void)dealloc
{
    statusLabel_ = nil;
    indicatorBackground_ = nil;
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
            indicatorBackground_.hidden = YES;
            [activity_ stopAnimating];
            statusLabel_.text = NSLocalizedString(@"PULL_UP_TO_UPDATE", @"");
            break;
        case KDPullRefreshPulling:
            statusLabel_.text = NSLocalizedString(@"RELEASE_TO_UPDATE", @"");
            break;
        case KDPullRefreshLoading:
            indicatorBackground_.hidden = NO;
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
    //set background image
//    UIImage *backgroundImage = [UIImage imageNamed:@"refresh_backgroud.png"];
//    UIImageView *backgroundImageView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
//    [backgroundImageView setFrame:CGRectMake(0.0f, 0.0f, backgroundImage.size.width, backgroundImage.size.height)];
//    [self addSubview:backgroundImageView];
    self.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:222.0/255.0 blue:213.0/255.0 alpha:1.0];
    //set status label
    statusLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, ([self respondHeight] - 20.0f) / 2, self.frame.size.width, 20.0f)];
    statusLabel_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    statusLabel_.font = [UIFont systemFontOfSize:13.0f];
    statusLabel_.textColor = KD_REFRESHTABLEVIEW_SIDEVIEW_TEXT_COLOR;
    statusLabel_.backgroundColor = [UIColor clearColor];
    statusLabel_.textAlignment = NSTextAlignmentCenter;
    [self addSubview:statusLabel_];
//    [statusLabel_ release];
    
    //set indicator background image view
    UIImage *bgImage = [UIImage imageNamed:@"footImage.png"];
    indicatorBackground_ = [[UIImageView alloc] initWithImage:bgImage];
    indicatorBackground_.frame = CGRectMake(self.frame.size.width - bgImage.size.width - 10.0f, ([self respondHeight] - bgImage.size.height) / 2, bgImage.size.width, bgImage.size.height);
    [self addSubview:indicatorBackground_];
//    [indicatorBackground_ release];
    
    //set activity
    activity_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activity_.center = indicatorBackground_.center;
    [self addSubview:activity_];
//    [activity_ release];
    
    state_ = -1;
}

- (CGFloat)respondHeight
{
    return 48.0f;
}



@end
