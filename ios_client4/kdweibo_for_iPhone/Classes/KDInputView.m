//
//  KDInputView.m
//  kdweibo
//
//  Created by Darren on 15/7/10.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDInputView.h"

@interface KDInputView ()
@property (nonatomic, assign) KDInputViewElement element;
@end

@implementation KDInputView


- (instancetype)initWithElement:(KDInputViewElement)element
{
    if (self = [super init])
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.element = element;
        [self updateWithElement:element];
    }
    return self;
}

- (void)updateWithElement:(KDInputViewElement)element
{
    [self.viewLine removeFromSuperview];
    [self.imageViewLeft removeFromSuperview];
    [self.labelLeft removeFromSuperview];
    [self.buttonRight removeFromSuperview];
    [self.labelRight removeFromSuperview];
    [self.textFieldMain removeFromSuperview];
    
    // 画线
    [self addSubview:self.viewLine];

    [self.viewLine makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.left).with.offset(0);
         make.right.equalTo(self.right).with.offset(-0);
         make.bottom.equalTo(self.bottom).with.offset(-0);
         make.height.mas_equalTo(1);
     }];
    
    // 左侧图片/文本二选一
    if ([self containElement:KDInputViewElementImageViewLeft])
    {
        [self addSubview:self.imageViewLeft];

        [self.imageViewLeft makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.left).with.offset(0);
             make.width.mas_equalTo(15);
             make.height.mas_equalTo(20);
             make.centerY.equalTo(self.centerY);
         }];
    }
    else if ([self containElement:KDInputViewElementLabelLeft])
    {
        [self addSubview:self.labelLeft];

        [self.labelLeft makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.left).with.offset(0);
             make.width.mas_equalTo(35);
             make.centerY.equalTo(self.centerY);
         }];
    }
    
    // 右侧按钮/文本二选一
    if ([self containElement:KDInputViewElementButtonRight])
    {
        [self addSubview:self.buttonRight];

        [self.buttonRight makeConstraints:^(MASConstraintMaker *make)
         {
             if (self.fButtonRightWidth>0)
             {
                 make.width.mas_equalTo(self.fButtonRightWidth);
             }
             else
             {
                 make.width.mas_equalTo(70);
             }
             make.right.equalTo(self.right).with.offset(-0);
             make.height.mas_equalTo(30);
             make.centerY.equalTo(self.centerY);
         }];
    }
    else if ([self containElement:KDInputViewElementLabelRight])
    {
        [self addSubview:self.labelRight];
        
        [self.labelRight makeConstraints:^(MASConstraintMaker *make)
         {
             make.right.equalTo(self.right).with.offset(-0);
             make.width.mas_equalTo(20);
             make.centerY.equalTo(self.centerY);
         }];
    }
    
    // 确定了左和右，开始算中间文本框
    [self addSubview:self.textFieldMain];
    
    [self.textFieldMain makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerY.equalTo(self.centerY);
         if ([self containElement:KDInputViewElementImageViewLeft])
         {
             make.left.equalTo(self.imageViewLeft.right).with.offset(9);
         }
         else if ([self containElement:KDInputViewElementLabelLeft])
         {
             make.left.equalTo(self.labelLeft.right).with.offset(0);
         }
         else
         {
             make.left.equalTo(self.left).with.offset(0);
         }
         
         if ([self containElement:KDInputViewElementButtonRight])
         {
             make.right.equalTo(self.buttonRight.left).with.offset(0);
         }
         else if ([self containElement:KDInputViewElementLabelRight])
         {
             make.right.equalTo(self.labelRight.left).with.offset(9);
         }
         else
         {
             make.right.equalTo(self.right).with.offset(0);
         }
     }];
}

- (void)setFButtonRightWidth:(float)fButtonRightWidth
{
    _fButtonRightWidth = fButtonRightWidth;
    
    [self.buttonRight updateConstraints:^(MASConstraintMaker *make)
     {
         if (self.fButtonRightWidth > 0)
         {
             make.width.mas_equalTo(self.fButtonRightWidth);
         }
         else
         {
             make.width.mas_equalTo(70);
         }
     }];
}

//- (void)setElement:(KDInputViewElement)element
//{
//    [self updateWithElement:element];
//}


- (void)drawRect:(CGRect)rect
{
    
}

- (BOOL)containElement:(KDInputViewElement)el
{
    return (self.element & el) == el;
}

#pragma mark - KDStyle Setting

//- (void)changeToKDV7Style
//{
//    _v7StyleSpace = 20.f;
//    [self updateWithElement:self.element];
//    
//    self.clipsToBounds = YES;
//    self.viewLine.hidden = YES;
//    self.backgroundColor = self.isAuthMode?[UIColor colorWithHexRGB:@"2e63b6" alpha:.2f]:[UIColor kdBackgroundColor7];
//}

- (UILabel *)labelLeft
{
    if (!_labelLeft)
    {
        _labelLeft = [UILabel new];
        _labelLeft.font = FS4;
        _labelLeft.textColor = FC3;
    }
    return _labelLeft;
}

- (UILabel *)labelRight
{
    if (!_labelRight)
    {
        _labelRight = [UILabel new];
    }
    return _labelRight;
}

- (UITextField *)textFieldMain
{
    if (!_textFieldMain)
    {
        _textFieldMain = [KDPasswordTextField new];
        [_textFieldMain addTarget:self action:@selector(textFieldMainEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
        [_textFieldMain addTarget:self action:@selector(textFieldMainEditingDidEnd) forControlEvents:UIControlEventEditingDidEnd];
        [_textFieldMain addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];

        _textFieldMain.font = FS4;
        _textFieldMain.textColor = FC3;
        _textFieldMain.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _textFieldMain;
}

- (UIImageView *)imageViewLeft
{
    if (!_imageViewLeft)
    {
        _imageViewLeft = [UIImageView new];
    }
    return _imageViewLeft;
}

- (UIButton *)buttonRight
{
    if (!_buttonRight)
    {
        _buttonRight = [UIButton new];
        [_buttonRight addTarget:self action:@selector(buttonRightPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonRight.titleLabel setFont:FS4];
        _buttonRight.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_buttonRight setTitleColor:FC5 forState:UIControlStateNormal];
        
    }
    return _buttonRight;
}

- (UIView *)viewLine
{
    if (!_viewLine)
    {
        _viewLine = [UIView new];
        _viewLine.backgroundColor = [UIColor kdDividingLineColor];
    }
    return _viewLine;
}

- (void)textFieldMainEditingDidBegin
{
    self.viewLine.backgroundColor = FC5;

}

- (void)textFieldMainEditingDidEnd
{
    self.viewLine.backgroundColor = [UIColor kdDividingLineColor];
}

- (void)textChanged
{
    if (self.textFieldMain.text.length > 0)
    {
        self.textFieldMain.textColor = FC1;
    }
    else
    {
        self.textFieldMain.textColor = FC3;
    }
}

- (void)buttonRightPressed:(UIButton *)button
{
    if (self.blockButtonRightPressed)
    {
        self.blockButtonRightPressed(button);
    }
}

@end
