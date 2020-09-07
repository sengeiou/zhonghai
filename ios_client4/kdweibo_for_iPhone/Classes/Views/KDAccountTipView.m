//
//  KDAccountTipView.m
//  kdweibo
//
//  Created by 王 松 on 13-10-25.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDAccountTipView.h"

#import <QuartzCore/QuartzCore.h>
#import "KDAnimationFactory.h"

@interface KDAccountTipView()

@property (nonatomic, retain) UIView *bgView;

@property (nonatomic, retain) UIView *mainView;

@property (nonatomic, retain) UIImageView *infoImageView;

@property (nonatomic, retain) UIWindow *alertWindow;

@property (nonatomic, retain) UIWindow *oldKeyWindow;

@property (nonatomic, retain) UIButton *button;

@property (nonatomic, retain) UILabel *titleLabel;

@property (nonatomic, retain) UILabel *msgLabel;

@end

@implementation KDAccountTipView

- (id)init
{
    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)btntitle completeBlock:(void (^)(void))block
{
    if (self = [super init]) {
        _titleLabel.text = title;
        _msgLabel.text = message;
        [_button setTitle:btntitle forState:UIControlStateNormal];
        _title = title ;//retain];
        _message = message;// retain];
        _buttonTitle = btntitle;// retain];
        _block =block;
    }
    return self;

}

- (void)setupViews
{
    _bgView = [[UIView alloc] initWithFrame:CGRectZero];
    _bgView.backgroundColor = [UIColor blackColor];
    [self addSubview:_bgView];
    
    _mainView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainView.layer.masksToBounds = YES;
    _mainView.layer.cornerRadius = 5.0f;
    _mainView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0];
    [self addSubview:_mainView];
    
    _infoImageView = [[UIImageView alloc] initWithImage:nil];
    [_mainView addSubview:_infoImageView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont systemFontOfSize:19.0f];
    _titleLabel.minimumScaleFactor = 14.0f;
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_mainView addSubview:_titleLabel];
    
    _msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _msgLabel.backgroundColor = [UIColor clearColor];
    _msgLabel.font = [UIFont systemFontOfSize:16.f];
    _msgLabel.textColor = RGBCOLOR(109, 109, 109);
    _msgLabel.adjustsFontSizeToFitWidth = YES;
    _msgLabel.textAlignment = NSTextAlignmentCenter;
    _msgLabel.minimumScaleFactor = 12.f;
    _msgLabel.numberOfLines = 0;
    [_mainView addSubview:_msgLabel];

    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.layer.borderColor = RGBCOLOR(203, 203, 203).CGColor;
    _button.layer.borderWidth = 1.0f;
    _button.layer.cornerRadius = 5.0f;
    _button.layer.masksToBounds = YES;
    [_button setTitle:ASLocalizedString(@"Global_Sure")forState:UIControlStateNormal];
    [_button setTitleColor:RGBCOLOR(109, 109, 109) forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_mainView addSubview:_button];
}

- (void)buttonAction:(id)sender
{
    CAAnimation *animation = [KDAnimationFactory alertDismissAnimationWithDuration:0.25];
    animation.delegate = self;
    [self.mainView.layer addAnimation:animation forKey:@"dismiss"];
    [self.bgView.layer addAnimation:[KDAnimationFactory windowFadeOutAnimationWithDuration:0.25] forKey:@"fadeOut"];
    if (_block) {
        double delayInSeconds = 0.25;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            _block();
        });
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _bgView.frame = self.bounds;
    
    CGFloat inset = 20.f;
    
    _mainView.frame = CGRectMake(inset, (CGRectGetHeight(self.frame) - (CGRectGetWidth(self.frame) - inset * 2.f)) / 2.f - 20.f, CGRectGetWidth(self.frame) - inset * 2.f, CGRectGetWidth(self.frame) - inset * 2.f);
    
    _infoImageView.frame = CGRectMake((CGRectGetWidth(_mainView.frame) - _infoImageView.image.size.width) / 2.f, 30.0f, _infoImageView.image.size.width, _infoImageView.image.size.height);
    
    if (_message && _message.length > 0) {
        _titleLabel.frame = CGRectMake(10.f, CGRectGetMidY(_infoImageView.frame) + 40.f, CGRectGetWidth(_mainView.frame) - 20.f, 40.f);
        
        _msgLabel.frame = CGRectMake(10.f, CGRectGetMidY(_titleLabel.frame) + 20.f, CGRectGetWidth(_mainView.frame) - 20.f, 40.f);
    }else {
        _titleLabel.frame = CGRectMake(10.f, CGRectGetMidY(_infoImageView.frame) + 80.f, CGRectGetWidth(_mainView.frame) - 20.f, 40.f);
        
        _msgLabel.frame = CGRectZero;
    }

    _button.frame = CGRectMake(10.f, CGRectGetHeight(_mainView.frame) - 60.f, CGRectGetWidth(_mainView.frame) - 20.f, 40.f);
}

- (void)showWithType:(KDAccountTipViewType)type window:(UIWindow *)window
{
    self.oldKeyWindow = window;

    UIImage *image = nil;
    switch (type) {
        case KDAccountTipViewTypeFaild:
            image = [UIImage imageNamed:@"account_failed_icon_v3.png"];
            break;
        case KDAccountTipViewTypeAlert:
            image = [UIImage imageNamed:@"account_alert_icon_v3.png"];
            break;
        case KDAccountTipViewTypeSuccess:
        default:
            image = [UIImage imageNamed:@"account_success_icon_v3.png"];
            break;
    }
    
    _infoImageView.image = image;
    
    UIWindow *keyWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    keyWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    keyWindow.opaque = NO;
    keyWindow.windowLevel = UIWindowLevelAlert;
    
    CGRect rect = keyWindow.bounds;
//    rect.origin.y += 20.0; // skip the status bar
//    rect.size.height -= 20.0;
    self.frame = rect;
    [keyWindow addSubview:self];
    [keyWindow makeKeyAndVisible];
    self.alertWindow = keyWindow;
//    [keyWindow release];
    
    [self.bgView.layer addAnimation:[KDAnimationFactory windowFadeInAnimationWithDuration:0.25] forKey:@"fadeIn"];
    [self.mainView.layer addAnimation:[KDAnimationFactory alertShowAnimationWithDuration:0.27] forKey:@"show"];
}

- (void)setTitle:(NSString *)title
{
    if (_title != title) {
//        [_title release];
        _title = title;// retain];
        _titleLabel.text = title;
    }
}

- (void)setMessage:(NSString *)message
{
    if (_message != message) {
//        [_message release];
        _message = message;// retain];
        _msgLabel.text = message;
    }
}

- (void)setButtonTitle:(NSString *)buttonTitle
{
    if (_buttonTitle != buttonTitle) {
//        [_buttonTitle release];
        _buttonTitle = buttonTitle ;//retain];
        [_button setTitle:buttonTitle forState:UIControlStateNormal];
    }
}

#pragma mark - CAAnimation Delegate Method
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.mainView.layer removeAnimationForKey:@"dismiss"];
    [self.bgView.layer removeAnimationForKey:@"fadeOut"];
    
    [self.oldKeyWindow makeKeyAndVisible];
    [self.alertWindow removeFromSuperview];
    self.alertWindow = nil;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_alertWindow);
    //KD_RELEASE_SAFELY(_bgView);
    //KD_RELEASE_SAFELY(_mainView);
    //KD_RELEASE_SAFELY(_infoImageView);
    //KD_RELEASE_SAFELY(_titleLabel);
    //KD_RELEASE_SAFELY(_msgLabel);
    //KD_RELEASE_SAFELY(_title);
    //KD_RELEASE_SAFELY(_buttonTitle);
    //KD_RELEASE_SAFELY(_message);
//    Block_release(_block);
    //[super dealloc];
}

@end
