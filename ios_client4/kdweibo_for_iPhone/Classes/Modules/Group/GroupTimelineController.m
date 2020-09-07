//
//  GroupTimelineController.m
//  TwitterFon
//
//  Created by  on 11-11-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "KDCommon.h"

#import "GroupTimelineController.h"
#import "PostViewController.h"
#import "KDStatusDetailViewController.h"

#import "KDWeiboAppDelegate.h"

#import "KDGroupStatus.h"
#import "KDStatusDataset.h"
#import "KDStatusTimelineProvider.h"

#import "KDNotificationView.h"

#import "KDRequestDispatcher.h"
#import "KDWeiboServicesContext.h"
#import "KDDefaultViewControllerContext.h"
#import "KDErrorDisplayView.h"

#import "KDUtility.h"
#import "KDDatabaseHelper.h"
#import "KDManagerContext.h"

#import "MBProgressHUD.h"
#import "KDStatusLayouter.h"
#import "KDStatusCell.h"

#import "KDStatusUploadTask.h"

#import "KDNewIncomingMessagePromptView.h"
#import "KDSendingStatusFailedMessagePromtView.h"
#import "KDDraftManager.h"

#import "ResourceManager.h"

@interface GroupTimelineController (){
    struct {
        unsigned int viewDidUnload:1;
        unsigned int shouldReloadTableData:1;
        unsigned int shouldShowNoDataTipsView:1;
        unsigned int loadStatusesOnFirstEnterStage:1;
    }flags_;
}

@property(nonatomic, retain) KDRefreshTableView *tableView;
@property(nonatomic, retain) KDStatusTimelineProvider *timelineProvider;
@property(nonatomic, retain) KDStatusDataset *statusDataset;
@property(nonatomic, retain) KDGroup *group;

@property(nonatomic, retain) NSIndexPath *selectedIndexPath;
@property(nonatomic, retain) KDStatus *selectedStatus;
@property(nonatomic, retain)NSCache *cellCache;

@end

@implementation GroupTimelineController

@synthesize tableView = _tableView;
@synthesize timelineProvider=timelineProvider_;
@synthesize statusDataset=statusDataset_;
@synthesize group=group_;

@synthesize selectedIndexPath=selectedIndexPath_;
@synthesize selectedStatus=selectedStatus_;

@synthesize newStatusCount;

@synthesize cellCache = cellCache_;

- (id)initWithGroup:(KDGroup *)group {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        flags_.shouldReloadTableData = 0;
        flags_.shouldShowNoDataTipsView = 0;
        flags_.loadStatusesOnFirstEnterStage = 0;

        
        group_ = group;// retain];
        
        statusDataset_ = [[KDStatusDataset alloc] init];
        
        self.newStatusCount = 0;
        
        timelineProvider_ = [[KDStatusTimelineProvider alloc] initWithViewController:self];
        self.navigationItem.title = group_.name;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusShouldDelete:) name:kKDStatusShouldDeleted object:nil];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stautsUploadTaskFinished:) name:@"TaskFinished" object:nil];
        
          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postingStatus:) name:kKDStatusOnPosting object:nil];
      
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor kdBackgroundColor1];//RGBCOLOR(237, 237, 237);
    
    
    UIImage *image = [UIImage imageNamed:@"nav_bar_edit_btn_bg"];
    UIImage *highligthImage = [UIImage imageNamed:@"nav_bar_edit_btn_bg_highlight"];
  
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highligthImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(postGroupTweet:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
     //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    
    //2013-12-26  Song.Wang

    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];// autorelease];
    float width = kRightNegativeSpacerWidth;
    negativeSpacer.width = width - 10;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,barButtonItem, nil];
//    [barButtonItem release];
    
    CGRect frame = self.view.bounds;
    frame.origin.y+=64;
    self.tableView = [[KDRefreshTableView alloc] initWithFrame:frame kdRefreshTableViewType:KDRefreshTableViewType_Both];// autorelease];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];//RGBCOLOR(237, 237, 237);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewContentModeBottom;
    
    [self.view addSubview:self.tableView];
    
    //[self restoreGroupStatus];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    //KD_RELEASE_SAFELY(_tableView);
    flags_.viewDidUnload = 1;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    flags_.viewDidUnload = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showErrorMsgPrmptView];
    if (flags_.shouldReloadTableData == 1) {
        flags_.shouldReloadTableData = 0;
        [self.tableView reloadData];
    }
    
    if (flags_.shouldShowNoDataTipsView == 1) {
        flags_.shouldShowNoDataTipsView = 0;
        [self showTipsOrNot];
    }
    
    if (flags_.loadStatusesOnFirstEnterStage == 0) {
        flags_.loadStatusesOnFirstEnterStage = 1;
        [self restoreGroupStatus];
    }
    
}


#pragma mark - Private Methods
- (void)showPrompView:(NSInteger)count {
    if(count >0) {
        [KDNewIncomingMessagePromptView  showPromptViewInView:self.view tag:NEW_ICOMING_TAG userInfo:@{@"message":[NSString stringWithFormat:ASLocalizedString(@"FriendsTimelineController_tips_4"),(long)count]} autoDismiss:YES];
    }
}

//显示出错提示 主要用来显示微博发送失败，移到草稿箱的提示
- (void)showErrorMsgPrmptView {
    KDStatus *unsendedStatus = [[KDSession globalSession] unsendedStatus];
    if (unsendedStatus &&[unsendedStatus isGroup] && [unsendedStatus.groupId isEqualToString:group_.groupId]) {
        [KDSendingStatusFailedMessagePromtView showPromptViewInView:self.view tag:SEND_ERROR_TAG userInfo:@{@"message":ASLocalizedString(@"FriendsTimelineController_tips_2")} autoDismiss:NO];
    }
}

- (void)postGroupTweet:(id)sender {
    KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
    PostViewController *pvc = [factory getPostViewController];
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeNewStatus];
    draft.groupId = group_.groupId;
    draft.groupName = group_.name;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:group_.profileImageURL]];
    UIImage *image = [UIImage imageWithData:data];
    draft.groupImage = image;
    
    [KDWeiboAppDelegate setExtendedLayout:pvc];
    pvc.draft = draft;
    pvc.isSelectRange = NO;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pvc];// autorelease];
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
}

- (void)sortStatus:(NSMutableArray *)status {
    NSSortDescriptor *sorteDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO];
    
    [status sortUsingDescriptors:[NSArray arrayWithObject:sorteDescriptor]];
}

- (void)restoreGroupStatus {
    [(KDRefreshTableView *)self.tableView setFirstInLoadingState];
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
        NSArray *statuses = [statusDAO queryGroupStatusesWithGroupId:group_.groupId limit:50 database:fmdb];
        return statuses;
        
    } completionBlock:^(id results){
        NSArray *statuses = results;
        // if (statuses != nil && [statuses count] > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            if (statuses != nil && [statuses count] > 0){
                for (KDGroupStatus *gs in statuses) {
                    gs.groupName = group_.name;
                    [KDStatusLayouter  groupStatusLayouter:gs constrainedWidth:self.view.bounds.size.width - 16];
                }
                [statusDataset_ mergeStatuses:statuses atHead:YES limit:-1];
            }
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                [self.tableView reloadData];
                [self autoLoadTimeline];
                
            });
        });
        //}
    }];
}


- (void)reloadTableViewData {
    if (self.navigationController.topViewController == self) {
        [self.tableView reloadData];
    }else {
        flags_.shouldReloadTableData = 1;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [statusDataset_ count];
}

////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    KDStatus *status = [statusDataset_ statusAtIndex:indexPath.row];
//    return [timelineProvider_ calculateStatusContentHeight:status inTableView:tableView bodyViewPosition:KDStatusBodyViewDisplayPositionGroup];
    
    KDStatus *status = [statusDataset_ statusAtIndex:indexPath.row];
    KDStatusLayouter *layouter = [KDStatusLayouter  groupStatusLayouter:status constrainedWidth:tableView.bounds.size.width - 16.0f];
    return layouter.frame.size.height + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDStatus *status = [statusDataset_ statusAtIndex:indexPath.row];
    KDStatusCell *cell = [self.cellCache objectForKey:status.statusId];
    if (!cell) {
        KDStatusLayouter *layouter = [KDStatusLayouter groupStatusLayouter:status constrainedWidth:0];
        KDLayouterView * layouterView = [layouter view];
        cell = [[KDStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];// autorelease];
        cell.backgroundColor = [UIColor clearColor];
        [cell addSubview:layouterView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        layouterView.layouter = layouter;
        [self.cellCache setObject:cell forKey:status.statusId cost:1];
    }
    
    if(!tableView.dragging && !tableView.decelerating){
        [cell loadThumbanilsImage];
    }

    return cell;

    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KDGroupStatus *sts = (KDGroupStatus *)[statusDataset_ statusAtIndex:indexPath.row];
    
    //正在发送和发送失败的情况下没有响应
    if (sts.sendingState == KDStatusSendingStateFailed ||
        sts.sendingState == KDStatusSendingStateProcessing) {
        return;
    }
    
    if ([sts isMemberOfClass:[KDGroupStatus class]]) { //设置已读标志
        sts.unread = NO;
    }
    
    self.selectedStatus = sts;
    self.selectedIndexPath = indexPath;
    
    KDStatusDetailViewController *VC = [[KDStatusDetailViewController alloc] initWithStatus:sts];
    [[self navigationController] pushViewController:VC animated:TRUE];
//    [VC release];
    
    
//    KDTimelineStatusCell *cell = (KDTimelineStatusCell *)[tableView cellForRowAtIndexPath:indexPath];
//    [cell.containerView update];
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    [self loadGroupStatuses:NO];
}

- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView {
    [self loadGroupStatuses:YES];
}

#pragma mark -
#pragma mark Notification Handler

//接收status 被删除的通知
- (void)statusShouldDelete:(NSNotification *)notfication {
    NSArray *statuses = [notfication.userInfo objectForKey:@"status"];// retain];
    [self removeStatuses:statuses];
//    [statuses release];
}

- (void)stautsUploadTaskFinished:(NSNotification *)notfication {
    KDStatusUploadTask *task = [notfication.userInfo objectForKey:@"task"];
    if (!task ||![task isKindOfClass:[KDStatusUploadTask class]]) {
        return;
    }
    KDStatus *originStatus = task.entity;
    
    if (originStatus.type != KDTLStatusTypeGroupStatus|| ![originStatus isGroup] ||![[originStatus groupId] isEqualToString:self.group.groupId]) {
        return;
    }
    if ([task isSuccess]) { //微博发送成功
            KDStatus *fetchedStatus = task.fetchedStatus;
            KDStatus *status = [self.statusDataset statusById:originStatus.statusId];
            if (status) {
                [self.cellCache removeObjectForKey:status.statusId]; //把cellCache 删除，才能重新创建cell
                [self.statusDataset replaceStatus:status withStatus:fetchedStatus]; //发送成功的status 替换原来的
                [self.tableView reloadData];
            }
    }else { //微博发送失败
            [self.statusDataset mergeStatuses:@[originStatus] atHead:YES configureBloc:^(NSArray * outArray) {
                for (KDStatus *aStatus in outArray) {
                    [self.cellCache removeObjectForKey:aStatus.statusId];
                }
            }];
            [self reloadTableViewData];
            [self showErrorMsgPrmptView];
    }
}

- (void)postingStatus:(NSNotification *)notfication {
    KDStatus *status = [notfication.userInfo objectForKey:@"status"];
    if (status.type != KDTLStatusTypeGroupStatus|| ![status isGroup] ||![[status groupId] isEqualToString:self.group.groupId]) {
        return;
    }
    
    [self.statusDataset mergeStatuses:@[status] atHead:YES configureBloc:^(NSArray * array){
        for (KDStatus *aStatus in array) {
            [self.cellCache removeObjectForKey:aStatus.statusId];
        }
        
    }];
    
    if (self.navigationController.topViewController == self) {
        //
        [self showTipsOrNot];
        [self.tableView reloadData];
    }else {
        flags_.shouldShowNoDataTipsView = 1;
        flags_.shouldReloadTableData = 1;
    }
    
}
#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
    [(KDRefreshTableView *)self.tableView kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [(KDRefreshTableView *)self.tableView kdRefreshTableviewDidEndDraging:scrollView];
    
    if(!decelerate){
        [KDStatusCell loadImagesForVisibleCellsIfNeed:(UITableView *)scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
     [KDStatusCell loadImagesForVisibleCellsIfNeed:(UITableView *)scrollView];
}

//将此方法所需要做的工作放到获取数据的方法中，能获得更多的信息，避免了过多的参数传递。
//缺点就是数据获取方法会显得臃肿。
/*
- (void)dataSourceDidFinishLoadingNewData:(BOOL)isPullDown{
//	if([]) {
//		_reloading1 = NO;
//		
////		[UIView beginAnimations:nil context:NULL];
////		[UIView setAnimationDuration:.3];
////		[self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
////		[UIView commitAnimations];
//		
//		[(KDRefreshTableView *)self.tableView finishedRefresh:YES];
//		
//	} else if(_reloadingFootView) {
//        _reloadingFootView = NO;
//        [(KDRefreshTableView *)self.tableView finishedLoadMore];
//    }
    if(isPullDown)
        [(KDRefreshTableView *)self.tableView finishedRefresh:YES];
}
 */

- (void)reloadTableViewDataSource:(UIScrollView *)scrollView {
    [(KDRefreshTableView *)self.tableView setFirstInLoadingState];
    [self loadGroupStatuses:YES];
}

- (void) autoLoadTimeline {
    [self loadGroupStatuses:YES];
     newStatusCount = 0;
}

- (KDQuery *)groupStatusRequestQuery:(BOOL)isPullDown {
    KDQuery *query = [KDQuery queryWithName:@"group_id" value:group_.groupId];
    NSInteger count = 50;
    KDGroupStatus *gs = nil;
    NSString *range = nil;
    if (isPullDown) {
        if ([statusDataset_ count] > 0) {
            gs = (KDGroupStatus *)[statusDataset_ sinceStatus];
            range = @"from";
        }
    
    } else {
        count = 20;
        
        gs = (KDGroupStatus *)[statusDataset_ maxStatus];
        range = @"to";
    }

    [query setParameter:@"count" integerValue:count];

    if(range != nil){
        NSTimeInterval seconds = [gs.updatedAt timeIntervalSince1970];
        [query setParameter:range unsignedLongLongValue:(KDUInt64)secondsToMilliseconds(seconds)];
    }
    
    return query;
}

- (void)loadGroupStatuses:(BOOL)isPullDown {
    KDQuery *query = [self groupStatusRequestQuery:isPullDown];
    
    __block GroupTimelineController *gtvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        BOOL success = NO;
        NSUInteger count = 0;
        if ([response isValidResponse]) {
            if (results != nil) {
                success = YES;
                NSArray *statuses = results;
                for (KDStatus *obj in statuses) {
                    KDLayouter * layouter =   [KDStatusLayouter  statusLayouter:obj constrainedWidth:self.view.bounds.size.width - 16];
                    KDLayouterView * layouterView = [layouter view];
                    KDStatusCell * cell = [[KDStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];// autorelease];
                    [cell addSubview:layouterView];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    layouterView.layouter = layouter;
                    [gtvc.cellCache setObject:cell forKey:[(KDStatus *)obj statusId] cost:1];
                }

                count = [statuses count];
                if (count > 0) {
                    if (isPullDown) {
                        __block KDStatus *tmpStatus = nil;
                        //将获取到得并且和原来stausId 相同的status  置为unread
                     NSMutableArray *updateStatuses = [NSMutableArray arrayWithArray:statuses];
                        [updateStatuses enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop){
                            tmpStatus = [gtvc.statusDataset statusById:[(KDGroupStatus *)obj statusId]];
                            if (tmpStatus && tmpStatus.sendingState == KDStatusSendingStateNone) { //现有的statusDateset中有可能存在从本地发送的，必须剔除掉
                                [(KDGroupStatus *)obj setUnread:YES];
                            }
                        }];
                    [gtvc sortStatus:updateStatuses]; //按更新时间排序
                    NSArray *originalStatus = [NSArray arrayWithArray:gtvc.statusDataset.allStatuses];
                    //BOOL exists = NO;
                        [gtvc.statusDataset mergeStatuses:updateStatuses atHead:YES limit:-1 configureBloc:^(NSArray * outArray){
                            for (KDStatus *status in outArray) {
                                  [gtvc.cellCache removeObjectForKey:status.statusId];//从cellCache 删除原来的statuscell，否则无法更新界面。
                            }
                        }];
                     [gtvc showPrompView:[originalStatus count] - [gtvc.statusDataset count]];
                    
                    } //下拉刷新
                    else { //上拉
                        [gtvc.statusDataset mergeStatuses:statuses atHead:isPullDown limit:-1];
                    }
                    
                    [gtvc.tableView reloadData];
                }
                
                if (isPullDown) {
                    [[KDManagerContext globalManagerContext].unreadManager didChangeGroupsBadgeValue:YES
                                                                                             groupId:gtvc.group.groupId];
                }
                
                // save group status into database
                [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
                    id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
                    [statusDAO saveGroupStatuses:statuses database:fmdb rollback:rollback];
                    
                    return nil;
                    
                } completionBlock:nil];
            }
            
            if (!isPullDown) {
                gtvc.haveFootView = count >=20;
            }
           
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:gtvc.view.window];
            }
        }
        
        [gtvc showTipsOrNot];
        
        if (isPullDown) {
            [(KDRefreshTableView *)gtvc.tableView finishedRefresh:success];
            gtvc.haveFootView = ([gtvc.statusDataset count] >=50);
        
        } else {
            [(KDRefreshTableView *)gtvc.tableView finishedLoadMore];
        }
        
        // release current view controller
//        [gtvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/group/statuses/:periodTimeline" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)showTipsOrNot {
    if([statusDataset_ count] < 1){
        UIView *blankView = [ResourceManager noDataPromptView];
        blankView.frame = self.tableView.bounds;
        self.tableView.tableFooterView = blankView;
    }else {
        self.tableView.tableFooterView = nil;
    }
}

#pragma mark EGORefreshFootDelegate Methods

- (BOOL) haveFootView {
    return _haveFootView;
}

- (void) setHaveFootView:(BOOL)haveFootView {
    _haveFootView = haveFootView;
    [(KDRefreshTableView *)self.tableView setBottomViewHidden:!_haveFootView];

}


- (void)removeStatuses:(NSArray *)statuses {
    KDStatus *theStatus = nil;
    for (KDStatus *status in statuses) {
        if ([status isGroup] && [status.groupId isEqualToString:self.group.groupId]) {
            theStatus = [self.statusDataset statusById:status.statusId];
            if (theStatus) {
                [self.cellCache removeObjectForKey:theStatus.statusId];
                [self.statusDataset removeStatus:theStatus];
            }
        }
    }
    
    [self reloadTableViewData];
    
    [self showTipsOrNot];
}

- (void) removeStatus:(KDStatus *)status {
    // delete group status from database
    if (status) {
         [self removeStatuses:@[status]];
    }
   
}
////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDThumbnailView delegate methods

// Use the view controller as thumbnail's delegate because the data source class will be
// destory on switch community,
- (void)thumbnailView:(KDThumbnailView2 *)thumbnailView didLoadThumbnail:(UIImage *)thumbnail {
    [thumbnailView loadThumbnailFromDisk];
}

//////////////////////////////////////////////////////////////////////

// Override (UIViewController category)
- (void)viewControllerWillDismiss {
    //[[KDRequestDispatcher globalRequestDispatcher] cancelRequestsForReceiveTypeWithDelegate:self];
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

- (NSCache *)cellCache {
    if (!cellCache_) {
        cellCache_ = [[NSCache alloc] init];
        cellCache_.totalCostLimit = 1000;
    }
    return cellCache_;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(group_);
    //KD_RELEASE_SAFELY(_tableView);
    
    //KD_RELEASE_SAFELY(selectedIndexPath_);
    //KD_RELEASE_SAFELY(selectedStatus_);
    
    //KD_RELEASE_SAFELY(timelineProvider_);
    //KD_RELEASE_SAFELY(statusDataset_);
    //KD_RELEASE_SAFELY(cellCache_);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //[super dealloc];
}

@end
