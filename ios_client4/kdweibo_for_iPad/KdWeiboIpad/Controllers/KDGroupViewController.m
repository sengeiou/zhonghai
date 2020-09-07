//
//  KDGroupViewController.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-3.
//
//

#import "KDGroupViewController.h"

#import "KDGroup.h"
//#import "ResourceManager.h"

#import "KDNotificationView.h"
#import "KDWeiboServicesContext.h"
#import "KDDatabaseHelper.h"
#import "KDRefreshTableView.h"
#import "KWIGroupCell.h"

#import "KDGroupStatusViewController.h"
#import "KWIRootVCtrl.h"

@interface KDGroupViewController ()<KDRefreshTableViewDataSource,KDRefreshTableViewDelegate>{
    struct {
        unsigned int init:1;
        unsigned int loadingGroups:1;
        unsigned int viewDidUnload:1;
    }groupViewControllerFlags_;
    
}
@property (nonatomic, retain)NSArray *groupArray;
@property (nonatomic, retain) KDRefreshTableView *tableView;
@property (nonatomic, retain)NSCache *cellCache;

@end


@implementation KDGroupViewController

@synthesize groupArray = groupArray_;;
@synthesize tableView=tableView_;
@synthesize cellCache = cellCache_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        groupViewControllerFlags_.init = 1;
        groupViewControllerFlags_.loadingGroups = 0;
        groupViewControllerFlags_.viewDidUnload = 0;
        
        // register unread listener
//        [[KDManagerContext globalManagerContext].unreadManager addUnreadListener:self];
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.frame = CGRectMake(10, 0, 250, CGRectGetHeight(KWIRootVCtrl.curInst.view.bounds));
    UIImage *bg = [UIImage imageNamed:@"groupLsBg.png"];
    UIImageView *bgv = [[[UIImageView alloc] initWithImage:bg] autorelease];
    CGRect bgFrame = bgv.frame;
    bgFrame.origin.x = -20;
    bgFrame.origin.y = -4;
    bgFrame.size.height = CGRectGetHeight(self.view.frame) + 4;
    bgv.frame = bgFrame;
    bgv.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:bgv];
    
    
    KDRefreshTableView *tableView = [[[KDRefreshTableView alloc] initWithFrame:self.view.bounds kdRefreshTableViewType:KDRefreshTableViewType_Header] autorelease];
    self.tableView = tableView;
    
    tableView_.dataSource = self;
    tableView_.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
}

- (void)restoreGroups {
    [self shouldShowBlankHolderView:YES];
    __block KDGroupViewController *gvc = [self retain];
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDGroupDAO> groupDAO = [[KDWeiboDAOManager globalWeiboDAOManager] groupDAO];
        NSArray *groups = [groupDAO queryGroupsWithLimit:9999 database:fmdb];
        return groups;
    } completionBlock:^(id results){
        gvc.groupArray = results;
        [gvc.tableView reloadData];
        [gvc getGroupList];
        // release current view controller
        [gvc release];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(groupViewControllerFlags_.init == 1){
        groupViewControllerFlags_.init = 0;
        [tableView_ setFirstInLoadingState];
        [self restoreGroups];
    }
    if(groupViewControllerFlags_.viewDidUnload == 1){
        groupViewControllerFlags_.viewDidUnload = 0;
    }
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [groupArray_ count];;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    KDGroup *group = [groupArray_ objectAtIndex:indexPath.row];
    return [self loadCellForGroup:group];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
//    KDGroup *group = [groupArray objectAtIndex:indexPath.row];
//    
//    GroupTimelineController *groupTimelineController = [[GroupTimelineController alloc]initWithGroup:group];
//    groupTimelineController.newStatusCount = [unread unreadForGroupId:group.groupId];
//    [self.navigationController pushViewController:groupTimelineController animated:YES];
//    [groupTimelineController release];
    
    KDGroup *group = [self.groupArray objectAtIndex:indexPath.row];
    //group.unreadCount = [NSNumber numberWithInt:0];
    
    KDGroupStatusViewController *groupStatusViewController = [KDGroupStatusViewController viewControllerByGroup:group];
    NSDictionary *uinf = [NSDictionary dictionaryWithObject:groupStatusViewController forKey:@"vctrl"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GroupStatusViewController.show" object:self userInfo:uinf];
}

#pragma mark - KDRefreshTableView datasource method and delegate methods
KDREFRESHTABLEVIEW_REFRESHDATE

- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView {
    [self getGroupList];
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIScrollView delegate methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [tableView_ kdRefreshTableviewDidEndDraging:scrollView];
    
	if(!decelerate){
		//[self loadAvatarForVisibleCellsIfNeed];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [tableView_ kdRefreshTableViewDidScroll:scrollView];
}
- (void)didChangeGroupBadgeValue {
    [self.tableView reloadData];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

- (NSCache *)cellCache {
    if (cellCache_ == nil) {
        cellCache_ = [[NSCache alloc] init];
        cellCache_.name = self.class.description;
        cellCache_.countLimit = 20;
    }
    return cellCache_;
}

- (KWIGroupCell *)loadCellForGroup:(KDGroup *)group {
    KWIGroupCell *cell = [cellCache_ objectForKey:group.groupId];
    if (nil == cell) {
        cell = [KWIGroupCell cellWithGroup:group];
        [cellCache_ setObject:cell forKey:group.groupId];
    }
    
    return cell;
}

- (void)updateGroupDetails {
    for (KDGroup *group in self.groupArray) {
         KDQuery *query = [KDQuery queryWithName:@"group_id" value:group.groupId];
        
         __block KDGroupViewController *givc = [self retain];
         KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            if(results != nil){
                KDGroup *theGroup = results;
                group.memberCount = theGroup.memberCount;
                group.messageCount = theGroup.messageCount;
                // update group
            }
            // release current view controller
            [givc release];
        };
        
        [KDServiceActionInvoker invokeWithSender:self actionPath:@"/group/:details" query:query
                                     configBlock:nil completionBlock:completionBlock];

    }
}
- (void)getGroupList {
    if(groupViewControllerFlags_.loadingGroups == 1) {
        return;
    }
    groupViewControllerFlags_.loadingGroups = 1;
    KDQuery *query = [KDQuery queryWithName:@"count" value:@"9999"];
    __block KDGroupViewController *gvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        BOOL success = NO;
        if ([response isValidResponse]) {
            success = YES;
            if(results != nil){
                 gvc.groupArray = results;
                 [self updateGroupDetails];
                 [gvc.tableView reloadData];
                if ([gvc.groupArray count] > 0) {
                    // delete status from database
                    [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
                        id<KDGroupDAO> groupDAO = [[KDWeiboDAOManager globalWeiboDAOManager] groupDAO];
                        [groupDAO saveGroups:results database:fmdb rollback:rollback];
                        return nil;
                    } completionBlock:nil];
                }
            }
            
        } else {
            if (![response isCancelled]) {
//                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage] inView:gvc.view.window];
            }
        }
        
        [gvc.tableView finishedRefresh:success];
        [gvc showTipsOrNot];
        
        (gvc -> groupViewControllerFlags_).loadingGroups = 0;
        
        // release current view controller
        [gvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/group/:joined" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

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

- (void)showTipsOrNot {
    BOOL should = NO;
    if(!groupArray_ ||[groupArray_ count] <= 0) {
        should = YES;
    }
    [self.tableView shouldShowNoDataTipView:should];
    
}

////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDUnreadListener methods

//- (void)unreadManager:(KDUnreadManager *)unreadManager didChangeUnread:(KDUnread *)unread {
//    if(groupViewControllerFlags_.viewDidUnload == 0){
//        [self.tableView reloadData];
//    }
//}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    groupViewControllerFlags_.viewDidUnload = 1;
    
    KD_RELEASE_SAFELY(tableView_);
}

- (void)dealloc {
    // remove unread listener
//    [[KDManagerContext globalManagerContext].unreadManager removeUnreadListener:self];
    
    KD_RELEASE_SAFELY(groupArray_);
    KD_RELEASE_SAFELY(tableView_);
    KD_RELEASE_SAFELY(cellCache_);
    
    [super dealloc];
}
@end