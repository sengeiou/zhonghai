//
//  KDCodeConfirmViewController.m
//  kdweibo
//
//  Created by bird on 14-4-19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDCodeConfirmViewController.h"
#import "DTAttributedLabel.h"
#import "NSAttributedString+HTML.h"
#import "XTOpenConfig.h"
#import "AlgorithmHelper.h"
#import "MBProgressHUD.h"
#import "BOSConfig.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"
#import "KDWebViewController.h"
#import "KDInputView.h"

#define kCapWidth 30.f
#define kSendMinTime (int)60

@interface KDCodeConfirmViewController ()<UITextFieldDelegate, UIGestureRecognizerDelegate,MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    NSTimer *_repeatTimer;
}

@property (nonatomic, retain) DTAttributedLabel *infoLabel;

@property (nonatomic, retain) KDInputView *codeTextField;

@property (nonatomic, retain) UIButton *nextButton;

@property (nonatomic, retain) UIButton *resendCodeButton;

@property (nonatomic, assign) NSInteger sendTime;

@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, retain) XTOpenSystemClient *openClient;
//A.wang 邮箱验证
@property (nonatomic, retain) XTOpenSystemClient *emailCodeClient;
@property (nonatomic, retain) XTOpenSystemClient *verifyCodeClient;

@property (nonatomic, retain) MBProgressHUD *hud;

@property (nonatomic, retain) UILabel   *countLabel;

@property (nonatomic, retain) UIButton *buttonSMS;

@property (nonatomic, retain) MBProgressHUD *hub;

@property (nonatomic, retain) UIButton *agreeButton;

@end

@implementation KDCodeConfirmViewController
@synthesize infoLabel = _infoLabel;
@synthesize openClient = _openClient;
@synthesize delegate = _delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _sendTime = kSendMinTime;
        _fromType = 0;
    }
    return self;
}
- (void)dealloc
{
    //KD_RELEASE_SAFELY(_countLabel);
    //KD_RELEASE_SAFELY(_hud);
    //KD_RELEASE_SAFELY(_openClient);
    //KD_RELEASE_SAFELY(_timer);
    //KD_RELEASE_SAFELY(_phoneNumber);
    //KD_RELEASE_SAFELY(_infoLabel);
    //KD_RELEASE_SAFELY(_codeTextField);
    ////KD_RELEASE_SAFELY(_nextButton);
    //KD_RELEASE_SAFELY(_resendCodeButton);
    //KD_RELEASE_SAFELY(_hub);

    
    //[super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [KDWeiboAppDelegate setExtendedLayout:self];
    
    [self setTitle:ASLocalizedString(@"KDCodeConfirmViewController_input_code")];
    
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

// 接受短信验证按钮初始化
- (UIButton *)buttonSMS {
    
    if (!_buttonSMS) {
        _buttonSMS = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonSMS setTitle:ASLocalizedString(@"KDCodeConfirmViewController_tips_cannot_receive_code")forState:UIControlStateNormal];
        [_buttonSMS.titleLabel setFont:FS6];
        [_buttonSMS.titleLabel setTextColor:RGBCOLOR(23, 131, 253)];
        [_buttonSMS addTarget:self action:@selector(buttonSMSPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonSMS;
}


- (void)setUpRightBarItem{
    _nextButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDAuthViewController_next_step")];
    [_nextButton.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
//    UIImage *btnBKImage = [UIImage imageNamed:@"signon_btn_bg_v2.png"];
    _nextButton.frame = CGRectMake(0, 0, 60, 40);
//    [_nextButton setBackgroundImage:btnBKImage forState:UIControlStateNormal];
    [_nextButton setCircle];
    _nextButton.enabled = NO;
    [_nextButton addTarget:self action:@selector(doNext:) forControlEvents:UIControlEventTouchUpInside];
    
    //TODO:徐伟豪
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_nextButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];// autorelease];
    negativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,rightItem, nil];
//    [rightItem release];
}
// 接受短信验证按钮事件
- (void)buttonSMSPressed:(UIButton *)button
{

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:ASLocalizedString(@"Global_Cancel")destructiveButtonTitle:[NSString stringWithFormat:ASLocalizedString(@"KDCodeConfirmViewController_tips_send_msg"),KD_APPNAME]
                                                    otherButtonTitles:nil];
    actionSheet.tag = 100;
    [actionSheet showInView:self.view];
//    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%ld",(long)buttonIndex);

    
    if (buttonIndex == 0)
    {
        // /user/getcode method=”post”
        // phone:string
        NSString *phoneNum = [XTOpenConfig sharedConfig].longPhoneNumber;
        NSLog(@"%@",phoneNum);
        
        if (nil == self.openClient) {
            self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(smsGetCodeWithPhone:result:)];
        }
        [self.openClient smsGetCodeWithPhone:phoneNum];
    }
    else
    {
        [_buttonSMS.titleLabel setTextColor:RGBCOLOR(23, 131, 253)];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}
- (void)showLoading
{
    self.hub.hidden = NO;

    self.view.userInteractionEnabled = NO;
}

- (void)hideLoading
{
    self.hub.hidden = YES;
    self.view.userInteractionEnabled = YES;
}

- (MBProgressHUD *)hub
{
    if (!_hub)
    {
        _hub = [[MBProgressHUD alloc]initWithView:self.view];
        _hub.labelText = ASLocalizedString(@"KDCodeConfirmViewController_tips_verify");
        _hub.yOffset = -100;
        [_hub show:YES];
        [self.view addSubview:_hub];

    }
    return _hub;
}




#pragma mark 短信上行getCode回调
- (void)smsGetCodeWithPhone:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
        self.openClient = nil;
    if(result.success)
    {
        // {"success":true,"error":null,"errorCode":100,"data":null,"code":"2892","token":"8e367afd-0d7d-4583-873d-a734bc906695","smsNumber":"1069004222936900002"}
        
        NSDictionary *dict = result.dictJSON;
        NSLog(@"dict:%@",dict);
        
        if ([dict[@"success"] boolValue])
        {
            XTOpenConfig *openObj = [XTOpenConfig sharedConfig];
            openObj.smsCode = dict[@"data"][@"code"];
            openObj.smsToken = dict[@"data"][@"token"];
            openObj.smsCMNumber = dict[@"data"][@"cmAccessNumber"];
            openObj.smsCUNumber = dict[@"data"][@"cuAccessNumber"];
            openObj.smsCTNumber = dict[@"data"][@"ctAccessNumber"];

            NSLog(@"%@", openObj.smsCTNumber);
            NSLog(@"%@", openObj.smsCUNumber);
            NSLog(@"%@", openObj.smsCTNumber);
            
            // TODO: 需要验证判断为空的逻辑
            if((KD_IS_NULL_JSON_OBJ((id)openObj.smsCMNumber)) && (KD_IS_NULL_JSON_OBJ((id)openObj.smsCUNumber)) && (KD_IS_NULL_JSON_OBJ((id)openObj.smsCTNumber)))
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDCodeConfirmViewController_get_num_fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                [alert show];
//                [alert release];
                return;
            }
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];// autorelease];
            if([MFMessageComposeViewController canSendText])
            {
                controller.body = openObj.smsCode ;
                
                NSSet *mySet = [NSSet setWithArray:@[openObj.smsCMNumber,openObj.smsCUNumber,openObj.smsCTNumber ]];
                
                
                NSArray *array = mySet.allObjects;
                
                NSLog(@"%@",array);

                controller.recipients = array;
                controller.messageComposeDelegate = self;
                [self presentViewController:controller animated:YES completion:nil];
            }
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:dict[@"error"] delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
//            [alert release];
            return;
        }
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDCodeConfirmViewController_tips_retry")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];

        return;
    }
    

}

// 发送短信回调
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    switch (result)
    {
            
        case MessageComposeResultCancelled:
        {
            
        }
            break;
            
        case MessageComposeResultSent:
        {
            // 用户点击了发送,开始轮询
            [self startRepeatTimer];
            [self showLoading];
        }
            break;

        case MessageComposeResultFailed:
        {
            
        }
            break;
            
        default:
            break;
    }
}


- (void)tap
{
    [_codeTextField.textFieldMain resignFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    [self updateButtonColor];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    [self invalidateRepeatTimer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_isRegister) {
        [self.codeTextField becomeFirstResponder];
    }
    
    if (self.shouldResetTimer) {
        [self resetTimer];
    }
    
//    if(!isAboveiPhone5)
//    [self setUpRightBarItem];
    
    [self updateButtonColor];
}

- (void)setupViews
{
//    NSString *info = [NSString stringWithFormat:@"<html>\
//                      <body>\
//                      <span style='font-size:16.000000px; font-family:.Helvetica Neue Interface; line-height:1.1; text-align:center; color:#808080;'>我们已发送验证码到</span>\
//                      <span></span><span></span>\
//                      <p style='font-size:16.000000px; font-family:.Helvetica Neue Interface; line-height:1.1; text-align:center; color:#6d6d6d;'>%@</p>\
//                      </body>\
//                      </html>\
//                      ", _phoneNumber];
//    
//    
//    
//    _infoLabel = [[DTAttributedLabel alloc] init];
//    _infoLabel.attributedString = (NSAttributedString *)[[[NSAttributedString alloc] initWithHTMLData:[info dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:NULL] autorelease];
//    _infoLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *sendLabel = [[UILabel alloc]init];//a;utorelease];
    sendLabel.textColor = UIColorFromRGB(0x808080);
    
    //sendLabel.text = ASLocalizedString(@"KDCodeConfirmViewController_tips_send_suc");
    if(_isSendAllCode){
        sendLabel.text =@"验证码已发送到您的邮箱和手机";
    }else if(_fromType == 3){
        sendLabel.text =@"验证码已发送到您的手机";
    }else  if(_fromType == 4){
        sendLabel.text =@"验证码已发送到您的邮箱";
        
    }
    sendLabel.backgroundColor = [UIColor clearColor];
    sendLabel.font = [UIFont systemFontOfSize:16.f];
    sendLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *numberLabel = [[UILabel alloc]init];//autorelease];
    numberLabel.textColor = UIColorFromRGB(0x808080);
    numberLabel.backgroundColor = [UIColor clearColor];
    
    if(_isSendAllCode){
        numberLabel.text = @"";
        
    }else{
        numberLabel.text = _phoneNumber;
    }
    numberLabel.font = [UIFont systemFontOfSize:16.f];
    numberLabel.textAlignment = NSTextAlignmentCenter;

    _countLabel = [[UILabel alloc] init];
    _countLabel.textColor = FC5;
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.font = [UIFont systemFontOfSize:14.f];
    
//    UIImage *textFieldBgImage = [UIImage imageNamed:@"textfield_bg_v3.png"];
//    textFieldBgImage = [textFieldBgImage stretchableImageWithLeftCapWidth:textFieldBgImage.size.width * 0.5f topCapHeight:textFieldBgImage.size.height * 0.5f];
    
    _codeTextField = [[KDInputView alloc] initWithElement:KDInputViewElementLabelLeft];
    _codeTextField.textFieldMain.keyboardType = UIKeyboardTypeNumberPad;
    _codeTextField.textFieldMain.placeholder = ASLocalizedString(@"KDCodeConfirmViewController_tips_input_code");
//    _codeTextField.textAlignment = NSTextAlignmentCenter;
//    _codeTextField.background = textFieldBgImage;
//    _codeTextField.font = [UIFont systemFontOfSize:16.f];
    _codeTextField.textFieldMain.delegate = self;
    _codeTextField.textFieldMain.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_codeTextField.textFieldMain addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    
    
    _resendCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
    [_resendCodeButton addTarget:self action:@selector(resendCode:) forControlEvents:UIControlEventTouchUpInside];
    [_resendCodeButton setTitle:ASLocalizedString(@"KDCodeConfirmViewController_resend")forState:UIControlStateNormal];
    [_resendCodeButton setTitleColor:FC5 forState:UIControlStateNormal];
    [_resendCodeButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];

    [self enableResendBtn:NO];
    
    [self.view addSubview:self.buttonSMS];
//    self.buttonSMS.hidden = (self.fromType == 2);
    self.buttonSMS.hidden = YES;

    CGRect rect = CGRectZero;
  //  if(isAboveiOS6){
        _nextButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDAuthViewController_next_step")];
//        [_nextButton setTitle:ASLocalizedString(@"下一步")forState:UIControlStateNormal];
//        UIImage *btnBKImage = [UIImage imageNamed:@"signon_btn_bg_v2.png"];
//        [_nextButton setBackgroundImage:btnBKImage forState:UIControlStateNormal];
//        _nextButton.layer.cornerRadius = 5.0f;
//        _nextButton.layer.masksToBounds = YES;
        [_nextButton setCircle];
        _nextButton.enabled = NO;
        [_nextButton addTarget:self action:@selector(doNext:) forControlEvents:UIControlEventTouchUpInside];
        
        sendLabel.frame = CGRectMake(kCapWidth, 64.0f+30.0f, CGRectGetWidth(self.view.frame) - kCapWidth * 2.f, 17.f);
        
        numberLabel.frame = CGRectMake(kCapWidth, CGRectGetMaxY(sendLabel.frame) + 15.f, CGRectGetWidth(self.view.frame) - kCapWidth * 2.f, 17.f);
//        _infoLabel.frame = CGRectMake(kCapWidth, 30.0f, CGRectGetWidth(self.view.frame) - kCapWidth * 2.f, 45.f);
        _resendCodeButton.frame = CGRectMake(kCapWidth, CGRectGetMaxY(numberLabel.frame) + 15.f,  CGRectGetWidth(self.view.frame) - kCapWidth * 2.f, 17);
        _countLabel.frame = CGRectMake(kCapWidth, CGRectGetMaxY(numberLabel.frame) + 15.f,  CGRectGetWidth(self.view.frame) - kCapWidth * 2.f, 17);
        _codeTextField.frame = CGRectMake(kCapWidth, CGRectGetMaxY(_countLabel.frame) + 10.0f, CGRectGetWidth(self.view.frame) - kCapWidth * 2.f, 45.f);
        _buttonSMS.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - 140.f) / 2.f, CGRectGetMaxY(_codeTextField.frame) + 23.f, 140.f, 17.f);
        _nextButton.frame = CGRectMake(kCapWidth, CGRectGetMaxY(_buttonSMS.frame) + 15.0f, CGRectGetWidth(self.view.frame) - kCapWidth * 2.f, 40.f);
        [_nextButton setCircle];
        rect = _nextButton.frame;

//    }
//    else{
//
//        sendLabel.frame = CGRectMake(kCapWidth, 30.0f, CGRectGetWidth(self.view.frame) - kCapWidth * 2.f, 17.f);
//        
//        numberLabel.frame = CGRectMake(kCapWidth, CGRectGetMaxY(sendLabel.frame) + 15.f, CGRectGetWidth(self.view.frame) - kCapWidth * 2.f, 17.f);
//    
//        _countLabel.frame = CGRectMake(kCapWidth, CGRectGetMaxY(numberLabel.frame) + 15.f,  CGRectGetWidth(self.view.frame) - kCapWidth * 2.f, 17);
//        _resendCodeButton.frame = CGRectMake(kCapWidth, CGRectGetMaxY(numberLabel.frame) + 15.f,  CGRectGetWidth(self.view.frame) - kCapWidth * 2.f, 17);
//        _codeTextField.frame = CGRectMake(kCapWidth, CGRectGetMaxY(_countLabel.frame) + 13.0f, CGRectGetWidth(self.view.frame) - kCapWidth * 2.f, 45.0f);
//        _buttonSMS.frame = CGRectMake(kCapWidth, CGRectGetMaxY(_codeTextField.frame) + 23.0f, CGRectGetWidth(self.view.frame) - kCapWidth * 2.f, 17.f);
//        rect = _buttonSMS.frame;
//
//        rect.origin.y = CGRectGetMaxY(rect) +15.f;
//        rect.origin.x = 35;
//        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIImage *agreeImage = [UIImage imageNamed:@"checkbox_unchecked"];
//        UIImage *agreeImageH = [UIImage imageNamed:@"checkbox_checked"];
//        [_agreeButton addTarget:self action:@selector(agreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_agreeButton setImage:agreeImage forState:UIControlStateNormal];
//        [_agreeButton setImage:agreeImageH forState:UIControlStateSelected];
//        rect.size = CGSizeMake(16.f, 16.f);
//        _agreeButton.frame = rect;
//        [self.view addSubview:_agreeButton];
//        _agreeButton.selected = YES;
//        
//        rect.origin.x = CGRectGetMaxX(rect) +5.f;
//        rect.size.width = 100.f;
//        UILabel *label = [[[UILabel alloc] initWithFrame:rect] autorelease];
//        label.font = [UIFont systemFontOfSize:14.f];
//        label.textColor = MESSAGE_TOPIC_COLOR;
//        label.text = ASLocalizedString(@"KDCodeConfirmViewController_tips_agree");
//        [self.view addSubview:label];
//        
//        rect.origin.x = CGRectGetMaxX(rect);
//        rect.size.width = 125.f;
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button addTarget:self action:@selector(privceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [button setTitle:ASLocalizedString(@"KDCodeConfirmViewController_tips_protcol")forState:UIControlStateNormal];
//        [button setTitleColor:RGBCOLOR(23, 131, 253) forState:UIControlStateNormal];
//        button.titleLabel.font = [UIFont systemFontOfSize:13.f];
//        button.frame = rect;
//        [self.view addSubview:button];
//    }
    
//    
//    if (_isRegister && !isAboveiOS6) {
//
//        rect.origin.y = CGRectGetMaxY(rect) +15.f;
//        rect.origin.x = 35;
//        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIImage *agreeImage = [UIImage imageNamed:@"checkbox_unchecked"];
//        UIImage *agreeImageH = [UIImage imageNamed:@"checkbox_checked"];
//        [_agreeButton addTarget:self action:@selector(agreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_agreeButton setImage:agreeImage forState:UIControlStateNormal];
//        [_agreeButton setImage:agreeImageH forState:UIControlStateSelected];
//        rect.size = CGSizeMake(16.f, 16.f);
//        _agreeButton.frame = rect;
//        [self.view addSubview:_agreeButton];
//        _agreeButton.selected = YES;
//        
//        rect.origin.x = CGRectGetMaxX(rect) +5.f;
//        rect.size.width = 100.f;
//        UILabel *label = [[[UILabel alloc] initWithFrame:rect] autorelease];
//        label.font = [UIFont systemFontOfSize:14.f];
//        label.textColor = MESSAGE_TOPIC_COLOR;
//        label.text = ASLocalizedString(@"KDCodeConfirmViewController_tips_agree");
//        [self.view addSubview:label];
//        
//        rect.origin.x = CGRectGetMaxX(rect);
//        rect.size.width = 125.f;
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button addTarget:self action:@selector(privceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [button setTitle:ASLocalizedString(@"KDCodeConfirmViewController_tips_protcol")forState:UIControlStateNormal];
//        [button setTitleColor:RGBCOLOR(23, 131, 253) forState:UIControlStateNormal];
//        button.titleLabel.font = [UIFont systemFontOfSize:13.f];
//        button.frame = rect;
//        [self.view addSubview:button];
//    }
    
    [self.view addSubview:sendLabel];
    [self.view addSubview:numberLabel];
    [self.view addSubview:_countLabel];
    [self.view addSubview:_codeTextField];
    [self.view addSubview:_nextButton];
    [self.view addSubview:_resendCodeButton];
    
}

#pragma mark - Button
- (void)privceButtonClick:(id)sender{
    KDWebViewController *web = [[KDWebViewController alloc] initWithUrlString:@"http://m.kdweibo.com/18zz3yq"];// autorelease];
    web.title = [NSString stringWithFormat:ASLocalizedString(@"KDAboutViewController_tips_3"),KD_APPNAME];
    [self.navigationController pushViewController:web animated:YES];
}
- (void)agreeButtonClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected && [_codeTextField.textFieldMain.text length] >0) {
        _nextButton.enabled = YES;
    }
    else
        _nextButton.enabled = NO;
}
- (void)doNext:(UIButton *)btn
{
    if (self.codeTextField.textFieldMain.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDCodeConfirmViewController_tips_input_code")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [XTOpenConfig sharedConfig].code = self.codeTextField.textFieldMain.text;
    
    [self.codeTextField resignFirstResponder];
    
    //激活码校验
    if (_hud == nil) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    if (nil == self.openClient) {
        self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(activeDidReceived:result:)];
    }
    
    if (nil == self.verifyCodeClient) {
        self.verifyCodeClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(verifyCodeDidReceived:result:)];
    }
    
    if (_fromType == 0) {
        [self.openClient activeWithPhone:[XTOpenConfig sharedConfig].longPhoneNumber checkCode:[AlgorithmHelper des_Encrypt:[XTOpenConfig sharedConfig].code key:[XTOpenConfig sharedConfig].longPhoneNumber]];
    }
    else if (_fromType == 2)
    {
        // 更新号码
        NSString *openID = [BOSConfig sharedConfig].user.openId;
        NSString *phoneNum = [XTOpenConfig sharedConfig].longPhoneNumber;
        NSString *checkCode = [AlgorithmHelper des_Encrypt:[XTOpenConfig sharedConfig].code key:[XTOpenConfig sharedConfig].longPhoneNumber];
      
        [self.openClient updatePhoneAccountWithOpenId:openID phone:phoneNum checkCode:checkCode];

    }
    //A.wang 手机验证
    else if (_fromType == 3)
    {
             [self.verifyCodeClient verifyCheckCode:[BOSSetting sharedSetting].userName  verifyCode:[AlgorithmHelper des_Encrypt:[XTOpenConfig sharedConfig].code key:[BOSSetting sharedSetting].userName] officePhone:_phoneNumber];
    }
    //A.wang 邮箱验证
    else if (_fromType == 4)
    {
        [self.verifyCodeClient verifyCheckCode:[BOSSetting sharedSetting].userName  verifyCode:[AlgorithmHelper des_Encrypt:[XTOpenConfig sharedConfig].code key:[BOSSetting sharedSetting].userName] officePhone:nil];
        
    }
    else
    {
        [self.openClient verifyCodeWithPhone:[XTOpenConfig sharedConfig].longPhoneNumber checkCode:[AlgorithmHelper des_Encrypt:[XTOpenConfig sharedConfig].code key:[XTOpenConfig sharedConfig].longPhoneNumber] openId:[BOSConfig sharedConfig].user.openId];
    }
}


/**
 *  不论是上行验证, 还是验证码验证, 最终调用同一个成功逻辑
 */
- (void)onSuccess
{
    if (_fromType == 0)
    {
        KDPwdConfirmViewController *ctr = [[KDPwdConfirmViewController alloc] init];
        ctr.delegate = _delegate;
        ctr.isRegister = self.isRegister;
        ctr.pwdType = KDPwdInputTypePwdSetting;
        [self.navigationController pushViewController:ctr animated:YES];
//        [ctr release];
    }
    else if (_fromType == 2)
    {
        [KDEventAnalysis event:event_settings_personal_mobile_ok];
        if (_delegate && [_delegate respondsToSelector:@selector(authViewConfirmPwd)])
        {
            [BOSConfig sharedConfig].user.phone = [XTOpenConfig sharedConfig].longPhoneNumber;
            [[BOSConfig sharedConfig] saveConfig];
            [_delegate authViewConfirmPwd];
        }
    }
     //A.wang 邮箱验证
    else if ( _fromType == 3 || _fromType == 4)
    {
        KDPwdConfirmViewController *ctr = [[KDPwdConfirmViewController alloc] init];
        ctr.delegate = _delegate;
        ctr.isRegister = NO;
        ctr.pwdType = KDPwdInputTypePwdConfirm;
        [self.navigationController pushViewController:ctr animated:YES];
        //        [ctr release];
    }
    else
    {
        if (_delegate && [_delegate respondsToSelector:@selector(authViewConfirmPwd)])
        {
            [BOSConfig sharedConfig].user.phone = [XTOpenConfig sharedConfig].longPhoneNumber;
            [[BOSConfig sharedConfig] saveConfig];
            [_delegate authViewConfirmPwd];
        }
    }
    
    self.shouldResetTimer = NO;
    self.codeTextField.textFieldMain.text = @"";
    [self enableResendBtn:YES];
}

- (void)activeDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
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
        [self.codeTextField becomeFirstResponder];
        
        return;
    }
    
    self.openClient = nil;
    
    if (result.success)
    {
        [self onSuccess];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
    [self.codeTextField becomeFirstResponder];
}

//A.wang 邮箱验证
- (void)verifyCodeDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (_hud) {
        [_hud hide:YES];
        self.hud = nil;
    }
    
    if (client.hasError || !result.success || ![result isKindOfClass:[BOSResultDataModel class]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
        
        self.verifyCodeClient = nil;
        [self.codeTextField becomeFirstResponder];
        
        return;
    }
    
    self.verifyCodeClient = nil;
    
    if (result.success)
    {
        [self onSuccess];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
    [self.codeTextField becomeFirstResponder];
}


- (void)enableResendBtn:(BOOL)enable
{
//    self.resendCodeButton.enabled = enable;
    self.resendCodeButton.hidden = !enable;
    self.countLabel.hidden = enable;
    if (!enable) {
        [_countLabel setText:[NSString stringWithFormat:ASLocalizedString(@"KDCodeConfirmViewController_tips_sec"),(long)_sendTime]];
    }
}
- (void)resendCode:(id)sender
{
    [self.codeTextField resignFirstResponder];
    
    //重新获取验证码
    if (_hud == nil) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    if (nil == self.openClient) {
        self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(reactiveDidReceived:result:)];
    }
    if (nil == self.emailCodeClient) {
        self.emailCodeClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(emailCodeDidReceived:result:)];
    }
    if (_fromType == 1) {
        
        [self.openClient fetchCodeWithPhone:[XTOpenConfig sharedConfig].longPhoneNumber openId:[BOSConfig sharedConfig].user.openId];
    }
    else if (_fromType == 2)
    {
        [self.openClient fetchCodeWithPhone:[XTOpenConfig sharedConfig].longPhoneNumber openId:[BOSConfig sharedConfig].user.openId];
    }
    else if (_fromType == 3)
    {
        [self.emailCodeClient sendEmail:[BOSSetting sharedSetting].userName officePhone:_phoneNumber];
    }
    else if (_fromType == 4)
    {
        [self.emailCodeClient sendEmail:[BOSSetting sharedSetting].userName officePhone:nil];
    }
    else
    {
        [self.openClient getCodeWithPhone:[XTOpenConfig sharedConfig].longPhoneNumber];
    }
    
}
- (void)reactiveDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (_hud) {
        [_hud hide:YES];
        self.hud = nil;
    }
    
    [self.codeTextField becomeFirstResponder];
    
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
        [self resetTimer];
        
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
}
//A.wang 邮箱验证
- (void)emailCodeDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (_hud) {
        [_hud hide:YES];
        self.hud = nil;
    }
    
    [self.codeTextField becomeFirstResponder];
    
    if (client.hasError || !result.success || ![result isKindOfClass:[BOSResultDataModel class]]) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
        
        self.emailCodeClient = nil;
        
        return;
    }
    
    self.emailCodeClient = nil;
    if (result.success)
    {
        [self resetTimer];
        
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
}

- (void)resetTimer
{
    _sendTime = kSendMinTime;
    NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
    self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(timerSchedule) userInfo:nil repeats:YES];
    [myRunLoop addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)timerSchedule
{
    _sendTime--;
    if (_sendTime > 0) {
        [self enableResendBtn:NO];
    }else {
        [self enableResendBtn:YES];
        [self.timer invalidate];
        
        [_countLabel setText:ASLocalizedString(@"KDCodeConfirmViewController_click_resend")];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textChanged:(UITextField *)textField
{
    _nextButton.enabled = textField.text.length > 0;
//    if (_isRegister && _nextButton.enabled) {
//        _nextButton.enabled = _agreeButton.selected;
//    }
    
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ([touch.view isKindOfClass:[UIButton class]]) ? NO : YES;;
}

#pragma mark - 短信上行轮询

// 什么时候invalidate轮询
- (void)invalidateRepeatTimer
{
    if(_repeatTimer != nil)
    {
        [_repeatTimer invalidate];
        _repeatTimer = nil;
    }
}

// 什么时候start轮询
- (void)startRepeatTimer
{
    if(_repeatTimer == nil)
    {
        [self startRequestSmsValiCheckCode];
        _repeatTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(repeatTimerFire:)
                                                      userInfo:nil repeats:YES];
    }
}

- (void)repeatTimerFire:(NSTimer *)timer
{
    [self startRequestSmsValiCheckCode];
}

- (void)startRequestSmsValiCheckCode
{
    XTOpenConfig *openObj = [XTOpenConfig sharedConfig];
    NSString *phoneNum = openObj.longPhoneNumber;
    NSString *token = openObj.smsToken;
    
    if (nil == self.openClient) {
        self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(smsValiCheckCodeWithPhone:result:)];
    }
    [self.openClient smsValiCheckCodeWithPhone:phoneNum token:token];
}

// 轮询回调
#define SMS_REGISER_SUCC_ALERT_VIEW_TAG 9999
- (void)smsValiCheckCodeWithPhone:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if(result.success)
    {

        NSDictionary *dict = result.dictJSON;
        NSLog(@"dict:%@",dict);

        if ([dict[@"data"][@"message"] boolValue])
        {
            [self invalidateRepeatTimer];
            if (_fromType == 2) {
                [KDEventAnalysis event:event_settings_personal_mobile_ok];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDCodeConfirmViewController_verify_suc")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            alert.tag = SMS_REGISER_SUCC_ALERT_VIEW_TAG;
            [alert show];
//            [alert release];
            
            [self hideLoading];
        }
        else
        {

        }
    }
    else
    {

    }
    
    self.openClient = nil;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == SMS_REGISER_SUCC_ALERT_VIEW_TAG)
    {
        [self onSuccess];
    }
}


- (void)updateButtonColor
{
    [_buttonSMS.titleLabel setTextColor:RGBCOLOR(23, 131, 253)];
}
@end
