//
//  XTSearchKeyboard.m
//  XT
//
//  Created by Gil on 13-7-15.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTSearchKeyboard.h"

typedef enum _XTSearchKeyboardTag
{
    XTSearchKeyboardNumberZero = 0,
    XTSearchKeyboardNumberOne = 1,
    XTSearchKeyboardNumberTwo = 2,
    XTSearchKeyboardNumberThree = 3,
    XTSearchKeyboardNumberFour = 4,
    XTSearchKeyboardNumberFive = 5,
    XTSearchKeyboardNumberSix = 6,
    XTSearchKeyboardNumberSeven = 7,
    XTSearchKeyboardNumberEight = 8,
    XTSearchKeyboardNumberNine = 9,
    XTSearchKeyboardAsterisk = 10,
    XTSearchKeyboardDelete = 11
}XTSearchKeyboardTag;

@interface XTSearchKeyboard () <UIInputViewAudioFeedback> {
    UITextField *_textField;
}
@property (nonatomic,weak) id<UITextInput>delegate;
@end

@implementation XTSearchKeyboard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self loadWithNIB];
    }
    return self;
}

- (UIView *)loadWithNIB
{
    NSArray *aNib = [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    UIView *view = [aNib objectAtIndex:0];
    [self addSubview:view];
    return view;
}

- (IBAction)keyboardBtnPressed:(UIButton *)btn
{
    switch (btn.tag) {
        case XTSearchKeyboardDelete:
            [self.delegate deleteBackward];
            [[UIDevice currentDevice] playInputClick];
            break;
        case XTSearchKeyboardAsterisk:
            break;
        default:
            [self.delegate insertText:[NSString stringWithFormat:@"%d", (int)btn.tag]];
            [[UIDevice currentDevice] playInputClick];
            break;
    }
}

#pragma mark - TextField Delegate

- (id<UITextInput>)delegate
{
    return _textField;
}

@end
