//
//  KDTodoListViewController.m
//  kdweibo
//
//  Created by bird on 13-7-4.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTodoListViewController.h"
#import "KDServiceActionInvoker.h"
#import "KDTodoParser.h"
#import "KDTodo.h"
#import "KDRequestWrapper.h"
#import "KDDatabaseHelper.h"
#import "KDWeiboDAOManager.h"
#import "KDErrorDisplayView.h"
#import "KDStatusContentDetailView.h"
#import "KDTodoListCell.h"
#import "KDUtility.h"
#import "KDManagerContext.h"
//#import "KDTaskDetailsViewController.h"
#import "KDCreateTaskViewController.h"
#import "MBProgressHUD.h"
#import "KDNavigationMenuView.h"
#import "KDTaskDiscussViewController.h"
#import "KDTitleNavView.h"

#define KMaxMessageCount 20
#define KPageSize 10
#define KD_STATUSCELL_FONTSIZE              14.0f
#define KD_TOTOCELL_EXTRA_HEIGHT    KD_TODO_CONTENT_TOP_MARGIN + KD_TODO_HEADER_HEIGHT +KD_TODO_CONTENT_SPACING
#define KD_TODOLIST_RELOAD_NOTIFICATION         @"kd_todolist_reload_notification"

typedef void (^Block) (void);

@interface KDTodoListViewController ()<TodoActionDelegate, KDTaskDiscussViewControllerDelegate>
{
    TodoType    _type;
    unsigned int _undoTotal;
    unsigned int _doneTotal;
    unsigned int _ignoreTotal;
    
    NSInteger   _meunSelect;
    
    UIView *backgroundView;
}
@property (nonatomic,assign,readwrite) TodoType     type;
@end

@implementation KDTodoListViewController
@synthesize type = _type;
- (id)initWithTodoType:(TodoType)type
{
    self = [super init];
    if (self) {
        // Custom initialization
        _type = type;
        _flag.isSearch  = NO;
        
        _flag.pageIndex = 1;
        _flag.pageSize  = KMaxMessageCount;
        
        
        _undoTotal = 0;
        _doneTotal = 0;
        _ignoreTotal = 0;
        _meunSelect = -1;
        _listArray = [NSMutableArray arrayWithCapacity:0];// retain];
        
        backgroundView = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTodoList) name:KD_TODOLIST_RELOAD_NOTIFICATION object:nil];
    }
    return self;
}
- (id)init
{
    return [self initWithTodoType:kTodoTypeUndo];
}
- (void)dealloc
{
    //[super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
//    if(backgroundView)
        //KD_RELEASE_SAFELY(backgroundView);
    //KD_RELEASE_SAFELY(_listArray);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //解决高度上升
//    if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)
//        self.edgesForExtendedLayout=UIRectEdgeNone;

    [KDWeiboAppDelegate setExtendedLayout:self];

    self.title = ASLocalizedString(@"KDApplicationQueryAppsHelper_task");
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    //标题选择栏
    [self setupMenuView];
    
    CGRect frame = self.view.bounds;

    frame.origin.y += CGRectGetMaxY(self.titleNavView.frame);//self.titleNavView.frame.size.height;
    frame.size.height -= frame.origin.y;

    //    self.navigationController.navigationBar
    // comments table view
    KDRefreshTableView *aTableView = [[KDRefreshTableView alloc] initWithFrame:frame
                                                        kdRefreshTableViewType:KDRefreshTableViewType_Both
                                                                         style:UITableViewStylePlain];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"navigationItem_create"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"navigationItem_create_hl"] forState:UIControlStateHighlighted];
    
    [button sizeToFit];
    
    [button addTarget:self action:@selector(createTask:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];// autorelease];
    negativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,rightBarButtonItem, nil];
//    [rightBarButtonItem release];
    
    aTableView.delegate = self;
    aTableView.dataSource = self;
    
    aTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    aTableView.backgroundColor = [UIColor clearColor];
    aTableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:aTableView];
    _tableView = aTableView;
//    [aTableView release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 21)];
    titleLabel.center = CGPointMake(ScreenFullWidth/2, ScreenFullHeight/3);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = ASLocalizedString(@"KDTodoListViewController_titleLabel_text");
    titleLabel.font = FS3;
    titleLabel.textColor = FC2;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.hidden = YES;
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
//    [titleLabel release];
    
    UIButton *btn = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDDefaultViewControllerContext_create_task")];
    [btn addTarget:self action:@selector(createTask:) forControlEvents:UIControlEventTouchUpInside];
//    btn.layer.cornerRadius = 6;
    btn.frame = CGRectMake((_tableView.frame.size.width - 100)/2, titleLabel.frame.origin.y+35, 100, 44);
    [btn setCircle];
    btn.center = CGPointMake(titleLabel.center.x, btn.center.y);
    btn.hidden = YES;
    [self.view addSubview:btn];
    self.btn = btn;
//    [btn release];
    
    
    [self reloadData];
    [_tableView setFirstInLoadingState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupMenuView {
    if(self.navigationItem)
    {
        KDTitleNavView *titleNavView = [[KDTitleNavView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, ScreenFullWidth, 40)];
        titleNavView.isFillWidth = YES;
        titleNavView.selectedColor = FC5;
        titleNavView.backgroundColor = [UIColor kdBackgroundColor2];
        titleNavView.titleArray = @[ASLocalizedString(@"KDToDoContainorViewController_undoModel_title"),ASLocalizedString(@"KDTodoListViewController_Do"),ASLocalizedString(@"KDInviteTeamCell_ignore"),ASLocalizedString(@"KDTodoListViewController_Me")];
        titleNavView.currentIndex = 0;
        titleNavView.delegate = self;
        self.titleNavView = titleNavView;
        [self.view addSubview:titleNavView];
//        [titleNavView release];
        
        
        NSInteger index = 0;
        if (_type == kTodoTypeUndo )
            index = 0;
        else if(_type == kTodoTypeDone)
            index = 1;
        else if(_type == kTodoTypeIgnore)
            index = 2;
        else if(_type == kTodoTypeCreate)
            index = 3;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


- (void) setBackgroud:(BOOL)isLoad {
    
    if (!isLoad) {
        //backgroundView.hidden = YES;
        self.titleLabel.hidden = YES;
        self.btn.hidden = YES;
        return;
    }
    
    self.titleLabel.hidden = NO;
    self.btn.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setType:(TodoType)type
{
    if (_type == type)  return;
    
    _type = type;
    
    [_tableView setFirstInLoadingState];
    
    _flag.pageIndex = 1;
    _flag.pageSize  = KMaxMessageCount;
    
    [_listArray removeAllObjects];
    [_tableView reloadData];
    
    [_tableView setBottomViewHidden:NO];
    [self reloadData];
}
- (NSString *)getTitle
{
    switch (_type) {
        case kTodoTypeUndo:
            return ASLocalizedString(@"KDToDoContainorViewController_undoModel_title");
            break;
        case kTodoTypeDone:
            return ASLocalizedString(@"KDTodoListViewController_Do");
            break;
        case kTodoTypeIgnore:
            return ASLocalizedString(@"KDInviteTeamCell_ignore");
            break;
        case kTodoTypeCreate:
            return ASLocalizedString(@"KDTodoListViewController_Me");
            break;
        default:
            return nil;
            break;
    }
}

- (NSString *)getTypeName
{
    switch (_type) {
        case kTodoTypeUndo:
            return @"undo";
            break;
        case kTodoTypeDone:
            return @"done";
            break;
        case kTodoTypeIgnore:
            return @"ignore";
            break;
        case kTodoTypeCreate:
            return @"";
            break;
        default:
            break;
    }
}
- (void)createTask:(id)sender
{
    KDCreateTaskViewController *pvc = [[KDCreateTaskViewController alloc] initWithNibName:nil bundle:nil];// autorelease];
    pvc.title = ASLocalizedString(@"KDDefaultViewControllerContext_create_task");
    [self.navigationController pushViewController:pvc animated:YES];
}
- (void)todoFinished:(KDTodo *)todo
{
    
    for (int i=0; i< [_listArray count]; i++) {
        
        KDTodo *p = [_listArray objectAtIndex:i];
        if (p == todo ) {
            
            [self removeDataFromDBWithTodoId:todo.todoId];
            
            if ([todo.status isEqualToString:@"undo"]) {
                
                KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
                NSInteger diff = unread.undoTotal - 1;
                if(diff < 0)
                    diff = 0;
                
                [[KDManagerContext globalManagerContext].unreadManager didChangeUndoBadgeValue:diff];
                
            }
            
            [_listArray removeObject:todo];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            
            [_tableView beginUpdates];
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView endUpdates];
            
            [self setBackgroud:[_listArray count] ==0];
            
            break;
        }
    }
}
#pragma mark
#pragma mark - load data from server methods
- (void)reloadData
{
    //全量更新
    _flag.latestTime = 0.00;
    _flag.farestTime  = 0.00;
    
    Block block = ^(void)
    {
        [self loadData:NO];
        
        
        //        if ([_listArray count] < KMaxMessageCount)
        //        {
        //            [self loadMoreData];
        //        }
    };
    
    if ([_listArray count]==0)
        [self fetchDataFromDBShowTips:NO block:block];
    else
        block();
}

- (void)loadMoreData
{
    if ([_listArray count]>0) {
        
        KDTodo *lastTodo  = [_listArray lastObject];
        //服务器接口有点问题，老是返回相同时间的数据，迁就下服务器-1
        //_flag.farestTime = [lastTodo.updateDate timeIntervalSince1970]-1;
        _flag.farestTime = [lastTodo.updateDate timeIntervalSince1970];
        _flag.latestTime    = 0.00;
        
        [self loadData:YES];
    }
    else
        [_tableView finishedLoadMore];
}
- (void)loadData:(BOOL)isloadMore{
    KDQuery *query = [self buildQuery];
    __block KDTodoListViewController *lcvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        
        if (isloadMore)
            [_tableView finishedLoadMore];
        else
            [_tableView finishedRefresh:YES];
        
        KDTodoParser *parserResult = results;
        
        if ([response isValidResponse] && parserResult && parserResult.success) {
            _undoTotal = parserResult.undoCount;
            _doneTotal = parserResult.doneCount;
            _ignoreTotal = parserResult.ignoreCount;
            
            if (!isloadMore)
            {
                //删除全部
                [self removeDataFromDBWithTodoType:[query genericParameterForName:@"status"]];
                
                [self saveDataToDB:parserResult.items];
                
                [self fetchDataFromDBShowTips:YES block:nil];
                
                //更新unread代办
                KDUnreadManager *manager = [KDManagerContext globalManagerContext].unreadManager;
                [manager didChangeUndoBadgeValue:0];
                
            }
            else
            {
                if ([_listArray count] < KMaxMessageCount) {
                    
                    int count = (int)[parserResult.items count];
                    if ([parserResult.items count] > KMaxMessageCount -[_listArray count]) {
                        count = KMaxMessageCount -(int)[_listArray count];
                    }
                    
                    
                    NSMutableArray *datas =[NSMutableArray array];
                    for (int i=0; i < count; i++) {
                        [datas addObject:[parserResult.items objectAtIndex:i]];
                    }
                    
                    [self saveDataToDB:datas];
                }
                
                
                if ([parserResult.items count]>0) {
                    
                    [_listArray addObjectsFromArray:parserResult.items];
                    [_tableView reloadData];
                    
                    CGPoint point = _tableView.contentOffset;
                    point.y += 40;
                    [_tableView setContentOffset:point];
                    
                }
                
                if ([parserResult.items count] < KMaxMessageCount)
                    [_tableView setBottomViewHidden:YES];
                
            }
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:self.view.window];
            }
        }
//        [lcvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/todo/:list" query:query
                                 configBlock:nil completionBlock:completionBlock];
}



- (void)todoAction:(KDQuery *)query
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:ASLocalizedString(@"提交中…")];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [hud hide:YES];
        if ([response isValidResponse] ) {
            
            if ([results isKindOfClass:[NSDictionary class]]) {
                NSDictionary *r = (NSDictionary *)results;
                if ([r valueForKey:@"success"])
                {
                    NSString *todoId = [r valueForKey:@"todoId"];
                    
                    for (int i=0; i< [_listArray count]; i++) {
                        KDTodo *p = [_listArray objectAtIndex:i];
                        if ([p.todoId isEqualToString:todoId]) {
                            [self todoFinished:p];
                            break;
                        }
                    }
                    
                }
            }
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:self.view.window];
            }
            
        }
        
    };
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/todo/:updateStatus" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}

#pragma mark
#pragma mark - query build methods
- (KDQuery *)buildQuery
{
    KDQuery *query = [KDQuery queryWithName:@"status" value:[self getTypeName]];
    
    if([self getTypeName].length == 0)
        [query setParameter:@"toOrFrom" stringValue:@"1"];
    else
        [query setParameter:@"toOrFrom" stringValue:@"0"];
    
    [query setParameter:@"page" intValue:_flag.pageIndex];
    [query setParameter:@"count" intValue:_flag.pageSize];
    
    if (_flag.latestTime != 0.00) {
        KDInt64 latestTime = (KDInt64)secondsToMilliseconds(_flag.latestTime);
        [query setParameter:@"since_time" longLongValue:latestTime];
    }
    if (_flag.farestTime != 0.00) {
        KDInt64 farestTime = (KDInt64)secondsToMilliseconds(_flag.farestTime);
        [query setParameter:@"max_time" longLongValue:farestTime];
    }
    
    return query;
}
#pragma mark -
#pragma mark - load data from db
- (void)fetchDataFromDBShowTips:(BOOL)isShow block:(Block)block
{
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb, BOOL *rollback){
        
        id<KDTodoDAO> todoDAO = [[KDWeiboDAOManager globalWeiboDAOManager] todoDAO];
        
        return [todoDAO queryTodoWithType:[self getTypeName] database:fmdb];
    } completionBlock:^(id results){
        
        if ([_listArray count]!=0)
            [_listArray removeAllObjects];
        
        [_listArray addObjectsFromArray:results];
        
        [_tableView reloadData];
        
        //最多保留KMaxMessageCount条数据在db
        if ([_listArray count] > KMaxMessageCount) {
            KDTodo *todo = [_listArray objectAtIndex:KMaxMessageCount];
            [self removeDataFromDBByUpdateTime:todo.updateDate];
        }
        
        //        [_tableView shouldShowNoDataTipView:[_listArray count] ==0&&!_tableView.isLoading&&isShow];
        [self setBackgroud:[_listArray count] ==0&&!_tableView.isLoading&&isShow];
        [_tableView setBottomViewHidden:[_listArray count] ==0];
        
        if (block)
            block();
    }];
}
- (void)removeDataFromDBByUpdateTime:(NSDate *)time
{
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb, BOOL *rollback){
        
        id<KDTodoDAO> todoDAO = [[KDWeiboDAOManager globalWeiboDAOManager] todoDAO];
        
        return [todoDAO removeTodoWithType:[self getTypeName] byTime:time database:fmdb];
        
    } completionBlock:^(id results){
        
    }];
}
- (void)removeDataFromDBWithTodoId:(NSString *)todoId
{
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb, BOOL *rollback){
        
        id<KDTodoDAO> todoDAO = [[KDWeiboDAOManager globalWeiboDAOManager] todoDAO];
        
        return @([todoDAO removeTodoWithID:todoId database:fmdb]);
        
        
    } completionBlock:nil];
}
- (void)removeDataFromDBWithTodoType:(NSString *)type
{
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb, BOOL *rollback){
        
        id<KDTodoDAO> todoDAO = [[KDWeiboDAOManager globalWeiboDAOManager] todoDAO];
        
        return @([todoDAO removeTodoWithType:type database:fmdb]);
        
    } completionBlock:nil];
}
- (void)saveDataToDB:(NSArray *)messages
{
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb, BOOL *rollback){
        id<KDTodoDAO> todoDAO = [[KDWeiboDAOManager globalWeiboDAOManager] todoDAO];
        [todoDAO saveTodoList:messages database:fmdb rollback:rollback];
        return nil;
    } completionBlock:^(id results){
        
        
    }];
}
#pragma mark -  UITableView delegate and data source methods


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// override
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_listArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [KDTodoListCell messageInteractiveCellHeight:[_listArray objectAtIndex:indexPath.row]];
}
// override
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    KDTodoListCell *cell = (KDTodoListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KDTodoListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier controller:self];// autorelease];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setTodo:[_listArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KDTodo *todo = [_listArray objectAtIndex:indexPath.row];
    if ([todo.fromType isEqual:@"task"]) {
        
        KDTaskDiscussViewController *taskDetailsViewController = [[KDTaskDiscussViewController alloc] initWithTaskId:todo.fromId];
        taskDetailsViewController.delegate = self;
        [self.navigationController pushViewController:taskDetailsViewController animated:YES];
//        [taskDetailsViewController release];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [(KDRefreshTableView *)scrollView kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [(KDRefreshTableView *)scrollView kdRefreshTableviewDidEndDraging:scrollView];
}

///////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - KDRefreshTableViewDelegate methods
KDREFRESHTABLEVIEW_REFRESHDATE
- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableVie{
    [self reloadData];
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    [self loadMoreData];
}
#pragma mark - TodoActionDelegate Methods
- (void)todoAction:(Action *)action todo:(KDTodo *)td
{
    if (action == nil) {
        //跳转到任务详情
        
        KDTaskDiscussViewController *taskDetailsViewController = [[KDTaskDiscussViewController alloc] initWithTaskId:td.fromId];
        taskDetailsViewController.delegate = self;
        [self.navigationController pushViewController:taskDetailsViewController animated:YES];
//        [taskDetailsViewController release];
    }
    else
    {
        if([action.title isEqualToString:@"finish"])
        {
            [self changeStatusWithTaskId:td.fromId isFinish:YES];
        }
        else if([action.title isEqualToString:@"unFinish"])
        {
            [self changeStatusWithTaskId:td.fromId isFinish:NO];
        }
        else if([action.title isEqualToString:@"delete"])
        {
            [self removeTaskWithTaskId:td.fromId];
        }
        else
        {
            KDQuery *query = [KDQuery queryWithName:@"todoId" value:td.todoId];
            [query setParameter:@"status" stringValue:td.status];
            [query setParameter:@"actId" stringValue:action.actId];
            
            [self todoAction:query];
        }
    }
}

-(void)changeStatusWithTaskId:(NSString *)taskId isFinish:(BOOL)isFinish
{
    KDQuery *query = [KDQuery query];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:ASLocalizedString(@"提交中…")];
    NSString* blockTaskId = taskId;// retain] autorelease];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [hud hide:YES];
        if ([response isValidResponse] ) {
            
            if ([results isKindOfClass:[NSDictionary class]]) {
                NSDictionary *r = (NSDictionary *)results;
                BOOL isSuc = [[r valueForKey:@"success"] boolValue];
                if (isSuc)
                {
                    //SString *taskId = [r valueForKey:@"id"];
                    for (int i=0; i< [_listArray count]; i++) {
                        KDTodo *p = [_listArray objectAtIndex:i];
                        if ([p.fromId isEqualToString:blockTaskId])
                        {
                            if(isFinish)
                                p.status = @"50";
                            else
                                p.status = @"30";
                            
                            //删除全部
                            [self removeDataFromDBWithTodoType:@""];
                            [self saveDataToDB:_listArray];
                            [_tableView reloadData];
                            break;
                        }
                    }
                    
                }
            }
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:self.view.window];
            }
            
        }
        
    };
    
    if(isFinish)
    {
        [query setProperty:taskId forKey:@"id"];
        [KDServiceActionInvoker invokeWithSender:self actionPath:@"/task/:finish" query:query
                                     configBlock:nil completionBlock:completionBlock];
    }
    else
    {
        [query setProperty:taskId forKey:@"id"];
        [query setParameter:@"status" stringValue:@"true"];
        [KDServiceActionInvoker invokeWithSender:self actionPath:@"/task/:cancelfinishtasknew" query:query
                                     configBlock:nil completionBlock:completionBlock];
    }
}


-(void)removeTaskWithTaskId:(NSString *)taskId
{
    KDQuery *query = [KDQuery query];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:ASLocalizedString(@"提交中…")];
    NSString* blockTaskId = taskId;// retain] autorelease];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response)
    {
        [hud hide:YES];
        if ([response isValidResponse] )
        {
            if ([results isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *r = (NSDictionary *)results;
                BOOL isSuc = [[r valueForKey:@"success"] boolValue];
                if (isSuc)
                {
                    //SString *taskId = [r valueForKey:@"id"];
                    for (int i=0; i< [_listArray count]; i++)
                    {
                        KDTodo *p = [_listArray objectAtIndex:i];
                        if ([p.fromId isEqualToString:blockTaskId])
                        {
                            [_listArray removeObject:p];
                            [self removeDataFromDBWithTodoId:p.fromId];
                            
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                            [_tableView beginUpdates];
                            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                            [_tableView endUpdates];
                            
                            break;
                        }
                    }
                }
            }
        }
        else
        {
            if (![response isCancelled])
            {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:self.view.window];
            }
        }
    };
    
    [query setProperty:taskId forKey:@"taskNewId"];
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/task/:removetasknew" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

//#pragma mark - KDNavigationMenuViewDelegate methods
//- (void)didSelectItemAtIndex:(NSUInteger)index
//{
//}

#pragma mark - KDTaskDetailsViewControllerDelegate
- (void)taskHasComplete:(KDTask *)task
{
    NSString *taskId = task.taskNewId;
    for (int i=0; i < [_listArray count]; i++) {
        KDTodo *todo = [_listArray objectAtIndex:i];
        if ([todo.fromId isEqualToString:taskId]) {
            [self todoFinished:todo];
            break;
        }
    }
}

#pragma mark - KD_TODOLIST_RELOAD_NOTIFICATION
- (void)reloadTodoList
{
    [self reloadData];
}

- (void)tabBarSelectedOnce
{
    if (![_tableView isLoading]) {
        [_tableView setFirstInLoadingState];
        [self reloadTodoList];
    }
}

#pragma mark - KDTitleNavViewDelegate
-(void)clickTitle:(NSString *)title inIndex:(int)index
{
    if (index == _meunSelect)
        return;
    _meunSelect = index;
    switch (index) {
        case 0:
            self.type = kTodoTypeUndo;
            break;
        case 1:
            self.type = kTodoTypeDone;
            break;
        case 2:
            self.type = kTodoTypeIgnore;
            break;
        case 3:
            self.type = kTodoTypeCreate;
            break;
        default:
            break;
    }
    
}


#pragma mark - KDTaskDiscussViewControllerDelegate
- (void)commentCountIncreaseWithTaskId:(NSString *)taskId count:(NSInteger)comments
{
    for (int i = 0; i<[_listArray count]; i++) {
        KDTodo *todo = [_listArray objectAtIndex:i];
        if ([todo.fromId isEqualToString:taskId]) {
            todo.taskCommentCount = [NSString stringWithFormat:@"%ld",(long)comments];
            [_tableView reloadData];
            break;
        }
    }
}


- (void)statusChangeWithTaskId:(NSString *)tId status:(int)status
{
    for (int i=0; i< [_listArray count]; i++)
    {
        KDTodo *p = [_listArray objectAtIndex:i];
        if([p isTask])
        {
            if ([p.fromId isEqualToString:tId])
            {
                p.status = [NSString stringWithFormat:@"%d",status];
                
                //删除全部
                [self removeDataFromDBWithTodoType:@""];
                [self saveDataToDB:_listArray];
                [_tableView reloadData];
                break;
            }
        }
        //        else
        //        {
        //            if ([p.fromId isEqualToString:tId])
        //            {
        //                [self todoFinished:p];
        //                break;
        //            }
        //        }
    }
}
@end
