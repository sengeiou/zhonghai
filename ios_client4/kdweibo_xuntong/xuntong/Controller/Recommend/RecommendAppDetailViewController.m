//
//  RecommendAppDetailViewController.m
//  EMPNativeContainer
//
//  Created by Gil on 13-3-15.
//  Copyright (c) 2013年 Kingdee.com. All rights reserved.
//

#import "RecommendAppDetailViewController.h"
#import "RecommendAppListDataModel.h"
#import "BOSUtils.h"
#import "BOSImageNames.h"

@interface RecommendAppDetailViewController ()

@end

@implementation RecommendAppDetailViewController

- (id)initWithRecommendAppDataModel:(RecommendAppDataModel *)app
{
    self = [super init];
    if (self) {
        // Custom initialization
        _app = app;// retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (_app == nil || [@"" isEqualToString:_app.detailURL]) {
        return;
    }
    
    self.navigationItem.title = ASLocalizedString(@"应用详情");
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[[UIImage imageNamed:IMAGE_BUTTON_NAVBACK] stretchableImageWithLeftCapWidth:25 topCapHeight:0] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[[UIImage imageNamed:IMAGE_BUTTON_NAVBACK_HIGHLIGHT] stretchableImageWithLeftCapWidth:25 topCapHeight:0] forState:UIControlStateHighlighted];
    [backButton setFrame:CGRectMake(0.0, 0.0, 80, 30)];
    [backButton setTitle:ASLocalizedString(@"RecommendAppDetailViewController_Recommend")forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton] ;//autorelease];
    self.navigationItem.leftBarButtonItem = backItem;
    
    CGRect frame = self.view.bounds;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            frame.size.width = 768;
            frame.size.height = 1004;
        }else{
            frame.size.width = 1024;
            frame.size.height = 748;
        }
    }
    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame] ;//autorelease];
    [webView setScalesPageToFit:YES];
    webView.delegate = self;
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_app.detailURL]]];
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //BOSRELEASE_app);
    //[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [BOSUtils appShouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval) duration
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
            self.view.frame = CGRectMake(0.0, 0.0, 768.0, 1004.0);
        }else{
            self.view.frame = CGRectMake(0.0, 0.0, 1024.0, 748.0);
        }
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{    
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    if ([components count] > 1) {
        NSString *scheme = (NSString *)[components objectAtIndex:0];
        NSString *method = (NSString *)[components objectAtIndex:1];
        if ([scheme isEqualToString:@"emp"]) {
            if ([method isEqualToString:@"smsShare"]) {
                if (![@"" isEqualToString:_app.downloadURL]) {
                    Class messageClass = NSClassFromString(@"MFMessageComposeViewController");
                    if (messageClass && [messageClass canSendText])
                    {
                        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
                        picker.navigationBar.barStyle = UIBarStyleDefault;
                        picker.navigationBar.tintColor = BOSCOLORWITHRGBADIVIDE255(169,175, 186, 1.0);
                        picker.body = [NSString stringWithFormat:ASLocalizedString(@"我正在使用金蝶移动应用-%@，挺好用的，推荐您也体验一下。\n安装地址：%@"),_app.appName,_app.downloadURL];
                        picker.messageComposeDelegate = self;
                        [self presentViewController:picker animated:YES completion:nil];
//                        [picker release];
                    }
                }
            }
            else if ([method isEqualToString:@"freeExperience"]) {
                 if (![@"" isEqualToString:_app.downloadURL]) {
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_app.downloadURL]];
                 }
            }
            
            return NO;
        }
        return YES;
    }
    return YES;
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultFailed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDPubAccDetailViewController_Fail")message:ASLocalizedString(@"RecommendAppDetailViewController_SendFail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
    }
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
