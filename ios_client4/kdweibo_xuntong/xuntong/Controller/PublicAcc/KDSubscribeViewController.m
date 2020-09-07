//
//  KDSubscribeViewController.m
//  XT
//
//  Created by mark on 14-1-11.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import "KDSubscribeViewController.h"
#import "KDPubAcctFetch.h"
#import "KDPublicAccountDataModel.h"
#import "XTPubAcctUserChatListViewController.h"
//#import "KDDetail.h"
#import "CKSlideSwitchView.h"
#import "KDSubscribeCollectionView.h"
#import "KDSubscribeCell.h"
#import "XTPersonDetailViewController.h"
#import "ContactClient.h"
#import "XTSetting.h"
#import "ContactLoginDataModel.h"
#import "KDPubAccDetailViewController.h"

//订阅消息是否全量获取过的标识
#define kAllPubicAcccountsFetch @"kAllPubicAcccountsFetch"

@interface KDSubscribeViewController ()
@property (nonatomic, strong) NSMutableArray *subscribedPubAccts;//已订阅的
@property (nonatomic, strong) NSMutableArray *canSubscribePubAccts;//未订阅但是可订阅的

@property (nonatomic, strong) CKSlideSwitchView *slideSwitchView;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) KDPubAcctFetch *fetcher;
@property (nonatomic, assign) BOOL isShowCollectionView;

@property (nonatomic, strong) ContactClient * contactClient;
@property (nonatomic, strong) PersonSimpleDataModel * publicDM;


@end
@interface KDSubscribeViewController ()<CKSlideSwitchViewDelegate>

@end
@implementation KDSubscribeViewController

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllPublicAccountFromDB) name:@"loadData" object:nil];
    }
    return self;
}

- (void)dealloc {
    ////[super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadData" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    self.title = ASLocalizedString(@"KDSubscribeViewController_Read");
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDSubscribeViewController_Refresh")style:UIBarButtonItemStylePlain target:self action:@selector(reload)];
    UIBarButtonItem *rightNegativeSpacer = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                            target:nil action:nil];
    rightNegativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:rightNegativeSpacer,rightItem, nil];
    
    _slideSwitchView = [[CKSlideSwitchView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-kd_StatusBarAndNaviHeight)];
    _slideSwitchView.tabItemTitleNormalColor = FC2;
    _slideSwitchView.tabItemTitleSelectedColor = FC5;
    _slideSwitchView.topScrollViewBackgroundColor = [UIColor kdBackgroundColor2];
    _slideSwitchView.tabItemShadowColor = FC5;
    _slideSwitchView.slideSwitchViewDelegate = self;
    _slideSwitchView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_slideSwitchView];
    
    for (UIGestureRecognizer *gesture in self.navigationController.view.gestureRecognizers)
    {
        if([gesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            [_slideSwitchView.rootScrollview.panGestureRecognizer requireGestureRecognizerToFail:gesture];
        }
    }

    
    [self.view addSubview:self.hud];
    
    [self getAllPublicAccount];
}


- (MBProgressHUD *)hud {
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _hud;
}

- (KDPubAcctFetch *)fetcher {
    if (_fetcher == nil) {
        _fetcher = [[KDPubAcctFetch alloc] init];
    }
    return _fetcher;
}

#pragma mark - 获取所有公共号

- (void)getAllPublicAccount {
//    BOOL isFetched = [[NSUserDefaults standardUserDefaults] boolForKey:kAllPubicAcccountsFetch];
//    BOOL isFetched = NO;    //后台有一个bug，已经发过消息然后禁用的公共号会显示在这个列表,先调整一下
//    if (!isFetched) {
    self.isShowCollectionView = NO;
    [self getAllPublicAccountFromNet];
//    }
//    else {
//        self.isShowCollectionView = YES;
//        [self getAllPublicAccountFromDB];
//    }
}

- (void)getAllPublicAccountFromNet {
    [self.hud setLabelText:ASLocalizedString(@"XTPersonalFilesController_Wait")];
    [self.hud show:YES];
    
    __block KDSubscribeViewController *selfInBlock = self;
    [self.fetcher fetchAllPubAcctsCompletionBlock: ^(BOOL success, NSArray *pubAccts) {
        [selfInBlock.hud hide:YES];
        
        if (success) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAllPubicAcccountsFetch];
        }
        
        if (success && [pubAccts count] > 0) {
            NSMutableArray *subscribedPubAccts = [[NSMutableArray alloc] init];
            NSMutableArray *canSubscribePubAccts = [[NSMutableArray alloc] init];
            for (KDPublicAccountDataModel *pubAcct in pubAccts) {
                if ([[pubAcct.subscribe description] isEqualToString:@"1"]) {
                    [subscribedPubAccts addObject:pubAcct];
                }
                else {
                    if ([[pubAcct.canUnsubscribe description] isEqualToString:@"1"]) {
                        [canSubscribePubAccts addObject:pubAcct];
                    }
                }
            }
            selfInBlock.subscribedPubAccts = subscribedPubAccts;
            selfInBlock.canSubscribePubAccts = canSubscribePubAccts;
            if(!selfInBlock.isShowCollectionView)
            {
                [selfInBlock.slideSwitchView reloadData];
                selfInBlock.isShowCollectionView = YES;
            }else{
                
                KDSubscribeCollectionView *collectionView = (KDSubscribeCollectionView *)[selfInBlock.slideSwitchView findContentViewWithIndex:0];
                collectionView.subscribeDataArray = selfInBlock.subscribedPubAccts;
                
                [collectionView reloadData];
                
                
                KDSubscribeCollectionView *collectionView2 = (KDSubscribeCollectionView *)[selfInBlock.slideSwitchView findContentViewWithIndex:1];
                collectionView2.subscribeDataArray = selfInBlock.canSubscribePubAccts;
                
                [collectionView2 reloadData];
                
            }
        }
        else {
            [selfInBlock getAllPublicAccountFromDB];
        }
    }];
}

- (void)getAllPublicAccountFromDB {
    NSMutableArray *subscribedPubAccts = [[NSMutableArray alloc] init];
    NSMutableArray *canSubscribePubAccts = [[NSMutableArray alloc] init];
    
    NSArray *pubAccts = [[XTDataBaseDao sharedDatabaseDaoInstance] queryAllPublicPersonSimple];
    [pubAccts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        KDPublicAccountDataModel *pubAcct = obj;
        if ([[pubAcct.subscribe description] isEqualToString:@"1"]) {
            [subscribedPubAccts addObject:pubAcct];
        }
        else {
            if ([[pubAcct.canUnsubscribe description] isEqualToString:@"1"]) {
                [canSubscribePubAccts addObject:pubAcct];
            }
        }
    }];
    self.subscribedPubAccts = subscribedPubAccts;
    self.canSubscribePubAccts = canSubscribePubAccts;
    [self.slideSwitchView reloadData];
}

#pragma mark - btn

- (void)reload {
    [KDEventAnalysis event:event_contact_pubacc_refresh];
    [self getAllPublicAccountFromNet];
}

#pragma mark - APPDelegate

- (void)photoclick:(PersonSimpleDataModel *)publicDM {
    if (self.slideSwitchView.currentSelectedTabItemIndex == 0) {
        if (publicDM.personId && [publicDM isKindOfClass:[PersonSimpleDataModel class]]) {
            KDPublicAccountDataModel *pubAcct = (KDPublicAccountDataModel *)publicDM;
            if (pubAcct.manager) {
                [self pubGroupList:publicDM];
//                XTPubAcctUserChatListViewController *publicTimelineViewController = [[XTPubAcctUserChatListViewController alloc] initWithPublicPerson:pubAcct];
//                [self.navigationController pushViewController:publicTimelineViewController animated:YES];
            }
            else {
                [self openChatViewController:pubAcct];
            }
        }
    }
    else {
//        [KDDetail toDetailWithPerson:publicDM inController:self];
//        XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:publicDM with:YES];
//        personDetail.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:personDetail animated:YES];
        KDPubAccDetailViewController *pubAccDetail =[[KDPubAccDetailViewController alloc] initWithPubAcct:publicDM];
        pubAccDetail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pubAccDetail animated:YES];
    }
}

-(void)pubGroupList:(PersonSimpleDataModel *)publicDM
{
    if (_contactClient == nil) {
        _contactClient = [[ContactClient alloc] initWithTarget:self action:@selector(publicGroupListDidReceived:result:)];
    }
    [_contactClient publicGroupList:publicDM.personId updateTime:[[XTSetting sharedSetting].pubAccountsUpdateTimeDict objectForKey:publicDM.personId]];
    [self.hud setLabelText:ASLocalizedString(@"KDSubscribeViewController_Load")];
    [self.hud show:YES];
    _publicDM = publicDM;
}

- (void)publicGroupListDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    [self.hud hide:YES];
    if (result.success && result.data) {
        GroupListDataModel *groupList = [[GroupListDataModel alloc] initWithDictionary:result.data];
        //更新updateTime
        if (![groupList.updateTime isEqualToString:@""]) {
            [[XTSetting sharedSetting].pubAccountsUpdateTimeDict setObject:groupList.updateTime forKey:_publicDM.personId];
        }
        [[XTSetting sharedSetting] saveSetting];
        if ([groupList.list count] > 0)
        {
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePublicGroupList:groupList withPublicId:_publicDM.personId];
        }
        //管理员，打开消息页面
        PubAccountDataModel *publAccountDataModel = [[PubAccountDataModel alloc] init];
        publAccountDataModel.publicId = _publicDM.personId;
        publAccountDataModel.name = _publicDM.personName;
        XTPubAcctUserChatListViewController *publicTimelineViewController = [[XTPubAcctUserChatListViewController alloc] initWithPubAccount2:publAccountDataModel andPerson:_publicDM];
        [self.navigationController pushViewController:publicTimelineViewController animated:YES];
    }
    else
    {
        [self openChatViewController:_publicDM];
    }
}

- (void)openChatViewController:(PersonSimpleDataModel *)publicDM {
    
    GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPersonForPublic:publicDM];
    
    if(group)
    {
        PersonSimpleDataModel *person = [group.participant firstObject];
        
        //赋值state
        KDPublicAccountDataModel *pubacc = [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:publicDM.personId];
        if(pubacc)
            person.state = pubacc.state;
        
        XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
        chatViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatViewController animated:YES];
    }
    else
    {
        XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:publicDM];
        chatViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatViewController animated:YES];
    }
}

#pragma mark - slideswitchdelegate
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView heightForTabItemForTopScrollview:(UIScrollView *)topScrollview
{
    return 40;
}

- (NSInteger)slideSwitchView:(CKSlideSwitchView *)slideSwitchView numberOfTabItemForTopScrollview:(UIScrollView *)topScrollview
{
    return 2;
}

- (NSString *)slideSwitchView:(CKSlideSwitchView *)slideSwitchView titleForTabItemForTopScrollviewAtIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            return ASLocalizedString(@"KDSubscribeViewController_My");
        }
            break;
        case 1:
        {
            return ASLocalizedString(@"KDSubscribeViewController_Book");
        }
            break;
    }
    return nil;
}

- (UIView *)slideSwitchView:(CKSlideSwitchView *)slideSwitchView viewForRootScrollViewAtIndex:(NSInteger)index
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat minSpace = (ScreenFullWidth - 300)/5;
    layout.sectionInset = UIEdgeInsetsMake(10, minSpace, 0, minSpace);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 5;
    KDSubscribeCollectionView *collectionView = [[KDSubscribeCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.tag = index;
    collectionView.subscribeDataArray = (index == 0 ? self.subscribedPubAccts : self.canSubscribePubAccts);
    
    __block KDSubscribeViewController *weakSelf = self;
    collectionView.subscribeCellDelegate = ^(PersonSimpleDataModel *data){
        [weakSelf photoclick:data];
    };
    collectionView.backgroundColor = [UIColor kdBackgroundColor2];
    [collectionView reloadData];
    return collectionView;
}

- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView widthForTabItemForTopScrollview:(UIScrollView *)topScrollview
{
    return CGRectGetWidth(self.view.frame)/2.0;
}

- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView marginForTopScrollview:(UIScrollView *)topscrollview
{
    return 0;
}
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView heightOfShadowImageForTopScrollview:(UIScrollView *)topScrollview
{
    return  2;
}
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView fontSizeForTabItemForTopScrollview:(UIScrollView *)topScrollview
{
    return 16;
}

- (NSInteger)slideSwitchView:(CKSlideSwitchView *)slideSwitchView selectedTabItemIndexForFirstStartForTopScrollview:(UIScrollView *)topScrollview
{
    return 0;
}

- (BOOL)slideSwitchView:(CKSlideSwitchView *)slideSwitchView seperatorImageViewShowInTopScrollview:(UIScrollView *)topScrollview
{
    return YES;
}
@end
