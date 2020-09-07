//
//  KDABRefreshTableHeaderView.m
//  kdweibo
//
//  Created by laijiandong on 12-11-7.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDABRefreshTableHeaderView.h"

@interface KDABRefreshTableHeaderView ()

@property(nonatomic, retain) UIImageView *backgroundImageView;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, retain, readonly) UILabel *infoLabel;

@end

@implementation KDABRefreshTableHeaderView {
 @private
    KDPullRefreshState state_;
}

@synthesize backgroundImageView=backgroundImageView_;
@synthesize activityIndicatorView=activityIndicatorView_;
@synthesize infoLabel=infoLabel_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupRefreshTableHeaderView];
    }
    
    return self;
}

- (void)_setupRefreshTableHeaderView {
    // background image view
    UIImage *bgImage = [UIImage imageNamed:@"refresh_background_v2.png"];
    backgroundImageView_ = [[UIImageView alloc] initWithImage:bgImage];
    [self addSubview:backgroundImageView_];
    
    //set status label
    infoLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    infoLabel_.backgroundColor = [UIColor clearColor];
    infoLabel_.font = [UIFont systemFontOfSize:15.0f];
    infoLabel_.textColor = KD_REFRESHTABLEVIEW_SIDEVIEW_TEXT_COLOR;
    infoLabel_.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:infoLabel_];
    
    //set activity
    activityIndicatorView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:activityIndicatorView_];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    backgroundImageView_.frame = self.bounds;
    
    CGFloat bottomVisibleHeight = [self respondHeight];
    
    CGFloat offsetX = 10.0;
    CGFloat offsetY = self.bounds.size.height - bottomVisibleHeight;
    
    // activity view
    CGRect rect = activityIndicatorView_.bounds;
    rect.origin = CGPointMake(offsetX, offsetY + (bottomVisibleHeight - rect.size.height) * 0.5);
    activityIndicatorView_.frame = rect;
    
    // info label
    rect = CGRectMake(0.0, offsetY + (bottomVisibleHeight - 30.0) * 0.5, self.bounds.size.width, 30.0);
    infoLabel_.frame = rect;
}


//////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDRefreshTableViewSideView protocol methods

- (void)setStatus:(KDPullRefreshState)state {
    if(state_ == state) return;
    
    if (KDPullRefreshNormal == state) {
        [activityIndicatorView_ stopAnimating];
        infoLabel_.text = nil;
    
    } else if(KDPullRefreshPulling == state){
        infoLabel_.text = nil;
    
    } else if(KDPullRefreshLoading == state){
        [activityIndicatorView_ startAnimating];
        infoLabel_.text = ASLocalizedString(@"RecommendViewController_Load");
    }
    
    state_ = state;
}

- (BOOL)isLoading {
    return KDPullRefreshLoading == state_;
}

- (CGFloat)respondHeight {
    return 48.0f;
}

- (void)refreshUpdatedTime:(NSDate *)date {

}

- (void)dealloc {
    //KD_RELEASE_SAFELY(backgroundImageView_);
    //KD_RELEASE_SAFELY(infoLabel_);
    //KD_RELEASE_SAFELY(activityIndicatorView_);
    
    //[super dealloc];
}

@end
