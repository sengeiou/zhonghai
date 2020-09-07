//
//  KDInboxListSubviewController.m
//  kdweibo
//
//  Created by AlanWong on 14-6-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDInboxListSubviewController.h"
#import "KDServiceActionInvoker.h"
#import "KDRequestWrapper.h"
#import "KDInbox.h"
#import "KDInboxParser.h"
#import "KDDatabaseHelper.h"
#import "KDWeiboDAOManager.h"
#import "KDDMConversationViewController.h"
#import "KDStatusDetailViewController.h"
#import "KDErrorDisplayView.h"
#import "DirectMessageCell.h"
#import "KDInboxCell.h"
#import "KDManagerContext.h"
#import "KDUtility.h"
#import "KDNewIncomingMessagePromptView.h"
#import "KDNavigationMenuView.h"

#define TABLE_ROW_HEIGHT 64

#define KMaxMessageCount 20
typedef void (^Block) (void);
@interface KDInboxListSubviewController ()<KDInboxCellDelegate>
{
    unsigned int _total;
    KDInboxType   _type;
    
    NSInteger _meunSelect;
    
    UIView * backgroundView;
    
}
@property(nonatomic,retain)KDRefreshTableView *tableView;
@property(nonatomic,retain)NSMutableArray *inboxArray;
@end

@implementation KDInboxListSubviewController

-(id)init{
    return [self initWithInboxType:KDInboxTypeAll];
}

- (id)initWithInboxType:(KDInboxType)type
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self setType:type];
        
        _flag.pageIndex = 1;
        _flag.pageSize  = KMaxMessageCount;
        _flag.sort      =  1;
        _flag.desc      = YES;
        _flag.latestTime   = 0.00;
        _flag.farestTime    = 0.00;
        
        _total = 0;
        _meunSelect = -1;
        _inboxArray = [NSMutableArray arrayWithCapacity:0];/// retain];
        
        _flag.firstLoad = 1;
        
        backgroundView = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startConversation:) name:@"StartConversation" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inboxMessageStatusResetNotification:) name:KDNotificationInboxStatusReset object:nil];
    }
    return self;
}
- (void)dealloc
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    if(backgroundView)
        //KD_RELEASE_SAFELY(backgroundView);
    //KD_RELEASE_SAFELY(_inboxArray);
    //KD_RELEASE_SAFELY(_tableView);
    //[super dealloc];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_flag.firstLoad == 1) {
        [self reloadData];
        _flag.firstLoad = 0;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    CGRect frame = self.view.bounds;
    // comments table view
    KDRefreshTableView *aTableView = [[KDRefreshTableView alloc] initWithFrame:frame
                                                        kdRefreshTableViewType:KDRefreshTableViewType_Both
                                                                         style:UITableViewStylePlain];
    
    aTableView.delegate = self;
    aTableView.dataSource = self;
    
    aTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    aTableView.backgroundColor = [UIColor clearColor];
    aTableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:aTableView];
    _tableView = aTableView;// retain];
//    [aTableView release];
    
    [_tableView setFirstInLoadingState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setType:(KDInboxType)type
{
    if (type == _type) return;
    _type = type;
    
    switch (type) {
        case KDInboxTypeAll:
            _flag.type = @"Metion,Comment";
            break;
        case KDInboxTypeComment:
            _flag.type = @"Comment";
            break;
        case KDInboxTypeMetion:
            _flag.type = @"Metion";
            break;
        default:
            break;
    }
}

- (void) setBackgroud:(BOOL)isLoad {
    
    if (!isLoad) {
        backgroundView.hidden = YES;
        return;
    }
    
    
    if (!backgroundView) {
        
        backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [backgroundView setUserInteractionEnabled:YES];
        backgroundView.backgroundColor = [UIColor clearColor];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_placeholder_v2.png"]];// autorelease];
        [bgImageView sizeToFit];
        bgImageView.center = CGPointMake(backgroundView.bounds.size.width * 0.5f, 137.5f);
        
        [backgroundView addSubview:bgImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(bgImageView.frame) + 15.0f, self.view.bounds.size.width, 15.0f)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15.0f];
        label.textColor = MESSAGE_NAME_COLOR;
        label.text = ASLocalizedString(@"No_Data_Refresh");
        
        [backgroundView addSubview:label];
//        [label release];
        
        [_tableView addSubview:backgroundView];
    }
    backgroundView.hidden = NO;
    
}

#pragma mark -
#pragma mark - load data from db
- (void)fetchDataFromDBShowTips:(BOOL)isShow block:(Block)block
{
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb, BOOL *rollback){
        
        id<KDInboxDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] inboxDAO];
        
        if (_type == KDInboxTypeAll)
            //           return [threadDAO queryInbox_database:fmdb];
            return [threadDAO queryAllTypeInboxwithDatabase:fmdb];
        else
            return [threadDAO queryInboxWithType:_flag.type database:fmdb];
        
    } completionBlock:^(id results){
        [_inboxArray addObjectsFromArray:results];
        
        [_tableView reloadData];
        if (block)
            block();
    }];
}
- (void)removeDataFromDB
{
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb, BOOL *rollback){
        
        id<KDInboxDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] inboxDAO];
        
        return @([threadDAO removeInbox_database:fmdb]);
        
        
    } completionBlock:^(id results){
    }];
}
- (void)removeDataFromDBByUpdateTime:(double)timeAt
{
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb, BOOL *rollback){
        
        id<KDInboxDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] inboxDAO];
        
        return @([threadDAO removeInboxByUpdateTime:timeAt database:fmdb]);
        
        
    } completionBlock:^(id results){
    }];
}
- (void)removeDataFromDBById:(NSString *)inboxId
{
    
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb, BOOL *rollback){
        
        id<KDInboxDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] inboxDAO];
        
        return @([threadDAO removeInboxByInboxId:inboxId database:fmdb]);
        
        
    } completionBlock:^(id results){
    }];
}
- (void)saveDataToDB:(NSArray *)messages
{
    [KDDatabaseHelper inDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
        id<KDInboxDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] inboxDAO];
        if (_flag.type == KDInboxTypeAll) {
            [threadDAO saveAllTypeInboxList:messages database:fmdb rollback:rollback];
        }
        else{
            [threadDAO saveInboxList:messages database:fmdb rollback:rollback];
        }
        return nil;
    } completionBlock:nil];
}

#pragma mark
#pragma mark - load data from server methods
- (void)reloadData
{
    Block block = ^(void)
    {
        [self loadData];
//        if ([_inboxArray count] < KMaxMessageCount)
//            [self loadMoreData];
        
    };
    [self fetchDataFromDBShowTips:NO block:block];
}

//下拉刷新
-(void)loadData{
    _flag.latestTime = 0.00;
    _flag.farestTime  = 0.00;
    if ([_inboxArray count] > 0) {
        KDInbox * inbox = [_inboxArray objectAtIndex:0];
        _flag.latestTime = inbox.updateTime;
        _flag.farestTime = 0.00;
    }
    [self loadDataFromServer:NO ];
}
//上拉刷新
- (void)loadMoreData
{
    
    if ([_inboxArray count]>0) {
        
        KDInbox *lastInbox  = [_inboxArray lastObject];
        _flag.farestTime    = lastInbox.updateTime;
        _flag.latestTime    = 0.00;
        
        [self loadDataFromServer:YES ];
        
    }
    else
        [_tableView finishedLoadMore];
}
- (void)loadDataFromServer:(BOOL)isloadMore{
    KDQuery *query = [self buildQuery];
    __block KDInboxListSubviewController *lcvc = self ;//retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        
        if (isloadMore)
            [lcvc.tableView finishedLoadMore];
        else
            [lcvc.tableView finishedRefresh:YES];
        
        KDInboxParser *parserResult = results;
        
        if ([response isValidResponse] && parserResult && parserResult.success) {
            
            _total = parserResult.total;
            
            if (!isloadMore)
            {
                [lcvc resetUnread];
                
                //修改提及回复的显示逻辑     --- 黄伟彬
                if ([parserResult.items count] > 0 ) {
//                    NSArray * tempArray = parserResult.items;
//                    lcvc.inboxArray = [NSMutableArray arrayWithArray:[tempArray arrayByAddingObjectsFromArray:lcvc.inboxArray]];
                    
                    [lcvc saveDataToDB:parserResult.items];
                    [_inboxArray removeAllObjects];
                    Block block = ^(void)
                    {
//                         [lcvc.tableView reloadData];
                        
                    };
                    [self fetchDataFromDBShowTips:NO block:block];

                    
//                    [lcvc.tableView reloadData];
                    [KDNewIncomingMessagePromptView  showPromptViewInView:self.view tag:NEW_ICOMING_TAG userInfo:@{@"message":[NSString stringWithFormat:ASLocalizedString(@"KDInboxListSubviewController_new_msg"),(unsigned long)[parserResult.items count]]} autoDismiss:YES];

                    
                }
                
                
            }
            else
            {
                if ([parserResult.items count]>0)
                {
                    if ([lcvc.inboxArray count] < KMaxMessageCount) {
                        
                        int count = (int)[parserResult.items count];
                        if ([parserResult.items count] > KMaxMessageCount -[_inboxArray count]) {
                            count = KMaxMessageCount -(int)[_inboxArray count];
                        }
                        
                        NSMutableArray *datas =[NSMutableArray array];
                        for (int i=0; i < count; i++) {
                            [datas addObject:[parserResult.items objectAtIndex:i]];
                        }
                        [lcvc saveDataToDB:datas];
                    }
                    [lcvc.inboxArray addObjectsFromArray:parserResult.items];
                    [lcvc.tableView reloadData];
                    
                    CGPoint point = _tableView.contentOffset;
                    point.y += 40;
                    [lcvc.tableView setContentOffset:point];
                    
                }
                if ([parserResult.items count] < KMaxMessageCount)
                    [lcvc.tableView setBottomViewHidden:YES];
            }
            
        }
        else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:lcvc.view.window];
            }
        }
        
//        [lcvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/inbox/:messages" query:query
                                 configBlock:nil completionBlock:completionBlock];
}
- (void)resetUnread
{
    [[KDManagerContext globalManagerContext].unreadManager didChangeInboxBadgeValue:0];
}

#pragma mark
#pragma mark - query build methods
- (KDQuery *)buildQuery
{
    KDQuery *query = [KDQuery queryWithName:@"type" value:_flag.type];
    [query setParameter:@"desc" booleanValue:_flag.desc];
    [query setParameter:@"page" intValue:_flag.pageIndex];
    [query setParameter:@"count" intValue:_flag.pageSize];
    [query setParameter:@"sort" intValue:_flag.sort];
    
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

#pragma mark -  UITableView delegate and data source methods


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_inboxArray count] > 0) {
        [self setBackgroud:NO];
    }
    else{
        [self setBackgroud:YES];
    }
    return [_inboxArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDInbox  *feed   = [_inboxArray objectAtIndex:indexPath.row];
    return [KDInboxCell messageInteractiveCellHeight:feed];
}
// override
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier;
    
    KDInbox  *feed   = [_inboxArray objectAtIndex:indexPath.row];
    if ([feed.type isEqualToString:@"PrivateMessage"])
        CellIdentifier = @"DCellIdentifier";
    else if([feed.type isEqualToString:@"Metion"])
        CellIdentifier = @"MCellIdentifier";
    else if([feed.type isEqualToString:@"Comment"])
        CellIdentifier = @"CCellIdentifier";
    else
        CellIdentifier = @"UCellIdentifier";
    
    KDInboxCell *cell = (KDInboxCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KDInboxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.inbox = feed;
    cell.delegate = self;
    
    if(!tableView.dragging && !tableView.decelerating){
        [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:cell.userAvatarView];
        
        if(!cell.userAvatarView.hasAvatar && !cell.userAvatarView.loadAvatar){
            [cell.userAvatarView setLoadAvatar:YES];
        }
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KDInbox  *feed   = [_inboxArray objectAtIndex:indexPath.row];
    
    if([feed.type isEqual:@"Comment"])
    {
        KDStatusDetailViewController* VC = [[KDStatusDetailViewController alloc] initWithStatusID:feed.refId fromInbox:feed._id];
        [self.navigationController pushViewController:VC animated:TRUE];
//        [VC release];
    }
    else if([feed.type isEqual:@"Metion"])
    {
        KDStatusDetailViewController* VC = [[KDStatusDetailViewController alloc] initWithStatusID:feed.refId fromInbox:feed._id];;
        [self.navigationController pushViewController:VC animated:TRUE];
//        [VC release];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [(KDRefreshTableView *)scrollView kdRefreshTableViewDidScroll:scrollView];
}

- (void)loadImageSourceIfNeed {
    [KDAvatarView loadImageSourceForTableView:_tableView];
    
    NSArray *cells = [_tableView visibleCells];
	if(cells != nil){
        for(KDInboxCell *cell in cells){
            if(!cell.userAvatarView.hasAvatar && !cell.userAvatarView.loadAvatar){
                [cell.userAvatarView setLoadAvatar:YES];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self loadImageSourceIfNeed];
	}
    
    [(KDRefreshTableView *)scrollView kdRefreshTableviewDidEndDraging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImageSourceIfNeed];
}
///////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - KDRefreshTableViewDelegate methods
KDREFRESHTABLEVIEW_REFRESHDATE
- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableVie{
    [self loadData];
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    [self loadMoreData];
}
#pragma NSNotificationCenter Methods

- (void)inboxMessageStatusResetNotification:(NSNotification *)notice
{
    NSDictionary *dic =[notice userInfo];
    
    BOOL isSuccess = [[dic valueForKey:@"isSuccess"] boolValue];
    if(!isSuccess)  return;
    
    NSString *statusId = [dic valueForKey:@"statusId"];
    
    for (int i =0; i < [_inboxArray count]; i++) {
        KDInbox *inbox = [_inboxArray objectAtIndex:i];
        if ([statusId isEqualToString:inbox.refId]) {
            if (inbox.isUnRead) {
                
                KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
                NSInteger diff = unread.inboxTotal - inbox.unReadCount;
                if(diff < 0)
                    diff = 0;
                [[KDManagerContext globalManagerContext].unreadManager didChangeInboxBadgeValue:diff];
                
                inbox.isUnRead = NO;
                inbox.unReadCount = 0;
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                
                [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb, BOOL *rollback){
                    id<KDInboxDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] inboxDAO];
                    return @([threadDAO updateInboxStatusWithId:inbox._id database:fmdb]);
                    
                } completionBlock:^(id results){
                    
                }];
            }
            break;
        }
    }
}
#pragma mark - StartConversationNotification method
- (void)startConversation:(NSNotification *)notification {
    NSString *threadId = [notification.userInfo objectForKey:@"NewDMThreadID"];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    KDDMConversationViewController *conversation = [[KDDMConversationViewController alloc] initWithDMThreadID:threadId];// autorelease];
    [self.navigationController pushViewController:conversation animated:YES];
}

#pragma mark - KDInboxCellDelegate
- (void)replyWithInbox:(KDInbox *)inbox {
    KDStatusDetailViewController* VC = [[KDStatusDetailViewController alloc] initWithStatusID:inbox.refId fromInbox:inbox._id];
    [self.navigationController pushViewController:VC animated:TRUE];
//    [VC release];
}

- (void)mentionWithInbox:(KDInbox *)inbox {
    KDStatusDetailViewController* VC = [[KDStatusDetailViewController alloc] initWithStatusID:inbox.refId fromInbox:inbox._id];;
    [self.navigationController pushViewController:VC animated:TRUE];
//    [VC release];
}

@end