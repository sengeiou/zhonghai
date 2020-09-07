//
//  KDNavigation_objc_internal.h
//  kdweibo
//
//  Created by sevli on 16/9/12.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//  Bar类扩展  可用于NavigationBar & ToolBar

#ifndef KDNavigation_objc_internal_h
#define KDNavigation_objc_internal_h

#import <objc/runtime.h>

#define kd_getProperty(objc,key) [objc valueForKey:key]


@protocol KDExtensionBarProtocol <NSObject>

@property (nonatomic, assign) CGSize kd_size;
- (UIView * _Nullable)kd_backgroundView;
- (CGSize)kd_sizeThatFits:(CGSize)size;
@end


#define KDExtensionBarImplementation \
- (CGSize)kd_sizeThatFits:(CGSize)size { \
CGSize newSize = [self kd_sizeThatFits:size]; \
return CGSizeMake(self.kd_size.width == 0.f ? newSize.width : self.kd_size.width, self.kd_size.height == 0.f ? newSize.height : self.kd_size.height); \
} \
- (void)setKd_size:(CGSize)size { \
objc_setAssociatedObject(self, @selector(kd_size), [NSValue valueWithCGSize:size], OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
[self sizeToFit]; \
} \
- (CGSize)kd_size { \
return [objc_getAssociatedObject(self, _cmd) CGSizeValue]; \
} \
- (UIView *)kd_backgroundView { \
return kd_getProperty(self, @"_backgroundView"); \
}




#endif /* KDNavigation_objc_internal_h */
