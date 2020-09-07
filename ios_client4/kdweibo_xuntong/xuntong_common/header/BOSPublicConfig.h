//
//  BOSPublicConfig.h
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//


#define XuntongAppClientId @"10200"

#define Adjust_Offset_Xcode5 0.0
//尺寸
#define ScreenBounds [[UIScreen mainScreen] bounds]     //屏幕
#define ScreenFullHeight [[UIScreen mainScreen] bounds].size.height //屏幕高度
#define ScreenFullWidth [[UIScreen mainScreen] bounds].size.width   //屏幕宽度
#define StatusBarHeight (isiPhoneX ? 44.0 : 20.0)       //状态栏高度
#define NavigationBarHeight 44.0    //导航栏高度
#define TabBarHeight 49.0           //标签栏高度
#define ToolBarHeight 44.0          //工具栏高度
#define NumKeyboardHeight 208.0      //键盘高度
#define SearchAreaHeight 54.0        //搜索框高度
#define MainHeight ScreenFullHeight - StatusBarHeight //主屏幕高度

//释放对象
//#define BOSRELEASEobj) { [obj release]; obj = nil; }
//使用RGBA值构建Color,其中RGB值分别除以255
#define BOSCOLORWITHRGBADIVIDE255(_RED,_GREEN,_BLUE,_ALPHA) [UIColor colorWithRed:_RED/255.0 green:_GREEN/255.0 blue:_BLUE/255.0 alpha:_ALPHA]

#define BOSCOLORWITHRGBA(rgbValue, alphaValue)		[UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 \
                                                                    green:((float)(((rgbValue) & 0x00FF00) >> 8))/255.0 \
                                                                    blue:((float)((rgbValue) & 0x0000FF))/255.0 \
                                                                    alpha:(alphaValue)]

#if DEBUG
    #define BOSAssert(condition, desc) NSAssert(condition, desc);
    #define BOSAssert1(condition, desc, arg1) NSAssert1(condition, desc, arg1);
    #define BOSAssert2(condition, desc, arg1, arg2) NSAssert2(condition, desc, arg1, arg2);
    #define BOSAssert3(condition, desc, arg1, arg2, arg3) NSAssert3(condition, desc, arg1, arg2, arg3);
    #define BOSAssert4(condition, desc, arg1, arg2, arg3, arg4) NSAssert4(condition, desc, arg1, arg2, arg3, arg4);
    #define BOSAssert5(condition, desc, arg1, arg2, arg3, arg4, arg5) NSAssert5(condition, desc, arg1, arg2, arg3, arg4, arg5);
#else
    #define BOSAssert(condition, desc)
    #define BOSAssert1(condition, desc, arg1)
    #define BOSAssert2(condition, desc, arg1, arg2)
    #define BOSAssert3(condition, desc, arg1, arg2, arg3)
    #define BOSAssert4(condition, desc, arg1, arg2, arg3, arg4)
    #define BOSAssert5(condition, desc, arg1, arg2, arg3, arg4, arg5)
#endif


