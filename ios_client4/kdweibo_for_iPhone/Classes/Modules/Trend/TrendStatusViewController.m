//
//  TrendStatusViewController.m
//  TwitterFon
//
//  Created by apple on 11-6-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TrendStatusViewController.h"
#import "PostViewController.h"
#import "KDStatusDetailViewController.h"
#import "ResourceManager.h"

#import "KDStatus.h"
#import "KDStatusDataset.h"
#import "KDStatusTimelineProvider.h"

#import "KDNotificationView.h"

#import "KDRequestDispatcher.h"
#import "KDWeiboServicesContext.h"
#import "KDDefaultViewControllerContext.h"
#import "KDDatabaseHelper.h"
#import "KDStatusCell.h"
#import "KDStatusLayouter.h"

@interface TrendStatusViewController ()

@property(nonatomic, retain) KDMenuView *menuView;
@property(nonatomic, retain) KDRefreshTableView *tableView;

@property(nonatomic, retain) UIActivityIndicatorView *activityView;

@property(nonatomic, retain) KDStatusTimelineProvider *timelineProvider;
@property(nonatomic, retain) KDStatusDataset *statusDataset;

@property(nonatomic, retain) KDTopic *topic;

@property(nonatomic, retain) NSIndexPath *selectedIndexPath;
@property(nonatomic, retain) KDStatus *selectedStatus;

@property(nonatomic, retain) NSCache *cellCache;

@property(nonatomic, retain)NSArray *toolbarItems;

@end

@implementation TrendStatusViewController {
 @private
    BOOL favotited_;
    BOOL reloading_;
    NSInteger pageCursor_;
    
    struct {
        unsigned int isFirstIn:1;
    }viewFlags_;
}

@synthesize menuView = menuView_;
@synthesize tableView=tableView_;

@synthesize activityView=activityView_;


@synthesize timelineProvider=timelineProvider_;
@synthesize statusDataset=statusDataset_;

@synthesize topic=topic_;

@synthesize selectedIndexPath=selectedIndexPath_;
@synthesize selectedStatus=selectedStatus_;
@synthesize topicStatus=topicStatus_;
@synthesize cellCache = cellCache_;
@synthesize toolbarItems = toolbarItems_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        timelineProvider_ = [[KDStatusTimelineProvider alloc] initWithViewController:self];
        pageCursor_ = 2;
        viewFlags_.isFirstIn = 1;
    }
    
    return self;
}

- (id)initWithTopic:(KDTopic *)topic {
    self = [super init];
    if (self) {
        topic_ = topic;// retain];
        
        self.navigationItem.title = [NSString stringWithFormat:@"#%@#", topic.name];
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(viewFlags_.isFirstIn == 1) {
        viewFlags_.isFirstIn = 0;
        [self beginGetTimeline];
        [self confirmHasFollowFromServers];
    }
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = self.view.bounds;
    frame.size.height -= 46;
    self.view.backgroundColor = RGBCOLOR(237, 237, 237);
    
    KDRefreshTableView *aTableView = [[KDRefreshTableView alloc] initWithFrame:CGRectMake(0, 64.f, ScreenFullWidth, ScreenFullHeight-64.f - 46.f)
                                                        kdRefreshTableViewType:KDRefreshTableViewType_Both
                                                                         style:UITableViewStylePlain];
    
    aTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:aTableView];
    aTableView.dataSource = self;
    aTableView.delegate = self;
    aTableView.backgroundColor = RGBCOLOR(237, 237, 237);
    aTableView.backgroundView = nil;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView = aTableView;
    self.tableView.scrollsToTop = YES;
//    [aTableView release];
    
    activityView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityView_.frame = CGRectMake(210, 384, 20, 20);
	activityView_.hidesWhenStopped = YES;
	[self.view addSubview:activityView_];
    
    frame = CGRectMake(0.0, self.view.bounds.size.height - 46.0, self.view.bounds.size.width, 46.0f);
    
    NSDictionary *createStatusItem = @{@"title":ASLocalizedString(@"PostViewController_Edit_weibo"),@"image":[UIImage imageNamed:@"bottom_tool_bar_write"]};
    NSDictionary *favoriteItem = @{@"title":ASLocalizedString(@"KDMainTimelineViewController_follow"),@"image":[UIImage imageNamed:@"topic_favorite"]};
    
    self.toolbarItems = @[createStatusItem,favoriteItem];
    KDMenuView *menu = [[KDMenuView alloc] initWithFrame:frame delegate:self images:toolbarItems_];
    self.menuView = menu;
//    [menu release];
    
    UIImage *image =[UIImage stretchableImageWithImageName:@"bottom_bg.png"
                               resizableImageWithCapInsets:UIEdgeInsetsMake(10, 5, 10, 5)];
    [menuView_ setBackgroundImage:image];
    menuView_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:menuView_];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    //KD_RELEASE_SAFELY(menuView_);
    //KD_RELEASE_SAFELY(tableView_);
    
    //KD_RELEASE_SAFELY(activityView_);
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(timelineProvider_);
    //KD_RELEASE_SAFELY(statusDataset_);
    
    //KD_RELEASE_SAFELY(topic_);
    
    //KD_RELEASE_SAFELY(selectedIndexPath_);
    //KD_RELEASE_SAFELY(selectedStatus_);
    //KD_RELEASE_SAFELY(topicStatus_);
    
    //KD_RELEASE_SAFELY(menuView_);
    //KD_RELEASE_SAFELY(tableView_);
    
    //KD_RELEASE_SAFELY(activityView_);
    
    //KD_RELEASE_SAFELY(cellCache_);
    //KD_RELEASE_SAFELY(toolbarItems_);
    
    //[super dealloc];
}


- (void)getTopicMessage:(BOOL)isLoadMore {
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"trend_name" stringValue:topic_.name]
            setParameter:@"count" stringValue:@"20"];
    
    if(isLoadMore) {
        [query setParameter:@"page" integerValue:pageCursor_];
    }
    
    if (topicStatus_ != nil && topicStatus_.groupId != nil) {
        [query setParameter:@"group_id" stringValue:topicStatus_.groupId];
    }
    
    __block TrendStatusViewController *tsvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results != nil) {
            NSArray *statuses = results;
            
            for (KDStatus *obj in statuses) {
                KDLayouter * layouter =   [KDStatusLayouter  statusLayouter:obj constrainedWidth:self.view.bounds.size.width - 16];
                KDLayouterView * layouterView = [layouter view];
                KDStatusCell * cell = [[KDStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];// autorelease];
                [cell addSubview:layouterView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                layouterView.layouter = layouter;
                [self.cellCache setObject:cell forKey:[(KDStatus *)obj statusId] cost:1];
            }

            if(tsvc.statusDataset == nil) {
                tsvc.statusDataset = [[KDStatusDataset alloc] init];// autorelease];
            }
            
            if ([statuses count] > 0) {
                [tsvc.statusDataset mergeStatuses:statuses atHead:!isLoadMore];
            }
            
            if(isLoadMore)
                tsvc->pageCursor_ = tsvc->pageCursor_ + 1;
            
            if([(NSArray *)results count] < 20) {
                [tsvc.tableView setBottomViewHidden:YES];
            }
            
            [tsvc.tableView reloadData];
        }
        
        if(!isLoadMore) {
            [tsvc.tableView setBottomViewHidden:NO];
            [tsvc dataSourceDidFinishLoadingNewData];
        } else {
            [tsvc.tableView finishedLoadMore];
        }
        
        
        // release current view controller
//        [tsvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/trends/:statuses" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)toggleFav:(BOOL)isFavotied {
    if (isFavotied != favotited_) {
        favotited_ = isFavotied;
        UIButton *favButton = (UIButton *)[[menuView_.menuItems objectAtIndex:1] customView];
        favButton.selected = favotited_;
    }
   
}
-(void)setFavotitedButtonSelected:(BOOL)isSelected{
    UIButton *favButton = (UIButton *)[[menuView_.menuItems objectAtIndex:1] customView];
    favButton.selected = isSelected;
}
- (void)topicSend:(id)sender {
    KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
    PostViewController *pvc = [factory getPostViewController];
    pvc.isSelectRange = YES;
    
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeNewStatus];
    draft.content = [NSString stringWithFormat:@"#%@#", topic_.name];
    
    if (topicStatus_ != nil && topicStatus_.groupId != nil) {
        draft.groupId = topicStatus_.groupId;
    }
    pvc.draft = draft;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pvc];// autorelease];
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:nav animated:YES completion:nil];;
    }else {
        [self presentViewController:nav animated:YES completion:nil];
    }
}
- (void)_toggleFollowResponse:(KDResponseWrapper *)response results:(id)results follow:(BOOL)isFollow {
    if (results != nil && [(NSNumber *)results boolValue]) {
        favotited_ = !favotited_;
        
        if(favotited_) {
            [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
                id<KDTopicDAO> topicDAO = [[KDWeiboDAOManager globalWeiboDAOManager] topicDAO];
                [topicDAO saveTopic:self.topic database:fmdb];
            }completionBlock:nil];
        }else {
            [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
                id<KDTopicDAO> topicDAO = [[KDWeiboDAOManager globalWeiboDAOManager] topicDAO];
                [topicDAO removeTopic:self.topic database:fmdb];
            }completionBlock:nil];
        }
        
        [self toggleFav:favotited_];
        
    } else {
        if (![response isCancelled]) {
        }
    }
}


#pragma mark - Database Method

-(void)saveTopicToDB:(KDTopic * )topic{
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
        id<KDTopicDAO> topicDAO = [[KDWeiboDAOManager globalWeiboDAOManager] topicDAO];
        [topicDAO saveTopic:topic database:fmdb];
    }completionBlock:nil];
}
-(void)deleteTopicFromDB:(KDTopic *)topic{
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
        id<KDTopicDAO> topicDAO = [[KDWeiboDAOManager globalWeiboDAOManager] topicDAO];
        [topicDAO removeTopic:topic database:fmdb];
    }completionBlock:nil];
    
    
    
}
#pragma mark -  Request Data From Service
-(void)confirmHasFollowFromServers{
    KDQuery *query = [KDQuery queryWithName:@"trend_name" value:topic_.name];
    
    __block TrendStatusViewController *tsvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results) {
            NSDictionary * resultsDic = results;
            BOOL isFavorited = [resultsDic boolForKey:@"result"];
            tsvc.topic.topicId = resultsDic[@"topicid"];
     
            [tsvc toggleFav:isFavorited];
    
            if (isFavorited) {
                [tsvc saveTopicToDB:tsvc.topic];
            }
            else{
                [tsvc deleteTopicFromDB:tsvc.topic];
            }
        }
//        [tsvc release];
    };
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/trends/:has_followed" query:query
                                 configBlock:nil completionBlock:completionBlock];
}
- (void)followTrend {
    KDQuery *query = [KDQuery queryWithName:@"trend_name" value:topic_.name];
    
    __block TrendStatusViewController *tsvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
//        [tsvc _toggleFollowResponse:response results:results follow:YES];
        if (results) {
            NSDictionary * resultsDic = results;
            BOOL isFavorited = [resultsDic boolForKey:@"result"];
            tsvc.topic.topicId = resultsDic[@"topicid"];
            
            [tsvc toggleFav:isFavorited];
            
            if (isFavorited) {
                [tsvc saveTopicToDB:tsvc.topic];
            }
            else{
                [tsvc deleteTopicFromDB:tsvc.topic];
            }
        }
//        [tsvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/trends/:follow" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)destoryFollowTrend {
    KDQuery *query = [KDQuery queryWithName:@"trend_id" value:topic_.topicId];
    //KDQuery *query = [KDQuery queryWithName:@"trend_name" value:topic_.name];
    __block TrendStatusViewController *tsvc = self ;//retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        BOOL isSuccesed = [results boolValue];
        if (isSuccesed) {
            [tsvc toggleFav:NO];
            [tsvc deleteTopicFromDB:tsvc.topic];
        }
//        [tsvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/trends/:destroy" query:query
                                 configBlock:nil completionBlock:completionBlock];
}
- (void)favTopic:(id)sender {
    if (favotited_) {
        [self destoryFollowTrend];
        
    } else {
        [self followTrend];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [statusDataset_ count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDStatus *status = [statusDataset_ statusAtIndex:indexPath.row];
    //return [timelineProvider_ calculateStatusContentHeight:status inTableView:tableView];
  
    KDStatusLayouter *layouter = [KDStatusLayouter  statusLayouter:status constrainedWidth:tableView.bounds.size.width - 16.0f];
    return layouter.frame.size.height + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDStatus *status = [statusDataset_ statusAtIndex:indexPath.row];
//    
//    if (![status propertyForKey:@"showLike"]) {
//        [status setProperty:@(YES) forKey:@"showLike"];
//    }
//    
//    return [timelineProvider_ timelineStatusCellInTableView:tableView status:status];
    KDStatusCell *cell = [self.cellCache objectForKey:status.statusId];
    if (!cell) {
        KDStatusLayouter *layouter = [KDStatusLayouter statusLayouter:status constrainedWidth:0];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KDStatus *sts = [statusDataset_ statusAtIndex:indexPath.row];
    self.selectedStatus = sts;
    self.selectedIndexPath = indexPath;
    
    KDStatusDetailViewController* tvc = [[KDStatusDetailViewController alloc] initWithStatus:sts];
    [self.navigationController pushViewController:tvc animated:TRUE];
//    [tvc release];
}

- (void)toggleactivityView_:(BOOL)animation {
    if (animation) {
        [activityView_ startAnimating];        
    
    } else {
	    [activityView_ stopAnimating];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[tableView_ kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [tableView_ kdRefreshTableviewDidEndDraging:scrollView];
    
    if(!decelerate){
        [KDStatusCell loadImagesForVisibleCellsIfNeed:(UITableView *)scrollView];
    }
}

- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView {
    [self getTopicMessage:NO];
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    [self getTopicMessage:YES];
}

#pragma mark - KDRefreshTableViewDataSource method

KDREFRESHTABLEVIEW_REFRESHDATE

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [KDStatusCell loadImagesForVisibleCellsIfNeed:(UITableView *)scrollView];
}

- (void)dataSourceDidFinishLoadingNewData{
    [tableView_ finishedRefresh:YES];
}

- (void)beginGetTimeline {
	[tableView_ setFirstInLoadingState];
    [self getTopicMessage:NO];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [statusDataset_ removeStatus:selectedStatus_];
    
    NSArray *indexPaths = [NSArray arrayWithObject:selectedIndexPath_];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
}

#pragma mark KDMenu delegate
- (void)menuView:(KDMenuView *)menuView configMenuButton:(UIButton *)button atIndex:(NSUInteger)index {
    
    NSString *hlImageName = nil;
    NSString *selectedImageName = nil;
    NSString *title = [[self.toolbarItems objectAtIndex:index] objectForKey:@"title"];
    if (index == 0) {
        hlImageName = @"bottom_tool_bar_write_hl";
        
    }else if (index == 1) {
        selectedImageName = @"topic_favorite_hl";
        [button setTitle:ASLocalizedString(@"KDMainTimelineViewController_followed") forState:UIControlStateSelected];
    }
    if (hlImageName) {
        UIImage *image = [UIImage imageNamed:hlImageName];
        [button setImage:image forState:UIControlStateHighlighted];
    }
    if (selectedImageName) {
        UIImage *image = [UIImage imageNamed:selectedImageName];
        [button setImage:image forState:UIControlStateSelected];
    }
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x7b7b7b) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
   
}

- (void)menuView:(KDMenuView *)menuView clickedMenuItemAtIndex:(NSInteger)index {
    if(index == 0)
        [self topicSend:nil];
    else if(index == 1){
        [self favTopic:nil];
    }
    
}

- (NSCache *)cellCache {
    if (!cellCache_) {
        cellCache_ = [[NSCache alloc] init];
        cellCache_.totalCostLimit = 500;
    }
    return cellCache_;
}
//////////////////////////////////////////////////////////////////////

// Override (UIViewController category)
- (void)viewControllerWillDismiss {
   
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}



@end
