//
//  KDProgressIndicatorView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-25.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDProgressIndicatorView.h"

@interface KDProgressIndicatorView ()

@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) UILabel *progressLabel;

@end

@implementation KDProgressIndicatorView

@synthesize activityView=activityView_;
@synthesize progressView=progressView_;
@synthesize progressLabel=progressLabel_;

- (void) setupProgressIndicatorView {
    // activity indicator view
    activityView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:activityView_];
    
    // progress view
    progressView_ = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [self addSubview:progressView_];
    progressView_.hidden = YES;
    
    // progress label
    progressLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    progressLabel_.backgroundColor = [UIColor clearColor];
    progressLabel_.font = [UIFont systemFontOfSize:14.0];
    progressLabel_.adjustsFontSizeToFitWidth = YES;
    progressLabel_.minimumScaleFactor = 11.0;
    progressLabel_.textColor = [UIColor blackColor];
    progressLabel_.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:progressLabel_];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        
        [self setupProgressIndicatorView];
    }
    
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 3.0;
    CGFloat width = self.bounds.size.width;
    
    CGRect rect = activityView_.bounds;
    rect.origin = CGPointMake((width - rect.size.width) * 0.5, offsetY);
    activityView_.frame = rect;
    
    offsetY += rect.size.height + 3.0;
    
    offsetX = (width - 120.0) * 0.5;
    rect = CGRectMake(offsetX, offsetY, 120.0, 12.0);
    progressView_.frame = rect;
    
    offsetY += rect.size.height + 3.0;
    progressLabel_.frame = CGRectMake(0.0, offsetY, width, 30.0);
}

- (void) setAvtivityIndicatorStartAnimation:(BOOL)start {
    if(start){
        if(![activityView_ isAnimating]){
            [activityView_ startAnimating];
        }
        
    }else {
        if([activityView_ isAnimating]){
            [activityView_ stopAnimating];
        }
    }
}

- (void) setProgressPercent:(float)percent info:(NSString *)info {
    progressView_.progress = percent;
    progressLabel_.text = info;
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(progressView_);
    //KD_RELEASE_SAFELY(progressLabel_);
    
    //[super dealloc];
}

@end
