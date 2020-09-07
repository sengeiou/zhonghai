//
//  KDMultipartyCallBannerView.m
//  kdweibo
//
//  Created by Darren on 15/7/27.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDMultipartyCallBannerView.h"

@interface KDMultipartyCallBannerView ()

@property (nonatomic, strong) UIImageView *imageViewIcon;
@property (nonatomic, strong) UIImageView *imageViewArrow;
@property (nonatomic, strong) UIButton *buttonConfirm;

@end

@implementation KDMultipartyCallBannerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = FC10;
        self.alpha = .9;
        
        [self addSubview:self.imageViewIcon];

        [self.imageViewIcon makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.left).with.offset(9);
             make.width.mas_equalTo(20);
             make.height.mas_equalTo(20);
             make.centerY.equalTo(self.centerY);
         }];
        
        [self addSubview:self.imageViewArrow];

        [self.imageViewArrow makeConstraints:^(MASConstraintMaker *make)
         {
             make.right.equalTo(self.right).with.offset(-12);
             make.width.mas_equalTo(7);
             make.height.mas_equalTo(13);
             make.centerY.equalTo(self.centerY);
         }];
        
        [self addSubview:self.labelTitle];

        [self.labelTitle makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.imageViewIcon.right).with.offset(23);
             make.right.equalTo(self.imageViewArrow.left).with.offset(-23);
             make.centerY.equalTo(self.centerY);
         }];
        
        [self addSubview:self.buttonConfirm];

        [self.buttonConfirm makeConstraints:^(MASConstraintMaker *make)
         {
             make.edges.equalTo(self).with.insets(UIEdgeInsetsZero);
         }];

    }
    return self;
}

- (UIImageView *)imageViewIcon
{
    if (!_imageViewIcon)
    {
        _imageViewIcon = [UIImageView new];
        _imageViewIcon.image = [UIImage imageNamed:@"message_img_phone_1"];
    }
    return _imageViewIcon;
}

- (UIImageView *)imageViewArrow
{
    if (!_imageViewArrow)
    {
        _imageViewArrow = [UIImageView new];
        _imageViewArrow.image = [UIImage imageNamed:@"phone_btn_enter_down"];
    }
    return _imageViewArrow;
}

- (UILabel *)labelTitle
{
    if (!_labelTitle)
    {
        _labelTitle = [UILabel new];
        _labelTitle.font = FS5;
        _labelTitle.textColor = FC6;
    }
    return _labelTitle;
}

- (UIButton *)buttonConfirm
{
    if (!_buttonConfirm)
    {
        _buttonConfirm = [UIButton new];
        [_buttonConfirm addTarget:self action:@selector(buttonConfirmPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonConfirm;
}

- (void)buttonConfirmPressed
{
    if (self.blockButtonConfirmPressed)
    {
        self.blockButtonConfirmPressed();
    }
}



@end
