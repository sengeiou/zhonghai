//
//  KDUIUtils.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-9.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KDUIUtils : NSObject

+ (BOOL)isSupportedPhoneCall;
+ (BOOL)isSupportedSendSMS;
+ (BOOL)canSendTextViaMessageCompose;

@end
