//
//  KDAppOpen.h
//  kdweibo
//
//  Created by Gil on 15/1/28.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDAppOpen : NSObject

+ (BOOL)isBULUOInstalled;

+ (BOOL)isWPSInstalled;
+ (void)openWPSIntro:(UIViewController *)controller;

+ (BOOL)openURL:(NSURL *)url controller:(UIViewController *)controller;
+ (BOOL)openURL:(NSURL *)url controller:(UIViewController *)controller isBlueNav:(BOOL)isBlueNav;

@end
