//
//  KDTextEditView.m
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDTextEditView.h"
#import "KDColorChooseView.h"

@interface KDTextEditView() <UITextViewDelegate, KDColorChooseViewDelegate>

@property (nonatomic, strong)KDColorChooseView *colorView;

@end

@implementation KDTextEditView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)layoutSubviews {
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,100)];
    _textView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [_textView setTextColor:[UIColor redColor]];
    [_textView setFont:[UIFont systemFontOfSize:30]];
    [_textView setReturnKeyType:UIReturnKeyDone];
    _textView.delegate = self;
    
    [self addSubview:_textView];
    
    _colorView = [[KDColorChooseView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 36)];
    _colorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    _colorView.delegate = self;
    _colorView.hiddenReturn = YES;
    [self addSubview:_colorView];
    
}

- (void)textSaveBtn{
    [_textView resignFirstResponder];
    
    if (self.editTextComplete) {
        self.editTextComplete(self.textView);
    }
}

#pragma mark -- KDColorChooseViewDelegate
- (void)chooseColorWithColor:(UIColor *)color {
    self.textView.textColor = color;
}

#pragma mark- UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self textSaveBtn];
        return NO;
    }
    return YES;
}

@end
