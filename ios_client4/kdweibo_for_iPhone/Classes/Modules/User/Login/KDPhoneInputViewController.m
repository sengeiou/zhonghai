//
//  KDPhoneInputViewController.m
//  kdweibo
//
//  Created by bird on 14-4-21.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDPhoneInputViewController.h"
#import "MBProgressHUD.h"
#import "XTOpenConfig.h"
#import "KDCodeConfirmViewController.h"
#import "BOSConfig.h"
#import "KDInputView.h"

#define KD_SIGN_UP_FONT_SIZE 15.0f
#define kPhoneAccountCapWidth 25.0f

@interface KDPhoneInputViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, retain) UILabel *countryNumLabel;

@property (nonatomic, retain) KDInputView *phoneTextField;

@property (nonatomic, retain) UIButton *nextButton;

@property (nonatomic, assign) BOOL isFormatting;

@property (nonatomic, retain) XTOpenSystemClient *openClient;
//A.wang 邮箱验证
@property (nonatomic, retain) XTOpenSystemClient *emailCodeClient;
@property (nonatomic, retain) NSString *officePhone;
@property (nonatomic, retain) NSString *officeEmail;
@property (nonatomic, assign) BOOL isSendAllCode;  //是否邮箱手机号都发送验证码

@property (nonatomic, retain) MBProgressHUD *hud;
@end

@implementation KDPhoneInputViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _type = KDPhoneInputTypeUndefine;
    }
    return self;
}
- (void)dealloc
{
    //KD_RELEASE_SAFELY(_hud);
    //KD_RELEASE_SAFELY(_openClient);
    //KD_RELEASE_SAFELY(_countryNumLabel);
    //KD_RELEASE_SAFELY(_phoneTextField);
    ////KD_RELEASE_SAFELY(_nextButton);
    
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
    
    if (_type == KDPhoneInputTypeUpdatePhoneAccount) {
        [KDEventAnalysis event:event_settings_personal_mobile_open];
    }
    
    [KDWeiboAppDelegate setExtendedLayout:self];
    
    if (_type == KDPhoneInputTypeRegister)
        [self setTitle:ASLocalizedString(@"KDPhoneInputViewController_regis")];
    else if(_type == KDPhoneInputTypeFindPwd)
        [self setTitle:ASLocalizedString(@"KDPhoneInputViewController_find_psw")];
    else if(_type == KDPhoneInputTypeBind || _type == KDPhoneInputTypeUpdatePhoneAccount)
        [self setTitle:ASLocalizedString(@"KDCreateTeamViewController_bind_mobile")];
    
    [self setupViews];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor2];//RGBCOLOR(237, 237, 237);
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
//    [gesture release];
    
    UILabel *logoLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenFullWidth / 2 - 150, ScreenFullHeight - 60, 300, 30)];
    logoLabel.textAlignment = NSTextAlignmentCenter;
    logoLabel.text = ASLocalizedString(@"KDAuthViewController_tips_logo");
    logoLabel.textColor = FC3;
    logoLabel.font = FS4;
    [self.view addSubview:logoLabel];
}
- (void)tap
{
    [_phoneTextField.textFieldMain resignFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.phoneTextField becomeFirstResponder];
    
  /*
    /////////////////////////////////////////////////////////////////////////////
#warning TEST ONLY 由于测试服务器故障收不到验证码，故跳过本页面，直接进入输入验证码页面
    KDCodeConfirmViewController *ctr = [[KDCodeConfirmViewController alloc] init];
    ctr.shouldResetTimer = YES;
    [XTOpenConfig sharedConfig].phoneNumber = @"13000000000";
    [XTOpenConfig sharedConfig].countryCode = @"+86";

    ctr.phoneNumber = [XTOpenConfig sharedConfig].phoneNumber;
    ctr.delegate = _delegate;
    if (_type == KDPhoneInputTypeBind) {
        ctr.fromType = 1;
    }
    
    if (_type == KDPhoneInputTypeUpdatePhoneAccount) {
        ctr.fromType = 2;
    }
    
    [self.navigationController pushViewController:ctr animated:YES];
    [ctr release];
    /////////////////////////////////////////////////////////////////////////////
   */
}

- (void)setupViews
{
//    UIImage *textFieldBgImage = [UIImage imageNamed:@"textfield_bg_v3.png"];
//    textFieldBgImage = [textFieldBgImage stretchableImageWithLeftCapWidth:textFieldBgImage.size.width * 0.5f topCapHeight:textFieldBgImage.size.height * 0.5f];
    
    _phoneTextField = [[KDInputView alloc] initWithElement:KDInputViewElementNone];
    _phoneTextField.frame = CGRectMake(kPhoneAccountCapWidth, kd_StatusBarAndNaviHeight+30.0f, CGRectGetWidth(self.view.frame) - kPhoneAccountCapWidth * 2.f, 48.0f);
    _phoneTextField.textFieldMain.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.textFieldMain.placeholder = ASLocalizedString(@"KDPhoneInputViewController_input_regis_mobile");
    if (_type == KDPhoneInputTypeBind  || _type == KDPhoneInputTypeUpdatePhoneAccount)
        _phoneTextField.textFieldMain.placeholder = ASLocalizedString(@"KDPhoneInputViewController_input_bind_mobile");
    _phoneTextField.textFieldMain.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    _phoneTextField.background = textFieldBgImage;
//    _phoneTextField.font = [UIFont systemFontOfSize:KD_SIGN_UP_FONT_SIZE];
    _phoneTextField.textFieldMain.delegate = self;
    _phoneTextField.textFieldMain.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_phoneTextField.textFieldMain addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    _phoneTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _countryNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 0.f, 60.f, CGRectGetHeight(_phoneTextField.frame))];
    _countryNumLabel.backgroundColor = [UIColor clearColor];
    _countryNumLabel.textAlignment = NSTextAlignmentCenter;
    _countryNumLabel.text = @"+86";
    _countryNumLabel.font = FS4;
    _countryNumLabel.textColor = FC2;
    _phoneTextField.textFieldMain.leftViewMode = UITextFieldViewModeAlways;
    _phoneTextField.textFieldMain.leftView = _countryNumLabel;
    
    _nextButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDBindEmailViewController_submit")];
    _nextButton.frame = CGRectMake(kPhoneAccountCapWidth, CGRectGetMaxY(_phoneTextField.frame) +27.f, ScreenFullWidth-2*kPhoneAccountCapWidth, 40.0f);
    [_nextButton setCircle];
    _nextButton.enabled = NO;
    [_nextButton addTarget:self action:@selector(doNext:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_phoneTextField];
    [self.view addSubview:_nextButton];
    
}
//A.wang 邮箱验证
#pragma mark - login logic
- (void)startGetEmailCode:(BOOL)isVerifyPhone
{
    //获取验证码
    if (_hud == nil) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    if (nil == self.emailCodeClient) {
        self.emailCodeClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getEmailCodeDidReceived:result:)] ;//autorelease];
    }
    
    if(isVerifyPhone){
        [self.emailCodeClient sendEmail:[BOSSetting sharedSetting].userName officePhone:_officePhone];
    }else{
        [self.emailCodeClient sendEmail:[BOSSetting sharedSetting].userName officePhone:nil];
        
    }
}
- (void)getEmailCodeDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (_hud) {
        [_hud hide:YES];
        self.hud = nil;
    }
    
    if (client.hasError || !result.success || ![result isKindOfClass:[BOSResultDataModel class]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
        //        [alert release];
        
        self.emailCodeClient = nil;
        
        return;
    }
    
    self.emailCodeClient = nil;
    if (result.success)
    {
        KDCodeConfirmViewController *ctr = [[KDCodeConfirmViewController alloc] init];
        ctr.shouldResetTimer = YES;
        
        ctr.delegate = _delegate;
        if(_officePhone){
            ctr.fromType = 3;
            ctr.phoneNumber = _officePhone;//手机验证
        }else if(_officeEmail){
            ctr.fromType = 4;
            ctr.phoneNumber = _officeEmail;//邮箱验证
        }
        if(_isSendAllCode){
            ctr.isSendAllCode = YES;
        }
        [self.navigationController pushViewController:ctr animated:YES];
        _officePhone = nil;
        _officeEmail = nil;
        _isSendAllCode = NO;
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
    
}

- (void)startSendCode
{
    //获取验证码
    if (_hud == nil) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    if (nil == self.openClient) {
        self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(reactiveDidReceived:result:)] ;//autorelease];
    }
    
    if (_type == KDPhoneInputTypeFindPwd) {
        [self.openClient getCodeWithPhone:[XTOpenConfig sharedConfig].longPhoneNumber];
    }
    else if (_type == KDPhoneInputTypeBind  || _type == KDPhoneInputTypeUpdatePhoneAccount){
        [self.openClient fetchCodeWithPhone:[XTOpenConfig sharedConfig].longPhoneNumber openId:[BOSConfig sharedConfig].user.openId];
    }
}
- (void)reactiveDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (_hud) {
        [_hud hide:YES];
        self.hud = nil;
    }
    
    if (client.hasError)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        
        self.openClient = nil;
        
        return;
    }
    
    self.openClient = nil;
    if (result.success)
    {
        KDCodeConfirmViewController *ctr = [[KDCodeConfirmViewController alloc] init];
        ctr.shouldResetTimer = YES;
        ctr.phoneNumber = [XTOpenConfig sharedConfig].phoneNumber;
        ctr.delegate = _delegate;
        if (_type == KDPhoneInputTypeBind) {
            ctr.fromType = 1;
        }
        else if (_type == KDPhoneInputTypeUpdatePhoneAccount) {
            ctr.fromType = 2;
        }
        
        [self.navigationController pushViewController:ctr animated:YES];
//        [ctr release];
    
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
//    [alert release];
}
- (void)doNext:(id)sender
{
    
    if (![self isPhoneNumber:[self.phoneTextField.textFieldMain.text stringByReplacingOccurrencesOfString:@"-" withString:@""]]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDInviteByPhoneNumberViewController_mobile_error")message:ASLocalizedString(@"KDInviteByPhoneNumberViewController_mobile_unavailable")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];
        [alertView show];
//        [alertView release];
        
    }
    
    else
    {
        [_phoneTextField resignFirstResponder];
        [XTOpenConfig sharedConfig].countryCode = @"+86";
        NSLog(@"%@",[BOSConfig sharedConfig].user.phone );
        NSString *inputNum = [self.phoneTextField.textFieldMain.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if (_type != KDPhoneInputTypeFindPwd && [[BOSConfig sharedConfig].user.phone isEqualToString:inputNum]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDPhoneInputViewController_mobile_same")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
//            [alert release];
        }
        else
        {
            [XTOpenConfig sharedConfig].phoneNumber = inputNum;
            if (_type == KDPhoneInputTypeRegister) {
                
                if (_hud == nil) {
                    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                }
                
                if (nil == self.openClient) {
                    self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(phoneCheckDidReceived:result:)];
                }
                [self.openClient phoneCheckWithPhone:[XTOpenConfig sharedConfig].longPhoneNumber];
            }
            else if (_type == KDPhoneInputTypeFindPwd || _type == KDPhoneInputTypeBind || _type == KDPhoneInputTypeUpdatePhoneAccount)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDAuthViewController_comfirm_mobilephone")message: [NSString stringWithFormat:ASLocalizedString(@"KDPhoneInputViewController_tips_1"), _countryNumLabel.text, [self.phoneTextField.textFieldMain.text stringByReplacingOccurrencesOfString:@"-" withString:@""]] delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDAuthViewController_ok"), nil];
                alert.tag = 0x99;
                [alert show];
//                [alert release];
                
                [_phoneTextField resignFirstResponder];
            }
        }
        
    }
}
- (void)phoneCheckDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel*)result
{
    if (_hud) {
        [_hud hide:YES];
        self.hud = nil;
    }
    
    if (client.hasError)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        
        self.openClient = nil;
        [_phoneTextField becomeFirstResponder];
        
        return;
    }
    
    self.openClient = nil;
    [BOSSetting sharedSetting].userName = [result.dictJSON objectForKey:@"userName"];
    if (result.errorCode == kAccountActivatedCode) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:[NSString stringWithFormat:ASLocalizedString(@"KDPhoneInputViewController_tips_2")] delegate:nil cancelButtonTitle:ASLocalizedString(@"KDAuthViewController_ok")otherButtonTitles:nil, nil];
        [alert show];
//        [alert release];
    }
    //设置密码
    else if (result.errorCode == kAccountNotActivatedCode)
    {
        //获取验证码
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDAuthViewController_comfirm_mobilephone")message: [NSString stringWithFormat:ASLocalizedString(@"KDPhoneInputViewController_tips_1"), _countryNumLabel.text, [self.phoneTextField.textFieldMain.text stringByReplacingOccurrencesOfString:@"-" withString:@""]] delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDAuthViewController_ok"), nil];
        alert.tag = 0x99;
        [alert show];
//        [alert release];
        
        [_phoneTextField resignFirstResponder];
    }else if(result.errorCode == kAccountNotExistedCode){
       // NSString *error = [NSString stringWithFormat:@"%@%@%@",ASLocalizedString(@"该账号"),[XTOpenConfig sharedConfig].phoneNumber,ASLocalizedString(@"未导入系统,请联系系统管理员或重新输入。")];
        NSString *error = ASLocalizedString(@"KDAuthViewController_tips_un_import2");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDAuthViewController_comfirm_account2")message:error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];
        [alert show];
//        [alert release];
    }
    else if (result.errorCode == kAccountNotPhoneCodeverify) {
        //A.wang 获取验证码
        if([[result.dictJSON objectForKey:@"isVerifyPhone"] intValue] == 1){
            _officePhone =[result.dictJSON objectForKey:@"officePhone1"];
            //NSString *error = [NSString stringWithFormat:@"%@\n%@ %@",ASLocalizedString(@"KDAuthViewController_tips_send_sms"),[XTOpenConfig sharedConfig].countryCode,[result.dictJSON objectForKey:@"officePhone1"]];
            
            //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDAuthViewController_comfirm_mobilephone") message:error delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDAuthViewController_ok"), nil];
            //alert.tag = 0x101;
            //[alert show];
            [self startGetEmailCode:YES];
            
        }else if([[result.dictJSON objectForKey:@"isVerifyPhone"] intValue] == 0){
            _officeEmail =[result.dictJSON objectForKey:@"userName"];
            //NSString *error = [NSString stringWithFormat:@"%@\n %@",@"我们将发送验证码短信到这个邮箱：",[result.dictJSON objectForKey:@"userName"]];
            //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定邮箱" message:error delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDAuthViewController_ok"), nil];
            //alert.tag = 0x100;
            //[alert show];
            [self startGetEmailCode:NO];
            
        }else if([[result.dictJSON objectForKey:@"isVerifyPhone"] intValue] == 2){
            _officePhone =[result.dictJSON objectForKey:@"officePhone1"];
            _isSendAllCode = YES;
            //NSString *error = [NSString stringWithFormat:@"%@",@"我们将发送验证码到您的邮箱和手机号码"];
            
            //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定" message:error delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDAuthViewController_ok"), nil];
            //alert.tag = 0x101;
            //[alert show];
            [self startGetEmailCode:YES];
        }
        
        
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        
        [_phoneTextField becomeFirstResponder];
    }
}

- (BOOL)isPhoneNumber:(NSString *)number
{
    //    NSString *re = @"^(1(([35][0-9])|(47)|[8][012356789]))[0-9]{8}$";
    //    NSRange range = [number rangeOfString:re options:NSRegularExpressionSearch];
    //    return range.location != NSNotFound;
    return number.length == 11;
}

- (BOOL)textChanged:(UITextField *)textField
{
    if (!self.isFormatting) {
        [self setSeperator:textField];
        self.isFormatting = NO;
    }
    _nextButton.enabled = textField.text.length > 0;
    return YES;
}

- (void)setSeperator:(UITextField *)textField
{
    self.isFormatting = YES;
    NSString *text = [textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (text.length > 8 && text.length <= 11) {
        NSString *temp = [text substringWithRange:NSMakeRange(0, 3)];
        NSMutableString *result = [NSMutableString stringWithFormat:@"%@-",temp];
        temp = [text substringWithRange:NSMakeRange(3, 4)];
        [result appendString:[NSString stringWithFormat:@"%@-",temp]];
        temp = [text substringWithRange:NSMakeRange(7, text.length - 7)];
        [result appendString:[NSString stringWithFormat:@"%@",temp]];
        textField.text = result;
    }else {
        textField.text = text;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0x99) {
        
        if (buttonIndex == 1) {
            
            [self startSendCode];
        }
        
    }else if (alertView.tag == 0x100) {
        
        if (buttonIndex == 1) {
            
            [self startGetEmailCode:NO];
        }
        
    }else if (alertView.tag == 0x101) {
        
        if (buttonIndex == 1) {
            
            [self startGetEmailCode:YES];
        }
        
    }
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ([touch.view isKindOfClass:[UIButton class]]) ? NO : YES;;
}
@end
