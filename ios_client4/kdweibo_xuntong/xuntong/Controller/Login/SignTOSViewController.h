//
//  AgreementViewController.h
//  Public
//
//  Created by Gil on 12-2-14.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "MCloudDelegate.h"
#import "AuthDataModel.h"

/*
 客户端协议签署界面
 */

@class MCloudClient;
@interface SignTOSViewController : UIViewController<MBProgressHUDDelegate,UIWebViewDelegate>{
    TOSType tosType_;
    BOOL hasToolBar_;
    
    UIWebView *webView;
    UIToolbar *toolBar;
//    id<SignTOSDelegate> delegate;
    
    MCloudClient *clientCloud;
    MBProgressHUD *hud;
}

@property (nonatomic,retain) UIWebView *webView;
@property (nonatomic,retain) UIToolbar *toolBar;
@property (nonatomic,assign) id<SignTOSDelegate> delegate;

-(id)initWithTOSType:(TOSType)tosType showToolBar:(BOOL)showToolBar;

@end
