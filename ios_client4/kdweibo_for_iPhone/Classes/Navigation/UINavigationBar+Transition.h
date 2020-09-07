//
//  UINavigationBar+Transition.h
//  kdweibo
//
//  Created by sevli on 16/9/9.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//  NavigationBar 透明&支持有Item 

#import <UIKit/UIKit.h>
#import "KDNavigation_objc_internal.h"

@interface UINavigationBar (Transition) <KDExtensionBarProtocol>

/**
 *  设置NavigationBar 透明度
 *
 *  @param navigationBarBackgroundAlpha
 */
- (void)setKD_navigationBarBackgroundAlpha:(CGFloat)navigationBarBackgroundAlpha;


@end
