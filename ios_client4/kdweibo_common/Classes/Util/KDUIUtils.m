//
//  KDUIUtils.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-9.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "KDUIUtils.h"

@implementation KDUIUtils

+ (BOOL)isSupportedURLSchema:(NSString *)schema {
    if (schema == nil || [schema length] == 0) {
        return NO;
    }
    
    NSURL *url = [NSURL URLWithString:schema];
    return [[UIApplication sharedApplication] canOpenURL:url];
}

+ (BOOL)isSupportedPhoneCall {
    return [KDUIUtils isSupportedURLSchema:@"tel:"];
}

+ (BOOL)isSupportedSendSMS {
    return [KDUIUtils isSupportedURLSchema:@"sms:"];
}

+ (BOOL)canSendTextViaMessageCompose {
    return [MFMessageComposeViewController canSendText];
}

@end
