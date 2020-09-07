//
//  UIButton+XT.h
//  XT
//
//  Created by Gil on 13-7-5.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIButton (XT)

+ (UIButton *)buttonWithTitle:(NSString *)title;
+ (UIButton *)backButton;
+ (UIButton *)scanButtonWithTitle:(NSString *)title;
+ (UIButton *)greenButtonWithTitle:(NSString *)title;
+ (UIButton *)redButtonWithTitle:(NSString *)title;
+ (UIButton *)whiteButtonWithTitle:(NSString *)title;

- (void)setTitle:(NSString *)title;

@end
