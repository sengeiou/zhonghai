//
//  KDVoiceMeetingMeImageView.m
//  kdweibo
//
//  Created by 张培增 on 16/9/7.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDVoiceMeetingMeImageView.h"

@implementation KDVoiceMeetingMeImageView

- (void)setImageViewType:(KDVoiceMeetingMeImageViewType)imageViewType {
    if (_imageViewType != imageViewType) {
        _imageViewType = imageViewType;
        switch (imageViewType) {
            case KDVoiceMeetingMeImageViewType_Mute:
            {
                [self addTitleMaskView:@"点击左方按钮\n打开话筒发言" maskViewColor:[UIColor colorWithRGB:0x04142a]];
            }
                break;
            case KDVoiceMeetingMeImageViewType_Speak:
            {
                [self removeMaskView];
            }
                break;
            case KDVoiceMeetingMeImageViewType_HandsUp:
            {
                [self addTitleMaskView:@"已申请发言\n请等待" maskViewColor:[UIColor colorWithRGB:0x04142a]];
            }
                break;
            case KDVoiceMeetingMeImageViewType_HandsDown:
            {
                [self addTitleMaskView:@"点击左方按钮\n举手申请发言" maskViewColor:[UIColor colorWithRGB:0x04142a]];
            }
                break;
            case KDVoiceMeetingMeImageViewType_BadNetwork:
            {
                [self addTitleMaskView:@"当前网络状况\n不佳" maskViewColor:[UIColor colorWithRGB:0xfa5454]];
            }
                break;
            default:
                break;
        }
    }
}

//静音蒙层
- (void)addMaskView {
    UIView *view = [self viewWithTag:20001];
    if (view) {
        [view removeFromSuperview];
    }
    
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectZero];
    maskView.backgroundColor = [UIColor colorWithRGB:0x04142a];
    maskView.alpha = 0.6;
    maskView.layer.cornerRadius = 45;
    maskView.layer.masksToBounds = YES;
    maskView.tag = 20001;
    [self addSubview:maskView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phone_btn_mute_big"]];
    [maskView addSubview:imageView];
    
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).with.insets(UIEdgeInsetsZero);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(maskView.mas_centerX);
        make.centerY.mas_equalTo(maskView.mas_centerY);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(28);
    }];
}

//文字蒙层
- (void)addTitleMaskView:(NSString *)title maskViewColor:(UIColor *)color {
    UIView *view = [self viewWithTag:20001];
    if (view) {
        [view removeFromSuperview];
    }
    
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectZero];
    maskView.backgroundColor = [UIColor clearColor];
    maskView.layer.cornerRadius = 45;
    maskView.layer.masksToBounds = YES;
    maskView.tag = 20001;
    [self addSubview:maskView];
    
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectZero];
    colorView.backgroundColor = color;
    colorView.alpha = 0.6;
    colorView.layer.cornerRadius = 45;
    colorView.layer.masksToBounds = YES;
    [maskView addSubview:colorView];
    [colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(maskView).with.insets(UIEdgeInsetsZero);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = FS8;
    titleLabel.textColor = FC6;
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    [maskView addSubview:titleLabel];
    
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).with.insets(UIEdgeInsetsZero);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.left).with.offset(10);
        make.right.mas_equalTo(self.right).with.offset(-10);
    }];
}

- (void)removeMaskView {
    UIView *maskView = [self viewWithTag:20001];
    if (maskView) {
        [maskView removeFromSuperview];
    }
}

@end
