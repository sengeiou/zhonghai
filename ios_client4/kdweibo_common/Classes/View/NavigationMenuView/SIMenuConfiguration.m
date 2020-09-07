//
//  SIMenuConfiguration.m
//  NavigationMenu
//
//  Created by Ivan Sapozhnik on 2/20/13.
//  Copyright (c) 2013 Ivan Sapozhnik. All rights reserved.
//

#import "SIMenuConfiguration.h"

@implementation SIMenuConfiguration
//Menu width
+ (float)menuWidth
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    return window.frame.size.width;
}

//Menu item height
+ (float)itemCellHeight
{
    return 44.0f;
}

//Animation duration of menu appearence
+ (float)animationDuration
{
    return 0.3f;
}

//Menu substrate alpha value
+ (float)backgroundAlpha
{
    return 0.6;
}

//Menu alpha value
+ (float)menuAlpha
{
    return 1.0;
}
//iOS7 适配 王松
//修正动画弹出高度
//Value of bounce
+ (float)bounceOffset
{
//    return -7.0;
    return 0.0;
}

//Arrow image near title
+ (UIImage *)arrowImage
{
    return [UIImage imageNamed:@"triangle_down_white"];
}

//Distance between Title and arrow image
+ (float)arrowPadding
{
    return 13.0;
}

//Items color in menu
+ (UIColor *)itemsColor
{
    return [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0];
}

+ (UIColor *)mainColor
{
    return [UIColor blackColor];
}

+ (float)selectionSpeed
{
    return 0.15;
}

+ (UIColor *)itemTextColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)selectionColor
{
    return [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
}
@end
