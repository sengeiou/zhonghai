//
//  KDProgressView.m
//  kdweibo
//
//  Created by bird on 13-12-30.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDProgressView.h"

@implementation KDProgressView
@synthesize progress = progress_;
@synthesize progressTintColor = progressTintColor_;
@synthesize trackTintColor = trackTintColor_;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setViews];
    }
    return self;
}
- (void)setViews
{
    trackView_ = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:trackView_];
    
    if (trackTintColor_ == nil)
        self.trackTintColor = UIColorFromRGB(0xdddddd);
    
    progressView_ = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:progressView_];
    if (progressTintColor_ == nil)
        self.progressTintColor = UIColorFromRGB(0x1a85ff);
    
    progress_ = 0.0f;
}
- (void)setTrackTintColor:(UIColor *)trackTintColor
{
    if (trackTintColor_) {
//        [trackTintColor_ release];
        trackTintColor_ = nil;
    }
    trackTintColor_ = trackTintColor;// retain];
    
    trackView_.backgroundColor = trackTintColor_;
}
- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    if (progressTintColor_) {
//        [progressTintColor_ release];
        progressTintColor_ = nil;
    }
    progressTintColor_ = progressTintColor;// retain];
    
    progressView_.backgroundColor = progressTintColor_;
}
- (void)setProgress:(float)progress
{
    if (progress <=0.0f) {
        progress =0.0f;
    }
    if (progress >=1.0f) {
        progress = 1.0f;
    }
    
    progress_ = progress;
    
    [self setNeedsLayout];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    trackView_.frame = self.bounds;
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGFloat progress_width = width *progress_;
    
    if (progress_width > width)
        progress_width = width;
    
    progressView_.frame = CGRectMake(0, 0, progress_width, height);
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)dealloc
{
    //KD_RELEASE_SAFELY(progressView_);
    //KD_RELEASE_SAFELY(trackView_);
    //KD_RELEASE_SAFELY(progressTintColor_);
    //KD_RELEASE_SAFELY(trackTintColor_);
    //[super dealloc];
}
@end
