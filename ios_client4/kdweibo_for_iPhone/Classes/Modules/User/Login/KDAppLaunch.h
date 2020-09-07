//
//  KDAppLaunch.h
//  kdweibo
//
//  Created by bird on 14/11/19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Scheme.h"

@interface KDAppLaunch : NSObject

+ (KDAppLaunch *)instance;

//要做的事都在这里处理
- (BOOL)handleLaunch:(NSURL *)url;

// 登录成功后执行的回调
- (BOOL)handleLaunchWhenLoginFinished;

// 短信登录逻辑
- (void)startFromMessageLogic;

@end
