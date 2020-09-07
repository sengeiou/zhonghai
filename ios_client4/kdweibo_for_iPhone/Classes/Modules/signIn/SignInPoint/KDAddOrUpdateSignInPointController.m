//
//  KDAddSignInPointController.m
//  kdweibo
//
//  Created by lichao_liu on 1/19/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDAddOrUpdateSignInPointController.h"
#import "KDSignInViewController.h"
#import "KDSignInSettingViewController.h"
#import "KDSetSignInPointVC.h"

#import "KDSignInPointWorkTimeCell.h"
#import "KDTimePicker.h"
#import "KDDistancePicker.h"

#import "KDLocationData.h"
#import "KDLocationManager.h"
#import "KDSignInClient.h"
#import "KDSignInLogManager.h"

#import "NSDate+Additions.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface KDAddOrUpdateSignInPointController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) KDTimePicker *datePicker;
@property (nonatomic, strong) NSArray *locationDataArray;
@property (nonatomic, strong) KDLocationData *currentLocationData;
@property (nonatomic, strong) KDSignInClient *searchPOIClient;

@property (nonatomic, strong) KDSignInPointWorkTimeCell *workTimeCell;
@property (nonatomic, strong) KDTableViewCell *alisaCell;
@property (nonatomic, strong) KDTableViewCell *rangeCell;
@property (nonatomic, strong) KDDailySignInCountCell *dailySignInCountCell;

@property (nonatomic, strong) UITextField *companyField;

@property (nonatomic, strong) KDDistancePicker *distancePicker;

@end

@implementation KDAddOrUpdateSignInPointController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.companyField resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    BOOL hasSignInPoint = YES;
    
    self.title = self.addOrUpdateSignInPointType == KDAddOrUpdateSignInPointType_update ? ASLocalizedString(@"编辑签到点"): ASLocalizedString(@"新增签到点");
    [self addRightNavgationBtn];
    [self addLeftNavationBtn];
    
    if (!self.signInPoint) {
        self.signInPoint = [KDSignInPoint new];
        self.signInPoint.offset = 200;
        self.signInPoint.clockInSectionTimes = 2;
        hasSignInPoint = NO;
        
        if (self.signInPointId) {
            [self getSigninPointMessage];
        }
    }
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame),   CGRectGetHeight(self.view.frame) - 64)   style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.clipsToBounds = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

- (void)addRightNavgationBtn
{
    UIButton *saveBtn = [UIButton blueBtnWithTitle:ASLocalizedString(@"完成")];
    [saveBtn addTarget:self action:@selector(saveOperation:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
//    [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
}

- (void)addLeftNavationBtn{
    UIButton *backBtn = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"返回")];
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (KDTableViewCell *)alisaCell {
    if (!_alisaCell) {
        _alisaCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"_alisaCell"];
        _alisaCell.textLabel.text = ASLocalizedString(@"签到点名称");
        [_alisaCell.contentView addSubview:self.companyField];
    }
    
    _alisaCell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    if (safeString(self.signInPoint.alias).length > 0) {
        self.companyField.text = self.signInPoint.alias;
    }
    else if (safeString(self.signInPoint.positionName).length > 0) {
        self.companyField.text = self.signInPoint.positionName;
    }
    else {
        self.companyField.text = @"";
    }
    return _alisaCell;
}

-(UITextField *)companyField
{
    if(!_companyField)
    {
        _companyField = [[UITextField alloc] initWithFrame:CGRectMake(100, 7, CGRectGetWidth(self.tableView.frame)-100-[NSNumber kdDistance1], 30)];
        _companyField.backgroundColor = [UIColor clearColor];
        _companyField.font = FS4;
        _companyField.textColor = FC2;
        _companyField.textAlignment = NSTextAlignmentRight;
        _companyField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _companyField.placeholder = ASLocalizedString(@"请输入签到点名称");
        _companyField.delegate = self;
        _companyField.returnKeyType = UIReturnKeyDone;
    }
    return _companyField;
}

- (KDTableViewCell *)rangeCell  {
    if (!_rangeCell) {
        _rangeCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"_rangeCell"];
        _rangeCell.textLabel.text = ASLocalizedString(@"有效签到范围");
        _rangeCell.textLabel.textColor = FC1;
        _rangeCell.detailTextLabel.textColor = FC5;
    }
    _rangeCell.detailTextLabel.text = (self.signInPoint && self.signInPoint.offset>0) ? [NSString stringWithFormat:ASLocalizedString(@"%ld米"),(long)self.signInPoint.offset] : ASLocalizedString(@"200米");
    return _rangeCell;
}

- (KDDailySignInCountCell *)dailySignInCountCell {
    if (!_dailySignInCountCell) {
        _dailySignInCountCell = [[KDDailySignInCountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DailySignInCountCell"];
        _dailySignInCountCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _dailySignInCountCell.dailySignInCount = self.signInPoint.clockInSectionTimes;
    }
    return _dailySignInCountCell;
}

- (KDSignInPointWorkTimeCell *)workTimeCell
{
    if(!_workTimeCell)
    {
        _workTimeCell = [[KDSignInPointWorkTimeCell  alloc] initWithFrame:CGRectZero];
        _workTimeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        __weak KDAddOrUpdateSignInPointController *weakSelf = self;
        
        [_workTimeCell setBlock:^(KDSignInPointWorkTimeType type){
            
            weakSelf.datePicker.rightEventHandler = ^(void){
                NSString *timeStr = [weakSelf.datePicker.date formatWithFormatter:KD_DATE_TIME];
                switch (type) {
                    case KDSignInPointWorkTimeType_fromBeginTime:
                    {
                        if([weakSelf compareHHMMTimeWithOneTimeStr:timeStr otherTimeStr:weakSelf.signInPoint.startWorkEnd])
                        {
                            weakSelf.signInPoint.startWorkBegin = timeStr;
                            [weakSelf.workTimeCell.fromBeginTimeBtn setTitle:timeStr forState:UIControlStateNormal];
                        }else{
                            [weakSelf showAlertViewWithMessage:ASLocalizedString(@"上午上班时间不能先于上午下班时间")];
                            return;
                        }
                    }
                        break;
                    case KDSignInPointWorkTimeType_toBeginTime:
                    {
                        if([weakSelf compareHHMMTimeWithOneTimeStr:timeStr otherTimeStr:weakSelf.signInPoint.startWorkBegin])
                        {
                            [weakSelf showAlertViewWithMessage:ASLocalizedString(@"上午上班时间不能先于上午下班时间")];
                            return;
                        }
                        if([weakSelf compareHHMMTimeWithOneTimeStr:timeStr otherTimeStr:weakSelf.signInPoint.endWorkBegin])
                        {
                            weakSelf.signInPoint.startWorkEnd = timeStr;
                            [weakSelf.workTimeCell.toBeginTimeBtn setTitle:timeStr forState:UIControlStateNormal];
                        }else{
                            [weakSelf showAlertViewWithMessage:ASLocalizedString(@"上午下班时间不能先于下午上班时间")];
                            return;
                        }
                    }
                        break;
                    case KDSignInPointWorkTimeType_fromEndTime:
                    {
                        if([weakSelf compareHHMMTimeWithOneTimeStr:timeStr otherTimeStr:weakSelf.signInPoint.startWorkEnd])
                        {
                            [weakSelf showAlertViewWithMessage:ASLocalizedString(@"上午下班时间不能先于下午上班时间")];
                            return;
                        }
                        if([weakSelf compareHHMMTimeWithOneTimeStr:timeStr otherTimeStr:weakSelf.signInPoint.endWorkEnd])
                        {
                            weakSelf.signInPoint.endWorkBegin = timeStr;
                            [weakSelf.workTimeCell.fromEndTimeBtn setTitle:timeStr forState:UIControlStateNormal];
                        }else{
                            [weakSelf showAlertViewWithMessage:ASLocalizedString(@"下午上班时间不能先于下午下班时间")];
                            return;
                        }
                        
                    }
                        break;
                    case KDSignInPointWorkTimeType_toEndTime:
                    {
                        if([weakSelf compareHHMMTimeWithOneTimeStr:weakSelf.signInPoint.endWorkBegin otherTimeStr:timeStr])
                        {
                            weakSelf.signInPoint.endWorkEnd = timeStr;
                            [weakSelf.workTimeCell.toEndTimeBtn setTitle:timeStr forState:UIControlStateNormal];
                        }else{
                            [weakSelf showAlertViewWithMessage:ASLocalizedString(@"下午上班时间不能先于下午下班时间")];
                            return;
                        }
                    }
                        break;
                    default:
                        break;
                }
                NSString *distanceStr = [weakSelf getDistanceOfSignInPoint];
                weakSelf.workTimeCell.countTimeLabel.text = distanceStr;
                [weakSelf dismissDatePicker];
            };
            weakSelf.datePicker.leftEventHandler = ^(void){
                [weakSelf dismissDatePicker];
            };
            switch (type) {
                case KDSignInPointWorkTimeType_fromBeginTime:
                {
                    weakSelf.datePicker.date = [weakSelf getDateWithTimeStr: weakSelf.signInPoint.startWorkBegin];
                }
                    break;
                case KDSignInPointWorkTimeType_toBeginTime:
                {
                    weakSelf.datePicker.date = [weakSelf getDateWithTimeStr:weakSelf.signInPoint.startWorkEnd];
                }
                    break;
                case KDSignInPointWorkTimeType_fromEndTime:
                {
                    weakSelf.datePicker.date = [weakSelf getDateWithTimeStr:weakSelf.signInPoint.endWorkBegin];
                }
                    break;
                case KDSignInPointWorkTimeType_toEndTime:
                {
                    weakSelf.datePicker.date = [weakSelf getDateWithTimeStr:weakSelf.signInPoint.endWorkEnd];
                }
                default:
                    break;
            }
            [weakSelf displayDatePicker];
        }];
    }
    NSString *fromTimeStr = @"08:30";
    NSString *endTimeStr = @"12:00";
    
    NSString *fromEndTimeStr = @"13:30";
    NSString *toEndTimeStr = @"18:00";
    
    if(self.signInPoint && self.signInPoint.startWorkBegin)
    {
        fromTimeStr = self.signInPoint.startWorkBegin;
    }else
    {
        self.signInPoint.startWorkBegin = fromTimeStr;
    }
    if(self.signInPoint && self.signInPoint.startWorkEnd)
    {
        endTimeStr = self.signInPoint.startWorkEnd;
    }else{
        self.signInPoint.startWorkEnd = endTimeStr;
    }
    
    if(self.signInPoint && self.signInPoint.endWorkBegin)
    {
        fromEndTimeStr = self.signInPoint.endWorkBegin;
    }else{
        self.signInPoint.endWorkBegin = fromEndTimeStr;
    }
    
    if(self.signInPoint && self.signInPoint.endWorkEnd)
    {
        toEndTimeStr = self.signInPoint.endWorkEnd;
    }else{
        self.signInPoint.endWorkEnd = toEndTimeStr;
    }
    
    [_workTimeCell initDataWithFromBeginTime:fromTimeStr toBeginTime:endTimeStr fromEndTime:fromEndTimeStr toendTime:toEndTimeStr];
    return _workTimeCell;
}

- (NSDate *)getDateWithTimeStr:(NSString *)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:KD_DATE_TIME];
    return [dateFormatter dateFromString:str];
}

- (void)backBtnAction:(id)sender{
    [self dismissSelf];
}

#pragma mark - UITableviewdelegate & UITableViewDatasource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.addOrUpdateSignInPointType == KDAddOrUpdateSignInPointType_add) {
        return 3;
    }
    else if (self.addOrUpdateSignInPointType == KDAddOrUpdateSignInPointType_update) {
        return 4;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return self.alisaCell;
        }
        else if(indexPath.row == 1) {
            static NSString *cellIdentifier1 = @"cellIdentifier1";
            KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
            if(cell == nil)
            {
                cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier1];
                cell.textLabel.text = ASLocalizedString(@"签到点地址");
                cell.detailTextLabel.textColor = FC2;
            }
            
            if (safeString(self.signInPoint.detailAddress).length > 0) {
                cell.detailTextLabel.text = self.signInPoint.detailAddress;
            }
            else if (safeString(self.signInPoint.positionName).length > 0) {
                cell.detailTextLabel.text = self.signInPoint.positionName;
            }
            else {
                cell.detailTextLabel.text = ASLocalizedString(@"请选择");
            }
            cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
            cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
            return cell;
        }
        else if(indexPath.row == 2) {
            return self.rangeCell;
        }
    }
    else if (indexPath.section == 1) {
        return self.dailySignInCountCell;
    }
    else if (indexPath.section == 2) {
        KDSignInPointWorkTimeCell *cell = [self workTimeCell];
        return cell;
    }
    
    if (self.addOrUpdateSignInPointType == KDAddOrUpdateSignInPointType_update) {
        if (indexPath.section == 3) {
            static NSString *cellIdentifier3 = @"cellIdentifier3";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
            }
            
            cell.textLabel.text = ASLocalizedString(@"删除签到点");
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = FC4;
            cell.textLabel.font = FS3;
            return cell;
            
        }
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section < 3) {
        return [NSNumber kdDistance2];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height =44;
    if (indexPath.section == 2) {
        height = 140;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.companyField resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            if (self.isFromSetSignInPointVC) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [self doSignin];
            }
        }
        else if (indexPath.row == 2) {
            [self displayDistancePicker];
            if (self.signInPoint && self.signInPoint.offset>0) {
                [self.distancePicker setDistance:self.signInPoint.offset];
            }
        }
    }
    else if (self.addOrUpdateSignInPointType == KDAddOrUpdateSignInPointType_update && indexPath.section == 3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"确认删除签到点")
                                                        message:ASLocalizedString(@"删除签到点后，在此办公地点的签到将视为外勤，确定要删除吗？")
                                                       delegate:self
                                              cancelButtonTitle:ASLocalizedString(@"取消")
                                              otherButtonTitles:ASLocalizedString(@"确认"), nil];
        alert.tag = 900002;
        [alert show];
    }
    
    return;
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.companyField resignFirstResponder];
}

- (void)deleteSignInPoint {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addOrUpdateSignInPointSuccess:signInPointType:rowIndex:)]) {
        [self.delegate addOrUpdateSignInPointSuccess:self.signInPoint signInPointType:KDAddOrUpdateSignInPointType_delete rowIndex:self.rowIndex];
    }
    
    [self dismissSelf];
}

#pragma mark -  DatePicker Stuff

- (KDTimePicker *)datePicker {
    if (!_datePicker) {
        UIView *mask = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        mask.tag = 100;
        mask.backgroundColor = [UIColor colorWithRGB:0x0C213F alpha:0.3];
        [[[UIApplication sharedApplication].windows firstObject] addSubview:mask];
        mask.hidden = YES;
        _datePicker = [[KDTimePicker alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.navigationController.view.bounds) - 260, CGRectGetWidth(self.navigationController.view.bounds), 260)];
        _datePicker.hidden = YES;
        [[[UIApplication sharedApplication].windows firstObject] addSubview:_datePicker];
    }
    return _datePicker;
}

- (void)displayDatePicker {
    UIView *mask = [[[UIApplication sharedApplication].windows firstObject] viewWithTag:100];
    if (mask) {
        mask.hidden = NO;
    }
    
    _datePicker.hidden = NO;
}

- (void)dismissDatePicker {
    UIView *mask = [[[UIApplication sharedApplication].windows firstObject] viewWithTag:100];
    mask.hidden = YES;
    _datePicker.hidden = YES;
}


- (void)displayDistancePicker
{
    if (!_distancePicker) {
        UIView *mask = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        mask.tag = 900;
        mask.backgroundColor = [UIColor colorWithRGB:0x0C213F alpha:0.3];
        [self.navigationController.view addSubview:mask];
        mask.hidden = YES;
        _distancePicker = [[KDDistancePicker alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.navigationController.view.bounds) - 260, CGRectGetWidth(self.navigationController.view.bounds), 260)];
        _distancePicker.hidden = YES;
        [self.navigationController.view addSubview:_distancePicker];
        
        __weak KDAddOrUpdateSignInPointController *weakSelf = self;
        _distancePicker.leftEventHandler = ^(NSInteger distance){
            [weakSelf dismissDistancePicker];
        };
        _distancePicker.rightEventHandler = ^(NSInteger distance){
            weakSelf.rangeCell.detailTextLabel.text =  [NSString stringWithFormat:ASLocalizedString(@"%ld米"),(long)distance];
            weakSelf.signInPoint.offset = distance;
            [weakSelf dismissDistancePicker];
        };
    }
    
    UIView *mask = [self.navigationController.view viewWithTag:900];
    if (mask) {
        mask.hidden = NO;
    }
    _distancePicker.hidden = NO;
}

- (void)dismissDistancePicker
{
    UIView *mask = [self.navigationController.view viewWithTag:900];
    mask.hidden = YES;
    _distancePicker.hidden = YES;
}

- (void)saveOperation:(id )sender {
    [self.companyField resignFirstResponder];
    
    if (self.addOrUpdateSignInPointType == KDAddOrUpdateSignInPointType_add) {
        if (!self.signInPoint.positionName || [self.signInPoint.positionName isEqualToString:@""] || self.signInPoint.positionName.length == 0) {
            [self getAlertViewWithMessage:ASLocalizedString(@"添加签到点，请先选择办公地点")];
            return;
        }
    }
    
    if (![self compareHHMMTimeWithOneTime:self.signInPoint.startWorkBegin otherTime:self.signInPoint.startWorkEnd]) {
        [self getAlertViewWithMessage:ASLocalizedString(@"上班起始时间不能大于上班结束时间")];
        return;
    }
    
    if (![self compareHHMMTimeWithOneTime:self.signInPoint.startWorkEnd otherTime:self.signInPoint.endWorkBegin]) {
        [self getAlertViewWithMessage:ASLocalizedString(@"上班结束时间不能大于下班起始时间")];
        return;
    }
    
    if (![self compareHHMMTimeWithOneTime:self.signInPoint.endWorkBegin otherTime:self.signInPoint.endWorkEnd]) {
        [self getAlertViewWithMessage:ASLocalizedString(@"下班起始时间不能大于下班结束时间")];
        return;
    }
    
    [self saveSignInPoint];
}


- (void)dismissSelf{
    if (self.isFromSetSignInPointVC) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)getAlertViewWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:ASLocalizedString(@"确定") otherButtonTitles: nil];
    [alert show];
}

- (BOOL)compareHHMMTimeWithOneTime:(NSString  *)oneTime otherTime:(NSString *)otherTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:KD_DATE_TIME];
    NSDate *date1 = [dateFormatter dateFromString:oneTime];
    NSDate *date2 = [dateFormatter dateFromString:otherTime];
    NSComparisonResult result =[date1 compare:date2];
    if(result == NSOrderedAscending)
    {
        return YES;
    }else if(result == NSOrderedDescending) {
        return NO;
    }
    return YES;
    
}

- (void)showError:(NSString *)error completionBlock:(void(^)())block
{
    __weak KDAddOrUpdateSignInPointController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [KDPopup showHUDToast:error inView:weakSelf.view ];
    });
    double delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(block)
        {
            block();
        }
    });
}

- (void)showSuccess:(NSString *)error completionBlock:(void(^)())block
{
    __weak KDAddOrUpdateSignInPointController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [KDPopup showHUDSuccess:error inView:weakSelf.view];
    });
    double delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(block)
        {
            block();
        }
    });
}

- (void)doSignin
{
    [KDEventAnalysis event:event_signin_clickbtn];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        NSString *msg = [NSString stringWithFormat:ASLocalizedString(@"打开“定位服务”允许“%@”确定你的位置"),KD_APPNAME];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"定位服务不可用") message:msg delegate:self cancelButtonTitle:ASLocalizedString(@"确认") otherButtonTitles:nil];
        
        [alert show];
    }else {
        
        [self startLocation];
    }
}

- (void)startLocation {
    if([KDReachabilityManager sharedManager].reachabilityStatus == KDReachabilityStatusNotReachable)
    {
        NSString * message = ASLocalizedString(@"当前网络不可用，请检查你的网络设置");
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:message delegate:nil cancelButtonTitle:ASLocalizedString(@"确定") otherButtonTitles: nil];
        [alertView show];
        
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationPOIFailure object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationPOISuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationPoiStart object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFailed:) name:KDNotificationLocationPOIFailure object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationNearbyDidSucess:) name:KDNotificationLocationPOISuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidstart:) name:KDNotificationLocationPoiStart object:nil];
    
    
    [[KDLocationManager globalLocationManager] setLocationType:KDLocationTypeGetPoiArray];
    [[KDLocationManager globalLocationManager] startLocating];
}


- (void)locationDidFailed:(NSNotification *)notifcation {
    
    NSDictionary *info = notifcation.userInfo;
    NSString *error = [NSString stringWithFormat:@"reason:%@\ndescription:%@" ,((NSError *)[info objectForKey:@"error"]).localizedFailureReason, ((NSError *)[info objectForKey:@"error"]).description];
    NSString * failedType = info[@"failedType"];
    
    [KDPopup hideHUDInView:self.view];
    if ([failedType isEqualToString:KDSignInFailedTypeLocation]) {
        UIAlertView * alertView =[[UIAlertView alloc]initWithTitle:@"" message:ASLocalizedString(@"由于网络信号较弱或不稳定，定位失败，请换个位置再试试") delegate:self cancelButtonTitle:ASLocalizedString(@"取消") otherButtonTitles:ASLocalizedString(@"再试一次"), nil];
        [alertView show];
    }
    else if ([failedType isEqualToString:KDSignInFailedTypePOIError]) {
        self.currentLocationData = info[@"currentData"];
        [self searchPOIFromOwnServer];
    }
    
    [KDSignInLogManager sendSignInLogWithFailureType:failedType errorMessage:error];
}

-(void)searchPOIFromOwnServer{
    if (_searchPOIClient == nil) {
        _searchPOIClient = [[KDSignInClient alloc]initWithTarget:self action:@selector(searchPOIDidReceived:result:)];
    }
    if(self.currentLocationData)
    {
        [KDPopup showHUD:ASLocalizedString(@"正在定位...") inView:self.view];
        [_searchPOIClient searchPOIWithLatitude:self.currentLocationData.coordinate.latitude longitude:self.currentLocationData.coordinate.longitude];
    }
}


- (void)searchPOIDidReceived:(KDSignInClient *)client result:(BOSResultDataModel *)result{
    
    [KDPopup hideHUDInView:self.view];
    BOSResultDataModel *bosResult = [[BOSResultDataModel alloc] initWithDictionary:(NSDictionary *)result];
    if (client.hasError ||bosResult == nil || bosResult.success == NO ) {
        [self showError:ASLocalizedString(@"定位失败") completionBlock:nil];
    }
    else{
        NSMutableArray * posArray = [NSMutableArray array];
        NSString * address = bosResult.data[@"address"];
        NSDictionary * formatted_addresses = bosResult.data[@"formatted_addresses"];
        NSString * recommend = formatted_addresses[@"recommend"];
        NSString * rough = formatted_addresses[@"rough"];
        KDLocationData * locationData = [[KDLocationData alloc]init];
        locationData.address = address;
        locationData.name = (recommend.length > 0 ? recommend : rough);
        locationData.coordinate = _currentLocationData.coordinate;
        [posArray addObject:locationData];
        NSArray * pois = [bosResult.data objectForKey:@"pois"];
        for (NSDictionary * dic in pois) {
            KDLocationData * locationData = [KDLocationData locationDataByDictionary:dic];
            if (locationData) {
                locationData.city = _currentLocationData.city;
                locationData.province = _currentLocationData.province;
                locationData.district = _currentLocationData.district;
                [posArray addObject:locationData];
            }
        }
        self.locationDataArray = posArray;
        self.currentLocationData = [posArray objectAtIndex:0];
        //网络状态不好时，正在获取周边，用户切换到了其它页面时，不再显示周边列表 song.wang 2014-01-14
        if (self.view.window == [UIApplication sharedApplication].keyWindow) {
            [self showLocationOptionViewController];
        }else {
        }
        
    }
}

- (void)showLocationOptionViewController
{
    KDSetSignInPointVC *setSigninVC = [[KDSetSignInPointVC alloc] initWithNibName:@"KDSetSignInPointVC" bundle:nil];
    if(self.signInPoint){
        setSigninVC.kdistance = self.signInPoint.offset;
    }
    setSigninVC.determineBlock = ^(KDLocationData *locationData,id controller){
        if(locationData)
        {
            self.signInPoint.lat = locationData.coordinate.latitude;
            self.signInPoint.lng = locationData.coordinate.longitude;
            self.signInPoint.positionName = locationData.name;
            self.signInPoint.detailAddress = locationData.longAddress;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    };
    setSigninVC.sourceType = SetSignInPointSource_addOrupdateSignInPointVC;
    
    //先显示该地址
    KDLocationData *data = [KDLocationData new];
    data.name = self.signInPoint.positionName;
    data.address = self.signInPoint.detailAddress;
    data.coordinate = CLLocationCoordinate2DMake(self.signInPoint.lat, self.signInPoint.lng);
    setSigninVC.tempLocationData = data;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:setSigninVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (NSString *)generateIssueContent {
    NSString *version = [KDCommon clientVersion];
    NSString *model = [[UIDevice currentDevice] model];
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString * statusString = [KDReachabilityManager sharedManager].reachabilityStatusDescription;
    
    return [NSString stringWithFormat:@"iOS，%@ %@，%@，%@:%@", model, iosVersion,statusString,KD_APPNAME,version];
}

- (BOOL)canGoToLocationOption
{
    return (_currentLocationData !=nil && _locationDataArray!= nil);
}

- (void)locationNearbyDidSucess:(NSNotification *)notifcation {
    [KDPopup hideHUDInView:self.view];
    NSDictionary *info = notifcation.userInfo;
    NSArray *array = [info objectForKey:@"locationArray"];
    self.locationDataArray = array;
    self.currentLocationData = [array objectAtIndex:0];
    if (self.view.window == [UIApplication sharedApplication].keyWindow) {
        [self showLocationOptionViewController];
    }
}

- (void)locationDidstart:(NSNotification *)notifcation {
    [KDPopup showHUD:ASLocalizedString(@"正在定位...") inView:self.view];
}

#pragma mark - 保存签到点信息 -
- (void)saveSignInPoint {
    __weak KDAddOrUpdateSignInPointController *weakSelf = self;
    [self saveSignInPointWithBlock:^(BOOL success, NSString *signInPointId,NSString *errorMessage) {
        if(success) {
            [weakSelf showSuccess:ASLocalizedString(@"保存成功") completionBlock:^() {
                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(addOrUpdateSignInPointSuccess:signInPointType:rowIndex:)]) {
                    weakSelf.signInPoint.signInPointId = signInPointId;
                    [weakSelf.delegate addOrUpdateSignInPointSuccess:weakSelf.signInPoint signInPointType:weakSelf.addOrUpdateSignInPointType rowIndex:weakSelf.rowIndex];
                }
                [weakSelf dismissSelf];
            }];
        }
        else {
            [KDPopup hideHUDInView:weakSelf.view];
            NSString *str = weakSelf.addOrUpdateSignInPointType == KDAddOrUpdateSignInPointType_add ? ASLocalizedString(@"添加签到点失败"):ASLocalizedString(@"修改签到点信息失败");
//            [KDPopup showAlertWithTitle:nil message:safeString(errorMessage).length > 0 ? errorMessage : str buttonTitles:@[ASLocalizedString(@"知道了")] onTap:nil];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:safeString(errorMessage).length > 0 ? errorMessage : str delegate:self cancelButtonTitle:nil otherButtonTitles:ASLocalizedString(@"知道了"), nil];
            [alert show];
        }
    }];
}

// 新增或修改签到点新接口,这里的修改签到点实则是创建一个新的签到点,然后替换旧的签到点,不这样做的话会导致用户修改了签到点,又不保存签到组信息的时候出现的数据不一致问题
- (void)saveSignInPointWithBlock:(void (^)(BOOL success,NSString *signInPointId,NSString *errorMessage))block {
    [KDPopup showHUD:self.addOrUpdateSignInPointType == KDAddOrUpdateSignInPointType_add ? ASLocalizedString(@"正在添加签到点"):ASLocalizedString(@"正在修改签到点") inView:self.view];
    
    if (self.signInPoint.offset == 0) {
        self.signInPoint.offset = 200;
    }
    NSString *positions = [NSString stringWithFormat:@"%@|%@|%@|%f|%f|%ld",self.signInPoint.positionName, self.signInPoint.detailAddress ? self.signInPoint.detailAddress:self.signInPoint.positionName, safeString(self.signInPoint.alias), self.signInPoint.lng, self.signInPoint.lat, (long)self.signInPoint.offset];
    NSString *attendanceTimes = [NSString stringWithFormat:@"%@|%@|%@|%@",self.signInPoint.startWorkBegin, self.signInPoint.startWorkEnd, self.signInPoint.endWorkBegin, self.signInPoint.endWorkEnd];
    
    //签到迁移，暂时屏蔽
//    KDSaveSignInPointRequest *request = [[KDSaveSignInPointRequest alloc] initWithPositions:positions attendanceTimes:attendanceTimes sourceAttSetsStr:self.sourceAttSetsStr clockInSectionTimes:self.dailySignInCountCell.dailySignInCount];
//    [request startCompletionBlockWithSuccess:^(__kindof KDRequest * _Nonnull request) {
//        if (kd_safeString(request.response.responseObject[@"attendanceSetId"]).length > 0) {
//            block(YES, request.response.responseObject[@"attendanceSetId"], nil);
//        }
//        else {
//            block(NO, nil, kd_safeDictionary(request.response.originalResponseObject)[@"errorMsg"]);
//        }
//    } failure:^(__kindof KDRequest * _Nonnull request) {
//        block(NO, nil, kd_safeDictionary(request.response.originalResponseObject)[@"errorMsg"]);
//    }];
    
    __weak KDAddOrUpdateSignInPointController *weakSelf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if (results) {
            NSDictionary *data = results[@"data"];
            if (data && [data isKindOfClass:[NSDictionary class]] && data.count > 0) {
                block(YES, data[@"attendanceSetId"], nil);
            }
            else {
                block(NO, nil, safeString(results[@"errorMsg"]));
            }
        } else {
            block(NO, nil, ASLocalizedString(@"保存失败"));
        }
    };
    
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"positions" stringValue:positions];
    [query setParameter:@"attendanceTimes" stringValue:attendanceTimes];
    [query setParameter:@"sourceAttSetsStr" stringValue:self.sourceAttSetsStr];
    [query setParameter:@"clockInSectionTimes" integerValue:self.dailySignInCountCell.dailySignInCount];
    
    [KDServiceActionInvoker invokeWithSender:weakSelf
                                  actionPath:@"/signId/:saveSignInPoint"
                                       query:query
                                 configBlock:nil
                             completionBlock:completionBlock];
}

- (NSString *)jsonFromArray:(NSArray *)array
{
    NSString *result;
    if ([NSJSONSerialization isValidJSONObject:array]) {
        @try {
            NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
            if (data) {
                result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
        }
        @catch (NSException *exception) {
            result = @"";
        }
        @finally {
        }
    }
    return result;
}

#pragma mark - alertviewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 99901)
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if(buttonIndex == 1 && alertView.tag == 900002)
    {
        [self deleteSignInPoint];
    }
}

- (NSString *)getDistanceOfSignInPoint
{
    NSString *fromBeginTimeStr = [_workTimeCell.fromBeginTimeBtn titleForState:UIControlStateNormal];
    NSString *toBeginTimeStr = [_workTimeCell.toBeginTimeBtn titleForState:UIControlStateNormal];
    NSString *fromEndTimeStr = [_workTimeCell.fromEndTimeBtn titleForState:UIControlStateNormal];
    NSString *toEndTimeStr = [_workTimeCell.toEndTimeBtn titleForState:UIControlStateNormal];
    
    CGFloat amDisatance = [self distanceBetwenTwoTime:fromBeginTimeStr endTimeStr:toBeginTimeStr];
    CGFloat pmDistance = [self distanceBetwenTwoTime:fromEndTimeStr endTimeStr:toEndTimeStr];
    CGFloat middayRestDidtance = [self distanceBetwenTwoTime:toBeginTimeStr endTimeStr:fromEndTimeStr];
    return [NSString stringWithFormat:ASLocalizedString(@"标准工时%.2f小时  午休时长%.2f小时"), amDisatance+pmDistance, middayRestDidtance];
}

- (CGFloat)getAccurateTimeDistanceBetwwenAmDistance:(CGFloat)amDistance pmDistance:(CGFloat)pmDistance
{
    return 0;
}

- (CGFloat)distanceBetwenTwoTime:(NSString *)beginTimeStr endTimeStr:(NSString *)endTimeStr
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSDate *date1=[dateFormatter dateFromString:beginTimeStr];
    NSDate *date2=[dateFormatter dateFromString:endTimeStr];
    
    NSTimeInterval time=[date2 timeIntervalSinceDate:date1];
    typedef double NSTimeInterval;
    
    CGFloat hours = time/3600;
    return hours;
}


- (BOOL)compareHHMMTimeWithOneTimeStr:(NSString *)oneTimeStr otherTimeStr:(NSString *)otherTimeStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:KD_DATE_TIME];
    NSDate *date1 = [dateFormatter dateFromString:oneTimeStr];
    NSDate *date2 = [dateFormatter dateFromString:otherTimeStr];
    NSComparisonResult result =[date1 compare:date2];
    if(result == NSOrderedAscending)
    {
        return YES;
    }else if(result == NSOrderedDescending) {
        return NO;
    }
    return YES;
    
}

- (void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:ASLocalizedString(@"确定") otherButtonTitles:nil];
    [alert show];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationPOIFailure object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationPOISuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationPoiStart object:nil];
    [_searchPOIClient cancelRequest];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.companyField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (safeString(self.signInPoint.alias).length == 0) {
        self.companyField.text = @"";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.signInPoint.alias = textField.text;
}

#pragma mark - getSignInPointMessage -
- (void)getSigninPointMessage {
    [KDPopup showHUD];

    //签到迁移，暂时屏蔽
//    KDGetSignInPointMessageRequest *request = [[KDGetSignInPointMessageRequest alloc] initWithAttendSetId: self.signInPointId];
//    [request startCompletionBlockWithSuccess:^(__kindof KDRequest * _Nonnull request) {
//        if ([request.response.responseObject isKindOfClass:[NSDictionary class]]) {
//            [KDPopup hideHUD];
//            self.signInPoint = [[KDSignInPoint alloc] initWithDictionary:request.response.responseObject];
//            self.dailySignInCountCell.dailySignInCount = self.signInPoint.clockInSectionTimes;
//            [self.tableView reloadData];
//        }
//        else {
//            [KDPopup showHUDToast:ASLocalizedString(@"获取签到点信息失败")];
//        }
//    } failure:^(__kindof KDRequest * _Nonnull request) {
//        [KDPopup showHUDToast:ASLocalizedString(@"获取签到点信息失败")];
//    }];
    
    __weak KDAddOrUpdateSignInPointController *weakSelf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if (results) {
            [KDPopup hideHUD];
            self.signInPoint = [[KDSignInPoint alloc] initWithDictionary:results[@"data"]];
            self.dailySignInCountCell.dailySignInCount = self.signInPoint.clockInSectionTimes;
            [self.tableView reloadData];
        } else {
            [KDPopup showHUDToast:ASLocalizedString(@"获取签到点信息失败")];
        }
    };
    
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"attendSetId" stringValue:self.signInPointId];
    
    [KDServiceActionInvoker invokeWithSender:weakSelf
                                  actionPath:@"/signId/:findAttendSet4Edit"
                                       query:query
                                 configBlock:nil
                             completionBlock:completionBlock];
    
}

@end
