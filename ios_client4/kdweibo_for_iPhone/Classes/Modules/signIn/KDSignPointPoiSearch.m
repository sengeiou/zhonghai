//
//  KDSignPointPoiSearch.m
//  officialDemo2D
//
//  Created by lichao_liu on 15/3/6.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "KDSignPointPoiSearch.h"
#import "KDSignInPointCell.h"
@interface KDSignPointPoiSearch () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, MAMapViewDelegate, AMapSearchDelegate> {
    dispatch_queue_t _searchQueue;
}

@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property(nonatomic, strong) AMapSearchAPI *search;
@end

@implementation KDSignPointPoiSearch

- (id)initWithContentsController:(UIViewController *)contentsController {
    if (self = [super init]) {
        _searchQueue = dispatch_queue_create("com.signPointPoiSearch.queue", NULL);
        
        [self setupSearchBar:contentsController];
        [self setupSearchDisplayController:self.searchBar contentsController:contentsController];
        [self initSearch];
    }
    return self;
}

- (void)initSearch {
    self.search = [[AMapSearchAPI alloc] initWithSearchKey:GAODE_MAP_KEY_IPHONE Delegate:self];
    self.search.delegate = self;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchDisplayController setActive:YES animated:YES];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [tableView setContentInset:UIEdgeInsetsZero];
    
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchTipsWithKey:searchText];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.searchBar.hidden = YES;
    [self.searchBar setText:nil];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self.searchBar resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tipCellIdentifier = @"tipCellIdentifier";
    
    KDSignInPointCell *cell = [tableView dequeueReusableCellWithIdentifier:tipCellIdentifier];
    
    if (cell == nil) {
        cell = [[KDSignInPointCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                        reuseIdentifier:tipCellIdentifier];
    }
    
    AMapTip *geocode = self.results[indexPath.row];
    
    cell.locationLabel.text = geocode.name;
    cell.detailLabel.text = geocode.district;
    cell.iconImageView.image = [UIImage imageNamed:@"sign_tip_location"];
    if(self.results.count == indexPath.row +1)
    {
        cell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
    }else{
        cell.separatorLineStyle  = KDTableViewCellSeparatorLineSpace;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AMapTip *geocode = self.results[indexPath.row];
    
    AMapGeocodeSearchRequest *geocodeRequest = [[AMapGeocodeSearchRequest alloc] init];
    geocodeRequest.searchType = AMapSearchType_Geocode;
    geocodeRequest.address = geocode.name;
    geocodeRequest.city = @[geocode.adcode];
    [self.search AMapGeocodeSearch:geocodeRequest];
    
    [self.searchDisplayController setActive:NO animated:NO];
    self.searchBar.text = geocode.name;
    self.searchBar.hidden = YES;
    [self.searchBar resignFirstResponder];
}

- (void)setupSearchDisplayController:(UISearchBar *)searchBar contentsController:(UIViewController *)contentsController {
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:contentsController];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsTableView.rowHeight = 50;
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchDisplayController.searchResultsTableView.backgroundColor = contentsController.view.backgroundColor;
}

- (UISearchBar *)setupSearchBar:(UIViewController *)contentsController {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(.0, 0, contentsController.view.frame.size.width, 44.0)];
    searchBar.delegate = self;
    [searchBar setCustomPlaceholder:ASLocalizedString(@"搜索")];
    self.searchBar = searchBar;
    [contentsController.view addSubview:self.searchBar];
    return searchBar;
}

- (void)dealloc {
    self.search.delegate = nil;
}

/* 输入提示 搜索.*/
- (void)searchTipsWithKey:(NSString *)key {
    if (key.length == 0) {
        return;
    }
    
    if (!self.results) {
        self.results = [NSMutableArray new];
    }
    else if (self.results && self.results.count > 0) {
        [self.results removeAllObjects];
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = key;
    tips.searchType = AMapSearchType_InputTips;
    [self.search AMapInputTipsSearch:tips];
    
}

#pragma mark - AMapSearchDelegate

/* 输入提示回调. */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response {
    [self.results removeAllObjects];
    for (AMapTip *mapTip in response.tips) {
//        if (mapTip.location.latitude > 0 && mapTip.location.longitude > 0) {
            [self.results addObject:mapTip];
//        }
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
}

/* 地理编码回调.*/
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if (response.geocodes.count > 0) {
        AMapGeocode *geocode = [response.geocodes firstObject];
        if (geocode.location.latitude > 0 && geocode.location.longitude > 0) {
            if (self.signInPointSearchDelegate && [self.signInPointSearchDelegate respondsToSelector:@selector(searchResultDidSelectedWithAMapTip:)]) {
                [self.signInPointSearchDelegate searchResultDidSelectedWithAMapTip:geocode];
            }
            return;
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"定位失败") delegate:nil cancelButtonTitle:ASLocalizedString(@"确定") otherButtonTitles:nil];
    [alert show];
}


- (void)searchRequest:(id)request didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"查询失败") delegate:nil cancelButtonTitle:ASLocalizedString(@"确定") otherButtonTitles:nil];
    [alert show];
}

- (void)showSearchBar {
    self.searchBar.hidden = NO;
    [self.searchBar setText:nil];
    if (self.results && self.results.count > 0) {
        [self.results removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    [self searchBarShouldBeginEditing:self.searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.hidden = YES;
    [self.searchBar setText:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (!self.results || self.results.count == 0) {
        [self searchTipsWithKey:self.searchBar.text];
    }
    [self.searchBar resignFirstResponder];
}
@end
