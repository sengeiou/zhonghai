//
//  KDBadgeView.m
//  kdweibo
//
//  Created by Tan Yingqi on 14-4-18.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDBadgeView.h"

#import "KDCommon.h"

#define KD_BADGE_PADDING  5.0f

@interface KDBadgeView ()

@property(nonatomic, retain) UIImageView *backgroundImageView;
@property(nonatomic, retain) UILabel *textLabel;


@end


@implementation KDBadgeView

@synthesize backgroundImageView=backgroundImageView_;
@synthesize textLabel=textLabel_;
@synthesize badgeValue = badgeValue_;
@synthesize badgeColor = badgeColor_;

- (void)setupBadgeIndicatorView {
    // background image layer
    backgroundImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    //backgroundImageView_.hidden = YES;
    
    // set default badge imag
    [self addSubview:backgroundImageView_];
    
    textLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    //textLabel_.hidden = YES;
    
    textLabel_.backgroundColor = [UIColor clearColor];
    textLabel_.font = [UIFont systemFontOfSize:12];
    textLabel_.textColor = [UIColor whiteColor];
    textLabel_.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:textLabel_];
    self.userInteractionEnabled = NO;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        badgeValue_ = 0;
        
        [self setupBadgeIndicatorView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if([self badgeIndicatorVisible]) {
        self.hidden = NO;
        backgroundImageView_.frame = self.bounds;
        [textLabel_ sizeToFit];
        textLabel_.center = backgroundImageView_.center;
    }else {
        self.hidden = YES;
    }
    
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize theSize = CGSizeZero;
    if (badgeValue_ > 0) {
        CGFloat h;
        CGFloat w;
        [textLabel_ sizeToFit];
        if (badgeValue_ < 100) {
            h = MAX(CGRectGetHeight(textLabel_.bounds), CGRectGetWidth(textLabel_.bounds));
            theSize = CGSizeMake(h+KD_BADGE_PADDING, h+KD_BADGE_PADDING);
        }else {
            h = CGRectGetHeight(textLabel_.bounds)+ KD_BADGE_PADDING+2;
            w = CGRectGetWidth(textLabel_.bounds) + KD_BADGE_PADDING +5;
            theSize =CGSizeMake(w, h);
        }
        
    }else {
        if (backgroundImageView_.image) {
            theSize =  [[self class] greenPointBackgroundImage].size;
        }
    }
    return theSize;
}

- (void)setBadgeValue:(NSInteger)badgeValue {
    if(badgeValue_ != badgeValue){
        badgeValue_ = badgeValue;
        // [self reload];
        self.hidden = ![self badgeIndicatorVisible];
        if ([self backgroundImageView]) {
            NSString *string = (badgeValue_ > 99) ? @"99+" :(badgeValue_ < 0 ? @"":[NSString stringWithFormat:@"%ld", (long)badgeValue_]);
            self.textLabel.text = string;
        }
  
    }
}

- (NSInteger)badgeValue {
    return badgeValue_;
}

- (void)setBadgeColor:(UIColor *)badgeColor {
    textLabel_.textColor = badgeColor;
}

- (void)setbadgeTextFont:(UIFont *)font {
    textLabel_.font = font;
}

- (UIColor *)badgeColor {
    return textLabel_.textColor;
}

- (void)setBadgeBackgroundImage:(UIImage *)image {
    backgroundImageView_.image = image;
    // [backgroundImageView_ sizeToFit];
}

- (BOOL)badgeIndicatorVisible {
    if(badgeValue_ == -1) {
        return YES;
    }else {
        return badgeValue_ > 0;
    }
}


+ (UIImage *)redGroupBackgroundImage
{
    UIImage *image = [UIImage imageNamed:@"group_new_bg.png"];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}
+ (UIImage *)tipBadgeBackgroundImage
{
    UIImage *image = [UIImage imageNamed:@"tip_view_badge_bg_v2.png"];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

+ (UIImage *)redBadgeBackgroundImage {
    UIImage *image = [UIImage imageNamed:@"red_badge_bg.png"];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

+ (UIImage *)newRedBadgeBackgroundImage {
    UIImage *image = [UIImage imageNamed:@"common_img_new"];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}
+ (UIImage *)XTRedBadgeBackgroudImage {
    UIImage *image = [UIImage imageNamed:@"dm_img_newnum.png"];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

+ (UIImage *)redLeftBadgeBackgroundImag
{
    UIImage *image = [UIImage imageNamed:@"red_badge_bg_v3.png"];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}
+ (UIImage *)redTeamBadgeBackgroundImag
{
    UIImage *image = [UIImage imageNamed:@"red_team_bg_v3.png"];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}
+ (UIImage *)greenPointBackgroundImage {
    return [UIImage imageNamed:@"green_point_v2.png"];
}


+ (UIImage *)smallRedGroupBackgroundImage
{
    UIImage *image = [UIImage imageNamed:@"small_red_badge_bg.png"];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(backgroundImageView_);
    //KD_RELEASE_SAFELY(textLabel_);
    
    //[super dealloc];
}

@end

