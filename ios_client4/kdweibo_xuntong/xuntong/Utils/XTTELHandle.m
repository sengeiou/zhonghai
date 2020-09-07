//
//  XTTELHandle.m
//  XT
//
//  Created by Gil on 13-7-23.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTTELHandle.h"

@interface XTTELHandle ()
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation XTTELHandle


+(XTTELHandle *)sharedTELHandle
{
    static dispatch_once_t pred;
    static XTTELHandle *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[XTTELHandle alloc] init];
    });
    return instance;
}

- (void)telWithPhoneNumbel:(NSString *)phoneNumber
{
    NSString *url = [NSString stringWithFormat:@"tel://%@",[self cleanPhoneNumber:phoneNumber]];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"TTELHandle_Call")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
    }
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

- (UIWebView *)webView
{
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    return _webView;
}

@end
