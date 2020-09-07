//
//  UIButton+KDV7.m
//  kdweibo
//
//  Created by Scan on 16/5/26.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "UIButton+KDV7.h"

@implementation UIButton (KDV7)

+ (UIButton *)whiteBtnWithTitle_V7:(NSString *)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    float width = title.length * 14.0 + 24.0;
    [btn setFrame:CGRectMake(0.0, 0.0, width, 27.0)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:FS7];
    [btn setTitleColor:FC2 forState:UIControlStateNormal];
    [btn setBackgroundColor:FC6];
//    [btn setTitleColor:FC7 forState:UIControlStateHighlighted];
//    [btn setBackgroundImage:[UIImage kd_imageWithColor:FC6] forState:UIControlStateNormal];
//    [btn setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdBackgroundColor3]] forState:UIControlStateHighlighted];
    btn.layer.borderColor = FC5.CGColor;
    btn.layer.borderWidth = 0.5;
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius = CGRectGetHeight(btn.bounds)/2;
    
    return btn;
}

- (void)changeToWhite_V7
{
    [self setTitleColor:FC2 forState:UIControlStateNormal];
//    [self setTitleColor:FC7 forState:UIControlStateHighlighted];
//    [self setBackgroundImage:[UIImage kd_imageWithColor:FC6] forState:UIControlStateNormal];
//    [self setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdBackgroundColor3]] forState:UIControlStateHighlighted];
    [self setBackgroundColor:FC6];

    self.layer.borderColor = UIColorFromRGB(0xB9C7D2).CGColor;
    self.layer.borderWidth = 0.5;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
}

- (void)changeToWhiteNoBorder_V7
{
    [self setTitleColor:FC2 forState:UIControlStateNormal];
    //    [self setTitleColor:FC7 forState:UIControlStateHighlighted];
    //    [self setBackgroundImage:[UIImage kd_imageWithColor:FC6] forState:UIControlStateNormal];
    //    [self setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdBackgroundColor3]] forState:UIControlStateHighlighted];
    [self setBackgroundColor:FC6];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
}




+ (UIButton *)blueBtnWithTitle_V7:(NSString *)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    float width = title.length * 14.0 + 24.0;
    
    [btn setFrame:CGRectMake(0.0, 0.0, width, 27.0)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:FS7];
    
    [btn setTitleColor:FC6 forState:UIControlStateNormal];
    
    [btn setBackgroundColor:FC5];

//    [btn setTitleColor:FC6 forState:UIControlStateHighlighted];
//    [btn setBackgroundImage:[UIImage kd_imageWithColor:FC5] forState:UIControlStateNormal];
//    [btn setBackgroundImage:[UIImage kd_imageWithColor:FC7 coverColor:[UIColor kdBlackColor]] forState:UIControlStateHighlighted];
    
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius = CGRectGetHeight(btn.bounds)/2;
    
    return btn;
}

- (void)changeToBlue_V7
{
    [self setTitleColor:FC6 forState:UIControlStateNormal];
    [self setBackgroundColor:FC5];

//    [self setTitleColor:FC6 forState:UIControlStateHighlighted];
//    [self setBackgroundImage:[UIImage kd_imageWithColor:FC5] forState:UIControlStateNormal];
//    [self setBackgroundImage:[UIImage kd_imageWithColor:FC5 coverColor:[UIColor kdBlackColor]] forState:UIControlStateHighlighted];
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.borderWidth = 0;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
}

+ (UIButton *)grayBtnWithTitle_V7:(NSString *)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    float width = title.length * 14.0 + 24.0;
    [btn setFrame:CGRectMake(0.0, 0.0, width, 27.0)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:FS5];
    [btn setTitleColor:FC2 forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor kdDividingLineColor]];

//    [btn setTitleColor:FC2 forState:UIControlStateHighlighted];
//    [btn setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdDividingLineColor]] forState:UIControlStateNormal];
//    [btn setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdDividingLineColor] coverColor:[UIColor kdBlackColor]] forState:UIControlStateHighlighted];
    btn.layer.borderColor = [UIColor kdDividingLineColor].CGColor;
    btn.layer.borderWidth = 0;
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius = CGRectGetHeight(btn.bounds)/2;
    
    return btn;
}

- (void)changeToGray_V7
{
    [self setTitleColor:FC2 forState:UIControlStateNormal];
    [self setBackgroundColor:[UIColor kdDividingLineColor]];

//    [self setTitleColor:FC2 forState:UIControlStateHighlighted];
//    [self setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdDividingLineColor]] forState:UIControlStateNormal];
//    [self setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdDividingLineColor] coverColor:[UIColor kdBlackColor]] forState:UIControlStateHighlighted];
    self.layer.borderColor = [UIColor kdDividingLineColor].CGColor;
    self.layer.borderWidth = 0;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
}

+ (UIButton *)yellowBtnWithTitle_V7:(NSString *)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    float width = title.length * 14.0 + 24.0;
    [btn setFrame:CGRectMake(0.0, 0.0, width, 27.0)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:FS5];
    [btn setTitleColor:FC6 forState:UIControlStateNormal];
    [btn setBackgroundColor:UIColorFromRGB(0xf7bf28)];

//    [btn setTitleColor:FC6 forState:UIControlStateHighlighted];
//    [btn setBackgroundImage:[UIImage kd_imageWithColor:UIColorFromRGB(0xf7bf28)] forState:UIControlStateNormal];
//    [btn setBackgroundImage:[UIImage kd_imageWithColor:UIColorFromRGB(0xf7bf28) coverColor:[UIColor kdBlackColor]] forState:UIControlStateHighlighted];
    btn.layer.borderColor = [UIColor clearColor].CGColor;
    btn.layer.borderWidth = 1;
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius = CGRectGetHeight(btn.bounds)/2;

    return btn;
}

- (void)blueBtnChangeToGrayTitle_noBorder_V7
{
    [self setTitleColor:FC2 forState:UIControlStateNormal];
    [self setBackgroundColor:[UIColor kdBackgroundColor2]];

//    [self setTitleColor:FC2 forState:UIControlStateHighlighted];
//    [self setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdBackgroundColor2]] forState:UIControlStateNormal];
//    [self setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdBackgroundColor2]] forState:UIControlStateHighlighted];
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.borderWidth = 0;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
}

+ (UIButton *)whiteBlueBorderBtnWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    float width = title.length * 14.0 + 24.0;
    [btn setFrame:CGRectMake(0.0, 0.0, width, 27.0)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:FS7];
    [btn setTitleColor:FC5 forState:UIControlStateNormal];
    [btn setBackgroundColor:FC6];
    btn.layer.borderColor = FC5.CGColor;
    btn.layer.borderWidth = 0.5;
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius = CGRectGetHeight(btn.bounds)/2;
    
    return btn;
}

- (void)changeToWhiteBlueBorder {
    [self setTitleColor:FC5 forState:UIControlStateNormal];
    [self setBackgroundColor:FC6];
    
    self.layer.borderColor = FC5.CGColor;
    self.layer.borderWidth = 0.5;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
}

@end
