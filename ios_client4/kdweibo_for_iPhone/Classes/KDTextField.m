//
//  KDTextField.m
//  kdweibo
//
//  Created by kingdee on 2017/7/14.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDTextField.h"

@implementation KDTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 2, 1);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 2, 1);
}

@end
