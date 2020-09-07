//
//  KDSignInRootViewController.m
//  kdweibo
//
//  Created by sevli on 15/11/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSignInRootViewController.h"

@interface KDSignInRootViewController()
{
    UIImageView *_lineVIew;
    id _navInteractiveTransitionDelegate;
}

@end

@implementation KDSignInRootViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone; // orginY 从64 开始

    [self setNavigationStyleBlue];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"app_img_backgroud"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 21, 0, 21)] forBarMetrics:UIBarMetricsDefault];
    
//    if (self.rt_navigationController.viewControllers.count > 1) {
//        UIButton *backButton = [UIButton backBtnInBlueNavWithTitle:@"取消"];
//        [backButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//        [backButton setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
//        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    }
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"Global_Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    UIButton *button = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [button addTarget:self action:@selector(goBackToLast) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    

    _lineVIew = [self findlineviw:self.navigationController.navigationBar];
}

- (void)setNavigationStyleBlue{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController.navigationBar setBarTintColor:FC5];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS1}];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
}

- (void)goBackToLast {
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIImageView*)findlineviw:(UIView*)view{
    
    if ([view isKindOfClass:[UIImageView class]]&&view.bounds.size.height<=1.0) {
        return (UIImageView*) view;
    }for (UIImageView *subview in view.subviews) {
        UIImageView *lineview = [self findlineviw:subview];
        if (lineview) {
            return lineview;
        }
    }
    return nil;
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _lineVIew.hidden = YES;
    _navInteractiveTransitionDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _lineVIew.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _lineVIew.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = _navInteractiveTransitionDelegate;
}



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer
                                      *)gestureRecognizer{
    return NO; //YES：允许右滑返回  NO：禁止右滑返回
}

@end
