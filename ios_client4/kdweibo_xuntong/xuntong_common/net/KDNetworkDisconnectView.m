//
//  KDNetworkDisconnectView.m
//  kdweibo
//
//  Created by kyle on 16/5/27.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDNetworkDisconnectView.h"

@interface KDNetworkDisconnectView()

@property (nonatomic, strong) UIImageView *imageViewIcon;
@property (nonatomic, strong) UILabel *labelTitle;

@end

@implementation KDNetworkDisconnectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor kdBackgroundColor4];
//        self.alpha = .9;
        
        [self addSubview:self.imageViewIcon];
        
        [self.imageViewIcon makeConstraints:^(MASConstraintMaker *make){
             make.left.equalTo(self.left).with.offset(12);
             make.width.mas_equalTo(20);
             make.height.mas_equalTo(20);
             make.centerY.equalTo(self.centerY);
         }];
        
        [self addSubview:self.labelTitle];
        
        [self.labelTitle makeConstraints:^(MASConstraintMaker *make){
             make.left.equalTo(self.imageViewIcon.right).with.offset(12);
             make.right.equalTo(self.right).with.offset(-23);
             make.centerY.equalTo(self.centerY);
         }];
    }
    return self;
}

- (UIImageView *)imageViewIcon
{
    if (!_imageViewIcon){
        _imageViewIcon = [UIImageView new];
        _imageViewIcon.image = [UIImage imageNamed:@"common_tip_remind"];
    }
    return _imageViewIcon;
}

- (UILabel *)labelTitle{
    if (!_labelTitle){
        _labelTitle = [UILabel new];
        _labelTitle.font = FS5;
        _labelTitle.textColor = FC4;
        _labelTitle.text = @"网络连接不可用";
    }
    return _labelTitle;
}

@end
