//
//  KDAppOpen.m
//  kdweibo
//
//  Created by Gil on 15/1/28.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDAppOpen.h"
//#import "KDLoginLogic.h"
#import "BOSConfig.h"
#import "NSString+URLEncode.h"
#import "URL+MCloud.h"

@implementation KDAppOpen

#if!(TARGET_IPHONE_SIMULATOR)

#define kWPSURL @"KingsoftOfficeApp://"
#define kWPSItunesURL @"http://yunzhijia.com/public/jump/jump-wps.html"

#endif


#define WPSAlert 100011
#define BULUOAlert 100012

+ (KDAppOpen *)instance {
    static dispatch_once_t onceToken;
    static KDAppOpen *instance;

    dispatch_once(&onceToken, ^{
        instance = [[KDAppOpen alloc] init];
    });

    return instance;
}

+ (BOOL)openURL:(NSURL *)url controller:(UIViewController *)controller isBlueNav:(BOOL)isBlueNav {
    if (url == nil) {
        return NO;
    }
     #if!(TARGET_IPHONE_SIMULATOR)
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if ([url.absoluteString hasPrefix:KD_Share_Open_Link]) {
            [KDPopup showHUD:@"正在打开..."];
//            [[KDLoginLogic sharedInstance] getShareTokenWithCompletion:^(BOOL succ) {
//                [KDPopup hideHUD];
//                if (succ) {
//                    NSString *urlString = url.absoluteString;
//                    NSString *tokenValue = [[NSString stringWithFormat:@"%@|%@", [BOSConfig sharedConfig].shareToken, [BOSConfig sharedConfig].shareTokenSecret] URLEncode];
//                    NSString *newUrlString = [NSString stringWithFormat:@"%@&token=%@", urlString, tokenValue];
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newUrlString]];
//                }
//                else {
//                    [[UIApplication sharedApplication] openURL:url];
//                }
//            }];
            return YES;
        }
        else {
            return [[UIApplication sharedApplication] openURL:url];
        }
    }
    else {
        if ([url.absoluteString hasPrefix:KD_Share_Open_Link]) {
            [self openBULUOIntro:controller isBlueNav:isBlueNav];
            return YES;
        }
       
        else if ([url.absoluteString hasPrefix:kWPSURL]) {
            [self openWPSIntro:controller isBlueNav:isBlueNav];
            return YES;
        }
        
     
        return NO;
    }
      #endif
}

+ (BOOL)openURL:(NSURL *)url controller:(UIViewController *)controller
{
    return [self openURL:url controller:controller isBlueNav:NO];
}

#pragma mark - BULUO -

+ (BOOL)isBULUOInstalled {
    #if!(TARGET_IPHONE_SIMULATOR)
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:KD_Share_Open_Link]];
    #endif
}

+ (void)openBULUOIntro:(UIViewController *)controller isBlueNav:(BOOL)isBlueNav {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?eid=%@",KD_Share_Install_Link, [BOSConfig sharedConfig].user.eid]]];
}

#pragma mark - WPS -

+ (BOOL)isWPSInstalled {
    #if!(TARGET_IPHONE_SIMULATOR)
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kWPSURL]];
    #endif
}

+ (void)openWPSIntro:(UIViewController *)controller {
    [self openWPSIntro:controller isBlueNav:NO];
}

+ (void)openWPSIntro:(UIViewController *)controller isBlueNav:(BOOL)isBlueNav{
#if!(TARGET_IPHONE_SIMULATOR)
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kWPSItunesURL]];
#endif
   
}

@end
