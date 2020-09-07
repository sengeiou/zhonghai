//
//  UIButton+KDV7.h
//  kdweibo
//
//  Created by Scan on 16/5/26.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (KDV7)

+ (UIButton *)whiteBtnWithTitle_V7:(NSString *)title;
+ (UIButton *)blueBtnWithTitle_V7:(NSString *)title;
+ (UIButton *)grayBtnWithTitle_V7:(NSString *)title;
+ (UIButton *)yellowBtnWithTitle_V7:(NSString *)title;
/// 白底蓝字蓝边框
+ (UIButton *)whiteBlueBorderBtnWithTitle:(NSString *)title;

- (void)changeToWhite_V7;
- (void)changeToWhiteNoBorder_V7;
- (void)changeToBlue_V7;
- (void)changeToGray_V7;
- (void)changeToWhiteBlueBorder;

/**
 *  蓝色按钮变成灰色标题按钮。背景为白色
 */
- (void)blueBtnChangeToGrayTitle_noBorder_V7;

@end
