//
//  KDInviteByPhoneNumberViewController.m
//  kdweibo
//
//  Created by 王 松 on 14-4-18.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDInviteByPhoneNumberViewController.h"
#import "BOSPublicConfig.h"
#import "XTOpenSystemClient.h"
#import "XTOpenConfig.h"
#import "BOSSetting.h"
#import "BOSConfig.h"
#import "MBProgressHUD.h"
#import "XTInitializationManager.h"
#import "KDChooseDepartmentViewController.h"
#import "KDInputView.h"

#import <QuartzCore/QuartzCore.h>
#define labelLeftCap 15.0

@interface KDInviteByPhoneNumberViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate, KDChooseDepartmentViewControllerDelegate>

@property (nonatomic, retain) UITextField *phoneTextField;
//@property (nonatomic, retain) UITextField *nameTextField;
//@property (nonatomic, retain) UITextField *departTextField;

@property (nonatomic, retain) XTOpenSystemClient *openClient;

@property (nonatomic, retain) UIButton *inviteButton;
@property (nonatomic, retain) KDChooseDepartmentModel *chosedModel;
@property (nonatomic, retain) KDInputView *inputView;
@end

@implementation KDInviteByPhoneNumberViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
}
-(KDInputView *)inputView
{
    if (!_inputView)
    {
        _inputView = [[KDInputView alloc] initWithElement:KDInputViewElementNone];
        _inputView.textFieldMain.secureTextEntry = NO;
        _inputView.textFieldMain.returnKeyType = UIReturnKeyDone;
        _inputView.textFieldMain.placeholder = ASLocalizedString(@"请输入工作圈名称");
        _inputView.textFieldMain.delegate = self;
    }
    return _inputView;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_invitedUrl);
    //KD_RELEASE_SAFELY(_chosedModel);
    //KD_RELEASE_SAFELY(_inviteButton);
//    //KD_RELEASE_SAFELY(_nameTextField);
//    //KD_RELEASE_SAFELY(_departTextField);
    //KD_RELEASE_SAFELY(_phoneTextField);
    //KD_RELEASE_SAFELY(_openClient);
    //[super dealloc];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self tap];
}
- (void)setupViews
{
    self.view.backgroundColor = [UIColor kdBackgroundColor3];
    
    self.title = ASLocalizedString(@"KDInviteByPhoneNumberViewController_mobile_invite");
    
    [self.view addSubview:self.inputView];
    
    [self.inputView makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(12);
         make.right.equalTo(self.view.right).with.offset(-12);
         make.top.equalTo(self.view.top).with.offset(76);
         make.height.mas_equalTo(45);
     }];

//    UIImage *bgImage = [UIImage imageNamed:@"textfield_bg_v3"];
//    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width * 0.5f topCapHeight:bgImage.size.height * 0.5f];
//    
//    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(25.0f, 30.0f + 64, CGRectGetWidth(self.view.bounds) - 40.0f, 48.0f)];
//    _phoneTextField.delegate = self;
//    _phoneTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    _phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
//    _phoneTextField.background = bgImage;
//    _phoneTextField.font = [UIFont systemFontOfSize:15.0f];
//    _phoneTextField.textColor = RGBCOLOR(62, 62, 62);
//    
//    
//    
//    _phoneTextField.placeholder = ASLocalizedString(@"KDInviteByPhoneNumberViewController_tips_1");
    
//    UILabel *label=  [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_phoneTextField.frame) - 10, _phoneTextField.frame.origin.y + 6.f, 10, 48)];
//    label.backgroundColor = [UIColor clearColor];
//    label.textColor = MESSAGE_NAME_COLOR;
//    label.text = @"*";
//    label.font = [UIFont systemFontOfSize:20.f];
//    [self.view addSubview:label];
//    [label release];
//    
//    UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
//    _phoneTextField.leftView = left;
//    _phoneTextField.leftViewMode = UITextFieldViewModeAlways;
//    [left release];
//    
//    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
//    _phoneTextField.rightView = right;
//    _phoneTextField.rightViewMode = UITextFieldViewModeAlways;
//    [right release];
//    
//    [self.view addSubview:_phoneTextField];
//    
//    _phoneTextField.textColor = [UIColor darkTextColor];
//    _phoneTextField.returnKeyType = UIReturnKeyNext;
    
    /*
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(15.0f, CGRectGetMaxY(_phoneTextField.frame)+ 10.f, CGRectGetWidth(self.view.bounds) - 30.0f, 48.0f)];
    _nameTextField.delegate = self;
    _nameTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _nameTextField.background = bgImage;
    _nameTextField.font = [UIFont systemFontOfSize:15.0f];
    _nameTextField.textColor = RGBCOLOR(62, 62, 62);
    _nameTextField.placeholder = ASLocalizedString(@"KDInviteByPhoneNumberViewController_tips_2");
    
    left = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
    _nameTextField.leftView = left;
    _nameTextField.leftViewMode = UITextFieldViewModeAlways;
    [left release];
    
    right = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
    _nameTextField.rightView = right;
    _nameTextField.rightViewMode = UITextFieldViewModeAlways;
    [right release];
    
    [self.view addSubview:_nameTextField];
    
    _nameTextField.textColor = [UIColor darkTextColor];
    _nameTextField.returnKeyType = UIReturnKeyNext;
    
    
    label=  [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_nameTextField.frame) - 10, _nameTextField.frame.origin.y + 6.f, 10, 48)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = MESSAGE_NAME_COLOR;
    label.text = @"*";
    label.font = [UIFont systemFontOfSize:20.f];
    [self.view addSubview:label];
    [label release];
    
    _departTextField = [[UITextField alloc] initWithFrame:CGRectMake(15.0f, CGRectGetMaxY(_nameTextField.frame)+ 10.f, CGRectGetWidth(self.view.bounds) - 30.0f, 48.0f)];
    _departTextField.delegate = self;
    _departTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _departTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _departTextField.background = bgImage;
    _departTextField.font = [UIFont systemFontOfSize:15.0f];
    _departTextField.textColor = RGBCOLOR(62, 62, 62);
    _departTextField.placeholder = ASLocalizedString(@"选择要邀请同事的部门");
    
    left = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
    _departTextField.leftView = left;
    _departTextField.leftViewMode = UITextFieldViewModeAlways;
    [left release];
    
    
    UIButton *vectorImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [vectorImageBtn setImage:[UIImage imageNamed:@"common_img_vector"] forState:UIControlStateNormal];
    [vectorImageBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -260)];
    [vectorImageBtn addTarget:self action:@selector(gotoDepartmentChoseView) forControlEvents:UIControlEventTouchUpInside];
    vectorImageBtn.backgroundColor = [UIColor clearColor];
    vectorImageBtn.frame = _departTextField.frame;
    
//    _departTextField.rightView = vectorImageBtn;
//    _departTextField.rightViewMode = UITextFieldViewModeAlways;
    
    [self.view addSubview:_departTextField];
    [self.view addSubview:vectorImageBtn];
    
    _departTextField.textColor = [UIColor darkTextColor];
    _departTextField.returnKeyType = UIReturnKeyNext;
     */
    UILabel *infoLabel = [UILabel new];
    infoLabel.numberOfLines = 0;
    infoLabel.backgroundColor = [UIColor clearColor];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:ASLocalizedString(@"KDInviteByPhoneNumberViewController_tips_4"),KD_APPNAME] attributes:nil];
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:8];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [attributedString length])];
    
    infoLabel.attributedText = attributedString;
    infoLabel.textColor =FC2;
    infoLabel.font = FS8;
    infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:infoLabel];
    
    [infoLabel makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(12);
         make.right.equalTo(self.view.right).with.offset(-12);
         make.top.equalTo(self.inputView.bottom).with.offset(15);
         make.height.mas_equalTo(40);
     }];

    
//    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    infoLabel.backgroundColor = [UIColor clearColor];
//    infoLabel.text = [NSString stringWithFormat:ASLocalizedString(@"邀请完全免费\n由%@后台发送短信给输入的手机号码"),KD_APPNAME];
//    infoLabel.font = [UIFont systemFontOfSize:13];
//    infoLabel.numberOfLines = 2;
//    infoLabel.textAlignment = NSTextAlignmentCenter;
//    infoLabel.textColor = UIColorFromRGB(0x808080);
//    infoLabel.frame = CGRectMake(labelLeftCap, CGRectGetMaxY(self.phoneTextField.frame) + 10, CGRectGetWidth(self.view.frame) - labelLeftCap * 2 , 40);
//    [self.view addSubview:infoLabel];

    self.inviteButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDInviteByPhoneNumberViewController_invite")];
    [self.inviteButton setCircle];
    
    self.inviteButton.titleLabel.font = FS2;
    [self.inviteButton addTarget:self action:@selector(create:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.inviteButton];
    
    [self.inviteButton makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(12);
         make.right.equalTo(self.view.right).with.offset(-12);
         make.top.equalTo(infoLabel.bottom).with.offset(20);
         make.height.mas_equalTo(44);
         make.centerX.equalTo(self.view.centerX);
     }];
    

//    _inviteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//    [_inviteButton addTarget:self action:@selector(invite:) forControlEvents:UIControlEventTouchUpInside];
//    [_inviteButton setTitle:ASLocalizedString(@"KDInviteByPhoneNumberViewController_invite")forState:UIControlStateNormal];
//    [_inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    _inviteButton.layer.cornerRadius = 5.0f;
//    _inviteButton.layer.masksToBounds = YES;
//    _inviteButton.backgroundColor = RGBCOLOR(23, 131, 253);
//    _inviteButton.frame = CGRectMake(15.0f, CGRectGetMaxY(infoLabel.frame) + 10.0f, CGRectGetWidth(self.view.bounds) - 30.0f, 41.0f);
//    [self.view addSubview:_inviteButton];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
//    [gesture release];
}
- (void)gotoDepartmentChoseView{
    
    KDChooseDepartmentViewController *ctr = [[KDChooseDepartmentViewController alloc] init];
    ctr.delegate = self;
    [self.navigationController pushViewController:ctr animated:YES];
//    [ctr release];
    
}
- (void)tap
{
    [_phoneTextField resignFirstResponder];
//    [_nameTextField resignFirstResponder];
}

- (void)invite:(id)sender
{
//    if ([_nameTextField.text length] == 0) {
//        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"请填写完整信息")message:ASLocalizedString(@"邀请的同事姓名不能为空")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];
//        [alertView show];
//        [alertView release];
//        
//        return;
//    }
//    
    if ([self isPhoneNumber:_phoneTextField.text]) {
        
        [_phoneTextField resignFirstResponder];
//        [_nameTextField resignFirstResponder];
        
        [self invitePhoneContact];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDInviteByPhoneNumberViewController_mobile_error")message:ASLocalizedString(@"KDInviteByPhoneNumberViewController_mobile_unavailable")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];
        [alertView show];
//        [alertView release];
    }
}

- (BOOL)isPhoneNumber:(NSString *)number
{
    return number.length >0;
}

- (void)invitePhoneContact
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSMutableArray *perons = [[NSMutableArray alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];// autorelease];
    [dict setObject:[_phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"phone"];
    [dict setObject:@"" forKey:@"name"];
    if (_chosedModel) {

        [dict setObject:_chosedModel.strID forKey:@"orgId"];
        [dict setObject:_chosedModel.strName forKey:@"deparment"];
    }

    [perons addObject:dict];
    
    
    if (!self.openClient)
    {
        _openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(inviteDidReceived:result:)];
    }
    [self.openClient phoneInviteWithEId:[BOSSetting sharedSetting].cust3gNo eName:[BOSSetting sharedSetting].customerName persons:perons name:[BOSConfig sharedConfig].user.name openId:[BOSConfig sharedConfig].user.openId URL:_invitedUrl];
}

- (void)inviteDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel*)result
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if (client.hasError)
    {
        [hud hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
        self.openClient = nil;
        return;
    }
    
    self.openClient = nil;
    if (result.success)
    {
        [hud hide:YES];
        
        [[[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDInviteByPhoneNumberViewController_invite_suc")message:ASLocalizedString(@"KDInviteByPhoneNumberViewController_tips7")delegate:self cancelButtonTitle:ASLocalizedString(@"KDAgoraSDKManager_Tip_9")otherButtonTitles:ASLocalizedString(@"KDApplicationQueryAppsHelper_no"), nil] show];
        
        [[XTInitializationManager sharedInitializationManager] startInitializeCompletionBlock:nil failedBlock:nil];
        
		[KDEventAnalysis event:event_invite_send attributes:@{ label_invite_send_inviteType : label_invite_send_inviteType_phone }];

        return;
    }
    
    [hud hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
}

- (void)hide
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ([touch.view isKindOfClass:[UIButton class]]) ? NO : YES;;
}
#pragma mark - KDChooseDepartmentViewControllerDelegate
- (void)didChooseDepartmentModel:(KDChooseDepartmentModel *)model longName:(NSString *)longName{
    self.chosedModel= model;
//    _departTextField.text = model.strName;
}
#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:ASLocalizedString(@"KDAgoraSDKManager_Tip_9")]) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:ASLocalizedString(@"KDApplicationQueryAppsHelper_no")]) {
    
        _phoneTextField.text = @"";
//        _nameTextField.text = @"";
//        _departTextField.text = @"";
        self.chosedModel = nil;
    }
}
@end
