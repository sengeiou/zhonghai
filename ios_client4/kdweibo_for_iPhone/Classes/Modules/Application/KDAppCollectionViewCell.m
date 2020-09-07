//
//  KDAppCollectionViewCell.m
//  kdweibo
//
//  Created by Joyingx on 16/9/8.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDAppCollectionViewCell.h"
#import "KDApplicationCommon.h"

static CGFloat kNameLabelHeight = 15.0f;

@interface KDAppCollectionViewCell ()

@property (nonatomic, strong, readwrite) UIImageView *logoImageView;
@property (nonatomic, strong, readwrite) UIView *redDot;
@property (nonatomic, strong, readwrite) UILabel *nameLabel;

@property (nonatomic, strong) UIImageView *deleteImageView;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation KDAppCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpViews];
    }
    
    return self;
}

- (void)setUpViews {
    [self.contentView addSubview:self.logoImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.redDot];
    [self.contentView addSubview:self.deleteImageView];
    [self.contentView addSubview:self.deleteButton];

    [self.logoImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset([NSNumber kdDistance1] + 6.0f);
        make.centerX.equalTo(self.contentView);
        make.width.mas_equalTo(kAppIconWidth);
        make.height.mas_equalTo(kAppIconHeight);
    }];
    
    [self.nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView.bottom).with.offset(8);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(self.contentView);
        make.height.mas_equalTo(kNameLabelHeight);
    }];
    
    [self.deleteImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView).with.offset(-5);
        make.right.equalTo(self.logoImageView).with.offset(5);
        make.width.mas_equalTo(13);
        make.height.mas_equalTo(13);
    }];
    
    [self.deleteButton makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.deleteImageView);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    [self.redDot makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView).with.offset(-2.0f);
        make.right.equalTo(self.logoImageView).with.offset(2.0f);
        make.size.mas_equalTo(CGSizeMake(9, 9));
    }];
}

- (void)deleteButtonPressed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewCellDeleteButtonDidPressed:)]) {
        [self.delegate collectionViewCellDeleteButtonDidPressed:self];
    }
}

#pragma mark - Setters and Getters

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.logoImageView.alpha = 0.5;
    } else {
        self.logoImageView.alpha = 1;
    }
}

- (void)setIsDeleteStatus:(BOOL)isDeleteStatus {
    _isDeleteStatus = isDeleteStatus;
    
    self.deleteImageView.hidden = !isDeleteStatus || self.isUndeleteable;
    self.deleteButton.hidden = !isDeleteStatus || self.isUndeleteable;
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAppIconWidth, kAppIconHeight)];
        _logoImageView.backgroundColor = [UIColor clearColor];
        _logoImageView.layer.cornerRadius = KApplicationCornerRadius(kAppIconWidth);
        _logoImageView.layer.masksToBounds = NO;
        _logoImageView.image = [UIImage imageNamed:@"app_default_icon"];
    }
    
    return _logoImageView;
}

- (UIView *)redDot {
    if (!_redDot) {
        _redDot = [[UIView alloc] init];
        _redDot.backgroundColor = UIColorFromRGB(0xF35959);
        _redDot.layer.cornerRadius = 4.5;
        _redDot.hidden = YES;
    }
    
    return _redDot;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.numberOfLines = 0;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = FC1;
        _nameLabel.font = FS8;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _nameLabel;
}

- (UIImageView *)deleteImageView {
    if (!_deleteImageView) {
        _deleteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_btn_remove_normal"]];
        _deleteImageView.hidden = YES;
    }
    
    return _deleteImageView;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.hidden = YES;
    }
    
    return _deleteButton;
}

+ (CGSize)size {
    return CGSizeMake(kAppViewWidth, kAppViewHeight);
}

@end
