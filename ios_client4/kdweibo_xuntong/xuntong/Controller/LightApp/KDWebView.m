//
//  KDWebView.m
//  kdweibo
//
//  Created by shifking on 16/3/10.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDWebView.h"
#import "KDWeiboAppDelegate.h"
#import <WebKit/WebKit.h>
#import "XTTELHandle.h"
#import "XTMAILHandle.h"
#import "XTSMSHandle.h"
#import "KDCookieSyncManager.h"
#import "NSString+Operate.h"
#define kKDWebHandle @"xuntong"
#define ms_ReloadTimeInterval 0.5

@interface KDWebView()<UIWebViewDelegate,WKUIDelegate,WKNavigationDelegate>

@property (strong , nonatomic) UIWebView *uiWebView;
@property (strong , nonatomic) WKWebView *wkWebView;
@property (assign , nonatomic) BOOL backOrForward;

@property (nonatomic, assign) BOOL hasAddWebView;

@end

@implementation KDWebView

- (instancetype)initWithUsingUIWebView:(BOOL)usingUIWebView {
    if (self = [super init]) {
        _usingUIWebView = usingUIWebView;
    }
    return self;
}

- (instancetype)init {
    
    BOOL usingUIWebView = YES;
    if (isAboveiOS8) {
        if ([[BOSSetting sharedSetting] useWKWebView]) {
            usingUIWebView = NO;
        }
    }
    
    return [self initWithUsingUIWebView:usingUIWebView];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview && !self.hasAddWebView) {
        if (!_usingUIWebView) {
            [self initWkWebView];
            [self addSubview:self.wkWebView];
            [self.wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        }
        else {
            [self initUIWebView];
            [self addSubview:self.uiWebView];
        }
        [self masmake];
        
        self.hasAddWebView = YES;
    }
}

- (void)dealloc {
    if (self.wkWebView) {
        [self.wkWebView removeObserver:self forKeyPath:@"title"];
    }
}

- (void)masmake {
    if (_uiWebView && _uiWebView.superview) {
        [_uiWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.mas_equalTo(self).with.offset(0);
        }];
    }
    else if (_wkWebView && _wkWebView.superview) {
        [_wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.mas_equalTo(self).with.offset(0);
        }];
    }
}

#pragma mark - Observer -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"title"] && self.wkWebView)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(kdWebView:observeTitleValueChange:)]) {
            [_delegate kdWebView:self observeTitleValueChange:self.wkWebView.title];
        }
    }
}

#pragma mark - UIWebViewDelegate -

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (_delegate && [_delegate respondsToSelector:@selector(kdWebViewDidStartLoad:)]) {
        [_delegate kdWebViewDidStartLoad:self];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!webView.isLoading) {
        if (_delegate && [_delegate respondsToSelector:@selector(kdWebViewDidFinishLoad:)]) {
            [_delegate kdWebViewDidFinishLoad:self];
        }
    }
    
    NSURLRequest *request = webView.request;
    NSCachedURLResponse *urlResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse.response;
    if (httpResponse && self.delegate && [self.delegate respondsToSelector:@selector(kdWebView:didResponseStatusCode:)]) {
        [self.delegate kdWebView:self didResponseStatusCode:httpResponse.statusCode];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (!webView.isLoading) {
        if (_delegate && [_delegate respondsToSelector:@selector(kdWebView:didFailLoadWithError:)]) {
            [_delegate kdWebView:self didFailLoadWithError:error];
        }
        
        if ([error.domain isEqualToString:@"NSURLErrorDomain"] && error.code <= -1202 && error.code >= -1206) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(kdWebView:didHTTPSVerifyFailure:)]) {
                [self.delegate kdWebView:self didHTTPSVerifyFailure:[NSString stringWithFormat:ASLocalizedString(@"UIWebView|HTTPS证书验证失败|Host:%@|%@"), [(NSURL *)[error.userInfo objectForKey:@"NSErrorFailingURLKey"] host], [error.userInfo objectForKey:@"NSLocalizedDescription"]]];
            }
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (_delegate && [_delegate respondsToSelector:@selector(kdWebView:shouldStartLoadWithRequest:navigationType:)]) {
        return [_delegate kdWebView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

#pragma mark - WKNavigationDelegate -
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (_delegate && [_delegate respondsToSelector:@selector(kdWebViewDidStartLoad:)]) {
        [_delegate kdWebViewDidStartLoad:self];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (!webView.isLoading) {
        if (_delegate && [_delegate respondsToSelector:@selector(kdWebViewDidFinishLoad:)]) {
            [_delegate kdWebViewDidFinishLoad:self];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (!webView.isLoading) {
        if (_delegate && [_delegate respondsToSelector:@selector(kdWebView:didFailLoadWithError:)]) {
            [_delegate kdWebView:self didFailLoadWithError:error];
        }
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    //由于左滑右滑跳转页面不会调用js桥
    //如果是左滑右滑跳转，停止加载，reload url使js得以重调
    if (_backOrForward) {
        _backOrForward = NO;
        [webView stopLoading];
        [webView reload];
        return ;
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL         *url = navigationAction.request.URL;
    if ([url.absoluteString isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return ;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(kdWebView:shouldStartLoadWithRequest:navigationType:)]) {
        BOOL result = [_delegate kdWebView:self shouldStartLoadWithRequest:navigationAction.request navigationType:(NSInteger)navigationAction.navigationType];
        if (!result) {
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    if (navigationAction.navigationType == WKNavigationTypeBackForward) {
        if (_delegate && [_delegate respondsToSelector:@selector(setupLeftBarButtonItems)]) {
            [_delegate performSelector:@selector(setupLeftBarButtonItems) withObject:nil];
        }
        _backOrForward = YES;
    }
    
    if ([url.absoluteString containSubString:@"//itunes.apple.com"]) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([url.scheme isEqualToString:@"tel"] || [url.scheme isEqualToString:@"sms"] || [url.scheme isEqualToString:@"mail"]) {
        NSRange rang = [url.absoluteString rangeOfString:@":"];
        NSString *target = [url.absoluteString substringFromIndex:rang.location + 1];
        if (target && [url.scheme isEqualToString:@"tel"]) {
            [[XTTELHandle sharedTELHandle] telWithPhoneNumbel:target];
        }
        else if (target && [url.scheme isEqualToString:@"sms"] ) {
            KDWeiboAppDelegate *dele = (KDWeiboAppDelegate *)[[UIApplication sharedApplication] delegate];
            [XTSMSHandle sharedSMSHandle].controller = dele.tabBarController;
            [[XTSMSHandle sharedSMSHandle] smsWithPhoneNumbel:target];
        }
        else if (target && [url.scheme isEqualToString:@"mail"] ) {
            KDWeiboAppDelegate *dele = (KDWeiboAppDelegate *)[[UIApplication sharedApplication] delegate];
            [XTMAILHandle sharedMAILHandle].controller = dele.tabBarController;
            [[XTMAILHandle sharedMAILHandle] mailWithEmailAddress:target];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return ;
    }
    
    if (![url.scheme.lowercaseString hasPrefix:@"http"] && ![url.scheme.lowercaseString hasPrefix:@"xuntong"]) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return ;
    }
    
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)navigationResponse.response;
        if (httpResponse && self.delegate && [self.delegate respondsToSelector:@selector(kdWebView:didResponseStatusCode:)]) {
            [self.delegate kdWebView:self didResponseStatusCode:httpResponse.statusCode];
        }
    }
    
    decisionHandler(WKNavigationResponsePolicyAllow);
    
}

// WKWebView HTTPS支持
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef secTrustRef = challenge.protectionSpace.serverTrust;
        SecTrustResultType result;
        SecTrustEvaluate(secTrustRef, &result);
        BOOL trustFailure = NO;
        NSString *failReason = @"";
        switch (result) {
            case kSecTrustResultRecoverableTrustFailure:
                trustFailure = YES;
                failReason = @"kSecTrustResultRecoverableTrustFailure; Trust denied; retry after changing settings.";
                break;
            case kSecTrustResultFatalTrustFailure:
                trustFailure = YES;
                failReason = @"kSecTrustResultFatalTrustFailure; Trust denied; no simple fix is available.";
                break;
            case kSecTrustResultInvalid:
                trustFailure = YES;
                failReason = @"kSecTrustResultInvalid; Invalid setting or result.";
                break;
            case kSecTrustResultDeny:
                trustFailure = YES;
                failReason = @"kSecTrustResultDeny; The user specified that the certificate should not be trusted.";
                break;
            default:
                break;
        }
        
        if (trustFailure && self.delegate && [self.delegate respondsToSelector:@selector(kdWebView:didHTTPSVerifyFailure:)]) {
            [self.delegate kdWebView:self didHTTPSVerifyFailure:[NSString stringWithFormat:ASLocalizedString(@"WKWebView|HTTPS证书验证失败|Host:%@|%@"), challenge.protectionSpace.host, failReason]];
        }
        
        NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

/// 因内存不足被清空后WebiView自动重新加载（iOS 9+）
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}

#pragma mark - WKUIDelegate -
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    [KDPopup showAlertWithTitle:nil message:message buttonTitles:@[ASLocalizedString(@"好的") ] onTap:^(NSInteger index) {
        if (completionHandler) {
            completionHandler();
        }
    }];

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [KDPopup showAlertWithTitle:nil message:message buttonTitles:@[ ASLocalizedString(@"好的") ] onTap:^(NSInteger index) {
//        }];
//    });
//    
//    if (completionHandler) {
//        completionHandler();
//    }
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [KDPopup showAlertWithTitle:nil message:message buttonTitles:@[ ASLocalizedString(@"取消"), ASLocalizedString(@"好的") ] onTap:^(NSInteger index) {
            if (completionHandler) {
                BOOL result = index == 0 ? NO : YES;
                completionHandler(result);
            }
        }];
    });
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt message:defaultText preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    UIAlertAction *actionSure = [UIAlertAction actionWithTitle:ASLocalizedString(@"好的") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *result = nil;
        if (alert.textFields.count > 0) {
            result = alert.textFields[0].text;
        }
        completionHandler(result);
    }];
    [alert addAction:actionSure];
    KDWeiboAppDelegate *dele = (KDWeiboAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (dele.tabBarController) {
        [dele.tabBarController presentViewController:alert animated:YES completion:nil];
    }
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - public methods -
- (BOOL)canGoBack {
    if (!_usingUIWebView) {
        return [self.wkWebView canGoBack];
    }
    
    else {
        return [self.uiWebView canGoBack];
    }
}


- (void)goBack {
    if (!_usingUIWebView) {
        [self.wkWebView goBack];
    }
    else {
        [self.uiWebView goBack];
    }
}

- (void)reload {
    if (!_usingUIWebView) {
        [self.wkWebView reload];
    }
    
    else {
        [self.uiWebView reload];
    }
}

- (void)loadRequest:(NSURLRequest *)request {
    if (!_usingUIWebView) {
        [self.wkWebView loadRequest:request];
    }
    
    else {
        [self.uiWebView loadRequest:request];
    }
    
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script {
    if (!script) {
        return nil;
    };
    if (!_usingUIWebView) {
        __block NSString *resultString = nil;
        __block BOOL finished = NO;
        
        [self.wkWebView evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
            if (error == nil) {
                if (result != nil) {
                    resultString = [NSString stringWithFormat:@"%@", result];
                }
            }
            finished = YES;
        }];
        
        while (!finished)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        return resultString;
    }
    
    else {
        NSString *result = [self.uiWebView  stringByEvaluatingJavaScriptFromString:script];
        return result;
    }
}

- (void)stringByEvaluatingJavaScriptFromString:(NSString *)script complete:(void (^)(NSString *))completeBlock {
    if (!script) {
        if (completeBlock) {
            completeBlock(nil);
        }
    };
    if (!_usingUIWebView) {
        [self.wkWebView evaluateJavaScript:script completionHandler:^(id _Nullable string, NSError * _Nullable error) {
            if (completeBlock) {
                completeBlock(string);
            }
        }];
    }
    
    else {
        NSString *result = [self.uiWebView  stringByEvaluatingJavaScriptFromString:script];
        if (completeBlock) {
            completeBlock(result);
        }
    }
}

#pragma mark - setter & getter -
- (void)initUIWebView {
    _uiWebView = [[UIWebView alloc] init];
    _uiWebView.scalesPageToFit = YES;
    _uiWebView.delegate = self;
    _uiWebView.opaque = NO;
    _uiWebView.allowsInlineMediaPlayback = YES;
//    if (!kProductMode) {
        _uiWebView.mediaPlaybackRequiresUserAction = NO;
//    }
}

- (void)initWkWebView {
    Class kdwkwebviewClass = NSClassFromString(@"WKWebView");
    if (kdwkwebviewClass) {
        WKWebViewConfiguration *config = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
        config.processPool = [KDCookieSyncManager sharedWKCookieSyncManager].processPool;
        config.allowsInlineMediaPlayback = YES;
//        if (!kProductMode) {
            config.mediaPlaybackRequiresUserAction = NO;
//        }
        _wkWebView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:CGRectZero configuration:config];
        
        NSMutableString *javascript = [NSMutableString string];
        [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按
        [javascript appendString:@"document.documentElement.style.webkitUserSelect='none';"];//禁止选择
        WKUserScript *noneSelectScript = [[NSClassFromString(@"WKUserScript") alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [_wkWebView.configuration.userContentController addUserScript:noneSelectScript];
        
        _wkWebView.allowsBackForwardNavigationGestures = YES;
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
    }
    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    if (_uiWebView) {
        _uiWebView.backgroundColor = _backgroundColor;
    }
    else if (_wkWebView) {
        _wkWebView.backgroundColor = _backgroundColor;
    }
}

- (NSURL *)URL {
    if (!_usingUIWebView) {
        return self.wkWebView.URL;
    }
    
    else {
        return self.uiWebView.request.URL;
    }
}

- (UIView *)activeView {
    if (!_usingUIWebView) {
        return self.wkWebView;
    }
    else {
        return self.uiWebView;
    }
}

- (void)setCanScroll:(BOOL)canScroll {
    _canScroll = canScroll;
    if (self.uiWebView && self.uiWebView.superview) {
        self.uiWebView.scrollView.scrollEnabled = canScroll;
    }
    if (self.wkWebView && self.wkWebView.superview) {
        self.wkWebView.scrollView.scrollEnabled = canScroll;
    }
}

@end
