//
//  KDPersonCell.m
//  kdweibo
//
//  Created by Gil on 15/3/16.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPersonCell.h"

@interface KDPersonCell ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation KDPersonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self.contentView addSubview:self.nameLabel];
		[self.contentView addSubview:self.contentLabel];
        
        autolayoutSetCenterY(self.nameLabel);
        autolayoutSetCenterY(self.contentLabel);
	}
	return self;
}

- (UILabel *)nameLabel {
	if (_nameLabel == nil) {
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = self.contentView.backgroundColor;
		_nameLabel.textColor = FC2;
		_nameLabel.font = FS3;
		_nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _nameLabel;
}

- (UILabel *)contentLabel {
	if (_contentLabel == nil) {
		_contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_contentLabel.backgroundColor = self.contentView.backgroundColor;
		_contentLabel.textColor = FC1;
		_contentLabel.font = FS3;
		_contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _contentLabel;
}

#pragma mark - autolayout -

- (void)updateConstraints {
    [super updateConstraints];
    
    if (self.hvlfs) {
        [self.contentView removeConstraints:self.hvlfs];
    }
    
    NSDictionary *views = @{@"nameLabel" : self.nameLabel,
                            @"contentLabel" : self.contentLabel};
    
    NSString *vfl = @"|-12-[nameLabel(80)]-30-[contentLabel]";
    CGFloat space = [NSNumber kdDistance1];
    if (self.accessoryStyle == KDTableViewCellAccessoryStyleDisclosureIndicator) {
        space += ([NSNumber kdDistance1] + 7);
    }
    vfl = [vfl stringByAppendingFormat:@"-(>=%f)-|",space];
    self.hvlfs = [NSLayoutConstraint constraintsWithVisualFormat:vfl
                                                         options:nil
                                                         metrics:nil
                                                           views:views];
    [self.contentView addConstraints:self.hvlfs];
}

@end

#pragma mark - KDPersonContactCell -

@interface KDPersonContactCell ()
@property (strong , nonatomic) UIButton *emailButton;
@property (strong , nonatomic) UIButton *phoneButton;
@property (strong , nonatomic) UIButton *messageButton;

@end

@implementation KDPersonContactCell

/* 取消下划线
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.contentLabel.text.length > 0) {
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:self.contentLabel.text];
        NSRange contentRange = {0,[content length]};
        [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
        [content addAttribute:NSUnderlineColorAttributeName value:self.contentLabel.textColor range:contentRange];
        self.contentLabel.attributedText = content;
    }
}*/

- (void)updateConstraints {
    [super updateConstraints];
    
    if (self.hvlfs) {
        [self.contentView removeConstraints:self.hvlfs];
    }
    
    NSDictionary *views = @{@"nameLabel" : self.nameLabel,
                            @"contentLabel" : self.contentLabel};
    NSString *vfl = @"|-12-[nameLabel(80)]-30-[contentLabel]";
    CGFloat space = [NSNumber kdDistance1] + 25;

    vfl = [vfl stringByAppendingFormat:@"-(>=%f)-|",space];
    self.hvlfs = [NSLayoutConstraint constraintsWithVisualFormat:vfl
                                                         options:nil
                                                         metrics:nil
                                                           views:views];
    [self.contentView addConstraints:self.hvlfs];
    

    if (_emailButton && _emailButton.superview) {
        autolayoutSetCenterY(self.emailButton);
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_emailButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-[NSNumber kdDistance1]]];
    }
    
    if (_phoneButton && _phoneButton.superview && _messageButton && _messageButton.superview) {
        autolayoutSetCenterY(self.phoneButton);
        autolayoutSetCenterY(self.messageButton);
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_phoneButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-[NSNumber kdDistance1]]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_messageButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_phoneButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-21]];
    }
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.emailButton];
        [self.contentView addSubview:self.phoneButton];
        [self.contentView addSubview:self.messageButton];
    }
    return self;
}

- (void)setContactType:(NSString *)contactType {
    _contactType = contactType;
    if ([_contactType isEqualToString:@"E"]) {
        self.phoneButton.hidden = YES;
        self.messageButton.hidden = YES;
        self.emailButton.hidden = NO;
    }
    else if ([_contactType isEqualToString:@"P"]) {
        self.emailButton.hidden = YES;
        self.phoneButton.hidden = NO;
        self.messageButton.hidden = NO;
    }
}

- (UIButton *)emailButton {
    if (_emailButton) return _emailButton;
    _emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_emailButton setImage:[UIImage imageNamed:@"profile_btn_email"] forState:UIControlStateNormal];
    _emailButton.translatesAutoresizingMaskIntoConstraints = NO;
    _emailButton.tag = 0x90;
    [_emailButton addTarget:self action:@selector(cellButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];

    return _emailButton;
}


- (UIButton *)phoneButton {
    if (_phoneButton) return _phoneButton;
    _phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_phoneButton setImage:[UIImage imageNamed:@"profile_btn_phone"] forState:UIControlStateNormal];
    _phoneButton.translatesAutoresizingMaskIntoConstraints = NO;
    _phoneButton.tag = 0x92;
    [_phoneButton addTarget:self action:@selector(cellButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    return _phoneButton;
}

- (UIButton *)messageButton {
    if (_messageButton) return _messageButton;
    _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_messageButton setImage:[UIImage imageNamed:@"profile_btn_message"] forState:UIControlStateNormal];
    _messageButton.translatesAutoresizingMaskIntoConstraints = NO;
    _messageButton.tag = 0x91;
    [_messageButton addTarget:self action:@selector(cellButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    return _messageButton;
}

- (void)cellButtonClickAction:(UIButton *)button {
    if (self.buttonClickBlock) {
        self.buttonClickBlock(button.tag - 0x90 , self.contentLabel.text);
    }
}


@end

#pragma mark - KDPersonCompanyCell -

@interface KDPersonCompanyCell ()
@property (nonatomic, strong) UILabel *leaderLabel;
@end

@implementation KDPersonCompanyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self.contentView addSubview:self.leaderLabel];

		autolayoutSetCenterY(self.leaderLabel);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[leaderLabel(15)]"
                                                                                 options:nil
                                                                                 metrics:nil
                                                                                   views:@{@"leaderLabel" : self.leaderLabel}]];
	}
	return self;
}

- (UILabel *)leaderLabel {
	if (_leaderLabel == nil) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = ASLocalizedString(@"负责人");
        label.font = FS8;
        label.textColor = FC6;
        label.backgroundColor = [UIColor clearColor];
        label.layer.backgroundColor = FC5.CGColor;
        label.layer.cornerRadius = 2;
        label.clipsToBounds = YES;
        label.textAlignment = NSTextAlignmentCenter;
		label.translatesAutoresizingMaskIntoConstraints = NO;
        _leaderLabel = label;
	}
	return _leaderLabel;
}

#pragma mark - autolayout -

- (void)updateConstraints {
    [super updateConstraints];
    
	if (self.hvlfs) {
		[self.contentView removeConstraints:self.hvlfs];
	}

	NSDictionary *views = @{@"nameLabel" : self.nameLabel,
							@"contentLabel" : self.contentLabel,
							@"leaderLabel" : self.leaderLabel};

	NSString *vfl = @"|-12-[nameLabel(60)]-50-[contentLabel]";
	if (!self.leaderLabel.hidden) {
		vfl = [vfl stringByAppendingString:@"-12-[leaderLabel(39)]"];
	}
    CGFloat space = [NSNumber kdDistance1];
	if (self.accessoryStyle == KDTableViewCellAccessoryStyleDisclosureIndicator) {
        space += ([NSNumber kdDistance1] + 7);
	}
    vfl = [vfl stringByAppendingFormat:@"-(>=%f)-|",space];
	self.hvlfs = [NSLayoutConstraint constraintsWithVisualFormat:vfl
                                                         options:nil
                                                         metrics:nil
                                                           views:views];
	[self.contentView addConstraints:self.hvlfs];
}

@end

#pragma mark - KDPersonOtherCell -

@implementation KDPersonOtherCell
@end

#pragma mark - KDPersonDynamicCell -

@interface KDPersonDynamicCell ()
@property (nonatomic, strong) UIImageView *logoImage;
@end

@implementation KDPersonDynamicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.nameLabel.font = FS5;
        self.nameLabel.textColor = FC1;
        self.contentLabel.hidden = YES;
        
        [self.contentView addSubview:self.logoImage];
        autolayoutSetCenterY(self.logoImage);
	}
	return self;
}

- (UIImageView *)logoImage {
    if (_logoImage == nil) {
        _logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buluo_small"]];
        _logoImage.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _logoImage;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    if (self.hvlfs) {
        [self.contentView removeConstraints:self.hvlfs];
    }
    
    NSDictionary *views = @{@"nameLabel" : self.nameLabel,
                            @"logoImage" : self.logoImage};
    NSString *vfl = @"|-12-[nameLabel]-(>=12)-[logoImage]-12-|";
    self.hvlfs = [NSLayoutConstraint constraintsWithVisualFormat:vfl
                                                         options:nil
                                                         metrics:nil
                                                           views:views];
    [self.contentView addConstraints:self.hvlfs];
}

@end

#pragma mark - KDPersonFoldCell -

@interface KDPersonFoldCell ()
{
    UILabel *titleLabel;
}
@property (nonatomic, strong) UIImageView *foldImageView;
@end

@implementation KDPersonFoldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

	if (self) {
		[self.contentView addSubview:self.foldImageView];

		autolayoutSetCenterY(self.foldImageView);
		autolayoutSetCenterX(self.foldImageView);
	}
	return self;
}

- (UIImageView *)foldImageView {
	if (_foldImageView == nil) {
		_foldImageView = [[UIImageView alloc] init];
		_foldImageView.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _foldImageView;
}

- (void)setTitle:(NSString *)title
{
    if (title) {
        if (!titleLabel) {
            titleLabel = [[UILabel alloc]init];
            titleLabel.textColor = FC1;
            titleLabel.font = FS7;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.frame = CGRectZero;
              [self.contentView addSubview:titleLabel];
            [titleLabel makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(44);
                make.width.mas_equalTo(120);
                make.centerX.offset(0);
                
            }];
        }
         titleLabel.text = title;
         titleLabel.hidden = NO;
         _foldImageView.hidden = YES;

    }
}

@end
