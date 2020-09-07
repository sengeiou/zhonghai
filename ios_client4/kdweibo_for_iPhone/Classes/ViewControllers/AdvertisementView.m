//
//  KDAdsManager.h
//  kdweibo
//
//  Created by lichao_liu on 16/1/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "AdvertisementView.h"
#import "Masonry.h"
#import "KDTimeButton.h"
#import "KDWebViewController.h"

@interface AdvertisementView ()
@property (nonatomic,assign)NSInteger timeNum;
@property (nonatomic,strong)KDTimeButton *closeButton;
@property (nonatomic,strong)UIImageView *adImageView;
@property (nonatomic,copy)NSString *showDetailURI;
@property (nonatomic,strong) UIImageView *bgImageView;
@property (nonatomic, strong) KDAdDetailModel *adsModel;
@property (nonatomic, strong) UIView *bgContentView;
@end

@implementation AdvertisementView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAction) name:@"TIMEOUT" object:nil];
        self.backgroundColor = [UIColor whiteColor];
        [self initImageConstarints];
    }
    return self;
}
#pragma mark - init layout
- (void)initImageConstarints {
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsZero);
    }];
    
    [self.adImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.height.mas_equalTo(0);
         make.width.mas_equalTo(ScreenFullWidth);
     }];
    
    _bgContentView = [UIView new];
    _bgContentView.backgroundColor = [UIColor clearColor];
    _bgContentView.alpha = 0.6;
    _bgContentView.userInteractionEnabled = YES;
    [self addSubview:_bgContentView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetailAction)];
    [_bgContentView addGestureRecognizer:tap];
    [_bgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsZero);
    }];
}

- (void)setAdsModel:(KDAdDetailModel *)adsModel timeout:(NSTimeInterval)timeout {
    self.adsModel = adsModel;
    
    if (adsModel) {
        [self loadImageWithPath:adsModel.pictureUrl];
        self.showDetailURI = adsModel.detailUrl;
        self.timeNum = timeout;
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-20);
            make.top.equalTo(self).offset(30);
            make.width.equalTo(@72);
            make.height.equalTo(@30);
        }];
    }else {
        [self closeAction];
    }
}

- (void)loadImageWithPath:(NSString *)imagePath {
    __weak __typeof(self) weakSelf = self;
    [self.adImageView setImageWithURL:[NSURL URLWithString:imagePath] completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType) {
        if (error) {
            [weakSelf closeAction];
        }else {
            [weakSelf updateUI];
        }
    }];
}
- (void)updateUI {
    if(self.adImageView.image)
    {
        self.adImageView.hidden = NO;
        
         CGFloat dy = ScreenFullWidth/(320.0/480.0);
        CGFloat bottomViewHeight = ScreenFullHeight - dy;
        if(self.adsModel.type == 1){
            bottomViewHeight = 0;
            self.bgImageView.hidden = YES;
        }else{
        if(!isAboveiPhone5)
        {
            bottomViewHeight = 45;
        }
        }
        
        CGFloat topHeight = ScreenFullHeight - bottomViewHeight;
        
//        CGSize imageSize = self.adImageView.image.size;
//        CGFloat distance = imageSize.width * 1.0 / ScreenFullWidth;
//        CGFloat cheight = imageSize.height / distance;
//        
//        if(cheight > topHeight)
//        {
//            cheight = topHeight;
//        }
        
        [self.adImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(topHeight);
        }];
        [self.adImageView layoutIfNeeded];
        self.closeButton.hidden = NO;
    }
}

- (UIImageView *)bgImageView
{
    if(!_bgImageView){
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.backgroundColor = [UIColor whiteColor];
        _bgImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_bgImageView];
        
        CGSize viewSize = self.bounds.size;
        NSString *viewOrientation = @"Portrait";
        NSString *launchImage = nil;
        NSArray*imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
        for (NSDictionary* dict in imagesDict)
        {
            CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
            if(CGSizeEqualToSize(imageSize, viewSize)&&[viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]){
                launchImage = dict[@"UILaunchImageName"];
                break;
            }
        }
        _bgImageView.image = [UIImage imageNamed:launchImage];
    }
    return _bgImageView;
}

- (UIImageView *)adImageView {
    if (!_adImageView) {
        _adImageView = [[UIImageView alloc] init];
        _adImageView.backgroundColor = [UIColor clearColor];
        _adImageView.contentMode = UIViewContentModeScaleAspectFill;
        _adImageView.clipsToBounds = YES;
        _adImageView.hidden = YES;
        [self addSubview:_adImageView];
    }
    return _adImageView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[KDTimeButton alloc] initWithTitle:[NSString stringWithFormat:@"%ld｜%@",self.timeNum, ASLocalizedString(@"KDTimeButton_Skip")] andTime:self.timeNum];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
//         _closeButton.layer.borderColor = FC6.CGColor;
        [_closeButton setTitleColor:FC6 forState:UIControlStateNormal];
        _closeButton.hidden = YES;
        _closeButton.titleLabel.font = FS7;
        _closeButton.backgroundColor = FC1;
        _closeButton.layer.cornerRadius = 15;
        _closeButton.layer.borderWidth = 0.5f;
        _closeButton.layer.masksToBounds = YES;
        
        [self.bgContentView addSubview:_closeButton];
    }
    return _closeButton;
}

#pragma mark - close action
- (void)closeAction {
    switch (self.AdAnimationType) {
        case ADAnimationTypeCurlUp:
        {
            [UIView animateWithDuration:1.6 animations:^{
                [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self cache:YES];
                self.alpha = 0;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if(self.block)
                {
                self.block();
                }
            }];
        }
            
            break;
        case ADAnimationTypeSlideDown:
        {
            [UIView animateWithDuration:1.5 animations:^{
                self.frame = CGRectMake(0,self.frame.size.height, self.frame.size.width, self.frame.size.height);
                self.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if(self.block)
                {
                self.block();
                }
            }];
        }
            
            break;
        case ADAnimationTypeSlideLeft:
        {
            [UIView animateWithDuration:1.5 animations:^{
                self.frame = CGRectMake(-self.frame.size.width,0, self.frame.size.width, self.frame.size.height);
                self.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if(self.block)
                {
                self.block();
                }
            }];
        }
            break;
        case ADAnimationTypeSlideRight:
        {
            [UIView animateWithDuration:1.5 animations:^{
                self.frame = CGRectMake(self.frame.size.width,0, self.frame.size.width, self.frame.size.height);
                self.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if(self.block)
                {
                self.block();
                }
            }];
        }
            break;
        case ADAnimationTypeSlideUp:
        {
            {
                [UIView animateWithDuration:1.5 animations:^{
                    self.frame = CGRectMake(0,-self.frame.size.height, self.frame.size.width, self.frame.size.height);
                    self.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                    if(self.block)
                    {
                    self.block();
                    }
                }];
            }
        }
            break;
        case ADAnimationTypeSlowDisappear:
        {
            [UIView animateWithDuration:0.25 animations:^{
//                self.alpha = 0.0f;
            } completion:^(BOOL finished) {
                if (self.superview) {
                    [self removeFromSuperview];
                }
                if(self.block)
                {
                self.block();
                }
            }];
        }
            break;
        case ADAnimationTypeZoom:
        {
            [UIView animateWithDuration:0.6 animations:^{
                CGAffineTransform newTransform = CGAffineTransformMakeScale(1.4,1.4);
                [self setTransform:newTransform];
                [self setAlpha:0];
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if(self.block)
                {
                self.block();
                }
            }];
        }
            break;
        default:
        {
            [UIView animateWithDuration:0.25 animations:^{
                self.alpha = 0.0f;
            } completion:^(BOOL finished) {
                if (self.superview) {
                    [self removeFromSuperview];
                }
                self.block();
            }];
        }
            break;
    }
}
- (void)showDetailAction {
    if(self.adsModel && self.adsModel.detailUrl && self.adsModel.detailUrl.length>0)
    {
    UIViewController *rootViewController = [[KDWeiboAppDelegate getAppDelegate].window rootViewController];
    KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:self.adsModel.detailUrl];
    webVC.hidesBottomBarWhenPushed = YES;
    webVC.isRigthBtnHide = YES;
    webVC.title = self.adsModel && self.adsModel.title.length > 0 ? self.adsModel.title : @"";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
//    nav.delegate = [KDNavigationManager sharedNavigationManager];
    if([rootViewController isKindOfClass:[UINavigationController class]])
    {
        UIViewController *viewController = ((UINavigationController *)rootViewController).topViewController;
        if(viewController.presentedViewController)
        {
            [viewController.presentedViewController presentViewController:nav animated:NO completion:nil];
        }else{
            [viewController.navigationController pushViewController:webVC animated:YES];
        }
    }else if([rootViewController isKindOfClass:[RESideMenu class]]){
        UIViewController *viewController = nil;
        UITabBarController *tabController = (UITabBarController *)(((RESideMenu *)rootViewController).contentViewController);
        UINavigationController *navigationController = [tabController.viewControllers objectAtIndex:tabController.selectedIndex];
        
        if (navigationController) {
            viewController = navigationController.topViewController;
        }
        else {
            navigationController = [tabController.viewControllers objectAtIndex:0];
            
            if (navigationController) {
                viewController = navigationController.topViewController;
                
                if (!viewController) {
                    viewController = [navigationController.viewControllers objectAtIndex:0];
                }
            }
        }
        
        if (viewController) {
            if (viewController.presentedViewController) {
                [viewController.presentedViewController presentViewController:nav animated:NO completion:nil];
            }
            else
            {
                [viewController.navigationController pushViewController:webVC animated:YES];
            }
        }
        
    }else
    {
       [rootViewController presentViewController:nav animated:NO completion:nil];
    }
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = CGRectMake(-self.frame.size.width,0, self.frame.size.width, self.frame.size.height);
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            if(self.block)
            {
            self.block();
            }
        }];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end