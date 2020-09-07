//
//  GroupViewController.m
//  TwitterFon
//
//  Created by apple on 11-1-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GroupViewController.h"
#import "GroupTimelineController.h"
#import "GroupInfoViewController.h"

#import "GroupCellView.h"
#import "KDGroup.h"
#import "ResourceManager.h"

#import "KDNotificationView.h"
#import "KDWeiboServicesContext.h"
#import "KDDatabaseHelper.h"

@interface GroupViewController ()

@property(nonatomic, retain) KDRefreshTableView *tableView;

@end


@implementation GroupViewController

@synthesize groupArray;
@synthesize tableView=tableView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        groupViewControllerFlags_.loadingGroups = 0;
        groupViewControllerFlags_.viewDidUnload = 0;
        
        // register unread listener
        [[KDManagerContext globalManagerContext].unreadManager addUnreadListener:self];
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.title = ASLocalizedString(@"GroupViewController_tips_1");
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    CGRect frame = self.view.bounds;
    frame.origin.y+=64;
    KDRefreshTableView *tableView = [[KDRefreshTableView alloc] initWithFrame:frame kdRefreshTableViewType:KDRefreshTableViewType_Header];// autorelease];
    self.tableView = tableView;
    
    tableView_.dataSource = self;
    tableView_.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];//BOSCOLORWITHRGBA(0xEDEDED, 1.0);
    self.tableView.rowHeight = 65;

    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    [self.tableView setTableHeaderView:view];
    
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
}

- (void)restoreGroups {
    
    __block GroupViewController *gvc = self;// retain];
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDGroupDAO> groupDAO = [[KDWeiboDAOManager globalWeiboDAOManager] groupDAO];
        NSArray *groups = [groupDAO queryGroupsWithLimit:999 database:fmdb];
        return groups;
        
    } completionBlock:^(id results){
        gvc.groupArray = results;
        [gvc.tableView reloadData];
        [gvc getGroupList];
        
        // release current view controller
//        [gvc release];
    }];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([self.groupArray count] == 0){
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
    return [groupArray count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    GroupCellView* cell = (GroupCellView*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
        cell = [[GroupCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.groupController = self;
    }
    
    KDGroup *group = [groupArray objectAtIndex:indexPath.row];
    cell.group = group;

    KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
    cell.unreadCount = (unread != nil) ? [unread unreadForGroupId:group.groupId] : 0;
    
    if(!tableView.dragging && !tableView.decelerating){
        if(!cell.avatarView.hasAvatar && !cell.avatarView.loadAvatar){
            [cell.avatarView setLoadAvatar:YES];
        }
    }
	return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
    KDGroup *group = [groupArray objectAtIndex:indexPath.row];
    
    GroupTimelineController *groupTimelineController = [[GroupTimelineController alloc]initWithGroup:group];
    groupTimelineController.newStatusCount = (int)[unread unreadForGroupId:group.groupId];
    [self.navigationController pushViewController:groupTimelineController animated:YES];
//    [groupTimelineController release];
}

#pragma mark - KDRefreshTableView datasource method and delegate methods
KDREFRESHTABLEVIEW_REFRESHDATE

- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView
{
    [self getGroupList];
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIScrollView delegate methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [tableView_ kdRefreshTableviewDidEndDraging:scrollView];
    
	if(!decelerate){
		[self loadAvatarForVisibleCellsIfNeed];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [tableView_ kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadAvatarForVisibleCellsIfNeed];
}

- (void)loadAvatarForVisibleCellsIfNeed {
    NSArray *cells = [self.tableView visibleCells];
	if(cells != nil){
        for(GroupCellView *cell in cells){
            if(!cell.avatarView.hasAvatar && !cell.avatarView.loadAvatar){
                [cell.avatarView setLoadAvatar:YES];
            }
        }
    }
}

- (void)didChangeGroupBadgeValue {
    
    self.groupArray = [NSMutableArray arrayWithArray:[self sortGroups:groupArray]];
    
    [self.tableView reloadData];
}

///////////////////////////////////////////////////////////////////////////////////////////

- (void)getGroupList {
    if(groupViewControllerFlags_.loadingGroups == 1) {
         return;
    }
    
    groupViewControllerFlags_.loadingGroups = 1;
    
    KDQuery *query = [KDQuery queryWithName:@"count" value:@"999"];
    
    __block GroupViewController *gvc = self ;//retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        BOOL success = NO;
        if ([response isValidResponse]) {
            success = YES;
            if(results != nil){
                
                gvc.groupArray = [NSMutableArray arrayWithArray:[self sortGroups:results]];
                [gvc.tableView reloadData];
                
                if ([groupArray count] > 0) {
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
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage] inView:gvc.view.window];
            }
        }
        
        [gvc.tableView finishedRefresh:success];
        [gvc showTipsOrNot];
        
        (gvc -> groupViewControllerFlags_).loadingGroups = 0;
        
        // release current view controller
//        [gvc release];
    };

    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/group/:joined" query:query
                                 configBlock:nil completionBlock:completionBlock];
}



- (void)showTipsOrNot {
    BOOL should = NO;
    if(!groupArray ||[groupArray count] <= 0) {
        should = YES;
    }

    [self setBackgroud:should];
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
        
        [tableView_ addSubview:backgroundView];
    }
    backgroundView.hidden = NO;
    
}


////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDUnreadListener methods



- (void)unreadManager:(KDUnreadManager *)unreadManager unReadType:(KDUnreadType)unReadType {
    if(groupViewControllerFlags_.viewDidUnload == 0){
        
        self.groupArray = [NSMutableArray arrayWithArray:[self sortGroups:groupArray]];
        
        [self.tableView reloadData];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    groupViewControllerFlags_.viewDidUnload = 1;
    
    //KD_RELEASE_SAFELY(tableView_);
}

- (void)dealloc {
    // remove unread listener
    [[KDManagerContext globalManagerContext].unreadManager removeUnreadListener:self];
}
#pragma mark - 小组按新消息数排序
- (NSArray *)sortGroups:(NSArray *)array
{
//    return [array sortedArrayUsingComparator: ^(id obj1, id obj2) {
//        
//        KDGroup *group1 = obj1;
//        KDGroup *group2 = obj2;
//        KDUnread *unread = [KDManagerContext globalManagerContext].unreadManager.unread;
//
//        if ([unread unreadForGroupId:group1.groupId]>[unread unreadForGroupId:group2.groupId]) {
//            return (NSComparisonResult)NSOrderedAscending;
//        }
//        if ([unread unreadForGroupId:group1.groupId] < [unread unreadForGroupId:group2.groupId]) {
//            return (NSComparisonResult)NSOrderedDescending;
//        }
//        return (NSComparisonResult)NSOrderedSame;
//    }];
    return array;
}
@end

