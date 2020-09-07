//
//  KDWebView.h
//  kdweibo
//
//  Created by shifking on 16/3/10.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
// 兼容uiwebview、wkwebview

#import <UIKit/UIKit.h>
@class KDWebView;
@protocol KDWebViewDelegate<NSObject>
- (void)kdWebView:(KDWebView *)webView observeTitleValueChange:(NSString *)title;
- (void)kdWebViewDidStartLoad:(KDWebView *)webView;
- (void)kdWebViewDidFinishLoad:(KDWebView *)webView;
- (void)kdWebView:(KDWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)kdWebView:(KDWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)kdWebView:(KDWebView *)webView didResponseStatusCode:(NSInteger)statusCode;
- (void)kdWebView:(KDWebView *)webView didHTTPSVerifyFailure:(NSString *)errorMessage;

@end


@interface KDWebView : UIView
@property (weak , nonatomic             ) id<KDWebViewDelegate> delegate;
@property (strong , nonatomic           ) UIColor           *backgroundColor;
@property (strong , nonatomic , readonly) NSURL             *URL;
@property (assign , nonatomic, readonly) BOOL usingUIWebView;

@property (assign , nonatomic) BOOL canScroll;
/**
 *  当前webview，wkwebview class or uiwebview class
 */
@property (strong , nonatomic , readonly) UIView *activeView;



- (instancetype)initWithUsingUIWebView:(BOOL)usingUIWebView;

/**
 *  异步执行js代码
 *
 *  @param script        js字符串
 *  @param completeBlock 回调block
 */
- (void)stringByEvaluatingJavaScriptFromString:(NSString *)script complete:(void(^)(NSString *result))completeBlock;
/**
 *  同步执行js代码，注意在ios8以上使用wkwebview执行js会导致主线程阻塞，小心使用
 *
 *  @param script js字符串
 *
 *  @return 返回字符串
 */
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
- (void)loadRequest:(NSURLRequest *)request;
- (BOOL)canGoBack;
- (void)goBack;
- (void)reload;
@end
