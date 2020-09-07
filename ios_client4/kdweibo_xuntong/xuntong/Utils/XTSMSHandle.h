//
//  XTSMSHandle.h
//  XT
//
//  Created by Gil on 13-7-23.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface XTSMSHandle : NSObject <MFMessageComposeViewControllerDelegate>

@property (nonatomic, weak) UIViewController *controller;

+(XTSMSHandle *)sharedSMSHandle;

- (void)smsWithPhoneNumbel:(NSString *)phoneNumber;
- (void)smsWithContent:(NSString *)content;
- (void)smsWithPhoneNumbel:(NSString *)phoneNumber content:(NSString *)content;

@end
