//
//  KDNavigationMenuButton.m
//  kdweibo
//
//  Created by Tan yingqi on 13-11-20.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDNavigationMenuButton.h"

@implementation KDNavigationMenuButton
@synthesize titleLabel = titleLabel_;
@synthesize iconImageView = iconImageView_;
@synthesize arrow = arrow_;
@synthesize isActive = isActive_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        iconImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:iconImageView_];
        
        frame.origin.y -= 2.0;
        titleLabel_  = [[UILabel alloc] initWithFrame:frame] ;
        titleLabel_.textAlignment = NSTextAlignmentCenter;
        titleLabel_.backgroundColor = [UIColor clearColor];
        titleLabel_.textColor = [UIColor whiteColor];
        titleLabel_.font = [UIFont boldSystemFontOfSize:20.0];
     
        [self addSubview:titleLabel_];
        
        UIImage *image = [UIImage imageNamed:@"title_view_arrow"];
        arrow_ = [[UIImageView alloc] initWithImage:image];
        [self addSubview:self.arrow];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [iconImageView_ sizeToFit];
    [titleLabel_ sizeToFit];
    CGPoint center = [[KDWeiboAppDelegate getAppDelegate] window].center;
    center = [self convertPoint:center fromView:[[KDWeiboAppDelegate getAppDelegate] window]];
    center.y = CGRectGetHeight(self.bounds)*0.5;
    titleLabel_.center = center;
    iconImageView_.center = CGPointMake(CGRectGetMinX(titleLabel_.frame) - CGRectGetMidX(iconImageView_.bounds) - 5, titleLabel_.center.y);
    arrow_.center = CGPointMake(CGRectGetMaxX(titleLabel_.frame) + 10, self.frame.size.height / 2);
    
}

#pragma mark - Deallocation
- (void)dealloc {
    //KD_RELEASE_SAFELY(titleLabel_);
    //KD_RELEASE_SAFELY(iconImageView_);
    //KD_RELEASE_SAFELY(arrow_);
    //[super dealloc];
}
@end