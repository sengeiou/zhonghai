//
//  KDAuthViewController.m
//  kdweibo
//
//

#import "KDCommon.h"
#import <QuartzCore/QuartzCore.h>

#import "KDAuthViewController.h"

#import "KDActivityIndicatorView.h"

#import "KDUser.h"
#import "KDLoggedInUser.h"

#import "KDWeiboAppDelegate.h"

#import "BOSLogger.h"
#import "BOSImageNames.h"
#import "BOSFileManager.h"
#import "MCloudClient.h"
#import "EMPServerClient.h"
#import "BOSPublicConfig.h"
#import "AuthDataModel.h"
#import "LoginDataModel.h"
#import "DemoAccountDataModel.h"
#import "InstructionsDataModel.h"
#import "CustomerPublicKeyDataModel.h"
#import "ValidateDataModel.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomerLogoDownloadService.h"
#import "SignTOSViewController.h"
#import "BOSUtils.h"
#import "BOSConfig.h"
#import "XTSetting.h"
//#import "KeyExpiredHandler.h"
#import "AlgorithmHelper.h"
#import "KDWeiboLoginService.h"
#import "XTOpenConfig.h"
#import "XTCompanyDelegate.h"
#import "KDCreateTeamViewController.h"
#import "KDPwdConfirmViewController.h"
#import "KDCodeConfirmViewController.h"
#import "KDPhoneInputViewController.h"
#import "KDCompanyChoseViewController.h"
#import "KDBindEmailViewController.h"
#import "KDDBManager.h"
#import "KDLinkInviteConfig.h"
#import "KDWeiboServicesContext.h"
#import "KDJoinWorkGroupViewController.h"
#import "NSStringAdditions.h"
#import "KDParamFetchManager.h"

#import "KDMainUserDataModel.h"
////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDAuthViewController class

#define KD_SIGNIN_VIEW_FONTSIZE  (15.0f)
#define kConfigLoginUserCode @"loginUserCode"

@interface KDAuthViewController () <UIGestureRecognizerDelegate, UIActionSheetDelegate, SignTOSDelegate, XTCompanyDelegate, KDLoginPwdConfirmDelegate, KDBindEmailViewControllerDelegate, KDLinkInviteDelegate, KDJoinWorkGroupViewControllerDelegate>

@property (nonatomic, retain) UIImageView *avatarView;
@property (nonatomic, retain) KDInputView *userNameTextField;
@property (nonatomic, retain) KDInputView *passwordTextField;
@property (nonatomic, retain) UIButton    *signInBtn;
@property (nonatomic, retain) UIButton    *forgetPasswordBtn;
@property (nonatomic, retain) UIButton    *signUpBtn;
@property (nonatomic, retain) UIButton    *opBtn;
@property (nonatomic, retain) UIView      *contentView;
@property (nonatomic, retain) UILabel     *nameLabel;

@property(nonatomic, retain) UIView *userListMaskView;
@property(nonatomic, retain) UITableView *tableView;
@property(nonatomic, retain) KDActivityIndicatorView *activityView;
@property(nonatomic, retain) UIView *blockView;

@property(nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic, retain) NSMutableArray *userList;
@property(nonatomic, retain) UINavigationController *verifyNav;
@property(nonatomic, retain) UILabel    *phoneLable;

@property(nonatomic, retain) BOSResultDataModel *finishResultModel;
@property(nonatomic, retain) UIView *invitedView;
@property (nonatomic, assign) BOOL isCheckBox;  //是否有用户使用协议
@property (nonatomic, assign) BOOL isHideSMSVerify;  //是否关闭短信验证密码
@property (nonatomic, assign) BOOL isChangeSecureText;

@property (nonatomic, retain) NSString *officePhone;
@property (nonatomic, retain) NSString *officeEmail;
@property (nonatomic, assign) BOOL isSendAllCode;  //是否邮箱手机号都发送验证码

- (BOOL)hasLoggedInUsers;
- (void)showLoggedInUsernameList:(UIButton *)btn;

@end

@implementation KDAuthViewController

@synthesize avatarView = avatarView_;
@synthesize userNameTextField = userNameTextField_;
@synthesize passwordTextField = passwordTextField_;
@synthesize signInBtn = signInBtn_;
@synthesize signUpBtn = signUpBtn_;
@synthesize opBtn = opBtn_;
@synthesize forgetPasswordBtn = forgetPasswordBtn_;
@synthesize contentView = contentView_;
@synthesize userListMaskView=userListMaskView_;
@synthesize tableView=tableView_;
@synthesize activityView=activityView_;
@synthesize blockView=blockView_;

@synthesize tapGestureRecognizer=tapGestureRecognizer_;

@synthesize userList=userList_;
@synthesize openClient = openClient_;
@synthesize delegate = delegate_;
@synthesize verifyNav = verifyNav_;
@synthesize nameLabel = nameLabel_;

- (id)initWithLoginViewType:(KDLoginViewType)type
{
    loginType_ = type;
    
    return [self init];
}

- (id)init {
    self = [super init];
    if (self) {
        
        if (loginType_ == KDLoginViewTypeUndefine)
            loginType_ = KDLoginViewTypePhoneNumInput;
        
        self.delegate = [XTOpenConfig sharedConfig].loginDelegate;
        
        isPickedUser_ = NO;
        
        authViewControllerFlags_.initialized = 0;
        authViewControllerFlags_.disableInputFieldsAnimation = 0;
        authViewControllerFlags_.signedUsersPickerVisible = 0;
        authViewControllerFlags_.shouldShowKeyBoard = 0;
        activityVisible_ = NO;
        self.isChangeSecureText = NO;
        
        self.navigationItem.title = NSLocalizedString(@"KDWEIBO", @"");
        
        // load logged in users from cache
        [self retrieveLoggedInUsers];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}
- (UIView *)invitedView{
    
    if (_invitedView) {
        return _invitedView;
    }
    
    CGRect rect = self.contentView.bounds;
    rect.size.height = CGRectGetMinY(userNameTextField_.frame);
    
    UIView *invitedView = [[UIView alloc] initWithFrame:rect];
    invitedView.backgroundColor = [UIColor clearColor];
    
    UIImage *eimg = [UIImage imageNamed:@"invite_img_letterpic"];
    UIImageView *eImageView = [[UIImageView alloc] initWithImage:eimg];
    [eImageView sizeToFit];
    [invitedView addSubview:eImageView];
    
    if (_invitedView.superview == nil) {
        [self.contentView addSubview:invitedView];
    }
    self.invitedView = invitedView ;//autorelease];
    
    rect = avatarView_.frame;
    CGSize size = CGSizeMake(rect.size.width*0.75, rect.size.height*0.75);
    rect.origin.x += (rect.size.width - size.width)*0.5f;
    rect.origin.y += (rect.size.height - size.height)*0.5f;
    rect.size = size;
    avatarView_.frame = rect;
    
    rect = [self.contentView convertRect:avatarView_.frame toView:_invitedView];
    
    eImageView.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    UILabel *invitedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(eImageView.frame) + 5, self.view.bounds.size.width, 21.f)] ;//autorelease];
    invitedLabel.tag = 0x99;
    invitedLabel.backgroundColor = [UIColor clearColor];
    invitedLabel.textColor = [UIColor whiteColor];
    invitedLabel.textAlignment = NSTextAlignmentCenter;
    invitedLabel.font = [UIFont systemFontOfSize:14.f];
    [invitedView addSubview:invitedLabel];
    
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(invitedLabel.frame), self.view.bounds.size.width, 30.f)];// autorelease];
    companyLabel.tag = 0x98;
    companyLabel.backgroundColor = [UIColor clearColor];
    companyLabel.textColor = [UIColor whiteColor];
    companyLabel.textAlignment = NSTextAlignmentCenter;
    companyLabel.font = [UIFont boldSystemFontOfSize:15.f];
    [invitedView addSubview:companyLabel];
    
    return invitedView;
}
- (void)startLoadingInvitedInfo{
    
    if (!self.invitedView) {
        return;
    }
    
    [self.contentView bringSubviewToFront:self.avatarView];
    [self.avatarView setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"login_tip_logo"]];
    //[self.avatarView rotate];
    
    nameLabel_.hidden = YES;
}
- (void)endLoadingInvitedInfo{
    
    //[self.avatarView stopRotate];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    [self _setupContentView];
    
    // tap gesture recongnizer
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_didTapOnTemplateView:)];
    self.tapGestureRecognizer = tapGestureRecognizer;
//    [tapGestureRecognizer release];
    
    tapGestureRecognizer_.delegate = self;
    tapGestureRecognizer_.enabled = NO;
    tapGestureRecognizer_.numberOfTapsRequired = 1;
    
    [self.contentView addGestureRecognizer:tapGestureRecognizer_];
    
    if ([[KDLinkInviteConfig sharedInstance] isExistInvite]) {
        [[KDLinkInviteConfig sharedInstance] goToInviteFormType:Invite_From_Launched];
    }
}

- (void)_setupContentView {
    //    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    //    bgImageView.image = [UIImage imageNamed:@"login_bg_v3"];
    //    [self.view addSubview:bgImageView];
    //    [bgImageView release];
    
    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds] ;//autorelease];
    [self.view addSubview:self.contentView];
    
    
    CGFloat offsetY = 42.0f;
    if([UIScreen mainScreen].bounds.size.height > 480) {
        offsetY = 80.0f;
    }
    
    //用户头像
    CGSize avatarSize = CGSizeMake(80.0f, 80.0f);
    self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds) - avatarSize.width) * 0.5f, offsetY, avatarSize.width, avatarSize.height)];// autorelease];
    self.avatarView.layer.cornerRadius=(ImageViewCornerRadius==-1?(CGRectGetHeight(self.avatarView.frame)/2):ImageViewCornerRadius);
    self.avatarView.layer.masksToBounds = YES;
    //[self.avatarView stopRotate];
    [self.contentView addSubview:self.avatarView];
    
    [self.avatarView setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"login_tip_logo"]];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(avatarView_.frame)+18, self.view.bounds.size.width, 30.f)] ;//autorelease];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textColor = FC5;
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.nameLabel];
    self.nameLabel.hidden = loginType_ != KDLoginViewTypePhoneLoginPwd;
    self.nameLabel.text = KD_APPNAME;
    if (loginType_ == KDLoginViewTypePhoneLoginPwd) {
        self.nameLabel.text = [BOSConfig sharedConfig].user.name;//[BOSSetting sharedSetting].userName;
    }
    
    //账号输入框
    NSString *inputFieldTitle = ASLocalizedString(@"KDAuthViewController_login_with_account");
    if (loginType_ == KDLoginViewTypeEmailInput)
        inputFieldTitle = ASLocalizedString(@"KDAuthViewController_email");
    
    self.userNameTextField = [self _textFieldWithTitle:nil andPlaceHolder:inputFieldTitle dropDownImageName:([self hasLoggedInUsers] ? @"login_input_drop_down_v6" : nil)];
    userNameTextField_.frame = CGRectMake(ScreenFullWidth*0.1, CGRectGetMaxY(avatarView_.frame) + 63.5f, ScreenFullWidth*0.8, 43.0f);
    if (loginType_ == KDLoginViewTypePhoneNumInput)
        userNameTextField_.textFieldMain.keyboardType = UIKeyboardTypeDefault;
    else
        userNameTextField_.textFieldMain.keyboardType = UIKeyboardTypeDefault;
    userNameTextField_.imageViewLeft.image = [UIImage imageNamed:@"login_tip_account"];
    
    if (loginType_ == KDLoginViewTypeEmailInput)
        self.userNameTextField.textFieldMain.returnKeyType = UIReturnKeyNext;
    
    if (userNameTextField_ && !userNameTextField_.hidden && loginType_ == KDLoginViewTypePhoneNumInput)
        userNameTextField_.textFieldMain.text = [BOSSetting sharedSetting].userName;
        
        
    [self.contentView addSubview:userNameTextField_];
    
    UIButton *dropDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"login_input_drop_down_v6"];
    dropDownBtn.frame = CGRectMake(0.0, 0.0, 30.0f, 43.0f);
    dropDownBtn.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 7.0f);
    [dropDownBtn setImage:image forState:UIControlStateNormal];
    [dropDownBtn addTarget:self action:@selector(showLoggedInUsernameList:) forControlEvents:UIControlEventTouchUpInside];
    userNameTextField_.textFieldMain.rightView = dropDownBtn;
    userNameTextField_.textFieldMain.rightViewMode = UITextFieldViewModeAlways;
    
    
    //为了让“+86”和提示水平对齐，在iOS7下，数字的显示有点偏上，故增加一个像素的偏移。/
    self.phoneLable = [[UILabel alloc] initWithFrame:CGRectMake(12, 1.0f , 30, 43.0f)];// autorelease];
    self.phoneLable.backgroundColor = [UIColor clearColor];
    self.phoneLable.textColor = [UIColor whiteColor];
    self.phoneLable.textAlignment = NSTextAlignmentCenter;
    //    [self.userNameTextField addSubview:self.phoneLable];
    self.phoneLable.text = @"+86";
    //    self.phoneLable.hidden = loginType_ != KDLoginViewTypePhoneNumInput;
    self.phoneLable.hidden = YES;
    
    userNameTextField_.hidden =  loginType_ != KDLoginViewTypePhoneNumInput && loginType_ != KDLoginViewTypeEmailInput;
    
    self.passwordTextField = [self setupPasswordTextField];//[self _textFieldWithTitle:nil andPlaceHolder:ASLocalizedString(@"KDAuthViewController_psw")dropDownImageName:nil];
    passwordTextField_.frame = CGRectMake(CGRectGetMinX(userNameTextField_.frame), userNameTextField_.hidden?CGRectGetMinY(userNameTextField_.frame):(CGRectGetMaxY(userNameTextField_.frame) + 2.0f), CGRectGetWidth(userNameTextField_.frame), CGRectGetHeight(userNameTextField_.frame));
    [self.contentView addSubview:passwordTextField_];
    
    passwordTextField_.hidden = loginType_ == KDLoginViewTypePhoneNumInput;
    
    NSString *signTitle = ASLocalizedString(@"KDAuthViewController_login");
    if (loginType_ == KDLoginViewTypePhoneNumInput)
        signTitle = ASLocalizedString(@"KDAuthViewController_next_step");
    
    self.signInBtn = [UIButton blueBtnWithTitle:signTitle];
    signInBtn_.backgroundColor = FC5;
    signUpBtn_.titleLabel.font = [UIFont systemFontOfSize:KD_SIGNIN_VIEW_FONTSIZE];
    [signInBtn_ addTarget:self action:@selector(signIn) forControlEvents:UIControlEventTouchUpInside];
    signInBtn_.frame = CGRectMake(CGRectGetMinX(userNameTextField_.frame), CGRectGetMaxY(loginType_ == KDLoginViewTypePhoneNumInput?userNameTextField_.frame:passwordTextField_.frame) + 32.0f, CGRectGetWidth(userNameTextField_.frame), CGRectGetHeight(userNameTextField_.frame));
    [signInBtn_ setCircle];
    [self.contentView addSubview:signInBtn_];
    
    self.forgetPasswordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgetPasswordBtn_ setTitleColor:FC2 forState:UIControlStateNormal];
    [forgetPasswordBtn_ setTitle:ASLocalizedString(@"KDAuthViewController_forget_psw")forState:UIControlStateNormal];
    [forgetPasswordBtn_ addTarget:self action:@selector(findPassword) forControlEvents:UIControlEventTouchUpInside];
    forgetPasswordBtn_.titleLabel.font = FS5;
    signUpBtn_.titleLabel.textAlignment = NSTextAlignmentLeft;
    CGFloat width = 80.f;
    CGFloat signUpBtnWidth = 85.f;
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:AppLanguage]isEqualToString:@"en"]) {
        width = 120.f;
        signUpBtnWidth = 140.f;
    }
    forgetPasswordBtn_.frame = CGRectMake(CGRectGetMinX(userNameTextField_.frame)-10, CGRectGetMaxY(signInBtn_.frame) + 14.0f, width, 22.0f);
   [self.contentView addSubview:forgetPasswordBtn_];
    
    self.signUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [signUpBtn_ setTitleColor:FC2 forState:UIControlStateNormal];
    [signUpBtn_ setTitle:ASLocalizedString(@"KDAuthViewController_change_account")forState:UIControlStateNormal];
    self.signUpBtn.backgroundColor = [UIColor clearColor];
    [signUpBtn_ addTarget:self action:@selector(opClick) forControlEvents:UIControlEventTouchUpInside];
    signUpBtn_.titleLabel.font = FS5;
    signUpBtn_.titleLabel.textAlignment = NSTextAlignmentRight;
    signUpBtn_.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - signUpBtnWidth - CGRectGetMinX(userNameTextField_.frame), CGRectGetMinY(forgetPasswordBtn_.frame), signUpBtnWidth, 22.0f);
    [self.contentView addSubview:signUpBtn_];
    
    UILabel *logoLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenFullWidth / 2 - 150, ScreenFullHeight - 60, 300, 30)];
    logoLabel.textAlignment = NSTextAlignmentCenter;
    logoLabel.text = ASLocalizedString(@"KDAuthViewController_tips_logo");
    logoLabel.textColor = FC3;
    logoLabel.font = FS4;
    [self.contentView addSubview:logoLabel];
    
    signUpBtn_.hidden = loginType_ != KDLoginViewTypePhoneLoginPwd;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isHideSMSVerify"] || loginType_ != KDLoginViewTypePhoneLoginPwd ) {
        forgetPasswordBtn_.hidden = YES;
    }else
    {
        forgetPasswordBtn_.hidden = NO;
    }
    
    
    
    NSString *opTitle = ASLocalizedString(@"Global_GoBack");
    switch (loginType_) {
        case KDLoginViewTypeEmailInput:
            opTitle = ASLocalizedString(@"KDAuthViewController_login_with_mobilephone");
            break;
        case KDLoginViewTypePhoneLoginPwd:
            break;
        case KDLoginViewTypePwdInput:
            break;
        case KDLoginViewTypePhoneNumInput:
            opTitle = ASLocalizedString(@"KDAuthViewController_login_with_other");
            break;
        default:
            break;
    }
    
    self.opBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [opBtn_ setTintColor:[UIColor whiteColor]];
    [opBtn_ addTarget:self action:@selector(opClick) forControlEvents:UIControlEventTouchUpInside];
    opBtn_.titleLabel.font = [UIFont systemFontOfSize:KD_SIGNIN_VIEW_FONTSIZE];
    [opBtn_ setTitle:opTitle forState:UIControlStateNormal];
    
    [opBtn_ setFrame:CGRectMake(0, 0, 150, 25)];
    opBtn_.center = CGPointMake(signInBtn_.center.x, self.view.frame.size.height - 45);
    [self.contentView addSubview:opBtn_];
    
    //    opBtn_.hidden = loginType_ == KDLoginViewTypePhoneLoginPwd || loginType_ == KDLoginViewTypePwdInput;
    //屏蔽首页其他方式登陆
    opBtn_.hidden = YES;
}

- (KDInputView *)_textFieldWithTitle:(NSString *)title andPlaceHolder:(NSString *)ph dropDownImageName:(NSString *)dropDownImageName {
    KDInputView *textField = [[KDInputView alloc] initWithElement:KDInputViewElementImageViewLeft];
    //textField.textFieldMain.borderStyle = UITextBorderStyleNone;
    //textField.textFieldMain.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //textField.textFieldMain.backgroundColor = RGBACOLOR(255, 255, 255, 0.3f);
    //textField.textFieldMain.font = [UIFont systemFontOfSize:KD_SIGNIN_VIEW_FONTSIZE];
    //textField.textFieldMain.layer.cornerRadius = 5.0f;
    textField.textFieldMain.delegate = self;
    //textField.textFieldMain.layer.masksToBounds = YES;
    
    textField.textFieldMain.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.textFieldMain.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.textFieldMain.returnKeyType = UIReturnKeyDone;
    textField.textFieldMain.keyboardType = UIKeyboardTypeASCIICapable;
    //textField.textFieldMain.textColor = [UIColor whiteColor];
    
    textField.textFieldMain.placeholder = ph;
    
    //left view
    CGFloat width = 255.f;
    if ([title length]<3)
        width = 45;
    else
    {
        
    }
    //    UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 43.0f)];
    //    left.backgroundColor = [UIColor clearColor];
    //    if([title length] < 3) {
    //        left.textColor = [UIColor whiteColor];
    //    }else {
    //        left.textColor = RGBCOLOR(0xdd, 0xdd, 0xdd);
    //    }
    //    left.text = title;
    //    left.font = [UIFont systemFontOfSize:KD_SIGNIN_VIEW_FONTSIZE];
    //    left.textAlignment = NSTextAlignmentCenter;
    //    textField.textFieldMain.leftView = left;
    //    [left release];
    //
    //    textField.textFieldMain.leftViewMode = UITextFieldViewModeAlways;
    
    // right view
    //    if (dropDownImageName != nil) {
    //        UIButton *dropDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //        UIImage *image = [UIImage imageNamed:dropDownImageName];
    //
    //        dropDownBtn.frame = CGRectMake(0.0, 0.0, 30.0f, 43.0f);
    //        dropDownBtn.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 7.0f);
    //        [dropDownBtn setImage:image forState:UIControlStateNormal];
    //
    //        [dropDownBtn addTarget:self action:@selector(showLoggedInUsernameList:) forControlEvents:UIControlEventTouchUpInside];
    //        textField.textFieldMain.rightView = dropDownBtn;
    //        textField.textFieldMain.rightViewMode = UITextFieldViewModeAlways;
    //
    //    } else {
    //        textField.textFieldMain.clearButtonMode = UITextFieldViewModeWhileEditing;
    //    }
    //
    //	textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    return textField;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    authViewControllerFlags_.navigationBarHidden = self.navigationController.navigationBarHidden ? 1 : 0;
    self.navigationController.navigationBarHidden = YES;
    
   
}

- (void)setHidePwd:(BOOL)hidePwd
{
     if (hidePwd) {
            forgetPasswordBtn_.hidden = YES;
        }else
        {
            forgetPasswordBtn_.hidden = NO;
        }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(authViewControllerFlags_.initialized == 0){
        authViewControllerFlags_.initialized = 1;
    }
    
    if (authViewControllerFlags_.shouldShowKeyBoard == 1 && [userNameTextField_ canBecomeFirstResponder]) {
        authViewControllerFlags_.shouldShowKeyBoard = 0;
        
        if (loginType_ == KDLoginViewTypePhoneNumInput || loginType_ == KDLoginViewTypeEmailInput)
            [userNameTextField_ becomeFirstResponder];
        else
            [passwordTextField_ becomeFirstResponder];
    }
    
    if (loginType_ == KDLoginViewTypePhoneLoginPwd){
        
        NSString *url = [self fetchLoggedInUserAvatarURLWithUserName:[BOSSetting sharedSetting].userName];
        if(url && url.length > 0) {
            [self.avatarView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"login_tip_logo"]];
        }
    }
    
    //    if ([[KDLinkInviteConfig sharedInstance] isExistInvite] && [[KDLinkInviteConfig sharedInstance] presented] && [[KDLinkInviteConfig sharedInstance] code] == LinkInviteErrorCode_Undefine) {
    //        [[KDLinkInviteConfig sharedInstance] cancelInvite];
    //
    //    }
}

- (BOOL)hasLoggedInUsers {
    return userList_ != nil && [userList_ count] > 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - button event
- (void)signIn
{
    // TEST ONLY 跳过验证码,直接进入输入验证码页面
    
    //    [XTOpenConfig sharedConfig].countryCode = @"+86";
    //    [XTOpenConfig sharedConfig].phoneNumber = @"18689223351";
    //    [self gotoCodeConfirmView];
    //    return;
    ////////////////////////////////
    if (loginType_ == KDLoginViewTypePhoneNumInput) {
        
        [self startCheckLoginPhoneNumber];
    }
    else
    {
        if (loginType_ == KDLoginViewTypePwdInput) {
            
            [self startCheckPwdInput];
        }
        else if(loginType_ == KDLoginViewTypeEmailInput)
        {
            [self startCheckEmailInput];
        }
        else if(loginType_ == KDLoginViewTypePhoneLoginPwd)
        {
            [self startCheckLoginPwd];
        }
    }
}
- (void)signUp
{
    [userNameTextField_ resignFirstResponder];
    [passwordTextField_ resignFirstResponder];
    
    [self gotoRegisterView];
}
- (void)opClick
{
    if (loginType_ == KDLoginViewTypePwdInput) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    KDLoginViewType type = KDLoginViewTypeEmailInput;
    switch (loginType_) {
        case KDLoginViewTypeEmailInput:
            type = KDLoginViewTypePhoneNumInput;
            break;
        case KDLoginViewTypePhoneLoginPwd:
            type = KDLoginViewTypePhoneNumInput;
            break;
        case KDLoginViewTypePwdInput:
            break;
        case KDLoginViewTypePhoneNumInput:
            type = KDLoginViewTypeEmailInput;
            break;
        default:
            break;
    }
    
    [[KDWeiboAppDelegate getAppDelegate] showLoginViewController:type];
}
#pragma mark -
#pragma mark UITableView delegate and data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [userList_ count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentify = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentify];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentify];// autorelease];
        
        cell.textLabel.font = [UIFont systemFontOfSize:KD_SIGNIN_VIEW_FONTSIZE];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];//RGBACOLOR(255, 255, 255, 0.5f);
        
        //cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        UIView *selectView = [[UIView alloc] initWithFrame:cell.bounds];;
        selectView.backgroundColor =  UIColorFromRGB(0xe1e6e9);
        cell.selectedBackgroundView = selectView;
//        [selectView release];
        
        // accessory view
        UIImage *bgImage = [UIImage imageNamed:@"gray_circle_remove.png"];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0.0, 0.0, bgImage.size.width, bgImage.size.height+14.0);
        
        //btn.imageEdgeInsets = UIEdgeInsetsMake(7.0, 11.0, 7.0, 4.0);
        [btn setImage:bgImage forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(removeLoggedInUser:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = btn;
    }
    
    KDLoggedInUser *loggedInUser = [userList_ objectAtIndex:indexPath.row];
    cell.textLabel.text = loggedInUser.identifier;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self hasLoggedInUsers]) {
        isPickedUser_ = YES;
        
        KDLoggedInUser *loggedInUser = [userList_ objectAtIndex:indexPath.row];
        [self textFieldShouldBeginEditing:userNameTextField_.textFieldMain];
        userNameTextField_.textFieldMain.text = loggedInUser.identifier;
        [self textFieldShouldEndEditing:userNameTextField_.textFieldMain];
        [self _loadAvatar];
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self loggedInUserPicker:NO anchorRect:CGRectZero];
    }
}


////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITextField delegate and data source methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UILabel *leftView = (UILabel *)textField.leftView;
    
    leftView.frame = CGRectMake(0.0f, 0.0f, 15.0f, 43.0f);
    if (loginType_ == KDLoginViewTypePhoneNumInput)
        leftView.frame = CGRectMake(0.0f, 0.0f, 15.0f, 0.0f);
    leftView.text = @"";
    
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField.text length] == 0) {
        UILabel *leftView = (UILabel *)textField.leftView;
        if (textField == userNameTextField_.textFieldMain)
        {
            leftView.frame = CGRectMake(0.0f, 0.0f, 255.0f, 43.0f);
            NSString *inputFieldTitle = ASLocalizedString(@"KDAuthViewController_login_with_many");
            if (loginType_ == KDLoginViewTypeEmailInput)
            {
                inputFieldTitle = ASLocalizedString(@"KDAuthViewController_email");
                leftView.frame = CGRectMake(0.0f, 0.0f, 45.f, 43.0f);
            }
            
            leftView.text = inputFieldTitle;
        }
        
        else if(textField == passwordTextField_.textFieldMain)
        {
            leftView.text = ASLocalizedString(@"KDAuthViewController_psw");
            leftView.frame = CGRectMake(0.0f, 0.0f, 45.f, 43.0f);
        }
        
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == userNameTextField_.textFieldMain){
        
        if (!passwordTextField_.hidden) {
            
            if([passwordTextField_ canBecomeFirstResponder]) {
                [passwordTextField_ becomeFirstResponder];
            }
        }
        else
            [textField resignFirstResponder];
        
        
    }else {
        [textField resignFirstResponder];
        
        /*
         */
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //明文切换密文后避免被清空
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (range.location != 0 && self.isChangeSecureText && textField == passwordTextField_.textFieldMain && passwordTextField_.textFieldMain.isSecureTextEntry) {
        textField.text = toBeString;
        return NO;
    }
    
    if(textField == userNameTextField_.textFieldMain) {
        NSMutableString *text = [NSMutableString stringWithString:textField.text];
        [text replaceCharactersInRange:range withString:string];
        
        if(text.length > 0) {
            [self _loadAvatar];
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.isChangeSecureText = NO;
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    if(notification.object == self.userNameTextField) {
        [self _loadAvatar];
    }
}

- (void)_loadAvatar {
    if(userNameTextField_.textFieldMain.text.length > 0) {
        NSString *url = [self fetchLoggedInUserAvatarURLWithUserName:userNameTextField_.textFieldMain.text];
        if(url && url.length > 0) {
            [self.avatarView setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"login_tip_logo"]];
        }
    }
}

- (void)_didChangeValueTextField:(UITextField *)textField {
    // somebody need to disappear the signed users picker when user start to editing.
    // Just wanna to disappear signed users picker view to listen value change event.
    // So expensive! please change it in the future.
    if (authViewControllerFlags_.signedUsersPickerVisible == 1) {
        // dismiss the signed users picker
        [self loggedInUserPicker:NO anchorRect:CGRectZero];
    }
}

/**
 *  在iOS7.0下，UITableViewCell的层级变了
 *
 *
 */
- (void)removeLoggedInUser:(UIButton *)btn {
    UIView *superView = btn.superview;
    
    while (superView && ![superView isKindOfClass:[UITableViewCell class]]) {
        superView = superView.superview;
    }
    
    if([superView isKindOfClass:[UITableViewCell class]]){
        UITableViewCell *cell = (UITableViewCell *)superView;
        NSIndexPath *indexPath = [tableView_ indexPathForCell:cell];
        
        [userList_ removeObjectAtIndex:indexPath.row];
        if([userList_ count] > 0){
            [tableView_ deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            
            [UIView animateWithDuration:0.25 animations:^{
                CGRect rect = tableView_.frame;
                rect.size.height = [userList_ count] * 36.0;
                tableView_.frame = rect;
            }];
            
        }else {
            [self loggedInUserPicker:NO anchorRect:CGRectZero];
            
            userNameTextField_.textFieldMain.rightView = nil;
            userNameTextField_.textFieldMain.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
        
        if (loginType_ != KDLoginViewTypePhoneLoginPwd)
            [KDLoggedInUser storeLoggedInUsers:userList_ isIphone:loginType_ != KDLoginViewTypeEmailInput];
        else
            [KDLoggedInUser storeLoggedInUsers:userList_];
    }
}

- (void)retrieveLoggedInUsers {
    // retrieve logged in users from cache if need
    if(userList_ == nil){
        
        NSArray *users = nil;
        if (loginType_ != KDLoginViewTypePhoneLoginPwd)
            users = [KDLoggedInUser getLoggedInUsersIsPhone:loginType_ != KDLoginViewTypeEmailInput];
        else
            users = [KDLoggedInUser retrieveLoggedInUsers];
        
        users = [users objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN(3, users.count))]];
        users = (users != nil) ? [NSMutableArray arrayWithArray:users] : [NSMutableArray array];
        
        self.userList = (NSMutableArray *)users;
    }
}

- (void)storeToLoggedInUserList:(NSString *)username {
    [self retrieveLoggedInUsers];
    
    BOOL exists = NO;
    // check the username does exits
    for(KDLoggedInUser *user in userList_){
        if([user.identifier isEqualToString:username]){
            exists = YES;
            break;
        }
    }
    
    if (!exists) {
        KDLoggedInUser *userObj = [KDLoggedInUser loggedInUserWithIdentifier:username loggedInTime:time(NULL)];
        [userList_ insertObject:userObj atIndex:0x00];
        userObj.isPhone = loginType_ == KDLoginViewTypePhoneNumInput;
        
        // remove the object over the boundary
        if([userList_ count] > 0x05){
            [userList_ removeLastObject];
        }
        
        // store to cache
        if (loginType_ != KDLoginViewTypePhoneLoginPwd)
            [KDLoggedInUser storeLoggedInUsers:userList_ isIphone:loginType_ != KDLoginViewTypeEmailInput];
        else
            [KDLoggedInUser storeLoggedInUsers:userList_];
    }
}

- (void)storeToLoggedInUser:(NSString *)userName andAvatarURL:(NSString *)url {
    if(!userName || userName.length == 0) return;
    
    [self retrieveLoggedInUsers];
    
    KDLoggedInUser *user = nil;
    
    for(KDLoggedInUser *u in userList_) {
        if([u.identifier isEqualToString:userName]) {
            user = u;
            break;
        }
    }
    
    if(!user) {
        user = [KDLoggedInUser loggedInUserWithIdentifier:userName loggedInTime:time(NULL)];
        [userList_ addObject:user];
        user.isPhone = loginType_ != KDLoginViewTypeEmailInput;
    }
    
    user.avatarURL = url;
    
    if (loginType_ != KDLoginViewTypePhoneLoginPwd)
        [KDLoggedInUser storeLoggedInUsers:userList_ isIphone:loginType_ != KDLoginViewTypeEmailInput];
    else
        [KDLoggedInUser storeLoggedInUsers:userList_];
}

- (NSString *)fetchLoggedInUserAvatarURLWithUserName:(NSString *)userName {
    [self retrieveLoggedInUsers];
    
    for(KDLoggedInUser *user in userList_) {
        if([user.identifier isEqualToString:userName]) {
            return user.avatarURL;
        }
    }
    
    return nil;
}

- (void)loggedInUserPicker:(BOOL)visible anchorRect:(CGRect)anchorRect {
    if(visible){
        CGRect frame;
        if(userListMaskView_ == nil){
            frame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
            userListMaskView_ = [[UIView alloc] initWithFrame:frame];
            
            userListMaskView_.backgroundColor = [UIColor clearColor];
            userListMaskView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            
            // tap gesture recognizer
            
        }
        [self.contentView addSubview:userListMaskView_];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissLoggedInUserPicker:)];
        [userListMaskView_ addGestureRecognizer:tapGestureRecognizer];
//        [tapGestureRecognizer release];
//
        if(tableView_ == nil){
            frame = anchorRect;
            frame.size.height = 0.0;
            
            tableView_ = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
            tableView_.backgroundColor = UIColorFromRGB(0xedf1f3);//RGBACOLOR(255, 255, 255, 1.0f);
            tableView_.backgroundView = nil;
            tableView_.separatorColor = UIColorFromRGB(0xd0d6de);
            
            tableView_.layer.borderColor = [UIColor clearColor].CGColor;//RGBCOLOR(202.0, 202.0, 202.0).CGColor;
            //            tableView_.layer.borderWidth = 1.0;
            //            tableView_.layer.cornerRadius = 5.0;
            
            
            tableView_.delegate = self;
            tableView_.dataSource = self;
            
            tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
            
        }
        [self.contentView addSubview:tableView_];
    }
    
    CGFloat height = 0.0;
    if(visible) {
        isPickedUser_ = NO;
        userListMaskView_.userInteractionEnabled = YES;
        tapGestureRecognizer_.enabled = NO;
        
        height = [userList_ count] * 36.0;
        CGFloat visibleHeight = self.view.bounds.size.height - anchorRect.origin.y;
        if(height < visibleHeight){
            tableView_.scrollEnabled = NO;
        }else {
            tableView_.scrollEnabled = YES;
            height = visibleHeight;
        }
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect rect = tableView_.frame;
                         rect.origin.y = visible ? anchorRect.origin.y : rect.origin.y;
                         rect.size.height = height;
                         
                         tableView_.frame = rect;
                     }
     
                     completion:^(BOOL finished){
                         authViewControllerFlags_.signedUsersPickerVisible = visible ? 1 : 0;
                         
                         if(!visible) {
                             for(UITapGestureRecognizer *tap in userListMaskView_.gestureRecognizers) {
                                 [userListMaskView_ removeGestureRecognizer:tap];
                             }
                             
                             [userListMaskView_ removeFromSuperview];
                             [tableView_ removeFromSuperview];
                             
                             tapGestureRecognizer_.enabled = YES;
                             if (loginType_ == KDLoginViewTypePhoneNumInput) {
                                 if (!isPickedUser_) {
                                     if ([userNameTextField_ canBecomeFirstResponder]) {
                                         [userNameTextField_ becomeFirstResponder];
                                     }
                                 }
                                 else
                                 {
                                     if ([userNameTextField_ canResignFirstResponder])
                                         [userNameTextField_ resignFirstResponder];
                                 }
                             }
                             else
                             {
                                 UITextField *responder = isPickedUser_ ? passwordTextField_.textFieldMain : userNameTextField_.textFieldMain;
                                 if ([responder canBecomeFirstResponder]) {
                                     [responder becomeFirstResponder];
                                 }
                             }
                         }
                     }];
}

- (void)dismissLoggedInUserPicker:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self loggedInUserPicker:NO anchorRect:CGRectZero];
}

- (void)showLoggedInUsernameList:(UIButton *)sender {
    authViewControllerFlags_.disableInputFieldsAnimation = 1;
    
    CGFloat height = CGRectGetHeight(userNameTextField_.frame);
    CGRect rect = userNameTextField_.frame;
    rect.origin.x = CGRectGetMinX(userNameTextField_.frame);
    rect.origin.y += height;
    rect.size.height = height;
    
    [self loggedInUserPicker:YES anchorRect:rect];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alertView = nil;
    
    if([message isEqualToString:NSLocalizedString(@"SIGN_IN_DID_FAIL_DETAILS", @"")]) {
        alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel") otherButtonTitles:NSLocalizedString(@"SIGN_IN_RESET_PASSWORD", @""),nil];
    } else {
        alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"OKAY", @"") otherButtonTitles:nil];
    }
    
    alertView.tag = 0x01;
    [alertView show];
//    [alertView release];
}

- (void)showPromptWithTitle:(NSString *)title message:(NSString *)message retry:(BOOL)retry {
    UIAlertView *alertView = [[UIAlertView alloc] initWithFrame:CGRectZero];
    alertView.delegate = self;
    alertView.tag = 0x02;
    alertView.title = title;
    alertView.message = message;
    
    alertView.cancelButtonIndex = 0x00;
    [alertView addButtonWithTitle:NSLocalizedString(@"OKAY", @"")];
    
    if (retry) {
        [alertView addButtonWithTitle:NSLocalizedString(@"RETRY", @"")];
    }
    
    [alertView show];
//    [alertView release];
}

- (void)showSignInFailsAnimation {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 1.0;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    animation.type = @"rippleEffect";//110
    
    [self.view.layer addAnimation:animation forKey:@"animation"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if (flag) {
        if([userNameTextField_ canResignFirstResponder]) {
            [userNameTextField_ becomeFirstResponder];
        }
    }
}

- (void)activityViewWithVisible:(BOOL)visible block:(BOOL)block isForThirdParty:(BOOL)isThird {
    if(visible == activityVisible_) return;
    activityVisible_ = visible;
    
    if(activityView_ == nil){
        CGRect rect = CGRectMake((self.view.bounds.size.width - 160.0) * 0.5, (self.view.bounds.size.height - 100.0) * 0.5 - 50.0, 160.0, 100.0);
        activityView_ = [[KDActivityIndicatorView alloc] initWithFrame:rect];
        activityView_.alpha = 0.0;
        
        [self.view addSubview:activityView_];
    }
    
    if(visible){
        if (block && blockView_ == nil) {
            blockView_ = [[UIView alloc] initWithFrame:self.view.bounds];
            blockView_.backgroundColor = RGBACOLOR(145.0, 145.0, 145.0, 0.35);
            
            blockView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [self.view insertSubview:blockView_ belowSubview:activityView_];
        }
        
        if(isThird) {
            [activityView_ show:YES info:NSLocalizedString(@"SIGNINING...", @"")];
        }
    }else {
        if (blockView_ != nil) {
            if (blockView_.superview != nil) {
                [blockView_ removeFromSuperview];
            }
            
            //KD_RELEASE_SAFELY(blockView_);
        }
        
        [activityView_ hide:YES];
    }
    
    if(visible) {
        //[self.avatarView rotate];
    }else {
        //[self.avatarView stopRotate];
    }
}


- (void)findPassword
{
    [userNameTextField_ resignFirstResponder];
    [passwordTextField_ resignFirstResponder];
    
    NSNumber *code = [[NSUserDefaults standardUserDefaults] objectForKey:kConfigLoginUserCode];
    NSInteger loginUserCode = [code integerValue];
    if(loginUserCode == KDPWDNotPhoneElse){
        UIAlertView *alert = [[UIAlertView alloc ]initWithTitle:@"" message:ASLocalizedString(@"KDAuthViewController_tips_forget_psw")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];
        [alert show];
//        [alert release];
    }else if(loginUserCode == KDPWDNotPhoneEmail){
        //邮箱重置密码
        [self resetPassordWithEmail:[BOSSetting sharedSetting].userName];
    }else{
        [self gotoFindPasswordView];
    }
    
    //    if([[BOSSetting sharedSetting] supportNotMobile]){
    //        UIAlertView *alert = [[UIAlertView alloc ]initWithTitle:@"" message:ASLocalizedString(@"KDAuthViewController_tips_forget_psw")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];
    //        [alert show];
    //        [alert release];
    //    }else{
    //        [self gotoFindPasswordView];
    //    }
    
}




- (void)_resignInputFieldFirstResponder {
    if([userNameTextField_.textFieldMain isFirstResponder]) {
        [userNameTextField_.textFieldMain resignFirstResponder];
    }
    
    if([passwordTextField_.textFieldMain isFirstResponder]) {
        [passwordTextField_.textFieldMain resignFirstResponder];
    }
}

- (BOOL)validate {
    NSString *username = userNameTextField_.textFieldMain.text;
    NSString *password = passwordTextField_.textFieldMain.text;
    
    // validate token
    if(username == nil || [username length] < 1){
        [self showAlertWithTitle:nil message:NSLocalizedString(@"USERNAME_CAN_NOT_BLANK", @"")];
        return NO;
    }
    
    if(password == nil || [password length] < 1){
        [self showAlertWithTitle:nil message:NSLocalizedString(@"PASSWORD_CAN_NOT_BLANK", @"")];
        return NO;
    }
    
    // resign first responder
    [self _resignInputFieldFirstResponder];
    
    return YES;
}

#pragma mark -
#pragma mark The keyboard notification

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    if (CGRectGetMinY([[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue]) < CGRectGetHeight(self.view.window.bounds)) {
        return;
    }
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *option = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView animateWithDuration:[duration floatValue]
                          delay:0.0f
                        options:[option integerValue]
                     animations:^{
                         CGRect signInBtnFrame = [self.view convertRect:self.signInBtn.frame fromView:self.contentView];
                         
                         if(CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(signInBtnFrame) < CGRectGetHeight(keyboardRect)) {
                             CGFloat deltaHeight = CGRectGetHeight(keyboardRect) - CGRectGetHeight(self.view.bounds) + CGRectGetMaxY(self.forgetPasswordBtn.frame);
                             
                             CGPoint center = self.contentView.center;
                             center = CGPointMake(center.x, center.y - deltaHeight);
                             
                             if (!isAboveiPhone5)
                             {
                                 if (loginType_ == KDLoginViewTypeEmailInput) {
                                     center.y += 37;
                                 }
                                 
                                 center.y -= 27.f;
                                 //                                 if (isAboveiOS7) {
                                 center.y -= 19;
                                 //                                 }
                             }
                             
                             
                             self.contentView.center = center;
                         }
                         
                     }
                     completion:^(BOOL finished) {
                         tapGestureRecognizer_.enabled = YES;
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSNumber *duration = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *option = [[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView animateWithDuration:[duration floatValue]
                          delay:0.0f
                        options:[option integerValue]
                     animations:^{
                         self.contentView.center = CGPointMake(CGRectGetWidth(self.view.bounds) * 0.5f, CGRectGetHeight(self.view.bounds) * 0.5f);
                     }
                     completion:^(BOOL finished) {
                         tapGestureRecognizer_.enabled = NO;
                     }];
}
/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIGestureRecognizer delegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ([touch.view isKindOfClass:[UIButton class]]) ? NO : YES;
}

- (void)_didTapOnTemplateView:(UITapGestureRecognizer *)gestureRecongnizer {
    if (UIGestureRecognizerStateRecognized == gestureRecongnizer.state) {
        [self _resignInputFieldFirstResponder];
    }
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    BOOL hidden = (authViewControllerFlags_.navigationBarHidden == 1) ? YES : NO;
    self.navigationController.navigationBarHidden = hidden;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(userNameTextField_);
    //KD_RELEASE_SAFELY(passwordTextField_);
    //KD_RELEASE_SAFELY(signInBtn_);
    //KD_RELEASE_SAFELY(signUpBtn_);
    //KD_RELEASE_SAFELY(forgetPasswordBtn_);
    //KD_RELEASE_SAFELY(contentView_);
    //KD_RELEASE_SAFELY(userListMaskView_);
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(blockView_);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
//    if (_iosURL)
//        //KD_RELEASE_SAFELY(_iosURL);
//    if (_clientCloud)
//        //KD_RELEASE_SAFELY(_clientCloud);
//    if (_clientServer)
//        //KD_RELEASE_SAFELY(_clientServer);
//    if (_authDeviceUnauthorizedDataModel)
//        //KD_RELEASE_SAFELY(_authDeviceUnauthorizedDataModel);
    
    //KD_RELEASE_SAFELY(_invitedView);
    //KD_RELEASE_SAFELY(_phoneLable);
    //KD_RELEASE_SAFELY(verifyNav_);
    //KD_RELEASE_SAFELY(openClient_);
    //KD_RELEASE_SAFELY(nameLabel_);
    //KD_RELEASE_SAFELY(opBtn_);
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(userNameTextField_);
    //KD_RELEASE_SAFELY(passwordTextField_);
    //KD_RELEASE_SAFELY(signInBtn_);
    //KD_RELEASE_SAFELY(signUpBtn_);
    //KD_RELEASE_SAFELY(forgetPasswordBtn_);
    //KD_RELEASE_SAFELY(contentView_);
    //KD_RELEASE_SAFELY(tapGestureRecognizer_);
    
    //KD_RELEASE_SAFELY(userList_);
    
    //KD_RELEASE_SAFELY(userListMaskView_);
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(blockView_);
    
    //KD_RELEASE_SAFELY(_finishResultModel);
    
    //[super dealloc];
}

- (void)setUpNavigationItemForViewController:(UIViewController *)vc
{
    
    if ([vc isKindOfClass:[KDBindEmailViewController class]])
        return;
    
    //    UIImage *image = [UIImage imageNamed:@"navigationItem_back"];
    //    UIImage *highlightImage = [UIImage imageNamed:@"navigationItem_back"];
    UIButton *button = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    //    [button setImage:image forState:UIControlStateNormal];
    //    [button setImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [button sizeToFit];
    
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    //song.wang 2013-12-26
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];// autorelease];
    negativeSpacer.width = kLeftNegativeSpacerWidth;
    vc.navigationItem.leftBarButtonItems = [NSArray
                                            arrayWithObjects:negativeSpacer,leftBarButtonItem, nil];
//    [leftBarButtonItem release];
}

#pragma mark - 非手机号码-邮箱 发送激活邮件
- (void)resetPassordWithEmail:(NSString *)email {
    
    KDQuery *query = [KDQuery queryWithName:@"email" value:email];
    
    //    __block KDAuthViewController *upevc = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        NSInteger errorCode = [results objectForKey:@"errorCode"];
        if (errorCode) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:ASLocalizedString(@"KDAuthViewController_check_email")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];
            [alert show];
            [alert show];
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/account/:resetPassordWithEmail" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

#pragma mark - 页面跳转
- (void)gotoPasswordInputView:(BOOL) isSupprotMobile withType:(NSInteger) type
{
    if (verifyNav_) {
//        [verifyNav_ release];
        verifyNav_ = nil;
    }
    
    KDPwdConfirmViewController *ctr = [[KDPwdConfirmViewController alloc] init];
    ctr.delegate = self;
    ctr.pwdType = KDPwdInputTypePwdConfirm;
    ctr.hasProtocolRegulation = self.isCheckBox;
    ctr.isHideSMSVerify = self.isHideSMSVerify;
    ctr.pwdSupportType = type;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    [self setUpNavigationItemForViewController:ctr];
    
    [self presentViewController:nav animated:YES completion:nil];
//    [ctr release];
//    [nav release];
//    
    self.verifyNav = nav;
    
}

- (void)gotoPasswordSettingView
{
    if (verifyNav_) {
//        [verifyNav_ release];
        verifyNav_ = nil;
    }
    
    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
    
    KDPwdConfirmViewController *ctr = [[KDPwdConfirmViewController alloc] init];
    ctr.delegate = self;
    ctr.pwdType = KDPwdInputTypePwdSetting;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    [self setUpNavigationItemForViewController:ctr];
    
    [self presentViewController:nav animated:YES completion:nil];
//    [ctr release];
//    [nav release];
    
    self.verifyNav = nav;
    
}

- (void)gotoRegisterView
{
    if (verifyNav_) {
//        [verifyNav_ release];
        verifyNav_ = nil;
    }
    
    KDPhoneInputViewController *ctr = [[KDPhoneInputViewController alloc] init];
    ctr.delegate = self;
    ctr.type = KDPhoneInputTypeRegister;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    
    [self setUpNavigationItemForViewController:ctr];
    
    [self presentViewController:nav animated:YES completion:nil];
//    [ctr release];
//    [nav release];
    
    self.verifyNav = nav;
}
- (void)gotoFindPasswordView
{
    if (verifyNav_) {
//        [verifyNav_ release];
        verifyNav_ = nil;
    }
    
    KDPhoneInputViewController *ctr = [[KDPhoneInputViewController alloc] init];
    ctr.delegate = self;
    ctr.type = KDPhoneInputTypeFindPwd;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    
    [self setUpNavigationItemForViewController:ctr];
    
    [self presentViewController:nav animated:YES completion:nil];
//    [ctr release];
//    [nav release];
    
    self.verifyNav = nav;
}

- (void)gotoEmailCodeConfirmView
{
    if (verifyNav_) {
        //        [verifyNav_ release];
        verifyNav_ = nil;
    }
    
    KDCodeConfirmViewController *ctr = [[KDCodeConfirmViewController alloc] init];
    ctr.isRegister = NO;
    ctr.delegate = self;
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
    ctr.shouldResetTimer = YES;
    
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    
    [self setUpNavigationItemForViewController:ctr];
    
    [self presentViewController:nav animated:YES completion:nil];
    _officePhone = nil;
    _officeEmail = nil;
    _isSendAllCode = NO;
    //    [ctr release];
    //    [nav release];
    
    self.verifyNav = nav;
}

- (void)gotoCodeConfirmView
{
    if (verifyNav_) {
//        [verifyNav_ release];
        verifyNav_ = nil;
    }
    
    KDCodeConfirmViewController *ctr = [[KDCodeConfirmViewController alloc] init];
    ctr.isRegister = YES;
    ctr.delegate = self;
    ctr.shouldResetTimer = YES;
    ctr.phoneNumber = [XTOpenConfig sharedConfig].longPhoneNumber;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    
    [self setUpNavigationItemForViewController:ctr];
    
    [self presentViewController:nav animated:YES completion:nil];
//    [ctr release];
//    [nav release];
    
    self.verifyNav = nav;
}
- (void)gotoCompanyChoseViewWithData:(NSDictionary *)data
{
    if (!data) {
        return;
    }
    if (verifyNav_) {
//        [verifyNav_ release];
        verifyNav_ = nil;
    }
    XTOpenCompanyListDataModel *companyList = [[XTOpenCompanyListDataModel alloc] initWithDictionary:data];
    
    if (companyList.companys.count > 1) {
        
        KDCompanyChoseViewController *ctr = [[KDCompanyChoseViewController alloc] init];
        ctr.delegate = self;
        ctr.dataModel = companyList;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
        
        [self setUpNavigationItemForViewController:ctr];
        
        [self presentViewController:nav animated:YES completion:nil];
//        [ctr release];
//        [nav release];
        
        self.verifyNav = nav;
    }
    else if(companyList.companys.count == 1){
        [self companyDidSelectWithCompany:[companyList.companys lastObject]];
    }
    else{
        [self gotoCompanyCreateView];
    }
    
//    [companyList release];
}
- (void)gotoCompanyCreateView
{
    if (verifyNav_) {
//        [verifyNav_ release];
        verifyNav_ = nil;
    }
    
    KDCreateTeamViewController *ctr = [[KDCreateTeamViewController alloc] init];
    ctr.fromType = KDCreateTeamFromTypeUnLogin;
    
    ctr.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    [self setUpNavigationItemForViewController:ctr];
    [self presentViewController:nav animated:YES completion:nil];
//    [ctr release];
//    [nav release];
    
    self.verifyNav = nav;
    
}
- (void)gotoJoinCompanyViewWithCompanys:(NSArray *)companys
{
    if (verifyNav_) {
//        [verifyNav_ release];
        verifyNav_ = nil;
    }
    
    KDJoinWorkGroupViewController *ctr = [[KDJoinWorkGroupViewController alloc] init];
    ctr.delegate = self;
    ctr.datas = companys;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    [self setUpNavigationItemForViewController:ctr];
    [self presentViewController:nav animated:YES completion:nil];
//    [ctr release];
//    [nav release];
    
    self.verifyNav = nav;
    
}
- (void)gotoBindEmailView
{
    if (verifyNav_) {
//        [verifyNav_ release];
        verifyNav_ = nil;
    }
    
    KDBindEmailViewController *ctr = [[KDBindEmailViewController alloc] init];
    ctr.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    [self setUpNavigationItemForViewController:ctr];
    [self presentViewController:nav animated:YES completion:nil];
//    [ctr release];
//    [nav release];
    
    self.verifyNav = nav;
    
}
#pragma mark - login logic
- (void)startGetPhoneCode
{
    [self activityViewWithVisible:YES block:YES isForThirdParty:NO];
    
    //注册
    if (nil == self.openClient) {
        self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getCodeDidReceived:result:)];// autorelease];
    }
    [self.openClient getCodeWithPhone:[XTOpenConfig sharedConfig].longPhoneNumber];
}

- (void)getCodeDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
    
    if (client.hasError)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        
        self.openClient = nil;
        [userNameTextField_ becomeFirstResponder];
        
        return;
    }
    
    self.openClient = nil;
    
    if (result.success)
    {
        [self gotoCodeConfirmView];
        
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
//    [alert release];
    [userNameTextField_ becomeFirstResponder];
}
//A.wang 邮箱验证
#pragma mark - login logic
- (void)startGetEmailCode:(BOOL)isVerifyPhone
{
    [self activityViewWithVisible:YES block:YES isForThirdParty:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText =@"正在登陆";
    //注册
    if (nil == self.emailCodeClient) {
        self.emailCodeClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getEmailCodeDidReceived:result:)];// autorelease];
    }
    if(isVerifyPhone){
        [self.emailCodeClient sendEmail:[BOSSetting sharedSetting].userName officePhone:_officePhone];
    }else{
          [self.emailCodeClient sendEmail:[BOSSetting sharedSetting].userName officePhone:nil];
        
    }
    
}

- (void)getEmailCodeDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if (client.hasError || !result.success || ![result isKindOfClass:[BOSResultDataModel class]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
        //        [alert release];
        
        self.emailCodeClient = nil;
        [userNameTextField_ becomeFirstResponder];
        
        return;
    }
    
    self.emailCodeClient = nil;
    
    if (result.success)
    {
        [self gotoEmailCodeConfirmView];
        
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
    //    [alert release];
    [userNameTextField_ becomeFirstResponder];
}


- (void)startCheckEmailInput
{
    if ([self validate]) {
        
        //[BOSSetting sharedSetting].userName = userNameTextField_.textFieldMain.text;
        [BOSSetting sharedSetting].password = passwordTextField_.textFieldMain.text;
        
        [self getTokenWithEId:nil];
        
        [BOSConfig sharedConfig].isLoginWithOpenAccount = NO;
        
    }
}
- (void)startCheckPwdInput
{
    if (passwordTextField_.textFieldMain.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDAuthViewController_input_psw")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        
        return;
    }
    [passwordTextField_ resignFirstResponder];
    
    //[BOSSetting sharedSetting].userName = [XTOpenConfig sharedConfig].longPhoneNumber;
    [BOSSetting sharedSetting].password = passwordTextField_.textFieldMain.text;
    
    [self getTokenWithEId:nil];
    
    [BOSConfig sharedConfig].isLoginWithOpenAccount = YES;
}
- (void)startCheckLoginPwd
{
    if (passwordTextField_.textFieldMain.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDAuthViewController_input_psw")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        
        return;
    }
    [passwordTextField_ resignFirstResponder];
    
    [XTOpenConfig sharedConfig].countryCode = @"+86";
    [XTOpenConfig sharedConfig].phoneNumber = [BOSSetting sharedSetting].userName;
    
    [BOSSetting sharedSetting].password = passwordTextField_.textFieldMain.text;
    
    [self getTokenWithEId:[BOSSetting sharedSetting].cust3gNo];
    
    [BOSConfig sharedConfig].isLoginWithOpenAccount = YES;
}
- (void)startCheckLoginPhoneNumber
{
    if (userNameTextField_.textFieldMain.text.length  == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDAuthViewController_input_account")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        
        return;
    }
    [userNameTextField_ resignFirstResponder];
    
    [XTOpenConfig sharedConfig].countryCode = @"+86";
    [XTOpenConfig sharedConfig].phoneNumber = userNameTextField_.textFieldMain.text;
    
    //手机号校验
    [self activityViewWithVisible:YES block:YES isForThirdParty:NO];
    
    self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(phoneCheckDidReceived:result:)] ;//autorelease];
    [self.openClient phoneCheckWithPhone:[XTOpenConfig sharedConfig].longPhoneNumber];
    
}

- (void)phoneCheckDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel*)result
{
    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
    
    if (client.hasError)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        
        self.openClient = nil;
        [userNameTextField_ becomeFirstResponder];
        
        return;
    }
    
    self.openClient = nil;
    self.isCheckBox = [[result.dictJSON objectForKey:@"isCheckBox"] boolValue];
    if([[result.dictJSON objectForKey:@"auth.verify.isopen"] boolValue])
    {
        self.isHideSMSVerify = [[result.dictJSON objectForKey:@"auth.verify.isopen"] boolValue];//短信重置密码
        [[NSUserDefaults standardUserDefaults]setBool:self.isHideSMSVerify forKey:@"isHideSMSVerify"];
    }else
    {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isHideSMSVerify"];
        self.isHideSMSVerify = NO;//短信重置密码
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:result.errorCode] forKey:kConfigLoginUserCode];
     [BOSSetting sharedSetting].userName = [result.dictJSON objectForKey:@"userName"];
    switch (result.errorCode) {
        case kAccountActivatedCode: ////输入密码
            [self gotoPasswordInputView:NO withType:0];
            break;
        case kAccountNotPhoneCodeActivated:
            [self gotoPasswordInputView:YES withType:kAccountNotPhoneCodeActivated];
            break;
        case kAccountNotPhoneCodeEmail:
            [self gotoPasswordInputView:YES withType:kAccountNotPhoneCodeEmail];
            break;
        case kAccountNotPhoneCodePhone:
            [self gotoPasswordInputView:YES withType:kAccountNotPhoneCodePhone];
            break;
        case kAccountNotActivatedCode:
        {
            //获取验证码
            NSString *error = [NSString stringWithFormat:@"%@\n%@ %@",ASLocalizedString(@"KDAuthViewController_tips_send_sms"),[XTOpenConfig sharedConfig].countryCode,[XTOpenConfig sharedConfig].phoneNumber];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDAuthViewController_comfirm_mobilephone")message:error delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDAuthViewController_ok"), nil];
            alert.tag = 0x99;
            [alert show];
//            [alert release];
        }
            break;
        case kAccountNotExistedCode:
        {
            //NSString *error = [NSString stringWithFormat:@"%@%@%@",ASLocalizedString(@"KDAuthViewController_tips_account"),[XTOpenConfig sharedConfig].phoneNumber,ASLocalizedString(@"KDAuthViewController_tips_un_import")];
            NSString *error = ASLocalizedString(@"KDAuthViewController_tips_un_import2");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDAuthViewController_comfirm_account2")message:error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];
            [alert show];
//            [alert release];
        }
            break;
        case kAccountNotPhoneCodeverify: {
                //A.wang 获取验证码
                if([[result.dictJSON objectForKey:@"isVerifyPhone"] intValue] == 1){
                    _officePhone =[result.dictJSON objectForKey:@"officePhone1"];
                    //NSString *error = [NSString stringWithFormat:@"%@\n%@ %@",ASLocalizedString(@"KDAuthViewController_tips_send_sms"),[XTOpenConfig sharedConfig].countryCode,[result.dictJSON objectForKey:@"officePhone1"]];
                    
                    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDAuthViewController_comfirm_mobilephone") message:error delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDAuthViewController_ok"), nil];
                    //alert.tag = 0x101;
                    //[alert show];
                    [self startGetEmailCode:YES];
                    
                } else if([[result.dictJSON objectForKey:@"isVerifyPhone"] intValue] == 0){
                    _officeEmail =[result.dictJSON objectForKey:@"userName"];
                    //NSString *error =[NSString stringWithFormat:@"%@\n %@",@"我们将发送验证码短信到这个邮箱：",[result.dictJSON objectForKey:@"userName"]];
                    
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
            break;
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
//            [alert release];
            
            [userNameTextField_ becomeFirstResponder];
        }
            break;
    }
    
    /*//输入密码
     if ((result.errorCode == kAccountActivatedCode) || (result.errorCode == kAccountNotPhoneCodeActivated)) {
     [self gotoPasswordInputView];
     }
     //设置密码
     else if (result.errorCode == kAccountNotActivatedCode)
     {
     //获取验证码
     NSString *error = [NSString stringWithFormat:@"%@\n%@ %@",ASLocalizedString(@"KDAuthViewController_tips_send_sms"),[XTOpenConfig sharedConfig].countryCode,[XTOpenConfig sharedConfig].phoneNumber];
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDAuthViewController_comfirm_mobilephone")message:error delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDAuthViewController_ok"), nil];
     alert.tag = 0x99;
     [alert show];
     [alert release];
     }else if(result.errorCode == kAccountNotExistedCode){
     NSString *error = [NSString stringWithFormat:@"%@%@%@",ASLocalizedString(@"KDAuthViewController_tips_mobilephone"),[XTOpenConfig sharedConfig].phoneNumber,ASLocalizedString(@"KDAuthViewController_tips_un_import")];
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDAuthViewController_comfirm_mobilephone")message:error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];
     [alert show];
     [alert release];
     }
     else {
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
     [alert show];
     [alert release];
     
     [userNameTextField_ becomeFirstResponder];
     }*/
}


- (void)companyDidSelectWithCompany:(XTOpenCompanyDataModel *)company {
    if (company) {
        [BOSSetting sharedSetting].cust3gNo = company.companyId;
        [BOSSetting sharedSetting].customerName = company.companyName;
    }
    else {
        [BOSSetting sharedSetting].cust3gNo = @"";
        [BOSSetting sharedSetting].customerName = @"";
    }
    
    [self getTokenWithEId:[BOSSetting sharedSetting].cust3gNo];
    
    [BOSConfig sharedConfig].isLoginWithOpenAccount = loginType_ != KDLoginViewTypeEmailInput;
}

- (void)alertNotFoundCompany
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDAuthViewController_need_create_com")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"Global_Sure"),nil];
    alert.tag = 10;
    [alert show];
}
#pragma mark - KDBindEmailViewControllerDelegate
- (void)finishBindEmail
{
    if (verifyNav_) {
        
        [self dismissViewControllerAnimated:YES completion:^(void){
            
            self.verifyNav = nil;
            
            if (delegate_ && [delegate_ respondsToSelector:@selector(loginFinished:)]) {
                [delegate_ loginFinished:_finishResultModel];
            }
            
            [BOSSetting sharedSetting].bindEmailFlag = 1;
            [[BOSSetting sharedSetting] saveSetting];
        }];
    }
}
#pragma mark - XTCompanyDelegate

- (void)companyDidSelect:(id)viewController company:(XTOpenCompanyDataModel *)company
{
    if (verifyNav_) {
        
        [self dismissViewControllerAnimated:YES completion:^(void){
            
            [self companyDidSelectWithCompany:company];
            
            self.verifyNav = nil;
            
        }];
    }
}

- (void)companyDidCreate:(id)createCompanyViewController company:(XTOpenCompanyDataModel *)company
{
    if (verifyNav_) {
        
        [self dismissViewControllerAnimated:YES completion:^(void){
            
            [self companyDidSelectWithCompany:company];
            
            self.verifyNav = nil;
            
        }];
    }
}

- (BOOL)companyNeedInvitePerson
{
    return YES;
}
#pragma mark - SignTOSDelegate

-(void)signedTOS:(BOOL)success
{
    if (success) {
        [self startAuth];
    }else{
    }
}

#pragma mark - get token

- (void)showGetTokenError:(NSString *)error {
    
    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
//    [alert release];
}

- (void)getTokenWithEId:(NSString *)eId {
    
    [self activityViewWithVisible:YES block:YES isForThirdParty:NO];
    
    self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getTokenDidReceived:result:)];// autorelease];
    NSString *password = [AlgorithmHelper des_Encrypt:[BOSSetting sharedSetting].password key:[BOSSetting sharedSetting].userName];
    [self.openClient loginWithCust3gNo:eId userName:[BOSSetting sharedSetting].userName password:password appClientId:XuntongAppClientId deviceId:[UIDevice uniqueDeviceIdentifier] deviceType:[[UIDevice currentDevice] model] token:@""];
}
- (void)loginWithResultData:(BOSResultDataModel *)result{
    if(result.errorCode != kWrongPassword && [[[BOSSetting sharedSetting] password] isEqualToString:@"000000"]){
        [self gotoPasswordSettingView];
        return;
    }
    
    if (!result.success) {
        
        [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
        
        //        result.errorCode = kCompanyNotFoundCode;
        if (result.errorCode == kCompanyMutilCode) {
            //多个企业
            [self gotoCompanyChoseViewWithData:result.data];
            
        }
        else if (result.errorCode == kCompanyNotFoundCode) {
            
            /*
             if ([[KDLinkInviteConfig sharedInstance] code] == LinkInviteErrorCode_Success) {
             XTOpenCompanyDataModel *model = [[[XTOpenCompanyDataModel alloc] init] autorelease];
             model.companyId = [[KDLinkInviteConfig sharedInstance] eid];
             [self companyDidSelectWithCompany:model];
             }
             else{
             
             
             }
             */
            
//            if ([[BOSSetting sharedSetting].userName isNumText]) {
//                XTOpenCompanyListDataModel *companyList = [[XTOpenCompanyListDataModel alloc] initWithDictionary:result.data];// autorelease];
//                [self gotoJoinCompanyViewWithCompanys:companyList.authstrCompanys];
//            }
//            else{
//                [self gotoCompanyCreateView];
//            }
            
            // bug 10701
            XTOpenCompanyListDataModel *companyList = [[XTOpenCompanyListDataModel alloc] initWithDictionary:result.data];
            [self gotoJoinCompanyViewWithCompanys:companyList.authstrCompanys];
        }
        else {
            [self showGetTokenError:result.error];
        }
        return;
    }
    
    UserDataModel *user = [[UserDataModel alloc] initWithDictionary:result.data];// autorelease];
    if (user.status != 3) {
        user.status = 3;
    }
    user.phone = user.bindedPhone;
    user.email = user.bindedEmail;
    KDAuthToken *token = [[KDAuthToken alloc] initWithKey:user.oauthToken secret:user.oauthTokenSecret];
    
    // 为切换团队账号，保存一份主账号的信息
    KDMainUserDataModel *mainUser = [[KDMainUserDataModel alloc] initWithDictionary:result.data];
    mainUser.phone = mainUser.bindedPhone;
    mainUser.email = mainUser.bindedEmail;
    
    // 主账号归档操作
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *arch = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [arch encodeObject:mainUser forKey:@"mainUser"];
    [arch finishEncoding];
    [data writeToFile:[[BOSFileManager xuntongPath] stringByAppendingPathComponent:@"mainUser.archiver"] atomically:YES];
    
    if (user.language != nil && user.language.length > 0) {
        if ([user.language hasPrefix:@"zh-Hans"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
        } else if ([user.language hasPrefix:@"zh-TW"] || [user.language hasPrefix:@"zh-HK"] || [user.language hasPrefix:@"zh-Hant"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
        } else if ([user.language hasPrefix:@"en"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:AppLanguage];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
        }
    }
//    [(KDWeiboAppDelegate *)[UIApplication sharedApplication].delegate setLangueage];
    
    if (Test_Environment) {
        
        KDWeiboLoginFinishedBlock block = ^(BOOL success, NSString *error)
        {
            if (success) {
                
                [[KDDBManager sharedDBManager] tryConnectToCommunity:user.eid];
                
                KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
                KDUser *currentUser = userManager.currentUser;
                userManager.currentUser = nil;
                userManager.currentUser = currentUser;
                
                //保存wbnetwordID
                [BOSConfig sharedConfig].user.wbNetworkId = currentUser.wbNetworkId;
                
                //add by lee 解决登录提示该用户已注销问题
                KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
                CompanyDataModel *company = [communityManager companyByDomainName:[BOSSetting sharedSetting].cust3gNo];
                if (company == nil) {
                    company = [[CompanyDataModel alloc] init];
                    company.eid = user.eid;
                    company.wbNetworkId = currentUser.wbNetworkId;
                }
                [communityManager connectToCompany:company];
                
                [self storeToLoggedInUser:[BOSSetting sharedSetting].userName andAvatarURL:currentUser.profileImageUrl];
                [self _loadAvatar];
            }
            
            [BOSConfig sharedConfig].user = user;
            
            [BOSSetting sharedSetting].cust3gNo = user.eid;
            [self authOrLoginBtn];
            
            
            [[XTDataBaseDao sharedDatabaseDaoInstance] setOpenId:user.openId eId:user.eid];
            
            [[XTSetting sharedSetting] setOpenId:user.openId eId:user.eid];
        };
        
        
        //        if ([token isValid])
        
        [KDWeiboLoginService signInToken:token finishBlock:block];
        
    }
    else
    {
        [BOSConfig sharedConfig].user = user;
        
        [BOSSetting sharedSetting].cust3gNo = user.eid;
        [self authOrLoginBtn];
        
        [self storeToLoggedInUser:[BOSSetting sharedSetting].userName andAvatarURL:user.photoUrl];
        [self _loadAvatar];
        
        [[XTDataBaseDao sharedDatabaseDaoInstance] setOpenId:user.openId eId:user.eid];
        
        [[XTSetting sharedSetting] setOpenId:user.openId eId:user.eid];
        
    }
}
- (void)getTokenDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result {
    
    if (client.hasError) {
        [self showGetTokenError:client.errorMessage];
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        [self showGetTokenError:ASLocalizedString(@"KDAuthViewController_return_fail")];
        return;
    }
    
    self.openClient = nil;
    
    //如果有邀请，打开应用邀请
    BOOL isFromInvited = [[KDLinkInviteConfig sharedInstance] isExistInvite];
    if (isFromInvited) {
        NSString *openid = [result.data stringForKey:@"openId"];
        if ([openid length] > 0) {
            [[KDLinkInviteConfig sharedInstance] setOpenId:openid];
            [[KDLinkInviteConfig sharedInstance] setExtraInfo:result];
            [[KDLinkInviteConfig sharedInstance] setDelegate:self];
            [[KDLinkInviteConfig sharedInstance] goToInviteFormType:Invite_From_Logining];
            
            return;
        }
    }
    [self loginWithResultData:result];
}

#pragma mark - auth

- (void)startAuth {
    [self auth];
}

- (void)authOrLoginBtn {
    [self auth];
}

- (void)auth {
    [self activityViewWithVisible:YES block:YES isForThirdParty:NO];
    
    if (_clientCloud != nil) {
        //BOSRELEASE_clientCloud);
    }
    _clientCloud = [[MCloudClient alloc] initWithTarget:self action:@selector(authDidReceived:result:)];
    [_clientCloud authWithCust3gNo:[BOSSetting sharedSetting].cust3gNo userName:[BOSSetting sharedSetting].userName];
}

- (void)showAuthError:(NSString *)error {
    
    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
//    [alert release];
}

-(void)authDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    if ([client connectedHostError]) {
        
        if ([client connectedByIP]) {
            //换用domain重新auth
            [self auth];
            return;
        }
        
        if ([client connectedByDomain]) {
            //降级方案
            [self login];
            return;
        }
    }
    
    if (client.hasError){
        [self showAuthError:client.errorMessage];
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        [self showAuthError:ASLocalizedString(@"KDAuthViewController_return_fail")];
        return;
    }
    
    if(result.success){
        AuthDataModel *authDM = [[AuthDataModel alloc] initWithDictionary:result.data];// autorelease];
        
        //记录需要保存的配置
        BOSSetting *bosSetting = [BOSSetting sharedSetting];
        //        bosSetting.welcome = authDM.welcome;
        bosSetting.customerName = [BOSConfig sharedConfig].user.companyName;
        //        bosSetting.security = authDM.security;
        bosSetting.params = authDM.params;
        bosSetting.url = authDM.url;
        bosSetting.xtOpen = authDM.xtOpen;
        
        //记录无需保存的配置(现在也需要保存)
        BOSConfig *bosConfig = [BOSConfig sharedConfig];
        bosConfig.loginUser = authDM.loginUser;
        bosConfig.appId = authDM.appId;
        bosConfig.instanceName = authDM.instanceName;
        [bosConfig updateConfig4Param];
        [bosConfig saveConfig];
        
        [BOSConnect setUAWithAppId:authDM.appId name:authDM.instanceName];
        
        [self login];
        
        [KDManagerContext globalManagerContext].userManager.verifyCache = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                           [BOSConfig sharedConfig].user.eid,@"eid",
                                                                           [BOSSetting sharedSetting].userName,@"userName",
                                                                           [BOSSetting sharedSetting].password,@"password",nil];
        [[KDManagerContext globalManagerContext].userManager storeUserData];
        
        [[KDParamFetchManager sharedParamFetchManager] startParamFetchCompletionBlock:^(BOOL success) {
            if (success) {
                //
            }
        }];
        
        if (!Test_Environment)
            [KDWeiboLoginService signInUser:[BOSSetting sharedSetting].userName password:[BOSSetting sharedSetting].password finishBlock:nil];
        
    } else {
        switch (result.errorCode) {
            case MCloudVersionLowError:
            {
                AuthVersionLowDataModel *authVersionLowDM = [[AuthVersionLowDataModel alloc] initWithDictionary:result.data];// autorelease];
                if ([authVersionLowDM.iosURL isEqualToString:@""]) {
                    [self showAuthError:result.error];
                }else {
                    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
                    
                    [self setIosURL:authVersionLowDM.iosURL];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""  message:result.error delegate:self cancelButtonTitle:ASLocalizedString(@"KDAuthViewController_upgrate")otherButtonTitles:nil];
                    alert.tag = 1;
                    [alert show];
//                    [alert release];
                }
                break;
            }
            case MCloudDeviceUnauthorizedError:
            {
                AuthDeviceUnauthorizedDataModel *authDeviceUnauthorizedDM = [[AuthDeviceUnauthorizedDataModel alloc] initWithDictionary:result.data] ;//;//autorelease];
                //到EMP Server鉴权
                [self setAuthDeviceUnauthorizedDataModel:authDeviceUnauthorizedDM];
                
                //鉴权成功，判断licence策略
                if (authDeviceUnauthorizedDM.licencePolicy == LicenceBaseOnApplyPolicy) {
                    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
                    //提示用户申请授权
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""  message:result.error delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"Global_Send"), nil];
                    alert.tag = 2;
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    UITextField *t_textField = [alert textFieldAtIndex:0];
                    t_textField.layer.cornerRadius = 5.0;
                    t_textField.backgroundColor = [UIColor whiteColor];
                    t_textField.placeholder = ASLocalizedString(@"KDAuthViewController_leave_msg");
                    [alert show];
//                    [alert release];
                }
                else {
                    //调用绑定接口
                    [self bindLicence:@""];
                }
                //                }
                break;
            }
            case MCloudDeviceStateError:
            {
                InstructionsDataModel *instructionsDM = [[InstructionsDataModel alloc] initWithDictionary:result.data] ;//autorelease];
                if ([instructionsDM.instructions count] <= 0) {
                    [self showAuthError:result.error];
                }else {
                    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
                    if (delegate_ && [delegate_ respondsToSelector:@selector(instructionsWhenDeviceStateError:)]) {
                        [delegate_ instructionsWhenDeviceStateError:instructionsDM];
                    }
                }
                break;
            }
            case MCloudTOSError:
            {
                AuthTOSDataModel *authTOSDM = [[AuthTOSDataModel alloc] initWithDictionary:result.data];// autorelease];
                if (authTOSDM.tosTag != TOSSigned) {
                    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
                    //切换至协议签署界面,签署协议
                    SignTOSViewController *signTOSVC = [[SignTOSViewController alloc] initWithTOSType:authTOSDM.tosTag showToolBar:YES];// autorelease];
                    signTOSVC.delegate = self;
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        signTOSVC.modalPresentationStyle = UIModalPresentationFormSheet;
                    }
                    [self presentViewController:signTOSVC animated:YES completion:nil];
                }else {
                    [self showAuthError:result.error];
                }
                break;
            }
            case MCloudBindingPolicyError:
            case MCloudUserUnauthorizedError:
            case MCloudGeneralError:
            default:
                [self showAuthError:result.error];
                break;
        }
    }
}

-(void)setIosURL:(NSString *)url
{
    if (_iosURL != url) {
//        [_iosURL release];
        _iosURL = [url copy];
    }
}

-(void)setAuthDeviceUnauthorizedDataModel:(AuthDeviceUnauthorizedDataModel *)authDM
{
    if (_authDeviceUnauthorizedDataModel != authDM) {
//        [_authDeviceUnauthorizedDataModel release];
        _authDeviceUnauthorizedDataModel = authDM ;//retain];
    }
}

#pragma mark - bindLicence

-(void)bindLicence:(NSString *)validateToken
{
    if (_clientCloud != nil) {
        //BOSRELEASE_clientCloud);
    }
    _clientCloud = [[MCloudClient alloc] initWithTarget:self action:@selector(bindLicenceDidReceived:result:)];
    [_clientCloud bindLicenceWithCust3gNo:[BOSSetting sharedSetting].cust3gNo userName:_authDeviceUnauthorizedDataModel.loginUser opToken:_authDeviceUnauthorizedDataModel.opToken validateToken:validateToken];
}

-(void)showBindLicenceError:(NSString *)error{
    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"LOGIN_FAIL_SERVER_EXCEPTION", nil)  delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
//    [alert release];
}

-(void)bindLicenceDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError){
        [self showBindLicenceError:client.errorMessage];
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        [self showBindLicenceError:ASLocalizedString(@"KDAuthViewController_return_fail")];
        return;
    }
    if (!result.success) {
        [self showBindLicenceError:result.error];
        return;
    }
    //绑定Licence成功，重新进行认证
    [self authOrLoginBtn];
}

#pragma mark - deviceLicenceApply

-(void)deviceLicenceApply:(NSString *)memo
{
    [self activityViewWithVisible:YES block:YES isForThirdParty:NO];
    
    if (_clientCloud != nil) {
        //BOSRELEASE_clientCloud);
    }
    _clientCloud = [[MCloudClient alloc] initWithTarget:self action:@selector(deviceLicenceApplyDidReceived:result:)];
    [_clientCloud deviceLicenceApplyWithCust3gNo:[BOSSetting sharedSetting].cust3gNo userName:_authDeviceUnauthorizedDataModel.loginUser memo:memo];
}

-(void)showDeviceLicenceApplyError:(NSString *)error{
    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"LOGIN_FAIL_SERVER_EXCEPTION", nil) delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
//    [alert release];
}

-(void)deviceLicenceApplyDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result{
    if (client.hasError){
        [self showDeviceLicenceApplyError:client.errorMessage];
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        [self showDeviceLicenceApplyError:ASLocalizedString(@"KDAuthViewController_return_fail")];
        return;
    }
    if (!result.success) {
        [self showDeviceLicenceApplyError:result.error];
        return;
    }
    //提示用户等待管理员审核
    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"DirectMessageCellView_tips_9")message:ASLocalizedString(@"KDAuthViewController_wait_examine")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
//    [alert release];
}

#pragma mark - login

//开始认证客户端并获取企业客户的服务器信息
-(void)loginButtonPressed
{
    [BOSConfig sharedConfig].bDemoLogin = NO;
    
    BOSSetting *setting = [BOSSetting sharedSetting];
    if ([setting.cust3gNo isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDAuthViewController_company_empty")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        return;
    }
    if (userNameTextField_.textFieldMain.text == nil || [userNameTextField_.textFieldMain.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"USERNAME_CAN_NOT_BLANK", @"") delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        return;
    }
    
    setting.userName = userNameTextField_.textFieldMain.text;
    setting.password = passwordTextField_.textFieldMain.text;
    
    if (
        delegate_&& [delegate_ respondsToSelector:@selector(loginWithLoginButton)]) {
        [delegate_ loginWithLoginButton];
    }
    [self getTokenWithEId:setting.cust3gNo];//开始认证
}
-(void)login
{
    BOSSetting *setting = [BOSSetting sharedSetting];
    if ([setting.url isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"LOGIN_FAIL_SERVER_EXCEPTION", nil) delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        
        [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
        return;
    }
    
    if (_clientServer != nil) {
        //KD_RELEASE_SAFELY(_clientServer);
    }
    
    NSString *languageKey = [[NSUserDefaults standardUserDefaults]objectForKey:AppLanguage];
    _clientServer = [[EMPServerClient alloc] initWithTarget:self action:@selector(loginDidReceived:result:)];
    [_clientServer authTokenWithToken:[BOSConfig sharedConfig].user.token
                          appClientId:XuntongAppClientId
                             deviceId:[UIDevice uniqueDeviceIdentifier]
                          deviceToken:[BOSConfig sharedConfig].deviceToken
                              langKey:languageKey];
    
}

-(void)showLoginError:(NSString *)error{
    
    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
    
    //add
    if (loginType_ == KDLoginViewTypePhoneNumInput || loginType_ == KDLoginViewTypePhoneLoginPwd) {
        [KDEventAnalysis event:event_fail_count attributes:@{label_login_ok_type: label_login_ok_type_phone}];
        [KDEventAnalysis eventCountly:event_fail_count attributes:@{label_login_ok_type: label_login_ok_type_phone}];
    }
    else if (loginType_ == KDLoginViewTypeEmailInput) {
        [KDEventAnalysis event:event_fail_count attributes:@{label_login_ok_type: label_login_ok_type_email}];
        [KDEventAnalysis eventCountly:event_fail_count attributes:@{label_login_ok_type: label_login_ok_type_email}];
    }
    
//    [alert release];
}

- (BOOL)hasChangedAccount
{
    NSString *lastOpenId = [[NSUserDefaults standardUserDefaults] valueForKey:@"kdweibo_last_openid"];
    return ![[BOSConfig sharedConfig].user.openId isEqualToString:lastOpenId];
}

- (void)saveLastAccount
{
    [[NSUserDefaults standardUserDefaults] setValue:[BOSConfig sharedConfig].user.openId forKey:@"kdweibo_last_openid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)loginDidReceived:(EMPServerClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError) {
        if (delegate_ && [delegate_ respondsToSelector:@selector(loginFailed:)]) {
            [delegate_ loginFailed:nil];
        }
        [self showLoginError:client.errorMessage];
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        if (delegate_ && [delegate_ respondsToSelector:@selector(loginFailed:)]) {
            [delegate_ loginFailed:nil];
        }
        [self showLoginError:ASLocalizedString(@"KDAuthViewController_return_fail")];
        return;
    }
    if (!result.success) {
        if (delegate_ && [delegate_ respondsToSelector:@selector(loginFailed:)]) {
            [delegate_ loginFailed:result];
        }
        [self showLoginError:result.error];
        return;
    }
    
    [self activityViewWithVisible:NO block:NO isForThirdParty:NO];
    
    LoginDataModel *loginDM = [[LoginDataModel alloc] initWithDictionary:result.data];// autorelease];
    
    BOSSetting *setting = [BOSSetting sharedSetting];
    setting.accessToken = loginDM.accessToken;
    if ([self hasChangedAccount]) {
        //登录用户不同,删除缓存数据
        if (delegate_ && [delegate_ respondsToSelector:@selector(loginByChangeAccount)]) {
            [delegate_ loginByChangeAccount];
        }
    }
    [self saveLastAccount];
    
    setting.hasFinishLogin = YES;
    [setting saveSetting];
    
    BOSConfig *bosConfig = [BOSConfig sharedConfig];
    bosConfig.ssoToken = loginDM.ssoToken;
    bosConfig.loginToken = loginDM.loginToken;
    bosConfig.homePage = loginDM.homePage;
    [bosConfig saveConfig];
    
    /*
     if ([self shouldBindEmail]) {
     self.finishResultModel = result;
     
     
     [self gotoBindEmailView];
     }
     else
     {
     if (delegate_ && [delegate_ respondsToSelector:@selector(loginFinished:)]) {
     [delegate_ loginFinished:result];
     }
     }
     */
    
    if (delegate_ && [delegate_ respondsToSelector:@selector(loginFinished:)]) {
        [delegate_ loginFinished:result];
        
        if (loginType_ == KDLoginViewTypePhoneNumInput || loginType_ == KDLoginViewTypePhoneLoginPwd) {
            [KDEventAnalysis event:event_login_ok attributes:@{label_login_ok_type: label_login_ok_type_phone}];
            [KDEventAnalysis eventCountly:event_login_ok attributes:@{label_login_ok_type: label_login_ok_type_phone}];
        }
        else if (loginType_ == KDLoginViewTypeEmailInput) {
            [KDEventAnalysis event:event_login_ok attributes:@{label_login_ok_type: label_login_ok_type_email}];
            [KDEventAnalysis eventCountly:event_login_ok attributes:@{label_login_ok_type: label_login_ok_type_email}];
        }
    }
}
- (BOOL)shouldBindEmail
{
    return [BOSSetting sharedSetting].bindEmailFlag == 0 && [[BOSConfig sharedConfig].user.email length] == 0;;
}
#pragma mark - KDJoinWorkGroupViewControllerDelegate
- (void)joinWorkGroupViewDidCreateCompany{
    if (verifyNav_) {
        
        [self dismissViewControllerAnimated:YES completion:^(void){
            self.verifyNav = nil;
            
            [self gotoCompanyCreateView];
            
        }];
    }
}
- (void)joinWorkGroupViewDidJoinCompany:(NSString *)eid{
    
    if (verifyNav_) {
        
        [self dismissViewControllerAnimated:YES completion:^(void){
            
            [self getTokenWithEId:eid];
            
            self.verifyNav = nil;
            
        }];
    }
}
#pragma mark - KDLoginPwdConfirmDelegate
- (void)goBack
{
    if (verifyNav_) {
        
        [self dismissViewControllerAnimated:YES completion:^(void){
            
            self.verifyNav = nil;
            
        }];
    }
}
- (void)authViewConfirmPwd
{
    if (verifyNav_) {
        
        [self dismissViewControllerAnimated:YES completion:^(void){
            
            if (passwordTextField_ && !passwordTextField_.hidden)
                passwordTextField_.textFieldMain.text = [BOSSetting sharedSetting].password;
            if (userNameTextField_ && !userNameTextField_.hidden && loginType_ == KDLoginViewTypePhoneNumInput)
                userNameTextField_.textFieldMain.text = [BOSSetting sharedSetting].userName;
            
            [self getTokenWithEId:nil];
            
            [BOSConfig sharedConfig].isLoginWithOpenAccount = YES;
            
            
            self.verifyNav = nil;
            
        }];
    }
}
#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_iosURL]];
            break;
        case 2:
            if (buttonIndex != alertView.cancelButtonIndex) {
                UITextField *field = [alertView textFieldAtIndex:0];
                [self deviceLicenceApply:field.text];
            }
            break;
        case 10:
            if (buttonIndex != alertView.cancelButtonIndex)
                [self gotoCompanyCreateView];
            break;
        case 0x99:
            if (buttonIndex != alertView.cancelButtonIndex)
                [self startGetPhoneCode];
            break;
            //A.wang 邮箱验证
        case 0x100:
            if (buttonIndex != alertView.cancelButtonIndex)
                [self startGetEmailCode:NO];
            break;
        case 0x101:
            if (buttonIndex != alertView.cancelButtonIndex)
                [self startGetEmailCode:YES];
            break;
            
        default:
            break;
    }
}

#pragma mark - 获取邀请人信息
- (void)invitedByPersonChannelWithToken:(NSString *)token toCompany:(NSString *)eid {
    
    [self startLoadingInvitedInfo];
    
    KDQuery *query = [KDQuery queryWithName:@"token" value:token];
    [query setParameter:@"kingdee_invite_eid" stringValue:eid];
    
    NSString *sourceURL = [[KDWeiboServicesContext defaultContext] serverBaseURL];
    sourceURL = [NSString stringWithFormat:@"%@%@", sourceURL, @"/invite/c/getUserByToken"];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results != nil) {
            if ([results isKindOfClass:[NSDictionary class]]) {
                
                BOOL success = [results boolForKey:@"success"];
                if (success) {
                    NSDictionary *data = [results objectNotNSNullForKey:@"data"];
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        NSString *username = [data stringForKey:@"username"];
                        NSString *companyname = [data stringForKey:@"companyName"];
                        NSString *photourl = [data stringForKey:@"photoPath"];
                        
                        UILabel *nameLabel = (UILabel *)[self.contentView viewWithTag:0x99];
                        UILabel *companyLabel = (UILabel *)[self.contentView viewWithTag:0x98];
                        nameLabel.text = [username stringByAppendingString:ASLocalizedString(@"KDAuthViewController_invite")];
                        companyLabel.text = companyname;
                        [self.avatarView setImageWithURL:[NSURL URLWithString:photourl] placeholderImage:[UIImage imageNamed:@"login_tip_logo"]];
                    }
                }
            }
        }
        
        [self endLoadingInvitedInfo];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/network/:getInvitePersonInfo" query:query
                                 configBlock:^(KDServiceActionInvoker *invoker){
                                     [invoker resetRequestURL:sourceURL];
                                 }
                             completionBlock:completionBlock];
}

#pragma mark - KDLinkInviteDelegate method

- (void)inviteFinishedBecauseOfAlreadyInCompany:(NSString *)eid{
    
    [self getTokenWithEId:eid];
    [[KDLinkInviteConfig sharedInstance] setDelegate:nil];
}

- (KDInputView *)setupPasswordTextField {
    if (!passwordTextField_) {
        UIImage *image = [UIImage imageNamed:@"login_btn_eye_bukejian_blue"];
        CGSize size = image.size;
        passwordTextField_ = [[KDInputView alloc] initWithElement:KDInputViewElementImageViewLeft | KDInputViewElementButtonRight];
        passwordTextField_.textFieldMain.delegate = self;
        passwordTextField_.textFieldMain.secureTextEntry = YES;
        passwordTextField_.textFieldMain.autocapitalizationType = UITextAutocapitalizationTypeNone;
        passwordTextField_.textFieldMain.autocorrectionType = UITextAutocorrectionTypeNo;
        passwordTextField_.textFieldMain.returnKeyType = UIReturnKeyDone;
        passwordTextField_.textFieldMain.keyboardType = UIKeyboardTypeASCIICapable;
        passwordTextField_.textFieldMain.placeholder = ASLocalizedString(@"KDAuthViewController_psw");
        
        passwordTextField_.fButtonRightWidth = size.width;
        
        [passwordTextField_.buttonRight setImage:image forState:UIControlStateNormal];
        __weak __typeof (self) weakSelf = self;
        passwordTextField_.blockButtonRightPressed = ^(UIButton *button) {
            [weakSelf buttonSecurePressed];
        };
        
        passwordTextField_.imageViewLeft.image = [UIImage imageNamed:@"login_tip_password"];
    }
    return passwordTextField_;
}

// 点击显示密码明文
- (void)buttonSecurePressed {
    //add
    [KDEventAnalysis event:event_lpwd_visible];
    [KDEventAnalysis eventCountly:event_lpwd_visible];
    // 防止密文切换 光标移位
    NSString *tempStr = self.passwordTextField.textFieldMain.text;
    self.passwordTextField.textFieldMain.text = nil;
    self.passwordTextField.textFieldMain.text = tempStr;
    [self.passwordTextField.textFieldMain setFont:nil];
    [self.passwordTextField.textFieldMain setFont:FS3];

    [self.passwordTextField.textFieldMain setSecureTextEntry:!self.passwordTextField.textFieldMain.secureTextEntry];
    if (self.passwordTextField.textFieldMain.secureTextEntry) {

        [self.passwordTextField.buttonRight setImage:[UIImage imageNamed:@"login_btn_eye_bukejian_blue"] forState:UIControlStateNormal];
    }
    else {
        self.isChangeSecureText = YES;
        self.passwordTextField.textFieldMain.keyboardType = UIKeyboardTypeASCIICapable;
        [self.passwordTextField.buttonRight setImage:[UIImage imageNamed:@"login_btn_eye_kejie_bule"] forState:UIControlStateNormal];
    }
    [self.passwordTextField.textFieldMain becomeFirstResponder];
}

@end
