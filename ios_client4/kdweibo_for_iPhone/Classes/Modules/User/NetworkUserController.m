//
//  NetworkUserController.m
//  TwitterFon
//
//  Created by apple on 10-11-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetworkUserController.h"

#import "ProfileViewController.h"
#import "ResourceManager.h"

#import "KDNotificationView.h"

#import "KDRequestDispatcher.h"
#import "KDWeiboServicesContext.h"
#import "KDDatabaseHelper.h"

#import "KDWeiboAppDelegate.h"
#import "NSDictionary+Additions.h"

#import "KDDefaultViewControllerContext.h"
@implementation NetworkUserController

@synthesize contacts = contacts_;
@synthesize tableView = tableView_;
@synthesize owerUser,isFollowee;
@synthesize currentPage=currentPage_;
@synthesize isLoadingMore = isLoadingMore_;
@synthesize subTitle;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.contacts = [NSMutableArray array];
        self.currentPage = -1;
    }
    
    return self;
}

- (void) loadView {
    [super loadView];
    
    if(self.subTitle)
        self.title = self.subTitle;
    
    self.tableView = [[KDRefreshTableView alloc] initWithFrame:CGRectMake(0, 62, ScreenFullWidth, ScreenFullHeight-62) kdRefreshTableViewType:KDRefreshTableViewType_Both];// autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor= [UIColor kdBackgroundColor1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn]];
    
    [self setNavigationStyle:KDNavigationStyleNormal];
}

- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section {
    return [self.contacts count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"NetworkUserCell";
	
    KDNetworkUserCell* cell = (KDNetworkUserCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[KDNetworkUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        UIView *selectBgView = [[UIView alloc] initWithFrame:CGRectZero];// autorelease];
        selectBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        selectBgView.backgroundColor = RGBCOLOR(26, 133, 255);
        cell.selectedBackgroundView = selectBgView;
    }
    
    // Configure the cell...
	KDUser *user=[self.contacts objectAtIndex:indexPath.row];
	cell.user=user;
    
	if(!tableView.dragging && !tableView.decelerating){
        if(!cell.avatarView.hasAvatar && !cell.avatarView.loadAvatar){
            [cell.avatarView setLoadAvatar:YES];
        }
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView_ deselectRowAtIndexPath:indexPath animated:YES];
	if(indexPath.row<[self.contacts count])
	{
        UINavigationController *nc = self.navigationController;
        
        if(!nc) {
            UIView *superView = self.view.superview;
            while (superView) {
                id superViewController = [superView nextResponder];
                if([superViewController isKindOfClass:[UIViewController class]]) {
                    UIViewController *vc = (UIViewController *)superViewController;
                    if(vc.navigationController) {
                        nc = vc.navigationController;
                        break;
                    }
                }
                
                superView = superView.superview;
            }
        }
        
		KDUser *user = [self.contacts objectAtIndex:indexPath.row];
//		ProfileViewController *pvc = [[ProfileViewController alloc] initWithUser:user andSelectedIndex:3];
//        [nc pushViewController:pvc animated:YES];
//        [pvc release];
        [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:user sender:self.view];

	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	//KD_RELEASE_SAFELY(owerUser);
    //KD_RELEASE_SAFELY(contacts_);
    //KD_RELEASE_SAFELY(tableView_);
    
   // //KD_RELEASE_SAFELY(promptView_);
    
    //[super dealloc];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
    [tableView_ kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [tableView_ kdRefreshTableviewDidEndDraging:scrollView];
    if(!decelerate){
		[self loadAvatarForVisibleCellsIfNeed];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadAvatarForVisibleCellsIfNeed];
}


- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
   // [self loadUsers:NO];
    [self getUserTimeline_next];
}

- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView {
    [self getUserTimeline];
}

#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE

- (void)loadAvatarForVisibleCellsIfNeed {
    NSArray *cells = [self.tableView visibleCells];
	if(cells != nil){
        for(KDNetworkUserCell *cell in cells){
            if(!cell.avatarView.hasAvatar && !cell.avatarView.loadAvatar){
                [cell.avatarView setLoadAvatar:YES];
            }
        }
    }
}

- (void)dataSourceDidFinishLoadingNewData{
	if(self.isLoadingMore) {
        [tableView_ finishedLoadMore];
    }else {
        [tableView_ finishedRefresh:YES];
    }
}

- (void)showTipsOrNot {
    if (!self.contacts || [self.contacts count] <= 0) {
        UIView *blankView = [ResourceManager noDataPromptView];
        blankView.frame = self.tableView.bounds;
        self.tableView.tableFooterView = blankView;
    }else {
        self.tableView.tableFooterView = nil;
    }
}

- (void)loadUsers:(BOOL)atHead {
    if (atHead) {
        self.currentPage = 0;
    }
    self.isLoadingMore = !atHead;
    
    NSString *actionPath = isFollowee ? @"/statuses/:friends" : @"/statuses/:followers";
    
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"user_id" stringValue:owerUser.userId]
             setParameter:@"count" stringValue:@"10"]
             setParameter:@"cursor" integerValue:self.currentPage];
    
    __block NetworkUserController *nuvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                NSDictionary *info = results;
                NSArray *users = [info objectForKey:@"users"];
                
                nuvc.currentPage = [info integerForKey:@"nextCursor"];
                
                if(nuvc.contacts == nil)
                    nuvc.contacts = [NSMutableArray arrayWithCapacity:10];
                
                //filter
                NSPredicate *userFilter = [NSPredicate predicateWithFormat:@"NOT (SELF.userId IN %@)", [nuvc.contacts valueForKeyPath:@"userId"]];
                NSArray *shouldAddUser = [users filteredArrayUsingPredicate:userFilter];
                
                if(shouldAddUser && shouldAddUser.count) {
                    if(atHead){
                        [nuvc.contacts insertObjects:shouldAddUser atIndexes:[NSIndexSet indexSetWithIndexesInRange:(NSRange){0, users.count}]];
                    }else
                        [nuvc.contacts addObjectsFromArray:shouldAddUser];
                    [nuvc.tableView reloadData];
                }
                
                nuvc.haveFootView = (nuvc.currentPage != 0);
                
                // save users into database
                [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb) {
                    id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                    [userDAO saveUsersSimple:users database:fmdb];
                    
                    return nil;
                    
                } completionBlock:nil];
            }
        }
        
        [nuvc showTipsOrNot];
        [nuvc dataSourceDidFinishLoadingNewData];
        
        // release current view controller
//        [nuvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)getUserTimeline {
    [self loadUsers:YES];
}

- (void)getUserTimeline_next {
    [self loadUsers:NO];
}

- (void) loadUserData {
    if (self.currentPage == -1 && ![tableView_ isLoading]) {
		[self getUserTimeline];
        [tableView_ setFirstInLoadingState];
	}
}


-(BOOL)haveFootView {
    return _haveFootView;
}

-(void) setHaveFootView:(BOOL)haveFootView {
    [tableView_ setBottomViewHidden:!haveFootView];
    _haveFootView=haveFootView;
}
//////////////////////////////////////////////////////////////////////

// Override (UIViewController category)
- (void)viewControllerWillDismiss {
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

@end

