
//
//  DailViewController.m
//  ContactsLite
//
//  Created by kingdee eas on 12-11-6.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "XTTimelineViewController.h"
#import "XTSetting.h"
#import "ContactClient.h"
//#import "AppDelegate.h"
#import "XTPersonDetailViewController.h"
#import "UIButton+XT.h"
#import "XTQRLoginViewController.h"
#import "AppsClient.h"
#import "KDWebViewController.h"
#import "XTPublicTimelineViewController.h"
#import "XTDeleteService.h"
#import "XTOpenConfig.h"
#import "BOSSetting.h"
#import "BOSConfig.h"
#import "KDLeftTeamMenuViewController.h"
#import "KDWeiboAppDelegate.h"
#import "LeveyTabBarController.h"
#import "XTTimelineSetTableViewCell.h"
#import "UIImage+Extension.h"
#import "KDAvatarSettingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "KDDiscoveryViewController.h"
#import "KDMainTimelineViewController.h"
#import "KDDefaultViewControllerContext.h"
#import "KDInviteColleaguesViewController.h"
#import "UIImage+Extension.h"
#import "FoldPublicDataModel.h"
#import "KDPublicTopCell.h"
#import "KDPhoneInputViewController.h"
#import "KDBindEmailViewController.h"
#import "KDTimelineManager.h"
#import "ContactLoginDataModel.h"
#import "XTPubAcctUserChatListViewController.h"
#import "KDSearch.h"
#import "KDToDoContainorViewController.h"
#import "KDApplicationQueryAppsHelper.h"
#import "KDPlusMenuView.h"
#import "PersonSimpleDataModel.h"
#import "KDInboxListViewController.h"
#import "KDMultipartyCallBannerView.h"
#import "KDAgoraCallView.h"
#import "KDAgoraSDKManager.h"
#import "KDPubAccDetailViewController.h"
#import "UINavigationController+Chat.h"
#import "XTDataBaseDao.h"
#import "KDNetworkDisconnectView.h"

#import <AudioToolbox/AudioToolbox.h>
#import "KDTimelineSectionItem.h"
#import "KDAgoraCallView.h"
#import "KDUserHelper.h"
#import "SimplePersonListDataModel.h"
#import "CircleProgressView.h"
#import "KDPersonCache.h"




#define BLURIMAGE_TAG 999
#define kPerPageSize (int)20
#define kPageRequstCount 40
#define kTimelineAdsBannerHeight ScreenFullWidth * (92.0/720)
static NSString *CellIdentifier = @"CellIdentifier";
static NSString *PublicCellIdentifier = @"PublicCellIdentifier";

@interface XTTimelineViewController ()
<UITableViewDataSource, UITableViewDelegate,KDLoginPwdConfirmDelegate, KDBindEmailViewControllerDelegate,SWTableViewCellDelegate,KDTabBarControllerDelegate>
@property (nonatomic, strong) ContactClient *toggleGroupTopClient;
@property (nonatomic, strong) ContactClient *groupListClient;
@property (nonatomic, strong) ContactClient *markAllMsgClient;
@property (nonatomic, strong) MBProgressHUD *progressHud;
@property (nonatomic, strong) ContactClient *personInfoClient;
@property (nonatomic, strong) ContactClient *deleteClient;
@property (nonatomic, strong) ContactClient *pubaccClient;
@property (nonatomic, strong) PersonSimpleDataModel *publicAccount;
@property (nonatomic, strong) GroupDataModel *selectGroup;
@property (nonatomic, assign) BOOL isGetGroupList;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *markButton;
@property (nonatomic, strong) UIButton *creatChatButton;
@property (nonatomic, strong) UIButton *qrButton;
@property (nonatomic, strong) UIButton *weiboButton;
@property (nonatomic, strong) UIButton *inviteButton;
@property (nonatomic, strong) UILabel *creatChatLabel;
@property (nonatomic, strong) UILabel *qrLabel;
@property (nonatomic, strong) UILabel *inviteLabel;
@property (nonatomic, strong) UILabel *weiboLabel;
@property (nonatomic, copy) NSString *unreadCountStr;
@property (nonatomic, strong) FoldPublicDataModel *publicDataModel;
@property (nonatomic, assign) CGPoint lastContentOffset;
@property (assign, nonatomic) BOOL isFirstReload;
@property (assign, nonatomic) int currentUnreadIndex;
@property (nonatomic, strong) ContactClient *pageRequestClient;
@property (nonatomic, assign) NSInteger pageRequestOffset;
@property (nonatomic, assign) BOOL isFirstPage;
@property (nonatomic, assign) BOOL bBackFromGroupChat; //"@提及"功能使用, 进入了多人组后, 回来时需要调用grouplist.action接口刷新页面
@property (nonatomic, strong) NSMutableArray *mArrayPublicAndGroups; // 为了 FoldPublicDataModel + GroupDataModel 混排
@property (nonatomic, assign) int iIndexOfPublicGroup;


@property (nonatomic, strong) UIImageView *imageViewTodoFilter; // 代办蒙版
@property (nonatomic, strong) UIButton *buttonTodoFilterConfirm; // 代办蒙版确认按钮

@property (nonatomic, strong) GroupDataModel *targetGroup; // 用于标记选中的group，用途：标记为已读，置顶
@property (nonatomic, assign) BOOL bTableReloading;

@property(nonatomic, strong) KDSearch *search;


@property (nonatomic, assign) BOOL isTopForFoldPublic;


@property (nonatomic, strong) KDPlusMenuView *plusMenuView;
@property (nonatomic, assign) BOOL bShowingPlusMenu;
@property (nonatomic, strong) UIImageView *imageViewPlus;
@property (nonatomic, strong) UIImageView *imageViewMark;

@property(nonatomic, assign) BOOL bShowVoiceBanner;
@property (nonatomic, strong) KDMultipartyCallBannerView *multipartyCallBannerView;
@property (nonatomic, strong) ContactClient *queryGroupInfoClient;
@property (nonatomic, strong) AppsClient *qrcodeAppClient;

@property (nonatomic, strong) AppsClient *publicAcctClient;

@property (nonatomic, strong) NSString *currentChatGroupId;
@property (nonatomic, strong) ContactClient *hasDelMsgClient;

//网络提示相关
@property (nonatomic, strong) KDNetworkDisconnectView *networkDisconnectView;
@property(nonatomic, strong) NSMutableArray *sectionList;
@property (nonatomic, assign) NSInteger networkStatus;

@property (nonatomic, strong) KDUserHelper *userHelper;

//@property (nonatomic, strong) GroupDataModel *pushGroup; // 推送过来，要进去的多人组
@property (nonatomic, copy) void(^blockRecursiveGetMoreRelatedPerson)(BOOL, BOOL, CGFloat, void(^)());

@property (nonatomic, assign) BOOL fininshFetchPerson;

@property (nonatomic, strong) CircleProgressView *progressView; //相关人员信息进度条

@property (nonatomic, strong) UIView *backView; //首次拉相关人员弹框底层背景，不给做其他操作

@property (nonatomic, assign) NSInteger currentCount;
@end

@implementation XTTimelineViewController{
    
    UIImageView * _blurImageView;
    dispatch_queue_t _dbReadQueue;
    BOOL menuBounceAnimation;
}

-(BOOL)isTopForFoldPublic
{
    if (!_isTopForFoldPublic)
    {
        _isTopForFoldPublic = NO;
    }
    return _isTopForFoldPublic;
}



- (void)dealloc
{
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"needUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationChannelNewMessage object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KDGroupIDNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDHasExitGroupNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDHasMessageDelNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        //第一次进6.0.4重新拉取一下groupList
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"XTTimelineUpdate_7.0.6"])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"XTTimelineUpdate_7.0.6"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllData];
            if(![[KDTimelineManager shareManager] shouldStarPagingRequest])
                [[KDTimelineManager shareManager]deleteCompanyInfoForPageRequest];
            [[KDTimelineManager shareManager] setNumberOfPages:0];
            [XTSetting sharedSetting].updateTime = [NSString string];
            [XTSetting sharedSetting].pubAcctUpdateTime = [NSString string];
            [[XTSetting sharedSetting] saveSetting];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"FetchRelatePersonInfo_%@_%@",[BOSConfig sharedConfig].user.orgId,[BOSConfig sharedConfig].user.userId]];
        }
        
        
        menuBounceAnimation = YES;
        //        [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
        //                                                 BOSCOLORWITHRGBA(0x6f7a84, 1.0), UITextAttributeTextColor,[UIFont systemFontOfSize:12],UITextAttributeFont,
        //                                                 nil] forState:UIControlStateNormal];
        //        [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
        //                                                 BOSCOLORWITHRGBA(0x0062d2, 1.0), UITextAttributeTextColor,[UIFont systemFontOfSize:12],UITextAttributeFont,
        //                                                 nil] forState:UIControlStateSelected];
        //
        //        [self.tabBarItem setFinishedSelectedImage:[XTImageUtil tabBarItemImageWithIndex:0 state:UIControlStateSelected]
        //                      withFinishedUnselectedImage:[XTImageUtil tabBarItemImageWithIndex:0 state:UIControlStateNormal]];
        
        //转发通知，放在viewWillAppear会出错
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forwardToPerson:) name:@"forwardPersonMessage" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forwardToGroup:) name:@"forwardGroupMessage" object:nil];
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGroupTable) name:@"reloadGroupTable" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareToGroup:) name:@"shareGroupMessage" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareStatus:) name:@"shareStatus" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidePlusMenu:) name:@"hidePlusMenu" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentChatInfo:) name:@"KDGroupIDNotification" object:nil];
        
        self.groups = [[NSMutableArray alloc] init];
        
        self.pageRequestOffset = [[KDTimelineManager shareManager]numberOfPages];
    }
    return self;
}

- (BOOL)shouldShowSetAvatarTipView
{
    return [[BOSConfig sharedConfig].user isDefaultAvatar] && [BOSSetting sharedSetting].showAvatarFlag == 0;
}
- (BOOL)shouldShowBindPhoneTipView
{
    //    return [BOSSetting sharedSetting].bindPhoneFlag == 0 && [[BOSConfig sharedConfig].user.phone length] == 0;
    return NO;
}
- (BOOL)shouldShowBindEmailTipView
{
    return NO;
    //return [BOSSetting sharedSetting].bindEmailFlag == 0 && [[BOSConfig sharedConfig].user.email length] == 0;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdate:) name:KDNotificationChannelNewMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNetworkConnectStatus:) name:KDReachabilityDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdate:) name:@"needUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedExitGroupNotification:) name:KDHasExitGroupNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasMessageDelete:) name:KDHasMessageDelNotification object:nil];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    _dbReadQueue = dispatch_queue_create("com.timeline.queue", NULL);
    self.isFirstReload = YES;
    self.sectionList = [NSMutableArray array];
    
    
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    self.addButton.backgroundColor = [UIColor redColor];
    [self.addButton setFrame:CGRectMake(0, 0, 44, 44)];
    
    self.imageViewPlus = [[UIImageView alloc]initWithImage:[XTImageUtil buttonAddMenuImage]];
    self.imageViewPlus.center = CGPointMake(22, 22);
    [self.addButton addSubview:self.imageViewPlus];
    
    
    [self.addButton addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.addButton.tag = 0;
    
    //标记
    self.markButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    self.addButton.backgroundColor = [UIColor redColor];
    [self.markButton setFrame:CGRectMake(0, 0, 44, 44)];
    
    self.imageViewMark = [[UIImageView alloc]initWithImage:[XTImageUtil buttonMarkImage]];
    self.imageViewMark.center = CGPointMake(22, 22);
    [self.markButton addSubview:self.imageViewMark];
    
    
    [self.markButton addTarget:self action:@selector(markBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.markButton.tag = 1;
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:self.addButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    UIBarButtonItem *markItem = [[UIBarButtonItem alloc] initWithCustomView:self.markButton];
    
    
    negativeSpacer.width = -15;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,addItem,markItem, nil];
    //    self.navigationItem.rightBarButtonItems = @[addItem];
    
    
    self.groupTableView = [UITableView new];
    self.groupTableView.backgroundColor = [UIColor kdBackgroundColor2];
    self.groupTableView.delegate = self;
    self.groupTableView.dataSource = self;
    self.groupTableView.rowHeight = 73.0;
    [self.view addSubview:self.groupTableView];
    self.groupTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.groupTableView registerClass:[XTTimelineCell class] forCellReuseIdentifier:CellIdentifier];
    [self.groupTableView registerClass:[KDPublicTopCell class] forCellReuseIdentifier:PublicCellIdentifier];
    
    [self.groupTableView makeConstraints:^(MASConstraintMaker *make)
     {
         make.edges.equalTo(self.view).with.insets(UIEdgeInsetsZero);
     }];
    
    self.lastContentOffset = self.groupTableView.contentOffset;
    __block XTTimelineViewController *weakSelf = self;
    self.search = [[KDSearch alloc] initWithContentsController:self];
    self.search.blockBeginSearching = ^{
        [weakSelf.tabBarController.tabBar setHidden:YES];
    };
    self.search.blockEndSearching = ^{
        [weakSelf.tabBarController.tabBar setHidden:NO];
        
    };
    self.groupTableView.tableHeaderView = self.search.searchBar;
    
    if ([XTOpenConfig sharedConfig].isCreater) {
        [self performSelector:@selector(showInvite) withObject:nil afterDelay:0.5];
    }
    
    self.currentUnreadIndex = -1;
    self.networkStatus = KDReachabilityStatusReachableViaWiFi;
    //账号第一次登陆触发
    if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"FetchRelatePersonInfo_%@_%@",[BOSConfig sharedConfig].user.orgId,[BOSConfig sharedConfig].user.userId]]) {
        self.currentCount = 0;
        [[UIApplication sharedApplication].keyWindow addSubview:self.backView];
        [self.progressView setProgress:0 animated:NO];
        __weak __typeof(self) weakSelf = self;
        if (!self.blockRecursiveGetMoreRelatedPerson) {
            self.blockRecursiveGetMoreRelatedPerson = ^(BOOL succ, BOOL more , CGFloat percent, void (^completion)()) {
                NSString *lastUpdateScore = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"lastPersonLastUpdateScore_%@_%@",[BOSConfig sharedConfig].user.orgId,[BOSConfig sharedConfig].user.userId]];
                // 递归防御
                [weakSelf.progressView setProgress:percent animated:NO];
                if (succ ){
                    if (more) {
                        [weakSelf fetchRelatedPersonsByPageWithScore:lastUpdateScore
                                                      recursiveBlock:weakSelf.blockRecursiveGetMoreRelatedPerson
                                                          completion:completion];
                    }else
                    {
                        weakSelf.currentCount = 0;
                        //                        [weakSelf.backView removeFromSuperview];
                        
                        //                        //第一次必须成功 才能后续使用
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"FetchRelatePersonInfo_%@_%@",[BOSConfig sharedConfig].user.orgId,[BOSConfig sharedConfig].user.userId]];
                        [weakSelf reloadGroupTable];
                        [weakSelf getGroupListBothType];
                        [weakSelf reloadAllData];
                    }
                    
                } else {
                    if (completion) {
                        completion();
                    }
                }
            };
        }
        [weakSelf fetchRelatedPersonsByPageWithScore:@""
                                      recursiveBlock:weakSelf.blockRecursiveGetMoreRelatedPerson
                                          completion:nil];
        
    }else
    {
        [self reloadGroupTable];
        [self getGroupListBothType];
        [self reloadAllData];
    }
    
}

- (UIView*)backView
{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    }
    return  _backView;
}

- (CircleProgressView*)progressView
{
    if (!_progressView) {
        _progressView = [[CircleProgressView alloc]initWithFrame:CGRectMake(100, 400, 150, 150)];
        _progressView.center = self.view.center;
        _progressView.backgroundColor = FC5;
        [_progressView setBackgroundStrokeColor:[UIColor clearColor]];
        [_progressView setProgressStrokeColor:[UIColor whiteColor]];
        _progressView.digitTintColor = [UIColor whiteColor];
        _progressView.layer.shadowColor = [UIColor blackColor].CGColor;
        _progressView.layer.shadowOffset = CGSizeMake(5, 5);
        _progressView.layer.shadowRadius = 5;
        _progressView.layer.cornerRadius = 12;
        _progressView.layer.masksToBounds = YES;
        [self.backView addSubview:self.progressView];
    }
    return  _progressView;
}
- (void)fetchRelatedPersonsByPageWithScore:(NSString *)personScore
                            recursiveBlock:(void (^)(BOOL succ, BOOL more, CGFloat percent, void (^completion)()))recursiveBlock
                                completion:(void (^)())completion{
    if (self.userHelper == nil)
        self.userHelper = [[KDUserHelper alloc] init];
    __weak __typeof(self) weakSelf = self;
    [self.userHelper getRelatePersonWithScore:personScore
                                   completion:^(BOOL success, BOOL more, NSDictionary *personDic, NSString *error) {
                                       if (success) {
                                           SimplePersonListDataModel *personList = [[SimplePersonListDataModel alloc]initWithDictionary:personDic];
                                           weakSelf.currentCount += [personList.list count];
                                           [personList.list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                               PersonSimpleDataModel *person = (PersonSimpleDataModel *) obj;
                                               [[XTDataBaseDao sharedDatabaseDaoInstance]insertPersonSimple:person];
                                               if ([person isPublicAccount]) {
                                                   [[XTDataBaseDao sharedDatabaseDaoInstance]insertPublicPersonSimple:person];
                                               }
                                               
                                           }];
                                           PersonSimpleDataModel *lastPerson = [personList.list lastObject];
                                           //把最后一次更新的score保存 跟登陆人员id绑定
                                           if (personList.lastUpdateScore > 0) {
                                               [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",personList.lastUpdateScore] forKey:[NSString stringWithFormat:@"lastUpdateScore_%@_%@",[BOSConfig sharedConfig].user.orgId,[BOSConfig sharedConfig].user.userId]];
                                           }
                                           
                                           [[NSUserDefaults standardUserDefaults] setValue:lastPerson.personScore forKey:[NSString stringWithFormat:@"lastPersonLastUpdateScore_%@_%@",[BOSConfig sharedConfig].user.orgId,[BOSConfig sharedConfig].user.userId]];
                                           if (recursiveBlock){
                                               recursiveBlock(YES, personList.hasMore, (CGFloat)weakSelf.currentCount/personList.totalCount, completion);
                                           }
                                           
                                       }else
                                       {
                                           if (recursiveBlock) {
                                               recursiveBlock(NO,NO,0.0,completion);
                                           }
                                       }
                                       
                                   }];
}

#pragma mark - sectionData
- (void)reloadAllData {
    [self reloadSectionData];
    [self.groupTableView reloadData];
}

- (void)reloadSectionData {
    [_sectionList removeAllObjects];
    if (![self isReachable]) {
        KDTimelineSectionItem *item = [KDTimelineSectionItem new];
        item.sectionType = KDTimelineSectionNetwork;
        [_sectionList addObject:item];
    }
    if (self.bShowVoiceBanner && [self isReachable]) {
        KDTimelineSectionItem *item = [KDTimelineSectionItem new];
        item.sectionType = KDTimelineSectionVoice;
        [_sectionList addObject:item];
    }
    //    if (self.bShowTrustBanner) {
    //        KDTimelineSectionItem *item = [KDTimelineSectionItem new];
    //        item.sectionType = KDTimelineSectionTrust;
    //        [_sectionList addObject:item];
    //    }
    //    if (self.bShowBanner && self.adDetailModel) {
    //        KDTimelineSectionItem *item = [KDTimelineSectionItem new];
    //        item.sectionType = KDTimelineSectionAds;
    //        [_sectionList addObject:item];
    //    }
    //    if ([[BOSSetting sharedSetting] isPersonalNetwork] && self.peopleMayKnownArr.count > 0) {
    //        KDTimelineSectionItem *item = [KDTimelineSectionItem new];
    //        item.sectionType = KDTimelineSectionPeople;
    //        [_sectionList addObject:item];
    //    }
    //    if (self.isNotDefault) {
    //        KDTimelineSectionItem *item = [KDTimelineSectionItem new];
    //        item.sectionType = KDTimelineSectionRelation;
    //        [_sectionList addObject:item];
    //    }
    
    KDTimelineSectionItem *item = [KDTimelineSectionItem new];
    item.sectionType = KDTimelineSectionGroupList;
    [_sectionList addObject:item];
}

- (BOOL)isReachable {
    return self.networkStatus == KDReachabilityStatusReachableViaWWAN || self.networkStatus == KDReachabilityStatusReachableViaWiFi;
}

- (void)buttonMaskPressed:(UIButton *)sender
{
    sender.hidden = YES;
}


- (void)showInvite
{
    //    [(KDLeftTeamMenuViewController *)[[[KDWeiboAppDelegate getAppDelegate] sideMenuViewController] menuViewController] showRecommendView];
    [XTOpenConfig sharedConfig].isCreater = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //代办里面的坑爹搜索默认关键字
    [[NSUserDefaults standardUserDefaults]setValue:@"" forKey:@"searchBarKeyWord"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self setNavigationStyle:KDNavigationStyleNormal];
    
    self.title = ASLocalizedString(@"XTTimelineViewController_Msg");
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGroupTable) name:@"reloadTimeLineGroupTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agoraMultiVoiceStatusChangeNotification:) name:KDAgoraMessageQuitChannelNotification object:nil];
    [self.search.searchBar setCustomPlaceholder:ASLocalizedString(@"KDSearchBar_Search")];
    self.addButton.hidden = NO;
    if (_blurImageView != nil) {
        _blurImageView.alpha = 0;
    }
    
    if (!self.stillHideTabBar) {
        [self.tabBarController.tabBar setHidden:NO];
    }
    
    // view did load那次不用再reload, 但以后都需要
    if (!self.isFirstReload && !self.bTableReloading && [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"FetchRelatePersonInfo_%@_%@",[BOSConfig sharedConfig].user.orgId,[BOSConfig sharedConfig].user.userId]]) {
        [self reloadGroupTable];
    }
    self.isFirstReload = NO;
    if (self.bShowingPlusMenu)
    {
        self.plusMenuView.alpha = 0;
        self.bShowingPlusMenu = NO;
        [self cancelRotatePlusButton];
    }
    [AppWindow addSubview:self.plusMenuView];
    
    if([[KDApplicationQueryAppsHelper shareHelper]getGroupTalkStatus])
    {
        KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
        if(agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel)
        {
            if(!self.bShowVoiceBanner)
            {
                [self showVoiceBanner];
            }
        }else if(self.bShowVoiceBanner)
        {
            self.bShowVoiceBanner = NO;
            [self reloadAllData];
        }
    }
    
    /**
     *  @提及需要从会话组返回时刷新
     */
    if(self.bBackFromGroupChat && !self.pushGroup.isRemoteMsg)
        [self getGroupList];
    
    [[KDApplicationQueryAppsHelper shareHelper] checkGroupTalkAvailableOrNot];
}

//- (void)fetchRelatedPersonsByPageWithScore:(NSString *)personScore completion:(void (^)())completion{
//
//
//}



- (void)cancelRotatePlusButton
{
    [UIView animateWithDuration:.25 animations:^
     {
         self.imageViewPlus.transform = CGAffineTransformIdentity;
     }];
}
- (BOOL)hasInvitePermission
{
    NSString *type = [[BOSSetting sharedSetting] hasInvitePermission];
    if ([type isEqualToString:@"0"])
    {
        return [[[BOSConfig sharedConfig]user]isAdmin];
    }
    else if ([type isEqualToString:@"1"])
    {
        return YES;
    }
    else
        return NO;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.stillHideTabBar) {
        [self.tabBarController.tabBar setHidden:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadTimeLineGroupTable" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDAgoraMessageQuitChannelNotification object:nil];
    
    self.addButton.hidden = YES;
    self.bGoMultiVoiceAfterCreateGroup = NO;
    [self.plusMenuView removeFromSuperview];
    
    [[KDTimelineManager shareManager]setNumberOfPages:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    DLog(@"XTTimelineViewController 内存警告");
}

-(void)needUpdate:(NSNotification *)notification
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"FetchRelatePersonInfo_%@_%@",[BOSConfig sharedConfig].user.orgId,[BOSConfig sharedConfig].user.userId]]) {
        return;
    }
    
    //拉取数据中，不操作，完成后再拉一次groupList就好
    if (self.isGetGroupList == YES) {
        return;
    }
    
    [self getGroupList];
}

#pragma Button

- (void)addBtnClicked:(UIButton *)btn
{
    if (self.bShowingPlusMenu)
    {
        [self hidePlusMenu];
    } else {
        [self showPlusMenu];
    }
}
- (void)markBtnClicked:(id)sender
{
    [[KDUserDefaults sharedInstance] consumeFlag:kMarkTimelineGuide];
    //    [DGActivityIndicatorView hideInView:self.markButton];
    
    [KDEventAnalysis event:event_mark_count];
    [KDEventAnalysis eventCountly:event_mark_count];
    
    KDMarkListVC *vc = [KDMarkListVC new];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)showPlusMenu
{
    [self.plusMenuView restoreTable];
    [self rotatePlusButton];
    [UIView animateWithDuration:.25 animations:^
     {
         //        self.plusMenu.view.alpha = 1;
         self.plusMenuView.alpha = 1;
         
     }];
    self.bShowingPlusMenu = YES;
}

- (void)hidePlusMenu
{
    [self cancelRotatePlusButton];
    [UIView animateWithDuration:.25 animations:^
     {
         //        self.plusMenu.view.alpha = 0;
         self.plusMenuView.alpha = 0;
         [self.plusMenuView shrinkTable];
     }];
    self.bShowingPlusMenu = NO;
}

- (void)hidePlusMenu:(NSNotification *)notic
{
    if (self.bShowingPlusMenu)
    {
        [self hidePlusMenu];
    }
}

- (void)currentChatInfo:(NSNotification *)noti {
    NSString *groupId = [[noti userInfo] objectForKey:@"groupId"];
    self.currentChatGroupId = groupId;
}

- (BOOL)haveChatInCurrent:(NSString *)groupId {
    if (self.currentChatGroupId && [groupId isEqualToString:self.currentChatGroupId]) {
        return YES;
    }
    return NO;
}

#pragma mark - 加号菜单 -

- (KDPlusMenuView *)plusMenuView
{
    if (!_plusMenuView)
    {
        __block XTTimelineViewController *weakSelf = self;
        
        _plusMenuView = [[KDPlusMenuView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, ScreenFullWidth, ScreenFullHeight)];
        NSMutableArray *mArray = @[].mutableCopy;
        
        [mArray addObject:[KDPlusMenuViewModel modelWithTitle:ASLocalizedString(@"XTTimelineViewController_CreatChat")imageName:@"menu_tip_session"
                                                    selection:^
                           {
                               [weakSelf createChatBtn:nil];
                               [weakSelf hidePlusMenu];
                           }]];
        //商务伙伴权限问题
        if ([BOSConfig sharedConfig].user.partnerType != 1) {
            [mArray addObject:[KDPlusMenuViewModel modelWithTitle:ASLocalizedString(@"XTTimelineViewController_SendWB")imageName:@"menu_tip_write"
                                                        selection:^
                               {
                                   [weakSelf weiboBtnClick:nil];
                                   [weakSelf hidePlusMenu];
                               }]];
        }
        
        [mArray addObject:[KDPlusMenuViewModel modelWithTitle:ASLocalizedString(@"XTTimelineViewController_Scan")imageName:@"menu_tip_scan"
                                                    selection:^
                           {
                               [weakSelf qrBtnClick:nil];
                               [weakSelf hidePlusMenu];
                           }]];
        
        
        
        if ([self hasInvitePermission])
        {
            [mArray addObject:[KDPlusMenuViewModel modelWithTitle:ASLocalizedString(@"XTTimelineViewController_Add")imageName:@"menu_tip_invite"
                                                        selection:^
                               {
                                   [weakSelf inviteBtn:nil];
                                   [weakSelf hidePlusMenu];
                               }]];
        }
        
        // 团队账号在移动端应该隐藏掉【发送到电脑】
        if ([[BOSConfig sharedConfig].user.userId isEqualToString:[BOSConfig sharedConfig].mainUser.userId]) {
            [mArray addObject:[KDPlusMenuViewModel modelWithTitle:ASLocalizedString(@"XTTimelineViewController_SendToComputer")imageName:@"menu_tip_send"
                                                        selection:^
                               {
                                   //add
                                   [KDEventAnalysis event:event_sendto_computer_shortcut];
                                   [KDEventAnalysis eventCountly:event_sendto_computer_shortcut];
                                   
                                   PersonDataModel *pubacc = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicPersonSimple:kFilePersonId];
                                   if (pubacc) {
                                       XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:pubacc];
                                       chatViewController.hidesBottomBarWhenPushed = YES;
                                       chatViewController.fromTimeLie = YES;
                                       [self.navigationController pushViewController:chatViewController animated:YES];
                                   }
                                   else
                                   {
                                       if(_publicAcctClient == nil)
                                           _publicAcctClient = [[AppsClient alloc] initWithTarget:self action:@selector(getPubAccountDidReceived:result:)];
                                       
                                       [_publicAcctClient getPublicAccount:kFilePersonId];
                                   }
                               }]];
        }
        
        _plusMenuView.mArrayModels = mArray;
        
        _plusMenuView.backgroundPressed = ^
        {
            [weakSelf hidePlusMenu];
        };
        _plusMenuView.alpha = 0;
    }
    return _plusMenuView;
}

-(void)getPubAccountDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    if (result.success)
    {
        if(result.data)
        {
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:result.data];
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertPublicPersonSimple:person];
            
            XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:person];
            chatViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatViewController animated:YES];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationViewController_tips_1")message:ASLocalizedString(@"KDApplicationViewController_network_error")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alertView show];
    }
}



- (void)rotatePlusButton
{
    [UIView animateWithDuration:.25 animations:^
     {
         self.imageViewPlus.transform = CGAffineTransformMakeRotation(M_PI_4);
     }];
}
- (void)menuBackButtonClicked:(id)sender
{
    //    [self hideAddMenuWithAnimate:YES showTabbar:YES];
}

- (void)hideAddMenuWithAnimate:(BOOL)animate
{
    //    [self hideAddMenuWithAnimate:animate showTabbar:NO];
}

- (void)hideAddMenuWithAnimate:(BOOL)animate showTabbar:(BOOL)showTabbar
{
    
    
}

- (void)inviteBtn:(UIButton *)btn
{
    
    if ([[BOSSetting sharedSetting] isIntergrationMode]) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"JSBridge_Tip_7")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return ;
        
    }
    KDInviteColleaguesViewController *contact = [[KDInviteColleaguesViewController alloc] init];
    contact.hasBackBtn = YES;
    contact.showRightBtn = YES;
    contact.inviteSource = KDInviteSourceShortcut;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contact];
    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
}

#pragma mark - get

- (MBProgressHUD *)progressHud
{
    if (_progressHud == nil) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
        _progressHud.delegate = self;
        [self.view addSubview:_progressHud];
    }
    return _progressHud;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return self.sectionList.count;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger extraRow = ([self shouldShowBindPhoneTipView] || [self shouldShowBindEmailTipView]) ? 1 : 0;
    //    if (extraRow == 0) {
    //        extraRow = [self shouldShowSetAvatarTipView] ? 1 : 0;
    //    }
    
    // return (self.publicDataModel != nil ? 1 : 0) + [self.groups count] + extraRow;
    
    KDTimelineSectionItem *sectionItem = [self.sectionList safeObjectAtIndex:section];
    if (sectionItem.sectionType == KDTimelineSectionPeople) {
        return 1;
    } else if (sectionItem.sectionType == KDTimelineSectionGroupList) {
        return self.mArrayPublicAndGroups.count + extraRow;
    } else if (sectionItem.sectionType == KDTimelineSectionRelation) {
        return 1;
    }
    
    return 0;
    
    
    //    return self.mArrayPublicAndGroups.count + extraRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if([self indexOfPublicData] == 1 && indexPath.row == 0) {
    //        return 52.0f;
    //    }
    //    return 66.0;
    
    KDTimelineSectionItem *sectionItem = [self.sectionList safeObjectAtIndex:indexPath.section];
    //    if (sectionItem.sectionType == KDTimelineSectionPeople) {
    //        return [KDExtPeopleMayKnownCell height];
    //    } else
    if (sectionItem.sectionType == KDTimelineSectionRelation) {
        return 44;
    }
    return 70;
    
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    KDTimelineSectionItem *sectionItem = [self.sectionList safeObjectAtIndex:section];
    switch (sectionItem.sectionType) {
        case KDTimelineSectionNetwork:
            return self.networkDisconnectView;
            break;
        case KDTimelineSectionVoice:
            return self.multipartyCallBannerView;
            break;
            //        case KDTimelineSectionTrust:
            //            return self.trustDeviceBannerView;
            //            break;
            //        case KDTimelineSectionAds:
            //            return self.viewAdsBanner;
            //            break;
            //        case KDTimelineSectionPeople:
            //            break;
        case KDTimelineSectionRelation:
            return nil;
            break;
            
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    KDTimelineSectionItem *sectionItem = [self.sectionList safeObjectAtIndex:section];
    switch (sectionItem.sectionType) {
        case KDTimelineSectionNetwork:
            return 35;
            break;
        case KDTimelineSectionVoice:
            return 35;
            break;
            //        case KDTimelineSectionTrust:
            //            return kTimelineAdsBannerHeight;
            //            break;
            //        case KDTimelineSectionAds:
            //            return kTimelineAdsBannerHeight;
            //            break;
            //        case KDTimelineSectionPeople:
            //            break;
            //        case KDTimelineSectionRelation:
            //            return 0;
            //        case KDTimelineSectionGroupList:
            //            return 0;
            //            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //提示设置头像
    if([self indexOfPublicData] == 1 && indexPath.row == 0) {
        static NSString *AvatarCellIdentifier = @"AvatarCellIdentifier";
        XTTimelineSetTableViewCell *cell = (XTTimelineSetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:AvatarCellIdentifier];
        if(!cell) {
            cell = [[XTTimelineSetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AvatarCellIdentifier];
            
            cell.imageView.image = [UIImage imageNamed:@"message_img_head"];
            cell.imageView.backgroundColor = [UIColor clearColor];
            
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            cell.textLabel.backgroundColor = [UIColor clearColor];
            
            UIImage *bg_normal_image = [UIImage imageNamed:@"message_img_shezhitx_bg.png"];
            bg_normal_image = [bg_normal_image stretchableImageWithLeftCapWidth:bg_normal_image.size.width * 0.5f topCapHeight:bg_normal_image.size.height * 0.5f];
            UIImageView *bg_normal = [[UIImageView alloc] initWithImage:bg_normal_image];
            bg_normal.frame = cell.bounds;
            [cell setBackgroundView:bg_normal];
            
            UIImage *bg_press_image = [UIImage imageNamed:@"message_img_shezhitx_bg_press.png"];
            bg_press_image = [bg_press_image stretchableImageWithLeftCapWidth:bg_press_image.size.width * 0.5f topCapHeight:bg_press_image.size.height * 0.5f];
            UIImageView *bg_press = [[UIImageView alloc] initWithImage:bg_press_image];
            bg_press.frame = cell.bounds;
            [cell setSelectedBackgroundView:bg_press];
        }
        
        if ([self shouldShowBindPhoneTipView]) {
            cell.textLabel.text = ASLocalizedString(@"XTTimelineViewController_BindPhone");
            cell.imageView.hidden = YES;
            
        }
        else if ([self shouldShowBindEmailTipView])
        {
            cell.textLabel.text = [NSString stringWithFormat:ASLocalizedString(@"XTTimelineViewController_BindEmail"),KD_APPNAME];
            cell.imageView.hidden = YES;
        }
        //        else
        //        {
        //            cell.textLabel.text = ASLocalizedString(@"XTTimelineViewController_SetPhoto");
        //            cell.imageView.hidden = NO;
        //
        //        }
        
        cell.separatorLineInset = UIEdgeInsetsMake(0, 66.0, 0, 0);
        return cell;
    }
    int row = (int)(indexPath.row - [self indexOfPublicData]);
    id obj = self.mArrayPublicAndGroups[row];
    if ([obj isKindOfClass:[GroupDataModel class]])
    {
        XTTimelineCell *cell = (XTTimelineCell *)[self.groupTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        // 置顶要变背景色
        GroupDataModel *model = (GroupDataModel *) obj;
        cell.imageViewTop.hidden = !model.isTop;
        cell.delegate = self;
        cell.rightUtilityButtons = [self rightButtonsWithGroupDataModel:model];
        if ([cell.groupName isEqualToString:model.groupName] && [cell.groupId isEqualToString:model.groupId]) {
            // 相同不做头像更新
        } else {
            cell.group = model;
        }
        
        cell.agoraMultiCallGroupType = [model getAgoraMultiCallGroup];
        cell.groupId = model.groupId;
        cell.groupName = model.groupName;
        return cell;
    }
    
    if ([obj isKindOfClass:[FoldPublicDataModel class]])
    {
        KDPublicTopCell *cell = (KDPublicTopCell *)[self.groupTableView dequeueReusableCellWithIdentifier:PublicCellIdentifier forIndexPath:indexPath];
        
        //置顶要变背景颜色
        FoldPublicDataModel *model = (FoldPublicDataModel *)obj;
        //        cell.imageViewTop.hidden = !self.isTopForFoldPublic;
        cell.delegate = self;
        cell.rightUtilityButtons = [self rightButtonsWithFoldPublicDataModel:model];
        cell.dataModel = obj;
        cell.separatorLineInset = UIEdgeInsetsMake(0, 66.0, 0, 0);
        return cell;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self indexOfPublicData] == 1 && indexPath.row == 0) {
        
        if([self shouldShowBindPhoneTipView])
        {
            KDPhoneInputViewController *ctr = [[KDPhoneInputViewController alloc] init];
            ctr.type = KDPhoneInputTypeBind;
            ctr.delegate = self;
            
            [self.navigationController pushViewController:ctr animated:YES];
            
            [BOSSetting sharedSetting].bindPhoneFlag = 1;
            [[BOSSetting sharedSetting] saveSetting];
            
            [_groupTableView reloadData];
            
            return;
        }
        if ([self shouldShowBindEmailTipView]) {
            
            KDBindEmailViewController *ctr = [[KDBindEmailViewController alloc] init];
            ctr.delegate = self;
            ctr.fromType = 1;
            [self.navigationController pushViewController:ctr animated:YES];
            
            [BOSSetting sharedSetting].bindEmailFlag = 1;
            [[BOSSetting sharedSetting] saveSetting];
            
            [_groupTableView reloadData];
            
            
            return;
        }
        return;
    }
    int row = (int)(indexPath.row - [self indexOfPublicData]);
    
    id obj = self.mArrayPublicAndGroups[row];
    
    if ([obj isKindOfClass:[GroupDataModel class]])
    {
        
        GroupDataModel *groupDM = self.mArrayPublicAndGroups[row];
        
        //没有折叠的公共号, 例如一呼百应
        if ((groupDM.groupType == GroupTypePublic || groupDM.groupType == GroupTypePublicNoInteractive || groupDM.groupType ==GroupTypeMessageNotification) && [groupDM.participant count] == 1)
        {
            PersonSimpleDataModel *person = [groupDM.participant firstObject];
            if ([person isPublicAccount]) {
                KDPublicAccountDataModel *pubacc = [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:person.personId];
                person.state = pubacc.state;
                if (pubacc.manager) {
                    //管理员，进入代言人界面
                    self.publicAccount = pubacc;
                    self.selectGroup = groupDM;
                    [self pubGroupList:pubacc.personId];
                    return;
                }
            }
        }
        // 当进入的是多人组 回来的时候要冲刷grouplist.action
        if (groupDM.groupType == GroupTypeTodo)
        {
            [self toToDoViewControllerWithGroup:groupDM];   //详细的查看这个group
            return;
        }
        // 进入的是多人组
        // 当进入的是多人组 回来的时候要冲刷grouplist.action
        self.bBackFromGroupChat = groupDM.participant.count > 1;
        [self toChatViewControllerWithGroup:groupDM withMsgId:nil];
    }
    
    if ([obj isKindOfClass:[FoldPublicDataModel class]])
    {
        //add
        [KDEventAnalysis event:event_pubacc_tab_count];
        [KDEventAnalysis eventCountly:event_pubacc_tab_count];
        
        [XTSetting sharedSetting].foldPublicAccountPressed = YES;
        [[XTSetting sharedSetting] saveSetting];
        
        //        [[KDApplicationQueryAppsHelper shareHelper] setFoldPublicAccountPressYes];
        XTPublicTimelineViewController *chatViewController = [[XTPublicTimelineViewController alloc] init];
        chatViewController.hidesBottomBarWhenPushed = YES;
        KDPublicTopCell *cell = (KDPublicTopCell *) [tableView cellForRowAtIndexPath:indexPath];
        chatViewController.title = cell.nameLabel.text;
        [self.hud hide:YES];
        [self.navigationController pushViewController:chatViewController animated:YES];
        return;
    }
    
    
}

#pragma mark - UITableView Delete

- (int)indexOfPublicData
{
    if([self shouldShowBindPhoneTipView] || [self shouldShowBindEmailTipView])//[self shouldShowSetAvatarTipView] ||
    {
        return 1;
    }
    return 0;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    if([self indexOfPublicData] == 1 && indexPath.row == 0)
////    {
////        return NO;
////    }
//
//
//
//    // 如果是代办的cell, 则不可删除
//    GroupDataModel *tododm;
//    int iTodoIndex;
//    for (id obj in [self.mArrayPublicAndGroups copy])
//    {
//
//        if ([obj isKindOfClass:[GroupDataModel class]])
//        {
//            GroupDataModel *dm = obj;
//            if (dm.participant.count > 0) {
//                if([[dm.participant[0] personId] isEqualToString: kTodoPersonId])
//                {
//                    tododm = dm;
//                    iTodoIndex = [self.mArrayPublicAndGroups indexOfObject:dm];
//                }
//            }
//        }
//    }
//    if (tododm && indexPath.row == iTodoIndex)
//    {
//        return NO;
//    }
//
//    if ([self.mArrayPublicAndGroups indexOfObject:self.publicDataModel] == indexPath.row) {
//        return NO;
//    }
//
//
//    return YES;
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//
//        int row = indexPath.row - [self indexOfPublicData];
//
//        id obj = self.mArrayPublicAndGroups[row];
//
//        if ([obj isKindOfClass:[FoldPublicDataModel class]])
//        {
//            [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllFoldPublicGroup];
//            self.publicDataModel = nil;
//        }
//
//        if ([obj isKindOfClass:[GroupDataModel class]])
//        {
//            GroupDataModel *group = obj;
//            NSString *groupId = group.groupId;
//            [self.groups removeObject:group];
//            if ([[XTDataBaseDao sharedDatabaseDaoInstance] setPrivateGroupListToDeleteWithGroupId:groupId])
//            {
//                [[XTDeleteService shareService] deleteGroupWithGroupId:groupId];
//
//                if(group.groupType == GroupTypeDouble)
//                {
//                    //TODO:从DB中删除当前group的participant
//                    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecentlyContact:[group.participant valueForKeyPath:@"personId"]];
//                }
//            }
//        }
//
//        [self.mArrayPublicAndGroups removeObject:obj];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
//}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    for (SWTableViewCell *cell in self.groupTableView.visibleCells)
    {
        cell.longPressGestureRecognizer.enabled = NO;
    }
    if (self.lastContentOffset.y <= scrollView.contentOffset.y) {
        dispatch_async(_dbReadQueue, ^{
            NSArray *temp = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupListWithLimit:kPerPageSize offset:(int)self.groups.count];
            [self.groups addObjectsFromArray:temp];
            
            //            [self addTodoGroup];
            //            [self mergePublicAndGroup:temp.count < kPerPageSize];
            [self mergerTodoAndPublicGroup];
            BOOL hasDataOrNot = temp.count > 0 ? YES : NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.bTableReloading && hasDataOrNot == YES) {
                    [self reloadAllData];
                }
            });
        });
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (scrollView.contentOffset.y > self.lastContentOffset.y) {
        self.lastContentOffset = scrollView.contentOffset;
    }
}

#pragma mark - double click
/**
 *  使用scrollToRowAtIndexPath这个方法，在cell数目为0的时候，会出现崩溃，所以改为scrollToTopInTableView
 *  alanwong
 */
- (void)tabBarSelectedOnce
{
    //add
    //    [KDEventAnalysis event:event_message_tab_count];
    
    self.currentUnreadIndex = -1;
    [self scrollToTopInTableView];
    //    [self.groupTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)tabBarSelectedDouble
{
    /**
     *  在cell数目为0的时候，使用scrollToRowAtIndexPath这个方法，会出现崩溃，所以加入判断条件
     *  alanwong
     */
    //add
    //    [KDEventAnalysis event:event_message_tab_count];
    
    if ([[self.groupTableView visibleCells]count] == 0) {
        return;
    }
    
    int currentIndex = [self findNextUnreadIndex:self.currentUnreadIndex];
    
    int row = 0;
    if (currentIndex < 0) {
        self.currentUnreadIndex = -1;
    }
    else {
        self.currentUnreadIndex = currentIndex;
        row = self.currentUnreadIndex + [self indexOfPublicData];
    }
    [self.groupTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (int)findNextUnreadIndex:(int)currentIndex
{
    int count = (int)[self.mArrayPublicAndGroups count];
    //已经到最底部
    if (currentIndex >= count - 1) {
        return -1;
    }
    
    for (int i = currentIndex + 1; i < count; i ++) {
        id obj = self.mArrayPublicAndGroups[i];
        if ([obj isKindOfClass:[ GroupDataModel class]]) {
            GroupDataModel *group = obj;
            if (group.unreadCount > 0) {
                return i;
            }
        }
    }
    
    return -1;
}

#pragma mark - getGroupList

- (void)getGroupList
{
    if (self.isGetGroupList == YES) {
        return;
    }
    
    self.isGetGroupList = YES;
    if (self.groupListClient == nil) {
        self.groupListClient = [[ContactClient alloc]initWithTarget:self action:@selector(getGroupListDidReceived:result:)];
    }
    [self.groupListClient getGroupListWithUpdateTime:[XTSetting sharedSetting].updateTime];
}

- (void)getGroupListDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    self.isGetGroupList = NO;
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (result.success && result.data)
    {
        
        __block GroupListDataModel *groupListDM = [[GroupListDataModel alloc] initWithDictionary:result.data];
        if ([groupListDM.list count] > 0)
        {
            //清除内存中的人员缓存
            [[KDPersonCache sharedPersonCache] removeAllPersons];
            
            //更新updateTime
            [[XTSetting sharedSetting] setUpdateTime:groupListDM.updateTime];
            [[XTSetting sharedSetting] saveSetting];
            
            //折叠号内的公共号来消息了，才把已点击字段复位
            
            [groupListDM.list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                GroupDataModel *group = obj;
                if(group.groupType >= GroupTypePublic && group.fold)
                {
                    [XTSetting sharedSetting].foldPublicAccountPressed = NO;
                    [[XTSetting sharedSetting] saveSetting];
                }
                //如果返回的字段没有参与人ID 则先查再入库，因这个ID只有第一拉的时候有返回，后面都为空，防止入库的覆盖掉 706
                if (!(group.participantIds.count > 0)) {
                    group.participantIds = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupParticipateWithGroupId:group.groupId];
                }
                //有点重复 但是为了保证问稳定，没办法了 706
                if (!(group.participant.count > 0)) {
                    group.participant = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupParticipatePersonsWithIds:group.participantIds];
                }
                NSInteger localScore = [[XTDataBaseDao sharedDatabaseDaoInstance] queryGroupLocalUpdateScoreWithGroupId:group.groupId];
                if (localScore > 0) {
                    group.localUpdateScore = localScore;
                }
            }];
            
            //更新数据库 GroupDataModel
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePrivateGroupList:groupListDM];
            
            [[KDApplicationQueryAppsHelper shareHelper] checkAndAppendToDoMsgWithGroupList:groupListDM];
            
            
            [groupListDM.list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                GroupDataModel *group = (GroupDataModel *) obj;
                if (group.groupType == GroupTypePublic && group.fold && group.unreadCount > 0) {
                    *stop = YES;
                }
                
                //                if (group.unreadCount > 0 && ![group.lastMsg.content isEqualToString:@""] && [group pushOpened] && [UIApplication sharedApplication].applicationState == UIApplicationStateActive && ![self haveChatInCurrent:group.groupId]) {
                //                    // 新消息的声音、振动提醒设置
                //                    if ([BOSSetting sharedSetting].isSound) {
                //                        static NSString *soundPath = nil;
                //                        static NSURL *soundURL = nil;
                //
                //                        static dispatch_once_t onceToken;
                //                        dispatch_once(&onceToken, ^{
                //                            soundPath = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"mp3"];
                //                            soundURL = [NSURL fileURLWithPath:soundPath];
                //                        });
                //
                //                        SystemSoundID soundID;
                //
                //                        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundID);
                //
                //                        AudioServicesPlaySystemSound(soundID);
                //                    }
                //                    if ([BOSSetting sharedSetting].isVibrate) {
                //                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                //                    }
                //                }
                
            }];
            
            //去掉语音弹框
            [groupListDM.list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                GroupDataModel *group = (GroupDataModel *)obj;
                //清空
                NSString *groupId = [[NSUserDefaults standardUserDefaults] valueForKey:@"AgoraGroup"];
                if (groupId.length > 0 && [group.groupId isEqualToString:groupId] && group.mCallStatus == 0) {
                    UIViewController *topViewController = ((RTRootNavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController).topViewController;
                    for (UIView *subViews in topViewController.tabBarController.view.subviews) {
                        if (subViews.tag == KDAgoraCallViewTag) {
                            KDAgoraCallView *agoraCallView = (KDAgoraCallView*)subViews;
                            [agoraCallView removeView];
                        }
                    }
                    
                }else if(group.mCallStatus == 1 && group.mCallCreator && ![group.mCallCreator isEqualToString:[self commonPersonId:group]])
                {
                    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
                    BOOL hasCallIng = agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel;
                    BOOL isSameGroup = NO;
                    if(hasCallIng && [group.groupId isEqualToString:agoraSDKManager.currentGroupDataModel.groupId])
                    {
                        isSameGroup = YES;
                    }
                    
                    if(!hasCallIng && !isSameGroup)
                    {//不同的已存在的会议
                        [[KDWeiboAppDelegate getAppDelegate].XT receiveRemoteNotificationWithInActiveWithUserInfo:[NSDictionary dictionaryWithObject:group.groupId forKey:@"groupId"]];
                    }
                    
                }
            }];
            if ([KDWeiboAppDelegate getAppDelegate].activeChatViewController != nil)
            {
                
                [groupListDM.list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    GroupDataModel *group = (GroupDataModel *)obj;
                    
                    //                    //清空
                    //                   NSString *groupId = [[NSUserDefaults standardUserDefaults] valueForKey:@"AgoraGroup"];
                    //                    if (groupId.length > 0 && [group.groupId isEqualToString:groupId] && group.mCallStatus == 0) {
                    //                        UIViewController *topViewController = ((RTRootNavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController).topViewController;
                    //                        for (UIView *subViews in topViewController.view.subviews) {
                    //                            if (subViews.tag == KDAgoraCallViewTag) {
                    //                                [subViews removeFromSuperview];
                    //                            }
                    //                        }
                    //
                    //                    }
                    
                    if ([group.groupId isEqualToString:[KDWeiboAppDelegate getAppDelegate].activeChatViewController.group.groupId])
                    {
                        [[KDWeiboAppDelegate getAppDelegate].activeChatViewController setGroup:group];
                        [[KDWeiboAppDelegate getAppDelegate].activeChatViewController fetchDataFromNet:group.lastMsgId];
                        *stop = YES;
                    }
                    else if([KDWeiboAppDelegate getAppDelegate].activeChatViewController.group.groupId.length == 0)
                    {
                        //首次发起会话时，不带groupId
                        [[KDWeiboAppDelegate getAppDelegate].activeChatViewController setGroup:group];
                        [[KDWeiboAppDelegate getAppDelegate].activeChatViewController fetchDataFromNet:nil];
                        *stop = YES;
                    }
                }];
            }
            //            else
            //            {
            
            //            }
        }
        [self judgeGroupDateOver];
        [self reloadGroupTable];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPubTimeLineGroupTable" object:nil];
        //A.wang 同步人员信息卡片
        if(self.backView){
        [self.backView removeFromSuperview];
        }
        
    }
}
- (NSString *)commonPersonId:(GroupDataModel *)group
{
    return (group.isExternalGroup ? [BOSConfig sharedConfig].user.externalPersonId : [BOSConfig sharedConfig].user.userId);
}
/*
 //  先保留，没有问题下面两个方法就删除吧
 // 公共号参与排序逻辑
 - (void)mergePublicAndGroup:(BOOL)bShouldAddPublic
 {
 //////////////////////////////////////////////////////////////////////
 
 if (self.publicDataModel != nil)
 {
 
 //        NSMutableArray *mArrayTemp1 = [[NSMutableArray alloc]init];
 //        [mArrayTemp1 addObject:self.publicDataModel.latestMessageTime];
 
 NSMutableArray *mArrayTemp2 =  [self.groups mutableCopy];
 
 
 ////////////////////////////////////////////////////////////
 // 如有todo，删除之，最后再加。
 
 
 
 GroupDataModel *todogdm = [[XTDataBaseDao sharedDatabaseDaoInstance] queryTodoMsgInXT];
 if (todogdm)
 {
 // 删除查出来的代办, 因为已经加过了.
 for (GroupDataModel *dm in self.groups)
 {
 if (dm.groupType == GroupTypeTodo) {
 [mArrayTemp2 removeObject:dm];
 }
 
 //                if (dm.participant.count > 0){
 //                    if([[dm.participant[0] personId] isEqualToString: kTodoPersonId])
 //                    {
 //                        [mArrayTemp2 removeObject:dm];
 //                    }
 //                }
 }
 }
 
 if (self.isTopForFoldPublic == YES)
 {
 [mArrayTemp2 insertObject:self.publicDataModel atIndex:0];
 }
 else
 {
 mArrayTemp2 = [self sortFoldPublicWhenIsNotTop:mArrayTemp2];
 }
 
 ////////////////////////////////////////////////////////////
 if (todogdm)
 {
 if (!todogdm.fold) {
 [mArrayTemp2 insertObject:todogdm atIndex:0];
 }
 }
 ////////////////////////////////////////////////////////////
 
 [self.mArrayPublicAndGroups setArray:mArrayTemp2];
 }
 else
 {
 [self.mArrayPublicAndGroups setArray:self.groups];
 }
 //////////////////////////////////////////////////////////////////////
 }
 
 - (void)addTodoGroup
 {
 GroupDataModel *todogdm = [[XTDataBaseDao sharedDatabaseDaoInstance] queryTodoMsgInXT];
 
 if (todogdm)
 {
 // 删除查出来的代办, 因为已经加过了.
 for (GroupDataModel *dm in [self.groups copy])
 {
 if (dm.groupType == GroupTypeTodo) {
 [self.groups removeObject:dm];
 }
 
 //            if (dm.participant.count > 0) {
 //                if([[dm.participant[0] personId] isEqualToString: kTodoPersonId])
 //                {
 //                    [self.groups removeObject:dm];
 //                }
 //            }
 }
 
 [self.groups insertObject:todogdm atIndex:0];
 }
 }*/

- (void)mergerTodoAndPublicGroup {
    GroupDataModel *todogdm = [[XTDataBaseDao sharedDatabaseDaoInstance] queryTodoMsgInXT];
    
    if (self.publicDataModel != nil) {
        NSMutableArray *mArrayTemp2 =  [self.groups mutableCopy];
        if (todogdm) {
            // 删除查出来的代办, 之后再加上
            for (GroupDataModel *dm in self.groups) {
                if (dm.groupType == GroupTypeTodo) {
                    [mArrayTemp2 removeObject:dm];
                }
            }
        }
        
        if (self.isTopForFoldPublic == YES) {
            [mArrayTemp2 insertObject:self.publicDataModel atIndex:0];
        } else {
            mArrayTemp2 = [self sortFoldPublicWhenIsNotTop:mArrayTemp2];
        }
        
        if (todogdm) {
            [mArrayTemp2 insertObject:todogdm atIndex:0];
        }
        [self.mArrayPublicAndGroups setArray:mArrayTemp2];
    } else {
        if (todogdm) {
            for (GroupDataModel *dm in [self.groups copy]) {
                if (dm.groupType == GroupTypeTodo) {
                    [self.groups removeObject:dm];
                }
            }
            [self.groups insertObject:todogdm atIndex:0];
        }
        [self.mArrayPublicAndGroups setArray:self.groups];
    }
}

- (void)reloadGroupTable
{
    __weak XTTimelineViewController *selfInBlock = self;
    [self reloadSectionData];
    self.bTableReloading = YES;
    
    
    dispatch_async(_dbReadQueue, ^{
        
        //第一行公共号
        FoldPublicDataModel *dm = [[XTDataBaseDao sharedDatabaseDaoInstance] queryFoldPublicModel];
        if (dm)
        {
            selfInBlock.publicDataModel = dm;
        }
        else
        {
            FoldPublicDataModel *placeholderDm = [[FoldPublicDataModel alloc]init];
            placeholderDm.groupName = nil;
            placeholderDm.latestMessage = nil;
            placeholderDm.latestMessageType = MessageTypeNews;
            selfInBlock.publicDataModel = placeholderDm;
        }
        
        int limit = (int)[selfInBlock.groups count] > kPerPageSize ? (int)[selfInBlock.groups count] : kPerPageSize;
        selfInBlock.groups = [[[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupListWithLimit:limit offset:0] mutableCopy];
        
        __block int unreadCount = (int)[[XTDataBaseDao sharedDatabaseDaoInstance] queryXTTimelineUnreadCount];
        
        if ([XTSetting sharedSetting].foldPublicAccountPressed) {
            unreadCount -= self.publicDataModel.unreadCount;
            self.publicDataModel.unreadCount = 0;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [selfInBlock.mArrayPublicAndGroups removeAllObjects];
            //            [selfInBlock addTodoGroup];
            //            [selfInBlock mergePublicAndGroup:selfInBlock.groups.count < kPerPageSize];
            [selfInBlock mergerTodoAndPublicGroup];
            [[KDWeiboAppDelegate getAppDelegate].tabBarController.tabBar setDotHidden:(unreadCount <= 0) atIndex:0];
            [selfInBlock.groupTableView reloadData];
            selfInBlock.bTableReloading = NO;
        });
    });
}

#pragma mark - to ChatViewController
- (void)toToDoViewControllerWithGroup:(GroupDataModel *)group {
    
    //add
    [KDEventAnalysis event:event_todo_tab_count];
    [KDEventAnalysis eventCountly:event_todo_tab_count];
    KDToDoContainorViewController *chatViewController = [[KDToDoContainorViewController alloc] initWithGroup:group];   //这个地方未来要用groupDM来处理不同的组
    chatViewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:chatViewController animated:YES];
}
- (void)toChatViewControllerWithGroup:(GroupDataModel *)group withMsgId:(NSString *)msgId
{
    self.pushGroup = group;
    [self.navigationController setupTimelineTab];
    
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
    if (msgId != nil && msgId.length > 0) {
        chatViewController.strScrollToMsgId = msgId;
    }
    if (self.bGoMultiVoiceAfterCreateGroup) {
        chatViewController.bGoMultiVoiceAfterCreateGroup = self.bGoMultiVoiceAfterCreateGroup;
    }
    chatViewController.hidesBottomBarWhenPushed = YES;
    //    [self.navigationController pushViewController:chatViewController animated:YES];
    if (self.editImage) {
        [chatViewController handleImage:self.editImage savedPhotosAlbum:NO withLibUrl:nil];
        self.editImage = nil;
    }
    
    __weak __typeof(self) weakSelf = self;
    [chatViewController getOnePageFromDBWithMsgId:@""
                               recordCountPerPage:NUMBER_OF_RECORDS_PER_PAGE
                                        direction:MessagePagingDirectionNew
                                       completion:^(NSArray *records) {
                                           [weakSelf setNavigationStyle:KDNavigationStyleNormal];
                                           [weakSelf.navigationController pushViewController:chatViewController animated:YES];
                                       }];
}

- (void)toChatViewControllerWithPerson:(PersonSimpleDataModel *)person
{
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:person];
    chatViewController.hidesBottomBarWhenPushed = YES;
    if (self.editImage) {
        [chatViewController handleImage:self.editImage savedPhotosAlbum:NO withLibUrl:nil];
        self.editImage = nil;
    }
    [self.navigationController pushViewController:chatViewController animated:YES];
}

-(void)toStatusDetailViewControllerWithID:(NSString *) sthID andType:(NSString *)type
{
    UIButton *btn1 = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [btn1 addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [btn2 addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    if([type isEqualToString:@"6"]){
        KDMainTimelineViewController *friendTimelineController = [[KDMainTimelineViewController alloc] init];
        KDStatusDetailViewController *detail = [[KDStatusDetailViewController alloc] initWithStatusID:sthID];
        [self.navigationController pushViewController:friendTimelineController animated:NO];
        [self.navigationController pushViewController:detail animated:NO];
        
        friendTimelineController.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn1]];
        detail.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn2]];
        
    }else if([type isEqualToString:@"1"] || [type isEqualToString:@"2"]){
        KDInboxListViewController *inbox = [[KDInboxListViewController alloc] initWithInboxType:kInboxTypeAll];
        KDStatusDetailViewController *sdvc = [[KDStatusDetailViewController alloc] initWithStatusID:sthID fromInbox:sthID];
        [self.navigationController pushViewController:inbox animated:NO];
        [self.navigationController pushViewController:sdvc animated:NO];
        
        inbox.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn1]];
        sdvc.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn2]];
    }
}


- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    hud = nil;
}


/*  http://192.168.0.22/jira/browse/KSSP-15351
 时间线上去掉头像点击打开详情，改为进入会话。
 
 #pragma mark - XTGroupHeaderImageViewDelegate
 
 - (void)groupHeaderClicked:(XTGroupHeaderImageView *)headerImageView person:(PersonSimpleDataModel *)person
 {
 if ([person isPublicAccount]) {
 
 XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:person with:YES];
 personDetail.hidesBottomBarWhenPushed = YES;
 [self.navigationController pushViewController:personDetail animated:YES];
 
 }else
 {
 XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:person with:NO];
 personDetail.hidesBottomBarWhenPushed = YES;
 [self.navigationController pushViewController:personDetail animated:YES];
 }
 }
 */

#pragma mark - create chat

- (void)toChooseViewControllerWithShareData:(XTShareDataModel *)shareData
{
    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentShare];
    contentViewController.shareData = shareData;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
}

- (void)toChooseViewControllerWithForwardData:(XTForwardDataModel *)forwardData
{
    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentForward];
    contentViewController.forwardData = forwardData;
    contentViewController.delegate = self;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
}

- (void)createChatBtn:(UIButton *)btn
{
    [KDEventAnalysis event:event_shortcut_new_session];
    [KDEventAnalysis eventCountly:event_shortcut_new_session];
    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentCreate];
    contentViewController.delegate = self;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
}

#pragma mark - XTChooseContentViewControllerDelegate

- (void)chooseContentView:(XTChooseContentViewController *)controller group:(GroupDataModel *)group
{
    [self toChatViewControllerWithGroup:group withMsgId:nil];
}

- (void)chooseContentView:(XTChooseContentViewController *)controller person:(PersonSimpleDataModel *)person
{
    [self toChatViewControllerWithPerson:person];
}

#pragma mark - Forward Notification Recieve

- (void)forwardToPerson:(NSNotification *)notify
{
    //add by fang，从通讯录进入发消息会导致内存泄漏，原因暂时不明，这里先补救下
    [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex = 0;
    
    PersonDataModel *person = (PersonDataModel *)[[notify userInfo] objectForKey:@"person"];
    XTForwardDataModel *forwardDM = (XTForwardDataModel*)[[notify userInfo] objectForKey:@"forwardDM"];
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:person];
    chatViewController.isForward = YES;
    chatViewController.forwardDM = forwardDM;
    //chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)forwardToGroup:(NSNotification *)notify
{
    //add by fang，从通讯录进入发消息会导致内存泄漏，原因暂时不明，这里先补救下
    [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex = 0;
    
    GroupDataModel *group = (GroupDataModel *)[[notify userInfo] objectForKey:@"group"];
    XTForwardDataModel *forwardDM = (XTForwardDataModel*)[[notify userInfo] objectForKey:@"forwardDM"];
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
    chatViewController.isForward = YES;
    chatViewController.forwardDM = forwardDM;
    chatViewController.hidesBottomBarWhenPushed = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:chatViewController animated:YES];
    });
}

- (void)shareToGroup:(NSNotification *)notify
{
    //    GroupDataModel *group = (GroupDataModel *)[[notify userInfo] objectForKey:@"group"];
    //    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
    //    chatViewController.hidesBottomBarWhenPushed = YES;
    //    [self.navigationController pushViewController:chatViewController animated:YES];
    
    //轻应用退出
    if([KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex == 1)
        [[KDWeiboAppDelegate getAppDelegate].enteriseAppViewController.navigationController popViewControllerAnimated:NO];
    
    GroupDataModel *group = (GroupDataModel *) [[notify userInfo] objectForKey:@"group"];
    [self toChatViewControllerWithGroup:group withMsgId:nil];
}

- (void)shareStatus:(NSNotification *)notify
{
    GroupDataModel *group = (GroupDataModel *)[[notify userInfo] objectForKey:@"group"];
    XTChatViewController *chat = [[XTChatViewController alloc] initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
    chat.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chat animated:YES];
}

#pragma mark
-(void)queryQrcodeInfoWithURL:(NSString *)url
{
    if (url == nil) {
        return;
    }
    
    if (_qrcodeAppClient  == nil) {
        _qrcodeAppClient = [[AppsClient alloc ]initWithTarget:self action:@selector(queryQRcodeInfoDidReceived:result:)];
    }
    
    [_qrcodeAppClient queryQrcodeInfo:url];
}

-(void)queryQRcodeInfoDidReceived:(AppsClient *)client result:(id)result
{
    BOOL isSuccess = [result objectForKey:@"success"];
    if (isSuccess) {
        NSString *pid = [result objectForKey:@"pid"];
        NSString *qrcodeurl = [result objectForKey:@"qrcodeurl"];
        if ([pid length] > 0) {
            KDPubAccDetailViewController *viewController = [[KDPubAccDetailViewController alloc] initWithPubAcctId:pid];
            
            if ([KDWeiboAppDelegate getAppDelegate].activeChatViewController)
                [[KDWeiboAppDelegate getAppDelegate].activeChatViewController.navigationController pushViewController:viewController animated:YES];
            else
                [self.navigationController pushViewController:viewController animated:YES];
        }
        
    }else{
        
    }
    //    if (result.success) {
    NSLog(@"123123");
    //    }
}

#pragma mark - QR

- (void)qrBtnClick:(UIButton *)btn
{
    //获取对摄像头的访问权限
    //    if (isAboveiOS7) {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:ASLocalizedString(@"JSBridge_Tip_14"),KD_APPNAME] delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return;
    }
    //    }
    
    [KDEventAnalysis event:event_shortcut_scan attributes:@{label_scan_open: label_scan_open_shortcut}];
    [KDEventAnalysis eventCountly:event_shortcut_scan attributes:@{label_scan_open: label_scan_open_shortcut}];
    
    XTQRScanViewController *qrScanController = [[XTQRScanViewController alloc] init];
    qrScanController.delegate = self;
    qrScanController.controller = self;
    UINavigationController *qrScanNavController = [[UINavigationController alloc] initWithRootViewController:qrScanController];
    [self presentViewController:qrScanNavController animated:YES completion:nil];
}

- (void)qrScanViewController:(XTQRScanViewController *)controller loginCode:(int)qrLoginCode result:(NSString *)result
{
    [[KDWeiboAppDelegate getAppDelegate].tabBarController dismissViewControllerAnimated:NO completion:^{
        //        if (qrLoginCode > 0) {
        //            XTQRLoginViewController *login = [[XTQRLoginViewController alloc] initWithURL:result qrLoginCode:qrLoginCode];
        //            login.hidesBottomBarWhenPushed = YES;
        //            [self.navigationController pushViewController:login animated:YES];
        //        }
        if (qrLoginCode > 0)
        {
            if (qrLoginCode == QRPubAccScan) {
                NSString *url = [result  stringByReplacingOccurrencesOfString:@"qrcodecreate" withString:@"pubqrcode"];
                [self queryQrcodeInfoWithURL:url];
            }else{
                XTQRLoginViewController *login = [[XTQRLoginViewController alloc] initWithURL:result qrLoginCode:qrLoginCode];
                login.hidesBottomBarWhenPushed = YES;
                if ([KDWeiboAppDelegate getAppDelegate].activeChatViewController)
                    [[KDWeiboAppDelegate getAppDelegate].activeChatViewController.navigationController pushViewController:login animated:YES];
                else
                    [self.navigationController pushViewController:login animated:YES];
            }
        }
    }];
}

- (void)qrScanViewControllerDidCancel:(XTQRScanViewController *)controller
{
    [controller.controller dismissViewControllerAnimated:YES completion:nil];
    //    [[KDWeiboAppDelegate getAppDelegate].tabBarController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadWebViewControllerWithUrl:(NSString *)url
{
    if (url.length == 0) {
        return;
    }
    
    KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:url];
    webVC.hidesBottomBarWhenPushed = YES;
    webVC.isOnlyOpenInBrowser = YES;
    if ([KDWeiboAppDelegate getAppDelegate].activeChatViewController)
        [[KDWeiboAppDelegate getAppDelegate].activeChatViewController.navigationController pushViewController:webVC animated:YES];
    else
        [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark -
#pragma mark weibo

- (void)weiboBtnClick:(UIButton *)btn
{
    [KDEventAnalysis event:event_shortcut_new_weibo];
    [KDEventAnalysis eventCountly:event_shortcut_new_weibo];
    [self hideAddMenuWithAnimate:NO];
    //    [self swipeToDisCoveryViewController];
    [self pushToWeiboViewControler];
}

- (void)swipeToDisCoveryViewController{
    KDWeiboAppDelegate *delegate =  (KDWeiboAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.tabBarController setSelectedIndex:2];
}

- (void)pushToWeiboViewControler{
    //    KDWeiboAppDelegate *delegate =  (KDWeiboAppDelegate *)[UIApplication sharedApplication].delegate;
    //    UINavigationController *navcontroller = [delegate.tabBarController.viewControllers objectAtIndex:2];
    //    KDDiscoveryViewController *controller = (KDDiscoveryViewController *)navcontroller.topViewController;
    //    KDMainTimelineViewController *mainTimelineViewController = [[KDMainTimelineViewController alloc] init];
    //    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:mainTimelineViewController animated:YES completion:nil];;
    //
    [self pushToPostViewController];
}

- (void)pushToPostViewController{
    PostViewController *pvc = [[PostViewController alloc] init] ;
    pvc.isSelectRange = YES;
    pvc.draft = [KDDraft draftWithType:KDDraftTypeNewStatus];
    [KDWeiboAppDelegate setExtendedLayout:pvc];
    [[KDDefaultViewControllerContext defaultViewControllerContext] showPostViewController:pvc];
}

- (void)scrollToTopInTableView{
    [self.groupTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark - KDLoginPwdConfirmDelegate methods
- (void)authViewConfirmPwd
{
    [self.navigationController popToViewController:self animated:YES];
}
- (void)finishBindEmail
{
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark -
#pragma mark 分页请求的方法
-(void)getGroupListBothType{
    if ([[KDTimelineManager shareManager] shouldStarPagingRequest]) {
        self.isFirstPage = YES;
        [self starPageRequestForGroupList];
    }
    else{
        [self getGroupList];
    }
}
-(void)starPageRequestForGroupList{
    
    if(_progressView)
    {
        [self.progressView setProgress:0.99f animated:NO];
        self.progressView.tipLabel.text = @"更新群组数据中...";
    }
    
    self.isGetGroupList = YES;
    if (self.pageRequestClient == nil) {
        self.pageRequestClient = [[ContactClient alloc]initWithTarget:self action:@selector(getPageRequstGroupListDidReceived:result:)];
    }
    [self.pageRequestClient getGroupListWithUpdateTime:nil offset:[[KDTimelineManager shareManager]numberOfPages] count:kPageRequstCount];
}

- (void)getPageRequstGroupListDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    
    if (result.success && result.data)
    {
        
        GroupListDataModel *groupListDM = [[GroupListDataModel alloc] initWithDictionary:result.data];
        
        //第一次把relateUpdateScore塞进去数据库
        __block NSMutableArray *listArray = [NSMutableArray new];
        NSInteger relateUpdateScore = [[[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"lastUpdateScore_%@_%@",[BOSConfig sharedConfig].user.orgId,[BOSConfig sharedConfig].user.userId]] integerValue];
        [groupListDM.list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GroupDataModel *group = [groupListDM.list objectAtIndex:idx];
            group.localUpdateScore = relateUpdateScore;
            [listArray addObject:group];
            
        }];
        groupListDM.list = listArray;
        
        if ([groupListDM.list count] > 0)
        {
            self.pageRequestOffset  = self.pageRequestOffset + [groupListDM count];
            [[KDTimelineManager shareManager]setNumberOfPages:self.pageRequestOffset];
            //更新数据库 GroupDataModel
            if (self.isFirstPage) {
                self.isFirstPage = NO;
                //更新updateTime
                [[XTSetting sharedSetting] setUpdateTime:groupListDM.updateTime];
                [[XTSetting sharedSetting] saveSetting];
                [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePrivateGroupList:groupListDM];
                
                [self reloadGroupTable];
            }
            else{
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePrivateGroupList:groupListDM];
                    
                });
            }
            if (groupListDM.more) {
                [self starPageRequestForGroupList];
            }
            else{
                self.isGetGroupList = NO;
                [[KDTimelineManager shareManager]setFinishPageRequest];
                [self reloadGroupTable];
                [self.backView removeFromSuperview];
                //预防在拉取过程中有来新消息
                [self getGroupList];
            }
        }
        //第一次激活人员时无数据 但是当第一次聊天以后更新数据时继续走starPageRequestForGroupList方法
        else
        {
            self.isGetGroupList = NO;
            [[KDTimelineManager shareManager]setFinishPageRequest];
            [self reloadGroupTable];
            [self.backView removeFromSuperview];
            //预防在拉取过程中有来新消息
            [self getGroupList];
            
            [[XTSetting sharedSetting] setUpdateTime:groupListDM.updateTime];
            [[XTSetting sharedSetting] saveSetting];
        }
    }
}


#pragma mark - 公共号代言人

-(void)pubGroupList:(NSString *)personId
{
    if (_pubaccClient == nil) {
        _pubaccClient = [[ContactClient alloc] initWithTarget:self action:@selector(publicGroupListDidReceived:result:)];
    }
    [_pubaccClient publicGroupList:personId updateTime:[[XTSetting sharedSetting].pubAccountsUpdateTimeDict objectForKey:personId]];
    [self.hud setLabelText:ASLocalizedString(@"KDSubscribeViewController_Load")];
    [self.hud show:YES];
}

- (void)publicGroupListDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    [self.hud hide:YES];
    if (result.success && result.data) {
        GroupListDataModel *groupList = [[GroupListDataModel alloc] initWithDictionary:result.data];
        //更新updateTime
        if (![groupList.updateTime isEqualToString:@""]) {
            [[XTSetting sharedSetting].pubAccountsUpdateTimeDict setObject:groupList.updateTime forKey:self.publicAccount.personId];
        }
        [[XTSetting sharedSetting] saveSetting];
        if ([groupList.list count] > 0)
        {
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePublicGroupList:groupList withPublicId:self.publicAccount.personId];
        }
        //管理员，打开消息页面
        PubAccountDataModel *publAccountDataModel = [[PubAccountDataModel alloc] init];
        publAccountDataModel.publicId = self.publicAccount.personId;
        publAccountDataModel.name = self.publicAccount.personName;
        XTPubAcctUserChatListViewController *publicTimelineViewController = [[XTPubAcctUserChatListViewController alloc] initWithPubAccount2:publAccountDataModel andPerson:self.publicAccount];
        [self.navigationController pushViewController:publicTimelineViewController animated:YES];
    }
    else
    {
        self.bBackFromGroupChat = self.selectGroup.participant.count > 1;
        [self toChatViewControllerWithGroup:self.selectGroup withMsgId:nil];
    }
}

- (NSMutableArray *)mArrayPublicAndGroups
{
    if (!_mArrayPublicAndGroups)
    {
        _mArrayPublicAndGroups = [[NSMutableArray alloc]init];
    }
    return _mArrayPublicAndGroups;
}


// 代办蒙版

- (UIImageView *)imageViewTodoFilter
{
    if (!_imageViewTodoFilter)
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:isAboveiPhone5 ?  CGRectFullScreenWithoutNavigationBar : CGRectMake(0,  0 , ScreenFullWidth, ScreenFullHeight)];
        imageView.image = [UIImage imageNamed:@"message_img_newuser"];
        [imageView sizeToFit];
        _imageViewTodoFilter = imageView;
        [_imageViewTodoFilter addSubview:self.buttonTodoFilterConfirm];
        _imageViewTodoFilter.userInteractionEnabled = YES;
        
    }
    return _imageViewTodoFilter;
}

- (void)buttonTodoFilterConfirmPressed
{
    self.imageViewTodoFilter.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MASK_TODO_SHOW"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIButton *)buttonTodoFilterConfirm
{
    if (!_buttonTodoFilterConfirm)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:ASLocalizedString(@"KDApplicationViewController_tips_i_know")forState:UIControlStateNormal];
        [button setBackgroundColor:BOSCOLORWITHRGBA(0x1A85FF,1.0)];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [button.titleLabel setTextColor:[UIColor whiteColor]];
        [button setFrame:CGRectMake(72, ScreenFullWidth, CGRectGetWidth(self.view.frame), 44)];
        button.layer.cornerRadius = 5.0f;
        [button addTarget:self action:@selector(buttonTodoFilterConfirmPressed) forControlEvents:UIControlEventTouchUpInside];
        _buttonTodoFilterConfirm = button;
    }
    return _buttonTodoFilterConfirm;
}




#pragma mark - 左滑菜单 -

#define RightButtonTitleTop ASLocalizedString(@"XTTimelineViewController_Top")
#define RightButtonTitleDelete ASLocalizedString(@"KDCommentCell_delete")
#define RightButtonTitleMarkRead ASLocalizedString(@"XTTimelineViewController_Read")
#define RightButtonIconTop @"timeline_utility_top"
#define RightButtonIconDown @"timeline_utility_down"
#define RightButtonIconTrashcan @"timeline_utility_trashcan"
#define RightButtonIconEmailOpen @"timeline_utility_email_open"
#pragma mark - 左滑菜单 -
- (NSArray *)rightButtonsWithFoldPublicDataModel:(FoldPublicDataModel *)model {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    //    [rightUtilityButtons sw_addUtilityButtonWithColor:
    //     UIColorFromRGB(0x929BA5)
    //                                                title:self.isTopForFoldPublic ? ASLocalizedString(@"XTTimelineViewController_Top_Cancel"): ASLocalizedString(@"XTTimelineViewController_Top")];
    
    // 折叠的公众号只显示标为已读
    if (model.unreadCount > 0)
    {
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         UIColorFromRGB(0xf7bf28)
                                                    title:ASLocalizedString(@"XTTimelineViewController_Read")];
    }
    
    return rightUtilityButtons;
}
- (NSArray *)rightButtonsWithGroupDataModel:(GroupDataModel *)model
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     UIColorFromRGB(0x929BA5)
                                                title:model.isTop ? ASLocalizedString(@"XTTimelineViewController_Top_Cancel"): ASLocalizedString(@"XTTimelineViewController_Top")];
    
    if (model.unreadCount > 0) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         UIColorFromRGB(0xf7bf28)
                                                    title:ASLocalizedString(@"XTTimelineViewController_Read")];
    }
    
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     UIColorFromRGB(0xF35959)
                                                title:ASLocalizedString(@"KDCommentCell_delete")];
    
    return rightUtilityButtons;
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    // 如果是代办的cell, 则不可删除
    GroupDataModel *tododm;
    int iTodoIndex;
    NSIndexPath *indexPath = [self.groupTableView indexPathForCell:cell];
    for (id obj in [self.mArrayPublicAndGroups copy]) {
        
        if ([obj isKindOfClass:[GroupDataModel class]]) {
            GroupDataModel *dm = obj;
            if (dm.participant.count > 0) {
                if ([[dm.participant[0] personId] isEqualToString:kTodoPersonId]) {
                    tododm = dm;
                    iTodoIndex = (int) [self.mArrayPublicAndGroups indexOfObject:dm];
                }
            }
        }
    }
    if (tododm && indexPath.row == iTodoIndex) {
        return NO;
    }
    
    //     如果是折叠公共号(订阅消息)
    if ([self.mArrayPublicAndGroups indexOfObject:self.publicDataModel] == indexPath.row) {
        return YES;
    }
    
    return YES;
    
}

// 点击左滑按钮
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.groupTableView indexPathForCell:cell];
    int row = (int) indexPath.row;
    id obj = self.mArrayPublicAndGroups[row];
    
    if ([obj isKindOfClass:[FoldPublicDataModel class]])
    {
        switch (index) {
                //            case 0: {
                //                // 置顶
                //
                //                if (self.isTopForFoldPublic == YES)
                //                {
                //                    self.isTopForFoldPublic = NO;
                //                    [KDEventAnalysis event:event_session_top_cancel];
                //                }
                //                else
                //                {
                //                    self.isTopForFoldPublic = YES;
                //                    [KDEventAnalysis event:event_session_top_set];
                //                }
                //            }
                //                break;
                
            case 0: {
                
                // XTTimelineViewController_Read
                [XTSetting sharedSetting].foldPublicAccountPressed = YES;
                [[XTSetting sharedSetting] saveSetting];
                
            }
                break;
                
            default:
                break;
        }
        
        [cell hideUtilityButtonsAnimated:YES];
        [self reloadGroupTable];
    }
    else
    {
        GroupDataModel *group = obj;
        if (group.unreadCount > 0) {
            switch (index) {
                case 0: {
                    // 置顶
                    
                    if (self.toggleGroupTopClient == nil) {
                        self.toggleGroupTopClient = [[ContactClient alloc] initWithTarget:self action:@selector(toggleGroupTopDidReceived:result:)];
                    }
                    
                    NSIndexPath *indexPath = [self.groupTableView indexPathForCell:cell];
                    int row = (int) indexPath.row;
                    id obj = self.mArrayPublicAndGroups[row];
                    GroupDataModel *group = obj;
                    self.targetGroup = group;
                    NSString *groupId = group.groupId;
                    
                    if (group.isTop) {
                        [KDEventAnalysis event:event_session_top_cancel];
                    } else {
                        [KDEventAnalysis event:event_session_top_set];
                    }
                    [self.toggleGroupTopClient toggleGroupTopWithGroupId:groupId status:!group.isTop];
                    
                }
                    break;
                    
                case  2: {
                    // 删除
                    
                    NSIndexPath *indexPath = [self.groupTableView indexPathForCell:cell];
                    
                    int row = (int) indexPath.row;
                    
                    id obj = self.mArrayPublicAndGroups[row];
                    
                    if ([obj isKindOfClass:[FoldPublicDataModel class]]) {
                        [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllFoldPublicGroup];
                        self.publicDataModel = nil;
                    }
                    
                    if ([obj isKindOfClass:[GroupDataModel class]]) {
                        GroupDataModel *group = obj;
                        NSString *groupId = group.groupId;
                        [self.groups removeObject:group];
                        if ([[XTDataBaseDao sharedDatabaseDaoInstance] setPrivateGroupListToDeleteWithGroupId:groupId]) {
                            [[XTDeleteService shareService] deleteGroupWithGroupId:groupId];
                            
                            if (group.groupType == GroupTypeDouble) {
                                [[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecentlyContact:group.participantIds];
                            }
                        }
                        [self exitRunningAgoraWhenDeleteGroup:group];
                    }
                    
                    [self.mArrayPublicAndGroups removeObject:obj];
                    [self.groupTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self reloadGroupTable];
                }
                    break;
                    
                case 1: {
                    
                    // 标为已读
                    
                    [KDEventAnalysis event:event_session_settings_markread];
                    if (self.markAllMsgClient == nil) {
                        self.markAllMsgClient = [[ContactClient alloc] initWithTarget:self action:@selector(markAllReadDidReceived:result:)];
                    }
                    
                    NSIndexPath *indexPath = [self.groupTableView indexPathForCell:cell];
                    int row = (int) indexPath.row;
                    id obj = self.mArrayPublicAndGroups[row];
                    GroupDataModel *group = obj;
                    NSString *groupId = group.groupId;
                    self.targetGroup = group;
                    [KDEventAnalysis event:event_session_mark_read];
                    [self.markAllMsgClient markAllReadWithGroupID:groupId];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
        
        else {
            switch (index) {
                case 0: {
                    // 置顶
                    
                    if (self.toggleGroupTopClient == nil) {
                        self.toggleGroupTopClient = [[ContactClient alloc] initWithTarget:self action:@selector(toggleGroupTopDidReceived:result:)];
                    }
                    
                    NSIndexPath *indexPath = [self.groupTableView indexPathForCell:cell];
                    int row = (int) indexPath.row;
                    id obj = self.mArrayPublicAndGroups[row];
                    GroupDataModel *group = obj;
                    self.targetGroup = group;
                    NSString *groupId = group.groupId;
                    if (group.isTop) {
                        [KDEventAnalysis event:event_session_top_cancel];
                    } else {
                        [KDEventAnalysis event:event_session_top_set];
                    }
                    [self.toggleGroupTopClient toggleGroupTopWithGroupId:groupId status:!group.isTop];
                }
                    break;
                    
                case  1: {
                    // 删除
                    
                    NSIndexPath *indexPath = [self.groupTableView indexPathForCell:cell];
                    
                    int row = (int) indexPath.row;
                    
                    id obj = self.mArrayPublicAndGroups[row];
                    
                    if ([obj isKindOfClass:[FoldPublicDataModel class]]) {
                        [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllFoldPublicGroup];
                        self.publicDataModel = nil;
                    }
                    
                    if ([obj isKindOfClass:[GroupDataModel class]]) {
                        GroupDataModel *group = obj;
                        NSString *groupId = group.groupId;
                        [self.groups removeObject:group];
                        if ([[XTDataBaseDao sharedDatabaseDaoInstance] setPrivateGroupListToDeleteWithGroupId:groupId]) {
                            [[XTDeleteService shareService] deleteGroupWithGroupId:groupId];
                            
                            if (group.groupType == GroupTypeDouble) {
                                [[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecentlyContact:group.participantIds];
                            }
                        }
                    }
                    
                    [self.mArrayPublicAndGroups removeObject:obj];
                    [self.groupTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                    break;
                    
                    
                default:
                    break;
            }
            
            
        }
        
        [cell hideUtilityButtonsAnimated:YES];
    }
    
}
//如果当前组正在进行的语音会议  则退出
- (void)exitRunningAgoraWhenDeleteGroup:(GroupDataModel *)group{
    if (group.mCallStatus == 1){
        KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
        if (agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel && [agoraSDKManager.currentGroupDataModel.groupId isEqualToString:group.groupId]) {
            [[KDAgoraSDKManager sharedAgoraSDKManager] leaveChannel];
            if(self.bShowVoiceBanner)
            {
                self.bShowVoiceBanner = NO;
                [self.groupTableView reloadData];
            }
        }
    }
}
//    {
//        switch (index)
//        {
//            case 0:
//            {
//                // 置顶
//
////                if (self.toggleGroupTopClient == nil)
////                {
////                    self.toggleGroupTopClient = [[ContactClient alloc] initWithTarget:self action:@selector(toggleGroupTopDidReceived:result:)];
////                }
////                GroupDataModel *group = obj;
////                self.targetGroup = group;
////                NSString *groupId = group.groupId;
////                [self.toggleGroupTopClient toggleGroupTopWithGroupId:groupId status:!group.isTop];
//                NSIndexPath *indexPath = [self.groupTableView indexPathForCell:cell];
//                int row = (int) indexPath.row;
//                id obj = self.mArrayPublicAndGroups[row];
//                GroupDataModel *group = obj;
//                self.targetGroup = group;
//                NSString *groupId = group.groupId;
//
//                if (group.isTop) {
//                    [KDEventAnalysis event:event_session_top_cancel];
//                } else {
//                    [KDEventAnalysis event:event_session_top_set];
//                }
//                [self.toggleGroupTopClient toggleGroupTopWithGroupId:groupId status:!group.isTop];
//            }
//                break;
//
//            case 2:
//            {
//                // 删除
//
//
//                if ([obj isKindOfClass:[FoldPublicDataModel class]])
//                {
//                    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllFoldPublicGroup];
//                    self.publicDataModel = nil;
//                }
//
//                if ([obj isKindOfClass:[GroupDataModel class]])
//                {
//                    GroupDataModel *group = obj;
//                    NSString *groupId = group.groupId;
//                    [self.groups removeObject:group];
//                    if ([[XTDataBaseDao sharedDatabaseDaoInstance] setPrivateGroupListToDeleteWithGroupId:groupId])
//                    {
//                        [[XTDeleteService shareService] deleteGroupWithGroupId:groupId];
//
//                        if(group.groupType == GroupTypeDouble)
//                        {
//                            [[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecentlyContact:[group.participant valueForKeyPath:@"personId"]];
//                        }
//                    }
//                }
//
//                [self.mArrayPublicAndGroups removeObject:obj];
//                [self.groupTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            }
//                break;
//
//            case 1:
//            {
//
//                // 标为已读
//
//                [KDEventAnalysis event:event_session_settings_markread];
//                if (self.markAllMsgClient == nil) {
//                    self.markAllMsgClient = [[ContactClient alloc] initWithTarget:self action:@selector(markAllReadDidReceived:result:)];
//                }
//
//                GroupDataModel *group = obj;
//                NSString *groupId = group.groupId;
//                self.targetGroup = group;
//                [self.markAllMsgClient markAllReadWithGroupID:groupId];
//            }
//                break;
//
//            default:
//                break;
//        }
//    }
//    else
//    {
//        switch (index)
//        {
//            case 0:
//            {
//                // 置顶
//
//                if (self.toggleGroupTopClient == nil)
//                {
//                    self.toggleGroupTopClient = [[ContactClient alloc] initWithTarget:self action:@selector(toggleGroupTopDidReceived:result:)];
//                }
//                GroupDataModel *group = obj;
//                self.targetGroup = group;
//                NSString *groupId = group.groupId;
//                [self.toggleGroupTopClient toggleGroupTopWithGroupId:groupId status:!group.isTop];
//            }
//                break;
//
//            case 1:
//            {
//                // 删除
//
//
//                if ([obj isKindOfClass:[FoldPublicDataModel class]])
//                {
//                    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllFoldPublicGroup];
//                    self.publicDataModel = nil;
//                }
//
//                if ([obj isKindOfClass:[GroupDataModel class]])
//                {
//                    GroupDataModel *group = obj;
//                    NSString *groupId = group.groupId;
//                    [self.groups removeObject:group];
//                    if ([[XTDataBaseDao sharedDatabaseDaoInstance] setPrivateGroupListToDeleteWithGroupId:groupId])
//                    {
//                        [[XTDeleteService shareService] deleteGroupWithGroupId:groupId];
//
//                        if(group.groupType == GroupTypeDouble)
//                        {
//                            [[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecentlyContact:[group.participant valueForKeyPath:@"personId"]];
//                        }
//                    }
//                }
//
//                [self.mArrayPublicAndGroups removeObject:obj];
//                [self.groupTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            }
//                break;
//            default:
//                break;
//        }
//    }
//
//    [cell hideUtilityButtonsAnimated:YES];
//
//}

- (void)markAllReadDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"XTTimelineViewController_Read_Fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    [[XTDataBaseDao sharedDatabaseDaoInstance] updateAllRecordsToReadWithGroup:self.targetGroup];
    self.markAllMsgClient = nil;
    [self reloadGroupTable];
}

- (void)toggleGroupTopDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"XTTimelineViewController_Top_Fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return;
    }
    [self.targetGroup toggleTop];
    
    [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithStatus:self.targetGroup.status withGroupId:self.targetGroup.groupId];
    
    self.toggleGroupTopClient = nil;
    
    [self reloadGroupTable];
    
}
#pragma mark - FoldPublicOrder
- (NSMutableArray *)sortFoldPublicWhenIsTop:(NSMutableArray *)tempArray
{
    __block NSUInteger theLocation = 0;
    __block BOOL findOrNot = NO;
    [tempArray enumerateObjectsUsingBlock:^(GroupDataModel *model, NSUInteger i, BOOL *stop)
     {
         if (model.status == 7)
         {
             //             NSLog(@"yes publicDataModel.latestMessageTime = %@, groupDataModel.latestMessageTime = %@, status = %d, groupName = %@", self.publicDataModel.latestMessageTime, model.lastMsgSendTime, model.status, model.groupName);
             if ([self.publicDataModel.latestMessageTime compare:model.lastMsgSendTime] == NSOrderedAscending)
             {
                 findOrNot = YES;
                 theLocation = i;
                 stop = YES;
             }
         }
     }];
    if (findOrNot == YES)
    {
        //        NSLog(@"theLocation = %d", theLocation);
        [tempArray insertObject:self.publicDataModel atIndex:theLocation];
    }
    else
    {
        [tempArray insertObject:self.publicDataModel atIndex:0];
    }
    return tempArray;
}

- (NSMutableArray *)sortFoldPublicWhenIsNotTop:(NSMutableArray *)tempArray
{
    __block NSUInteger theLocation = 0;
    __block BOOL findOrNot = NO;
    [tempArray enumerateObjectsUsingBlock:^(GroupDataModel *model, NSUInteger i, BOOL *stop)
     {
         if (model.status != 7)
         {
             //            NSLog(@"no publicDataModel.latestMessageTime = %@, groupDataModel.latestMessageTime = %@, status = %d, groupName = %@", self.publicDataModel.latestMessageTime, model.lastMsgSendTime, model.status, model.groupName);
             if ([self.publicDataModel.latestMessageTime compare:model.lastMsgSendTime] == NSOrderedAscending)
             {
                 findOrNot = YES;
                 theLocation = i;
                 stop = YES;
             }
         }
     }];
    //    if (findOrNot == YES)
    //    {
    //        NSLog(@"theLocation = %d", theLocation);
    //        [tempArray insertObject:self.publicDataModel atIndex:theLocation];
    //    }
    //    else
    //    {
    [tempArray insertObject:self.publicDataModel atIndex:0];
    //    }
    return tempArray;
}
#pragma mark - 网络连接不可用
- (KDNetworkDisconnectView *)networkDisconnectView{
    if (!_networkDisconnectView) {
        _networkDisconnectView = [[KDNetworkDisconnectView alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth, 35)];
    }
    return _networkDisconnectView;
}

- (void)setNetworkConnectStatus:(NSNotification *)info{
    if ([info.userInfo[KDReachabilityStatusKey] intValue] > 0) {
        self.title = ASLocalizedString(@"XTTimelineViewController_Msg");
    }else{
        self.title = ASLocalizedString(@"XTTimelineViewController_Msg_Notconnect");
    }
    self.networkStatus = [KDReachabilityManager sharedManager].reachabilityStatus;
    [self reloadAllData];
}

- (void)showMultiCallViewWithGroupDataModel:(GroupDataModel *)groupDataModel
{
    __weak __typeof(self) weakSelf = self;
    
    if(![self.tabBarController.view viewWithTag:KDAgoraCallViewTag])
    {
        
        __block  KDAgoraCallView *agoraCallView = [[KDAgoraCallView alloc] initWithFrame:self.tabBarController.view.bounds];
        agoraCallView.tag = KDAgoraCallViewTag;
        [agoraCallView setGroupDataModel:groupDataModel];
        agoraCallView.agoraCallViewBlock = ^(agoraCallViewOperationType type){
            if(type == agoraCallViewOperationType_answer)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AgoraCallViewAnswer" object:nil];
                if(weakSelf.queryGroupInfoClient == nil)
                {
                    weakSelf.queryGroupInfoClient = [[ContactClient alloc] initWithTarget:self action:@selector(queryGroupInfoClientDidReceive:result:)];
                }
                [weakSelf.queryGroupInfoClient queryGroupInfoWithGroupId:groupDataModel.groupId];
            }
            [agoraCallView removeFromSuperview];
            agoraCallView = nil;
        };
        [self.tabBarController.view addSubview:agoraCallView];
    }
}

- (void)judgeGroupDateOver
{
    if([[KDApplicationQueryAppsHelper shareHelper]getGroupTalkStatus])
    {
        KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
        if(agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel)
        {
            GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:agoraSDKManager.currentGroupDataModel.groupId];
            if(group)
            {
                if(![group chatAvailable])
                {
                    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
                    
                    if(agoraSDKManager.currentGroupDataModel && agoraSDKManager.currentGroupDataModel.groupId){
                        [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraMessageQuitChannelNotification object:self userInfo:@{@"status":@(NO),@"groupId":(agoraSDKManager.currentGroupDataModel && agoraSDKManager.currentGroupDataModel.groupId) ? agoraSDKManager.currentGroupDataModel.groupId : @""}];
                    }
                    
                    
                    if(agoraSDKManager.agoraPersonsChangeBlock)
                    {
                        agoraSDKManager.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_needExitChannel,nil,nil,nil);
                    }
                    if(self.bShowVoiceBanner)
                    {
                        self.bShowVoiceBanner = NO;
                        [self reloadAllData];
                    }
                    [agoraSDKManager leaveChannel];
                    [agoraSDKManager agoraLogout];
                }else if([group chatAvailable] && group.mCallStatus == 0)
                {
                    //当前的会议已经关闭
                    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
                    
                    if(agoraSDKManager.currentGroupDataModel && agoraSDKManager.currentGroupDataModel.groupId){
                        [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraMessageQuitChannelNotification object:self userInfo:@{@"status":@(NO),@"groupId":(agoraSDKManager.currentGroupDataModel && agoraSDKManager.currentGroupDataModel.groupId) ? agoraSDKManager.currentGroupDataModel.groupId : @""}];
                    }
                    
                    
                    
                    if(agoraSDKManager.agoraPersonsChangeBlock)
                    {
                        agoraSDKManager.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_needExitChannel,nil,nil,nil);
                    }
                    if(self.bShowVoiceBanner)
                    {
                        self.bShowVoiceBanner = NO;
                        [self reloadAllData];
                    }
                    [agoraSDKManager leaveChannel];
                    [agoraSDKManager agoraLogout];
                }
            }
        }
    }
}


#pragma mark - 【装饰物】语音会议横幅 -

//电话会议提示
- (KDMultipartyCallBannerView *)multipartyCallBannerView
{
    if (!_multipartyCallBannerView)
    {
        _multipartyCallBannerView = [[KDMultipartyCallBannerView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, ScreenFullWidth, 35)];
        _multipartyCallBannerView.labelTitle.text = ASLocalizedString(@"XTTimelineViewController_Meet");
        __weak __typeof(self) weakSelf = self;
        _multipartyCallBannerView.blockButtonConfirmPressed = ^()
        {
            [weakSelf goToMultiVoice];
        };
        _multipartyCallBannerView.hidden = NO;
    }
    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
    if(agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel)
    {
        _multipartyCallBannerView.labelTitle.text = [NSString stringWithFormat: ASLocalizedString(@"XTTimelineViewController_Meetting"),agoraSDKManager.currentGroupDataModel.groupName];
    }else{
        _multipartyCallBannerView.labelTitle.text = ASLocalizedString(@"XTTimelineViewController_Meet");
    }
    return _multipartyCallBannerView;
}

// 横幅点击事件
-(void)goToMultiVoice
{
    [[KDAgoraSDKManager sharedAgoraSDKManager] goToMultiVoiceWithGroup:nil viewController:self];
}

- (void)agoraMultiVoiceStatusChangeNotification:(NSNotification *)notification
{
    NSDictionary *userInfo =  notification.userInfo;
    if(userInfo)
    {
        id status = userInfo[@"status"];
        if(status)
        {
            BOOL statusFlag = [status boolValue];
            if(statusFlag)
            {
                if(!self.bShowVoiceBanner)
                {
                    [self showVoiceBanner];
                }
            }
            else
            {
                if(self.bShowVoiceBanner)
                {
                    self.bShowVoiceBanner = NO;
                    [self.groupTableView reloadData];
                }
            }
        }
    }
    
}

- (void)showVoiceBanner
{
    self.bShowVoiceBanner = YES;
    [self reloadAllData];
}

- (void)queryGroupInfoClientDidReceive:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (result.success && result.data)
    {
        GroupDataModel *groupDataModel = [[GroupDataModel alloc] initWithDictionary:result.data];
        if(groupDataModel)
        {
            GroupListDataModel *groupListDataModel = [[GroupListDataModel alloc] init];
            groupListDataModel.list = [[NSMutableArray alloc] initWithObjects:groupDataModel, nil];
            if (groupDataModel.dissolveDate.length == 0) {
                [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePrivateGroupList:groupListDataModel];
            }
            
            if(groupDataModel && groupDataModel.mCallStatus == 1)
            {
                [[KDAgoraSDKManager sharedAgoraSDKManager] goToMultiVoiceWithGroup:groupDataModel viewController:self];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"XTChatViewController_Tip_32")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
                [alert show];
            }
        }
    }
    
}

/**
 *  已经退出群组
 */
- (void)receivedExitGroupNotification:(NSNotification *)notification {
    if (self.isFirstReload) {
        return;
    }
    
    //群组被解散或退出时 干掉悬浮窗
    if (!self.multipartyCallBannerView.hidden) {
        NSString * Ids = [KDAgoraSDKManager sharedAgoraSDKManager].currentGroupDataModel.groupId;
        if (Ids) {
            GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:Ids];
            if (group.status == 0) {
                [[KDAgoraSDKManager sharedAgoraSDKManager] leaveChannel];
                [[KDAgoraSDKManager sharedAgoraSDKManager] agoraLogout];
            }
        }
    }
    
    [self reloadGroupTable];
    
    GroupDataModel *currentChatGroup = [KDWeiboAppDelegate getAppDelegate].activeChatViewController.group;
    //    // 退出群组后，会把group的状态置0
    //    if (currentChatGroup.status == 0) {
    //        return;
    //    }
    // 仅多人会话才有退出、解散群逻辑
    if (currentChatGroup && currentChatGroup.groupType != GroupTypeMany) {
        return;
    }
    
    __block BOOL isCurrentGroupId = NO;
    __block BOOL isDissolve = NO;
    NSArray *groupExitList = notification.object;
    [groupExitList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id groupId = [obj objectForKey:@"groupId"];
        if ([currentChatGroup.groupId isEqualToString:groupId]) {
            isCurrentGroupId = YES;
            isDissolve = [[obj objectForKey:@"isDissolve"] boolValue];
            *stop = YES;
        }
    }];
    
    if (isCurrentGroupId && isDissolve && ![currentChatGroup isManager]) {
        if ([self.navigationController.viewControllers count] > 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"Group_dissolved") delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure") otherButtonTitles:nil, nil];
            alert.tag = 9999;
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 9999 && buttonIndex == 0) {
        NSArray *vcArray = self.navigationController.viewControllers;
        [vcArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIViewController *vc = (UIViewController *)vc;
            if (vc.presentedViewController) {
                [vc dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        if (self.navigationController.presentedViewController) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)hasMessageDelete:(NSNotification *)noti {
    if (!self.hasDelMsgClient) {
        self.hasDelMsgClient = [[ContactClient alloc]initWithTarget:self action:@selector(hasMsgDelDidReceive:result:)];
    }
    
    if ([XTSetting sharedSetting].msgLastDelUpdateTime != nil && [XTSetting sharedSetting].msgLastDelUpdateTime.length > 0) {
        [self.hasDelMsgClient hasDelMsgWithLastUpdateTime:[XTSetting sharedSetting].msgLastDelUpdateTime];
    } else {
        [self.hasDelMsgClient hasDelMsgWithLastUpdateTime:@""];
    }
}

- (void)hasMsgDelDidReceive:(ContactClient *)client result:(BOSResultDataModel *)result {
    if (!client.hasError && [result isKindOfClass:[BOSResultDataModel class]] && result.success && result.data) {
        HasMsgDelDateModel *model = [[HasMsgDelDateModel alloc]initWithDictionary:result.data];
        //成功后记录更新时间
        if (model.msgLastDelUpdateTime != nil && model.msgLastDelUpdateTime.length > 0) {
            [XTSetting sharedSetting].msgLastDelUpdateTime = model.msgLastDelUpdateTime;
            [[XTSetting sharedSetting] saveSetting];
        }
        if ([model.list count] > 0) {
            [model.list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DeleteMsgDateModel *deleteModel = (DeleteMsgDateModel*) obj;
                [[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecordWithMsgId:deleteModel.msgId];
                [[XTDataBaseDao sharedDatabaseDaoInstance] deleteToDoDataWithMsgId:deleteModel.msgId];
            }];
            
            
            // 有公共号消息被删除，刷新聊天界面
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePublicChatMessageList" object:model.list];
        }
        
        // 刷新代办数据，更新代办ID
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTodoDataAndUndoMsg" object:@{@"list": model.list, @"needDelUndoMsgIds": model.needDelUndoMsgIds}];
        
        //zgbin:更新的代办ID
        if ([model.needDelUndoMsgIds count] > 0) {
            [model.needDelUndoMsgIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DeleteUndoMsgDateModel *delUndoId = (DeleteUndoMsgDateModel *)obj;
                [[XTDataBaseDao sharedDatabaseDaoInstance] deleteToDoDataWithMsgId:delUndoId.msgId];
            }];
        }
        //end
        
    } else {
        
    }
}

@end

