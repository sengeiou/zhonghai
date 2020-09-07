//
//  Global.h
//  SignUp
//
//  Created by 曾昭英 on 13-1-7.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#define kColor_bg [UIColor colorWithRed:49./255. green:162./255. blue:214./255. alpha:1.00f]

typedef enum {
    AppStateLogin = 0,
    AppStateGestureSetting = 1,
    AppStateMain = 2,
} AppState;

@interface Global : NSObject

#define kSetting_appState @"appState"
#define kAutoLogin @"kAutoLogin"
@property (nonatomic) AppState appState;
@property (nonatomic) BOOL isAutoLogin;
@property (nonatomic) BOOL isEntering;

// global resource
+ (Global *)shared;

@end
