//
//  XTContentViewController.m
//  XT
//
//  Created by Gil on 13-7-19.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTContentViewController.h"
#import "T9.h"
#import "MBProgressHud.h"
#import "ContactClient.h"
#import "SimplePersonListDataModel.h"
#import "BOSSetting.h"

@interface XTContentViewController ()<UISearchBarDelegate,MBProgressHUDDelegate>
{
    BOOL _canSearch;
    MBProgressHUD * _hud;
}
@property (nonatomic, retain) NSArray *collectionsArray;
@property(nonatomic, retain) NSMutableArray *defaultContacts;
@property(nonatomic, retain) NSMutableArray *searchedContacts;


@property(nonatomic, retain) NSMutableArray *sectionTitles;

@property(nonatomic, retain) UILabel *promptInfoLabel;
@property(nonatomic, retain) UIView *maskView;
@property (nonatomic,retain) ContactClient *personSearchClient;

@end

@implementation XTContentViewController
@synthesize collectionsArray = collectionsArray_;

@synthesize defaultContacts=defaultContacts_;
@synthesize searchedContacts=searchedContacts_;
@synthesize sectionTitles = sectionTitles_;
@synthesize displayContacts = displayContacts_;
@synthesize tableView = tableView_;
@synthesize kdSearchBar = kdSearchBar_;
@synthesize maskView = maskView_;
@synthesize leftBarItems = leftBarItems_;
@synthesize isFromConversation = isFromConversation_;
@synthesize personSearchClient = personSearchClient_;

- (id)init
{
    self = [super init];
    if (self) {
        isFromConversation_ = NO;
        self.isFilterTeamAcc = NO;
    }
    return self;
}

- (id)initWithInitContents
{
    self = [super init];
    if (self) {
        [self initContents];
    }
    return self;
}

- (void)initialize{
    needsToLayoutTableView_ = 1;
    state_ = KDContactViewStateNormal;
    
    personViewControllerFlags_.initialized = 0;
    
    personViewControllerFlags_.searching = 0;
    personViewControllerFlags_.forceCancelled = 0;
    
    personViewControllerFlags_.favoritedContactsMask = 0x0000;
    personViewControllerFlags_.searchContactsMask = 0x0f00;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = ASLocalizedString(@"XTContactContentViewController_Contact");
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    [self initialize];
    CGRect frame = CGRectMake(0.0, kd_StatusBarAndNaviHeight, CGRectGetWidth(self.view.frame), 44.0);
    kdSearchBar_ = [[KDSearchBar alloc] initWithFrame:frame];
    kdSearchBar_.showsCancelButton = NO;
    kdSearchBar_.delegate = self;
//    [kdSearchBar_ setCustomPlaceholder:ASLocalizedString(@"搜索姓名/拼音/电话")];
    [self.view addSubview:kdSearchBar_];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(kdSearchBar_.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(kdSearchBar_.frame) - 49 - kd_BottomSafeAreaHeight) style:UITableViewStylePlain];
    tableView.backgroundColor = self.view.backgroundColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.sectionIndexColor = FC1;
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadContents];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.leftBarItems == nil) {
        self.leftBarItems = self.navigationItem.leftBarButtonItems;
    }
    
    if(state_ == KDContactViewStateSearch){
        [self _setupCancelSearchingButton:YES];
    }
}


#pragma mark - contents

- (void)initContents
{
    self.contents = [NSMutableArray array];
}

- (void)reloadContents
{
    [self initContents];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

#pragma mark -
#pragma mark UISearchBar Delegate

- (void)searchBarTextDidEndEditing:(KDSearchBar *)searchBar{
    if(searchBar.text.length > 0){
        return;
    }
    [self searchBarDidEndEditingAction];
    [self _maskViewWithVisible:NO];
}

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

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    [self searchBarDidBeginEditingAction];
    if([searchBar.text isEqualToString:@""])
    {
        [KDEventAnalysis event:event_contact_search];
        //第一次点击触发搜索界面
        [self _maskViewWithVisible:YES];
        __block BOOL *finishFlag = &_canSearch;
        [[T9 sharedInstance] firstInitial:^(BOOL isInitial) {
            if(isInitial)
            {
                [self toast:ASLocalizedString(@"XTContentViewController_Wait")];
            }
        }
                             initFinished:^() {
                                 *finishFlag = YES;
                                 [self toastClose];
                             }];
    }
}

- (void)toast:(NSString *)msg
{
    if(_hud == nil)
    {
        _hud = [[MBProgressHUD alloc] initWithView:maskView_];
        [maskView_ addSubview:_hud];
    }
    _hud.mode = MBProgressHUDModeText;
    _hud.yOffset = -1 * (maskView_.frame.size.height - 70) / 2;
    _hud.labelText = msg;
    _hud.delegate = self;
    [_hud show:YES];
}

- (void)toastClose
{
    if(_hud)
        [_hud hide:YES];
}

- (void)umeng:(NSString *)text
{
    if (text.length == 0) {
        return;
    }
    
    T9SearchTextType type = [T9 calcSearchType:text];
    if (type == T9SearchTextChinese) {
        [KDEventAnalysis event:event_contact_search_type attributes:@{label_contact_search_type_type : label_contact_search_type_type_chinese}];
    }
    else if (type == T9SearchTextNumber) {
        [KDEventAnalysis event:event_contact_search_type attributes:@{label_contact_search_type_type : label_contact_search_type_type_number}];
    }
    else {
        [KDEventAnalysis event:event_contact_search_type attributes:@{label_contact_search_type_type : label_contact_search_type_type_pinyin}];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length > 0 && searchText.length == 0) {
        [self umeng:searchBar.text];
    }
}

- (void)searchBarTextDidChange:(KDSearchBar *)searchBar
{
    if(![[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
        [self _searchObject:searchBar.text];
        [self _maskViewWithVisible:NO];
    }
}

- (void)searchBarDidBeginEditingAction{
    //add
    [KDEventAnalysis event:event_contacts_search];
    [KDEventAnalysis eventCountly:event_contacts_search];
    if(personViewControllerFlags_.searching == 0){
        personViewControllerFlags_.searching = 1;
        state_ = KDContactViewStateSearch;
        if(needsToLayoutTableView_){
            CGRect rect =  self.tableView.frame ;
            rect.size.height += 50;
            self.tableView.frame  = rect;
        }
        [self _setupCancelSearchingButton:YES];
        if(!isFromConversation_)
            [KDWeiboAppDelegate getAppDelegate].tabBarController.tabBar.hidden = YES;
    }
}

- (void)searchBarDidEndEditingAction{
    if(self.kdSearchBar.text.length == 0){
        personViewControllerFlags_.searching = 0;
        state_ = KDContactViewStateNormal;
        
        if(needsToLayoutTableView_){
            CGRect rect =  self.tableView.frame ;
            rect.size.height -= 50;
            self.tableView.frame  = rect;
        }
        [self _setupCancelSearchingButton:NO];
        [self.tableView reloadData];
        if(!isFromConversation_)
            [KDWeiboAppDelegate getAppDelegate].tabBarController.tabBar.hidden = NO;
    }
}

- (void)_searchObject:(NSString *)searchtext
{
    if(displayContacts_ == nil){
        displayContacts_ = [[NSMutableArray alloc] init];
    } else {
        [displayContacts_ removeAllObjects];
    }
    
    if (![[BOSSetting sharedSetting] isNetworkOrgTreeInfo]) {
        if(_canSearch) {
            [displayContacts_ addObjectsFromArray:[[T9 sharedInstance] search:searchtext]];
            [self processSearchResultsBeforeReload];
        }
        
        [self.tableView reloadData];
        [self refreshTableViewFooterView];
    }else{
        [self getPersonSearchClient:searchtext];
    }
}

- (void)processSearchResultsBeforeReload
{
    
}


#pragma mark  -- search person result from network
-(void)getPersonSearchClient:(NSString *)word
{
    if (personSearchClient_ == nil) {
        personSearchClient_ = [[ContactClient alloc ]initWithTarget:self action:@selector(getPersonSerchDidReceived:result:)];
    }
    
    [personSearchClient_ personNewSearchWithWord:word begin:0 count:20 isFilter:NO];
}


-(void)getPersonSerchDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success && result.data && !client.hasError && [result isKindOfClass:[BOSResultDataModel class]]) {
        SimplePersonListDataModel *personsList = [[SimplePersonListDataModel alloc] initWithDictionary:result.data];
        personsList.isFilterTeamAcc = self.isFilterTeamAcc;
        
        [displayContacts_ addObjectsFromArray:personsList.list];
        NSLog(@"123");
        [self processSearchResultsBeforeReload];
        [self.tableView reloadData];
        [self refreshTableViewFooterView];
    }
}



#pragma mark -
#pragma mark private

- (BOOL)_isFavoritedContactsTab {
    return state_ == KDContactViewStateNormal;
}

- (BOOL)_isSearchContactsTab {
    return state_ == KDContactViewStateSearch;
}



- (void)_updateDisplayContacts:(BOOL)clear reload:(BOOL)reload {
    if (displayContacts_ == nil) {
        displayContacts_ = [[NSMutableArray alloc] init];
    }
    
    if (clear && [displayContacts_ count] > 0) {
        [displayContacts_ removeAllObjects];
    }
    
    if ([self _isFavoritedContactsTab]) {
        if (defaultContacts_ != nil) {
            [displayContacts_ addObjectsFromArray:defaultContacts_];
        }
        
    } else if ([self _isSearchContactsTab]) {
        if (searchedContacts_ != nil) {
            [displayContacts_ addObject:searchedContacts_];
        }
    }
    
    if (reload) {
        [self.tableView reloadData];
        [self refreshTableViewFooterView];
        
        // No matter there is prompt info or not, just dismiss it
        //        [self _showPromptInfo:NO info:nil];
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
    UIView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds ] ;
    [backgroundView setUserInteractionEnabled:YES];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_placeholder_v2.png"]] ;
    [bgImageView sizeToFit];
    bgImageView.center = CGPointMake(backgroundView.bounds.size.width * 0.5f, 137.5f);
    
    [backgroundView addSubview:bgImageView];
    backgroundView.backgroundColor = [UIColor kdBackgroundColor2];//RGBCOLOR(241, 242, 245);
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(bgImageView.frame) + 5.0f, self.view.bounds.size.width, 15.0f)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = MESSAGE_NAME_COLOR;
    label.font = [UIFont systemFontOfSize:15.0f];
    label.text = NSLocalizedString(@"AB_NO_MATCHED_CONTACTS", @"");
    [backgroundView addSubview:label];
    
    [self.tableView  setBackgroundView:backgroundView];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
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
    
    self.defaultContacts = groupedContacts;
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
    if (sectionTitles_ == nil) {
        NSMutableArray *titles = [[NSMutableArray alloc] init];
        
        NSInteger base = 65; // (A-Z)
        for (int i = 0; i < 26; i++) {
            [titles addObject:[NSString stringWithFormat:@"%ld", (long)base++]];
        }
        
        [titles addObject:@"*"]; // *
        
        self.sectionTitles = titles;
    }
}


- (void)_maskViewWithVisible:(BOOL)visible {
    if (maskView_ == nil) {
        CGRect rect = tableView_.frame;
        maskView_ = [[UIView alloc] initWithFrame:rect];
        maskView_.backgroundColor = [UIColor kdBackgroundColor2];//MESSAGE_BG_COLOR;
        // tap gesture recognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_didTapOnMaskView:)];
        tap.numberOfTapsRequired = 1;
        
        [maskView_ addGestureRecognizer:tap];
        
        // swipe gesture recognizer
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_didSwipeOnMaskView:)];
        swipe.direction = UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown;
        
        [maskView_ addGestureRecognizer:swipe];
        
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
    if ([kdSearchBar_ isFirstResponder] && [kdSearchBar_ canResignFirstResponder]) {
        [kdSearchBar_ resignFirstResponder];
    }
}

- (void)_setupCancelSearchingButton:(BOOL)istempLeftItem{
    if(istempLeftItem){
        UIButton *btn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
//        //[btn setTitle:NSLocalizedString(@"BACK", @"") forState:UIControlStateNormal];
//        
//        [btn setBackgroundImage:[UIImage imageNamed:@"navigationItem_back.png"] forState:UIControlStateNormal];
//        [btn setBackgroundImage:[UIImage imageNamed:@"navigationItem_back.png"] forState:UIControlStateHighlighted];
//        
//        [btn sizeToFit];
        
        [btn addTarget:self action:@selector(_shouldCancelSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
        //2013-12-26 song.wang
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = kLeftNegativeSpacerWidth;
        self.navigationItem.leftBarButtonItems = [NSArray
                                                  arrayWithObjects:negativeSpacer,leftItem, nil];
    }
    else{
        self.navigationItem.leftBarButtonItems = self.leftBarItems;
    }
}

- (void)_shouldCancelSearch:(UIButton *)btn {
    
    if (self.kdSearchBar.text.length > 0) {
        [self umeng:self.kdSearchBar.text];
    }
    
    personViewControllerFlags_.forceCancelled = 1; // mark as force cancelled
    self.displayContacts = nil;
    
    if ([kdSearchBar_ isFirstResponder]) {
        self.kdSearchBar.text = @"";
        [self _searchBarResignFirstResponder];
        
    } else {
        // call did end editing manually when search bar is not on editing mode.
        self.kdSearchBar.text = @"";
        [self searchBarDidEndEditingAction];
    }
}

#pragma mark - UIScrollViewDelegate

//拉动视图，关闭键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.kdSearchBar resignFirstResponder];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    _hud = nil;
}

@end
