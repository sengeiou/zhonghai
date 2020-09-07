//
//  KDDMThreadViewController.m
//  kdweibo
//
//  Created by Tan yingqi on 12-12-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDDMThreadViewController.h"
#import "KDRefreshTableView.h"
//#import "MsgPromptView.h"
//#import "ResourceManager.h"
#import "KDErrorDisplayView.h"
#import "KDRequestWrapper.h"
//#import "KDDefaultViewControllerFactory.h"
//#import "KDDefaultViewControllerContext.h"
//#import "DirectMessageCell.h"
//#import "KDDMConversationViewController.h"
#import "KDUtility.h"
#import "KDUnreadManager.h"
#import "KDManagerContext.h"
#import "KDWeiboServicesContext.h"

#import "KDWeiboDAOManager.h"
#import "KDDatabaseHelper.h"
#import "JsonConstant.h"

#import "KWIThreadCell.h"
#import "KWIConversationVCtrl.h"
#import "KWISelectThreadParticipantVCtrl.h"
#import "KDQuery.h"


#define DM_LOAD_COUNT   20  
#define TABLE_ROW_HEIGHT 64

@interface KDDMThreadViewController ()<KDRefreshTableViewDataSource,KDRefreshTableViewDelegate,KDRequestWrapperDelegate,KDUnreadListener > {
    KDRefreshTableView *tableView_;
    BOOL haveFootView_;
    UIView *noDataTipsView_;
    NSArray *dmThreads_;
    
    KWISelectThreadParticipantVCtrl *_selectThreadParticipantVCtrl;
    struct {
        unsigned int init:1;
        unsigned int shouldRestore;
        unsigned int viewDidUnload:1;
        unsigned int shouldRefresh:1;
    }flags_;
    
}

@property(nonatomic,retain)KDRefreshTableView *tableView;
@property(nonatomic,retain)NSArray *dmThreads;
@property(nonatomic,retain)NSIndexPath  *selectIndexPath;
@property(nonatomic,retain)NSDate *lastFreshDate;
@property(nonatomic,assign)BOOL haveFootView;
@property(nonatomic,retain)NSCache *cellCache;

@end

@implementation KDDMThreadViewController

@synthesize tableView = tableView_;
@synthesize selectIndexPath = selectIndexPath_;
@synthesize lastFreshDate = lastFreshDate_;
@synthesize dmThreads = dmThreads_;
@synthesize haveFootView = haveFootView_;
@synthesize cellCache = cellCache_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        flags_.viewDidUnload = 0;
        flags_.shouldRefresh = 0;
        flags_.shouldRestore = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_onParticipantsSelected:)
                                                     name:@"KWISelectThreadParticipantVCtrl.doneSelecting"
                                                   object:nil];
    }
    return self;
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    // navigation item title view
    
    UIImage *image = [UIImage imageNamed:@"newThreadBg.png"];
    UIImageView *newTreadBgView = [[[UIImageView alloc] initWithImage:image] autorelease];
   // newTreadBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:newTreadBgView];
    
    UIImage *newThreadBtnImg = [UIImage imageNamed:@"newThreadBtn.png"];
    UIButton *newTreadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect btnFrame = newTreadBtn.frame;
    btnFrame.size = newThreadBtnImg.size;
    btnFrame.origin.x = (newTreadBgView.frame.size.width - btnFrame.size.width) / 2;
    btnFrame.origin.y = (newTreadBgView.frame.size.height - btnFrame.size.height) / 2;
    newTreadBtn.frame = btnFrame;
    [newTreadBtn setBackgroundImage:newThreadBtnImg forState:UIControlStateNormal];
    newTreadBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:18];
    [newTreadBtn setTitleColor:[UIColor colorWithRed:93/255.0 green:71/255.0 blue:61/255.0 alpha:1] forState:UIControlStateNormal];
    [newTreadBtn setTitle:@" 新 建 短 邮" forState:UIControlStateNormal];
    [newTreadBtn addTarget:self action:@selector(_onNewThreadBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newTreadBtn];
    
    
    
    CGRect frame = self.view.bounds;
    frame.origin.y =newTreadBgView.frame.size.height;
    frame.size.height-=newTreadBgView.frame.size.height;
    // comments table view
    KDRefreshTableView *aTableView = [[KDRefreshTableView alloc] initWithFrame:frame
                                                        kdRefreshTableViewType:KDRefreshTableViewType_Both
                                                                         style:UITableViewStylePlain];
    self.tableView = aTableView;
    [aTableView release];
    aTableView.delegate = self;
    aTableView.dataSource = self;
    
    aTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    aTableView.backgroundColor =[UIColor whiteColor];
    aTableView.separatorColor = [UIColor clearColor];
    aTableView.rowHeight = TABLE_ROW_HEIGHT;
    [self.view addSubview:aTableView];
   
}

// overrides
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(flags_.viewDidUnload == 1){
        flags_.viewDidUnload = 0;
    }
    if (flags_.shouldRestore == 1) {
        flags_.shouldRestore = 0;
        [self reStoreDmessages];
    }
    //[self shouldUpdateDMThreadsTableView:NO];
    if (flags_.shouldRefresh == 1) {
        flags_.shouldRefresh = 0;
        [self reloadCurrentDataSource];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    flags_.viewDidUnload = 1;
    
    KD_RELEASE_SAFELY(tableView_);
    KD_RELEASE_SAFELY(noDataTipsView_);
}

// ios 6.0 purge out  easily created object
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    KD_RELEASE_SAFELY(noDataTipsView_);
}


#pragma mark - private methods
- (void)shouldShowBlankHolderView:(BOOL)should {
    if (should) {
        UIView *view  = [[UIView alloc] initWithFrame:tableView_.bounds];
        view.backgroundColor =[UIColor clearColor];
        
//        UIImageView *clouldImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_placeholder_v2"]];
//        clouldImageView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds) - 50);
//        [view addSubview:clouldImageView];
//        [clouldImageView release];
        
        self.tableView.tableFooterView = view;
        [view release];
        
    }else {
        self.tableView.tableFooterView = nil;
    }
}

- (BOOL)shouldShowNoDataTipsView {
    BOOL shouldShow = NO;
    if(dmThreads_ == nil || [dmThreads_ count] <= 0) {
        shouldShow = YES;
    }
    return shouldShow;
}

- (void)showNodataTipsView {
    [tableView_ shouldShowNoDataTipView:[self shouldShowNoDataTipsView]];
}

//- (UIView *)noDataTipsView {
//    if (noDataTipsView_ == nil) {
//        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, KD_TABLEVIEW_FOOTERVIEW_HEIGHT)];
//        
//        infoLabel.backgroundColor = [UIColor clearColor];
//        infoLabel.textColor = [UIColor darkGrayColor];
//        infoLabel.font = [UIFont systemFontOfSize:15.0];
//        infoLabel.lineBreakMode = UILineBreakModeTailTruncation;
//        infoLabel.textAlignment = UITextAlignmentCenter;
//        
//        infoLabel.text = NSLocalizedString(@"NO_DATA_AND_PULL_DOWN_REFRESH", @"");
//        
//        infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        noDataTipsView_ = infoLabel;
//    }
//    return noDataTipsView_;
//}

- (void)reloadTableViewDataSource:(UIScrollView *)scrollView {	
    [self loadLatestDMMessages];
}

- (void)loadLatestDMMessages{
    KDQuery *query = [KDQuery queryWithName:@"count" value:[NSString stringWithFormat:@"%d",DM_LOAD_COUNT]];
    [query setParameter:@"contain_p_list" stringValue:@"false"];
    
    if ([self hasDMThreads]) {
        KDDMThread *thread = [dmThreads_ objectAtIndex:0];
        KDInt64 sinceTime = (KDInt64)secondsToMilliseconds(thread.updatedAt);
        [[query setParameter:@"since_time" longLongValue:sinceTime]
                setParameter:@"inclued_total_unread" stringValue:@"true"];
    }
    
    __block KDDMThreadViewController *tvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        BOOL isSuccess = NO;
        if ([response isValidResponse]) {
            isSuccess = YES;
            NSDictionary *info = results;
            
            NSArray *threads = nil;
            NSInteger count = 0;
            NSInteger unreadCount = 0;
            if (info != nil) {
               threads = [info objectNotNSNullForKey:@"threads"];
               count = [threads count];
               unreadCount = [info intForKey:@"unreads"];
            }
            
//            [MsgPromptView showPromptViewInView:tvc.tableView count:count suffixMessage:@"条新信息"];
            
            [tvc retain]; // retain before async database operation
            [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
                NSArray *objs = nil;
                id<KDDMThreadDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmThreadDAO];
                if (threads) {
                    [threadDAO saveDMThreads:threads database:fmdb rollback:rollback];
                    objs = [threadDAO queryDMThreadsWithLimit:[tvc.dmThreads count] + count database:fmdb];
                }
                
                return objs;
                
            } completionBlock:^(id results) {
                if (unreadCount > 0) {
                    [[KDManagerContext globalManagerContext].unreadManager didChangeDMBadgeValue:unreadCount];
                }
                
                if (results) {
                    tvc.dmThreads = results;
                }
              
                [tvc.tableView reloadData];
                [tvc setHaveFootView:([tvc.dmThreads count] >= DM_LOAD_COUNT)];
                [tvc showNodataTipsView];
                
                [tvc release];
            }];
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:tvc.view.window];
            }
            
            [tvc showNodataTipsView];
            [tvc setHaveFootView:([tvc.dmThreads count] >= DM_LOAD_COUNT)];
        }
        
        [tvc.tableView finishedRefresh:isSuccess];
        
        // release current view controller
        [tvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/dm/:threads" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)loadEarlierDMMessages {
    KDDMThread *thread = [dmThreads_ lastObject];
    if (thread) {
        KDInt64 maxTime = (KDInt64)secondsToMilliseconds(thread.updatedAt);
        
        KDQuery *query = [KDQuery query];
        [[[[query setParameter:@"max_time" longLongValue:maxTime]
                  setParameter:@"inclued_total_unread" stringValue:@"true"]
                  setParameter:@"count" stringValue:[NSString stringWithFormat:@"%d",DM_LOAD_COUNT]]
                  setParameter:@"contain_p_list" stringValue:@"false"];
        
        __block KDDMThreadViewController *tvc = [self retain];
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            NSInteger threadsCount = 0;
            NSArray *threads = nil;
            NSInteger unreads = 0;
            if ([response isValidResponse]) {
                NSDictionary *info = results;
                if (info != nil) {
                    threads = [info objectNotNSNullForKey:@"threads"];
                    unreads = [info integerForKey:@"unreads"];
                    threadsCount = [threads count];
                }
                
                if (threads) {
                    [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
                        id<KDDMThreadDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmThreadDAO];
                        [threadDAO saveDMThreads:threads database:fmdb rollback:rollback];
                        return nil;
                        
                    } completionBlock:nil];
                    
                    if (unreads >0) {
                        [[KDManagerContext globalManagerContext].unreadManager didChangeDMBadgeValue:unreads];
                    }
                    
                    tvc.dmThreads = [tvc.dmThreads arrayByAddingObjectsFromArray:threads];
                }
                
            } else {
                if(![response isCancelled]) {
                    [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                                  inView:tvc.view.window];
                }
            }
            
            [tvc setHaveFootView:(threadsCount >= DM_LOAD_COUNT)];
            [tvc.tableView finishedLoadMore];
            [tvc.tableView reloadData];
         
            // release current view controller
            [tvc release];
        };
        
        [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/dm/:threads" query:query
                                     configBlock:nil completionBlock:completionBlock];
    }
}

- (BOOL) canReloadCurrentDataSource {
    BOOL canReload = NO;
    canReload = ![self.tableView isLoading];
    return canReload;
}

- (BOOL) canReloadCurrentDataSourceWhenDataSourceEmpty {
    
    return[self canReloadCurrentDataSource]&&[self canReloadCurrentDataSource];
}

- (void) reloadCurrentDataSource {
    [self.tableView setFirstInLoadingState];
    [self loadLatestDMMessages];
}


- (void)setTableViewBottomViewHidden {
    
    [self.tableView setBottomViewHidden:![self haveFootView]];
}

- (void)reStoreDmessages {
    [self.tableView setFirstInLoadingState];
    [self shouldShowBlankHolderView:YES];
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDDMThreadDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmThreadDAO];
        NSArray *threads = [threadDAO queryDMThreadsWithLimit:DM_LOAD_COUNT database:fmdb];
        return threads;
        
    } completionBlock:^(id results){
             self.dmThreads = results;
        [self.tableView reloadData];
        [self loadLatestDMMessages];
        
    }];
}

- (void)setHaveFootView:(BOOL)haveFootView {
     [tableView_ setBottomViewHidden:!haveFootView];
     haveFootView_ = haveFootView;
}

//override
- (BOOL)haveFootView {
    BOOL result = NO;
    if([self.dmThreads count] >= DM_LOAD_COUNT)
        result = YES;
    return result;
}

- (BOOL)hasDMThreads {
    return (dmThreads_ != nil && [dmThreads_ count] > 0) ? YES : NO;
}


//拉网络数据后刷新未读数的显示
- (void)refreshUnreadDmMessageWhenEndNetLoadingWithDict:(NSDictionary *)dict {
    if (dict) {
        NSInteger value = [dict intForKey:JSN_TOTAL_UN_READ];
        
        [[KDManagerContext globalManagerContext].unreadManager didChangeDMBadgeValue:value];
    }
}

- (void)_onNewThreadBtnTapped {
    if (!_selectThreadParticipantVCtrl) {
        _selectThreadParticipantVCtrl = [[KWISelectThreadParticipantVCtrl vctrl] retain];
    }
    
    [UIApplication.sharedApplication.keyWindow.rootViewController.view addSubview:_selectThreadParticipantVCtrl.view];
}

- (void)_onParticipantsSelected:(NSNotification *)note {
    [self newMessage:[note.userInfo objectForKey:@"users"]];
}

- (void)newMessage:(NSArray *)participants
{
    if (participants == nil ||[participants count] == 0 ) {
        DLog(@"短邮参与人为空");
        return;
    }
    KDDMThread *thread = [[[KDDMThread alloc] init] autorelease];
    //thread.participants = participants;
    KWIConversationVCtrl *vctrl = [KWIConversationVCtrl vctrlForThread:thread];
    vctrl.participants = participants;
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIConversationVCtrl.show" object:self userInfo:inf];
}


//////////////////////////////////////////////////////


#pragma mark -  UITableView delegate and data source methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 108;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// override
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {   
    return [self.dmThreads  count];    
}

// override
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDDMThread *thread = [dmThreads_ objectAtIndex:indexPath.row];
    return  [self loadCell:thread];
}

- (KWIThreadCell *)loadCell:(KDDMThread *)thread {
    KWIThreadCell *cell = [self.cellCache objectForKey:thread.threadId];
    if (nil == cell) {
        cell = [KWIThreadCell cell];
        cell.data = thread;
        [self.cellCache setObject:cell forKey:thread.threadId];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    KDDMThread *thread = [dmThreads_ objectAtIndex:indexPath.row];
    KWIConversationVCtrl *vctrl = [KWIConversationVCtrl vctrlForThread:thread];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIConversationVCtrl.show" object:self userInfo:inf];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [(KDRefreshTableView *)scrollView kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [(KDRefreshTableView *)scrollView kdRefreshTableviewDidEndDraging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadAvatarForVisibleCellsIfNeed:scrollView];
}

- (void)loadAvatarForVisibleCellsIfNeed:(UIScrollView *)scrollView {
//    NSArray *cells = [self.tableView visibleCells];
//    if ([cells count] >0) {
//        for(DirectMessageCell *dmCell in cells){
//            if(dmCell.avatarView.hasUnloadAvatars && !dmCell.avatarView.loadingAvatars){
//                dmCell.avatarView.loadingAvatars = YES;
//            }
//        }
//
//    }
}


///////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - KDRefreshTableViewDelegate methods
- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableVie{
    [self loadLatestDMMessages];
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    [self loadEarlierDMMessages];
}


#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE


#pragma mark -  KDTabBarViewControllerInteraction delegate methods


- (void)shouldReloadDataSource:(BOOL)forceReload {
    [self reStoreDmessages];
    flags_.shouldRestore = 0;
}


#pragma mark - KDDMConversationViewController delegate methods
//- (void)dmThread:(KDDMThread *)thread didChangeUnreadCount:(NSUInteger)unreadCount {
//    KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
//    
//    NSInteger diff = unread.directMessages - unreadCount;
//    if(diff < 0){
//        diff = 0;
//    }
//    // if view did unload and not need to refresh dm thread cell
//    if(flags_.viewDidUnload == 0){
//        NSUInteger index = [dmThreads_ indexOfObject:thread];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0x00];
//        
//        DirectMessageCell *cell = (DirectMessageCell *)[tableView_ cellForRowAtIndexPath:indexPath];
//        if(cell != nil){
//            [cell update];
//        }
//    }
//    
//    [[KDManagerContext globalManagerContext].unreadManager didChangeDMBadgeValue:diff];
//}


#pragma mark - KDDMThreadSubjectDidChangeNofication Handler

- (void)dmThreadSubjectChanged:(NSNotification *)notification {
     flags_.shouldRestore = 1;    
}


#pragma mark - KDUnreadListener methods

- (void)unreadManager:(KDUnreadManager *)unreadManager didChangeUnread:(KDUnread *)unread{
    //[self shouldChangeSegmentedBadgeValue];
}

#pragma mark - UIViewController category
- (void)viewControllerWillDismiss {
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}


- (NSCache *)cellCache {
    if (!cellCache_) {
        cellCache_ = [[NSCache alloc] init];
        cellCache_.name = self.class.description;
        cellCache_.countLimit = 100;
    }
    return cellCache_;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KWISelectThreadParticipantVCtrl.doneSelecting" object:nil];
    [[[KDManagerContext globalManagerContext] unreadManager] removeUnreadListener:self];
    
    KD_RELEASE_SAFELY(tableView_);
    KD_RELEASE_SAFELY(dmThreads_);
    KD_RELEASE_SAFELY(lastFreshDate_);
    KD_RELEASE_SAFELY(noDataTipsView_);
    KD_RELEASE_SAFELY(cellCache_);
    KD_RELEASE_SAFELY(_selectThreadParticipantVCtrl);
    [super dealloc];
}

@end
