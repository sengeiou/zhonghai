//
//  KDSearchViewController.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-16.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDSearchViewController.h"

#import "KDActivityIndicatorView.h"
#import "KDNetworkUserBaseCell.h"
#import "KDNotificationView.h"
#import "KDErrorDisplayView.h"

#import "KDStatus.h"
#import "KDTopic.h"
#import "KDUser.h"
#import "KDStatusTimelineProvider.h"

#import "KDRequestDispatcher.h"
#import "KDRequestWrapper.h"

#import "KDWeiboServicesContext.h"
#import "KDDefaultViewControllerContext.h"

#define KD_MAX_SEARCH_ITEM_COUNT_PER_PAGE   20


@interface KDSearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, KDRequestWrapperDelegate> 

@property (nonatomic, retain) NSMutableArray *statuses;
@property (nonatomic, retain) NSMutableArray *hits;

@property(nonatomic, retain) KDStatusTimelineProvider *timelineProvider;
@property(nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UILabel *infoLabel;
@property (nonatomic, retain) KDActivityIndicatorView *activityView;

@end


@implementation KDSearchViewController {
 @private
//    id<KDSearchViewControllerDelegate> delegate_;
    KDSearchMaskType searchMaskType_;
    
    NSUInteger currentPage_;
    NSString *keywords_;
    
    NSMutableArray *statuses_;
    NSMutableArray *hits_; // may be KDUser / Topic Text
    
    KDStatusTimelineProvider *timelineProvider_;
    
    UISearchBar *searchBar_;
    UITableView *tableView_;
    UILabel *infoLabel_;
    KDActivityIndicatorView *activityView_;
    
    UIButton *moreButton_; // weak reference
    
    struct {
        unsigned int hasRequests:1;
        unsigned int backToPrevious:1;
        unsigned int initialized:1;
        
    }searchViewControllerFlags_; 
}

@synthesize delegate=delegate_;
@synthesize searchMaskType=searchMaskType_;

@synthesize keywords=keywords_;
@synthesize currentPage=currentPage_;

@synthesize statuses=statuses_;
@synthesize hits=hits_;
@synthesize timelineProvider=timelineProvider_;

@synthesize searchBar=searchBar_;
@synthesize tableView=tableView_;
@synthesize infoLabel=infoLabel_;
@synthesize activityView=activityView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        searchMaskType_ = KDSearchMaskTypeNone;
        currentPage_ = 1;
        
        timelineProvider_ = [[KDStatusTimelineProvider alloc] initWithViewController:self];
        
        searchViewControllerFlags_.hasRequests = 0;
        searchViewControllerFlags_.backToPrevious = 1;
        searchViewControllerFlags_.initialized = 0;
        
        self.navigationItem.title = ASLocalizedString(@"KDSearchBar_Search");
    }
    
    return self;
}

- (id)initWithSearchMaskType:(KDSearchMaskType)searchMaskType {
    self = [self initWithNibName:nil bundle:nil];
    if(self){
        searchMaskType_ = searchMaskType;
    }
    
    return self;
}

- (void)loadView {
    UIView *aView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = aView;
//    [aView release];

    self.view.backgroundColor = UIColorFromRGB(0xF0F0F0);
    
    NSUInteger searchAll = [self isSearchAll];
    
    // search bar
    CGFloat height = searchAll ? 90.0 : 40.0;
    CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, height);
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:frame];
    self.searchBar = searchBar;
//    [searchBar release];
    
    searchBar_.delegate = self;
    searchBar_.tintColor = RGBCOLOR(165.0, 174.0, 188.0);
    searchBar_.placeholder = ASLocalizedString(@"KDSearchBar_Search");
    
    // enter sub view controller and did recieve memory warning,
    // set the keywords to search bar
    searchBar_.text = (keywords_ != nil) ? keywords_ : nil;
    
    searchBar_.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    if(searchAll){
        searchBar_.scopeButtonTitles = [NSArray arrayWithObjects:NSLocalizedString(@"SEARCH_STATUSES", @""), 
                                                                  NSLocalizedString(@"SEARCH_USERS", @""), nil];
        searchBar_.showsScopeBar = YES;
        
        if([searchBar_ respondsToSelector:@selector(setScopeBarButtonTitleTextAttributes:forState:)]){
            NSDictionary *normalInfo = [NSDictionary dictionaryWithObjectsAndKeys:RGBCOLOR(63.0, 92.0, 132.0), UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, nil];
            
            NSDictionary *selectedInfo = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,
                                          [UIColor darkGrayColor], UITextAttributeTextShadowColor, nil];
            
            [searchBar_ setScopeBarButtonTitleTextAttributes:normalInfo forState:UIControlStateNormal];
            [searchBar_ setScopeBarButtonTitleTextAttributes:selectedInfo forState:UIControlStateSelected];
        }
    }
    
    searchBar_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:searchBar_];
    
    // table view
    frame.origin.y = frame.origin.y + frame.size.height;
    frame.size.height = self.view.bounds.size.height - frame.origin.y;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView = tableView;
//    [tableView release];
    
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.backgroundColor = [UIColor clearColor];
    tableView_.separatorStyle = ([self isSearchTrends]) ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
    
    // disable right bar button item if not search all
    if(!searchAll){
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self setBackItem];
}

- (void)setBackItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"nav_bar_back_btn_bg.png"];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    NSArray *controllers = [self.navigationController viewControllers];
//    
//    //上一个
//    UIViewController *lastViewController = [controllers objectAtIndex:controllers.count - 2];
//    [back setTitle:lastViewController.title];
    

    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //2013-12-26 song.wang
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];// autorelease];
    negativeSpacer.width = kLeftNegativeSpacerWidth;
    self.navigationItem.leftBarButtonItems = [NSArray
                                              arrayWithObjects:negativeSpacer,back, nil];
//    [back release];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // reset flags
    if(searchViewControllerFlags_.backToPrevious == 0){
       searchViewControllerFlags_.backToPrevious = 1;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(searchViewControllerFlags_.initialized == 0){
        searchViewControllerFlags_.initialized = 1;
        
        if(keywords_ != nil && ([self isSearchUsers] || [self isSearchTrends])){
            [self search:keywords_ isLoadMore:NO];
        }
    }
}


//////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *source = [self dataSource];
    return (source != nil) ? [source count] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0;
    if([self isSearchUsers]){
        height = 56.0;
        
    }else if([self isSearchStatuses]){
        KDStatus *status = [statuses_ objectAtIndex:indexPath.row];
        return [timelineProvider_ calculateStatusContentHeight:status inTableView:tableView];
        
    }else if([self isSearchTrends]){
        height = 44.0;
    }
    
	return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self isSearchUsers]){
        static NSString *UserCellIdentifier = @"UserCell";
        KDNetworkUserBaseCell *cell = (KDNetworkUserBaseCell *)[tableView dequeueReusableCellWithIdentifier:UserCellIdentifier];
        if(cell == nil){
            cell = [[KDNetworkUserBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserCellIdentifier];// autorelease];
            cell.allowedShowUserProfile = (KDSearchMaskTypeUsers == searchMaskType_) ? NO : YES;
        }
        
        cell.user = [hits_ objectAtIndex:indexPath.row];
        [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:cell.avatarView];
        
        return cell;
        
    }else if ([self isSearchStatuses]) {
        KDStatus *status = [statuses_ objectAtIndex:indexPath.row];
        return [timelineProvider_ timelineStatusCellInTableView:tableView status:status];
        
    }else if ([self isSearchTrends]) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.minimumScaleFactor = 12;
            cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle; 
        }
        
        KDTopic *topic = [hits_ objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"#%@#", topic.name];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(KDSearchMaskTypeUsers == searchMaskType_){
        // only search user
        if(delegate_ != nil && [delegate_ respondsToSelector:@selector(searchViewController:didSelectUser:)]){
            KDUser *user = [hits_ objectAtIndex:indexPath.row];
            [delegate_ searchViewController:self didSelectUser:user];
        }
        
    }else if([self isSearchAll]){
        if([self isSearchStatuses]){
            
            // TODO: xxx please change status details view controller
            
            
        }else {
            KDUser *user = [hits_ objectAtIndex:indexPath.row];
            [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:user sender:tableView];
        }
    
    }else if([self isSearchTrends]){
        if(delegate_ != nil && [delegate_ respondsToSelector:@selector(searchViewController:didSelectTopicText:)]){
            KDTopic *topic = [hits_ objectAtIndex:indexPath.row];
            [delegate_ searchViewController:self didSelectTopicText:topic.name];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if(!decelerate){
        [self _loadImageSourceIfNeed];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _loadImageSourceIfNeed];
}

- (void)_loadImageSourceIfNeed {
    if ([self isSearchUsers]) {
        // user avatar
        [KDAvatarView loadImageSourceForTableView:tableView_];
        
    } else if ([self isSearchStatuses]) {
        [timelineProvider_ loadImageSourceInTableView:self.tableView];
    }
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UISearchBar delegate methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if([searchBar canResignFirstResponder]){
        [searchBar resignFirstResponder];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // reset page number before start new sreach
    currentPage_ = 1;
    [self clearDataSource:[self dataSource]];
    
    self.keywords = searchBar.text;
    [self search:keywords_ isLoadMore:NO];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    // cancel exist requests if need
    [self cancelRequets];
    
    currentPage_ = 1;
    
    // clear the data source before switch to another scope
    NSMutableArray *source = ([self isSearchStatuses]) ? hits_ : statuses_;
    [self clearDataSource:source];
    
    // retrive the hits for keywords if need
    self.keywords = searchBar.text;
    [self search:keywords_ isLoadMore:NO];
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (void)activityViewWithVisible:(BOOL)visible {
    if(activityView_ == nil){
        CGRect rect = CGRectMake((self.view.bounds.size.width - 120.0) * 0.5, (self.view.bounds.size.height - 80.0) * 0.5, 120.0, 80.0);
        activityView_ = [[KDActivityIndicatorView alloc] initWithFrame:rect];
        activityView_.alpha = 0.0;
        
        [self.view addSubview:activityView_];
    }
    
    if (visible) {
        [activityView_ show:YES info:ASLocalizedString(@"RecommendViewController_Load")];
        
    } else {
        [activityView_ hide:YES];
    }
}

- (void)toggleMoreButtonEnabled:(BOOL)enabled isLoading:(BOOL)loading {
    if (moreButton_ != nil) {
        NSString *btnTitle = loading ? ASLocalizedString(@"RecommendViewController_Load") :  ASLocalizedString(@"KDPlaceAroundTableView_More");
        [moreButton_ setTitle:btnTitle forState:UIControlStateNormal];
        
        moreButton_.enabled = enabled;
    }
}

- (void)setMoreButtonActive:(BOOL)active {
    if(active){
        if(tableView_.tableFooterView == nil){
            // footer view
            CGRect frame = CGRectMake(0.0, 0.0, tableView_.bounds.size.width, 54.0);
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
            
            [moreBtn addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
            
            moreBtn.enabled = NO;
            [footerView addSubview:moreBtn];
            
            footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            tableView_.tableFooterView = footerView;
//            [footerView release];
        }
        
        [self toggleMoreButtonEnabled:YES isLoading:NO];
        
    } else {
        moreButton_ = nil;
        tableView_.tableFooterView = nil;
    }
}

- (void)loadMore:(UIButton *)btn {
    [self search:keywords_ isLoadMore:YES];
}

- (NSString *)emptyDataMessage {
    NSString *message = nil;
    if([self isSearchStatuses]){
        message = NSLocalizedString(@"SEARCH_NO_MATCHED_STATUS", @"");
        
    }else if([self isSearchUsers]){
        message = ASLocalizedString(@"SEARCH_NO_MATCHED_USER");
        
    }else if([self isSearchTrends]){
        message = ASLocalizedString(@"NO_DATA_TASK_DISSCUSS");
    }
    
    return message;
}

- (void)infoLabelWithVisible:(BOOL)visible {
    if(infoLabel_ == nil){
        // info label
        CGRect rect = CGRectMake(0.0, tableView_.frame.origin.y, self.view.bounds.size.width, 40.0);
        infoLabel_ = [[UILabel alloc] initWithFrame:rect];
        
        infoLabel_.backgroundColor = [UIColor clearColor];
        infoLabel_.textColor = [UIColor grayColor];
        infoLabel_.font = [UIFont systemFontOfSize:15.0];
        infoLabel_.lineBreakMode = NSLineBreakByTruncatingTail;
        infoLabel_.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:infoLabel_];
    }
    
    infoLabel_.hidden = visible ? NO : YES;
    if(visible){
        infoLabel_.text = [self emptyDataMessage];
        
        [self.view bringSubviewToFront:infoLabel_];
        
        if([self isSearchTrends]){
            tableView_.scrollEnabled = NO;
            tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        
    }else {
        [self.view sendSubviewToBack:infoLabel_];
        
        if([self isSearchTrends]){
            tableView_.scrollEnabled = YES;
            tableView_.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
    }
}

- (BOOL)isSearchStatuses {
    return ([self isSearchAll] && searchBar_.selectedScopeButtonIndex == 0x00);
}

- (BOOL)isSearchUsers {
    return (searchMaskType_ == KDSearchMaskTypeUsers) 
            || ([self isSearchAll] && searchBar_.selectedScopeButtonIndex == 0x01);
}

- (BOOL)isSearchTrends {
    return searchMaskType_ == KDSearchMaskTypeTrends;
}

- (BOOL)isSearchAll {
    return (KDSearchMaskTypeUsers|KDSearchMaskTypeStatuses) == searchMaskType_;
}

- (NSMutableArray *)dataSource {
    return ([self isSearchStatuses]) ? statuses_ : hits_;
}

- (void)clearDataSource:(NSMutableArray *)dataSource {
    [self setMoreButtonActive:NO];
    
    if(dataSource != nil && [dataSource count] > 0) {
        [dataSource removeAllObjects];
        
        [tableView_ reloadData];
    }
}

- (void)_handleSearchHits:(NSArray *)hits {
    NSUInteger count = [hits count];
    if (count > 0) {
        if([self isSearchStatuses]) {
            if(statuses_ == nil) {
                statuses_ = [[NSMutableArray alloc] initWithCapacity:10];
            }
            
            [statuses_ addObjectsFromArray:hits];
            
        }else if([self isSearchTrends] || [self isSearchUsers]) {
            if(hits_ == nil) {
                hits_ = [[NSMutableArray alloc] initWithCapacity:[hits count]];
            }
            
            [hits_ addObjectsFromArray:hits];
        }
    }
    
    [self.tableView reloadData];
    
    BOOL active = (count == KD_MAX_SEARCH_ITEM_COUNT_PER_PAGE) ? YES : NO;
    [self setMoreButtonActive:active];
    
    NSMutableArray *dataSource = [self dataSource];
    BOOL matched = (dataSource != nil && [dataSource count] > 0x00) ? YES : NO;
    [self infoLabelWithVisible:(matched ? NO : YES)];
}

- (void)search:(NSString *)keywords isLoadMore:(BOOL)loadMore {
    if (keywords != nil && [keywords length] > 0) {
        if([searchBar_ canResignFirstResponder]){
            [searchBar_ resignFirstResponder];
        }
        
        if (searchViewControllerFlags_.hasRequests) {
            [self cancelRequets];
        
        } else {
            searchViewControllerFlags_.hasRequests = 1;
            
            // clear datasource before any search action
            [self.tableView reloadData];
            
            [self activityViewWithVisible:YES];
            [self toggleMoreButtonEnabled:NO isLoading:YES];
            
            NSString *actionPath = nil;
            if ([self isSearchUsers]) {
                actionPath = @"/users/:search";
                
            } else if ([self isSearchStatuses]) {
                actionPath = @"/statuses/:search";
            
            } else if ([self isSearchTrends]) {
                actionPath = @"/trends/:search";
            }
            
            // request parameters
            NSUInteger page = loadMore ? (currentPage_ + 1) : currentPage_;
            
            KDQuery *query = [KDQuery query];
            [[[query setParameter:@"q" stringValue:keywords]
                     setParameter:@"count" integerValue:KD_MAX_SEARCH_ITEM_COUNT_PER_PAGE]
                     setParameter:@"page" integerValue:page];
            
            __block KDSearchViewController *svc = self;// retain];
            KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
                [svc activityViewWithVisible:NO];
                [svc toggleMoreButtonEnabled:NO isLoading:NO];
                
                if([response isValidResponse]) {
                    if (results != nil) {
                        [svc _handleSearchHits:results];
                        
                        // plus 1 to current page index
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
                
                (svc -> searchViewControllerFlags_).hasRequests = 0;
                
                // release current view controller
//                [svc release];
            };
            
            [KDServiceActionInvoker invokeWithSender:nil actionPath:actionPath query:query
                                         configBlock:nil completionBlock:completionBlock];
        }
    }
}

- (void)cancelRequets {
    if(searchViewControllerFlags_.hasRequests){
        // cancel the requests
        [[KDRequestDispatcher globalRequestDispatcher] cancelRequestsWithDelegate:self force:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if(searchViewControllerFlags_.backToPrevious){
        [self cancelRequets];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    moreButton_ = nil;
    
    //KD_RELEASE_SAFELY(searchBar_);
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(infoLabel_);
    //KD_RELEASE_SAFELY(activityView_);
}

- (void)dealloc {
    delegate_ = nil;
    moreButton_ = nil;
    
    //KD_RELEASE_SAFELY(keywords_);
    
    //KD_RELEASE_SAFELY(statuses_);
    //KD_RELEASE_SAFELY(hits_);
    
    //KD_RELEASE_SAFELY(timelineProvider_);
    
    //KD_RELEASE_SAFELY(searchBar_);
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(infoLabel_);
    //KD_RELEASE_SAFELY(activityView_);
    
    //[super dealloc];
}

@end
