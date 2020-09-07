//
//  KDSignOutConfirmVC.m
//  kdweibo
//
//  Created by DarrenZheng on 14-9-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDSignOutConfirmVC.h"
#import "KDManagerContext.h"
#import "NSDictionary+Additions.h"
#import "CustomAlertView.h"
#import "BOSSetting.h"
#import "KDErrorDisplayView.h"
#import "KDDBManager.h"
#import "BOSConfig.h"
#import "KDTimelineManager.h"

@interface KDSignOutConfirmVC () <XTChooseContentViewControllerDelegate, CustomAlertViewDelegate>

@property (nonatomic, retain) UIImageView *imageViewLogo;
@property (nonatomic, retain) UILabel *labelTitle;
@property (nonatomic, retain) UILabel *labelMessage;
@property (nonatomic, copy) NSString *strCompanyName;
@property (nonatomic, retain) UIButton *buttonConfirm;
@property (nonatomic, retain) NSArray *currentSelectedPerson;

@end

@implementation KDSignOutConfirmVC

#define NAVI_TITLE ASLocalizedString(@"退出工作圈")
#define LABLE_TITLE ASLocalizedString(@"KDSignOutConfirmVC_LABLE_TITLE")
#define LABLE_MESSAGE ASLocalizedString(@"KDSignOutConfirmVC_LABLE_MESSAGE")
#define BUTTON_TITLE ASLocalizedString(@"KDSignOutConfirmVC_BUTTON_TITLE")
#define ALERT_TAG_SIGNOUT_SUCC 0x99
NSString *const KDQuitCompanyFinishedNotification = @"kd_quit_company_finished_notification";

#pragma mark - UI Setup -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [KDEventAnalysis event:event_settings_quitband_open];
    
    self.navigationItem.title = NAVI_TITLE;
    self.labelTitle.text = LABLE_TITLE;
    self.labelMessage.text = [NSString stringWithFormat:LABLE_MESSAGE,self.strCompanyName];
    [self.view setBackgroundColor:MESSAGE_BG_COLOR];
    [self.view addSubview:self.imageViewLogo];
    [self.view addSubview:self.labelTitle];
    [self.view addSubview:self.labelMessage];
    [self.view addSubview:self.buttonConfirm];
}

- (NSString *)strCompanyName
{
    if (!_strCompanyName)
    {
//        KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
//        _strCompanyName = userManager.currentUser.companyName;
        _strCompanyName = [[BOSSetting sharedSetting] customerName];
    }
    return _strCompanyName;
}

- (UIImageView *)imageViewLogo
{
    if (!_imageViewLogo)
    {
        _imageViewLogo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_img_tzgzq_normal"]];
        _imageViewLogo.frame = CGRectMake(119, 70, 82, 88);
    }
    return _imageViewLogo;
}

- (UILabel *)labelTitle
{
    if (!_labelTitle)
    {
        _labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(126, 175, 68, 21)];
        _labelTitle.font = [UIFont systemFontOfSize:16];
        _labelTitle.backgroundColor = [UIColor clearColor];
        _labelTitle.textColor = UIColorFromRGB(0x808080);
    }
    return _labelTitle;
}

- (UILabel *)labelMessage
{
    if (!_labelMessage)
    {
        _labelMessage = [[UILabel alloc]initWithFrame:CGRectMake(46, 199, 228, 67)];
        _labelMessage.font = [UIFont systemFontOfSize:14];
        _labelMessage.backgroundColor = [UIColor clearColor];
        _labelMessage.textAlignment = NSTextAlignmentCenter;
        _labelMessage.textColor = UIColorFromRGB(0x808080);
        _labelMessage.numberOfLines = 4;
    }
    return _labelMessage;
}

- (UIButton *)buttonConfirm
{
    if (!_buttonConfirm)
    {
        _buttonConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonConfirm addTarget:self action:@selector(buttonConfirmPressed) forControlEvents:UIControlEventTouchUpInside];
        _buttonConfirm.frame = CGRectMake(66, 316, 189, 42);
        [_buttonConfirm setTitle:BUTTON_TITLE forState:UIControlStateNormal];
        [_buttonConfirm setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [_buttonConfirm setBackgroundImage:[[UIImage imageNamed:@"app_btn_addapp2_normal"]  resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 20, 10)] forState:UIControlStateNormal];
        [_buttonConfirm setBackgroundImage:[[UIImage imageNamed:@"app_btn_addapp2_press"]   resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 20, 10)] forState:UIControlStateHighlighted];
    }
    return _buttonConfirm;
}


#pragma mark - STEP 0 用户点击退出工作圈按钮 -

- (void)buttonConfirmPressed
{
    // ->STEP 1
    [self showPasswordView];
}

#pragma mark - STEP 1 验证密码 -

- (void)showPasswordView
{
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithDelegate:self alertType:CustomAlertViewTypeInputAlert meesage:[NSString stringWithFormat:ASLocalizedString(@"如果要退出：%@"),[BOSSetting sharedSetting].customerName] title:ASLocalizedString(@"   退出确认")subTitle:[NSString stringWithFormat:ASLocalizedString(@"请输入%@密码"),KD_APPNAME] cancelButtonTitle:ASLocalizedString(@"Global_Cancel")doneButtonTitle:ASLocalizedString(@"Global_Sure")];
    [alertView show];
}

- (void)buttonClick:(CustomAlertView *)alertView atIndex:(NSInteger)index{
    
    if (index == 1)
    {
        if ([alertView.textField.text length] ==0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:[NSString stringWithFormat:ASLocalizedString(@"KDSignOutConfirmVC_Pwd_Nil"),KD_APPNAME]  delegate:nil cancelButtonTitle:ASLocalizedString(@"好的")otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
        }
        if (![alertView.textField.text isEqualToString:[BOSSetting sharedSetting].password])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:[NSString stringWithFormat:ASLocalizedString(@"KDSignOutConfirmVC_Pwd_Err"),KD_APPNAME] delegate:nil cancelButtonTitle:ASLocalizedString(@"好的")otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
        }
        // ->STEP 2
        [self requestIsNeedNextAdmin];
    }
}

#pragma mark - STEP 2 调用接口:是否需要制定管理员(isNeedNextAdmin.json) -

- (void)requestIsNeedNextAdmin
{
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response)
    {
        if (results != nil)
        {
            NSDictionary *info = results;
            BOOL bIsNeedNextAdmin= [info boolForKey:@"isNeedNextAdmin"];
            
            if (bIsNeedNextAdmin)
            {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:ASLocalizedString(@"KDSignOutConfirmVC_alertView_message_find_admin")delegate:self cancelButtonTitle:ASLocalizedString(@"好的")otherButtonTitles:nil, nil];
                alertView.tag = 0x98;
                [alertView show];
                
                // ->STEP 3
                
            }
            else
            {
                // ->STEP 4 不传管理员id
                [self requstTeamSignOutWithAdminUserIds:nil];
            }
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:self
                                  actionPath:@"/network/:isNeedNextAdmin"
                                       query:nil
                                 configBlock:nil
                             completionBlock:completionBlock];
}

#pragma mark - STEP 3 选人模块 -

- (void)choosePersons
{
    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentAdd];
    contentViewController.delegate = self;
    contentViewController.bSetAdmin = YES;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
}

// 选人回调 PersonSimpleDataModel in persons
- (void)chooseContentView:(XTChooseContentViewController *)controller persons:(NSArray *)persons
{
    NSMutableString *personStr = [NSMutableString string];
    NSMutableArray *mArrayPersonIds = [NSMutableArray new];
    int idx = 0;
    for (PersonSimpleDataModel *person in persons)
    {
        [mArrayPersonIds addObject:person.wbUserId];
        
        [personStr appendString:person.personName];
        
        if (idx <2) {
            
            if (idx != persons.count -1) {
                [personStr appendString:@"，"] ;
            }
        }
        idx++;
    }
    
    if (persons.count > 2) {
        [personStr appendFormat:ASLocalizedString(@"KDSignOutConfirmVC_personStr"),(unsigned long)persons.count];
    }
    
    self.currentSelectedPerson = mArrayPersonIds;
    
    NSString *msg = [NSString stringWithFormat:ASLocalizedString(@"KDSignOutConfirmVC_alertView_message_setting_admin"),personStr];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:msg delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"Global_Sure"), nil];
    alertView.tag = 0x97;
    [alertView show];
    
}

#pragma mark - STEP 4 调用接口:退出工作圈(sign-out.json) -

- (void)requstTeamSignOutWithAdminUserIds:(NSArray *)arrayAdminUserIds
{
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    __block KDSignOutConfirmVC *pvc = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response)
    {
        [MBProgressHUD hideHUDForView:self.view.window animated:YES];
        if([response isValidResponse])
        {
            if (results != nil)
            {
                if ([results boolForKey:@"success"])
                {
                    [KDEventAnalysis event:event_settings_quitband_ok];
                    // ->STEP 5
                    [self cleanCache];
                    
                    // ->STEP 6
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"成功")message:ASLocalizedString(@"退出工作圈成功！")delegate:self cancelButtonTitle:ASLocalizedString(@"好的")otherButtonTitles:nil, nil];
                    alertView.tag = ALERT_TAG_SIGNOUT_SUCC;
                    [alertView show];
                }
                else
                {
                    [KDErrorDisplayView showErrorMessage:[results stringForKey:@"errormsg"]
                                                  inView:pvc.view.window];
                }
            }
            else
            {
                [KDErrorDisplayView showErrorMessage:ASLocalizedString(@"退出工作圈失败")inView:pvc.view.window];
            }
        }
        else
        {
            if (![response isCancelled])
            {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:pvc.view.window];
            }
        }
    };
    
    // 多个id之间用半角逗号”,”隔开.
    KDQuery *query;
    if (arrayAdminUserIds.count > 0)
    {
        NSMutableString *mStrAdminUserIds = [NSMutableString new];
        for (NSString *str in arrayAdminUserIds)
        {
            [mStrAdminUserIds appendString:[NSString stringWithFormat:@"%@,",str]];
        }
        [mStrAdminUserIds setString:[mStrAdminUserIds substringToIndex:mStrAdminUserIds.length - 1]];
        query = [KDQuery query];
        [query setParameter:@"adminUserIds" stringValue:mStrAdminUserIds];
    }

    [KDServiceActionInvoker invokeWithSender:self
                                  actionPath:@"/network/:teamSignOut"
                                       query:query
                                 configBlock:nil
                             completionBlock:completionBlock];
}

#pragma mark - STEP 5 清缓存逻辑 -

- (void)cleanCache
{
    // 删除XT缓存
    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllData];
    
    // 删除缓存
    [[KDDBManager sharedDBManager] deleteCurrentCompanyDataBase];
    
    // 删除BOSConfig缓存
    [[BOSConfig sharedConfig] clearConfig];
    
    // 删除当前公司
    KDCommunityManager *manager = [[KDManagerContext globalManagerContext] communityManager];
    NSMutableArray *companies = [NSMutableArray arrayWithArray:manager.joinedCommpanies];
    [companies removeObject:manager.currentCompany];
    [manager setJoinedCommpanies:companies];
    [manager storeCompanies];
    
    //删除会话列表分页请求的标志
    [[KDTimelineManager shareManager]deleteCompanyInfoForPageRequest];
    
    // 停止计时器
    [[[KDManagerContext globalManagerContext] unreadManager] stop];
}

#pragma mark - STEP 6 通知其他页面退出成功, 此页面完成任务 -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_TAG_SIGNOUT_SUCC)
    {
        KDCommunityManager *manager = [[KDManagerContext globalManagerContext] communityManager];
        NSMutableArray *companies = [NSMutableArray arrayWithArray:manager.joinedCommpanies];
        [[NSNotificationCenter defaultCenter] postNotificationName:KDQuitCompanyFinishedNotification object:nil userInfo:@{@"companies":companies}];
    }
    else if(alertView.tag == 0x98){
        [self choosePersons];
    }
    else if(alertView.tag == 0x97){
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqual:ASLocalizedString(@"Global_Sure")]) {
         
            // ->STEP 4 传管理员id
            [self requstTeamSignOutWithAdminUserIds:_currentSelectedPerson];
        }
        else{
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        self.currentSelectedPerson = nil;
    }
}

@end
