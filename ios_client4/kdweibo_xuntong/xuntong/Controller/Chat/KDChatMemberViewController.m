//
//  KDChatMemberViewController.m
//  kdweibo
//
//  Created by liwenbo on 16/2/16.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDChatMemberViewController.h"
#import "BOSConfig.h"

#import "KDChatDetailSearch.h"

#import "KDAgoraSDKManager.h"
#import "XTContactPersonViewCell.h"
#import "XTPersonDetailViewController.h"
#import "KDPersonFetch.h"
#import "XTDataBaseDao.h"
#import "SimplePersonListDataModel.h"
#import "KDUserHelper.h"

#define QUIT_BUTTON_TAG 1001
#define TRANSFER_BUTTON_TAG 1002

@interface KDChatMemberViewController ()<UITableViewDataSource, UITableViewDelegate, XTChooseContentViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UILocalizedIndexedCollation *collation;    // 索引
@property (nonatomic, strong) NSMutableArray *mArrayAtoZ;
@property (nonatomic, strong) NSMutableArray *mArrayNewSectionsArray;
@property (nonatomic, strong) NSMutableArray *mArrayNonEmptySectionArray;
@property (nonatomic, strong) NSMutableArray *contactPersonIdsArray; //内部人员数组

@property (nonatomic, strong) NSMutableArray *selectedPersons;
@property (nonatomic, strong) NSMutableArray *selectedPersonIds;
@property (nonatomic, strong) NSMutableArray *unVerifiedUsers;
@property (nonatomic, strong) NSMutableArray *unVerifiedUserIds;


@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) KDChatDetailSearch *search; //搜索

@property (nonatomic, strong)ContactClient *personInfoClient;

@property (nonatomic, strong) KDUserHelper *userHelper;
@property (nonatomic, copy) void(^blockRecursiveGetGroupUser)(BOOL, SimplePersonListDataModel *personListData, void(^)());



@end

@implementation KDChatMemberViewController


- (MBProgressHUD *)hud
{
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.labelText = nil;
        [self.view addSubview:_hud];
    }
    return _hud;
}

#pragma mark -
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    
    __weak KDChatMemberViewController *weakSelf = self;
    dispatch_queue_t concurrentQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^(void) {
        //迭代获取相关人员信息块
        weakSelf.blockRecursiveGetGroupUser = ^(BOOL succ, SimplePersonListDataModel *personListData, void (^completion)()) {
            // 递归防御
            if (succ){
                if (personListData.hasMore) {
                    [weakSelf fetchGroupUsersByPageWithGroupId:weakSelf.group.groupId
                                                         Score:[NSString stringWithFormat:@"%ld",personListData.lastUpdateScore]
                                                recursiveBlock:weakSelf.blockRecursiveGetGroupUser
                                                    completion:completion];
                }else
                {
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [weakSelf updateGroupMemeber];
                    });
                    
                }
            }
        };
        [weakSelf fetchGroupUsersByPageWithGroupId:self.group.groupId
                                             Score:@"0"
                                    recursiveBlock:weakSelf.blockRecursiveGetGroupUser
                                        completion:nil];
    });
    
}
//拉去组人员信息块
- (void)fetchGroupUsersByPageWithGroupId:(NSString *)groupId
                                   Score:(NSString *)personScore
                          recursiveBlock:(void (^)(BOOL succ, SimplePersonListDataModel *personListData, void (^completion)()))recursiveBlock
                              completion:(void (^)())completion{
    
    [self.userHelper  getGroupUsersWithGroupId:groupId
                                         Score:personScore
                                    completion:^(BOOL success, BOOL more, NSDictionary *personsDic, NSString *error) {
                                        if (success) {
                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                                SimplePersonListDataModel *personList = [[SimplePersonListDataModel alloc]initWithDictionary:personsDic];
                                                if ([personList.list count ] > 0) {
                                                    //太慢了 得优化
                                                    NSMutableArray *personIdArray = [NSMutableArray array];
                                                    [personList.list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                        PersonSimpleDataModel *person = (PersonSimpleDataModel *) obj;
                                                        //插入人员表 可能有个坑，新增人员不会出现在最近联系人里面
                                                        [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonSimple:person];
                                                        
                                                        //生成人员id列表
                                                        [personIdArray addObject:person.personId];
                                                    }];
                                                    //把删除人员移除组参与人
                                                    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteParticpantWithPersonIdArray:personIdArray groupId:groupId];
                                                    //把新增人员添加到参与id表里面
                                                    [[XTDataBaseDao sharedDatabaseDaoInstance] addParticpantWithPersonIdArray:personIdArray groupId:groupId];
                                                }
                                                if (recursiveBlock){
                                                    //拉数据前根据updateScore去拉人
                                                    recursiveBlock(YES, personList, completion);
                                                }
                                            });
                                        }else
                                        {
                                            if (recursiveBlock) {
                                                recursiveBlock(NO,nil,completion);
                                            }
                                        }
                                    }];
}
- (void)setGroup:(GroupDataModel *)group {
    _group = group;
    
    if (self.dataArr && self.dataArr.count > 0)
    {
        [self.dataArr removeAllObjects];
    }
    else
    {
        self.dataArr = [NSMutableArray array];
    }
    [self updateGroupMemeber];
}

//更新数据源
- (void)updateGroupMemeber
{
    if (self.dataArr.count > 0)
    {
        [self.dataArr removeAllObjects];
    }
    
    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setDetailsLabelText:nil];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    
    if (self.selectedPersonIds.count > 0) {
        [self.selectedPersonIds removeAllObjects];
    }
    if (self.selectedPersons.count > 0) {
        [self.selectedPersons removeAllObjects];
    }
    if (self.unVerifiedUserIds.count > 0) {
        [self.unVerifiedUserIds removeAllObjects];
    }
    if (self.unVerifiedUsers.count > 0) {
        [self.unVerifiedUsers removeAllObjects];
    }
    [self personInfo];
    
    
//    __weak KDChatMemberViewController *weakself = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSMutableArray *tempWbUserIds = [NSMutableArray array];
//        [KDPersonFetch fetchWithPersonIds:@[[BOSConfig sharedConfig].user.userId]
//                          completionBlock:^(BOOL success, NSArray *persons, BOOL isAdminRight) {
//                              if (success) {
//                                  PersonSimpleDataModel *selfPerson = [persons firstObject];
//                                  if (selfPerson.status != 3) {
//                                      selfPerson.status = 3;
//                                  }
//                                  [weakself.dataArr addObject:selfPerson];
//                                  //将每个人按name分到某个section下
//                                  
//                                  
////                                  NSMutableArray *managerArr = [NSMutableArray array];
////                                  if ([weakself isManager:selfPerson])
////                                  {
////                                      [managerArr addObject:selfPerson];
////                                  }
//                                  //得出collation索引的数量，这里是27个（26个字母和1个#）
//                                  NSInteger sectionTitlesCount = [[self.collation sectionTitles] count];
//                                  weakself.mArrayNewSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount + 1];
//                                  //初始化27个空数组加入newSectionsArray
//                                  for (NSInteger index = 0; index < sectionTitlesCount; index++) {
//                                      NSMutableArray *array = [[NSMutableArray alloc] init];
//                                      [weakself.mArrayNewSectionsArray addObject:array];
//                                  }
//                                  
//                                  NSMutableArray *managerArr = [NSMutableArray array];
//                                  if ([weakself isManager:selfPerson])
//                                  {
//                                      [managerArr addObject:selfPerson];
//                                  }else
//                                  {
//                                      NSInteger sectionNumber = [self.collation sectionForObject:selfPerson collationStringSelector:@selector(personName)];
//                                      //把name为“林丹”的p加入newSectionsArray中的第11个数组中去
//                                      NSMutableArray *sectionNames = _mArrayNewSectionsArray[sectionNumber];
//                                      [sectionNames addObject:selfPerson];
//
//                                  }
//
//                                  
//                                  
//                                  for (PersonSimpleDataModel *person in weakself.group.participant) {
//                                      if (person && [person accountAvailable]){
//                                          if ([weakself isManager:person])
//                                          {
//                                              [managerArr addObject:person];
//                                              continue;
//                                          }
//                                          //获取name属性的值所在的位置，比如"林丹"，首字母是L，在A~Z中排第12（第一位是0），sectionNumber就为11
//                                          NSInteger sectionNumber = [self.collation sectionForObject:person collationStringSelector:@selector(personName)];
//                                          //把name为“林丹”的p加入newSectionsArray中的第11个数组中去
//                                          NSMutableArray *sectionNames = _mArrayNewSectionsArray[sectionNumber];
//                                          [sectionNames addObject:person];
//                                          
//                                          [tempWbUserIds addObject:person.personId];
//                                          [weakself.dataArr addObject:person];
//                                      }
//                                  }
//                                  //        if ([weakself.group isExternalGroup])
//                                  //        {
//                                  //            //此处用personId作为TABLE_GROUP表中的WbUserId来查内部人员
//                                  //            weakself.contactPersonIdsArray = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWbUserIdsWithExternalWbUserIds:tempWbUserIds]];
//                                  //        }
//                                  
//                                  //对每个section中的数组按照name属性排序
//                                  for (int index = 0; index < sectionTitlesCount; index++) {
//                                      NSMutableArray *personArrayForSection = weakself.mArrayNewSectionsArray[index];
//                                      NSArray *sortedPersonArrayForSection = [weakself.collation sortedArrayFromArray:personArrayForSection collationStringSelector:@selector(personName)];
//                                      weakself.mArrayNewSectionsArray[index] = sortedPersonArrayForSection;
//                                  }
//                                  
//                                  NSMutableArray *mArray = [NSMutableArray new];
//                                  for (NSArray *array in weakself.mArrayNewSectionsArray) {
//                                      if (array.count > 0) {
//                                          [mArray addObject:array];
//                                      }
//                                  }
//                                  
//                                  weakself.mArrayAtoZ = [NSMutableArray new];
//                                  for (NSArray *array in weakself.mArrayNewSectionsArray) {
//                                      if (array.count > 0) {
//                                          NSUInteger index = [weakself.mArrayNewSectionsArray indexOfObject:array];
//                                          [weakself.mArrayAtoZ addObject:[weakself.collation sectionTitles][index]];
//                                      }
//                                  }
//                                  //把管理员加入第一个位置
//                                  if (managerArr.count > 0)
//                                  {
//                                      [mArray insertObject:managerArr atIndex:0];
//                                      [weakself.mArrayAtoZ insertObject:ASLocalizedString(@"KDMeIconTableViewCell_admin") atIndex:0];
//                                  }
//                                  
//                                  _mArrayNonEmptySectionArray = mArray.mutableCopy;
//                                  dispatch_async(dispatch_get_main_queue(), ^{
//                                      [weakself.tableView reloadData];
//                                      [weakself.hud hide:YES]; 
//                                  });
//                              }
//                          }];
//    });
//    
//    if (self.selectedPersonIds.count > 0) {
//        [self.selectedPersonIds removeAllObjects];
//    }
//    if (self.selectedPersons.count > 0) {
//        [self.selectedPersons removeAllObjects];
//    }
//    if (self.unVerifiedUserIds.count > 0) {
//        [self.unVerifiedUserIds removeAllObjects];
//    }
//    if (self.unVerifiedUsers.count > 0) {
//        [self.unVerifiedUsers removeAllObjects];
//    }
}

- (void)personInfo
{
    if (self.personInfoClient == nil) {
            self.personInfoClient = [[ContactClient alloc] initWithTarget:self action:@selector(personInfoDidReceived:result:)];
    }
    [self.personInfoClient getPersonInfoWithPersonID:[BOSConfig sharedConfig].user.userId type:nil];

}

- (void)personInfoDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success) {
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc]initWithDictionary:result.data];
            [self.dataArr addObject:person];
            //将每个人按name分到某个section下
            
            
            //                                  NSMutableArray *managerArr = [NSMutableArray array];
            //                                  if ([weakself isManager:selfPerson])
            //                                  {
            //                                      [managerArr addObject:selfPerson];
            //                                  }
        
            NSMutableArray *tempWbUserIds = [NSMutableArray array];
            //得出collation索引的数量，这里是27个（26个字母和1个#）
            NSInteger sectionTitlesCount = [[self.collation sectionTitles] count];
            self.mArrayNewSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount + 1];
            //初始化27个空数组加入newSectionsArray
            for (NSInteger index = 0; index < sectionTitlesCount; index++) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [self.mArrayNewSectionsArray addObject:array];
            }
            
            NSMutableArray *managerArr = [NSMutableArray array];
            if ([self isManager:person])
            {
                if(self.group.participantIds.count == 1 && [self.group.participantIds.firstObject isEqualToString:person.personId])
                {
                    //不加
                }
                else
                    [managerArr addObject:person];
            }else
            {
                NSInteger sectionNumber = [self.collation sectionForObject:person collationStringSelector:@selector(personName)];
                //把name为“林丹”的p加入newSectionsArray中的第11个数组中去
                NSMutableArray *sectionNames = _mArrayNewSectionsArray[sectionNumber];
                [sectionNames addObject:person];
                
            }
            
            
            
            for (NSString *personId in self.group.participantIds) {
                PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPersonWithPersonId:personId];
                if (person){
                    if ([self isManager:person])
                    {
                        [managerArr addObject:person];
                        continue;
                    }
                    //获取name属性的值所在的位置，比如"林丹"，首字母是L，在A~Z中排第12（第一位是0），sectionNumber就为11
                    NSInteger sectionNumber = [self.collation sectionForObject:person collationStringSelector:@selector(personName)];
                    //把name为“林丹”的p加入newSectionsArray中的第11个数组中去
                    NSMutableArray *sectionNames = _mArrayNewSectionsArray[sectionNumber];
                    [sectionNames addObject:person];
                    
                    [tempWbUserIds addObject:person.personId];
                    [self.dataArr addObject:person];
                }
            }
            //        if ([weakself.group isExternalGroup])
            //        {
            //            //此处用personId作为TABLE_GROUP表中的WbUserId来查内部人员
            //            weakself.contactPersonIdsArray = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWbUserIdsWithExternalWbUserIds:tempWbUserIds]];
            //        }
            
            //对每个section中的数组按照name属性排序
            for (int index = 0; index < sectionTitlesCount; index++) {
                NSMutableArray *personArrayForSection = self.mArrayNewSectionsArray[index];
                [personArrayForSection sortUsingComparator:^NSComparisonResult(PersonSimpleDataModel *  _Nonnull person1, PersonSimpleDataModel *  _Nonnull person2) {
                    return [person1.personName compare:person2.personName];
                }];
                self.mArrayNewSectionsArray[index] = personArrayForSection;
            }
            
            NSMutableArray *mArray = [NSMutableArray new];
            for (NSArray *array in self.mArrayNewSectionsArray) {
                if (array.count > 0) {
                    [mArray addObject:array];
                }
            }
            
            self.mArrayAtoZ = [NSMutableArray new];
            for (NSArray *array in self.mArrayNewSectionsArray) {
                if (array.count > 0) {
                    NSUInteger index = [self.mArrayNewSectionsArray indexOfObject:array];
                    [self.mArrayAtoZ addObject:[self.collation sectionTitles][index]];
                }
            }
            //把管理员加入第一个位置
            if (managerArr.count > 0)
            {
                [mArray insertObject:managerArr atIndex:0];
                [self.mArrayAtoZ insertObject:ASLocalizedString(@"KDMeIconTableViewCell_admin") atIndex:0];
            }
            
            _mArrayNonEmptySectionArray = mArray.mutableCopy;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.hud hide:YES];
            });
        }

}

- (void)addMember:(id)sender
{
    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentAdd];
    contentViewController.delegate = self;
    contentViewController.isFromConversation = NO;
    
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
//    contentNav.delegate = [KDNavigationManager sharedNavigationManager];
    [self presentViewController:contentNav animated:YES completion:nil];
}


#pragma mark - XTChooseContentViewControllerDelegate

- (void)chooseContentView:(XTChooseContentViewController *)controller persons:(NSArray *)persons
{
    if(self.chooseContentDelegate)
    {
        [self.navigationController popViewControllerAnimated:NO];
        if([self.chooseContentDelegate respondsToSelector:@selector(chooseContentView:persons:)])
            [self.chooseContentDelegate chooseContentView:controller persons:persons];
    }
}

- (void)setType:(KDChatMemberViewControllerType)type
{
    _type = type;
    if (type == KDChatMemberViewControllerTypeNormal)
    {
        //if([self.group isManager]){
        if(((![self.group abortAddPersonOpened] || [self.group isManager])))
        {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDAppDetailViewController_add") style:UIBarButtonItemStylePlain target:self action:@selector(addMember:)];
            [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
        }
        //}
        self.title = [NSString stringWithFormat:ASLocalizedString(@"KDChatMemberViewController_members"),[self.chooseContentDelegate.chatViewController getMutiChatGroupParticipantCount]];
    }
//    else if (type == KDChatMemberViewControllerTypeDelete)
//    {
//        self.title = @"删除管理员";
//    }
//    else if (type == KDChatMemberViewControllerTypeManager)
//    {
//        self.title = @"设置管理员";
//    }
}


- (void)setupViews
{
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.sectionIndexColor = FC1;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    [self.tableView makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(-1, 0, 0, 0));
    }];
    
    self.search = [[KDChatDetailSearch alloc] initWithContentsController:self];
    self.search.isDelete = (self.type == KDChatMemberViewControllerTypeDelete);
    self.search.dataArray = self.dataArr;
    self.search.group = self.group;
    self.tableView.tableHeaderView = self.search.searchBar;
}

- (UILocalizedIndexedCollation *)collation {
    if (!_collation) {
        _collation = [UILocalizedIndexedCollation currentCollation];
    }
    return _collation;
}

- (NSMutableArray *)selectedPersonIds
{
    if (!_selectedPersonIds) {
        _selectedPersonIds  = [NSMutableArray array];
    }
    return _selectedPersonIds;
}

- (NSMutableArray *)unVerifiedUsers
{
    if (!_unVerifiedUsers) {
        _unVerifiedUsers = [NSMutableArray array];
    }
    return _unVerifiedUsers;
}

- (NSMutableArray *)unVerifiedUserIds
{
    if (!_unVerifiedUserIds) {
        _unVerifiedUserIds = [NSMutableArray array];
    }
    return _unVerifiedUserIds;
}

- (NSMutableArray *)selectedPersons
{
    if (!_selectedPersons) {
        _selectedPersons  = [NSMutableArray array];
    }
    return _selectedPersons;
}


#pragma mark - TableViewDelegate && DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.mArrayAtoZ count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *title = _mArrayAtoZ[section];
    if (title) {
        
        return [(NSArray *)_mArrayNonEmptySectionArray[section] count];
    }
    
    return 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSMutableArray *sectionIndexTitleArr = _mArrayAtoZ.mutableCopy;
    [sectionIndexTitleArr replaceObjectAtIndex:0 withObject:@" "];
    return sectionIndexTitleArr;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak __typeof(self) weakSelf = self;
    static NSString *cellIdentifier = @"cellIdentifier";

    PersonSimpleDataModel *person = _mArrayNonEmptySectionArray[indexPath.section][indexPath.row];
    
    XTContactPersonViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell ){
        cell = [[XTContactPersonViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setDisplayDepartment:NO];
        [cell.accessoryImageView setHidden:YES];
    }
    cell.person =  person;
    cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    cell.separatorLineInset = UIEdgeInsetsMake(0, 35.0 + 2 * 10, 0, 0);
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PersonSimpleDataModel *person = _mArrayNonEmptySectionArray[indexPath.section][indexPath.row];
    
    //已注销不给点
    if(![person accountAvailable])
        return;
    
    XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:person with:NO];
    personDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personDetail animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = _mArrayAtoZ[section];
    
    if (title)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 22)];
        view.backgroundColor = [UIColor kdSubtitleColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], CGRectGetMinY(view.frame), CGRectGetWidth(view.frame) - [NSNumber kdDistance1], CGRectGetHeight(view.frame))];
        label.text = title;
        label.font = FS7;
        label.textColor = FC1;
        label.backgroundColor = view.backgroundColor;
        [view addSubview:label];
        return view;
    }
    return nil;
}



#pragma mark -
- (BOOL)isExternalPerson:(NSString *)personId
{
    if ([personId isEqualToString:[BOSConfig sharedConfig].user.userId])
    {
        return NO;
    }
    if ([personId hasSuffix:@"_ext"])
    {
        return ![self.contactPersonIdsArray containsObject:[personId substringToIndex:personId.length - 4]];
    }
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    
}


- (void)popToChatViewController
{
    for (UIViewController *viewController in self.navigationController.viewControllers)
    {
        if ([viewController isKindOfClass:[XTChatViewController class]])
        {
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
}

- (BOOL)isManager:(PersonSimpleDataModel *)person
{
    if ([self.group.managerIds containsObject:person.wbUserId] || [self.group.managerIds containsObject:[NSString stringWithFormat:@"%@_ext",person.wbUserId]])
    {
        return YES;
    }
    if ([self.group.managerIds containsObject:person.personId])
    {
        return YES;
    }
    return NO;
}


//- (void)quitBtnPressed:(UIButton *)btn
//{
//    if ([self.group isManager] && self.group.participantIds.count > 1)
//    {
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请先转让管理员权限后再退出多人聊天" message:@"" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
//        [alertView show];
//        
//        return;
//    }
//    
//    UIAlertView *quitAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定退出多人聊天？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
//    quitAlertView.tag = QUIT_BUTTON_TAG;
//    
//    [quitAlertView show];
//}

- (KDUserHelper *)userHelper
{
    if (_userHelper == nil) {
        _userHelper = [[KDUserHelper alloc]init];
    }
    return _userHelper;
}



@end
