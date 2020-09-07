//
//  KKTextLable.m
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KKTextLable.h"

@implementation KKTextLable

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _textInsets)];
}

@end
