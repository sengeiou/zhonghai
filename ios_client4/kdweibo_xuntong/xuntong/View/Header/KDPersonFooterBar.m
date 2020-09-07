//
//  KDPersonFooterBar.m
//  kdweibo
//
//  Created by Gil on 15/7/15.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPersonFooterBar.h"

@interface KDPersonFooterBar ()
@property (nonatomic, strong) UIButton *msgButton;
@property (nonatomic, strong) UIButton *callButton;
@property (nonatomic, strong) UIImageView *backgroundView;
@end

@implementation KDPersonFooterBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backgroundView];
        [self addSubview:self.msgButton];
        [self addSubview:self.callButton];
        
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - 1) / 2, (CGRectGetHeight(_backgroundView.bounds) - 14.0) / 2, 1, 14.0)];
        line.backgroundColor = [UIColor whiteColor];
        [self addSubview:line];
    }
    return self;
}

- (UIImageView *)backgroundView {
    if (_backgroundView == nil) {
        _backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"toolbar_other_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 21, 0, 21)]];
        _backgroundView.frame = self.bounds;
        _backgroundView.userInteractionEnabled = YES;
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(_backgroundView.bounds) - 1) / 2, (CGRectGetHeight(_backgroundView.bounds) - 14.0) / 2, 1, 14.0)];
        line.backgroundColor = [UIColor whiteColor];
        [_backgroundView addSubview:line];
    }
    return _backgroundView;
}

- (UIButton *)msgButton {
    if (_msgButton == nil) {
        _msgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_msgButton setImage:[UIImage imageNamed:@"profile_tip_message_normal"] forState:UIControlStateNormal];
        [_msgButton setImage:[UIImage imageNamed:@"profile_tip_message_normal"] forState:UIControlStateHighlighted];
        [_msgButton setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor2]] forState:UIControlStateNormal];
        [_msgButton setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor3]] forState:UIControlStateHighlighted];
        [_msgButton setTitle:ASLocalizedString(@"KDPersonFooterBar_Send")forState:UIControlStateNormal];
        [_msgButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_msgButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_msgButton.titleLabel setFont:FS5];
        [_msgButton setFrame:CGRectMake(.0, 1, CGRectGetWidth(self.bounds)/2+1 , CGRectGetHeight(self.bounds) - 1)];
        [_msgButton addTarget:self action:@selector(msgBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _msgButton;
}

- (UIButton *)callButton {
    if (_callButton == nil) {
        _callButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_callButton setImage:[UIImage imageNamed:@"profile_tip_phone_normal"] forState:UIControlStateNormal];
        [_callButton setImage:[UIImage imageNamed:@"profile_tip_phone_normal"] forState:UIControlStateHighlighted];
        [_callButton setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor2]] forState:UIControlStateNormal];
        [_callButton setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor3]] forState:UIControlStateHighlighted];
        [_callButton setTitle:ASLocalizedString(@"XTPersonDetailViewController_Call")forState:UIControlStateNormal];
        [_callButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_callButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_callButton.titleLabel setFont:FS5];
        [_callButton setFrame:CGRectMake(CGRectGetWidth(self.bounds)/2, 1, CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds) - 1)];
        [_callButton addTarget:self action:@selector(callBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callButton;
}

#pragma mark - button pressed

- (void)msgBtnPressed:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(personFooterViewMsgButtonPressed:)]) {
        [self.delegate personFooterViewMsgButtonPressed:self];
    }
}

- (void)callBtnPressed:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(personFooterViewPhoneButtonPressed:)]) {
        [self.delegate personFooterViewPhoneButtonPressed:self];
    }
}

@end
