//
//  XTContactContentCollectionController.m
//  kdweibo
//
//  Created by weihao_xu on 14-4-21.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTContactContentCollectionController.h"
#import "XTContactPersonViewCell.h"
#import "KDRefreshTableView.h"
#import "KDSearchBar.h"
#import "XTPersonDetailViewController.h"
#import "XTContactOrganPersonCell.h"

@interface XTContactContentCollectionController () <KDRefreshTableViewDataSource,KDRefreshTableViewDelegate,KDSearchBarDelegate>{
    
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
@property (nonatomic, retain) NSArray *recentContactsArray;
@property (nonatomic, retain) NSArray *collectionsArray;
@property(nonatomic, retain) NSMutableArray *favoriedContacts;
@property(nonatomic, retain) NSMutableArray *searchedContacts;

@property(nonatomic, retain) NSMutableArray *displayContacts;
@property(nonatomic, retain) NSMutableArray *sectionTiltes;

@property(nonatomic, assign) NSInteger searchContactsPageIndex;

@property(nonatomic, retain) KDSearchBar *searchBar;
@property(nonatomic, retain) KDRefreshTableView *refreshTableView;

@property(nonatomic, retain) KDActivityIndicatorView *activityView;
@property(nonatomic, retain) UILabel *promptInfoLabel;
@property(nonatomic, retain) UIView *maskView;
@end

@implementation XTContactContentCollectionController
@synthesize recentContactsArray = recentContactsArray_;
@synthesize collectionsArray = collectionsArray_;
@synthesize refreshTableView = refreshTableView_;

@synthesize favoriedContacts=favoriedContacts_;
@synthesize searchedContacts=searchedContacts_;

@synthesize displayContacts=displayContacts_;
@synthesize sectionTiltes=sectionTiltes_;

@synthesize searchContactsPageIndex=searchContactsPageIndex_;

@synthesize searchBar=searchBar_;
@synthesize activityView=activityView_;
@synthesize promptInfoLabel=promptInfoLabel_;
@synthesize maskView=maskView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = BOSCOLORWITHRGBA(0xededed, 1.0);
    self.navigationItem.title = ASLocalizedString(@"XTContactContentCollectionController_MyCollect");
    
    KDSearchBar *searchBar = [[KDSearchBar alloc]initWithFrame:CGRectMake(0, 0, ScreenFullWidth, 50)];
    searchBar_ = searchBar;
    searchBar_.placeHolder = NSLocalizedString(@"AB_SEARCH_CONTACTS_PLACEHOLDER", @"");
    searchBar_.delegate = self;
    searchBar_.showsCancelButton = NO;
    searchBar_.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:searchBar_];
    
    KDRefreshTableView *tableView = [[KDRefreshTableView alloc]initWithFrame:CGRectMake(0.0, 50.0, ScreenFullWidth, ScreenFullHeight - NavigationBarHeight)
                                                      kdRefreshTableViewType:KDRefreshTableViewType_None style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource =self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.backgroundColor = BOSCOLORWITHRGBA(0xededed, 1.0);
    refreshTableView_ = tableView;
    [self.view addSubview:refreshTableView_];
    
    
    
    
    [self initContentsWithShowRecent:NO showFav:YES];
    if(collectionsArray_){
        [self _groupFavoritedContacts:collectionsArray_];
        [self _buildTableViewSectionTitle];
        [self _updateDisplayContacts:YES reload:YES];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark UITableViewDataSource And UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return (displayContacts_ != nil) ? [displayContacts_ count] : 0;

}

- (NSArray *)_datasourceInSection:(NSInteger)section {
    return [displayContacts_ objectAtIndex:section];
}
- (BOOL)_hasContactsInSection:(NSInteger)section {
    NSArray *sectionContacts= [self _datasourceInSection:section];
    return sectionContacts != nil && [sectionContacts count] > 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    if ([self _isFavoritedContactsTab]) {
        rows = [(NSArray *)[displayContacts_ objectAtIndex:section] count];
    } else {
        NSArray *items = [self _datasourceInSection:section];
        rows = [items count];
    }
    
    return rows;
}

#define XTContactPersonViewCellIdentifier @"XTContactPersonViewCellIdentifier"
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    XTContactOrganPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:XTContactPersonViewCellIdentifier];
    if(!cell){
        cell = [[XTContactOrganPersonCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:XTContactPersonViewCellIdentifier];//autorelease];
        [cell.accessoryImageView setHidden:YES];
    }
    cell.person = [[displayContacts_ objectAtIndex:section]objectAtIndex:row];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PersonSimpleDataModel *simpleData =  [[displayContacts_ objectAtIndex:[indexPath section]]objectAtIndex:[indexPath row]];
    XTPersonDetailViewController*personDetail = [[XTPersonDetailViewController alloc]initWithSimplePerson:simpleData with:NO];// autorelease];
    personDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personDetail animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(![self _hasContactsInSection:section] || ![self _isFavoritedContactsTab] ){
        return 0;
    }
    return 20.f;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return ([self _isFavoritedContactsTab]) ? sectionTiltes_ : nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(![self _hasContactsInSection:section] || ![self _isFavoritedContactsTab] ){
        return nil;
    }
    NSString *title = [sectionTiltes_ objectAtIndex:section];

    UILabel *view = [[UILabel alloc]initWithFrame:CGRectZero] ;//autorelease];
    view.text = [NSString stringWithFormat:@"  %@",title];
    view.font = [UIFont systemFontOfSize:12.f];
    view.textColor = [UIColor colorWithRed:128/255.0f green:128/255.0f blue:128/255.0f alpha:1.0f];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = RGBCOLOR(237, 237, 237);
    return view;
}

#pragma mark -
#pragma mark KDSearchBar Delegate

- (void)searchBarCancelButtonClicked:(KDSearchBar *)searchBar{

    [searchBar resignFirstResponder];
}
- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar{
    [self _searchObject:searchBar.text];
    [self _maskViewWithVisible:NO];
    if([searchBar canResignFirstResponder] && [searchBar isFirstResponder]){
        [searchBar resignFirstResponder];
    }
}

- (void)searchBarTextDidBeginEditing:(KDSearchBar *)searchBar{
    [self searchBarDidBeginEditingAction];
    [self _maskViewWithVisible:YES];
    
}
- (void)searchBarTextDidEndEditing:(KDSearchBar *)searchBar{
    [self searchBarDidEndEditingAction];
    [self _maskViewWithVisible:NO];
}

- (void)searchBar:(KDSearchBar *)searchBar textDidChange:(NSString *)searchText{
//    [self _searchObject:searchText];
}


- (void)searchBarDidBeginEditingAction{
    selectedTabIndex_ = 0x03;
    
}

- (void)searchBarDidEndEditingAction{
    selectedTabIndex_ = 0x02;
//    [self _updateDisplayContacts:YES reload:YES];
}

- (void)_searchObject:(NSString *)searchtext{
    
    if(searchedContacts_ == nil){
        searchedContacts_ = [[NSMutableArray alloc]init];
    }
    else{
        [searchedContacts_ removeAllObjects];
    }
    for(PersonSimpleDataModel *person in collectionsArray_){
        if([person.defaultPhone rangeOfString:searchtext].location != NSNotFound
           || [person.personName rangeOfString:searchtext].location != NSNotFound
           || [person.fullPinyin rangeOfString:searchtext].location != NSNotFound){
            [searchedContacts_ addObject:person];
        }
    }
    [self _updateDisplayContacts:YES reload:YES];
}
#pragma mark -
#pragma mark private method
- (void)initContentsWithShowRecent:(BOOL)showRecent showFav:(BOOL)showFav
{
    //展开最近联系人
    if (showRecent) {
        NSArray *recentPersons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryRecentPersonsWithLimitNumber:30 isContainPublic:YES];
        
        if ([recentPersons count] > 0) {
            self.recentContactsArray = recentPersons;
        } else {
            //TODO可以添加没有最近联系人的信息
        }
    }
    else if(recentContactsArray_){
        //KD_RELEASE_SAFELY(recentContactsArray_);
    }
    
    //展开我的收藏
    if (showFav) {
        NSArray *favPersons = [[XTDataBaseDao sharedDatabaseDaoInstance] queryFavPersons];
        if ([favPersons count] > 0) {
            self.collectionsArray = favPersons;
        } else {
            //TODO可以添加没有收藏联系人的信息
        }
    }
    else if(collectionsArray_){
        //KD_RELEASE_SAFELY(collectionsArray_);
    }
}


- (BOOL)_isFavoritedContactsTab {
    return selectedTabIndex_ == 0x02;
}

- (BOOL)_isSearchContactsTab {
    return selectedTabIndex_ == 0x03;
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
        [refreshTableView_ reloadData];
        [self refreshTableViewFooterView];
        
        // No matter there is prompt info or not, just dismiss it
//        [self _showPromptInfo:NO info:nil];
    }
}

- (void)refreshTableViewFooterView {
    if([self numberOfSectionsInTableView:self.refreshTableView] == 0) {
        [self setBackgroud];
    }else {
        self.refreshTableView.backgroundView = nil;
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
    
    
    
    
    [self.refreshTableView  setBackgroundView:backgroundView];
    [self.refreshTableView setBackgroundColor:[UIColor clearColor]];
}

- (void)_groupFavoritedContacts:(NSArray *)persons {
    NSUInteger count = [persons count];
    if (count < 0x01) {
        return;
    }
    
    // initiailize grouped contacts container
    NSMutableArray *groupedContacts = [self _buildGroupedContactsContainer];
    NSUInteger wildcardIdx = [groupedContacts count] - 1; // the wildcard(*) index
    
    for(PersonSimpleDataModel *p in persons) {
        NSUInteger index = [p.personName convertFirstCharacterToAZIndex];
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


- (void)_maskViewWithVisible:(BOOL)visible {
    if (maskView_ == nil) {
        CGRect rect = refreshTableView_.frame;
        maskView_ = [[UIView alloc] initWithFrame:rect];
        maskView_.backgroundColor = MESSAGE_BG_COLOR;
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

- (void)_searchBarResignFirstResponder {
    if ([searchBar_ isFirstResponder] && [searchBar_ canResignFirstResponder]) {
        [searchBar_ resignFirstResponder];
    }
}

- (void)dealloc{
    //KD_RELEASE_SAFELY(searchBar_);
    //KD_RELEASE_SAFELY(maskView_);
    //KD_RELEASE_SAFELY(refreshTableView_);
    //KD_RELEASE_SAFELY(sectionTiltes_);
    //KD_RELEASE_SAFELY(displayContacts_);
    //KD_RELEASE_SAFELY(favoriedContacts_);
    //KD_RELEASE_SAFELY(searchedContacts_);
    //KD_RELEASE_SAFELY(collectionsArray_);
    //KD_RELEASE_SAFELY(recentContactsArray_);
    //KD_RELEASE_SAFELY(activityView_);
    //[super dealloc];
}

@end
