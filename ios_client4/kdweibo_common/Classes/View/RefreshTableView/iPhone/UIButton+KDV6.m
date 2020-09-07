//
//  UIButton+KDV6.m
//  kdweibo
//
//  Created by Gil on 15/7/6.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "UIButton+KDV6.h"
#import "UIImage+Additions.h"
#import "KDStyleSyntaxSugar.h"



@implementation UIButton (KDV6)

+ (UIButton *)whiteBtnWithTitle:(NSString *)title {
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	float width = MAX(title.length, 3) * 14.0 + 8.0;
	[btn setFrame:CGRectMake(0.0, 0.0, width, 27.0)];
	[btn setTitle:title forState:UIControlStateNormal];
	[btn.titleLabel setFont:FS5];
	[btn setTitleColor:FC5 forState:UIControlStateNormal];
	[btn setTitleColor:FC7 forState:UIControlStateHighlighted];
	[btn setBackgroundImage:[UIImage imageWithColor:FC6] forState:UIControlStateNormal];
	[btn setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor3]] forState:UIControlStateHighlighted];
	btn.layer.borderColor = FC5.CGColor;
	btn.layer.borderWidth = 1;
    btn.clipsToBounds = YES;
	btn.layer.cornerRadius = 3;

	return btn;
}

- (void)changeToWhite {
    [self setTitleColor:FC5 forState:UIControlStateNormal];
    [self setTitleColor:FC7 forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:FC6] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor3]] forState:UIControlStateHighlighted];
    self.layer.borderColor = FC5.CGColor;
    self.layer.borderWidth = 1;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 3;
}

+ (UIButton *)blueBtnWithTitle:(NSString *)title {
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	float width = MAX(title.length, 3) * 14.0 + 8.0;
	[btn setFrame:CGRectMake(0.0, 0.0, width, 27.0)];
	[btn setTitle:title forState:UIControlStateNormal];
	[btn.titleLabel setFont:FS3];
	[btn setTitleColor:FC6 forState:UIControlStateNormal];
	[btn setTitleColor:FC6 forState:UIControlStateHighlighted];
	[btn setBackgroundImage:[UIImage imageWithColor:FC5] forState:UIControlStateNormal];
	[btn setBackgroundImage:[UIImage imageWithColor:FC7] forState:UIControlStateHighlighted];
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius = CGRectGetHeight(btn.frame)/2;
    btn.layer.masksToBounds = YES;


	return btn;
}

+ (UIButton *)normalBtnWithTile:(NSString *)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    float width = MAX(title.length, 3) * 14.0 + 8.0;
    [btn setFrame:CGRectMake(0.0, 0.0, width, 27.0)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:FS3];
    [btn setTitleColor:FC5 forState:UIControlStateNormal];
    [btn setTitleColor:FC7 forState:UIControlStateHighlighted];
    [btn setTitleColor:FC3 forState:UIControlStateDisabled];
    [btn setBackgroundImage:[UIImage imageWithColor:FC6] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor3]] forState:UIControlStateHighlighted];
//    btn.layer.borderColor = FC5.CGColor;
//    btn.layer.borderWidth = 1;
    btn.clipsToBounds = YES;
//    btn.layer.cornerRadius = 3;
    
    return btn;
}

- (void)changeToBlue {
    [self setTitleColor:FC6 forState:UIControlStateNormal];
    [self setTitleColor:FC6 forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:FC5] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:FC7] forState:UIControlStateHighlighted];
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.borderWidth = 0;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 3;
}

+ (UIButton *)grayBtnWithTitle:(NSString *)title {
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	float width = MAX(title.length, 3) * 14.0 + 8.0;
	[btn setFrame:CGRectMake(0.0, 0.0, width, 27.0)];
	[btn setTitle:title forState:UIControlStateNormal];
	[btn.titleLabel setFont:FS3];
	[btn setTitleColor:FC2 forState:UIControlStateNormal];
	[btn setTitleColor:FC2 forState:UIControlStateHighlighted];
	[btn setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor2]] forState:UIControlStateNormal];
	[btn setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor2]] forState:UIControlStateHighlighted];
    btn.layer.borderColor = [UIColor kdDividingLineColor].CGColor;
    btn.layer.borderWidth = 1;
    btn.clipsToBounds = YES;
	btn.layer.cornerRadius = 3;

	return btn;
}

- (void)changeToGray {
    [self setTitleColor:FC2 forState:UIControlStateNormal];
    [self setTitleColor:FC2 forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor2]] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor2]] forState:UIControlStateHighlighted];
    self.layer.borderColor = [UIColor kdDividingLineColor].CGColor;
    self.layer.borderWidth = 1;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 3;
}


- (void)setCircle
{
    self.layer.cornerRadius = CGRectGetHeight(self.frame)/2;
    self.layer.masksToBounds = YES;
}

+ (UIButton *)backBtnInWhiteNavWithTitle:(NSString *)title {
    return [self backBtnInWhiteNavWithTitle:title inNav:YES];
}

+ (UIButton *)backBtnInWhiteNavWithTitle:(NSString *)title inNav:(BOOL)inNav {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat titleLength = title.length;
    if (titleLength == 0) {
        title = ASLocalizedString(@"Global_GoBack");
    }
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:AppLanguage] isEqualToString:@"en"]) {
        titleLength = 3;
    }
    float width = titleLength * 14.0 + 8.0;
    width += 16;
    [btn setFrame:CGRectMake(0.0, 0.0, width, 27)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:FS3];
    [btn setTitleColor:FC5 forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRGB:0xDFEBF2] forState:UIControlStateHighlighted];
    [btn setImage:[[UIImage imageNamed:@"nav_btn_back_light_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 0)] forState:UIControlStateNormal];
    [btn setImage:[[UIImage imageNamed:@"nav_btn_back_light_highlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 0)] forState:UIControlStateHighlighted];
    if (inNav) {
        if (isiPhone6Plus) {
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0.667, -13, -0.667, 13)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0.667, -7, -0.667, 7)];
        }
        else {
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0.5, -11 , -0.5, 11)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(1, -9 , -1, 9)];
        }
    }
    else {
        if (isiPhone6Plus) {
            [btn setImageEdgeInsets:UIEdgeInsetsMake(-0.333, 0, 0.333, 0)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(-0.333, 6, 0.333, -6)];
        }
        else {
            [btn setImageEdgeInsets:UIEdgeInsetsMake(-0.5, -4, 0.5, 4)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
        }
    }
    return btn;
}

+ (UIButton *)cancelButtonInPresentedVC
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *strTitle = ASLocalizedString(@"Global_Cancel");
    [btn setFrame:CGRectMake(0.0, 0.0, 40, 27)];
    [btn setTitle:strTitle forState:UIControlStateNormal];
    [btn.titleLabel setFont:FS3];
    [btn setTitleColor:FC5 forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRGB:0xDFEBF2] forState:UIControlStateHighlighted];
    CGFloat space = 0;
    if (isiPhone6Plus) {
        space = 2;
    }
    return btn;
}

+ (UIButton *)backBtnInBlueNavWithTitle:(NSString *)title {
    return [self backBtnInBlueNavWithTitle:title inNav:YES];
}

+ (UIButton *)backBtnInBlueNavWithTitle:(NSString *)title inNav:(BOOL)inNav {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title.length == 0) {
        title = ASLocalizedString(@"Global_GoBack");
    }
    float width = title.length * 14.0 + 8.0;
    width += 16;
    [btn setFrame:CGRectMake(0.0, 0.0, width, 27)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:FS3];
    [btn setTitleColor:FC6 forState:UIControlStateNormal];
    [btn setTitleColor:[FC6 colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [btn setImage:[[UIImage imageNamed:@"nav_btn_back_dark_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 0)] forState:UIControlStateNormal];
    [btn setImage:[[UIImage imageNamed:@"nav_btn_back_dark_press"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 0)] forState:UIControlStateHighlighted];
    if (inNav) {
        if (isiPhone6Plus) {
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0.667, -13, -0.667, 13)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0.667, -7, -0.667, 7)];
        }
        else {
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0.5, -11 , -0.5, 11)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(1, -9 , -1, 9)];
        }
    }
    else {
        if (isiPhone6Plus) {
            [btn setImageEdgeInsets:UIEdgeInsetsMake(-0.333, 0, 0.333, 0)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(-0.333, 6, 0.333, -6)];
        }
        else {
            [btn setImageEdgeInsets:UIEdgeInsetsMake(-0.5, -4, 0.5, 4)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
        }
    }
    return btn;
}

+ (UIButton *)btnInNavWithImage:(UIImage *)image
               highlightedImage:(UIImage *)highlightedImage {
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	if (image) {
		[btn setImage:image forState:UIControlStateNormal];
		[btn setBounds:CGRectMake(0, 0, image.size.width, image.size.height)];
	}
	if (highlightedImage) {
		[btn setImage:highlightedImage forState:UIControlStateHighlighted];
	}
    if (isiPhone6Plus) {
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 8, 0, -8)];
    }
    else {
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 3, 0, -3)];
    }
	return btn;
}

@end
