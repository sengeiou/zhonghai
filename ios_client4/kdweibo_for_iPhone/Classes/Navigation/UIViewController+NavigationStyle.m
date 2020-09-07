//
//  UIViewController+NavigationStyle.m
//  kdweibo
//
//  Created by sevli on 16/9/8.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "UIViewController+NavigationStyle.h"
#import "UIView+Responder.h"
#import "UINavigationBar+Transition.h"

@interface UIViewController()

@property (nonatomic, strong) UIColor *customColor;

@end

@implementation UIViewController (NavigationStyle)

#pragma mark - Method Swizzling
+ (void)load {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        void (^__instanceMethod_swizzling)(Class, SEL, SEL) = ^(Class cls, SEL orgSEL, SEL swizzlingSEL){
            Method orgMethod = class_getInstanceMethod(cls, orgSEL);
            Method swizzlingMethod = class_getInstanceMethod(cls, swizzlingSEL);
            if (class_addMethod(cls, orgSEL, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod))) {

                class_replaceMethod(cls, orgSEL, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
            }
            else
            {
                method_exchangeImplementations(orgMethod, swizzlingMethod);
            }

        };

        {
            __instanceMethod_swizzling([self class], @selector(viewDidLoad), @selector(___viewDidLoad));
        }
//        {
//            __instanceMethod_swizzling([self class], @selector(viewWillAppear:), @selector(___viewWillAppear:));
//        }
//        {
//            __instanceMethod_swizzling([self class], @selector(didRotateFromInterfaceOrientation:), @selector(___didRotateFromInterfaceOrientation:));
//        }
    });
}

- (void)___viewDidLoad{
    
//    [self setDividingLineHidden:NO];
    
    UIImage *backButtonImage = [[UIImage imageNamed:@"nav_btn_back_light_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationController.navigationBar.backIndicatorImage = backButtonImage;
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = backButtonImage;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    [self ___viewDidLoad];
 
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)___viewWillAppear:(BOOL)animated {
    CGFloat lineHeight = 1.0 / [UIScreen mainScreen].scale;
    self.navLine.frame = CGRectMake(0, CGRectGetHeight(self.navigationController.navigationBar.frame) - lineHeight, ScreenFullWidth, lineHeight);
    [self.navigationController.navigationBar addSubview:self.navLine];
    
    self.navigationImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    self.navigationImageView.hidden = YES;
    
    [self setNavigationStyle:self.style];
    
    [self ___viewWillAppear:animated];
}

- (void)___didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    // 旋转完屏幕之后重设navLine的frame
    CGFloat lineHeight = 1.0 / [UIScreen mainScreen].scale;
    self.navLine.frame = CGRectMake(0, CGRectGetHeight(self.navigationController.navigationBar.frame) - lineHeight, ScreenFullWidth, lineHeight);
    
    [self ___didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - Navigation Style

- (void)setDividingLineHidden:(BOOL)hidden
{
    self.lineHidden = hidden;
    
    self.navLine.hidden = self.lineHidden;
}

- (void)setNavigationStyle:(KDNavigationStyle)style {
    self.style = style;
    
    if (self.style != KDNavigationStyleNormal) {
        self.navLine.hidden = YES;
    } else {
        self.navLine.hidden = self.lineHidden;
    }
    
    if ([NSStringFromClass([self class]) isEqualToString:@"_UIRemoteInputViewController"]
        || self.view.parentController != self
        || [self isKindOfClass:[RTContainerController class]]
        || [self isKindOfClass:[AppWindow.rootViewController class]]
        || [self isKindOfClass:[UINavigationController class]]
        || [self isKindOfClass:NSClassFromString(@"UICompatibilityInputViewController")]
        || [self isKindOfClass:[UIAlertController class]]
        || [NSStringFromClass([self class]) isEqualToString:@"_UIAlertControllerTextFieldViewController"]
        || [NSStringFromClass([self class]) isEqualToString:@"UIInputWindowController"]) {
        return;
    }
    
    switch (style) {
        case KDNavigationStyleNormal:
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
            
            [self.navigationController.navigationBar setTranslucent:YES];

            [self.navigationController.navigationBar setBarTintColor:nil];
            [self.navigationController.navigationBar setKD_navigationBarBackgroundAlpha:1.f];
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : FC1, NSFontAttributeName : FS1}];
            
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC1, NSFontAttributeName : FS3} forState:UIControlStateNormal];
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC1, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
            
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC1, NSFontAttributeName : FS3} forState:UIControlStateNormal];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC1, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
        }
            break;
        case KDNavigationStyleBlue:
        {
            [self.navigationController.navigationBar setTranslucent:NO];
            [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [self.navigationController.navigationBar setBarTintColor:FC5];
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS1}];
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
        }
            break;
        case KDNavigationStyleYellow:
        {
            [self.navigationController.navigationBar setTranslucent:NO];
            [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [self.navigationController.navigationBar setBarTintColor:[UIColor kdNavYellowColor]];
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS1}];
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
        }
            break;
        case KDNavigationStyleClear:
        {
            [self.navigationController.navigationBar setTranslucent:NO];
            [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [self.navigationController.navigationBar setKD_navigationBarBackgroundAlpha:0.f];
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS1}];
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
        }
            break;
        case KDNavigationStyleTLClear:
        {
            [self.navigationController.navigationBar setTranslucent:YES];
            [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//            [self.navigationController.navigationBar setKD_navigationBarBackgroundAlpha:0.f];
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS1}];
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
        }
            break;
        case KDNavigationStyleCustom:
        {
            [self.navigationController.navigationBar setTranslucent:NO];
            [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [self.navigationController.navigationBar setBarTintColor:self.customColor];
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS1}];
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
        }
            break;

        default:
            break;
    }
}

- (void)setNavigationCustomStyleWithColorStr:(NSString *)colorStr {

    if (colorStr && colorStr.length == 7) {
        NSString *trueColor = [colorStr substringWithRange:NSMakeRange(1, colorStr.length - 1)];
        if (![[trueColor lowercaseString] isEqualToString:@"ffffff"]) {
            self.customColor = [UIColor colorWithHexRGB:trueColor];
            [self setNavigationStyle:KDNavigationStyleCustom];
        }
    }
}

- (void)setNavigationCustomStyleWithColor:(UIColor *)color {

    if (color && !CGColorEqualToColor(color.CGColor, FC6.CGColor)) {
        self.customColor = color;
        [self setNavigationStyle:KDNavigationStyleCustom];
    }
}

#pragma mark - setter && getter
- (BOOL)lineHidden
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setLineHidden:(BOOL)lineHidden
{
    objc_setAssociatedObject(self, @selector(lineHidden), @(lineHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)navLine
{
    UIView *navLine = objc_getAssociatedObject(self, _cmd);
    
    if (!navLine) {
        navLine = [[UILabel alloc] init];
        navLine.backgroundColor = [UIColor kdDividingLineColor];
        
        objc_setAssociatedObject(self, @selector(navLine), navLine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return navLine;
}

- (void)setNavLine:(UIView *)navLine
{
    objc_setAssociatedObject(self, @selector(navLine), navLine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)navigationImageView
{
    return objc_getAssociatedObject(self, _cmd);
}
           
- (void)setNavigationImageView:(UIView *)navigationImageView
{
    objc_setAssociatedObject(self, @selector(navigationImageView), navigationImageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (KDNavigationStyle)style {

   return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setStyle:(KDNavigationStyle)style {

    objc_setAssociatedObject(self, @selector(style), @(style), OBJC_ASSOCIATION_ASSIGN);
}


- (UIColor *)customColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCustomColor:(UIColor *)customColor {
        objc_setAssociatedObject(self, @selector(customColor), customColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
