//
//  KDChooseOrganizationViewController.m
//  kdweibo
//
//  Created by shen kuikui on 14-5-14.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDChooseOrganizationViewController.h"
#import "XTOrgTreeDataModel.h"
#import "ContactClient.h"
#import "XTSelectPersonsView.h"
#import "UIButton+XT.h"
#import "PersonSimpleDataModel.h"
#import "XTContactPersonMultipleChoiceCell.h"
#import "KDContactDepartmentMultipleChoiceCell.h"
#import "XTOrgCell.h"
#import "BOSConfig.h"
#import "KDWebViewController.h"
#import "KDNotOrganizationView.h"
#import "BOSSetting.h"
#import "JSBridgeChooseGroupTableViewCell.h"
#import "KDWaterMarkAddHelper.h"
#import "KDUnallotViewController.h"
#import "KDOrganizationSelectView.h"
#import "KDOrgTreeItemDataModel.h"
//#import "XTContactEmployeesView.h"

@interface KDChooseOrganizationViewController ()<UITableViewDataSource, UITableViewDelegate, XTSelectPersonsViewDataSource,JSBridgeChooseGroupTableViewCellDelegate,KDOrganizationSelectViewDataDelegate,KDOrganizationSelectViewDelegate>

@property (nonatomic, copy) NSString *orgId;
@property (nonatomic, strong) XTOpenSystemClient *orgClient;
@property (nonatomic, strong) ContactClient *contactClient;
@property (nonatomic, strong) XTOrgTreeDataModel *orgTreeData;
@property (nonatomic, strong) KDContactDepartmentMultipleChoiceCell *departmentSelectedCell;

@property (nonatomic, strong) UIView *viewHideToolBar;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL     isRequesting;
@property (nonatomic, assign) BOOL     isForCurrentUser;
@property (nonatomic, strong) UILabel *sureButton;
@property (nonatomic, strong) UILabel *groupLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIScrollView *bottomScrollView;
@property (nonatomic, strong) NSMutableArray *selectedOrgModelMuti;   //存放选中的参数
@property (nonatomic, strong) NSMutableArray *tempStoreWhiteListName;   //请求以获得
@property (nonatomic, strong) NSMutableSet *cellSet;
@property (nonatomic, strong) NSMutableSet *cellSetForPerson;
@property (nonatomic, strong) XTOpenSystemClient *myClient;
@property (nonatomic, assign) NSInteger unallotPersonCount;
@property (nonatomic, strong) KDOrganizationSelectView *organiztionSelectView;
@property (nonatomic, strong) NSMutableArray *organiztionStack;
//@property (nonatomic, strong) XTContactEmployeesView *leadersView; //没用，先屏蔽一段时间，没问题就删除相关代码
@end

@implementation KDChooseOrganizationViewController
- (id)init
{
    self = [self initWithOrgId:@"" isForCurrentUser:NO];
    if(self) {
        
    }
    
    return self;
}

- (id)initWithOrgId:(NSString *)orgId isForCurrentUser:(BOOL)yesOrNo
{
    self = [super init];
    if(self) {
        _orgId = [orgId copy];
        _isForCurrentUser = yesOrNo;
        _blockCurrentUser = NO;
        _pType = 1;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    self.cellSetForPerson = [NSMutableSet set];
    
    if (self.JSBridgeType == selectOrg || self.JSBridgeType == selectDepts) {
        self.cellSet = [NSMutableSet set];
        self.selectedOrgModelMuti = [NSMutableArray array];
        self.tempStoreWhiteListName = [NSMutableArray array];
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - CGRectGetHeight(self.selectedPersonsView.frame)) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor kdBackgroundColor1];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
        _tableView.rowHeight = 65.0;
        [self.view addSubview:_tableView];
        [self.tableView registerClass:[JSBridgeChooseGroupTableViewCell class] forCellReuseIdentifier:@"JSBridgeChooseGroupTableViewCell"];
        
        if (self.whiteList != nil) {
            self.myClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(whiteListDidReceived:result:)];
            for (NSInteger i = 0; i < self.whiteList.count; i++) {
                [self.myClient orgTreeInfoWithOrgId:self.whiteList[i]];
            }
        }
        return;
    }
    // Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)- CGRectGetHeight(self.selectedPersonsView.frame)) style:UITableViewStylePlain];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Close")style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
    [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
    
    self.organiztionSelectView = [[KDOrganizationSelectView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, CGRectGetWidth(self.view.frame), 48)];
    self.organiztionSelectView.delegate = self;
    self.organiztionSelectView.dataDelegate = self;
    self.organiztionSelectView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.organiztionSelectView];
    self.organiztionSelectView.hidden = YES;
}

- (void)setShowOrgTreeSelectView:(BOOL)show
{
    if (show) {
        if (@available(iOS 11.0, *)) {
            self.tableView.frame = CGRectMake(0.0, CGRectGetHeight(self.organiztionSelectView.frame) + kd_StatusBarAndNaviHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.organiztionSelectView.frame) - CGRectGetHeight(self.selectedPersonsView.frame) - kd_StatusBarAndNaviHeight);
        } else {
            self.tableView.frame = CGRectMake(0.0, CGRectGetHeight(self.organiztionSelectView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.organiztionSelectView.frame) - CGRectGetHeight(self.selectedPersonsView.frame));
        }
        
        self.organiztionSelectView.hidden = NO;
    }
    else
    {
        self.tableView.frame = CGRectMake(0.0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)- CGRectGetHeight(self.selectedPersonsView.frame));
        self.organiztionSelectView.hidden = YES;
    }
    [self.organiztionSelectView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationStyle:KDNavigationStyleNormal];
    
    self.backButton = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Goack")];
    [self.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(backToRoot:)];
    [self.backButton addGestureRecognizer:longPress];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer.width = kLeftNegativeSpacerWidth;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,backItem, nil];
    
    
    if(_isForCurrentUser) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setImage:[UIImage imageNamed:@"head_btn_organization"] forState:UIControlStateNormal];
        [rightBtn setImage:[UIImage imageNamed:@"head_btn_organization_press"] forState:UIControlStateHighlighted];
        [rightBtn sizeToFit];
        [rightBtn addTarget:self action:@selector(showAll:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *negativeSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpace.width = kRightNegativeSpacerWidth;
        UIBarButtonItem *allItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItems = @[negativeSpace, allItem];
    }
    
    [self.selectedPersonsView addDataSource:self];
    
    if (self.JSBridgeType == selectOrg || self.JSBridgeType == selectDepts) {
        self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.bounds.size.width, 44)];
        [self.bottomView setBackgroundColor:[UIColor colorWithPatternImage:[XTImageUtil tabBarBackgroundImage]]];
        [self.view addSubview:self.bottomView];
        
        UIImage *bgImage = [UIImage imageNamed:@"contact_start_v3.png"];
        bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width*0.5 topCapHeight:bgImage.size.height*0.5];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(JSBridgeSureClicked:)];
        self.sureButton = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 75, 4, 70, 36)];
        [self.sureButton setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
        [self.sureButton setFont:[UIFont systemFontOfSize:17]];
        [self.sureButton setTextAlignment:NSTextAlignmentCenter];
        [self.sureButton setTextColor:[UIColor whiteColor]];
        [self.sureButton setText:ASLocalizedString(@"KDChooseOrganizationViewController_Sure")];
        [self.sureButton addGestureRecognizer:tap];
        [self.sureButton setUserInteractionEnabled:YES];
        [self.bottomView addSubview:self.sureButton];
        
        CALayer *layer = self.sureButton.layer;
        [layer setCornerRadius:5];
        [layer setMasksToBounds:YES];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 4, 40, 36)];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setText:ASLocalizedString(@"KDChooseOrganizationViewController_Choosed")];
        [self.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [self.bottomView addSubview:self.titleLabel];
        
        self.groupLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 130, 36)];
        [self.groupLabel setBackgroundColor:[UIColor clearColor]];
        [self.groupLabel setFont:[UIFont systemFontOfSize:17]];
        [self.groupLabel setText:[NSString stringWithFormat:@""]];
        
        self.bottomScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(50, 4, self.view.frame.size.width - 130, 36)];
        [self.bottomScrollView setBackgroundColor:[UIColor clearColor]];
        [self.bottomScrollView setBounces:NO];
        [self.bottomScrollView setShowsHorizontalScrollIndicator:NO];
        [self.bottomScrollView setContentSize:CGSizeMake(self.view.frame.size.width - 130, 36)];
        [self.bottomScrollView addSubview:self.groupLabel];
        
        [self.bottomView addSubview:self.bottomScrollView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self orgTreeInfo:self.orgId];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.selectedPersonsView removeDataSource:self];
    
    [super viewDidDisappear:animated];
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.viewHideToolBar) {
        [self.viewHideToolBar removeFromSuperview];
    }
}

- (void)close:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    DLog(@"KDChooseOrganizationViewController 内存警告");
}

-(void)whiteListDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result {
    XTOrgTreeDataModel *orgTreeDM = [[XTOrgTreeDataModel alloc] initWithDictionary:result.data];
    [self.selectedOrgModelMuti addObject:orgTreeDM];
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

- (BOOL)shouldShowDepartmentChoice
{
    return _orgTreeData.children.count == 0;
}

- (BOOL)isAllSelected
{
    
    if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
        if(_orgTreeData.allPersons.count == 0)
            return NO;
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (int i = 0; i < self.selectedPersonsView.persons.count; i++) {
            PersonSimpleDataModel *selectPerson = self.selectedPersonsView.persons[i];
            dic[selectPerson.personId] = @"placeholderValue";
        }
        
        if(![BOSSetting sharedSetting].supportNotMobile || self.selectedPersonsView.isFromTask)
        {
            for (int j = 0; j < _orgTreeData.allPersons.count; j++) {
                PersonSimpleDataModel *person = _orgTreeData.allPersons[j];
                if (![dic[person.personId] isEqualToString:@"placeholderValue"] && [person xtAvailable]) {
                    return NO;
                }
            }
        }
        else
        {
            for (int j = 0; j < _orgTreeData.allPersons.count; j++) {
                PersonSimpleDataModel *person = _orgTreeData.allPersons[j];
                if (![dic[person.personId] isEqualToString:@"placeholderValue"]) {
                    return NO;
                }
            }
        }
        return YES;
        
//        for(PersonSimpleDataModel *personId in _orgTreeData.allPersons) {
//            BOOL isExist = NO;
//            for(PersonSimpleDataModel *person in self.selectedPersonsView.persons) {
//                if([personId.personId isEqualToString:person.personId]) {
//                    isExist = YES;
//                    break;
//                }
//            }
//            
//            if(!isExist) {
//                return NO;
//            }
//        }
    }else{
        for(NSString *personId in _orgTreeData.personIds) {
            BOOL isExist = NO;
            for(PersonSimpleDataModel *person in self.selectedPersonsView.persons) {
                if([personId isEqualToString:person.personId]) {
                    isExist = YES;
                    break;
                }
            }
            
            if(!isExist) {
                return NO;
            }
        }
    }
    
    return YES;
}
#pragma mark - get

//- (XTContactEmployeesView *)leadersView
//{
//    if (_leadersView == nil) {
//        _leadersView = [[XTContactEmployeesView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 96.0f)];
//        _leadersView.controller = self;
//        _leadersView.delegate = self;
//    }
//    return _leadersView;
//}
#pragma mark - orgTree


- (NSMutableArray *)organiztionStack
{
    if (_organiztionStack == nil) {
        _organiztionStack = [[NSMutableArray alloc] init];
    }
    return _organiztionStack;
}

- (void)orgTreeInfo:(NSString *)orgId
{
    if (self.isRequesting) {
        return;
    }
    
    self.isRequesting = YES;
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if(!hud) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [hud setMode:MBProgressHUDModeIndeterminate];
    [hud show:YES];
    
    
    if ([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]) {
        [self.contactClient orgTreeInfoWithOrgId:orgId andPartnerType:self.partnerType isFilter:NO];
    }else{
        [self.orgClient orgTreeInfoWithOrgId:orgId];
    }
}

- (void)orgTreeInfoDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    self.isRequesting = NO;
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    
    
    if (client.hasError || !result.success) {
        NSString *error = ASLocalizedString(@"KDChooseOrganizationViewController_Error");
        if (client.hasError) {
            error = client.errorMessage;
        } else {
            error = result.error;
        }
        
        if(!hud) {
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        
        [hud setLabelText:error];
        [hud setMode:MBProgressHUDModeText];
        [hud hide:YES afterDelay:1.0];
        
        return;
    }
    
    [hud hide:YES];
    
    XTOrgTreeDataModel *orgTreeDM = [[XTOrgTreeDataModel alloc] initWithDictionary:result.data];
    orgTreeDM.isFilterTeamAcc = self.isFilterTeamAcc;
    
    self.orgTreeData = orgTreeDM;
    [self filterOrgTreeData];
    
     _unallotPersonCount = [orgTreeDM.unallotPersons count];
    
    //架构树
    KDOrgTreeItemDataModel *itemData = [KDOrgTreeItemDataModel new];
    itemData.orgId = _orgTreeData.orgId;
    itemData.orgName = [_orgTreeData.orgName copy];
    if(![self.organiztionStack containsObject:itemData])
        [self.organiztionStack addObject:itemData];

    
    [self reloadViews];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
//    /**
//     *  是还没有设置组织架构，要进行一下操作
//     */
//    if ([self.orgTreeData isRootOrganization] && [self.orgTreeData isLeafOrganization]) {
//        ContactStyle style = [[BOSSetting sharedSetting]contactStyle];
//        PersonSimpleDataModel * currentUser = [[BOSConfig sharedConfig]currentUser];
//        if (style == ContactStyleShowAll) {
//            KDNotOrganizationView * notOrgView = [[KDNotOrganizationView alloc]initWithFrame:self.view.bounds Style:style isAdmin:currentUser.isAdmin];
//            if (currentUser.isAdmin == YES) {
//                KDNotOrganizationView * weakView = notOrgView;
//                KDChooseOrganizationViewController * weakVC = self;
//                [notOrgView setHandleBlock:^{
//                    [weakView removeFromSuperview];
//                    [weakVC openOrganizationLightApp];
//                }];
//            }
//            
//            [self.view addSubview:notOrgView];
//            
//            [self hideToolBar];
//
//        }else{
//            
//            [self showToolBar];
//            
//            KDNotOrganizationView * notOrgView = [[KDNotOrganizationView alloc]initWithFrame:[KDWeiboAppDelegate getAppDelegate].window.bounds Style:style isAdmin:currentUser.isAdmin];
//            if (notOrgView) {
//                if (currentUser.isAdmin == YES) {
//                    KDChooseOrganizationViewController * weakVC = self;
//                    KDNotOrganizationView * weakView = notOrgView;
//                    [notOrgView setHandleBlock:^{
//                        [weakView removeFromSuperview];
//                        [weakVC openOrganizationLightApp];
//                    }];
//                }
//                
//                [[KDWeiboAppDelegate getAppDelegate].window addSubview:notOrgView];
//            }
//        }
//    }

    
}

- (UIView *)viewHideToolBar
{
    if (!_viewHideToolBar) {
        _viewHideToolBar = [[UIView alloc]initWithFrame:CGRectMake(0, self.navigationController.view.frame.size.height - 44, ScreenFullWidth, 44)];
        _viewHideToolBar.backgroundColor = BOSCOLORWITHRGBA(0xEAEAEA, 1.0);
        _viewHideToolBar.hidden = YES;
        [self.navigationController.view addSubview:_viewHideToolBar];
    }
    return _viewHideToolBar;
}

// 隐藏选人工具栏
- (void)hideToolBar
{
    self.viewHideToolBar.hidden = NO;
}

- (void)showToolBar
{
    self.viewHideToolBar.hidden = YES;
}

/**
 *  进入设置组织架构的轻应用
 */
- (void)openOrganizationLightApp{
    NSString *appID = [[BOSSetting sharedSetting] groupManageAppId];
    if ([appID length] > 0 ) {
        KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:@"" appId:appID];
        webVC.title = ASLocalizedString(@"KDChooseOrganizationViewController_Setting");
        webVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webVC animated:YES];
    }
    
    
    
}

- (void)filterOrgTreeData
{
//    if(_blockCurrentUser) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF.personId == %@)", [BOSConfig sharedConfig].user.userId];
//        NSArray *filterArray = [self.orgTreeData.personIds filteredArrayUsingPredicate:predicate];
//        self.orgTreeData.personIds = filterArray;
//    }
    //屏蔽自己，add  by li.wenjie
    if (_blockCurrentUser) {
        
        if(self.orgTreeData.personIds.count > 0)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId != %@", [BOSConfig sharedConfig].user.userId];
            NSArray *filterArray = nil;
            if([self.orgTreeData.personIds.firstObject isKindOfClass:[NSString class]])
            {
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.orgTreeData.personIds];
                [tempArray removeObject:[BOSConfig sharedConfig].user.userId];
                filterArray =  [NSArray arrayWithArray:tempArray];
            }
            else {
                filterArray = [self.orgTreeData.personIds filteredArrayUsingPredicate:predicate];
            }
            self.orgTreeData.personIds = filterArray;
            
            NSMutableArray *allPersonsMutableArr = [NSMutableArray array];
            [allPersonsMutableArr addObjectsFromArray:filterArray];
            [allPersonsMutableArr addObjectsFromArray:self.orgTreeData.leaders];
            self.orgTreeData.allPersons = allPersonsMutableArr;
        }
        
        if ( _unallotPersonCount > 0)
        {
            NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"personId != %@", [BOSConfig sharedConfig].user.userId];
            NSArray *filterArray2 = nil;
            if([self.orgTreeData.unallotPersons.firstObject isKindOfClass:[NSString class]])
            {
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.orgTreeData.unallotPersons];
                [tempArray removeObject:[BOSConfig sharedConfig].user.userId];
                filterArray2 =  [NSArray arrayWithArray:tempArray];
            }
            else
                filterArray2 =[self.orgTreeData.unallotPersons filteredArrayUsingPredicate:predicate2];

            self.orgTreeData.unallotPersons = filterArray2;
        }
    }
}

- (void)reloadViews
{
    if ([self.orgTreeData.employees count] == 0
        && [self.orgTreeData.children count] == 0
        && [self.orgTreeData.leaders count] == 0) {
        //        && (unallotPersonCount.length > 0 && unallotPersonCount.integerValue > 0)) {
        if(!self.noItemView)
        {
            self.noItemView = [[KDNoItemView alloc]initShowInView:self.view];
            [self.view addSubview:self.noItemView];
            [self.view bringSubviewToFront:self.noItemView];
        }
    }
    else
    {
        [self.noItemView hiddenView];
        self.noItemView = nil;
    }

    //组织树
    if(self.organiztionStack.count<=1)
    {
        [self setShowOrgTreeSelectView:NO];
    }
    else
    {
        [self setShowOrgTreeSelectView:YES];
    }

    
    
    if ([self.orgTreeData isRootOrganization]) {
        self.navigationItem.title =(self.partnerType == 1?ASLocalizedString(@"XTChooseContentViewController_partner"):ASLocalizedString(@"KDChooseOrganizationViewController_Organtion"));
//        [self.navigationItem setTitle:ASLocalizedString(@"组织架构")forceRebuild:YES];
    } else {
        self.navigationItem.title = self.orgTreeData.orgName;
    }
    if ([self.orgTreeData.leaders count] > 0) {
        
        if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo])
        {
//            self.leadersView.personIds = self.orgTreeData.leaders;
        }
        else
        {
            __block NSMutableArray *personIds = [NSMutableArray array];
            [self.orgTreeData.leaders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                XTOrgPersonDataModel *person = (XTOrgPersonDataModel *)obj;
                [personIds addObject:person.personId];
            }];
//            self.leadersView.personIds = personIds;
        }
    }


    [self.tableView reloadData];
    
    
    //水印
    if ([[BOSSetting sharedSetting] openWaterMark:WaterMarkTypeContact]) {
        [KDWaterMarkAddHelper coverOnView:self.view withFrame:self.view.frame];
    }
    else {
        [KDWaterMarkAddHelper removeWaterMarkFromView:self.tableView];
    }
}


#pragma mark - btn pressed
- (void)showAll:(UIButton *)btn
{
    self.isForCurrentUser = NO;
    self.navigationItem.rightBarButtonItems = nil;
    [self orgTreeInfo:@""];
}

- (void)back:(UIButton *)btn
{
    if ([self.orgTreeData isRootOrganization] || ([[BOSConfig sharedConfig].user.orgId isEqualToString:_orgTreeData.orgId] && _isForCurrentUser) || self.orgTreeData.parentId.length == 0 || self.organiztionStack.count == 1) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {
        
        [self.organiztionStack removeLastObject];
        if(self.organiztionStack.count>0)
            [self.organiztionStack removeLastObject];
            
        [self orgTreeInfo:self.orgTreeData.parentId];
        
    }
    
}

- (void)backToRoot:(UILongPressGestureRecognizer *)longPress
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableView Delegate/Datasource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.JSBridgeType == selectOrg || self.JSBridgeType == selectDepts) {
        return 1;
    }
    else {
        int count = 4;
        
        if (_orgTreeData.unallotPersons.count > 0) {
            count += 1;
        }
        return count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.JSBridgeType == selectOrg || self.JSBridgeType == selectDepts)
    {
        if (self.blackList.count > 0)
        {
            NSMutableArray *tempArray = [NSMutableArray array];
            
            BOOL hasOrNot;
            for (NSInteger i = 0; i < _orgTreeData.children.count; i++)
            {
                hasOrNot = NO;
                for (NSInteger j = 0; j < self.blackList.count; j++)
                {
                    if ([self.blackList[j] isEqualToString:[_orgTreeData.children[i] orgId]]) hasOrNot = YES;
                }
                if (hasOrNot == NO) [tempArray addObject:_orgTreeData.children[i]];
            }
            
            self.orgTreeData.children = tempArray;
        }
        return _orgTreeData.children.count;
    }
    else if (self.JSBridgeType == selectPersons)
    {
        if(section == 0)
        {
            if (self.JSBridgeSelectPersonsBlackList.count > 0)
            {
                NSArray *oidArray = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithOids:self.JSBridgeSelectPersonsBlackList];
                
                BOOL hasOrNot;
                NSMutableArray *tempArray = [NSMutableArray array];
                for (NSInteger i = 0; i < _orgTreeData.personIds.count; i++) {
                    hasOrNot = NO;
                    for (NSInteger j = 0; j < oidArray.count; j++)
                    {
                        if ([[oidArray[j] personId] isEqualToString:_orgTreeData.personIds[i]]) hasOrNot = YES;
                    }
                    if (hasOrNot == NO) [tempArray addObject:_orgTreeData.personIds[i]];
                }
                _orgTreeData.personIds = tempArray;
            }
            return _orgTreeData.personIds.count;
        }
        
        if (section == 1) {
            return _orgTreeData.children.count;
        }
        
        return 1;
    }else{
        if (section == 0) { // 部门name
            if ([self shouldShowDepartmentChoice]) {
                return 1;
            } else {
                return 0;
            }
        }
        if (section == 1) { // 部门负责人
            return _orgTreeData.leaders.count;
        }
        if(section == 2 ) { // 部门负责人以外的其他成员
            return _orgTreeData.personIds.count;
        }
        if (section == 3){ // 部门下的子部门
            return _orgTreeData.children.count;
        }
        return 1; // 未分配人员部门
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.JSBridgeType == selectOrg || self.JSBridgeType == selectDepts) {
        return 65.0;
    }
    if (indexPath.section == 0) {
        if ([self shouldShowDepartmentChoice]) {
            return 50.0;
        } else {
            return 0.01f;
        }
    }
    if (indexPath.section == 1|| indexPath.section == 2) {
        //人员
        return 68.0;
    }
    
    // 部门
    return 44.0;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.JSBridgeType == selectOrg || self.JSBridgeType == selectDepts) {
        return 22.0;
    }
    if (section == 0) {
        return 0.01f;
    }
    if (section == 1 && [self.orgTreeData.leaders count] == 0) {
        return 0.01f;
    }
    if (section == 2  && [self.orgTreeData.employees count] == 0) {
        return  0.01f;
    }
    if (section == 3 && [self.orgTreeData.children count] == 0) {
        return 0.01f;
    }
    
    return 22.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!_orgTreeData) {
        return nil;
    }
    if (section == 0 && self.JSBridgeType != selectOrg && self.JSBridgeType != selectDepts) {
        return nil;
    }
    
    if (section == 1 && [self.orgTreeData.leaders count] > 0 && self.JSBridgeType != selectOrg && self.JSBridgeType != selectDepts) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 22)];
        view.backgroundColor = [UIColor kdSubtitleColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], CGRectGetMinY(view.frame), CGRectGetWidth(view.frame) - [NSNumber kdDistance1], CGRectGetHeight(view.frame))];
        label.text = ASLocalizedString(@"XTOrganizationViewController_Admin");
        label.font = FS7;
        label.textColor = FC1;
        label.backgroundColor = view.backgroundColor;
        [view addSubview:label];
        return view;
    }
    else if(section == 1)
        return nil;
    
    if(section == 2)
    {
        if ([self.orgTreeData.personIds count] == 0) {
            return nil;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 22)];
        view.backgroundColor = [UIColor kdSubtitleColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], CGRectGetMinY(view.frame), CGRectGetWidth(view.frame) - [NSNumber kdDistance1], CGRectGetHeight(view.frame))];
        label.text = ASLocalizedString(@"KDChooseOrganizationViewController_ChooeseFromCrurrent");
        label.font = FS7;
        label.textColor = FC1;
        label.backgroundColor = view.backgroundColor;
        [view addSubview:label];
        return view;
    }
    if (section == 3) {
        if ([self.orgTreeData.children count] == 0) {
            return nil;
        }
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 22)];
    view.backgroundColor = [UIColor kdSubtitleColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], CGRectGetMinY(view.frame), CGRectGetWidth(view.frame) - [NSNumber kdDistance1], CGRectGetHeight(view.frame))];
    label.text = ASLocalizedString(@"KDChooseOrganizationViewController_Choose");
    label.font = FS7;
    label.textColor = FC1;
    label.backgroundColor = view.backgroundColor;
    [view addSubview:label];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_orgTreeData) {
        static NSString *CellIdentifier = @"cell-nil";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = tableView.backgroundColor;
        }
        return cell;
    }
    if (self.JSBridgeType == selectOrg || self.JSBridgeType == selectDepts) {
        JSBridgeChooseGroupTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"JSBridgeChooseGroupTableViewCell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[JSBridgeChooseGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JSBridgeChooseGroupTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        XTOrgChildrenDataModel *child = [_orgTreeData.children objectAtIndex:indexPath.row];
        
        cell.groupLabelOne.text = child.orgName;
        cell.delegate = self;
        cell.model = child;
        
        BOOL isEqual = NO;
        for (NSInteger i = 0; i < self.selectedOrgModelMuti.count; i++)
        {
            if ([[self.selectedOrgModelMuti[i] orgId] isEqualToString:cell.model.orgId])
            {
                isEqual = YES;
            }
        }
        
        if (isEqual == YES)
        {
            [cell setChecked:YES];
        }
        else
        {
            [cell setChecked:NO];
        }
        
        [self.cellSet addObject:cell];
        return cell;
        
    }
    
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"cell-name";
        KDContactDepartmentMultipleChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[KDContactDepartmentMultipleChoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.frame = CGRectMake(0, 0, ScreenFullWidth, 50.0f);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.orgId = _orgTreeData.orgId;
        [cell setDepartmentName:_orgTreeData.orgName];
        cell.separateLineSpace = 0.0f;
        if([cell.orgId isEqualToString:self.departmentSelectedCell.orgId]) {
            self.departmentSelectedCell.checked = [self isAllSelected];
            [cell setChecked:self.departmentSelectedCell.checked animated:NO];
        } else {
            [cell setChecked:[self isAllSelected] animated:NO];
        }
        self.departmentSelectedCell = cell;
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [cell addGestureRecognizer:gesture];
        
        return cell;
    }
    
    if (indexPath.section  == 1) {
        // 负责人
        static NSString *CellIdentifier = @"cell-identifier";
        XTContactPersonMultipleChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell) {
            cell = [[XTContactPersonMultipleChoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.separateLineImageView.hidden = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.showGrayStyle = YES;
            cell.isFromTask = self.selectedPersonsView.isFromTask;
        }
        
        PersonSimpleDataModel *person;
        if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
            person = [self.orgTreeData.leaders objectAtIndex:indexPath.row];
        }else{
            person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:_orgTreeData.personIds[indexPath.row]];
        }
        cell.person = person;
        //语音会议邀请另外显示 置灰且不可点
        if (_inviteFromAgora) {
            cell.agoraSelected = [self.selectedAgoraPersons containsObject:person];
            cell.userInteractionEnabled = ![self.selectedAgoraPersons containsObject:person];
        }

        cell.checked = [self.selectedPersonsView.persons containsObject:person];
        cell.pType = self.pType;
        
        return cell;
    }
    
    if(indexPath.section == 2) {
        // 负责人以外的成员
        static NSString *CellIdentifier = @"cell-identifier";
        XTContactPersonMultipleChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell) {
            cell = [[XTContactPersonMultipleChoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.separateLineImageView.hidden = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.showGrayStyle = YES;
            cell.isFromTask = self.selectedPersonsView.isFromTask;
        }
        
        PersonSimpleDataModel *person;
        if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
            person = [self.orgTreeData.personIds objectAtIndex:indexPath.row];
        }else{
            person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:_orgTreeData.personIds[indexPath.row]];
        }
        cell.person = person;
        //语音会议邀请另外显示 置灰且不可点
        if (_inviteFromAgora) {
            cell.agoraSelected = [self.selectedAgoraPersons containsObject:person];
            cell.userInteractionEnabled = ![self.selectedAgoraPersons containsObject:person];
        }
        cell.checked = [self.selectedPersonsView.persons containsObject:person];
        cell.pType = self.pType;
        
        return cell;
    }
    if (indexPath.section == 3) {
        // 部门
        static NSString *CellIdentifier = @"CellIdentifier";
        XTOrgCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[XTOrgCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        XTOrgChildrenDataModel *child = [self.orgTreeData.children objectAtIndex:indexPath.row];
        
        if(child.partnerType == 1)
            cell.imageView.image = [UIImage imageNamed:@"message_tip_shang_small"];
        else
            cell.imageView.image = nil;
            
        cell.textLabel.text = child.orgName;
        if ([[BOSSetting sharedSetting]showPersonCount] && self.partnerType != 1 ) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",child.personCount];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        return cell;
    }
    
    //未分配部门的人员
    static NSString *CellIdentifier = @"UnallotCellIdentifier";
    KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text =  ASLocalizedString(@"KDChooseOrganizationViewController_UnallocaledPerson");
    //设置是否显示人数
    if ([[BOSSetting sharedSetting]showPersonCount] && self.partnerType != 1 ) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.orgTreeData.unallotPersons.count];//[_orgTreeData.unallotPersons count]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
    cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    [self.cellSetForPerson addObject:cell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.JSBridgeType == selectOrg || self.JSBridgeType == selectDepts) {
        JSBridgeChooseGroupTableViewCell *cell = (JSBridgeChooseGroupTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.checked == YES) {
            [cell setChecked:NO];
            
            if (self.isMult == NO) {
                [self.selectedOrgModelMuti removeAllObjects];
                [self setBottomViewNothingOrOneOrg:@""];
            }
            else {
                XTOrgChildrenDataModel *tempModel;
                for (NSInteger i = 0; i < self.selectedOrgModelMuti.count; i++) {
                    tempModel = self.selectedOrgModelMuti[i];
                    
                    if ([tempModel.orgName isEqualToString:cell.groupLabelOne.text]) {
                        [self.selectedOrgModelMuti removeObjectAtIndex:i];
                    }
                }
                
                [self setBottomViewWithSelectedOrg];
            }
        }
        else {
            [cell setChecked:YES];
            
            if (self.isMult == NO) {
                JSBridgeChooseGroupTableViewCell *tempCell;
                NSEnumerator *enumerator = [self.cellSet objectEnumerator];
                for (int i = 0; i < self.cellSet.count; i++) {
                    tempCell = [enumerator nextObject];
                    
                    if ([tempCell isEqual:cell]) {
                        continue;
                    }
                    else {
                        [tempCell setChecked:NO];
                    }
                }
                [self.selectedOrgModelMuti removeAllObjects];
                [self.selectedOrgModelMuti addObject:cell.model];
                [self setBottomViewNothingOrOneOrg:cell.groupLabelOne.text];
            }
            else {
                BOOL hasOrNot = NO;
                XTOrgChildrenDataModel *tempModel;
                for (NSInteger i = 0; i < self.selectedOrgModelMuti.count; i++) {
                    tempModel = self.selectedOrgModelMuti[i];
                    
                    if ([tempModel.orgName isEqualToString:cell.groupLabelOne.text]) {
                        hasOrNot = YES;
                    }
                }
                if (hasOrNot == NO) {
                    [self.selectedOrgModelMuti addObject:cell.model];
                }
                [self setBottomViewWithSelectedOrg];
            }
        }
        
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        return;
    }
    
    if (indexPath.section == 1) {
        // 负责人
        PersonSimpleDataModel *person;
        if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
            person = [self.orgTreeData.leaders objectAtIndex:indexPath.row];
        }else{
            person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:_orgTreeData.personIds[indexPath.row]];
        }
        
        //未激活不给点
        if((![BOSSetting sharedSetting].supportNotMobile || self.selectedPersonsView.isFromTask) && ![person xtAvailable])
            return;
        
        XTContactPersonMultipleChoiceCell *cell = (XTContactPersonMultipleChoiceCell *)[tableView cellForRowAtIndexPath:indexPath];
        BOOL checked = cell.checked;
        
        //单选判断的操作
        if (checked == NO && self.selectedPersonsView.isMult == NO && [self.selectedPersonsView.persons count] > 0) {
            return;
        }
        
        if (self.pType == 2 && person.partnerType == 1) {
            return;
        }
        if (self.pType == 3 && person.partnerType == 0) {
            return;
        }

        [cell setChecked:!checked animated:YES];
        
        if (checked) {
            [self.selectedPersonsView deletePerson:person];
        } else {
            [self.selectedPersonsView addPerson:person];
            
            if (self.adduserType) {
                [KDEventAnalysis event:event_session_adduser attributes:@{ label_session_adduser_type : self.adduserType }];
            }
        }
        return;

    }
    if(indexPath.section == 2 ){
        // 负责人以外的人员
        PersonSimpleDataModel *person;
        if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
            person = [self.orgTreeData.personIds objectAtIndex:indexPath.row];
        }else{
            person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:_orgTreeData.personIds[indexPath.row]];
        }
        
        //未激活不给点
        if((![BOSSetting sharedSetting].supportNotMobile || self.selectedPersonsView.isFromTask) &&![person xtAvailable])
            return;
        
        XTContactPersonMultipleChoiceCell *cell = (XTContactPersonMultipleChoiceCell *)[tableView cellForRowAtIndexPath:indexPath];
        BOOL checked = cell.checked;
        
        //单选判断的操作
        if (checked == NO && self.selectedPersonsView.isMult == NO && [self.selectedPersonsView.persons count] > 0) {
            return;
        }
        
        if (self.pType == 2 && person.partnerType == 1) {
            return;
        }
        if (self.pType == 3 && person.partnerType == 0) {
            return;
        }
        [cell setChecked:!checked animated:YES];
        
        if (checked) {
            [self.selectedPersonsView deletePerson:person];
        } else {
            [self.selectedPersonsView addPerson:person];
            
            if (self.adduserType) {
                [KDEventAnalysis event:event_session_adduser attributes:@{ label_session_adduser_type : self.adduserType }];
            }
        }
        return;
    }
    if (indexPath.section == 3 && self.orgTreeData.children.count > 0) {
        //部门
        XTOrgChildrenDataModel *child = [self.orgTreeData.children objectAtIndex:indexPath.row];
        [self orgTreeInfo:child.orgId];
        return;
    }
    
    //未分配部门的人员
    KDUnallotViewController *unallotViewController = [[KDUnallotViewController alloc]init];
    unallotViewController.orgPersons = self.orgTreeData.unallotPersons;
    unallotViewController.selectedPersonsView = self.selectedPersonsView;
    unallotViewController.blockCurrentUser = self.blockCurrentUser;
    unallotViewController.title = ASLocalizedString(@"KDChooseOrganizationViewController_UnallocaledPerson");
    unallotViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:unallotViewController animated:YES];
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap
{
    NSArray *persons;
    if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
        persons = _orgTreeData.allPersons;
    }else{
        persons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonIds:_orgTreeData.personIds];
    }
    //单选判断的操作
    if (self.selectedPersonsView.isMult == NO) {
        if ([persons count] > 1) {
            return;
        }
        if ([self.selectedPersonsView.persons count] > 0 && self.departmentSelectedCell.checked == NO) {
            return;
        }
    }
    
    
    if (self.pType == 2) {
        NSMutableArray *partnerPerson = [NSMutableArray array];
        [persons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PersonSimpleDataModel *person = obj;
            if (person.partnerType == 1) {
                [partnerPerson addObject:person];
            }
        }];
        if ([partnerPerson count] >= 1) {
            return;
        }
    }
    // bug 3924
    if (self.pType == 3) {
        NSMutableArray *innerPersons = [NSMutableArray array];
        [persons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PersonSimpleDataModel *person = obj;
            if (person.partnerType == 0) {
                [innerPersons addObject:person];
            }
        }];
        if ([innerPersons count] >= 1) {
            return;
        }
    }

    if(self.departmentSelectedCell.checked) {
        self.selectedPersonsView.isStopRefresh = YES;
        [self.selectedPersonsView removeDataSource:self];
        for(PersonSimpleDataModel *p in persons) {
            [self.selectedPersonsView deletePerson:p];
        }
        self.selectedPersonsView.isStopRefresh = NO;
        [self.selectedPersonsView addDataSource:self];
        [self.tableView reloadData];
        [self.departmentSelectedCell setChecked:NO animated:NO];
    }else {
        self.selectedPersonsView.isStopRefresh = YES;
        [self.selectedPersonsView removeDataSource:self];
        for(PersonSimpleDataModel *p in persons) {
            if((![BOSSetting sharedSetting].supportNotMobile || self.selectedPersonsView.isFromTask) && [p xtAvailable])
                [self.selectedPersonsView addPerson:p];
            else if(!self.selectedPersonsView.isFromTask && [BOSSetting sharedSetting].supportNotMobile)
                [self.selectedPersonsView addPerson:p];
        }
        self.selectedPersonsView.isStopRefresh = NO;
        [self.selectedPersonsView addDataSource:self];
        [self.tableView reloadData];
        [self.departmentSelectedCell setChecked:YES animated:NO];
    }
}

#pragma mark - XTSelectPersonsViewDataSource Methods
- (void)selectPersonViewDidAddPerson:(PersonSimpleDataModel *)person
{
    if(_orgTreeData.personIds.count > 0) {
        NSUInteger index;
        if ([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]) {
            index = [_orgTreeData.personIds indexOfObject:person];
        }else{
            index = [_orgTreeData.personIds indexOfObject:person.personId];
        }
        if(index != NSNotFound) {
//            XTContactPersonMultipleChoiceCell *cell = (XTContactPersonMultipleChoiceCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//            [cell setChecked:YES animated:YES];
        }
        
        [self.departmentSelectedCell setChecked:[self isAllSelected] animated:NO];
    }
}

- (void)selectPersonsViewDidDeletePerson:(PersonSimpleDataModel *)person
{
    if(_orgTreeData.personIds.count > 0) {
        NSUInteger index;
        if ([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]) {
            index = [_orgTreeData.personIds indexOfObject:person];;
        }else{
            index = [_orgTreeData.personIds indexOfObject:person.personId];
        }
        if(index != NSNotFound) {
//            if(self.JSBridgeType == selectOrg || self.JSBridgeType == selectDepts)
//            {
//                XTContactPersonMultipleChoiceCell *cell = (XTContactPersonMultipleChoiceCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//                [cell setChecked:NO animated:YES];
//            }else
//            {
//                
//            }

        }
        [self.tableView reloadData];
        [self.departmentSelectedCell setChecked:[self isAllSelected] animated:NO];
    }
}

#pragma mark - JSBridgeChooseGroupTableViewCellDelegate
-(void)childGroupButtonClickedMessage:(JSBridgeChooseGroupTableViewCell *)cell {
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    XTOrgChildrenDataModel *child = [self.orgTreeData.children objectAtIndex:path.row];
    [self orgTreeInfo:child.orgId];
}

#pragma mark - JSBridgeSureClicked
-(void)JSBridgeSureClicked:(UIButton *)sender {
    if (self.selectedOrgModelMuti.count > 0)
    {
        if (self.JSBridgeType == selectDepts)
        {
            if (self.JSBridgeDelegate != nil && [self.JSBridgeDelegate respondsToSelector:@selector(selectDeptsArray:)])
            {
                [self.JSBridgeDelegate selectDeptsArray:self.selectedOrgModelMuti];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (self.JSBridgeType == selectOrg)
        {
            if (self.JSBridgeDelegate != nil && [self.JSBridgeDelegate respondsToSelector:@selector(selectOrgArray:)])
            {
                [self.JSBridgeDelegate selectOrgArray:self.selectedOrgModelMuti];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        [hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_ChooseValid")];
        [hud setMode:MBProgressHUDModeText];
        [hud show:YES];
        [hud hide:YES afterDelay:1.0];
        self.isRequesting = NO;
    }
}

#pragma mark - caculate label width & bridge string
-(void)setBottomViewWithSelectedOrg {
    NSString *lableString = @"";
    for (NSInteger i = 0; i < self.selectedOrgModelMuti.count; i++) {
        
        if (i == self.selectedOrgModelMuti.count - 1)
        {
            lableString = [NSString stringWithFormat:@"%@ %@", lableString, [self.selectedOrgModelMuti[i] orgName]];
        }
        else
        {
            lableString = [NSString stringWithFormat:@"%@ %@,", lableString, [self.selectedOrgModelMuti[i] orgName]];
        }
        
    }
    
    CGSize textSize = {1000.0,44.0};
    CGSize size = [lableString sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    [self.bottomScrollView setContentSize:size];
    
    CGRect labelRect = self.groupLabel.frame;
    labelRect.size.width = size.width;
    self.groupLabel.frame = labelRect;
    
    self.groupLabel.text = lableString;
}

-(void)setBottomViewNothingOrOneOrg:(NSString *)lableString {
    CGSize textSize = {1000.0,44.0};
    CGSize size = [lableString sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    [self.bottomScrollView setContentSize:size];
    
    CGRect labelRect = self.groupLabel.frame;
    labelRect.size.width = size.width;
    self.groupLabel.frame = labelRect;
    
    self.groupLabel.text = lableString;
}

- (void)setBlockCurrentUser:(BOOL)blockCurrentUser
{
    _blockCurrentUser = blockCurrentUser;
}

#pragma  mark - IDOrganization Delegate Methods

- (void)organiztionSelectView:(KDOrganizationSelectView *)view didSelectedAtIndex:(NSUInteger)index
{
    if (index == self.organiztionStack.count - 1) {
        return;
    }
    //    [KDEventAnalysis event:event_contact_toast_tap];
    KDOrgTreeItemDataModel *selectItem = [self.organiztionStack objectAtIndex:index];
    NSUInteger stackCount = self.organiztionStack.count;
    NSRange range = NSMakeRange(index, stackCount - index);
    [self.organiztionStack removeObjectsInRange:range];
    
    [self orgTreeInfo:selectItem.orgId];
    //    haveNewItemPush = NO;
    
}

- (NSUInteger)numberOfItemsInOraganizationSelectView:(KDOrganizationSelectView *)view
{
    return [self.organiztionStack count];
}

- (NSString *)organiztionSelectView:(KDOrganizationSelectView *)view itemViewAtIndex:(NSUInteger)index
{
    KDOrgTreeItemDataModel *item = [self.organiztionStack objectAtIndex:index];
    return item.orgName;
}

@end
