//
//  UIAlertView+OverLap.m
//  kdweibo
//
//  Created by kingdee on 17/5/8.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "UIAlertView+OverLap.h"
#import "KDAlertViewRecorder.h"
#import <objc/message.h>

@implementation UIAlertView (OverLap)
+ (void)load {
    Method showMethod = class_getInstanceMethod(self, @selector(show));
    Method myShowMethod = class_getInstanceMethod(self, @selector(myShow));
    
    method_exchangeImplementations(showMethod, myShowMethod);
}

- (void)myShow {
    // 将之前所有的alertView取出来消失掉
    NSMutableArray *array =  [KDAlertViewRecorder shareAlertViewRecorder].alertViewArray;
    for (UIAlertView *alertView in array) {
        if ([alertView isKindOfClass:[UIAlertView class]]) {
            [alertView dismissWithClickedButtonIndex:-1 animated:YES];
        }
    }
    
    [array removeAllObjects];
    [self myShow];
    [array addObject:self];
}

@end
