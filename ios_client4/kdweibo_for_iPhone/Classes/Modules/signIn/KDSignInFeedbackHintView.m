//
//  KDSignInFeedbackHintView.m
//  kdweibo
//
//  Created by 张培增 on 2016/11/1.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSignInFeedbackHintView.h"

#define HintView_Width_Ratio 0.72 //hintView所占大屏宽比例
#define HintView_Height_Ratio (359.0/568.0) //hintView所占大屏高比例

@interface KDSignInFeedbackHintView ()

@property (nonatomic, strong) UIImageView   *headerImageView;
@property (nonatomic, strong) UIImageView   *iconImageView;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UILabel       *contentLabel;
@property (nonatomic, strong) UILabel       *timeLabel;
@property (nonatomic, strong) UIButton      *feedbackButton;
@property (nonatomic, strong) UIButton      *iKnowButton;
@property (nonatomic, strong) UIView        *bgView;

@end

@implementation KDSignInFeedbackHintView

- (instancetype)initWithSignInRecord:(KDSignInRecord *)record hintViewType:(KDSignInFeedbackHintType)type {
    self = [super init];
    
    if (self) {
        
        self.record = record;
        self.signInFeedbackHintType = type;
        
        [self addSubview:self.headerImageView];
        [self.headerImageView addSubview:self.iconImageView];
        [self.headerImageView addSubview:self.titleLabel];
        [self addSubview:self.contentLabel];
        [self addSubview:self.timeLabel];
        [self addSubview:self.feedbackButton];
        [self addSubview:self.iKnowButton];
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        self.clipsToBounds = NO;
    }
    
    return self;
}

- (void)showHintView {
    if ([AppWindow.subviews containsObject:self]) {
        return;
    }
    [AppWindow addSubview:self.bgView];
    [AppWindow addSubview:self];
    [self setUpView];
}

- (void)setUpView {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(AppWindow).with.insets(UIEdgeInsetsZero);
    }];
    
    CGFloat width      = [UIApplication sharedApplication].keyWindow.screen.bounds.size.width;
    CGFloat selfwidth  = width * HintView_Width_Ratio;
    CGFloat selfheight = 275;
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(selfwidth, selfheight));
        make.center.mas_equalTo(AppWindow);
    }];
    
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(138);
        make.height.mas_equalTo(100);
        make.top.mas_equalTo(self).with.offset(-12);
    }];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.headerImageView.mas_centerX);
        make.top.mas_equalTo(self.headerImageView).with.offset(10);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.headerImageView.mas_centerX);
        make.top.mas_equalTo(self.iconImageView.bottom).with.offset(8);
    }];
    
    if (self.signInFeedbackHintType == KDSignInFeedbackHint_signInSuccess) {
        [self.headerImageView setImage:[UIImage imageNamed:@"signIn_feedback_blueHeaderImage"]];
        [self.iconImageView setImage:[UIImage imageNamed:@"signIn_feedback_success"]];
        self.titleLabel.text = ASLocalizedString(@"签到成功");
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(self.headerImageView.bottom).with.offset(20);
        }];
        self.contentLabel.text = (self.record.exceptionType && [self.record.exceptionType isEqualToString:@"LATE"]) ? ASLocalizedString(@"你迟到了") : ASLocalizedString(@"你早退了");
        
        [self.iKnowButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self);
            make.top.mas_equalTo(self.bottom).with.offset(-44);
            make.width.mas_equalTo(selfwidth/2);
            make.height.mas_equalTo(44);
        }];
        
        [self.feedbackButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iKnowButton);
            make.right.mas_equalTo(self);
            make.width.mas_equalTo(selfwidth/2);
            make.height.mas_equalTo(44);
        }];
        
        UIView *vLine = [[UIView alloc] initWithFrame:CGRectZero];
        vLine.backgroundColor = [UIColor kdDividingLineColor];
        [self addSubview:vLine];
        [vLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.iKnowButton.right);
            make.centerY.mas_equalTo(self.iKnowButton.mas_centerY);
            make.width.mas_equalTo(1);
            make.height.mas_equalTo(20);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.bottom.mas_equalTo(self.feedbackButton.top).with.offset(-50);
        }];
        int hour = 0;
        int minute = 0;
        if (self.record.exceptionMinitues > 0) {
            hour = (int)self.record.exceptionMinitues / 60;
            minute = (int)self.record.exceptionMinitues % 60;
        }
        if (hour > 0) {
            self.timeLabel.font = [UIFont systemFontOfSize:35];
            self.timeLabel.text = [NSString stringWithFormat:ASLocalizedString(@"%d小时%d分钟"), hour, minute];
        }
        else {
            self.timeLabel.text = [NSString stringWithFormat:ASLocalizedString(@"%d分钟"), minute];
        }
    }
    else {
        [self.headerImageView setImage:[UIImage imageNamed:@"signIn_feedback_orangeHeaderImage"]];
        [self.iconImageView setImage:[UIImage imageNamed:@"signIn_feedback_ exclamation"]];
        self.titleLabel.text = ASLocalizedString(@"无法反馈");
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(self.headerImageView.bottom).with.offset(30);
        }];
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.font = FS2;
        if (self.signInFeedbackHintType == KDSignInFeedbackHint_cannotFeedback) {
            self.contentLabel.text = ASLocalizedString(@"你的部门没有设置负责人\n\n请联系管理员设置");
        }
        else {
            self.contentLabel.text = ASLocalizedString(@"反馈失败,稍后请进\n\n入签到统计中进行反馈");
        }
        
        [self.iKnowButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.mas_equalTo(self);
            make.height.mas_equalTo(44);
        }];
    }
    
    UIView *hLine = [[UIView alloc] initWithFrame:CGRectZero];
    hLine.backgroundColor = [UIColor kdDividingLineColor];
    [self addSubview:hLine];
    [hLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self);
        make.height.mas_equalTo(1);
        make.top.mas_equalTo(self.bottom).mas_equalTo(-44);
    }];
}

#pragma mark - getter -
- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] init];
    }
    return _headerImageView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = FS4;
        _titleLabel.textColor = FC6;
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = FS4;
        _contentLabel.textColor = FC1;
    }
    return _contentLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:45];
        _timeLabel.textColor = FC5;
    }
    return _timeLabel;
}

- (UIButton *)feedbackButton {
    if (!_feedbackButton) {
        _feedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_feedbackButton setTitle:ASLocalizedString(@"我要反馈") forState:UIControlStateNormal];
        [_feedbackButton setTitleColor:FC5 forState:UIControlStateNormal];
        _feedbackButton.titleLabel.font = FS2;
        [_feedbackButton addTarget:self action:@selector(feedbackButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _feedbackButton;
}

- (UIButton *)iKnowButton {
    if (!_iKnowButton) {
        _iKnowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_iKnowButton setTitle:ASLocalizedString(@"我知道了") forState:UIControlStateNormal];
        [_iKnowButton setTitleColor:FC2 forState:UIControlStateNormal];
        _iKnowButton.titleLabel.font = FS2;
        [_iKnowButton addTarget:self action:@selector(iKnowButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _iKnowButton;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor kdPopupBackgroundColor];
    }
    return _bgView;
}

#pragma mark - buttonMethod -
- (void)feedbackButtonDidClicked:(UIButton *)sender {
    if (self.buttonDidClickBlock) {
        self.buttonDidClickBlock(1);
    }
    [self remove];
}

- (void)iKnowButtonDidClicked:(UIButton *)sender {
    if (self.buttonDidClickBlock) {
        self.buttonDidClickBlock(0);
    }
    [self remove];
}

#pragma mark - removeFromSuperView -
- (void)remove {
    [self removeFromSuperview];
    [self.bgView removeFromSuperview];
}

@end
