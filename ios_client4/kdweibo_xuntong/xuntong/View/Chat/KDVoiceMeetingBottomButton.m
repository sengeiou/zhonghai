//
//  KDVoiceMeetingBottomButton.m
//  kdweibo
//
//  Created by 张培增 on 16/8/16.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDVoiceMeetingBottomButton.h"

@interface KDVoiceMeetingBottomButton ()

@property (nonatomic, strong) UILabel           *textLabel;
@property (nonatomic, strong) UISwitch          *aSwitch;

@end

@implementation KDVoiceMeetingBottomButton

+ (KDVoiceMeetingBottomButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title image:(UIImage *)image imageIsSquare:(BOOL)isSquare {
    KDVoiceMeetingBottomButton *button = [KDVoiceMeetingBottomButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdBackgroundColor7]] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage kd_imageWithColor:[UIColor colorWithRGB:0xdbdee2]] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage kd_imageWithColor:[UIColor colorWithRGB:0xdbdee2]] forState:UIControlStateSelected];
    
    CGSize size = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:FS4} context:nil].size;
    CGFloat imageWidth = 0;
    if (isSquare) {
        imageWidth = 20;
    }
    else {
        imageWidth = 15;
    }
    CGFloat width = imageWidth + 8 + ceilf(size.width);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [button addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(button.mas_centerX).with.offset(-width/2);
        make.top.mas_equalTo(button.mas_centerY).with.offset(-10);
        make.width.mas_equalTo(imageWidth);
        make.height.mas_equalTo(20);
    }];
    
    button.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    button.textLabel.text = title;
    button.textLabel.textColor = FC2;
    button.textLabel.font = FS4;
    [button addSubview:button.textLabel];
    [button.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(button.mas_centerX).with.offset(width/2);
        make.top.mas_equalTo(button.mas_centerY).with.offset(-size.height/2);
        make.width.mas_equalTo(ceilf(size.width));
        make.height.mas_equalTo(size.height);
    }];
    
//    UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
//    line.backgroundColor = [UIColor colorWithRGB:0xdbdee2];
//    [button addSubview:line];
//    [line mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.and.right.and.top.mas_equalTo(button);
//        make.height.mas_equalTo(0.5);
//    }];
    
    return button;
}

+ (KDVoiceMeetingBottomButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title selectedColor:(UIColor *)selectedColor {
    KDVoiceMeetingBottomButton *button = [KDVoiceMeetingBottomButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdBackgroundColor7]] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage kd_imageWithColor:[UIColor colorWithRGB:0xdbdee2]] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage kd_imageWithColor:[UIColor colorWithRGB:0xdbdee2]] forState:UIControlStateSelected];
    
    CGSize size = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:FS4} context:nil].size;
    CGFloat width = ceilf(size.width) + 8 + 40;
    
    button.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    button.textLabel.text = title;
    button.textLabel.textColor = FC2;
    button.textLabel.font = FS4;
    [button addSubview:button.textLabel];
    [button.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(button.mas_centerX).with.offset(-width/2);
        make.top.mas_equalTo(button.mas_centerY).with.offset(-size.height/2);
        make.width.mas_equalTo(ceilf(size.width));
        make.height.mas_equalTo(size.height);
    }];
    
    button.aSwitch = [[UISwitch alloc] init];
    button.aSwitch.transform = CGAffineTransformMakeScale(0.6, 0.6);
    button.aSwitch.userInteractionEnabled = NO;
    button.aSwitch.onTintColor = selectedColor;
    [button addSubview:button.aSwitch];
    [button.aSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(button.mas_centerX).with.offset(width/2);
        make.top.mas_equalTo(button.mas_centerY).with.offset(-15);
    }];
    
//    UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
//    line.backgroundColor = [UIColor colorWithRGB:0xdbdee2];
//    [button addSubview:line];
//    [line mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.and.right.and.top.mas_equalTo(button);
//        make.height.mas_equalTo(0.5);
//    }];
    
    return button;
}

- (void)changeToHostMode {
    self.textLabel.textColor = FC10;
    self.aSwitch.on = YES;
}

- (void)changeToFreeMode {
    self.textLabel.textColor = FC2;
    self.aSwitch.on = NO;
}

@end
