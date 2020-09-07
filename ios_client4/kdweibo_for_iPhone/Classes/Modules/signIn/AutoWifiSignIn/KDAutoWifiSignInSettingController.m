//
//  KDAutoWifiSignInSettingController.m
//  kdweibo
//
//  Created by lichao_liu on 1/5/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDAutoWifiSignInSettingController.h"
#import "KDSignInSettingCell.h"
#import "UIView+Blur.h"
#import "KDTimePicker.h"
#import "KDAutoWifiSignInSettingCell.h"
#import "KDAutoWifiSignInIntroduceController.h"
#import "KDAutoWifiSignInDataManager.h"
#import "KDReachabilityManager.h"
#import "KDErrorDisplayView.h"

#define KDAutoWifiSignInDatapickerTag 10001
@interface KDAutoWifiSignInSettingController ()<UITableViewDataSource,UITableViewDelegate,KDAutoWifiSignInSettingCellDelegate>

@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) KDSignInSettingCell *autoWifiStatusCell;
@property (nonatomic, strong) KDTimePicker *datePicker;
@property (nonatomic, strong) KDAutoWifiSignInSettingCell *onWorkCell;
@property (nonatomic, strong) KDAutoWifiSignInSettingCell *offWorkCell;
@property (nonatomic, strong) KDAutoWifiSignInDataManager *autoWifiSignInDataManager;
@end

@implementation KDAutoWifiSignInSettingController
@synthesize tableview = tableView_;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(ASLocalizedString(@"WIFI自动签到"), nil);
    self.navigationItem.leftBarButtonItems = [KDCommon leftNavigationItemWithTarget:self action:@selector(backAction:)];
    self.autoWifiSignInDataManager = [KDAutoWifiSignInDataManager sharedAutoWifiSignInDataMananger];
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = MESSAGE_BG_COLOR;
    tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width , self.view.bounds.size.height)];
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.backgroundColor = [UIColor clearColor];
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView_];
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
}

- (KDTimePicker *)datePicker {
    if (!_datePicker) {
        UIView *mask = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        mask.tag = KDAutoWifiSignInDatapickerTag;
        mask.alpha = 0.7;
        mask.backgroundColor = [UIColor blackColor];
        [self.navigationController.view addSubview:mask];
        mask.hidden = YES;
        _datePicker = [[KDTimePicker alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.navigationController.view.bounds) - 260, CGRectGetWidth(self.navigationController.view.bounds), 260)];
        _datePicker.hidden = YES;
        [self.navigationController.view addSubview:_datePicker];
    }
    return _datePicker;
}

- (KDSignInSettingCell *)autoWifiStatusCell
{
//    if (!_autoWifiStatusCell) {
//        _autoWifiStatusCell = [[KDSignInSettingCell alloc] initWithFrame:CGRectZero];
//        _autoWifiStatusCell.selectionStyle = UITableViewCellSelectionStyleNone;
//        [_autoWifiStatusCell addBorderAtPosition:KDBorderPositionAll ];
//        _autoWifiStatusCell.leftLabel.text = ASLocalizedString(@"状态");
//        __unsafe_unretained KDAutoWifiSignInSettingController *weakSelf = self;
//        _autoWifiStatusCell.mindSwitch.didChangeHandler = ^(BOOL on) {
//            [KDEventAnalysis event:event_signin_wifiset];
//            if(on)
//            {
//                [weakSelf isWiFiClockInAvaliableWithBlock:^(BOOL result) {
//                    if(result)
//                    {
//                        [weakSelf.autoWifiSignInDataManager setLauchAutoWifiSignInFlag:on];
//                        [weakSelf.autoWifiSignInDataManager initDataForSetting];
//                     }else{
//                        weakSelf.autoWifiStatusCell.mindSwitch.on = NO;
//                    }
//                }];
//            }
//            else {
//                [weakSelf.autoWifiSignInDataManager setLauchAutoWifiSignInFlag:on];
////                [[KDReachabilityManager sharedManager] stopReachability];
//            }
//        };
//    }
//    _autoWifiStatusCell.mindSwitch.on = [_autoWifiSignInDataManager isLauchAutoWifiSignInFlag];
//    _autoWifiStatusCell.middleLabel.hidden = YES;
    return _autoWifiStatusCell;
}

- (KDAutoWifiSignInSettingCell *)onWorkCell
{
    _onWorkCell = [[KDAutoWifiSignInSettingCell alloc] initWithFrame:CGRectZero];
    _onWorkCell.selectionStyle = UITableViewCellSelectionStyleNone;
    _onWorkCell.backgroundColor = [UIColor clearColor];
    _onWorkCell.autoSignInSettingCellType = KDAutoSignInSettingCellType_onWork;
    _onWorkCell.cellDelegate = self;
    
    return _onWorkCell;
}

- (KDAutoWifiSignInSettingCell *)offWorkCell
{
    _offWorkCell = [[KDAutoWifiSignInSettingCell alloc] initWithFrame:CGRectZero];
    _offWorkCell.selectionStyle = UITableViewCellSelectionStyleNone;
    _offWorkCell.autoSignInSettingCellType = KDAutoSignInSettingCellType_offWork;
    _offWorkCell.backgroundColor = [UIColor clearColor];
    _offWorkCell.cellDelegate = self;
    
    return _offWorkCell;
}

- (void)isWiFiClockInAvaliableWithBlock:(void (^)(BOOL result))block
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak KDAutoWifiSignInSettingController *weakSelf =self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        //设置已经从服务器查询是否设置签到点
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (results) {
             if([results[@"success"] boolValue])
             {
                 block(YES);
             }else{
                 block(NO);
                  NSInteger index = [results[@"data"] integerValue];
                 NSString *str = @"";
                 switch (index) {
                     case 0:
                     {
                         str = ASLocalizedString(@"无签到点");
                     }
                         break;
                     case 1:
                     {
                         str = ASLocalizedString(@"有签到点无关联wifi");
                     }
                         break;
                     case 2:
                     {
                         str = ASLocalizedString(@"有wifi关联签到点");
                     }
                         break;
                     default:
                         break;
                 }
                 [weakSelf showError:weakSelf.view title:str];
             }
        }else {
            NSString *errorMessage = [response.responseDiagnosis networkErrorMessage];
            if (KD_IS_BLANK_STR(errorMessage)) {
                errorMessage = ASLocalizedString(@"发生错误，请重试");
            }
            [KDErrorDisplayView showErrorMessage:errorMessage
                                          inView:weakSelf.view.window];
            block(NO);
        }
    };
    [KDServiceActionInvoker invokeWithSender:self
                                  actionPath:@"/signId/:isWiFiClockInAvaliable"
                                  parameters:nil
                                 configBlock:nil
                             completionBlock:completionBlock];
}

- (void)showError:(UIView *)view title:(NSString *)title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:view animated:YES];
        [MBProgressHUD HUDForView:view].labelText = title;
    });
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MBProgressHUD hideAllHUDsForView:view animated:YES];
    });
}


- (void)displayDatePicker {
    UIView *mask = [self.navigationController.view viewWithTag:KDAutoWifiSignInDatapickerTag];
    if (mask) {
        mask.hidden = NO;
    }
    _datePicker.hidden = NO;
}

- (void)dismissDatePicker {
    UIView *mask = [self.navigationController.view viewWithTag:KDAutoWifiSignInDatapickerTag];
    mask.hidden = YES;
    _datePicker.hidden = YES;
}

#pragma mark - tableviewDelegate & datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        cell = [self autoWifiStatusCell];
    }else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell = [self onWorkCell];
            [cell addBorderAtPosition:KDBorderPositionBottom];
        }else if(indexPath.row == 1)
        {
            cell = [self offWorkCell];
            [cell addBorderAtPosition:KDBorderPositionBottom];
        }
    }else if(indexPath.section == 2)
    {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        cell.backgroundColor = [UIColor clearColor];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:ASLocalizedString(@"什么是WIFI自动签到?")];
        [attributedString addAttributes:@{NSForegroundColorAttributeName:BOSCOLORWITHRGBA(0x1A85FF,1.0),NSFontAttributeName :[UIFont systemFontOfSize:13.f]} range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, attributedString.length)];
        cell.textLabel.attributedText = attributedString;
        cell.imageView.image = [UIImage imageNamed:@"sign_img_question_normal"];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }else if(section == 1)
    {
        return 2;
    }else if(section == 2)
    {
        return 1;
    }
    else{
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            return 50;
        }
    }else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            return  [KDAutoWifiSignInSettingCell cellHeightForAutoWifiSignInSettingCellType:KDAutoSignInSettingCellType_onWork];
        }else if(indexPath.row == 1)
        {
            return [KDAutoWifiSignInSettingCell cellHeightForAutoWifiSignInSettingCellType:KDAutoSignInSettingCellType_offWork];
        }
    }else if(indexPath.section == 2)
    {
        return 40;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView_.frame), 35)];
        sectionView.backgroundColor = [UIColor clearColor];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,5, 200, 25)];
        titleLabel.text = ASLocalizedString(@"自动签到时间范围设置:");
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.textColor = MESSAGE_TOPIC_COLOR;
        [sectionView addSubview:titleLabel];
        return sectionView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        return 35;
    }else if(section ==0)
    {
    return 15;
    }
    else
    {
    return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2)
    {
        if(self.isFromAutoSignInSetting)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            KDAutoWifiSignInIntroduceController *introduceController = [[KDAutoWifiSignInIntroduceController alloc] init];
            [self.navigationController pushViewController:introduceController animated:YES];
        }
    }
}

#pragma mark -KDAutoWifiSignInSettingCellDelegate
- (void)whenTimeBtnClickedWithType:(KDAutoSignInSettingCellType)cellType isFromTime:(BOOL)isFromTimeFlag
{
    __unsafe_unretained KDAutoWifiSignInSettingController *weakSelf = self;
    switch (cellType) {
        case KDAutoSignInSettingCellType_offWork:
        {
            weakSelf.datePicker.date = isFromTimeFlag ? _autoWifiSignInDataManager.fromOffWorkTime : _autoWifiSignInDataManager.toOffWorkTime;
            weakSelf.datePicker.leftEventHandler = ^(){
                [weakSelf dismissDatePicker];
            };
            
            self.datePicker.rightEventHandler = ^(){
                if(isFromTimeFlag)
                {
                    if(![weakSelf.autoWifiSignInDataManager compareTimeWithOneTime:weakSelf.autoWifiSignInDataManager.fromOffWorkTime otherTime:weakSelf.datePicker.date])
                    {
                        if(![weakSelf.autoWifiSignInDataManager compareHHMMTimeWithOneTime:weakSelf.datePicker.date otherTime:weakSelf.autoWifiSignInDataManager.toOffWorkTime])
                        {
                            [weakSelf.autoWifiSignInDataManager showAlertWithMessage:ASLocalizedString(@"WIFI自动签到下班时间段开始时间不能大于结束时间")title:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")];
                            return ;
                        }
                        
                        if(![weakSelf.autoWifiSignInDataManager compareHHMMTimeWithOneTime:weakSelf.autoWifiSignInDataManager.toOnWorkTime otherTime:weakSelf.datePicker.date])
                        {
                            [weakSelf.autoWifiSignInDataManager showAlertWithMessage:ASLocalizedString(@"WIFI自动签到下班时间段开始时间不能小于上班时间段结束时间")title:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")];
                            return ;
                        }
                        
                        weakSelf.autoWifiSignInDataManager.fromOffWorkTime = weakSelf.datePicker.date;
                        [weakSelf.tableview reloadData];
                    }
                }else{
                    if(![weakSelf.autoWifiSignInDataManager compareTimeWithOneTime:weakSelf.autoWifiSignInDataManager.toOffWorkTime otherTime:weakSelf.datePicker.date])
                    {
                        if([weakSelf.autoWifiSignInDataManager compareHHMMTimeWithOneTime:weakSelf.datePicker.date otherTime:weakSelf.autoWifiSignInDataManager.fromOffWorkTime])
                        {
                            [weakSelf.autoWifiSignInDataManager showAlertWithMessage:ASLocalizedString(@"WIFI自动签到下班时间段结束时间不能小于开始时间")title:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")];
                            return ;
                        }
                        weakSelf.autoWifiSignInDataManager.toOffWorkTime = weakSelf.datePicker.date;
                        [weakSelf.tableview reloadData];
                    }
                }
                [weakSelf dismissDatePicker];
            };
            
        }
            break;
        case KDAutoSignInSettingCellType_onWork:
        {
            self.datePicker.date = isFromTimeFlag ? _autoWifiSignInDataManager.fromOnWorkTime : _autoWifiSignInDataManager.toOnWorkTime;
            __unsafe_unretained KDAutoWifiSignInSettingController *weakSelf = self;
            self.datePicker.leftEventHandler = ^(){
                [weakSelf dismissDatePicker];
            };
            
            self.datePicker.rightEventHandler = ^(){
                 if(isFromTimeFlag)
                {
                    if(![weakSelf.autoWifiSignInDataManager compareTimeWithOneTime:weakSelf.autoWifiSignInDataManager.fromOnWorkTime otherTime:weakSelf.datePicker.date])
                    {
                          if(![weakSelf.autoWifiSignInDataManager compareHHMMTimeWithOneTime:weakSelf.datePicker.date otherTime:weakSelf.autoWifiSignInDataManager.toOnWorkTime])
                        {
                            [weakSelf.autoWifiSignInDataManager showAlertWithMessage:ASLocalizedString(@"WIFI自动签到上班时间段开始时间不能大于结束时间")title:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")];
                            return ;
                        }
                        weakSelf.autoWifiSignInDataManager.fromOnWorkTime = weakSelf.datePicker.date;
                        [weakSelf.tableview reloadData];
                    }
                }else{
                    if(![weakSelf.autoWifiSignInDataManager compareTimeWithOneTime:weakSelf.autoWifiSignInDataManager.toOnWorkTime otherTime:weakSelf.datePicker.date])
                    {
                        if([weakSelf.autoWifiSignInDataManager compareHHMMTimeWithOneTime:weakSelf.datePicker.date otherTime:weakSelf.autoWifiSignInDataManager.fromOnWorkTime])
                        {
                             [weakSelf.autoWifiSignInDataManager showAlertWithMessage:ASLocalizedString(@"WIFI自动签到上班时间段结束时间不能小于开始时间")title:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")];
                            return ;
                        }
                        
                        if([weakSelf.autoWifiSignInDataManager compareHHMMTimeWithOneTime:weakSelf.autoWifiSignInDataManager.fromOffWorkTime otherTime:weakSelf.datePicker.date])
                        {
                            [weakSelf.autoWifiSignInDataManager showAlertWithMessage:ASLocalizedString(@"WIFI自动签到上班时间段结束时间不能大于下班时间段开始时间")title:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")];
                            return ;
                        }
                        weakSelf.autoWifiSignInDataManager.toOnWorkTime = weakSelf.datePicker.date;
                        [weakSelf.tableview reloadData];
                    }
                }
                
                [weakSelf dismissDatePicker];
            };
            
        }
            break;
        default:
            break;
    }
    [self displayDatePicker];
}

@end
