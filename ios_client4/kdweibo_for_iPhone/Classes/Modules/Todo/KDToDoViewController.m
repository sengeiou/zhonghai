//
//  KDToDoViewController.m
//  kdweibo
//
//  Created by janon on 15/4/6.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//
#import "NSJSONSerialization+KDCategory.h"
#import "KDToDoViewController.h"
#import "KDActivityCell.h"
#import "KDToDoViewCell.h"
#import "KDToDoOperateCell.h"
#import "KDApplicationQueryAppsHelper.h"
#import "KDToDoMessageDataModel.h"
#import "BOSConfig.h"
#import "NSString+Scheme.h"
#import "KDApplicationQueryAppsHelper.h"
#import "KDInviteColleaguesViewController.h"
#import "GroupDataModel.h"
#import "RecordDataModel.h"

#import "KDTaskDiscussViewController.h"
#import "KDTodoListViewController.h"
#import "NSDictionary+Additions.h"
#import "ProfileViewController2.h"
#import "KDSignInViewController.h"
#import "KDAutoWifiSignInSettingController.h"
//#import "KDAppOpen.h"
#import "GroupDataModel.h"
#import "KDPublicAccountDataModel.h"
#import "RecordListDataModel.h"

#import "KDSignInPoint.h"
#import "KDAddOrUpdateSignInPointController.h"
#import "MBProgressHUD.h"
#import "XTDatabaseTableManager.h"
#import "KDWebViewController.h"
#import "XTDeleteService.h"

#import "ContactClient.h"
#import "BOSSetting.h"
#import "BOSConfig.h"
#import "UIViewController+DZCategory.h"

#define REFRESH_HEADER_HEIGHT 30.0f //分页

#define NUMBER_OF_RECORDS_PER_PAGE1 20
#define TEMP_NUMBER_OF_RECORDS_PER_PAGE1 50

#define NUMBER_OF_SERARCH_PER_PAGE1 20



typedef NS_ENUM(NSUInteger, TodoMessagePagingDirection)
{
    TodoMessagePagingDirectionOld = 0,
    TodoMessagePagingDirectionNew,
    TodoMessagePagingDirectionCurrent,//取现有数据，包含自己，方向为New
};

static NSInteger pageSize = 100;

@interface KDToDoViewController () <UITableViewDelegate, UITableViewDataSource, KDToDoOperateCellDelegate, UIScrollViewDelegate,KDToDoViewCellDelegate,KDTitleNavViewDelegate,KDSearchBarDelegate>
{
    NSIndexPath *_indexPath;
    KDToDoMessageDataModel *_taskMsgDataModel;  //用于保存任务办理状态的信息，任务完成后回调通过它获取对应的msgid 从而改变状态
    BOOL  _isCurrentView;
    NSInteger   _meunSelect;
    
}


@property (nonatomic, strong) NSString *appidString;

@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, assign) CGRect hideFrame;
@property (nonatomic, assign) CGRect showFrame;

@property (nonatomic, strong) UIView *emptyDataLabel;

//代办表的名称
@property (nonatomic, strong) NSString *msgTableName;
@property (nonatomic, strong) NSString *todoTableName;

//刷新动画
@property (nonatomic, assign) BOOL isPaging;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isAllData;
@property (nonatomic, strong) NSTimer *myTimer;
@property (nonatomic, strong) KDToDoMessageDataModel *modelToBeDeleted;
@property (nonatomic, strong) NSMutableArray *storePageArray;

//按页刷新
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, assign) NSInteger operateCellPressed;
@property (nonatomic, assign) NSInteger loadingCellLocation;

@property (nonatomic, strong) ContactClient *toDoListClient;
@property (nonatomic, strong) NSString *grouplistUpdateTime;
//@property (nonatomic, strong) CKSlideSwitchView *slideSwitchView;


@property (nonatomic,strong) NSMutableArray *undoArray;
@property (nonatomic,strong) NSMutableArray *doneArray;

@property (nonatomic, strong) KDToDoMessageDataModel *sortDataModel;

@property (nonatomic, strong) NSString *latestMsgId; // 本地最新的msg id
@property (nonatomic, strong) NSString *oldestMsgId; // 本地最旧的msg id
@property (nonatomic, strong) NSString *latestMsgSendTime; // 本地最新的msg sendTime
@property (nonatomic, strong) NSString *oldestMsgSendTime; // 本地最旧的msg id



@property (nonatomic, copy) NSString *lastMsgId;
@property (nonatomic, copy) NSString *lastMsgSendTime;
/**
 *  消息分页相关
 */
@property (nonatomic, strong) ContactClient *todMsgListClient;
@property(nonatomic, copy) void (^blockMsgListClient)(BOOL succ, NSDictionary *dictData);
@property(nonatomic, assign) BOOL bLoadingLock; //  处理并发
@property (nonatomic, strong) UILabel *pullDownLabel;
@property (nonatomic, strong) UILabel *pullUpLabel;
@property(nonatomic, assign) BOOL bNoMoreOldPagings; // old方向拉倒最好一页
@property (nonatomic, copy) void(^blockRecursiveGetMoreTodoMessagesOld)(BOOL, BOOL, void(^)());
@property (nonatomic, copy) void(^blockRecursiveGetMoreTodoMessagesNew)(BOOL, BOOL, void(^)());

@property (nonatomic, assign) BOOL bFirstFetch;

@property (nonatomic, strong) NSString *todoType;

@property (nonatomic, strong) UIActivityIndicatorView *nextPageIndicatorView;

@property(nonatomic, assign) CGFloat lastContentSizeHeight;

@property (nonatomic, assign) BOOL firtTime;

@property (nonatomic, assign) BOOL fetchNewMsg;

//分页
@property(nonatomic, strong) UIActivityIndicatorView *lastPageIndicatorView;



@property (nonatomic, strong) NSString *lastSearchMsgId;

@property (nonatomic, strong) ContactClient *searchMsgListClient;

//@property (nonatomic, strong) NSString *searchKeyWord;

@property (nonatomic, assign) BOOL needLoad;//

@property (nonatomic, strong) NSString *score;

@property (nonatomic, strong) KDToDoMessageDataModel *oldestMsgModel; // 本地最新的msg score
@property (nonatomic, strong) KDToDoMessageDataModel *latestMsgModel; // 本地最旧的msg score


@property (nonatomic, assign) BOOL loadSearch;//

@property (nonatomic, strong) ContactClient *verifyMsgStatusClient;
@property (nonatomic, strong) ContactClient *changeUndoStateClient;
@property (nonatomic, strong) ContactClient *markedNotifyMsgClient;

@property (nonatomic, strong) UIButton *makedNofifyBtn; //底部

@property (nonatomic, strong) MBProgressHUD *hud;
//分页
@property(nonatomic, strong) UIActivityIndicatorView *makNotifyIndicatorView;

//点击代办重新拉取新消息
@property(nonatomic, assign) BOOL undoTabClick;

@end

@implementation KDToDoViewController
-(instancetype)initWithGroup:(GroupDataModel *)group
{
    self = [super init];
    if (self)
    {
        self.group = group;
        //zgbin:固定跳到待办 20180329
        NSString *todoStatus = @"undo";
        //        if (self.group.todoPriStatus.length > 0) {
        //            todoStatus = self.group.todoPriStatus;
        //        }else{
        //            RecordDataModel *record = group.lastMsg;
        //            todoStatus = record.todoStatus;
        //        }
        self.todoType = todoStatus;
        //end
        
        if ([todoStatus isEqualToString:@"undo"]) {
            _meunSelect = 0;
            self.undoTabClick = YES;
        }else if ([todoStatus isEqualToString:@"done"])
        {
            _meunSelect = 1;
        }else
        {
            self.todoType = @"notify";
            _meunSelect = 2;
        }
        //        self.firtTime = YES;
    }
    return self;
}

- (ContactClient *)verifyMsgStatusClient
{
    if (!_verifyMsgStatusClient) {
        _verifyMsgStatusClient = [[ContactClient alloc]initWithTarget:self action:@selector(verifyMsgStatusClientDidReceived:result:)];
    }
    return _verifyMsgStatusClient;
}
- (void)verifyMsgStatusClientDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success) {
        
    }
}

-(KDToDoViewControllerType)type
{
    if (!_type)
    {
        _type = KDToDoViewControllerType_Normal;
    }
    return _type;
}

- (void)setState:(KDToDoViewControllerType)state
{
    _state = state;
    switch (_state) {
        case KDToDoViewControllerType_Normal:
        {
            CGRect rect = self.tableView.frame;
            NSLog(@"%f",CGRectGetMinY(self.view.frame));
            if (rect.origin.y < CGRectGetHeight(self.titleNavView.frame) + CGRectGetMinY(self.titleNavView.frame)) {
                rect.origin.y += CGRectGetHeight(self.titleNavView.frame);
                rect.size.height -= CGRectGetHeight(self.titleNavView.frame);
                self.tableView.frame = rect;
            }
            if (self.titleNavView.hidden) {
                self.page = 0;
                self.searchBar.hidden = YES;
                self.titleNavView.hidden = NO;
            }
            
        }
            
            break;
        case KDToDoViewControllerType_Special:
        {
            if (!self.titleNavView.hidden) {
                self.titleNavView.hidden = YES;
                CGRect rect = self.tableView.frame;
                rect.origin.y -= CGRectGetHeight(self.titleNavView.frame);
                rect.size.height += CGRectGetHeight(self.titleNavView.frame);
                self.tableView.frame = rect;
            }
            
            
        }
            break;
        case KDToDoViewControllerType_Search:
        {
            if(self.searchBar.hidden)
            {
                self.searchBar.hidden = NO;
                self.titleNavView.hidden = YES;
                
            }
            
            //            CGRect rect = self.tableView.frame;
            //            rect.origin.y += CGRectGetHeight(self.searchBar.frame);
            //            rect.size.height -= CGRectGetHeight(self.searchBar.frame);
            //            self.tableView.frame = rect;
            
        }
            break;
        default:
            break;
    }
}

-(NSMutableArray *)todoArray {
    if (!_todoArray) {
        _todoArray = [NSMutableArray array];
    }
    return _todoArray;
}
-(NSMutableArray *)undoArray {
    if (!_undoArray) {
        _undoArray = [NSMutableArray array];
    }
    return _undoArray;
}
-(NSMutableArray *)doneArray {
    if (!_doneArray) {
        _doneArray = [NSMutableArray array];
    }
    return _doneArray;
}
-(UIView *)emptyDataLabel {
    if (!_emptyDataLabel) {
        _emptyDataLabel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, 120)];
        _emptyDataLabel.center = CGPointMake(ScreenFullWidth / 2.f, 250);
        
        UIImageView *emptyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 86)];
        emptyImageView.image = [UIImage imageNamed:@"blank_placeholder_v2"];
        
        UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 120, 30)];
        emptyLabel.text = ASLocalizedString(@"KDToDoViewController_No_Completed");
        emptyLabel.textColor = [UIColor colorWithRGB:0x98A1A8];
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        
        [_emptyDataLabel addSubview:emptyImageView];
        [_emptyDataLabel addSubview:emptyLabel];
    }
    return _emptyDataLabel;
}

-(NSString *)todoTableName
{
    if (!_todoTableName)
    {
        _todoTableName = [XTDatabaseTableManager tableNameWithTableType:XTTableTypeToDo eId:[BOSConfig sharedConfig].user.eid];
    }
    return _todoTableName;
}

-(NSString *)msgTableName
{
    if (!_msgTableName)
    {
        _msgTableName = [XTDatabaseTableManager tableNameWithTableType:XTTableTypeMessage eId:[BOSConfig sharedConfig].user.eid];
    }
    return _msgTableName;
}

-(NSInteger)page
{
    if (!_page)
    {
        _page = 0;
    }
    return _page;
}

-(KDToDoMessageDataModel *)modelToBeDeleted
{
    if (!_modelToBeDeleted)
    {
        _modelToBeDeleted = [[KDToDoMessageDataModel alloc]init];
    }
    return _modelToBeDeleted;
}

-(BOOL)isPaging
{
    if (!_isPaging)
    {
        _isPaging = NO;
    }
    return _isPaging;
}

-(BOOL)isLoading
{
    if (!_isLoading)
    {
        _isLoading = NO;
    }
    return _isLoading;
}

-(BOOL)isAllData
{
    if (!_isAllData)
    {
        _isAllData = NO;
    }
    return _isAllData;
}

-(NSMutableArray *)storePageArray
{
    if (!_storePageArray)
    {
        _storePageArray = [NSMutableArray array];
    }
    return _storePageArray;
}

-(NSInteger)operateCellPressed
{
    if (!_operateCellPressed)
    {
        _operateCellPressed = -1;
    }
    return _operateCellPressed;
}

-(NSInteger)loadingCellLocation
{
    if (!_loadingCellLocation)
    {
        _loadingCellLocation = -1;
    }
    return _loadingCellLocation;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateToDoMessageDidReceive" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recordToDoTimeLine" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateTodoDataAndUndoMsg" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KD_TODOLIST_STATE_NOTIFICATION object:nil];
}

-(NSString *)grouplistUpdateTime {
    if (!_grouplistUpdateTime) {
        _grouplistUpdateTime = @"";
    }
    return _grouplistUpdateTime;
}
#pragma mark - view
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isCurrentView = YES;
    //为何刷新通知类型的状态
    if (_meunSelect == 2 && self.type == KDToDoViewControllerType_Normal) {
        //        [self refreshNotify];
        [self fetchNewTodoMessages];
        [self sortAllData];
        NSInteger notifyCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"notifyUnreadCount"];
        if (notifyCount > 0 ) {
            [self showMarkedNotifyBtn];
            self.makedNofifyBtn.enabled = YES;
        }else
        {
            [self hideMarkedNotifyBtn];
        }
        
    }else if(!self.makedNofifyBtn.hidden)
    {
        //筛选，搜索状态下不显示
        [self hideMarkedNotifyBtn];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _isCurrentView = NO;
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    [KDWeiboAppDelegate setExtendedLayout:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToDoMessageDidReceive:) name:@"updateToDoMessageDidReceive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordTimeLine:) name:@"recordToDoTimeLine" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskFinished:) name:KD_TODOLIST_STATE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasMsgDelDidReceive:) name:@"updateTodoDataAndUndoMsg" object:nil];
    
    CGRect frame = self.view.frame;
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    KDTitleNavView *titleNavView = [[KDTitleNavView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, ScreenFullWidth, 40)];
    titleNavView.isFillWidth = YES;
    titleNavView.selectedColor = FC5;
    titleNavView.backgroundColor = [UIColor kdBackgroundColor2];
    titleNavView.titleArray = @[ASLocalizedString(@"KDToDoViewController_TODO"),ASLocalizedString(@"KDToDoViewController_Done"),ASLocalizedString(@"KDTodo_Notification")];
    titleNavView.currentIndex = (int)_meunSelect;
    titleNavView.delegate = self;
    self.titleNavView = titleNavView;
    [self.view addSubview:titleNavView];
    if (@available(iOS 11.0, *)) {
    } else {
        [titleNavView.scrollView setContentOffset:CGPointMake(0, 64) animated:YES];
    }
    
    
    
    KDSearchBar  *searchBar = [[KDSearchBar alloc]initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, ScreenFullWidth, 40)];
    searchBar.hidden = YES;
    searchBar.delegate = self;
    searchBar.backgroundColor = [UIColor kdBackgroundColor1];
    
    self.searchBar = searchBar;
    
    [self.view addSubview:self.searchBar];
    
    
    
    frame.origin.y += (kd_StatusBarAndNaviHeight+40);
    frame.size.height -= (kd_StatusBarAndNaviHeight+40 + kd_BottomSafeAreaHeight);
    
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.tableView.bounces = NO;
    [self.tableView setShowsVerticalScrollIndicator:YES];
    [self.tableView setBackgroundColor:[UIColor kdBackgroundColor1]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[KDToDoOperateCell class] forCellReuseIdentifier:@"todoOperate"];
    [self.tableView registerClass:[KDToDoViewCell class] forCellReuseIdentifier:@"todoNormal"];
    [self.tableView registerClass:[KDActivityCell class] forCellReuseIdentifier:@"normalTableViewCell"];
    [self.view addSubview:self.tableView];
    
    [self.navigationController.toolbar setTranslucent:NO];
    //    if (@available(iOS 11.0, *)) {
    //        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    //    } else {
    //        self.automaticallyAdjustsScrollViewInsets = NO;
    //    }
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    [self.view addSubview:self.emptyDataLabel];
    self.emptyDataLabel.hidden = YES;
    
    // 下拉加载菊花
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, REFRESH_HEADER_HEIGHT)];
    label.backgroundColor = [UIColor kdBackgroundColor1];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.center = CGPointMake(label.bounds.size.width / 2, label.bounds.size.height / 2);
    indicatorView.hidesWhenStopped = YES;
    self.lastPageIndicatorView = indicatorView;
    [label addSubview:indicatorView];
    self.tableView.tableFooterView = label;
    self.pullUpLabel = label;
    [self loadOnePageAtViewDidLoad];
    
    self.makedNofifyBtn = [UIButton normalBtnWithTile:ASLocalizedString(@"BubbleTableViewCell_Tip_25")];
    [self.makedNofifyBtn addTarget:self action:@selector(makedNofifyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.makedNofifyBtn];
    [self.makedNofifyBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.bottom).with.offset(-kd_BottomSafeAreaHeight);
        make.height.mas_equalTo(44);
    }];
    [self.makedNofifyBtn addSubview:self.makNotifyIndicatorView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.todoArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row >= self.todoArray.count)
        return [[UITableViewCell alloc] init];
    
    KDToDoMessageDataModel *model = self.todoArray[indexPath.row];
    
    if ([model isEqual:self.modelToBeDeleted] && self.isLoading == YES)
    {
        KDActivityCell *cell = (KDActivityCell *)[self.tableView dequeueReusableCellWithIdentifier:@"normalTableViewCell" forIndexPath:indexPath];
        [cell setActivityAnimate];
        return cell;
    }
    
    if (model.cellType == KDToDoCellType_NotOperateAble)
    {
        KDToDoViewCell *cell = (KDToDoViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"todoNormal" forIndexPath:indexPath];
        [cell setDelegate:self];
        cell.todoVC = self;
        if (KDToDoViewControllerType_Search == _type) {
            cell.searchType = YES;
            cell.searchKeyWord = _searchKeyWord;
        }
        else
        {
            cell.searchType = NO;
            
        }
        [cell anotherSetCellInformation:model];
        return cell;
    }
    else if (model.cellType == KDToDoCellType_Operate_Hide || model.cellType == KDToDoCellType_Operate_Show)
    {
        KDToDoOperateCell *cell = (KDToDoOperateCell *)[self.tableView dequeueReusableCellWithIdentifier:@"todoOperate" forIndexPath:indexPath];
        [cell setDelegate:self];
        [cell anotherSetCellInformation:model];
        return cell;
    }
    else
    {
        return nil;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //正常情况
    KDToDoMessageDataModel *model = self.todoArray[indexPath.row];
    
    if ([model isEqual:self.modelToBeDeleted])
    {
        return 44.0f;
    }
    if (model.cellType == KDToDoCellType_NotOperateAble)
    {
        //针对MessageTypeAttach类型数据做的特殊处理
        if (model.msgType == MessageTypeAttach || model.msgType == MessageTypeText) {
            model.normalCellHeight = [model caculateCellHeightForNormalCellWithString:model.content];
        }
        else{
            model.normalCellHeight = [model caculateCellHeightForNormalCellWithString:model.text];
        }
        return model.normalCellHeight ;
    }
    else if (model.cellType == KDToDoCellType_Operate_Hide)
    {
        return [model caculateCellHeightForNormalCellWithString:model.text] ;
    }
    else if (model.cellType == KDToDoCellType_Operate_Show)
    {
        return 80.0f + 38.0f + model.caculateHeight;
    }
    else
    {
        return 0.0f;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDToDoMessageDataModel *model = self.todoArray[indexPath.row];
    
    [self makeNoteWhenCellClicked:model IndexPath:indexPath];
    
    if (model.cellType == KDToDoCellType_Operate_Show)
    {
        [self showCellSelectWithModel:model IndexPath:indexPath];
    }
    else if (model.cellType == KDToDoCellType_Operate_Hide)
    {
        [self hideCellSelectWithModel:model IndexPath:indexPath];
    }
    else if (model.cellType == KDToDoCellType_NotOperateAble)
    {
        [self normalCellSelectWithModel:model IndexPath:indexPath];
    }
    //刷新界面
    if (self.type == KDToDoViewControllerType_Normal)
    {
        [self sortAllData];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)refreshNotify
{
    if (_meunSelect == 2) {
        NSString *tempString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE todoStatus = '' OR todoStatus is null ORDER BY status, sendTime DESC LIMIT %ld;", self.todoTableName, [self.todoArray count]];
        self.todoArray= [[XTDataBaseDao sharedDatabaseDaoInstance] queryPageOfToDoRecordWithSql:tempString];
        
    }
}

#pragma mark - Select Action
- (void)makeNoteWhenCellClicked:(KDToDoMessageDataModel *)model IndexPath:(NSIndexPath *)indexPath
{
    DLog(@"model.param = %@", model.param);
    
    NSString *sourceGroupId = @"";
    if (safeString(model.url).length > 0) {
        KDSchemeHostType t;
        NSDictionary *dic = [model.url schemeInfoWithType:&t shouldDecoded:NO];
        if (t == KDSchemeHostType_Chat) {
            sourceGroupId = [dic objectForKey:@"groupId"];
        }
    }
    
    [[KDApplicationQueryAppsHelper shareHelper] todoMsgStateChangeWithMsgDataModel:model andSourceGroupId:sourceGroupId];
    DLog(@"msgId:%@, readState:Yes", model.msgId);
}

- (void)hideCellSelectWithModel:(KDToDoMessageDataModel *)model IndexPath:(NSIndexPath *)indexPath
{
    [model setStatus:MessageStatusRead];
    [model adjustModelForCellTypeShow:model.text];
    [model setCellType:KDToDoCellType_Operate_Show];
    [self setOperateCellPressed:indexPath.row];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (indexPath.row == self.todoArray.count - 1)
    {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

- (void)showCellSelectWithModel:(KDToDoMessageDataModel *)model IndexPath:(NSIndexPath *)indexPath
{
    [model setStatus:MessageStatusRead];
    [model adjustModelForCellTypeHide];
    [model setCellType:KDToDoCellType_Operate_Hide];
    [self setOperateCellPressed:indexPath.row];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (indexPath.row == self.todoArray.count - 1)
    {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

- (void)normalCellSelectWithModel:(KDToDoMessageDataModel *)model IndexPath:(NSIndexPath *)indexPath
{
    //本地数据库中，标记为已读
    [[XTDataBaseDao sharedDatabaseDaoInstance] updateToDoWhenHasMsgIdWithStatus:@"1" MsgId:model.msgId];
    [model setStatus:MessageStatusRead];
    if(indexPath.row >= 0 && indexPath.row < self.todoArray.count)
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    else
        [self.tableView reloadData];
    
    NSString *url = model.url;
    NSString *title = model.title;
    
    if (model.msgType == MessageTypeAttach) {
        MessageAttachDataModel *paramObject = model.param.paramObject;
        MessageAttachEachDataModel *attach = [paramObject.attach objectAtIndex:0];
        url = attach.value;
        title = attach.name;
    }
    else
    {
        url = model.url;
        title = model.title;
    }
    //打开连接
    [self openWithUrl:url
                appId:model.appid
                title:title
                share:[self makeMessageNewsEachDataModel:model]
         messageModel:model
            IndexPath:indexPath];
    //重新从database获取数据，刷新table定位到当前
    //    [self queryDataBaseWithTodoMsgStateUpdateWithMsgCount:self.todoArray.count];
    //    [self queryDataBaseWithLocation:indexPath.row];
}
#pragma mark - queryDataBaseWithCaculatePage
//- (void)queryDataBaseWithLocation:(NSInteger)location
//{
//    NSString *tempString = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY readState, sendTime DESC LIMIT %d;", self.todoTableName, self.page * pageSize];
//    NSMutableArray *tempArray = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPageOfToDoRecordWithSql:tempString];
//    [self.todoArray removeAllObjects];
//    [self.todoArray addObjectsFromArray:tempArray];
//    [self.tableView reloadData];
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:location inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
//}
#pragma mark - KDToDoOperateCellDelegate

- (void)bubbleDidDeleteMsgWithModel:(KDToDoMessageDataModel *)model cell:(KDToDoViewCell *)cell {
    __block NSInteger location = -1;
    
    [self.todoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KDToDoMessageDataModel *todoMsg = (KDToDoMessageDataModel *)obj;
        if([todoMsg.msgId isEqualToString:model.msgId])
        {
            location = idx;
            *stop = YES;
        }
    }];
    
    if(location == -1)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:location inSection:0];
    [self.todoArray removeObjectAtIndex:location];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[XTDeleteService shareService] deleteMessageWithGroupId:self.group.groupId msgId:model.msgId];
}

- (void)changeUndoMsgWithModel:(KDToDoMessageDataModel *)model cell:(KDToDoViewCell *)cell
{
    if (self.changeUndoStateClient == nil) {
        self.changeUndoStateClient = [[ContactClient alloc]initWithTarget:self action:@selector(changeUndoMsgClientDidReceived:result:)];
    }
    [self.changeUndoStateClient ignoreUndoMessageWithGroupId:model.groupId MsgId:model.msgId];
}
- (void)changeUndoMsgClientDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success) {
        
    }
}

-(void)leftButtonWithcell:(KDToDoOperateCell *)cell Dic:(NSDictionary *)dic Model:(KDToDoMessageDataModel *)model
{
    DLog(@"办理");
    [self openWithUrl:[dic objectForKey:@"url"]
                appId:[dic objectForKey:@"appid"]
                title:[dic objectForKey:@"title"]
                share:[self makeMessageNewsEachDataModel:model]
         messageModel:model
            IndexPath:[self.tableView indexPathForCell:cell]];
    //标记为已读
    [[XTDataBaseDao sharedDatabaseDaoInstance] updateToDoWhenHasMsgIdWithStatus:@"1" MsgId:model.sourceMsgId];
    [model setStatus:MessageStatusRead];
    [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    DLog(@"url = %@", [dic objectForKey:@"url"]);
}

-(void)middleButtonWithcell:(KDToDoOperateCell *)cell Dic:(NSDictionary *)dic Model:(KDToDoMessageDataModel *)model
{
    DLog(@"不办理");
    [self openWithUrl:[dic objectForKey:@"url"]
                appId:[dic objectForKey:@"appid"]
                title:[dic objectForKey:@"title"]
                share:[self makeMessageNewsEachDataModel:model]
         messageModel:model
            IndexPath:[self.tableView indexPathForCell:cell]];
    //标记为已读
    [[XTDataBaseDao sharedDatabaseDaoInstance] updateToDoWhenHasMsgIdWithStatus:@"1" MsgId:model.sourceMsgId];
    [model setStatus:MessageStatusRead];
    [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    DLog(@"url = %@", [dic objectForKey:@"url"]);
}

-(void)rightButtonWithcell:(KDToDoOperateCell *)cell Dic:(NSDictionary *)dic Model:(KDToDoMessageDataModel *)model
{
    DLog(@"不处理");
    [self openWithUrl:[dic objectForKey:@"url"]
                appId:[dic objectForKey:@"appid"]
                title:[dic objectForKey:@"title"]
                share:[self makeMessageNewsEachDataModel:model]
         messageModel:model
            IndexPath:[self.tableView indexPathForCell:cell]];
    //标记为已读
    [[XTDataBaseDao sharedDatabaseDaoInstance] updateToDoWhenHasMsgIdWithStatus:@"1" MsgId:model.sourceMsgId];
    [model setStatus:MessageStatusRead];
    [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    DLog(@"url = %@", [dic objectForKey:@"url"]);
}

#pragma mark - UIScrollViewDelegate  Animation
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.todoArray.count - 1 inSection:0]];
    BOOL hasBottomCell = [self.tableView.visibleCells containsObject:cell];
    //屏蔽动画 去除闪退
    // if (hasBottomCell == YES && self.isLoading == NO && self.isAllData == NO) [self loadingAnimation];
}

-(void)loadingAnimation
{
    self.loadingCellLocation = self.todoArray.count - 1;
    
    //下拉动画
    self.isLoading = YES;
    self.isPaging = YES;
    
    [self.todoArray addObject:self.modelToBeDeleted];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.todoArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.todoArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(mYTimerAction) userInfo:nil repeats:YES];
    
    //    self.storePageArray = [self queryDataBaseWithCaculatePageWithPage];
    if (self.storePageArray.count == 0 || self.storePageArray == nil || [self.storePageArray isKindOfClass:[NSNull class]]) self.isAllData = YES;
    self.isPaging = NO;
}

-(void)mYTimerAction
{
    if (self.isPaging == NO)
    {
        if (self.isAllData == YES)
        {
            [self.todoArray removeObject:self.modelToBeDeleted];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.todoArray.count inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.loadingCellLocation inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [self.myTimer invalidate];
            if (self.isAllData == YES) self.page--; DLog(@"page = %li", (long)self.page);
            self.isLoading = NO;
            self.loadingCellLocation = -1;
        }
        else
        {
            [self.todoArray removeObject:self.modelToBeDeleted];
            [self.todoArray addObjectsFromArray:self.storePageArray];
            [self.storePageArray removeAllObjects];
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.loadingCellLocation inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [self.myTimer invalidate];
            self.isLoading = NO;
            self.loadingCellLocation = -1;
        }
    }
}

#pragma mark - queryDataBaseWithCaculatePage
- (void)queryDataBaseWithTodoMsgStateUpdateWithMsgCount:(NSInteger)count
{
    NSString *tempString = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY status, sendTime DESC LIMIT %ld;", self.todoTableName, self.page * pageSize];
    NSMutableArray *tempArray = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPageOfToDoRecordWithSql:tempString];
    [self.todoArray removeAllObjects];
    [self.todoArray addObjectsFromArray:tempArray];
    self.emptyDataLabel.hidden = YES;
    [self.tableView reloadData];
    DLog(@"发生了状态回调");
}

- (NSMutableArray *)queryDataBaseWithCaculatePageWithPage
{
    if (self.type == KDToDoViewControllerType_Normal)
    {
        return [self queryDataBaseWithCaculatePageWithPageInNormalState];
    }
    else if (self.type == KDToDoViewControllerType_Special)
    {
        return [self queryDataBaseWithCaculatePageWithPageInSpecialState];
    }
    else
    {
        return nil;
    }
}

-(NSMutableArray *)queryDataBaseWithCaculatePageWithPageInNormalState
{
    //改改改
    NSString *tempString = nil;
    NSMutableArray *tempArray = [NSMutableArray array];
    
    
    if (self.page == 0)
    {
        tempString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE todoStatus = '' OR todoStatus is null ORDER BY status, sendTime DESC LIMIT %ld;", self.todoTableName, (long)pageSize];
        self.page++;
        tempArray = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPageOfToDoRecordWithSql:tempString];
        
        //保存最后一条消息
        if (_meunSelect == 2) {
            NSString *tempString1 = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE todoStatus = '' OR todoStatus is null ORDER BY sendTime DESC LIMIT %ld;", self.todoTableName, (long)pageSize];
            NSArray *tempArray1 = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPageOfToDoRecordWithSql:tempString1];
            if ([tempArray1 count] > 0) {
                KDToDoMessageDataModel *notifyModel = [tempArray1 lastObject];
                [[NSUserDefaults standardUserDefaults] setValue:notifyModel.msgId forKey:@"oldNotifyMsgId"];
                [[NSUserDefaults standardUserDefaults] setValue:notifyModel.score forKey:@"oldNotifyMsgScore"];
            }
            
        }
        
        
        return tempArray;
    }
    else
    {
        tempString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE todoStatus = '' OR todoStatus is null ORDER BY status, sendTime DESC LIMIT %ld OFFSET %ld;", self.todoTableName, (long)pageSize, self.page * pageSize];
        self.page++;
        tempArray = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPageOfToDoRecordWithSql:tempString];
        
        if (_meunSelect == 2) {
            NSString *tempString1 = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE todoStatus = '' OR todoStatus is null ORDER BY sendTime DESC LIMIT %ld OFFSET %ld;", self.todoTableName, (long)pageSize, self.page * pageSize];
            NSArray *tempArray2 = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPageOfToDoRecordWithSql:tempString1];
            if ([tempArray2 count] > 0) {
                KDToDoMessageDataModel *notifyModel = [tempArray2 lastObject];
                [[NSUserDefaults standardUserDefaults] setValue:notifyModel.msgId forKey:@"oldNotifyMsgId"];
                [[NSUserDefaults standardUserDefaults] setValue:notifyModel.score forKey:@"oldNotifyMsgScore"];
            }
        }
        
        return tempArray;
    }
}

-(NSMutableArray *)queryDataBaseWithCaculatePageWithPageInSpecialState
{
    NSString *tempString = nil;
    NSMutableArray *tempArray = [NSMutableArray array];
    
    pageSize = 50;
    if (self.page == 0)
    {
        tempString = [NSString stringWithFormat:@"%@ LIMIT %li;", self.appidString, (long)pageSize];
        self.page++;
        tempArray = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPageOfToDoRecordWithSql:tempString];
        //如果小于100 则为全部数据
        if ([tempArray count] < (long)pageSize) {
            self.isAllData = YES;
        }
        return tempArray;
    }
    else
    {
        tempString = [NSString stringWithFormat:@"%@ LIMIT %li OFFSET %li;", self.appidString, (long)pageSize, (long)self.page * pageSize];
        self.page++;
        tempArray = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPageOfToDoRecordWithSql:tempString];
        return tempArray;
    }
}

#pragma mark - SortDelegate
-(void)sortNewDataWithModel:(KDToDoMessageDataModel*)model
{
    [self hideMarkedNotifyBtn];
    if ([self.todoArray count] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [self.todoArray removeAllObjects];
        [self.tableView reloadData];
    }
    self.page = 0;
    self.isAllData = NO;
    self.type = KDToDoViewControllerType_Special;
    self.sortDataModel = model;
    self.appidString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE ", self.todoTableName];
    
    if (_meunSelect == 0) {
        //undo
        self.appidString = [self.appidString stringByAppendingFormat:@"todoStatus = 'undo' AND "];
        
    }
    else if (_meunSelect == 1)
    {
        self.appidString =[self.appidString stringByAppendingFormat:@"todoStatus = 'done' AND "];
    } else if (_meunSelect == 2)
    {
        self.appidString =[self.appidString stringByAppendingFormat:@"(todoStatus = '' OR todoStatus is null) AND "];
    }
    
    //当为提及时 条件改为appid
    NSString *title = model.title;
    if ([model.title isEqualToString:@"@提及"])
    {
        self.appidString = [self.appidString stringByAppendingFormat:@"appid = '' "];
        title = @"";
    }
    //当为文本消息时 条件改为msgType
    else if ([model.title isEqualToString:ASLocalizedString(@"KDToDoViewCell_text")]) {
        self.appidString = [self.appidString stringByAppendingFormat:@"msgType = '%d' ", 2];
    }
    else
    {
        //notification
        self.appidString = [self.appidString stringByAppendingFormat:@"title = '%@' ", model.title];
    }
    //    [self setRedDotWithTitle:title];
    self.appidString = [self.appidString stringByAppendingString:@"ORDER BY sendTime DESC"];
    DLog(@"self.appidString = %@", self.appidString);
    
    
    [self.todoArray addObjectsFromArray:[self queryDataBaseWithCaculatePageWithPageInSpecialState]];
    if (self.todoArray.count > 0)
    {
        [self.tableView setScrollEnabled:YES];
        self.emptyDataLabel.hidden = YES;
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    else
    {
        [self.tableView reloadData];
        self.emptyDataLabel.hidden = NO;
        [self.tableView setScrollEnabled:NO];
    }
    self.isAllData = NO;
    self.type = KDToDoViewControllerType_Special;
}

-(void)sortAllData
{
    self.isAllData = NO;
    if (_meunSelect != 2) {
        if ([self.todoArray count ] > 0) {
            NSArray *result = [self.todoArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                
                KDToDoMessageDataModel *model1 =  (KDToDoMessageDataModel *)obj1;
                KDToDoMessageDataModel *model2 =  (KDToDoMessageDataModel *)obj2;
                return [model2.sendTime compare:model1.sendTime]; //降序
                
            }];
            [self.todoArray removeAllObjects];
            [self.todoArray addObjectsFromArray:result];
        }
        
    }else
    {
        if (_meunSelect == 2) {
            NSString *tempString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE todoStatus = '' OR todoStatus is null ORDER BY status, sendTime DESC LIMIT %ld;", self.todoTableName, [self.todoArray count]];
            self.todoArray= [[XTDataBaseDao sharedDatabaseDaoInstance]queryPageOfToDoRecordWithSql:tempString];
            
        }
    }
    
    
    [self setRedDot];
    
    if (self.todoArray.count > 0)
    {
        //刷新代办消息
        //        if (self.type == KDToDoViewControllerType_Special) {
        //            [self sortNewDataWithModel:self.sortDataModel];
        //        }else
        //        {
        [self.tableView setScrollEnabled:YES];
        self.emptyDataLabel.hidden = YES;
        
        self.lastContentSizeHeight = self.tableView.contentSize.height;
        [self.tableView reloadData];
        if (_meunSelect == 2) {
            [self.tableView scrollsToTop];
        }
        //        }
    }
    else
    {
        [self.tableView reloadData];
        self.emptyDataLabel.hidden = NO;
        [self.tableView setScrollEnabled:NO];
    }
}

#pragma mark - NSNotification
-(void)updateToDoMessageDidReceive:(NSNotification *)sender
{
    NSDictionary *dic = sender.userInfo;
    NSString *info = [dic objectForKey:@"info"];
    
    //如果是筛选出特殊状态,不做更新,回退的时候调用sortAllData会做更新
    if (self.type == KDToDoViewControllerType_Special || self.type == KDToDoViewControllerType_Special)
    {
        return;
    }
    
    //如果是普通状态才会做更新
    if (self.type == KDToDoViewControllerType_Normal)
    {
        if ([info isEqualToString:@"updateTodoState"])
        {
            DLog(@"代办状态更新");
            [self queryDataBaseWithTodoMsgStateUpdateWithMsgCount:self.todoArray.count];
            return;
        }
        
    }
}

-(void)recordTimeLine:(NSNotification *)sender
{
    if (self.type == KDToDoViewControllerType_Search || !_isCurrentView) {
        return;
    }
    NSString *todoStatus = [sender.userInfo objectForKey:@"todoStatus"];
    BOOL needFectchMsg = NO;
    //只有在当前页才加载数据
    switch (_meunSelect) {
        case 0:
            if ([todoStatus isEqualToString:@"undo"]) {
                needFectchMsg =  YES;
            }
            break;
        case 1:
            if ([todoStatus isEqualToString:@"done"]) {
                needFectchMsg =  YES;
            }
            break;
            
        case 2:
            if ([todoStatus isEqualToString:@""]) {
                needFectchMsg =  YES;
            }
            break;
        default:
            break;
    }
    if (needFectchMsg) {
        [self fetchNewTodoMessages];
    }else
    {
        [self setRedDot];
    }
}

#pragma mark - Jump Action
- (void)openWithUrl:(NSString *)url appId:(NSString *)appId title:(NSString *)title share:(MessageNewsEachDataModel *)share messageModel:(KDToDoMessageDataModel *)theModel IndexPath:(NSIndexPath *)indexPath
{
    [self makeNoteForPubAccountWithMessageModel:theModel];
    if (indexPath != nil) {
        _indexPath = nil;
    }
    [self.verifyMsgStatusClient verifyMsgStatusWithGroupId:theModel.groupId userId:[BOSConfig sharedConfig].user.userId msgId:theModel.msgId todoStatus:theModel.todoStatus];
    _indexPath = indexPath;
    if (url.length > 0)
    {
        KDSchemeHostType t;
        NSDictionary *dic = [url schemeInfoWithType:&t shouldDecoded:NO];
        
        if (t == KDSchemeHostType_Chat)   //会话
        {
            if ([dic objectNotNSNullForKey:@"groupId"] && [dic objectNotNSNullForKey:@"msgId"])
            {
                GroupDataModel *gdm = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:[dic objectNotNSNullForKey:@"groupId"]];
                if (gdm)
                {
                    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:gdm pubAccount:nil mode:ChatPrivateMode];
                    chatViewController.hidesBottomBarWhenPushed = YES;
                    chatViewController.strScrollToMsgId = [dic objectNotNSNullForKey:@"msgId"];
                    
                    [self.navigationController pushViewController:chatViewController animated:YES];
                }
                else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:ASLocalizedString(@"TODO_msg_no_exit") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        [[XTDataBaseDao sharedDatabaseDaoInstance] deleteToDoDataWithMsgId:[dic objectForKey:@"msgId"]];
                        
                        [self.todoArray removeObjectAtIndex:indexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                    }];
                    [alert addAction:confirmAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }            }
        }
        else if (t == KDSchemeHostType_PersonalSetting)   //个人设置
        {
            ProfileViewController2 *profile = [[ProfileViewController2 alloc] init];
            [self.navigationController pushViewController:profile animated:YES];
        }
        else if (t == KDSchemeHostType_Status)
        {
            //            url = [url stringByReplacingOccurrencesOfString:@"cloudhub://status?id" withString:@"kdweibo://status?statusId"];
            //            url = [url appendParamsForShare];
            //            NSURL *realUrl = [NSURL URLWithString:url];
            //            [KDAppOpen openURL:realUrl];
        }
        else if (t == KDSchemeHostType_Unknow)
        {
            //            if ([url hasPrefix:@"kdweibo://"])
            //            {
            //                url = [url appendParamsForShare];
            //            }
            //            NSURL *realUrl = [NSURL URLWithString:url];
            //            [KDAppOpen openURL:realUrl];
        }
        else if (t == KDSchemeHostType_Invite)
        {
            //埋点
            [[KDApplicationQueryAppsHelper shareHelper] todoMsgStateChangeWithSourceMsgId:theModel.sourceMsgId PersonId:[BOSConfig sharedConfig].user.userId ReadState:YES DoneState:YES];
            
            KDInviteColleaguesViewController *contact = [[KDInviteColleaguesViewController alloc] init];
            contact.isFromFirstToDo = YES;
            contact.hasBackBtn = YES;
            contact.inviteSource = KDInviteSourceContact;
            contact.bShouldDismissOneLayer = YES;
            UINavigationController *contactNav = [[UINavigationController alloc] initWithRootViewController:contact];
            contactNav.delegate = [KDNavigationManager sharedNavigationManager];
            //在present动画结束之前锁住不让点击，因为用户点击蒙层过早会出现bug。
            
            contactNav.view.userInteractionEnabled = NO;
            [self presentViewController:contactNav animated:YES completion:^
             {
                 contactNav.view.userInteractionEnabled = YES;
             }];
        }
        else if (t == KDSchemeHostType_HTTP || t == KDSchemeHostType_HTTPS || t == KDSchemeHostType_NOTURI)
        {
            //可能是轻应用
            NSString *groupID = nil;
            NSString *msgId = nil;
            if ([dic isKindOfClass:[NSDictionary class]] && [dic objectNotNSNullForKey:@"groupId"])
            {
                groupID = [dic objectNotNSNullForKey:@"groupId"];
            }
            if ([dic isKindOfClass:[NSDictionary class]] && [dic objectNotNSNullForKey:@"msgId"])
            {
                msgId = [dic objectNotNSNullForKey:@"msgId"];
            }
            
            [self openLightAppWithUrl:url appId:appId title:title share:share groupId:groupID  userId:[BOSConfig sharedConfig].user.userId  msgId:msgId todoStatus:theModel.todoStatus];
        }
        else if (t == KDSchemeHostType_Todo)   //任务详情
        {
            //每次进来添加这个接口 陈俊全要求
            //            NSString *groupID = nil;
            //            NSString *msgId = nil;
            //            if ([dic isKindOfClass:[NSDictionary class]] && [dic objectNotNSNullForKey:@"groupId"])
            //            {
            //                groupID = [dic objectNotNSNullForKey:@"groupId"];
            //            }
            //            if ([dic isKindOfClass:[NSDictionary class]] && [dic objectNotNSNullForKey:@"msgId"])
            //            {
            //                msgId = [dic objectNotNSNullForKey:@"msgId"];
            //            }
            
            
            //打开任务详情前保存该消息的数据模型
            if (_taskMsgDataModel != nil) {
                _taskMsgDataModel = nil;
                
            }
            _taskMsgDataModel = theModel;
            NSString *taskId = [dic stringForKey:@"id"];
            KDTaskDiscussViewController *ctr = [[KDTaskDiscussViewController alloc] initWithTaskId:taskId];
            ctr.hidesBottomBarWhenPushed = YES;
            [self.navigationController  pushViewController:ctr animated:YES];
        }
        else if (t == KDSchemeHostType_Todolist)   //任务列表
        {
            KDTodoListViewController *ctr = [[KDTodoListViewController alloc] initWithTodoType:kTodoTypeUndo];
            ctr.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:ctr animated:YES];
        }
        else if(t == KDSchemeHostType_Signin)
        {
            KDSignInViewController *signInController = [[KDSignInViewController alloc] init];
            signInController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:signInController animated:YES];
        }
        else if(t == KDSchemeHostType_wifiSignInSetting)
        {
            //            KDAutoWifiSignInSettingController *autoWifiSignInController = [[KDAutoWifiSignInSettingController alloc] init];
            //            [self.navigationController pushViewController:autoWifiSignInController animated:YES];
        }
        else if(t == KDSchemeHostType_wifiLink)
        {
            //进入编辑页面
            NSString *attendSetId = [dic stringForKey:@"attendSetId"];
            if(attendSetId && ! [attendSetId isKindOfClass:[NSNull class]])
            {
                [self findAttendSet4EditWithAttendsetid:attendSetId];
            }
            else
            {
                NSString *latitudeStr = [dic stringForKey:@"latitude"];
                NSString *longitudeStr = [dic stringForKey:@"longitude"];
                if(latitudeStr && longitudeStr && ![latitudeStr isKindOfClass:[NSNull class]] && ![longitudeStr isKindOfClass:[NSNull class]])
                {
                    double latitudeValue = [latitudeStr doubleValue];
                    double longitudeValue = [longitudeStr doubleValue];
                    NSString *positionNameStr = [dic stringForKey:@"positionName"];
                    NSString *addressStr = [dic stringForKey:@"address"];
                    [self goingToAddOrUpdateSignInPointControllerWithLat:latitudeValue lon:longitudeValue position:positionNameStr address:addressStr];
                }
            }
        }
    }
    else
    {
        //可能是轻应用
        [self openLightAppWithUrl:@"" appId:appId title:title share:share groupId:nil  userId:nil  msgId:nil todoStatus:theModel.todoStatus];
    }
    
}

- (void)openLightAppWithUrl:(NSString *)url appId:(NSString *)appId title:(NSString *)title share:(MessageNewsEachDataModel *)share groupId:(NSString *)groupId userId:(NSString *)userId msgId:(NSString *)msgId todoStatus:(NSString *)todoStatus
{
    
    if (url.length == 0 && appId.length == 0)
    {
        return;
    }
    
    KDWebViewController *webVC = nil;
    if (appId.length > 0)
    {
        webVC = [[KDWebViewController alloc] initWithUrlString:url appId:appId];
    }
    else   //专门用来处理消息里面的url链接点击跳转的逻辑
    {
        if ([self.group.groupId rangeOfString:@"XT"].location != NSNotFound && [self.group.participant count] == 1)
        {
            PersonSimpleDataModel *person = [self.group.participant firstObject];
            webVC = [[KDWebViewController alloc] initWithUrlString:url pubAccId:person.personId menuId:@"pubmessagelink"];
        }
        else
        {
            webVC = [[KDWebViewController alloc] initWithUrlString:url];
        }
    }
    webVC.todoGroupId = groupId;
    webVC.todoUserId = userId;
    webVC.todoMsgId = msgId;
    webVC.todoStatus = todoStatus;
    if (webVC)
    {
        GroupDataModel *group = self.group;
        PersonSimpleDataModel *person = [group firstParticipant];
        if ([person isPublicAccount])
        {
            KDPublicAccountDataModel *pubAcct = (KDPublicAccountDataModel *)person;
            if (pubAcct.share)
            {
                webVC.personDataModel = pubAcct;
                //传入数据，用于分享
                webVC.shareNewsDataModel = share;
            }
        }
        webVC.title = title;
        webVC.hidesBottomBarWhenPushed = YES;
        
        
        __weak __typeof(webVC) weak_webvc = webVC;
        __weak __typeof(self) weak_controller = self;
        webVC.getLightAppBlock = ^() {
            if(weak_webvc && !weak_webvc.bPushed){
                [weak_controller.navigationController pushViewController:weak_webvc animated:YES];
            }
        };
    }
}

-(MessageNewsEachDataModel *)makeMessageNewsEachDataModel:(KDToDoMessageDataModel *)model
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    //如果点击跳转用不到recordTimeLine里面的param里面的参数,model里面的这些值全部都会是空,set就会出错
    if (model.appid != nil && ![model.appid isKindOfClass:[NSNull class]])
    {
        [dic setObject:model.appid forKey:@"appid"];
    }
    if (model.date != nil && ![model.date isKindOfClass:[NSNull class]])
    {
        [dic setObject:model.date forKey:@"date"];
    }
    if (model.name != nil && ![model.name isKindOfClass:[NSNull class]])
    {
        [dic setObject:model.name forKey:@"name"];
    }
    if (model.text != nil && ![model.text isKindOfClass:[NSNull class]])
    {
        [dic setObject:model.text forKey:@"text"];
    }
    if (model.title != nil && ![model.title isKindOfClass:[NSNull class]])
    {
        [dic setObject:model.title forKey:@"title"];
    }
    if (model.url != nil && ![model.url isKindOfClass:[NSNull class]])
    {
        [dic setObject:model.url forKey:@"url"];
    }
    if (model.row != nil && ![model.row isKindOfClass:[NSNull class]])
    {
        [dic setObject:model.row forKey:@"row"];
    }
    
    MessageNewsEachDataModel *eachModel = [[MessageNewsEachDataModel alloc]initWithDictionary:dic];
    
    return eachModel;
}

-(void)makeNoteForPubAccountWithMessageModel:(KDToDoMessageDataModel *)theModel
{
    //    [[KDApplicationQueryAppsHelper shareHelper] makeNoteForPubAccountMsgClickedWithPubId:@"" MsgId:theModel.msgId];
    PersonSimpleDataModel *model = self.group.participant.firstObject;
    NSString *pid = model.personId;
    
    //是代办时，公共号id设置为@""
    if ([pid isEqualToString:@"XT-10001"])
    {
        pid = @"";
    }
    
    //是公共号的时候才统计
    //    if ([pid rangeOfString:@"XT"].location != NSNotFound || [pid isEqualToString:@""])
    //    {
    //        [[KDApplicationQueryAppsHelper shareHelper] makeNoteForPubAccountMsgClickedWithPubId:pid MsgId:theModel.msgId];
    //        //[[KDApplicationQueryAppsHelper shareHelper] makeNoteForPubAccountMsgClickedWithPubId:pid MsgId:self.dataInternal.record.msgId];
    //    }
    
}

#pragma mark - SignIn
- (void)findAttendSet4EditWithAttendsetid:(NSString *)attendSetId
{
    __weak KDToDoViewController *weakSelf = self;
    [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        if (results)
        {
            if([results[@"success"] boolValue])
            {
                KDSignInPoint *signInPoint = [[KDSignInPoint alloc] initWithDictionary:results[@"data"]];
                KDAddOrUpdateSignInPointController *controller = [[KDAddOrUpdateSignInPointController alloc] init];
                controller.signInPoint = signInPoint;
                controller.addOrUpdateSignInPointType = KDAddOrUpdateSignInPointType_update;
                //                controller.sou/\rceType = KDAddOrUpdateSignInPointSource_signinPointController;
                [weakSelf.navigationController pushViewController:controller animated:YES];
            }
            else
            {
                [weakSelf showErrorMessage:ASLocalizedString(@"获取数据失败")seconds:1.0f view:weakSelf.view];
            }
        }
        else
        {
            [weakSelf showErrorMessage:ASLocalizedString(@"获取数据失败")seconds:1.0f view:weakSelf.view];
        }
    };
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"attendSetId" stringValue:attendSetId];
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/signId/:findAttendSet4Edit" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)goingToAddOrUpdateSignInPointControllerWithLat:(double)lat lon:(double)lon  position:(NSString *)position address:(NSString *)address
{
    KDSignInPoint *signInPoint = [[KDSignInPoint alloc] init];
    signInPoint.lat = lat;
    signInPoint.lng = lon;
    signInPoint.positionName = position;
    signInPoint.detailAddress = address;
    
    KDAddOrUpdateSignInPointController *controller = [[KDAddOrUpdateSignInPointController alloc] init];
    controller.addOrUpdateSignInPointType = KDAddOrUpdateSignInPointType_add;
    controller.signInPoint = signInPoint;
    //    controller.sourceType = KDAddOrUpdateSignInPointSource_signInControllerCell;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)showErrorMessage:(NSString *)message seconds:(double)delayInSeconds view:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.yOffset = 0;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:delayInSeconds];
}


- (void)taskFinished:(NSNotification *)notifycation
{
    //    NSDictionary *stateDic = [notifycation object];
    //    NSString *state = [stateDic valueForKey:@"state"];
    //
    //    [[XTDataBaseDao sharedDatabaseDaoInstance]updateToDoWithSourceMsgId:_taskMsgDataModel.msgId doneState:state];
    //
    //    if(self.todoArray.count != 0)
    //        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:_indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    //    else
    //        [self.tableView reloadData];
    //    [self sortAllData];
}

#pragma mark - slideswitchdelegate
-(void)clickTitle:(NSString *)title inIndex:(int)index
{
    if (_meunSelect == index) {
        return;
    }
    _meunSelect = index;
    
    //    self.firtTime = YES;
    self.bNoMoreOldPagings = NO;
    self.page = 0;
    
    NSInteger count = 0;
    //用于筛选
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",_meunSelect] forKey:@"MenuSelect"];
    switch (_meunSelect) {
        case 0:
            //add
            [KDEventAnalysis event:event_todo_todo_tab];
            [KDEventAnalysis eventCountly:event_todo_todo_tab];
            self.todoType = @"undo";
            if (!self.makedNofifyBtn.hidden) {
                [self hideMarkedNotifyBtn];
            }
            self.undoTabClick = YES;
            break;
        case 1:
            //add
            [KDEventAnalysis event:event_todo_hasdone_tab];
            [KDEventAnalysis eventCountly:event_todo_hasdone_tab];
            self.todoType = @"done";
            if (!self.makedNofifyBtn.hidden) {
                [self hideMarkedNotifyBtn];
            }
            break;
        case 2:
        {
            //add
            [KDEventAnalysis event:event_todo_notify_tab];
            [KDEventAnalysis eventCountly:event_todo_notify_tab];
            self.todoType = @"notify";
            //为了挽救坑爹的数字问题
            NSInteger notifyCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"notifyUnreadCount"];
            count = [[[XTDataBaseDao sharedDatabaseDaoInstance]queryUnreadNotificationMsgNum]count];
            if (count > notifyCount) {
                [[XTDataBaseDao sharedDatabaseDaoInstance]deleteAllNotifyMsg];
            }
            if (notifyCount > 0) {
                [self showMarkedNotifyBtn];
            }
        }
            break;
        default:
            break;
    }
    
    
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    if ([self.todoArray count] > 0) {
        [self.todoArray removeAllObjects];
        [self.tableView reloadData];
    }
    [self loadOnePageAtViewDidLoad];
}
-(void)clickArrowSinceIndex:(int)sinceIndex toIndex:(int)toIndex
{
    
}

- (void) setRedDot
{
    XTUnreadImageView *firstRedNum =  [self.titleNavView.redNumArray objectAtIndex:0];
    XTUnreadImageView *thirdRedNum =  [self.titleNavView.redNumArray objectAtIndex:2];
    
    NSInteger  undoCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"undoCount"];
    NSInteger  notifyUnreadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"notifyUnreadCount"];
    
    firstRedNum.hidden = undoCount <= 0;
    if (undoCount > 0) {
        firstRedNum.unreadCount = (int)undoCount;
    }
    
    thirdRedNum.hidden = notifyUnreadCount <= 0;
    if (notifyUnreadCount > 0) {
        thirdRedNum.unreadCount = (int)notifyUnreadCount;
    }
}

- (NSString *)oldestMsgId
{
    if (_meunSelect == 2) {
        NSString *oldNotifyMsgId = [[NSUserDefaults standardUserDefaults] valueForKey:@"oldNotifyMsgId"];
        return oldNotifyMsgId;
    }else
    {
        KDToDoMessageDataModel *todoModel = [self.todoArray lastObject];
        return todoModel.msgId;
    }
}

- (NSString *)latestMsgId{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE ", self.todoTableName];
    switch (_meunSelect) {
        case 0:
            sql = [sql stringByAppendingFormat:@"todoStatus = 'undo' ORDER BY sendTime DESC limit 1;"];
            break;
        case 1:
            sql =  [sql stringByAppendingFormat:@"todoStatus = 'done' ORDER BY sendTime DESC limit 1;"];
            break;
        case 2:
            sql =  [sql stringByAppendingFormat:@"todoStatus = '' OR todoStatus is null  ORDER BY sendTime DESC limit 1;"];
            break;
        default:
            break;
    }
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPageOfToDoRecordWithSql:sql]];
    if ([tempArray count] > 0) {
        KDToDoMessageDataModel *model = [tempArray firstObject];
        return model.msgId;
    }
    return @"";
}


- (KDToDoMessageDataModel*)latestMsgModel
{
    if (_meunSelect == 0 && self.undoTabClick) {
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE ", self.todoTableName];
    switch (_meunSelect) {
        case 0:
            sql = [sql stringByAppendingFormat:@"todoStatus = 'undo' ORDER BY score DESC limit 1;"];
            break;
        case 1:
            sql =  [sql stringByAppendingFormat:@"todoStatus = 'done' ORDER BY score DESC limit 1;"];
            break;
        case 2:
            sql =  [sql stringByAppendingFormat:@"todoStatus = '' OR todoStatus is null  ORDER BY score DESC limit 1;"];
            break;
        default:
            break;
    }
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPageOfToDoRecordWithSql:sql]];
    if ([tempArray count] > 0) {
        KDToDoMessageDataModel *model = [tempArray firstObject];
        return model;
    }
    return nil;
}

#pragma mark 数据库分页拉取
// 分页加载
- (void)getOnePageFromDBWithMsgId:(NSString *)msgId
                     countPerPage:(int)countPerPage
                         todoType:(NSString *)type
                        direction:(MessagePagingDirection)direction
                       completion:(void(^)(NSArray *todoData))completionBlock
{
    __weak __typeof(self) weakSelf = self;
    
    __block int count = countPerPage;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        
        weakSelf.appidString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE ", weakSelf.todoTableName];
        if ([type isEqualToString:@"undo"]) {
            
            weakSelf.appidString = [weakSelf.appidString stringByAppendingFormat:@"todoStatus = 'undo' "];//AND "];
            
        }
        else if ([type isEqualToString:@"done"])
        {
            weakSelf.appidString =[weakSelf.appidString stringByAppendingFormat:@"todoStatus = 'done' "];//AND "];
        } else
        {
            weakSelf.appidString =[weakSelf.appidString stringByAppendingFormat:@"(todoStatus = '' OR todoStatus is null) "];// AND "];
        }
        
        
        NSString *lastMsgtempSql= weakSelf.appidString;
        //代办，已办的消息数据库查询方式
        if (_meunSelect != 2) {
            if (msgId.length > 0)
            {
                if (direction == MessagePagingDirectionNew)
                {
                    //  lastMsgtempSql = [weakSelf.appidString stringByAppendingFormat:@"AND score > (select score from %@ where msgId = '%@') ", weakSelf.todoTableName,msgId];
                    count = (int)[weakSelf.todoArray count] + 20;
                }
                else if (direction == MessagePagingDirectionOld )
                {
                    lastMsgtempSql = [weakSelf.appidString stringByAppendingFormat:@"AND score < (select score from %@ where msgId = '%@') ", weakSelf.todoTableName,msgId];
                }
                else {
                    [weakSelf.todoArray removeAllObjects];
                }
                
            }
            lastMsgtempSql = [lastMsgtempSql stringByAppendingString:[NSString stringWithFormat:@"ORDER BY score DESC LIMIT %i ;", count]];
            
            
            NSMutableArray *lastMsgTempArray = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPageOfToDoRecordWithSql:lastMsgtempSql]];
            dispatch_async(dispatch_get_main_queue(), ^ {
                if([lastMsgTempArray count] > 0)
                {
                    //                //如果为新消息 则插入到最前面
                    if (weakSelf.fetchNewMsg) {
                        //                        [weakSelf.todoArray insertObjects:lastMsgTempArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[lastMsgTempArray count])]];
                        [weakSelf.todoArray removeAllObjects];
                        [weakSelf.todoArray addObjectsFromArray:lastMsgTempArray];
                        
                        
                    }
                    else
                    {
                        
                        [weakSelf.todoArray addObjectsFromArray:lastMsgTempArray];
                        
                    }
                    KDToDoMessageDataModel *model  = [weakSelf.todoArray lastObject];
                    weakSelf.oldestMsgModel = model;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(lastMsgTempArray);
                });
            });
            
        }
        else  //通知的数据库查询方式 由于查出来会出现时间和是否读取顺序问题 故分开处理
        {
            if ((weakSelf.fetchNewMsg  || weakSelf.firtTime ) && msgId.length > 0) {
                if (direction == MessagePagingDirectionNew)
                {
                    weakSelf.appidString = [weakSelf.appidString stringByAppendingFormat:@"AND sendTime > (select sendTime from %@ where msgId = '%@') ", weakSelf.todoTableName,msgId];
                }
                else if (direction == MessagePagingDirectionOld )
                {
                    weakSelf.appidString = [weakSelf.appidString stringByAppendingFormat:@"AND score < (select score from %@ where msgId = '%@') ", weakSelf.todoTableName,msgId];
                }
                else {
                    [weakSelf.todoArray removeAllObjects];
                }
                
            }
            
            DLog(@"self.appidString = %@", self.appidString);
            
            NSString *tempString = nil;
            NSMutableArray *tempArray = [NSMutableArray array];
            
            if (weakSelf.fetchNewMsg || weakSelf.firtTime)
            {
                //针对来新消息
                if (direction == MessagePagingDirectionNew && msgId.length > 0) {
                    tempString = [NSString stringWithFormat:@"%@ LIMIT %li ;", [weakSelf.appidString stringByAppendingString:@"ORDER BY sendTime DESC"], (long)countPerPage];
                }
                else
                {
                    tempString = [NSString stringWithFormat:@"%@ LIMIT %li ;", [weakSelf.appidString stringByAppendingString:@"ORDER BY score DESC"], (long)countPerPage];
                }
                
                
                tempArray = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPageOfToDoRecordWithSql:tempString];
                if ([tempArray count] > 0) {
                    if (direction == MessagePagingDirectionOld || !(msgId.length > 0)) {
                        weakSelf.oldestMsgModel = [tempArray lastObject];
                    }
                    
                    KDToDoMessageDataModel *notifyModel = [tempArray lastObject];
                    [[NSUserDefaults standardUserDefaults] setValue:notifyModel.msgId forKey:@"oldNotifyMsgId"];
                }
            }
            else
            {
                //拉去旧数据
                tempString = [NSString stringWithFormat:@"%@ LIMIT %li OFFSET %li;", [weakSelf.appidString stringByAppendingString:@"ORDER BY status ASC, sendTime DESC"], (long)countPerPage, (long)weakSelf.page * countPerPage];
                tempArray = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPageOfToDoRecordWithSql:tempString];
                
                
                if (_meunSelect == 2) {
                    NSArray *tempArray1 = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPageOfToDoRecordWithSql:[NSString stringWithFormat:@"%@ LIMIT %li OFFSET %li;", [weakSelf.appidString stringByAppendingString:@"ORDER BY sendTime DESC"], (long)countPerPage, (long)weakSelf.page * countPerPage]];
                    if ([tempArray1 count] > 0) {
                        KDToDoMessageDataModel *notifyModel = [tempArray1 lastObject];
                        [[NSUserDefaults standardUserDefaults] setValue:notifyModel.msgId forKey:@"oldNotifyMsgId"];
                        //                        [[NSUserDefaults standardUserDefaults] setValue:notifyModel.score forKey:@"oldNotifyMsgScore"];
                    }
                }
                if ([tempArray count] > 0) {
                    weakSelf.page++;
                }else
                {
                    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE ",  weakSelf.todoTableName];
                    sql =  [sql stringByAppendingFormat:@"todoStatus = '' OR todoStatus is null  ORDER BY score ASC limit 1;"];
                    
                    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPageOfToDoRecordWithSql:sql]];
                    if ([tempArray count] > 0) {
                        weakSelf.oldestMsgModel = [tempArray lastObject];
                    }
                    
                }
                
            }
            dispatch_async(dispatch_get_main_queue(), ^ {
                if([tempArray count] > 0)
                {
                    //                //如果为新消息 则插入到最前面
                    if (weakSelf.fetchNewMsg) {
                        
                        [weakSelf.todoArray insertObjects:tempArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[tempArray count])]];
                        
                    }
                    else
                    {
                        [weakSelf.todoArray addObjectsFromArray:tempArray];
                        
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(tempArray);
                });
            });
            
            
        }
        
    });
}

#pragma mark -
#pragma mark 网络拉取核心方法[1]: 逐页拉取 (通用)

/**
 *  拉取核心方法[1]: 逐页拉取 (通用)
 *  1. MessagePagingDirectionOld 从本地最旧一条消息从服务器往更旧的方向取一页消息
 *  2. MessagePagingDirectionNew 从本地最新一条消息从服务器往更新的方向取一页消息, 如果msgId为空, 则取最新的一页.
 *
 *  @param direction      方向
 *  @param recursiveBlock 内部递归使用, 在setupRecursiveBlocks后, 添加blockRecursiveGetMoreMessagesNew或blockRecursiveGetMoreMessagesOld
 *  @param completion     最终完成回调
 */
- (void)fetchMessageOnePageWithDirection:(MessagePagingDirection)direction
                        todoCountPerPage:(int)todoCountPerPage
                                todoType:(NSString *)todoType
                          recursiveBlock:(void (^)(BOOL succ, BOOL more, void (^completion)()))recursiveBlock
                              completion:(void (^)())completion{
    __weak __typeof(self) weakSelf = self;
    NSString *strMsgId = nil;
    NSString *strType = nil;
    NSString *score  = nil;
    switch (direction) {
        case MessagePagingDirectionOld: {
            strMsgId = self.oldestMsgModel.msgId;
            score = self.oldestMsgModel.score;
            strType = @"old";
        }
            break;
        case MessagePagingDirectionNew: {
            strMsgId = self.latestMsgModel.msgId;
            strType = @"new";
            score = self.latestMsgModel.score;
            self.fetchNewMsg = YES;
        }
            break;
        default:
            break;
    }
    [weakSelf getTodoMsgListClientWithGroupId:weakSelf.group.groupId
                                       userId:@""
                                        msgId:strMsgId
                                         type:strType
                                        score:score
                                     todoType:todoType
                                        count:[NSString stringWithFormat:@"%d",todoCountPerPage]
                                   completion:^(BOOL succ, NSDictionary *dictData) {
                                       [weakSelf stopLoading];
                                       if (succ) {
                                           if (_meunSelect == 0 && weakSelf.undoTabClick) {
                                               weakSelf.undoTabClick = NO;
                                               [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllUndoMsg];
                                           }
                                           RecordListDataModel *records = [[RecordListDataModel alloc] initWithDictionary:dictData];
                                           //保存用于显示未读数
                                           NSInteger  undoCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"undoCount"];
                                           NSInteger  notifyUnreadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"notifyUnreadCount"];
                                           if (undoCount != records.undoCount || notifyUnreadCount != records.notifyUnreadCount) {
                                               [[NSUserDefaults standardUserDefaults]setInteger:records.notifyUnreadCount forKey:@"notifyUnreadCount"];
                                               [[NSUserDefaults standardUserDefaults]setInteger:records.undoCount forKey:@"undoCount"];
                                               [weakSelf setRedDot];
                                           }
                                           
                                           //春平要求，刷新列表未读数目
                                           GroupDataModel *todoGroup = [[XTDataBaseDao sharedDatabaseDaoInstance] queryTodoMsgInXT];
                                           [[XTDataBaseDao sharedDatabaseDaoInstance] updateUnreadCountWithGroupId:todoGroup.groupId UnreadCount:records.undoCount+records.notifyUnreadCount];
                                           
                                           if (_meunSelect == 2 && records.notifyUnreadCount > 0 && self.type == KDToDoViewControllerType_Normal) {
                                               [self showMarkedNotifyBtn];
                                           }else
                                           {
                                               [self hideMarkedNotifyBtn];
                                           }
                                           
                                           KDToDoMessageDataModel *model = [records.list lastObject];
                                           if (records.list.count == 0 || (records.list.count == 1 && model.score.longLongValue == score.longLongValue)) {
                                               
                                               weakSelf.firtTime = NO;
                                               weakSelf.fetchNewMsg = NO;
                                               if (recursiveBlock) {
                                                   recursiveBlock(NO, NO, completion);
                                               }
                                           }else
                                           {
                                               weakSelf.emptyDataLabel.hidden = YES;;
                                               //更新时间
                                               [[XTDataBaseDao sharedDatabaseDaoInstance] insertToDoRecords:records.list];
                                               
                                               
                                               weakSelf.firtTime = YES;
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [weakSelf getOnePageFromDBWithMsgId:strMsgId
                                                                          countPerPage:todoCountPerPage
                                                                              todoType:todoType
                                                                             direction:direction
                                                                            completion:^(NSArray *todoData) {
                                                                                if (todoData.count > 0) {
                                                                                    if (recursiveBlock) {
                                                                                        recursiveBlock(YES, [dictData boolForKey:@"more"], completion);
                                                                                    }
                                                                                    
                                                                                } else {
                                                                                    if (recursiveBlock) {
                                                                                        if (score.longLongValue < weakSelf.latestMsgModel.score.longLongValue) {
                                                                                            recursiveBlock(YES, [dictData boolForKey:@"more"], completion);
                                                                                        }
                                                                                        recursiveBlock(NO, NO, completion);
                                                                                    }
                                                                                }
                                                                            }];
                                               });
                                           }
                                       } else {
                                           if (recursiveBlock) {
                                               recursiveBlock(NO, NO, completion);
                                           }
                                       }
                                   }];
}

#pragma mark 网络拉取核心方法[2]: 逐页拉取 (new方向) 直到more为false
- (void)fetchNewMessagesPageByPageWithTodoCountPerPage:(int)todoCountPerPage  todoType:(NSString *)todoType completion:(void (^)())completion{
    self.lastMsgSendTime = self.latestMsgSendTime;
    __weak __typeof(self) weakSelf = self;
    
    if (!self.blockRecursiveGetMoreTodoMessagesNew) {
        self.blockRecursiveGetMoreTodoMessagesNew = ^(BOOL succ, BOOL more, void (^completion)()) {
            // 递归防御
            if (succ && more) {
                [weakSelf fetchMessageOnePageWithDirection:MessagePagingDirectionNew
                                          todoCountPerPage:todoCountPerPage
                                                  todoType:todoType
                                            recursiveBlock:weakSelf.blockRecursiveGetMoreTodoMessagesNew
                                                completion:completion];
            } else {
                if (completion) {
                    completion();
                }
            }
        };
    }
    [UIView animateWithDuration:0
                     animations:^ {
                         [weakSelf.lastPageIndicatorView startAnimating];
                     } completion:^(BOOL finished) {
                         //     兼容第一次拉取
                         [weakSelf fetchMessageOnePageWithDirection:MessagePagingDirectionNew
                                                   todoCountPerPage:todoCountPerPage
                                                           todoType:todoType
                                                     recursiveBlock:weakSelf.blockRecursiveGetMoreTodoMessagesNew
                                                         completion:completion];
                     }];
}

#pragma mark -
#pragma mark 事件[1] 首次进入聊天页面
- (void)loadOnePageAtViewDidLoad{
    __weak __typeof(self) weakSelf = self;
    void (^blockFetchNewMessagesPageByPage)(int todoCountPerPage) = ^(int todoCountPerPage){
        [weakSelf fetchNewMessagesPageByPageWithTodoCountPerPage:todoCountPerPage
                                                        todoType:weakSelf.todoType
                                                      completion:^{
                                                          weakSelf.bFirstFetch = NO;
                                                          if([weakSelf.todoArray count] > 0)
                                                              [weakSelf sortAllData];
                                                          weakSelf.bLoadingLock = NO;
                                                      }];
    };
    
    self.bLoadingLock = YES;
    // 表示外部调用过取db数据
    //    if (self.todoArray.count > 0) {
    //        [self.tableView reloadData];
    //        blockFetchNewMessagesPageByPage(NUMBER_OF_RECORDS_PER_PAGE1);
    //    } else {
    //先取本地数据
    [self getOnePageFromDBWithMsgId:@""
                       countPerPage:NUMBER_OF_RECORDS_PER_PAGE1
                           todoType:weakSelf.todoType
                          direction:MessagePagingDirectionNew
                         completion:^(NSArray *todoData) {
                             [weakSelf.tableView setContentOffset:CGPointMake(0, 0)];
                             if (todoData.count > 0) {
                                 blockFetchNewMessagesPageByPage(NUMBER_OF_RECORDS_PER_PAGE1);
                             } else {
                                 // 首次拉取 msgId为空, 方向为new
                                 blockFetchNewMessagesPageByPage(NUMBER_OF_RECORDS_PER_PAGE1);
                             }
                             [weakSelf sortAllData];
                         }];
    //    }
}

- (void)fetchNewTodoMessages
{
    if (!self.bLoadingLock) {
        self.bLoadingLock = YES;
        self.fetchNewMsg = YES;
        __weak __typeof(self) weakSelf = self;
        
        [self fetchNewMessagesPageByPageWithTodoCountPerPage:NUMBER_OF_RECORDS_PER_PAGE1
                                                    todoType:weakSelf.todoType
                                                  completion:^{
                                                      if (weakSelf.needLoad && weakSelf.type != KDToDoViewControllerType_Normal) {
                                                          weakSelf.needLoad = NO;
                                                          if (weakSelf.type == KDToDoViewControllerType_Special) {
                                                              [weakSelf sortNewDataWithModel:weakSelf.sortDataModel];
                                                          }else if (weakSelf.type == KDToDoViewControllerType_Search)
                                                          {
                                                              [weakSelf sortSearchDataWithText:weakSelf.searchKeyWord];
                                                          }
                                                      }else
                                                      {
                                                          [weakSelf sortAllData];
                                                          //                                                            [weakSelf.tableView reloadData];
                                                          [weakSelf.tableView setScrollsToTop:YES];
                                                      }
                                                      weakSelf.bLoadingLock = NO;
                                                  }];
    }
    
}

#pragma mark 事件[2] 下拉 旧消息
- (void)startLoading
{
    if (!self.bLoadingLock ) {
        self.fetchNewMsg = NO;
        __weak __typeof(self) weakSelf = self;
        weakSelf.bLoadingLock = YES;
        [UIView animateWithDuration:0 animations:^ {
            [weakSelf.lastPageIndicatorView startAnimating];
        } completion:^(BOOL finished) {
            [weakSelf getOnePageFromDBWithMsgId:weakSelf.oldestMsgModel.msgId
                                   countPerPage:NUMBER_OF_RECORDS_PER_PAGE1
                                       todoType:weakSelf.todoType
                                      direction:MessagePagingDirectionOld
                                     completion:^(NSArray *todoData) {
                                         if (todoData.count == 0) {
                                             [weakSelf fetchMessageOnePageWithDirection:MessagePagingDirectionOld
                                                                       todoCountPerPage:NUMBER_OF_RECORDS_PER_PAGE1
                                                                               todoType:weakSelf.todoType
                                                                         recursiveBlock:^(BOOL succ, BOOL more, void (^completion)()) {
                                                                             if (succ) {
                                                                                 //                                                                                 if ( _meunSelect == 2)
                                                                                 //                                                                                 {
                                                                                 [weakSelf sortAllData];
                                                                                 //                                                                                 }else
                                                                                 //                                                                                 {
                                                                                 //                                                                                     [weakSelf resetScrollPositionWithBlock:^{                                                                                     [weakSelf sortAllData];
                                                                                 //
                                                                                 //                                                                                     }];
                                                                                 //
                                                                                 //                                                                                 }
                                                                             }
                                                                             weakSelf.bLoadingLock = NO;
                                                                             //                                                                             weakSelf.bNoMoreOldPagings = !more;
                                                                         } completion:nil];
                                         }else
                                         {
                                             //                                             if (todoData.count < 20 && _meunSelect == 2) {
                                             [weakSelf stopLoading];
                                             [weakSelf sortAllData];
                                             weakSelf.bLoadingLock = NO;
                                             //                                             }else
                                             //                                             {
                                             //                                                 [weakSelf resetScrollPositionWithBlock:^{
                                             //
                                             //                                                     [weakSelf sortAllData];
                                             //                                                     weakSelf.bLoadingLock = NO;
                                             //                                                 }];
                                             //
                                             //                                             }
                                             
                                             
                                         }
                                     }];
        }];
    }
}


//#pragma mark 事件[3] 轮询、长连接，获取网络数据
//- (void)fetchTodoDataFromNet:(NSString *)msgId {
//    //如果已经是最新的消息，则不需要更新(仅仅的状态或者未读数的变更)
//    if (msgId && [msgId isEqualToString:[self latestMsgId]]) {
//        return;
//    }
//    [self fetchNewMessages];
//}
#pragma mark 消息拉取接口
- (ContactClient *)todMsgListClient
{
    if (!_todMsgListClient) {
        _todMsgListClient = [[ContactClient alloc]initWithTarget:self action:@selector(todoMsgListClientDidReceived:result:)];
    }
    return _todMsgListClient;
}
- (void)getTodoMsgListClientWithGroupId:(NSString *)groupId
                                 userId:(NSString *)userId
                                  msgId:(NSString *)msgId
                                   type:(NSString *)type
                                  score:(NSString *)score
                               todoType:(NSString *)todoType
                                  count:(NSString *)count
                             completion:(void (^)(BOOL succ, NSDictionary *dictData))completion
{
    self.blockMsgListClient = completion;
    [self.todMsgListClient  getTodoMsgListWithGroupId:groupId
                                               userId:@""
                                                msgId:msgId
                                                 type:type
                                                score:score
                                             todoType:todoType
                                                count:count];
}


- (void)todoMsgListClientDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (!client.hasError && [result isKindOfClass:[BOSResultDataModel class]] && result.success && result.data) {
        if (self.blockMsgListClient) {
            self.blockMsgListClient(YES, result.data);
        }
    } else {
        if (self.blockMsgListClient) {
            self.blockMsgListClient(NO, nil);
        }
    }
}

// 下拉 消息菊花
- (void)stopLoading{
    [self.lastPageIndicatorView stopAnimating];
}
#pragma mark - Scroll View -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = scrollView.frame.size.height + scrollView.frame.origin.y - 64;
    CGFloat contentYoffset = scrollView.contentOffset.y;
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
    NSLog(@"%f, %f",distanceFromBottom,height);
    if (distanceFromBottom < height +1 ) {
        if (self.type == KDToDoViewControllerType_Search) {
            //            NSArray *tempArray = [[XTDataBaseDao sharedDatabaseDaoInstance]searchTodoMsgWithSearchText:self.searchKeyWord type:_meunSelect lastMsgId:self.lastSearchMsgId];
            //            if ([tempArray count] > 0) {
            //                [self.todoArray addObjectsFromArray:tempArray];
            //            }
            if (!self.loadSearch) {
                [self searchTodoMsgFromNetWihtKeyword:self.searchKeyWord count:NUMBER_OF_SERARCH_PER_PAGE1];
            }
        }else if (self.type == KDToDoViewControllerType_Special)
        {
            NSArray *tempArray = [self queryDataBaseWithCaculatePageWithPageInSpecialState];
            if ([tempArray count] > 0) {
                [self.todoArray addObjectsFromArray:tempArray];
                [self.tableView reloadData];
            }
        }
        else
        {
            //停留在代办页面，清除指令以后数据拉取问题
            if (!self.latestMsgModel) {
                [self.todoArray removeAllObjects];
                [self loadOnePageAtViewDidLoad];
            }else
            {
                [self startLoading];
            }
        }
    }
}

- (void)resetScrollPositionWithBlock:(void(^)())block{
    self.lastContentSizeHeight = self.tableView.contentSize.height;
    if (block) {
        block();
    }
    [self.tableView setContentOffset:CGPointMake(0.0, self.lastContentSizeHeight) animated:NO];
    //    double height = self.tableView.contentSize.height - self.lastContentSizeHeight;
    //    if(height < 64)
    //        height = -64;
    //    [self.tableView setContentOffset:CGPointMake(0.0,height) animated:NO];
    NSLog(@"##############3%f",self.tableView.contentSize.height - self.lastContentSizeHeight);
    //    [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.contentSize.height - self.lastContentSizeHeight) animated:NO];
}

- (void)hasMsgDelDidReceive:(NSNotification *)sender {
    __weak __typeof(self) weakSelf = self;
    NSMutableArray *delList = sender.object[@"list"];
    if (delList.count > 0) {
        [delList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DeleteMsgDateModel *deleteModel = (DeleteMsgDateModel*) obj;
            [weakSelf deleUndoMsgWithID:deleteModel.msgId delMsg:YES];
        }];
    }
    
    NSMutableArray *needDelUndoMsgIds = sender.object[@"needDelUndoMsgIds"];
    //更新的代办ID
    if ([needDelUndoMsgIds count] > 0) {
        [needDelUndoMsgIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DeleteUndoMsgDateModel *delUndoId = (DeleteUndoMsgDateModel *)obj;
            [weakSelf deleUndoMsgWithID:delUndoId.msgId delMsg:NO];
        }];
        [self sortAllData];
        //        [self refreshNotify];
    }
}

//先查询后删除
- (void) deleUndoMsgWithID:(NSString *)msgID delMsg:(BOOL)isDelMsg
{
    __block NSInteger location = -1;
    
    [self.todoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KDToDoMessageDataModel *todoMsg = (KDToDoMessageDataModel *)obj;
        if([todoMsg.msgId isEqualToString:msgID])
        {
            location = idx;
            *stop = YES;
        }
    }];
    
    if(location == -1) {
        return;
    }
    
    //    if (isDelMsg) {
    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteToDoDataWithMsgId:msgID];
    //    } else {
    //        [[XTDataBaseDao sharedDatabaseDaoInstance] updateUndoMsgWithId:msgID];
    //    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:location inSection:0];
    [self.todoArray removeObjectAtIndex:location];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) searchTodoMsgFromNetWihtKeyword:(NSString *)keyword count:(NSInteger)count
{
    if (!self.searchMsgListClient) {
        self.searchMsgListClient = [[ContactClient alloc]initWithTarget:self action:@selector(searchTodoMsgDidReceive:result:)];
    }
    [self.searchMsgListClient searchTodoMsgWithGroupId:self.group.groupId msgId:self.lastSearchMsgId count:count todoType:self.todoType criteria:keyword];
    self.loadSearch = YES;
}

-(void)sortSearchDataWithText:(NSString *)text
{
    [self hideMarkedNotifyBtn];
    self.searchKeyWord = text;
    self.searchBar.text = self.searchKeyWord;
    [[NSUserDefaults standardUserDefaults]setValue:text forKey:@"searchBarKeyWord"];
    self.type = KDToDoViewControllerType_Search;
    [self.todoArray removeAllObjects];
    //        [self.todoArray addObjectsFromArray:[[XTDataBaseDao sharedDatabaseDaoInstance]searchTodoMsgWithSearchText:text type:_meunSelect lastMsgId:nil]];
    //
    //        if (self.todoArray.count > 0)
    //        {
    //            KDToDoMessageDataModel *lastTodoMsg = [self.todoArray lastObject];
    //            self.lastSearchMsgId = lastTodoMsg.msgId;
    //            [self.tableView setScrollEnabled:YES];
    //            self.emptyDataLabel.hidden = YES;
    ////            self.titleNavView.hidden = YES;
    ////            CGRect rect = self.tableView.frame;
    ////            rect.origin.y -= CGRectGetHeight(self.titleNavView.frame);
    ////            rect.size.height += CGRectGetHeight(self.titleNavView.frame);
    ////            self.tableView.frame = rect;
    //
    //            //搜索默认显示20条，先本地，后服务器
    //            if ([self.todoArray count] < NUMBER_OF_SERARCH_PER_PAGE1) {
    //                [self searchTodoMsgFromNetWihtKeyword:text count:NUMBER_OF_SERARCH_PER_PAGE1-[self.todoArray count]];
    //
    //            }else
    //            {
    //                [self.tableView reloadData];
    //                self.oldestMsgModel = lastTodoMsg;
    ////                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    //            }
    //        }
    //        else
    //        {
    self.lastSearchMsgId = @"";
    [self searchTodoMsgFromNetWihtKeyword:text count:NUMBER_OF_SERARCH_PER_PAGE1];
    //        }
    
}
- (void)searchTodoMsgDidReceive:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (!client.hasError && [result isKindOfClass:[BOSResultDataModel class]] && result.success && result.data) {
        RecordListDataModel *records = [[RecordListDataModel alloc] initWithDictionary:result.data];
        if ([records.list count] > 0) {
            self.emptyDataLabel.hidden = YES;
            [self.tableView setScrollEnabled:YES];
            [self.todoArray addObjectsFromArray:records.list];
            
            KDToDoMessageDataModel *model = [self.todoArray lastObject];
            self.lastSearchMsgId = model.msgId;
            self.loadSearch = NO;
            [self setRedDot];
            [self.tableView reloadData];
            if ( [records.list count] > 0 && [self.todoArray count] <= NUMBER_OF_SERARCH_PER_PAGE1) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            
        }else
        {
            if ([self.todoArray count] == 0) {
                self.emptyDataLabel.hidden = NO;
                [self.tableView setScrollEnabled:NO];
                [self.tableView reloadData];
            }
        }
    }
}


#pragma mark - KDSearchBarDelegate
- (void)searchBar:(KDSearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        searchBar.text = @"";
    }
    //    [[NSUserDefaults standardUserDefaults]setValue:searchBar.text forKey:@"searchBarKeyWord"];
}
- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar {
    if ([self search:searchBar.text]) {
        self.state = KDToDoViewControllerType_Search;
        [self.searchBar resignFirstResponder];
        [self sortSearchDataWithText:searchBar.text];
    }
    
}

- (BOOL)search:(NSString *)text {
    BOOL succes = NO;
    NSString *string = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (string.length == 0) {
        return succes;
    }
    else
        return YES;
}

- (void)showMarkedNotifyBtn
{
    //搜索，筛选状态不显示
    if (self.makedNofifyBtn.hidden) {
        self.makedNofifyBtn.hidden = NO;
        [self.makedNofifyBtn setTitleColor:FC5 forState:UIControlStateNormal];
        [self.makedNofifyBtn setTitleColor:FC5 forState:UIControlStateHighlighted];
        CGRect  rect = self.tableView.frame;
        rect.size.height -= 44;
        self.tableView.frame = rect;
    }
    
    
}
- (void)hideMarkedNotifyBtn
{
    if (!self.makedNofifyBtn.hidden) {
        self.makedNofifyBtn.hidden = YES;
        CGRect rect = self.tableView.frame;
        rect.size.height += 44;
        self.tableView.frame = rect;
    }
    [self.makNotifyIndicatorView stopAnimating];
}
- (void)makedNofifyBtnClick:(id)sender
{
    //add
    [KDEventAnalysis event:event_todo_ignore_all_count];
    [KDEventAnalysis eventCountly:event_todo_ignore_all_count];
    self.makedNofifyBtn.enabled = NO;
    [self.makNotifyIndicatorView startAnimating];
    if (self.markedNotifyMsgClient == nil) {
        self.markedNotifyMsgClient = [[ContactClient alloc]initWithTarget:self action:@selector(makedNofifyClientDidReceived:result:)];
    }
    [self.markedNotifyMsgClient markedNotifyMsgReadWithGroupId:self.group.groupId];
}
- (void)makedNofifyClientDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    
    [self.makNotifyIndicatorView stopAnimating];
    self.makedNofifyBtn.enabled = YES;
    if (result.success) {
        //        [self.hud hide:YES];
        //        NSInteger lastIgnoreNotifyScore = [[NSUserDefaults standardUserDefaults]integerForKey:@"lastIgnoreNotifyScore"];
        //        [[XTDataBaseDao sharedDatabaseDaoInstance]updateUndoMsgWithLastIgnoreNotifyScore:[NSString stringWithFormat:@"%ld",(long)lastIgnoreNotifyScore]];
        //        [self sortAllData];
        
    }else
    {
        //        [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        //        [self.hud setMode:MBProgressHUDModeIndeterminate];
        //        [self.hud show:YES];
    }
    
}

- (UIActivityIndicatorView *)makNotifyIndicatorView
{
    if (_makNotifyIndicatorView == nil) {
        _makNotifyIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _makNotifyIndicatorView.center =  CGPointMake(ScreenFullWidth / 4 - 15, 22);
        _makNotifyIndicatorView.hidesWhenStopped = YES;
    }
    return _makNotifyIndicatorView;
}

- (MBProgressHUD *)hud
{
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    return _hud;
}
@end
