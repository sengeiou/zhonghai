//
//  KDRecentlyColleagueViewController.m
//  kdweibo
//
//  Created by gordon_wu on 13-12-5.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//
#define  CELLIMAGE_TAG   999
#define  CELLCONTENT_TAG 998
#define  CELLLINE_TAG    997
#define  CELLARROW_TAG   996

#import "KDCommon.h"
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
#import "KDManagerContext.h"

#import "KDRecentlyColleagueViewController.h"

#import "KDALLColleagueViewController.h"
#import "KDFavoriedColleagueViewController.h"
#import "LeveyTabBarController.h"
#import "KDInvitePhoneContactsViewController.h"
#import "KDAppViewCell.h"

@interface KDRecentlyColleagueViewController ()<KDSearchBarDelegate, KDABPersonActionHelperDelegate, KDRefreshTableViewDelegate, KDRefreshTableViewDataSource, KDRequestWrapperDelegate>

@property(nonatomic, retain) KDABPersonActionHelper *actionHelper;

@property(nonatomic, retain) NSMutableArray *recentlyContacts;
@property(nonatomic, retain) NSMutableArray *searchedContacts;

@property(nonatomic, retain) NSMutableArray *displayContacts;


@property(nonatomic, assign) NSInteger searchContactsPageIndex;

@property(nonatomic, retain) KDSearchBar *searchBar;
@property(nonatomic, retain) KDRefreshTableView *tableView;


@property(nonatomic, retain) KDActivityIndicatorView *activityView;
@property(nonatomic, retain) UILabel *promptInfoLabel;
@property(nonatomic, retain) UIView *maskView;

@property(nonatomic, retain) UIBarButtonItem *tempLeftBarItem; // use to cache navigation left bar item


@end


@implementation KDRecentlyColleagueViewController{
@private
    NSInteger selectedTabIndex_;
    NSInteger recentlyContactsPageIndex_;
    
    struct {
        unsigned int initialized:1;
        
        unsigned int searching:1;
        unsigned int forceCancelled:1;
        
        unsigned int recentlyContactsMask;
        unsigned int searchContactsMask;
        
    }personViewControllerFlags_;
}

@synthesize actionHelper=actionHelper_;
@synthesize recentlyContacts=recentlyContacts_;
@synthesize searchedContacts=searchedContacts_;
@synthesize displayContacts=displayContacts_;


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
        
        actionHelper_          = [[KDABPersonActionHelper alloc] initWithViewController:self];
        actionHelper_.delegate = self;
        selectedTabIndex_ = 0;
        
        recentlyContactsPageIndex_ = 1;
        searchContactsPageIndex_   = 1;
        
        personViewControllerFlags_.initialized          = 0;
        personViewControllerFlags_.searching            = 0;
        personViewControllerFlags_.forceCancelled       = 0;
        personViewControllerFlags_.recentlyContactsMask = 0x0000;
        personViewControllerFlags_.searchContactsMask   = 0x0f00;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"AB_ADDRESS_BOOK", @"");
    self.view.backgroundColor = RGBCOLOR(237,237,237);
    
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //2013-12-26 song.wang
    
    
    self.tempLeftBarItem = [self.navigationItem.leftBarButtonItems lastObject];
    
    
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
    

    
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
    
    
    // long press gesture recognizer
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_didLongPress:)];
    longPressGestureRecognizer.minimumPressDuration = 0.3;
    [tableView_ addGestureRecognizer:longPressGestureRecognizer];
//    [longPressGestureRecognizer release];
    
    
    KDCommunity *current = [KDManagerContext globalManagerContext].communityManager.currentCommunity;
    if(current.isAdmin && current.communityType == KDCommunityTypeTeam) {
        [self setRightItem];
    }
}

- (void)setRightItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"colleague_add_contact_n_v3.png"];
    UIImage *hlImage = [UIImage imageNamed:@"colleague_add_contact_hl_v3.png"];

    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:hlImage forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(invitePhoneContacts:) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    CGFloat titltWidth = CGRectGetWidth(btn.titleLabel.frame) - 5.f;
    CGFloat imageWidth = CGRectGetWidth(btn.imageView.frame) + 6.f;
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, titltWidth, 0, -titltWidth)];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth)];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:btn];// autorelease];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil] ;//autorelease];
    negativeSpacer.width = kRightNegativeSpacerWidth - 5.0f;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, rightItem];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger num = 0;
    if(selectedTabIndex_ == 0x03){
        if([displayContacts_ count]==0)
        {
            num = 0;
        }else{
            num =(displayContacts_ != nil) ? 1 : 0;
        }
        
    }else{
        if([displayContacts_ count]==0){
            num = 1;
        }else{
            num =(displayContacts_ != nil) ? 2 : 1;
        }
        
    }
    
    return num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if ((section == 0)&&(selectedTabIndex_ != 0x03)) {
        rows = 2;
    } else {
        NSArray *items = [self _datasourceInSection:0];
        rows = [items count];
    }
    
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if(section==0){
        height = 0;
    }else{
        height = 25.0f;
    }
    
    return height;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString * title      = nil;
    UIView   * headerView = nil;
    if(section==1){
        
        title  = [NSString stringWithFormat:ASLocalizedString(@"KDRecentlyColleagueViewController_Common")];
        UILabel *titleLabel        = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, tableView.bounds.size.width - 10.0f, 25.0f)];
        titleLabel.textAlignment   = NSTextAlignmentLeft;
        titleLabel.font            = [UIFont systemFontOfSize:14.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor       = RGBCOLOR(109,109,109);
        titleLabel.text            = title;
        
        UIImage *separatorImage = [UIImage imageNamed:@"address_book_separator_line_v2.png"];
        separatorImage = [separatorImage stretchableImageWithLeftCapWidth:1 topCapHeight:1];
        UIImageView *separatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
        
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, 25.0f)];// autorelease];
        [headerView addSubview:titleLabel];
        headerView.backgroundColor = MESSAGE_BG_COLOR;
//        [titleLabel release];
        
        [headerView addSubview:separatorImageView];
        separatorImageView.frame = CGRectMake(0.0f, 25.0f - 1.0f, tableView.bounds.size.width, 1.0f);
//        [separatorImageView release];
    }
    
    
    return headerView;
}



- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifier1 = @"Cell1";
    UITableViewCell * cell   = nil;
    
    if((indexPath.section == 1)||(selectedTabIndex_ ==0x03)){
        cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell  = [[KDABPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
            cell.backgroundView = nil;
            cell.backgroundColor        = RGBCOLOR(250,250,250);
        }
    }else{
        cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            cell  = [[KDAppViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];// autorelease];
            
            UIImageView * cellImageView    = [[UIImageView alloc] initWithFrame:CGRectZero];
            cellImageView.tag              = CELLIMAGE_TAG;
            [cell.contentView addSubview:cellImageView];
            cell.backgroundView = nil;
            cell.backgroundColor           = RGBCOLOR(250,250,250);
            
    
            
            //KD_RELEASE_SAFELY(cellImageView);
          
    
        }
    }
    
    
    cell.accessoryType = nil;
    
    if((indexPath.section == 0)&&(selectedTabIndex_ ==0x00)){
        ((KDAppViewCell *) cell).iconImageView.image = nil;
        cell.textLabel.font  = [UIFont systemFontOfSize:17];
        
        UIImageView * cellImageView = (UIImageView *)[cell.contentView viewWithTag:CELLIMAGE_TAG];
        cellImageView.frame         = CGRectMake(10,6,48,48);
        
        UIImageView * separatorImageView  = (UIImageView *)[cell.contentView viewWithTag:CELLLINE_TAG];
        separatorImageView.frame          = CGRectMake(0.0f, 60.0f - 1.0f, self.view.bounds.size.width, 1.0f);
        
    
        if(indexPath.row == 0){
            cell.textLabel.text    = ASLocalizedString(@"全部");
           
            cellImageView.image  = [UIImage imageNamed:@"icon_allContact.png"];
        }
        
        if(indexPath.row == 1){
            cell.textLabel.text    = [NSString stringWithFormat:ASLocalizedString(@"KDABActionTabBar_tips_1")];
            cellImageView.image  = [UIImage imageNamed:@"icon_favoried.png"];
        }
        
               
        
    }else
    {
        
        NSArray *persons                 = [self _datasourceInSection:0];
        NSLog(@"%ld",(long)indexPath.row);
        KDABPerson *person               = [persons objectAtIndex:indexPath.row];
        ((KDABPersonCell *)cell).person  = person;
        [((KDABPersonCell *)cell) update:YES];
        [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:((KDABPersonCell *)cell).avatarView];
        
    }
    
    UIView *selectBgView = [[UIView alloc] initWithFrame:CGRectZero] ;//autorelease];
    selectBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    selectBgView.backgroundColor = RGBCOLOR(26, 133, 255);
    cell.selectedBackgroundView = selectBgView;
    

    return cell;
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if((indexPath.section == 1)||(selectedTabIndex_ == 0x03)){
        NSArray *persons = [self _datasourceInSection:0];
        KDABPerson *person = [persons objectAtIndex:indexPath.row];
        
//        ProfileViewController *pvc = [[[ProfileViewController alloc] initWithUserId:person.userId andSelectedIndex:3] autorelease];
//        [self.navigationController pushViewController:pvc animated:YES];
        [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewControllerByUserId:person.userId sender:tableView];
        
    }
    if((indexPath.section == 0)&&(selectedTabIndex_ == 0x00)){
        
        if(indexPath.row ==0){
            KDALLColleagueViewController * allViewController = [[KDALLColleagueViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:allViewController animated:YES];
            //KD_RELEASE_SAFELY(allViewController);
        }
        
        if(indexPath.row ==1){
            KDFavoriedColleagueViewController * favoriedViewController =[[KDFavoriedColleagueViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:favoriedViewController animated:YES];
            //KD_RELEASE_SAFELY(favoriedViewController);
        }
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = RGBCOLOR(250, 250, 250);
}

#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE

- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView {
    
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    if ([self _isRecentlyContactsTab]) {
        [self _loadABPersonWithType:KDABPersonTypeRecently pageIndex:recentlyContactsPageIndex_ count:20];
        
    } else if ([self _isSearchContactsTab]) {
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
    //2013-12-26 song.wang
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

- (void) showToolBar:(BOOL) show
{
    if(show){
        [[NSNotificationCenter defaultCenter] postNotificationName:kKDModalViewShowNotification object:nil];
    }else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kKDModalViewHideNotification object:nil];
    }
    
}


#pragma mark -
#pragma mark private methods
- (void)cancleMenuClicked
{
    if(selectedTabIndex_ == 0x00){
        [self showToolBar:NO];
    }
    
}


- (void)_didLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if(UIGestureRecognizerStateBegan == gestureRecognizer.state){
        CGPoint anchorPoint = [gestureRecognizer locationInView:tableView_];
        NSIndexPath *indexPath = [tableView_ indexPathForRowAtPoint:anchorPoint];
        if(indexPath != nil){
            if((indexPath.section==1)&&(selectedTabIndex_== 0x00)){
                [self showToolBar:YES];
                NSArray *persons = [self _datasourceInSection:0];
                KDABPerson *person = [persons objectAtIndex:indexPath.row];
                [actionHelper_ showContactMainActionMenu:person];
                
            }
            else if((indexPath.section==0)&&(selectedTabIndex_== 0x03))
            {
                NSArray *persons = [self _datasourceInSection:0];
                KDABPerson *person = [persons objectAtIndex:indexPath.row];
                [actionHelper_ showContactMainActionMenu:person];
                
            }
            
           
        }
    }
}



////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark displaying data source

- (NSArray *)_datasourceInSection:(NSInteger)section {
    return [displayContacts_ objectAtIndex:section];
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
        //KD_RELEASE_SAFELY(searchedContacts_);
    }
}

- (void)_appendContacts:(NSArray *)persons to:(NSMutableArray * __strong*)container clear:(BOOL)clear
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
    
    if ([self _isRecentlyContactsTab]) {
        if (recentlyContacts_ != nil) {
            [displayContacts_ addObject:recentlyContacts_];
        }
        
    }  else if ([self _isSearchContactsTab]) {
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

- (NSMutableArray *)_buildGroupedContactsContainer {
    // initiailize grouped contacts container
    NSMutableArray *groupedContacts = [NSMutableArray array];
    int i = 0;
    for (; i < 27; i++) {
        [groupedContacts addObject:[NSMutableArray array]];
    }
    
    return groupedContacts;
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
    if ([self _isRecentlyContactsTab]) {
        mask = personViewControllerFlags_.recentlyContactsMask;
        
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
        selectedTabIndex_ = 0x03;
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
        
        selectedTabIndex_ = 0x00;
        
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
        [self showToolBar:YES];
        // cancel the table view refresh state for other tabs if need
        [tableView_ finishedRefresh:YES];
        
        [self _setupCancelSearchingButton]; // setup navigation left bar button item
        
    } else {
        [self showToolBar:NO];
        // self.navigationItem.leftBarButtonItem = tempLeftBarItem_;
        //self.navigationItem.rightBarButtonItem = tempRightBarItem_;
        //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
        //2013-12-26 song.wang
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];// autorelease];
        negativeSpacer.width = kLeftNegativeSpacerWidth;
        self.navigationItem.leftBarButtonItems = [NSArray
                                                  arrayWithObjects:negativeSpacer,self.tempLeftBarItem, nil];

    }
    
    [UIView animateWithDuration:0.25
                     animations:^(void) {
                         
                     }
                     completion:^(BOOL finished) {
                         if (isSearching) {
                             
                         }
                         
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
    
    __block KDRecentlyColleagueViewController *pvc = self;// retain];
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
                
                // same tab
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
- (BOOL)_isRecentlyContactsTab {
    return selectedTabIndex_ == 0x00;
}

- (BOOL)_isSearchContactsTab {
    return selectedTabIndex_ == 0x03;
}
////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark toggle action tab

- (void)_didChangeSelectedActionTab {
    // clear current display items
    [self _clearDisplayingContacts:YES];
    
    // step 2: clear any prompt info text or loading state
    unsigned int mask = [self _currentSelectedTabMask];
    BOOL hasNextPage = [self _hasNextPageWithTabMask:mask];
    BOOL loading = [self _isLoadingWithTabMask:mask];
    
    [tableView_ setBottomViewHidden:!hasNextPage];
    [self _activityViewWithVisible:loading info:(loading ? ASLocalizedString(@"RecommendViewController_Load") : nil)];
    
    if ([self _isRecentlyContactsTab]) {
        [self _toggleToRecentlyContactsTab];
    }
    
}


- (void) reloadFromDB
{
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb) {
        id<KDABPersonDAO> personDAO = [[KDWeiboDAOManager globalWeiboDAOManager] ABPersonDAO];
        NSArray *persons = [personDAO queryABPersonsByType:KDABPersonTypeRecently limit:20 database:fmdb];
        return persons;
        
    } completionBlock:^(id results) {
        NSArray *persons = results;
        if (persons != nil) {
            [self _appendContacts:persons to:&recentlyContacts_ clear:YES update:YES reload:YES];
        }
    }];

}

- (void)_toggleToRecentlyContactsTab {
    BOOL force = NO;
    if (![self _hasUpdatedFirstPageWithTabMask:personViewControllerFlags_.recentlyContactsMask]) {
        [self _changeTabMask:&personViewControllerFlags_.recentlyContactsMask orBits:0x0f00];
        force = YES;
        
        // TODO: change to async mode in the future please.
        [self reloadFromDB];
    }
    
    if (force || [recentlyContacts_ count] == 0) {
        // reload the recently ABPersons
        [tableView_ setFirstInLoadingState];
        [self _loadABPersonWithType:KDABPersonTypeRecently pageIndex:1 count:20];
        
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
    
    actionPath = @"/ab/:recentlyListSimple";
    mask = &personViewControllerFlags_.recentlyContactsMask;
        
    [self _changeTabMask:mask orBits:0x00f0];
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"page" integerValue:pageIndex]
     setParameter:@"count" integerValue:count];
    
    __block KDRecentlyColleagueViewController *pvc = self;// retain];
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
  
    NSInteger *nextPagePtr = NULL;
    unsigned int *hasNextPagePtr = NULL;
    
    NSMutableArray * __strong* container = NULL;
    
    if (KDABPersonTypeRecently == type) {
        
        nextPagePtr = &recentlyContactsPageIndex_;
        
        container = &recentlyContacts_;
        
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
    
    BOOL sameTab = YES;
    
    [self _appendContacts:persons to:container clear:isFirstPage update:YES reload:YES];
    
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

- (void)invitePhoneContacts:(UIButton *)sender {
    KDInvitePhoneContactsViewController *vc = [[KDInvitePhoneContactsViewController alloc] initWithNibName:nil bundle:nil];// autorelease];
    vc.isNeedFilter = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark tabbar delegate
- (void)tabBarSelectedOnce
{
    personViewControllerFlags_.recentlyContactsMask = 0x0000;
    [self _didChangeSelectedActionTab];
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
    
    //KD_RELEASE_SAFELY(recentlyContacts_);
    //KD_RELEASE_SAFELY(searchedContacts_);
    
    //KD_RELEASE_SAFELY(displayContacts_);
    
    //KD_RELEASE_SAFELY(searchBar_);
    //KD_RELEASE_SAFELY(tableView_);
    
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(promptInfoLabel_);
    //KD_RELEASE_SAFELY(maskView_);
    
    //KD_RELEASE_SAFELY(tempLeftBarItem_);
   
    
    //[super dealloc];
}

@end

