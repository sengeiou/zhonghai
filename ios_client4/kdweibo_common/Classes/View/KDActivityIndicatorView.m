//
//  KDActivityIndicatorView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-17.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "KDCommon.h"
#import "KDActivityIndicatorView.h"

@interface KDActivityIndicatorView ()

@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) UILabel *infoLabel;

- (void)setupActivityIndicatorView;

@end


@implementation KDActivityIndicatorView {
@private
    UIActivityIndicatorView *activityView_;
    UILabel *infoLabel_;
}

@synthesize activityView=activityView_;
@synthesize infoLabel=infoLabel_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupActivityIndicatorView];
    }
    
    return self;
}

- (void)setupActivityIndicatorView {
    self.backgroundColor = RGBACOLOR(35.0, 35.0, 35.0, 0.8);
    self.layer.cornerRadius = 8.0;
    
    // activity indicator view
    activityView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:activityView_];
    
    // info label
    infoLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    
    infoLabel_.backgroundColor = [UIColor clearColor];
    infoLabel_.textColor = [UIColor whiteColor];
    infoLabel_.font = [UIFont systemFontOfSize:15.0];
    infoLabel_.lineBreakMode = NSLineBreakByTruncatingTail;
    infoLabel_.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:infoLabel_];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat labelHeight = 30.0;
    CGFloat offsetY = (self.bounds.size.height - (activityView_.bounds.size.height + labelHeight)) * 0.5;
    
    if(infoLabel_.text == nil || [infoLabel_.text length] < 1) {
        activityView_.center = CGPointMake(self.bounds.size.width * 0.5f, self.bounds.size.height * 0.5f);
        
    } else {
        CGRect rect = activityView_.bounds;
        rect.origin = CGPointMake((self.bounds.size.width - rect.size.width) * 0.5, offsetY);
        activityView_.frame = rect;
        
        rect = CGRectMake(0.0, rect.origin.y + rect.size.height, self.bounds.size.width, labelHeight);
        infoLabel_.frame = rect;
    }
}

- (void)startAnimatingWithInfo:(NSString *)info {
    if(![activityView_ isAnimating]){
        [activityView_ startAnimating];
    }
    
    infoLabel_.text = info;
    
    [self setNeedsLayout];
}

- (void)stopAnimating {
    if([activityView_ isAnimating]){
        [activityView_ stopAnimating];
    }
}

- (void) setVisible:(BOOL)visible {
    self.alpha = visible ? 1.0 : 0.0;
}

- (void)activityViewWithVisible:(BOOL)visible animated:(BOOL)animated {
    if(animated){
        [UIView animateWithDuration:0.25
                         animations:^{
                             [self setVisible:visible];
                         }];
    }else {
        [self setVisible:visible];
    }
}

- (void)show:(BOOL)animated info:(NSString *)info {
    [self startAnimatingWithInfo:info];
    [self activityViewWithVisible:YES animated:animated];
}

- (void)hide:(BOOL)animated {
    [self stopAnimating];
    [self activityViewWithVisible:NO animated:animated];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(infoLabel_);
    
    //[super dealloc];
}

@end
