//
//  KDInviteHint View.m
//  kdweibo
//
//  Created by AlanWong on 14-10-13.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDInviteHintView.h"
@interface KDInviteHintView()
@property (nonatomic,strong) UIButton * bgButton;
@property (nonatomic,strong) UIImageView * bgImageView;
@property (nonatomic,strong) UIButton * inviteButton;
@property (nonatomic,strong) UILabel * tipsLabel;
@property (nonatomic,strong) UIButton * checkButton;
@property (nonatomic,strong) UIButton *buttonTip;
@property (nonatomic, assign) BOOL bDontBotherMe;
@end
@implementation KDInviteHintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bgButton];
        [self addSubview:self.bgImageView];
        [self addSubview:self.inviteButton];
        [self addSubview:self.tipsLabel];
        [self addSubview:self.buttonTip];
       // [self addSubview:self.checkButton];
    }
    return self;
}
-(UIButton *)bgButton{
    if (!_bgButton) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:self.bounds];
        [button addTarget:self action:@selector(bgButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _bgButton = button;
    }
    return _bgButton;
}
-(UIImageView * )bgImageView{
    if (_bgImageView) {
        return _bgImageView;
    }
    NSString * imageName = isAboveiPhone5 ? @"college_img_newuser" : @"college_img_newuser960";
    UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    [imageView setFrame:self.bounds];
    _bgImageView = imageView;
    return _bgImageView;
}

-(UIButton *)inviteButton{
    if (_inviteButton) {
        return _inviteButton;
    }
    CGFloat originY = isAboveiPhone5 ? 200 : 170;
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:ASLocalizedString(@"马上邀请")forState:UIControlStateNormal];
    [button setBackgroundColor:BOSCOLORWITHRGBA(0x1A85FF,1.0)];
    [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button.titleLabel setTextColor:[UIColor whiteColor]];
    [button setFrame:CGRectMake(0, originY, 183, 44)];
    [button setCenter:CGPointMake(self.center.x, button.center.y)];
    button.layer.cornerRadius = 5.0f;
    [button addTarget:self action:@selector(inviteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _inviteButton = button;
    return _inviteButton;
}

-(UILabel *)tipsLabel{
    if (_tipsLabel) {
        return _tipsLabel;
    }
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.text = ASLocalizedString(@"KDInviteHintView_Tip");
    label.font = [UIFont systemFontOfSize:14.0f];
    label.textColor = BOSCOLORWITHRGBA(0xAEAEAE, 1.0);
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    UIView * bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, label.bounds.size.height -1, label.bounds.size.width, 1)];
    [bottomLine setBackgroundColor:BOSCOLORWITHRGBA(0xAEAEAE, 1.0)];
    [label addSubview:bottomLine];
    [label setFrame:CGRectMake(self.center.x - label.frame.size.width/2,
                              CGRectGetMaxY(self.inviteButton.frame) + 20,
                              label.frame.size.width,
                               label.frame.size.height)];
    _tipsLabel = label;
    return _tipsLabel;
}

- (UIButton *)buttonTip
{
    if (!_buttonTip)
    {
        _buttonTip = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonTip.frame = self.tipsLabel.frame;
        [_buttonTip addTarget:self action:@selector(buttonTipPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonTip;
}

- (void)buttonTipPressed
{
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kContactMaskHidenForever];
    [self removeFromSuperview];
}

//-(UIButton *)checkButton{
//    if (!_checkButton) {
//        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setImage:[UIImage imageNamed:@"task_checkbox_unselected"] forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@"task_checkbox_selected"] forState:UIControlStateSelected];
//        [button sizeToFit];
//        button.center = CGPointMake(CGRectGetMinX(self.tipsLabel.frame) - 40, self.tipsLabel.center.y);
//        [button addTarget:self action:@selector(checkButtonClick) forControlEvents:UIControlEventTouchUpInside];
//        _checkButton = button;
//    }
//    return _checkButton;
//}

-(void)bgButtonClick{
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kNotShowInviteHint];

    [self removeFromSuperview];
//    if ([_checkButton isSelected]) {
//        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kNotShowInviteHint];
//    }
}
-(void)inviteButtonClick{
    [self bgButtonClick];
    if (_block) {
        _block();
    }
}
//-(void)checkButtonClick{
//    [self.checkButton setSelected:!self.checkButton.isSelected];
//}

@end
