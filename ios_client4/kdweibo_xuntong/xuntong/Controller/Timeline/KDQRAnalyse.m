//
//  KDQRAnalyse.m
//  kdweibo
//
//  Created by kyle on 16/5/4.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDQRAnalyse.h"
#import "XTQRLoginViewController.h"
#import "KDWebViewController.h"
//#import "KDDetail.h"
//#import "ContactClient.h"
//#import "BOSUtils.h"
//#import "KDSiteTester.h"
#import "AppsClient.h"
#import "KDPubAccDetailViewController.h"

@interface KDQRAnalyse ()
@property (nonatomic, assign) QRLoginCode qrCode;
@property (nonatomic, strong) NSString *qrUrl;
@property (nonatomic, strong) KDQRAnalyseCallbackBlock callbackBlock;
@property (nonatomic, strong) AppsClient *qrcodeAppClient;
@property (nonatomic, weak) UIViewController *targetVC;

@property (nonatomic, strong) NSString *qrResult;
@end

@implementation KDQRAnalyse

+ (KDQRAnalyse *)sharedManager {
	static KDQRAnalyse *sharedQRAnalyseInstance = nil;
	static dispatch_once_t predicate;

	dispatch_once(&predicate, ^{
		sharedQRAnalyseInstance = [[self alloc] init];
	});
	return sharedQRAnalyseInstance;
}

- (instancetype)init {
	self = [super init];

	if (self) {}
	return self;
}

- (QRLoginCode)analyse:(NSString *)qrResult {
    self.qrResult = qrResult;
    
    NSString *url = [qrResult lowercaseString];
    
    int qrCode = QRLoginNO;
    
    if (qrResult.length == 0) {
        return qrCode;
    }
    
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
        if ([url rangeOfString:@"qrlogin.do"].location != NSNotFound) {
            qrCode = QRLoginXTWeb;
        }
        else if ([url rangeOfString:@"login.mykingdee.com/qrcode"].location != NSNotFound) {
            qrCode = QRLoginMykingdee;
        }
        else if ([url rangeOfString:@"kingdee_invite_eid"].location != NSNotFound) {
            qrCode = QRInvite;
        }
        else if ([url rangeOfString:@"yzjfuntion=profile"].location != NSNotFound) {
//            qrCode = KDQRCodeProfile;
//            
//            [KDEventAnalysis event:event_exfriend_invite attributes:@{@"外部好友邀请":@"名片邀请即二维码扫描"}];
        }
        else if ([url rangeOfString:@"yzjfuntion=lightapp"].location != NSNotFound) {
            qrCode = KDQRCodeExternalGroup;
        }
        else {
            qrCode = KDQRCodeHTTP;
        }
    }
    return qrCode;
}


- (void)execute:(NSString *)qrUrl callbackBlock:(KDQRAnalyseCallbackBlock)callbackBlock
{
    self.callbackBlock = callbackBlock;
    self.qrUrl = qrUrl;
    
    [self onCapture];
}


- (UIViewController *)gotoResultVCInTargetVC:(UIViewController *)targetVC withQRResult:(NSString *)qrResult andQRCode:(QRLoginCode)qrCode
{
    if (qrResult.length == 0) {
        return nil;
    }
    
    self.targetVC = targetVC;
    UIViewController *vc = nil;
    
    if(qrCode > 0)
    {
        if (qrCode == QRPubAccScan) {
            NSString *url = [qrResult  stringByReplacingOccurrencesOfString:@"qrcodecreate" withString:@"pubqrcode"];
            [self queryQrcodeInfoWithURL:url];
        }
        else if (qrCode == QRInvite)
        {
            KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:qrResult];
            webVC.hidesBottomBarWhenPushed = YES;
            webVC.isOnlyOpenInBrowser = YES;
            vc = webVC;
        }
        else if(qrCode == KDQRCodeExternalGroup)
        {
            NSURLComponents *urlComp = [NSURLComponents componentsWithURL:[NSURL URLWithString:qrResult] resolvingAgainstBaseURL:YES];
            NSMutableDictionary *queryComp = [urlComp.query queryComponents];
            
            if (queryComp) {
                NSString *lightappid = queryComp[@"lightappid"];
                
                if (lightappid) {
                    KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:self.qrUrl appId:lightappid];
                    webVC.hidesBottomBarWhenPushed = YES;
                    vc = webVC;
                }
            }
        }
        else{
            XTQRLoginViewController *login = [[XTQRLoginViewController alloc] initWithURL:qrResult qrLoginCode:qrCode];
            login.hidesBottomBarWhenPushed = YES;
            vc = login;
        }
    }
    else
    {
        KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:qrResult];
        webVC.hidesBottomBarWhenPushed = YES;
        webVC.isOnlyOpenInBrowser = YES;
        vc = webVC;
    }

    if(vc)
        [targetVC.navigationController pushViewController:vc animated:YES];
    
    return vc;
}

-(void)queryQrcodeInfoWithURL:(NSString *)url
{
    if (url == nil) {
        return;
    }
    
    [KDPopup showHUD];
    
    if (_qrcodeAppClient  == nil) {
        _qrcodeAppClient = [[AppsClient alloc ]initWithTarget:self action:@selector(queryQRcodeInfoDidReceived:result:)];
    }
    
    [_qrcodeAppClient queryQrcodeInfo:url];
}

-(void)queryQRcodeInfoDidReceived:(AppsClient *)client result:(id)result
{
    [KDPopup hideHUD];
    
    BOOL isSuccess = [result objectForKey:@"success"];
    if (isSuccess) {
        NSString *pid = [result objectForKey:@"pid"];
        NSString *qrcodeurl = [result objectForKey:@"qrcodeurl"];
        if ([pid length] > 0) {
            KDPubAccDetailViewController *viewController = [[KDPubAccDetailViewController alloc] initWithPubAcctId:pid];
            [self.targetVC.navigationController pushViewController:viewController animated:YES];
        }
        
    }else{
        
    }
}


- (void)onCapture
{
    NSString *url = [self.qrUrl lowercaseString];
    
    if ([[KDWeiboAppDelegate getAppDelegate] checkJoinByURL:url]) {
        return;
    }
    
    int qrLoginCode = QRLoginNO;
    if ([url hasPrefix:@"http://"])
    {
        if ([url rangeOfString:@"qrlogin.do"].location != NSNotFound)
        {
            qrLoginCode = QRLoginXTWeb;
        }
        else if ([url rangeOfString:@"login.mykingdee.com/qrcode"].location != NSNotFound)
        {
            qrLoginCode = QRLoginMykingdee;
        }
        //邀请加入
        else if ([url rangeOfString:@"kingdee_invite_eid"].location != NSNotFound)
        {
            qrLoginCode = QRInvite;
        }else if(([url rangeOfString:@"mid"].location != NSNotFound) && ([url rangeOfString:@"appid"].location != NSNotFound))
        {
            qrLoginCode = QRLoginThirdPart;
        }else if([url rangeOfString:@"qrcodecreate?ticket"].location != NSNotFound){
            qrLoginCode = QRPubAccScan;
        }else if ([url rangeOfString:@"yzjfuntion=lightapp"].location != NSNotFound) {
            qrLoginCode = KDQRCodeExternalGroup;
        }
    }
    
    if (qrLoginCode > 0)
    {
        if (qrLoginCode == QRLoginXTWeb || qrLoginCode == QRLoginMykingdee || qrLoginCode == QRLoginThirdPart || qrLoginCode == QRPubAccScan) {
//            if (_delegate && [_delegate respondsToSelector:@selector(qrScanViewController:loginCode:result:)]) {
//                [self.delegate qrScanViewController:self loginCode:qrLoginCode result:self.qrUrl];
//            }
            
        }
        else if (qrLoginCode == QRInvite) {
            //            if (_delegate && [_delegate respondsToSelector:@selector(loadWebViewControllerWithUrl:)]) {
            //                [self.delegate loadWebViewControllerWithUrl:self.qrUrl];
            //            }
//            if (_delegate && [_delegate respondsToSelector:@selector(qrScanViewController:loginCode:result:)]) {
//                [self.delegate qrScanViewController:self loginCode:QRLoginNO result:self.qrUrl];
//            }
//            if (_delegate && [_delegate respondsToSelector:@selector(loadWebViewControllerWithUrl:)]) {
//                [self.delegate loadWebViewControllerWithUrl:self.qrUrl];
//            }
            
        }
        
        if(self.callbackBlock)
            self.callbackBlock(qrLoginCode,self.qrUrl);
    }
    else
    {
//        if (self.JSBridgeDelegate && [self.JSBridgeDelegate respondsToSelector:@selector(theURL:)]) {
//            [self.navigationController dismissViewControllerAnimated:YES completion:^(void){
//                [self.JSBridgeDelegate theURL:self.qrUrl];
//            }];
//            return;
//        }
        
        UIAlertView *alert = nil;
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.qrUrl]]) {
//            alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTQRScanViewController_Open_Url")message:self.qrUrl delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"Global_Sure"), nil];
            if(self.callbackBlock)
                self.callbackBlock(self.qrCode,self.qrUrl);

        } else {
            alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTQRScanViewController_QR_Info")message:self.qrUrl delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:ASLocalizedString(@"BubbleTableViewCell_Tip_6"), nil];
            alert.tag = 9000;
        }
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        //[self startCapture];
    } else {
        if (alertView.tag == 9000) {
            if (alertView.message) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setString:alertView.message];
            }
            //[self startCapture];
            return;
        }
        
        
        if(self.callbackBlock)
            self.callbackBlock(self.qrCode,self.qrUrl);
        
    }
}


@end
