//
//  KDSignInViewController.m
//  kdweibo
//
//  Created by 王 松 on 13-8-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//



#import "KDSignInViewController.h"
#import "KDLocationOptionViewController.h"
#import "KDSignInSettingViewController.h"
#import "KDAddOrUpdateSignInPointController.h"
#import "KDNewPhotoSignInController.h"
#import "KDOutDoorSignInViewController.h"
#import "KDSignInViewController+Activity.h"
#import "KDSignInViewController+Medal.h"
#import "KDSignInViewController+Photo.h"
#import "KDSignInViewController+Share.h"
#import "KDSignInViewController+Feedback.h"
#import "KDSignInViewController+OverTime.h"

#import "KDRefreshTableView.h"
#import "KDSignInCell.h"
#import "KDSignInPOIInputView.h"
#import "KDCommonHintView.h"

#import "KDDatabaseHelper.h"
#import "KDSigninRecordDAO.h"
#import "KDLocationManager.h"
#import "KDWeiboDAOManager.h"
#import "KDSigninMedalModel.h"
#import "KDSignInManager.h"
#import "KDSignInClient.h"
#import "KDSignInSchema.h"
//#import "KDURLPathManager.h"
#import "KDAppOpen.h"
#import "KDFailureSignInTask.h"
#import "KDLocationDefineManager.h"
#import "KDConfigurationContext.h"
#import "KDSignInUtil.h"
#import "KDSignInLogManager.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "NSString+Scheme.h"
#import "NSData+Base64.h"
#import "UIButton+KDV7.h"

#define KDCheatingProcessingOperationTime 5 * 60
#define KRecordFailuredContent ASLocalizedString(@"签不了，拍照试试")

static const NSTimeInterval KDviewDidLoadLocationTimeout = 5;
typedef enum kSignLocationType {
    kSignLocationType_None = 0,
    kSignLocationType_Signin,
    kSignLocationType_ReSignin
} kSignLocationType;

@interface KDSignInViewController () <KDRefreshTableViewDataSource, KDRefreshTableViewDelegate,
                                      KDSignInCellDelegate, UIGestureRecognizerDelegate,
                                      KDLocationOptionViewControllerDelegate, UIAlertViewDelegate,
                                      KDPhotoSignInPhotoCollectionViewDelegate>

@property(nonatomic, strong) KDRefreshTableView *tableview;
@property(nonatomic, strong) UILabel *weekLabel;
@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) UILabel *signTypeLabel;
@property(nonatomic, assign) NSInteger timerScheduleCount;
@property(nonatomic, strong) KDSignInCell *currentRevealingCell;
@property(nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic, strong) UIView *emptyView;
@property(nonatomic, strong) KDLocationData *currentLocationData;
@property(nonatomic, strong) NSArray *locationDataArray;
@property(nonatomic, assign) kSignLocationType locationType;
@property(nonatomic, strong) KDSignInRecord *faildRecord;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSDate *currentDate;
@property(nonatomic, strong) KDSignInClient *searchPOIClient;
@property(nonatomic, strong) CLLocation *clDefinelocation;
@property(nonatomic, assign) NSTimeInterval clDefineTimeInterval;
@property(nonatomic, assign) NSTimeInterval dolocationTimeInterVal;
@property(nonatomic, assign) NSTimeInterval doSignInTimeInterVal;
@property(nonatomic, strong) KDCommonHintView *guideHintView;
@property(nonatomic, assign) OutDoor_Type outDoorType;
@property(nonatomic, assign) NSInteger expandCount;//扩大搜索范围计数,签到失败2次的时候需要扩大搜索范围
@property(nonatomic, assign) BOOL isGuideHintViewShow;//签到升级弹窗是否正在显示
@property(nonatomic, strong) KDUnableToGetPositionAlert *unableToGetPositionAlert;

@end

@implementation KDSignInViewController {
    KDLocationDefineManager *_locationDefineManager;
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locationType = kSignLocationType_None;
    _currentDate = [NSDate date];
    _dataSource = [NSMutableArray array];
    _expandCount = 0;

    self.title = ASLocalizedString(@"签到");
    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"KDAUTOWifiSignInSuccessNotification"
                                               object:nil];
    
    //显示用户引导
    if ([KDSignInManager isSigninGuideShow]) {
        //[KDEventAnalysis event:event_signin_guide_show];
        [self.guideHintView show];
        [KDSignInManager setSigninGuideShow:NO];
        self.isGuideHintViewShow = YES;
    }
    
    [self setupViews];
    [self setNavigationRightItem];
    [self viewDidLoadData];
    
    if (self.isFromSignInRemindNotification && !self.isGuideHintViewShow) {
        [self doSignin:nil];
    }
}

- (void)whenApplicationWillEnterForeground{
    NSDate *date = [NSDate date];
    if (![KDSignInUtil isSameTimeWithOneDate:self.currentDate otherDate:date]) {
        if(![KDSignInUtil isSameDayWithOneDate:self.currentDate otherDate:date]){
            self.currentDate = date;
            [self viewDidLoadData];
            [self updateDateLabel];
        }
        else {
            self.currentDate = date;
        }
        [self updateTimeLabel];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.cancelActivity = YES;
}

- (BOOL)isAlreadyExistSignInViewControllerInNav
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if(viewControllers.count>1)
    {
        for (NSInteger index = 0; index < viewControllers.count -1; index++) {
            RTContainerController *controller = viewControllers[index];
            if(controller.contentViewController && [controller.contentViewController isKindOfClass:[KDSignInViewController class]])
            {
                return YES;
            }
        }
    }
    return NO;
}

- (void)viewDidLoadStartLocation {
    if ([KDReachabilityManager sharedManager].reachabilityStatus != KDReachabilityStatusNotReachable && ![KDSignInUtil locationServiceNotEnable]) {
        
        __weak KDSignInViewController *weakSelf = self;
        weakSelf.clDefineTimeInterval = [[NSDate date] timeIntervalSince1970];
        [KDLocationDefineManager shareManager].locationSuccessBlock = ^(CLLocation *data) {
            NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
            if (nowTimeInterval - weakSelf.clDefineTimeInterval <= KDviewDidLoadLocationTimeout) {
                weakSelf.unableToGetPositionAlert.failedCount = 0;
                weakSelf.clDefinelocation = data;
                [weakSelf getAttendanceSetInfo];
            }
        };
        [[KDLocationDefineManager shareManager] startLocation];
    }
    else {
        [self setSignTypeLabelText:2];
    }
}

- (BOOL)judgeToSignIn {
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    if (nowTimeInterval - self.clDefineTimeInterval <= KDviewDidLoadLocationTimeout) {
        self.currentLocationData = [KDLocationData locationDataByCoordiante:self.clDefinelocation.coordinate];
        [self doLocationSuccess:nil fileIds:nil cacheStr:nil];
        return YES;
    } else {
        self.clDefinelocation = nil;
        return NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.timer) {
        if ([self.timer isValid]) {
            [self.timer invalidate];
        }
        self.timer = nil;
    }
    
    self.canShowHintView = NO;
    
    [KDPopup hideHUDInView:self.view];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationFailed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationStart object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationOffsetCoor object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
//    if(self.isMovingFromParentViewController)
//    {
//        if(![self isAlreadyExistSignInViewControllerInNav])
//        {
//            [KDStyle setupStyple];
//        }
//    }

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.timer || ![self.timer isValid]) {
        NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
        
        self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerSchedule) userInfo:nil repeats:YES];
        [myRunLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenApplicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.cancelActivity = NO;
    self.canShowHintView = YES;
    
    self.timerScheduleCount = 0;
    [self viewDidLoadStartLocation];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

/**
 *  设置组件视图
 */
- (void)setupViews {
    UIImageView *timelineImageView = [[UIImageView alloc] init];
    timelineImageView.backgroundColor = [UIColor colorWithRGB:0xdce1e8];
    [self.view addSubview:timelineImageView];
    [timelineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).with.offset(64);
        make.left.mas_equalTo(self.view).with.offset(30);
        make.bottom.mas_equalTo(self.view);
        make.width.mas_equalTo(1);
    }];
    
    CGRect tableRect =CGRectMake(50, 64 + 10, ScreenFullWidth - 25 - 50, CGRectGetHeight(self.view.frame) - 64 - 64 - 10 - 100 - 15 - 44);
    _tableview = [[KDRefreshTableView alloc] initWithFrame:tableRect kdRefreshTableViewType:KDRefreshTableViewType_Header style:UITableViewStylePlain];
    _tableview.clipsToBounds = NO;
    _tableview.dataSource = self;
    _tableview.delegate = self;
    _tableview.showsHorizontalScrollIndicator = NO;
    _tableview.showsVerticalScrollIndicator = NO;
    _tableview.backgroundColor = [UIColor clearColor];
    _tableview.topView.backgroundColor = [UIColor clearColor];
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (isAboveiPhone6) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableRect.size.width, 14)];
        headerView.backgroundColor = [UIColor whiteColor];
        _tableview.tableHeaderView = headerView;
    }
    
    [self.view addSubview:_tableview];
    
    [self setupBottomView];
    [self setUpSignInHeaderView];
    
    UITapGestureRecognizer *bgClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgClick:)];
    bgClick.delegate = self;
    [self.view addGestureRecognizer:bgClick];
}

- (void)setUpSignInHeaderView
{
    UIView *signInHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    signInHeaderView.backgroundColor = FC5;
    [self.view addSubview:signInHeaderView];
    [signInHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(self.view);
        make.height.mas_equalTo(64);
    }];
    
    UILabel *groupNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    groupNameLabel.backgroundColor = [UIColor clearColor];
    groupNameLabel.textColor = FC6;
    groupNameLabel.font = FS4;
    groupNameLabel.textAlignment = NSTextAlignmentLeft;
    groupNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    groupNameLabel.text = ([[BOSConfig sharedConfig].user.companyName length] > 0 ? [BOSConfig sharedConfig].user.companyName : ([BOSSetting sharedSetting].customerName ? [BOSSetting sharedSetting].customerName : ASLocalizedString(@"未设置")));
    [signInHeaderView addSubview:groupNameLabel];
    
    self.weekLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.weekLabel.backgroundColor = [UIColor clearColor];
    self.weekLabel.textColor = FC6;
    self.weekLabel.font = FS6;
    self.weekLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.weekLabel.textAlignment = NSTextAlignmentLeft;
    [signInHeaderView addSubview:self.weekLabel];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.font = FS6;
    self.dateLabel.textColor = FC6;
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [signInHeaderView addSubview:self.dateLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sign_headview_image"]];
    [signInHeaderView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(signInHeaderView).with.offset(-[NSNumber kdDistance1]);
        make.bottom.mas_equalTo(signInHeaderView);
    }];
    
    [groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(signInHeaderView).with.offset([NSNumber kdDistance1]);
        make.left.mas_equalTo(signInHeaderView).with.offset([NSNumber kdDistance1]);
        make.right.mas_equalTo(signInHeaderView).with.offset(-2 * [NSNumber kdDistance1] - 62);
    }];
    
    [self.weekLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(groupNameLabel.bottom).with.offset(6);
        make.left.mas_equalTo(signInHeaderView).with.offset([NSNumber kdDistance1]);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
        make.top.mas_equalTo(self.weekLabel).with.offset(0);
        make.left.mas_equalTo(self.weekLabel.right).with.offset(6);
    }];
    
    [self updateDateLabel];
}


- (void)setNavigationRightItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"设置") style:UIBarButtonItemStylePlain target:self action:@selector(setting:)];
    [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:FC6,NSForegroundColorAttributeName,FS3,NSFontAttributeName, nil] forState:UIControlStateNormal];
}

/**
 *  设置底部组件
 */
- (void)setupBottomView {
    
    UIView *bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)- 64 - 100 - 15 - 44 - 72, CGRectGetWidth(self.view.bounds), 48)];
    [KDSignInUtil insertTransparentGradientWithView:bottomBgView];
    [self.view addSubview:bottomBgView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bottomBgView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.frame)- CGRectGetMaxY(bottomBgView.frame))];
    bottomView.backgroundColor = [UIColor kdBackgroundColor2];
    [self.view addSubview:bottomView];
    
    UIButton *countBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [countBtn.titleLabel setFont:FS2];
    [countBtn setTitleColor:FC5 forState:UIControlStateNormal];
    [countBtn setTitle:ASLocalizedString(@"签到统计") forState:UIControlStateNormal];
    [countBtn setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdBackgroundColor7]] forState:UIControlStateNormal];
    [countBtn setBackgroundImage:[UIImage kd_imageWithColor:[UIColor colorWithRGB:0xd7dadd]] forState:UIControlStateHighlighted];
    [countBtn addTarget:self action:@selector(checkAllRecords) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:countBtn];
    [countBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    
    UIButton *signButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signButton setBackgroundImage:[UIImage imageNamed:@"sign_btn_punchbutton_normal"] forState:UIControlStateNormal];
    [signButton setBackgroundImage:[UIImage imageNamed:@"sign_btn_punchbutton_press"] forState:UIControlStateHighlighted];
    [signButton addTarget:self action:@selector(doSignin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signButton];
    [signButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(countBtn.top).with.offset(-15);
        make.height.mas_equalTo(100);
        make.width.mas_equalTo(100);
    }];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.font = [UIFont systemFontOfSize:24];
    self.timeLabel.textColor = [UIColor colorWithRGB:0xffffff alpha:0.6];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [signButton addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(signButton);
        make.centerY.mas_equalTo(signButton).with.offset(-14);
    }];
    
    UILabel *signLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    signLabel.font = FS2;
    signLabel.textColor = FC6;
    signLabel.text = ASLocalizedString(@"签到");
    signLabel.textAlignment = NSTextAlignmentCenter;
    [signButton addSubview:signLabel];
    [signLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(signButton.mas_centerX);
        make.centerY.mas_equalTo(signButton.mas_centerY).with.offset(13);
    }];
    
    UIImageView *signBubbleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sign_bubble"]];
    [self.view addSubview:signBubbleImageView];
    [signBubbleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(signButton.top).with.offset(-6);
        make.centerX.mas_equalTo(signButton.mas_centerX);
    }];
    
    self.signTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.signTypeLabel.textAlignment = NSTextAlignmentCenter;
    self.signTypeLabel.font = FS5;
    self.signTypeLabel.textColor = FC2;
    self.signTypeLabel.text = ASLocalizedString(@"定位中");
    [signBubbleImageView addSubview:self.signTypeLabel];
    [self.signTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(signBubbleImageView.mas_centerX);
        make.centerY.mas_equalTo(signBubbleImageView.mas_centerY).with.offset(-2);
    }];
    
    [self updateTimeLabel];
}

/**
 *  将cell划回初始状态
 */
- (void)sliderInCell {
    if (_currentRevealingCell) {
        [_currentRevealingCell slideInContentView];
    }
}


#pragma mark
#pragma mark KDRefreshTableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"KDSignInCell";
    KDSignInCell *cell = [[KDSignInCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.delegate = self;
    
    if ([_dataSource count] > indexPath.row) {
        [cell setRecord:_dataSource[indexPath.row]];
        cell.photoSignInCollectionViewDelegate = self;
    }
    else {
        return nil;
    }
    
    if (indexPath.row == 0) {
        cell.cellStyle = kSigninStyleBlue;
    }
    else {
        cell.cellStyle = kSigninStyleGray;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView {
    
    [self reloadDataSource:^(BOOL success, int count) {
        [self.tableview finishedRefresh:success];
        if (success && count > 0) {
            [self.tableview reloadData];
            [self removeEmptyView];
        }
    }];
}

#pragma mark
#pragma mark KDRefreshTableViewDelegate


KDREFRESHTABLEVIEW_REFRESHDATE

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataSource && _dataSource.count > indexPath.row) {
        return [KDSignInCell cellHeightByRecord:((KDSignInRecord *) _dataSource[indexPath.row])] + 16.0f;
    } else {
        return 0;
    }
}

#pragma mark
#pragma mark signin cell delegate

- (void)cellDidReveal:(KDSignInCell *)cell {
    if (_currentRevealingCell && cell != _currentRevealingCell) {
        [self sliderInCell];
    }
    _currentRevealingCell = cell;
}

- (void)cellDidClicked:(KDSignInCell *)cell withTag:(NSUInteger)tag {
    [self sliderInCell];
    if (tag == kSignInWeiboButtonTag) {
        [self sendWeibo:cell.record];
    } else if (tag == kdSignInFailuredBtnTag) {
        [[KDFailureSignInTask sharedFailureSignInTask] uploadFailedRecord];
    }
}

#pragma mark -
#pragma mark UIScroll delegate  methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [(KDRefreshTableView *) scrollView kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [(KDRefreshTableView *) scrollView kdRefreshTableviewDidEndDraging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {}

#pragma mark -
#pragma mark Location notification
- (void)locationDidSucess:(NSNotification *)notifcation {
    self.unableToGetPositionAlert.failedCount = 0;
    self.dolocationTimeInterVal = [[NSDate date] timeIntervalSince1970] - self.dolocationTimeInterVal;
    NSDictionary *info = notifcation.userInfo;
    NSArray *array = [info objectForKey:@"OffsetLocationArray"];
    self.locationDataArray = array;
    self.currentLocationData = [array objectAtIndex:0];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationOffsetCoor object:nil];
    [self doLocationSuccess:nil fileIds:nil cacheStr:nil];
}

- (void)locationNearbyDidSucess:(NSNotification *)notifcation {
    NSDictionary *info = notifcation.userInfo;
    NSArray *array = [info objectForKey:@"locationArray"];
    self.locationDataArray = array;
    self.currentLocationData = [array objectAtIndex:0];
    [self showLocationOptionViewController];
}

- (void)locationDidFailed:(NSNotification *)notifcation {
    NSDictionary *info = notifcation.userInfo;
    NSString *error = [NSString stringWithFormat:@"reason:%@\ndescription:%@", ((NSError *) [info objectForKey:@"error"]).localizedFailureReason, ((NSError *) [info objectForKey:@"error"]).description];
    NSString *failedType = info[@"failedType"];
    
    if ([failedType isEqualToString:KDSignInFailedTypeLocation]) {
        [KDPopup hideHUDInView:self.view];
        
        __weak KDSignInViewController *weakSelf = self;
        [self.unableToGetPositionAlert show:^{
            [weakSelf presentImagePickerController];
            [weakSelf addTipViewWithTip:ASLocalizedString(@"无法定位，拍张照片说明你的位置吧！")];
        }];
        
    }
    else if ([failedType isEqualToString:KDSignInFailedTypePOIError]) {
        [self searchPOIFromOwnServer];
    }
    
    [KDSignInLogManager sendSignInLogWithFailureType:failedType errorMessage:error];
}

- (void)locationDidstart:(NSNotification *)notifcation {
    [KDPopup showHUD:ASLocalizedString(@"正在定位...") inView:self.view];
}

#pragma mark -
#pragma mark Notification Handle Method
/**
 *  定位成功时处理后续
 *  kSignLocationType_Signin
 *     message : 自定义签到地址
 *  kSignLocationType_ReSignin
 *     message : 外勤时传过来的原因
 *
 */

- (void)doLocationSuccess:(NSString *)message fileIds:(NSString *)fileIds cacheStr:(NSString *)cacheArrayStr {
    self.doSignInTimeInterVal = [[NSDate date] timeIntervalSince1970];
    if (_locationType == kSignLocationType_Signin) {
        //内勤签到
        if (message == nil) {
            __weak KDSignInViewController *weakSelf = self;
            [KDPopup showHUD:ASLocalizedString(@"正在签到...") inView:weakSelf.view];
            
            [self signinToServerAddress:message block:^(BOOL success, KDSignInRecord *record, NSString *errorStr, NSInteger errorCode) {
                //内勤签到成功
                if (success && record.status == kKDSignInStatusSuccess && ![record.featurename isEqual:@""]) {
                    weakSelf.doSignInTimeInterVal = [[NSDate date] timeIntervalSince1970] - weakSelf.doSignInTimeInterVal;
                    
                    record.recordType = KDSignInSuccessType_internal;
                    [KDSignInUtil saveRecords:@[record]
                                         date:weakSelf.currentDate
                                       reload:NO
                              completionBlock:^(id results) {
                                  [weakSelf signInSuccessFunctionWithRecord:record];
                              }];
                    
                    BOOL shouldShowToast = NO;
                    //弹窗优先级：异常反馈>活动弹窗>勋章弹窗>加班弹窗
                    if (![weakSelf showFeedbackWithRecord:record]) {
                        if (![weakSelf showActivityWithRecord:record]) {
                            KDSigninMedalModel *medal = [[KDSigninMedalModel alloc] initWithDictionary:record.medalDic];
                            if (![weakSelf showMedalListAlertWithModel:medal]) {
                                KDSignInOverTimeModel *overTimeModel = [[KDSignInOverTimeModel alloc] initWithDictionary:record.attendanceTipsDic];
                                if (![weakSelf showOverTimeHintViewWithModel:overTimeModel]) {
                                    shouldShowToast = YES;
                                }
                            }
                        }
                    }
                    
                    [KDPopup hideHUDInView:weakSelf.view];
                    if (shouldShowToast) {
                        [KDPopup showHUDToast:ASLocalizedString(@"签到成功")];
                    }
                    
                    [weakSelf setSignTypeLabelText:0];
                    
                }
                else if (record && (record.status == kKDSignInStatusFaild || record.status == KDSignInStatusHaveNoLink || record.status == KDSignInStatusSetNoPoint)) {
                    weakSelf.locationType = kSignLocationType_ReSignin;
                    weakSelf.faildRecord = record;
                    [weakSelf signinFaild];
                    
                    if (weakSelf.expandCount >= 0 && weakSelf.expandCount < 2) {
                        weakSelf.expandCount += 1;
                    }
                }
                // 内勤签到失败
                else if (!success) {
                    // 时间鉴权失败
                    if (errorCode == 401) {
                        [KDPopup showHUDToast:ASLocalizedString(@"手机时间异常，请进入系统时间设置中将其改为最新时间") inView:weakSelf.view];
                        return;
                    }
                    
                    double delayInSeconds = 0.5;
                    
                    [KDSignInLogManager sendSignInLogWithFailureType:KDSignInFailedTypeNormal errorMessage:[NSString stringWithFormat:ASLocalizedString(@"reason:内勤签到失败\ndescription:%@"), errorStr ?: @""]];
                    
                    KDSignInRecord *saveSignInRecord = [[KDSignInRecord alloc] init];
                    [weakSelf setRecordFeaturesWithRecord:saveSignInRecord];
                    if (KD_IS_BLANK_STR(saveSignInRecord.featurename)) {
                        [KDPopup hideHUDInView:weakSelf.view];
                        [weakSelf.unableToGetPositionAlert show:^{
                            [weakSelf presentImagePickerController];
                            [weakSelf addTipViewWithTip:ASLocalizedString(@"网络不稳定，拍张照片说明你的位置吧！")];
                        }];
                        return;
                    }
                    saveSignInRecord.clockInType = @"manual";
                    
                    [weakSelf setSSIDBSSIDForRecord:saveSignInRecord];
                    saveSignInRecord.manualType = KDSignInManualType_neiQin;
                    [weakSelf failOperateWithRecord:saveSignInRecord];
                    
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                        [KDPopup hideHUDInView:weakSelf.view];
                    });
                }
            }];
        }
        //自定义签到
        else {
            __weak KDSignInViewController *weakSelf = self;
            [KDPopup showHUD: ASLocalizedString(@"正在签到...") inView:weakSelf.view];
            
            [self signinToServerAddress:message block:^(BOOL success, KDSignInRecord *record, NSString *errorStr, NSInteger errorCode) {
                //自定义签到成功
                if (success && ![record.featurename isEqual:@""]) {
                    weakSelf.doSignInTimeInterVal = [[NSDate date] timeIntervalSince1970] - weakSelf.doSignInTimeInterVal;
                    record.recordType = KDSignInSuccessType_custom;
                    [KDSignInUtil saveRecords:@[record]
                                         date:weakSelf.currentDate
                                       reload:NO
                              completionBlock:^(id results) {
                                  [weakSelf signInSuccessFunctionWithRecord:record];
                              }];
                    
                    BOOL shouldShowToast = NO;
                    if (![weakSelf showActivityWithRecord:record]) {
                        shouldShowToast = YES;
                    }
                    
                    [KDPopup hideHUDInView:weakSelf.view];
                    if (shouldShowToast) {
                        [KDPopup showHUDToast:ASLocalizedString(@"签到成功")];
                    }
                }
                //自定义签到失败
                else if (!success || !record) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [KDPopup showHUDSuccess:ASLocalizedString(@"数据成功保存到本地") inView:weakSelf.view];
                    });
                    
                    [KDSignInLogManager sendSignInLogWithFailureType:KDSignInFailedTypeNormal errorMessage:[NSString stringWithFormat:ASLocalizedString(@"reason:自定义签到失败\ndescription:%@"), errorStr ?: @""] ];
                    
                    KDSignInRecord *saveSignInRecord = [[KDSignInRecord alloc] init];
                    
                    if (fileIds && fileIds.length > 0) {
                        saveSignInRecord.photoIds = fileIds;
                    }
                    
                    [weakSelf setRecordFeaturesWithRecord:saveSignInRecord];
                    saveSignInRecord.clockInType = @"manual";
                    if (message) {
                        saveSignInRecord.address = message;
                    }
                    if ((!saveSignInRecord.featurename || saveSignInRecord.featurename.length == 0) && message) {
                        saveSignInRecord.featurename = message;
                    }
                    [weakSelf setSSIDBSSIDForRecord:saveSignInRecord];
                    saveSignInRecord.manualType = KDSignInManualType_custom;
                    [weakSelf failOperateWithRecord:saveSignInRecord];

                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                        [KDPopup hideHUDInView:weakSelf.view];
                    });
                }
                
            }];
            
        }
    }
    else if (_locationType == kSignLocationType_ReSignin) {
        __weak KDSignInViewController *weakSelf = self;
        [KDPopup showHUD:ASLocalizedString(@"正在签到...") inView:weakSelf.view];
        //外勤签到
        [self reSigninToServer:message fileIds:(NSString *) fileIds block:^(BOOL success, KDSignInRecord *record, NSString *errorStr) {
            //外勤签到成功
            if (success && ![record.featurename isEqual:@""]) {
                weakSelf.doSignInTimeInterVal = [[NSDate date] timeIntervalSince1970] - weakSelf.doSignInTimeInterVal;
                
                if ([[[BOSConfig sharedConfig] user] isAdmin]) {
                    record.recordType = KDSignInSuccessType_adminExternal;
                } else {
                    record.recordType = KDSignInSuccessType_customExternal;
                }
                if (fileIds && ![fileIds isEqualToString:@""]) {
                    record.photoIds = fileIds;
                }
                [KDSignInUtil saveRecords:@[record]
                                     date:weakSelf.currentDate
                                   reload:NO
                          completionBlock:^(id results) {
                              [weakSelf signInSuccessFunctionWithRecord:record];
                          }];
                
                if (weakSelf.outDoorType == OutDoor_Type_None) {
                    BOOL shouldShowToast = NO;
                    if (![weakSelf showActivityWithRecord:record]) {
                        KDSignInOverTimeModel *overTimeModel = [[KDSignInOverTimeModel alloc] initWithDictionary:record.attendanceTipsDic];
                        if (![weakSelf showOverTimeHintViewWithModel:overTimeModel]) {
                            shouldShowToast = YES;
                        }
                    }
                    
                    [KDPopup hideHUDInView:weakSelf.view];
                    if (shouldShowToast) {
                        [KDPopup showHUDToast:ASLocalizedString(@"签到成功")];
                    }
                }
                else {
                    NSString *type = @"";
                    NSString *title = @"";
                    if (weakSelf.outDoorType == OutDoor_Type_LOOK_STORE) {
                        type = @"LOOK_STORE";
                        title = ASLocalizedString(@"门店巡访");
//                        [KDEventAnalysis event:event_signin_look_store];
                    }
                    else if (weakSelf.outDoorType == OutDoor_Type_CUSTOMER_VISIT) {
                        type = @"CUSTOMER_VISIT";
                        title = ASLocalizedString(@"客户跟进");
//                        [KDEventAnalysis event:event_signin_custom_visit];
                    }
                    KDWebViewController *webViewVC = [[KDWebViewController alloc] initWithUrlString:[NSString stringWithFormat:@"%@workreport/create/report/clockIn?clockInId=%@&type=%@",[[[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance] getServerBaseURL],record.singinId,type]];
                    webViewVC.title = title;
                    webViewVC.isBlueNav = YES;
                    [weakSelf.navigationController pushViewController:webViewVC animated:YES];
                }
            }
            //外勤签到失败
            else if (!success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KDPopup hideHUDInView:weakSelf.view];
                    
                    [KDSignInLogManager sendSignInLogWithFailureType:KDSignInFailedTypeNormal errorMessage:[NSString stringWithFormat:ASLocalizedString(@"reason:外勤签到失败\ndescription:%@"), errorStr ? errorStr : @""]];
                    
                    KDSignInRecord *saveSignInRecord = [[KDSignInRecord alloc] init];
                    if (weakSelf.faildRecord && ![weakSelf.faildRecord.singinId isKindOfClass:[NSNull class]] && weakSelf.faildRecord.singinId && weakSelf.faildRecord.singinId.length > 0) {
                        saveSignInRecord.singinId = [weakSelf.faildRecord.singinId copy];
                    }
                    
                    if (fileIds && fileIds.length > 0) {
                        saveSignInRecord.photoIds = [fileIds copy];
                    } else if (cacheArrayStr && cacheArrayStr.length > 0) {
                        saveSignInRecord.cachesUrl = [cacheArrayStr copy];
                    }
                    
                    [weakSelf setRecordFeaturesWithRecord:saveSignInRecord];
                    saveSignInRecord.clockInType = @"manual";
                    if (message) {
                        saveSignInRecord.address = message;
                        record.message = message;
                    }
                    
                    [weakSelf setSSIDBSSIDForRecord:saveSignInRecord];
                    saveSignInRecord.org_latitude = _faildRecord.latitude;
                    saveSignInRecord.org_longitude = _faildRecord.longitude;
                    saveSignInRecord.manualType = KDSignInManualType_waiQin;
                    [weakSelf failOperateWithRecord:saveSignInRecord];
                });
            }
        }];
    }
}

- (void)showLocationOptionViewController {
    [KDPopup hideHUDInView:self.view];
    if ([self canGoToLocationOption]) {
        KDLocationOptionViewController *  _locationOptionViewController = [[KDLocationOptionViewController alloc] init];
        _locationOptionViewController.delegate = self;
        _locationOptionViewController.title = ASLocalizedString(@"我的位置");
        _locationOptionViewController.optionsArray = self.locationDataArray;
        _locationOptionViewController.locationData = self.currentLocationData;
        
        __weak KDSignInViewController *weakSelf = self;
        _locationOptionViewController.locationOptionPhotoSignInBlock = ^(void){
            [weakSelf presentImagePickerController];
        };
        _locationOptionViewController.shouldHideBottomView = NO;
        _locationOptionViewController.isFromSignInVC = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_locationOptionViewController];
        
        [self presentViewController:nav animated:YES completion:nil];
        
    }
}

/**
 *  定位位置非法时
 *
 */
- (void)signinFaild {
    if (self.clDefinelocation) {
        [[KDLocationManager globalLocationManager] setClDefineCurrentData:self.clDefinelocation];
    }
    [[KDLocationManager globalLocationManager] doReverseGeocodingSearch];
    [KDPopup showHUD:ASLocalizedString(@"正在获取周边位置...") inView:self.view];
}

/**
 *  播放定位成功声音
 */
- (void)playSound {
    static NSString *soundPath = nil;
    static NSURL *soundURL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        soundPath = [[NSBundle mainBundle]
                     pathForResource:@"Calypso" ofType:@"caf"];
        soundURL = [NSURL fileURLWithPath:soundPath];
    });
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) soundURL, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];

    if ([buttonTitle isEqualToString:ASLocalizedString(@"签到记录")]) {
        [self checkAllRecords];
        return;
    }
    
    if ([buttonTitle isEqualToString:ASLocalizedString(@"分享我的奋斗史到朋友圈")]) {
        [KDEventAnalysis event:event_signin_record_sharewx];
        [self shareSignInRecordToWXWithAlert:alertView];
        return;
    }
    if (alertView.tag == KDSignInShareAlertTag && [buttonTitle isEqualToString:ASLocalizedString(@"取消")]) {
        [KDEventAnalysis event:event_signin_record_noshare];
        return;
    }
    
    //勋章榜弹窗
    if (alertView.tag == KDSigninMedalAlertTag) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self clickAlertButtonWithIndex:0];
        }
        else {
            [self clickAlertButtonWithIndex:1];
        }
        return;
    }
    
}

#pragma mark KDLocationOptionViewController delegate methods

- (void)determineLocation:(KDLocationData *)locationData viewController:(KDLocationOptionViewController *)viewController beginTimeInterval:(NSTimeInterval)beginTimeInterval {
    
    if (![self cheatingProcessingOperationWithBeginTimeInterval:beginTimeInterval]) {
        return;
    }
    self.currentLocationData = locationData;
    
    [KDPopup hideHUDInView:self.view];
    
    NSTimeInterval nowBeginTimeInterval = [[NSDate date] timeIntervalSince1970];
    __weak KDSignInViewController *weak_self = self;
    KDOutDoorSignInViewController *outDoorSignInViewController = [[KDOutDoorSignInViewController alloc] init];
    outDoorSignInViewController.controller = self;
    outDoorSignInViewController.locationData = locationData;
    outDoorSignInViewController.completeBlock = ^(NSString *content, NSString *fileIds, NSString *cacheStr , OutDoor_Type type) {
        [KDPopup hideHUDInView:self.view];
        weak_self.outDoorType = type;
        if (![self cheatingProcessingOperationWithBeginTimeInterval:nowBeginTimeInterval]) {
            return;
        }
        [self doLocationSuccess:content fileIds:fileIds cacheStr:cacheStr];
    };
    [self.navigationController pushViewController:outDoorSignInViewController animated:YES];
}

- (BOOL)cheatingProcessingOperationWithBeginTimeInterval:(NSTimeInterval)beginTimeInterval {
    NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970] - beginTimeInterval;
    if (nowInterval > KDCheatingProcessingOperationTime) {
        self.currentLocationData = nil;
        double delayInSeconds = 1;
        [KDPopup showHUDToast:ASLocalizedString(@"定位超时，正在重新定位...") inView:self.view];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self doSignin:nil];
        });
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark UI Handle Method

/**
 *  判断是否可以进入选地图界面
 *
 *  @return
 */
- (BOOL)canGoToLocationOption {
    return (_currentLocationData != nil && _locationDataArray != nil);
}

- (void)showPOIInputView {
    
    _locationType = kSignLocationType_Signin;
    KDSignInPOIInputView *inputView = [[KDSignInPOIInputView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [inputView setBlock:^(NSString *address) {
        [self doLocationSuccess:address fileIds:nil cacheStr:nil];
    }];
    [self.navigationController.view addSubview:inputView];
}


/**
 *  内容为空时显示的视图
 *
 *  @return 内容为空时显示的视图
 */
- (UIView *)emptyView {
    if (!_emptyView) {
        NSString *content;
        if ([BOSConfig sharedConfig].user.isAdmin) {
            content = ASLocalizedString(@"我能管理小伙伴的内外勤工作.\n还能帮你核算工时,\n让考勤更简单,快试试吧!");
        }else{
            content = ASLocalizedString(@"KDSignInCell_Sigin");
        }
        CGSize contentSize = [content boundingRectWithSize:CGSizeMake(ScreenFullWidth - 50 - 25 - 12 * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:FS3} context:nil].size;
        _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0, ScreenFullWidth - 50 - 25, ceilf(contentSize.height + 8 * 2))];
        
        KDSigninCellInnerView *innerView = [[KDSigninCellInnerView alloc] initWithFrame:_emptyView.bounds];
        [innerView setGestureEnable:NO];
        
        KDSignInRecord *record = [[KDSignInRecord alloc] init];
        [record setContent:content];
        
        innerView.cellStyle = kSigninStyleGray;
        innerView.record = record;
        
        [_emptyView addSubview:innerView];
    }
    
    return _emptyView;
}


- (void)addEmptyView {
    if (!_emptyView || _emptyView.superview != _tableview) {
        [_tableview addSubview:[self emptyView]];
    }
}

- (void)removeEmptyView {
    if (_emptyView && _emptyView.superview == _tableview) {
        [_emptyView removeFromSuperview];
    }
}

- (void)timerSchedule {
    //30秒定位一次，并获取签到类型
    if (self.timerScheduleCount >= 30) {
        self.timerScheduleCount = 0;
        [self viewDidLoadStartLocation];
    }
    else {
        self.timerScheduleCount++;
    }
    
    if (!self.currentDate) {
        return;
    }
    [self whenApplicationWillEnterForeground];
}

- (void)updateDateLabel {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =
    [gregorian components:( NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit) fromDate:_currentDate];
    NSInteger month = [weekdayComponents month];
    NSInteger day = [weekdayComponents day];
    NSInteger year = [weekdayComponents year];
    NSInteger week = [weekdayComponents weekday];
    self.dateLabel.text = [NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)year, (long)month,(long)day];
    self.weekLabel.text = [KDSignInUtil weekDayWithWeekIndex:week];
}

- (void)updateTimeLabel {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =
    [gregorian components:( NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:_currentDate];
    NSInteger hour = [weekdayComponents hour];
    NSInteger minute = [weekdayComponents minute];
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)hour, (long)minute];
}

- (void)startLocation {
    if ([KDReachabilityManager sharedManager].reachabilityStatus == KDReachabilityStatusNotReachable) {
        [KDPopup hideHUDInView:self.view];
        
        __weak KDSignInViewController *weakSelf = self;
        [self.unableToGetPositionAlert show:^{
            [weakSelf presentImagePickerController];
            [weakSelf addTipViewWithTip:ASLocalizedString(@"网络不稳定，拍张照片说明你的位置吧！")];
        }];
        
        return;
    }
    
    //首先移除通知  再添加通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationFailed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationStart object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationLocationOffsetCoor object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationNearbyDidSucess:) name:KDNotificationLocationSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFailed:) name:KDNotificationLocationFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidstart:) name:KDNotificationLocationStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidSucess:) name:KDNotificationLocationOffsetCoor object:nil];
    
    
    _locationType = kSignLocationType_Signin;
    if (self.clDefinelocation) {
        BOOL signInResult = [self judgeToSignIn];
        if (signInResult) {
            [[KDLocationManager globalLocationManager] setLocationType:KDLocationTypeSignIn];
            [[KDLocationManager globalLocationManager] startInitMapSearch];
            return;
        }
    }
    self.dolocationTimeInterVal = [[NSDate date] timeIntervalSince1970];
    [[KDLocationManager globalLocationManager] setLocationType:KDLocationTypeSignIn];
    [[KDLocationManager globalLocationManager] startLocating];
}

- (void)setCurrentLocationData:(KDLocationData *)currentLocationData {
    if (_currentLocationData != currentLocationData) {
        _currentLocationData = currentLocationData;
    }
}

/**
 *  根据经纬度判断当前的签到类型（内勤／外勤）
 */
- (void)getAttendanceSetInfo {
    if (self.clDefinelocation) {
        
        __weak KDSignInViewController *weakSelf = self;
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
            if (results) {
                BOOL attendanceLabel = [[results objectForKey:@"attendanceLabel"] boolValue];
                if (attendanceLabel) {
                    [self setSignTypeLabelText:1];
                }
                else {
                    [self setSignTypeLabelText:0];
    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //进签到首页时判断是内勤的话就自动签到
                        if (!self.isGuideHintViewShow && !self.isFromSignInRemindNotification && [[KDSignInManager autoSignInFlagString] compare:[[NSDate date] formatWithFormatter:KD_DATE_ISO_8601_SHORT_FORMATTER]] == NSOrderedAscending) {
                            [KDSignInManager setAutoSignInFlagWithString:[[NSDate date] formatWithFormatter:KD_DATE_ISO_8601_SHORT_FORMATTER]];
                            [KDPopup showHUDInView:self.view];
                            [self doSignin:nil];
                        }
                    });
                }

            } else {
                [self setSignTypeLabelText:2];
            }
        };
        
        KDQuery *query = [KDQuery query];
        [query setParameter:@"longitude" doubleValue:self.clDefinelocation.coordinate.longitude];
        [query setParameter:@"latitude" doubleValue:self.clDefinelocation.coordinate.latitude];
        [KDServiceActionInvoker invokeWithSender:weakSelf
                                      actionPath:@"/signId/:getAttendanceSetInfo"
                                           query:query
                                     configBlock:nil
                                 completionBlock:completionBlock];
    }
    else {
        [self setSignTypeLabelText:2];
    }
}

/**
 * setSignTypeLabelText
 *
 * @param type 0:内勤 1:外勤 2:网络不好,拍照签到
 */
- (void)setSignTypeLabelText:(NSInteger)type {
    switch (type) {
        case 0:
            self.signTypeLabel.text = ASLocalizedString(@"进入签到范围内");
            break;
        case 1:
            self.signTypeLabel.text = ASLocalizedString(@"外勤签到");
            break;
        case 2:
            self.signTypeLabel.text = ASLocalizedString(@"网络不好,拍照签到");
            break;
        default:
            break;
    }
}

/**
 *  签到的方法
 *
 *  @param address 自定义签到的地址名（如果为nil，则是正常签到，否则为自定义签到）
 *  @param block
 *
 */
- (void)signinToServerAddress:(NSString *)address block:(void (^)(BOOL success, KDSignInRecord *record, NSString *errorStr, NSInteger errorCode))block {
    __weak KDSignInViewController *weakSelf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if (results) {
            BOOL success = [[results objectForKey:@"success"] boolValue];
            NSInteger errorCode = [[results objectForKey:@"errorCode"] integerValue];
            NSArray *signs = [results objectForKey:@"singIns"];
            if (success && [signs count] > 0) {
                KDSignInRecord *record = (KDSignInRecord *) [signs lastObject];
                if (KD_IS_BLANK_STR(record.featurename)) {
                    record.featurename = [BOSSetting sharedSetting].customerName;
                }
                if (block) {
                    block(success, record, success ? nil : [NSString stringWithFormat:@" %@ statusCode: %ld", [response responseAsString] ?: @"", (long) [response statusCode]], 0);
                }
            }
            else {
                if (block) {
                    block(NO, nil, [NSString stringWithFormat:@" %@ statusCode: %ld", [response responseAsString] ?: @"", (long) [response statusCode]], errorCode);
                }
            }
        } else {
            if (block) {
                block(NO, nil, [NSString stringWithFormat:@" %@ statusCode: %ld", [response responseAsString] ?: @"", (long) [response statusCode]], 0);
            }
        }
    };
    
    KDSignInRecord *record = [[KDSignInRecord alloc] init];
    [self setRecordFeaturesWithRecord:record];
    KDQuery *query = [KDQuery query];
    [self setSSIDBSSIDForRecord:record];
    record.clockInType = @"manual";
    [query setProperty:record forKey:@"signin"];
    if (address) {
        [query setParameter:@"address" stringValue:address];
    }
    
    if (self.expandCount >= 0 && self.expandCount < 2) {
        [query setParameter:@"isExpand" booleanValue:NO];
    }
    else if (self.expandCount == 2) {
        [query setParameter:@"isExpand" booleanValue:YES];
    }
    
    [query setParameter:@"deviceInfo" stringValue:[KDSignInUtil getSignInDeviceInfo]];
    
    [KDServiceActionInvoker invokeWithSender:weakSelf
                                  actionPath:@"/signId/:sign"
                                       query:query
                                 configBlock:nil
                             completionBlock:completionBlock];
}

/**
 *  首次定位不合法，重新定位请求
 *  @param block
 */
- (void)reSigninToServer:(NSString *)message fileIds:(NSString *)fileIds block:(void (^)(BOOL success, KDSignInRecord *record, NSString *errorStr))block {
    __weak KDSignInViewController *weakSelf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        
        if (results) {
            BOOL success = [[results objectForKey:@"success"] boolValue];
            NSArray *signs = [results objectForKey:@"singIns"];
            if ([signs count] > 0) {
                KDSignInRecord *record = (KDSignInRecord *) [signs lastObject];
                
                if (block) {
                    block(success, record, nil);
                }
            } else {
                if (block) {
                    block(NO, nil, [NSString stringWithFormat:@" %@ statusCode: %ld", [response responseAsString] ?: @"", (long) [response statusCode]]);
                }
            }
        } else {
            if (block) {
                block(NO, nil, [NSString stringWithFormat:@" %@ statusCode: %ld", [response responseAsString] ?: @"", (long) [response statusCode]]);
            }
        }
    };
    
    KDSignInRecord *record = [[KDSignInRecord alloc] init];
    record.singinId = _faildRecord && _faildRecord.singinId ? [_faildRecord.singinId copy]:@"";
    [self setRecordFeaturesWithRecord:record];
    record.message = message;
    KDQuery *query = [KDQuery query];
    [self setSSIDBSSIDForRecord:record];
    record.clockInType = @"manual";
    
    [query setProperty:record forKey:@"signin"];
    [query setParameter:@"org_latitude" doubleValue:_faildRecord.latitude];
    [query setParameter:@"org_longitude" doubleValue:_faildRecord.longitude];
    if (message && message.length > 0) {
        [query setParameter:@"remark" stringValue:message];
    }
    
    if (fileIds && ![fileIds isKindOfClass:[NSNull class]]) {
        [query setParameter:@"photoId" stringValue:fileIds];
    }
    
    [query setParameter:@"deviceInfo" stringValue:[KDSignInUtil getSignInDeviceInfo]];
    
    [KDServiceActionInvoker invokeWithSender:weakSelf actionPath:@"/signId/:resign" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

/**
 *  从网络重新加载数据
 *
 *  @param block
 */
- (void)reloadDataSource:(void (^)(BOOL success, int count))block {
    
    __weak KDSignInViewController *weakSelf = self;
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if (results) {
            NSArray *signs = [results objectForKey:@"singIns"];
            KDSignInSchema *schema = [results objectForKey:@"schema"];
            weakSelf.currentDate = schema.time;
            
            [KDSignInUtil saveRecords:signs date:weakSelf.currentDate reload:YES completionBlock:^(id results) {
                if (results && [(NSArray *) results count] > 0) {
                    [weakSelf.dataSource removeAllObjects];
                    [weakSelf.dataSource addObjectsFromArray:results];
                    if (block) {
                        block(YES, (int) signs.count);
                    }
                }
                else {
                    if (block) {
                        block(YES, 0);
                    }
                }
            }];
        } else {
            if (block) {
                block(NO, 0);
            }
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:weakSelf actionPath:@"/signId/:getSignList" query:nil
                                 configBlock:nil completionBlock:completionBlock];
    
}

- (void)searchPOIFromOwnServer {
    if (_searchPOIClient == nil) {
        _searchPOIClient = [[KDSignInClient alloc] initWithTarget:self action:@selector(searchPOIDidReceived:result:)];
    }
    [_searchPOIClient searchPOIWithLatitude:self.currentLocationData.coordinate.latitude longitude:self.currentLocationData.coordinate.longitude];
}

- (void)searchPOIDidReceived:(KDSignInClient *)client result:(BOSResultDataModel *)result {
    
    [KDPopup hideHUDInView:self.view];
    
    BOSResultDataModel *bosResult = [[BOSResultDataModel alloc] initWithDictionary:(NSDictionary *) result];
    if (client.hasError || bosResult == nil || bosResult.success == NO) {
        [self showPOIInputView];
    }
    else {
        NSMutableArray *posArray = [NSMutableArray array];
        NSString *address = bosResult.data[@"address"];
        NSDictionary *formatted_addresses = bosResult.data[@"formatted_addresses"];
        NSString *recommend = formatted_addresses[@"recommend"];
        NSString *rough = formatted_addresses[@"rough"];
        KDLocationData *locationData = [[KDLocationData alloc] init];
        locationData.address = address;
        locationData.name = (recommend.length > 0 ? recommend : rough);
        locationData.coordinate = _currentLocationData.coordinate;
        [posArray addObject:locationData];
        NSArray *pois = [bosResult.data objectForKey:@"pois"];
        for (NSDictionary *dic in pois) {
            KDLocationData *locationData = [KDLocationData locationDataByDictionary:dic];
            if (locationData) {
                locationData.city = _currentLocationData.city;
                locationData.province = _currentLocationData.province;
                locationData.district = _currentLocationData.district;
                [posArray addObject:locationData];
            }
        }
        self.locationDataArray = posArray;
        self.currentLocationData = [posArray objectAtIndex:0];
        [self showLocationOptionViewController];
    }
}

#pragma mark -
#pragma mark Database Method

/**
 *  先从本地加载数据，再从网络加载数据
 */
- (void)loadData {
    __weak KDSignInViewController *weakSelf = self;
    [KDDatabaseHelper asyncInDatabase:(id) ^(FMDatabase *fmdb) {
        id <KDSigninRecordDAO> signinDAO = [[KDWeiboDAOManager globalWeiboDAOManager] signinDAO];
        [weakSelf.dataSource removeAllObjects];
        [weakSelf.dataSource addObjectsFromArray:[signinDAO queryRecordsWithLimit:NSUIntegerMax withDate:weakSelf.currentDate database:fmdb]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.dataSource count] <= 0) {
                [weakSelf addEmptyView];
            }
            else {
                if (weakSelf.emptyView && weakSelf.emptyView.superview) {
                    [weakSelf removeEmptyView];
                }
            }
            [weakSelf.tableview reloadData];
        });
        return nil;
    }                 completionBlock:nil];
}


#pragma mark -
#pragma mark 事件操作方法
- (void)popViewController {
    [self.navigationController popToRootViewControllerAnimated:NO];
    [[KDWeiboAppDelegate getAppDelegate].tabBarController setSelectedIndex:0];
}

//签到
- (void)doSignin:(UIButton *)sender {
    //在自动签到之前用户点击了签到按钮时候,更新自动签到标记的值
    if ([[KDSignInManager autoSignInFlagString] compare:[[NSDate date] formatWithFormatter:KD_DATE_ISO_8601_SHORT_FORMATTER]] == NSOrderedAscending) {
        [KDSignInManager setAutoSignInFlagWithString:[[NSDate date] formatWithFormatter:KD_DATE_ISO_8601_SHORT_FORMATTER]];
    }
    
    [KDEventAnalysis event:event_signin_clickbtn];
    
    if ([KDSignInUtil locationServiceNotEnable]) {
        [KDPopup hideHUDInView:self.view];
        [KDLocationAlertManager showLocationAlert];
    }
    else {
        [self sliderInCell];
        [self startLocation];
    }
    
}

- (void)setting:(id)sender {
    if (![KDSignInManager isSignInSettingBtnClicked]) {
        [KDSignInManager setIsSignInSettingBtnClicked:YES];
    }
    [KDEventAnalysis event:event_signin_set];
    
    KDSignInSettingViewController *vc = [[KDSignInSettingViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
    [self sliderInCell];
}


//背景点击事件
- (void)bgClick:(UITapGestureRecognizer *)ges {
    [self sliderInCell];
}

- (void)checkAllRecords {
    [KDEventAnalysis event:event_signin_myrecord];
    KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:@"https://webapp.coli688.com/moapproval-emp/yunxt/detail.do" appId:@"1012103"];
    webVC.isBlueNav = YES;
    webVC.title = ASLocalizedString(@"签到统计");
    webVC.hidesBottomBarWhenPushed = YES;
    __weak __typeof(self) weakSelf = self;
    
    __weak __typeof(webVC) weakWebVC = webVC;
    
    webVC.getLightAppBlock = ^() {
            [weakSelf.navigationController pushViewController:weakWebVC animated:YES];
    };
}


- (void)saveSignInFaluredWithRecord:(KDSignInRecord *)record controller:(KDSignInViewController *)weakSelf {
    record.status = -1;
    record.singinTime = [NSDate date];
    if (!record.singinId || [record.singinId isKindOfClass:[NSNull class]] || record.singinId.length == 0)
        record.singinId = [NSString stringWithFormat:@"%@%f%lu", @"KD", [record.singinTime timeIntervalSince1970], (unsigned long) [record hash]];
    [KDSignInUtil saveRecords:@[record]
                         date:record.singinTime
                       reload:NO
              completionBlock:^(id results) {
                  [weakSelf removeEmptyView];
                  
                  KDSignInCell *cell = (KDSignInCell *) [weakSelf.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                  cell.cellStyle = kSigninStyleGray;
                  
                  [weakSelf.dataSource insertObject:record atIndex:0];
                  [weakSelf.tableview insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                  [weakSelf.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
              }];
}

- (void)viewDidLoadData {
    __weak KDSignInViewController *weakSelf = self;
    [KDDatabaseHelper asyncInDatabase:(id) ^(FMDatabase *fmdb) {
        id <KDSigninRecordDAO> signinDAO = [[KDWeiboDAOManager globalWeiboDAOManager] signinDAO];
        [weakSelf.dataSource removeAllObjects];
        [weakSelf.dataSource addObjectsFromArray:[signinDAO queryRecordsWithLimit:NSUIntegerMax withDate:weakSelf.currentDate database:fmdb]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.dataSource count] <= 0) {
                [weakSelf addEmptyView];
            }
            else {
                if (weakSelf.emptyView && weakSelf.emptyView.superview) {
                    [weakSelf removeEmptyView];
                }
            }
            [weakSelf.tableview reloadData];
        });
        return nil;
    }                 completionBlock:nil];
}

- (void)dealloc {
    
    [[KDLocationManager globalLocationManager] disableLocating];
    [KDServiceActionInvoker cancelInvokersWithSender:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[KDLocationDefineManager shareManager] stopLocationOperation];
    
    if (_searchPOIClient) {
        [_searchPOIClient cancelRequest];
        _searchPOIClient = nil;
    }
    
}

#pragma mark - getter & setter

- (KDCommonHintView *)guideHintView {
    if (_guideHintView) return _guideHintView;
    
    __weak KDSignInViewController *weakSelf = self;
    _guideHintView = [[KDCommonHintView alloc] init];
    
    if ([BOSConfig sharedConfig].user.isAdmin) {
        [_guideHintView setupTitle:ASLocalizedString(@"签到设置升级啦") image:[UIImage imageNamed:@"sign_tip_guide_admin"] pointTexts:@[ASLocalizedString(@"按部门设置考勤组,考勤状态更精准"),ASLocalizedString(@"设置弹性考勤时间,提升员工幸福感")]];
        _guideHintView.showCloseButton = YES;
        _guideHintView.hideRightButton = YES;
        _guideHintView.leftButtonString = ASLocalizedString(@"体验一下");
        _guideHintView.leftButtonTextColor = FC5;
        _guideHintView.buttonClickBlock = ^(NSInteger index , NSString *text) {
            if (index == 0) {
                KDSignInSettingViewController *vc = [[KDSignInSettingViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                vc.showGuideView = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        };
    }
    else {
        [_guideHintView setupTitle:ASLocalizedString(@"欢迎使用签到") image:[UIImage imageNamed:@"sign_tip_guide"] pointTexts:@[ASLocalizedString(@"支持内勤、外勤签到"),ASLocalizedString(@"多种方式精确定位"),ASLocalizedString(@"实时掌控外勤人员轨迹路线"),ASLocalizedString(@"电脑/手机便捷查看团队考勤报表"),ASLocalizedString(@"报表一键导出，方便快捷")]];
        _guideHintView.buttonClickBlock = ^(NSInteger index , NSString *text) {
            if (index == 0) {
                //[KDEventAnalysis event:event_signin_guide_iknow];
            }
            if (index == 1) {
                //[KDEventAnalysis event:event_signin_guide_checkmore];
                
                NSString *kdweiboUrlStr = [NSString stringWithFormat:ASLocalizedString(@"%@/attendancelight/signin-ldy/index.html?point=8478&msg=签到引导页进来"),[[[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance] getServerBaseURL]];
                NSString* encodedString = [kdweiboUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                KDWebViewController *activityVC = [[KDWebViewController alloc] initWithUrlString:encodedString];
                activityVC.title = ASLocalizedString(@"移动签到升级啦");
                activityVC.isBlueNav = YES;
                activityVC.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:activityVC animated:YES];
            }
        };
    }
    
    return _guideHintView;
}

- (KDUnableToGetPositionAlert *)unableToGetPositionAlert {
    if (!_unableToGetPositionAlert) {
        _unableToGetPositionAlert = [[KDUnableToGetPositionAlert alloc] init];
    }
    return _unableToGetPositionAlert;
}

- (void)setSSIDBSSIDForRecord:(KDSignInRecord *)saveSignInRecord{
    NSDictionary *savedwifiModelDict = [KDSignInUtil getCurrentWifiData];
    if (savedwifiModelDict && ![savedwifiModelDict isKindOfClass:[NSNull class]]) {
        NSString *savedssid = savedwifiModelDict[@"ssid"];
        NSString *savedbssid = savedwifiModelDict[@"bssid"];
        
        if (savedssid && ![savedssid isKindOfClass:[NSNull class]]) {
            saveSignInRecord.ssid = savedssid;
        }
        if (savedbssid && ![savedbssid isKindOfClass:[NSNull class]]) {
            saveSignInRecord.bssid = savedbssid;
        }
    }
}

- (void)signInSuccessFunctionWithRecord:(KDSignInRecord *)record{
    KDSignInCell *cell = (KDSignInCell *) [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.cellStyle = kSigninStyleGray;
    
    [self.dataSource insertObject:record atIndex:0];
    [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableview scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    [self removeEmptyView];
    
    [self playSound];
    self.locationType = kSignLocationType_None;
    self.locationDataArray = nil;
    self.currentLocationData = nil;
    self.faildRecord = nil;
}

- (void)setRecordFeaturesWithRecord:(KDSignInRecord *)saveSignInRecord{
    saveSignInRecord.latitude = self.currentLocationData.coordinate.latitude;
    saveSignInRecord.longitude = self.currentLocationData.coordinate.longitude;
    saveSignInRecord.featurename = safeString(self.currentLocationData.name);
    saveSignInRecord.featurenamedetail = safeString(self.currentLocationData.longAddress);
    
    if (saveSignInRecord.featurenamedetail.length > 0 && saveSignInRecord.featurename.length > 0 && ![saveSignInRecord.featurename isEqualToString:saveSignInRecord.featurenamedetail]) {
        
        if (isAboveiOS8 && ([saveSignInRecord.featurenamedetail containsString:saveSignInRecord.featurename] || [saveSignInRecord.featurename containsString:saveSignInRecord.featurenamedetail])) {
            return;
        }
        
        saveSignInRecord.featurenamedetail = [NSString stringWithFormat:@"%@ %@", saveSignInRecord.featurenamedetail, saveSignInRecord.featurename];
        saveSignInRecord.featurename = [NSString stringWithFormat:@"%@(%@)", saveSignInRecord.featurename, saveSignInRecord.featurenamedetail];
    }
}

- (void)failOperateWithRecord:(KDSignInRecord *)record {
    if (record.featurename && record.featurename.length > 0) {
        [self saveSignInFaluredWithRecord:record controller:self];
    }
    self.locationDataArray = nil;
    self.currentLocationData = nil;
    self.faildRecord = nil;
}

@end
