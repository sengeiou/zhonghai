//
//  AgreementViewController.m
//  Public
//
//  Created by Gil on 12-2-14.
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "SignTOSViewController.h"
#import "BOSLogger.h"
#import "URL+MCloud.h"
#import "BOSPublicConfig.h"
#import "MCloudClient.h"
#import "BOSSetting.h"
#import "BOSUtils.h"

@implementation SignTOSViewController
@synthesize webView,toolBar,delegate;

-(id)initWithTOSType:(TOSType)tosType showToolBar:(BOOL)showToolBar
{
    self = [super init];
    if (self) {
        tosType_ = tosType;
        hasToolBar_ = showToolBar;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc
{
    //BOSRELEASEclientCloud);
    if (hud) {
        [hud removeFromSuperview];
        hud.delegate = nil;
        //BOSRELEASEhud);
    }
    self.webView.delegate = nil;
    //BOSRELEASEwebView);
    //BOSRELEASEtoolBar);
    //[super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = ASLocalizedString(@"隐私策略及使用条款");
    
    CGRect screenBounds = ScreenBounds;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        screenBounds = CGRectMake(0.0, 0.0, 540.0, 620.0);//标准尺寸
    }
    self.view = [[UIView alloc] initWithFrame:screenBounds];//／／ autorelease];
    self.view.autoresizesSubviews = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (hasToolBar_) {
            self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, screenBounds.size.width, ToolBarHeight)];// autorelease];
            UIBarButtonItem *cancleItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"Global_Cancel")style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed)];
            UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            UIBarButtonItem *comfireItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"同意")style:UIBarButtonItemStyleDone target:self action:@selector(agreeButtonPressed)];
            NSArray *items = [NSArray arrayWithObjects:cancleItem,flexibleSpaceItem,comfireItem, nil];
           // [cancleItem release];[flexibleSpaceItem release];//[comfireItem release];
            [self.toolBar setItems:items];
            self.toolBar.hidden = YES;
            self.toolBar.tintColor = BOSCOLORWITHRGBADIVIDE255(169.0, 175.0, 186.0, 1.0);
            [self.view addSubview:self.toolBar];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
            label.center = self.toolBar.center;
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            if (tosType_ == TOSUnsigned) {
                label.text = ASLocalizedString(@"请阅读条款");
            }else if(tosType_ == TOSChanged){
                label.text = ASLocalizedString(@"条款变更，请阅读条款");
            }
            [self.toolBar addSubview:label];
//            [label release];
        }else {
            self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, screenBounds.size.width, ToolBarHeight)];// autorelease];
            UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            UIBarButtonItem *comfireItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Close")style:UIBarButtonItemStyleDone target:self action:@selector(closeButtonPressed)];
            NSArray *items = [NSArray arrayWithObjects:flexibleSpaceItem,comfireItem, nil];
//            [flexibleSpaceItem release];[comfireItem release];
            [self.toolBar setItems:items];
            self.toolBar.hidden = YES;
            self.toolBar.tintColor = BOSCOLORWITHRGBADIVIDE255(169.0, 175.0, 186.0, 1.0);
            [self.view addSubview:self.toolBar];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
            label.center = self.toolBar.center;
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.text = ASLocalizedString(@"隐私策略及使用条款");
            [self.toolBar addSubview:label];
//            [label release];
        }
    }else {
        if (hasToolBar_) {
            self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, screenBounds.size.width, ToolBarHeight)];// autorelease];
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(backButtonPressed)];
            UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            UIBarButtonItem *comfireItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"同意")style:UIBarButtonItemStyleDone target:self action:@selector(agreeButtonPressed)];
            NSArray *items = [NSArray arrayWithObjects:backItem,flexibleSpaceItem,comfireItem, nil];
//            [backItem release];[flexibleSpaceItem release];[comfireItem release];
            [self.toolBar setItems:items];
            self.toolBar.hidden = YES;
            self.toolBar.tintColor = BOSCOLORWITHRGBADIVIDE255(169.0, 175.0, 186.0, 1.0);
            [self.view addSubview:self.toolBar];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
            label.center = self.toolBar.center;
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            if (tosType_ == TOSUnsigned) {
                label.text = ASLocalizedString(@"请阅读条款");
            }else if(tosType_ == TOSChanged){
                label.text = ASLocalizedString(@"条款变更，请阅读条款");
            }
            [self.toolBar addSubview:label];
//            [label release];
        }
    }
    
    
    
    CGRect webRect = CGRectMake(0.0, 0.0, screenBounds.size.width, screenBounds.size.height);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || hasToolBar_) {
        webRect = CGRectMake(0.0, ToolBarHeight, screenBounds.size.width, screenBounds.size.height-ToolBarHeight);
    }
    self.webView = [[UIWebView alloc] initWithFrame:webRect];// autorelease];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[MCloudClient mcloudBaseUrl] stringByAppendingString:MCLOUDURL_TOS(XuntongAppClientId)]]]];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [BOSUtils appShouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark - method
-(void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (delegate && [delegate respondsToSelector:@selector(signedTOS:)])
        [delegate signedTOS:NO];
}

-(void)agreeButtonPressed
{
    //同意协议，网络连接
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = ASLocalizedString(@"KDChooseOrganizationViewController_Waiting");
    hud.delegate = self;
    [hud show:YES];
    
    // 点击提交
    clientCloud = [[MCloudClient alloc] initWithTarget:self action:@selector(signtosDidiReceived:result:)];
    [clientCloud signtosWithCust3gNo:[BOSSetting sharedSetting].cust3gNo userName:[BOSSetting sharedSetting].userName];
}

-(void)closeButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)signtosDidiReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    [hud hide:YES];
    if (client.hasError) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"协议签署失败")message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        
        //BOSRELEASEclientCloud);
        return;
    }
    
    //BOSRELEASEclientCloud);
    
    if (result.success) {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (delegate && [delegate respondsToSelector:@selector(signedTOS:)])
            [delegate signedTOS:YES];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"协议签署失败")message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
    }
}

#pragma mark - UIWebViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = ASLocalizedString(@"RefreshTableFootView_Loading");
    [self.view addSubview:hud];
    [hud show:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [hud hide:YES];
    self.toolBar.hidden = NO;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [hud hide:YES];
    self.toolBar.hidden = NO;
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud1{
    [hud removeFromSuperview];
    hud = nil;
}

@end
