//
//  KDFavoriedColleagueViewController.m
//  kdweibo
//
//  Created by gordon_wu on 13-12-5.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDFavoriedColleagueViewController.h"

#import "KDCommon.h"
#import "KDABPersonViewController.h"
#import "KDABPersonDetailsViewController.h"

#import "KDSearchBar.h"
#import "KDRefreshTableView.h"
#import "KDABRefreshTableHeaderView.h"
#import "KDABPersonCell.h"
#import "KDActivityIndicatorView.h"
#import "KDErrorDisplayView.h"

#import "KDABPerson.h"
#import "KDABPersonActionHelper.h"

#import "KDWeiboServicesContext.h"
#import "KDRequestDispatcher.h"
#import "KDDefaultViewControllerContext.h"

#import "NSDictionary+Additions.h"
#import "NSString+Additions.h"
#import "KDUIUtils.h"
#import "KDDatabaseHelper.h"
#import "ProfileViewController.h"
//#import "LeveyTabBarController.h"


@interface KDFavoriedColleagueViewController () <KDSearchBarDelegate, KDRefreshTableViewDelegate, KDRefreshTableViewDataSource, KDRequestWrapperDelegate>

@property(nonatomic, retain) KDABPersonActionHelper *actionHelper;


@property(nonatomic, retain) NSMutableArray *favoriedContacts;
@property(nonatomic, retain) NSMutableArray *searchedContacts;

@property(nonatomic, retain) NSMutableArray *displayContacts;
@property(nonatomic, retain) NSMutableArray *sectionTiltes;

@property(nonatomic, assign) NSInteger searchContactsPageIndex;

@property(nonatomic, retain) KDSearchBar *searchBar;
@property(nonatomic, retain) KDRefreshTableView *tableView;

@property(nonatomic, retain) KDActivityIndicatorView *activityView;
@property(nonatomic, retain) UILabel *promptInfoLabel;
@property(nonatomic, retain) UIView *maskView;

@property(nonatomic, retain) UIBarButtonItem *tempLeftBarItem; // use to cache navigation left bar item

@end

@implementation KDFavoriedColleagueViewController{
@private
    NSInteger selectedTabIndex_;
    
    NSInteger favoriedContactsPageIndex_;
    
    struct {
        unsigned int initialized:1;
        
        unsigned int searching:1;
        unsigned int forceCancelled:1;
        
        unsigned int favoritedContactsMask;
        unsigned int searchContactsMask;
        
    }personViewControllerFlags_;
}

@synthesize actionHelper=actionHelper_;


@synthesize favoriedContacts=favoriedContacts_;
@synthesize searchedContacts=searchedContacts_;

@synthesize displayContacts=displayContacts_;
@synthesize sectionTiltes=sectionTiltes_;

@synthesize searchContactsPageIndex=searchContactsPageIndex_;

@synthesize searchBar=searchBar_;

@synthesize tableView=tableView_;


@synthesize activityView=activityView_;
@synthesize promptInfoLabel=promptInfoLabel_;
@synthesize maskView=maskView_;

@synthesize tempLeftBarItem=tempLeftBarItem_;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"AB_ACTION_FAVORITE", @"");
        
        actionHelper_ = [[KDABPersonActionHelper alloc] initWithViewController:self];
        
        selectedTabIndex_ = 0x02;

        favoriedContactsPageIndex_ = 1;
        searchContactsPageIndex_ = 1;
        
        personViewControllerFlags_.initialized = 0;
        
        personViewControllerFlags_.searching = 0;
        personViewControllerFlags_.forceCancelled = 0;
        
        personViewControllerFlags_.favoritedContactsMask = 0x0000;
        personViewControllerFlags_.searchContactsMask = 0x0f00;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    self.view.backgroundColor = [UIColor whiteColor];
    
    // build table section titles
    [self _buildTableViewSectionTitle];
    
    // search bar background image view
    CGFloat offsetY = 0.0;
    CGRect frame = CGRectMake(0.0, offsetY, self.view.bounds.size.width, 50.0);
    
    UIImage *searchBGImage = [UIImage imageNamed:@"address_book_search_bg_v2.png"];
    searchBGImage = [searchBGImage stretchableImageWithLeftCapWidth:(searchBGImage.size.width * 0.5)
                                                       topCapHeight:(searchBGImage.size.height * 0.5)];
    
    UIImageView *searchBarBGView = [[UIImageView alloc] initWithImage:searchBGImage];
    searchBarBGView.frame = frame;
    
    searchBarBGView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:searchBarBGView];
//    [searchBarBGView release];
    
    // search bar
    frame.size.height -= 1.0;
    
    KDSearchBar *searchBar = [[KDSearchBar alloc] initWithFrame:frame];
    self.searchBar = searchBar;
//    [searchBar release];
//
    searchBar_.placeHolder = NSLocalizedString(@"AB_SEARCH_CONTACTS_PLACEHOLDER", @"");
    searchBar_.delegate = self;
    searchBar_.showsCancelButton = NO;
    searchBar_.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // searchBar_.backgroundImage = [UIImage imageNamed:@"address_book_search_bg_v2.png"];
    
    searchBar_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:searchBar_];
    
    frame.size.height += 1.0;
    
    // table view
    offsetY += frame.size.height;
    frame.origin.y = offsetY;
    frame.size.height = self.view.bounds.size.height - offsetY;
    
    KDRefreshTableView *tableView = [[KDRefreshTableView alloc] initWithFrame:frame kdRefreshTableViewType:KDRefreshTableViewType_Footer style:UITableViewStylePlain];
    self.tableView = tableView;
//    [tableView release];
    
    // custom table refresh header view
    KDABRefreshTableHeaderView *refreshHeaderView = [[KDABRefreshTableHeaderView alloc] initWithFrame:tableView_.bounds];
    [tableView_ setTopView:refreshHeaderView];
//    [refreshHeaderView release];
    
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView_.rowHeight = 56.0;
    // tableView_.backgroundColor = [UIColor whiteColor];
    
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
    
    // action tab bar
    frame.origin.y = self.view.bounds.size.height - 57.0;
    frame.size.height = 57.0;
    
    
    // long press gesture recognizer
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_didLongPress:)];
    longPressGestureRecognizer.minimumPressDuration = 0.3;
    [tableView_ addGestureRecognizer:longPressGestureRecognizer];
//    [longPressGestureRecognizer release];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.tempLeftBarItem) {
        self.tempLeftBarItem = [self.navigationItem.leftBarButtonItems lastObject];
    }
    
    if (personViewControllerFlags_.initialized == 0) {
        personViewControllerFlags_.initialized = 1;
        
        [self _didChangeSelectedActionTab];
    }else
    {
        [self reloadFromDB];
    }
}

///////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (displayContacts_ != nil) ? [displayContacts_ count] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if ([self _isFavoritedContactsTab]) {
        rows = [(NSArray *)[displayContacts_ objectAtIndex:section] count];
    } else {
        NSArray *items = [self _datasourceInSection:section];
        rows = [items count];
    }
    
    return rows;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if ([self _isFavoritedContactsTab]) {
//        if (![self _hasContactsInSection:section]) {
//            return nil;
//        }
//
//        return [sectionTiltes_ objectAtIndex:section];
//    }
//
//    return nil;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(![self _isFavoritedContactsTab] || ![self _hasContactsInSection:section])
    {

        return 0.0f;
    }
    
    return 22.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(![self _isFavoritedContactsTab] || ![self _hasContactsInSection:section]) return nil;
    
    NSString *title = [sectionTiltes_ objectAtIndex:section];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, tableView.bounds.size.width - 10.0f, 22.0f)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = RGBCOLOR(26,133, 255);
    titleLabel.text = title;
    
    UIImage *separatorImage = [UIImage imageNamed:@"address_book_separator_line_v2.png"];
    separatorImage = [separatorImage stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    UIImageView *separatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, 22.0f)];
    [headerView addSubview:titleLabel];
    headerView.backgroundColor = MESSAGE_BG_COLOR;
//    [titleLabel release];
    
    [headerView addSubview:separatorImageView];
    separatorImageView.frame = CGRectMake(0.0f, 22.0f - 1.0f, tableView.bounds.size.width, 1.0f);
//    [separatorImageView release];
    
   
    return headerView;// autorelease];
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    return ([self _isFavoritedContactsTab]) ? sectionTiltes_ : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    KDABPersonCell *cell = (KDABPersonCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KDABPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
    }
    
    NSArray *persons = [self _datasourceInSection:indexPath.section];
    KDABPerson *person = [persons objectAtIndex:indexPath.row];
    cell.person = person;
    
    UIView *selectBgView = [[UIView alloc] initWithFrame:CGRectZero] ;//autorelease];
    selectBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    selectBgView.backgroundColor = RGBCOLOR(26, 133, 255);
    cell.selectedBackgroundView = selectBgView;
    
    [cell update:![self _isFavoritedContactsTab]];
    
    [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:cell.avatarView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *persons = [self _datasourceInSection:indexPath.section];
    KDABPerson *person = [persons objectAtIndex:indexPath.row];
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewControllerByUserId:person.userId sender:tableView];
    //    actionHelper_.pickedPerson = person;
    //    [actionHelper_ showABPersonProfile];
}

#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE

- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView {
    
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    if ([self _isSearchContactsTab]) {
        [self _search:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (tableView_ == scrollView) {
        [tableView_ kdRefreshTableViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (tableView_ == scrollView) {
        [tableView_ kdRefreshTableviewDidEndDraging:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [KDAvatarView loadImageSourceForTableView:tableView_];
}


///////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UISearchBar delegate methods

- (void)searchBarTextDidBeginEditing:(KDSearchBar *)searchBar {
    [self _willBeginSearching];
    [self _maskViewWithVisible:YES];
}

- (void)searchBarTextDidEndEditing:(KDSearchBar *)searchBar {
    [self _didFinishSearching];
    [self _maskViewWithVisible:NO];
}


- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar {
    [self _searchBarResignFirstResponder];
    
    [self _search:YES];
}



///////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark extend views

- (void)_setupCancelSearchingButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    //[btn setTitle:NSLocalizedString(@"BACK", @"") forState:UIControlStateNormal];
    
    [btn setBackgroundImage:[UIImage imageNamed:@"navigationItem_back.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"navigationItem_back.png"] forState:UIControlStateHighlighted];
    
    [btn sizeToFit];
    
    [btn addTarget:self action:@selector(_shouldCancelSearch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //song.wang 2013-12-26
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil] ;//autorelease];
    negativeSpacer.width = kLeftNegativeSpacerWidth;
    self.navigationItem.leftBarButtonItems = [NSArray
                                              arrayWithObjects:negativeSpacer,leftItem, nil];
//    [leftItem release];
}

- (void)_showPromptInfo:(BOOL)visible info:(NSString *)info {
    if (visible) {
        if (promptInfoLabel_ == nil) {
            CGRect frame = CGRectMake(0.0, 80.0, self.view.bounds.size.width, 30.0);
            promptInfoLabel_ = [[UILabel alloc] initWithFrame:frame];
            
            promptInfoLabel_.backgroundColor = [UIColor clearColor];
            promptInfoLabel_.textColor = [UIColor grayColor];
            promptInfoLabel_.font = [UIFont systemFontOfSize:15.0];
            promptInfoLabel_.textAlignment = NSTextAlignmentCenter;
            
            [self.view insertSubview:promptInfoLabel_ aboveSubview:tableView_];
        }
        
        promptInfoLabel_.text = info;
    }
    
    promptInfoLabel_.hidden = !visible;
}

- (void)_activityViewWithVisible:(BOOL)visible info:(NSString *)info {
    if(activityView_ == nil){
        CGRect rect = CGRectMake((self.view.bounds.size.width - 120.0) * 0.5, (self.view.bounds.size.height - 80.0) * 0.5, 120.0, 80.0);
        activityView_ = [[KDActivityIndicatorView alloc] initWithFrame:rect];
        activityView_.alpha = 0.0;
        
        [self.view addSubview:activityView_];
    }
    
    if(visible){
        [activityView_ show:YES info:info];
        
    }else {
        [activityView_ hide:YES];
    }
}

- (void)_maskViewWithVisible:(BOOL)visible {
    if (maskView_ == nil) {
        CGRect rect = tableView_.frame;
        maskView_ = [[UIView alloc] initWithFrame:rect];
        
        // tap gesture recognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_didTapOnMaskView:)];
        tap.numberOfTapsRequired = 1;
        
        [maskView_ addGestureRecognizer:tap];
//        [tap release];
        
        // swipe gesture recognizer
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_didSwipeOnMaskView:)];
        swipe.direction = UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown;
        
        [maskView_ addGestureRecognizer:swipe];
//        [swipe release];
        
        maskView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:maskView_];
    }
    
    maskView_.hidden = !visible;
}

- (void)_didTapOnMaskView:(UITapGestureRecognizer *)gestureRecognizer {
    [self _searchBarResignFirstResponder];
}

- (void)_didSwipeOnMaskView:(UISwipeGestureRecognizer *)gestureRecognizer {
    [self _searchBarResignFirstResponder];
}

- (void)_showNoContactsInfoIfNeed {
    BOOL hasResults = [self _hasDisplayContacts];
    [self _showPromptInfo:!hasResults info:(hasResults ? nil : NSLocalizedString(@"AB_NO_MATCHED_CONTACTS", @""))];
}

- (void)_reportNetworkErrorMessage:(KDResponseWrapper *)response {
    if(![response isCancelled]) {
        [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage] inView:self.view.window];
    }
}


///////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (void)_didLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
   
    if(UIGestureRecognizerStateBegan == gestureRecognizer.state){
        CGPoint anchorPoint = [gestureRecognizer locationInView:tableView_];
        NSIndexPath *indexPath = [tableView_ indexPathForRowAtPoint:anchorPoint];
        if(indexPath != nil){
            NSArray *persons = [self _datasourceInSection:indexPath.section];
            KDABPerson *person = [persons objectAtIndex:indexPath.row];
            
            [actionHelper_ showContactMainActionMenu:person];
        }
    }
}


////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark displaying data source

- (NSArray *)_datasourceInSection:(NSInteger)section {
    return [displayContacts_ objectAtIndex:section];
}

- (BOOL)_hasContactsInSection:(NSInteger)section {
    NSArray *sectionContacts= [self _datasourceInSection:section];
    return sectionContacts != nil && [sectionContacts count] > 0;
}

- (BOOL)_hasDisplayContacts {
    BOOL hasResults = NO;
    if (displayContacts_ != nil) {
        for (NSArray *item in displayContacts_) {
            if ([item count] > 0) {
                hasResults = YES;
                
                break;
            }
        }
    }
    
    return hasResults;
}

- (void)_clearDisplayingContacts:(BOOL)reload {
    if (displayContacts_ != nil) {
        [displayContacts_ removeAllObjects];
    }
    
    if (reload) {
        [tableView_ reloadData];
        [self refreshTableViewFooterView];
    }
}

- (void)_clearSearchedContacts {
    // clear any cached objects
    if (searchedContacts_ != nil) {
        [searchedContacts_ removeAllObjects];
    }
}

- (void)_appendContacts:(NSArray *)persons to:(NSMutableArray *__strong*)container clear:(BOOL)clear
                 update:(BOOL)update reload:(BOOL)reload {
    
    NSUInteger count = 0;
    if (persons == nil || (count = [persons count]) == 0 || container == NULL) {
        return;
    }
    
    if (*container == nil) {
        *container = [[NSMutableArray alloc] initWithCapacity:count];
        
    } else {
        if (clear) {
            [*container removeAllObjects];
        }
    }
    
    [*container addObjectsFromArray:persons];
    
    if (update) {
        [self _updateDisplayContacts:YES reload:reload];
    }
}

- (void)_updateDisplayContacts:(BOOL)clear reload:(BOOL)reload {
    if (displayContacts_ == nil) {
        displayContacts_ = [[NSMutableArray alloc] init];
    }
    
    if (clear && [displayContacts_ count] > 0) {
        [displayContacts_ removeAllObjects];
    }
    
    if ([self _isFavoritedContactsTab]) {
        if (favoriedContacts_ != nil) {
            [displayContacts_ addObjectsFromArray:favoriedContacts_];
        }
        
    } else if ([self _isSearchContactsTab]) {
        if (searchedContacts_ != nil) {
            [displayContacts_ addObject:searchedContacts_];
        }
    }
    
    if (reload) {
        [tableView_ reloadData];
        [self refreshTableViewFooterView];
        
        // No matter there is prompt info or not, just dismiss it
        [self _showPromptInfo:NO info:nil];
    }
}

// group contact's name to the A-Z sequence
- (void)_groupFavoritedContacts:(NSArray *)persons {
    NSUInteger count = [persons count];
    if (count < 0x01) {
        return;
    }
    
    // initiailize grouped contacts container
    NSMutableArray *groupedContacts = [self _buildGroupedContactsContainer];
    NSUInteger wildcardIdx = [groupedContacts count] - 1; // the wildcard(*) index
    
    for(KDABPerson *p in persons) {
        NSUInteger index = [p.name convertFirstCharacterToAZIndex];
        if (index == NSNotFound) {
            index = wildcardIdx;
        }
        
        [[groupedContacts objectAtIndex:index] addObject:p];
    }
    
    self.favoriedContacts = groupedContacts;
}

- (NSMutableArray *)_buildGroupedContactsContainer {
    // initiailize grouped contacts container
    NSMutableArray *groupedContacts = [NSMutableArray array];
    int i = 0;
    for (; i < 27; i++) {
        [groupedContacts addObject:[NSMutableArray array]];
    }
    
    return groupedContacts;
}

- (void)_buildTableViewSectionTitle {
    if (sectionTiltes_ == nil) {
        NSMutableArray *titles = [[NSMutableArray alloc] init];
        
        NSInteger base = 65; // (A-Z)
        for (int i = 0; i < 26; i++) {
            [titles addObject:[NSString stringWithFormat:@"%ld", (long)base++]];
        }
        
        [titles addObject:@"*"]; // *
        
        self.sectionTiltes = titles;
//        [titles release];
    }
}

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark tab state masks

//         #1(update first page)   #2(isLoading)   #3(has next page)
//                                                       0x000f
//                                     0x00f0
//                 0x0f00

- (BOOL)_hasUpdatedFirstPageWithTabMask:(unsigned int)mask {
    return (0x0f00 & mask) > 0;
}

- (BOOL)_isLoadingWithTabMask:(unsigned int)mask {
    return (0x00f0 & mask) > 0;
}

- (BOOL)_hasNextPageWithTabMask:(unsigned int)mask {
    return (0x000f & mask) > 0;
}

- (void)_changeTabMask:(unsigned int *)mask andBits:(unsigned int)val {
    *mask = *mask & val;
}

- (void)_changeTabMask:(unsigned int *)mask orBits:(unsigned int)val {
    *mask = *mask | val;
}

- (unsigned int)_currentSelectedTabMask {
    unsigned int mask = 0;
    if ([self _isFavoritedContactsTab]) {
        mask = personViewControllerFlags_.favoritedContactsMask;
        
    } else if ([self _isSearchContactsTab]) {
        mask = personViewControllerFlags_.searchContactsMask;
    }
    
    return mask;
}


////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark searching

- (void)_searchBarResignFirstResponder {
    if ([searchBar_ isFirstResponder] && [searchBar_ canResignFirstResponder]) {
        [searchBar_ resignFirstResponder];
    }
}

- (void)_willBeginSearching {
    if (personViewControllerFlags_.searching == 0) {
        personViewControllerFlags_.searching = 1;
        
        // reset force canncelled flag
        personViewControllerFlags_.forceCancelled = 0;
        
        selectedTabIndex_ = 0x03; // fake tab index
        
        [self _didChangeSearchingState:YES];
    }
}

- (void)_didFinishSearching {
    BOOL forceCancelled = NO;
    if (personViewControllerFlags_.forceCancelled == 1) {
        personViewControllerFlags_.forceCancelled = 0;
        
        forceCancelled = YES;
    }
    
    BOOL shouldChange = NO;
    if (forceCancelled || [searchBar_.text length] == 0) {
        shouldChange = YES;
    }
    
    if (shouldChange && personViewControllerFlags_.searching == 1) {
        personViewControllerFlags_.searching = 0;
        
        selectedTabIndex_ = 0x02;
        
        [self _didChangeSearchingState:NO];
        
        if (forceCancelled) {
            searchBar_.text = nil;
            
            [self _cancelSearchingRequests];
        }
    }
}

- (void)_shouldCancelSearch:(UIButton *)btn {
    personViewControllerFlags_.forceCancelled = 1; // mark as force cancelled
    
    if ([searchBar_ isFirstResponder]) {
        [self _searchBarResignFirstResponder];
        
    } else {
        // call did end editing manually when search bar is not on editing mode.
        [self searchBarTextDidEndEditing:searchBar_];
    }
}

- (void)_didChangeSearchingState:(BOOL)isSearching {
    if (isSearching) {
        
        // cancel the table view refresh state for other tabs if need
        [tableView_ finishedRefresh:YES];
        
       
        [self _setupCancelSearchingButton]; // setup navigation left bar button item
        
       
        
    } else {
        // self.navigationItem.leftBarButtonItem = tempLeftBarItem_;
        //self.navigationItem.rightBarButtonItem = tempRightBarItem_;
        //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
        //song.wang 2013-12-26
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                            target:nil action:nil];// autorelease];
        negativeSpacer.width = kLeftNegativeSpacerWidth;
        self.navigationItem.leftBarButtonItems = [NSArray
                                                  arrayWithObjects:negativeSpacer,tempLeftBarItem_, nil];
        
        
        
        
    }
    
    [UIView animateWithDuration:0.25
                     animations:^(void) {
                                             }
                     completion:^(BOOL finished) {
                       
                         // clear any cached objects
                         [self _clearSearchedContacts];
                         
                         [self _didChangeSelectedActionTab];
                     }];
}

- (void)_search:(BOOL)firstPage {
    NSString *q = searchBar_.text;
    if (q == nil || [q length] < 1) { // invalid keywords
        return;
    }
    
    if ([self _isLoadingWithTabMask:personViewControllerFlags_.searchContactsMask]) {
        // if there is any request on the queue, cancel it at first
        [self _cancelSearchingRequests];
        
        return;
    }
    
    unsigned int *mask = &personViewControllerFlags_.searchContactsMask;
    [self _changeTabMask:mask orBits:0x00f0];
    
    if (firstPage) { // is search results start from first page means start new search action
        searchContactsPageIndex_ = 1;
        
        // disable pull up action
        [self _changeTabMask:mask andBits:0x0ff0];
        
        // clear any cached objects
        [self _clearSearchedContacts];
        
        // clear the results and reload table
        [self _updateDisplayContacts:YES reload:YES];
    }
    
    if (firstPage) {
        [self _activityViewWithVisible:YES info:ASLocalizedString(@"RecommendViewController_Load")];
    }
    
   
    
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"q" stringValue:q]
      setParameter:@"page" integerValue:searchContactsPageIndex_]
     setParameter:@"count" stringValue:@"20"];
    
    __block KDFavoriedColleagueViewController *pvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (firstPage) {
            [pvc _activityViewWithVisible:NO info:nil];
        }
        
        if (pvc.searchContactsPageIndex > 1) {
            [pvc.tableView finishedLoadMore];
        }
        
        if ([response isValidResponse]) {
            if (results != nil) {
                NSArray *persons = results;
                
                pvc.searchContactsPageIndex += 1;
                
                BOOL hasNextPages = [persons count] == 20;
                if (hasNextPages) {
                    // active pull up action (has next page)
                    [pvc _changeTabMask:mask orBits:0x000f];
                    
                } else {
                    // disable pull up action
                    [pvc _changeTabMask:mask andBits:0x0ff0];
                }
                
                if ([pvc _isSearchContactsTab]) { // same tab
                    [pvc _appendContacts:persons to:&pvc->searchedContacts_ clear:NO update:YES reload:YES];
                    [pvc.tableView setBottomViewHidden:!hasNextPages];
                    
                    if (firstPage) {
                        [pvc _showNoContactsInfoIfNeed];
                    }
                }
            }else
            {
                [pvc _updateDisplayContacts:YES reload:YES];
            }
            
        } else {
            [pvc _reportNetworkErrorMessage:response];
        }
        
        [pvc _changeTabMask:mask andBits:0x0f0f];
        
        // release current view controller
//        [pvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/ab/:searchListSimple" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)_cancelSearchingRequests {
    [[KDRequestDispatcher globalRequestDispatcher] cancelRequestsWithAPIIdentifier:KDAPIABSearch];
}


////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark toggle action tab


- (BOOL)_isFavoritedContactsTab {
    return selectedTabIndex_ == 0x02;
}

- (BOOL)_isSearchContactsTab {
    return selectedTabIndex_ == 0x03;
}

- (void)_didChangeSelectedActionTab {
    // clear current display items
    [self _clearDisplayingContacts:YES];
    
    // step 2: clear any prompt info text or loading state
    unsigned int mask = [self _currentSelectedTabMask];
    BOOL hasNextPage = [self _hasNextPageWithTabMask:mask];
    BOOL loading = [self _isLoadingWithTabMask:mask];
    
    [tableView_ setBottomViewHidden:!hasNextPage];
    [self _activityViewWithVisible:loading info:(loading ? ASLocalizedString(@"RecommendViewController_Load") : nil)];
    
    // reload the data source for current tab
     if ([self _isFavoritedContactsTab]){
        [self _toggleToFavoritedContactsTab];
    }
}

- (void) reloadFromDB
{
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb) {
        id<KDABPersonDAO> personDAO = [[KDWeiboDAOManager globalWeiboDAOManager] ABPersonDAO];
        NSArray *persons = [personDAO queryABPersonsByType:KDABPersonTypeFavorited limit:500 database:fmdb];
        return persons;
        
    } completionBlock:^(id results) {
        NSArray *persons = results;
        if (persons != nil) {
            [self _groupFavoritedContacts:persons];
            [self _updateDisplayContacts:YES reload:YES];
        }
    }];
}

- (void)_toggleToFavoritedContactsTab {
    BOOL force = NO;
    if (![self _hasUpdatedFirstPageWithTabMask:personViewControllerFlags_.favoritedContactsMask]) {
        [self _changeTabMask:&personViewControllerFlags_.favoritedContactsMask orBits:0x0f00];
        force = YES;
        
        // TODO: change to async mode in the future please.
        [self reloadFromDB];
    }
    
    if (force || [searchedContacts_ count] == 0) {
        // reload the recently ABPersons
        [tableView_ setFirstInLoadingState];
        [self _loadABPersonWithType:KDABPersonTypeFavorited pageIndex:1 count:500];
        
    } else {
        [self _updateDisplayContacts:YES reload:YES];
    }
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark load the Address Book contacts

- (void)_loadABPersonWithType:(KDABPersonType)type pageIndex:(NSUInteger)pageIndex count:(NSUInteger)count {
    NSString *actionPath = nil;
    unsigned int *mask = NULL;
    actionPath = @"/ab/:favoritedListSimple";
    mask = &personViewControllerFlags_.favoritedContactsMask;
 
    [self _changeTabMask:mask orBits:0x00f0];
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"page" integerValue:pageIndex]
     setParameter:@"count" integerValue:count];
    
    __block KDFavoriedColleagueViewController *pvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [pvc _changeTabMask:mask andBits:0x0f0f];
        
        BOOL success = NO;
        if([response isValidResponse]) {
            if (results != nil) {
                success = YES;
                
                [pvc _didFinishLoadABPersons:results type:type pageIndex:pageIndex limit:count];
            }
        } else {
            [pvc _reportNetworkErrorMessage:response];
        }
        
        if (pageIndex == 1) {
            [pvc.tableView finishedRefresh:success];
            
        } else {
            [pvc.tableView finishedLoadMore];
        }
        
        // release current view controller
//        [pvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)_didFinishLoadABPersons:(NSArray *)persons type:(KDABPersonType)type
                      pageIndex:(NSUInteger)pageIndex limit:(NSUInteger)limit {
    BOOL isFirstPage = pageIndex == 1;
    NSUInteger count = [persons count];
    
    NSInteger tabIndex = 0;
    
    NSInteger *nextPagePtr = NULL;
    unsigned int *hasNextPagePtr = NULL;
    
    NSMutableArray *__strong*container = NULL;
    
    if(KDABPersonTypeFavorited == type) {
        tabIndex = 2;
        
        container = &favoriedContacts_;
    }
    
    if (nextPagePtr != NULL) {
        *nextPagePtr += 1;
    }
    
    BOOL hasNextPage = NO;
    if (hasNextPagePtr != NULL) {
        hasNextPage = count == limit;
        
        unsigned int val = hasNextPage ? 0x0fff : 0x0ff0;
        [self _changeTabMask:hasNextPagePtr andBits:val];
    }
    
    BOOL sameTab = selectedTabIndex_ == tabIndex;
    
    if (KDABPersonTypeFavorited == type) {
        [self _groupFavoritedContacts:persons];
        [self _updateDisplayContacts:YES reload:NO];
        
    } else {
        [self _appendContacts:persons to:container clear:isFirstPage update:YES reload:YES];
    }
    
    if (sameTab) {
        if (!hasNextPage) {
            [tableView_ setBottomViewHidden:YES];
            
        } else {
            [tableView_ finishedLoadMore];
        }
        
        [tableView_ reloadData];
        [self refreshTableViewFooterView];
        
        
        if (isFirstPage) {
            [self _showNoContactsInfoIfNeed]; // show prompt info if need
        }
    }
    
    // update cache if current page is 1
    if (isFirstPage) {
        // save ab persons
        [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
            id<KDABPersonDAO> personDAO = [[KDWeiboDAOManager globalWeiboDAOManager] ABPersonDAO];
            [personDAO saveABPersons:persons type:type clear:YES database:fmdb rollback:rollback];
            
            return nil;
            
        } completionBlock:nil];
    }
}

- (void)refreshTableViewFooterView {
    if([self numberOfSectionsInTableView:self.tableView] == 0) {
        [self setBackgroud];
    }else {
        self.tableView.backgroundView = nil;
    }
}

- (void) setBackgroud {
    UIView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds ];// autorelease];
    [backgroundView setUserInteractionEnabled:YES];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_placeholder_v2.png"]];// autorelease];
    [bgImageView sizeToFit];
    bgImageView.center = CGPointMake(backgroundView.bounds.size.width * 0.5f, 137.5f);
    
    [backgroundView addSubview:bgImageView];
    backgroundView.backgroundColor = RGBCOLOR(241, 242, 245);
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(bgImageView.frame) + 5.0f, self.view.bounds.size.width, 15.0f)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = MESSAGE_NAME_COLOR;
    label.font = [UIFont systemFontOfSize:15.0f];
    label.text = NSLocalizedString(@"AB_NO_MATCHED_CONTACTS", @"");
    [backgroundView addSubview:label];
//    [label release];

    
    
    
    [self.tableView setBackgroundView:backgroundView];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
}
//////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIViewController navigation category method

- (void)viewControllerWillDismiss {
    // if navigate to previous view controller, If search bar is first responder now,
    // Then the keyboard will hide notification will sending from notification center.
    // Make current object ignore the delegate methods from search bar after it was dealloced
    searchBar_.delegate = nil;
    
    // cancel the requests
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

#pragma mark -
#pragma mark viewControllerDidClosedToLeft
- (void)viewControllerDidSlidedToLeft {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    //KD_RELEASE_SAFELY(searchBar_);
    
    //KD_RELEASE_SAFELY(tableView_);
   
    
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(promptInfoLabel_);
    //KD_RELEASE_SAFELY(maskView_);
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(actionHelper_);
    //KD_RELEASE_SAFELY(favoriedContacts_);
    //KD_RELEASE_SAFELY(searchedContacts_);
    
    //KD_RELEASE_SAFELY(displayContacts_);
    //KD_RELEASE_SAFELY(sectionTiltes_);
    
    //KD_RELEASE_SAFELY(searchBar_);
    //KD_RELEASE_SAFELY(tableView_);
    
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(promptInfoLabel_);
    //KD_RELEASE_SAFELY(maskView_);
    
    //KD_RELEASE_SAFELY(tempLeftBarItem_);
  
    
    //[super dealloc];
}

@end
