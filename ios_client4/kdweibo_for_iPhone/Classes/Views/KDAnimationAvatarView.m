//
//  KDAnimationAvatarView.m
//  kdweibo
//
//  Created by shen kuikui on 13-11-19.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDAnimationAvatarView.h"
#import "KDIrregularImageView.h"

static NSString *const KDRotateAnimationKey = @"rotate";

@interface KDFlipImageView : UIView
{
    UIImageView *imageView1_;
    UIImageView *imageView2_;
    BOOL isImageOneShowing_;
}

@property (nonatomic, retain) UIImage *image;

- (id)initWithFrame:(CGRect)frame andDefaultImage:(UIImage *)image;

- (void)flipToImage:(UIImage *)image;

@end

@implementation KDFlipImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setupView];
        isImageOneShowing_ = YES;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andDefaultImage:(UIImage *)image
{
    self = [self initWithFrame:frame];
    if(self) {
        imageView1_.image = image;
    }
    
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(imageView1_);
    //KD_RELEASE_SAFELY(imageView2_);
    
    //[super dealloc];
}
- (void)layoutSubviews{
    [super layoutSubviews];
  
    imageView1_.frame = self.bounds;
    imageView2_.frame = self.bounds;
    imageView1_.layer.cornerRadius = CGRectGetWidth(self.bounds) * 0.5f;
    imageView2_.layer.cornerRadius = CGRectGetWidth(self.bounds) * 0.5f;
    
    self.layer.cornerRadius = CGRectGetWidth(self.bounds)*0.5f;
}
- (void)setupView
{
    imageView1_ = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView2_ = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView1_.layer.masksToBounds = YES;
    imageView2_.layer.masksToBounds = YES;
    imageView1_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView2_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView1_.contentMode = UIViewContentModeScaleAspectFit;
    imageView2_.contentMode = UIViewContentModeScaleAspectFit;

    
    [self addSubview:imageView2_];
    [self addSubview:imageView1_];
    
    self.clipsToBounds = YES;
}

- (void)flipToImage:(UIImage *)image
{
    if(isImageOneShowing_) {

        imageView2_.image = image;
    }else {
        imageView1_.image = image;
    }
    [UIView transitionFromView:(isImageOneShowing_ ? imageView1_ : imageView2_)
                        toView:(isImageOneShowing_ ? imageView2_ : imageView1_)
                      duration:0.75
                       options:UIViewAnimationOptionTransitionFlipFromLeft + UIViewAnimationOptionCurveEaseInOut
                    completion:^(BOOL finished){
                        if(finished) {
                            isImageOneShowing_ = !isImageOneShowing_;
                        }
                    }];
}

- (void)setImage:(UIImage *)image
{
    if(isImageOneShowing_) {
        imageView1_.image = image;
    }else {
        imageView2_.image = image;
    }
}

- (UIImage *)image
{
    if(isImageOneShowing_) {
        return imageView1_.image;
    }else {
        return imageView2_.image;
    }
}

@end

@interface KDAnimationAvatarView ()
{
    KDFlipImageView *avatarImageView_;
    UIImageView *borderImageView_;
    UIImageView *animateImageView_;
    
    NSString *avatarImageURL_;
    
    BOOL hasHighLight_;
    
    BOOL isRotatingWhenEnterBackground_;
}

@property (nonatomic, retain) KDFlipImageView   *avatarImageView;
@property (nonatomic, retain) UIImageView       *borderImageView;
@property (nonatomic, retain) UIImageView       *animatedImageView;

@end

@implementation KDAnimationAvatarView

@synthesize avatarImageView = avatarImageView_;
@synthesize borderImageView = borderImageView_;
@synthesize animatedImageView = animateImageView_;
@synthesize avatarImageURL = avatarImageURL_;

- (id)initWithFrame:(CGRect)frame andNeedHighLight:(BOOL)isNeed
{
    self = [super initWithFrame:frame];
    if(self) {
        hasHighLight_ = isNeed;
        [self setupView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andNeedHighLight:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //KD_RELEASE_SAFELY(avatarImageView_);
    //KD_RELEASE_SAFELY(borderImageView_);
    //KD_RELEASE_SAFELY(animateImageView_);
    //KD_RELEASE_SAFELY(avatarImageURL_);
    
    //[super dealloc];
}

- (void)setupView
{
    UIImage *logo = [UIImage imageNamed:@"sign_in_view_logo_v3"];
    UIImage *circle = [UIImage imageNamed:@"sign_in_view_circle_v3"];
    UIImage *animateImage = [UIImage imageNamed:@"sign_in_view_light_v3"];
    
//    CGFloat wRatio = logo.size.width / circle.size.width;
//    CGFloat hRatio = logo.size.height / circle.size.height;
    
//    CGSize  circleSize = self.frame.size;
//    CGSize  logoSize = CGSizeMake(circleSize.width * wRatio, circleSize.height * hRatio);
    
    self.avatarImageView = [[KDFlipImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)*0.12f, CGRectGetHeight(self.bounds)*0.12f, CGRectGetWidth(self.bounds) - CGRectGetWidth(self.bounds)*0.12f*2, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.bounds)*0.12f*2) andDefaultImage:logo];// autorelease];
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    self.animatedImageView = [[UIImageView alloc] initWithImage:animateImage] ;//autorelease];
    self.animatedImageView.frame = self.bounds;
    self.animatedImageView.hidden = !hasHighLight_;
    self.animatedImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.borderImageView = [[UIImageView alloc] initWithImage:circle] ;//autorelease];
    self.borderImageView.frame = self.bounds;
    self.borderImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:self.borderImageView];
    [self addSubview:self.animatedImageView];
    [self addSubview:self.avatarImageView];
    
    if(hasHighLight_) {
        [self rotate];
    }
}

- (void)didEnterBackground:(NSNotification *)notification
{
    isRotatingWhenEnterBackground_ = ([self.animatedImageView.layer animationForKey:KDRotateAnimationKey] != nil);
    [self stopRotate];
}

- (void)willEnterForeground:(NSNotification *)notification
{
    if(hasHighLight_ && isRotatingWhenEnterBackground_) {
        [self rotate];
    }
}

- (void)rotate
{
    CABasicAnimation *rotateAnimation = (CABasicAnimation *)[self.layer animationForKey:KDRotateAnimationKey];
    if(!rotateAnimation) {
        CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotateAnimation.fromValue = [NSNumber numberWithFloat:0 * M_PI];
        rotateAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
        rotateAnimation.repeatCount = HUGE_VALF;
        rotateAnimation.beginTime = CACurrentMediaTime();
        rotateAnimation.removedOnCompletion = YES;
        rotateAnimation.autoreverses = NO;
        rotateAnimation.duration = 1.0f;
        rotateAnimation.fillMode = kCAFillModeForwards;
        
        [self.animatedImageView.layer addAnimation:rotateAnimation forKey:KDRotateAnimationKey];
    }
}

- (void)rotateWithReaptCount:(float)repeateCount duration:(CFTimeInterval)duration andDelegate:(id)delegate
{
    [self stopRotate];
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0 * M_PI];
    rotateAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    rotateAnimation.repeatCount = repeateCount;
    rotateAnimation.beginTime = CACurrentMediaTime();
    rotateAnimation.removedOnCompletion = YES;
    rotateAnimation.autoreverses = NO;
    rotateAnimation.duration = duration;
    rotateAnimation.fillMode = kCAFillModeForwards;
    rotateAnimation.delegate = delegate;
    
    [self.animatedImageView.layer addAnimation:rotateAnimation forKey:KDRotateAnimationKey];
}

- (void)stopRotate
{
    [self.animatedImageView.layer removeAnimationForKey:KDRotateAnimationKey];
}

- (void)setAvatarImageURL:(NSString *)avatarImageURL
{
    if(avatarImageURL != avatarImageURL_ && ![avatarImageURL isEqualToString:avatarImageURL_]) {
//        [avatarImageURL_ release];
        avatarImageURL_ = [avatarImageURL copy];
        
        __block KDAnimationAvatarView *avatarView = self ;//retain];
        
        [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:avatarImageURL_] options:SDWebImageLowPriority | SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished){
        
            if ([url isEqual:[NSURL URLWithString:avatarImageURL_]] || [url absoluteString] == avatarImageURL_) {
                
                BOOL animated = YES;
                if (!image) {
                    animated = NO;
                    image = [UIImage imageNamed:@"user_avatar_placeholder_v3.png"];
                }
                
                [self changeAvatarImageTo:image animation:animated];
            }
            
//            [avatarView release];
        }];
    }
}

- (void)changeAvatarImageTo:(UIImage *)image animation:(BOOL)animated
{
    if(image == self.avatarImageView.image || image == nil) return;
    
    if(animated) {
        [self.avatarImageView flipToImage:image];
    }else {
        self.avatarImageView.image = image;
    }
}

- (BOOL)hasHighLight
{
    return hasHighLight_;
}

- (void)setNeedHighLight:(BOOL)isNeed
{
    if(isNeed != hasHighLight_) {
        if(isNeed) {
            self.animatedImageView.hidden = NO;
            [self rotate];
        }else {
            [self.animatedImageView.layer removeAnimationForKey:KDRotateAnimationKey];
            self.animatedImageView.hidden = YES;
        }
        hasHighLight_ = isNeed;
    }
}

- (UIImage *)ringImage
{
    return self.borderImageView.image;
}

- (void)setRingImage:(UIImage *)ringImage
{
    self.borderImageView.image = ringImage;
}

- (void)setAnimateImageViewHidden:(BOOL)hidden
{
    self.animatedImageView.hidden = hidden;
    self.borderImageView.hidden = hidden;
    if (hidden) {
        CGSize  circleSize = self.frame.size;
        self.avatarImageView.frame = CGRectMake((CGRectGetWidth(self.bounds) - circleSize.width) * 0.5f, (CGRectGetHeight(self.bounds) - circleSize.height) * 0.5f, circleSize.width, circleSize.height);
    }else {
        UIImage *logo = [UIImage imageNamed:@"sign_in_view_logo_v3"];
        UIImage *circle = [UIImage imageNamed:@"sign_in_view_circle_v3"];
        CGFloat wRatio = logo.size.width / circle.size.width;
        CGFloat hRatio = logo.size.height / circle.size.height;
        
        CGSize  circleSize = self.frame.size;
        CGSize  logoSize = CGSizeMake(circleSize.width * wRatio, circleSize.height * hRatio);
        
        self.avatarImageView.frame = CGRectMake((CGRectGetWidth(self.bounds) - logoSize.width) * 0.5f, (CGRectGetHeight(self.bounds) - logoSize.height) * 0.5f, logoSize.width, logoSize.height);
    }
}
@end
