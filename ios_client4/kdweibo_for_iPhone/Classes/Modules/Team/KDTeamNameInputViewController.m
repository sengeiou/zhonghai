//
//  KDTeamNameInputViewController.m
//  kdweibo
//
//  Created by bird on 14-4-22.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDTeamNameInputViewController.h"
#import "XTOpenSystemClient.h"
#import "UIButton+XT.h"
#import "BOSSetting.h"
#import "XTOpenConfig.h"
#import "MBProgressHUD.h"
#import "ContactConfig.h"
#import "BOSConfig.h"

@interface KDTeamNameInputViewController ()
@property (retain, nonatomic) NSString *eId;
@property (retain, nonatomic) NSString *companyName;

@property (retain, nonatomic) XTOpenSystemClient *openClient;
@property (retain, nonatomic) UITextField *nameField;
@property (nonatomic, retain) MBProgressHUD *progressHUD;
@end

@implementation KDTeamNameInputViewController

- (id)initWithEId:(NSString *)eid companyName:(NSString *)companyName
{
    self = [super init];
    if (self) {
        self.eId = eid;
        self.companyName = companyName;
    }
    return self;
}
- (void)dealloc
{
    //[super dealloc];
    
    //KD_RELEASE_SAFELY(_eId);
    //KD_RELEASE_SAFELY(_companyName);
    //KD_RELEASE_SAFELY(_openClient);
    //KD_RELEASE_SAFELY(_nameField);
    //KD_RELEASE_SAFELY(_progressHUD);
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.nameField becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = MESSAGE_BG_COLOR;
    self.navigationItem.title = ASLocalizedString(@"KDTeamNameInputViewController_navigationItem_title");

    // Do any additional setup after loading the view.
    UIImage *bgImage = [UIImage imageNamed:@"textfield_bg_v3"];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width * 0.5f topCapHeight:bgImage.size.height * 0.5f];
    
    _nameField = [[UITextField alloc] initWithFrame:CGRectMake(15.0f, 30.0f, CGRectGetWidth(self.view.bounds) - 30.0f, 48.0f)];
    _nameField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _nameField.background = bgImage;
    _nameField.font = [UIFont systemFontOfSize:15.0f];
    _nameField.textColor = RGBCOLOR(62, 62, 62);
    _nameField.placeholder = ASLocalizedString(@"姓名");
    
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
    _nameField.leftView = left;
    _nameField.leftViewMode = UITextFieldViewModeAlways;
//    [left release];
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 48.0f)];
    _nameField.rightView = right;
    _nameField.rightViewMode = UITextFieldViewModeAlways;
//    [right release];
    
    [self.view addSubview:_nameField];    if ([BOSConfig sharedConfig].user.name.length > 0) {
        _nameField.text = [BOSConfig sharedConfig].user.name;
    }
    self.nameField = _nameField;
    [self.view addSubview:_nameField];
    
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.backgroundColor = RGBACOLOR(23, 131, 253, 1.0f);
    confirmButton.layer.cornerRadius = 5.0f;
    confirmButton.layer.masksToBounds = YES;
    [confirmButton setTitle:ASLocalizedString(@"KDCompanyChoseViewController_complete")forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [confirmButton addTarget:self action:@selector(finishClick) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.frame = CGRectMake(15.f, CGRectGetMaxY(_nameField.frame) + 20.f, 290, 41.f);
    [self.view addSubview:confirmButton];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)finishClick
{
    if (self.nameField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"请输入姓名")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [self.nameField resignFirstResponder];
    
    [self.progressHUD show:YES];
    
    self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(createCompanyDidReceived:result:)];
    [self.openClient createCompanyWithEId:self.eId phone:[BOSSetting sharedSetting].userName name:self.nameField.text];
}

- (void)createCompanyDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    [self.progressHUD hide:YES];
    
    BOOL needCreate = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(companyNeedInvitePerson)])
        needCreate = [_delegate companyNeedInvitePerson];
    
    [XTOpenConfig sharedConfig].isCreater = needCreate;
    
    if (result.success) {
        [self finishCreate];
        return;
    }
    
    NSString *error = result.error;
    if (client.hasError) {
        error = client.errorMessage;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
    [alert show];
}

- (void)finishCreate
{
    if (_delegate && [_delegate respondsToSelector:@selector(companyDidCreate:company:)]) {
        
        XTOpenCompanyDataModel *company = [[XTOpenCompanyDataModel alloc] init];
        company.companyId = self.eId;
        company.companyName = self.companyName;
        [_delegate companyDidCreate:self company:company];
//        [company release];
    }
}

@end
