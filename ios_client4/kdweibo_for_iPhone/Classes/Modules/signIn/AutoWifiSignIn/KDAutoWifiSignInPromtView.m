//
//  KDAutoWifiSignInPromtView.m
//  kdweibo
//
//  Created by lichao_liu on 1/12/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDAutoWifiSignInPromtView.h"

@interface KDAutoWifiSignInPromtView()
{
    UILabel *_contentLabel;
    UILabel * _tipsLabel;
    UIButton * _confirmButton;
    UIButton * _cancelButton;
    UIImageView *_iconImageView;
}
@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, copy) NSString *bssid;
@property (nonatomic, copy) NSString *attendSetId;
@property (nonatomic, copy) NSString *attendSetName;
@end

@implementation KDAutoWifiSignInPromtView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.7f);
        
        UIView *_backgroundView = [[UIView alloc]initWithFrame:CGRectMake((CGRectGetWidth(frame) - 280)/2, (CGRectGetHeight(frame) - 180)/2-30, 280, 180)];
        _backgroundView.backgroundColor = BOSCOLORWITHRGBA(0xFFFFFF, 0.95);
        _backgroundView.layer.cornerRadius = 8.0;
        _backgroundView.hidden = NO;
        [self addSubview:_backgroundView];
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 20, 20, 20)];
        _iconImageView.image = [UIImage imageNamed:@"file_img_choose_down"];
        [_backgroundView addSubview:_iconImageView];
        
        _tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(98, 10.0f, 140, 40)];
        _tipsLabel.text = ASLocalizedString(@"KDSignInViewController_success");
        _tipsLabel.font = [UIFont systemFontOfSize:17.0f];
        _tipsLabel.backgroundColor = [UIColor clearColor];
        _tipsLabel.textColor = [UIColor blackColor];
        [_backgroundView addSubview:_tipsLabel];
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.numberOfLines = 4;
        _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.frame = CGRectMake(10, 10, 260, 150);
        [_backgroundView addSubview:_contentLabel];
        
         _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:ASLocalizedString(@"下次再说")forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f] ];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton setTitleColor:BOSCOLORWITHRGBA(0x1A85FF, 1.0f) forState:UIControlStateHighlighted];
        [_cancelButton sizeToFit];
        [_cancelButton setFrame:CGRectMake(0,
                                           CGRectGetHeight(_backgroundView.frame) - 44,
                                           CGRectGetWidth(_backgroundView.frame) / 2,
                                           44)];
        [_cancelButton addTarget:self action:@selector(cancelButonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView addSubview:_cancelButton];
        UIView * topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _backgroundView.bounds.size.width / 2, 1)];
        [topLine setBackgroundColor:BOSCOLORWITHRGBA(0xDDDDDD, 1.0f)];
        [_cancelButton addSubview:topLine];
        UIView * rightLine = [[UIView alloc]initWithFrame:CGRectMake(_backgroundView.bounds.size.width / 2 - 0.5, 0, 0.5, 44)];
        [rightLine setBackgroundColor:BOSCOLORWITHRGBA(0xDDDDDD, 1.0f)];
        [_cancelButton addSubview:rightLine];
        
        
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:ASLocalizedString(@"设置wifi关联")forState:UIControlStateNormal];
        [_confirmButton sizeToFit];
        [_confirmButton setFrame:CGRectMake(_backgroundView.bounds.size.width / 2, CGRectGetHeight(_backgroundView.frame) - 44,_backgroundView.bounds.size.width / 2, 44)];
        [_confirmButton addTarget:self action:@selector(confimButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f] ];
        [_confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_confirmButton setTitleColor:BOSCOLORWITHRGBA(0x1A85FF, 1.0f) forState:UIControlStateHighlighted];
        [_backgroundView addSubview:_confirmButton];
        UIView * topLine2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _backgroundView.bounds.size.width / 2, 1)];
        [topLine2 setBackgroundColor:BOSCOLORWITHRGBA(0xDDDDDD, 1.0f)];
        [_confirmButton addSubview:topLine2];
        UIView * leftLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0.5, 44)];
        [leftLine setBackgroundColor:BOSCOLORWITHRGBA(0xDDDDDD, 1.0f)];
        [_confirmButton addSubview:leftLine];
        
    }
    return self;
}

- (void)setBlock:(KDAutoWifiSignInPromtViewBlock)block ssid:(NSString *)ssid promtType:(KDAutoWifiSignInPromtViewType)type
{
//    self.block = block;
//    self.ssid = ssid;
//    self.type = type;
//    
//    if(type == KDAutoWifiSignInPromtViewType_signInSuccess)
//    {
//    _contentLabel.text = [NSString stringWithFormat:ASLocalizedString(@"如果%@是公司WIFI,建议关联到签到点。关联后，员工连接到这个WIFI就可自动签到了，赶快去设置吧。"),self.ssid];
//    }else if(type == KDPromtViewAddWifiLinkFromNone)
//    {
//        _tipsLabel.text = ASLocalizedString(@"保存成功");
//        _contentLabel.text = ASLocalizedString(@"现在可以自动签到了，请赶紧去通知你的小伙伴们吧!");
//        [_confirmButton setTitle:ASLocalizedString(@"通知所有员工")forState:UIControlStateNormal];
//        [_cancelButton setTitle:ASLocalizedString(@"不用了")forState:UIControlStateNormal];
//    }
//    else{
//        _contentLabel.text = [NSString stringWithFormat:ASLocalizedString(@"员工连接到%@就可以自动签到了，请赶紧去通知你的小伙伴吧。"),self.ssid];
//        _tipsLabel.text = ASLocalizedString(@"WIFI设置成功");
//        [_confirmButton setTitle:ASLocalizedString(@"通知所有员工")forState:UIControlStateNormal];
//        [_cancelButton setTitle:ASLocalizedString(@"不用了")forState:UIControlStateNormal];
//    }
}

- (void)setBlock:(KDAutoWifiSignInPromtViewBlock)block promtType:(KDAutoWifiSignInPromtViewType)type
{
//    self.block = block;
//    self.type = type;
//    
//    if(type == KDPromtViewAdminSignInSuccess)
//    {
//        _contentLabel.text = [NSString stringWithFormat:ASLocalizedString(@"不想每次选择位置，就快去设置固定签到点吧！进入公司即可一步签到，且系统自动记录内勤哦...")];
//        _tipsLabel.text = ASLocalizedString(@"签到成功");
//        [_confirmButton setTitle:ASLocalizedString(@"设置签到点")forState:UIControlStateNormal];
//        [_cancelButton setTitle:ASLocalizedString(@"下次再说")forState:UIControlStateNormal];
//    }else if(type == KDPromtViewSignInPointSetSuccess)
//    {
//        _contentLabel.text = ASLocalizedString(@"赶快去试试，签到点现在就可以显示了。另外，查看所有签到记录，请点击右上角【所有记录】");
//        _tipsLabel.text = ASLocalizedString(@"签到点设置成功");
//        [_confirmButton setTitle:ASLocalizedString(@"所有记录")forState:UIControlStateNormal];
//        [_cancelButton setTitle:ASLocalizedString(@"知道了")forState:UIControlStateNormal];
//    }else if(type == KDPromtViewCustomSignInSuccess)
//    {
//        _contentLabel.text = ASLocalizedString(@"亲，还没有设置签到点噢~赶快去通知管理员设置吧！以后就不用选择位置，进入公司即可一步签到，且系统自动记录为内勤哦");
//        _tipsLabel.text = ASLocalizedString(@"签到成功!");
//        [_confirmButton setTitle:ASLocalizedString(@"通知管理员")forState:UIControlStateNormal];
//        [_cancelButton setTitle:ASLocalizedString(@"看看再说")forState:UIControlStateNormal];
//    }else if(type == KDPromtViewNotificationAdminSuccess)
//    {
//        _contentLabel.text = ASLocalizedString(@"耐心等待管理员设置，成功后即可一步签到了。另外，查看所有签到记录，请点击右上角【所有记录】");
//        _tipsLabel.text = ASLocalizedString(@"已成功通知管理员");
//        _iconImageView.frame = CGRectMake(50, _iconImageView.frame.origin.y, CGRectGetWidth(_iconImageView.frame), CGRectGetHeight(_iconImageView.frame));
//        _tipsLabel.frame = CGRectMake(_tipsLabel.frame.origin.x - 20, _tipsLabel.frame.origin.y, CGRectGetWidth(_tipsLabel.frame), CGRectGetHeight(_tipsLabel.frame));
//        [_confirmButton setTitle:ASLocalizedString(@"所有记录")forState:UIControlStateNormal];
//        [_cancelButton setTitle:ASLocalizedString(@"知道了")forState:UIControlStateNormal];
//    }else if(type == KDPromtViewAddOrUpdateSignInPointSource)
//    {
//        _contentLabel.text = ASLocalizedString(@"进入公司可以一步签到了，且系统自动记录为内勤，赶快去试试吧！");
//        _tipsLabel.text = ASLocalizedString(@"签到点设置成功");
//        [_confirmButton setTitle:ASLocalizedString(@"通知所有员工")forState:UIControlStateNormal];
//        [_cancelButton setTitle:ASLocalizedString(@"知道了")forState:UIControlStateNormal];
//    }
}

- (void)cancelButonClicked:(UIButton *)sender
{
    if(self.block)
    {
        self.block(NO);
    }
    [self removeFromSuperview];
}

- (void)confimButtonClicked:(UIButton *)sender
{
    if(self.block)
    {
        self.block(YES);
    }
    [self removeFromSuperview];
}
@end
