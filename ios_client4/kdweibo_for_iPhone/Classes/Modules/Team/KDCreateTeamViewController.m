//
//  KDCreateTeamViewController.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDCreateTeamViewController.h"
#import "KDCommon.h"
#import "KDInvitePhoneContactsViewController.h"
#import "KDPreInvitePersonViewController.h"
#import "KDWeiboServices.h"
#import "KDWeiboServicesContext.h"
#import "KDAccountTipView.h"
#import "MBProgressHUD.h"
#import "KDABRecord.h"
#import "SBJSON.h"
#import "XTOpenConfig.h"
#import "MCloudClient.h"
#import "BOSSetting.h"
#import "MBProgressHUD.h"
#import "XTSetting.h"
#import "KDPhoneInputViewController.h"
#import "BOSConfig.h"

#define KD_CREATE_TEAM_FONT_SIZE 15.0f

NSString *const KDCreateTeamFinishedNotification = @"kd_create_team_finished_notification";

@interface KDCreateTeamViewController () <UITextFieldDelegate, XTCompanyDelegate, KDLoginPwdConfirmDelegate>
{
    UITextField *teamNameTextField_;
    UITextField *userNameTextField_;
    UILabel     *invitePersonNumberLabel_;
//    UIButton    *createButton_;
    
    NSMutableArray *inviteContacts_;
    
    int     fistLoad_;
}
@property (retain, nonatomic) MCloudClient *mcloudClient;
@property (retain, nonatomic) XTOpenSystemClient *openClient;
@property (retain, nonatomic) NSString *eId;
@property (retain, nonatomic) UIButton   *createButton;
@property (nonatomic, strong) KDInputView *inputTeamNameField;
@end

@implementation KDCreateTeamViewController

@synthesize didSignIn = _didSignIn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = ASLocalizedString(@"KDCreateTeamViewController_create_com");
        inviteContacts_ = [[NSMutableArray alloc] initWithCapacity:2];
        _didSignIn = NO;
        fistLoad_ = NO;
    }
    return self;
}
- (KDInputView *)inputTeamNameField
{
    if (!_inputTeamNameField)
    {
        _inputTeamNameField = [[KDInputView alloc] initWithElement:KDInputViewElementNone];
        _inputTeamNameField.textFieldMain.secureTextEntry = NO;
        _inputTeamNameField.textFieldMain.returnKeyType = UIReturnKeyDone;
        _inputTeamNameField.textFieldMain.font = [UIFont systemFontOfSize:14];
        _inputTeamNameField.textFieldMain.placeholder = ASLocalizedString(@"KDCreateTeamViewController_com_name");
        _inputTeamNameField.textFieldMain.delegate = self;
    }
    return _inputTeamNameField;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_eId);
    //KD_RELEASE_SAFELY(teamNameTextField_);
    //KD_RELEASE_SAFELY(invitePersonNumberLabel_);
//    //KD_RELEASE_SAFELY(createButton);
    //KD_RELEASE_SAFELY(inviteContacts_);
    //KD_RELEASE_SAFELY(_mcloudClient);
    //KD_RELEASE_SAFELY(_openClient);
    
    //[super dealloc];
}

- (BOOL)resignFirstResponder
{
    [teamNameTextField_ resignFirstResponder];
    [userNameTextField_ resignFirstResponder];
    return [super resignFirstResponder];
}

#define kTIPSLABELFONTSIZE 14.0f
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (fistLoad_)
        [_inputTeamNameField becomeFirstResponder];
    fistLoad_ = NO;

//    if(self.bHideBackButton)
//        self.navigationItem.leftBarButtonItem = nil;
//    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    

    [self.view addSubview:self.inputTeamNameField];
    
    [self.inputTeamNameField makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(12);
         make.right.equalTo(self.view.right).with.offset(-12);
         make.top.equalTo(self.view.top).with.offset(kd_StatusBarAndNaviHeight + 12);
         make.height.mas_equalTo(45);
     }];
    
//    if (self.text) {
//        self.inputTeamNameField.textFieldMain.text = self.text;
//
//    else {
//        [self.inputTeamNameField.textFieldMain becomeFirstResponder];
//    }
    
    UILabel *tipsForTeamName = [UILabel new];
    tipsForTeamName.numberOfLines = 0;
    tipsForTeamName.backgroundColor = [UIColor clearColor];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:ASLocalizedString(@"KDCreateTeamViewController_tips_only")attributes:nil];
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:8];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [attributedString length])];
    
    tipsForTeamName.attributedText = attributedString;
    tipsForTeamName.textColor =FC2;
    tipsForTeamName.font = FS8;
    tipsForTeamName.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tipsForTeamName];
    
    [tipsForTeamName makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(12);
         make.right.equalTo(self.view.right).with.offset(-12);
         make.top.equalTo(self.inputTeamNameField.bottom).with.offset(15);
         make.height.mas_equalTo(40);
     }];
    
    
    self.createButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDCreateTaskViewController_create")];
    
    
    self.createButton.titleLabel.font = FS2;
    [self.createButton addTarget:self action:@selector(create:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.createButton];
    
    [self.createButton makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(12);
         make.right.equalTo(self.view.right).with.offset(-12);
         make.top.equalTo(tipsForTeamName.bottom).with.offset(20);
         make.height.mas_equalTo(44);
         make.centerX.equalTo(self.view.centerX);
     }];
    
    [self.createButton setCircle];
    
    if (_fromType == KDCreateTeamFromTypeDidLogin) {
        [KDEventAnalysis event:event_band_create_open attributes:@{label_band_create_open_createType: label_band_create_open_createType_other}];
    }
    else {
        [KDEventAnalysis event:event_band_create_open attributes:@{label_band_create_open_createType: label_band_create_open_createType_first}];
    }

    
//    if (self.umengType == nil) {
//        self.umengType = label_invite_company_create_type_add;
//    }
//    [KDEventAnalysis event:event_invite_company_create_type attributes:@{label_invite_company_create_type : self.umengType}];
    
    
//	// Do any additional setup after loading the view.
//    UIImage *bgImage = [UIImage imageNamed:@"textfield_bg_v3"];
//    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width * 0.5f topCapHeight:bgImage.size.height * 0.5f];
//    
//    teamNameTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(15.0f, 30.0f + 64, CGRectGetWidth(self.view.bounds) - 30.0f, 48.0f)];
//    teamNameTextField_.delegate = self;
//    teamNameTextField_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    teamNameTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    teamNameTextField_.background = bgImage;
//    teamNameTextField_.font = [UIFont systemFontOfSize:15.0f];
//    teamNameTextField_.textColor = RGBCOLOR(62, 62, 62);
//    teamNameTextField_.placeholder = ASLocalizedString(@"KDCreateTeamViewController_com_name2");
//    
//    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
//    teamNameTextField_.leftView = left;
//    teamNameTextField_.leftViewMode = UITextFieldViewModeAlways;
//    [left release];
//    
//    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
//    teamNameTextField_.rightView = right;
//    teamNameTextField_.rightViewMode = UITextFieldViewModeAlways;
//    [right release];
//    
//    [self.view addSubview:teamNameTextField_];
//    
//    teamNameTextField_.textColor = [UIColor darkTextColor];
//    teamNameTextField_.returnKeyType = UIReturnKeyNext;
//    
    userNameTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(15.f, CGRectGetMaxY(teamNameTextField_.frame) +15.f, CGRectGetWidth(self.view.bounds) - 30.f, 48.f)];

    userNameTextField_.delegate = self;
    userNameTextField_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    userNameTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    userNameTextField_.background  = bgImage;
    userNameTextField_.font = [UIFont systemFontOfSize:15.f];
    userNameTextField_.textColor = [UIColor darkGrayColor];
    userNameTextField_.placeholder = ASLocalizedString(@"KDCreateTeamViewController_com_name3");
    if (_fromType == KDCreateTeamFromTypeDidLogin) {
        
        userNameTextField_.text = [BOSConfig sharedConfig].user.name;
        userNameTextField_.enabled = NO;
        userNameTextField_.textColor = [UIColor grayColor];
    }

    
//    left = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
//    userNameTextField_.leftView = left;
//    userNameTextField_.leftViewMode = UITextFieldViewModeAlways;
//    [left release];
//    
//    right = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
//    userNameTextField_.rightView = right;
//    userNameTextField_.rightViewMode = UITextFieldViewModeAlways;
//    [right release];
//
//    [self.view addSubview:userNameTextField_];
//    
//    
//    userNameTextField_.returnKeyType = UIReturnKeyDone;
//    
//    UILabel *tipsForTeamName = [[[UILabel alloc] initWithFrame:CGRectMake(15.0f, CGRectGetMaxY(userNameTextField_.frame) + 5.0f, CGRectGetWidth(userNameTextField_.frame), 18.0f*3)] autorelease];
//    tipsForTeamName.numberOfLines = 0;
//    tipsForTeamName.backgroundColor = [UIColor clearColor];
//    tipsForTeamName.text = ASLocalizedString(@"KDCreateTeamViewController_tips_only");
//    tipsForTeamName.textColor = RGBCOLOR(109, 109, 109);
//    tipsForTeamName.font = [UIFont systemFontOfSize:kTIPSLABELFONTSIZE];
//    [self.view addSubview:tipsForTeamName];
//    
//    invitePersonNumberLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
//    invitePersonNumberLabel_.backgroundColor = [UIColor clearColor];
//    invitePersonNumberLabel_.textColor = RGBCOLOR(23, 131, 253);
//    
//    createButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//    [createButton_ addTarget:self action:@selector(create:) forControlEvents:UIControlEventTouchUpInside];
//    [createButton_ setTitle:ASLocalizedString(@"完成")forState:UIControlStateNormal];
//    [createButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    createButton_.layer.cornerRadius = 5.0f;
//    createButton_.layer.masksToBounds = YES;
//    createButton_.backgroundColor = RGBCOLOR(23, 131, 253);
//    createButton_.frame = CGRectMake(15.0f, CGRectGetMaxY(tipsForTeamName.frame) + 20.0f, CGRectGetWidth(self.view.bounds) - 30.0f, 41.0f);
//    [self.view addSubview:createButton_];
//    
//    if(!isAboveiPhone5){
//        userNameTextField_.frame = CGRectMake(15.f, CGRectGetMaxY(teamNameTextField_.frame) +10.f, CGRectGetWidth(self.view.bounds) - 30.f, 48.f);
//        tipsForTeamName.frame = CGRectMake(15.0f, CGRectGetMaxY(userNameTextField_.frame) + 18.0f, CGRectGetWidth(userNameTextField_.frame), 18.0f*3);
//    }
//    
//    if (_fromType == KDCreateTeamFromTypeDidLogin) {
//        [KDEventAnalysis event:event_band_create_open attributes:@{label_band_create_open_createType: label_band_create_open_createType_other}];
//    }
//    else {
//        [KDEventAnalysis event:event_band_create_open attributes:@{label_band_create_open_createType: label_band_create_open_createType_first}];
//    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateInvitePersonNumberLabel];
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
    [alert show];
//    [alert release];
}

- (void)gotoTeamHomePage
{
    //after user clicked "进入团队", goto public timeline
    [[NSNotificationCenter defaultCenter] postNotificationName:KDCreateTeamFinishedNotification object:nil userInfo:nil];
}

- (NSString *)teamMemberString
{
    if(inviteContacts_.count == 0) return nil;
    
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:2];
    
    for(KDABRecord *record in inviteContacts_) {
        if(record.phoneNumber && record.phoneNumber.length > 0) {
            [result appendString:record.phoneNumber];
            [result appendString:@","];
        }
    }
    
    if([result hasSuffix:@","]) {
        [result deleteCharactersInRange:NSMakeRange(result.length - 1, 1)];
    }
    
    return result;// autorelease];
}

#pragma mark - Network Methods
- (void)createTeam
{
    [teamNameTextField_ resignFirstResponder];
    [userNameTextField_ resignFirstResponder];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.mcloudClient = [[MCloudClient alloc] initWithTarget:self action:@selector(registerDidReceived:result:)];// autorelease];
    
    NSString *phoneNum = [BOSSetting sharedSetting].userName;
    if (_fromType == KDCreateTeamFromTypeUnLogin) {
        phoneNum = [BOSSetting sharedSetting].userName;
    }
    else if(_fromType == KDCreateTeamFromTypeDidLogin){
        phoneNum = [BOSConfig sharedConfig].user.phone;
    }

    [self.mcloudClient registerWithCustName:self.inputTeamNameField.textFieldMain.text phone:phoneNum name:userNameTextField_.text];
}

- (void)registerDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    if (result.success && result.data && [result.data isKindOfClass:[NSDictionary class]]) {
        
        NSString *eId = result.data[@"eid"];
       
        if (eId.length > 0) {
            
            self.eId = eId;
            
            [self createCompany];
            
            return;
        }
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSString *error = result.error;
    if (client.hasError) {
        error = client.errorMessage;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
    [alert show];
//    [alert release];
}
- (void)createCompany
{
    self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(createCompanyDidReceived:result:)] ;//autorelease];
    
    NSString *phoneNum = [BOSSetting sharedSetting].userName;
    if (_fromType == KDCreateTeamFromTypeUnLogin) {
        phoneNum = [BOSSetting sharedSetting].userName;
    }
    else if(_fromType == KDCreateTeamFromTypeDidLogin){
        phoneNum = [BOSConfig sharedConfig].user.phone;
    }

    [self.openClient createCompanyWithEId:_eId phone:phoneNum name:userNameTextField_.text];
}
- (void)createCompanyDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if (result.success) {
        
        [KDEventAnalysis event:event_band_create_ok];
        
        [XTOpenConfig sharedConfig].isCreater = YES;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:ASLocalizedString(@"KDCreateTeamViewController_tips_create_suc")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];// autorelease];
        [alertView setTag:0x99];
        [alertView show];
        
        return;
    }
    
    self.eId = nil;
    
    NSString *error = result.error;
    if (client.hasError) {
        error = client.errorMessage;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
    [alert show];
//   / [alert release];
}

- (void)finishCreate
{
    if (_delegate == nil)
    {
        CompanyDataModel *company = [[CompanyDataModel alloc] init];
        company.eid = self.eId;
        company.wbNetworkId = self.eId;
        company.name = [teamNameTextField_ text];

        [[NSNotificationCenter defaultCenter] postNotificationName:KDCreateTeamFinishedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:company forKey:@"company"]];
        
//        [company release];

    }
    else
    {
        if (_delegate && [_delegate respondsToSelector:@selector(companyDidCreate:company:)]) {
            
            XTOpenCompanyDataModel *company = [[XTOpenCompanyDataModel alloc] init];
            company.companyId = self.eId;
            company.companyName = [teamNameTextField_ text];
            [_delegate companyDidCreate:self company:company];
//            [company release];
        }
    }
    
 
}
#pragma mark - UITouch methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_inputTeamNameField resignFirstResponder];
//    [userNameTextField_ resignFirstResponder];
}

#pragma mark - Private Methods
- (void)tapGesture:(UITapGestureRecognizer *)tap
{
    KDInvitePhoneContactsViewController *invite = [[KDInvitePhoneContactsViewController alloc] initWithNibName:nil bundle:nil];// autorelease];
    invite.invitePeople = inviteContacts_;
    [self.navigationController pushViewController:invite animated:YES];
}

- (void)create:(id)sender
{
    if([self.inputTeamNameField.textFieldMain isFirstResponder] && [self.inputTeamNameField.textFieldMain canResignFirstResponder]) {
        [self.inputTeamNameField.textFieldMain resignFirstResponder];
    }
//    if([userNameTextField_ isFirstResponder] && [userNameTextField_ canResignFirstResponder]) {
//        [userNameTextField_ resignFirstResponder];
//    }
//    
//    if(self.inputTeamNameField.textFieldMain.text.length > 0 && userNameTextField_.text.length > 0) {
    if(self.inputTeamNameField.textFieldMain.text.length > 0 )
    {
        NSString *inputText = self.inputTeamNameField.textFieldMain.text;
        int count = 0;
        for (int i = 0; i<inputText.length; i++) {
            unichar c = [inputText characterAtIndex:i];
            if (c >=0x4E00 && c <=0x9FA5)
            {
                count++;
            }
        }
        if(count == inputText.length)
        {
            if(inputText.length>16)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:ASLocalizedString(@"KDCreateTeamViewController_tips_name_over")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                [alert show];
//                [alert release];
                return;
            }
        }
        else
        {
            const char   *cString = [inputText UTF8String];
            if (strlen(cString) >40)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:ASLocalizedString(@"KDCreateTeamViewController_tips_name_over")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                [alert show];
//                [alert release];
                return;
            }
        }
        
        if (_fromType == KDCreateTeamFromTypeUnLogin) {
            
            if ([self isNumText:[BOSSetting sharedSetting].userName]) {
                [self createTeam];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDCreateTeamViewController_create_new_com")message:[NSString stringWithFormat:ASLocalizedString(@"KDCreateTeamViewController_tips_create_fail"),KD_APPNAME] delegate:nil cancelButtonTitle:ASLocalizedString(@"KDAuthViewController_ok")otherButtonTitles:nil, nil];
                [alertView show];
//                [alertView release];
            }
        }
        else if(_fromType == KDCreateTeamFromTypeDidLogin)
        {
            if ([self isNumText:[BOSSetting sharedSetting].userName]) {
                
                [self createTeam];
            }
            else{
                
                if ([[BOSConfig sharedConfig].user.phone length] == 0) {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDCreateTeamViewController_bind_mobile")message:ASLocalizedString(@"KDCreateTeamViewController_tips_un_bind")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDAuthViewController_ok"), nil];
                    [alertView setDelegate:self];
                    [alertView show];
//                    [alertView release];
                }
                else
                {
                    [self createTeam];
                }
                
//                [self getPhone];
            }
        }
        
    }else {
//        if (teamNameTextField_.text.length > 0) {
//            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDCreateTeamViewController_input_name")message:nil delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
//            [alert show];
//        }
//        else
//        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDCreateTeamViewController_input_name2")message:nil delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
//            [alert release];
//        }
    }
}
- (void)bindPhone
{
    KDPhoneInputViewController *ctr = [[KDPhoneInputViewController alloc] init];
    ctr.type = KDPhoneInputTypeBind;
    ctr.delegate = self;
    [self.navigationController pushViewController:ctr animated:YES];
//    [ctr release];
}
- (void)updateInvitePersonNumberLabel
{
    UIView *contentView = [[invitePersonNumberLabel_ superview] superview];
    invitePersonNumberLabel_.text = inviteContacts_.count > 0 ? [NSString stringWithFormat:ASLocalizedString(@"KDCreateTeamViewController_tips_count"), (unsigned long)inviteContacts_.count] : nil;

    [invitePersonNumberLabel_ sizeToFit];
    
    invitePersonNumberLabel_.frame = CGRectMake(CGRectGetWidth(contentView.frame) - CGRectGetWidth(invitePersonNumberLabel_.bounds) - 30.0f, (CGRectGetHeight(contentView.bounds) - CGRectGetHeight(invitePersonNumberLabel_.bounds)) * 0.5f, CGRectGetWidth(invitePersonNumberLabel_.bounds), CGRectGetHeight(invitePersonNumberLabel_.bounds));
}

//是否是纯数字

- (BOOL)isNumText:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0x99) {
        
        [self finishCreate];
    }
    else{
    
        if (buttonIndex == 1) {
            [self bindPhone];
        }
    }
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:teamNameTextField_])
        [userNameTextField_ becomeFirstResponder];
    else
        [textField resignFirstResponder];
    return YES;
}
#pragma mark KDLoginPwdConfirmDelegate
- (void)authViewConfirmPwd
{
    [self.navigationController popToViewController:self animated:YES];
    
    [self createTeam];
}

#pragma mark XTCompanyDeleagte

- (void)companyDidCreate:(id)createCompanyViewController company:(XTOpenCompanyDataModel *)company
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KDCreateTeamFinishedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:company forKey:@"company"]];
}
- (BOOL)companyNeedInvitePerson
{
    return NO;
}
@end
