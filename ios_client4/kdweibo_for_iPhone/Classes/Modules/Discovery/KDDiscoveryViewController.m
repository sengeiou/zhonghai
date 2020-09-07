//
//  KDDiscoveryViewController.m
//  kdweibo
//
//  Created by Tan Yingqi on 14-4-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDDiscoveryViewController.h"
#import "KDDiscoveryViewCell.h"
#import "UIView+Blur.h"
#import "KDDiscoveryTopicCell.h"
#import "KDTopicGridView.h"
#import  "KDMainTimelineViewController.h"
#import  "GroupViewController.h"
#import "KDTrendsViewController.h"
#import "KDInboxListViewController.h"
#import "TrendStatusViewController.h"
#import "AppsClient.h"
#import "BOSSetting.h"
#import "BOSConfig.h"
#import "ContactLoginDataModel.h"
#import "XTPubAcctUserChatListViewController.h"
#import "XTChatViewController.h"
#import "KDWebViewController.h"
#import "KDDiscoveryActionViewController.h"
#import "KDWisdomRadarController.h"


#import "KDMainInboxListViewController.h"

@interface KDDiscoveryViewController () <KDRefreshTableViewDataSource, KDRefreshTableViewDelegate, KDDiscoveryTopicCellDelegate,KDTopicGridViewDelete,KDUnreadListener> {
    NSInteger companyStatusUnread_;
    NSInteger mentionMeUnread_;
    NSInteger groupStatsusUnread_;
    NSInteger bossSpeechUnread_;
    BOOL _isLoading;
    struct {
       int currentItem;  //0:老板开奖 1:运动频道 2:智慧雷达
    }_flag;
}

@property(nonatomic, retain)AppsClient *appclient;
@property(nonatomic,retain)PersonSimpleDataModel *pubAccount;
@property(nonatomic,copy) NSString *latestStatusSenderPhotoUrl;
@property(nonatomic,retain)KDUserAvatarView *userAvatarView;
@property(nonatomic,retain) MBProgressHUD *hud;
@property(nonatomic,retain) NSArray *companyNames;
@property(nonatomic,retain) NSArray *extraTopicNames;
@end
//static NSString * const companyNames[] = {@"动态", @"提及回复", @"小组"};

static NSString * const companyImageNames[] = {@"icon_discovery_status", @"icon_disovery_at_me", @"icon_discovery_group_status"};

static NSString * const topicName = @"话题";

static NSString * const topicImageName = @"icon_disovery_topic";

//static NSString * const extraTopicNames[] = {@"领导开讲", @"运动频道", @"智慧雷达"};

static NSString * const extraTopicImageNames[] = {@"icon_disovery_boss_speech", @"icon_disovery_sports",@"icon_discover_img_waibu"};


#define KING_DEE_SPORT_URL  @"http://www.hipalsports.com:8080/business/vanke/dd/kingdeeController"
#define KING_DEE_SPORT_MENUID @"pubsportslink"
#define KING_DEE_SPORT_PUBACCID @"XT-6ba47b46-5f7d-42dd-81c2-2feb62e4b168"

//智慧雷达
#define WISDOM_RADAR_URL @""
#define SPROT_CHANNEL_SWICH  @"F01"
#define WISDON_RADAR_SWICH   @"F02"

@implementation KDDiscoveryViewController

@synthesize refreshTableView = refreshTableView_;
@synthesize pubAccount = pubAccount_;
@synthesize appclient = appclient_;
@synthesize latestStatusSenderPhotoUrl = latestStatusSenderPhotoUrl_;
@synthesize userAvatarView = userAvatarView_;
@synthesize hud = hud_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _flag.currentItem = -1;
        [[KDManagerContext globalManagerContext].unreadManager addUnreadListener:self];
    }
    return self;
}

- (void)setUpView{
    self.view.backgroundColor = [UIColor kdBackgroundColor1];//RGBCOLOR(237, 237, 237);
    //self.view.backgroundColor = [UIColor redColor];
    CGFloat offsetX = 5.f;
    CGFloat offsetY = 0.f;
    CGRect rect = self.view.bounds;
    rect = CGRectMake(0, offsetY, CGRectGetWidth(rect), CGRectGetHeight(rect) - offsetY);
    KDRefreshTableView *tableView = [[KDRefreshTableView alloc]initWithFrame:rect kdRefreshTableViewType:KDRefreshTableViewType_None];
    tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    //tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor =[UIColor kdBackgroundColor1];// UIColorFromRGB(0xededed);
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    refreshTableView_ = tableView;
    [self.view addSubview:refreshTableView_];
    
}


- (void)loadView{
    [super loadView];
    [self setUpView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//     self.navigationItem.title = ASLocalizedString(@"发现");
    [self.refreshTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = ASLocalizedString(@"KDDiscoveryViewController_discovery");
    
}


#pragma mark - Avatar url persistence
- (void)storeLatestStatusSenderPhotoUrl {
    DLog(@"save key = %@",[[KDUtility defaultUtility] companySpecifickey:@"latestStatusSenderPhotoUrl"]);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
         [[KDSession globalSession] saveProperty:self.latestStatusSenderPhotoUrl forKey:[[KDUtility defaultUtility] companySpecifickey:@"latestStatusSenderPhotoUrl"] storeToMemoryCache:YES];
    });

}

- (void)restoreLatestStatusSenderPhotoUrl {
    self.latestStatusSenderPhotoUrl = [[KDSession globalSession] getPropertyForKey:[[KDUtility defaultUtility] companySpecifickey:@"latestStatusSenderPhotoUrl"] fromMemoryCache:YES];
}


#pragma mark- HUD
- (void)showHud:(BOOL)animated{
    if (hud_ == nil) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:animated];// autorelease];
    }else {
        [hud_ show:animated];
    }
}

- (void)hideHud:(BOOL)animated {
    if (hud_) {
        [hud_ hide:YES];
    }
}



#pragma mark- Local Logic

- (void)loadBossInfo {
    NSString *bossTaskShowId = [[BOSSetting sharedSetting] bossTalkShowId];
    if (!KD_IS_BLANK_STR(bossTaskShowId)) { //老板开讲开通了
        _isLoading = YES;
        [self showHud:YES];
        if (!appclient_) {
            appclient_ = [[AppsClient alloc] initWithTarget:self action:@selector(getPubAccountDidReceived:result:)];
        }
        [appclient_ getPublicAccount:bossTaskShowId];
    }else  { //老板开讲没有开通
        [self bossTaskNotAllowd];
    }
}

//是否开通领导开讲
-(BOOL)isOpenBossInfo
{
     NSString *bossTaskShowId = [[BOSSetting sharedSetting] bossTalkShowId];
    if(!KD_IS_BLANK_STR(bossTaskShowId)){
        return YES;
    }
    
    return NO;
}

-(void)getPubAccountDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    [self hideHud:YES];
    _isLoading = NO;
    if (result.success) {
        if(result.data) {
            PersonSimpleDataModel *ps = [[PersonSimpleDataModel alloc] initWithDictionary:result.data];// autorelease];
            // 存数据库
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertPublicPersonSimple:ps];
            self.pubAccount = ps;
            [self bossTaskAllowed];
        }
    }
}

- (void)bossTaskAllowed { //老板开讲开通了
  
    if (self.pubAccount) {
        PubAccountDataModel *publAccountDataModel = [[PubAccountDataModel alloc] init] ;//autorelease];
        publAccountDataModel.publicId = self.pubAccount.personId;
        publAccountDataModel.name = self.pubAccount.personName;
        publAccountDataModel.photoUrl = self.pubAccount.photoUrl;
        if (self.pubAccount.manager) { //是老板或管理员
            XTPubAcctUserChatListViewController *pubAcctUserChatListViewController = [[XTPubAcctUserChatListViewController alloc] initWithPubAccount:publAccountDataModel andPerson:self.pubAccount];
            [self.navigationController pushViewController:pubAcctUserChatListViewController animated:YES];
//            [pubAcctUserChatListViewController release];
        }else {
            XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithPubAccount:publAccountDataModel];
            chatViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatViewController animated:YES];
//            [chatViewController release];
        }
    }
    
}

- (void)bossTaskNotAllowd { //老板开讲没有开通
    KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:@"http://kdweibo.com/public/v4/lbkj/list.html"];
    webVC.title = ASLocalizedString(@"老板开讲");
    [self.navigationController pushViewController:webVC animated:YES];
    webVC.rightButton.hidden = YES;
//    [webVC release];
}


- (BOOL)sportChannelAvailabel {
    BOOL has = NO;
    NSString *funswitch = [[BOSSetting sharedSetting] funcswitch];
    if (funswitch) {
        has = [funswitch rangeOfString:SPROT_CHANNEL_SWICH].location != NSNotFound;
    }
    return has;
    
}

- (BOOL)wisdomRadarAvailabel {
    BOOL has = NO;
    NSString *funswitch = [[BOSSetting sharedSetting] funcswitch];
    if (funswitch) {
        has = [funswitch rangeOfString:WISDON_RADAR_SWICH].location != NSNotFound;
    }
    return has;
}

- (void)kdDiscoveryDidSelectedItemAtIndexPath:(KDTopicSelectedIndex)index{
    NSLog(@"%lu",(unsigned long)index);
    
}

- (void)gotoSportChannel {
    if ([self sportChannelAvailabel] ) { //  公司有运动频道
        KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:@"" appId:@"10003"];
        webVC.title = ASLocalizedString(@"运动频道");
        webVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webVC animated:YES];
//        [webVC release];
        
    }else {
        KDDiscoveryActionViewController *actionViewController = [[KDDiscoveryActionViewController alloc]initWithNibName:nil bundle:nil];
        [KDWeiboAppDelegate setExtendedLayout:actionViewController];
        [self.navigationController pushViewController:actionViewController animated:YES];
    }
    
}

- (void)gotoWisdomRadar {
    if ([self wisdomRadarAvailabel] ) { //  公司有智慧雷达
        KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:@"" appId:@"10002"];
        webVC.title = ASLocalizedString(@"智慧雷达");
        webVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webVC animated:YES];
//        [webVC release];
    }else {
        KDWisdomRadarController *wisdomRadarController = [[KDWisdomRadarController alloc] init];
        [KDWeiboAppDelegate setExtendedLayout:wisdomRadarController];
        [self.navigationController pushViewController:wisdomRadarController animated:YES];
//        [wisdomRadarController release];
    }
    
    
}

#pragma mark - getter
- (KDUserAvatarView *)userAvatarView {
    if (!userAvatarView_) {
        userAvatarView_ = [KDUserAvatarView avatarView] ;//retain];
        userAvatarView_.enabled = NO;
        userAvatarView_.bounds = CGRectMake(0, 0, 37, 37);
        userAvatarView_.layer.cornerRadius = 6;
        userAvatarView_.layer.masksToBounds = YES;
        KDUser *user = [[KDUser alloc] init];// autorelease];
        [self restoreLatestStatusSenderPhotoUrl];
        user.profileImageUrl = latestStatusSenderPhotoUrl_;
        self.userAvatarView.avatarDataSource = user;
        if (![self.userAvatarView hasAvatar] && ![self.userAvatarView loadAvatar]) {
            [self.userAvatarView setLoadAvatar:YES];
        }
    }
    return userAvatarView_;
}

#pragma mark -
#pragma mark UITableViewDataSource And UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == KDDiscoveryViewSectionCompany){
        return 1;
    }
    else if(section == KDDiscoveryViewSectionCompanyExtra)
    {
        return 3;
    }
    else{
        int row =0;
        if([self isOpenBossInfo]){
            row++;
        }
        return row;
    }
}

#define KDDiscoveryViewCellIdentifier @"KDDiscoveryViewCellIdentifier"
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    self.extraTopicNames = @[ASLocalizedString(@"BOSSetting_Speak"),ASLocalizedString(@"运动频道"),ASLocalizedString(@"智慧雷达")];
    KDDiscoveryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KDDiscoveryViewCellIdentifier];
    if(!cell){
        cell = [[KDDiscoveryViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KDDiscoveryViewCellIdentifier];//autorelease];
    }
    
    cell.extendView = nil;
    cell.userAvatar = nil;
    [cell showBadgeTipView:NO];
    [cell setBadgeValue:0];
    cell.accessoryImageView.hidden = YES;
    
    if(section == KDDiscoveryViewSectionCompany || section == KDDiscoveryViewSectionCompanyExtra|| section == KDDiscoveryViewSectionTopic){
      
        if(section == KDDiscoveryViewSectionCompany){
            [cell.avatarImageView setImage:[UIImage imageNamed:companyImageNames[row]]];
//            cell.discoveryLabel.text = _companyNames[row];
            if(row == 0){ //公司动态
                cell.discoveryLabel.text = ASLocalizedString(@"KDDefaultViewControllerContext_trends");
                cell.userAvatar = [self userAvatarView];
                cell.rowType = None;
                KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
                [cell showBadgeTipView:unread.publicStatuses >0];
                cell.accessoryImageView.hidden = NO;
            }
        }
        else if(section == KDDiscoveryViewSectionCompanyExtra)
        {
            [cell.avatarImageView setImage:[UIImage imageNamed:companyImageNames[row+1]]];
//            cell.discoveryLabel.text = _companyNames[row+1];
            if (row == 0) { //@我的
                cell.discoveryLabel.text = ASLocalizedString(@"KDDiscoveryViewController_replu");
                cell.rowType = None;
                KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
                [cell setBadgeValue:unread.inboxTotal];
            }else if (row == 1) { //小组
                cell.discoveryLabel.text = ASLocalizedString(@"DraftTableViewCell_tips_1");
                cell.rowType = MiddleRow;
                KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
                [cell showBadgeTipView:[unread hasNewgroupStatuses]];
            }
            else if( row == 2)
            {
                [cell.avatarImageView setImage:[UIImage imageNamed:topicImageName]];
                cell.discoveryLabel.text = ASLocalizedString(@"KDDiscoveryViewController_topic");
                cell.rowType = None;
            }

        }
        else if(section == KDDiscoveryViewSectionTopic){
            
            if (![self sportChannelAvailabel] && row>0 && [self wisdomRadarAvailabel]) {
                row++;
            }
            
            if(row == 0){
                cell.rowType = None;

            }//老板开讲
            else if (row == 1){
                cell.rowType = MiddleRow;

            }//运动频道
            else if (row == 2){
                cell.rowType = LastRow;
                
                if (![self sportChannelAvailabel]) {
                    cell.rowType = MiddleRow;
                }

            }//外部资讯
            [cell.avatarImageView setImage:[UIImage imageNamed:extraTopicImageNames[row]]];
            
            if(row == 0){
                cell.discoveryLabel.text = [[BOSSetting sharedSetting] bossTalkName];
            }else{
                cell.discoveryLabel.text = self.extraTopicNames[row];
            }
            
        }
      
    }

    [cell setNeedsLayout];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isLoading) {
        return;
    }
    if (indexPath.section == KDDiscoveryViewSectionCompany) {
        if (indexPath.row == 0 ) {
            [KDEventAnalysis event:event_discover_status];
            [KDEventAnalysis eventCountly:event_discover_status];
            [KDSession globalSession].timelineType = KDTLStatusTypePublic;
            
            KDMainTimelineViewController *mainTimelineViewController = [[KDMainTimelineViewController alloc] init];
            [self.navigationController pushViewController:mainTimelineViewController animated:YES];
//            [mainTimelineViewController release];
        }
    }
    else if(indexPath.section == KDDiscoveryViewSectionCompanyExtra)
    {
        if (indexPath.row == 0) {
            //add
            [KDEventAnalysis event:event_find_mention_reply];
            [KDEventAnalysis eventCountly: event_find_mention_reply];
            KDMainInboxListViewController * inboxListViewController = [[KDMainInboxListViewController alloc]init];
            
            [self.navigationController pushViewController:inboxListViewController animated:YES];
//            [inboxListViewController release];
            
        }else if (indexPath.row == 1) { //小组
            //add
            [KDEventAnalysis event: event_find_group];
            [KDEventAnalysis eventCountly: event_find_group];
            KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
            [unread saveGroupStatusUnread];
            GroupViewController *groupViewController = [[GroupViewController alloc] init];
            [self.navigationController pushViewController:groupViewController animated:YES];
//            [groupViewController release];
        }
        else if (indexPath.row == 2) { //话题
            //add
            [KDEventAnalysis event:event_find_topic];
            [KDEventAnalysis eventCountly:event_find_topic];
            KDTrendsViewController *trentdsViewController = [[KDTrendsViewController alloc] init];
            [self.navigationController pushViewController:trentdsViewController animated:YES];
//            [trentdsViewController release];
        }
    }
    else if (indexPath.section == KDDiscoveryViewSectionTopic) {
        
        int row = (int)indexPath.row;
        if (![self sportChannelAvailabel] && row>0 && [self wisdomRadarAvailabel]) {
            row++;
        }
        
        if (row == 0) { //老板开讲
            [KDEventAnalysis event:event_discover_bosstalk];
            _flag.currentItem = 0;
            [self loadBossInfo];
        }
        else if (row == 1) {//运动频道
            [KDEventAnalysis event:event_discover_sport];
             _flag.currentItem = 1;
            [self gotoSportChannel];
        }
        else if (row == 2) {//智慧雷达
            [KDEventAnalysis event:event_discover_smartradar];
            _flag.currentItem = 2;
            [self gotoWisdomRadar];
        }
    }

}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section == KDDiscoveryViewSectionTopic ){
        return 10.f;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == KDDiscoveryViewSectionTopic || section == KDDiscoveryViewSectionCompanyExtra){
        return 10.f;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor clearColor];//RGBCOLOR(237, 237, 237);
    return view;// autorelease];
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor clearColor];//RGBCOLOR(237, 237, 237);
    return view;// autorelease];
}



- (void)setLatestStatusSenderPhotoUrl:(NSString *)latestStatusSenderPhotoUrl {
    if (![latestStatusSenderPhotoUrl_ isEqualToString:latestStatusSenderPhotoUrl]) {
//        [latestStatusSenderPhotoUrl_ release];
        latestStatusSenderPhotoUrl_ = [latestStatusSenderPhotoUrl copy];
        KDUser *user = [[KDUser alloc] init];// autorelease];
        user.profileImageUrl = latestStatusSenderPhotoUrl_;
        self.userAvatarView.avatarDataSource = user;
        if (![self.userAvatarView hasAvatar] && ![self.userAvatarView loadAvatar]) {
            [self.userAvatarView setLoadAvatar:YES];
        }
        [self storeLatestStatusSenderPhotoUrl];
      
    }
}
- (void)didSeletedGridAtIndex:(NSInteger) index{}
#pragma mark - KDUnreadListener methods

- (void)unreadManager:(KDUnreadManager *)unreadManager unReadType:(KDUnreadType)unReadType{

    //先判断有没有启用发现模块
    [self.tabBarController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *vc = ((UINavigationController *)obj).viewControllers[0];
        if(vc == self)
        {
            if([BOSConfig sharedConfig].user.partnerType != 1){
                //设置小红点
                [[KDWeiboAppDelegate getAppDelegate].tabBarController.tabBar setDotHidden:(unreadManager.unread.publicStatuses<=0) atIndex:idx];
            }
            *stop = YES;
        }
    }];
    
    if(!self.isViewLoaded)
        return;
    
    [self.refreshTableView reloadData];
    
    NSString *url = unreadManager.unread.latestStatusMsgHeadUrl;
    if (KD_IS_BLANK_STR(url)) {
        return;
    }
    self.latestStatusSenderPhotoUrl = url;
}

- (void)dealloc{
    [[KDManagerContext globalManagerContext].unreadManager removeUnreadListener:self];
    //KD_RELEASE_SAFELY(refreshTableView_);
    //KD_RELEASE_SAFELY(appclient_);
    //KD_RELEASE_SAFELY(pubAccount_);
    //KD_RELEASE_SAFELY(latestStatusSenderPhotoUrl_);
    //KD_RELEASE_SAFELY(userAvatarView_);
    //KD_RELEASE_SAFELY(hud_);
    //[super dealloc];
}


@end
