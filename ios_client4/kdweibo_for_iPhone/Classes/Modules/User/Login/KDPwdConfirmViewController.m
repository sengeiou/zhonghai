//
//  KDPwdConfirmViewController.m
//  kdweibo
//
//  Created by bird on 14-4-19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDPwdConfirmViewController.h"
#import "BOSSetting.h"
#import "XTOpenConfig.h"
#import "AlgorithmHelper.h"
#import "MBProgressHUD.h"
#import "XTOpenSystemClient.h"
#import "KDPhoneInputViewController.h"
#import "KDLinkInviteConfig.h"
#import "KDCodeConfirmViewController.h"
#import "KDUnderLineButton.h"
#import "KDConfigurationContext.h"
#import "KDWebViewController.h"
#import "URL+MCloud.h"

#define KD_SIGN_UP_FONT_SIZE 15.0f
#define kPhoneAccountCapWidth ScreenFullWidth*0.08

@interface KDPwdConfirmViewController ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, retain) UILabel *accountLabel;
@property (nonatomic, retain) KDInputView *pwdTextField;
@property (nonatomic, retain) KDInputView *pwdConfirmTextField;

@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) MBProgressHUD *hud;
@property (nonatomic ,retain) XTOpenSystemClient *openClient;

@property (nonatomic, retain) UIView      *regulationView;
@property (nonatomic, retain) UIButton *tickBtn;

@property (nonatomic, copy) NSString *complexPwdMsg;
@property (nonatomic, copy) NSString *complexPwdRegex;
@property (nonatomic, assign) BOOL isOpenComplexPwd;
@property (nonatomic, assign) BOOL isChangeSecureText;

@end

@implementation KDPwdConfirmViewController
@synthesize pwdTextField = _pwdTextField;
@synthesize delegate = _delegate;
@synthesize hud = _hud;
@synthesize openClient = _openClient;
@synthesize regulationView = _regulationView;
@synthesize tickBtn = _tickBtn;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _pwdType = KDPwdInputTypeUndefine;
        _pwdSupportType = KDPWDNotPhoneElse;
        _hasProtocolRegulation = NO;
        _isChangeSecureText = NO;
    }
    return self;
}
- (void)dealloc
{
    //KD_RELEASE_SAFELY(_openClient);
    //KD_RELEASE_SAFELY(_hud);
    //KD_RELEASE_SAFELY(_pwdTextField);
    ////KD_RELEASE_SAFELY(_nextButton);
    
    //[super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
//    [gesture release];
    
    if (_pwdType == KDPwdInputTypePwdConfirm)
        [self setTitle:ASLocalizedString(@"KDAuthViewController_psw")];
    else if(_pwdType == KDPwdInputTypePwdSetting) {
        [self setTitle:ASLocalizedString(@"KDPwdConfirmViewController_SettingPwd")];
        [self getPasswdSetting];
    }
    [self setupViews];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    
}

- (void)getPasswdSetting {
    NSString *urlStr = [NSString stringWithFormat:@"%@openaccess/user/getpwdsetting",MCLOUD_IP_FOR_PUBACC];
    NSString *newURLStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:newURLStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            if (httpResponse.statusCode == 200) {
                
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data];
                id settingData = dic[@"data"];
                if (settingData) {
                    NSMutableDictionary *data = settingData;
                    
                    id complexPwdMsg = (data[@"complexPwdMsg"] == [NSNull null]?nil:data[@"complexPwdMsg"]);
                    id complexPwdRegex = (data[@"complexPwdRegex"] == [NSNull null]?nil:data[@"complexPwdRegex"]);
                    id isOpenComplexPwd = (data[@"isOpenComplexPwd"] == [NSNull null]?nil:data[@"isOpenComplexPwd"]);
                    
                    self.complexPwdMsg = complexPwdMsg;
                    self.complexPwdRegex = complexPwdRegex;
                    self.isOpenComplexPwd = [isOpenComplexPwd boolValue];
                }
            }
        }
        
    }];
    
    [task resume];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([_pwdTextField.textFieldMain canBecomeFirstResponder]) {
        [_pwdTextField.textFieldMain becomeFirstResponder];
    }
}




- (void)tap
{
    [_pwdTextField.textFieldMain resignFirstResponder];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_pwdTextField becomeFirstResponder];
}
- (void)setupViews
{
    if(_pwdType == KDPwdInputTypePwdSetting)
    {
        _accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPhoneAccountCapWidth, kd_StatusBarAndNaviHeight+30, CGRectGetWidth(self.view.frame) - kPhoneAccountCapWidth * 2.f, 23)];
        _accountLabel.backgroundColor = [UIColor clearColor];
        _accountLabel.font = [UIFont systemFontOfSize:15.f];
        _accountLabel.textColor = FC2;
        _accountLabel.text = [NSString stringWithFormat:ASLocalizedString(@"你的登录账号是:%@"),[XTOpenConfig sharedConfig].phoneNumber];
        _accountLabel.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_accountLabel];
    }
    
    _pwdTextField =  [[KDInputView alloc] initWithElement:_pwdType == KDPwdInputTypePwdConfirm?KDInputViewElementButtonRight:KDInputViewElementNone];
    _pwdTextField.frame =CGRectMake(kPhoneAccountCapWidth,_pwdType == KDPwdInputTypePwdSetting?(CGRectGetMaxY(_accountLabel.frame)+10):(64+30.0f), CGRectGetWidth(self.view.frame) - kPhoneAccountCapWidth * 2.f, 48.0f);
    //_pwdTextField.imageViewLeft.image = [UIImage imageNamed:@"login_tip_password"];
    _pwdTextField.textFieldMain.placeholder = ASLocalizedString(@"KDAuthViewController_input_psw");
    if(_pwdType == KDPwdInputTypePwdSetting)
        _pwdTextField.textFieldMain.placeholder = [NSString stringWithFormat:ASLocalizedString(@"KDPwdConfirmViewController_textFieldMain_placeholder"),KD_APPNAME];
    _pwdTextField.textFieldMain.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _pwdTextField.textFieldMain.delegate = self;
    _pwdTextField.textFieldMain.secureTextEntry = NO;
    if(_pwdType == KDPwdInputTypePwdConfirm)
        _pwdTextField.textFieldMain.secureTextEntry = YES;
    [_pwdTextField.textFieldMain addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    _pwdTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
    if (_pwdType == KDPwdInputTypePwdConfirm) {
        UIImage *image = [UIImage imageNamed:@"login_btn_eye_bukejian_blue"];
        CGSize size = image.size;
        _pwdTextField.fButtonRightWidth = size.width;
        [_pwdTextField.buttonRight setImage:image forState:UIControlStateNormal];
        __weak __typeof (self) weakSelf = self;
        _pwdTextField.blockButtonRightPressed = ^(UIButton *button) {
            [weakSelf buttonSecurePressed:weakSelf.pwdTextField];
        };
    }
    
    CGFloat y = CGRectGetMaxY(_pwdTextField.frame) +27.f;
    
    if (_pwdType == KDPwdInputTypePwdSetting) {
        
        _pwdConfirmTextField =  [[KDInputView alloc] initWithElement:KDInputViewElementNone];
        _pwdConfirmTextField.frame =CGRectMake(CGRectGetMinX(_pwdTextField.frame), CGRectGetMaxY(_pwdTextField.frame)+10, CGRectGetWidth(_pwdTextField.frame), CGRectGetHeight(_pwdTextField.frame));
        //_pwdConfirmTextField.imageViewLeft.image = [UIImage imageNamed:@"login_tip_password"];
        _pwdConfirmTextField.textFieldMain.placeholder = ASLocalizedString(@"KDChangePasswordVC_Confirm_Pwd");
        _pwdConfirmTextField.textFieldMain.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _pwdConfirmTextField.textFieldMain.secureTextEntry = _pwdTextField.textFieldMain.secureTextEntry;
        _pwdConfirmTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _pwdConfirmTextField.textFieldMain.delegate = self;
        [_pwdConfirmTextField.textFieldMain addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_pwdConfirmTextField];
        
        y = CGRectGetMaxY(_pwdConfirmTextField.frame) +10.f;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_pwdTextField.frame), y, 80, 23)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15.f];
        label.textColor = FC2;
        label.text = ASLocalizedString(@"KDPwdConfirmViewController_ShowPwd");
        label.textAlignment = NSTextAlignmentLeft;
        CGRect frame = label.frame;
        [label sizeToFit];
        frame.size.width = CGRectGetWidth(label.frame);
        label.frame = frame;
        [self.view addSubview:label];
//        [label release];
        
        UIButton *crookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [crookButton setFrame:CGRectMake(CGRectGetMaxX(label.frame), y, 23, 23)];
        [crookButton setImage:[UIImage imageNamed:@"login_check_press"] forState:UIControlStateNormal];
        [crookButton addTarget:self action:@selector(crookClick:) forControlEvents:UIControlEventTouchUpInside];
        crookButton.tag = 0x99;
        [self.view addSubview:crookButton];
//        if(!isAboveiPhone5){
//            label.frame = CGRectMake(kPhoneAccountCapWidth+20, CGRectGetMaxY(_pwdTextField.frame)+15.f, 80, 23);
//            crookButton.frame = CGRectMake(CGRectGetMaxX(label.frame), CGRectGetMaxY(_pwdTextField.frame)+15.f, 23, 23);
//        }
        y = CGRectGetMaxY(crookButton.frame) +15.f;
    }
//    else if (_pwdType == KDPwdInputTypePwdConfirm)
//    {
//        UIButton *signUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [signUpBtn setTitleColor:FC2 forState:UIControlStateNormal];
//        [signUpBtn setTitle:ASLocalizedString(@"KDPwdConfirmViewController_ForgetPwd")forState:UIControlStateNormal];
//        signUpBtn.backgroundColor = [UIColor clearColor];
//        [signUpBtn addTarget:self action:@selector(opClick) forControlEvents:UIControlEventTouchUpInside];
//        signUpBtn.titleLabel.font = FS6;
//        signUpBtn.frame = CGRectMake(CGRectGetMinX(_pwdTextField.frame), CGRectGetMaxY(_pwdTextField.frame)+10.f, 85.0f, 22.0f);
//        [self.view addSubview:signUpBtn];
//
//        y = CGRectGetMaxY(signUpBtn.frame)+15.f;
////        signUpBtn.hidden = _pwdSupportType == KDPWDSupportTypeSetting?YES:NO;
//    }
    
    //员工守则视图
    _regulationView = [[UIView alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.view.bounds), 30.0f)];// autorelease];
    _regulationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_regulationView];
    
    _tickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_tickBtn setImage:[UIImage imageNamed:@"login_check_normal"] forState:UIControlStateNormal];
    [_tickBtn setImage:[UIImage imageNamed:@"login_check_press"] forState:UIControlStateSelected];
    [_tickBtn sizeToFit];
    [_tickBtn addTarget:self action:@selector(tickAction:) forControlEvents:UIControlEventTouchUpInside];
    _tickBtn.frame = CGRectMake(24.0f, (CGRectGetHeight(_regulationView.frame) - _tickBtn.bounds.size.height) * 0.5f+8.f, _tickBtn.bounds.size.width, _tickBtn.bounds.size.height);
    _tickBtn.center = CGPointMake(_tickBtn.center.x, CGRectGetHeight(_regulationView.frame)/2);
    [self.regulationView addSubview:_tickBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = RGBCOLOR(123, 123, 123);
    label.text = ASLocalizedString(@"KDPwdConfirmViewController_AgreeAndComply");
    label.font = FS6;
    [label sizeToFit];
    label.frame = CGRectMake(CGRectGetMaxX(_tickBtn.frame) + 5.0f, (CGRectGetHeight(_regulationView.frame) - CGRectGetHeight(label.bounds)) * 0.5f, CGRectGetWidth(label.bounds), CGRectGetHeight(label.bounds));
    label.center = CGPointMake(label.center.x, CGRectGetHeight(_regulationView.frame)/2);
    [_regulationView addSubview:label];
//    [label release];
    
    KDUnderLineButton *btn = [KDUnderLineButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitleColor:FC2 forState:UIControlStateNormal];
    btn.titleLabel.font = FS5;
    NSString *regulationInfo = [NSString stringWithFormat:ASLocalizedString(@"KDPwdConfirmViewController_Regulation"),KD_APPNAME];
    [btn setTitle:regulationInfo forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.underLineColor = FC2;
    btn.lineSpace = 1.0f;
    btn.frame = CGRectMake(CGRectGetMaxX(label.frame) + 2.0f, (CGRectGetHeight(_regulationView.frame) - CGRectGetHeight(btn.bounds)) * 0.5f, CGRectGetWidth(btn.bounds), CGRectGetHeight(btn.bounds));
    [btn addTarget:self action:@selector(staffRegulation:) forControlEvents:UIControlEventTouchUpInside];
    [_regulationView addSubview:btn];
    
    _regulationView.hidden =!_hasProtocolRegulation;
    if(![_regulationView isHidden]){
        y = CGRectGetMaxY(_regulationView.frame) +27.f;
    }

    _nextButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDAuthViewController_next_step")];
    _nextButton.frame = CGRectMake(kPhoneAccountCapWidth, y, ScreenFullWidth-2*kPhoneAccountCapWidth, 40.0f);
    [_nextButton setCircle];
    _nextButton.enabled = NO;
    [_nextButton addTarget:self action:@selector(doNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pwdTextField];
    [self.view addSubview:_nextButton];
    
    if (_pwdType == KDPwdInputTypePwdConfirm && !self.isHideSMSVerify)
    {
        UIButton *signUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [signUpBtn setTitleColor:FC2 forState:UIControlStateNormal];
        [signUpBtn setTitle:ASLocalizedString(@"KDPwdConfirmViewController_ForgetPwd")forState:UIControlStateNormal];
        signUpBtn.backgroundColor = [UIColor clearColor];
        [signUpBtn addTarget:self action:@selector(opClick) forControlEvents:UIControlEventTouchUpInside];
        signUpBtn.titleLabel.font = FS5;
        signUpBtn.frame = CGRectMake(CGRectGetMinX(_pwdTextField.frame)-3, CGRectGetMaxY(_nextButton.frame)+10.f, 125.0f, 22.0f);
        [self.view addSubview:signUpBtn];
        
        y = CGRectGetMaxY(signUpBtn.frame)+15.f;
        //        signUpBtn.hidden = _pwdSupportType == KDPWDSupportTypeSetting?YES:NO;
    }
    
    UILabel *logoLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenFullWidth / 2 - 150, ScreenFullHeight - 60, 300, 30)];
    logoLabel.textAlignment = NSTextAlignmentCenter;
    logoLabel.text = ASLocalizedString(@"KDAuthViewController_tips_logo");
    logoLabel.textColor = FC3;
    logoLabel.font = FS4;
    [self.view addSubview:logoLabel];
}


// 点击显示密码明文
- (void)buttonSecurePressed:(KDInputView *)inputView {
    //add
    [KDEventAnalysis event:event_lpwd_visible];
    [KDEventAnalysis eventCountly:event_lpwd_visible];
    // 防止密文切换 光标移位
    NSString *tempStr = inputView.textFieldMain.text;
    inputView.textFieldMain.text = nil;
    inputView.textFieldMain.text = tempStr;
    [inputView.textFieldMain setFont:nil];
    [inputView.textFieldMain setFont:FS3];
    
    [inputView.textFieldMain setSecureTextEntry:!inputView.textFieldMain.secureTextEntry];
    if (inputView.textFieldMain.secureTextEntry) {
        [inputView.buttonRight setImage:[UIImage imageNamed:@"login_btn_eye_bukejian_blue"] forState:UIControlStateNormal];
    }
    else {
        self.isChangeSecureText = YES;
        inputView.textFieldMain.keyboardType = UIKeyboardTypeASCIICapable;
        [inputView.buttonRight setImage:[UIImage imageNamed:@"login_btn_eye_kejie_bule"] forState:UIControlStateNormal];
    }
}

- (void)opClick
{
    if(_pwdSupportType == KDPWDNotPhoneEmail){
        [self resetPassordWithEmail:[XTOpenConfig sharedConfig].phoneNumber];
    }else if(_pwdSupportType == KDPWDNotPhonePhone){
        NSString *countryCode = [XTOpenConfig sharedConfig].countryCode;
        NSString *phoneNumber = [XTOpenConfig sharedConfig].phoneNumber;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDAuthViewController_comfirm_mobilephone")message: [NSString stringWithFormat:ASLocalizedString(@"KDPhoneInputViewController_tips_1"), countryCode, phoneNumber] delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDAuthViewController_ok"), nil];
        alert.tag = 0x99;
        [alert show];
//        [alert release];
    }else if(_pwdSupportType == KDPWDNotPhoneElse){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDAuthViewController_tips_forget_psw")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];
        [alert show];
//        [alert release];
    }else{
        NSString *countryCode = [XTOpenConfig sharedConfig].countryCode;
        NSString *phoneNumber = [XTOpenConfig sharedConfig].phoneNumber;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDAuthViewController_comfirm_mobilephone")message: [NSString stringWithFormat:ASLocalizedString(@"KDPhoneInputViewController_tips_1"), countryCode, phoneNumber] delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDAuthViewController_ok"), nil];
        alert.tag = 0x99;
        [alert show];
//        [alert release];
    }
    
    [_pwdTextField resignFirstResponder];
}
- (void)crookClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == 0x99) {
        
        [button setImage:[UIImage imageNamed:@"login_check_normal"] forState:UIControlStateNormal];
        _pwdTextField.textFieldMain.secureTextEntry = YES;
        _pwdConfirmTextField.textFieldMain.secureTextEntry = YES;
        button.tag = 0x98;
    }
    else if(button.tag == 0x98)
    {
        [button setImage:[UIImage imageNamed:@"login_check_press"] forState:UIControlStateNormal];
        
        _pwdTextField.textFieldMain.secureTextEntry = NO;
        _pwdConfirmTextField.textFieldMain.secureTextEntry = NO;
        button.tag = 0x99;
    }
}

- (void)tickAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected && [_pwdTextField.textFieldMain.text length] >0) {
        _nextButton.enabled = YES;
    }
    else
        _nextButton.enabled = NO;
}

- (void)staffRegulation:(KDUnderLineButton *)btn
{
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"i.World-staff-regulation" ofType:@"pdf"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]];
    KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
    NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
    NSString *fileUrl = [NSString stringWithFormat:@"%@/res/client/agreement.pdf",baseURL];
    KDWebViewController *webView = [[KDWebViewController alloc] initWithUrlString:fileUrl];
    [self.navigationController pushViewController:webView animated:YES];
}

- (void)resetPassordWithEmail:(NSString *)email {
    
    KDQuery *query = [KDQuery queryWithName:@"email" value:email];
    
//    __block KDPwdConfirmViewController *upevc = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        NSInteger errorCode = [results objectForKey:@"errorCode"];
        if (errorCode) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:ASLocalizedString(@"已经将密码重置链接发送到你的邮箱,请及时查收。")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];
            [alert show];
            [alert show];
        }
        
        
        //
        //        if(user){
        //
        //            [BOSConfig sharedConfig].user.name = userName;
        //            [[BOSConfig sharedConfig] saveConfig];
        //
        //
        //            [[NSNotificationCenter defaultCenter] postNotificationName:KDProfileUserNameUpdateNotification object:self userInfo:[NSDictionary dictionaryWithObject:user forKey:@"user"]];
        //        }
        //
        //        [upevc _handleResponseUser:user message:NSLocalizedString(@"UPDATE_USER_USERNAME_DID_FAIL", @"")];
        
        // release current view controller
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/account/:resetPassordWithEmail" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)doNext:(id)sender
{
    NSInteger pwdLength = _pwdTextField.textFieldMain.text.length;
    if (pwdLength == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDAuthViewController_input_psw")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        return;
    }
    
    // 判断密码是否合法
    if (self.isOpenComplexPwd) {
        if (![self checkPassword:_pwdTextField.textFieldMain.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:self.complexPwdMsg delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure") otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    } else {
        if(pwdLength < 6 || pwdLength > 25){
            NSString *tip = ASLocalizedString(@"KDPwdConfirmViewController_alertView_message");
            if (_pwdType == KDPwdInputTypePwdConfirm) {
                tip =  ASLocalizedString(@"KDPwdConfirmViewController_alertView_message_confirm");
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:tip delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
//            [alert release];
            return;
        }
    }
    
    [_pwdTextField resignFirstResponder];
    
    if (_pwdType == KDPwdInputTypePwdConfirm) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(authViewConfirmPwd)]) {
            
            //[BOSSetting sharedSetting].userName = [XTOpenConfig sharedConfig].longPhoneNumber;
            [BOSSetting sharedSetting].password = _pwdTextField.textFieldMain.text;
            
            [_delegate authViewConfirmPwd];
        }
    }
    else if(_pwdType == KDPwdInputTypePwdSetting)
    {
        if(![_pwdTextField.textFieldMain.text isEqualToString:_pwdConfirmTextField.textFieldMain.text])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"两次输入的密码不一致，请重新输入")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
//            [alert release];
            return ;
        }
        
        //not equal to  inital password
        if([_pwdTextField.textFieldMain.text isEqualToString:@"000000"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDPwdConfirmViewController_alertView_message_tips")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
//            [alert release];
            return ;
        }
        
        if (_hud == nil) {
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        
        self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(changepwdDidReceived:result:)];
        NSString *code = @"";
        if ([XTOpenConfig sharedConfig].code) {
           code =  [AlgorithmHelper des_Encrypt:[XTOpenConfig sharedConfig].code key:[XTOpenConfig sharedConfig].longPhoneNumber];
        }
        NSString *password = [AlgorithmHelper des_Encrypt:_pwdTextField.textFieldMain.text key:[XTOpenConfig sharedConfig].longPhoneNumber];
        [self.openClient changepwdWithPhone:[XTOpenConfig sharedConfig].longPhoneNumber checkCode:code password:password passwordack:password];
    }
}
- (void)changepwdDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
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

        if (_delegate && [_delegate respondsToSelector:@selector(authViewConfirmPwd)]) {
            
            //[BOSSetting sharedSetting].userName = [XTOpenConfig sharedConfig].longPhoneNumber;
            [BOSSetting sharedSetting].password = _pwdTextField.textFieldMain.text;
            
            [_delegate authViewConfirmPwd];
            
            if (self.isRegister) {
                if ([[KDLinkInviteConfig sharedInstance] isExistInvite]) {
                    [KDEventAnalysis event:event_register_mobile_ok attributes:@{label_register_mobile_ok_registerType:label_register_mobile_ok_registerType_passive}];
                }
                else{
                    [KDEventAnalysis event:event_register_mobile_ok attributes:@{label_register_mobile_ok_registerType:label_register_mobile_ok_registerType_initiative}];
                }
            }
            else {
                [KDEventAnalysis event:event_login_resetpassword_ok];
            }
        }
        
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
        self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(reactiveDidReceived:result:)];// autorelease];
    }
    
    [self.openClient getCodeWithPhone:[XTOpenConfig sharedConfig].longPhoneNumber];
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
        [self.navigationController pushViewController:ctr animated:YES];
//        [ctr release];
        
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
//    [alert release];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textChanged:(UITextField *)textField
{
    _nextButton.enabled = (_pwdTextField.textFieldMain.text.length > 0) &&(_pwdType == KDPwdInputTypePwdSetting?(_pwdConfirmTextField.textFieldMain.text.length>0):YES) && (_tickBtn.selected == YES || [_regulationView isHidden]);
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_pwdTextField resignFirstResponder];
    [_pwdConfirmTextField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //明文切换密文后避免被清空
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (range.location != 0 && self.isChangeSecureText && textField == self.pwdTextField.textFieldMain && self.pwdTextField.textFieldMain.isSecureTextEntry) {
        textField.text = toBeString;
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.isChangeSecureText = NO;
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ([touch.view isKindOfClass:[UIButton class]]) ? NO : YES;;
}

#pragma mark - UIAlertView Delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0x99) {
        
        if (buttonIndex == 1) {
            
            [self startSendCode];
        }
        
    }
}

- (BOOL)checkPassword:(NSString *) pwd
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", self.complexPwdRegex];
    BOOL isMatch = [pred evaluateWithObject:pwd];
    return isMatch;
}

@end
