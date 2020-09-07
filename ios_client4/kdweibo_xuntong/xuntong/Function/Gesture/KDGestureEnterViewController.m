//
//  KDGestureEnterViewController.m
//  DynamicCode
//
//  Created by 曾昭英 on 13-11-29.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "Global.h"
#import "KDGestureEnterViewController.h"
#import "BOSConfig.h"
#import "UIImageView+WebCache.h"
#define kSetting_failCount @"failCount"

@interface KDGestureEnterViewController ()
{
    int _enterFailCount;
}
@property(nonatomic,strong)UILabel * tipsLabel;
@end

@implementation KDGestureEnterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOSDEBUG(@"pw:%@",[[KDLockControl shared] lockPassword]);
    
    CGFloat zoom = 0.5f;
    if (isAboveiPhone5) {
        zoom =  1.0f;
    }
    
    UIImageView * backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"key_img_bg"]];
    [backgroundView setFrame:self.view.bounds];
    [self.view addSubview:backgroundView];
    

    
    NSNumber *setCount = [[NSUserDefaults standardUserDefaults] objectForKey:kSetting_failCount];
    if (setCount == nil) {
        setCount = @0;
    }
    _enterFailCount = [setCount intValue];
    if (_enterFailCount >= 5) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDGestureEnterViewController_Tip")message:ASLocalizedString(@"KDGestureEnterViewController_Five_ReLogin")delegate:self cancelButtonTitle:nil otherButtonTitles:ASLocalizedString(@"KDGestureEnterViewController_ReLogin"), nil];
        [av show];
    }

//    UIImageView *roundBG = nil;
//    if (isAboveiPhone5) {
//        roundBG = [[UIImageView alloc] initWithFrame:CGRectMake(125, 67.5 , 70, 70)];
//    }
//    else{
//        roundBG = [[UIImageView alloc] initWithFrame:CGRectMake(125, 37.5 , 70, 70)];
//        
//    }
//    roundBG.image = [UIImage imageNamed:@"key_img_touxiang"];
//    [self.view addSubview:roundBG];

    
    //头像
    if (isAboveiPhone5) {
        _portraitIV = [[UIImageView alloc] initWithFrame:CGRectMake(0.5*(CGRectGetWidth(self.view.frame)- 80), 70 , 80, 80)];
    }
    else{
        _portraitIV = [[UIImageView alloc] initWithFrame:CGRectMake(0.5*(CGRectGetWidth(self.view.frame)- 80), 40 , 80, 80)];
        
        
    }
    
    [_portraitIV setImageWithURL:[NSURL URLWithString:[KDManagerContext globalManagerContext].userManager.currentUser.profileImageUrl]];
    [self.view addSubview:_portraitIV];
    _portraitIV.clipsToBounds = YES;
    _portraitIV.layer.cornerRadius = 5;
    
    
    
    //名字
    _nameL = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_portraitIV.frame) + 19 * zoom, ScreenFullWidth, 20)];
    _nameL.textColor = FC5;
    _nameL.font = FS3;
    _nameL.textAlignment = NSTextAlignmentCenter;
    _nameL.text = [BOSConfig sharedConfig].user.name;
    _nameL.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_nameL];
    
    _tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_nameL.frame) + 18 * zoom, ScreenFullWidth, 18)];
    [_tipsLabel setFont:FS5];
    [_tipsLabel setTextColor:FC4];
    _tipsLabel.textAlignment = NSTextAlignmentCenter;
    _tipsLabel.backgroundColor = [UIColor clearColor];

    [self.view addSubview:_tipsLabel];
    
    _lockViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.5*(CGRectGetWidth(self.view.frame)- 320), CGRectGetMaxY(_nameL.frame) + 40 * zoom, ScreenFullWidth, 280)];
    [self.view addSubview:_lockViewContainer];
    _lockView = [[PPLockView alloc]initWithFrame:_lockViewContainer.bounds];
    _lockView.delegate = self;
    [_lockViewContainer addSubview:_lockView];
    
    //忘记手势
    _forgetPwL = [UIButton buttonWithType:UIButtonTypeCustom];
    [_forgetPwL setTitle:ASLocalizedString(@"KDGestureEnterViewController_ForgetCode")forState:UIControlStateNormal];
    [_forgetPwL setTitleColor:FC2 forState:UIControlStateNormal];
    _forgetPwL.titleLabel.font = FS3;
    [_forgetPwL sizeToFit];
    [_forgetPwL setFrame:CGRectMake(0.5*(CGRectGetWidth(self.view.frame)- _forgetPwL.bounds.size.width), CGRectGetMaxY(_lockViewContainer.frame) + 25 * zoom, _forgetPwL.bounds.size.width, _forgetPwL.bounds.size.height)];
    [_forgetPwL addTarget:self action:@selector(forgetPwAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_forgetPwL];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)forgetPwAction:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDGestureEnterViewController_Tip")message:ASLocalizedString(@"KDGestureEnterViewController_ForgetCode_Relogin")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDGestureEnterViewController_ReLogin"), nil];
    [av show];
}

#pragma mark - PPLockViewDelegate

- (void)lockViewUnlockWithPasswd:(NSString *)pass
{
    
    if ([pass isEqualToString:[[KDLockControl shared] lockPassword]]) {
        [_lockView success];
        [self dismissViewControllerAnimated:YES completion:NULL];
        
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:kSetting_failCount];
    } else {
        [_lockView fail];
        
        _enterFailCount ++;
        
        [[NSUserDefaults standardUserDefaults] setObject:@(_enterFailCount) forKey:kSetting_failCount];
        
        if (_enterFailCount >= 5) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDGestureEnterViewController_Tip")message:ASLocalizedString(@"KDGestureEnterViewController_Tip_1")delegate:self cancelButtonTitle:nil otherButtonTitles:ASLocalizedString(@"KDGestureEnterViewController_ReLogin"), nil];
            [av show];
        } else {
 //           _nameL.textColor = [UIColor colorWithRed:255./255. green:204./255. blue:0 alpha:1.00f];
            _tipsLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDGestureEnterViewController_Tip_2"),5-_enterFailCount];
           // _tipsLabel.text = ASLocalizedString(@"KDGestureEnterViewController_Tip_3");
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self _signOut];
    }
}

- (void)_signOut
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        //清除签到提示的标识
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:kSetting_failCount];
        
        [[KDWeiboAppDelegate getAppDelegate] signOut];
        
    }];

    
  //  [[KDWeiboAppDelegate getAppDelegate] showAuthViewController];
}

@end
