//
//  KDLeftTeamMenuViewController.m
//  kdweibo
//
//  Created by gordon_wu on 13-11-18.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//
#define ACTIVITY_TAG 555

#import "KDLeftTeamMenuViewController.h"
#import "KDManagerContext.h"
#import "KDWeiboServicesContext.h"
#import "KDDBManager.h"
#import "KDDatabaseHelper.h"
#import "KDManagerContext.h"
#import "KDLeftTitleView.h"
//#import "LeveyTabBarController.h"
#import "ProfileViewController2.h"
#import "KDSearchViewControllerNew.h"
#import "KDCreateTeamViewController.h"
#import "KDSearchTeamViewController.h"
#import "KDTeamRequestHelper.h"
#import "KDTeamPageViewController.h"
#import "KDLeftWorkGroupInfoView.h"
#import "KDTodoListViewController.h"

#import "KDLeftMenuTitleView.h"
#import "KDLeftMenuCell.h"
#import "KDLeftMenuButton.h"
#import "KDLeftMenuBottomView.h"
#import "XTSMSHandle.h"
#import "KDAnimateGuidViewController.h"
#import "XTChatViewController.h"
#import "XTPubAcctUserChatListViewController.h"
#import "ContactLoginDataModel.h"
#import "ContactConfig.h"
#import "BOSConfig.h"
#import "XTOpenConfig.h"
#import "KDInviteColleaguesViewController.h"
#import "KDSettingViewController.h"
#import "KDRecommendViewController.h"

#import "XTOpenSystemClient.h"
#import "CompanyDataModel.h"
#import "MCloudClient.h"
#import "KDCompanyChoseViewController.h"
#import "XTSetting.h"

#import "AppsClient.h"
#import "KDGuideVC.h"
#import "KDWeiboAppDelegate.h"

#import "KDChangeTeamAccountViewController.h"
#import "TeamAccountModel.h"
#define  kKDLeftMenuCellHeight 130.f

typedef NS_ENUM(NSUInteger, MenuTitlesEnum) {
    MenuTitleCreateErp = 0,
    MenuTitleRecommend,
    //    MenuTitleIntroduce,
    //    MenuTitlesFeedback,
    MenuTitleSetting
};


@interface KDLeftTeamMenuViewController () <KDLetfTitleViewDelegate, KDLeftWorkGroupInfoViewDelegate, UITableViewDataSource, UITableViewDelegate, KDLeftMenuCellDelegate, KDLeftMenuTitleViewDelegate, KDAnimateGuidViewDelegate, XTCompanyDelegate>
{
    UINavigationController    *nav_;
    
    
    NSMutableArray             *teamInvitations_;
    
    BOOL                       *isAnimationing_;
    
    KDLeftWorkGroupInfoView    *workGroupInfoView_;
    CGRect                      workGroupInfoViewNormalFrame_;
    
    XTOpenSystemClient *_client;
    
    MCloudClient *_mCloudClient;
    
    struct {
        unsigned int isGettingUser:1;
        unsigned int isGettingCommunity:1;
    }netWorkFlags_;
    
}

@property (nonatomic, strong) KDLeftWorkGroupInfoView *workGroupInfoView;
@property (nonatomic, strong) KDLeftMenuTitleView  * titleView;
@property (nonatomic, strong) NSMutableArray *datasoure;
@property (nonatomic, strong) UITableView *menuTableView;
@property (nonatomic, strong) NSArray *arrayCompanyDataModels;
@property (nonatomic, strong) AppsClient *appsClient;

@property (nonatomic, strong) NSMutableArray *kMenuTitles;
@property (nonatomic, strong) NSMutableArray *kMenuImageNames;
@property (nonatomic, assign) BOOL bIsAdmin;
@property (nonatomic, strong) KDSettingViewController *settingCtr;

@end

@implementation KDLeftTeamMenuViewController
@synthesize user           = user_;
@synthesize titleView      = titleView_;
@synthesize workGroupInfoView = workGroupInfoView_;
#pragma mark -
#pragma mark lifeCycle
- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
        [self initData];
        [self getCurrentUser];
        [self getCommunityData];
        [self getRecommonedURL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishCreateTeam:) name:KDCreateTeamFinishedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishSignOutTeam:) name:KDQuitCompanyFinishedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(companyChanged:) name:kKDCommunityDidChangedNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage:) name:@"changeLanguage" object:nil];
        [[BOSConfig sharedConfig] addObserver:self forKeyPath:@"currentUser" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        
    }
    return self;
}

- (NSMutableArray *)kMenuTitles
{
    if (!_kMenuTitles)
    {
        _kMenuTitles = [[NSMutableArray alloc]init];
    }
    
    [_kMenuTitles setArray:self.hasInvitePermission ?  @[ASLocalizedString(@"KDInviteByPhoneNumberViewController_invite"), ASLocalizedString(@"KDLeftTeamMenuViewController_setting")] : @[ASLocalizedString(@"KDLeftTeamMenuViewController_setting")]];
    
    
    if ([self haveTeamAccount]) {
        [_kMenuTitles insertObject:ASLocalizedString(@"KDLeftTeamMenuViewController_team_account") atIndex:_kMenuTitles.count - 1];
    }
    
    if (self.bIsAdmin && [self isMainUser])
    {
        [_kMenuTitles insertObject:ASLocalizedString(@"KDCreateTeamViewController_create_com")atIndex:0];
    }
    
    return [_kMenuTitles mutableCopy];
}

- (NSMutableArray *)kMenuImageNames
{
    if (!_kMenuImageNames)
    {
        _kMenuImageNames = [[NSMutableArray alloc]init];
    }
    
    [_kMenuImageNames setArray:self.hasInvitePermission ?  @[@"menu_invitation_",@"menu_set_"] : @[@"menu_set_"]];
    
    if ([self haveTeamAccount]) {
        [_kMenuImageNames insertObject:@"menu_switch_" atIndex:_kMenuImageNames.count - 1];
    }
    
    if (self.bIsAdmin && [self isMainUser]){
        [_kMenuImageNames insertObject:@"menu_creat_" atIndex:0];
    }
    
    return [_kMenuImageNames mutableCopy];
}

- (BOOL)haveTeamAccount {
    NSMutableArray *mutbaleArray = [NSMutableArray array];
    NSArray *teamAccount = [BOSConfig sharedConfig].user.teamAccount;
    [teamAccount enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TeamAccountModel *teamAcc = [[TeamAccountModel alloc] initWithDictionary:obj];
        if (teamAcc.status == 1 || teamAcc.status == 3) {
            [mutbaleArray addObject:teamAcc];
        }
    }];
    return [mutbaleArray count];
}

- (BOOL)isMainUser {
    return [[BOSConfig sharedConfig].user.openId isEqualToString:[BOSConfig sharedConfig].mainUser.openId];
}

- (BOOL)bIsAdmin
{
    return [[[BOSConfig sharedConfig]user]isAdmin];
}

- (BOOL)hasInvitePermission
{
    NSString *type = [[BOSSetting sharedSetting] hasInvitePermission];
    // 只有管理员可以邀请
    if ([type isEqualToString:@"0"])
    {
        return [[[BOSConfig sharedConfig]user]isAdmin];
    }
    //所有人可以邀请
    else if ([type isEqualToString:@"1"])
    {
        return YES;
    }
    //所有人不可以
    else
        return NO;
}
- (void)loadView
{
    [super loadView];
    
    //修正iOS7下bug
//    UIImageView *view = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    [view setImage:[UIImage imageNamed:@"menu_bg"]];
    UIImage *image = [UIImage imageNamed:@"menu_bg2"];
    self.view.layer.contents = (id) image.CGImage;
//    [self.view  addSubview: image];
//    [view release];
    
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_bg"]]];
//    [self.view setBackgroundColor:[UIColor grayColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DLog(@"KDLeftTeamMenuViewControllerMemoryWarning");
    
    // Dispose of any resources that can be recreated.
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDCreateTeamFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDProfileUserAvatarUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDTeamInvitationOnceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDNotificationDidReceiveRemoteTeamInviteNotificationKey object:nil];
    
    [[BOSConfig sharedConfig] removeObserver:self forKeyPath:@"currentUser"];
}

#pragma mark -
#pragma mark initData
-(void) initData
{
    
}

/**
 *  初始化头像
 */
- (void)initUser
{
    //    workGroupInfoView_.user = user_;
}
/**
 *  初始化团队
 */
- (void) getCommunityData
{
    //    NSArray *meunLists = [self getUnreadInfoCommunity];
    //    if (meunLists!=0)
    //        [workGroupInfoView_ setGroups:meunLists];
    
    [self fetchNetworkList];
}

- (void)reloadIcons
{
    
    NSString *feedbackTitle = @"";
    
    //管理员显示的是团队名称
    PubAccountDataModel *pubAccount = [[ContactConfig sharedConfig].publicAccountList.list firstObject];
    if (pubAccount.manager) {
        feedbackTitle = pubAccount.name;
    }else {
        feedbackTitle = ASLocalizedString(@"意见反馈");
    }
    
    
    [_datasoure removeAllObjects];
    int count = (int)self.kMenuTitles.count;
    
    for (int i = 0; i < count; i++) {
        KDLeftMenuButtonModel *model = [[KDLeftMenuButtonModel alloc] init];
        model.title = self.kMenuTitles[i];
        if ([self.kMenuTitles[i] isEqual:ASLocalizedString(@"意见反馈")]) {
            model.title = feedbackTitle;
        }
        model.type = i;
        model.normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@normal", [self.kMenuImageNames objectAtIndex: i]]];
        model.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@press", [self.kMenuImageNames objectAtIndex:i]]];
        [_datasoure addObject:model];
    }
    
    [_menuTableView reloadData];
}

#pragma mark -
#pragma mark initComponent
- (void)setup
{
    netWorkFlags_.isGettingCommunity = 0;
    netWorkFlags_.isGettingUser = 0;
    
    CGRect frame  = self.view.bounds;
    CGFloat width = 13;
    if (isAboveiPhone6) {
        width = 0;
    }
    if (isiPhone6Plus) {
        width = -10;
    }
    
    frame.size.width = CGRectGetWidth(self.view.frame) - ScreenFullWidth / 5 + 10 + width;
    frame.size.height = 133;
    
    
    titleView_                 = [[KDLeftMenuTitleView alloc] initWithFrame:frame];
    titleView_.backgroundColor = [UIColor clearColor];
    
    titleView_.delegate = self;
    [self.view addSubview:titleView_];
    
    _datasoure = [NSMutableArray array];
    
    int count = (int)self.kMenuTitles.count;
    
    NSString *feedbackTitle = @"";
    
    //管理员显示的是团队名称
    PubAccountDataModel *pubAccount = [[ContactConfig sharedConfig].publicAccountList.list firstObject];
    if (pubAccount.manager) {
        feedbackTitle = pubAccount.name;
    }else {
        feedbackTitle = ASLocalizedString(@"意见反馈");
    }
    
    for (int i = 0; i < count; i++) {
        KDLeftMenuButtonModel *model = [[KDLeftMenuButtonModel alloc] init];
        model.title = self.kMenuTitles[i];
        if ([self.kMenuTitles[i] isEqual:ASLocalizedString(@"意见反馈")]) {
            model.title = feedbackTitle;
        }
        model.type = i;
        model.normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@normal.png", [self.kMenuImageNames objectAtIndex: i]]];
        model.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@press.png", [self.kMenuImageNames objectAtIndex:i]]];
        [_datasoure addObject:model];
    }
    
    CGFloat marigin = 10.f;
    CGFloat detaHeight = 0.f;
    
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(titleView_.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(titleView_.frame) - marigin - detaHeight)];
    maskView.clipsToBounds = YES;
    [self.view addSubview:maskView];
    
    _menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 20, CGRectGetWidth(self.view.frame) - ScreenFullWidth / 5 , CGRectGetHeight(maskView.frame))];
    _menuTableView.backgroundColor = [UIColor clearColor];
    //    _menuTableView.scrollEnabled = NO;
    _menuTableView.scrollsToTop = NO;
    _menuTableView.delegate = self;
    _menuTableView.dataSource = self;
    [_menuTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [maskView addSubview:_menuTableView];
    
    frame.origin.y  = 0.f;
    
    frame.size.height = CGRectGetHeight(maskView.frame);
    
    workGroupInfoViewNormalFrame_ = frame;
    frame.origin.y -= frame.size.height;
    KDLeftWorkGroupInfoView *workGroupInfoView = [[KDLeftWorkGroupInfoView alloc] initWithFrame:frame];
    workGroupInfoView.delegate = self;
    workGroupInfoView.alpha = 0.0f;
    [maskView addSubview:workGroupInfoView];
    workGroupInfoView_ = workGroupInfoView;
    
    KDLeftMenuBottomView *bottomView = [KDLeftMenuBottomView bottomView];
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [bottomView addTarget:self action:@selector(recommondApp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomView];
    
    workGroupInfoView_.groups = [KDManagerContext globalManagerContext].communityManager.joinedCommpanies;
    [self updateTitlViewTipAnimation];
}

- (void)updateTitlViewTipAnimation
{
    if(workGroupInfoView_.groups.count > 1) {
        self.titleView.shouldShowTipAnimation = YES;
        [self.titleView startTipAnimation];
    }else {
        self.titleView.shouldShowTipAnimation = NO;
        [self.titleView stopTipAnimation];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [self resetDatasource];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [self resetDatasource];
}
- (void)resetDatasource
{
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", kMenuTitles[MenuTitleRecommend]];
    //    if ([self.datasoure filteredArrayUsingPredicate:predicate].count <= 0 && ![[BOSSetting sharedSetting] isIntergrationMode]) {
    //        KDLeftMenuButtonModel *model = [[[KDLeftMenuButtonModel alloc] init] autorelease];
    //        model.title = kMenuTitles[MenuTitleRecommend];
    //        model.type = MenuTitleRecommend;
    //        model.normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@normal.png", kMenuImageNames[MenuTitleRecommend]]];
    //        model.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@press.png", kMenuImageNames[MenuTitleRecommend]]];
    //        [_datasoure insertObject:model atIndex:MenuTitleRecommend];
    //    }
    //    else if([self.datasoure filteredArrayUsingPredicate:predicate].count >0 && [[BOSSetting sharedSetting] isIntergrationMode]){
    //        [_datasoure removeObjectAtIndex:MenuTitleRecommend];
    //    }
    //    [_menuTableView reloadData];
}

- (void)recommondApp:(id)sender
{
    //    NSString *content = [NSString stringWithFormat:ASLocalizedString(@"是一款移动工作平台，挺简单的，推荐你用一下 。点击 %@ 下载手机客户端。"),[BOSSetting sharedSetting].appDownloadURL];
    //    [XTSMSHandle sharedSMSHandle].controller = [KDWeiboAppDelegate getAppDelegate].sideMenuViewController;
    //    [[XTSMSHandle sharedSMSHandle] smsWithContent:content];
    
    KDRecommendViewController *recommmendViewController = [[KDRecommendViewController alloc] init];
    [self zoomInViewController:recommmendViewController];
}

- (void)showRecommendView
{
    //    if ([[BOSSetting sharedSetting] isIntergrationMode]) {
    //        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"温馨提示")message:ASLocalizedString(@"该工作圈由管理员设置为后台维护，不支持移动端邀请操作")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
    //        [alertView show];
    //        [alertView release];
    //        return;
    //    }
    KDInviteColleaguesViewController *contact = [[KDInviteColleaguesViewController alloc] init];
    contact.title = [self.kMenuTitles objectAtIndex: MenuTitleRecommend];
    contact.inviteSource = KDInviteSourceSidebar;
    [self zoomInViewController:contact];
}
- (KDTodoListViewController *)showTodoView
{
    KDTodoListViewController *listController = [[KDTodoListViewController alloc] init];
    [self zoomInViewController:listController];
    
    return listController;
}
- (void)updateDraftTips{
    
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
        
        return [NSNumber numberWithInt:(int)[draftDAO queryAllDraftsCountInDatabase:fmdb]];
        
    } completionBlock:^(id results){
        
        [titleView_ updateDraft:[results integerValue]];
    }];
}
#pragma mark -
#pragma mark initData
- (void)getInvited
{
    KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
    [workGroupInfoView_ setInfoCount:unread.inviteTotal];
}
- (void)getCurrentUser {
    
    KDUser *user = [[[KDManagerContext globalManagerContext] userManager] currentUser];
    
    if (!user) {
        __block KDUser *dbUser = nil;
        NSString *userId = [[[KDManagerContext globalManagerContext] userManager] currentUserId];
        [KDUser syncUserWithId:userId completionBlock:^(KDUser *user){
            dbUser = user;
        }];
        user = dbUser;
    }
    if (!user)
    {
        NSString *userId = [[[KDManagerContext globalManagerContext] userManager] currentUserId];
        [self fetchRemoteCurrentUser:userId];
    }
    else
    {
        self.user = user;
        [self initUser];
    }
}

#pragma mark -
#pragma mark business
- (void)setUser:(KDUser *)user {
    if (user_ != user) {
        user_ = user;
    }
}
/**
 *  获取当前用户
 *
 *  @param userId
 */
- (void)fetchRemoteCurrentUser:(NSString *)userId {
    
    if (netWorkFlags_.isGettingUser) {
        return;
    }
    
    netWorkFlags_.isGettingUser = 1;
    
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:userId];
    
    __block KDLeftTeamMenuViewController *lcvc = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        lcvc.user = results;
        [lcvc initUser];
        // update current user
        [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
            id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
            [userDAO saveUser:(KDUser *)results database:fmdb];
            
            return nil;
            
        } completionBlock:nil];
        
        netWorkFlags_.isGettingUser = 0;
        
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/users/:show" query:query
                                 configBlock:nil completionBlock:completionBlock];
}


/**
 *  获取所有的团队列表
 */
- (void)fetchNetworkList{
    
    if (netWorkFlags_.isGettingCommunity) {
        //        return;
    }
    
    netWorkFlags_.isGettingCommunity = 1;
    
    if (!_client) {
        _client = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getElistReceived:result:)];
    }
    
    [_client elistWithToken:[BOSConfig sharedConfig].user.token];
}

- (void)getElistReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    netWorkFlags_.isGettingCommunity = 0;
    
    if (![result isKindOfClass:[BOSResultDataModel class]] || client.hasError)
    {
        return;
    }
    
    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    
    NSMutableArray *eList = [NSMutableArray array];
    NSArray *currentCommunity = communityManager.joinedCommpanies;
    
    for (NSDictionary * dict in result.data) {
        CompanyDataModel *model = [[CompanyDataModel alloc] initWithDictionary:dict];
        if (model.user.status == 1 || model.user.status == 3) {
            
            [eList addObject:model];
            
            for (CompanyDataModel *cm in currentCommunity) {
                
                if ([cm.eid isEqualToString:model.eid]) {
                    model.unreadCount = cm.unreadCount;
                    model.wbUnreadCount = cm.wbUnreadCount;
                    
                    break;
                }
            }
        }
    }
    
    workGroupInfoView_.groups = eList;
    
    [self updateTitlViewTipAnimation];
    
    communityManager.joinedCommpanies = eList;
    [communityManager storeCompanies];
    [communityManager updateWithCompanies:eList currentDomain:[BOSSetting sharedSetting].cust3gNo];
    self.workGroupInfoView.groups = eList;
}

//获取
- (void)getRecommonedURL
{
    if ([BOSSetting sharedSetting].appDownloadURL.length <= 0) {
        _mCloudClient = [[MCloudClient alloc] initWithTarget:self action:@selector(appInfoDidReceived:result:)];
        [_mCloudClient appInfo];
    }
}

-(void)appInfoDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError) {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (!result.success || result.data == nil || ![result.data isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString *downloadURL = [result.data objectForKey:@"downloadURL"];
    if (downloadURL && ![downloadURL isKindOfClass:[NSNull class]]) {
        [BOSSetting sharedSetting].appDownloadURL = downloadURL;
        [[BOSSetting sharedSetting] saveSetting];
    }
}


- (NSArray *)getUnreadInfoCommunity
{
    KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
    
    BOOL showBadge = NO;
    
    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    
    NSArray *menuLists_ = communityManager.joinedCommunities;
    
    if((menuLists_!=nil)&&([menuLists_ count]>0)){
        
        KDCommunity *currentCommunity = [KDManagerContext globalManagerContext].communityManager.currentCommunity;
        for(int i= 0;i<[menuLists_ count];i++){
            
            KDCommunity * community = (KDCommunity *)[menuLists_ objectAtIndex:i];
            NSInteger badgeValue    = [unread noticeForCommunityId:community.subDomainName];
            community.unreadNum = badgeValue;
            showBadge = (badgeValue > 0) || showBadge;
            if ([community.communityId isEqualToString:currentCommunity.communityId])
                community.unreadNum = unread.directMessages + unread.inboxTotal;
            
        }
    }
    [titleView_ setBadgeViewHidden:!showBadge];
    return menuLists_;
}

- (void)setUpNavigationItemForViewController:(UIViewController *)vc
{
//    UIImage *image = [UIImage imageNamed:@"navigationItem_back"];
//    UIImage *highlightImage = [UIImage imageNamed:@"navigationItem_back"];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setImage:image forState:UIControlStateNormal];
//    [button setImage:highlightImage forState:UIControlStateHighlighted];
//    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//    
//    [button sizeToFit];
//    
//
    UIButton *btn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    vc.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn]];
//    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"Global_GoBack")style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    //song.wang 2013-12-26
//    UIBarButtonItem *negativeSpacer = [[[UIBarButtonItem alloc]
//                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                        target:nil action:nil] autorelease];
//    negativeSpacer.width = 0;
//    vc.navigationItem.leftBarButtonItems = @[leftBarButtonItem];
//    [leftBarButtonItem release];
}

- (void)goBack
{
    //多语言刷新主列表
    [[[UIApplication sharedApplication] keyWindow] resignFirstResponder];
    [self zoomOutViewControoler];
    
    [KDWeiboAppDelegate getAppDelegate].currentTopVC = nil;
//    BOOL show =[[[NSUserDefaults standardUserDefaults] valueForKey:@"refreshMainView"] boolValue];
//    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"refreshMainView"] boolValue]) {
//        [[KDWeiboAppDelegate getAppDelegate] resetMainView];
//        [[NSUserDefaults standardUserDefaults]setValue:@"0" forKey:@"refreshMainView"];
//    }

}


- (void)setSuperViewGestureEnabled:(BOOL)enabled
{
    for(UIGestureRecognizer *gest in self.view.superview.gestureRecognizers) {
        gest.enabled = enabled;
    }
}

- (void)zoomOutViewControoler
{
    if(isAnimationing_) return;
    isAnimationing_ = YES;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if(nav_.view.superview) {
        [UIView animateWithDuration:0.25f animations:^{
            nav_.view.transform = CGAffineTransformMakeScale(0.2, 0.2);
            nav_.view.alpha = 0.0f;
        }completion:^(BOOL finished) {

            if(finished) {
                [nav_.view removeFromSuperview];
                //                nav_.view.frame = CGRectZero;
                //                nav_.view.hidden = YES;
                
                [self setSuperViewGestureEnabled:YES];
                isAnimationing_ = NO;
            }
            
        }];
    }
   

}

- (void)zoomOutViewControllerWithCompletion:(void(^)())block
{
    if(isAnimationing_) return;
    isAnimationing_ = YES;
    if(nav_.view.superview) {
        [UIView animateWithDuration:0.25f animations:^{
            nav_.view.transform = CGAffineTransformMakeScale(0.2, 0.2);
            nav_.view.alpha = 0.0f;
        }completion:^(BOOL finished) {
            if(finished) {
                [nav_.view removeFromSuperview];
                [self setSuperViewGestureEnabled:YES];
                isAnimationing_ = NO;
                block();
            }
        }];
    }
}

- (void)zoomInViewController:(UIViewController *)vc
{
    if(isAnimationing_ || nav_.view.superview) return;
    isAnimationing_ = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//    if(nav_) {
//        //KD_RELEASE_SAFELY(nav_);
//    }
    
    nav_ = [[UINavigationController alloc] initWithRootViewController:vc];

    
    [self setUpNavigationItemForViewController:vc];
    
//    if(isAboveiOS7) {
        nav_.view.frame = self.view.frame;
//    }else {
//        nav_.view.frame = CGRectMake(0, 20.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 20.0f);
//    }
    
    nav_.view.alpha = 0.0f;
    nav_.view.transform = CGAffineTransformMakeScale(0.2, 0.2);
    [self.sideMenuViewController.view.superview addSubview:nav_.view];
    
    [UIView animateWithDuration:0.25f animations:^{
        nav_.view.transform = CGAffineTransformMakeScale(1, 1);
        nav_.view.alpha = 1;
    } completion:^(BOOL finished) {
        [self setSuperViewGestureEnabled:NO];
        isAnimationing_ = NO;
    }];
}
#pragma mark -
#pragma mark - Notification
- (void)didChangeAvatar
{
    //    [titleView_ setCurrentUser:[KDManagerContext globalManagerContext].userManager.currentUser];
    //    [workGroupInfoView_ setUser:[KDManagerContext globalManagerContext].userManager.currentUser];
}
- (void)didChangeInvite
{
    KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
    NSInteger count = unread.inviteTotal-1;
    
    [[KDManagerContext globalManagerContext].unreadManager didChangeInvitedBadgeValue:count];
    
    [self getInvited];
    [self fetchNetworkList];
}

- (void)companyDidSelect:(id)viewController company:(XTOpenCompanyDataModel *)company
{
    CompanyDataModel *companyDataModel;
    for (CompanyDataModel *cdm in self.arrayCompanyDataModels)
    {
        if ([company.companyId isEqualToString:cdm.eid])
        {
            companyDataModel = cdm;
        }
    }
    KDWeiboAppDelegate *appDelegate = (KDWeiboAppDelegate *)[KDWeiboAppDelegate getAppDelegate];
    [appDelegate changeNetWork:companyDataModel finished:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)didFinishSignOutTeam:(NSNotification *)noti
{
    
    /**
     *  修改流程, 退出工作圈后, 还有工作圈? 有->选择工作圈 : 没有->创建工作圈 Modified by Darren @ 20140915
     */
    
    // 界面代码, 照搬旧代码
    //   [self zoomOutViewControoler];
    //    [self fetchNetworkList];
    self.workGroupInfoView.groups = [KDManagerContext globalManagerContext].communityManager.joinedCommpanies;
    
    [BOSSetting sharedSetting].cust3gNo = @"";
    [[BOSSetting sharedSetting] saveSetting];
    
    [[XTSetting sharedSetting] cleanSetting];
    
    XTOpenCompanyListDataModel *companyList = [[XTOpenCompanyListDataModel alloc]init];
    
    self.arrayCompanyDataModels = [NSArray arrayWithArray:noti.userInfo[@"companies"]];
    NSMutableArray *mArrayXTOpenCompanyDataModels = [NSMutableArray new];
    NSMutableArray *mArrayXTAuthstrCompanyDataModels = [NSMutableArray new];
    
    for (CompanyDataModel *cdm in self.arrayCompanyDataModels)
    {
        XTOpenCompanyDataModel *xTCompanyModel = [XTOpenCompanyDataModel new];
        xTCompanyModel.companyId = cdm.eid;
        xTCompanyModel.companyName = cdm.name;
        
        if (cdm.user.status == 1) {
            [mArrayXTOpenCompanyDataModels addObject:xTCompanyModel];
        }
        else{
            [mArrayXTAuthstrCompanyDataModels addObject:xTCompanyModel];
        }
    }
    
    
    companyList.openId = [BOSConfig sharedConfig].user.openId;
    companyList.companys = [mArrayXTOpenCompanyDataModels copy];
    companyList.authstrCompanys = [mArrayXTAuthstrCompanyDataModels copy];
    
    [self zoomOutViewControllerWithCompletion:^
     {
         [self hideLeftView];
         if (companyList.companys.count > 0)
         {
             // 选择工作圈
             KDCompanyChoseViewController *ctr = [[KDCompanyChoseViewController alloc] init];
             ctr.delegate = self;
             ctr.dataModel = companyList;
             UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
             UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] init];
             ctr.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:leftBarButtonItem, nil];
             [self presentViewController:nav animated:YES completion:nil];
         }
         else
         {
             // 创建工作圈
             KDCreateTeamViewController *createTeamViewController_ = [[KDCreateTeamViewController alloc] initWithNibName:nil bundle:nil];
             createTeamViewController_.didSignIn = YES;
             createTeamViewController_.fromType = KDCreateTeamFromTypeDidLogin;
             createTeamViewController_.bHideBackButton = YES;
             [self zoomInViewController:createTeamViewController_];
         }
     }];
    
    /* 这里是旧代码, 流程是直接切换了一个工作圈
     [self zoomOutViewControoler];
     [self fetchNetworkList];
     
     self.workGroupInfoView.groups = [KDManagerContext globalManagerContext].communityManager.joinedCommpanies;
     
     [self hideLeftView];
     
     NSDictionary *userInfo = [noti userInfo];
     CompanyDataModel *model = [userInfo objectNotNSNullForKey:@"company"];
     [[KDWeiboAppDelegate getAppDelegate] changeNetWork:model];
     */
    
    
    
    
}
- (void)didFinishCreateTeam:(NSNotification *)noti
{
    //    [[NSNotificationCenter defaultCenter] postNotificationName:KDProfileUserNameUpdateNotification object:nil userInfo:nil];
    NSDictionary *userInfo = [noti userInfo];
    CompanyDataModel *model = [userInfo objectNotNSNullForKey:@"company"];
    if (model) {
        KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
        NSMutableArray *eList = [NSMutableArray arrayWithArray:communityManager.joinedCommpanies];
        [eList addObject:model];
        self.workGroupInfoView.groups = [NSArray arrayWithArray:eList];
    }
    
    [self zoomOutViewControoler];
    [self performSelector:@selector(fetchNetworkList) withObject:nil afterDelay:3];
    //    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    //    hud.labelText = ASLocalizedString(@"注册公司成功");
    //    [hud hide:YES afterDelay:1.f];
    
    [self hideLeftView];
    
    [[KDWeiboAppDelegate getAppDelegate] changeNetWork:model];
}

- (void)userAvatarUpdated:(NSNotification *)niti
{
    self.user = [[[KDManagerContext globalManagerContext] userManager] currentUser];
    [self initUser];
}

- (void)didReceiveTeamInvitation:(NSNotification *)noti
{
    [self invitedTeamsClicked];
}

- (void)changeLanguage:(NSNotification *)notification
{
//    [self setUpNavigationItemForViewController:self.settingCtr];
//    self.navigationItem.leftBarButtonItem.title = ASLocalizedString(@"Global_GoBack");
}
#pragma mark - KDLeftTitleViewDelegate Methods
- (void)leftTitleView:(KDLeftTitleView *)view searchButtonClicked:(UIButton *)btn
{
    
    KDSearchViewControllerNew *searchViewController_ = [[KDSearchViewControllerNew alloc] initWithSearchMaskType:KDSearchNewMaskTypeStatuses | KDSearchNewMaskTypeUsers];
    searchViewController_.shouldDelayShowKeyBoard = YES;
    
    [self zoomInViewController:searchViewController_];
}

- (void)leftTitleView:(KDLeftTitleView *)view settingButtonClicked:(UIButton *)btn
{
    if(!isAnimationing_) {
        //        [titleView_.avatarView rotateWithReaptCount:1 duration:0.5 andDelegate:self];
    }
}

- (void)leftTitleView:(KDLeftTitleView *)view avatarViewClicked:(KDAnimationAvatarView *)avatarView
{
    [avatarView rotateWithReaptCount:1 duration:0.5 andDelegate:self];
}

- (void)leftTitleView:(KDLeftTitleView *)view infoCenterButtonClicked:(UIButton *)btn
{
    KDTeamPageViewController *teamPageViewController_ = [[KDTeamPageViewController alloc] initWithContentType:KDTeamPageContentType_InviteMe];
    
    [teamPageViewController_.allInvitation addObjectsFromArray:teamInvitations_];
    
    [self zoomInViewController:teamPageViewController_];
    
}
#pragma mark -
#pragma mark - KDCommunitySearchViewControllerDelegate
- (void)communityDidSelected
{
    [self zoomOutViewControoler];
    
    //    [titleView_ setCurrentCommunity:[KDManagerContext globalManagerContext].communityManager.currentCommunity];
    
    [self.sideMenuViewController hideMenuViewController];
}
- (void)reloadCommunityDataSource
{
    NSArray *menuLists = [self getUnreadInfoCommunity];
    if (menuLists!=0)
        [workGroupInfoView_ setGroups:menuLists];
}
#pragma mark -
#pragma mark - KDLeftWorkGroupInfoViewDelegate
- (void) hideLeftView
{
    [titleView_ resetActionButtonRotate];
    [self toggleWorkGroupInfoViewAnimated:NO withSender:nil];
    [self.sideMenuViewController hideMenuViewController];
}
- (void) showNetWorkList{
    
    if (_menuTableView.alpha > 0.0f) {
        [titleView_ showListActionButtonRotate];
        [self toggleWorkGroupInfoViewAnimated:NO withSender:nil];
    }
}
- (void)showCommunitySearchViewController:(NSArray *)communities
{
    
}

- (void)createEnterprice
{
    KDCreateTeamViewController *createTeamViewController_ = [[KDCreateTeamViewController alloc] initWithNibName:nil bundle:nil];
    createTeamViewController_.didSignIn = YES;
    createTeamViewController_.fromType = KDCreateTeamFromTypeDidLogin;
    
    [self zoomInViewController:createTeamViewController_];
}

- (void)joinTeamButtonClicked
{
    KDSearchTeamViewController *searchTeamViewController_ = [[KDSearchTeamViewController alloc] initWithNibName:nil bundle:nil];
    searchTeamViewController_.shouldDelayShowKeyBoard = YES;
    
    [self zoomInViewController:searchTeamViewController_];
}
- (void)invitedTeamsClicked
{
    KDTeamPageViewController *teamPageViewController_ = [[KDTeamPageViewController alloc] initWithContentType:KDTeamPageContentType_InviteMe];
    
    [self zoomInViewController:teamPageViewController_];
}

- (void)createTeamButtonClicked
{
    
}

- (void)companyChanged:(NSNotification *)notification
{
    [self reloadIcons];
    [self resetDatasource];
}


#pragma mark - CAAnimation Delegate Methods
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if(flag) {
        [self showProfile];
    }
}

#pragma mark -
#pragma mark animation
- (void) groupViewWillAppear
{
    if (workGroupInfoView_)
        [workGroupInfoView_ sortGroups];
    
    //    [self updateDraftTips];
}
#pragma mark -
#pragma mark capture
- (UIImage *)capture
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(size, self.view.opaque, [UIScreen mainScreen].scale);
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark
#pragma mark tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  ceil((float)self.datasoure.count / kKDLeftMenuCellButtonPerRow);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDLeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[KDLeftMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.delegate = self;
        cell.backgroundColor = tableView.backgroundColor;
    }
    
    NSInteger startIndex = [indexPath row] * kKDLeftMenuCellButtonPerRow;
    NSInteger count = MIN(kKDLeftMenuCellButtonPerRow, [_datasoure count] - startIndex);
    cell.models = [_datasoure subarrayWithRange:NSMakeRange(startIndex, count)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return isAboveiPhone5 ? kKDLeftMenuCellHeight : kKDLeftMenuCellHeight - 20.f;
}

#pragma mark
#pragma mark leftMenuCell datasource
- (void)leftMenuCell:(KDLeftMenuCell *)leftMenuCell sender:(KDLeftMenuButton *)sender atIndex:(NSUInteger)index
{
    NSUInteger type = ((KDLeftMenuButtonModel *)[leftMenuCell.models objectAtIndex:index]).type;
    NSLog(@"%lu",(unsigned long)type);
    NSString *invation = [[BOSSetting sharedSetting] hasInvitePermission];
    if ([invation isEqualToString:@"0"])
    {
        if ([self bIsAdmin])
        {
            if ([self isMainUser]) {
                if ([self haveTeamAccount]) {
                    switch (type) {
                        case 0:
                        {
                            [self createEnterprice];
                        }
                            break;
                        case 1:
                        {
                            [self showRecommendView];
                        }
                            break;
                        case 2:
                        {
                            [self changeTeamAccount];
                        }
                            break;
                        case 3:
                        {
                            [self setting];
                        }
                            break;
                    }

                } else {
                    switch (type) {
                        case 0:
                        {
                            [self createEnterprice];
                        }
                            break;
                        case 1:
                        {
                            [self showRecommendView];
                        }
                            break;
                        case 2:
                        {
                            [self setting];
                        }
                            break;
                    }
                }
            } else {
                if ([self haveTeamAccount]) {
                    switch (type) {
                        case 0:
                        {
                            [self showRecommendView];
                        }
                            break;
                        case 1:
                        {
                            [self changeTeamAccount];
                        }
                            break;
                        case 2:
                        {
                            [self setting];
                        }
                            break;
                    }
                    
                } else {
                    switch (type) {
                        case 0:
                        {
                            [self showRecommendView];
                        }
                            break;
                        case 1:
                        {
                            [self setting];
                        }
                            break;
                    }
                }
            }
        }
        else
        {
            if ([self haveTeamAccount]) {
                switch (type) {
                    case 0:
                    {
                        [self changeTeamAccount];
                    }
                        break;
                    case 1:
                    {
                        [self setting];
                    }
                        break;
                        
                }

            }
            else {
                [self setting];
            }
        }
    }
    else if ([invation isEqualToString:@"1"])
    {
        if ([self bIsAdmin])
        {
            if ([self isMainUser]) {
                if ([self haveTeamAccount]) {
                    switch (type) {
                        case 0:
                        {
                            [self createEnterprice];
                        }
                            break;
                        case 1:
                        {
                            [self showRecommendView];
                        }
                            break;
                        case 2:
                        {
                            [self changeTeamAccount];
                        }
                            break;
                        case 3:
                        {
                            [self setting];
                        }
                            break;
                    }
                    
                } else {
                    switch (type) {
                        case 0:
                        {
                            [self createEnterprice];
                        }
                            break;
                        case 1:
                        {
                            [self showRecommendView];
                        }
                            break;
                        case 2:
                        {
                            [self setting];
                        }
                            break;
                    }
                }
            } else {
                if ([self haveTeamAccount]) {
                    switch (type) {
                        case 0:
                        {
                            [self showRecommendView];
                        }
                            break;
                        case 1:
                        {
                            [self changeTeamAccount];
                        }
                            break;
                        case 2:
                        {
                            [self setting];
                        }
                            break;
                    }
                    
                } else {
                    switch (type) {
                        case 0:
                        {
                            [self showRecommendView];
                        }
                            break;
                        case 1:
                        {
                            [self setting];
                        }
                            break;
                    }
                }
            }
        }
        else
        {
            if ([self haveTeamAccount]) {
                switch (type) {
                    case 0:
                    {
                        [self showRecommendView];
                    }
                        break;
                    case 1:
                    {
                        [self changeTeamAccount];
                    }
                        break;
                    case 2:
                    {
                        [self setting];
                    }
                        break;
                        
                }
                
            }
            else {
                switch (type) {
                    case 0:
                    {
                        [self showRecommendView];
                    }
                        break;
                    case 1:
                    {
                        [self setting];
                    }
                        break;
            
                }
        
            }
        }
    }
    else
    {
        if ([self bIsAdmin])
        {
            if ([self isMainUser]) {
                if ([self haveTeamAccount]) {
                    switch (type) {
                        case 0:
                        {
                            [self createEnterprice];
                        }
                            break;
                        case 1:
                        {
                            [self changeTeamAccount];
                        }
                            break;
                        case 2:
                        {
                            [self setting];
                        }
                            break;
                    }
                    
                } else {
                    switch (type) {
                        case 0:
                        {
                            [self createEnterprice];
                        }
                            break;
                        case 1:
                        {
                            [self setting];
                        }
                            break;
                    }
                }
            } else {
                if ([self haveTeamAccount]) {
                    switch (type) {
                        case 0:
                        {
                            [self changeTeamAccount];
                        }
                            break;
                        case 1:
                        {
                            [self setting];
                        }
                            break;
                    }
                    
                } else {
                    [self setting];
                }
                
            }
            
        }
        else
        {
            if ([self haveTeamAccount]) {
                switch (type) {
                    case 0:
                    {
                        [self changeTeamAccount];
                    }
                        break;
                    case 1:
                    {
                        [self setting];
                    }
                        break;
                        
                }
                
            }
            else {
                [self setting];
            }
        }
        
    }
}

#pragma mark
#pragma mark animateView delegate
- (void)animateGuidView:(KDGuideVC *)animateGuidView scrollToLast:(BOOL)flag
{
    [self zoomOutViewControoler];
}

#pragma mark
#pragma mark leftMenuTitleView delegate

- (void)showProfile
{
    [KDEventAnalysis event:event_settings_personal_open attributes:@{label_settings_personal_open_source: label_settings_personal_open_source_sidebar}];
    ProfileViewController2 *profileViewController_ = [[ProfileViewController2 alloc] initWithNibName:nil bundle:nil];
    [self zoomInViewController:profileViewController_];
    
    [KDWeiboAppDelegate getAppDelegate].currentTopVC = profileViewController_.navigationController;
}

- (void)leftMenuTitleView:(KDLeftMenuTitleView *)leftMenuTitleView actionButtonClicked:(id)sender
{
    [self fetchNetworkList];
    ((UIButton *)sender).enabled = NO;
    [self toggleWorkGroupInfoViewAnimated:YES withSender:(UIButton *)sender];
}

- (void)leftMenuTitleView:(KDLeftMenuTitleView *)leftMenuTitleView showProfile:(id)sender
{
    [self showProfile];
}

- (void)toggleWorkGroupInfoViewAnimated:(BOOL)animated withSender:(UIButton *)sender
{
    sender.enabled = NO;
    int workInfoViewAlpha = workGroupInfoView_.alpha == 0 ? 1 : 0;
    int menuTableViewAlpha = workGroupInfoView_.alpha == 0 ? 0 : 1;
    
    if (!animated) {
        workGroupInfoView_.alpha = workInfoViewAlpha;
        workGroupInfoView_.frame = workGroupInfoViewNormalFrame_;
        _menuTableView.alpha = menuTableViewAlpha;
        sender.enabled = YES;
        return;
    }
    
    if(workInfoViewAlpha > 0) {
        //展示工作圈的下拉动画：1.淡出menu 2.下拉工作圈.
        [UIView animateWithDuration:0.15 animations:^{
            _menuTableView.alpha = menuTableViewAlpha;
        }completion:^(BOOL finished) {
            if(finished) {
                [UIView animateWithDuration:0.20 animations:^{
                    workGroupInfoView_.alpha = workInfoViewAlpha;
                    workGroupInfoView_.frame = workGroupInfoViewNormalFrame_;
                }];
            }
            sender.enabled = YES;
        }];
    }else {
        //1.上拉工作圈 2.淡入menu.
        [UIView animateWithDuration:0.20 animations:^{
            CGRect rect = workGroupInfoViewNormalFrame_;
            rect.origin.y -= rect.size.height;
            workGroupInfoView_.frame = rect;
            workGroupInfoView_.alpha = workInfoViewAlpha;
        }completion:^(BOOL finished) {
            if(finished) {
                [UIView animateWithDuration:0.15 animations:^{
                    _menuTableView.alpha = menuTableViewAlpha;
                }];
            }
            sender.enabled = YES;
        }];
    }
    
}



#pragma mark - 管理员助手逻辑 -

- (AppsClient *)appsClient
{
    _appsClient = nil;
    if (!_appsClient) {
        _appsClient = [[AppsClient alloc] initWithTarget:self action:@selector(getPubAccountDidReceived:result:)];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    return _appsClient;
}


-(void)getPubAccountDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (result.success)
    {
        if(result.data)
        {
            PersonSimpleDataModel *ps = [[PersonSimpleDataModel alloc] initWithDictionary:result.data];
            
            if (ps)
            {
                PubAccountDataModel *publAccountDataModel = [[PubAccountDataModel alloc] init];
                publAccountDataModel.publicId = ps.personId;
                publAccountDataModel.name = ps.personName;
                publAccountDataModel.photoUrl = ps.photoUrl;
                
                XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithPubAccount:publAccountDataModel] ;
                chatViewController.hidesBottomBarWhenPushed = YES;
                [self zoomInViewController:chatViewController];
            }
        }
    }
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[[BOSConfig sharedConfig] class]])
    {
        
        if ([keyPath isEqualToString:@"currentUser"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadIcons];
            });
            
        }
    }
}

- (void)changeTeamAccount {
    KDChangeTeamAccountViewController *changeTeamAccountViewController = [KDChangeTeamAccountViewController new];
    [self zoomInViewController:changeTeamAccountViewController];
}

- (void)setting {
    //add
    [KDEventAnalysis event:event_setting_click];
    [KDEventAnalysis eventCountly:event_setting_click];
    KDSettingViewController *settingViewController_ = [[KDSettingViewController alloc] initWithNibName:nil bundle:nil];
    self.settingCtr = settingViewController_;
    [self zoomInViewController:settingViewController_];
}

@end
