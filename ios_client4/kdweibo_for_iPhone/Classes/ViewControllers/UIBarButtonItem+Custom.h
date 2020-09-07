//
//  UIBarButtonItem+Custom.h
//  kdweibo
//
//  Created by sevli on 16/9/9.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    KDNavigationItemStyle_Normal = 0,    // system
    KDNavigationItemStyle_Blue,
    KDNavigationItemStyle_White,
} KDNavigationItemStyle;



#define KDBARBUTTON_OFFSET_DEFAULT [UIBarButtonItem kd_leftSecondItemOffsetX]

@interface UIBarButtonItem (Custom)

/**
 *  返回按钮
 *
 *  @param target
 *  @param action
 *
 *  @return
 */
+ (UIBarButtonItem * _Nullable)kd_makeDefaultBackItemTarget:(nullable id)target
                                                     action:(nullable SEL)action;


/**
 *  自定义
 *
 *  @param customView
 *
 *  @return
 */
+ (UIBarButtonItem * _Nullable)kd_makeLeftItemWithCustomView:(nullable UIView *)customView;
+ (UIBarButtonItem * _Nullable)kd_makeRightItemWithCustomView:(nullable UIView *)customView;


/**
 *  文字
 *
 *  @param title
 *  @param style
 *  @param target
 *  @param action
 *  @param offsetX
 *
 *  @return
 */
+ (UIBarButtonItem * _Nullable)kd_makeLeftItemWithTitle:(nullable NSString *)title
                                                  color:(nullable UIColor *)color
                                                 target:(nullable id)target
                                                 action:(nullable SEL)action;

+ (UIBarButtonItem * _Nullable)kd_makeRightItemWithTitle:(nullable NSString *)title
                                                   color:(nullable UIColor *)color
                                                  target:(nullable id)target
                                                  action:(nullable SEL)action;



/**
 *  图片
 *
 *  @param title
 *  @param style
 *  @param target
 *  @param action
 *  @param offsetX
 *
 *  @return
 */

+ (UIBarButtonItem * _Nullable)kd_makeItemWithImageName:(nullable NSString *)imageName
                                          highlightName:(nullable NSString *)highlightName
                                                offsetX:(CGFloat)offsetX
                                                 target:(nullable id)target
                                                 action:(nullable SEL)action;




+ (UIBarButtonItem * _Nullable)kd_makeLeftItemWithImageName:(nullable NSString *)imageName
                                              highlightName:(nullable NSString *)highlightName
                                                     target:(nullable id)target
                                                     action:(nullable SEL)action;



+ (UIBarButtonItem * _Nullable)kd_makeRightItemWithImageName:(nullable NSString *)imageName
                                              highlightName:(nullable NSString *)highlightName
                                                     target:(nullable id)target
                                                     action:(nullable SEL)action;

/**
 *  chatRoom 特殊
 *
 *  @param title
 *  @param url
 *  @param target
 *  @param action
 *  @param isExtGroup
 *
 *  @return
 */

+ (UIBarButtonItem * _Nullable)kd_makeChatItemWithGroup:(nullable GroupDataModel *)group
                                                 target:(nullable id)target
                                                 action:(nullable SEL)action;








+ (CGFloat)kd_leftSecondItemOffsetX;
+ (CGFloat)kd_leftSecondImageOffsetX;
+ (CGFloat)kd_customViewDistance;

@end
