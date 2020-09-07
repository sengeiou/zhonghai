
//
//  KDBindEmailViewController.m
//  kdweibo
//
//  Created by bird on 14-5-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDBindEmailViewController.h"
#import "BOSConfig.h"
#import "AlgorithmHelper.h"
#import "BOSSetting.h"

#define KD_SIGN_UP_FONT_SIZE 15.0f
#define kPhoneAccountCapWidth 15.0f

@interface KDBindEmailViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, retain) UITextField *pwdTextField;
@property (nonatomic, retain) UITextField *userNameTextField;
@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) MBProgressHUD *hud;
@property (nonatomic ,retain) XTOpenSystemClient *openClient;
@end

@implementation KDBindEmailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _fromType = 0;
    }
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_userNameTextField);
    //KD_RELEASE_SAFELY(_openClient);
    //KD_RELEASE_SAFELY(_hud);
    //KD_RELEASE_SAFELY(_pwdTextField);
    //KD_RELEASE_SAFELY(_nextButton);
    
    //[super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (_fromType == 1) {
        [KDEventAnalysis event:event_settings_personal_email_open];
    }
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
//    [gesture release];


    [self setTitle:[NSString stringWithFormat:ASLocalizedString(@"KDBindEmailViewController_bind_email"),KD_APPNAME]];
    
    [self setupViews];
    
    self.view.backgroundColor = RGBCOLOR(237, 237, 237);
}
- (void)tap
{
    [_userNameTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_userNameTextField becomeFirstResponder];
}
- (void)setupViews
{
    UIImage *textFieldBgImage = [UIImage imageNamed:@"textfield_bg_v3.png"];
    textFieldBgImage = [textFieldBgImage stretchableImageWithLeftCapWidth:textFieldBgImage.size.width * 0.5f topCapHeight:textFieldBgImage.size.height * 0.5f];
    
    _userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(kPhoneAccountCapWidth, 30.0f, CGRectGetWidth(self.view.frame) - kPhoneAccountCapWidth * 2.f, 48.0f)];
    _userNameTextField.keyboardType = UIKeyboardTypeEmailAddress;
    _userNameTextField.placeholder = [NSString stringWithFormat:ASLocalizedString(@"KDBindEmailViewController_email"),KD_APPNAME];
    _userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _userNameTextField.background = textFieldBgImage;
    _userNameTextField.font = [UIFont systemFontOfSize:KD_SIGN_UP_FONT_SIZE];
    _userNameTextField.delegate = self;
    _userNameTextField.returnKeyType = UIReturnKeyNext;
    _userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_userNameTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    _userNameTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
    _userNameTextField.leftView = left;
    _userNameTextField.leftViewMode = UITextFieldViewModeAlways;
//    [left release];
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
    _userNameTextField.rightView = right;
    _userNameTextField.rightViewMode = UITextFieldViewModeAlways;
//    [right release];
    
    
    _pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(kPhoneAccountCapWidth, CGRectGetMaxY(_userNameTextField.frame) + 15.f, CGRectGetWidth(self.view.frame) - kPhoneAccountCapWidth * 2.f, 48.0f)];
    _pwdTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _pwdTextField.placeholder = [NSString stringWithFormat:ASLocalizedString(@"KDBindEmailViewController_psw"),KD_APPNAME];
    _pwdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _pwdTextField.background = textFieldBgImage;
    _pwdTextField.font = [UIFont systemFontOfSize:KD_SIGN_UP_FONT_SIZE];
    _pwdTextField.delegate = self;
    _pwdTextField.secureTextEntry = YES;
    _pwdTextField.returnKeyType = UIReturnKeyGo;
    _pwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_pwdTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    _pwdTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    left = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
    _pwdTextField.leftView = left;
    _pwdTextField.leftViewMode = UITextFieldViewModeAlways;
//    [left release];
    
    right = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
    _pwdTextField.rightView = right;
    _pwdTextField.rightViewMode = UITextFieldViewModeAlways;
//    [right release];
    
    
    CGFloat y = CGRectGetMaxY(_pwdTextField.frame) +27.f;
    
    _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(kPhoneAccountCapWidth, y, 290.0f, 40.0f)];
    [_nextButton setTitle:ASLocalizedString(@"KDBindEmailViewController_submit")forState:UIControlStateNormal];
    UIImage *btnBKImage = [UIImage imageNamed:@"signon_btn_bg_v2.png"];
    [_nextButton setBackgroundImage:btnBKImage forState:UIControlStateNormal];
    _nextButton.layer.cornerRadius = 5.0f;
    _nextButton.layer.masksToBounds = YES;
    _nextButton.titleLabel.font = [UIFont systemFontOfSize:KD_SIGN_UP_FONT_SIZE];
    [_nextButton addTarget:self action:@selector(doNext) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_pwdTextField];
    [self.view addSubview:_userNameTextField];
    [self.view addSubview:_nextButton];
    
    
    if (_fromType == 0) {
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmBtn setImage:[UIImage imageNamed:@"navigationItem_title_arrow"] forState:UIControlStateNormal];
        [confirmBtn setImage:[UIImage imageNamed:@"navigationItem_title_arrow"] forState:UIControlStateHighlighted];
        [confirmBtn addTarget:self action:@selector(accessBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [confirmBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
        [confirmBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -35, 0, 0)];
        [confirmBtn setTitle:ASLocalizedString(@"KDBindEmailViewController_enter")forState:UIControlStateNormal];
        [confirmBtn sizeToFit];
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:confirmBtn];
        //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
        //2013-12-26 song.wang
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                            target:nil action:nil];// autorelease];
        negativeSpacer.width = kRightNegativeSpacerWidth;
        self.navigationItem.rightBarButtonItems = [NSArray
                                                   arrayWithObjects:negativeSpacer,rightItem, nil];
//        [rightItem release];
    }
}
- (void)accessBtnTapped
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:ASLocalizedString(@"KDBindEmailViewController_tips_giveup_email"),KD_APPNAME,KD_APPNAME] delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"Global_Sure"),nil];
    [alert show];
//    [alert release];

    alert.tag = 0x99;
}
- (void)doNext
{
    if ([_userNameTextField.text length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:ASLocalizedString(@"KDBindEmailViewController_tips_input_email"),KD_APPNAME] delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        return;
    }
    else if([[_pwdTextField text] length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:ASLocalizedString(@"KDBindEmailViewController_tips_input_psw"),KD_APPNAME] delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        return;
    }
    
    [self tap];
    
    if (_hud == nil) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(bindEmailDidReceived:result:)];// autorelease];
    NSString *password = [AlgorithmHelper des_Encrypt:_pwdTextField.text key:_userNameTextField.text];
    [self.openClient bindEmail:_userNameTextField.text secrect:password openId:[BOSConfig sharedConfig].user.openId];
}

- (void)bindEmailDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (_hud) {
        [_hud hide:YES];
        self.hud = nil;
    }
    
    if (client.hasError)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
        
        self.openClient = nil;
        
        return;
    }
    
    self.openClient = nil;
    if (result.success)
    {
        
        if (_fromType == 1) {
            [KDEventAnalysis event:event_settings_personal_email_ok];
        }
        
        [BOSConfig sharedConfig].user.email =_userNameTextField.text;
        [[BOSConfig  sharedConfig] saveConfig];
        
        if (_delegate && [_delegate respondsToSelector:@selector(finishBindEmail)]) {
            [_delegate finishBindEmail];
        }
        
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
}
- (BOOL)textChanged:(UITextField *)textField
{
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_userNameTextField == textField) {
        [_pwdTextField becomeFirstResponder];
    }
    else{
        [self tap];
    }
    
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ([touch.view isKindOfClass:[UIButton class]]) ? NO : YES;;
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0x99) {
    
        if (buttonIndex == 1) {
            
            if (_delegate && [_delegate respondsToSelector:@selector(finishBindEmail)]) {
                [_delegate finishBindEmail];
            }
        }
    }
    else
    {
    
    }
}
@end
