//
//  KDChatDetailHeaderCell.m
//  kdweibo
//
//  Created by kyle on 16/9/29.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDChatDetailHeaderCell.h"

@implementation KDChatDetailHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _groupHeaderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        _groupHeaderImageView.layer.cornerRadius = 35.0;
        _groupHeaderImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.groupHeaderImageView];
        
        [self.groupHeaderImageView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(23);
            make.centerX.equalTo(self.contentView.centerX);
            make.width.height.equalTo(@70);
        }];
        
//        _canmeraImageView = [[UIImageView alloc] initWithImage:[UIImage kd_imageWithColor:YZJ_BLUE]];
//        _canmeraImageView.layer.cornerRadius = 10.5;
//        _canmeraImageView.layer.masksToBounds = YES;
//        [self.contentView addSubview:self.canmeraImageView];
//        [self.canmeraImageView makeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(self.groupHeaderImageView);
//            make.bottom.equalTo(self.groupHeaderImageView);
//            make.width.height.mas_equalTo(21);
//        }];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor = FC1;
        _nameLabel.font = FS3;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.numberOfLines = 1;
        _nameLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClicked)];
        [_nameLabel addGestureRecognizer:tap];
        
        [self.contentView addSubview:_nameLabel];
        
        _editGroupNameBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_editGroupNameBtn setImage:[UIImage imageNamed:@"edit_group_name"] forState:UIControlStateNormal];
        [_editGroupNameBtn addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_editGroupNameBtn];
        
        
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.groupHeaderImageView.bottom).offset(10);
            make.centerX.equalTo(self.contentView.centerX);
            make.height.equalTo(@34);
        }];
        
        self.extImageView = [[UIImageView alloc] init];
        self.extImageView.image = [UIImage imageNamed:@"message_tip_shang_small"];
        self.extImageView.hidden = YES;
        [self.contentView addSubview:self.extImageView];
        [self.extImageView remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.nameLabel.left).offset(-4);
            make.centerY.equalTo(self.nameLabel.centerY);
            make.width.height.mas_equalTo(16);
        }];
        [_editGroupNameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.right).offset(4);
            make.centerY.equalTo(self.nameLabel.centerY);
            make.width.height.mas_equalTo(16);
        }];
        
//        [self.contentView kd_setupVFL: @{
//                             @"groupHeaderImageView": self.groupHeaderImageView,
//                             @"nameLabel": self.nameLabel,
//                             @"editGroupNameBtn": self.editGroupNameBtn
//                             }
//                  metrics:@{
//                            @"nameLabelMaxLenght": @(ScreenFullWidth - (30 * 2))
//                            }
//              constraints: @[
//                             @"V:|-23-[groupHeaderImageView(70)]-10-[nameLabel]",
//                             @"H:[groupHeaderImageView(70)]",
//                             @"H:[nameLabel(<=nameLabelMaxLenght)]-4-[editGroupNameBtn]"
//                             ]
//         delayInvoke:false];
//        
//        [self.groupHeaderImageView kd_setCenterXWithImmediately:YES];
//        [self.editGroupNameBtn kd_setCenterYToItem:self.nameLabel immediately:YES];
//        [self.nameLabel kd_setCenterXWithImmediately:YES];
//        [self.nameLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        //外
    }
    
    return self;
}

- (void)buttonClicked {
    if (self.block) {
        self.block();
    }
}

- (void)setNameLabelValue:(NSString *)text {
    _nameLabel.text = text;
    [_nameLabel remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupHeaderImageView.bottom).offset(10);
        make.centerX.equalTo(self.contentView.centerX);
    }];
    
    [_editGroupNameBtn remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.right).offset(4);
        make.right.lessThanOrEqualTo(self.contentView.right).with.offset(-12);
        make.centerY.equalTo(self.nameLabel.centerY);
        make.width.height.mas_equalTo(16);
    }];
    
    if (!self.extImageView.hidden) {
        [self.extImageView remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.nameLabel.left).offset(-4);
            make.centerY.equalTo(self.nameLabel.centerY);
            make.width.height.mas_equalTo(16);
        }];
    }
}

@end
