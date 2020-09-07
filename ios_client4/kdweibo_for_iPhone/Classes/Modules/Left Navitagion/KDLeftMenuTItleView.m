//
//  KDLeftMenuTItleView.m
//  KDLeftMenu
//
//  Created by 王 松 on 14-4-16.
//  Copyright (c) 2014年 Song.wang. All rights reserved.
//

#import "KDLeftMenuTitleView.h"

#import "KDAnimationAvatarView.h"

#import "KDBadgeIndicatorView.h"

#import <QuartzCore/QuartzCore.h>

#import "UserDataModel.h"

#import "KDManagerContext.h"

#import "ContactConfig.h"
#import "BOSSetting.h"

#import "BOSConfig.h"

#import "NSDictionary+Additions.h"

#define kKDLeftMenuAvatarWidth 58.f
#define kKDLeftMenuAvatarHeight kKDLeftMenuAvatarWidth
#define kKDLeftMenuLabelMaxWidth 120.f
#define kKDLeftMenuBadgeWidth 10.f

typedef NS_ENUM(NSUInteger, KDActionButtonType)
{
    KDActionButtonTypeUp,
    KDActionButtonTypeDown
};

@interface KDLeftMenuTitleView ()

@property (nonatomic, retain) KDAnimationAvatarView *avatarView;

@property (nonatomic, retain) UILabel *nameLabel;

@property (nonatomic, retain) UILabel *currentCommunityLabel;

@property (nonatomic, retain) KDBadgeIndicatorView *badgeImageView;
@property (nonatomic, retain) KDBadgeIndicatorView *draftBadgeImageView;

@property (nonatomic, retain) UIButton *actionButton;

@property (nonatomic, assign) KDActionButtonType type;

@property (nonatomic, retain) UIView *separatorView;

@property (nonatomic, retain) NSArray *animationLayers;
@property (nonatomic, retain) NSArray *upAnimationLayers;
@property (nonatomic, assign) BOOL    isAnimatingWhenEnterBackground;

@property (nonatomic, retain) UIView *tapMaskView;

@end

@implementation KDLeftMenuTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = KDActionButtonTypeDown;
        _shouldShowTipAnimation = NO;
        [self setupViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdate:) name:kKDCommunityDidChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdate:) name:KDProfileUserNameUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdate:) name:KDProfileUserAvatarUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadCount:) name:kKDMessageNoticeNumChangeNotification object:nil];
    }
    return self;
}

- (void)setupViews
{
    _avatarView = [[KDAnimationAvatarView alloc] initWithFrame:CGRectMake(15.f, 53.f, kKDLeftMenuAvatarWidth, kKDLeftMenuAvatarHeight)];
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _currentCommunityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    _badgeImageView = [[KDBadgeIndicatorView alloc] initWithFrame:CGRectZero];
    [_badgeImageView setBadgeBackgroundImage:[KDBadgeIndicatorView redLeftBadgeBackgroundImag]];
    
    _draftBadgeImageView = [[KDBadgeIndicatorView alloc] initWithFrame:CGRectZero];
    [_draftBadgeImageView setBadgeBackgroundImage:[KDBadgeIndicatorView redLeftBadgeBackgroundImag]];

    _actionButton = [UIButton buttonWithType:UIButtonTypeCustom] ;//retain];
    [_actionButton setImage:[UIImage imageNamed:@"drop_down"] forState:UIControlStateNormal];
    [_actionButton setImage:[UIImage imageNamed:@"drop_up"] forState:UIControlStateHighlighted];
    [_actionButton sizeToFit];
    [_actionButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableArray *layers = [NSMutableArray array];
    for(NSInteger index = 0; index < 3; index++) {
        CALayer *layer = [CALayer layer];
        layer.contents = (id)[UIImage imageNamed:@"drop_down"].CGImage;
        layer.opacity = 0.5f + index * 0.15;
        layer.hidden = YES;
        [self.layer addSublayer:layer];
        [layers addObject:layer];
    }
    
    NSMutableArray *upLayers = [NSMutableArray array];
    CGImageRef upImage = [UIImage imageNamed:@"drop_down"].CGImage;
    for(NSInteger index = 0; index < 3; index++) {
        CALayer *layer = [CALayer layer];
        layer.contents = (__bridge id)upImage;
        layer.affineTransform = CGAffineTransformMakeRotation(M_PI);
        layer.opacity = 0.5f + index * 0.15;
        layer.hidden = YES;
        [self.layer addSublayer:layer];
        [upLayers addObject:layer];
    }
    
    _animationLayers = [[NSArray alloc] initWithArray:layers];
    _upAnimationLayers = [[NSArray alloc]initWithArray:upLayers];
    
    _separatorView = [[UIView alloc] init];
    _separatorView.backgroundColor = UIColorFromRGBA(0xffffff, 0.1);
//    _separatorView.backgroundColor = UIColorFromRGB(0x000000);
    
    _nameLabel.backgroundColor = [UIColor clearColor];
//    _nameLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
    _nameLabel.textColor = UIColorFromRGB(0xffffff);
    _nameLabel.font = [UIFont systemFontOfSize:16.f];
    
    _currentCommunityLabel.backgroundColor = [UIColor clearColor];
    _currentCommunityLabel.textColor = UIColorFromRGB(0xc5c9d9); // [[UIColor whiteColor] colorWithAlphaComponent:0.65];
    _currentCommunityLabel.font = [UIFont systemFontOfSize:14.f];
    
    [_avatarView setAnimateImageViewHidden:YES];
    [_avatarView changeAvatarImageTo:[UIImage imageNamed:@"user_avatar_placeholder_v3.png"] animation:NO];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile:)];
    [_avatarView addGestureRecognizer:tap];
//    [tap release];
    
    [self addSubview:_avatarView];
    [self addSubview:_nameLabel];
    [self addSubview:_currentCommunityLabel];
    [self addSubview:_badgeImageView];
//    [self addSubview:_draftBadgeImageView];
    [self addSubview:_actionButton];
    [self addSubview:_separatorView];
    
    [self userInfoUpdate:nil];
    
    UITapGestureRecognizer *communityTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(communityTapped)];
    
    UIView *tapMaskView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:tapMaskView];
//    [tapMaskView release];
    
    [tapMaskView addGestureRecognizer:communityTap];
    tapMaskView.userInteractionEnabled = YES;
    
//    [communityTap release];
    
    self.tapMaskView = tapMaskView;
}
- (void)unreadCount:(NSNotification *)noti {

    NSInteger number = [[noti userInfo] integerForKey:@"count" defaultValue:0];
    [_badgeImageView setBadgeValue:number];
    
    [self setNeedsDisplay];
}
- (void)userInfoUpdate:(NSNotification *)noti {
    
    //放弃原的用户名，改用login 返回的用户名
    KDUser *user = [KDManagerContext globalManagerContext].userManager.currentUser;
   // _nameLabel.text = user.username;
    _nameLabel.text = [BOSConfig sharedConfig].user.name;
    _avatarView.avatarImageURL = user.profileImageUrl;
    self.currentCommunityLabel.text = [BOSSetting sharedSetting].customerName;
    [self setNeedsLayout];
}
- (void)updateDraft:(NSInteger)count{
    _draftBadgeImageView.badgeValue = count;
}
- (void)setBadgeViewHidden:(BOOL)hidden
{
    self.badgeImageView.hidden = hidden;
}

#define kActionButtonWidth 30
#define kActionButtonHeight 82

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat spacing = 15.f;
    
    
    CGSize size = [_nameLabel sizeThatFits:CGSizeMake(kKDLeftMenuLabelMaxWidth, 20.f)];
    size.width = MIN(size.width, kKDLeftMenuLabelMaxWidth);
    
    _nameLabel.frame = CGRectMake(spacing + CGRectGetMaxX(_avatarView.frame), CGRectGetMidY(_avatarView.frame) - size.height + 3.f, size.width, size.height);
    
    size = [_currentCommunityLabel sizeThatFits:CGSizeMake(kKDLeftMenuLabelMaxWidth, 20.f)];
    size.width = MIN(size.width, kKDLeftMenuLabelMaxWidth);
    
    _currentCommunityLabel.frame = CGRectMake(spacing + CGRectGetMaxX(_avatarView.frame), CGRectGetMaxY(_nameLabel.frame) + 5.f, size.width, size.height);
    
    CGFloat arrowWidth  = kActionButtonWidth;
    CGFloat arrowHeigth = kActionButtonHeight;
    
    _actionButton.frame = CGRectMake(CGRectGetWidth(self.frame) - kActionButtonWidth - 4, CGRectGetMaxY(_currentCommunityLabel.frame) - arrowHeigth*0.6, arrowWidth, arrowHeigth);
    UIImage *image = [UIImage imageNamed:@"drop_down"];
    NSInteger count = _animationLayers.count;
    for(NSInteger index = 0; index < count; index++) {
        CALayer *layer = (CALayer *)_animationLayers[index];
        layer.frame = CGRectMake(CGRectGetWidth(self.frame) - kActionButtonWidth , CGRectGetMidY(_actionButton.frame) - (image.size.height * 0.75) * (3 - index) - 4.0f, image.size.width, image.size.height);
    }
    
    NSInteger upCount = _upAnimationLayers.count;
    for(NSInteger index = 0; index < upCount; index++) {
        CALayer *layer = (CALayer *)_upAnimationLayers[index];
        layer.frame = CGRectMake(CGRectGetWidth(self.frame) - kActionButtonWidth, CGRectGetMidY(_actionButton.frame) - (image.size.height * 0.75) * (3 - index) - 4.0f, image.size.width, image.size.height);
    }
    /*
    size = [_draftBadgeImageView getBadgeContentSize];
    _draftBadgeImageView.frame = CGRectMake(CGRectGetMaxX(_avatarView.frame) - kKDLeftMenuBadgeWidth , CGRectGetMinY(_avatarView.frame) -10, size.width, size.height);
    */
    
    size = [_badgeImageView getBadgeContentSize];
    _badgeImageView.frame = CGRectMake(CGRectGetMinX(_actionButton.frame) , CGRectGetMidY(_nameLabel.frame) - kKDLeftMenuBadgeWidth * 0.5 -5, size.width, size.height);
    
    _separatorView.frame = CGRectMake(CGRectGetMinX(_avatarView.frame), CGRectGetMaxY(_avatarView.frame) + 25.f, CGRectGetWidth(self.frame), 1);
    
    _tapMaskView.frame = CGRectMake(CGRectGetMaxX(_avatarView.frame), CGRectGetMinY(_avatarView.frame), CGRectGetMaxX(_actionButton.frame) -CGRectGetMaxX(_avatarView.frame) , CGRectGetMaxY(_avatarView.frame) - CGRectGetMinY(_avatarView.frame) + 10.f);
}

- (void)actionButtonClicked:(id)sender
{
    if (!self.actionButton.enabled) {
        return;
    }
    _type = !_type;
    [self stopTipAnimation];

    if (_type == KDActionButtonTypeUp) {
        [self rotateArrow:M_PI];
    }else {
        
        [self rotateArrow:0];
    }
    if ([_delegate respondsToSelector:@selector(leftMenuTitleView:actionButtonClicked:)]) {
        [_delegate leftMenuTitleView:self actionButtonClicked:sender];
    }
}

- (void)communityTapped
{
    [self actionButtonClicked:_actionButton];
}

- (void)resetActionButtonRotate
{
    _type = KDActionButtonTypeDown;
    [self stopTipAnimation];
    [self rotateArrow:0];
}
- (void)showListActionButtonRotate{
    if (_type != KDActionButtonTypeUp) {
        _type = KDActionButtonTypeUp;
        [self stopTipAnimation];
        [self rotateArrow:M_PI];
    }
}
- (void)rotateArrow:(float)degrees {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.actionButton.imageView.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
    } completion:^(BOOL finished) {
            [self startTipAnimation];
    }];
}

- (void)showProfile:(UIGestureRecognizer *)gesture
{
    if ([_delegate respondsToSelector:@selector(leftMenuTitleView:showProfile:)]) {
        [_delegate leftMenuTitleView:self showProfile:gesture.view];
    }
}

- (void)startTipAnimation
{
    if(!_shouldShowTipAnimation) return;
//    if(!CATransform3DEqualToTransform(self.actionButton.imageView.layer.transform, CATransform3DIdentity)) return;
    
    if(_type == KDActionButtonTypeDown){
        NSUInteger count = _animationLayers.count;
        CGFloat interval = 1 / 6.0f;
        for(NSUInteger idx = 0; idx < count; idx++) {
            CALayer *layer = (CALayer *)_animationLayers[idx];
            
            if(layer && ![layer animationForKey:@"flash"]) {
                CAKeyframeAnimation *key = [CAKeyframeAnimation animationWithKeyPath:@"hidden"];
                key.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                key.values = @[@(NO), @(YES), @(NO)];
                key.keyTimes = @[@(0.0f), @(interval + idx * interval), @(interval * (idx + 4))];
                key.duration = 0.9f;
                key.repeatCount = HUGE_VALF;
            
                [layer addAnimation:key forKey:@"flash"];
            }
        }
    }
    else{
        NSUInteger count = _upAnimationLayers.count;
        CGFloat interval = 1/6.0f;
        for(NSInteger idx = count - 1; idx >= 0 ; idx--){
            CALayer *layer = (CALayer *)[_upAnimationLayers objectAtIndex:idx];
            
            if(layer && ![layer animationForKey:@"flash"]){
                CAKeyframeAnimation *key = [CAKeyframeAnimation animationWithKeyPath:@"hidden"];
                key.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                key.values = @[@(NO), @(YES), @(NO)];
                key.keyTimes = @[@(0.0f), @(interval + (count - idx) * interval), @(interval * (count - idx + 4))];
                key.duration = 0.9f;
                key.repeatCount = HUGE_VALF;
                
                [layer addAnimation:key forKey:@"flash"];

            }
        }
    }
    
    
}

- (void)stopTipAnimation
{
    if(_type == KDActionButtonTypeUp){
        for(CALayer *layer in _animationLayers) {
            [layer removeAnimationForKey:@"flash"];
        }
    }
    else{
        for(CALayer *layer in _upAnimationLayers){
            [layer removeAnimationForKey:@"flash"];
        }
    }
}

- (void)willEnterForeground:(NSNotification *)noti
{
    if(_isAnimatingWhenEnterBackground) {
        [self startTipAnimation];
    }
}

- (void)didEnterBackground:(NSNotification *)noti
{
    if([_animationLayers count] > 0 || [_upAnimationLayers count] > 0) {
        _isAnimatingWhenEnterBackground = YES;
        [self stopTipAnimation];
    }
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint center = self.avatarView.center;
    CGFloat radius = self.avatarView.frame.size.width/2 + 1;
    //头像加一个圆环
    [path addArcWithCenter:center radius:radius startAngle:M_PI_2*3 endAngle:M_PI_2*3-2*M_PI clockwise:NO];
    
    [[UIColor colorWithHexRGB:@"0x636e80"] setStroke];
    path.lineWidth = 2;
    
    [path stroke];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //KD_RELEASE_SAFELY(_tapMaskView);
    //KD_RELEASE_SAFELY(_avatarView);
    //KD_RELEASE_SAFELY(_nameLabel);
    //KD_RELEASE_SAFELY(_currentCommunityLabel);
    //KD_RELEASE_SAFELY(_badgeImageView);
    //KD_RELEASE_SAFELY(_actionButton);
    //KD_RELEASE_SAFELY(_separatorView);
    //KD_RELEASE_SAFELY(_animationLayers);
    //KD_RELEASE_SAFELY(_upAnimationLayers);
    //[super dealloc];
}

@end
