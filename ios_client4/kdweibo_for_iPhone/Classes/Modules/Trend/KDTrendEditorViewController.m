//
//  KDTrendEditorViewController.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-8-1.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDTrendEditorViewController.h"

#import "KDActivityIndicatorView.h"
#import "KDNotificationView.h"
#import "KDErrorDisplayView.h"
#import "KDRequestDispatcher.h"
#import "KDWeiboServicesContext.h"

#import "KDTopic.h"

#import "pinyin.h"
#import "NSString+Additions.h"
#import "NSDictionary+Additions.h"
#import "KDTrendCell.h"


@interface KDTrendEditorViewController ()

@property(nonatomic, retain) NSArray *displayTopics;
@property(nonatomic, retain) NSArray *topics;
@property(nonatomic, retain) NSArray *topicsIndex;

@property(nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) KDActivityIndicatorView *activityView;

@end

@implementation KDTrendEditorViewController

@synthesize delegate=delegate_;

@synthesize displayTopics=displayTopics_;
@synthesize topics=topics_;
@synthesize topicsIndex=topicsIndex_;

@synthesize tableView=tableView_;
@synthesize activityView=activityView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        viewControllerFlags_.initialized = 0;
        viewControllerFlags_.hasCustomTopic = 0;
        
        self.title = ASLocalizedString(@"IMPORT_TRENDS");
    }
    
    return self;
}

- (void)loadView {
    UIView *aView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = aView;
//    [aView release];
    
    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:self.backBtnTitle];
    [backBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];// autorelease];
    self.navigationItem.leftBarButtonItems = @[backItem];
    
    //self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,backItem, nil];

    [KDCommon leftNavigationItemWithTarget:self action:@selector(cancel)];
    
    // table view
    CGRect rect = self.view.bounds;
    UITableView *tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView = tableView;
//    [tableView release];
    
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.allowsSelectionDuringEditing = YES;
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView_.editing = YES;
    
    tableView_.backgroundColor = RGBCOLOR(248.0, 248.0, 249.0);
    
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
    
    // table header view (search bar)
    CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 50.0);
    KDSearchBar *searchBar = [[KDSearchBar alloc] initWithFrame:frame];
    
    searchBar.delegate = self;
    searchBar.placeHolder = ASLocalizedString(@"TRENDS_CREATE_OR_FILTER_BY");
    
    // when view controller did receive memory warning
    if(topics_ != nil && [displayTopics_ count] > [topics_ count]){
        // The first topic text is user custom topic text
        searchBar.text = [displayTopics_ objectAtIndex:0x00];
    }
    
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    searchBar.showsCancelButton = NO;
    tableView_.tableHeaderView = searchBar;
//    [searchBar release];
    
    // table footer view
    [self setupTableFooterView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(viewControllerFlags_.initialized == 0){
        viewControllerFlags_.initialized = 1;
        
        [self listDefaultTrends];
    }
}

//////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0x01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (displayTopics_ != nil) ? [displayTopics_ count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    KDTrendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KDTrendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle; 
    }
    
    NSString *topic = [displayTopics_ objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"#%@#", topic];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView_ deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *topicText = [displayTopics_ objectAtIndex:indexPath.row];
    [self didSelectTopicWithText:topicText];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UISearchBar *searchBar = (UISearchBar *)tableView_.tableHeaderView;
    if([searchBar isFirstResponder] && [searchBar canResignFirstResponder]){
        [searchBar resignFirstResponder];
    }
}

///////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UISearchBar delegate methods

- (void)searchBar:(KDSearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateDisplayTopicsWithKeywords:searchText];
}

- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar {
    [self searchTrends];
}

- (void)searchBarCancelButtonClicked:(KDSearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidChange:(KDSearchBar *)searchBar
{
    [self updateDisplayTopicsWithKeywords:searchBar.text];
}


///////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods
- (void)toggleTableFooterVisible:(BOOL)visible {
    tableView_.tableFooterView.hidden = visible ? NO : YES;
    searchButton_.enabled = visible ? YES : NO;
}

- (void)setupTableFooterView {
    // footer view
    CGRect frame = CGRectMake(0.0, 0.0, tableView_.bounds.size.width, 54.0);
    UIView *footerView = [[UIView alloc] initWithFrame:frame];
    
    // more button
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton_ = searchButton;
    
    searchButton.frame = CGRectMake((frame.size.width - 240.0) * 0.5, (frame.size.height - 32.0) * 0.5, 240.0, 32.0);
    searchButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    searchButton.showsTouchWhenHighlighted = YES;
    
    [searchButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [searchButton setTitleColor:RGBCOLOR(56.0, 84.0, 135.0) forState:UIControlStateHighlighted];
    [searchButton setTitle:ASLocalizedString(@"SEARCH_ON_NETWORK") forState:UIControlStateNormal];
    
    [searchButton addTarget:self action:@selector(searchTrends) forControlEvents:UIControlEventTouchUpInside];
    
    searchButton.enabled = NO;
    [footerView addSubview:searchButton];
    
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tableView_.tableFooterView = footerView;
//    [footerView release];
    
    [self toggleTableFooterVisible:NO];
}

- (void)activityViewWithVisible:(BOOL)visible info:(NSString *)info {
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

- (void)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchTrends {
    KDSearchViewControllerNew *svc = [[KDSearchViewControllerNew alloc] initWithSearchMaskType:KDSearchNewMaskTypeTrends];
    
    svc.delegate = self;
    
    NSString *keywords = [self inputText];
    if(keywords != nil && [keywords length] > 0){
        svc.keywords = keywords;
    }
    
    [self.navigationController pushViewController:svc animated:YES];
//    [svc release];
}

- (void)didSelectTopicWithText:(NSString *)topicText {
    if(delegate_ != nil && [delegate_ respondsToSelector:@selector(trendEditorViewController:didPickTopicText:)]){
        NSString *formatTopicText = [NSString stringWithFormat:@"#%@#", topicText];
        [delegate_ trendEditorViewController:self didPickTopicText:formatTopicText];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *)inputText {
    UISearchBar *searchBar = (UISearchBar *)tableView_.tableHeaderView;
    NSString *text = searchBar.text;
    return (text != nil) ? text : @"";
}

- (void)updateDisplayTopicsWithKeywords:(NSString *)keywords {
    BOOL hasText = (keywords != nil && [keywords length] > 0) ? YES : NO;
    
    [self toggleTableFooterVisible:hasText];
    
    NSArray *items = nil;
    if(hasText){
        NSMutableArray *results = [NSMutableArray array];
        
        // insert custom topic
        [results addObject:keywords];
        
        if(topics_ != nil){
            // use predicate to filter by results
            keywords = [NSString stringWithFormat:@".*%@.*", keywords];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES[cd] %@", keywords];
            
            NSArray *hits = [topics_ filteredArrayUsingPredicate:predicate];
            if(hits != nil && [hits count] > 0) {
                [results addObjectsFromArray:hits];
            }
            
            hits = [topicsIndex_ filteredArrayUsingPredicate:predicate];
            if(hits != nil && [hits count] > 0) {
                NSUInteger index = 0;
                NSString *topic = nil;
                for(NSString *item in hits){
                    index = [topicsIndex_ indexOfObject:item];
                    topic = [topics_ objectAtIndex:index];
                    
                    // Don't add same object more than twice
                    if([results indexOfObject:topic] == NSNotFound){
                        [results addObject:topic];
                    }
                }
            }
        }
        
        items = results;
        
    }else {
        items = topics_;
    }
    
    self.displayTopics = items;
    
    [tableView_ reloadData];
}

- (void)generateTrendsIndex {
    NSUInteger count = 0;
    if(topics_ != nil && (count = [topics_ count]) > 0){
        NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:count];
        NSString *indexHit = nil;
        
        for(NSString *item in topics_) {
            // 李雷 -> LL ; 韩梅梅 -> HMM
            indexHit = [item convertChineseToAZSequence];
            if(indexHit == nil) {
                indexHit = item;
            }
            
            [indexes addObject:indexHit];
        }
        
        self.topicsIndex = indexes;
    }
}

- (void)handleResponseTopics:(NSArray *)topics {
    NSUInteger count = 0;
    if ((count = [topics count]) > 0) {
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
        
        for(KDTopic *t in topics){
            [items addObject:t.name];
        }
        
        self.topics = items;
        [self generateTrendsIndex];
        
        // The network request may be delay response for some seconds.
        // So update display items with user inputed keywords. 
        [self updateDisplayTopicsWithKeywords:[self inputText]];
    }
}

- (void)listDefaultTrends {
    [self activityViewWithVisible:YES info:ASLocalizedString(@"RecommendViewController_Load")];
    
    __block KDTrendEditorViewController *tevc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                [tevc handleResponseTopics:results];
            }
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:tevc.view.window];
            }
        }
        
        [tevc activityViewWithVisible:NO info:nil];
        
        // release current view controller
//        [tevc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/trends/:listDefault" query:nil
                                 configBlock:nil completionBlock:completionBlock];
}


///////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDSearchViewController delegate methods

- (void)searchViewControllerNew:(KDSearchViewControllerNew *)svc didSelectTopicText:(NSString *)topicText {
    [self.navigationController popViewControllerAnimated:NO];
    
    [self didSelectTopicWithText:topicText];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    searchButton_ = nil;
    
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(activityView_);
}

- (void)dealloc {
    delegate_ = nil;
    searchButton_ = nil;
    
    //KD_RELEASE_SAFELY(displayTopics_);
    //KD_RELEASE_SAFELY(topics_);
    //KD_RELEASE_SAFELY(topicsIndex_);
    
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(activityView_);
    
    //[super dealloc];
}

@end
