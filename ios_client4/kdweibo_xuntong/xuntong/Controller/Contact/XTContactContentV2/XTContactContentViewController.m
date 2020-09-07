//
//  XTContactContentViewController.m
//  kdweibo
//
//  Created by weihao_xu on 14-4-18.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTContactContentViewController.h"
#import "XTContactContentTopViewCell.h"
#import "XTContactGroupViewCell.h"
#import "XTContactPersonViewCell.h"
#import "XTOrganizationViewController.h"
#import "XTContactGroupViewController.h"
#import "XTPublicListViewController.h"
#import "XTContactContentCollectionController.h"
#import "XTPersonDetailViewController.h"
#import "UIButton+XT.h"
#import "BOSSetting.h"
#import "XTSearchCell.h"
#import "KDInviteColleaguesViewController.h"

#import "XTPublicListViewController.h"

#import "KDContactGroupDataModel.h"
#import "BOSConfig.h"
#import "KDInviteHintView.h"
#import "KDSubscribeViewController.h"
#define kFunctionModuleSection 0

#define TopicNameOrg @"XTContactContentViewController_Tip_1"
#define TopicNamePartner @"XTChooseContentViewController_partner"
#define TopicNameMulti @"XTContactContentViewController_MulChat"
#define TopicNamePublic @"XTContactContentViewController_Tip_2"


//static NSString * const topSectionNames[] = {@"组织架构", @"多人会话",@"公共号"};
//static NSString * const topSectionImageNames[] = {@"college_img_organization", @"college_img_group.png", @"college_img_public.png"};


@interface XTContactContentViewController ()<MBProgressHUDDelegate>
@property (nonatomic, strong) NSArray *topSectionNames;
@property (nonatomic, strong) NSArray *topSectionImageNames;

@property (nonatomic, strong) NSMutableArray *indexsArray;   //索引的数组，只有在显示所有联系人的方案的才会用到

@property (nonatomic, strong) NSMutableArray * dataArray;  //KDContactGroupDataModel

@property (nonatomic, assign) NSInteger contactsTotal;  //联系人总数，尽在KDContactViewShowTypeAll模式下，有用到

@property (nonatomic, retain) AppsClient *publicAcctClient;   //获取公号信息的通讯客户端

@property (nonatomic, retain) MBProgressHUD *appHud;          //等待进度器

@property (nonatomic, assign) BOOL shouldHidePublic;  //是否应该显示公共号
@property (strong, nonatomic) UIButton *qrInviteBtn;


@end

@implementation XTContactContentViewController
@synthesize dataArray = _dataArray;
@synthesize indexsArray = _indexsArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        self.title = ASLocalizedString(@"XTContactContentViewController_Contact");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _shouldHidePublic = [[BOSConfig sharedConfig].user.eid isEqualToString:@"10109"];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    //
    //    self.tableView.frame = CGRectMake(0.0, 44.0f, ScreenFullWidth, MainHeight - TabBarHeight - NavigationBarHeight - 44.0f);
    //    self.tableView.backgroundColor = BOSCOLORWITHRGBA(0xededed, 1.0);
    //    self.tableView.sectionIndexColor = BOSCOLORWITHRGBA(0x808080, 1.0);
    //
    ////    if (isAboveiOS7) {
    //        self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    //    }
    
    {
        //根据实际情况显示
        if([BOSConfig sharedConfig].user.partnerType == 0)
        {
            self.topSectionNames = @[TopicNameOrg,TopicNameMulti];
            self.topSectionImageNames = @[@"college_img_organization", @"contacts_tip_imgroup"];
        }
        else if([BOSConfig sharedConfig].user.partnerType == 1)
        {
            self.topSectionNames = @[TopicNamePartner,TopicNameMulti];
            self.topSectionImageNames = @[@"message_tip_shang", @"contacts_tip_imgroup"];
        }
        else if([BOSConfig sharedConfig].user.partnerType == 2)
        {
            self.topSectionNames = @[TopicNameOrg,TopicNamePartner,TopicNameMulti];
            self.topSectionImageNames = @[@"college_img_organization",@"message_tip_shang", @"contacts_tip_imgroup"];
        }
        
        //加入没有隐藏公共号，把公共号加进去
        if(!_shouldHidePublic)
        {
            self.topSectionNames = [self.topSectionNames arrayByAddingObject:TopicNamePublic];
            self.topSectionImageNames = [self.topSectionImageNames arrayByAddingObject:@"college_img_public_timeline.png"];
        }
    }
    
    UIButton *qrInviteBtn = [UIButton btnInNavWithImage:[UIImage imageNamed:@"nav_btn_invite_normal"] highlightedImage:[UIImage imageNamed:@"nav_btn_invite_press"]];
    [qrInviteBtn addTarget:self action:@selector(qrInviteClick:) forControlEvents:UIControlEventTouchUpInside];
    self.qrInviteBtn = qrInviteBtn;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:qrInviteBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    //    UIButton *qrInviteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    UIImage *addImage = [UIImage imageNamed:@"colleague_add_contact_n_v3"];
    //    UIImage *hightAddImage = [UIImage imageNamed:@"colleague_add_contact_hl_v3"];
    //    [qrInviteBtn setImage:addImage forState:UIControlStateNormal];
    //    [qrInviteBtn setImage:hightAddImage forState:UIControlStateHighlighted];
    //    [qrInviteBtn sizeToFit];
    //    [qrInviteBtn addTarget:self action:@selector(qrInviteClick:) forControlEvents:UIControlEventTouchUpInside];
    //
    
    //    UIBarButtonItem *rightItem = [[[UIBarButtonItem alloc] initWithCustomView:qrInviteBtn] autorelease];
    //    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    
    if ([self hasInvitePermission]) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:qrInviteBtn];// autorelease];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.kdSearchBar setPlaceHolder:ASLocalizedString(@"XTContactContentViewController_Search")];
    [self loadContactsView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(personViewControllerFlags_.searching == 1)
        [KDWeiboAppDelegate getAppDelegate].tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setNavigationStyle:KDNavigationStyleNormal];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)dealloc{
    
    //KD_RELEASE_SAFELY(_indexsArray);
    
    //[super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Contact DataSource Method
-(void)loadContactsView{
    if ([[BOSSetting sharedSetting]contactStyle] == ContactStyleShowAll) {
        [self setShowType:KDContactViewShowTypeAll];
    }
    else if ([[BOSSetting sharedSetting]contactStyle] == ContactStyleShowRecently){
        [self setShowType:KDContactViewShowTypeRecently];
    }
}

-(void)setShowType:(KDContactViewShowType )newType{
    
    showType = newType;
    if (showType == KDContactViewShowTypeRecently) {
        [self getRecentlyContactData];
    }
    else if (showType == KDContactViewShowTypeAll){
        [self getAllContactData];
    }
}

-(void)getAllContactData{
    if (_indexsArray) {
        [_indexsArray removeAllObjects];
    }
    else{
        _indexsArray = [[NSMutableArray alloc]init];
    }
    
    if (_dataArray) {
        [_dataArray removeAllObjects];
    }
    else{
        _dataArray =[[NSMutableArray alloc]init];;
    }
    [_indexsArray addObject:UITableViewIndexSearch];
    NSArray *favPersons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryFavPersons];
    if ([favPersons count] > 0) {
        KDContactGroupDataModel * contactGroup = [[KDContactGroupDataModel alloc]init];
        contactGroup.sectionName = ASLocalizedString(@"XTChooseContentViewController_Collect_Person");
        contactGroup.contactArray = favPersons;
        [_dataArray addObject:contactGroup];
//        [contactGroup release];
        [_indexsArray addObject:@"★"];
    }
    
    NSArray * allPersons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryRecentPersonsWithLimitNumber:30 isContainPublic:YES];
    _contactsTotal = [allPersons count];
    if ([allPersons count] == 0) {
        return;
    }
    NSArray * contactArray = [self groupArrayWithPersons:allPersons];
    if ([contactArray count] > 0 ) {
        [_dataArray addObjectsFromArray:contactArray];
        for (KDContactGroupDataModel * groupDM in contactArray) {
            [_indexsArray addObject:groupDM.sectionName];
        }
    }
    
    [self.tableView reloadData];
    
    //会导致一些情况下，通讯录界面滚到最下面去，屏蔽掉
//    BOOL notShowInviteHint = NO;
//    notShowInviteHint = [[NSUserDefaults standardUserDefaults]boolForKey:kNotShowInviteHint];
//    if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
//        BOOL contactMaskHidenForever = [[NSUserDefaults standardUserDefaults]boolForKey:kContactMaskHidenForever];
//        
//        if (_contactsTotal < 7 && !notShowInviteHint && !contactMaskHidenForever) {
//            
//            if(state_ == KDContactViewStateNormal)
//            {
//                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[_dataArray count] + 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//            }
////            if ([self hasInvitePermission]) {
////                [self showInviteHintView];
////            }
//        }
//    }
//    
    
}

-(void)getRecentlyContactData{
    
    if (_dataArray) {
        [_dataArray removeAllObjects];
    }
    else{
        _dataArray =[[NSMutableArray alloc]init];;
    }
    NSArray *favPersons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryFavPersons];
    if ([favPersons count] > 0) {
        KDContactGroupDataModel * contactGroup = [[KDContactGroupDataModel alloc]init];
        contactGroup.sectionName = ASLocalizedString(@"XTChooseContentViewController_Collect_Person");
        contactGroup.contactArray = favPersons;
        [_dataArray addObject:contactGroup];
//        [contactGroup release];
    }
    NSArray *recentPersons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryRecentPersonsWithLimitNumber:30 isContainPublic:YES];
    if ([recentPersons count] > 0) {
        KDContactGroupDataModel * contactGroup = [[KDContactGroupDataModel alloc]init];
        contactGroup.sectionName = ASLocalizedString(@"XTChooseContentViewController_Current_Person");
        contactGroup.contactArray = recentPersons;
        [_dataArray addObject:contactGroup];
//        [contactGroup release];
    }
    [self.tableView reloadData];
    
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
//        [contactGroup release];
    }
    
    return contactArray;
    
}

#pragma mark -
#pragma mark UITableViewDataSource And UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if(state_ == KDContactViewStateNormal){
        if (showType == KDContactViewShowTypeAll) {
            return [_dataArray count] + 2;
            
        }
        return [_dataArray count] + 1;
    }
    else
        return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(state_ == KDContactViewStateNormal){
        if (section == kFunctionModuleSection) {
            return  self.topSectionNames.count;//return (_shouldHidePublic ? 2 : 3);
        }
        if ([self isContactsTotalSection:section]) {
            return 1;
        }
        KDContactGroupDataModel * contactGroup = (KDContactGroupDataModel * )[_dataArray objectAtIndex:(section-1)];
        return [contactGroup.contactArray count];
    }
    else{
        NSInteger count = [self.displayContacts count];
        return count;
    }
}

//#define XTContactContentCellIdentifier @"XTContactContentTopCellIdentifier"
//#define XTContactGroupViewCellIdentifier @"XTContactGroupViewCellIdentifier"
//#define XTContactPersonViewCellIdentifier @"XTContactPersonViewCellIdentifier"
//#define XTContactTotalCellIdentifier @"XTContactTotalCellIdentifier"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *XTContactContentCellIdentifier = @"XTContactContentTopCellIdentifier";
    //static NSString *XTContactGroupViewCellIdentifier = @"XTContactGroupViewCellIdentifier";
    static NSString *XTContactPersonViewCellIdentifier = @"XTContactPersonViewCellIdentifier";
    static NSString *XTContactTotalCellIdentifier = @"XTContactTotalCellIdentifier";
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    if(state_ == KDContactViewStateNormal){
        if (section == kFunctionModuleSection){
            XTContactContentTopViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XTContactContentCellIdentifier ];
            if(!cell){
                cell = [[XTContactContentTopViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:XTContactContentCellIdentifier] ;//autorelease];
            }
            cell.discoveryLabel.text = ASLocalizedString(self.topSectionNames[row]);
//            switch (indexPath.row) {
//                case 0:
//                    cell.discoveryLabel.text = ASLocalizedString(@"XTContactContentViewController_Tip_1");
//                    break;
//                case 1:
//                    cell.discoveryLabel.text = ASLocalizedString(@"XTContactContentViewController_MulChat");
//                    break;
//                case 2:
//                    cell.discoveryLabel.text = ASLocalizedString(@"XTContactContentViewController_Tip_2");
//                    break;
//                default:
//                    break;
//            }
            cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
            [cell.avatarImageView setImage:[UIImage imageNamed:self.topSectionImageNames[row]]];
            
            if (indexPath.row == self.topSectionNames.count - 1) {
                cell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
            }
            
            return cell;
        }
        else if ([self isContactsTotalSection:section]){
            KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XTContactTotalCellIdentifier ];
            if(!cell){
                cell = [[KDTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:XTContactTotalCellIdentifier];// autorelease];
                UILabel * label = [[UILabel alloc]initWithFrame:CGRectZero];
                label.textAlignment = NSTextAlignmentCenter;
                
                label.font = [UIFont systemFontOfSize:16.0f];
                label.textColor = BOSCOLORWITHRGBA(0xAEAEAE, 1.0);
//                label.backgroundColor = [UIColor clearColor];
                label.tag = 100111;
                
                [cell.contentView addSubview:label];
                cell.userInteractionEnabled = NO;
                cell.backgroundColor = [UIColor kdBackgroundColor2];
                cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
                cell.separatorLineInset = UIEdgeInsetsMake(0, 55.0, 0, 0);
                
            }
            // 判断是否包含自己
//            NSArray * allPersons = [[XTDataBaseDao sharedDatabaseDaoInstance]queryAllContactPersonsContainPublic:YES];
//            
//            BOOL bContainSelf = NO;
//            for (PersonSimpleDataModel * dm in allPersons)
//            {
//                if ([dm.personId isEqualToString:[[[BOSConfig sharedConfig]user]userId]]) {
//                    bContainSelf = YES;
//                }
//            }
//            UILabel * label = (UILabel *)[cell.contentView viewWithTag:100111];
//            label.text = [NSString stringWithFormat:ASLocalizedString(@"XTContactContentViewController_ContactNum"),(long)(bContainSelf ? _contactsTotal - 1 : _contactsTotal)];
//            [label sizeToFit];
//            [label setFrame:CGRectMake(0,50, cell.contentView.bounds.size.width, label.frame.size.height)];
            return cell;
        }
        else{
            KDContactGroupDataModel * contactGroup = [_dataArray objectAtIndex:(section-1)];
            PersonSimpleDataModel * person = [contactGroup.contactArray objectAtIndex:row];
            
            XTContactPersonViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XTContactPersonViewCellIdentifier ];
            if(!cell ){
                cell = [[XTContactPersonViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:XTContactPersonViewCellIdentifier] ;//autorelease];
                [cell setDisplayDepartment:NO];
                [cell.accessoryImageView setHidden:YES];
            }
            cell.person =  person;
            cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
            cell.separatorLineInset = UIEdgeInsetsMake(0, 48.0 + 2 * 10, 0, 0);
            
            if (indexPath.row == contactGroup.contactArray.count - 1) {
                cell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
            }
            
            return cell;
            
        }
    }
    
    else{
        //人员检索结果
        static NSString *CellIdentifier = @"CellIdentifierForSearch";
        XTSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[XTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        }
        cell.separateLineImageView.hidden = NO;
        
        if (self.displayContacts && [self.displayContacts count] > row)
        {
            if (![[BOSSetting sharedSetting]isNetworkOrgTreeInfo]) {
                cell.searchResult = [self.displayContacts objectAtIndex:row];
            }else{
                cell.person = [self.displayContacts objectAtIndex:row];
            }
            
        }
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(state_ == KDContactViewStateSearch)
        return 65.0f;
    else{
        if ([self isContactsTotalSection:indexPath.section]) {
            return (isAboveiPhone5 ? 120:95);
        }
        return 65.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    if (state_ == KDContactViewStateNormal) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (section == kFunctionModuleSection) {
            NSString *topicName = self.topSectionNames[indexPath.row];
            if ([topicName isEqualToString:TopicNameOrg]) {
                //add
                [KDEventAnalysis event: event_contacts_org_structure];
                //add
                [KDEventAnalysis eventCountly:event_contacts_org_structure];
                [self toOrganizationViewControllerWithOrgId:@"" andPartnerType:0];
            }
            else if ([topicName isEqualToString:TopicNamePartner]){
                //add
                [KDEventAnalysis event: event_contacts_business_partner];
                [KDEventAnalysis eventCountly:event_contacts_business_partner];
                [self toOrganizationViewControllerWithOrgId:@"" andPartnerType:1];
            }
            else if ([topicName isEqualToString:TopicNameMulti]) {
                //add
                [KDEventAnalysis event: event_contacts_important_group];
                [KDEventAnalysis eventCountly: event_contacts_important_group];
                UIViewController *viewController = [[XTContactGroupViewController alloc] init];// autorelease];
                viewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else if ([topicName isEqualToString:TopicNamePublic]) {
                //add
                [KDEventAnalysis event: event_contact_pubacc_count];
                [KDEventAnalysis eventCountly: event_contact_pubacc_count];
//                XTPublicListViewController *publicListViewController = [[[XTPublicListViewController alloc]init] autorelease];
//                [self.navigationController pushViewController:publicListViewController animated:YES];
                KDSubscribeViewController *publiclistViewController = [[KDSubscribeViewController alloc] init];
                
                publiclistViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:publiclistViewController animated:YES];
            }
        }
        else{
            //add
            [KDEventAnalysis event: event_personal_info_count];
            //add
            [KDEventAnalysis eventCountly: event_personal_info_count];
            
            KDContactGroupDataModel * contactGroup = [_dataArray objectAtIndex:(section-1)];
            PersonSimpleDataModel * personDM = [contactGroup.contactArray objectAtIndex:row];
            if ([personDM.personId hasPrefix:@"XT"]) {
                [self openPublicApp:personDM];
            }
            else{
                XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc]initWithSimplePerson:personDM with:NO];// autorelease];
                personDetail.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:personDetail animated:YES];
                
            }
            
        }
    }
    else {
        //add
        [KDEventAnalysis event: event_personal_info_count];
        //add
        [KDEventAnalysis eventCountly: event_personal_info_count];
        //直接进入个人信息
        XTContactPersonViewCell *cell = (XTContactPersonViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        //add by stone 很神奇的情况，忽略掉！
        if (![cell isKindOfClass:[XTSearchCell class]])
            return;
        
        PersonSimpleDataModel *person =  cell.person;
        
        XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc]initWithSimplePerson:person with:NO];// autorelease];
        personDetail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:personDetail animated:YES];
//        UINavigationController *navigationController2 = self.navigationController;
//        navigationController2.isShowToolBar = YES;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if((state_ == KDContactViewStateNormal && section != kFunctionModuleSection) && [self isContactsTotalSection:section] == NO)
        return 25.0f;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (showType == KDContactViewShowTypeAll && section == ([_dataArray count] + 1)) {
        return nil;
    }
    if(state_ == KDContactViewStateNormal && section != kFunctionModuleSection){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 22)];
        view.backgroundColor = [UIColor kdSubtitleColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], CGRectGetMinY(view.frame), CGRectGetWidth(view.frame) - [NSNumber kdDistance1], CGRectGetHeight(view.frame))];
        label.text = [NSString stringWithFormat:@"   %@",[(KDContactGroupDataModel *)[_dataArray objectAtIndex:(section-1)] sectionName]];
        label.font = FS7;
        label.textColor = FC1;
        label.backgroundColor = view.backgroundColor;
        [view addSubview:label];
        return view;
    }
    return nil;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];// autorelease];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = RGBCOLOR(237, 237, 237);
    return view;
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


#pragma mark -
#pragma mark private method

- (void)toContactContentCollectionController : (NSArray *)collectionArray{
    XTContactContentCollectionController *viewController = [[XTContactContentCollectionController alloc] initWithNibName:nil bundle:nil];// autorelease];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)toOrganizationViewControllerWithOrgId:(NSString *)orgId andPartnerType:(NSInteger)partnerType;
{
    
    XTOrganizationViewController *viewController = [[XTOrganizationViewController alloc] initFromAddressBookWithOrgId:orgId] ;//autorelease];
    viewController.partnerType = partnerType;
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)qrInviteClick:(id)sender
{
    
    if ([[BOSSetting sharedSetting] isIntergrationMode]) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"JSBridge_Tip_7")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
//        [alertView release];
        return ;
        
    }
    KDInviteColleaguesViewController *contact = [[KDInviteColleaguesViewController alloc] init];// autorelease];
    contact.hasBackBtn = YES;
    contact.inviteSource = KDInviteSourceContact;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contact];// autorelease];
    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
}

-(void)openPublicApp:(PersonSimpleDataModel * )person{
    if (!person.personId || [person.personId length] == 0) {
        return ;
    }
    PersonSimpleDataModel *publicAccount = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:person.personId];
    if(publicAccount)
    {
        [self gotoChatViewWithPublicAccount:publicAccount];
        return;
    }
    
    if(_publicAcctClient == nil)
        _publicAcctClient = [[AppsClient alloc] initWithTarget:self action:@selector(getPubAccountDidReceived:result:)];
    
    if (_appHud == nil)
    {
        _appHud = [[MBProgressHUD alloc] initWithView:self.view];
        _appHud.labelText = ASLocalizedString(@"XTContactContentViewController_Load");
        _appHud.delegate = self;
        [self.view addSubview:_appHud];
        [_appHud show:YES];
    }
    
    [_publicAcctClient getPublicAccount:person.personId];
    
}
-(void)getPubAccountDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    [_appHud hide:YES];
    
    if (result.success)
    {
        if(result.data)
        {
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:result.data];// autorelease];
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonSimple:person];
            [self gotoChatViewWithPublicAccount:person];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTContactContentViewController_Tip_3")message:ASLocalizedString(@"XTContactContentViewController_Error")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alertView show];
//        [alertView release];
    }
}
-(void)gotoChatViewWithPublicAccount:(PersonSimpleDataModel *)person{
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:person];// autorelease];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

#pragma mark MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    self.appHud = nil;
}

#pragma mark -
#pragma mark InviteHintView method

-(BOOL)isContactsTotalSection:(NSInteger)section{
    return (showType == KDContactViewShowTypeAll && section == ([_dataArray count] + 1)
            &&state_ == KDContactViewStateNormal);
}

-(void)showInviteHintView{
    KDInviteHintView * inviteHintView = [[KDInviteHintView alloc]initWithFrame:[KDWeiboAppDelegate getAppDelegate].window.bounds];
    [inviteHintView setBlock:^{
        [self qrInviteClick:nil];
        
    }];
    [[KDWeiboAppDelegate getAppDelegate].window addSubview:inviteHintView];
}

@end
