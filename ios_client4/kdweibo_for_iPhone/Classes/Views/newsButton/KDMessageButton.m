//
//  KDLeftMsgButton.m
//  kdweibo
//
//  Created by gordon_wu on 13-11-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//
#define MSG_IMAGE_TAG 200
#import "KDMessageButton.h"

@implementation KDMessageButton

@synthesize msgImage = msgImage_;

@synthesize bageImageView = bageImageView_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColor = RGBCOLOR(arc4random() % 255, arc4random() % 255, arc4random() % 255);
        [self setupViews];
    }
    return self;
}

- (void) setMsgImage:(UIImage *)msgImage
{
    
    msgImage_ = msgImage;// retain];
    
    UIImageView * imageView = [[UIImageView alloc] initWithImage:msgImage];
    //    图片+文字时 王松 2013-12-05
    if (self.imageView.image) {
        imageView.frame         = CGRectMake(CGRectGetMaxX(self.imageView.frame) - 5.f,5,msgImage_.size.width,msgImage_.size.height);
    }else { //只有文字时
        imageView.frame         = CGRectMake(self.frame.size.width-15,5,msgImage_.size.width,msgImage_.size.height);
    }
    imageView.hidden        = YES;
    imageView.tag           = MSG_IMAGE_TAG;
    [self addSubview:imageView];
    //KD_RELEASE_SAFELY(imageView);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([self.bageImageView badgeIndicatorVisible]) {
        [self layoutBadgeIndicatorView];
    }
}

- (void)setupViews;
{
     bageImageView_ = [[KDBadgeIndicatorView alloc] initWithFrame:CGRectZero];
    [bageImageView_ setBadgeBackgroundImage:[KDBadgeIndicatorView smallRedGroupBackgroundImage]];
    [bageImageView_ setBadgeColor:[UIColor whiteColor]];
    [bageImageView_ setbadgeTextFont:[UIFont systemFontOfSize:10.f]];
    [self addSubview:bageImageView_];
}

- (void)setBadgeValue:(NSInteger)badgeValue
{
    self.bageImageView.badgeValue = badgeValue;
    
    if ([self.bageImageView badgeIndicatorVisible]) {
        [self layoutBadgeIndicatorView];
    }
}

- (void)layoutBadgeIndicatorView
{
    if (self.imageView.image) {
        CGSize contentSize = [self.bageImageView getBadgeContentSize];
        CGRect rect = self.bageImageView.frame;
        rect.size = contentSize;
        self.bageImageView.frame = rect;
        CGPoint point = CGPointMake(CGRectGetMaxX(self.imageView.frame), CGRectGetMinY(self.imageView.frame) + 8.f);
        self.bageImageView.center = point;
    }
}

- (void) showMsgImage:(BOOL) isShow
{
    UIImageView * imageView = (UIImageView *)[self viewWithTag:MSG_IMAGE_TAG];
    imageView.hidden        = !isShow;
}

- (void) dealloc
{
    //KD_RELEASE_SAFELY(msgImage_);
    //KD_RELEASE_SAFELY(bageImageView_);
    //[super dealloc];
}

@end
