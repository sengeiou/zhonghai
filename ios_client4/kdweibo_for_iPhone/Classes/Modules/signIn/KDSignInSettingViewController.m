//
//  KDSignInSettingViewController.m
//  kdweibo
//
//  Created by Tan yingqi on 13-8-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDSignInSettingViewController.h"
#import "KDSignInSettingCell.h"
#import "BOSConfig.h"
#import "KDSignInManager.h"
#import "KDSignInRemindController.h"
#import "KDConfigurationContext.h"

#define STATISTICS_PERMISSION_URL @"/attendancelight/guidance/statisticsl-permissions.html"
#define CUSTOMIZED_ATTENDANCE_URL @"/attendancelight/guidance/customized-attendance.html"

@interface KDSignInSettingViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property(nonatomic, strong) UITableView            *tableView;
@property(nonatomic, strong) NSString               *deviceId;
@property(nonatomic, assign) BOOL                   isCanSetAttPoint;
@end

@implementation KDSignInSettingViewController


- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    self.isCanSetAttPoint = NO;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor kdBackgroundColor1];
    _tableView.rowHeight = 50;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    if (![[BOSConfig sharedConfig] user].isAdmin) {
        [self getIsCanSetAttPointFlag];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [[BOSConfig sharedConfig] user].isAdmin ? ASLocalizedString(@"管理与设置") : ASLocalizedString(@"移动签到设置");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.showGuideView) {
        [self addGuideView];
        self.showGuideView = NO;
    }
}

- (void)getIsCanSetAttPointFlag {
    
    __weak KDSignInSettingViewController *weakSelf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if ( [response statusCode] == 200) {
            weakSelf.isCanSetAttPoint = [results[@"data"][@"isCanSetAttPoint"] boolValue];
            if (weakSelf.isCanSetAttPoint) {
                weakSelf.title = ASLocalizedString(@"管理与设置");
            }
            [weakSelf.tableView reloadData];

        }
    };
    
    [KDServiceActionInvoker invokeWithSender:weakSelf
                                  actionPath:@"/signId/:getAttendAdminRole"
                                       query:nil
                                 configBlock:nil
                             completionBlock:completionBlock];
}

#pragma mark - UITableViewDelegate & dataSource -
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[BOSConfig sharedConfig] user].isAdmin) {
        return section == 0 ? 5 : 3;
    }
    else if (self.isCanSetAttPoint) {
        return section == 0 ? 2 : 3;
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return  [NSNumber kdDistance2];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[BOSConfig sharedConfig] user].isAdmin || self.isCanSetAttPoint) {
        if (indexPath.row == 0) {
            return 30;
        }
        else if (indexPath.section == 0) {
            return 60;
        }
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //管理员和签到负责人
    if ([[BOSConfig sharedConfig] user].isAdmin || self.isCanSetAttPoint) {
        if (indexPath.row == 0) {
            KDLS8Cell *cell = [tableView dequeueReusableCellWithIdentifier:@"headerCell"];
            
            if (!cell) {
                cell = [[KDLS8Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell"];
                cell.kd_contentView.kd_separatorLine.hidden = YES;
            }
            
            if (indexPath.section == 0) {
                cell.kd_contentView.kd_textLabel.text = ASLocalizedString(@"签到管理");
            }
            else {
                cell.kd_contentView.kd_textLabel.text = ASLocalizedString(@"个人设置");
            }
            
            return cell;
        }
        else if (indexPath.section == 0) {
            KDSignInSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"signInManagerCell"];
            
            if (!cell) {
                cell = [[KDSignInSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"signInManagerCell"];
                [cell.kd_contentView install:cell.contentView style:KDListStyleLs4];
                cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
            }
            
            if (indexPath.row == 1) {
                cell.kd_contentView.kd_textLabel.text = ASLocalizedString(@"签到组管理");
                cell.kd_contentView.kd_detailTextLabel.text = ASLocalizedString(@"为团队设置签到规则");
            }
            
            if ([[BOSConfig sharedConfig] user].isAdmin) {
                if (indexPath.row == 2) {
                    cell.kd_contentView.kd_textLabel.text = ASLocalizedString(@"考勤状态管理");
                    cell.kd_contentView.kd_detailTextLabel.text = ASLocalizedString(@"支持异常反馈、外勤确认");
                }
                else if (indexPath.row == 3) {
                    cell.kd_contentView.kd_textLabel.text = ASLocalizedString(@"统计权限管理");
                    cell.kd_contentView.kd_detailTextLabel.text = ASLocalizedString(@"授权员工查看各部门的签到情况");
                }
                else if (indexPath.row == 4) {
                    cell.kd_contentView.kd_textLabel.text = ASLocalizedString(@"考勤日期管理");
                    cell.kd_contentView.kd_detailTextLabel.text = ASLocalizedString(@"自定义团队工作日、休息日");
                }
            }
            
            return cell;
        }
        else if (indexPath.section == 1) {
            KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personalSettingCell"];
            
            if (!cell) {
                cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"personalSettingCell"];
                cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
            }
            
            if (indexPath.row == 1) {
                cell.textLabel.text = ASLocalizedString(@"我的签到提醒");
                cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
            }
            else {
                cell.textLabel.text = ASLocalizedString(@"我的签到设备绑定");
                cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
            }
            
            return cell;
        }
    }
    //其他人
    else {
        KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personalSettingCell"];
        
        if (!cell) {
            cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"personalSettingCell"];
            cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        }
        
        if (indexPath.section == 0) {
            cell.textLabel.text = ASLocalizedString(@"我的签到提醒");
            cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
        }
        else if (indexPath.section == 1) {
            cell.textLabel.text = ASLocalizedString(@"我的签到设备绑定");
            cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
        }
        
        return cell;
    }
    
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[BOSConfig sharedConfig] user].isAdmin || self.isCanSetAttPoint) {
        if (indexPath.section == 0) {
            if (indexPath.row == 1) {
                KDSignInGroupManageViewController *signInGroupManageViewController = [[KDSignInGroupManageViewController alloc] init];
                [self.navigationController pushViewController:signInGroupManageViewController animated:YES];
            }
            
            if ([[BOSConfig sharedConfig] user].isAdmin) {
                if (indexPath.row == 2) {
                    KDAttendanceStatusManageViewController *attendanceStatusManageVC = [[KDAttendanceStatusManageViewController alloc] init];
                    [self.navigationController pushViewController:attendanceStatusManageVC animated:YES];
                }
                else if (indexPath.row == 3) {
                    KDWebViewController *web = [[KDWebViewController alloc] initWithUrlString:[NSString stringWithFormat:@"%@%@", [[[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance] getServerBaseURL], STATISTICS_PERMISSION_URL]];
                    web.isBlueNav = YES;
                    web.title = ASLocalizedString(@"统计权限管理");
                    [self.navigationController pushViewController:web animated:YES];
                }
                else if (indexPath.row == 4) {
                    KDWebViewController *web = [[KDWebViewController alloc] initWithUrlString:[NSString stringWithFormat:@"%@%@", [[[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance] getServerBaseURL], CUSTOMIZED_ATTENDANCE_URL]];
                    web.isBlueNav = YES;
                    web.title = ASLocalizedString(@"考勤日期管理");
                    [self.navigationController pushViewController:web animated:YES];
                }
            }
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == 1) {
                //签到提醒
                KDSignInRemindController *remindController = [[KDSignInRemindController alloc] init];
                
                [self.navigationController pushViewController:remindController animated:YES];
            }
            else if (indexPath.row == 2) {
                [self showDeviceId];
            }
        }
    }
    else {
        if (indexPath.section == 0)
        {
            //签到提醒
            KDSignInRemindController *remindController = [[KDSignInRemindController alloc] init];
            
            [self.navigationController pushViewController:remindController animated:YES];
        }
        else if (indexPath.section == 1) {
            [self showDeviceId];
        }
    }
}

#pragma mark - method -

- (void)showDeviceId {
    if (!self.deviceId) {
        self.deviceId = [UIDevice uniqueDeviceIdentifier];
    }
    NSString *message = nil;
    if (self.deviceId == nil || [self.deviceId length] == 0) {
        message = ASLocalizedString(@"获取设备号失败！");
    }
    else {
        message = [NSString stringWithFormat:ASLocalizedString(@"%@\n本设备号经过加密，用来纠察和核实代签到"), self.deviceId];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:ASLocalizedString(@"确定") otherButtonTitles:ASLocalizedString(@"绑定当前帐号"), nil];
    alert.tag = 10001;
    [alert show];
    
}

- (void)addGuideView {
    KDSignInSettingGuideView *guideView = [[KDSignInSettingGuideView alloc] init];
    guideView.type = 0;
    guideView.actionBlock = ^{
        KDSignInGroupManageViewController *signInGroupVC = [[KDSignInGroupManageViewController alloc] init];
        signInGroupVC.showGuideView = YES;
        [self.navigationController pushViewController:signInGroupVC animated:YES];
    };
    [self.navigationController.view addSubview:guideView];
    [guideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.navigationController.view);
    }];
    
    guideView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        guideView.alpha = 1;
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10001) {
        if (buttonIndex == 1) {
            //绑定当前帐号
            [self bindingDeviceService];
        }
        return;
    }
}

- (void)bindingDeviceService {
    [KDPopup showHUD:ASLocalizedString(@"绑定帐号中...") inView:self.view];
    
    __weak KDSignInSettingViewController *weakSelf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if(results)
        {
            if ([[results objectForKey:@"data"] boolValue]) {
                [KDPopup showHUDSuccess:ASLocalizedString(@"已经成功绑定当前帐号") inView:weakSelf.view];
            }
            else {
                [KDPopup showHUDToast:ASLocalizedString(@"绑定当前帐号失败") inView:weakSelf.view];
            }
        }
        else
            [KDPopup showHUDToast:ASLocalizedString(@"绑定当前帐号失败") inView:weakSelf.view];
    };
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/signId/:bindingDevice" parameters:nil configBlock:nil completionBlock:completionBlock];
    
}

@end
