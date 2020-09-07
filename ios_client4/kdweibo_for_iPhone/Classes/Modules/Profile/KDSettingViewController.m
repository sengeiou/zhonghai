//
//  ProfileViewController2.m
//  TwitterFon
//
//  Created by apple on 11-1-4.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KDCommon.h"
#import "KDSettingViewController.h"

#import "ProfileViewDetailController.h"
#import "KDSearchViewController.h"
#import "KDAboutViewController.h"
#import "DraftViewController.h"
#import "KDUserProfileEditViewController.h"
#import "KDTrendsViewController.h"
#import "IssuleViewController.h"
#import "KDAllDownloadedViewController.h"

#import "KDABPersonViewController.h"

#import "KDNotificationView.h"
#import "KDErrorDisplayView.h"
#import "KDUser.h"
#import "KDWeiboGlobals.h"

#import "SettingTableViewCell.h"

#import "KDRequestDispatcher.h"
#import "KDWeiboServicesContext.h"
#import "KDDefaultViewControllerContext.h"
#import "UIViewController+Navigation.h"

#import "ResourceManager.h"
#import "KDWeiboAppDelegate.h"

#import "NSString+Additions.h"
#import "KDUtility.h"
#import "KDCacheUtlities.h"
#import "KDDatabaseHelper.h"
#import "KDInboxListViewController.h"

#import "KDProfileDetailTabBarController.h"

#import "ProfileViewController2.h"
#import "KDApplicationViewController.h"
#import "ContactLoginDataModel.h"
#import "XTChatViewController.h"
#import "ContactConfig.h"
#import "BOSConfig.h"
#import "XTSetting.h"
#import "ContactClient.h"
#import "ContactUtils.h"
#import "SDImageCache.h"
#import "RecommendViewController+XT.h"
#import "T9.h"
#import "XTInitializationManager.h"
#import "CustomAlertView.h"
#import "BOSSetting.h"
#import "KDDBManager.h"
#import "KDLockControl.h"
#import "KDGestureSettingViewController.h"
#import "KDSignOutConfirmVC.h"
#import "KDVersionCheck.h"
#import "KDCleanDataViewController.h"
#import "KDMultilanguageViewController.h"
#import "KDMessageRemoteSettingViewController.h"
#import "KDChangePasswordVC.h"
#import "KDDeviceManagementViewController.h"

////////////////////////////////////////////////////////

@interface KDSettingVCTextCell : UITableViewCell

@property (nonatomic, strong) UILabel *labelTitle;

@end

@implementation KDSettingVCTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self.contentView addSubview:self.labelTitle];
    }
    return self;
}

- (UILabel *)labelTitle
{
    if (!_labelTitle)
    {
        _labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(14, 12, 121, 21)];
        _labelTitle.backgroundColor = [UIColor clearColor];
        _labelTitle.font = [UIFont boldSystemFontOfSize:16];
        _labelTitle.textColor = [UIColor blackColor];
    }
    return _labelTitle;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////

//NSString *const KDQuitCompanyFinishedNotification = @"kd_quit_company_finished_notification";

@interface KDSettingViewController () <CustomAlertViewDelegate>

@property(nonatomic, retain) KDUser* currentUser;
@property(nonatomic, retain) MBProgressHUD  *activityView;
@property (copy, nonatomic) NSDictionary *updateResult;

@end

#define KD_APP_RATING_URL_IN_ITUNES     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=452952400"

@implementation KDSettingViewController

@synthesize currentUser=currentUser_;

@synthesize userTableView=userTableView_;

@synthesize activityView = activityView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
       
        
        profileControllerFlags_.hasRequests = 0;
        profileControllerFlags_.userProfileDidChange = 1;
        profileControllerFlags_.pausedCalculateCacheSize = 0;
        //        [CommenMethod addCheckVesionFinishNotification:self action:@selector(checkVersionFinishNotificaction:)];
    }
    
    return self;
}

- (void)viewControllerWillDismiss {
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    CGRect frame = self.view.bounds;
    // table view
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor kdTableViewBackgroundColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.userTableView = tableView;
//    [tableView release];
//
    userTableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:userTableView_];
    
//    [self setupSignOutButton];
    
    activityView_ = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:activityView_];
}

- (void)setupSignOutButton {
    CGRect rect = CGRectMake(0.0, 0.0, userTableView_.bounds.size.width, 62.0);
    UIView *footerView = [[UIView alloc] initWithFrame:rect];
    
    // sign out button
    rect = CGRectMake(7.0, 10.0, rect.size.width - 14.0, 40.0f);
    UIButton *signOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    signOutBtn.frame = rect;
    signOutBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    signOutBtn.layer.cornerRadius = 3.0f;
    signOutBtn.layer.masksToBounds = YES;
    [signOutBtn setBackgroundColor:RGBCOLOR(229, 47, 46)];
    
    [signOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [signOutBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [signOutBtn setTitle:ASLocalizedString(@"KDSettingViewController_Logout_Account")forState:UIControlStateNormal];
    
    [signOutBtn addTarget:self action:@selector(signOut:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:signOutBtn];
    
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    userTableView_.tableFooterView = footerView;
//    [footerView release];
}

- (void)setRightNavigationItem {
    
}

- (void)refreshUserInfoAndView {
    KDManagerContext *context = [KDManagerContext globalManagerContext];
    self.currentUser = context.userManager.currentUser;
    
    [userTableView_ reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshUserInfoAndView];
    [self upateDownloadCount];
    self.title = ASLocalizedString(@"KDLeftTeamMenuViewController_setting");
}

- (KDUser *)currentUser {
    if (currentUser_ == nil) {
        currentUser_ = [[[KDManagerContext globalManagerContext] userManager] currentUser];// retain];
    }
    
    return currentUser_;
}

- (void)upateDownloadCount {
    //TODO:fetch the downloaded attachment count
}

////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source methods
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [NSNumber kdDistance2];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger rows = 1;
    if(section == 0) {
        rows = 5;
        // 是否能修改密码
        if ([self enableChangePassword]) {
            rows ++;
        }
        
        // 是否支持多语言
        if ([self enableMulitLanguage]) {
            rows ++;
        }
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

#define KD_NEW_VERSION_ICON_TAG     0x64
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"KDSettingVCCell";
    KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0)
    {
        cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        cell.separatorLineInset = UIEdgeInsetsMake(0, 12.0, 0, 0);
        cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
        
        
        if ([self enableChangePassword]) {
            if (indexPath.row == 0) {
                cell.textLabel.text = ASLocalizedString(@"KDChangePasswordVC_Change_Pwd");
            }
            if (indexPath.row == 1)
            {
                BOOL isReSet = [KDLockControl shared].isSetDone ? YES : NO;
                if(isReSet)
                    cell.textLabel.text = ASLocalizedString(@"KDSettingViewController_Change_Pwd");
                else
                    cell.textLabel.text = ASLocalizedString(@"KDSettingViewController_Setting_Pwd");
            }
            else if (indexPath.row == 2)
            {
                cell.textLabel.text = ASLocalizedString(@"KDSettingViewController_New_Notifications");
            }
            else  if (indexPath.row == 3)
            {
                cell.textLabel.text = ASLocalizedString(@"KDCleanDataViewController_clean_memory");
            }
            //A.wang  deviceBind
            else  if (indexPath.row == 4)
            {
                cell.textLabel.text = @"设备管理";
            }
            else if (indexPath.row == 5)
            {
                if ([self enableMulitLanguage]) {
                    
                    cell.textLabel.text = ASLocalizedString(@"Multilanguage");
                    
                }else
                {
                    cell.textLabel.text = ASLocalizedString(@"KDAboutViewController_tips_1");
                    
                }        }
            else if (indexPath.row == 6)
            {
                cell.textLabel.text = ASLocalizedString(@"KDAboutViewController_tips_1");
            }
        } else {
            if (indexPath.row == 0)
            {
                BOOL isReSet = [KDLockControl shared].isSetDone ? YES : NO;
                if(isReSet)
                    cell.textLabel.text = ASLocalizedString(@"KDSettingViewController_Change_Pwd");
                else
                    cell.textLabel.text = ASLocalizedString(@"KDSettingViewController_Setting_Pwd");
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = ASLocalizedString(@"KDSettingViewController_New_Notifications");
            }
            else  if (indexPath.row == 2)
            {
                cell.textLabel.text = ASLocalizedString(@"KDCleanDataViewController_clean_memory");
            }
            //A.wang  deviceBind
            else  if (indexPath.row == 3)
            {
                cell.textLabel.text = @"设备管理";
            }
            else if (indexPath.row == 4)
            {
                if ([self enableMulitLanguage]) {
                    
                    cell.textLabel.text = ASLocalizedString(@"Multilanguage");
                    
                }else
                {
                    cell.textLabel.text = ASLocalizedString(@"KDAboutViewController_tips_1");
                    
                }        }
            else if (indexPath.row == 5)
            {
                cell.textLabel.text = ASLocalizedString(@"KDAboutViewController_tips_1");
            }
        }
        
    }
    else if (indexPath.section == 1)
    {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = ASLocalizedString(@"KDSettingViewController_Logout");
        cell.textLabel.textColor = FC4;
        cell.accessoryStyle = KDTableViewCellAccessoryStyleNone;
        cell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
    }
    
    return cell;
    
}

- (void)_showProfileView
{
    [KDEventAnalysis event:event_settings_personal_open attributes:@{label_settings_personal_open_source: label_settings_personal_open_source_menu}];
    ProfileViewController2 *profile = [[ProfileViewController2 alloc] init];// autorelease];
    [self.navigationController pushViewController:profile animated:YES];
}

- (void)_showApplicationView
{
    RecommendViewController *appController = [[RecommendViewController alloc] initWithRecommendType:RecommendTypeField] ;//autorelease];
    [self.navigationController pushViewController:appController animated:YES];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0)
    {
        if ([self enableChangePassword]) {
            if (indexPath.row == 0) {
                // 修改密码
                KDChangePasswordVC *changePW = [[KDChangePasswordVC alloc] init];
                [self.navigationController pushViewController:changePW animated:YES];
            }
            else if (indexPath.row == 1)
            {
                [[KDLockControl shared]setHasBeenUsed:YES];
                KDGestureSettingViewController *vc = [[KDGestureSettingViewController alloc] init];
                vc.isReset = [KDLockControl shared].isSetDone ? YES : NO;
                UINavigationController *vcNav = [[UINavigationController alloc] initWithRootViewController:vc];
                vcNav.delegate = [KDNavigationManager sharedNavigationManager];
                [self.navigationController pushViewController:vc animated:YES];
                
            }
            else if (indexPath.row == 2)
            {
                //新消息通知
                KDMessageRemoteSettingViewController *viewController = [[KDMessageRemoteSettingViewController alloc] init];
                
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else if (indexPath.row == 3)
            {
                [KDEventAnalysis event:event_settings_wipecache];
                KDCleanDataViewController *avc = [[KDCleanDataViewController alloc] init];
                UINavigationController *avcNav = [[UINavigationController alloc]initWithRootViewController:avc];
                avcNav.delegate = [KDNavigationManager sharedNavigationManager];
                [self.navigationController pushViewController:avc animated:YES];
//                [avc release];
                
            }
            else if (indexPath.row == 4)
            {
                //A.wang deviceBind
                KDDeviceManagementViewController *viewController = [[KDDeviceManagementViewController alloc] init];
                
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else if (indexPath.row == 5)
            {
                if ([self enableMulitLanguage]) {
                    
                    KDMultilanguageViewController *avc = [[KDMultilanguageViewController alloc] init];
                    UINavigationController *avcNav = [[UINavigationController alloc]initWithRootViewController:avc];
                    avcNav.delegate = [KDNavigationManager sharedNavigationManager];
                    [self.navigationController pushViewController:avc animated:YES];
//                    [avc release];
                    
                }else
                {
                    KDAboutViewController *avc = [[KDAboutViewController alloc] init];
                    UINavigationController *avcNav = [[UINavigationController alloc]initWithRootViewController:avc];
                    avcNav.delegate = [KDNavigationManager sharedNavigationManager];
                    [self.navigationController pushViewController:avc animated:YES];
//                    [avc release];
                    
                }
            }
            else if (indexPath.row == 6)
            {
                KDAboutViewController *avc = [[KDAboutViewController alloc] init];
                UINavigationController *avcNav = [[UINavigationController alloc]initWithRootViewController:avc];
                avcNav.delegate = [KDNavigationManager sharedNavigationManager];
                [self.navigationController pushViewController:avc animated:YES];
//                [avc release];
            }
        } else {
            if (indexPath.row == 0)
            {
                [[KDLockControl shared]setHasBeenUsed:YES];
                KDGestureSettingViewController *vc = [[KDGestureSettingViewController alloc] init];
                vc.isReset = [KDLockControl shared].isSetDone ? YES : NO;
                UINavigationController *vcNav = [[UINavigationController alloc] initWithRootViewController:vc];
                vcNav.delegate = [KDNavigationManager sharedNavigationManager];
                [self.navigationController pushViewController:vc animated:YES];
                
            }
            else if (indexPath.row == 1)
            {
                //新消息通知
                KDMessageRemoteSettingViewController *viewController = [[KDMessageRemoteSettingViewController alloc] init];
                
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else if (indexPath.row == 2)
            {
                [KDEventAnalysis event:event_settings_wipecache];
                KDCleanDataViewController *avc = [[KDCleanDataViewController alloc] init];
                UINavigationController *avcNav = [[UINavigationController alloc]initWithRootViewController:avc];
                avcNav.delegate = [KDNavigationManager sharedNavigationManager];
                [self.navigationController pushViewController:avc animated:YES];
//                [avc release];
                
            }
            else if (indexPath.row == 3)
            {
                //A.wang deviceBind
                KDDeviceManagementViewController *viewController = [[KDDeviceManagementViewController alloc] init];
                
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else if (indexPath.row == 4)
            {
                if ([self enableMulitLanguage]) {
                    
                    KDMultilanguageViewController *avc = [[KDMultilanguageViewController alloc] init];
                    UINavigationController *avcNav = [[UINavigationController alloc]initWithRootViewController:avc];
                    avcNav.delegate = [KDNavigationManager sharedNavigationManager];
                    [self.navigationController pushViewController:avc animated:YES];
//                    [avc release];
                    
                }else
                {
                    KDAboutViewController *avc = [[KDAboutViewController alloc] init];
                    UINavigationController *avcNav = [[UINavigationController alloc]initWithRootViewController:avc];
                    avcNav.delegate = [KDNavigationManager sharedNavigationManager];
                    [self.navigationController pushViewController:avc animated:YES];
//                    [avc release];
                    
                }
            }
            else if (indexPath.row == 5)
            {
                KDAboutViewController *avc = [[KDAboutViewController alloc] init];
                UINavigationController *avcNav = [[UINavigationController alloc]initWithRootViewController:avc];
                avcNav.delegate = [KDNavigationManager sharedNavigationManager];
                [self.navigationController pushViewController:avc animated:YES];
//                [avc release];
            }
        }

    }
    else if(indexPath.section == 1)
    {
        [self signOut:nil];
    }

    
    
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.backgroundColor = RGBCOLOR(250, 250, 250);
//}

////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (BOOL)enableChangePassword {
    // 统一身份认证后不允许修改密码
    BOOL flag = ![BOSConfig sharedConfig].user.isVerify;
    return flag;
}

- (BOOL)enableMulitLanguage {
    BOOL flag = [BOSConfig sharedConfig].user.enableLanguage == 1 && [[BOSConfig sharedConfig].user.userId isEqualToString:[BOSConfig sharedConfig].mainUser.userId];
    return flag;
}

- (void)didPostDraft:(NSNotification *)notification
{
    [self refreshUserInfoAndView];
    [self upateDownloadCount];
}

- (BOOL)_addressBookModuleEnabled {
    BOOL enabled = NO;
    
    KDManagerContext *context = [KDManagerContext globalManagerContext];
    if ([context.communityManager isCompanyDomain] && ![context.userManager isPublicUser]) {
        enabled = YES;
    }
    
    return enabled;
}

- (void)signOut:(UIButton *)btn {
    //add
    [KDEventAnalysis event:event_login_out];
    [KDEventAnalysis eventCountly:event_login_out];
    
    [self _signOut];
}

// MARK: 退出工作圈流程: 入口
- (void)quitOut
{
    //    // <最后一个工作圈?>
    //    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    //    NSArray *communites = communityManager.joinedCommpanies;
    //    if (communites.count <= 1)
    //    {
    //
    //        CustomAlertView *alertView = [[CustomAlertView alloc] initWithDelegate:nil alertType:CustomAlertViewTypeTitleAlert meesage:ASLocalizedString(@"KDSettingViewController_alertView_Last_Work")title:nil subTitle:ASLocalizedString(@"KDSettingViewController_alertView_subTitle_error")cancelButtonTitle:ASLocalizedString(@"好的")doneButtonTitle:nil];
    //        [alertView show];
    //        [alertView release];
    //    }
    //    else
    //    {
    // <是企业工作圈?>
    
    if ([[BOSSetting sharedSetting] isIntergrationMode]) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"KDSettingViewController_alertView_tips")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
//        [alertView release];
        return ;
        
    }
    if(self.currentUser.isCompany)
    {
        // [提示错误]
        CustomAlertView *alertView = [[CustomAlertView alloc] initWithDelegate:nil alertType:CustomAlertViewTypeTitleAlert meesage:ASLocalizedString(@"KDSettingViewController_alertView_message_error")title:nil subTitle:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")doneButtonTitle:nil];
        [alertView show];
//        [alertView release];
    }
    else
    {
        // TODO: 验证 [进入退出工作圈确认界面]
        KDSignOutConfirmVC *confirmVC = [[KDSignOutConfirmVC alloc]init];
        [self.navigationController pushViewController:confirmVC animated:YES];
//        [confirmVC release];
    }
    //    }
}

- (void)buttonClick:(CustomAlertView *)alertView atIndex:(NSInteger)index{}
///**
// *  提示输入密码
// */
//- (void)showPasswordView
//{
//    CustomAlertView *alertView = [[CustomAlertView alloc] initWithDelegate:self alertType:CustomAlertViewTypeInputAlert meesage:[NSString stringWithFormat:ASLocalizedString(@"KDSettingViewController_alertView_message_tips"),[BOSSetting sharedSetting].customerName] title:ASLocalizedString(@"   退出确认")subTitle:ASLocalizedString(@"请输入密码")cancelButtonTitle:ASLocalizedString(@"Global_Cancel")doneButtonTitle:ASLocalizedString(@"Global_Sure")];
//    [alertView show];
//    [alertView release];
//}

/*
 #pragma mark CustomAlertViewDelegate methods
 - (void)buttonClick:(CustomAlertView *)alertView atIndex:(NSInteger)index{
 
 if (index == 1) {
 
 if ([alertView.textField.text length] ==0) {
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:ASLocalizedString(@"KDSettingViewController_NilPwd")delegate:nil cancelButtonTitle:ASLocalizedString(@"好的")otherButtonTitles:nil, nil];
 [alertView show];
 [alertView release];
 
 return;
 }
 if (![alertView.textField.text isEqualToString:[BOSSetting sharedSetting].password]) {
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:ASLocalizedString(@"KDSettingViewController_ErrorPwd")delegate:nil cancelButtonTitle:ASLocalizedString(@"好的")otherButtonTitles:nil, nil];
 [alertView show];
 [alertView release];
 
 return;
 }
 
 [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
 
 __block KDSettingViewController *pvc = [self retain];
 KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
 
 [MBProgressHUD hideHUDForView:self.view.window animated:YES];
 
 if([response isValidResponse]) {
 if (results != nil) {
 
 if ([results boolForKey:@"success"]) {
 
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDSettingViewController_Success")message:ASLocalizedString(@"KDSettingViewController_Logout_Work_Success")delegate:self cancelButtonTitle:ASLocalizedString(@"好的")otherButtonTitles:nil, nil];
 alertView.tag = 0x99;
 [alertView show];
 [alertView release];
 
 }
 else{
 [KDErrorDisplayView showErrorMessage:[results stringForKey:@"errormsg"]
 inView:pvc.view.window];
 }
 }
 else{
 
 [KDErrorDisplayView showErrorMessage:ASLocalizedString(@"KDSettingViewController_Logout_Work_Fail")inView:pvc.view.window];
 }
 
 } else {
 if (![response isCancelled]) {
 [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
 inView:pvc.view.window];
 }
 }
 
 // release current view controller
 [pvc release];
 };
 
 // MARK: 修改退出工作圈流程, 当需要指定多人成为管理员时，多个id之间用半角逗号”,”隔开.
 
 NSString *strAdminUserIds;
 
 KDQuery *query = [KDQuery query];
 [query setParameter:@"adminUserIds" stringValue:strAdminUserIds];
 
 
 [KDServiceActionInvoker invokeWithSender:self actionPath:@"/network/:teamSignOut" query:nil
 configBlock:nil completionBlock:completionBlock];
 }
 }
 */


- (void)_signOut
{
    [KDEventAnalysis event:event_settings_logout_ok];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[KDWeiboAppDelegate getAppDelegate] signOut];
}

- (void)editUserProfile:(UIButton *)sender {
    KDUserProfileEditViewController *upev = [[KDUserProfileEditViewController alloc] initWithNibName:nil bundle:nil];
    upev.user = currentUser_;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:upev];
//    [upev release];
    
    [self presentViewController:nc animated:YES completion:nil];
//    [nc release];
}

- (NSInteger)getDraftsCount {
    __block NSUInteger count = 0;
    
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb) {
        id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
        NSUInteger draftsCount = [draftDAO queryAllDraftsCountWithType:DraftNotInSending database:fmdb];
        return @(draftsCount);
        
    } completionBlock:^(id results) {
        count = [(NSNumber *)results integerValue];
    }];
    
    return count;
}

- (void)gotoProfileViewDetailControllerAtIndex:(NSInteger)index {
    KDProfileDetailTabBarController *pdvc = [KDProfileDetailTabBarController profileDetailViewController];
    pdvc.currentUser = currentUser_;
    [pdvc setSelectedTabIndex:index];
    
    [self.navigationController pushViewController:pdvc animated:YES];
}

////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark remove cache

- (void)_showRemoveCacheAlertView {
    
    sizeOfDownloads = 0;
    sizeOfPictures = 0;
    sizeOfVideos = 0;
    sizeOfAudios = 0;
    sizeOfXTAudios = 0;
    sizeOfSDWebImages = 0;
    sizeOfDownloadsFile = 0;
    
    // change the control flag
    @synchronized(self) {
        profileControllerFlags_.pausedCalculateCacheSize = 0;
    }
    
    profileControllerFlags_.finishedCalculation = 0;
    
    alertView_ = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REMOVE_CACHE_CONFIRM", @"")
                                            message:NSLocalizedString(@"CALCULATE_CACHE_SIZE", @"")
                                           delegate:self
                                  cancelButtonTitle:ASLocalizedString(@"Global_Cancel")
                                  otherButtonTitles:nil];
    
    [alertView_ show];
    didPresentAlertView_ = NO;
//    [alertView_ release];
    
    __block NSInteger tasksMask = 7; // mark as 6 task
    
    // calculate the size of downloads cache folder
    KDUtility *utility = [KDUtility defaultUtility];
    NSString *downloadsPath = [utility searchDirectory:KDDownloadDocument inDomainMask:KDTemporaryDomainMask needCreate:NO];
    [KDCacheUtlities asyncCalculateFolderSize:downloadsPath
                               cancelledBlock:^(void) {
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }
                                finishedBlock:^(KDUInt64 totalSize, NSUInteger count) {
                                    tasksMask--;
                                    sizeOfDownloads = totalSize;
                                    if (0x00 == tasksMask) {
                                        [self changeAlertViewMessage:tasksMask];
                                    }
                                }];
    
    // calculate the size of pictures cache folder
    NSString *picturesPath = [utility searchDirectory:KDPicturesDirectory inDomainMask:KDTemporaryDomainMask needCreate:NO];
    [KDCacheUtlities asyncCalculateFolderSize:picturesPath
                               cancelledBlock:^(void) {
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }
                                finishedBlock:^(KDUInt64 totalSize, NSUInteger count) {
                                    tasksMask--;
                                    sizeOfPictures = totalSize;
                                    if (0x00 == tasksMask) {
                                        [self changeAlertViewMessage:tasksMask];
                                    }
                                }];
    
    //calculate the size of audio cache folder
    NSString *audiosPath = [utility searchDirectory:KDDownloadAudio inDomainMask:KDTemporaryDomainMask needCreate:NO];
    [KDCacheUtlities asyncCalculateFolderSize:audiosPath
                               cancelledBlock:^{
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }
                                finishedBlock:^(KDUInt64 totalSize, NSUInteger count) {
                                    tasksMask--;
                                    sizeOfAudios = totalSize;
                                    if(0x00 == tasksMask) {
                                        [self changeAlertViewMessage:tasksMask];
                                    }
                                    
                                }];
    
    // calculate the size of pictures cache folder
    NSString *videosPath = [utility searchDirectory:KDVideosDirectory inDomainMask:KDTemporaryDomainMask needCreate:NO];
    [KDCacheUtlities asyncCalculateFolderSize:videosPath
                               cancelledBlock:^(void) {
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }
                                finishedBlock:^(KDUInt64 totalSize, NSUInteger count) {
                                    tasksMask--;
                                    sizeOfVideos = totalSize;
                                    if (0x00 == tasksMask) {
                                        [self changeAlertViewMessage:tasksMask];
                                    }
                                }];
    
    //calculate the size of xt audio cache folder
    NSString *xtAudioPath = [[BOSFileManager currentUserPathWithOpenId:[BOSConfig sharedConfig].user.openId] stringByAppendingPathComponent:kRecorderDirectoryName];
    [KDCacheUtlities asyncCalculateFolderSize:xtAudioPath
                               cancelledBlock:^(void){
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }finishedBlock:^(KDUInt64 totalSize, NSUInteger count){
                                   tasksMask--;
                                   sizeOfXTAudios = totalSize;
                                   if(0x00 == tasksMask) {
                                       [self changeAlertViewMessage:tasksMask];
                                   }
                               }];
    
    //calculate the size of xt audio cache folder
    NSString *sdWebImagePath = [[SDImageCache sharedImageCache] getCachPath];
    [KDCacheUtlities asyncCalculateFolderSize:sdWebImagePath
                               cancelledBlock:^(void){
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }finishedBlock:^(KDUInt64 totalSize, NSUInteger count){
                                   tasksMask--;
                                   sizeOfSDWebImages = totalSize;
                                   if(0x00 == tasksMask) {
                                       [self changeAlertViewMessage:tasksMask];
                                   }
                               }];
    //xuntong 下的file文件
    NSString *dowonFile = [[BOSFileManager currentUserPathWithOpenId:[BOSConfig sharedConfig].user.openId] stringByAppendingPathComponent:kFileDirectoryName];
    [KDCacheUtlities asyncCalculateFolderSize:dowonFile
                               cancelledBlock:^(void){
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }finishedBlock:^(KDUInt64 totalSize, NSUInteger count){
                                   tasksMask--;
                                   sizeOfDownloadsFile = totalSize;
                                   if(0x00 == tasksMask) {
                                       [self changeAlertViewMessage:tasksMask];
                                   }
                               }];

}

- (void)changeAlertViewMessage:(NSInteger)taskMask {
    NSString *msg = [self _formatRemoveCacheMessage:taskMask];
    
    [self changeMessage:msg];
    
    profileControllerFlags_.finishedCalculation = 1;
}

- (void)changeMessage:(NSString *)msg {
    if(didPresentAlertView_) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REMOVE_CACHE_CONFIRM", @"")
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:ASLocalizedString(@"Global_Cancel")
                                              otherButtonTitles:NSLocalizedString(@"OKAY", @""), nil];
        
        [alert show];
//        [alert release];
        [alertView_ dismissWithClickedButtonIndex:0 animated:NO];
    }else {
        [self performSelector:@selector(changeMessage:) withObject:msg afterDelay:0.1];
    }
}



//2013年10月17日10:04:45， 更改此处代码（沈逵逵）
//更改原因：逻辑太混乱
//@modify-time:2013年10月22日14:03:39
//@modify-by:shenkuikui
//@modify-reason:MOB-222
- (NSString *)_formatRemoveCacheMessage:(NSInteger)tasksMask {
    NSMutableString *message = [NSMutableString string];
    NSString *downloadSize = [NSString formatContentLengthWithBytes:sizeOfDownloads + sizeOfAudios + sizeOfVideos + sizeOfXTAudios + sizeOfDownloadsFile];
    NSString *picturesSize = [NSString formatContentLengthWithBytes:sizeOfPictures + sizeOfSDWebImages];
    //    NSString *audiosSize = [NSString formatContentLengthWithBytes:sizeOfAudios];
    //    NSString *videosSize = [NSString formatContentLengthWithBytes:sizeOfVideos];
    
    //@modify:2013年10月17日10:06:26添加
    [message appendString:NSLocalizedString(@"REMOVE_CACHE_PRE", @"")];
    
    if(sizeOfDownloads + sizeOfAudios + sizeOfVideos + sizeOfXTAudios + sizeOfDownloadsFile > 0) {
        [message appendString:[NSString stringWithFormat:@"%@%@", [NSString stringWithFormat:NSLocalizedString(@"REMOVE_DOWNLOADS_CACHE_ONLY%@", nil), downloadSize], NSLocalizedString(@"REMOVE_CACHE_UNION", nil)]];
    }
    
    if(sizeOfPictures + sizeOfSDWebImages > 0) {
        [message appendString:[NSString stringWithFormat:@"%@%@", [NSString stringWithFormat:NSLocalizedString(@"REMOVE_PICTURES_CACHE_ONLY%@", nil), picturesSize], NSLocalizedString(@"REMOVE_CACHE_UNION", nil)]];
    }
    
    if ([message hasSuffix:NSLocalizedString(@"REMOVE_CACHE_UNION", nil)]) {
        [message deleteCharactersInRange:NSMakeRange(message.length - 1, 1)];
    }
    
    if ([message isEqualToString:NSLocalizedString(@"REMOVE_CACHE_PRE",@"")] && (0x00 == tasksMask)) {
        message = [NSMutableString stringWithString:NSLocalizedString(@"NO_CACHE_TO_REMOVE", @"")];
    }
    
    return message;
}

- (void)_showRemoveCacheActivityView:(BOOL)visible text:(NSString *)text onlyText:(BOOL)onlyText {
    if (visible && activityView_ == nil) {
        activityView_ = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        activityView_.completionBlock = ^(){
            [activityView_ removeFromSuperview];
            //KD_RELEASE_SAFELY(activityView_);
        };
        
        [self.navigationController.view addSubview:activityView_];
    }
    
    if (onlyText) {
        activityView_.mode = MBProgressHUDModeText;
    }
    
    activityView_.labelText = text;
    
    if (visible) {
        [activityView_ show:YES];
        self.view.window.userInteractionEnabled = NO;
        
    } else {
        [activityView_ hide:YES afterDelay:2];
        self.view.window.userInteractionEnabled = YES;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0x00 inSection:0x00];
        [userTableView_ reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)t9Update
{
    [[XTInitializationManager sharedInitializationManager] startInitializeCompletionBlock:^(int count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userTableView reloadData];
            if (self.activityView != nil) {
                [self.activityView hide:YES];
            }
        });
    } failedBlock:^(NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.activityView != nil) {
                [self.activityView hide:YES];
            }
        });
    }];
}

- (void)_removeCache {
    __block BOOL removed = NO;
    __block NSInteger tasksMask = 0x00;
    if (sizeOfDownloads > 0) {
        tasksMask |= 0x01 << 0;
    }
    
    if (sizeOfPictures > 0) {
        tasksMask |= 0x01 << 1;
    }
    
    if (sizeOfVideos > 0) {
        tasksMask |= 0x01 << 2;
    }
    
    if(sizeOfAudios > 0) {
        tasksMask |= 0x01 << 3;
    }
    
    if(sizeOfXTAudios > 0) {
        tasksMask |= 0x01 << 4;
    }
    
    if(sizeOfSDWebImages > 0) {
        tasksMask |= 0x01 << 5;
    }
    if (sizeOfDownloadsFile > 0) {
        tasksMask |= 0x01 << 6;
    }
    if (tasksMask != 0x00) {
        [self _showRemoveCacheActivityView:YES text:NSLocalizedString(@"REMOVING_CACHE", @"") onlyText:NO];
    }
    
    if (sizeOfDownloads > 0) {
        NSString *downloadsPath = [[KDUtility defaultUtility] searchDirectory:KDDownloadDocument
                                                                 inDomainMask:KDTemporaryDomainMask
                                                                   needCreate:NO];
        
        // remove downloads
        [KDCacheUtlities asyncRemovePath:downloadsPath
                           finishedBlock:^(BOOL success, NSError *error){
                               tasksMask ^= (0x01 << 0);
                               removed = removed || success;
                               [self _didFinishRemoveCache:tasksMask removed:removed];
                           }];
    }
    
    if (sizeOfPictures > 0) {
        // remove pictures
        NSString *picturesPath = [[KDUtility defaultUtility] searchDirectory:KDPicturesDirectory
                                                                inDomainMask:KDTemporaryDomainMask
                                                                  needCreate:NO];
        
        [KDCacheUtlities asyncRemovePath:picturesPath
                           finishedBlock:^(BOOL success, NSError *error){
                               tasksMask ^= (0x01 << 1);
                               removed = removed || success;
                               [self _didFinishRemoveCache:tasksMask removed:removed];
                           }];
    }
    
    if (sizeOfVideos > 0) {
        // remove pictures
        NSString *videoPath = [[KDUtility defaultUtility] searchDirectory:KDVideosDirectory
                                                             inDomainMask:KDTemporaryDomainMask
                                                               needCreate:NO];
        
        [KDCacheUtlities asyncRemovePath:videoPath
                           finishedBlock:^(BOOL success, NSError *error){
                               tasksMask ^= (0x01 << 2);
                               removed = removed || success;
                               [self _didFinishRemoveCache:tasksMask removed:removed];
                           }];
    }
    
    if(sizeOfAudios > 0) {
        NSString *audioPath = [[KDUtility defaultUtility] searchDirectory:KDDownloadAudio
                                                             inDomainMask:KDTemporaryDomainMask
                                                               needCreate:NO];
        [KDCacheUtlities asyncRemovePath:audioPath finishedBlock:^(BOOL success, NSError *error) {
            tasksMask ^= (0x01 << 3);
            removed = removed || success;
            [self _didFinishRemoveCache:tasksMask removed:removed];
        }];
    }
    
    if(sizeOfXTAudios > 0) {
        NSString *xtAudioPath = [[BOSFileManager currentUserPathWithOpenId:[BOSConfig sharedConfig].user.openId] stringByAppendingPathComponent:kRecorderDirectoryName];
        
        [KDCacheUtlities asyncRemovePath:xtAudioPath finishedBlock:^(BOOL success, NSError *error) {
            tasksMask ^= (0x01 << 4);
            removed = removed || success;
            
            [self _didFinishRemoveCache:tasksMask removed:removed];
        }];
    }
    
    if(sizeOfSDWebImages > 0) {
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^(void){
            [[SDImageCache sharedImageCache] clearMemory];
            tasksMask ^= (0x01 << 5);
            removed = removed || YES;
            
            [self _didFinishRemoveCache:tasksMask removed:removed];
        }];
    }
    if (sizeOfDownloadsFile > 0) {
        NSString *downloadFilePath = [[BOSFileManager currentUserPathWithOpenId:[BOSConfig sharedConfig].user.openId] stringByAppendingPathComponent:kFileDirectoryName];
        
        [KDCacheUtlities asyncRemovePath:downloadFilePath finishedBlock:^(BOOL success, NSError *error) {
            tasksMask ^= (0x01 << 6);
            removed = removed || success;
            
            [self _didFinishRemoveCache:tasksMask removed:removed];
        }];
    }
    

    [[KDWeiboAppDelegate getAppDelegate] clearCacheAndCookie];
}

- (void)_didFinishRemoveCache:(NSInteger)tasksMask removed:(BOOL)removed {
    if (0x00 == tasksMask) {
        // did finished all task
        NSString *text = removed ? NSLocalizedString(@"SUCCESS_IN_REMOVAL", @"") : NSLocalizedString(@"ERROR_IN_REMOVAL", @"");
        [self _showRemoveCacheActivityView:NO text:text onlyText:YES];
        [self upateDownloadCount];
    }
}

- (NSArray *)sortCommunity:(NSArray *)array
{
    return [array sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        if (((CompanyDataModel *)obj1).unreadCount + ((CompanyDataModel *)obj1).wbUnreadCount>
            ((CompanyDataModel *)obj2).unreadCount + ((CompanyDataModel *)obj2).wbUnreadCount) {
            
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (((CompanyDataModel *)obj1).unreadCount + ((CompanyDataModel *)obj1).wbUnreadCount
            < ((CompanyDataModel *)obj2).unreadCount + ((CompanyDataModel *)obj2).wbUnreadCount) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
}

/*
 #pragma mark CustomAlertViewDelegate methods
 - (void)buttonClick:(CustomAlertView *)alertView atIndex:(NSInteger)index{
 
 if (index == 1) {
 
 if ([alertView.textField.text length] ==0) {
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:ASLocalizedString(@"KDSettingViewController_NilPwd")delegate:nil cancelButtonTitle:ASLocalizedString(@"好的")otherButtonTitles:nil, nil];
 [alertView show];
 [alertView release];
 
 return;
 }
 if (![alertView.textField.text isEqualToString:[BOSSetting sharedSetting].password]) {
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:ASLocalizedString(@"KDSettingViewController_ErrorPwd")delegate:nil cancelButtonTitle:ASLocalizedString(@"好的")otherButtonTitles:nil, nil];
 [alertView show];
 [alertView release];
 
 return;
 }
 
 [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
 KDQuery *query = [KDQuery queryWithName:@"adminUserIds" value:@""];
 __block KDSettingViewController *pvc = [self retain];
 KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
 
 [MBProgressHUD hideHUDForView:self.view.window animated:YES];
 
 if([response isValidResponse]) {
 if (results != nil) {
 
 if ([results boolForKey:@"success"]) {
 
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDSettingViewController_Success")message:ASLocalizedString(@"KDSettingViewController_Logout_Work_Success")delegate:self cancelButtonTitle:ASLocalizedString(@"好的")otherButtonTitles:nil, nil];
 alertView.tag = 0x99;
 [alertView show];
 [alertView release];
 
 }
 else{
 [KDErrorDisplayView showErrorMessage:[results stringForKey:@"errormsg"]
 inView:pvc.view.window];
 }
 }
 else{
 
 [KDErrorDisplayView showErrorMessage:ASLocalizedString(@"KDSettingViewController_Logout_Work_Fail")inView:pvc.view.window];
 }
 
 } else {
 if (![response isCancelled]) {
 [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
 inView:pvc.view.window];
 }
 }
 
 // release current view controller
 [pvc release];
 };
 
 [KDServiceActionInvoker invokeWithSender:self actionPath:@"/network/:teamSignOut" query:nil
 configBlock:nil completionBlock:completionBlock];
 }
 }
 */
#pragma mark -
#pragma mark UIAlertViewDelegate methods
/*
 *解决iOS7下，计算缓存一直显示缓存计算中的问题
 */
- (void)didPresentAlertView:(UIAlertView *)alertView {
    
    didPresentAlertView_ = YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 0x99) {
        /* 旧代码, 旧流程, 直接跳到一个工作圈
         KDCommunityManager *manager = [[KDManagerContext globalManagerContext] communityManager];
         NSMutableArray *companies = [NSMutableArray arrayWithArray:manager.joinedCommpanies];
         [companies removeObject:manager.currentCompany];
         
         [manager setJoinedCommpanies:companies];
         [manager storeCompanies];
         
         NSArray *sorted = [self sortCommunity:companies];
         
         CompanyDataModel *target = nil;
         if ([sorted count]>0) {
         target = [sorted objectAtIndex:0];
         }
         
         [[NSNotificationCenter defaultCenter] postNotificationName:KDQuitCompanyFinishedNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:target,@"company", nil]];
         */
        /**
         *  修改流程, 退出工作圈后, 进入工作圈选择界面 Modified by Darren @ 20140802
         */
        // 需要清缓存
        
        // 删除XT缓存
        [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllData];
    
        // 删除缓存
        [[KDDBManager sharedDBManager] deleteCurrentCompanyDataBase];
        
        // 设置界面的清除缓存
        //[self _removeCache];
        
        // 删除BOSConfig缓存
        [[BOSConfig sharedConfig] clearConfig];
        
        KDCommunityManager *manager = [[KDManagerContext globalManagerContext] communityManager];
        NSMutableArray *companies = [NSMutableArray arrayWithArray:manager.joinedCommpanies];
        [companies removeObject:manager.currentCompany];
        
        [manager setJoinedCommpanies:companies];
        [manager storeCompanies];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KDQuitCompanyFinishedNotification object:nil userInfo:@{@"companies":companies}];
        
        return;
    }
    
    alertView_ = nil;
    
    @synchronized(self) {
        profileControllerFlags_.pausedCalculateCacheSize = 1;
    }
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self _removeCache];
    }
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
    // when profile view did receive memory warning, should reload user's profile
    profileControllerFlags_.userProfileDidChange = 1;
    
    //KD_RELEASE_SAFELY(userTableView_);
    
    alertView_ = nil;
    //KD_RELEASE_SAFELY(activityView_);
}

- (void)dealloc {
    
    //KD_RELEASE_SAFELY(currentUser_);
    //KD_RELEASE_SAFELY(userTableView_);
    //KD_RELEASE_SAFELY(_updateResult);
    
    //KD_RELEASE_SAFELY(menuItems_);
    
    alertView_ = nil;
    //KD_RELEASE_SAFELY(activityView_);
    
    //[super dealloc];
}

@end
