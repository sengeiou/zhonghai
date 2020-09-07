//
//  KDSignInOverTimeHintView.m
//  kdweibo
//
//  Created by 张培增 on 2017/1/22.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDSignInOverTimeHintView.h"

#define HintView_Width_Ratio 0.775 //hintView所占大屏宽比例

@interface KDSignInOverTimeHintView ()

@property (nonatomic, strong) KDSignInOverTimeModel *model;

@property (nonatomic, strong) UIView            *bgView;
@property (nonatomic, strong) UIImageView       *backgroundImageView;
@property (nonatomic, strong) UIImageView       *lineImageView;
@property (nonatomic, strong) UILabel           *timeLabel;
@property (nonatomic, strong) UILabel           *textLabel;
@property (nonatomic, strong) UILabel           *extraRemarkLabel;
@property (nonatomic, strong) UILabel           *extraRemarkAuthorLabel;
@property (nonatomic, strong) UIButton          *shareButton;
@property (nonatomic, strong) UIButton          *closeButton;

@end

@implementation KDSignInOverTimeHintView

- (instancetype)initWithSignInOverTimeModel:(KDSignInOverTimeModel *)model {
    self = [super init];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.backgroundImageView];
        [self addSubview:self.lineImageView];
        [self addSubview:self.timeLabel];
        [self addSubview:self.textLabel];
        [self addSubview:self.extraRemarkLabel];
        [self addSubview:self.extraRemarkAuthorLabel];
        [self addSubview:self.shareButton];
        
        self.model = model;
    }
    
    return self;
}

- (void)showHintView {
    if ([AppWindow.subviews containsObject:self]) {
        return;
    }
    [AppWindow addSubview:self.bgView];
    [AppWindow addSubview:self];
    [AppWindow addSubview:self.closeButton];
    [self setUpView];
}

- (void)hideHintView {
    [self.bgView removeFromSuperview];
    [self removeFromSuperview];
    [self.closeButton removeFromSuperview];
}

- (void)setUpView {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(AppWindow).with.insets(UIEdgeInsetsZero);
    }];
    
    CGFloat width      = [UIApplication sharedApplication].keyWindow.screen.bounds.size.width;
    CGFloat selfwidth  = width * HintView_Width_Ratio;
    CGFloat selfheight = selfwidth / 0.8;
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(selfwidth, selfheight));
        make.center.mas_equalTo(AppWindow);
    }];
    
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).with.insets(UIEdgeInsetsZero);
    }];
    [self.backgroundImageView setImageWithURL:[NSURL URLWithString:self.model.thumbnailUrl] placeholderImage:[UIImage kd_imageWithColor:[UIColor colorWithRGB:0x3b4a95]]];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).with.offset(40);
        make.left.mas_equalTo(self).with.offset(22);
    }];
    if (safeString(self.model.alertClockInTime).length > 0) {
        self.timeLabel.text = self.model.alertClockInTime;
    }
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.bottom).with.offset(0);
        make.left.mas_equalTo(self).with.offset(22);
    }];
    
    if (self.model.alertCeilTextArray.count > 0) {
        NSString *text = @"";
        for (int i = 0; i < self.model.alertCeilTextArray.count - 1; i++) {
            text = [text stringByAppendingString:safeString([self.model.alertCeilTextArray safeObjectAtIndex:i])];
            text = [text stringByAppendingString:@"\n"];
        }
        text = [text stringByAppendingString:safeString([self.model.alertCeilTextArray lastObject])];
        if (text.length > 0) {
            self.textLabel.text = text;
        }
    }
    
    [self.lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textLabel.bottom).with.offset(15);
        make.left.mas_equalTo(self).with.offset(22);
        make.right.mas_equalTo(self).with.offset(-22);
    }];
    
    [self.extraRemarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineImageView.bottom).with.offset(7);
        make.left.mas_equalTo(self).with.offset(22);
        make.right.mas_equalTo(self).with.offset(-22);
    }];
    if (safeString(self.model.alertContent).length > 0) {
        self.extraRemarkLabel.text = self.model.alertContent;
    }
    
    [self.extraRemarkAuthorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.extraRemarkLabel.bottom).with.offset(4);
        make.right.mas_equalTo(self).with.offset(-22);
    }];
    if (safeString(self.model.alertAuthor).length > 0) {
        self.extraRemarkAuthorLabel.text = self.model.alertAuthor;
    }
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).with.offset(-14);
        make.left.mas_equalTo(self).with.offset(11);
        make.right.mas_equalTo(self).with.offset(-11);
        make.height.mas_equalTo(44);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.right).with.offset(-15);
        make.top.mas_equalTo(self.top).with.offset(-10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

#pragma mark - buttonMethod -
- (void)shareButtonDidClicked:(UIButton *)sender {
    if (self.buttonDidClickBlock) {
        [self hideHintView];
        self.buttonDidClickBlock(1);
    }
}

- (void)closeButtonDidClicked:(UIButton *)sender {
    if (self.buttonDidClickBlock) {
        [self hideHintView];
        self.buttonDidClickBlock(0);
    }
}

#pragma mark - getter -
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorWithRGB:0x0C213F alpha:0.8];
    }
    return _bgView;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
    }
    return _backgroundImageView;
}

- (UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView = [[UIImageView alloc] init];
        _lineImageView.image = [UIImage imageNamed:@"signIn_overTime_line"];
    }
    return _lineImageView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:36];
        _timeLabel.textColor = FC6;
    }
    return _timeLabel;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.font = FS8;
        _textLabel.textColor = FC6;
        _textLabel.numberOfLines = 2;
    }
    return _textLabel;
}

- (UILabel *)extraRemarkLabel {
    if (!_extraRemarkLabel) {
        _extraRemarkLabel = [[UILabel alloc] init];
        _extraRemarkLabel.font = isAboveiPhone6 ? FS1 : FS4;
        _extraRemarkLabel.textColor = FC6;
        _extraRemarkLabel.numberOfLines = 0;
        _extraRemarkLabel.text = ASLocalizedString(@"不加班的人生不完美。我加起班来我自己都害怕。");
    }
    return _extraRemarkLabel;
}

- (UILabel *)extraRemarkAuthorLabel {
    if (!_extraRemarkAuthorLabel) {
        _extraRemarkAuthorLabel = [[UILabel alloc] init];
        _extraRemarkAuthorLabel.font = FS8;
        _extraRemarkAuthorLabel.textColor = FC6;
        _extraRemarkAuthorLabel.text = ASLocalizedString(@"--云之家");
    }
    return _extraRemarkAuthorLabel;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.layer.cornerRadius = 22;
        _shareButton.layer.borderWidth = 1.0;
        _shareButton.layer.borderColor = [UIColor colorWithRGB:0xFFFFFF alpha:0.5].CGColor;
        _shareButton.layer.masksToBounds = YES;
        _shareButton.titleLabel.font = FS3;
        [_shareButton setTitleColor:FC6 forState:UIControlStateNormal];
        [_shareButton setTitleColor:[UIColor colorWithRGB:0xFFFFFF alpha:0.5] forState:UIControlStateHighlighted];
        [_shareButton setBackgroundImage:[UIImage kd_imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [_shareButton setBackgroundImage:[UIImage kd_imageWithColor:[UIColor colorWithRGB:0x0C213F alpha:0.1]] forState:UIControlStateHighlighted];
        [_shareButton setTitle:ASLocalizedString(@"分享") forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(closeButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[UIImage imageNamed:@"sign_tip_popup_close"] forState:UIControlStateNormal];
        [_closeButton setImageEdgeInsets:UIEdgeInsetsMake(-10, -10, 10, 10)];
    }
    return _closeButton;
}

@end
