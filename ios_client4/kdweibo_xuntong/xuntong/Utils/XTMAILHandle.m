//
//  XTMAILHandle.m
//  XT
//
//  Created by Gil on 13-7-24.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTMAILHandle.h"

@implementation XTMAILHandle

+(XTMAILHandle *)sharedMAILHandle
{
    static dispatch_once_t pred;
    static XTMAILHandle *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[XTMAILHandle alloc] init];
    });
    return instance;
}

- (void)mailWithEmailAddress:(NSString *)emailAddress
{
    Class messageClass = NSClassFromString(@"MFMailComposeViewController");
    if (messageClass)
    {
        if ([messageClass canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
//            if (!isAboveiOS7) {
                picker.navigationBar.tintColor = FC5;
//            }
            if (emailAddress.length > 0) {
                [picker setToRecipients:[NSArray arrayWithObject:emailAddress]];
            }
            picker.mailComposeDelegate = self;
            
            [self.controller presentViewController:picker animated:YES completion:nil];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"XTMAILHandle_Email")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark - MFEmailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultFailed)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDPubAccDetailViewController_Fail")message:ASLocalizedString(@"XTMAILHandle_Email_Fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
    }
    
    [self.controller dismissViewControllerAnimated:YES completion:nil];
}

@end
