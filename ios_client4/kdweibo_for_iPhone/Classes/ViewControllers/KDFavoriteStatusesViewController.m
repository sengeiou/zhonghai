//
//  KDFavoriteStatusesViewController.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-8-1.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDFavoriteStatusesViewController.h"
#import "ProfileViewController2.h"
#import "UIViewController+Navigation.h"

#import "KDNotificationView.h"
#import "KDStatus.h"
#import "KDStatusTimelineProvider.h"

#import "KDRequestDispatcher.h"

#import "KDWeiboServicesContext.h"
#import "KDDefaultViewControllerContext.h"
#import "KDStatusDetailViewController.h"
#import "KDStatusLayouter.h"
#import "KDLayouterView.h"
#import "KDLayouter.h"
#import "KDStatusCell.h"
#import "ProfileViewController.h"

@interface KDFavoriteStatusesViewController ()

@property(nonatomic, retain) KDStatusTimelineProvider *timelineProvider;
@property(nonatomic, retain) NSMutableArray *statuses;
@property(nonatomic, retain) KDStatus *selectedStatus;

@property(nonatomic, retain) KDRefreshTableView *tableView;
@property(nonatomic, retain) NSCache  *cellCache;

- (void)reloadFavoriteResults;
- (void)listFavoriteStatuses:(BOOL)atHead;

@end

@implementation KDFavoriteStatusesViewController

@synthesize statuses=statuses_;
@synthesize selectedStatus=selectedStatus_;
@synthesize timelineProvider=timelineProvider_;
@synthesize cellCache = cellCache_;
@synthesize tableView=tableView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        timelineProvider_ = [[KDStatusTimelineProvider alloc] initWithViewController:self];
        timelineProvider_.showAccurateGroupName = YES;
        
        pageIndex_ = 1;
        
        statusesViewControllerFlags_.dismissed = 0;
        
        self.navigationItem.title = NSLocalizedString(@"FAVORITES_STATUSES", @"");

        
    }
    
    return self;
}

- (NSCache *)cellCache {
    if(cellCache_ == nil) {
        cellCache_ = [[NSCache alloc] init];
        cellCache_.totalCostLimit = 500;
    }
    return cellCache_;
}

- (void)loadView {
    UIView *aView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = aView;
//    [aView release];
    
    // table view
    CGRect rect = self.view.bounds;
    rect.origin.y += 64.f;
    rect.size.height -=24.f;
    KDRefreshTableView *tableView = [[KDRefreshTableView alloc] initWithFrame:rect kdRefreshTableViewType:KDRefreshTableViewType_Both style:UITableViewStylePlain];
    self.tableView = tableView;
//    [tableView release];
    tableView_.backgroundColor = RGBCOLOR(237, 237, 237);
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
    
    // long press gesture recognizer
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    longPressGestureRecognizer.minimumPressDuration = 0.3;
    [tableView_ addGestureRecognizer:longPressGestureRecognizer];
//    [longPressGestureRecognizer release];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // load results if need
    [self reloadFavoriteResults];
}

- (void)viewControllerWillDismiss {
    statusesViewControllerFlags_.dismissed = 1;
    
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0x01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (statuses_ != nil) ? [statuses_ count] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDStatus *status = [statuses_ objectAtIndex:indexPath.row];
    
    KDStatusLayouter *layouter = [KDStatusLayouter statusLayouter:status constrainedWidth:CGRectGetWidth(tableView.bounds) - 16.0f];
    
    return CGRectGetHeight(layouter.frame) + 10;
    
    //return [timelineProvider_ calculateStatusContentHeight:status inTableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDStatus *status = [statuses_ objectAtIndex:indexPath.row];
    
    KDStatusCell *cell = [self.cellCache objectForKey:status.statusId];
    if (!cell) {
        KDStatusLayouter *layouter = [KDStatusLayouter statusLayouter:status constrainedWidth:0];
        KDLayouterView * layouterView = [layouter view];
        cell = [[KDStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];// autorelease];
        cell.backgroundColor = [UIColor clearColor];
        [cell addSubview:layouterView];
        layouterView.layouter = layouter;
        [self.cellCache setObject:cell forKey:status.statusId cost:1];
        
    }
    
    if(!tableView.dragging && !tableView.decelerating){
        [cell loadThumbanilsImage];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KDStatus *status = [statuses_ objectAtIndex:indexPath.row];
    self.selectedStatus = status;
    
    KDStatusDetailViewController *sdvc = [[KDStatusDetailViewController alloc] initWithStatus:status];// autorelease];
    
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [tableView_ kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [KDStatusCell loadImagesForVisibleCellsIfNeed:(UITableView *)scrollView];
    }
    
    [tableView_ kdRefreshTableviewDidEndDraging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [KDStatusCell loadImagesForVisibleCellsIfNeed:(UITableView *)scrollView];
}

- (void)removeStatus:(KDStatus *)status {
    NSUInteger idx = [statuses_ indexOfObject:selectedStatus_];
    
    if(idx != NSNotFound) {
        [statuses_ removeObject:selectedStatus_];
        selectedStatus_ = nil;
        
        [tableView_ deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    } else {
        [tableView_ reloadData];
    }
}

/////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDRefreshTableView delegate method

- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView
{
    [self listFavoriteStatuses:YES];
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView
{
    [self listFavoriteStatuses:NO];
}

#pragma mark - 
#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE
////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDUserDataLoader delegate method

- (void) loadUserData {
    [self reloadFavoriteResults];
}


////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (void)reloadFavoriteResults {
    BOOL hasResults = (statuses_ != nil && [statuses_ count] > 0) ? YES : NO;
    if(!hasResults){
        [tableView_ setFirstInLoadingState];
        [self listFavoriteStatuses:YES];
    }
}

- (void)_handleResponseStatuses:(NSArray *)statuses atHead:(BOOL)atHead {
    if(atHead){
        // reset data source
        self.statuses = [NSMutableArray arrayWithArray:statuses];
        
        pageIndex_ = 1;
    
    } else {
        // append data source
        if(statuses_ == nil){
            statuses_ = [[NSMutableArray alloc] initWithCapacity:[statuses count]];
        }
        
        [statuses_ addObjectsFromArray:statuses];
        
        if([statuses count] > 0){
            pageIndex_ += 1;
        }
    }
    
    [tableView_ reloadData];
    
    // BOOL hasFooterView = ([statuses count] > 0 && ([statuses count] % 20 == 0)) ? YES : NO;
    BOOL hasFooterView = ([statuses count] == 20) ? YES : NO;
    [tableView_ setBottomViewHidden:!hasFooterView];
}

- (void)listFavoriteStatuses:(BOOL)atHead {
    NSInteger page = atHead ? 1 : (pageIndex_ + 1);
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"page" integerValue:page]
            setParameter:@"count" stringValue:@"20"];
    
    __block KDFavoriteStatusesViewController *fsvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results != nil) {
            for (KDStatus *obj in results) {
                KDLayouter * layouter =   [KDStatusLayouter  statusLayouter:obj constrainedWidth:self.view.bounds.size.width - 16];
                KDLayouterView * layouterView = [layouter view];
                KDStatusCell * cell = [[KDStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];// autorelease];
                [cell addSubview:layouterView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                layouterView.layouter = layouter;
                [self.cellCache setObject:cell forKey:[(KDStatus *)obj statusId] cost:1];
            }
            
            [fsvc _handleResponseStatuses:results atHead:atHead];
        }
        
        if (atHead) {
            [fsvc.tableView finishedRefresh:(results != nil)];
            
        } else {
            [fsvc.tableView finishedLoadMore];
        }
        
        [fsvc showTipsOrNot];
        
        // release current view controller
//        [fsvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/favorites/:favorites" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)showTipsOrNot {
    if(!statuses_ || [statuses_ count] <= 0) {
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, KD_TABLEVIEW_FOOTERVIEW_HEIGHT)];
        
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.textColor = [UIColor darkGrayColor];
        infoLabel.font = [UIFont systemFontOfSize:15.0];
        infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        infoLabel.textAlignment = NSTextAlignmentCenter;
        
        infoLabel.text = ASLocalizedString(@"No_Data_Refresh");
        
        infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.tableView.tableFooterView = infoLabel;
//        [infoLabel release];
    }else {
        self.tableView.tableFooterView = nil;
    }
}

//MethodsForPromptView(promptView_);

- (void)favoritesDestory {
    // Issue(Favorite-001)
    // Because the data source may be changed on action sheet on show.
    // Check the status does exist in data source.
    // eg:
    // reload (request is going)
    // -> long press (show action sheet) 
    // -> update data source (reload request did finish) 
    // -> selected statuses may be removed from data source
    
    if(NSNotFound != [statuses_ indexOfObject:selectedStatus_]){
        KDQuery *query = [KDQuery queryWithName:@"id" value:selectedStatus_.statusId];
        [query setProperty:selectedStatus_.statusId forKey:@"entityId"];
        
        __block KDFavoriteStatusesViewController *fsvc = self;// retain];
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            if ([response isValidResponse] && (fsvc -> statusesViewControllerFlags_).dismissed == 0) {
                // see issue(Favorite-001)
                NSUInteger index = [fsvc.statuses indexOfObject:fsvc.selectedStatus];
                if (NSNotFound != index) {
                    [fsvc.statuses removeObjectAtIndex:index];
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0x00];
                    [fsvc.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                          withRowAnimation:UITableViewRowAnimationRight];
                    
                    // delay to update footer view after delete cell animation did finish.
                    // The table view content size will be change when the animation did stop
                    [fsvc performSelector:@selector(updateRefreshTableFooterView) withObject:nil afterDelay:0.35];
                }
                
                // post user profile did change notification
                [[NSNotificationCenter defaultCenter] postNotificationName:KDUserProfileDidChangeNotification object:fsvc];
            }
            
            // cancel selected statuses
            fsvc.selectedStatus = nil;
            
            // release current view controller
//            [fsvc release];
        };
        
        [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/favorites/:destoryById" query:query
                                     configBlock:nil completionBlock:completionBlock];
    }
}

- (void)updateRefreshTableFooterView {
    BOOL hasFooterView = ([statuses_ count] > 0) ? YES : NO;
    [tableView_ setBottomViewHidden:!hasFooterView];
}

- (void)didLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(UIGestureRecognizerStateBegan == gestureRecognizer.state){
        CGPoint anchorPoint = [gestureRecognizer locationInView:tableView_];
        NSIndexPath *indexPath = [tableView_ indexPathForRowAtPoint:anchorPoint];
        if(indexPath != nil){
            self.selectedStatus = [statuses_ objectAtIndex:indexPath.row];
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"FAVORITES_CANCEL", @""), ASLocalizedString(@"Global_Cancel"), nil];
            
            actionSheet.cancelButtonIndex = 0x01;
            [actionSheet showInView:self.view.window];
//            [actionSheet release];
        }
    }
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIActionSheet delegate method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(0x00 == buttonIndex){
        [self favoritesDestory];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}
- (void)viewDidUnload {
    [super viewDidUnload];

    //KD_RELEASE_SAFELY(tableView_);
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(timelineProvider_);
    //KD_RELEASE_SAFELY(statuses_);
    //KD_RELEASE_SAFELY(selectedStatus_);
    
    //KD_RELEASE_SAFELY(tableView_);
    ////KD_RELEASE_SAFELY(promptView_);
    
    //[super dealloc];
}

@end
