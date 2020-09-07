//
//  KDNewSigninRemindController.m
//  kdweibo
//
//  Created by lichao_liu on 9/8/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDNewSigninRemindController.h"
#import "KDWorkDayPickerViewController.h"

#import "KDSignInRemindManager.h"

#import "NSDate+Additions.h"

@interface KDNewSigninRemindController ()

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UILabel *repeatTypeLabel;
@property (strong, nonatomic) IBOutlet UIButton *deletebtn;
@property (strong, nonatomic) IBOutlet UIView *repeatView;
@property (nonatomic, assign) NSInteger repeatType;
@end

@implementation KDNewSigninRemindController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [KDEventAnalysis event:event_signInRemind];
    if(self.signInRemind)
    {
        self.title = ASLocalizedString(@"编辑提醒");
    }else{
        self.title = ASLocalizedString(@"新建提醒");
    }
    
    UIButton *rightBtn = [UIButton blueBtnWithTitle:ASLocalizedString(@"保存")];
    [rightBtn addTarget:self action:@selector(whenSaveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    self.repeatTypeLabel.textColor = FC2;
    self.repeatView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectRepeatTypeAction:)];
    [self.repeatView addGestureRecognizer:tap];
    
    if (self.signInRemind) {
        [self.deletebtn setTitleColor:FC4 forState:UIControlStateNormal];
        [self.deletebtn setTitleColor:FC4 forState:UIControlStateHighlighted];
        [self.deletebtn setBackgroundImage:[UIImage kd_imageWithColor:FC6] forState:UIControlStateNormal];
        [self.deletebtn setBackgroundImage:[UIImage kd_imageWithColor:FC6] forState:UIControlStateHighlighted];
        self.repeatType = self.signInRemind.repeatType;
        self.datePicker.date = [self getDateWithHHmmStr:self.signInRemind.remindTime];
        self.repeatTypeLabel.text = [self repeatRepresention];
    }
    else {
        self.repeatType = KDSignInRemindRepeatWorkDay;
        self.datePicker.date = [NSDate date];
        self.deletebtn.hidden = YES;
        self.repeatTypeLabel.text = [self repeatRepresention];
    }
}


- (void)whenSaveBtnClicked:(id)sender
{
    if (!self.signInRemind) {
        self.signInRemind = [[KDSignInRemind alloc] init];
    }
    self.signInRemind.isRemind = YES;
    self.signInRemind.remindTime = [self getHHmmWithDate:self.datePicker.date];
    self.signInRemind.repeatType = self.repeatType;
    
    [KDPopup showHUDInView:self.view];
    if (self.signInRemind.remindId) {
        [KDSignInRemindManager setSignInRemind:self.signInRemind operateType:1 block:^(BOOL success, NSString *remindId) {
            [KDPopup hideHUDInView:self.view];
            if (success) {
                BOOL result = [[XTDataBaseDao sharedDatabaseDaoInstance] updateSignInRemindWithRemindId:self.signInRemind.remindId isRemind:self.signInRemind.isRemind remindTime:self.signInRemind.remindTime repeatType:self.signInRemind.repeatType];
                if(result) {
                    [KDSignInRemindManager updateSignInRemindWithRemind:self.signInRemind];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [KDPopup showHUDToast:ASLocalizedString(@"保存失败")];
            }
        }];
    }
    else {
        [KDSignInRemindManager setSignInRemind:self.signInRemind operateType:0 block:^(BOOL success, NSString *remindId) {
            [KDPopup hideHUDInView:self.view];
            if (success && safeString(remindId).length > 0) {
                self.signInRemind.remindId = remindId;
                BOOL result = [[XTDataBaseDao sharedDatabaseDaoInstance] addSignInRemindWithRemindId:self.signInRemind.remindId isRemind:self.signInRemind.isRemind remindTime:self.signInRemind.remindTime repeatType:self.signInRemind.repeatType];
                if (result) {
                    [KDSignInRemindManager addSignInRemindNotificationWithRemind:self.signInRemind];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [KDPopup showHUDToast:ASLocalizedString(@"保存失败")];
            }
        }];
    }
    
}

- (IBAction)whenDeleteBtnClicked:(id)sender
{
    [KDPopup showHUD];
    [KDSignInRemindManager setSignInRemind:self.signInRemind operateType:2 block:^(BOOL success, NSString *remindId) {
        
        if (success) {
            [KDPopup hideHUD];
            BOOL result = [[XTDataBaseDao sharedDatabaseDaoInstance] deleteSignInRemindWithRemindId:self.signInRemind.remindId];
            if (result) {
                [KDSignInRemindManager cancelSignInRemindWithRemind:self.signInRemind];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [KDPopup showHUDToast:ASLocalizedString(@"删除失败")];
        }
    }];
}

- (void)selectRepeatTypeAction:(id)sender
{
    __weak KDNewSigninRemindController *weakSelf = self;
    KDWorkDayPickerViewController *workDayPickerViewController = [[KDWorkDayPickerViewController alloc] init];
    workDayPickerViewController.workDayPickerBlock = ^(NSInteger repeatType){
        weakSelf.repeatType = repeatType;
        weakSelf.repeatTypeLabel.text = [weakSelf repeatRepresention];
    };
    workDayPickerViewController.repeatType = self.repeatType;
    [self.navigationController pushViewController:workDayPickerViewController animated:YES];
}

- (NSString *)repeatRepresention {
    NSString *result = nil;
    NSString *weeks[] = {ASLocalizedString(@"、周日"), ASLocalizedString(@"、周一"), ASLocalizedString(@"、周二"), ASLocalizedString(@"、周三"), ASLocalizedString(@"、周四"), ASLocalizedString(@"、周五"), ASLocalizedString(@"、周六")};
    KDSignInRemindRepeatType repeateType = [self repeatType];
    if (repeateType == KDSignInRemindRepeatNone) {
        result = ASLocalizedString(@"永不");
    } else if (repeateType == KDSignInRemindRepeatEveryDay) {
        result = ASLocalizedString(@"每天");
    } else if (repeateType == KDSignInRemindRepeatWorkDay) {
        result = ASLocalizedString(@"工作日");
    } else {
        NSMutableString *str = [NSMutableString string];
        NSInteger n = 0;
        for (NSInteger i = 1; i < 8; i++) {
            n = KDSignInRemindRepeatSun << (i % 7);
            if ((n & repeateType) == n) {
                [str appendString:weeks[i % 7]];
            }
        }
        result = [str stringByReplacingCharactersInRange:(NSRange) {0, 1} withString:@""];
        
        result = [NSString stringWithFormat:@"%@", result];
    }
    return result;
}


- (NSString *)getHHmmWithDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    return [formatter stringFromDate:date];
}

- (NSDate *)getDateWithHHmmStr:(NSString *)str
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    return [formatter dateFromString:str];
}
@end
