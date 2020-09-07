//
//  KDInputView.h
//  kdweibo
//
//  Created by Darren on 15/7/10.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDPasswordTextField.h"

/*
 [imageViewLeft/label] [textFieldMain] [imageViewRight/label)]
 --------------------------------------------------------
 */

typedef NS_ENUM(NSInteger,KDInputViewElement)
{
    KDInputViewElementNone              = 0,        // 纯文本框
    KDInputViewElementImageViewLeft     = 1 << 0,   // 左为图片
    KDInputViewElementLabelLeft         = 1 << 1,   // 左为文本
    KDInputViewElementButtonRight       = 1 << 2,   // 右为按钮
    KDInputViewElementLabelRight        = 1 << 3,   // 右为文本
};

@interface KDInputView : UIView

- (instancetype)initWithElement:(KDInputViewElement)element;    // 指定初始化方法。element：样式，复选
// xib
- (void)updateWithElement:(KDInputViewElement)element;

// 控件指针
@property (nonatomic, strong) KDPasswordTextField *textFieldMain;                       // 主文本框
@property (nonatomic, strong) UIImageView *imageViewLeft;                       // 图标
@property (nonatomic, strong) UIButton *buttonRight;                            // 密码明文眼睛
@property (nonatomic, copy) void (^blockButtonRightPressed)(UIButton *button);  // 右侧按钮点击
@property (nonatomic, strong) UILabel *labelRight;                              // 倒计时
@property (nonatomic, strong) UILabel *labelLeft;                               // +86
@property (nonatomic, strong) UIView *viewLine;                                 // 未激活灰色，激活蓝色
@property (nonatomic, assign) float fButtonRightWidth;   // 右侧按钮的宽度


//- (void)changeToKDV7Style;

@end
