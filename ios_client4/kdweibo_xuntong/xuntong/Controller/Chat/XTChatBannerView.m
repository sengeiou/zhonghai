//
//  XTChatBannerView.m
//  kdweibo
//
//  Created by DarrenZheng on 14-8-1.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTChatBannerView.h"

@interface XTChatBannerView ()

@property (nonatomic, strong) UIButton *buttonDelete;
@property (nonatomic, strong) UIButton *buttonConfirm;
@property (nonatomic, strong) UILabel *labelTitle;

@end

@implementation XTChatBannerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubview:self.labelTitle];
        [self addSubview:self.buttonDelete];
        [self addSubview:self.buttonConfirm];
        
        self.backgroundColor = [UIColor blackColor];
        self.alpha = .7;

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)buttonDeletePressed
{
    [self.delegate chatBannerViewButtonDeletePressed];
}

- (void)buttonConfirmPressed
{
    [self.delegate chatBannerViewButtonConfirmPressed];
}

- (void)show
{
    self.hidden = NO;
}

- (void)hide
{
    self.hidden = YES;
}

- (void)setText:(NSString *)text
{
    self.labelTitle.text  = text;
}

#pragma mark - property setup 

- (UIButton *)buttonDelete
{
    if (!_buttonDelete)
    {
        _buttonDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonDelete.frame = CGRectMake(ScreenFullWidth-55, 0, 45, 45);
        [_buttonDelete setImage:[UIImage imageNamed:@"message_prompt_delete"] forState:UIControlStateNormal];
        _buttonDelete.backgroundColor = [UIColor clearColor];
        [_buttonDelete addTarget:self action:@selector(buttonDeletePressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonDelete;
}

- (UIButton *)buttonConfirm
{
    if (!_buttonConfirm)
    {
        _buttonConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonConfirm.frame = CGRectMake(20, 0, 247, 45);
        _buttonConfirm.backgroundColor = [UIColor clearColor];
        [_buttonConfirm addTarget:self action:@selector(buttonConfirmPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonConfirm;
}

- (UILabel *)labelTitle
{
    if (!_labelTitle)
    {
        _labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 12, 247, 21)];
        _labelTitle.backgroundColor = [UIColor clearColor];
        _labelTitle.textColor = [UIColor whiteColor];
    }
    return _labelTitle;
}

- (void)dealloc
{
    if (_labelTitle)
    {
//        [_labelTitle release];
        _labelTitle = nil;
    }
    //[super dealloc];
}
@end
