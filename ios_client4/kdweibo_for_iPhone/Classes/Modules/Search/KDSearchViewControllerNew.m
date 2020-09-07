//
//  KDSearchViewController.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-16.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDSearchViewControllerNew.h"

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
#import "KDStatusDetailViewController.h"
#import "ProfileViewController.h"
#import "KDSearchBar.h"
#import "KDMaskView.h"
#import "KDStatusLayouter.h"
#import "KDLayouterView.h"
#import "KDStatusCell.h"
#import "XTPersonDetailViewController.h"

#import "XTSearchCell.h"
#import "XTInitializationManager.h"
#import "T9.h"

#define KD_MAX_SEARCH_ITEM_COUNT_PER_PAGE   20


@interface KDSearchViewControllerNew () <UITableViewDelegate, UITableViewDataSource, KDSearchBarDelegate, KDRequestWrapperDelegate, KDSearchViewControllerNewDelegate, KDMaskViewDelegate>

@property (nonatomic, retain) NSMutableArray *statuses;
@property (nonatomic, retain) NSMutableArray *hits;

@property (nonatomic, retain) KDStatusTimelineProvider *timelineProvider;
@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, retain) KDSearchBar *searchBar;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UILabel *infoLabel;
@property (nonatomic, retain) KDActivityIndicatorView *activityView;

@property (nonatomic, retain) NSCache *statusCellCache;

@end


@implementation KDSearchViewControllerNew {
 @private
//    id<KDSearchViewControllerNewDelegate> delegate_;
    KDSearchNewMaskType searchMaskType_;
    
    NSUInteger currentPage_;
    NSString *keywords_;
    
    NSMutableArray *statuses_;
    NSMutableArray *hits_; // may be KDUser / Topic Text
    
    KDStatusTimelineProvider *timelineProvider_;
    
    KDSearchBar *searchBar_;
    UITableView *tableView_;
    UILabel *infoLabel_;
    KDActivityIndicatorView *activityView_;
    
    UIButton *moreButton_; // weak reference
    
    KDMaskView *maskView_; //weak
    
    BOOL canSearch_;
    struct {
        unsigned int hasRequests:1;
        unsigned int backToPrevious:1;
        unsigned int initialized:1;
        
    }searchViewControllerFlags_; 
}

@synthesize delegate=delegate_;
@synthesize searchMaskType=searchMaskType_;
@synthesize isReturnByGesture = _isReturnByGesture;
@synthesize keywords=keywords_;
@synthesize shouldDelayShowKeyBoard = _shouldDelayShowKeyBoard;
@synthesize statuses=statuses_;
@synthesize hits=hits_;
@synthesize timelineProvider=timelineProvider_;
@synthesize currentPage=currentPage_;

@synthesize searchBar=searchBar_;
@synthesize tableView=tableView_;
@synthesize infoLabel=infoLabel_;
@synthesize activityView=activityView_;

@synthesize statusCellCache = statusCellCache_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        searchMaskType_ = KDSearchNewMaskTypeNone;
        currentPage_ = 1;
        
        timelineProvider_ = [[KDStatusTimelineProvider alloc] initWithViewController:self];
        
        searchViewControllerFlags_.hasRequests = 0;
        searchViewControllerFlags_.backToPrevious = 1;
        searchViewControllerFlags_.initialized = 0;
        delegate_ = self;
        
        self.navigationItem.title = ASLocalizedString(@"KDSearchBar_Search");
    }
    
    return self;
}

- (id)initWithSearchMaskType:(KDSearchNewMaskType)searchMaskType {
    self = [self initWithNibName:nil bundle:nil];
    if(self){
        searchMaskType_ = searchMaskType;
    }
    
    return self;
}

- (BOOL)resignFirstResponder {
    [searchBar_ resignFirstResponder];
    
    return [super resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(0xF0F0F0);
    
    BOOL searchAll = [self isSearchAll];
    
    // search bar
    CGFloat height = searchAll ? 100.0 : 50.0;
    CGRect frame = CGRectMake(0.0, 0.0f, CGRectGetWidth(self.view.bounds), height);
    
    KDSearchBar *searchBar = [[KDSearchBar alloc] initWithFrame:frame];
    self.searchBar = searchBar;
    searchBar.showsCancelButton = NO;
//    [searchBar release];
    
    if(searchMaskType_ == (KDSearchNewMaskTypeStatuses | KDSearchNewMaskTypeUsers)) {
        self.searchBar.backgroundColor = RGBCOLOR(232, 232, 232);
    }
    searchBar_.delegate = self;
    searchBar_.autocorrectionType = UITextAutocapitalizationTypeAllCharacters;
    searchBar_.scopeBar.backgroundColor = RGBCOLOR(237, 237, 237);
    // set the keywords to search bar
    searchBar_.text = (keywords_ != nil) ? keywords_ : nil;
    
    if(searchAll){
        searchBar_.scopeBar.scopeButtonTitles = [NSArray arrayWithObjects:NSLocalizedString(@"SEARCH_STATUSES", @""),
                                                 NSLocalizedString(@"SEARCH_USERS", @""), nil];
    }
    
    [self.view addSubview:searchBar_];
    
    // table view
    frame.origin.y = frame.origin.y + frame.size.height;
    frame.size.height = self.view.bounds.size.height - frame.origin.y;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView = tableView;
//    [tableView release];
    
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.backgroundColor = UIColorFromRGB(0xF0F0F0);
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
    
    // disable right bar button item if not search all
    if(!searchAll){
        self.navigationItem.rightBarButtonItems = nil;
    }
}

- (NSCache *)statusCellCache {
    if(statusCellCache_ == nil) {
        statusCellCache_ = [[NSCache alloc] init];
        statusCellCache_.totalCostLimit = 500;
    }
    
    return statusCellCache_;
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
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _isReturnByGesture = NO;
    if(searchViewControllerFlags_.backToPrevious){
        [self cancelRequets];
    }
    
    
    [self removeMaskView];
  
    [searchBar_ resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(!([self dataSource] && [self dataSource].count > 0)) {
        if(_shouldDelayShowKeyBoard) {
            [searchBar_ performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.25f];
        }else {
            [searchBar_ becomeFirstResponder];
        }
    }
    
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
        height = 65.0f;
        
    }else if([self isSearchStatuses]){
        KDStatus *status = [statuses_ objectAtIndex:indexPath.row];
        
        KDStatusLayouter *layouter = [KDStatusLayouter statusLayouter:status constrainedWidth:tableView.bounds.size.width - 16.0f];
        return layouter.frame.size.height + 10;
    }else if([self isSearchTrends]){
        height = 44.0;
    }
    
	return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self isSearchUsers]){
        static NSString *UserCellIdentifier = @"UserCell";
         XTSearchCell *cell = (XTSearchCell *)[tableView dequeueReusableCellWithIdentifier:UserCellIdentifier];
            if(cell == nil){
                cell = [[XTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserCellIdentifier] ;//autorelease];
                }

        cell = [[XTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserCellIdentifier] ;//autorelease];
        cell.searchResult = [[self dataSource] objectAtIndex:indexPath.row];
        return cell;
        
    }else if ([self isSearchStatuses]) {
        KDStatus *status = [statuses_ objectAtIndex:indexPath.row];
        
        KDStatusCell *cell = [self.statusCellCache objectForKey:status.statusId];
        if (!cell) {
            KDStatusLayouter *layouter = [KDStatusLayouter statusLayouter:status constrainedWidth:0];
            KDLayouterView * layouterView = [layouter view];
            cell = [[KDStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];// autorelease];
            [cell addSubview:layouterView];
           
            layouterView.layouter = layouter;
            [self.statusCellCache setObject:cell forKey:status.statusId cost:1];
            
        }
        if(!tableView.dragging && !tableView.decelerating){
            [cell loadThumbanilsImage];
        }
        return cell;
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
    [tableView_ deselectRowAtIndexPath:indexPath animated:YES];
    
    if(KDSearchNewMaskTypeUsers == searchMaskType_){
        // only search user
        if(delegate_ != nil && [delegate_ respondsToSelector:@selector(searchViewControllerNew:didSelectUser:)]){
            KDUser *user = [hits_ objectAtIndex:indexPath.row];
            [delegate_ searchViewControllerNew:self didSelectUser:user];
        }
        
    }else if([self isSearchAll]){
        if([self isSearchStatuses]){
            if(delegate_ && [delegate_ respondsToSelector:@selector(searchViewControllerNew:didSelectStatus:)])
                [delegate_ searchViewControllerNew:self didSelectStatus:[statuses_ objectAtIndex:indexPath.row]];
        }else {
//            KDUser *user = [hits_ objectAtIndex:indexPath.row];
//            if(delegate_ && [delegate_ respondsToSelector:@selector(searchViewControllerNew:didSelectUser:)])
//                [delegate_ searchViewControllerNew:self didSelectUser:user];
            XTSearchCell *cell = (XTSearchCell *)[tableView cellForRowAtIndexPath:indexPath];
            PersonSimpleDataModel *person = cell.person;
            XTPersonDetailViewController*personDetail = [[XTPersonDetailViewController alloc]initWithSimplePerson:person with:NO] ;//autorelease];
            personDetail.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:personDetail animated:YES];
        }
    
    }else if([self isSearchTrends]){
        if(delegate_ && [delegate_ respondsToSelector:@selector(searchViewControllerNew:didSelectTopicText:)]){
            KDTopic *topic = [hits_ objectAtIndex:indexPath.row];
            [delegate_ searchViewControllerNew:self didSelectTopicText:topic.name];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = UIColorFromRGB(0xF0F0F0);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if(!decelerate){
        [self _loadImageSourceIfNeed];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _loadImageSourceIfNeed];
}

//TODO:暂时注释，需要解决图片延时加载问题
- (void)_loadImageSourceIfNeed {
    
    if ([self isSearchUsers]) {
        // user avatar
        [KDAvatarView loadImageSourceForTableView:tableView_];
        
    } else if ([self isSearchStatuses]) {
        //[timelineProvider_ loadImageSourceInTableView:self.tableView];
         [KDStatusCell loadImagesForVisibleCellsIfNeed:tableView_];
    }
    
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDSearchBar delegate methods

- (void)searchBarTextDidChange:(KDSearchBar *)searchBar {
    [self removeMaskView];
    //[self search:searchBar.text isLoadMore:NO];
    if ([self isSearchUsers]) {
        [self searchUser:searchBar.text];
    }
}


- (void)searchBarTextDidBeginEditing:(KDSearchBar *)searchBar {
//    searchBar.showsCancelButton = YES;
    [self addMaskView];

    if ([self isSearchUsers]) {
        __block BOOL *finishFlag = &canSearch_;
        [[T9 sharedInstance] firstInitial:^(BOOL isInitial) {
         if(isInitial)
            {
                [self activityViewWithVisible:YES message:ASLocalizedString(@"KDSearchViewControllerNew_init")];
             }
           }
            initFinished:^() {
                    *finishFlag = YES;
                                // [self toastClose];
               [self activityViewWithVisible:NO];
            }];
        }
    if (canSearch_) {
        [self searchUser:searchBar.text];
    }
   
}

- (void)searchBarTextDidEndEditing:(KDSearchBar *)searchBar {
//    searchBar.showsCancelButton = NO;
    [self removeMaskView];
}

- (void)searchBarCancelButtonClicked:(KDSearchBar *)searchBar {
    /*
     IOS7 适配
     */
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
    if([searchBar canResignFirstResponder]){
        [searchBar resignFirstResponder];
    }
    if(delegate_ && [delegate_ respondsToSelector:@selector(searchViewControllerNewDidCancel:)])
        [delegate_ searchViewControllerNewDidCancel:self];
}

- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar {
   
   
    self.keywords = searchBar.text;
    
    if ([self isSearchUsers]) { //搜索user
        [self searchUser:self.keywords];
        if([searchBar canResignFirstResponder]){
            [searchBar resignFirstResponder];
        }
        return;
    }
    
    // reset page number before start new sreach
    currentPage_ = 1;
    [self clearDataSource:[self dataSource]];
    [self search:keywords_ isLoadMore:NO];
}

- (void)searchBar:(KDSearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    // cancel exist requests if need
    [self cancelRequets];
    
    // retrive the hits for keywords if need
    self.keywords = searchBar.text;
    if ([self isSearchUsers]) { //搜索user
        [self searchUser:self.keywords];
        return;
    }
    
    // clear the data source before switch to another scope
    NSMutableArray *source = ([self isSearchStatuses]) ? statuses_: hits_;
    [self clearDataSource:source];
     currentPage_ = 1;
    [self search:keywords_ isLoadMore:NO];
}

#pragma mark - KDMaskViewDelegate Methods
- (void)maskView:(KDMaskView *)maskView touchedInLocation:(CGPoint)location {
    [self.searchBar resignFirstResponder];
}

#pragma mark - KDSearchBar aid method
- (void)addMaskView {
    if(!maskView_) {
        maskView_ = [[KDMaskView alloc] initWithFrame:CGRectZero];
        maskView_.delegate = self;
        [self.view addSubview:maskView_];
//        [maskView_ release];
    }
    
    maskView_.frame = self.tableView.frame;
}

- (void)removeMaskView {
    if(maskView_) {
        if(maskView_.superview) {
            [maskView_ removeFromSuperview];
        }
        maskView_ = nil;
    }
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (void)activityViewWithVisible:(BOOL)visible {
    [self activityViewWithVisible:visible message:ASLocalizedString(@"RecommendViewController_Load")];
}

- (void)activityViewWithVisible:(BOOL)visible message:(NSString *)message {
    if(activityView_ == nil){
        CGRect rect = CGRectMake((self.view.bounds.size.width - 120.0) * 0.5, (self.view.bounds.size.height - 80.0) * 0.5, 120.0, 80.0);
        activityView_ = [[KDActivityIndicatorView alloc] initWithFrame:rect];
        activityView_.alpha = 0.0;
        
        [self.view addSubview:activityView_];
    }
    
    if (visible) {
        [activityView_ show:YES info:message];
        
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
            [moreBtn setTitle:ASLocalizedString(@"KDPlaceAroundTableView_More") forState:UIControlStateNormal];
            
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
    return ([self isSearchAll] && searchBar_.scopeBar.selectedScopeButtonIndex == 0x00);
}

- (BOOL)isSearchUsers {
    return (searchMaskType_ == KDSearchNewMaskTypeUsers)
            || ([self isSearchAll] && searchBar_.scopeBar.selectedScopeButtonIndex == 0x01);
}

- (BOOL)isSearchTrends {
    return searchMaskType_ == KDSearchNewMaskTypeTrends;
}

- (BOOL)isSearchAll {
    return (KDSearchNewMaskTypeUsers|KDSearchNewMaskTypeStatuses) == searchMaskType_;
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

- (UIView *)noSearchResultView {
    UIView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds ];// autorelease];
    [backgroundView setUserInteractionEnabled:YES];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_placeholder_v2.png"]] ;//autorelease];
    [bgImageView sizeToFit];
    bgImageView.center = CGPointMake(backgroundView.bounds.size.width * 0.5f, 137.5f);
    
    [backgroundView addSubview:bgImageView];
    backgroundView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(bgImageView.frame) + 10.0f, self.view.bounds.size.width, 15.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = MESSAGE_NAME_COLOR;
    label.font = [UIFont systemFontOfSize:12.0f];
    
    if([self isSearchStatuses])
        label.text = NSLocalizedString(@"SEARCH_NO_MATCHED_STATUS", @"");
    else if([self isSearchUsers])
        label.text = ASLocalizedString(@"SEARCH_NO_MATCHED_USER");
    else if([self isSearchTrends])
        label.text = ASLocalizedString(@"NO_DATA_TASK_DISSCUSS");
    
    [backgroundView addSubview:label];
//    [label release];
    
    return backgroundView;
}

- (void)searchUser:(NSString *)searchtext
{
    if (KD_IS_BLANK_STR(searchtext)) {
        return;
    }
    if (!hits_) {
        hits_ = [[NSMutableArray alloc] init];
    }
     [self clearDataSource:[self dataSource]];
     [[self dataSource] addObjectsFromArray:[[T9 sharedInstance] search:searchtext]];
     [self.tableView reloadData];
   // [self refreshTableViewFooterView];
    if (![self dataSource] || [self dataSource].count == 0) {
        self.tableView.backgroundView = [self noSearchResultView];
        
    } else {
        self.tableView.backgroundView = nil;
    }
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
            
          
            
            NSString *actionPath = nil;
            if ([self isSearchUsers]) {
                //actionPath = @"/users/:search";
                
            } else if ([self isSearchStatuses]) {
                actionPath = @"/statuses/:search";
                [self activityViewWithVisible:YES];
                [self toggleMoreButtonEnabled:NO isLoading:YES];
            
            } else if ([self isSearchTrends]) {
                actionPath = @"/trends/:search";
                [self activityViewWithVisible:YES];
                [self toggleMoreButtonEnabled:NO isLoading:YES];
            }
            
            // request parameters
            NSUInteger page = loadMore ? (currentPage_ + 1) : currentPage_;
            
            KDQuery *query = [KDQuery query];
            [[[query setParameter:@"q" stringValue:keywords]
                     setParameter:@"count" integerValue:KD_MAX_SEARCH_ITEM_COUNT_PER_PAGE]
                     setParameter:@"page" integerValue:page];
            
            __block KDSearchViewControllerNew *svc = self ;//／／retain];
            KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
                [svc activityViewWithVisible:NO];
                [svc toggleMoreButtonEnabled:NO isLoading:NO];
                
                if ([response isValidResponse]) {
                    if(!results || [(NSArray *)results count] == 0) {
                        [[svc dataSource] removeAllObjects];
                        [svc.tableView reloadData];
                        
                    } else {
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
                
                if (![svc dataSource] || [svc dataSource].count == 0) {
                    svc.tableView.backgroundView = [svc noSearchResultView];
                    
                } else {
                    svc.tableView.backgroundView = nil;
                }
                
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


#pragma mark - KDSearchViewControllerNewDelegate Method
- (void)searchViewControllerNew:(KDSearchViewControllerNew *)svcn didSelectStatus:(KDStatus *)status {
    KDStatusDetailViewController *sdvc = [[KDStatusDetailViewController alloc] initWithStatus:status];
    [self.navigationController pushViewController:sdvc animated:YES];
//    [sdvc release];
}

- (void)searchViewControllerNew:(KDSearchViewControllerNew *)svcn didSelectTopicText:(NSString *)topicText {
    
}

- (void)searchViewControllerNew:(KDSearchViewControllerNew *)svcn didSelectUser:(KDUser *)user {
//    ProfileViewController *pvc = [[ProfileViewController alloc] initWithUser:user];
//    [self.navigationController pushViewController:pvc animated:YES];
//    [pvc release];
      [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:user sender:self.view];
    
}

- (void)searchViewControllerNewDidCancel:(KDSearchViewControllerNew *)svcn {
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    moreButton_ = nil;
    
    //KD_RELEASE_SAFELY(searchBar_);
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(infoLabel_);
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(maskView_);
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
    //KD_RELEASE_SAFELY(statusCellCache_);
    
    //[super dealloc];
}

@end
