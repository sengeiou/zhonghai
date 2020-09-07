//
//  UIView+Responder.m
//  kdweibo
//
//  Created by sevli on 16/9/22.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "UIView+Responder.h"

@implementation UIView (Responder)

- (UIViewController *)parentController {
    UIResponder *responder = [self nextResponder];
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
                return (UIViewController*)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}


@end
