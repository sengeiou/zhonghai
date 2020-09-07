//
//  UITableView+TopWhiteBackground.m
//  kdweibo
//
//  Created by Joyingx on 2016/10/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "UITableView+TopWhiteBackground.h"

@interface UITableView ()

@property (nonatomic, strong) UIView *topWhiteBackgroundView;

@end

@implementation UITableView (TopWhiteBackground)

- (void)setShouldShowTopWhiteBackground:(BOOL)shouldShowTopWhiteBackground {
    objc_setAssociatedObject(self, @selector(shouldShowTopWhiteBackground), @(shouldShowTopWhiteBackground), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (shouldShowTopWhiteBackground) {
        [self insertSubview:self.topWhiteBackgroundView atIndex:0];
    } else {
        [self.topWhiteBackgroundView removeFromSuperview];
    }
}

- (BOOL)shouldShowTopWhiteBackground {
    return objc_getAssociatedObject(self, @selector(shouldShowTopWhiteBackground));
}

- (void)setTopWhiteBackgroundView:(UIView *)topWhiteBackgroundView {
    objc_setAssociatedObject(self, @selector(topWhiteBackgroundView), topWhiteBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)topWhiteBackgroundView {
    UIView *view = objc_getAssociatedObject(self, @selector(topWhiteBackgroundView));
    if (!view) {
        CGFloat width = ScreenFullWidth > ScreenFullHeight ? ScreenFullWidth : ScreenFullHeight;
        view = [[UIView alloc] initWithFrame:CGRectMake(0, -width, width, width)];
        view.backgroundColor = [UIColor kdBackgroundColor2];
    }
    
    return view;
}

@end
