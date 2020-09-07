//
//  BlogViewController.m
//  TwitterFon
//
//  Created by apple on 11-6-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BlogViewController.h"

#import "ResourceManager.h"

#import "KDStatusTimelineProvider.h"
#import "KDStatusDataset.h"

#import "KDWeiboServicesContext.h"
#import "KDRequestDispatcher.h"
#import "KDNotificationView.h"
#import "KDErrorDisplayView.h"
#import "NSDictionary+Additions.h"
#import "KDStatusDetailViewController.h"
#import "KDWeiboAppDelegate.h"
#import "ProfileViewController.h"
#import "KDStatusCounts.h"
#import "KDStatusLayouter.h"
#import "KDLayouterView.h"
#import "KDStatusCell.h"

@interface BlogViewController ()

@property(nonatomic, retain) KDStatusTimelineProvider *timelineProvider;
@property(nonatomic, retain) KDStatusDataset *dataset;
@property(nonatomic, assign) NSInteger currentPage;

@property(nonatomic, retain) KDRefreshTableView *tableView;

@property(nonatomic, assign) BOOL hasFooterView;

@property(nonatomic, retain) NSIndexPath *selectedIndexPath;
@property(nonatomic, retain) KDStatus *selectedStatus;
@property(nonatomic, retain) NSCache  *cellCache;

@end

@implementation BlogViewController {
 @private
    BOOL isLoadingMore_;
}

@synthesize delegate=delegate_;
@synthesize user=user_;

@synthesize timelineProvider=timelineProvider_;
@synthesize dataset=dataset_;
@synthesize currentPage=currentPage_;

@synthesize tableView = tableView_;

@synthesize hasFooterView=hasFooterView_;

@synthesize selectedIndexPath=selectedIndexPath_;
@synthesize selectedStatus=selectedStatus_;
@synthesize cellCache = cellCache_;
@synthesize subTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentPage_ = -1;
        isLoadingMore_ = NO;
        
        timelineProvider_ = [[KDStatusTimelineProvider alloc] initWithViewController:self];
    }
    
    return self;
}

- (NSCache *)cellCache {
    if(!cellCache_) {
        cellCache_ = [[NSCache alloc] init];
        cellCache_.totalCostLimit = 500;
    }
    
    return cellCache_;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if(subTitle)
        self.title = subTitle;
    self.tableView = [[KDRefreshTableView alloc] initWithFrame:CGRectMake(0, 62, ScreenFullWidth, ScreenFullHeight-62) kdRefreshTableViewType:KDRefreshTableViewType_Both] ;//autorelease];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = RGBCOLOR(237, 237, 237);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIButton *btn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn]];
    
    [self setNavigationStyle:KDNavigationStyleNormal];
}

- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	KDStatus *status = [dataset_ statusAtIndex:indexPath.row];
    
    KDStatusLayouter *layouter = [KDStatusLayouter statusLayouter:status constrainedWidth:CGRectGetWidth(tableView.bounds) - 16.0f];
    return layouter.frame.size.height + 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataset_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDStatus *status = [dataset_ statusAtIndex:indexPath.row];

    KDStatusCell *cell = [self.cellCache objectForKey:status.statusId];
    if (!cell) {
        KDStatusLayouter *layouter = [KDStatusLayouter statusLayouter:status constrainedWidth:0];
        KDLayouterView * layouterView = [layouter view];
        cell = [[KDStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] ;//autorelease];
        [cell addSubview:layouterView];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KDStatus *status = [dataset_ statusAtIndex:indexPath.row];
    self.selectedIndexPath = indexPath;
    self.selectedStatus = status;
    
    KDStatusDetailViewController *sdvc = [[KDStatusDetailViewController alloc] initWithStatus:status] ;//autorelease];
    
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
    
    [nc pushViewController:sdvc animated:YES];
}

- (void)removeStatus:(KDStatus *)status {
    if (NSNotFound != [dataset_ indexOfStatus:selectedStatus_]) {
        [dataset_ removeStatus:selectedStatus_];
        
        NSArray *indexPaths = [NSArray arrayWithObject:selectedIndexPath_];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
    }
}

- (void)getTimelineIDS:(NSArray *)statuses {
    NSUInteger count = (statuses != nil) ? [statuses count] : 0;
    if(count < 0x01) return;
    
    NSMutableString *IDs = [NSMutableString string];
    NSUInteger idx = 0;
    for(KDStatus *item in statuses){
        [IDs appendString:item.statusId];
        if(idx++ != (count - 1)){
            [IDs appendString:@","];
        }
    }
    
    KDQuery *query = [KDQuery queryWithName:@"ids" value:IDs];
    
    __block BlogViewController *bc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results != nil) {
            NSArray *objs = results;
            
            NSUInteger count = [objs count];
            if (count > 0) {
                
                __block BOOL shouldReloadTableView;
                for (KDStatusCounts *sc in objs) {
                    [statuses enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop) {
                        KDStatus *status = obj;
                        if ([[status  statusId] isEqualToString:sc.statusId]) {
                            if(status.forwardsCount != sc.forwardsCount ||
                                status.commentsCount != sc.commentsCount||
                                status.likedCount !=sc.likedCount) {
                                status.forwardsCount = sc.forwardsCount;
                                status.commentsCount = sc.commentsCount;
                                status.likedCount = sc.likedCount;
                                if (!shouldReloadTableView) {
                                    shouldReloadTableView = YES;
                                }
                           }
                            *stop = YES;
                           
                        }
                    }];
                }
                
                if (shouldReloadTableView) {
                    [bc.tableView reloadData];
                    
                }
            }
        }
        
        // release the data source
//        [bc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self  actionPath:@"/statuses/:counts" query:query
                                 configBlock:nil completionBlock:completionBlock];
}


- (void)loadUserTimeline:(BOOL)atHead {
    isLoadingMore_ = !atHead;
    
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"user_id" stringValue:user_.userId]
             setParameter:@"count" stringValue:@"20"]
             setParameter:@"cursor" integerValue:currentPage_];
    
    __block BlogViewController *bvc = self ;//retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results != nil) {
            NSDictionary *info = results;
            NSArray *statuses = [info objectForKey:@"statuses"];
            for (KDStatus *obj in statuses) {
                KDLayouter * layouter =   [KDStatusLayouter  statusLayouter:obj constrainedWidth:self.view.bounds.size.width - 16];
                KDLayouterView * layouterView = [layouter view];
                KDStatusCell * cell = [[KDStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] ;//autorelease];
                [cell addSubview:layouterView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                layouterView.layouter = layouter;
                [self.cellCache setObject:cell forKey:[(KDStatus *)obj statusId] cost:1];
            }
            
            bvc.currentPage = [info integerForKey:@"nextCursor"];
            
            if(bvc.dataset == nil){
                KDStatusDataset *dataset = [[KDStatusDataset alloc] init];
                bvc.dataset = dataset;
//                [dataset release];
            }
            
            NSUInteger count = [statuses count];
            if (count > 0) {
                [bvc getTimelineIDS:statuses];
                [bvc.dataset mergeStatuses:statuses atHead:atHead limit:20];
            }
            
            [bvc.tableView reloadData];
            
            bvc.hasFooterView = (bvc.currentPage != 0) ? YES : NO;
        }
        
        [bvc showTipsOrNot];
        [bvc dataSourceDidFinishLoadingNewData];
        
        // release current view controller
//        [bvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/statuses/:userTimelineByCursor" query:query
                                 configBlock:nil completionBlock:completionBlock];
}


- (void)showTipsOrNot {
    if(dataset_ == nil || [dataset_ count] <= 0) {
        UIView *blankView = [ResourceManager noDataPromptView];
        blankView.frame = self.tableView.bounds;
        self.tableView.tableFooterView = blankView;
    }else {
        self.tableView.tableFooterView = nil;
    }
}

- (void)getUserTimeline {
    currentPage_ = -1;
    [self loadUserTimeline:YES];
}

- (void)getUserTimeline_Next {
    [self loadUserTimeline:NO];
}


- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    [self getUserTimeline_Next];
}

- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView {
    [self getUserTimeline];
}

#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[tableView_ kdRefreshTableViewDidScroll:scrollView];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [KDStatusCell loadImagesForVisibleCellsIfNeed:(UITableView *)scrollView];
    }
    
    [tableView_ kdRefreshTableviewDidEndDraging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //[self loadAvatarForVisibleCellsIfNeed:scrollView];
     [KDStatusCell loadImagesForVisibleCellsIfNeed:(UITableView *)scrollView];
}



- (void)dataSourceDidFinishLoadingNewData {
	if(isLoadingMore_) {
        [tableView_ finishedLoadMore];
    }else {
        [tableView_ finishedRefresh:YES];
    }
    
    if ([delegate_ respondsToSelector:@selector(blogViewController:withStatusCount:)]) {
        [delegate_ blogViewController:self withStatusCount:[dataset_ count]];
    }
}

- (void)reloadTableViewDataSource {
    [self getUserTimeline];
}

- (BOOL)hasFooterView {
    return hasFooterView_;
}

- (void)setHasFooterView:(BOOL)hasFooterView {
    [self.tableView setBottomViewHidden:!hasFooterView];
    
    hasFooterView_ = hasFooterView;
}

- (void)loadUserData {
	if (dataset_ == nil && ![tableView_ isLoading]) {
		[self getUserTimeline];
        [tableView_ setFirstInLoadingState];
	}
}

//////////////////////////////////////////////////////////////////////

// Override (UIViewController category)
- (void)viewControllerWillDismiss {
    
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    delegate_ = nil;
    
    //KD_RELEASE_SAFELY(timelineProvider_);
    //KD_RELEASE_SAFELY(dataset_);
    //KD_RELEASE_SAFELY(cellCache_);
    //KD_RELEASE_SAFELY(user_);
    //KD_RELEASE_SAFELY(selectedIndexPath_);
    //KD_RELEASE_SAFELY(selectedStatus_);
    
    //KD_RELEASE_SAFELY(tableView_);
    //[super dealloc];
}

@end
