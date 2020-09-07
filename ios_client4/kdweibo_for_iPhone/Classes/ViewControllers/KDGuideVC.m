//
//  KDGuideVC.m
//  kdweibo
//
//  Created by DarrenZheng on 14/12/2.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDGuideVC.h"
#import "KDGuideView.h"
#import "KDAppUserDefaultsAdapter.h"
#import "KDWeiboServicesContext.h"
#import "KDVersion.h"

@interface KDGuideVC () <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UIScrollView *scrollViewMain;
@property (nonatomic, strong) UIButton *buttonSignIn;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *guideViews;
@property (nonatomic, strong) NSArray *distributionImages;
@property (assign, nonatomic) BOOL isAnimation;
@end

@implementation KDGuideVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor2];

    [self.view addSubview:self.scrollViewMain];
    [self.view addSubview:self.buttonSignIn];
    [self.view addSubview:self.pageControl];
    [self.view addSubview:self.topImageView];
    
    //动画视图
    CGFloat startY = 37.0;
    if (isiPhone6Plus) {
        startY = 97.0;
    }
    else if (isAboveiPhone6) {
        startY = 83.0;
    }
    else if (isAboveiPhone5) {
        startY = 55.0;
    }
    
    for (int i = 0; i < [self.guideViews count]; i++) {
        UIView *guideView = self.guideViews[i];
        guideView.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, startY + CGRectGetHeight(guideView.bounds) / 2);
        guideView.hidden = (i > 0);
        [self.view addSubview:guideView];
    }
    
    self.isAnimation = NO;
    

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    KDGuideView *guideView = [self.guideViews firstObject];
    if (guideView && [guideView respondsToSelector:@selector(autoAnimation)]) {
        [guideView autoAnimation];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

#pragma mark - getters -

- (NSArray *)guideViews {
    if (!_guideViews) {
        NSMutableArray *guideViews = [NSMutableArray array];
        for (int i = 0; i < [self.distributionImages count]; i++) {
            KDGuideView *guideView = [KDGuideView guideViewWithIndex:i];
            [guideViews addObject:guideView];
        }
        _guideViews = guideViews;
    }
    return _guideViews;
}

- (NSArray *)distributionImages {
	if (!_distributionImages) {
		_distributionImages = @[@"guide_text_v6",
                                @"guide_text_voice",
                                @"guide_text_new",
                                @"guide_text_easy"];
	}
	return _distributionImages;
}

- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide_img_decoraction"]];
        _topImageView.frame = CGRectMake(.0, .0, 470.0 * ScreenFullWidth / 320.0, 65.0 * ScreenFullWidth / 320.0);
    }
    return _topImageView;
}

- (UIScrollView *)scrollViewMain {
	if (!_scrollViewMain) {
		_scrollViewMain = [[UIScrollView alloc] initWithFrame:CGRectMake(.0, .0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
		_scrollViewMain.pagingEnabled = YES;
		_scrollViewMain.contentSize = CGSizeMake([self.guideViews count] * CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
		_scrollViewMain.delegate = self;
		_scrollViewMain.showsHorizontalScrollIndicator = NO;
		_scrollViewMain.backgroundColor = self.view.backgroundColor;
        
        for (int i = 0; i < 4; i++)
        {
            UILabel *mainLabel = [[UILabel alloc] init];
            mainLabel.font = [UIFont systemFontOfSize:20];
            mainLabel.textAlignment = NSTextAlignmentCenter;
            mainLabel.textColor = [UIColor colorWithRGB:0x5e5e5e];
            
            UILabel *subLabel = [[UILabel alloc] init];
            subLabel.font = [UIFont systemFontOfSize:14];
            subLabel.textAlignment = NSTextAlignmentCenter;
            subLabel.textColor = [UIColor colorWithRGB:0x3f3f3f];
        
            if(i == 0)
            {
                mainLabel.text = [NSString stringWithFormat:@"%@",KD_APPNAME];
                subLabel.text = [NSString stringWithFormat:@"%@",ASLocalizedString(@"KDGuideVC_tips_1")];
            }
            else if(i == 1)
            {
                mainLabel.text = [NSString stringWithFormat:@"%@",ASLocalizedString(@"KDGuideVC_tips_2")];
                subLabel.text = [NSString stringWithFormat:@"%@",ASLocalizedString(@"KDGuideVC_tips_3")];
            }
            else if(i == 2)
            {
                mainLabel.text = [NSString stringWithFormat:@"%@",ASLocalizedString(@"KDGuideVC_tips_4")];
                subLabel.text = [NSString stringWithFormat:@"%@",ASLocalizedString(@"KDGuideVC_tips_5")];
            }
            else if(i == 3)
            {
                mainLabel.text = [NSString stringWithFormat:@"%@",ASLocalizedString(@"KDGuideVC_tips_6")];
                subLabel.text = [NSString stringWithFormat:@"%@",ASLocalizedString(@"KDGuideVC_tips_7")];
            }
            [mainLabel sizeToFit];
            [subLabel sizeToFit];
            
            CGFloat startY = -25.0 + 37.0 + 320;
            if (isiPhone6Plus) {
                startY = 48.0 + 97.0 + 320.0;
            }
            else if (isAboveiPhone6) {
                startY = 25.0 + 83.0 + 320.0;
            }
            else if (isAboveiPhone5) {
                startY = 10.0 + 55.0 + 320.0;
            }
            
            mainLabel.frame = CGRectMake(CGRectGetWidth(_scrollViewMain.frame) / 2 - CGRectGetWidth(mainLabel.bounds) / 2 + i * CGRectGetWidth(_scrollViewMain.frame), startY, CGRectGetWidth(mainLabel.bounds), CGRectGetHeight(mainLabel.bounds));
            [_scrollViewMain addSubview:mainLabel];
            
            subLabel.frame = CGRectMake(0, CGRectGetMaxY(mainLabel.frame)+5, CGRectGetWidth(subLabel.bounds), CGRectGetHeight(subLabel.bounds));
            subLabel.center = CGPointMake(mainLabel.center.x, subLabel.center.y);
            [_scrollViewMain addSubview:subLabel];
        }

	}
	return _scrollViewMain;
}

- (UIButton *)buttonSignIn {
    if (!_buttonSignIn) {
        _buttonSignIn = [UIButton blueBtnWithTitle:[NSString stringWithFormat:ASLocalizedString(@"KDGuideVC_tips_open"),KD_APPNAME]];
        [_buttonSignIn setFrame:CGRectMake(32.0, CGRectGetHeight(self.view.bounds) - (isAboveiPhone5 ? 33.0 : 13.0) - 44.0, CGRectGetWidth(self.view.bounds) - 64.0, 44.0)];
        [_buttonSignIn setCircle];
        [_buttonSignIn addTarget:self action:@selector(buttonSignInPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonSignIn;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(.0, CGRectGetMinY(self.buttonSignIn.frame) - (isAboveiPhone5 ? 30.0 : 20.0) - 10, CGRectGetWidth(self.view.bounds), 10.0)];
        _pageControl.pageIndicatorTintColor = FC3;
        _pageControl.currentPageIndicatorTintColor = FC5;
        _pageControl.numberOfPages = [self.guideViews count];
        [_pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}

#pragma mark - btn -

- (void)buttonSignInPressed {
    
    if (self.blockDidPressEnterButton)
    {
        self.blockDidPressEnterButton(self);
        return;
    }
    
    if (self.presentingViewController) {
        if (self.isAnimation) {
            return;
        }
        self.isAnimation = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 0.5;
        } completion:^(BOOL finished) {
            self.isAnimation = NO;
            self.view.alpha = 0.5;
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
        return;
    }
//    if ([_delegate respondsToSelector:@selector(animateGuidView:scrollToLast:)]) {
//        [_delegate animateGuidView:self scrollToLast:YES];
//        return;
//    }
    [self startKDWeibo];
//    [[KDWeiboAppDelegate getAppDelegate] showLoginViewController:KDLoginViewTypePhoneNumAndPwd phoneNumber:nil bShowKeyboard:NO];
}
- (void)startKDWeibo {
    NSString *clientVersion = [KDCommon clientVersion];
    // save current version into local cache
    KDAppUserDefaultsAdapter *userDefaultAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    [userDefaultAdapter storeObject:clientVersion forKey:KDWEIBO_USER_DEFAULTS_PREV_CLIENT_VERSION_KEY];
    
    KDWeiboAppDelegate *appDelegate = (KDWeiboAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate showTimelineViewController];
}
- (void)pageChanged:(UIPageControl *)pageControl {
    CGRect frame = self.scrollViewMain.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
    [self.scrollViewMain scrollRectToVisible:frame animated:YES];
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollViewMain.frame.size.width;
    float fractionalPage = self.scrollViewMain.contentOffset.x / pageWidth;
    
    NSInteger page = lround(fractionalPage);
    if (self.pageControl.currentPage != page) {
        self.pageControl.currentPage = page;
    }
    
    //top位移
    if (fractionalPage > 0 && fractionalPage < 3) {
        CGRect topRect = self.topImageView.frame;
        topRect.origin.x = (- fractionalPage * 50.0);
        self.topImageView.frame = topRect;
    }
    
    //第一个页面的位移（第一个页面的动画是自动的）
    if (fractionalPage < 1.0 && fractionalPage > 0) {
        KDGuideView *guideView1 = self.guideViews[0];
        guideView1.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2 - CGRectGetWidth(self.scrollViewMain.bounds) * fractionalPage, guideView1.center.y);
    }
    
    //第二个页面的动画
    KDGuideView *guideView2 = self.guideViews[1];
    guideView2.hidden = (fractionalPage <= 0.1);
    if ([guideView2 respondsToSelector:@selector(animation:startFractional:endFractional:)]) {
        [guideView2 animation:fractionalPage startFractional:0.1 endFractional:1.0];
    }
    //第二个页面的位移
    if (fractionalPage < 2.0 && fractionalPage > 1.0) {
        guideView2.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2 - CGRectGetWidth(self.scrollViewMain.bounds) * (fractionalPage - 1.0), guideView2.center.y);
    }
    
    //第三个页面的动画
    KDGuideView *guideView3 = self.guideViews[2];
    guideView3.hidden = (fractionalPage <= 1.1);
    if ([guideView3 respondsToSelector:@selector(animation:startFractional:endFractional:)]) {
        [guideView3 animation:fractionalPage startFractional:1.1 endFractional:2.0];
    }
    //第三个页面的位移
    if (fractionalPage < 3.0 && fractionalPage > 2.0) {
        guideView3.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2 - CGRectGetWidth(self.scrollViewMain.bounds) * (fractionalPage - 2.0), guideView3.center.y);
    }
    
    //第四个页面的动画
    KDGuideView *guideView4 = self.guideViews[3];
    guideView4.hidden = (fractionalPage <= 2.1);
    if ([guideView4 respondsToSelector:@selector(animation:startFractional:endFractional:)]) {
        [guideView4 animation:fractionalPage startFractional:2.1 endFractional:3.0];
    }

}
/**
 *  是否显示教程：规则
 *  1.如果上次版本小于当前版本，并且版本号最后一位为0
 *  2.如果没有版本号
 */
+ (BOOL)shouldShowGuideView {
    NSString *lastShowVersionString = [[KDSession globalSession] getPropertyForKey:KD_LAST_SHOW_GUIDE_VERSION_KEY fromMemoryCache:YES];
    NSString *currentVersionString  = [KDCommon clientVersion];
    
    BOOL shouldShow = NO;
    
    
    if(lastShowVersionString) {
        NSComparisonResult result = nil;
        if([KDVersion quickCompareVersionA:lastShowVersionString versionB:currentVersionString results:&result]) {
            if(result == NSOrderedAscending && [KDCommon versionLastBit] == 0) {
                KDVersion *v = [[KDVersion alloc] initWithVersionString:currentVersionString];
                if(v.releaseStatus == Release) {
                    shouldShow = YES;
                }
                
//                [v release];
            }
        }
    }else {
        if([KDCommon versionLastBit] == 0) {
            shouldShow = YES;
        }
    }
    
    if(shouldShow) {
        [[KDSession globalSession] saveProperty:currentVersionString forKey:KD_LAST_SHOW_GUIDE_VERSION_KEY storeToMemoryCache:YES];
    }
    
    return shouldShow;
}
@end
