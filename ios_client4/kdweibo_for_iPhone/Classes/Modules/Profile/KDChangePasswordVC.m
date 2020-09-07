//
//  KDChangePasswordVC.m
//  kdweibo
//
//  Created by Darren on 15/3/16.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDChangePasswordVC.h"
#import "BOSConfig.h"
#import "AlgorithmHelper.h"
#import "URL+MCloud.h"

@interface KDChangePasswordVC ()
<UITextFieldDelegate, UIAlertViewDelegate>
@property(nonatomic, strong) XTOpenSystemClient *openClient;
@property(nonatomic, strong) NSString *nPassword;

@property(nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) KDInputView *inputViewCurrentPassword;
@property (nonatomic, strong) KDInputView *inputViewNewPassword;
@property (nonatomic, strong) KDInputView *inputViewConfirmPassword;
@property(nonatomic, strong) UIButton *buttonDone;
@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) NSString *complexPwdMsg;
@property (nonatomic, strong) NSString *complexPwdRegex;
@property (nonatomic, assign) BOOL isOpenComplexPwd;

@end

@implementation KDChangePasswordVC

#define alertview_flag_success 10001

- (void)dealloc {
    [_openClient cancelRequest];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = ASLocalizedString(@"KDChangePasswordVC_Change_Pwd");

    [self.view addSubview:self.labelTitle];
    
    CGFloat inputViewLeftRightDistance = 32.5;
    [self.labelTitle makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(inputViewLeftRightDistance);
         make.top.equalTo(self.view.top).with.offset(35+kd_StatusBarAndNaviHeight);
     }];

    [self.view addSubview:self.inputViewCurrentPassword];

    [self.inputViewCurrentPassword makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(inputViewLeftRightDistance);
         make.right.equalTo(self.view.right).with.offset(-inputViewLeftRightDistance);
         make.top.equalTo(self.labelTitle.bottom).with.offset(20);
         make.height.mas_equalTo(45);
     }];
    
    [self.view addSubview:self.inputViewNewPassword];

    [self.inputViewNewPassword makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(inputViewLeftRightDistance);
         make.right.equalTo(self.view.right).with.offset(-inputViewLeftRightDistance);
         make.top.equalTo(self.inputViewCurrentPassword.bottom).with.offset(8);
         make.height.mas_equalTo(45);
     }];
    
    [self.view addSubview:self.inputViewConfirmPassword];

    [self.inputViewConfirmPassword makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(inputViewLeftRightDistance);
         make.right.equalTo(self.view.right).with.offset(-inputViewLeftRightDistance);
         make.top.equalTo(self.inputViewNewPassword.bottom).with.offset(8);
         make.height.mas_equalTo(45);
     }];
    
    [self.view addSubview:self.tipsLabel];
    
    [self.tipsLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).with.offset(inputViewLeftRightDistance);
        make.right.equalTo(self.view.right).with.offset(-inputViewLeftRightDistance);
        make.top.equalTo(self.inputViewConfirmPassword.bottom).with.offset(8);
        make.height.mas_equalTo(35);
    }];
    
    [self.view addSubview:self.buttonDone];

    [self.buttonDone makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(inputViewLeftRightDistance);
         make.right.equalTo(self.view.right).with.offset(-inputViewLeftRightDistance);
         make.top.equalTo(self.tipsLabel.bottom).with.offset(25);
         make.height.mas_equalTo(44);
     }];

    [self changeToV7Style];
    [self getPasswdSetting];
    
}

- (void)changeToV7Style
{
//    [self.inputViewCurrentPassword changeToKDV7Style];
//    [self.inputViewNewPassword changeToKDV7Style];
//    [self.inputViewConfirmPassword changeToKDV7Style];
//    
//    self.inputViewCurrentPassword.layer.cornerRadius = 45.0/2;
//    self.inputViewNewPassword.layer.cornerRadius = 45.0/2;
//    self.inputViewConfirmPassword.layer.cornerRadius = 45.0/2;
    
    self.buttonDone.layer.cornerRadius = 44.0/2;
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
                    self.complexPwdMsg = data[@"complexPwdMsg"];
                    self.complexPwdRegex = data[@"complexPwdRegex"];
                    self.isOpenComplexPwd = [data[@"isOpenComplexPwd"] boolValue];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.tipsLabel.text = self.isOpenComplexPwd ? self.complexPwdMsg : ASLocalizedString(@"KDPwdConfirmViewController_alertView_message");
                    });
                }
            }
        }
        
    }];
    
    [task resume];
}

- (void)buttonDonePressed:(UIButton *)button {
    if (self.inputViewCurrentPassword.textFieldMain.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDChangePasswordVC_Old_Pwd_Nil") delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (self.inputViewNewPassword.textFieldMain.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDChangePasswordVC_New_Pwd_Nil") delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (self.inputViewConfirmPassword.textFieldMain.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDChangePasswordVC_Confirm_Pwd_Nil") delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (![self.inputViewNewPassword.textFieldMain.text isEqualToString:self.inputViewConfirmPassword.textFieldMain.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDChangePasswordVC_Pwd_Different") delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    // 判断密码是否合法
    if (self.isOpenComplexPwd) {
        if (![self checkPassword:self.inputViewNewPassword.textFieldMain.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:self.complexPwdMsg delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure") otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    } else {
        if(self.inputViewNewPassword.textFieldMain.text.length < 6 || self.inputViewNewPassword.textFieldMain.text.length > 25){
            NSString *tip = ASLocalizedString(@"KDPwdConfirmViewController_alertView_message");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:tip delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    
    
    if (self.openClient == nil)
    {
        self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(changepwdDidReceived:result:)];
    }
    
    NSString *strAccount = [BOSConfig sharedConfig].user.phone.length != 0 ? [BOSConfig sharedConfig].user.phone : [BOSConfig sharedConfig].user.email;
    NSString *oldPassword = [AlgorithmHelper des_Encrypt:self.inputViewCurrentPassword.textFieldMain.text key:strAccount];
    NSString *newPassword = [AlgorithmHelper des_Encrypt:self.inputViewNewPassword.textFieldMain.text key:strAccount];
    self.nPassword = self.inputViewNewPassword.textFieldMain.text;
    [self.openClient changePasswordWithAccount:strAccount oldPassword:oldPassword newPassword:newPassword];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)changepwdDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (client.hasError)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure") otherButtonTitles:nil];
        [alert show];
        self.openClient = nil;
        return;
    }
    self.openClient = nil;
    if (result.success)
    {
        [BOSSetting sharedSetting].password = self.nPassword;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDChangePasswordVC_Pwd_Change_Success") delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure") otherButtonTitles:nil];
        alert.tag = alertview_flag_success;
        [alert show];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure") otherButtonTitles:nil];
    [alert show];
}

- (UILabel *)labelTitle
{
    if (!_labelTitle)
    {
        _labelTitle = [UILabel new];
        _labelTitle.backgroundColor = [UIColor clearColor];
        NSString *strPhoneNum = [BOSConfig sharedConfig].user.phone;
        NSString *strText = strPhoneNum != 0 ? [NSString stringWithFormat:ASLocalizedString(@"KDChangePasswordVC_Login_Account"), strPhoneNum] : [NSString stringWithFormat:ASLocalizedString(@"KDChangePasswordVC_Login_Account"), [BOSConfig sharedConfig].user.email];
        
        NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:strText];
        [mas dz_setFont:FS3];
        [mas dz_setTextColor:FC2 range:NSMakeRange(0, 8)];
        [mas dz_setTextColor:FC1 range:NSMakeRange(9, strText.length - 8 - 1)];
        
        _labelTitle.attributedText = mas;
    }
    return _labelTitle;
}

- (KDInputView *)inputViewCurrentPassword
{
    if (!_inputViewCurrentPassword)
    {
//        _inputViewCurrentPassword = [[KDInputView alloc] initWithElement:KDInputViewElementNone shouldFormatPhoneNumber:NO];
        _inputViewCurrentPassword = [[KDInputView alloc] initWithElement:KDInputViewElementNone];
        _inputViewCurrentPassword.textFieldMain.secureTextEntry = YES;
        _inputViewCurrentPassword.textFieldMain.returnKeyType = UIReturnKeyNext;
        _inputViewCurrentPassword.textFieldMain.placeholder = ASLocalizedString(@"KDChangePasswordVC_Old_Pwd");
        _inputViewCurrentPassword.textFieldMain.delegate = self;
    }
    return _inputViewCurrentPassword;
}

- (KDInputView *)inputViewNewPassword
{
    if (!_inputViewNewPassword)
    {
//        _inputViewNewPassword = [[KDInputView alloc] initWithElement:KDInputViewElementNone shouldFormatPhoneNumber:NO];
        _inputViewNewPassword = [[KDInputView alloc] initWithElement:KDInputViewElementNone];
        _inputViewNewPassword.textFieldMain.secureTextEntry = YES;
        _inputViewNewPassword.textFieldMain.returnKeyType = UIReturnKeyNext;
        _inputViewNewPassword.textFieldMain.placeholder = ASLocalizedString(@"KDChangePasswordVC_New_Pwd");
        _inputViewNewPassword.textFieldMain.delegate = self;
    }
    return _inputViewNewPassword;
}

- (KDInputView *)inputViewConfirmPassword
{
    if (!_inputViewConfirmPassword)
    {
//        _inputViewConfirmPassword = [[KDInputView alloc] initWithElement:KDInputViewElementNone shouldFormatPhoneNumber:NO];
        _inputViewConfirmPassword = [[KDInputView alloc] initWithElement:KDInputViewElementNone];
        _inputViewConfirmPassword.textFieldMain.secureTextEntry = YES;
        _inputViewConfirmPassword.textFieldMain.returnKeyType = UIReturnKeyNext;
        _inputViewConfirmPassword.textFieldMain.placeholder = ASLocalizedString(@"KDChangePasswordVC_Confirm_Pwd");
        _inputViewConfirmPassword.textFieldMain.delegate = self;
    }
    return _inputViewConfirmPassword;
}

- (UIButton *)buttonDone
{
    if (!_buttonDone)
    {
        _buttonDone = [KDWideButton new];
        [_buttonDone setTitle:ASLocalizedString(@"KDCompanyChoseViewController_complete") forState:UIControlStateNormal];
        [_buttonDone addTarget:self action:@selector(buttonDonePressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonDone;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.backgroundColor = [UIColor clearColor];
        _tipsLabel.text = ASLocalizedString(@"KDPwdConfirmViewController_alertView_message");
        _tipsLabel.textColor = FC3;
        _tipsLabel.font = FS5;
        _tipsLabel.textAlignment = NSTextAlignmentLeft;
        _tipsLabel.numberOfLines = 0;
    }
    return _tipsLabel;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.inputViewCurrentPassword.textFieldMain)
    {
        [self.inputViewNewPassword.textFieldMain becomeFirstResponder];
    }
    else if (textField == self.inputViewNewPassword.textFieldMain)
    {
        [self.inputViewConfirmPassword becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == alertview_flag_success) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)checkPassword:(NSString *) pwd
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", self.complexPwdRegex];
    BOOL isMatch = [pred evaluateWithObject:pwd];
    return isMatch;
}

@end
