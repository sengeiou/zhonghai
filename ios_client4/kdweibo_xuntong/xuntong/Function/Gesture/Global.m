//
//  Global.m
//  SignUp
//
//  Created by 曾昭英 on 13-1-7.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "Global.h"

@implementation Global
@synthesize appState = _appState;

+ (Global *)shared
{
    static Global *Global_P = nil;
    @synchronized(self)
    {
        if (Global_P == nil) {
            Global_P = [[self alloc] init];
        }
    }
    return Global_P;
}

- (void)setIsAutoLogin:(BOOL)isAutoLogin
{
    _isAutoLogin = isAutoLogin;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isAutoLogin] forKey:kAutoLogin];
}

- (void)setAppState:(AppState)appState
{
    _appState = appState;
    [[NSUserDefaults standardUserDefaults] setObject:@(appState) forKey:kSetting_appState];
}


@end
