//
//  KDSignInSettingCell.m
//  kdweibo
//
//  Created by Tan yingqi on 13-8-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDSignInSettingCell.h"

@implementation KDSignInSettingCell

#pragma mark - addMethod -
- (void)addMarkImageBtn {
    [self.contentView addSubview:self.markImageBtn];
    [self.markImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.kd_contentView.kd_textLabel.right).with.offset(6);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(20);
    }];
}

- (void)addAccessorySwitch {
    [self.contentView addSubview:self.accessorySwitch];
    [self.accessorySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).with.offset(-14);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
}

- (void)addButton {
    [self.contentView addSubview:self.accessoryButton];
    [self.accessoryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).with.offset(-12);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(28);
    }];
}

- (void)addTextField {
    [self.contentView addSubview:self.accessoryTextField];
    [self.accessoryTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).with.offset(100);
        make.right.mas_equalTo(self.contentView).with.offset(-12);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30);
    }];
}

#pragma mark - setter & getter -
- (KDV8CellContentView *)kd_contentView
{
    if (!_kd_contentView) {
        _kd_contentView = [KDV8CellContentView new];
    }
    return _kd_contentView;
}

- (UIButton *)markImageBtn {
    if (!_markImageBtn) {
        _markImageBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        _markImageBtn.backgroundColor = FC4;
        [_markImageBtn setTitle:@"New" forState:UIControlStateNormal];
        _markImageBtn.layer.cornerRadius = 8;
        _markImageBtn.layer.masksToBounds = YES;
        _markImageBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_markImageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _markImageBtn.userInteractionEnabled = NO;
        _markImageBtn.hidden = YES;
    }
    
    return _markImageBtn;
}

- (void)setIsShowMarkImageBtn:(BOOL)isShowMarkImageBtn {
    _isShowMarkImageBtn = isShowMarkImageBtn;
    self.markImageBtn.hidden = !isShowMarkImageBtn;
}

- (UISwitch *)accessorySwitch {
    if (!_accessorySwitch) {
        _accessorySwitch = [UISwitch new];
        _accessorySwitch.onTintColor = FC5;
        [_accessorySwitch setOn:NO];
        [_accessorySwitch addTarget:self action:@selector(switchDidClicked:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _accessorySwitch;
}

- (UIButton *)accessoryButton {
    if (!_accessoryButton) {
        _accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _accessoryButton.layer.borderWidth = 1;
        _accessoryButton.layer.borderColor = FC5.CGColor;
        _accessoryButton.layer.cornerRadius = 14;
        _accessoryButton.layer.masksToBounds = YES;
        [_accessoryButton setTitle:ASLocalizedString(@"添加") forState:UIControlStateNormal];
        [_accessoryButton setTitleColor:FC5 forState:UIControlStateNormal];
        [_accessoryButton setTitleColor:[UIColor colorWithRGB:0x3cbaff alpha:0.5] forState:UIControlStateHighlighted];
        [_accessoryButton setBackgroundImage:[UIImage kd_imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_accessoryButton setBackgroundImage:[UIImage kd_imageWithColor:[UIColor colorWithRGB:0x0c213f alpha:0.05]] forState:UIControlStateHighlighted];
        _accessoryButton.titleLabel.font = FS6;
        [_accessoryButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _accessoryButton;
}

- (KDTextField *)accessoryTextField {
    if (!_accessoryTextField) {
        _accessoryTextField = [[KDTextField alloc] initWithFrame:CGRectZero];
        _accessoryTextField.backgroundColor = [UIColor clearColor];
        _accessoryTextField.font = FS4;
        _accessoryTextField.textColor = FC2;
        _accessoryTextField.textAlignment = NSTextAlignmentRight;
        _accessoryTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _accessoryTextField.returnKeyType = UIReturnKeyDone;
    }
    return _accessoryTextField;
}

#pragma mark - action -
- (void)setSwitchStatus:(BOOL)status {
    [self.accessorySwitch setOn:status animated:YES];
}

- (void)switchDidClicked:(id)sender {
    if (self.switchDidClickedBlock) {
        self.switchDidClickedBlock();
    }
}

- (void)buttonDidClicked:(id)sender {
    if (self.buttonDidClickedBlock) {
        self.buttonDidClickedBlock();
    }
}

@end
