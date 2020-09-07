//
//  KDPasswordTextField.m
//  kdweibo
//
//  Created by kingdee on 16/10/31.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDPasswordTextField.h"

@implementation KDPasswordTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.secureTextEntry == YES) {
        UIMenuController *mm = [UIMenuController sharedMenuController];
        if (mm) {
            mm.menuVisible = NO;
        }
        return NO;
    }
    else {
        return [super canPerformAction:action withSender:sender];
    }
}

@end
