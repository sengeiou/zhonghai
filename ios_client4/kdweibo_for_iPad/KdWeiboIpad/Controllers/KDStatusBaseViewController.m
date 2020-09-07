//
//  KDStatusBaseViewController.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-1.
//
//

#import "KDStatusBaseViewController.h"
#import "KDStatusDataProvider.h"
#import "KWIStatusCell.h"
#import "KWIStatusVCtrl.h"
//#import "KDMessageStatusProvider.h"
@interface KDStatusBaseViewController (){
    CGPoint lastOffset;
}

@end

@implementation KDStatusBaseViewController
@synthesize tableView = tableView_;
@synthesize dataProvider = dataProvider_;
@synthesize selectStatus = selectStatus_;
@synthesize haveMore = haveMore_;
@synthesize dataSourceArray = dataSourceArray_;
@synthesize haveFootView = haveFootView_;
@synthesize cellCache = cellCache_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        flags_.initDataProvider = 1;
        flags_.shouldLoadFromLocal = 1;
        flags_.viewDidUnload = 0;
        flags_.shouldRefresh = 0;
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
 
        [dnc addObserver:self
                selector:@selector(onStatusDeleted:)
                    name:@"KWStatus.remove"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(onCommentCountUpdated:)
                    name:@"comment_count_updated"
                  object:nil];
     
    }
    return self;
}

- (void)viewDidLoad {
     DLog(@"viewDidLoad....");
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    // navigation item title view
    self.navigationController.navigationBarHidden = YES;
    CGRect frame = self.view.bounds;
    // comments table view
    KDRefreshTableView *aTableView = [[KDRefreshTableView alloc] initWithFrame:frame
                                                        kdRefreshTableViewType:KDRefreshTableViewType_Both
                                                                         style:UITableViewStylePlain];
    
    aTableView.delegate = self;
    aTableView.dataSource = self;
    
    aTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    aTableView.autoresizesSubviews = YES;
    [self.view addSubview:aTableView];
    
    aTableView.backgroundColor = [UIColor clearColor];
    aTableView.separatorColor = [UIColor clearColor];
    self.tableView = aTableView;
    [aTableView release];
    
}
- (void)viewDidUnload {
     DLog(@"viewDidUnload....");
    lastOffset = self.tableView.contentOffset;
    self.tableView = nil;
    flags_.viewDidUnload = 1;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(flags_.initDataProvider == 1) {
        flags_.initDataProvider = 0;
        [self initWithDataProvider];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(flags_.shouldLoadFromLocal == 1) {
        flags_.shouldLoadFromLocal = 0;
        [self loadFromLocal];
    }
    
    if(flags_.viewDidUnload == 1){
        flags_.viewDidUnload = 0;
    }
    
    if (flags_.shouldRefresh == 1) {
        flags_.shouldRefresh = 0;
        [self reloadCurrentDataSource];
    }
    if (flags_.viewDidUnload == 1) {
        flags_.viewDidUnload = 0;
        [self.tableView reloadData];
        [self.tableView setContentOffset:lastOffset];

    }
}

- (void)reloadCurrentDataSource {
    if ([self canReloadCurrentDataSource]) {
        [self.tableView setFirstInLoadingState];
        [self loadStatuses:YES];
    }
}

- (void)loadFromLocal {
    [dataProvider_ loadCachedStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    KD_RELEASE_SAFELY(cellCache_);
    DLog(@"didReceivememoryWarnign....");
}

- (void)shouldShowBlankHolderView:(BOOL)should {
//    if (should) {
//        UIView *view  = [[UIView alloc] initWithFrame:tableView_.bounds];
//        view.backgroundColor =[UIColor clearColor];
//        
//        //        UIImageView *clouldImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_placeholder_v2"]];
//        //        clouldImageView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds) - 50);
//        //        [view addSubview:clouldImageView];
//        //        [clouldImageView release];
//        
//        self.tableView.tableFooterView = view;
//        [view release];
//        
//    }else {
//        self.tableView.tableFooterView = nil;
//    }
}


- (BOOL)canReloadCurrentDataSource {
    BOOL canReload = NO;
    canReload = ![self.tableView isLoading];
    return canReload;
}

- (void)setHaveFootView:(BOOL)haveFootView {
    [tableView_ setBottomViewHidden:!haveFootView];
    haveFootView_ = haveFootView;
}
///////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - KDRefreshTableViewDelegate methods
- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableVie {
    [self loadStatuses:YES];
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    [self loadStatuses:NO];
}

#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE

#pragma  mark -  Public Methods

//override
- (void)initWithDataProvider {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"should be overrided." userInfo:nil];
}

- (void)cellSelected {
    KWIStatusVCtrl *vctrl = [KWIStatusVCtrl vctrlWithStatus:self.selectStatus];
    
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [KWIStatusCell class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusVCtrl.show" object:self userInfo:inf];
}

- (void)shouldShowNoDataTipsView:(BOOL)isShould {
    [self.tableView shouldShowNoDataTipView:isShould];
}

- (id)init{
    self = [super init];
    if (self) {
        //
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
       
        [dnc addObserver:self
                selector:@selector(onStatusDeleted:)
                    name:@"KWStatus.remove"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(onCommentCountUpdated:)
                    name:@"comment_count_updated"
                  object:nil];
    }
    return self;
    
}

-(void)onCommentCountUpdated:(NSNotification *)notification {
    NSDictionary *uinf = notification.userInfo;
    NSString *id_ = [uinf objectForKey:@"id"];
    
    NSInteger count = [(NSNumber *)[uinf objectForKey:@"count"] integerValue];
    
    KDStatus *status = [self.dataProvider.dataSet statusById:id_];
    if (status == nil) {
        return;
    }
    status.forwardsCount = count;
    [self.cellCache removeObjectForKey:status.statusId];
    NSInteger index = [self.dataProvider.dataSet indexOfStatus:status];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:
                                            [NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
    
}

-(void)onStatusDeleted:(NSNotification *)notification {
    KDStatus *status = (KDStatus *)[notification object];
    KDStatus *toBeDeletedStatus = [self.dataProvider.dataSet statusById:status.statusId];
    if(toBeDeletedStatus == nil) {
        return;
    }
    NSInteger index = [self.dataProvider.dataSet indexOfStatus:toBeDeletedStatus];
    
    [self.dataProvider.dataSet removeStatus:toBeDeletedStatus];
    NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void)loadStatuses:(BOOL)isHead {
    if(isHead) {
        [dataProvider_ loadLatestStatus];
    }else {
        [dataProvider_ loadEarlierStatus];
    }
}

- (void)showPrompView:(NSInteger)count {

}

- (void)setFirstInLoadingState {
    [tableView_ setFirstInLoadingState];
}

- (void)finishLoadMore {
    [tableView_ finishedLoadMore];
}

- (void)reloadTableView {
    [tableView_ reloadData];
}

- (void)finishRefreshed:(BOOL)isSuccessful {
    [tableView_ finishedRefresh:isSuccessful];
}

- (void)displayError:(NSString *)errorString {
    [KDErrorDisplayView showErrorMessage:errorString
                                  inView:self.view.window];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [(KDRefreshTableView *)scrollView kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [(KDRefreshTableView *)scrollView kdRefreshTableviewDidEndDraging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
   // [self loadAvatarForVisibleCellsIfNeed:scrollView];
}



#pragma mark - TableView dataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ must be overrided by %@",NSStringFromSelector(_cmd),self] userInfo:nil];
   KDStatus *status = [dataProvider_.dataSet statusAtIndex:indexPath.row ];
    //return [dataProvider_ timelineStatusCellInTableView:tableView status:status];
    return [self loadCellForStatus:status];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDStatus *status = [dataProvider_.dataSet statusAtIndex:indexPath.row ];
    UITableViewCell *cell = [self loadCellForStatus:status];
    return CGRectGetHeight(cell.frame);
    //return [dataProvider_  calculateStatusContentHeight:status];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([dataProvider_.dataSet count]>0) {
        tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    else {
        tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    return [dataProvider_.dataSet count];
}

- (UITableViewCell *)loadCellForStatus:(KDStatus *)status
{
    KWIStatusCell *cell = [self.cellCache objectForKey:status.statusId];
    if (nil == cell) {
        cell = [KWIStatusCell cell];
        cell.data = status;
        [self.cellCache setObject:cell forKey:status.statusId];
    }
    return cell;
}
- (NSCache *)cellCache {
    if (!cellCache_) {
        cellCache_ = [[NSCache alloc] init];
        cellCache_.name = self.class.description;
        cellCache_.countLimit = 100;
    }
    
    return cellCache_;
}
#pragma mark - TableView delegate  Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectStatus = [dataProvider_.dataSet statusAtIndex:indexPath.row];
    [self cellSelected];
}

#pragma mark -  reloadTableViewDataSource
- (void)reloadTableViewDataSource:(UIScrollView *)scrollView {
	//  should be calling your tableviews model to reload
    [self loadStatuses:YES];
}

#pragma mark - UIViewController category
- (void)viewControllerWillDismiss {
    [dataProvider_ cancleAllNetworkRequest];
}

- (void)dealloc {
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc removeObserver:self name:@"KWStatus.remove" object:nil];
    [dnc removeObserver:self name:@"comment_count_updated" object:nil];
    KD_RELEASE_SAFELY(tableView_);
    dataProvider_.viewController = nil;
    KD_RELEASE_SAFELY(dataProvider_);
    KD_RELEASE_SAFELY(selectStatus_);
    KD_RELEASE_SAFELY(dataSourceArray_);
    KD_RELEASE_SAFELY(cellCache_);
    [super dealloc];
}

@end
