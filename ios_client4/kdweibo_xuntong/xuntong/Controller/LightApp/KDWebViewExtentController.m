//
//  KDWebViewExtentController.m
//  kdweibo
//
//  Created by fang.jiaxin on 15/12/17.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDWebViewExtentController.h"
#import "KDWebViewController+Share.h"
#import "KDWebViewController+JSBridge.h"
#import "NJKWebViewProgressView.h"

#import "NSString+Scheme.h"
#import "XTOpenSystemClient.h"
#import "BOSConfig.h"
#import "UIButton+XT.h"
#import "KDLinkInviteConfig.h"
#import "UIViewController+DZCategory.h"


static NSString *KDWebViewLightAppScheme = @"xuntong:";




@interface KDWebViewExtentController ()<UITabBarControllerDelegate>

@end

@implementation KDWebViewExtentController











- (void)viewDidLoad {
    [super viewDidLoad];
    
    //zgbin:代理为了实现点击tabbar刷新界面
    self.tabBarController.delegate = self;
    //zgbin:end
    
    __weak __typeof(self) weak_controller = self;
    [self.webView updateConstraints:^(MASConstraintMaker *make)
     {
         make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
     }];
    
    [self setupRightBarButtonItem];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //zgbin:点击通知横幅刷新界面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationForReloadView) name:@"bidaRefresh" object:nil];
    //zgbin:end
    
    [self showBackBtn];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //zgbin:移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"bidaRefresh" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(UIButton *)button
{
    if ([self.webView canGoBack])
        [self.webView goBack];
    [self showBackBtn];
}





















-(void)showBackBtn
{
    
    if ([self.webView.URL.absoluteString hasPrefix:@"https://iwork.coli688.com:8010/web/task/index?"]) {
        //zgbin:修复刷新后还有返回按钮
        if([self.navigationController.delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)])
            [self.navigationController.delegate navigationController:self.navigationController willShowViewController:self animated:YES];
    } else {
        if([self.webView canGoBack])
        {
            if([self respondsToSelector:@selector(setupLeftBarButtonItem)])
            {
                [self performSelector:@selector(setupLeftBarButtonItem)];
                self.navigationItem.leftBarButtonItems = (self.navigationItem.leftBarButtonItems.firstObject?@[self.navigationItem.leftBarButtonItems.firstObject]:nil);
            }
        }
        else
        {
            if([self.navigationController.delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)])
                [self.navigationController.delegate navigationController:self.navigationController willShowViewController:self animated:YES];
        }
    }
    
    
}












- (void)setupRightBarButtonItem
{
    [super setupRightBarButtonItem];
    
    //是否显示刷新按钮
    if(self.isShowRefreshBtn)
    {
        UIButton *rightButton = [UIButton btnInNavWithImage:[UIImage imageNamed:@"refresh_normal"] highlightedImage:[UIImage imageNamed:@"refresh_press"]];
        [rightButton addTarget:self action:@selector(reloadAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItems = @[rightItem];
    }
}










#pragma mark - UIWebViewDelegate
- (BOOL)kdWebView:(KDWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [super kdWebView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"###########%@",requestString);
    if ([requestString hasPrefix:KDWebViewLightAppScheme]) {
        
    }else {
        //必达轻应用界面tarbar的隐藏
        
        if ([@"https://iwork.coli688.com:8010/web/task/add" isEqualToString:requestString] || [@"http://192.0.3.172:8081/web/task/add" isEqualToString:requestString]) {
            [self makeTabBarHidden:YES];
            
        }
        else if ([requestString hasPrefix:@"https://iwork.coli688.com:8010/web/task/detail?"] || [requestString hasPrefix:@"http://192.0.3.172:8081/web/task/detail?"]) {
            [self makeTabBarHidden:YES];
            
            
            //            KDBidaViewController *bidaWebVC = [[KDBidaViewController alloc] initWithUrlString:requestString];
            //            bidaWebVC.hidesBottomBarWhenPushed = YES;
            //            bidaWebVC.delegate = self;
            //            [self.navigationController pushViewController:bidaWebVC animated:YES];
        }
        else if ([requestString hasPrefix:@"https://iwork.coli688.com:8010/web/task/personDetail?"] || [requestString hasPrefix:@"http://192.0.3.172:8081/web/task/personDetail?"]) {
            [self makeTabBarHidden:YES];
            
        }
        else if ([requestString hasPrefix:@"https://iwork.coli688.com:8010/web/task/toCopyPerson?"] || [requestString hasPrefix:@"http://192.0.3.172:8081/web/task/toCopyPerson?"]) {
            [self makeTabBarHidden:YES];
        }
        else if ([requestString hasPrefix:@"https://iwork.coli688.com:8010/web/task/notice_detail?"] || [requestString hasPrefix:@"http://192.0.3.172:8081/web/task/notice_detail?"]) {
            [self makeTabBarHidden:YES];
        }
        else if ([requestString hasPrefix:@"https://iwork.coli688.com:8010/web/task/noticeAdd"] || [requestString hasPrefix:@"http://192.0.3.172:8081/web/task/noticeAdd?"]) {
            [self makeTabBarHidden:YES];
        }
        else if ([requestString hasPrefix:@"https://iwork.coli688.com:8010/web/task/receiver?"] || [requestString hasPrefix:@"http://192.0.3.172:8081/web/task/receiver?"]) {
            [self makeTabBarHidden:YES];
        }
        else if ([requestString hasPrefix:@"https://iwork.coli688.com:8010/web/task/index?"] || [requestString hasPrefix:@"http://192.0.3.172:8081/web/task/index?"]) {
            [self makeTabBarHidden:NO];
            
        }
        else if ([requestString hasPrefix:@"https://iwork.coli688.com:8010/web/task/backIndex"] || [requestString hasPrefix:@"http://192.0.3.172:8081/web/task/backIndex"]) {
            [self makeTabBarHidden:NO];
        }
        else {
            
        }
        
    }
    return YES;
}

- (void)kdWebView:(KDWebView *)webView didFailLoadWithError:(NSError *)error
{
    [super kdWebView:webView didFailLoadWithError:error];
    [self showBackBtn];
}


- (void)kdWebViewDidFinishLoad:(KDWebView *)webView
{
    //    if([super respondsToSelector:@selector(webViewDidFinishLoad:)])
    //        [super webViewDidFinishLoad:webView];
    [super kdWebViewDidFinishLoad:webView];
    [self showBackBtn];
}













- (void)makeTabBarHidden:(BOOL)hide
{
    //    [self.view bringSubviewToFront:self.webView];
    
    //    for(UIView *view in [KDWeiboAppDelegate getAppDelegate].tabBarController.view.subviews) {
    //        if ([view isKindOfClass:[UITabBar class]]) {
    //            view.backgroundColor = [UIColor redColor];
    //            if (hide) {
    //                [view setFrame:CGRectMake(view.frame.origin.x, ScreenFullHeight, view.frame.size.width, view.frame.size.height)];
    //            }else {
    //                [view setFrame:CGRectMake(view.frame.origin.x, ScreenFullHeight-49, view.frame.size.width, view.frame.size.height)];
    //            }
    //        }
    //
    //    }
    
    //    if ([self.tabBarController.view.subviews count] < 2) {
    //        return;
    //    }
    //    UIView *contentView;
    //    if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]]) {
    //        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    //    } else {
    //        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    //    }
    //    if (hide) {
    //        self.edgesForExtendedLayout = UIRectEdgeBottom;
    //        contentView.frame = self.tabBarController.view.bounds;
    //        contentView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    //    } else {
    //        contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x, self.tabBarController.view.bounds.origin.y, self.tabBarController.view.bounds.size.width, self.tabBarController.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
    //    }
    
    [KDWeiboAppDelegate getAppDelegate].tabBarController.tabBar.hidden = hide;
    
    self.navigationController.navigationBar.barTintColor = [UIColor greenColor];
    self.view.backgroundColor = [UIColor blueColor];
    if (hide) {
        self.view.frame = CGRectMake(0, 49+15+1, ScreenFullWidth, ScreenFullHeight-49-15);
    }else {
        self.view.frame = CGRectMake(0, 49+15, ScreenFullWidth, ScreenFullHeight-49-15-49);
    }
}

//
//- (void)kdWebView:(KDWebView *)webView didFailLoadWithError:(NSError *)error {
//    [self finishProgress];
//}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (self.tabBarController.selectedIndex==2) {
        [self loadRequest];
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//zgbin:通知界面刷新
- (void)notificationForReloadView
{
    [self loadRequest];
}

@end
