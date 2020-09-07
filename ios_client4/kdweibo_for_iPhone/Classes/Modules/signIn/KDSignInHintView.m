//
//  KDSignInHintView.m
//  kdweibo
//
//  Created by lichao_liu on 7/17/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDSignInHintView.h"
@interface KDSignInHintView()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation KDSignInHintView

- (instancetype)initWithFrame:(CGRect)frame 
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        [self addSubview:self.bgImageView];
        [self addSubview:self.titleLabel];
//        [self addSubview:self.cancelBtn];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenCancleBtnClicked:)];
        [self addGestureRecognizer:tap];
     }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bgImageView.frame = self.bounds;

   if(self.signInHintType == KDSignInHintType_share)
    {
        self.titleLabel.frame = CGRectMake(5, 37.5, 130, 20);
//        self.cancelBtn.frame = CGRectMake(138, 40, 15, 15);
     }else{
         self.titleLabel.frame = CGRectMake(5, 40, 200, 45);
//         self.cancelBtn.frame = CGRectMake(180, 53, 15, 15);
    }
}

- (UILabel *)titleLabel
{
    if(!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = FC6;
        _titleLabel.font = FS4;
        _titleLabel.numberOfLines = 2;
         _titleLabel.text = ASLocalizedString(@"KDSignInHintView_titleLabel_text_init");
      }
    return _titleLabel;
}

- (UIImageView *)bgImageView
{
    if(!_bgImageView)
    {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bgImageView.image= [UIImage imageNamed:@"sign_bg_blacktipsleft"];
     }
    return _bgImageView;
}

- (UIButton *)cancelBtn
{
    if(!_cancelBtn)
    {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"sign_btn_x_nor"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(whenCancleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (void)whenCancleBtnClicked:(id)sender
{
    [self removeFromSuperview];
}

- (void)setSignInHintType:(KDSignInHintType)signInHintType
{
    _signInHintType = signInHintType;
    if(signInHintType == KDSignInHintType_share)
    {
        self.titleLabel.text = ASLocalizedString(@"KDSignInHintView_titleLabel_text_init");
    }else{
//        self.titleLabel.text = ASLocalizedString(@"KDSignInHintView_titleLabel_text_prompt");
    }
}
@end
