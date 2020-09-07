//
//  KDVoicePopView.m
//  kdweibo
//
//  Created by tangzeng on 2017/3/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDVoicePopView.h"
@interface KDVoicePopView()
@property (nonatomic, strong) UIView   *bottomView;
@property (nonatomic, strong) UILabel  *inviteLabel;
@property (nonatomic, strong) UILabel  *pptShareLabel;
@property (nonatomic, strong) UILabel  *callJoinLabel;
@property (nonatomic, strong) UIButton *inviteBtn;
@property (nonatomic, strong) UIButton *pptShareBtn;
@property (nonatomic, strong) UIButton *callJoinBtn;

@property (nonatomic, strong) MASConstraint *bottomViewTopConstraint;

@end

@implementation KDVoicePopView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor kdPopupBackgroundColor];
        self.alpha = 0;
        self.userInteractionEnabled= YES;
        UITapGestureRecognizer *tapPopView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenPopView)];
        [self addGestureRecognizer:tapPopView];
        
        
        self.bottomView = [[UIView alloc] init];
        self.bottomView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bottomView];
        [self.bottomView makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(164);
            make.left.and.and.right.mas_equalTo(self);
            self.bottomViewTopConstraint = make.top.equalTo(self.bottom);
        }];
        
        UIButton *inviteBtn = [self createButtonWithTag:100 NorImg:@"phone_btn_invite" PreImg:@"phone_btn_invite_press" DisableImg:nil];
        UILabel  *inviteLabel = [self createLabelWithTitle:ASLocalizedString(@"邀请人员")];
        [self.bottomView addSubview:inviteBtn];
        [self.bottomView addSubview:inviteLabel];
        self.inviteLabel = inviteLabel;
        self.inviteBtn  = inviteBtn;
        [self.inviteBtn makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(46);
            make.top.equalTo(self.bottomView.top).offset(42);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(50);
        }];
        [self.inviteLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.inviteBtn);
            make.bottom.equalTo(self.bottomView).offset(-42);
        }];
        
        UIButton *pptShareBtn = [self createButtonWithTag:101 NorImg:@"phone_btn_share_ppt" PreImg:@"phone_btn_share_ppt_press" DisableImg:nil];
        UILabel  *pptShareLabel = [self createLabelWithTitle:ASLocalizedString(@"PPT共享")];
        [self.bottomView addSubview:pptShareBtn];
        [self.bottomView addSubview:pptShareLabel];
        self.pptShareBtn = pptShareBtn;
        self.pptShareLabel = pptShareLabel;
        
        [self.pptShareBtn makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bottomView.top).offset(42);
            make.centerX.equalTo(self.bottomView);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(50);
        }];
        [self.pptShareLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.pptShareBtn);
            make.bottom.equalTo(self.bottomView).offset(-42);
        }];

//        UIButton *callJoinBtn = [self createButtonWithTag:102 NorImg:@"phone_btn_phone_join_disable" PreImg:nil DisableImg:@"phone_btn_phone_join_disable"];
//        callJoinBtn.enabled = NO;
//        UILabel  *callJoinLabel = [self createLabelWithTitle:ASLocalizedString(@"电话接入")];
//        UILabel *tipLabel = [[UILabel alloc] init];
//        tipLabel.text = ASLocalizedString(@"开发中，敬请期待");
//        tipLabel.font = FS9;
//        tipLabel.textColor = FC3;
//        [self.bottomView addSubview:tipLabel];
//        [self.bottomView addSubview:callJoinBtn];
//        [self.bottomView addSubview:callJoinLabel];
//        self.callJoinBtn = callJoinBtn;
//        self.callJoinLabel = callJoinLabel;
//        
//        [self.callJoinBtn makeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(self.bottomView).offset(-46);
//            make.top.equalTo(self.bottomView.top).offset(42);
//            make.width.mas_equalTo(50);
//            make.height.mas_equalTo(50);
//        }];
//        [self.callJoinLabel makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.callJoinBtn);
//            make.bottom.equalTo(self.bottomView).offset(-42);
//        }];
//        [tipLabel makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.callJoinBtn);
//            make.top.equalTo(self.callJoinLabel.bottom).offset(2);
//        }];
    }
    return self;
}

- (void)hiddenPopView {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomViewTopConstraint.offset(0);
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0;
        }];
    }];
}

- (void)showPopView {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomViewTopConstraint.offset(-164);
            [self layoutIfNeeded];
        }];
    }];
}

- (void)buttonClick:(UIButton *)button {
    NSInteger tag = button.tag;
    switch (tag) {
        case 100:
        {
            if ([self.delegate respondsToSelector:@selector(invitePersonJoinMeeting)]) {
                [self.delegate invitePersonJoinMeeting];
            }
        }
            break;
        case 101:
        {
            if ([self.delegate respondsToSelector:@selector(sharePPTForMeeting)]) {
                [self.delegate sharePPTForMeeting];
            }
        }
            break;
        case 102:
        {
//            if ([self.delegate respondsToSelector:@selector(joinMeetingByPhone)]) {
//                [self.delegate joinMeetingByPhone];
//            }
        }
            break;
            
        default:
            break;
    }
}

- (UILabel *)createLabelWithTitle:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.font = FS6;
    label.textColor = FC2;
    label.textAlignment = NSTextAlignmentCenter;
    label.text =  title;
    return label;
}

- (UIButton *)createButtonWithTag:(NSInteger)tag NorImg:(NSString *)normalImageName PreImg:(NSString *)pressImageName DisableImg:(NSString *)disableImageName{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = tag;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    if (normalImageName) {
        [button setImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
    }
    if (pressImageName) {
        [button setImage:[UIImage imageNamed:pressImageName] forState:UIControlStateHighlighted];
    }
    if (disableImageName) {
        [button setImage:[UIImage imageNamed:disableImageName] forState:UIControlStateDisabled];
    }
    return button;
}

- (void)setEnableSharePPT:(BOOL)enableSharePPT {
    if (!enableSharePPT) {
        self.pptShareLabel.hidden = YES;
        self.pptShareBtn.hidden = YES;
        
        CGFloat space = 0.29*ScreenFullWidth - 25;
        [self.inviteBtn updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(space);
        }];
        [self.callJoinBtn updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bottomView).offset(-space);
        }];
    }
}
@end
