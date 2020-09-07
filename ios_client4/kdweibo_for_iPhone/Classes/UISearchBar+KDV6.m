//
//  UISearchBar+KDV6.m
//  kdweibo
//
//  Created by Gil on 15/7/28.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "UISearchBar+KDV6.h"

@implementation UISearchBar (KDV6)

- (void)setCustomPlaceholder:(NSString *)placeholder {
    if (!placeholder || placeholder.length == 0) {
        placeholder = ASLocalizedString(@"KDSearchBar_Search");
    }
    [[UITextField appearanceWhenContainedIn:[self class], nil] setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholder attributes:@{NSFontAttributeName : FS6, NSForegroundColorAttributeName : FC3}]];
}

@end
