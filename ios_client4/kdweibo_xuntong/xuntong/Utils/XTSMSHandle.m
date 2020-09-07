//
//  XTSMSHandle.m
//  XT
//
//  Created by Gil on 13-7-23.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTSMSHandle.h"
#import "BOSPublicConfig.h"

@implementation XTSMSHandle

+(XTSMSHandle *)sharedSMSHandle
{
    static dispatch_once_t pred;
    static XTSMSHandle *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[XTSMSHandle alloc] init];
    });
    return instance;
}

- (NSString*)cleanPhoneNumber:(NSString*)mobile
{
    NSString* number = [NSString stringWithString:mobile];
    NSString* number1 = [[[[number stringByReplacingOccurrencesOfString:@" " withString:@""]
                            stringByReplacingOccurrencesOfString:@"-" withString:@""]
                           stringByReplacingOccurrencesOfString:@"(" withString:@""]
                         stringByReplacingOccurrencesOfString:@")" withString:@""];
    return number1;
}

- (void)smsWithPhoneNumbel:(NSString *)phoneNumber
{
    [self smsWithPhoneNumbel:phoneNumber content:nil];
}

- (void)smsWithContent:(NSString *)content
{
    [self smsWithPhoneNumbel:nil content:content];
}

- (void)smsWithPhoneNumbel:(NSString *)phoneNumber content:(NSString *)content
{
    Class messageClass = NSClassFromString(@"MFMessageComposeViewController");
    if (messageClass)
    {
        if ([messageClass canSendText]) {
            
            
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            
            if (phoneNumber.length > 0) {
                [picker setRecipients:[NSArray arrayWithObject:[self cleanPhoneNumber:phoneNumber]]];
            }
            
            if (content.length > 0) {
                [picker setBody:content];
            }
            
//            if (isAboveiOS7) {
                picker.view.backgroundColor = [UIColor whiteColor];
                picker.title = phoneNumber;
//            }
            
            picker.messageComposeDelegate = self;
            [self.controller presentViewController:picker animated:YES completion:nil];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"TTELHandle_Call")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
            
        }
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultFailed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDPubAccDetailViewController_Fail")message:ASLocalizedString(@"RecommendAppDetailViewController_SendFail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
    }
    
    [self.controller dismissViewControllerAnimated:YES completion:nil];
}

@end
