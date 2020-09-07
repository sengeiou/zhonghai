//
//  KDProgressActionView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-3.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDProgressActionView.h"

#import "UIButton+Additions.h"

@interface KDProgressActionView ()

@property (nonatomic, retain) UIImageView *backgroundImageView;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *progressLabel;
@property (nonatomic, retain) UIProgressView *progressView;

@property (nonatomic, retain) UIImageView *dividerImageView;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;

@end


@implementation KDProgressActionView

@synthesize backgroundImageView=backgroundImageView_;

@synthesize titleLabel=titleLabel_;
@synthesize progressLabel=progressLabel_;
@synthesize progressView=progressView_;

@synthesize dividerImageView=dividerImageView_;
@synthesize activityView=activityView_;

- (void) setupProgressActionView {
    // background image view
    UIImage *image = [UIImage imageNamed:@"round_light_gray_bg.png"];
    image = [image stretchableImageWithLeftCapWidth:0.5*image.size.width topCapHeight:0.5*image.size.height];
    backgroundImageView_ = [[UIImageView alloc] initWithImage:image];
    
    [self addSubview:backgroundImageView_];
    
    // title label
    titleLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel_.backgroundColor = [UIColor clearColor];
    titleLabel_.font = [UIFont systemFontOfSize:16.0];
    titleLabel_.adjustsFontSizeToFitWidth = YES;
    titleLabel_.minimumScaleFactor = 12.0;
    
    titleLabel_.textColor = RGBCOLOR(31.0, 31.0, 31.0);
    
    [self addSubview:titleLabel_];
    
    // progress label
    progressLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    progressLabel_.backgroundColor = [UIColor clearColor];
    progressLabel_.font = [UIFont systemFontOfSize:15.0];
    progressLabel_.adjustsFontSizeToFitWidth = YES;
    progressLabel_.minimumScaleFactor = 12.0;
    progressLabel_.textAlignment = NSTextAlignmentCenter;
    
    progressLabel_.textColor = [UIColor grayColor];
    
    [self addSubview:progressLabel_];
    
    // progress view
    progressView_ = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [self addSubview:progressView_];
    
    // divider image view
    image = [UIImage imageNamed:@"cell_white_divider.png"];
    image = [image stretchableImageWithLeftCapWidth:0.5*image.size.width topCapHeight:0];
    dividerImageView_ = [[UIImageView alloc] initWithImage:image];
    dividerImageView_.bounds = CGRectMake(0.0, 0.0, 0.0, image.size.height);
    
    [self addSubview:dividerImageView_];
    
    // activity view
    activityView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:activityView_];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupProgressActionView];
    }
    
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    backgroundImageView_.frame = self.bounds;
    
    CGFloat offsetX = 10.0;
    CGFloat offsetY = 0.0;
    CGFloat width = self.bounds.size.width - 2*offsetX;
    
    // activity view
    CGRect rect = activityView_.bounds;
    rect.origin = CGPointMake(self.bounds.size.width - rect.size.width - 5.0, offsetY + (30.0 - rect.size.height) * 0.5);
    activityView_.frame = rect;
    
    // title label
    rect = CGRectMake(offsetX, offsetY, rect.origin.x - offsetX - 5.0, 30.0);
    titleLabel_.frame = rect;
    
    // divider image view
    offsetY = rect.origin.y + rect.size.height;
    rect = CGRectMake(1.0, offsetY, self.bounds.size.width - 2.0, dividerImageView_.bounds.size.height);
    dividerImageView_.frame = rect;
    
    // progress view
    offsetY = rect.origin.y + rect.size.height + 15.0;
    rect = CGRectMake(offsetX + (width - 120.0) * 0.5, offsetY, 120.0, 12.0);
    progressView_.frame = rect;
    
    // progress label
    offsetY = rect.origin.y + rect.size.height;
    rect = CGRectMake(offsetX, offsetY, width, 40.0);
    progressLabel_.frame = rect;
}

- (void) activeActivityView:(BOOL)active {
    if(active){
        if(![activityView_ isAnimating]){
            [activityView_ startAnimating];
        }
        
    }else {
        if([activityView_ isAnimating]){
            [activityView_ stopAnimating];
        }
    }
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(backgroundImageView_);
    
    //KD_RELEASE_SAFELY(titleLabel_);
    //KD_RELEASE_SAFELY(progressLabel_);
    //KD_RELEASE_SAFELY(progressView_);
    
    //KD_RELEASE_SAFELY(dividerImageView_);
    //KD_RELEASE_SAFELY(activityView_);
    
    //[super dealloc];
}

@end
