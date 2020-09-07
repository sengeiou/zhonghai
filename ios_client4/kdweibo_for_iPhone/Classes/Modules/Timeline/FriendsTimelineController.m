//
//  FriendsTimelineController.m
//  kdweibo
//
//

#import <objc/runtime.h>
#import "FriendsTimelineController.h"
#import "KDRefreshTableView.h"
#import "FriendsTimelineDataSource.h"
#import "KDWeiboAppDelegate.h"
#import "KDStatusDetailViewController.h"

//#import "KDMainTimelineTitleView.h"
#import "KDNotificationView.h"
//#import "KDAppTipsView.h"

#import "KDManagerContext.h"
#import "KDWeiboServicesContext.h"
#import "KDDefaultViewControllerContext.h"

#import "KDUtility.h"
#import "KDDatabaseHelper.h"


#import "KDInvitePhoneContactsViewController.h"

#import "KDTipView.h"

#import "MBProgressHUD.h"

#import "KDInvitePhoneContactView.h"
#import "KDNavigationMenuView.h"
#import "KDStatusCell.h"
#import "KDStatusView.h"

#import "KDStatusUploadTask.h"

#import "KDNewIncomingMessagePromptView.h"

#import "KDSendingStatusFailedMessagePromtView.h"

#import "KDDraftManager.h"

#import "ResourceManager.h"


#import "KDActivityIndicatorView.h"
#import "KDRequestDispatcher.h"
#import "KDErrorDisplayView.h"
#import "KDSearchBar.h"
#import "KDStatusDAO.h"
#import "KDCommentUploadTask.h"

#define KD_MAX_SEARCH_ITEM_COUNT_PER_PAGE   20
#define KD_SEARCHBAR_HEIGHT 36.5f



#define KD_KDWEIBO_TIMELINE_PLACEHOLDER_VIEW_TAG    0xc8
#define KD_TOGGLE_TIMELINE_NOTICE_VIEW_TAG          0xca

@interface FriendsTimelineController ()<KDSearchBarDelegate>

@property(nonatomic,retain) FriendsTimelineDataSource *timelineDataSource;
@property(nonatomic,retain) KDSearchBar * statusSearchBar;
@property(nonatomic,retain) UIView * searchBackgroundView;
@property(nonatomic,retain) KDRefreshTableView * searchTableView;
@property(nonatomic,retain) NSMutableArray * searchStatus;
@property(nonatomic,retain) KDActivityIndicatorView *activityView;
@property(nonatomic,retain) NSString * keywords;
@property(nonatomic,retain) UIButton * moreButton;
@property(nonatomic,assign) NSUInteger currentPage;

@property(nonatomic,assign) BOOL commentReply;

@end


@implementation FriendsTimelineController

@synthesize timelineDataSource = timelineDataSource_;

@synthesize tableView = tableView_;
@synthesize hasFooterView = hasFooterView_;
@synthesize cellCache = cellCache_;
@synthesize timelineType = timelineType_;

@synthesize statusSearchBar = statusSearchBar_;
@synthesize searchTableView = searchTableView_;
@synthesize searchBackgroundView = searchBackgroundView_;
@synthesize searchStatus = searchStatus_;
@synthesize activityView = activityView_;
@synthesize keywords = keywords_;
@synthesize moreButton = moreButton_;
@synthesize currentPage = currentPage_;
@synthesize commentReply = commentReply_;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        _timelineFlags.showingNewMessagesPromptView = 0;
        _timelineFlags.didReceiveMemoryWarning = 0;
        _timelineFlags.shouldRefresh = 0;
        _timelineFlags.loadStatusesOnFirstEnterStage = 0;
        _timelineFlags.shouldReloadDataSourceWhenLayoutDidChange = 0;
        _timelineFlags.shouldReloadTableData = 0;
        _timelineFlags.shouldShowNoDataTipsView = 0;
        
        _timelineFlags.hasRequests = 0;
        _timelineFlags.isSearching = 0;
        commentReply_ = NO;
        
        currentPage_ = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusShouldDelete:) name:kKDStatusShouldDeleted object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stautsUploadTaskFinished:) name:@"TaskFinished" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postingStatus:) name:kKDStatusOnPosting object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delectCache:) name:@"delectCache" object:nil];
    }
    return self;
}

- (void) loadView {
    [super loadView];
    CGRect frame = self.view.bounds;
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];//MESSAGE_BG_COLOR;
    
    KDRefreshTableView *aTableView = [[KDRefreshTableView alloc] initWithFrame:frame
                                                        kdRefreshTableViewType:KDRefreshTableViewType_Both
                                                                         style:UITableViewStylePlain];
    
    aTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:aTableView];
    aTableView.dataSource = self;
    aTableView.delegate = self;
    aTableView.backgroundColor = [UIColor clearColor];
    aTableView.backgroundView = nil;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView = aTableView;
    self.tableView.scrollsToTop = YES;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    //    [aTableView release];
    
    //添加搜索框
    self.statusSearchBar=[[KDSearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ScreenFullWidth, KD_SEARCHBAR_HEIGHT)];// autorelease];
    self.statusSearchBar.autocorrectionType=UITextAutocorrectionTypeNo;
    self.statusSearchBar.autocorrectionType = UITextAutocapitalizationTypeAllCharacters;
    self.statusSearchBar.showsCancelButton = NO;
    self.statusSearchBar.cancelButtonTitle = ASLocalizedString(@"FriendsTimelineController_tips_1");
    
    [self.statusSearchBar setBottomLineHidden:YES];
    self.statusSearchBar.delegate = self;
    self.tableView.tableHeaderView=self.statusSearchBar;
    
    [self showTeamTipsView];
    
    
}

- (void)showTeamTipsView {
    BOOL didShow = [[[KDSession globalSession] getPropertyForKey:KD_TEAM_SHOW_TIPS_VIEW_KEY fromMemoryCache:YES] boolValue];
    
    KDCommunity *current = [KDManagerContext globalManagerContext].communityManager.currentCommunity;
    
    if(!didShow && current.communityType == KDCommunityTypeTeam && current.isAdmin) {
        if(!teamTipsView_) {
            teamTipsView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth, 50)];
            
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"team_tips_bg_v3.png"]];
            [teamTipsView_ addSubview:imgView];
            //            [imgView release];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:@"team_tips_close_btn_v3.png"] forState:UIControlStateNormal];
            [btn sizeToFit];
            
            btn.frame = CGRectMake(CGRectGetWidth(teamTipsView_.frame) - CGRectGetWidth(btn.bounds) - 6.0f, (CGRectGetHeight(teamTipsView_.frame) - CGRectGetHeight(btn.bounds)) * 0.5f, CGRectGetWidth(btn.bounds), CGRectGetHeight(btn.bounds));
            [btn addTarget:self action:@selector(closeTipsView:) forControlEvents:UIControlEventTouchUpInside];
            [teamTipsView_ addSubview:btn];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTeamTipsView:)];
            [teamTipsView_ addGestureRecognizer:tap];
            //            [tap release];
        }
        
        if(teamTipsView_.superview) {
            [teamTipsView_ removeFromSuperview];
        }
        
        [self.view addSubview:teamTipsView_];
        
        self.tableView.frame = CGRectMake(CGRectGetMinX(self.tableView.frame), CGRectGetMaxY(teamTipsView_.frame), CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(teamTipsView_.frame));
    }
}

- (void)closeTipsView:(UIButton *)sender {
    [UIView animateWithDuration:0.25 animations:^{
        [teamTipsView_ removeFromSuperview];
        self.tableView.frame = self.view.bounds;
    }completion:^(BOOL finished) {
        [[KDSession globalSession] saveProperty:@(YES) forKey:KD_TEAM_SHOW_TIPS_VIEW_KEY storeToMemoryCache:YES];
    }];
}

- (void)didTapTeamTipsView:(UITapGestureRecognizer *)tap {
    [[NSNotificationCenter defaultCenter] postNotificationName:KDTeamTipsViewDidTapNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //zgbin:start
    for (KDStatus *status in timelineDataSource_.dataset.allStatuses) {
        [status setProperty:nil forKey:@"layouter"];
    }
    //zgbin:end
    _timelineFlags.didReceiveMemoryWarning = 0;
    
    if(_timelineFlags.loadStatusesOnFirstEnterStage == 0){
        _timelineFlags.loadStatusesOnFirstEnterStage = 1;
        [self restoreStatus];
    }
    
    if (_timelineFlags.shouldRefresh == 1) {
        _timelineFlags.shouldRefresh = 0;
        if (timelineDataSource_) {
            [timelineDataSource_ reloadTableViewDataSource];
        }
    }
}

- (void)restoreStatus {
    FriendsTimelineDataSource *dataSource = [[FriendsTimelineDataSource alloc] initWithController:self type:self.timelineType];
    self.timelineDataSource = dataSource;
    //    [dataSource release];
    
    [timelineDataSource_ restore];
    
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    if (_timelineFlags.shouldReloadTableData == 1) {
        _timelineFlags.shouldReloadTableData = 0;
        [self.tableView reloadData];
        
    }
    
    if (_timelineFlags.shouldShowNoDataTipsView == 1) {
        _timelineFlags.shouldShowNoDataTipsView = 0;
        [self showTipsOrNot];
    }
    [self showErrorMsgPrmptView];
    
}

- (void)showErrorMsgPrmptView {
    if ([[KDSession globalSession] unsendedStatus]&& ![[[KDSession globalSession] unsendedStatus] isGroup]) {
        
        [KDSendingStatusFailedMessagePromtView showPromptViewInView:self.view tag:SEND_ERROR_TAG userInfo:@{@"message":ASLocalizedString(@"FriendsTimelineController_tips_2")} autoDismiss:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    KDNavigationMenuView *menuView =  (KDNavigationMenuView*)(self.parentViewController.navigationItem.titleView);
    //    if (menuView) {
    //        [menuView hideNavigationToolBar];
    //    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    _timelineFlags.didReceiveMemoryWarning = 1;
    //KD_RELEASE_SAFELY(tableView_);
}

///////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (void)setHasFooterView:(BOOL)hasFooterView {
    [tableView_ setBottomViewHidden:!hasFooterView];
    hasFooterView_ = hasFooterView;
}

- (void)pushPhoneContactViewController {
    KDInvitePhoneContactsViewController *ipcvc = [[KDInvitePhoneContactsViewController alloc] initWithNibName:nil bundle:nil] ;//autorelease];
    [self.navigationController pushViewController:ipcvc animated:YES];
}


- (void)removeStatuses:(NSArray *)statuses {
    KDStatus *theStatus = nil;
    for (KDStatus *status in statuses) {
        if (![status isKindOfClass:[KDGroupStatus class]]) {
            theStatus = [self.timelineDataSource.dataset statusById:status.statusId];
            if (theStatus) {
                //                theStatus.text = ASLocalizedString(@"FriendsTimelineController_tips_3");
                //                [self.timelineDataSource.dataset ]
                [self.cellCache removeObjectForKey:theStatus.statusId];
                [self.timelineDataSource.dataset removeStatus:theStatus];
            }
        }
    }
    [self reloadTableView];
    [self showTipsOrNot];
    
}

- (void)removeStatus:(KDStatus *)status {
    //    if (timelineDataSource_.dataset && [timelineDataSource_.dataset contains:status]) {
    //        [timelineDataSource_.dataset removeStatus:status];
    //        if (tableView_) {
    //            [tableView_ reloadData];
    //        }
    //    }
    if(status){
        [self removeStatuses:@[status]];
    }
}


- (NSCache *)cellCache {
    if (!cellCache_) {
        cellCache_ = [[NSCache alloc] init];
        cellCache_.totalCostLimit = 1000;
    }
    return cellCache_;
}
- (void)removeAllCellCache {
    self.cellCache = nil;
}
- (void)delectCache:(NSNotification *)notfication {
    //    NSLog(@"%@",[notfication.userInfo objectForKey:@"status"]);
    KDStatus *status = [notfication.userInfo objectForKey:@"status"];
    //清除该cell缓冲，重新加载
    [status setProperty:nil forKey:@"layouter"];
    [self.cellCache removeObjectForKey:status.statusId];
}
#pragma mark -
#pragma mark public methods
- (void)shouldShowBlankHolderView:(BOOL)should {
    if (should) {
        UIView *view  = [[UIView alloc] initWithFrame:tableView_.bounds];
        view.backgroundColor =[UIColor clearColor];
        
        self.tableView.tableFooterView = view;
        //        [view release];
        
    }else {
        self.tableView.tableFooterView = nil;
    }
}

- (void)initRefreshTableView {
    if (![tableView_ isLoading] && !commentReply_) {
        [tableView_ setFirstInLoadingState];
    }
}

- (void)finishLoadMore {
    [tableView_ finishedLoadMore];
}

- (void)finishRefreshed:(BOOL)isSuccessful {
    [tableView_ finishedRefresh:isSuccessful];
}



- (void)reloadTableView {
    if (self.parentViewController.navigationController.topViewController == self.parentViewController) {
        //
        [self.tableView reloadData];
        
    }else {
        _timelineFlags.shouldReloadTableData = 1;
    }
    
}

- (void)showPrompView:(NSInteger)count {
    if(count >0 && timelineType_ != KDTLStatusTypeHotComment) {
        [KDNewIncomingMessagePromptView  showPromptViewInView:self.view tag:NEW_ICOMING_TAG userInfo:@{@"message":[NSString stringWithFormat:ASLocalizedString(@"FriendsTimelineController_tips_4"),(long)count]} autoDismiss:YES];
    }
}


- (void) removeKDWeiboPlaceholderView {
    UIView *placeholderView = [self.tableView viewWithTag:KD_KDWEIBO_TIMELINE_PLACEHOLDER_VIEW_TAG];
    if(placeholderView != nil){
        [placeholderView removeFromSuperview];
    }
}



- (void)shouldReloadDataSource:(BOOL)forceReload {
    // [self reloadTimeline:forceReload];
}


- (void)reload {
    [self.timelineDataSource reloadTableViewDataSource];
}
#pragma mark -
#pragma mark UIScroll delegate  methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [(KDRefreshTableView *)scrollView kdRefreshTableViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (!decelerate) {
        [KDStatusCell loadImagesForVisibleCellsIfNeed:(UITableView *)scrollView];
    }
    [(KDRefreshTableView *)scrollView kdRefreshTableviewDidEndDraging:scrollView];
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [KDStatusCell loadImagesForVisibleCellsIfNeed:(UITableView *)scrollView];
    
}

#pragma mark -
#pragma mark UITableView data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

//多出来的那个是邀请手机联系人,只在team里出现
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        NSInteger num = 0;
        
        if(timelineDataSource_) {
            num = [timelineDataSource_.dataset count];
        }
        
        return num;
    }
    else if(tableView == searchTableView_){
        return [searchStatus_ count];
    }
    else{
        return 0;
        
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDStatus * status = nil;
    if (tableView == self.tableView) {
        status = [timelineDataSource_.dataset statusAtIndex:indexPath.row];
    }
    else{
        status = [searchStatus_ objectAtIndex:indexPath.row];
    }
    //zgbin:加了点赞和评论，新的布局
    //    KDStatusLayouter *layouter = [KDStatusLayouter  statusLayouter:status constrainedWidth:tableView.bounds.size.width - 16];
    KDStatusLayouter *layouter = [KDStatusLayouter  newStatusLayouter:status constrainedWidth:tableView.bounds.size.width - 16];
    //zgbin:end
    return layouter.frame.size.height + 10; //多出来的为卡片之间的空隙
    
    // return 230;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDStatus * status = nil;
    if (tableView == self.tableView) {
        status = [timelineDataSource_.dataset statusAtIndex:indexPath.row];
    }
    else{
        status = [searchStatus_ objectAtIndex:indexPath.row];
    }
    
    KDStatusCell *cell = nil;
    if (status) {
        //zgbin:不从缓存拿cell
        //        cell = [self.cellCache objectForKey:status.statusId];
        if (!cell) {
            //            KDStatusLayouter *layouter = [KDStatusLayouter statusLayouter:status constrainedWidth:0];
            KDStatusLayouter *layouter = [KDStatusLayouter newStatusLayouter:status constrainedWidth:tableView.bounds.size.width - 16];
            KDLayouterView * layouterView = [layouter view];
            cell = [[KDStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];// autorelease];
            
            [cell addSubview:layouterView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            layouterView.layouter = layouter;
            //            [self.cellCache setObject:cell forKey:status.statusId cost:1];
            //zgbin:end
        }
        if(!tableView.dragging && !tableView.decelerating){
            [cell loadThumbanilsImage];
        }
        
    }
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KDStatus *sts = nil;
    if (tableView == self.tableView) {
        if(indexPath.row < timelineDataSource_.dataset.count) {
            sts = [timelineDataSource_.dataset statusAtIndex:indexPath.row];
        }
    }
    else{
        if(indexPath.row < [searchStatus_ count]) {
            sts = [searchStatus_ objectAtIndex:indexPath.row];
        }
    }
    if (sts.sendingState == KDStatusSendingStateFailed ||
        sts.sendingState == KDStatusSendingStateProcessing) {
        return;
    }
    KDStatusDetailViewController *statusDetailViewController = [[KDStatusDetailViewController alloc] initWithStatus:sts];// autorelease];
    [self.navigationController pushViewController:statusDetailViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - KDRefreshTableViewDelegate methods
- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableVie {
    //zgbin:start
    for (KDStatus *status in timelineDataSource_.dataset.allStatuses) {
        [status setProperty:nil forKey:@"layouter"];
    }
    //zgbin:end
    [timelineDataSource_ loadLatestStatus];
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    [timelineDataSource_ loadEarlierStatus];
}

#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE

#pragma mark -
#pragma mark NSNotification Handle


- (void)postingStatus:(NSNotification *)notfication {
    if (_timelineFlags.isSearching) {
        [self quitSearchState];
    }
    if (self.timelineType != KDTLStatusTypePublic && self.timelineType != KDTLStatusTypeFriends) { //必须是动态和我的关注才显示草稿status
        return;
    }
    KDStatus *status = [notfication.userInfo objectForKey:@"status"];
    if (!status ||status.type != KDTLStatusTypePublic) {
        return;
    }
    [self.timelineDataSource.dataset mergeStatuses:@[status] atHead:YES configureBloc:^(NSArray *array) {
        for (KDStatus *aStatus in array) {
            [self.cellCache removeObjectForKey:aStatus.statusId];
        }
        
    }];
    
    if (self.parentViewController.navigationController.topViewController == self.parentViewController) {
        //
        [self showTipsOrNot];
        [self.tableView reloadData];
        
    }else {
        _timelineFlags.shouldShowNoDataTipsView = 1;
        _timelineFlags.shouldReloadTableData = 1;
    }
}


//接收status 被删除的通知
- (void)statusShouldDelete:(NSNotification *)notfication {
    
    NSArray *statues = [notfication.userInfo objectForKey:@"status"];// retain];
    [self removeStatuses:statues];
    for(KDStatus *status in statues){
        [KDDatabaseHelper inTransaction:(id)^(FMDatabase *fmdb,BOOL *rollBack) {
            BOOL success = YES;
            id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
            
            success = [statusDAO removeStatusWithId:status.statusId database:fmdb];
            *rollBack = !success;
            return @(success);
        } completionBlock:nil];
    }
    //    [statues release];
}


- (void)stautsUploadTaskFinished:(NSNotification *)notfication {
    if (_timelineFlags.isSearching) {
        [self quitSearchState];
    }
    KDStatusUploadTask *task = [notfication.userInfo objectForKey:@"task"];
    if (!task ||![task isKindOfClass:[KDStatusUploadTask class]]) {
        return;
    }
    //专为回复刷新
    if ([task isKindOfClass:[KDCommentUploadTask class]]) {
        commentReply_ = YES;
        [timelineDataSource_ loadLatestStatus];
    }
    
    KDStatus *originStatus = task.entity;
    if (!originStatus ||originStatus.type != KDTLStatusTypePublic) {
        return;
    }
    if ([task isSuccess]) { //微博发送成功
        if ([task isKindOfClass:[KDStatusUploadTask class]]) {
            
            KDStatus *fetchedStatus = task.fetchedStatus;
            KDStatus *status = [self.timelineDataSource.dataset statusById:originStatus.statusId];
            if (status) {
                [self.cellCache removeObjectForKey:status.statusId]; //把cellCache 删除，才能重新创建cell
                
                [self.timelineDataSource.dataset replaceStatus:status withStatus:fetchedStatus]; //发送成功的status 替换原来的
                [self.tableView reloadData];
                
            }
        }
        
    }else { //微博发送失败
        KDStatus *status = [self.timelineDataSource.dataset statusById:originStatus.statusId];
        if (status) {
            [self.timelineDataSource.dataset mergeStatuses:@[originStatus] atHead:YES configureBloc:^(NSArray * outArray) {
                for (KDStatus *aStatus in outArray) {
                    [self.cellCache removeObjectForKey:aStatus.statusId];
                }
            }];
            [self reloadTableView];
        }
        [self showErrorMsgPrmptView];
    }
}


- (void)showTipsOrNot {
    if([self.timelineDataSource.dataset count] < 1){
        UIView *blankView = [ResourceManager noDataPromptView];
        blankView.frame = self.tableView.bounds;
        self.tableView.tableFooterView = blankView;
        
    }else {
        self.tableView.tableFooterView = nil;
    }
}

- (void) dealloc {
    // remove unread listener
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.timelineDataSource cancelAllGetRequests];
    [self cancelRequets];
    
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(teamTipsView_);
    timelineDataSource_.controller = nil;
    //KD_RELEASE_SAFELY(timelineDataSource_);
    //KD_RELEASE_SAFELY(cellCache_);
    
    
    //KD_RELEASE_SAFELY(statusSearchBar_);
    //KD_RELEASE_SAFELY(searchTableView_);
    //KD_RELEASE_SAFELY(searchBackgroundView_);
    //KD_RELEASE_SAFELY(searchStatus_);
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(keywords_);
    //[super dealloc];
}

#pragma mark -
#pragma mark KDSearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    self.keywords = statusSearchBar_.text;
    currentPage_ = 1;
    [self search:keywords_ isLoadMore:NO];
    if([statusSearchBar_ canResignFirstResponder]){
        [statusSearchBar_ resignFirstResponder];
    }
}

- (void)searchBarCancelButtonClicked:(KDSearchBar *)searchBar{
    [self quitSearchState];
    
}

- (BOOL)searchBarShouldBeginEditing:(KDSearchBar *)searchBar{
    //add
    [KDEventAnalysis event: event_tendency_search];
    [KDEventAnalysis eventCountly: event_tendency_search];
    if (tableView_.dragging || [tableView_ isLoading]) {
        return NO;
        
    }
    [self intoSearchState];
    return YES;
    
}
#pragma mark - The Methods For Search
//进入编辑状态
-(void)intoSearchState{
    //设置标识符
    _timelineFlags.isSearching = 1;
    //显示取消按钮
    [self.statusSearchBar setShowsCancelButton:YES];
    //调整搜索框的位置
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    //禁止切换功能
    self.parentViewController.navigationItem.titleView.userInteractionEnabled = NO;
    //清空数据
    [searchStatus_ removeAllObjects];
    [searchTableView_ reloadData];
    //隐藏更多按钮
    [self setMoreButtonActive:NO];
    //禁止主tableview滑动
    self.tableView.scrollEnabled = NO;
    //显示搜索tableview出来
    [self.searchBackgroundView addSubview:self.searchTableView];
    [self.view addSubview:self.searchBackgroundView];
}
//退出编辑状态
-(void)quitSearchState{
    //设置标识符
    _timelineFlags.isSearching = 0;
    //隐藏activityView
    [self activityViewWithVisible:NO];
    //取消正在发送的请求
    [self cancelRequets];
    //隐藏取消按钮
    [statusSearchBar_ setShowsCancelButton:NO];
    //恢复切换功能
    self.parentViewController.navigationItem.titleView.userInteractionEnabled = YES;
    //恢复主tableview滑动
    self.tableView.scrollEnabled = YES;
    //移去搜索tableview
    [searchBackgroundView_ removeFromSuperview];
    //欢迎searchbar的状态
    statusSearchBar_.text = @"";
    [statusSearchBar_ resignFirstResponder];
    [self.tableView reloadData];
}
-(UIView * )searchBackgroundView{
    if (!searchBackgroundView_) {
        searchBackgroundView_ = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.statusSearchBar.bounds) + 7, self.view.bounds.size.width, self.tableView.bounds.size.height - self.statusSearchBar.bounds.size.height)];
        searchBackgroundView_.backgroundColor = [UIColor kdBackgroundColor1];
        searchBackgroundView_.userInteractionEnabled = YES;
        
    }
    return searchBackgroundView_;
}
-(UITableView * )searchTableView{
    if (!searchTableView_) {
        searchTableView_ = [[KDRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.tableView.bounds.size.height - self.statusSearchBar.bounds.size.height - 7) kdRefreshTableViewType:KDRefreshTableViewType_None];
        searchTableView_.dataSource = self;
        searchTableView_.delegate = self;
        searchTableView_.backgroundColor = [UIColor clearColor];
        searchTableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
        searchTableView_.scrollsToTop = YES;
        searchTableView_.estimatedRowHeight = 0;
        searchTableView_.estimatedSectionHeaderHeight = 0;
        searchTableView_.estimatedSectionFooterHeight = 0;
    }
    return searchTableView_;
}

- (void)cancelRequets {
    if(_timelineFlags.hasRequests){
        // cancel the requests
        [[KDRequestDispatcher globalRequestDispatcher] cancelRequestsWithDelegate:self force:NO];
    }
}

- (void)search:(NSString *)keywords isLoadMore:(BOOL)loadMore {
    if (keywords != nil && [keywords length] > 0) {
        if([statusSearchBar_ canResignFirstResponder]){
            [statusSearchBar_ resignFirstResponder];
        }
        
        if (_timelineFlags.hasRequests) {
            [self cancelRequets];
            
        } else {
            
            // clear datasource before any search action
            [self.tableView reloadData];
            _timelineFlags.hasRequests = 1;
            
            [self activityViewWithVisible:YES];
            [self toggleMoreButtonEnabled:NO isLoading:YES];
            
            
            NSUInteger page = loadMore ? (currentPage_ + 1) : currentPage_;
            
            NSString *actionPath = @"/statuses/:search";
            KDQuery *query = [KDQuery query];
            [[[query setParameter:@"q" stringValue:keywords]
              setParameter:@"count" integerValue:KD_MAX_SEARCH_ITEM_COUNT_PER_PAGE]
             setParameter:@"page" integerValue:page];
            
            __block FriendsTimelineController *svc = self;// retain];
            KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
                [svc activityViewWithVisible:NO];
                [svc toggleMoreButtonEnabled:NO isLoading:NO];
                if([response isValidResponse]) {
                    if (results != nil) {
                        [svc _handleSearchHits:results];
                        if (loadMore) {
                            svc.currentPage += 1;
                        }
                    }
                } else {
                    if (![response isCancelled]) {
                        [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                                      inView:svc.view.window];
                    }
                }
                
                (svc -> _timelineFlags).hasRequests = 0;
                
                // release current view controller
                //        [svc release];
                //KD_RELEASE_SAFELY(svc);
            };
            
            [KDServiceActionInvoker invokeWithSender:nil actionPath:actionPath query:query
                                         configBlock:nil completionBlock:completionBlock];
        }
    }
}

- (void)activityViewWithVisible:(BOOL)visible {
    if(activityView_ == nil){
        CGRect rect = CGRectMake((self.view.bounds.size.width - 120.0) * 0.5, (self.view.bounds.size.height - 80.0) * 0.4, 120.0, 80.0);
        activityView_ = [[KDActivityIndicatorView alloc] initWithFrame:rect];
        activityView_.alpha = 0.0;
        
        [self.searchBackgroundView addSubview:activityView_];
    }
    
    if (visible) {
        [activityView_ show:YES info:ASLocalizedString(@"RecommendViewController_Load")];
        
    } else {
        [activityView_ hide:YES];
    }
}



- (void)_handleSearchHits:(NSArray *)hits {
    NSUInteger count = [hits count];
    if (count > 0) {
        if(searchStatus_ == nil) {
            searchStatus_ = [[NSMutableArray alloc] initWithCapacity:10];
        }
        [searchStatus_ addObjectsFromArray:hits];
        for (int i = 0 ; [searchBackgroundView_ gestureRecognizers]; i++) {
            
        }
    }
    [self.searchTableView reloadData];
    
    BOOL active = (count == KD_MAX_SEARCH_ITEM_COUNT_PER_PAGE) ? YES : NO;
    [self setMoreButtonActive:active];
}

- (void)toggleMoreButtonEnabled:(BOOL)enabled isLoading:(BOOL)loading {
    if (moreButton_ != nil) {
        NSString *btnTitle = loading ? ASLocalizedString(@"RecommendViewController_Load") : ASLocalizedString(@"KDPlaceAroundTableView_More");
        [moreButton_ setTitle:btnTitle forState:UIControlStateNormal];
        
        moreButton_.enabled = enabled;
    }
}

- (void)setMoreButtonActive:(BOOL)active {
    if(active){
        if(tableView_.tableFooterView == nil){
            // footer view
            CGRect frame = CGRectMake(0.0, 0.0, searchTableView_.bounds.size.width, 54.0);
            UIView *footerView = [[UIView alloc] initWithFrame:frame];
            
            // more button
            UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            moreButton_ = moreBtn;
            
            moreBtn.frame = CGRectMake((frame.size.width - 240.0) * 0.5, (frame.size.height - 32.0) * 0.5, 240.0, 32.0);
            moreBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
            
            [moreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [moreBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
            [moreBtn setTitle: ASLocalizedString(@"KDPlaceAroundTableView_More") forState:UIControlStateNormal];
            
            UIImage *bgImage = [UIImage imageNamed:@"dm_thread_more_btn_bg.png"];
            bgImage = [bgImage stretchableImageWithLeftCapWidth:0.5*bgImage.size.width topCapHeight:0.5*bgImage.size.height];
            [moreBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
            
            [moreBtn addTarget:self action:@selector(searchLoadMore:) forControlEvents:UIControlEventTouchUpInside];
            
            moreBtn.enabled = NO;
            [footerView addSubview:moreBtn];
            
            footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            searchTableView_.tableFooterView = footerView;
            //            [footerView release];
        }
        
        [self toggleMoreButtonEnabled:YES isLoading:NO];
        
    } else {
        moreButton_ = nil;
        searchTableView_.tableFooterView = nil;
    }
}

- (void)searchLoadMore:(UIButton *)btn {
    [self search:keywords_ isLoadMore:YES];
}



@end

