//
//  KDTrendsViewController.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDTrendsViewController.h"
#import "TrendStatusViewController.h"
#import "KDNotificationView.h"
#import "ProfileViewController.h"
#import "UIViewController+Navigation.h"
#import <objc/runtime.h>
#import "KDDatabaseHelper.h"

#import "KDUser.h"
#import "KDTopic.h"

#import "KDRequestDispatcher.h"

#import "KDWeiboAppDelegate.h"

#import "UILabel+Additions.h"
#import "SINavigationMenuView.h"

#import "KDTableViewCell.h"

#import "ResourceManager.h"

@interface KDTrendsViewController ()<SINavigationMenuDelegate>

@property (nonatomic, retain) NSArray *trends;
@property (nonatomic, retain) NSArray *recentlyTrends;

@property (nonatomic, retain) UITableView *tableView;

@end


@implementation KDTrendsViewController

@synthesize type=type_;
@synthesize user=user_;

@synthesize trends=trends_;
@synthesize recentlyTrends=recentlyTrends_;

@synthesize tableView=tableView_;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"TRENDS", @"");
        
        type_ = KDTrendsViewControllerTypePublic;
        contentType_ = KDTrendsViewControllerContentTypeHot;
        user_ = nil;
        
        trends_ = nil;
        recentlyTrends_ = nil;
        
        tableView_ = nil;
        
        reloading_ = NO;
        
        pageCursor_ = 2;
        
        trendsViewControllerFlags_.initilization = 1;
        trendsViewControllerFlags_.presentingSubViewController = 0;
    }
    
    return self;
}

- (id)initWithTrendsType:(KDTrendsViewControllerType)type {
    self = [self initWithNibName:nil bundle:nil];
    if(self){
        type_ = type;
    }
    
    return self;
}

//- (void)getInputParameter {
//    id para = objc_getAssociatedObject(self, "extrainfo");
//    if(para) {
//        NSInteger i = [para integerValue];
//        if(i == 1) {
//            contentType_ = KDTrendsViewControllerContentTypeHot;
//            self.navigationItem.title = NSLocalizedString(@"TRENDS_WEEKLY", @"");
//        }else if(i == 2) {
//            contentType_ = KDTrendsViewControllerContentTypeNew;
//            self.navigationItem.title = NSLocalizedString(@"TRENDS_RECENTLY", @"");
//        }
//    }
//}

- (void)setNavTitle {
    if (contentType_ ==  KDTrendsViewControllerContentTypeHot) {
        self.title = ASLocalizedString(@"TRENDS_WEEKLY");
    }else if (contentType_ ==  KDTrendsViewControllerContentTypeNew) {
         self.title = NSLocalizedString(@"TRENDS_RECENTLY", @"");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setClipsToBounds:YES];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];//RGBCOLOR(237, 237, 237);
    
    CGRect frame = CGRectZero;

//    if(KDTrendsViewControllerTypePublic == type_) {
//        [self getInputParameter];
//    }
    
    // table view
    [self setNavTitle];
    KDRefreshTableViewType type = 0;
    if(user_)
        type = KDRefreshTableViewType_Both;
    else
        type = KDRefreshTableViewType_Header;
    CGRect rect = self.view.bounds;
    rect.origin.y += kd_StatusBarAndNaviHeight;
    rect.size.height -= kd_StatusBarAndNaviHeight;
    KDRefreshTableView *tableView = [[KDRefreshTableView alloc] initWithFrame:rect kdRefreshTableViewType:type];
    self.tableView = tableView;
//    [tableView release];
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:tableView_];
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    // add placeholder label at bottom of table
    frame = CGRectMake(0.0, 0.0, tableView_.frame.size.width, 40.0);
    self.tableView.tableFooterView = [UILabel infoLabelForTableFooterView:frame];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (@available(iOS 11.0, *)) {
        tableView_.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

//- (void)setupMenuView
//{
//    if(self.navigationItem) {
//        NSString *title = nil;
//        NSArray *items = nil;
//        if (contentType_ == KDTrendsViewControllerContentTypeHot ) {
//            title = NSLocalizedString(@"TRENDS_WEEKLY", nil);
//           items =  @[NSLocalizedString(@"TRENDS_WEEKLY", nil), NSLocalizedString(@"TRENDS_RECENTLY", nil)];
//        }else if(contentType_ == KDTrendsViewControllerContentTypeNew) {
//              title = NSLocalizedString(@"TRENDS_RECENTLY", nil);
//            items =  @[NSLocalizedString(@"TRENDS_RECENTLY", nil), NSLocalizedString(@"TRENDS_WEEKLY", nil)];
//
//        }
//        if (title && items) {
//            SINavigationMenuView *menuView = [[SINavigationMenuView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, self.navigationController.navigationBar.bounds.size.height) title:title];
//            menuView.items = items;
//            menuView.delegate = self;
//            [menuView displayMenuInView:self.view];
//            self.navigationItem.titleView = menuView;
//            [menuView release];
//
//        }
//    }
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self setupMenuView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(trendsViewControllerFlags_.presentingSubViewController == 1){
        trendsViewControllerFlags_.presentingSubViewController = 0;
    }
    
    if(KDTrendsViewControllerTypePublic == type_ && trendsViewControllerFlags_.initilization == 1){
        trendsViewControllerFlags_.initilization = 0;
        //[self setupMenuView];
        [tableView_ setFirstInLoadingState];
        if(user_) {
            [self  loadTrendsForUser];
        } else {
            [self loadPublicTrends];
        }
    }
}

- (BOOL)isRecentlyTrends {
     return KDTrendsViewControllerTypePublic == type_ && contentType_ == KDTrendsViewControllerContentTypeNew;
}

- (NSArray *)trendsDataSource {
    return [self isRecentlyTrends] ? recentlyTrends_ : trends_;
}

- (NSInteger)numberOfTrends {
    NSArray *dataSource = [self isRecentlyTrends] ? recentlyTrends_ : trends_;
    return (dataSource != nil) ? [dataSource count] : 0;
}

//////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark DataBase Method
//添加从数据读取缓存的方法
-(void)fetchDataFromDB{
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
        id<KDTopicDAO> topicDAO = [[KDWeiboDAOManager globalWeiboDAOManager] topicDAO];
        return  [topicDAO queryTopic_database:fmdb];
    }completionBlock:^(id results) {
        [tableView_ finishedRefresh:YES];
        if (results != nil && [(NSArray *)results count]) {
            NSArray * resultArray = results;
            self.trends = resultArray;
            [self->tableView_ reloadData];
        }
    }];

}
-(void)saveDataToDB:(NSArray * )array{
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
        id<KDTopicDAO> topicDAO = [[KDWeiboDAOManager globalWeiboDAOManager] topicDAO];
        [topicDAO saveTopics:array database:fmdb];
    }completionBlock:nil];

}

//////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfTrends];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = RGBCOLOR(250, 250, 250);
        cell.backgroundView = nil;
        cell.contentView.backgroundColor = RGBCOLOR(250, 250, 250);
//      ／  cell.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 10.0f, 5.0f, 10.0f);
        cell.layer.borderColor = RGBCOLOR(203, 203, 203).CGColor;
        cell.layer.borderWidth = 0.5f;
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        //cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        UIView *selectBgView = [[UIView alloc] initWithFrame:CGRectZero] ;//autorelease];
        selectBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        selectBgView.backgroundColor = RGBCOLOR(240, 241, 242);
        cell.selectedBackgroundView = selectBgView;
    }
    
    KDTopic *topic = [[self trendsDataSource] objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"#%@#", topic.name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = RGBCOLOR(250, 250, 250);
    cell.contentView.backgroundColor = RGBCOLOR(250, 250, 250);
    cell.backgroundView = nil;
    cell.accessoryView.backgroundColor = RGBCOLOR(250, 250, 250);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView_ deselectRowAtIndexPath:indexPath animated:YES];
    
    trendsViewControllerFlags_.presentingSubViewController = 1;
    
    KDTopic *topic = [[self trendsDataSource] objectAtIndex:indexPath.row]; 
    
    // If this class use in ProfileViewController class, The segment code at below will not works,
    // Because the self.navigationController is nil and the reason is this class treat as a view not
    // a view controller, This is a bad solution, please fix it in the future
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
    
    TrendStatusViewController *tsvc = [[TrendStatusViewController alloc] initWithTopic:topic];
    [nc pushViewController:tsvc animated:YES];                
//    [tsvc release];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [tableView_ kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [tableView_ kdRefreshTableviewDidEndDraging:scrollView];
}

- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView {
    if(user_ != nil) {
        [self loadTrendsForUser];
    } else {
        [self loadPublicTrends];
    }
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    [self loadTrends:user_.userId isLoadMore:YES];
}

#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE

////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Csutom methods

- (void)didFinishLoadTrends:(BOOL)canceled {
    reloading_ = NO;
    
    if(!canceled){
        [tableView_ finishedRefresh:YES];
        
        [tableView_ reloadData];
    }
}

- (void)loadTrendsForUser {
    [self loadTrends:user_.userId isLoadMore:NO];
}

- (void)loadPublicTrends {
    [self loadTrends:nil isLoadMore:NO];
}

- (void)loadTrends:(NSString *)userId isLoadMore:(BOOL)isLoadMore{
    KDQuery *query = [KDQuery query];
    
    NSString *actionPath = nil;
    if(userId != nil){
        [query setParameter:@"user_id" stringValue:userId];
        actionPath = @"/trends/:trends";
        
        if(isLoadMore) {
            [query setParameter:@"page" integerValue:pageCursor_];
        }
    }else {
        actionPath = (contentType_ == KDTrendsViewControllerContentTypeHot) ? @"/trends/:recently" : @"/trends/:recently";
    }
    
    
    __block KDTrendsViewController *tvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if (results != nil) {
                if ([tvc isRecentlyTrends]) {
                    tvc.recentlyTrends = results;
                    
                } else {
                    if(userId) {
                        NSMutableArray *temp = [NSMutableArray arrayWithArray:tvc.trends];
                        if(isLoadMore) {
                            [temp addObjectsFromArray:(NSArray *)results];
                        } else {
                            for(KDTopic *topic in (NSArray *)results) {
                                for(KDTopic *tc in temp) {
                                    if([tc.topicId isEqualToString:topic.topicId]) {
                                        [temp removeObject:tc];
                                        break;
                                    }
                                }
                            }
                            
                            [temp insertObjects:(NSArray *)results atIndexes:[NSIndexSet indexSetWithIndexesInRange:(NSRange){0, [(NSArray *)results count]}]];
                        }
                        
                        tvc.trends = temp;

                    } else {
                        tvc.trends = results;
                    }
                }
                
                if(userId) {
                    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
                        id<KDTopicDAO> topicDAO = [[KDWeiboDAOManager globalWeiboDAOManager] topicDAO];
                        [topicDAO saveTopics:results database:fmdb];
                    }completionBlock:NULL];
                }
                
                if(isLoadMore && userId) {
                    [tvc->tableView_ setBottomViewHidden:YES];
                    tvc->pageCursor_ = tvc->pageCursor_ + 1;
                }
            }
        }
        
        [tvc showTipsOrNot];
        
        if(!isLoadMore) {
            [tvc didFinishLoadTrends:[response isCancelled]];
        } else {
            [tvc->tableView_ finishedLoadMore];
            [tvc->tableView_ reloadData];
        }
//        [tvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)viewControllerWillDismiss {
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

- (void)showTipsOrNot {
    if ([self numberOfTrends] <= 0) {
        UIView *blankView = [ResourceManager noDataPromptView];
        blankView.frame = self.tableView.bounds;
        self.tableView.tableFooterView = blankView;
    } else {
        self.tableView.tableFooterView = nil;
    }
}

////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDUserDataLoader delegate method

- (void)loadUserData {
    if(trends_ == nil && !reloading_ && trendsViewControllerFlags_.initilization == 1) {
        [tableView_ setFirstInLoadingState];
        //调用从数据读取缓存的方法 --- 黄伟彬
        [self fetchDataFromDB];
        [self loadTrendsForUser];
        trendsViewControllerFlags_.initilization = 0;
	}
}

//#pragma mark - SINavigationMenuDelegate methods
//- (void)didSelectItemAtIndex:(NSUInteger)index
//{
////    if(index == 0) {
////        if(contentType_ == KDTrendsViewControllerContentTypeNew) {
////            
////        }
////        contentType_ = KDTrendsViewControllerContentTypeNew;
////    }else if(index == 1) {
////        contentType_ = KDTrendsViewControllerContentTypeHot;
////    }
//    SINavigationMenuView *menuView = (SINavigationMenuView *)self.navigationItem.titleView;
//    NSString *title = menuView.items[index];
//    if ([title isEqualToString:NSLocalizedString(@"TRENDS_WEEKLY", @"")]) {
//         contentType_ = KDTrendsViewControllerContentTypeHot;
//    }
//    else if ([title isEqualToString:NSLocalizedString(@"TRENDS_RECENTLY", @"")]) {
//        contentType_ = KDTrendsViewControllerContentTypeNew;
//    }
//    [tableView_ setFirstInLoadingState];
//    [self loadPublicTrends];
//}

////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDMenuView delegate methods

- (void) viewDidUnload {
    [super viewDidUnload];
    
    //KD_RELEASE_SAFELY(tableView_);
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(user_);
    //KD_RELEASE_SAFELY(trends_);
    //KD_RELEASE_SAFELY(recentlyTrends_);
    
    //KD_RELEASE_SAFELY(tableView_);
    
    //[super dealloc];
}

@end
