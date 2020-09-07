//
//  UIButton+XT.m
//  XT
//
//  Created by Gil on 13-7-5.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "UIButton+XT.h"
#import "UIImage+XT.h"

@implementation UIButton (XT)

+ (UIButton *)buttonWithTitle:(NSString *)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    float width = title.length * 15.0 + 24.0 + 5.0;
    if (width < 59.0) {
        width = 59.0;
    }
    [btn setFrame:CGRectMake(0.0, 0.0, width, 43.0)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:FC5 forState:UIControlStateNormal];
    [btn setTitleColor:FC5 forState:UIControlStateHighlighted];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    
    return btn;
}

+ (UIButton *)backButton
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundImage:[XTImageUtil buttonBackImageWithState:UIControlStateNormal] forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[XTImageUtil buttonBackImageWithState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [backBtn sizeToFit];
    return backBtn;
}

+ (UIButton *)scanButtonWithTitle:(NSString *)title
{
    if (title.length == 0) {
        title = @"";
    }
    
    UIButton *scanBtn = [self buttonWithTitle:title];
    [scanBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0)];
    [scanBtn setTitleColor:BOSCOLORWITHRGBA(0x94c7f3, 1.0) forState:UIControlStateNormal];
    [scanBtn setTitleColor:BOSCOLORWITHRGBA(0x769fc2, 1.0) forState:UIControlStateHighlighted];
    [scanBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [scanBtn setBackgroundImage:[XTImageUtil qrButtonScanImageWithState:UIControlStateNormal] forState:UIControlStateNormal];
    [scanBtn setBackgroundImage:[XTImageUtil qrButtonScanImageWithState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    return scanBtn;
}

+ (UIButton *)greenButtonWithTitle:(NSString *)title
{
    CGRect rect = CGRectMake(7.0f, 0.0f, ScreenFullWidth - 14.0f, 41.0f);
    UIButton *greenBtn = [[UIButton alloc] initWithFrame:rect];
    greenBtn.layer.cornerRadius = 3.0f;
    greenBtn.layer.masksToBounds = YES;
    [greenBtn setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(32, 192, 0)] forState:UIControlStateNormal];
    [greenBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 30.0f)];
    [greenBtn setTitle:title forState:UIControlStateNormal];
    greenBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [greenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [greenBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    return greenBtn;
}

+ (UIButton *)redButtonWithTitle:(NSString *)title
{
    CGRect rect = CGRectMake(7.0f, 0.0f, ScreenFullWidth - 14.0f, 41.0f);
    UIButton *redBtn = [[UIButton alloc] initWithFrame:rect];
    redBtn.layer.cornerRadius = 3.0f;
    redBtn.layer.masksToBounds = YES;
    [redBtn setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(255, 102, 0)] forState:UIControlStateNormal];
    [redBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 30.0f)];
    [redBtn setTitle:title forState:UIControlStateNormal];
    redBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [redBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [redBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    return redBtn;
}

+ (UIButton *)whiteButtonWithTitle:(NSString *)title
{
    CGRect rect = CGRectMake(7.0f, 0.0f, ScreenFullWidth - 14.0f, 41.0f);
    UIButton *whiteBtn = [[UIButton alloc] initWithFrame:rect];
    whiteBtn.layer.cornerRadius = 3.0f;
    whiteBtn.layer.masksToBounds = YES;
    [whiteBtn.layer setBorderWidth:1.0];
    [whiteBtn.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [whiteBtn setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0xF0F0F0, 1.0)] forState:UIControlStateNormal];
    [whiteBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 30.0f)];
    [whiteBtn setTitle:title forState:UIControlStateNormal];
    whiteBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [whiteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [whiteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    return whiteBtn;
}

- (void)setTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
    
    float width = title.length * 15.0 + 24.0 + 5.0;
    if (width < 59.0) {
        width = 59.0;
    }
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height)];
}

@end
