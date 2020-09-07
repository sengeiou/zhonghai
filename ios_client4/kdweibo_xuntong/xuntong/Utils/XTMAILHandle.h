//
//  XTMAILHandle.h
//  XT
//
//  Created by Gil on 13-7-24.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface XTMAILHandle : NSObject <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) UIViewController *controller;

+(XTMAILHandle *)sharedMAILHandle;

- (void)mailWithEmailAddress:(NSString *)emailAddress;

@end
