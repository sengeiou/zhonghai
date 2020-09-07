//
//  XTOrganizationViewController.m
//  XT
//
//  Created by Gil on 13-7-17.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTOrganizationViewController.h"
#import "UIButton+XT.h"
#import "ContactClient.h"
#import "XTOrgTreeDataModel.h"
#import "XTContactEmployeesView.h"
#import "XTContactPersonCell.h"
#import "MBProgressHUD.h"
#import "XTTELHandle.h"
#import "XTCell.h"
#import "XTPersonDetailViewController.h"
#import "XTContactContentV2/XTContactPersonViewCell.h"
#import "XTContactOrganPersonCell.h"
#import "KDNotOrganizationView.h"

#import "BOSSetting.h"

#import "BOSConfig.h"

#import "KDContactGroupDataModel.h"

#import "KDWebViewController.h"


#import "KDOrganizationSelectView.h"
#import "KDOrgTreeItemDataModel.h"
//#import "KDAddOrganiztionViewController.h"
//#import "KDEditeOrgViewController.h"
#import "KDOrganiztionCell.h"
#import "KDNoItemView.h"
#import "KDPersonCell.h"
#import "KDUnallotViewController.h"

#import "KDWaterMarkAddHelper.h"

#define MinFoldCellNumber 3
#define unFoldCellNumber  10

@interface XTOrganizationViewController ()<UIGestureRecognizerDelegate,KDOrganizationSelectViewDataDelegate,KDOrganizationSelectViewDelegate,KDTableViewCellDelegate,XTChooseContentViewControllerDelegate>
{
    KDOrganizationSelectView *_organiztionSelectView;
     NSMutableArray *_organiztionStack;
    
    KDNoItemView *noItemView;
    
    
    BOOL haveNewItemPush;
    
    UIButton *addBtn;
    NSString *rootOrganiztionName;
    UIBarButtonItem *manageItemGuanl;
    UIBarButtonItem *manageItemWanc;
    
    UIView *editeFooterBarView;
    UIButton *addSubOrgBt;
    UIButton *addMember;
    
    BOOL haveLeaders;
    BOOL haveEmployees;
    
    BOOL isFold;
    
    float foldSheild;
    
    UIView *hintView;
    BOOL haveFoldeCell;
    NSString *unallotPersonCount;
    NSString *orgOldId;
}


@property (nonatomic, copy) NSString *orgId;
@property (nonatomic, strong) XTOpenSystemClient *orgClient;
@property (nonatomic, retain) ContactClient *contactClient;

@property (nonatomic, strong) XTOrgTreeDataModel *orgTreeData;

@property (nonatomic, assign) BOOL isRequesting;

//UI
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) XTContactEmployeesView *leadersView;
@property (nonatomic, strong) UITableView *childrenTableView;
@property (nonatomic, strong) MBProgressHUD *hud;

//if YES, tap back button pop.
@property (nonatomic, assign) BOOL  isSingle;

//点通讯录模块点击组织架构进来的话,为YES
@property (nonatomic, assign) BOOL isFromAddressBook;

@property (nonatomic, assign) BOOL shouldRequestData; //是不是应该在viewDidApear


@property (nonatomic, strong) NSMutableArray * dataArray;

//add by lee
//@property (nonatomic,strong) NSMutableArray * personIdArray; //部门负责人


@end

@implementation XTOrganizationViewController

- (void)dealloc {
    DLog(@"XTOrganizationViewController 释放了");
}

- (id)init
{
    return [self initWithOrgId:@""];
}

- (id)initWithOrgId:(NSString *)orgId isOnlySingleOrganization:(BOOL)isSingle
{
    self = [super init];
    if (self) {
        self.orgId = orgId;
        _isSingle = isSingle;
        _isFromAddressBook = NO;
        _shouldRequestData = YES;
        _isFromAddressBook = NO;
//        _managerSchema = NO;
        
        haveEmployees = NO;
        haveLeaders = NO;
        
        foldSheild = MinFoldCellNumber;
        unallotPersonCount = @"0";
        orgOldId = @"-1";
    }
    return self;
}

- (id)initWithOrgId:(NSString *)orgId
{
    isFold = YES;
    return [self initWithOrgId:orgId isOnlySingleOrganization:NO];
}
- (id)initFromAddressBookWithOrgId:(NSString *)orgId{
    self = [self initWithOrgId:orgId];
    if (self) {
        _isFromAddressBook = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
//    self.backButton = [UIButton backButton];
//    [self.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(backToRoot:)];
//    [self.backButton addGestureRecognizer:longPress];
//    
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
//                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                        target:nil action:nil];
//    negativeSpacer.width = kLeftNegativeSpacerWidth;
//    
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
//    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,backItem, nil];
    
//    UIBarButtonItem *leftItem  = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"通讯录")style:UIBarButtonSystemItemFixedSpace target:self action:@selector(back:)];
//    self.navigationItem.leftBarButtonItems = [NSArray
//                                               arrayWithObjects:nil,leftItem, nil];
//    [self setBackItem];
    
   
    
    if (_shouldRequestData) {
        _shouldRequestData = NO;
        [self orgTreeInfo:self.orgId];

    }

   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    self.navigationItem.title =(self.partnerType == 0? ASLocalizedString(@"KDChooseOrganizationViewController_Organtion"):ASLocalizedString(@"XTChooseContentViewController_partner"));
    [self setNavigationStyle:KDNavigationStyleNormal];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [closeButton setTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Close")];
//    [closeButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
//    [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    

//    self.navigationItem.rightBarButtonItem = closeItem;
//    [self setBackItem];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Close")style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
//    
//    UIBarButtonItem *rightNegativeSpacer = [[UIBarButtonItem alloc]
//                                            initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                            target:nil action:nil];
//    self.navigationItem.rightBarButtonItems = [NSArray
//                                               arrayWithObjects:rightNegativeSpacer,rightItem, nil];
    
   self.childrenTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kd_StatusBarAndNaviHeight + 48, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - kd_StatusBarAndNaviHeight - 48 - 45)];
    self.childrenTableView.backgroundColor = self.view.backgroundColor;
    self.childrenTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.childrenTableView.delegate = self;
    self.childrenTableView.dataSource = self;
    [self.view addSubview:self.childrenTableView];
    
    _organiztionSelectView = [[KDOrganizationSelectView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, CGRectGetWidth(self.view.frame), 48)];
    _organiztionSelectView.delegate = self;
    _organiztionSelectView.dataDelegate = self;
    _organiztionSelectView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_organiztionSelectView];
    _organiztionSelectView.hidden = YES;
     haveNewItemPush = YES;
    
//    _personIdArray = [[NSMutableArray alloc]init];
    [self setupLeftBarButtonItems];
}

- (void)setupLeftBarButtonItems {
    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Close")style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
    
    [closeItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[backBtn titleColorForState:UIControlStateNormal] , NSFontAttributeName:backBtn.titleLabel.font } forState:UIControlStateNormal];
    [closeItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[backBtn titleColorForState:UIControlStateHighlighted] , NSFontAttributeName:backBtn.titleLabel.font} forState:UIControlStateHighlighted];
    
    [closeItem setTitlePositionAdjustment:UIOffsetMake(-8, 0) forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:backBtn], closeItem];
    
    //小于8.1系统 ，leftBarButtonItems 对于上面2种不同的item创建方式放置位置不一样
    if ([UIDevice currentDevice].systemVersion.doubleValue <= 8.1) {
        [backBtn setContentEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 0)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DLog(@"XTOrganizationViewController 内存警告");
    // Dispose of any resources that can be recreated.
}

#pragma mark -- setNavigationItem
- (void)setBackItem {
    NSString *backTitle = ASLocalizedString(@"Global_GoBack");
    if (_isFromAddressBook) {
        if ([self.orgTreeData isRootOrganization]) {
            backTitle = ASLocalizedString(@"XTContactContentViewController_Contact");
        }
    }
    UIButton *btn = [UIButton backBtnInWhiteNavWithTitle:backTitle];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn]];
}


#pragma mark - get

- (XTContactEmployeesView *)leadersView
{
    if (_leadersView == nil) {
        _leadersView = [[XTContactEmployeesView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.childrenTableView.frame), 96.0f)];
        _leadersView.controller = self;
        _leadersView.delegate = self;
    }
    return _leadersView;
}

- (XTOpenSystemClient *)orgClient
{
    if (_orgClient == nil) {
        _orgClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(orgTreeInfoDidReceived:result:)];
    }
    return _orgClient;
}

-(ContactClient *)contactClient
{
    
    if (_contactClient == nil) {
        _contactClient = [[ContactClient alloc] initWithTarget:self action:@selector(orgTreeInfoDidReceived:result:)];
    }
    return _contactClient;
}

- (MBProgressHUD *)hud
{
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    return _hud;
}
- (NSMutableArray *)organiztionStack
{
    if (_organiztionStack == nil) {
        _organiztionStack = [NSMutableArray array];
    }
    return _organiztionStack;
}
#pragma mark - orgTree

- (void)orgTreeInfo:(NSString *)orgId
{
    if (self.isRequesting) {
        return;
    }
    
    self.isRequesting = YES;
    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    
    // 是页面是收起状态
    isFold = YES;
    if ([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]) {
        [self.contactClient orgTreeInfoWithOrgId:orgId andPartnerType:self.partnerType isFilter:NO];
    }else{
        [self.orgClient orgTreeInfoWithOrgId:orgId];
    }
}

- (void)orgTreeInfoDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    self.isRequesting = NO;
    
    if (client.hasError || !result.success) {
        NSString *error = ASLocalizedString(@"KDChooseOrganizationViewController_Error");
        if (client.hasError) {
            error = client.errorMessage;
        } else {
            error = result.error;
        }
        [self.hud setLabelText:error];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    
    [self.hud hide:YES];
    
    XTOrgTreeDataModel *orgTreeDM = [[XTOrgTreeDataModel alloc] initWithDictionary:result.data];
    _orgTreeData = orgTreeDM;
    unallotPersonCount = [NSString stringWithFormat:@"%ld",[orgTreeDM.unallotPersons count]];
    
    if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
        if ((orgTreeDM.personIds == nil) || [orgTreeDM.personIds count] == 0) {
            [_dataArray removeAllObjects];
        }
    }
    
    //后台说英文翻译改不了，那就前端特殊判断一下
    if([orgTreeDM.orgName isEqualToString:@"商务伙伴"])
        orgTreeDM.orgName = ASLocalizedString(@"XTChooseContentViewController_partner");

    if (haveNewItemPush) {
        //如果非组织架构进来，则把上级加进去
        KDOrgTreeItemDataModel *itemData = [KDOrgTreeItemDataModel new];
        itemData.orgId = _orgTreeData.orgId;
        itemData.orgName = [_orgTreeData.orgName copy];
        [[self organiztionStack] addObject:itemData];
        //解决个人详情部门点进来上面混乱问题  不知道有没有其他坑
        if (!_isFromAddressBook && orgTreeDM.parentId.length > 0) {
            KDOrgTreeItemDataModel *itemData = [KDOrgTreeItemDataModel new];
            KDOrgTreeItemDataModel *lastItemData = nil;
            if ([_organiztionStack count] > 1) {
                lastItemData = [_organiztionStack objectAtIndex:[_organiztionStack count] - 2];
            }
            
            if (![_orgTreeData.parentId isEqualToString:lastItemData.orgId]) {
                itemData.orgId = _orgTreeData.parentId;
                itemData.orgName = [_orgTreeData.parentName copy];
                
                [[self organiztionStack] insertObject:itemData atIndex:0];
            }
        }
        haveNewItemPush = NO;
    }

    [self reloadViews];
    
    
    
    NSLog(@"%@",self.orgTreeData);
    
    /**
     *  是还没有设置组织架构，要进行一下操作
     */
    static BOOL haveNoItems = NO;
//    if (self.isFromAddressBook == YES && [self.orgTreeData isRootOrganization] && [self.orgTreeData isLeafOrganization]) {
//        if (_organiztionStack && [_organiztionStack count] > 1) {
//            return;
//        }
////        ContactStyle style = [[BOSSetting sharedSetting]contactStyle];
////        PersonSimpleDataModel * currentUser = [[BOSConfig sharedConfig]currentUser];
////        if (style == ContactStyleShowAll) {
////            KDNotOrganizationView * notOrgView = [[KDNotOrganizationView alloc]initWithFrame:self.view.bounds Style:style isAdmin:currentUser.isAdmin];
////            if (currentUser.isAdmin == YES) {
////                __weak KDNotOrganizationView * weakView = notOrgView;
////                __weak XTOrganizationViewController * weakVC = self;
////                [notOrgView setHandleBlock:^{
////                    [weakView removeFromSuperview];
////                    [weakVC openOrganizationLightApp];
////                    weakVC.isFromAddressBook = YES;
////                    weakVC.shouldRequestData = YES;
////                }];
////            }
////            
////            [self.view addSubview:notOrgView];
////        }else{
////            KDNotOrganizationView * notOrgView = [[KDNotOrganizationView alloc]initWithFrame:[KDWeiboAppDelegate getAppDelegate].window.bounds Style:style isAdmin:currentUser.isAdmin];
////            if (notOrgView) {
////                if (currentUser.isAdmin == YES) {
////                    __weak XTOrganizationViewController * weakVC = self;
////                    __weak KDNotOrganizationView * weakView = notOrgView;
////                    [notOrgView setHandleBlock:^{
////                        [weakView removeFromSuperview];
////                        [weakVC openOrganizationLightApp];
////                        weakVC.isFromAddressBook = YES;
////                        weakVC.shouldRequestData = YES;
////
////
////                    }];
////                }
////                
////                [[KDWeiboAppDelegate getAppDelegate].window addSubview:notOrgView];
////            }
////        }
//        self.isFromAddressBook = NO;
//    }else if (haveNoItems)
//    {
//        haveNoItems = NO;
//    }
    
    [self setGestureEnable:([self.orgTreeData isRootOrganization] || _isSingle)];
    

}

//- (NSArray *)personIdsFilter:(NSArray *)personIds
//{
//    if ([personIds count] == 0) {
//        return personIds;
//    }
//    
//    //查询数据库中是否都存在
//    NSArray *personNewIds = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonIdsWithPersonIds:personIds];
//    if ([personIds count] == [personNewIds count]) {
//        return personIds;
//    }
//    
//    NSMutableArray *personNeedDeleteIds = [NSMutableArray array];
//    [personIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if (![personNewIds containsObject:obj]) {
//            [personNeedDeleteIds addObject:obj];
//        }
//    }];
//    
//    NSMutableArray *result = [NSMutableArray arrayWithArray:personIds];
//    [result removeObjectsInArray:personNeedDeleteIds];
//    return result;
//}

- (void)reloadViews
{
    
    if ([self.orgTreeData.employees count] == 0
        && [self.orgTreeData.children count] == 0
        && [self.orgTreeData.leaders count] == 0) {
//        && (unallotPersonCount.length > 0 && unallotPersonCount.integerValue > 0)) {
        if(!noItemView)
        {
            noItemView = [[KDNoItemView alloc]initShowInView:self.view];
            [self.view insertSubview:editeFooterBarView aboveSubview:noItemView];
        }
    }
    else
    {
        [noItemView hiddenView];
        noItemView = nil;
    }
    
//    if ([self.orgTreeData isRootOrganization]) {
        self.navigationItem.title =(self.partnerType == 0? ASLocalizedString(@"KDChooseOrganizationViewController_Organtion"):ASLocalizedString(@"XTChooseContentViewController_partner"));
//    } else {
//        self.navigationItem.title = self.orgTreeData.orgName;
//    }
    [_organiztionSelectView reloadData];
    
    if([self.orgTreeData isRootOrganization])
    {
        [self setShowOrgTreeSelectView:NO];
    }
    else
    {
        [self setShowOrgTreeSelectView:YES];
    }
    
    if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
        if ([self.orgTreeData.personIds count] > 0 ){
            if (_dataArray) {
                [_dataArray removeAllObjects];
            }
            else {
                _dataArray = [[NSMutableArray alloc]init];
            }
            
            [_dataArray addObjectsFromArray:self.orgTreeData.personIds];
        }
    }else{
        if ([_orgTreeData.employees count] > 0 ){
            if (_dataArray) {
                [_dataArray removeAllObjects];
            }
            else {
                _dataArray = [[NSMutableArray alloc]init];
            }
            NSMutableArray *tempArray;
            if(tempArray){
                [tempArray removeAllObjects];
            }else{
                 tempArray = [[NSMutableArray alloc]init];
            }
            for (XTOrgPersonDataModel *personDetal in self.orgTreeData.employees) {
                PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:personDetal.personId];
                if (person) {
                    [tempArray addObject:personDetal];
                }
            }
            
            for(XTOrgPersonDataModel *personDetal in self.orgTreeData.leaders){
                NSInteger location = 0;
                for(int index = 0; index < [self.orgTreeData.personIds count]; index++){
                    if([personDetal.personId isEqualToString:[self.orgTreeData.personIds objectAtIndex:index]]){
                        location = index;
                        break;
                    }
                }
                [tempArray insertObject:personDetal atIndex:location];
            }
            
            [_dataArray addObjectsFromArray:tempArray];
        }else{ //解决组织架构下一层没有领导时重复显示上一层领导bug
            if (_dataArray) {
                [_dataArray removeAllObjects];
            }
        }

    }
    
    if (_isFromAddressBook) {
        [self setBackItem];
    }
    
    
    if ([self.orgTreeData.leaders count] > 0) {
        
        if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo])
        {
            self.leadersView.personIds = self.orgTreeData.leaders;
        }
        else
        {
            __block NSMutableArray *personIds = [NSMutableArray array];
            [self.orgTreeData.leaders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                XTOrgPersonDataModel *person = (XTOrgPersonDataModel *)obj;
                [personIds addObject:person.personId];
            }];
            self.leadersView.personIds = personIds;
        }
        haveLeaders = YES;
    }
    else {
        haveLeaders = NO;
    }

    haveFoldeCell = (self.orgTreeData.employees.count > foldSheild) && (self.orgTreeData.children.count != 0);
    [self.childrenTableView reloadData];
    [self.childrenTableView setContentOffset:CGPointMake(0, 0) animated:NO];
    [self addWaterMark];
}

- (void) addWaterMark
{
    if ([[BOSSetting sharedSetting] openWaterMark:WaterMarkTypeContact]) {
        [KDWaterMarkAddHelper coverOnView:self.view withFrame:self.view.frame];
    }
    else {
        [KDWaterMarkAddHelper removeWaterMarkFromView:self.childrenTableView];
    }

}
/**
 *  把包含PersonSimpleDataModel数组，分组为包含KDContactGroupDataMdeol的数组
 *
 *  @param persons 包含PersonSimpleDataModel数组
 *
 *  @return 包含KDContactGroupDataMdeol的数组
 */
-(NSArray *)groupArrayWithPersons:(NSArray *)persons{
    if ([persons count] == 0) {
        return nil;
    }
    NSMutableArray * contactArray = [NSMutableArray array];
    for (PersonSimpleDataModel * person in persons) {
        [contactArray addObject:person];
    }
    
    
    return contactArray;
    
}

/**
 *  设置组树的是否显示
 */
- (void)setShowOrgTreeSelectView:(BOOL)show
{
    if (show) {
        self.childrenTableView.frame = CGRectMake(0.0, kd_StatusBarAndNaviHeight + 48 + 8, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - kd_StatusBarAndNaviHeight - 48 - 8);
        _organiztionSelectView.hidden = NO;
    }
    else
    {
//        if (_managerSchema) {
//            self.childrenTableView.frame = CGRectMake(0.0, 64.0 + 8, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64.0  - 8 - 45);
//            _organiztionSelectView.hidden = YES;
//            return;
//        }
        self.childrenTableView.frame = CGRectMake(0.0, kd_StatusBarAndNaviHeight + 8.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - kd_StatusBarAndNaviHeight - 8.0);
        _organiztionSelectView.hidden = YES;
    }
    
}

#pragma  mark - IDOrganization Delegate Methods

- (void)organiztionSelectView:(KDOrganizationSelectView *)view didSelectedAtIndex:(NSUInteger)index
{
    if (index == _organiztionStack.count - 1) {
        return;
    }
//    [KDEventAnalysis event:event_contact_toast_tap];
    KDOrgTreeItemDataModel *selectItem = [_organiztionStack objectAtIndex:index];
    NSUInteger stackCount = _organiztionStack.count;
    for (NSInteger i = index + 1; i < stackCount; i++) {
        [_organiztionStack removeLastObject];
    }
    if (!_isFromAddressBook) {
        [_organiztionStack removeAllObjects];
        haveNewItemPush = YES;
    }
    [self orgTreeInfo:selectItem.orgId];
    //    haveNewItemPush = NO;
 
}

- (NSUInteger)numberOfItemsInOraganizationSelectView:(KDOrganizationSelectView *)view
{
    return [_organiztionStack count];
}

- (NSString *)organiztionSelectView:(KDOrganizationSelectView *)view itemViewAtIndex:(NSUInteger)index
{
    KDOrgTreeItemDataModel *item = [_organiztionStack objectAtIndex:index];
    return item.orgName;
}

#pragma mark - btn pressed

- (void)back:(UIButton *)btn
{
//by fangjiaxin 可能有坑 有待确定 160314
    
//    if(_isSingle) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    if (!_fromOrganization) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
    //非组织架构进来 则原路返回
    if (!_isFromAddressBook) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (_organiztionStack.count > 1) {
            [_organiztionStack removeLastObject];
            KDOrgTreeItemDataModel *selectItem = [_organiztionStack lastObject];
            [self orgTreeInfo:selectItem.orgId];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
}

- (void)backToRoot:(UILongPressGestureRecognizer *)longPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)close:(UIButton *)btn
{
    if (hintView) {
        [hintView removeFromSuperview];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setGestureEnable:(BOOL)enable
{
    for (UIGestureRecognizer *gesture in self.view.gestureRecognizers) {
        gesture.enabled = enable;
    }
}
#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSInteger count = [_dataArray count];
//    if ([self.orgTreeData isLeafOrganization]) {
//        return [self.dataArray count];
//    }
//    return [self.orgTreeData.children count] + count;
    if (section == 0) {
        if ([self.orgTreeData.leaders count] > 0) {
            return 1;
        }
        return 0;
    }
    if (section == 1) {
        
        if ([self.orgTreeData.employees count] <= MinFoldCellNumber || self.orgTreeData.children.count == 0) {
            return [self.orgTreeData.employees count];
        }
        if (isFold) {
            return foldSheild + 1;
        }
        return [self.orgTreeData.employees count] + 1;
    }
    if (section == 2) {
        return [self.orgTreeData.children count];
    }
    if (section == 3 ) {
        //
        if (unallotPersonCount.length > 0 && unallotPersonCount.integerValue > 0) {
            return 1;
        }
        //        if ([self.orgTreeData.unallotPersons count] > 0) {
        //            return 1;
        //        }
    }
    return 0;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 0;
    if (section == 0) {
        return    [self.orgTreeData.leaders count] > 0  ?  22.0 : 0.0;
    }
    if (section == 1 ) {
        return   [self.orgTreeData.employees count] > 0  ?  22.0 : 0.0;;
    }
    if (section == 2) {
        return  [self.orgTreeData.children count] > 0  ?  22.0 : 0.0;
    }
    
    if (section == 3) {
        return  0.0;
    }
    return 0.0;

}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == 0 && self.orgTreeData.leaders.count > 0)
    {
        if (self.orgTreeData.employees.count > 0 ||
            self.orgTreeData.children.count > 0 ||
            ( self.orgTreeData.unallotPersons.count > 0))
        {
            return [NSNumber kdDistance2];
        }
        return 0;
    }
    
    if (section == 1 && self.orgTreeData.employees.count > 0) {
        if (self.orgTreeData.children.count > 0 ||  ( self.orgTreeData.unallotPersons.count > 0)) {
            return [NSNumber kdDistance2];
        }
        return 0;
    }
    if (section == 2 && self.orgTreeData.children.count > 0) {
        
        if ( unallotPersonCount.length > 0 && unallotPersonCount.integerValue > 0) {
            return [NSNumber kdDistance2];
        }
        return 0;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger count = [_dataArray count];
//    if (count > 0 && indexPath.row < count) {
//        return 68.f;
//    }
//    return 44.f;
    if (indexPath.section == 0) {
        return 96;
    }
    if (indexPath.section == 1)
    {
        NSInteger count =  [self.orgTreeData.employees count];
        if (!haveFoldeCell) {
            return 68;
        }
        BOOL isFoldCell = NO;
        if (count > foldSheild) {
            if (isFold && indexPath.row == foldSheild) {
                //折叠行
                isFoldCell = YES;
            }
            else if (!isFold && indexPath.row == count) {
                //展开行
                isFoldCell = YES;
            }
            if (isFoldCell) {
                return 44.0;
            }
        }
        if (!isFoldCell) {
            return 68;
        }
    }
//
    //子组织或者未分配部门的人员
    return 44;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *title = @"";
    if (section == 0 && [self.orgTreeData.leaders count] > 0) {
        title = ASLocalizedString(@"XTOrganizationViewController_Admin");
    }
    else if (section == 1 && [self.orgTreeData.employees count] > 0)
    {
        title = ASLocalizedString(@"XTOrganizationViewController_Person");
    }
    else if (section == 2 && [self.orgTreeData.children count] > 0)
    {
        title = ASLocalizedString(@"XTOrganizationViewController_Down");
    }
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), [self tableView:tableView heightForHeaderInSection:section])];
    titleView.backgroundColor = [UIColor kdSubtitleColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], 0, CGRectGetWidth(titleView.bounds) - 2 * [NSNumber kdDistance1], CGRectGetHeight(titleView.bounds))];
    label.backgroundColor = titleView.backgroundColor;
    label.textColor = FC1;
    label.font = FS6;
    label.text = title;
    
    [titleView addSubview:label];
    
    return titleView;

}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = [UIColor kdSubtitleColor];
    return footView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section  == 0) {
        static NSString *LeaderCellIdentifier = @"LeaderCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LeaderCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LeaderCellIdentifier];
            [cell addSubview:self.leadersView];
        }
        return cell;
    }
    if (indexPath.section == 1) {
        

        NSInteger count = [self.orgTreeData.employees count];
        if (count > foldSheild) {
            BOOL isFoldCell = NO;
            if (isFold && indexPath.row == foldSheild) {
                //折叠行
                isFoldCell = YES;
            }
            else if (!isFold && indexPath.row == count) {
                //展开行
                isFoldCell = YES;
            }
            if (isFoldCell && self.orgTreeData.children.count != 0) {
                static NSString *cellIdentifier = @"KDEmployeesFoldCellIdentifier";
                KDPersonFoldCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (!cell) {
                    cell = [[KDPersonFoldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                if (isFold) {
                    //                    cell.foldImageView.image = [UIImage imageNamed:@"person_detail_fold"];
                    [cell setTitle:ASLocalizedString(@"XTOrganizationViewController_More")];
                }
                else {
                    //                    cell.foldImageView.image = [UIImage imageNamed:@"person_detail_unfold"];
                    [cell setTitle:ASLocalizedString(@"XTOrganizationViewController_Up")];
                }
                return cell;
            }
        }
//        NSInteger count = [_dataArray count];
        if (count > 0 && indexPath.row < count) {
            static NSString *LeafCellIdentifier = @"LeafCellIdentifier";
            XTContactOrganPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:LeafCellIdentifier];
            if (cell == nil) {
                cell = [[XTContactOrganPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LeafCellIdentifier];
                CGRect unActivatedFrame = cell.headerImageView.unActivatedLabel.frame;
                unActivatedFrame.origin.x += 6;
                unActivatedFrame.origin.y += 6;
                cell.headerImageView.unActivatedLabel.frame = unActivatedFrame;
                

            }
            if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
                PersonSimpleDataModel * dataModel = [_dataArray objectAtIndex:indexPath.row];
                //            if (dataModel.isPartJob) {
                //                cell.showParttimeJob = YES;
                //            }
                cell.showManagerImage = YES;
                [cell setPerson:dataModel];
            }else{
                XTOrgPersonDataModel *orgPerson = [self.orgTreeData.employees objectAtIndex:indexPath.row];
                PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:orgPerson.personId];
                if (orgPerson.isPartJob == 1) {
                    //                cell.showParttimeJob = YES;
                    person.jobTitle = orgPerson.job;
                }else{
                    cell.showParttimeJob = NO;
                }
                cell.showManagerImage = YES;
                [cell setPerson:person];
            }
            cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
            cell.separatorLineInset = UIEdgeInsetsMake(0, kHeaderWidth_Big + 2 * 10, 0, 0);
            return cell;
        }
    }
   else if (indexPath.section == 2) {
       //子组织
       static NSString *CellIdentifier = @"CellIdentifier";
       KDOrganiztionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
       if (cell == nil) {
           cell = [[KDOrganiztionCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
       }
       XTOrgChildrenDataModel *child = [self.orgTreeData.children objectAtIndex:indexPath.row];
       
       if(child.partnerType == 1)
       {
           cell.imageView.image = [UIImage imageNamed:@"message_tip_shang_small"];
       }
       else
           cell.imageView.image = nil;
       cell.textLabel.text = child.orgName;
       
       //设置是否显示人数
       if ([[BOSSetting sharedSetting]showPersonCount]&& child.partnerType != 1 ) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", child.personCount];
       }
      
       cell.separatorLineStyle = (indexPath.row == [self.orgTreeData.children count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
       cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
       
//       [cell setEditingShowSytle:NO];
       

       return cell;
    }
    static NSString *CellIdentifier = @"CellIdentifier";
    
    KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
//    XTOrgChildrenDataModel *child = [self.orgTreeData.children objectAtIndex:indexPath.row - round];
    
    
    cell.textLabel.text =  ASLocalizedString(@"KDChooseOrganizationViewController_UnallocaledPerson");
    //设置是否显示人数
    if ([[BOSSetting sharedSetting]showPersonCount] && self.partnerType != 1 ) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)unallotPersonCount.integerValue];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
    cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    
    return cell;


}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        return;
    }
    if (indexPath.section == 1) {
        
        NSInteger count = [self.orgTreeData.employees  count];
        BOOL isFoldCell = NO;
        if (count > foldSheild) {
            if (isFold && indexPath.row == foldSheild) {
                //折叠行
                isFoldCell = YES;
            }
            else if (!isFold && indexPath.row == count) {
                //展开行
                isFoldCell = YES;
            }
            if (isFoldCell) {
                //                foldSheild += unFoldCellNumber;
                //                if (count > foldSheild)
                //                {
                //                    isFold = YES;
                //                }
                //                else
                //                {
                //                    isFold = NO;
                //                    foldSheild = MinFoldCellNumber - unFoldCellNumber;
                //                }
                isFold = !isFold;
//                [KDEventAnalysis event:event_contact_view_more];
//                [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
//                [self addWaterMark];
                [tableView reloadData];
                [self addWaterMark];
                return;
            }
        }
        
        id obj = [self.orgTreeData.employees objectAtIndex:indexPath.row];
        PersonSimpleDataModel *person = nil;
        if([obj isKindOfClass:[XTOrgPersonDataModel class]])
        {
            XTOrgPersonDataModel *orgPerson = [self.orgTreeData.employees objectAtIndex:indexPath.row];
            //NSInteger row = indexPath.row;
            person = [KDCacheHelper personForKey:orgPerson.personId];
        }
        else
            person = obj;
        
        if (person) {
//            [KDDetail toDetailWithPerson:person inController:self];
            XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc]initWithSimplePerson:person with:NO];
            personDetail.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:personDetail animated:YES];
        }
        return;
    }
    else if (indexPath.section == 2) {
        XTOrgChildrenDataModel *child = [self.orgTreeData.children objectAtIndex:indexPath.row];
        [self orgTreeInfo:child.orgId];
//        _isFromAddressBook = YES;
        haveNewItemPush = YES;
        return;
    }
//    else {
//        NSLog(@"%ld",(long)indexPath.row);
//        XTOrgChildrenDataModel *child = [self.orgTreeData.children objectAtIndex:indexPath.row - [_dataArray count]];
//        [self orgTreeInfo:child.orgId ];
//    }
    
    KDUnallotViewController *unallotViewController = [[KDUnallotViewController alloc]init];
    unallotViewController.orgPersons = self.orgTreeData.unallotPersons;
//    unallotViewController.title = ASLocalizedString(@"KDChooseOrganizationViewController_UnallocaledPerson");
    unallotViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:unallotViewController animated:YES];

}

-(void)tochatviewcontroller:(UIButton*)btn
{
    PersonSimpleDataModel*personData = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:[self.orgTreeData.personIds objectAtIndex:btn.tag]];
    [[KDWeiboAppDelegate getAppDelegate].XT timelineToChatWithPerson:personData];
}

-(void)tophoneviewcontroller:(UIButton*)btn
{
   PersonSimpleDataModel*personData = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:[self.orgTreeData.personIds objectAtIndex:btn.tag]];
    [[XTTELHandle sharedTELHandle] telWithPhoneNumbel:personData.defaultPhone];
}
/**
 *  进入设置组织架构的轻应用
 */
-(void)openOrganizationLightApp{
    NSString *appID = [[BOSSetting sharedSetting] groupManageAppId];
    if ([appID length] > 0 ) {
        KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:@"" appId:appID];
        webVC.title = ASLocalizedString(@"KDChooseOrganizationViewController_Setting");
        webVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}
- (void)personHeaderClicked:(XTPersonHeaderView *)headerView person:(PersonSimpleDataModel *)person
{
    XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc]initWithSimplePerson:person with:NO];
    personDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personDetail animated:YES];
}



@end
