//
//  EdidGroupNameViewController.m
//  ContactsLite
//
//  Created by kingdee eas on 13-2-28.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import "XTModifyGroupNameViewController.h"
#import "UIButton+XT.h"
#import "GroupDataModel.h"
#import "MBProgressHUD.h"
#import "ContactClient.h"

@interface XTModifyGroupNameViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, strong) UITextField *groupNameTextField;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ContactClient *modifyClient;

@property (nonatomic, strong) KDInputView *inputGroupNameView;

@end

@implementation XTModifyGroupNameViewController


- (id)initWithGroup:(GroupDataModel *)group
{
    self = [super init];
    if (self) {
        self.group = group;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [_groupNameTextField resignFirstResponder];
     [self.inputGroupNameView.textFieldMain resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    self.title= ASLocalizedString(@"XTChatDetailViewController_Group_Name");
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"Global_Sure")style:UIBarButtonItemStylePlain target:self action:@selector(doneBtnClick:)]];
//    UIButton *doneBtn = [UIButton buttonWithTitle:ASLocalizedString(@"Global_Sure")];
//    [doneBtn addTarget:self action:@selector(doneBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneBtn];
//    self.navigationItem.rightBarButtonItems = @[doneItem];
    
//    self.groupNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(15.0, 11.0, ScreenFullWidth - 30.0, 44.0)];
//    self.groupNameTextField.layer.cornerRadius = 5.0;
//    self.groupNameTextField.layer.borderWidth = 1.0;
//    self.groupNameTextField.layer.borderColor = BOSCOLORWITHRGBA(0xCFCFCF, 1.0).CGColor;
//    self.groupNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    self.groupNameTextField.backgroundColor = [UIColor whiteColor];
//    self.groupNameTextField.font = [UIFont systemFontOfSize:14.0];
//    self.groupNameTextField.text = self.group.groupName;
//
//    UILabel *paddingView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 44.0)];
//    paddingView.backgroundColor = [UIColor clearColor];
//    self.groupNameTextField.leftView = paddingView;
//    self.groupNameTextField.leftViewMode = UITextFieldViewModeAlways;
//    [self.view addSubview:self.groupNameTextField];
//    [self.groupNameTextField makeConstraints:^(MASConstraintMaker *make)
//     {
//         make.left.equalTo(self.view.left).with.offset(12);
//         make.right.equalTo(self.view.right).with.offset(-12);
//         make.top.equalTo(self.view.top).with.offset(76);
//         make.height.mas_equalTo(44);
//     }];
//
//    
//    [self.groupNameTextField becomeFirstResponder];
    [self.view addSubview:self.inputGroupNameView];
    
    [self.inputGroupNameView makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(12);
         make.right.equalTo(self.view.right).with.offset(-12);
         make.top.equalTo(self.view.top).with.offset(kd_StatusBarAndNaviHeight + 12);
         make.height.mas_equalTo(44);
     }];
    [self.inputGroupNameView.textFieldMain becomeFirstResponder];
  
}

- (MBProgressHUD *)hud
{
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    return _hud;
}

-(void)doneBtnClick:(id)sender
{
    if (self.inputGroupNameView.textFieldMain.text.length == 0) {
        return;
    }
    
    [self.inputGroupNameView.textFieldMain resignFirstResponder];
    
    if ([self.inputGroupNameView.textFieldMain.text isEqualToString:self.group.groupName]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (self.modifyClient == nil) {
        self.modifyClient = [[ContactClient alloc] initWithTarget:self action:@selector(modifyGroupNameDidReceived:result:)];
    }
    
    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    [self.modifyClient updateGroupNameWithGroupID:self.group.groupId groupName:self.inputGroupNameView.textFieldMain.text];
}


- (void)modifyGroupNameDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        [self.hud setLabelText:result.error.length>0 ? result.error : ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    
    [self.hud setLabelText:ASLocalizedString(@"XTChatDetailViewController_Success")];
    [self.hud setMode:MBProgressHUDModeText];
    [self.hud hide:YES afterDelay:1.0];
    [self performSelector:@selector(modifyFinish) withObject:nil afterDelay:1.0];
}

- (void)modifyFinish
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyGroupNameDidFinish:groupName:)]) {
        [self.delegate modifyGroupNameDidFinish:self groupName:self.inputGroupNameView.textFieldMain.text];
    }
    [self.inputGroupNameView.textFieldMain resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];

}
- (KDInputView *)inputGroupNameView
{
    if (!_inputGroupNameView)
    {
        _inputGroupNameView = [[KDInputView alloc] initWithElement:KDInputViewElementNone];
        _inputGroupNameView.textFieldMain.secureTextEntry = NO;
        _inputGroupNameView.textFieldMain.returnKeyType = UIReturnKeyDone;
        _inputGroupNameView.textFieldMain.text = self.group.groupName;
        _inputGroupNameView.textFieldMain.placeholder = ASLocalizedString(@"XTModifyGroupNameViewController_ChatName");
        _inputGroupNameView.textFieldMain.delegate = self;
    }
    return _inputGroupNameView;
}


@end
