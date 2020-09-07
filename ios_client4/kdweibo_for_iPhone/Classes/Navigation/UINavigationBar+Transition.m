//
//  UINavigationBar+Transition.m
//  kdweibo
//
//  Created by sevli on 16/9/9.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "UINavigationBar+Transition.h"

@implementation UINavigationBar (Transition)

KDExtensionBarImplementation

+ (void)load {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        void (^__instanceMethod_swizzling)(Class, SEL, SEL) = ^(Class cls, SEL orgSEL, SEL swizzlingSEL){
            Method orgMethod = class_getInstanceMethod(cls, orgSEL);
            Method swizzlingMethod = class_getInstanceMethod(cls, swizzlingSEL);
            if (class_addMethod(cls, orgSEL, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod))) {

                class_replaceMethod(cls, orgSEL, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
            }
            else
            {
                method_exchangeImplementations(orgMethod, swizzlingMethod);
            }

        };

        {
            __instanceMethod_swizzling([self class], @selector(sizeThatFits:), @selector(kd_sizeThatFits:));
        }
    });
}

#pragma mark - Private Method
- (void)setKD_navigationBarBackgroundAlpha:(CGFloat)navigationBarBackgroundAlpha {
    [self.kd_backgroundView setAlpha:navigationBarBackgroundAlpha];
    
    for (UIView *view in self.kd_backgroundView.subviews) {
        if (![view isKindOfClass:[UIImageView class]]) {
            view.backgroundColor = [UIColor colorWithRGB:0xFFFFFF alpha:0.65];
        }
    }
}

@end
