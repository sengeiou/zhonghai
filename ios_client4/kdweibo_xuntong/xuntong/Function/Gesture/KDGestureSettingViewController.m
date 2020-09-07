//
//  KDGestureViewController.m
//  DynamicCode
//
//  Created by 曾昭英 on 13-11-28.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "Global.h"
#import "UIButton+XT.h"
#import "KDGestureSettingViewController.h"
#import "BOSSetting.h"

@interface KDGestureSettingViewController ()<UIActionSheetDelegate>
{
    int _failCount;
}
@property(nonatomic, strong) NSString * tempPassword;


@end

@implementation KDGestureSettingViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}
- (void)showPromptMsg:(NSString *)msg
{
    _promptL.text = msg;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor kdBackgroundColor3];

//    UINavigationController *nav= self.navigationController;
    
    self.lockType = LockType_setting;
    [self setupNavigationItems];
    if (_isReset) {
        self.title = ASLocalizedString(@"KDGestureSettingViewController_Edit");
    }
    else{
        self.title = ASLocalizedString(@"KDGestureSettingViewController_SettingCode");
        
    }
    //手势预览
        _descV = [[GestureDescView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)- 40)/2.0, 32+ kd_StatusBarAndNaviHeight, 40, 40)];
    [self.view addSubview:_descV];
    
    _promptL = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_descV.frame) + 19, ScreenFullWidth, 21)];
    _promptL.backgroundColor = [UIColor clearColor];
    _promptL.textColor = FC4;
    _promptL.font = FS3;
    _promptL.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_promptL];
    [self showPromptMsg:ASLocalizedString(@"KDGestureSettingViewController_Draw")];
    
    if (isAboveiPhone5) {
        _lockViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_promptL.frame) + 40, ScreenFullWidth, 320)];
    }
    else{
        _lockViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_promptL.frame) + 20, ScreenFullWidth, 320)];
    }
    [self.view addSubview:_lockViewContainer];
    
    //9个按钮
     _lockView = [[PPLockView alloc] initWithFrame:CGRectMake((_lockViewContainer.bounds.size.width- 320)*0.5, 0, 320, _lockViewContainer.bounds.size.height)];
    _lockView.delegate = self;
  
	[_lockViewContainer addSubview:_lockView];
    
    
    
}


- (void)setupNavigationItems
{

//    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Close")style:UIBarButtonItemStylePlain target:self action:@selector(cancelSetting:)];
//    self.navigationItem.leftBarButtonItems = @[leftBarButtonItem];
//    UIButton *btn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"设置")];
//    [btn addTarget:self action:@selector(cancelSetting:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItems= @[[[UIBarButtonItem alloc] initWithCustomView:btn]];
    
    //如果为强制使用手势密码，则 隐藏取消密码按钮
    if ([KDLockControl shared].isSetDone && ![[BOSSetting sharedSetting] openGesturePassword]) {
        UIBarButtonItem  *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDGestureSettingViewController_CancelCode")style:UIBarButtonItemStylePlain target:self action:@selector(cancelPatternLock:)];
        self.navigationItem.rightBarButtonItems = @[rightBarButtonItem];
    }
    

}

//-(void)cancelSetting:(id)sender{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
-(void)cancelPatternLock:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ASLocalizedString(@"KDGestureSettingViewController_Tip_1")delegate:self cancelButtonTitle:ASLocalizedString(@"KDGestureSettingViewController_Tip_2")destructiveButtonTitle:ASLocalizedString(@"KDGestureSettingViewController_Tip_3")otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}


#pragma mark - ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [KDEventAnalysis event:event_settings_gesturepassword attributes:@{label_settings_gesturepassword_status: label_settings_gesturepassword_status_off}];
        [KDLockControl shared].isSetDone = NO;
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"failCount"];
       [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - PPLockViewDelegate

- (void)lockViewUnlockWithPasswd:(NSString *)pass
{
    if (pass.length < 4) {
        [self showPromptMsg:ASLocalizedString(@"KDGestureSettingViewController_Tip_4")];
        
        [_lockView fail];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_descV setPw:nil];\
        });
        return;
    }

    if (self.lockType == LockType_setting) {
        _tempPassword = [NSString stringWithString:pass];
        self.lockType = LockType_confirm;
        [_lockView success];
        [self showPromptMsg:ASLocalizedString(@"KDGestureSettingViewController_Tip_5")];
    } else if (self.lockType == LockType_confirm) {
        if ([pass isEqualToString:_tempPassword]) {

            if (self.isReset) {
                [self showPromptMsg:ASLocalizedString(@"KDGestureSettingViewController_Tip_6")];
            } else {
                [self showPromptMsg:ASLocalizedString(@"KDGestureSettingViewController_Tip_7")];
                [KDEventAnalysis event:event_settings_gesturepassword attributes:@{label_settings_gesturepassword_status: label_settings_gesturepassword_status_on}];
            }

            [[KDLockControl shared] setLockPassword:[NSString stringWithString:pass]];
            [[KDLockControl shared] setIsSetDone:YES];
            
            int64_t delayInSeconds = 1.;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                    if (self.isReset)
                        [self.navigationController popViewControllerAnimated:YES];
                    else
                    {
                        [Global shared].appState = AppStateMain;
                        
                        if(self.navigationController.viewControllers.count>1)
                            [self.navigationController popViewControllerAnimated:YES];
                        else
                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                            
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHandText" object:nil userInfo:nil];
                    }
            });
        } else {
            [self showPromptMsg:ASLocalizedString(@"KDGestureSettingViewController_Reset")];
            self.lockType = LockType_setting;
            [_lockView fail];
            
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [_descV setPw:nil];
            });
        }
    }
}

- (void)lockViewDidCheck:(NSString *)pass isFinished:(BOOL)flag
{
    if (!flag && self.lockType == LockType_setting) {
        [_descV setPw:pass];
    }
}

@end
