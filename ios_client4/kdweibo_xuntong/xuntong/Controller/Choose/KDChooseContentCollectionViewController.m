//
//  KDChooseContentCollectionViewController.m
//  kdweibo
//
//  Created by shen kuikui on 14-5-13.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDChooseContentCollectionViewController.h"
#import "KDSearchBar.h"
#import "XTContactPersonMultipleChoiceCell.h"
#import "KDSearchForXTChatViewController.h"
#import "ContactClient.h"
#import "KDNotificationView.h"
#import "KDUserHelper.h"
#import "SimplePersonListDataModel.h"

@interface KDChooseContentCollectionViewController ()<UITableViewDataSource, UITableViewDelegate, KDSearchBarDelegate, XTSelectPersonsViewDataSource>
{
    struct {
        unsigned int isInSearchMode : 1;
    }_flags;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) KDSearchBar *searchBar;

@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, strong) KDSearchForXTChatViewController *search;

@property (nonatomic, assign) BOOL bSelectAll;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *selectStateImageView;
@property (nonatomic, retain) ContactClient *contactClient;
@property (nonatomic, strong) KDUserHelper *userHelper;
@property (nonatomic, copy) void(^blockRecursiveGetGroupUser)(BOOL, SimplePersonListDataModel *personListData, void(^)());

@property (nonatomic, assign) NSUInteger localUpdateScore;//本地最新score
@property (nonatomic, strong) NSMutableArray *groupData;
@property (nonatomic, strong) NSMutableArray *participantIds;
@end

@implementation KDChooseContentCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _searchResults = [[NSMutableArray alloc] initWithCapacity:10];
        _blockCurrentUser = NO;
        _bShowSelectAll = YES;
    }
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_tableView);
    //KD_RELEASE_SAFELY(_collectionDatas);
    //KD_RELEASE_SAFELY(_searchBar);
    //KD_RELEASE_SAFELY(_searchResults);
    //KD_RELEASE_SAFELY(_selectedPersonsView);
    
    //[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor kdTableViewBackgroundColor];
    
    
    //返回按钮
    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.sectionIndexColor = FC1;
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.rowHeight = 68.0;
    [self.view addSubview:_tableView];
    __weak KDChooseContentCollectionViewController *weakSelf = self;
    
    [_tableView makeConstraints:^(MASConstraintMaker *make)
     {
         if(weakSelf.selectedPersonsView)
         {
             make.left.equalTo(self.view.left).with.offset(0);
             make.right.equalTo(self.view.right).with.offset(-0);
             make.top.equalTo(self.view.top).with.offset(-1);
             make.bottom.equalTo(self.view.bottom).with.offset(-44);
         }
         else
         {
             make.edges.equalTo(self.view).with.insets(UIEdgeInsetsZero);
         }
     }];
    
    self.search = [[KDSearchForXTChatViewController alloc] initWithContentsController:self];
    self.search.selectedPersonsView = self.selectedPersonsView;
    self.search.isMult = self.bShowSelectAll;
    self.search.pType = self.pType;
    self.search.type = self.type;
    self.tableView.tableHeaderView = self.search.searchBar;
    
    if (self.pType == 2) {
        NSMutableArray *partnerPerson = [NSMutableArray array];
        [self.collectionDatas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PersonSimpleDataModel *person = obj;
            if (person.partnerType == 1) {
                [partnerPerson addObject:person];
            }
        }];
        if ([partnerPerson count] >= 1) {
            self.bShowSelectAll = NO;
        }
    }
    
    if (self.pType == 3) {
        NSMutableArray *persons = [NSMutableArray array];
        [self.collectionDatas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PersonSimpleDataModel *person = obj;
            if (person.partnerType == 0) {
                [persons addObject:person];
            }
        }];
        if ([persons count] >= 1) {
            self.bShowSelectAll = NO;
        }
    }
    //获取有权限可见的人员列表
    if(!self.groupId)
    {
        _tableView.delegate = self;
        _tableView.dataSource = self;
        self.search.dataArray = self.collectionDatas;
        return;
    }
    dispatch_queue_t concurrentQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^(void) {
        //迭代获取相关人员信息块
        weakSelf.blockRecursiveGetGroupUser = ^(BOOL succ, SimplePersonListDataModel *personListData, void (^completion)()) {
            // 递归防御
            if (succ){
                if (personListData.hasMore) {
                    [weakSelf fetchGroupUsersByPageWithGroupId:weakSelf.groupId
                                                         Score:[NSString stringWithFormat:@"%ld",personListData.lastUpdateScore]
                                                recursiveBlock:weakSelf.blockRecursiveGetGroupUser
                                                    completion:completion];
                }else
                {
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        weakSelf.participantIds = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupParticipateWithGroupId:weakSelf.groupId];
                        weakSelf.groupData = [[XTDataBaseDao sharedDatabaseDaoInstance]queryGroupParticipatePersonsWithIds:weakSelf.participantIds];
                        weakSelf.collectionDatas =  weakSelf.groupData;
                        weakSelf.search.dataArray =  weakSelf.groupData;
                        
                        //获取有权限可见的人员列表
                        if(self.groupId)
                            [self.contactClient getPerSonAuthorityWithGroupId:self.groupId];
                        
                        [weakSelf.tableView reloadData];
                    });
                    
                }
            }
        };
        [weakSelf fetchGroupUsersByPageWithGroupId:self.groupId
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
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.selectedPersonsView.hidden = NO;
    
    [self.selectedPersonsView addDataSource:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.selectedPersonsView.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.selectedPersonsView removeDataSource:self];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(ContactClient *)contactClient
{
    if(_contactClient == nil)
        _contactClient = [[ContactClient alloc] initWithTarget:self action:@selector(getPerSonAuthority:result:)];
    return _contactClient;
}

-(void)getPerSonAuthority:(ContactClient *)client result:(id)result
{
    if (!client.hasError && result && [result isKindOfClass:[NSData class]]) {
        return;
    }
    
    NSArray *personIds = [((BOSResultDataModel *)result).data objectForKey:@"personIds"] ;
    NSMutableArray *collectionDatas = [NSMutableArray array] ;//autorelease];
    if(personIds)
    {
        [self.collectionDatas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PersonSimpleDataModel *person = obj;
            if([personIds containsObject:person.personId])
                [collectionDatas addObject:person];
        }];
    }
    self.collectionDatas = collectionDatas;
    self.search.dataArray = collectionDatas;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.tableView reloadData];
    
    if(self.collectionDatas.count == 0)
    {
        UIWindow *window = [KDWeiboAppDelegate getAppDelegate].window;
        [[KDNotificationView defaultMessageNotificationView] showInView:window message: ASLocalizedString(@"KDChooseContentCollectionViewController_NoDataTips")type:KDNotificationViewTypeNormal];
    }
}

#pragma mark - View Method
- (UIView *)headerView {
    if (self.bShowSelectAll == NO) {
        return nil;
    }
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(.0, .0, CGRectGetWidth(self.view.frame), 40)];
        _headerView.backgroundColor = [UIColor kdBackgroundColor2];
        
        _selectStateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.bSelectAll ? @"task_editor_finish" : @"task_editor_select"]];
        _selectStateImageView.frame = CGRectMake(0, 0, 25, 25);
        SetOrigin(_selectStateImageView.frame, [NSNumber kdDistance1]+3.0f, (CGRectGetHeight(_headerView.frame) - CGRectGetHeight(_selectStateImageView.frame)) / 2);
        [_headerView addSubview:_selectStateImageView];
        
        UILabel *labelSelectAll = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_selectStateImageView.frame) + [NSNumber kdDistance1], (CGRectGetHeight(_headerView.frame) - CGRectGetHeight(_selectStateImageView.frame)) / 2, CGRectGetWidth(_headerView.frame) - CGRectGetMaxX(_selectStateImageView.frame) - 2 * [NSNumber kdDistance1], CGRectGetHeight(_selectStateImageView.frame))];
        labelSelectAll.backgroundColor = _headerView.backgroundColor;
        labelSelectAll.font = FS3;
        labelSelectAll.textColor = FC1;
        labelSelectAll.text = ASLocalizedString(@"KDChooseContentCollectionViewController_All");
        [_headerView addSubview:labelSelectAll];
        
        UIButton *buttonSelectAll = [[UIButton alloc] initWithFrame:CGRectMake(.0, .0, ScreenFullWidth, CGRectGetHeight(_headerView.frame))];
        [buttonSelectAll addTarget:self action:@selector(buttonSelectAllPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:buttonSelectAll];
        
        UIImageView*line = [[UIImageView alloc] initWithImage:[XTImageUtil cellSeparateLineImage]] ;//autorelease];
        line.frame = CGRectMake(35 + 2*[NSNumber kdDistance1], _headerView.frame.size.height - 0.5, CGRectGetWidth(self.view.bounds) - 35 + 2*[NSNumber kdDistance1], 0.5);
        [_headerView addSubview:line];
    }
    return _headerView;
}

#pragma mark -- Button Method
-(void)buttonSelectAllPressed:(UIButton *) button
{
    self.bSelectAll = !self.bSelectAll;
    _selectStateImageView.image = [UIImage imageNamed:self.bSelectAll ? @"task_editor_finish" : @"task_editor_select"];

    if(self.bSelectAll){
        self.selectedPersonsView.isStopRefresh = YES;
        [self.selectedPersonsView removeDataSource:self];
        for (PersonSimpleDataModel *person in _collectionDatas) {
            if(self.type == KDChooseContentNormal)
            {
                if((![BOSSetting sharedSetting].supportNotMobile || self.selectedPersonsView.isFromTask) && [person xtAvailable] && [person accountAvailable])
                    [self.selectedPersonsView addPerson:person];
                else if(([BOSSetting sharedSetting].supportNotMobile || self.selectedPersonsView.isFromTask) && [person accountAvailable])
                    [self.selectedPersonsView addPerson:person];
            }
            else
                [self.selectedPersonsView addPerson:person];
        }
        self.selectedPersonsView.isStopRefresh = NO;
        [self.selectedPersonsView addDataSource:self];
        [self.tableView reloadData];
    }else{
        self.selectedPersonsView.isStopRefresh = YES;
        [self.selectedPersonsView removeDataSource:self];
        for (PersonSimpleDataModel *person in _collectionDatas) {
            [self.selectedPersonsView deletePerson:person];
        }
        self.selectedPersonsView.isStopRefresh = NO;
        [self.selectedPersonsView addDataSource:self];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableView Delegate/Datasource methods
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.bShowSelectAll == NO) {
        return 0.f;
    }
    return 40.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self _isInSearchMode]) {
        return _searchResults.count;
    }else {
        return _collectionDatas.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell-identifier";
    XTContactPersonMultipleChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[XTContactPersonMultipleChoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        cell.separateLineImageView.hidden = NO;
        
//        UIImageView*line = [[[UIImageView alloc] initWithImage:[XTImageUtil cellSeparateLineImage]] autorelease];
//        line.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 1);
//        [cell addSubview:line];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.showGrayStyle = (self.type == KDChooseContentNormal);
        cell.isFromTask = self.selectedPersonsView.isFromTask;
    }
    
    PersonSimpleDataModel *person = nil;
    
    if([self _isInSearchMode]) {
        person = [_searchResults objectAtIndex:indexPath.row];
    }else {
        person = [_collectionDatas objectAtIndex:indexPath.row];
    }
    
    cell.person = person;
    //语音会议邀请另外显示 置灰且不可点
    if (_inviteFromAgora) {
        cell.agoraSelected = [self.selectedAgoraPersons containsObject:person];
        cell.userInteractionEnabled = ![self.selectedAgoraPersons containsObject:person];;
    }
    cell.checked = [self.selectedPersonsView.persons containsObject:person];
    cell.pType = self.pType;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PersonSimpleDataModel *person = nil;
    if([self _isInSearchMode]) {
        person = _searchResults[indexPath.row];
    }else {
        person = _collectionDatas[indexPath.row];
    }
    
    //未激活不给点
    if((((![BOSSetting sharedSetting].supportNotMobile || self.selectedPersonsView.isFromTask) &&![person xtAvailable]) || ![person accountAvailable]) && self.type == KDChooseContentNormal)
        return;
    
    XTContactPersonMultipleChoiceCell *cell = (XTContactPersonMultipleChoiceCell *)[tableView cellForRowAtIndexPath:indexPath];
    BOOL checked = cell.checked;
    if (checked == NO && self.selectedPersonsView.isMult == NO && [self.selectedPersonsView.persons count] > 0) {
        //单选时点击其他行，清空数据重选
        [self.selectedPersonsView deleteAllPerson];
        [self.tableView reloadData];
    }
    
    if (self.pType == 2 && person.partnerType == 1) { // 商务伙伴不可选
        return;
    }
    if (self.pType == 3 && person.partnerType == 0) { // 内部员工不可选
        return;
    }
    
    [cell setChecked:!checked animated:YES];
    
    if (checked) {
        [self.selectedPersonsView deletePerson:person];
    } else {
        [self.selectedPersonsView addPerson:person];
    }
    
    [self updateSelectAll];
}

#pragma mark - KDSearchBar Delegate methods
- (void)searchBarTextDidChange:(KDSearchBar *)searchBar
{
    //TODO:search
    [self _searchWithKey:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar
{
    //TODO:search
    [self _searchBarResignFirstResponder];
    [self _searchWithKey:searchBar.text];
    [self _maskViewWithVisible:NO];
}

- (void)searchBarCancelButtonClicked:(KDSearchBar *)searchBar
{
     _searchBar.showsCancelButton = NO;
    [self _searchBarResignFirstResponder];
    [self _maskViewWithVisible:NO];
}

- (void)searchBarTextDidBeginEditing:(KDSearchBar *)searchBar
{
     _searchBar.showsCancelButton = YES;
    [self _switchToSearchMode];
    [self _maskViewWithVisible:YES];
}

- (void)searchBarTextDidEndEditing:(KDSearchBar *)searchBar
{
    [self _searchBarResignFirstResponder];
    [self _maskViewWithVisible:NO];
    
    if(searchBar.text.length == 0) {
        [self _switchToNormalMode];
    }
}

#pragma mark - XTSelectPersonsViewDataSource Methods
- (void)selectPersonViewDidAddPerson:(PersonSimpleDataModel *)person
{
    NSUInteger index = NSNotFound;
    
    if(_flags.isInSearchMode == 1) {
        index = [_searchResults indexOfObject:person];
    }else {
        index = [_collectionDatas indexOfObject:person];
    }
    
    if(index != NSNotFound) {
        XTContactPersonMultipleChoiceCell *cell = (XTContactPersonMultipleChoiceCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell setChecked:YES animated:YES];
    }
    
    [self updateSelectAll];
}

- (void)selectPersonsViewDidDeletePerson:(PersonSimpleDataModel *)person
{
    NSUInteger index = NSNotFound;
    
    if(_flags.isInSearchMode == 1) {
        index = [_searchResults indexOfObject:person];
    }else {
        index = [_collectionDatas indexOfObject:person];
    }
    
    if(index != NSNotFound) {
        XTContactPersonMultipleChoiceCell *cell = (XTContactPersonMultipleChoiceCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell setChecked:NO animated:YES];
    }
    
    [self updateSelectAll];
    [self.search.searchDisplayController.searchResultsTableView reloadData];
}


#pragma mark - Private methods

- (void)updateSelectAll
{
    NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"(SELF in %@)", self.collectionDatas];
    NSArray *filterArray = [self.selectedPersonsView.persons filteredArrayUsingPredicate:thePredicate];
    self.bSelectAll = filterArray.count == _collectionDatas.count;
    _selectStateImageView.image = [UIImage imageNamed:self.bSelectAll ? @"task_editor_finish" : @"task_editor_select"];
}

- (void)_switchToSearchMode
{
    _flags.isInSearchMode = 1;
    [_searchResults addObjectsFromArray:_collectionDatas];
    [_tableView reloadData];
}

- (void)_switchToNormalMode
{
    _flags.isInSearchMode = 0;
    
    [_searchResults removeAllObjects];
    [_tableView reloadData];
}

- (BOOL)_isInSearchMode
{
    return _flags.isInSearchMode == 1;
}

- (void)_searchWithKey:(NSString *)keyWord
{
    NSMutableArray *resutls = [NSMutableArray array];
    
    for(PersonSimpleDataModel *p in _collectionDatas) {
        if([p.personName rangeOfString:keyWord].location != NSNotFound ||
           [p.defaultPhone rangeOfString:keyWord].location != NSNotFound ||
           [p.fullPinyin rangeOfString:keyWord].location != NSNotFound) {
            [resutls addObject:p];
        }
    }
    
    [_searchResults removeAllObjects];
    [_searchResults addObjectsFromArray:resutls];
    [self.tableView reloadData];
}

- (void)_maskViewWithVisible:(BOOL)visible {
#define MASK_VIEW_TAG   10010
    UIView *maskView_ = [self.view viewWithTag:MASK_VIEW_TAG];
        
    if (maskView_ == nil) {
        CGRect rect = _tableView.frame;
        maskView_ = [[UIView alloc] initWithFrame:rect];
        maskView_.backgroundColor = MESSAGE_BG_COLOR;
        maskView_.tag = MASK_VIEW_TAG;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_didTapOnMaskView:)];
        tap.numberOfTapsRequired = 1;
        
        [maskView_ addGestureRecognizer:tap];
//        [tap release];
        
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_didSwipeOnMaskView:)];
        swipe.direction = UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown;
        
        [maskView_ addGestureRecognizer:swipe];
//        [swipe release];
        
        maskView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:maskView_];
//        [maskView_ release];
    }
    
    maskView_.hidden = !visible;
}

- (void)_didTapOnMaskView:(UITapGestureRecognizer *)gestureRecognizer {
    [self _searchBarResignFirstResponder];
}

- (void)_didSwipeOnMaskView:(UISwipeGestureRecognizer *)gestureRecognizer {
    [self _searchBarResignFirstResponder];
}

- (void)_searchBarResignFirstResponder {
    if ([_searchBar isFirstResponder] && [_searchBar canResignFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
}
- (KDUserHelper *)userHelper
{
    if (_userHelper == nil) {
        _userHelper = [[KDUserHelper alloc]init];
    }
    return _userHelper;
}
@end
