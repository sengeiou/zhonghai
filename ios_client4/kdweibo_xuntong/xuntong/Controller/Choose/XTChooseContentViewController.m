//
//  XTChooseContentViewController.m
//  XT
//
//  Created by Gil on 13-7-19.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTChooseContentViewController.h"
#import "XTContactDataModel.h"
#import "XTSetting.h"
#import "XTImageCell.h"
#import "XTContactPersonMultipleChoiceCell.h"
#import "UIButton+XT.h"
#import "ContactClient.h"
#import "NSDataAdditions.h"
#import "ContactUtils.h"
#import "BOSConfig.h"
#import "KDChooseContentCollectionViewController.h"
#import "KDChooseOrganizationViewController.h"

#import "KDConfigurationContext.h"
#import "ASIHTTPRequest+OAuth.h"
#import "XTSearchMultipleChoiceCell.h"

#import "KDContactGroupDataModel.h"
#import "XTContactContentTopViewCell.h"

#import "KDChooseInviteHintView.h"

#import "KDInviteColleaguesViewController.h"
#import "KDForwardChooseViewController.h"
#import "KDImportantGroupCell.h"
#import "KDTableViewHeaderFooterView.h"
#import "UIBarButtonItem+Custom.h"
#import "XTChatViewController+ForwardMsg.h"
#import "KDImageEditorViewController.h"
#import "KDImageAlertView.h"

#define kFunctionModuleSection 0


#define TopicNameOrg @"KDChooseOrganizationViewController_Organtion"
#define TopicNamePartner @"XTChooseContentViewController_partner"
#define TopicNameMyDepartment @"XTChooseContentViewController_MyDepartment"
#define TopicNameChat @"XTChooseContentViewController_Chat"




@interface XTChooseContentViewController ()<KDSearchBarDelegate, UIAlertViewDelegate,KDChooseInviteHintViewDelegate, KKImageEditorDelegate>

@property (nonatomic, strong) XTSelectPersonsView *selectPersonsView;
@property (nonatomic, assign) XTChooseContentType type;

@property (nonatomic, strong) ContactClient *createChatClient;
@property (nonatomic, strong) NSArray *wantCreateChatPersons;

@property (nonatomic, strong) ContactClient *sendMessageClient;
@property (nonatomic, strong) MBProgressHUD *progressHud;

@property (nonatomic, strong) XTShareStartView *shareView;
@property (nonatomic, assign) BOOL needSendLeaveMessage;

@property (nonatomic, strong) ContactClient *personInfoClient;


@property (nonatomic, strong) GroupDataModel *group;

@property (nonatomic, strong) NSMutableArray *indexsArray;

@property (nonatomic, strong) NSMutableArray * dataArray;  //KDContactGroupDataModel

@property (nonatomic, strong) NSMutableArray *topSectionNames;
@property (nonatomic, strong) NSMutableArray *topSectionImageNames;
@property (nonatomic, strong) ContactClient *groupListClient;
@property (nonatomic, strong) NSString *groupId;

@property (nonatomic, strong) ContactClient *personAuthorityClient;
@property (nonatomic, strong) NSArray *queryPersons;

@property (strong, nonatomic) XTOpenSystemClient *openSystemClient;
@property (nonatomic, strong) PersonSimpleDataModel *newsForwardPerson;
@property (nonatomic, strong) NSMutableArray *hadChoosePersons;
@end

@implementation XTChooseContentViewController

- (ContactClient *)personAuthorityClient {
    if (!_personAuthorityClient) {
        _personAuthorityClient = [[ContactClient alloc] initWithTarget:self action:@selector(getPerSonAuthorityDidReceived:result:)];
    }
    return _personAuthorityClient;
}
- (void)getPerSonAuthorityDidReceived:(ContactClient *)client result:(id)result
{
    if (!client.hasError && result && [result isKindOfClass:[NSData class]]) {
        return;
    }
    
    NSArray *personIds = [((BOSResultDataModel *)result).data objectForKey:@"personIds"] ;
    NSMutableArray *authorityPersons = [NSMutableArray array];
    if(personIds)
    {
        [self.queryPersons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PersonSimpleDataModel *person = obj;
            if([personIds containsObject:person.personId]) {
                [authorityPersons addObject:person];
            }
        }];
    }
    
    if (showType == KDContactViewShowTypeRecently) {
        KDContactGroupDataModel * contactGroup = [[KDContactGroupDataModel alloc]init];
        contactGroup.sectionName = ASLocalizedString(@"XTChooseContentViewController_Current_Person");
        contactGroup.contactArray = authorityPersons;
        [_dataArray addObject:contactGroup];
    }
    else if (showType == KDContactViewShowTypeAll){
        NSArray * contactArray = [self groupArrayWithPersons:authorityPersons];
        if ([contactArray count] > 0 ) {
            [_dataArray addObjectsFromArray:contactArray];
            for (KDContactGroupDataModel * groupDM in contactArray) {
                [_indexsArray addObject:groupDM.sectionName];
            }
        }
    }
    
    [self.tableView reloadData];
}

- (XTOpenSystemClient *)openSystemClient
{
    if (_openSystemClient == nil) {
        _openSystemClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getPersonsDidRecieve:result:)];
    }
    return _openSystemClient;
}

- (void)getPersonsDidRecieve:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        return;
    }
    
    if (result.data && result.success) {
        NSArray *persons = result.data;
        for (NSDictionary *personDic in persons) {
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:personDic];
            [self.selectPersonsView addPerson:person];
        }
    }
}

- (NSMutableArray *)topSectionNames
{
    if (!_topSectionNames) {
        _topSectionNames = [[NSMutableArray alloc]init];
    }
    
    if([BOSConfig sharedConfig].user.orgId.length>0)
    {
        [_topSectionNames setArray:@[TopicNameOrg,TopicNameMyDepartment,TopicNameChat]];
    }
    else
    {
        [_topSectionNames setArray:@[TopicNameOrg,TopicNameChat]];
    }
    
    
    if([BOSConfig sharedConfig].user.partnerType == 1)
    {
        [_topSectionNames replaceObjectAtIndex:0 withObject:TopicNamePartner];
    }
    else if([BOSConfig sharedConfig].user.partnerType == 2)
    {
        [_topSectionNames insertObject:TopicNamePartner atIndex:1];
    }

    if (self.pType == 1) {
        
    } else if (self.pType == 2) { // 仅内部员工
        if ([_topSectionNames containsObject:TopicNamePartner]) {
            [_topSectionNames removeObject:TopicNamePartner];
        }
    } else if (self.pType == 3) { // 仅商务伙伴
        if ([_topSectionNames containsObject:TopicNameOrg]) {
            [_topSectionNames removeObject:TopicNameOrg];
        }
        
        // 若只能选择商务伙伴，且当前用户为内部人员，不显示 我的部门
//        if ([BOSConfig sharedConfig].user.partnerType == 0) {
//            if ([_topSectionNames containsObject:TopicNameMyDepartment]) {
//                [_topSectionNames removeObject:TopicNameMyDepartment];
//            }
//
//        }
    }
    
    return _topSectionNames;
}

- (NSMutableArray *)topSectionImageNames
{
    if (!_topSectionImageNames) {
        _topSectionImageNames = [[NSMutableArray alloc]init];
    }
    
    if([BOSConfig sharedConfig].user.orgId.length>0)
    {
        [_topSectionImageNames setArray:@[@"college_img_organization", @"college_img_apartment", @"contacts_tip_session"]];
    }
    else
    {
        [_topSectionImageNames setArray:@[@"college_img_organization", @"contacts_tip_session"]];
    }
    
    if([BOSConfig sharedConfig].user.partnerType == 1)
    {
        [_topSectionImageNames replaceObjectAtIndex:0 withObject:@"message_tip_shang"];
    }
    else if([BOSConfig sharedConfig].user.partnerType == 2)
    {
        [_topSectionImageNames insertObject:@"message_tip_shang" atIndex:1];
    }
    
    if (self.pType == 1) {
        
    } else if (self.pType == 2) { // 仅内部员工
        if ([_topSectionImageNames containsObject:@"message_tip_shang"]) {
            [_topSectionImageNames removeObject:@"message_tip_shang"];
        }
    } else if (self.pType == 3) { // 仅商务伙伴
        if ([_topSectionImageNames containsObject:@"college_img_organization"]) {
            [_topSectionImageNames removeObject:@"college_img_organization"];
        }
        // 若只能选择商务伙伴，且当前用户为内部人员，不显示 我的部门
//        if ([BOSConfig sharedConfig].user.partnerType == 0) {
//            if ([_topSectionImageNames containsObject:@"college_img_apartment"]) {
//                [_topSectionImageNames removeObject:@"college_img_apartment"];
//            }
//        }
    }
    
    return _topSectionImageNames;
}


- (void)initContents
{
    NSMutableArray *contents = [NSMutableArray array];
    NSArray *recentPersons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryRecentPersonsWithLimitNumber:30 isContainPublic:NO];
    if ([recentPersons count] > 0) {
        [contents addObjectsFromArray:[self blockCurrentUserFrom:recentPersons]];
        
        // 获取有权限可见人员
        NSMutableArray *personsIds = [NSMutableArray array];
        [contents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PersonSimpleDataModel *person = obj;
            [personsIds addObject:person.personId];
        }];
        self.queryPersons = nil;
        self.queryPersons = contents;
        [self.personAuthorityClient getPerSonAuthorityWithPersonIds:personsIds];
    }
//    self.contents = contents;
}

- (void)reloadContents
{
    //nothing
}

- (id)init
{
    self = [super init];
    if (self) {
        self.title = ASLocalizedString(@"XTChooseContentViewController_ChooseContact");
        self.pType = 1; //不传值就默认为1
        self.blockCurrentUser = YES;//默认屏蔽自己
    }
    return self;
}

- (id)initWithType:(XTChooseContentType)type
{
    self = [self init];
    if (self) {
        self.type = type;
        self.isMult = YES;
    }
    return self;
}

- (id)initWithType:(XTChooseContentType)type isMult:(BOOL)isMult{
    self = [self init];
    if (self) {
        self.type = type;
        self.isMult = isMult;
       
    }
    return self;
    
    
}


- (void)dealloc
{
    if(self.selectPersonsView && self.selectPersonsView.superview) {
        [self.selectPersonsView removeFromSuperview];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    UINavigationController *navController = (UINavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController;
    UIViewController *topViewController = navController.topViewController;
    if(topViewController && [topViewController isKindOfClass:[KDWebViewController class]])
    {
        [self setNavigationStyle:KDNavigationStyleNormal];
    }
    
    self->needsToLayoutTableView_ = 0;
    self.tableView.frame = CGRectMake(0.0, CGRectGetMaxY(self.kdSearchBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.kdSearchBar.frame) - 44.0);
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    if(_type == XTChooseContentForwardMulti)
    {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem kd_makeLeftItemWithTitle:ASLocalizedString(@"Global_Cancel") color:FC5 target:self action:@selector(cancelMulti:)];
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem kd_makeRightItemWithTitle:ASLocalizedString(@"KDForward_Radio") color:FC5 target:self action:@selector(cancelMulti:)];
    }
    else
    {
        UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Close")style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        
        self.navigationItem.rightBarButtonItems = @[cancelButtonItem];
    }
    
    XTSelectPersonsView *selectPersonsView = [[XTSelectPersonsView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(self.navigationController.view.frame) - 44.0f - 44.0f, self.view.frame.size.width, 44.0)];
    selectPersonsView.isFromTask = self.isFromTask;
    selectPersonsView.type = self.type == XTChooseContentShareStatus?1:0;
    if (self.type == XTChooseContentAdd && self.isFromConversation == NO) {
        selectPersonsView.minCount = 0;
    }
    [selectPersonsView updateType];
    selectPersonsView.dataSource = self;
    selectPersonsView.delegate = self;
    if (self.type == XTChooseContentShare && self.shareData.shareType == ShareMessageApplication) {
        XTShareApplicationDataModel *application = self.shareData.mediaObject;
        if ([application sharedToGroup]) {
            selectPersonsView.minCount = 2;
        }
    }
    //把是否多选的属性赋值给selectPersonsView
    if (_selectedPersons) {
        for (PersonSimpleDataModel * person in _selectedPersons) {
            [selectPersonsView addPerson:person];
        }
    }
    
    
    self.selectPersonsView = selectPersonsView;
    _selectPersonsView.isMult = self.isMult;
    
//    if (self.whiteList != nil) {
//        NSArray *whiteListPersons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithOids:self.whiteList];
//        
//        for (PersonSimpleDataModel *model in whiteListPersons) {
//            [self.selectPersonsView addPerson:model];
//        }
//    }
    
    if (self.selectedOids.count > 0) { // 是否有oid
        NSString *oidsStr = @"";
        for (NSInteger i = 0; i < self.selectedOids.count; i++) {
            oidsStr = [oidsStr stringByAppendingString:[NSString stringWithFormat:i==0?@"%@":@",%@",self.selectedOids[i]]];
        }
        [self.openSystemClient getPersonsByOids:oidsStr token:[BOSConfig sharedConfig].user.token];
    } else {
        if (self.selectedMobiles.count > 0) { // 若没有oid，再看是否有mobile
            NSString *phonesStr = @"";
            for (NSInteger i = 0; i < self.selectedMobiles.count; i++) {
                phonesStr = [phonesStr stringByAppendingString:[NSString stringWithFormat:i==0?@"%@":@",%@",self.selectedMobiles[i]]];
            }
            [self.openSystemClient getPersonsByPhones:phonesStr eid:[BOSConfig sharedConfig].user.eid token:[BOSConfig sharedConfig].user.token];
        }
    }
    
    selectPersonsView.frame = CGRectMake(0.0f, CGRectGetHeight(self.navigationController.view.frame) - 44.0f, CGRectGetWidth(self.navigationController.view.frame), 44.0f);
    [self.navigationController.view addSubview:selectPersonsView];
    
    __weak XTChooseContentViewController *viewController = self;
    if ([self.shareData.participantIds count] > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [viewController personInfo];
        });
    }
    [self loadContactsView];
    
    
}

-(void)loadContactsView{
    if ([[BOSSetting sharedSetting]contactStyle] == ContactStyleShowAll) {
        [self setShowType:KDContactViewShowTypeAll];
    }
    else if ([[BOSSetting sharedSetting]contactStyle] == ContactStyleShowRecently){
        [self setShowType:KDContactViewShowTypeRecently];
    }
}

- (UIButton *)btnWithTarget:(id)target action:(SEL)selector normalImage:(UIImage *)nImage highlightedImage:(UIImage *)hImage title:(NSString *)title andBtnTag:(NSInteger)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:nImage forState:UIControlStateNormal];
    [btn setImage:hImage forState:UIControlStateHighlighted];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.tag = tag;
    
    CGFloat spacing = 7.0f;
    CGSize imageSize = nImage.size;
    btn.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -imageSize.width, -(imageSize.height + spacing), 0.0f);
    
    CGSize titleSize = btn.titleLabel.frame.size;
    btn.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0f, 0.0f, -titleSize.width);
    
    return btn;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if(self.isMovingToParentViewController)
//    {
        UINavigationController *navController = (UINavigationController *)[KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController;
        UIViewController *topViewController = navController.topViewController;
        if (topViewController && [topViewController isKindOfClass:[KDWebViewController class]])
        {
            [self setNavigationStyle:KDNavigationStyleNormal];
        }
//    }

    
    self.selectPersonsView.hidden = NO;
    
    if (self.bSetAdmin)
    {
        self.navigationItem.title = ASLocalizedString(@"XTChooseContentViewController_Set_Admin");
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (UIViewController *)toChooseContentCollectionViewWithDatas:(NSArray *)datas title:(NSString *)title andGroupId:(NSString *)groupId
{
    KDChooseContentCollectionViewController *ccvc = [[KDChooseContentCollectionViewController alloc] initWithNibName:nil bundle:nil];
    ccvc.selectedPersonsView = self.selectPersonsView;
    ccvc.collectionDatas = datas;//[self filterWithPersons:datas];
    ccvc.selectedAgoraPersons = _selectedAgoraPersons;
    ccvc.inviteFromAgora = _inviteFromAgora;
    ccvc.groupId = groupId;
    ccvc.needUmeng = YES;
    ccvc.pType = self.pType;
    ccvc.navigationItem.title = title;
    ccvc.bShowSelectAll = self.isMult;
    [self.navigationController pushViewController:ccvc animated:YES];
    
    return ccvc;
}

- (NSArray *)filterWithPersons:(NSArray *)persons {
    __block NSMutableArray *tmpPersons = [NSMutableArray array];
    if (self.isFilterTeamAcc) {
        [persons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PersonSimpleDataModel *person = obj;
            if (person.defaultPhone.length > 0 && person.wbUserId.length > 0) {
                [tmpPersons addObject:person];
            }
        }];
    } else {
        [persons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PersonSimpleDataModel *person = obj;
            if (person.wbUserId.length > 0) {
                [tmpPersons addObject:person];
            }
        }];
    }
    
    return tmpPersons;
}

- (BOOL)shouldBlockCurrentUser
{
    return (self.type == XTChooseContentForward || self.type == XTChooseContentCreate || self.type == XTChooseContentAdd || self.type == XTChooseContentShare || self.type == XTChooseContentForwardMulti) && self.blockCurrentUser;
}

//array of PersonSimpleDataModel
- (NSArray *)blockCurrentUserFrom:(NSArray *)persons
{
    if([self shouldBlockCurrentUser]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF.personId == %@)", [BOSConfig sharedConfig].user.userId];
        
        return [persons filteredArrayUsingPredicate:predicate];
    }
    
    return persons;
}
#pragma mark -
#pragma mark - DataSource Method  获取显示数据的方法

-(void)setShowType:(KDContactViewShowType )newType{
    _dataArray = [[NSMutableArray alloc]init];
    if (showType == newType) {
        return ;
    }
    showType = newType;
    if (showType == KDContactViewShowTypeRecently) {
        [self getRecentlyContactData];
    }
    else if (showType == KDContactViewShowTypeAll){
        [self getAllContactData];
    }
}
-(void)getAllContactData{
    
    if(self.type == XTChooseContentForwardMulti)
    {
        _recentGroups = [NSMutableArray array];
        NSMutableArray *groups = [[[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupListWithLimit:100 offset:0] mutableCopy];
        
        //为了后面处理方便，把group用person封装下
        [groups enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GroupDataModel *group = obj;
            PersonSimpleDataModel *person = [group packageToPerson];
            [_recentGroups addObject:person];
        }];
        [self.tableView reloadData];
        return;
    }
    
    
    _indexsArray = [[NSMutableArray alloc]init];
    [_indexsArray addObject:UITableViewIndexSearch];
    NSArray *favPersons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryFavPersons];
    if ([favPersons count] > 0) {
        KDContactGroupDataModel * contactGroup = [[KDContactGroupDataModel alloc]init];
        contactGroup.sectionName = ASLocalizedString(@"XTChooseContentViewController_Collect_Person");
        contactGroup.contactArray = favPersons;
        [_dataArray addObject:contactGroup];
        [_indexsArray addObject:@"★"];
    }
    
    
   // NSMutableArray * allPersons = [[[XTDataBaseDao sharedDatabaseDaoInstance]queryAllContactPersonsContainPublic:NO] mutableCopy];
    NSArray * allPerson = [[XTDataBaseDao sharedDatabaseDaoInstance] queryRecentPersonsWithLimitNumber:30 isContainPublic:NO];
    NSMutableArray *allPersons = [NSMutableArray arrayWithArray:allPerson];
    
    // 选人过滤掉自己
    for (PersonSimpleDataModel *dm in [allPersons copy])
    {
        if ([dm.personId isEqualToString:[[[BOSConfig sharedConfig]user]userId]]) {
            [allPersons removeObject:dm];
        }
        
        if (self.isFilterTeamAcc && dm.defaultPhone.length == 0) {
            [allPersons removeObject:dm];
        }
    }
    
    // 获取有权限可见人员
    NSMutableArray *personsIds = [NSMutableArray array];
    [allPersons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PersonSimpleDataModel *person = obj;
        [personsIds addObject:person.personId];
    }];
    self.queryPersons = nil;
    self.queryPersons = allPersons;
    [self.personAuthorityClient getPerSonAuthorityWithPersonIds:personsIds];
    
//    NSArray * contactArray = [self groupArrayWithPersons:allPersons];
//    if ([contactArray count] > 0 ) {
//        [_dataArray addObjectsFromArray:contactArray];
//        for (KDContactGroupDataModel * groupDM in contactArray) {
//            [_indexsArray addObject:groupDM.sectionName];
//        }
//    }
    
//    [self.tableView reloadData];
    
    //    if ([allPersons count] == 0) {
    //        KDChooseInviteHintView * view = [[KDChooseInviteHintView alloc]initWithFrame:[KDWeiboAppDelegate getAppDelegate].window.bounds];
    //        view.delegate = self;
    //        [[KDWeiboAppDelegate getAppDelegate].window addSubview:view];
    //        __weak KDChooseInviteHintView * weakView = view;
    //        __weak XTChooseContentViewController * weakVC = self;
    //
    //        [view setHandleBlock:^{
    //                    }];
    //    }
    
}
- (void)buttonPressedWithView:(KDChooseInviteHintView *)view
{
    [view removeFromSuperview];
    KDInviteColleaguesViewController *contact = [[KDInviteColleaguesViewController alloc] init];
    contact.hasBackBtn = YES;
    contact.inviteSource = KDInviteSourceContact;
    contact.bShouldDismissOneLayer = YES;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contact];
    
    
    // 在present动画结束之前锁住不让点击，因为用户点击蒙层过早会出现bug。
    contentNav.view.userInteractionEnabled = NO;
    [self presentViewController:contentNav animated:YES completion:^{
        contentNav.view.userInteractionEnabled = YES;
    }];
    
}

-(void)getRecentlyContactData{
    
    if(self.type == XTChooseContentForwardMulti)
    {
        _recentGroups = [NSMutableArray array];
        NSMutableArray *groups = [[[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupListWithLimit:100 offset:0] mutableCopy];
        
        //为了后面处理方便，把group用person封装下
        [groups enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GroupDataModel *group = obj;
            
            //被注销的不显示
            if(group.groupType == GroupTypeDouble && group.participant.count>0 && (![((PersonSimpleDataModel *)[group.participant firstObject]) accountAvailable]))
                return;
            
            PersonSimpleDataModel *person = [group packageToPerson];
            [_recentGroups addObject:person];
        }];
        [self.tableView reloadData];
        return;
    }

    
    NSArray *favPersons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryFavPersons];
    if ([favPersons count] > 0) {
        KDContactGroupDataModel * contactGroup = [[KDContactGroupDataModel alloc]init];
        contactGroup.sectionName = ASLocalizedString(@"XTChooseContentViewController_Collect_Person");
        contactGroup.contactArray = favPersons;
        [_dataArray addObject:contactGroup];
    }
    NSArray *recentPersons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryRecentPersonsWithLimitNumber:30 isContainPublic:NO];
    if ([recentPersons count] > 0) {
//        KDContactGroupDataModel * contactGroup = [[KDContactGroupDataModel alloc]init];
//        contactGroup.sectionName = ASLocalizedString(@"XTChooseContentViewController_Current_Person");
//        contactGroup.contactArray = recentPersons;
//        [_dataArray addObject:contactGroup];
        
        // 获取有权限可见人员
        NSMutableArray *personsIds = [NSMutableArray array];
        [recentPersons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PersonSimpleDataModel *person = obj;
            [personsIds addObject:person.personId];
        }];
        self.queryPersons = nil;
        self.queryPersons = recentPersons;
        [self.personAuthorityClient getPerSonAuthorityWithPersonIds:personsIds];
        
    }
    
//    [self.tableView reloadData];
    
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
    NSMutableArray * abnormalArray = [NSMutableArray array];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    for (PersonSimpleDataModel * person in persons) {
        person.fullPinyin = [person.fullPinyin stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (person.fullPinyin == nil || [person.fullPinyin length] == 0) {
            [abnormalArray addObject:person];
            continue;
        }
        
        char firstChar = [person.fullPinyin characterAtIndex:0];
        if ((firstChar >= 'A' && firstChar <= 'Z')||(firstChar >= 'a' && firstChar <= 'z') ){
            NSString * letter = [[person.fullPinyin substringToIndex:1]uppercaseString];
            
            NSMutableArray * array = [dic objectForKey:letter];
            if (array) {
                [array addObject:person];
            }
            else{
                array = [NSMutableArray array];
                [array addObject:person];
                [dic setObject:array forKey:letter];
            }
            
        }
        else{
            [abnormalArray addObject:person];
            
        }
    }
    
    for (char ch = 'A'; ch <= 'Z'; ch++) {
        NSString * keyName = [NSString stringWithFormat:@"%c", ch];
        NSMutableArray * array = [dic objectForKey:keyName];
        if (array) {
            KDContactGroupDataModel * contactGroup = [[KDContactGroupDataModel alloc]init];
            contactGroup.sectionName = keyName;
            contactGroup.contactArray = array;
            [contactArray addObject:contactGroup];
        }
    }
    
    if ([abnormalArray count] > 0 ) {
        KDContactGroupDataModel * contactGroup = [[KDContactGroupDataModel alloc]init];
        contactGroup.contactArray = abnormalArray;
        contactGroup.sectionName = @"#";
        [contactArray addObject:contactGroup];
    }
    
    return contactArray;
    
}

#pragma mark - method

- (void)cancel:(UIButton *)btn
{
    if (self.type == XTChooseContentShare && self.shareData.shareType != ShareMessageApplication)
    {
        //跳转回第三方应用
        [self dismissViewControllerAnimated:NO completion:^{
            if (self.shareData.appId.length > 0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"emp%@://",self.shareData.appId]]];
            }
        }];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelChoosePerson)]) {
        [self.delegate cancelChoosePerson];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)finishSelectGroup:(GroupDataModel *)group
{
    if(_delegate && [_delegate isKindOfClass:[KDForwardChooseViewController class]])
    {
        if (_delegate && [_delegate respondsToSelector:@selector(chooseContentView:group:)]) {
            [_delegate chooseContentView:self group:group];
        }
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:^{
            if (group != nil) {
                if (_type == XTChooseContentForward) {
                    if (_delegate && [_delegate respondsToSelector:@selector(popViewController)]) {
                        [_delegate popViewController];
                    }
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:group,@"group",_forwardData,@"forwardDM",nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"forwardGroupMessage" object:nil userInfo:dict];
                }
                else
                {
                    if (_delegate && [_delegate respondsToSelector:@selector(chooseContentView:group:)]) {
                        [_delegate chooseContentView:self group:group];
                    }
                }
            }
        }];
    }
}

- (void)finishSelectPerson:(PersonSimpleDataModel *)person
{
    if(_delegate && [_delegate isKindOfClass:[KDForwardChooseViewController class]])
    {
        if (_delegate && [_delegate respondsToSelector:@selector(chooseContentView:person:)]) {
            [_delegate chooseContentView:self person:person];
        }
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:^{
            if (person != nil) {
                if (_type == XTChooseContentForward) {
                    if (_delegate && [_delegate respondsToSelector:@selector(popViewController)]) {
                        [_delegate popViewController];
                    }
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:person,@"person",_forwardData,@"forwardDM",nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"forwardPersonMessage" object:nil userInfo:dict];
                }
                else
                {
                    if (_delegate && [_delegate respondsToSelector:@selector(chooseContentView:person:)]) {
                        [_delegate chooseContentView:self person:person];
                    }
                }
            }
        }];
    }
}

- (XTShareStartView *)shareView
{
    if (_shareView == nil) {
        _shareView = [[XTShareStartView alloc] initWithShareData:self.shareData];
    }
    _shareView.delegate = self;
    _shareView.shareTextField.delegate = self;
    return _shareView;
}

- (void)showShareStartView:(BOOL)show
{
    //打开分享界面
    self.progressHud.labelText = nil;
    self.progressHud.mode = MBProgressHUDModeCustomView;
    self.progressHud.customView = self.shareView;
    self.progressHud.margin = 0;
    self.progressHud.dimBackground = YES;
    if (show) {
        [self.progressHud show:YES];
    }
}

- (void)sendShareStatusWithGroupId:(NSString *)groupId orUserId:(NSString *)userId
{
    self.progressHud.labelText = ASLocalizedString(@"XTChooseContentViewController_Send");
    self.progressHud.mode = MBProgressHUDModeIndeterminate;
    if(self.progressHud.alpha < 0.5f)
        [self.progressHud show:YES];
    
    XTShareNewsDataModel *news = self.shareData.mediaObject;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:self.shareData.appName?self.shareData.appName:@"" forKey:@"appName"];
    [param setObject:news.title?news.title:@"" forKey:@"title"];
    [param setObject:news.content?news.content:@"" forKey:@"content"];
    [param setObject:news.thumbURL?news.thumbURL:@"" forKey:@"thumbUrl"];
    [param setObject:news.webpageUrl?news.webpageUrl:@"" forKey:@"webpageUrl"];
    
    NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    if (paramJsonData) {
        NSString *paramJsonString =[[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
        [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:userId msgType:MessageTypeShareNews content:news.title msgLent:(int)news.title.length param:paramJsonString clientMsgId:[ContactUtils uuid]];
    }
}

#pragma mark - person info

- (ContactClient *)personInfoClient
{
    if (!_personInfoClient) {
        _personInfoClient = [[ContactClient alloc] initWithTarget:self action:@selector(personInfoDidReceived:result:)];
    }
    return _personInfoClient;
}

- (void)personInfo
{
    [self.personInfoClient getPersonInfoWithPersonID:[self.shareData.participantIds objectAtIndex:0] type:self.shareData.system];
}

- (void)personInfoDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success) {
        
        __weak XTChooseContentViewController *viewController = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PersonDataModel *person = [[PersonDataModel alloc] initWithDictionary:result.data];
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonContacts:person];
            
            [viewController.contents insertObject:[[XTContactDataModel alloc] initWithType:ContactDataParticipant canOpen:NO datas:[NSArray arrayWithObject:person]] atIndex:1];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [viewController.selectPersonsView addPerson:person];
                [viewController.tableView reloadData];
            });
        });
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(state_ == KDContactViewStateNormal){
        
        if(_type == XTChooseContentForwardMulti)
            return 2;
    
        return [_dataArray count] + 1;
        
    }
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(state_ == KDContactViewStateNormal){
        if (section == 0) {
            return self.topSectionNames.count;
        }
        
        if(_type == XTChooseContentForwardMulti)
            return _recentGroups.count;
        
        KDContactGroupDataModel * contactGroup = (KDContactGroupDataModel * )[_dataArray objectAtIndex:(section-1)];
        return [contactGroup.contactArray count];
    }
    else{
        NSInteger count = [self.displayContacts count];
        return count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(state_ == KDContactViewStateNormal){
        if (indexPath.section == kFunctionModuleSection) {
            return 65.0;
        }
        return 65.0f;
    }
    else
        return 65.0f;
}

#define XTContactContentCellIdentifier @"XTContactContentTopCellIdentifier"
#define XTContactPersonViewCellIdentifier @"XTContactPersonViewCellIdentifier"
#define XTContactSearchCellIdentifier @"XTContactSearchCellIdentifier"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    if(state_ == KDContactViewStateNormal) {
        if (section == kFunctionModuleSection){
            XTContactContentTopViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XTContactContentCellIdentifier];
            if(!cell){
                cell = [[XTContactContentTopViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:XTContactContentCellIdentifier];
            }
            cell.discoveryLabel.text = ASLocalizedString(self.topSectionNames[row]);
            [cell.avatarImageView setImage:[UIImage imageNamed:self.topSectionImageNames[row]]];
            return cell;
        }
        else{
            PersonSimpleDataModel * person = nil;
            if(self.type == XTChooseContentForwardMulti)
                person = [_recentGroups objectAtIndex:indexPath.row];
            else
            {
                KDContactGroupDataModel * contactGroup = [_dataArray objectAtIndex:(section-1)];
                person = [contactGroup.contactArray objectAtIndex:row];
            }
            
            XTContactPersonMultipleChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:XTContactPersonViewCellIdentifier ];
            if(!cell ){
                cell = [[XTContactPersonMultipleChoiceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:XTContactPersonViewCellIdentifier];
            }
            cell.person =  person;
            //语音会议邀请另外显示 置灰且不可点
            if (_inviteFromAgora) {
                cell.agoraSelected = [self.selectedAgoraPersons containsObject:person];
                cell.userInteractionEnabled = ![self.selectedAgoraPersons containsObject:person];;
            }
            
            cell.checked = [self.selectPersonsView.persons containsObject:person];
       
//            UIImageView*line = [[UIImageView alloc] initWithImage:[XTImageUtil cellSeparateLineImage]];
//            line.frame = CGRectMake(0, 0, ScreenFullWidth, 1);
//            [cell addSubview:line];
            
            cell.pType = self.pType;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }else if (state_ == KDContactViewStateSearch) {
        XTSearchMultipleChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:XTContactSearchCellIdentifier];
        if (cell == nil) {
            cell = [[XTSearchMultipleChoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:XTContactSearchCellIdentifier];
            cell.showGrayStyle = YES;
            cell.isFromTask = self.selectPersonsView.isFromTask;
        }
        
        cell.separateLineImageView.hidden = YES;
        PersonSimpleDataModel *person;
        if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
            person = [self.displayContacts objectAtIndex:indexPath.row];
            cell.person = person;
        }else{
            T9SearchResult *searchResult = self.displayContacts[indexPath.row];
            person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithResult:searchResult];
            cell.searchResult = searchResult;
        }
        
        cell.checked = ([self.selectPersonsView.persons containsObject:person]);
//        UIImageView*line = [[UIImageView alloc] initWithImage:[XTImageUtil cellSeparateLineImage]];
//        line.frame = CGRectMake(0, 0, ScreenFullWidth, 1);
//        [cell addSubview:line];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        cell.separatorLineInset = UIEdgeInsetsMake(0, 68.0, 0, 0);
        cell.pType = self.pType;
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(state_ == KDContactViewStateNormal){
        if (indexPath.section == kFunctionModuleSection) {
            NSString *topicName = self.topSectionNames[indexPath.row];

            if ([topicName isEqualToString:TopicNameOrg])
            {
                //组织架构
                KDChooseOrganizationViewController *org = [[KDChooseOrganizationViewController alloc] initWithOrgId:@"" isForCurrentUser:NO];
                org.inviteFromAgora = self.inviteFromAgora;
                org.selectedAgoraPersons = self.selectedAgoraPersons;
                org.selectedPersonsView = self.selectPersonsView;
                org.blockCurrentUser = [self shouldBlockCurrentUser];
                if (self.type == XTChooseContentCreate || self.type == XTChooseContentAdd || self.type == XTChooseContentForwardMulti) {
                    org.adduserType = label_session_adduser_type_organization;
                }
                org.partnerType = 0;
                org.isFilterTeamAcc = self.isFilterTeamAcc;
                [self.navigationController pushViewController:org animated:YES];
                return ;
            }
            
            if ([topicName isEqualToString:TopicNamePartner])
            {
                //商务伙伴
                KDChooseOrganizationViewController *org = [[KDChooseOrganizationViewController alloc] initWithOrgId:@"" isForCurrentUser:NO];
                org.inviteFromAgora = self.inviteFromAgora;
                org.selectedAgoraPersons = self.selectedAgoraPersons;
                org.selectedPersonsView = self.selectPersonsView;
                org.blockCurrentUser = [self shouldBlockCurrentUser];
                if (self.type == XTChooseContentCreate || self.type == XTChooseContentAdd || self.type == XTChooseContentForwardMulti) {
                    org.adduserType = label_session_adduser_type_organization;
                }
                org.partnerType = 1;
                [self.navigationController pushViewController:org animated:YES];
                return ;
            }
            
            
//            __weak __typeof(self) weakSelf = self;
//            void (^existGroup)() = ^()
//            {
//                //已有会话
//                self.selectPersonsView.hidden = (_type!=XTChooseContentForwardMulti);
//                XTGroupTimelineViewController *groupTimeline = [[XTGroupTimelineViewController alloc] init];
//                groupTimeline.delegate = self;
//                groupTimeline.selectPersonsView = (_type!=XTChooseContentForwardMulti?nil:self.selectPersonsView);
//                [weakSelf.navigationController pushViewController:groupTimeline animated:YES];
//                return;
//            };
            
            
            if ([topicName isEqualToString:TopicNameMyDepartment])
            {
                //我的部门
                KDChooseOrganizationViewController *org = [[KDChooseOrganizationViewController alloc] initWithOrgId:[BOSConfig sharedConfig].user.orgId isForCurrentUser:YES];
                org.inviteFromAgora = self.inviteFromAgora;
                org.selectedAgoraPersons = self.selectedAgoraPersons;
                org.selectedPersonsView = self.selectPersonsView;
                org.blockCurrentUser = [self shouldBlockCurrentUser];
                if (self.type == XTChooseContentCreate || self.type == XTChooseContentAdd || self.type == XTChooseContentForwardMulti) {
                    org.adduserType = label_session_adduser_type_mydepartment;
                }
                org.partnerType = [BOSConfig sharedConfig].user.partnerType;
                org.isMult = self.isMult;
                org.pType = self.pType;
                org.isFilterTeamAcc = self.isFilterTeamAcc;
                [self.navigationController pushViewController:org animated:YES];
                return ;
            }
            
            if ([topicName isEqualToString:TopicNameChat])
            {
                //已有会话
//                existGroup();
                
                self.selectPersonsView.hidden = (_type!=XTChooseContentForwardMulti);
                XTGroupTimelineViewController *groupTimeline = [[XTGroupTimelineViewController alloc] init];
                groupTimeline.inviteFromAgora = self.inviteFromAgora;
                if (self.inviteFromAgora) {
                     groupTimeline.exitedGroup = self.exitedGroup;
                }
               
                groupTimeline.delegate = self;
                groupTimeline.selectPersonsView = (_type!=XTChooseContentForwardMulti?nil:self.selectPersonsView);
                [self.navigationController pushViewController:groupTimeline animated:YES];
                return;
            }
            
        }
        else{
            //最近联系人、收藏联系人、公司联系人
            PersonSimpleDataModel * person = nil;
            
            if(_type == XTChooseContentForwardMulti)
            {
                person = [_recentGroups objectAtIndex:indexPath.row];
            }
            else
            {
                KDContactGroupDataModel * contactGroup = [_dataArray objectAtIndex:(indexPath.section - 1)];
                person = [contactGroup.contactArray objectAtIndex:indexPath.row];
            }
            
            XTContactPersonMultipleChoiceCell *cell = (XTContactPersonMultipleChoiceCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            BOOL checked = cell.checked;
            if (checked == NO && _isMult == NO && [self.selectPersonsView.persons count] > 0) {
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
                [self.selectPersonsView deletePerson:person];
            } else {
                [self.selectPersonsView addPerson:person];
                    //                if (self.type == XTChooseContentCreate || self.type == XTChooseContentAdd || self.type == XTChooseContentForwardMulti) {
                    //                    NSString *type = label_session_adduser_type_list;
                    //                    if ([contactGroup.sectionName isEqualToString:ASLocalizedString(@"XTChooseContentViewController_Collect_Person")]) {
                    //                        type = label_session_adduser_type_favorites;
                    //                    }
                    //                    else if ([contactGroup.sectionName isEqualToString:ASLocalizedString(@"XTChooseContentViewController_Current_Person")]) {
                    //                        type = label_session_adduser_type_recently;
                    //                    }
                    //                    [KDEventAnalysis event:event_session_adduser attributes:@{ label_session_adduser_type : type }];
                    //                }
            }
        }
    }
    else if (state_ == KDContactViewStateSearch) {
        PersonSimpleDataModel * person;
        if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
            person = [self.displayContacts objectAtIndex:indexPath.row];
        }else{
            T9SearchResult *searchResult = self.displayContacts[indexPath.row];
            person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithResult:searchResult];
        }
        
        //未激活不给点
        if(![BOSSetting sharedSetting].supportNotMobile && ![person xtAvailable])
            return;
        
        if (self.pType == 2 && person.partnerType == 1) {
            return;
        }
        if (self.pType == 3 && person.partnerType == 0) {
            return;
        }
        
        XTSearchMultipleChoiceCell *cell = (XTSearchMultipleChoiceCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        BOOL checked = cell.checked;
        if (checked == NO && _isMult == NO && [self.selectPersonsView.persons count] > 0) {
            return;
        }
        [cell setChecked:!checked animated:YES];
        
        if (checked) {
            [self.selectPersonsView deletePerson:person];
        } else {
            [self.selectPersonsView addPerson:person];
            if (self.type == XTChooseContentCreate || self.type == XTChooseContentAdd || self.type == XTChooseContentForwardMulti) {
                [KDEventAnalysis event:event_session_adduser attributes:@{ label_session_adduser_type : label_session_adduser_type_search }];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(state_ == KDContactViewStateNormal && section != kFunctionModuleSection) {
        return 25.0f;
    }else {
        return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(state_ == KDContactViewStateNormal && section != kFunctionModuleSection && _type != XTChooseContentForwardMulti){
        UILabel *view = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenFullWidth, 25)];
        view.text = [NSString stringWithFormat:@"   %@",[(KDContactGroupDataModel *)[_dataArray objectAtIndex:(section-1)] sectionName]];
        view.font = [UIFont systemFontOfSize:13.f];
        view.textColor = [UIColor colorWithRed:128/255.0f green:128/255.0f blue:128/255.0f alpha:1.0f];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor kdSubtitleColor];;
        CALayer *lineLayer = [CALayer layer];
        lineLayer.frame =CGRectMake(0.0f, CGRectGetHeight(view.frame) -  0.5, ScreenFullWidth, 0.5f);
        lineLayer.backgroundColor = UIColorFromRGB(0xdddddd).CGColor;
        [view.layer addSublayer:lineLayer];
        return view;
    }
    else if(state_ == KDContactViewStateNormal && _type == XTChooseContentForwardMulti)
    {
        KDTableViewHeaderFooterView *view = [[KDTableViewHeaderFooterView alloc] initWithStyle:KDTableViewHeaderFooterViewStyleGrayWhite];
        view.title = ASLocalizedString(@"KDForward_Recent_Chat");
        return view;
    }
    return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (showType == KDContactViewShowTypeAll) {
        return _indexsArray;
    }
    else if (showType == KDContactViewShowTypeRecently){
        return nil;
    }
    return nil;
}

#pragma mark - XTSelectPersonsViewDelegate

- (void)selectPersonViewDidConfirm:(NSMutableArray *)persons
{
    if (self.hadChoosePersons.count > 0) {
        [self.hadChoosePersons removeAllObjects];
    }
    self.hadChoosePersons = [NSMutableArray arrayWithArray:persons];
    
    switch (self.type) {
        case XTChooseContentCreate:
        {
            __block __typeof(self) weakSelf = self;
            void (^createBlock)() = [^(){
                
                //开始创建会话
                if ([persons count] == 1) {
                    PersonSimpleDataModel *person = [persons objectAtIndex:0];
                    //确认选择组
                    GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
                    if (group != nil) {
                        [weakSelf finishSelectGroup:group];
                    }
                    else {
                        [weakSelf finishSelectPerson:person];
                    }
                }
                else
                {
                    //创建组
                    [weakSelf createChatWithPersons:persons];
                }
                
            } copy];
            
            
            if(self.createByType != XTChooseContentCreate)
            {
                NSMutableArray *activePersons = [NSMutableArray array];
                [persons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
                    //未激活人不给转发,手机账号环境才需要过滤未激活人员
                    if(person && !person.group && ![BOSSetting sharedSetting].supportNotMobile)
                    {
                        if(![person xtAvailable])
                        {
                            return;
                        }
                    }
                    [activePersons addObject:person];
                }];
                
                //无可转发人
                if(activePersons.count == 0)
                {
                    [KDPopup showHUDToast:ASLocalizedString(@"KDAddOrUpdateSignInPointController_tips_27")];
                    return;
                }
                
                NSMutableString *groupName = [NSMutableString string];
                [persons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
                    [groupName appendString:person.personName];
                    
                    //只显示三个人的名字
                    if(idx == 2)
                    {
                        *stop = YES;
                        return;
                    }
                    
                    if(idx!=persons.count-1)
                        [groupName appendString:@","];
                }];
                
                if(persons.count>3)
                    [groupName appendString:ASLocalizedString(@"KDForward_Tips_AndSoOn")];
                
                NSString *msg = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%@",ASLocalizedString(@"XTChatViewController_Tip_5"),ASLocalizedString(@"XTChatViewController_Tip_61")],groupName, persons.count];
                
                __weak XTChooseContentViewController *weakSelf = self;
                if ([self canEditImage]) {
                    XTForwardDataModel *forwardData = [self getImageForwardData];
                    if (forwardData && forwardData.originalUrl.description.length > 0) {
                    }
                    
                    [[SDWebImageManager sharedManager] downloadWithURL:forwardData.originalUrl options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
                        if (image) {
                            KDImageAlertView *alert = [[KDImageAlertView alloc] initWithTitle:msg Image:image];
                            alert.clickConfirmBlock = ^{
                                createBlock();
                            };
                            alert.editImageBlock = ^{
                                [weakSelf goToImageEditorWithImage:image];
                            };
                            [alert showImageAlert];
                        } else {
                            [KDPopup showHUD:ASLocalizedString(@"图片加载失败")];
                        }
                    }];
                } else {
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Cancel") style:UIAlertActionStyleDefault handler:nil];
                    [alertVC addAction:actionCancel];
                    
                    UIAlertAction *actionSure = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        createBlock();
                    }];
                    [alertVC addAction:actionSure];
                    
                    [self.navigationController presentViewController:alertVC animated:YES completion:nil];
                }
            }
            else
            {
                createBlock();
            }
        }
            break;
        case XTChooseContentAdd:
        {
            
            if (self.inviteFromAgora) {
                NSMutableString *groupName = [NSMutableString string];
                PersonSimpleDataModel *person = [persons firstObject];
                if (persons.count == 1) {
                    groupName =[NSMutableString stringWithFormat:@" %@ ",person.personName];
                }else if (persons.count > 1)
                {
                    groupName =[NSMutableString stringWithFormat:ASLocalizedString(@"XTChooseContentViewController_totalNum"),person.personName,(unsigned long)[persons count]];
                }
                
                    
//                [persons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
//                    [groupName appendString:person.personName];
//                    
//                    //只显示三个人的名字
//                    if(idx == 2)
//                    {
//                        *stop = YES;
//                        return;
//                    }
//                    
//                    if(idx!=persons.count-1)
//                        [groupName appendString:@","];
//                }];
//                
//                if(persons.count>2)
//                    [groupName appendString:ASLocalizedString(@"XTChooseContentViewController_totalNum")];
                NSString *title = [NSString stringWithFormat:ASLocalizedString(@"XTChooseContentViewController_title"),groupName];
                NSString *msg = ASLocalizedString(@"XTChooseContentViewController_msg");
                
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Cancel") style:UIAlertActionStyleDefault handler:nil];
                [alertVC addAction:actionCancel];
                
                UIAlertAction *actionSure = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        if (_delegate && [_delegate respondsToSelector:@selector(chooseContentView:persons:)]) {
                            [_delegate chooseContentView:self persons:persons];
                        }
                    }];
                    
//                    [alertVC dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertVC addAction:actionSure];
                
                [self presentViewController:alertVC animated:YES completion:nil];
            }else
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    if (_delegate && [_delegate respondsToSelector:@selector(chooseContentView:persons:)]) {
                        [_delegate chooseContentView:self persons:persons];
                    }
                }];
            }
        }
            break;
        case XTChooseContentShare:
        {
            if ([persons count] == 1) {
                //分享
                PersonSimpleDataModel *person = [persons objectAtIndex:0];
                if ([[BOSConfig sharedConfig].currentUser.personId isEqualToString:person.personId]) {
                    [self.progressHud show:YES];
                    [self.progressHud setLabelText:ASLocalizedString(@"XTChooseContentViewController_No_Share_Self")];
                    [self.progressHud setMode:MBProgressHUDModeText];
                    [self.progressHud hide:YES afterDelay:1.0];
                    return;
                }
                GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
                if (group == nil) {
                    [self beforeCreateChatWithPersons:persons];
                }
                else {
                    self.shareView.group = group;
                    self.shareView.person = person;
                    [self showShareStartView:YES];
                }
            }
            else
            {
                //暂时不创建组，只是记录
                [self beforeCreateChatWithPersons:persons];
            }
        }
            break;
        case XTChooseContentForward:
        {
            if ([persons count] == 1) {
                //转发
                PersonSimpleDataModel *person = [persons objectAtIndex:0];
                GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
                if (group != nil) {
                    [self finishSelectGroup:group];
                }
                else {
                    [self finishSelectPerson:person];
                }
            }
            else
            {
                //创建组
                [self createChatWithPersons:persons];
            }
        }
            break;
        case XTChooseContentShareStatus:
        {
            NSMutableString *content = [NSMutableString string];
            
            for(NSUInteger idx = 0; idx < MIN(5, persons.count); ++idx) {
                PersonSimpleDataModel *person = persons[idx];
                [content appendFormat:@"%@、", person.personName];
            }
            [content deleteCharactersInRange:NSMakeRange(content.length - 1, 1)];
            if(persons.count > 1) {
                [content appendFormat:ASLocalizedString(@"XTChooseContentViewController_PersonNum"), persons.count];
            }
            
            self.wantCreateChatPersons = persons;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTChooseContentViewController_Send_Sure")message:content
                                                           delegate:self
                                                  cancelButtonTitle:ASLocalizedString(@"KDAgoraSDKManager_Tip_9")otherButtonTitles:ASLocalizedString(@"KDApplicationQueryAppsHelper_no"), nil];
            [alert show];
        }
            break;
        case XTChooseContentJSBridgeSelectPerson:{
            if (self.delegate && [self.delegate respondsToSelector:@selector(chooseContentView:selectedPerson:)]) {
                [self.delegate chooseContentView:self selectedPerson:persons];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case XTChooseContentJSBridgeSelectPersons: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(chooseContentView:selectedPersons:)]) {
                [self.delegate chooseContentView:self selectedPersons:persons];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case XTChooseContentForwardMulti:
        {
            __weak __typeof(self) weakSelf = self;
            
            NSMutableArray *activePersons = [NSMutableArray array];
            [persons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
                //未激活人不给转发,手机账号环境才需要过滤未激活人员
                if(person && !person.group)
                {
                    if(![person xtAvailable] && ![BOSSetting sharedSetting].supportNotMobile)
                    {
                        return;
                    }
                }
                else if(person.group)
                {
                    //禁言模式，不给发
                    if(![person.group isManager] && [person.group slienceOpened])
                        return;
                }
                [activePersons addObject:person];
            }];
            
            //无可转发人
            if(activePersons.count == 0)
            {
                [KDPopup showHUDToast:ASLocalizedString(@"KDAddOrUpdateSignInPointController_tips_27")];
                return;
            }
            
            [activePersons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                PersonSimpleDataModel *person = obj;
                
                if(weakSelf.createByType == XTChooseContentShareStatus)
                {
                    if (person.group)
                    {
                        [self sendShareStatusWithGroupId:person.group.groupId orUserId:nil];
                    }
                    else
                    {
                        GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
                        [self sendShareStatusWithGroupId:group.groupId orUserId:person.personId];
                    }
                }
                else
                {
                    if(person.group)
                    {
                        XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:person.group pubAccount:nil mode:ChatPrivateMode];
                        chatViewController.forwardDM = weakSelf.forwardData;
                        chatViewController.isForward = YES;
                        [chatViewController forwardMessagesToGroup];
                    }
                    else
                    {
                        XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:person];
                        chatViewController.forwardDM = weakSelf.forwardData;
                        chatViewController.isForward = YES;
                        [chatViewController forwardMessagesToGroup];
                    }
                }
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    [KDPopup showHUDToast:ASLocalizedString(@"KDForward_Tips_Complete")];
                }];
            });
        }
            break;
        default:
            break;
    }
}

#pragma mark - XTSelectPersonsViewDataSource

- (void)selectPersonsViewDidDeletePerson:(PersonSimpleDataModel *)person
{
    if(state_ == KDContactViewStateNormal) {
        //        NSUInteger row = [self.contents indexOfObject:person];
        //        if(row != NSNotFound) {
        //            XTContactPersonMultipleChoiceCell *cell = (XTContactPersonMultipleChoiceCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        //            [cell setChecked:NO animated:YES];
        //        }
        NSArray * array = [self.tableView visibleCells];
        for (UITableViewCell * cell in array) {
            if ([cell isKindOfClass:[XTContactPersonMultipleChoiceCell class]]) {
                
                XTContactPersonMultipleChoiceCell * newCell = (XTContactPersonMultipleChoiceCell *)cell;
                if ([newCell.person.personId isEqualToString:person.personId]) {
                    [newCell setChecked:NO animated:YES];
                }
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"unallotViewControllerReload" object:nil];
    }else {
        [self.displayContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if([obj isKindOfClass:[T9SearchResult class]]) {
                T9SearchResult *result = (T9SearchResult *)obj;
                if(result.userId == person.userId) {
                    XTSearchMultipleChoiceCell *cell = (XTSearchMultipleChoiceCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                    [cell setChecked:NO animated:YES];
                }
            }
        }];
    }
}

- (void)selectPersonViewDidAddPerson:(PersonSimpleDataModel *)person
{
    
    if(state_ == KDContactViewStateNormal) {
        //        NSUInteger row = [self.contents indexOfObject:person];
        //        if(row != NSNotFound) {
        //            XTContactPersonMultipleChoiceCell *cell = (XTContactPersonMultipleChoiceCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        //            [cell setChecked:YES animated:YES];
        //        }
        NSArray * array = [self.tableView visibleCells];
        for (UITableViewCell * cell in array) {
            if ([cell isKindOfClass:[XTContactPersonMultipleChoiceCell class]]) {
                
                XTContactPersonMultipleChoiceCell * newCell = (XTContactPersonMultipleChoiceCell *)cell;
                if ([newCell.person.personId isEqualToString:person.personId]) {
                    [newCell setChecked:YES animated:YES];
                }
            }
        }
    }else {
        [self.displayContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if([obj isKindOfClass:[T9SearchResult class]]) {
                T9SearchResult *result = (T9SearchResult *)obj;
                if(result.userId == person.userId) {
                    XTSearchMultipleChoiceCell *cell = (XTSearchMultipleChoiceCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                    [cell setChecked:YES animated:YES];
                }
            }
        }];
    }
}

#pragma mark - XTGroupTimelineViewControllerDelegate

- (void)groupTimeline:(XTGroupTimelineViewController *)controller group:(GroupDataModel *)group
{
    if (self.type == XTChooseContentShare) {
        [controller.navigationController popViewControllerAnimated:NO];
        self.shareView.group = group;
        self.shareView.person = nil;
        [self showShareStartView:YES];
        return;
    }
    
    if(self.type == XTChooseContentShareStatus) {
        [controller.navigationController popViewControllerAnimated:NO];
        
        self.group = group;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTChooseContentViewController_Send_Sure")message:
                              [NSString stringWithFormat:ASLocalizedString(@"XTChooseContentViewController_PersonNum"),(unsigned long)group.participant.count]
                                                       delegate:self
                                              cancelButtonTitle:ASLocalizedString(@"KDApplicationViewController_none")otherButtonTitles:ASLocalizedString(@"KDApplicationQueryAppsHelper_no"), nil];
        [alert show];
        return;
    }
    
    //    [self finishSelectGroup:group];
    if(_type == XTChooseContentForward) {
        [self dismissViewControllerAnimated:NO completion:^{
            if (group != nil) {
                if (_type == XTChooseContentForward) {
                    if (_delegate && [_delegate respondsToSelector:@selector(popViewController)]) {
                        [_delegate popViewController];
                    }
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:group,@"group",_forwardData,@"forwardDM",nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"forwardGroupMessage" object:nil userInfo:dict];
                }
                //                else
                //                {
                //                    if (_delegate && [_delegate respondsToSelector:@selector(chooseContentView:group:)]) {
                //                        [_delegate chooseContentView:self group:group];
                //                    }
                //                }
            }
        }];
    }
    else if(self.type == XTChooseContentForwardMulti)
    {
        PersonSimpleDataModel *person = [group packageToPerson];
        if([self.selectPersonsView.persons containsObject:person])
            [self.selectPersonsView deletePerson:person];
        else
            [self.selectPersonsView addPerson:person];
    }
    else {
        [self toChooseContentCollectionViewWithDatas:group.participant title:group.groupName andGroupId:group.groupId];
    }
    
}

#pragma mark - get

- (MBProgressHUD *)progressHud
{
    if (_progressHud == nil) {
        _progressHud = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
        _progressHud.delegate = self;
        _progressHud.removeFromSuperViewOnHide = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:_progressHud];
    }
    return _progressHud;
}

#pragma mark - 创建组

- (void)beforeCreateChatWithPersons:(NSArray *)persons
{
    if (persons.count ==2) {
        for (NSInteger i = 0; i < persons.count; i++) {
            PersonSimpleDataModel *person = persons[i];
            if ([[BOSConfig sharedConfig].currentUser.personId isEqualToString:person.personId]) {
                [self.progressHud show:YES];
                [self.progressHud setLabelText:ASLocalizedString(@"XTChooseContentViewController_Least_Two_Members")];
                [self.progressHud setMode:MBProgressHUDModeText];
                [self.progressHud hide:YES afterDelay:1.0];
                return;
            }
        }
    }
    
    self.wantCreateChatPersons = persons;
    
    self.shareView.group = nil;
    self.shareView.person = nil;
    [self showShareStartView:YES];
}

- (void)createChatWithPersons:(NSArray *)persons
{
    if(persons && persons.count == 1){
        self.shareView.person = [persons firstObject];
        [self applicationShared];
    }else{
        NSMutableArray *personIds = [NSMutableArray array];
        [persons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
            [personIds addObject:person.personId];
        }];
        
        if ([personIds count] == 0) {
            return;
        }
        
        if (self.createChatClient == nil) {
            self.createChatClient = [[ContactClient alloc] initWithTarget:self action:@selector(createChatDidReceived:result:)];
        }
        
        if ([self.wantCreateChatPersons count] == 0 || self.type == XTChooseContentShareStatus) {
            self.progressHud.labelText = ASLocalizedString(@"正在创建群组...");
            self.progressHud.mode = MBProgressHUDModeIndeterminate;
            self.progressHud.margin = 20;
            self.progressHud.dimBackground = NO;
            [self.progressHud show:YES];
        }
        self.wantCreateChatPersons = nil;
        
        [self.createChatClient creatGroupWithUserIds:personIds groupName:self.shareData.theme];
    }
}

- (void)createChatDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        if (result.error.length > 0) {
            [self.progressHud setLabelText:result.error];
        }
        else
        {
            [self.progressHud setLabelText:ASLocalizedString(@"创建失败")];
        }
        [self.progressHud setMode:MBProgressHUDModeText];
        self.progressHud.margin = 20;
        self.progressHud.dimBackground = NO;
        [self.progressHud hide:YES afterDelay:1.0];
        
        return;
    }
    
    GroupDataModel *groupDM = [[GroupDataModel alloc] initWithDictionary:result.data];
    if (self.type == XTChooseContentCreate)
    {
        groupDM.isNewGroup = YES;
        
        [self.progressHud removeFromSuperview];
        self.progressHud = nil;
        
        //拼接一个grouplist 用于会话组查询参与人ID 706
        GroupListDataModel *groupList = [[GroupListDataModel alloc]init];
        groupList.list = [[NSMutableArray alloc] initWithArray:@[groupDM]];
        [[XTDataBaseDao sharedDatabaseDaoInstance]insertUpdatePrivateGroupList:groupList];
        
        //确认选择组
        [self finishSelectGroup:groupDM];
    }
    else if (self.type == XTChooseContentShare)
    {
        //分享
        self.shareView.group = groupDM;
        self.shareView.person = nil;
        
        if (self.shareView.shareData.shareType == ShareMessageApplication) {
            XTShareApplicationDataModel *application = self.shareView.shareData.mediaObject;
            if (application.callbackUrl.length > 0) {
                [self applicationCallback];
            }
            else {
                [self applicationShared];
            }
        }
        else {
            [self applicationShared];
        }
    }
    else if (self.type == XTChooseContentForward)
    {
        [self.progressHud removeFromSuperview];
        self.progressHud = nil;
        //转发
        [self finishSelectGroup:groupDM];
    }else if(self.type == XTChooseContentShareStatus) {
        self.group = groupDM;
        [self sendShareStatusWithGroupId:groupDM.groupId orUserId:nil];
    }
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [_progressHud removeFromSuperview];
    _progressHud = nil;
}

#pragma mark - UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.type == XTChooseContentShareStatus) {
        if(buttonIndex == alertView.cancelButtonIndex) {
            self.group = nil;
        }else {
            if(self.group) {
                [self sendShareStatusWithGroupId:self.group.groupId orUserId:nil];
            }else if(self.wantCreateChatPersons.count == 1) {
                PersonSimpleDataModel *person = (PersonSimpleDataModel *)self.wantCreateChatPersons[0];
                GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
                if (!group) {
                    self.newsForwardPerson = person;
                }
                self.group = group;
                [self sendShareStatusWithGroupId:group.groupId orUserId:person.personId];
            }else {
                [self createChatWithPersons:self.wantCreateChatPersons];
            }
        }
    }
}

#pragma mark - XTShareViewDelegate

- (void)shareView:(XTShareView *)shareView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([shareView isKindOfClass:[XTShareFinishView class]]) {
        
        //跳转回第三方应用
        [self.progressHud hide:NO];
        [self dismissViewControllerAnimated:NO completion:^{
            
            if (buttonIndex == shareView.cancelButtonIndex && self.shareData.shareType != ShareMessageApplication && shareView.shareData.appId.length > 0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"emp%@://",shareView.shareData.appId]]];
            }
            
        }];
        
        return;
    }
    
    if ([shareView isKindOfClass:[XTShareStartView class]]) {
        [shareView.shareTextField resignFirstResponder];
        
        if (buttonIndex == shareView.cancelButtonIndex) {
            
            if (self.shareData.shareType != ShareMessageApplication) {
                //跳转回第三方应用
                [self.progressHud hide:NO];
                [self dismissViewControllerAnimated:NO completion:^{
                    
                    if (shareView.shareData.appId.length > 0) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"emp%@://",shareView.shareData.appId]]];
                    }
                    
                }];
            }
            else {
                [self.progressHud hide:YES];
            }
            
            return;
        }
    }
    
    self.needSendLeaveMessage = (shareView.shareTextField.text.length > 0);
    
    self.progressHud.labelText = ASLocalizedString(@"XTChooseContentViewController_Send");
    self.progressHud.mode = MBProgressHUDModeIndeterminate;
    self.progressHud.margin = 20;
    self.progressHud.dimBackground = NO;
    [self.progressHud show:YES];
    
    if ([self.wantCreateChatPersons count] > 0) {
        [self createChatWithPersons:self.wantCreateChatPersons];
    }
    else {
        if (shareView.shareData.shareType == ShareMessageApplication) {
            XTShareApplicationDataModel *application = shareView.shareData.mediaObject;
            if (application.callbackUrl.length > 0) {
                [self applicationCallback];
            }
            else {
                [self applicationShared];
            }
        }
        else {
            [self applicationShared];
        }
    }
}

#pragma mark - application share

- (void)applicationShared
{
    NSString *groupId = self.shareView.group.groupId;
    NSString *personId = self.shareView.person.personId;
    NSString *uuid = [ContactUtils uuid];
    
    switch (self.shareView.shareData.shareType) {
        case ShareMessageText:
        {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:self.shareView.shareData.appId forKey:@"appId"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            if (paramJsonData) {
                XTShareTextDataModel *textDM = self.shareView.shareData.mediaObject;
                NSString *paramJsonString =[[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeText content:textDM.text msgLent:(int)textDM.text.length param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
        case ShareMessageImage:
        {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:self.shareView.shareData.appId forKey:@"appId"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            if (paramJsonData) {
                XTShareImageDataModel *imageDM = self.shareView.shareData.mediaObject;
                NSData *imageData = [NSData base64DataFromString:imageDM.imageData];
                NSData *sendData = [ContactUtils XOR80:imageData];
                NSString *paramJsonString =[[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                [self.sendMessageClient sendFileWithGroupId:groupId toUserId:personId msgType:MessageTypePicture msgLen:(int)imageData.length upload:sendData fileExt:@"jpg" param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
        case ShareMessageNews:
        {
            XTShareNewsDataModel *news = self.shareView.shareData.mediaObject;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:news.title forKey:@"title"];
            [param setObject:news.content forKey:@"content"];
            [param setObject:news.thumbData forKey:@"thumbData"];
            [param setObject:news.webpageUrl forKey:@"webpageUrl"];
            [param setObject:self.shareView.shareData.appId forKey:@"appId"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            if (paramJsonData) {
                NSString *paramJsonString =[[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeShareNews content:news.title msgLent:(int)news.title.length param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
        case ShareMessageApplication:
        {
            XTShareApplicationDataModel *application = self.shareView.shareData.mediaObject;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:application.title forKey:@"title"];
            [param setObject:application.cellContent forKey:@"content"];
            [param setObject:application.thumbData forKey:@"thumbData"];
            [param setObject:application.webpageUrl forKey:@"webpageUrl"];
            [param setObject:application.lightAppId forKey:@"lightAppId"];
            [param setObject:self.shareView.shareData.appId forKey:@"pubAccId"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            if (paramJsonData) {
                NSString *paramJsonString =[[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeShareNews content:application.title msgLent:(int)application.title.length param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
        default:
            break;
    }
}

- (void)applicationCallback
{
    XTShareApplicationDataModel *application = self.shareView.shareData.mediaObject;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",application.callbackUrl]]];
    
    if (self.shareView.group.groupId.length > 0) {
        [request setPostValue:self.shareView.group.groupId forKey:@"groupId"];
    }
    else if (self.shareView.person.personId.length > 0) {
        [request setPostValue:self.shareView.person.personId forKey:@"personId"];
    }
    [request setPostValue:[BOSConfig sharedConfig].user.eid forKey:@"eId"];
    [request setPostValue:[BOSConfig sharedConfig].user.oId forKey:@"openId"];
    if (application.content.length > 0) {
        [request setPostValue:application.content forKey:@"content"];
    }
    
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    id<KDConfiguration> conf = [[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance];
    [request signRequestWithClientIdentifier:[conf getOAuthConsumerKey]
                                      secret:[conf getOAuthConsumerSecret]
                             tokenIdentifier:userManager.accessToken.keyToken
                                      secret:userManager.accessToken.secretToken
                                 usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];
    
    [request setTimeOutSeconds:300];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(applicationCallbackFinished:)];
    [request setDidFailSelector:@selector(applicationCallbackFailed:)];
    [request setShouldAttemptPersistentConnection:YES];
    [request startAsynchronous];
}

- (void)applicationCallbackFailed:(ASIFormDataRequest *)theRequest
{
    [self.progressHud setLabelText:ASLocalizedString(@"XTChatUnreadCollectionView_Send_Fail")];
    [self.progressHud setMode:MBProgressHUDModeText];
    self.progressHud.margin = 20;
    self.progressHud.dimBackground = NO;
    [self.progressHud hide:YES afterDelay:1.0];
}

- (void)applicationCallbackFinished:(ASIFormDataRequest *)theRequest
{
    if (theRequest.responseString.length > 0) {
        id result = [NSJSONSerialization JSONObjectWithData:[theRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if ([[result objectForKey:@"success"] boolValue]) {
            NSString *data = [result objectForKey:@"data"];
            if (data.length > 0) {
                XTShareApplicationDataModel *application = self.shareView.shareData.mediaObject;
                application.webpageUrl = [application.webpageUrl stringByAppendingString:data];
            }
            [self applicationShared];
            return;
        }
    }
    
    [self.progressHud setLabelText:ASLocalizedString(@"XTChatUnreadCollectionView_Send_Fail")];
    [self.progressHud setMode:MBProgressHUDModeText];
    self.progressHud.margin = 20;
    self.progressHud.dimBackground = NO;
    [self.progressHud hide:YES afterDelay:1.0];
}

#pragma mark - send message

- (ContactClient *)sendMessageClient
{
    if (!_sendMessageClient) {
        _sendMessageClient = [[ContactClient alloc] initWithTarget:self action:@selector(sendMessageDidReceived:result:)];
    }
    return _sendMessageClient;
}

- (void)sendMessageDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        [self.progressHud setLabelText:ASLocalizedString(@"XTChatUnreadCollectionView_Send_Fail")];
        [self.progressHud setMode:MBProgressHUDModeText];
        self.progressHud.margin = 20;
        self.progressHud.dimBackground = NO;
        [self.progressHud hide:YES afterDelay:1.0];
        
        self.group = nil;
        
        return;
    }
    
    self.groupId = [result.data objectForKey:@"groupId"];
    if (self.shareData.shareType == ShareMessageApplication) {
        if (self.wantCreateChatPersons.count == 1) {
            [self getGroupList];
            return;
        }
        //跳入相应的聊天界面
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.shareView.group,@"group",nil];
        
        [self.progressHud hide:NO];
        [self dismissViewControllerAnimated:NO completion:nil];
//        [(UINavigationController *) [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController popToRootViewControllerAnimated:NO];
//        [[KDWeiboAppDelegate getAppDelegate].XT setupTabBeforetimelineToChat];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shareGroupMessage" object:nil userInfo:dict];
        
        
        return;
    }
    
    if(self.createByType == XTChooseContentShareStatus) {
//        GroupDataModel *group = self.group;
//        if(!group) {
//            group = [[GroupDataModel alloc] init];
//            
//            NSString *groupId = [result.data valueForKeyPath:@"groupId"];
//            group.groupId = groupId;
//            group.groupName = self.newsForwardPerson.personName;
//        }
        
//        [self.progressHud hide:NO];
//        [self dismissViewControllerAnimated:YES completion:NULL];
//        [[KDWeiboAppDelegate getAppDelegate].XT setupTabBeforetimelineToChat];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"shareStatus" object:nil userInfo:@{@"group" : group}];
        
        return;
    }
    
    if (self.needSendLeaveMessage) {
        self.needSendLeaveMessage = NO;
        NSString *shareLeaveMessage = self.shareView.shareTextField.text;
        NSString *groupId = self.shareView.group.groupId;
        NSString *personId = self.shareView.person.personId;
        NSString *uuid = [ContactUtils uuid];
        [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeText content:shareLeaveMessage msgLent:(int)shareLeaveMessage.length param:nil clientMsgId:uuid];
    }
    else
    {
        XTShareFinishView *finishView = [[XTShareFinishView alloc] initWithShareData:self.shareView.shareData];
        finishView.group = self.shareView.group;
        finishView.person = self.shareView.person;
        finishView.delegate = self;
        
        self.progressHud.labelText = nil;
        self.progressHud.mode = MBProgressHUDModeCustomView;
        self.progressHud.margin = 0;
        self.progressHud.dimBackground = YES;
        self.progressHud.customView = finishView;
        
    }
}

- (void)getGroupList {
    if (self.groupListClient == nil) {
        self.groupListClient = [[ContactClient alloc] initWithTarget:self action:@selector(getGroupListDidReceived:result:)];
    }
    [self.groupListClient getGroupListWithUpdateTime:[XTSetting sharedSetting].updateTime];
}

- (void)getGroupListDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result {
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    
    if (result.success && result.data) {
        GroupListDataModel *groupListDM = [[GroupListDataModel alloc] initWithDictionary:result.data];
        
        if ([groupListDM.list count] > 0) {
            GroupDataModel *tempModel = nil;
            
            for (NSInteger i = 0; i < groupListDM.list.count; i++) {
                tempModel = groupListDM.list[i];
                
                if ([tempModel.groupId isEqualToString:self.groupId]) {
                    //跳入相应的聊天界面
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:tempModel, @"group", nil];
                    
                    [self.progressHud hide:NO];
                    [self dismissViewControllerAnimated:NO completion:nil];
//                    [[KDWeiboAppDelegate getAppDelegate].XT setupTabBeforetimelineToChat];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"shareGroupMessage" object:nil userInfo:dict];
                }
            }
        }
    }
}

#pragma mark - KDSearchBar Delegate Methods
- (void)searchBarTextDidBeginEditing:(KDSearchBar *)searchBar
{
    [super searchBarTextDidBeginEditing:searchBar];
    
}

- (void)searchBarTextDidEndEditing:(KDSearchBar *)searchBar
{
    [super searchBarTextDidEndEditing:searchBar];
    
}

- (void)searchBar:(KDSearchBar *)searchBar textDidChange:(NSString *)searchText{
    [super searchBar:searchBar textDidChange:searchText];
}

- (void)processSearchResultsBeforeReload
{
    if([self shouldBlockCurrentUser]) {
        if([BOSConfig sharedConfig].currentUser.userId != 0)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.userId != %d", [BOSConfig sharedConfig].currentUser.userId];
            
            [self.displayContacts filterUsingPredicate:predicate];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = self.progressHud.frame;
        rect.origin.y -= 120.0;
        self.progressHud.frame = rect;
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = self.progressHud.frame;
        rect.origin.y += 120.0;
        self.progressHud.frame = rect;
    }];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}


-(void)cancelMulti:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)canEditImage {
    XTForwardDataModel *forwardData = [self getImageForwardData];
    if (forwardData && forwardData.originalUrl.description.length > 0 && forwardData.bCanEditImage == YES) {
        return YES;
    }
    
    return NO;
}

- (XTForwardDataModel *)getImageForwardData {
    
    XTForwardDataModel *forwardData = [[XTForwardDataModel alloc] init];
    
    if ([self.forwardData isKindOfClass:[NSArray class]] && ((NSArray*)self.forwardData).count == 1) {
        forwardData = [self.forwardData firstObject];
    }
    
    if ([self.forwardData isKindOfClass:[XTForwardDataModel class]]) {
        forwardData = (XTForwardDataModel *)self.forwardData;
    }
    
    return forwardData;
}

- (void)goToImageEditorWithImage:(UIImage *)image {
    if (!image) {
        return;
    }
    
    KDImageEditorViewController *editor = [[KDImageEditorViewController alloc] initWithImage:image delegate:self];
//    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:editor];
    [self presentViewController:editor animated:YES completion:nil];
}

#pragma mark- KKImageEditorDelegate

- (void)imageDidFinishEdittingWithImage:(UIImage *)image {
    if (!image) {
        return;
    }
    
    XTForwardDataModel *forwardData = [self getImageForwardData];
    forwardData.editImage = image;
    self.forwardData = forwardData;
    
    //开始创建会话
    if ([self.hadChoosePersons count] == 1) {
        PersonSimpleDataModel *person = [self.hadChoosePersons objectAtIndex:0];
        //确认选择组
        GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
        if (group != nil) {
            [self finishSelectGroup:group];
        }
        else {
            [self finishSelectPerson:person];
        }
    }
    else
    {
        //创建组
        [self createChatWithPersons:self.hadChoosePersons];
    }
}

@end
