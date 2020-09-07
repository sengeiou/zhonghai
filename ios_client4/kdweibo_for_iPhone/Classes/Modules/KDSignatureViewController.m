//
//  KDSignatureViewController.m
//  kdweibo
//
//  Created by Joyingx on 16/6/23.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSignatureViewController.h"
// :: Other ::
#import "NSDate+Additions.h"
#import "iAppRevision.h"
#import "iAppRevisionView.h"
#import "iAppRevisionService.h"

@interface KDSignatureViewController ()

@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) iAppRevisionView *handwrittingView;

@property (nonatomic, assign, readwrite) BOOL isPresented;

@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGFloat webWidth;
@property (nonatomic, assign) CGFloat webHeight;
@property (nonatomic, assign) CGFloat penWidth;
@property (nonatomic, assign) NSInteger penType;
@property (nonatomic, copy) NSString *penColor;

@end

@implementation KDSignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpViews];
    
    self.isPresented = YES;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
//    NSNumber *value = [NSNumber numberWithInt:self.orientation];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self iAppRevisionHadSuccessAuthorized]) {
        // 注册授权信息异常
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:ASLocalizedString(@"KDSignatureViewController_authorized_fail") preferredStyle:UIAlertControllerStyleAlert];
        
        __weak __typeof(self) weakSelf = self;
        UIAlertAction *actionSure = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertVC addAction:actionSure];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (self.orientation == UIInterfaceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }
    else if(self.orientation == UIInterfaceOrientationLandscapeRight){
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)setUpViews {
    [self.view addSubview:self.navigationBar];
    
    [self.view addSubview:self.handwrittingView];
    
    UIButton *clearButton = [UIButton grayBtnWithTitle:ASLocalizedString(@"KDLocationOptionViewController_clean")];
    clearButton.layer.cornerRadius = 15;
    [clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];
    
    UIButton *penButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [penButton setImage:[UIImage imageNamed:@"revision_pen"] forState:UIControlStateNormal];
    [self.view addSubview:penButton];
    
    [self.navigationBar makeConstraints:^(MASConstraintMaker *make) {
        if (self.orientation == UIInterfaceOrientationPortrait
            || self.orientation == UIInterfaceOrientationPortraitUpsideDown) {
            make.top.equalTo(self.view.top).with.offset(20);
        } else {
            make.top.equalTo(self.view.top).with.offset(0);
        }
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.height.mas_equalTo(44);
    }];
    
    [self.handwrittingView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBar.bottom);
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.bottom.equalTo(self.view.bottom);
    }];
    
    [penButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).with.offset(6);
        make.bottom.equalTo(self.view.bottom).with.offset(-15);
        make.width.mas_equalTo(41);
        make.height.mas_equalTo(40);
    }];
    
    [clearButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.right).with.offset(-20);
        make.bottom.equalTo(self.view.bottom).with.offset(-20);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(30);
    }];
}

#pragma mark - Events

- (void)finish {
    
    if ([KDReachabilityManager sharedManager].reachabilityStatus == KDReachabilityStatusNotReachable) {
        [KDPopup showHUDToast:ASLocalizedString(@"KDSignatureViewController_non_network")];
        return;
    }
    
    __block UIImage *image;
    __block UIImage *signatureImage;
    __block CGRect signatureRect = CGRectZero;
    
    __weak __typeof(self) weakSelf = self;
    [self.handwrittingView saveSignatureWithCompletion:^(UIImage *fullImage, UIImage *clipImage, CGRect clipRect) {
        
        image = fullImage;
        signatureImage = clipImage;
        signatureRect = clipRect;
        
        if (signatureRect.size.width > weakSelf.maxWidth || signatureRect.size.height > weakSelf.maxHeight) {
            signatureImage = [signatureImage scaleToSize:CGSizeMake(weakSelf.maxWidth,weakSelf.maxHeight) type:KDImageScaleTypeFit];
        }
    }];
    
    if (!image && !signatureImage) {
        [KDPopup showHUDToast:ASLocalizedString(@"KDSignatureViewController_invalid_value") inView:self.view];
        return;
    }
    
    NSData *imageData = UIImagePNGRepresentation(signatureImage);
    NSString *base64Image = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    if (self.serverURL.length > 0) {
        
        NSString *fieldValue = [[iAppRevisionService service] fieldValueWithSignatureImageData:imageData signatureRect:signatureRect userName:self.userName oldFieldValue:nil];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        NSString *nowDateString = [dateFormatter stringFromDate:[NSDate date]];
        
        [KDPopup showHUD];
        [[iAppRevisionService service] saveSignatureWithWebService:self.serverURL recordID:self.recordID userName:self.userName fieldName:self.fieldName fieldValue:fieldValue dateTime:nowDateString extractImage:YES success:^(NSString *message) {
            
            [KDPopup hideHUD];
            [weakSelf postHandwrittingAndDismissWithImage:base64Image size:signatureImage.size];
            
        } failure:^(NSError *error) {
            
            [KDPopup hideHUD];
            [weakSelf postFailedAndDissmiss];
        }];
    } else {
        [self postHandwrittingAndDismissWithImage:base64Image size:signatureImage.size];
    }
}

- (void)postHandwrittingAndDismissWithImage:(NSString *)base64Image size:(CGSize)size {

    if (self.delegate && [self.delegate respondsToSelector:@selector(signatureDidFinished:imageSize:)]) {
        [self.delegate signatureDidFinished:base64Image imageSize:CGSizeMake(size.width, size.height)];
    }
    
    self.isPresented = NO;
    [self dismissViewControllerAnimated:YES completion:^{ }];
}

- (void)postFailedAndDissmiss {
    if (self.delegate && [self.delegate respondsToSelector:@selector(signatureDidFailed:)]) {
        [self.delegate signatureDidFailed:ASLocalizedString(@"KDSignatureViewController_save_fail")];
    }
    
    self.isPresented = NO;
    [self dismissViewControllerAnimated:YES completion:^{ }];
}

- (void)goBack {
    if (self.delegate && [self.delegate respondsToSelector:@selector(signatureDidFinished:imageSize:)]) {
        [self.delegate signatureDidFinished:@"" imageSize:CGSizeMake(0, 0)];
    }
    
    self.isPresented = NO;
    [self dismissViewControllerAnimated:YES completion:^{ }];
}

- (void)clear {
    [self.handwrittingView clean];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        [self.navigationBar updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.top).with.offset(20);
        }];
    } else {
        [self.navigationBar updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.top).with.offset(0);
        }];
    }
    
    [self resetHandwrittingView];
}

- (void)resetHandwrittingView {
    [self.handwrittingView removeFromSuperview];
    self.handwrittingView = nil;
    
    [self.view addSubview:self.handwrittingView];
    [self.handwrittingView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBar.bottom);
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.bottom.equalTo(self.view.bottom);
    }];
    
    [self setPenType:self.penType color:self.penColor width:self.penWidth];
}

- (BOOL)iAppRevisionHadSuccessAuthorized {
    NSString *copyright = [[BOSSetting sharedSetting] copyright];
    if (copyright.length == 0) {
        return NO;
    }
    
    return [iAppRevision sharedInstance].isAuthorized;
}

#pragma mark - Setters and Getters

- (UINavigationBar *)navigationBar {
    if (!_navigationBar) {
        _navigationBar = [[UINavigationBar alloc] init];
        _navigationBar.barStyle = UIBarStyleDefault;
        [_navigationBar setBarTintColor:FC6];
        [_navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : FC1, NSFontAttributeName : FS1}];
        
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:ASLocalizedString(@"KDSignatureViewController_title")];
        
        [navItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC5, NSFontAttributeName : FS3} forState:UIControlStateNormal];
        [navItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC5, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
        [navItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC5, NSFontAttributeName : FS3} forState:UIControlStateNormal];
        [navItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC5, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
        
        navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"Global_Cancel") style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
        navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDABActionTabBar_tips_2") style:UIBarButtonItemStyleDone target:self action:@selector(finish)];
        [_navigationBar setItems:@[navItem]];
    }
    
    return _navigationBar;
}

- (iAppRevisionView *)handwrittingView {
    if (!_handwrittingView) {
        iAppRevisionView *handwrittingView = [[iAppRevisionView alloc] init];
        handwrittingView.translatesAutoresizingMaskIntoConstraints = NO;
        handwrittingView.handwritingType = KGHandwritingTypePen;
        handwrittingView.handwritingColor = [UIColor blackColor];
        handwrittingView.handwritingWidth = 0.5;
        handwrittingView.backgroundColor = [UIColor whiteColor];
        _handwrittingView = handwrittingView;
    }
    
    return _handwrittingView;
}

- (void)setStamp:(NSString *)stamp {
    NSString *nowString = [[NSDate date] formatWithFormatter:@" yyyy-MM-dd"];
    _stamp = [stamp stringByAppendingString:nowString];
    
    if ([stamp isKindOfClass:[NSString class]] && stamp.length > 0) {
        [self.handwrittingView setWatermark:YES];
        [self.handwrittingView setWatermarkWithContent:self.stamp color:[UIColor blackColor] position:KGWatermarkPositionDefault scaleFactor:0.5];
    } else {
        [self.handwrittingView setWatermark:NO];
    }
}

- (void)setMaxSize:(CGSize)maxSize {
    if (maxSize.width <= 0 || maxSize.height <= 0) {
        return;
    }
    
    self.maxWidth = maxSize.width;
    self.maxHeight = maxSize.height;
}

- (void)setWebSize:(CGSize)webSize {
    if (webSize.width <= 0 || webSize.height <= 0) {
        return;
    }
    
    self.webWidth = webSize.width;
    self.webHeight = webSize.height;
}

- (void)setPenType:(NSInteger)penType color:(NSString *)color width:(CGFloat)width {
    self.penType = penType;
    self.penColor = [color copy];
    self.penWidth = width;
    
//    if (self.webWidth > 0) {
//        width = self.view.bounds.size.width * [UIScreen mainScreen].scale / self.webWidth * width;
//    }
    
    if ([color isKindOfClass:[NSString class]] && color.length > 0) {
        unsigned rgbValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:color];
        [scanner setScanLocation:1];
        [scanner scanHexInt:&rgbValue];
        self.handwrittingView.handwritingColor = UIColorFromRGB(rgbValue);
    }
    
    if (width > 0) {
        self.handwrittingView.handwritingWidth = width;
    }
    
    switch (penType) {
        case 0:
            self.handwrittingView.handwritingType = KGHandwritingTypePen;
            break;
        case 1:
            self.handwrittingView.handwritingType = KGHandwritingTypeBrush;
            break;
        case 2:
            self.handwrittingView.handwritingType = KGHandwritingTypePencil;
            break;
        case 3:
            self.handwrittingView.handwritingType = KGHandwritingTypeWaterColor;
            break;
            
        default:
            break;
    }
}

@end
