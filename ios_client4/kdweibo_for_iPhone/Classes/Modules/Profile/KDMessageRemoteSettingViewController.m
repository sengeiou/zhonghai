//
//  KDMessageRemoteSettingViewController.m
//  kdweibo
//
//  Created by liwenbo on 15/12/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDMessageRemoteSettingViewController.h"

#import "KDMessageRemoteSettingTableViewCell.h"
#import "KDMessageRemoteSettingDatePickerView.h"
#import "XTSetting.h"
#import "ContactClient.h"
//#import "KDSearchHelper.h"

#import <AudioToolbox/AudioToolbox.h>

#define defaultBeginTime @"22:00"
#define defaultEndTime @"08:00"

typedef enum : NSUInteger {
    kMessageRemoteSettingTimeTypeBegin = 1,
    kMessageRemoteSettingTimeTypeEnd,
} kMessageRemoteSettingTimeType;


@interface KDMessageRemoteSettingViewController ()<UITableViewDataSource,UITableViewDelegate,KDMessageRemoteSettingTableViewCellDelegate, MBProgressHUDDelegate, UIAlertViewDelegate>
{
    MBProgressHUD *_hud;

}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) KDMessageRemoteSettingDatePickerView *datePickerView;

@property (nonatomic, assign) CGRect datePickerViewHideFrame;
@property (nonatomic, assign) CGRect datePickerViewShowFrame;

@property (nonatomic, strong) NSDate *beginTime;
@property (nonatomic, strong) NSDate *endTime;

@property (nonatomic, assign) kMessageRemoteSettingTimeType currentSettingTimeType;

@property (nonatomic, strong) ContactClient *getClient;
@property (nonatomic, strong) ContactClient *updateClient;

@property (nonatomic, assign) BOOL isRegisteredRemote;  //是否注册推送
@property (nonatomic, strong) UISwitch *disturbSwitch;

@property (nonatomic, strong) UISwitch *soundSwitch; // 声音
@property (nonatomic, strong) UISwitch *vibrateSwitch; // 振动

@end

@implementation KDMessageRemoteSettingViewController

- (NSDate *)beginTime
{
    if (!_beginTime)
    {
        _beginTime = [self getDateFromTimeString:@"22:00"];
    }
    return _beginTime;
}


- (NSDate *)endTime
{
    if (!_endTime)
    {
        _endTime = [self getDateFromTimeString:@"08:00"];
    }
    return _endTime;
}

- (UISwitch *)soundSwitch
{
    if (!_soundSwitch) {
        _soundSwitch = [UISwitch new];
        _soundSwitch.onTintColor = FC5;
        [_soundSwitch setOn:[BOSSetting sharedSetting].isSound animated:YES];
        [_soundSwitch addTarget:self action:@selector(soundSetting:) forControlEvents:UIControlEventValueChanged];
    }
    return _soundSwitch;
}

- (UISwitch *)vibrateSwitch
{
    if (!_vibrateSwitch) {
        _vibrateSwitch = [UISwitch new];
        _vibrateSwitch.onTintColor = FC5;
        [_vibrateSwitch setOn:[BOSSetting sharedSetting].isVibrate animated:YES];
        [_vibrateSwitch addTarget:self action:@selector(vibrateSetting:) forControlEvents:UIControlEventValueChanged];
    }
    return _vibrateSwitch;
}

- (void)soundSetting:(id)sender {
    UISwitch *soundSwitch = sender;
    if (soundSwitch.on == YES) {
        DLog(@"开启声音=======");
      //  AudioServicesPlaySystemSound(1007);
        
        static NSString *soundPath = nil;
        static NSURL *soundURL = nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            soundPath = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"mp3"];
            soundURL = [NSURL fileURLWithPath:soundPath];
        });
        
        SystemSoundID soundID;
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundID);
        
        AudioServicesPlaySystemSound(soundID);
        
    } else {
        DLog(@"关闭声音=======");
    }
    
    [BOSSetting sharedSetting].isSound = soundSwitch.on;
    [[BOSSetting sharedSetting] saveSetting];
}
- (void)vibrateSetting:(id)sender {
    UISwitch *vibrateSwitch = sender;
    if (vibrateSwitch.on == YES) {
        DLog(@"开启振动=======");
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    } else {
        DLog(@"关闭振动=======");
    }
    
    [BOSSetting sharedSetting].isVibrate = vibrateSwitch.on;
    [[BOSSetting sharedSetting] saveSetting];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = ASLocalizedString(@"KDSettingViewController_New_Notifications");
    self.view.backgroundColor = [UIColor kdBackgroundColor1];

    [self setupViews];
    [self getDoNotDisturb];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidReceived:) name:UIApplicationWillEnterForegroundNotification object:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    
}


- (BOOL)isRegisteredRemote
{
    //iOS8 check if user allow notification
    if (isAboveiOS8) {// system is iOS8
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone != setting.types) {
                return YES;
        }
    } else
    {//iOS7
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if(UIRemoteNotificationTypeNone != type){
                return YES;
        }
    }
    
    return NO;
}

- (void)notificationDidReceived:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification])
    {
        [self.tableView reloadData];
    }
}




- (void)getDoNotDisturb
{
    //可以接收推送信息
    if (self.isRegisteredRemote)
    {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
        
        _hud.delegate = self;
        [_hud show:YES];
        
        
        if (!_getClient)
        {
            _getClient = [[ContactClient alloc] initWithTarget:self action:@selector(getDoNotDisturbDidReceived:result:)];
        }
        [self.getClient getDoNorDisturb];
    }
    else
    {
        [XTSetting sharedSetting].isDoNotDisturbMode = self.isRegisteredRemote;
        [self.tableView reloadData];
    }
}

- (void)getDoNotDisturbDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    [_hud hide:YES];
    if (result.success && !client.hasError)
    {
        NSDictionary *dict = result.data;
        BOOL enable = [[dict objectForKey:@"enable"] boolValue];
        
        NSString *beginTime = [dict objectForKey:@"from"];
        NSString *endTime = [dict objectForKey:@"to"];
        
        if (beginTime && [beginTime isKindOfClass:[NSString class]])
        {
            self.beginTime = [self getDateFromTimeString:beginTime];
        }
        if (endTime && endTime)
        {
            self.endTime = [self getDateFromTimeString:endTime];
        }
        
        [XTSetting sharedSetting].isDoNotDisturbMode = enable;
        
        [self.tableView reloadData];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:client.errorMessage delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel") otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)updateDisturbTimeWithEnable:(BOOL)enable
{
    [_hud show:YES];
    
    if (!_updateClient)
    {
        _updateClient = [[ContactClient alloc] initWithTarget:self action:@selector(updateDisturbTimeWithEnableDidReceived:result:)];
    }
    [self.updateClient updateDoNotDisturbWithEnable:enable from:[self getTimeStringFromDate:self.beginTime] to:[self getTimeStringFromDate:self.endTime]];
}

- (void)updateDisturbTimeWithEnableDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    [_hud hide:YES];
    
    if (result.success && !client.hasError)
    {
        NSDictionary *dict = result.data;
        BOOL enable = [[dict objectForKey:@"enable"] boolValue];
        
        NSString *beginTime = [dict objectForKey:@"from"];
        NSString *endTime = [dict objectForKey:@"to"];
        
        if (beginTime && [beginTime isKindOfClass:[NSString class]])
        {
            self.beginTime = [self getDateFromTimeString:beginTime];
        }
        if (endTime && endTime)
        {
            self.endTime = [self getDateFromTimeString:endTime];
        }

        [XTSetting sharedSetting].isDoNotDisturbMode = enable;
        
        [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
//        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.currentSettingTimeType == kMessageRemoteSettingTimeTypeBegin ? 1 : 2 inSection:1];
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error.debugDescription delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel") otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)setupViews
{
    self.datePickerViewHideFrame = CGRectMake(0, CGRectGetMaxY(self.view.frame), ScreenFullWidth, 256);
    self.datePickerViewShowFrame = CGRectMake(0, CGRectGetMaxY(self.view.frame) - 256,ScreenFullWidth, 256);
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor kdTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsZero); 
    }];
    
    self.datePickerView  = [[KDMessageRemoteSettingDatePickerView alloc] initWithFrame:self.datePickerViewHideFrame];
    [self.view addSubview:self.datePickerView];
    [self.datePickerView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left); 
        make.right.equalTo(self.view.right);
        make.height.mas_equalTo(256);
        make.top.equalTo(self.view.bottom);
    }];
    
    __weak __typeof(self) weakSelf = self;
    
    //datePicker点击回调
    [self.datePickerView setCompleteSetup:^(NSDate *aDate){
        
        [UIView animateWithDuration:.25f animations:^{
            
            weakSelf.datePickerView.frame = weakSelf.datePickerViewHideFrame;
            [weakSelf.datePickerView updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(weakSelf.view.left); 
                make.right.equalTo(weakSelf.view.right);
                make.height.mas_equalTo(256);
                make.top.equalTo(weakSelf.view.bottom);
            }];
        }];
        if (aDate)
        {
            switch (weakSelf.currentSettingTimeType)
            {
                case kMessageRemoteSettingTimeTypeBegin:
                {
                    weakSelf.beginTime = aDate;
                }
                    break;
                case kMessageRemoteSettingTimeTypeEnd:
                {
                    weakSelf.endTime = aDate;
                }
                default:
                    break;
            }
            [weakSelf updateDisturbTimeWithEnable:YES];
        }
    }];
    
    [self.datePickerView setCancelSetup:^(NSDate *aDate){
        [UIView animateWithDuration:.25f animations:^{
            
            weakSelf.datePickerView.frame = weakSelf.datePickerViewHideFrame;
            [weakSelf.datePickerView updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(weakSelf.view.left); 
                make.right.equalTo(weakSelf.view.right);
                make.height.mas_equalTo(256);
                make.top.equalTo(weakSelf.view.bottom);
            }];
        }];
    }];
}

#pragma mark - TableView Delegate && DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    return 3;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
//    else if (section == 1)
//    {
//        return 2;
//    }
    else if (section == 1)
    {
        if (self.isRegisteredRemote)
        {
            return [XTSetting sharedSetting].isDoNotDisturbMode ? 3 : 1;
        }
        else return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier1= @"KDMessageRemoteSettingViewControllerCellIdentifier1";
    static NSString *cellIdentifier2= @"KDMessageRemoteSettingViewControllerCellIdentifier2";
    static NSString *cellIdentifier3= @"KDMessageRemoteSettingViewControllerCellIdentifier3";
    static NSString *cellIdentifier4= @"KDMessageRemoteSettingViewControllerCellIdentifier4";
    if (indexPath.section == 0)
    {
        KDMessageRemoteSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (!cell)
        {
            cell = [[KDMessageRemoteSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier1 Type:kMessageRemoteSettingCellTypeNone];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = ASLocalizedString(@"KDMessageRemoteSettingViewController_message_noti_2");
        cell.detailTextLabel.text = self.isRegisteredRemote ? ASLocalizedString(@"KDMessageRemoteSettingViewController_on"):ASLocalizedString(@"KDMessageRemoteSettingViewController_off");
        cell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
        cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
        return cell;
        
    }
//    else if (indexPath.section == 1)
//    {
//        switch (indexPath.row)
//        {
//            case 0:
//            {
//                KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"soundCell"];
//                if (!cell) {
//                    cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"soundCell"];
//                }
//                cell.textLabel.text = ASLocalizedString(@"KDMessageRemoteSettingViewController_sound");
//                cell.accessoryView = self.soundSwitch;
//                cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                
//                return cell;
//                
//            }
//                break;
//            case 1:
//            {
//                KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"vibrateCell"];
//                if (!cell) {
//                    cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"vibrateCell"];
//                }
//                cell.textLabel.text = ASLocalizedString(@"KDMessageRemoteSettingViewController_vibrate");
//                cell.accessoryView = self.vibrateSwitch;
//                cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                
//                return cell;
//                
//            }
//                break;
//            default:
//                return nil;
//                break;
//        }
//    }
    else if(indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                KDMessageRemoteSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
                if (!cell)
                {
                    cell = [[KDMessageRemoteSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier2 Type:kMessageRemoteSettingCellTypeSwitch];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.canClickSwitch = self.isRegisteredRemote;
                if (!self.isRegisteredRemote) {
                    cell.modelSwitch.on = NO;
                }else{
                    cell.modelSwitch.on = [XTSetting sharedSetting].isDoNotDisturbMode;
                }
                self.disturbSwitch = cell.modelSwitch; //
                cell.separatorLineStyle = [XTSetting sharedSetting].isDoNotDisturbMode ? KDTableViewCellSeparatorLineSpace : KDTableViewCellSeparatorLineTop;
                cell.accessoryStyle = KDTableViewCellAccessoryStyleNone;
                cell.textLabel.text = ASLocalizedString(@"KDMessageRemoteSettingViewController_no_disturb_mode");
                cell.delegate = self;
                return cell;
                
            }
                break;
            case 1:
            {
                KDMessageRemoteSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
                if (!cell)
                {
                    cell = [[KDMessageRemoteSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier3 Type:kMessageRemoteSettingCellTypeBeginTime];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = ASLocalizedString(@"KDMessageRemoteSettingViewController_start_time");
                [cell.timeButton setTitle: [self getTimeStringFromDate:self.beginTime] forState:UIControlStateNormal];
                cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
                cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
                cell.delegate = self;
                return cell;
                
            }
                break;
            case 2:
            {
                
                KDMessageRemoteSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier4];
                if (!cell)
                {
                    cell = [[KDMessageRemoteSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier4 Type:kMessageRemoteSettingCellTypeEndTime];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = ASLocalizedString(@"KDMessageRemoteSettingViewController_end_time");
                [cell.timeButton setTitle: [self getTimeStringFromDate:self.endTime] forState:UIControlStateNormal];
                cell.separatorLineStyle = KDTableViewCellSeparatorLineTop;
                cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
                cell.delegate = self;
                return cell;
                
            }
                break;
            default:
                return nil;
                break;
        }
    }
    else
    {
        return nil;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 50.0f;
    } else {
        return 0.01f;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    if (section == 1) {
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake([NSNumber kdDistance1], 0, ScreenFullWidth - 2*[NSNumber kdDistance1], 50.0f);
        label.text = [NSString stringWithFormat:ASLocalizedString(@"KDMessageRemoteSettingViewController_tip2"),KD_APPNAME];
        label.font = FS6;
        label.textColor = FC2;
        label.numberOfLines = 0;
        
        [view addSubview:label];
    }
    
    return view;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (isAboveiOS8) {
                NSURL*url=[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:ASLocalizedString(@"KDMessageRemoteSettingViewController_tip1"),KD_APPNAME] delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure") otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - KDMessageRemoteSettingTableViewCellDelegate
- (void)setupDisturbModel:(BOOL)isDoNotDisturbModel
{
    if (self.isRegisteredRemote) {
        [self updateDisturbTimeWithEnable:isDoNotDisturbModel];
    }else{
        self.disturbSwitch.on = NO; //
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDMessageRemoteSettingTableViewCell_allow_noti") delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Cancel") otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)disturbTimeButtonClick:(kMessageRemoteSettingCellType)type
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"HH:mm"];
    NSDate *beginDate = self.beginTime;
    NSDate *endDate = self.endTime;
    
    if (type == kMessageRemoteSettingCellTypeBeginTime)
    {
        self.currentSettingTimeType = kMessageRemoteSettingTimeTypeBegin;
        [self.datePickerView.datePicker setDate:beginDate];
        self.datePickerView.frame = self.datePickerViewShowFrame;
        [self.datePickerView updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.left); 
            make.right.equalTo(self.view.right);
            make.height.mas_equalTo(256);
            make.top.equalTo(self.view.bottom).with.offset(-256);
        }];
    }
    if (type == kMessageRemoteSettingCellTypeEndTime)
    {
        self.currentSettingTimeType = kMessageRemoteSettingTimeTypeEnd;
        [self.datePickerView.datePicker setDate:endDate];
        self.datePickerView.frame = self.datePickerViewShowFrame;
        [self.datePickerView updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.left); 
            make.right.equalTo(self.view.right);
            make.height.mas_equalTo(256);
            make.top.equalTo(self.view.bottom).with.offset(-256);
        }];
    }
}


- (NSDate *)getDateFromTimeString:(NSString *)timeString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"HH:mm"];
    NSDate *date = [formatter dateFromString:timeString];
    
    return date;
}

- (NSString *)getTimeStringFromDate:(NSDate *)date
{
    if (date)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateFormat:@"HH:mm"];
        NSString *timeString = [formatter stringFromDate:date];
        return timeString;
    }
    else
    {
        return @"";
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        [self.tableView reloadData];
    }
}




/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
