//
//  UIButton+Factory.m
//  kdweibo
//
//  Created by AlanWong on 14/12/30.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "UIButton+Factory.h"

@implementation UIButton (Factory)
+(UIButton *)blueRoundedButtonWithTitle:(NSString *)buttonTitle{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    button.backgroundColor = RGBCOLOR(23, 131, 253);
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    button.layer.cornerRadius = 5.0f;
    button.layer.masksToBounds = YES;
    [button sizeToFit];
    return button;
}

+(UIBarButtonItem *)textBarButtonItemWithTitle:(NSString *)buttonTitle addTarget:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setButtonTitle:buttonTitle];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [button setTitleColor:FC5 forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButton;
}

- (void)setButtonTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
    
    float width = title.length * 15.0 + 24.0 + 5.0;
    if (width < 59.0) {
        width = 59.0;
    }
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height)];
}
@end
