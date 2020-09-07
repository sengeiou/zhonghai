//
//  KDSearchBar.m
//  kdweibo
//
//  Created by shifking on 15/11/10.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDLocationOptionSearchBar.h"
#import "KDLocationTableViewCell.h"
#import "KDLocationData.h"
#import "NSString+Operate.h"
#import "KDSignInLocationManager.h"

@interface KDLocationOptionSearchBar()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;

@property (nonatomic, strong) KDSignInLocationManager *locationManager;
@property (nonatomic, strong) KDLocationData *locationData;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation KDLocationOptionSearchBar

#pragma mark - init and setup -
- (id)initWithContentsController:(UIViewController *)contentsController locationData:(KDLocationData *)locationData{
    self = [super init];
    if (self) {
        [self setupSearchBar:contentsController];
        [self setupSearchDisplayController:self.searchBar contentsController:contentsController];
        self.locationData = locationData;
        self.pageIndex = 1;
    }
    return self;
}

- (UISearchBar *)setupSearchBar:(UIViewController *)contentsController {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(.0, 0, contentsController.view.frame.size.width, 44.0)];
    searchBar.delegate = self;
    [searchBar setCustomPlaceholder:ASLocalizedString(@"搜索")];
    self.searchBar = searchBar;
    [contentsController.view addSubview:self.searchBar];
    return searchBar;
}

- (void)setupSearchDisplayController:(UISearchBar *)searchBar contentsController:(UIViewController *)contentsController {
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:contentsController];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsTableView.rowHeight = 68;
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchDisplayController.searchResultsTableView.backgroundColor = contentsController.view.backgroundColor;
}

#pragma mark - UISearchBarDelegate -
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchDisplayController setActive:YES animated:YES];
    return YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    SetY(self.searchBar.frame, 20);
    [self.searchBar setShowsCancelButton:YES animated:YES];
//    [KDEventAnalysis event:event_signin_queryaddress];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    SetY(self.searchBar.frame, 0);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self.searchBar resignFirstResponder];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [tableView setContentInset:UIEdgeInsetsZero];
    
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    for (UIView *subview in tableView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *textLab = (UILabel *)subview;
            [textLab setFont:FS2];
            [textLab setText:@""];
        }
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if (searchString.length == 0) {
        return NO;
    }
    [self searchPOIByKeyword:searchString isLoadMore:NO];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchPOIByKeyword:searchBar.text isLoadMore:NO];
    [self.searchBar resignFirstResponder];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"searchBarResult";
    KDLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KDLocationTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    KDLocationData *data = [self.results objectAtIndex:indexPath.row];
    [cell.accessoryImageView setImage:nil];
    
    cell.label.text = data.name;
    cell.subLabel.text = data.longAddress;
    cell.separatorLineStyle = (indexPath.row + 1 == self.results.count) ? KDTableViewCellAccessoryStyleNone : KDTableViewCellSeparatorLineSpace;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [KDEventAnalysis event:event_signin_selectaddress];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    KDLocationData *location = self.results[indexPath.row];
    [self.searchDisplayController setActive:NO animated:NO];
    [self.searchBar resignFirstResponder];
    if (self.selectedBlock) {
        self.selectedBlock(location, indexPath);
    }
}

#pragma mark - search method -
- (void)searchPOIByKeyword:(NSString *)keyword isLoadMore:(BOOL)isLoadMore {
    self.pageIndex = isLoadMore ? self.pageIndex + 1 : 1;
    
    [KDPopup showHUDInView:self.searchDisplayController.searchContentsController.view];
    __weak KDLocationOptionSearchBar *weakSelf = self;
    [self.locationManager doPoiSearchWithOffset:20 page:self.pageIndex radius:250 location:[[CLLocation alloc] initWithLatitude:self.locationData.coordinate.latitude longitude:self.locationData.coordinate.longitude] keyword:keyword successBlock:^(NSArray *pois, KDMapOperationType type) {
        
        if ([self.searchDisplayController.searchResultsTableView isFooterRefreshing]) {
            [self.searchDisplayController.searchResultsTableView footerEndRefreshing];
        }
        [KDPopup hideHUDInView:weakSelf.searchDisplayController.searchContentsController.view];
        
        // data
        if (weakSelf.pageIndex == 1) {
            [weakSelf.results removeAllObjects];
        }
        for (KDLocationData *data in pois) {
            if (data.coordinate.latitude > 0 && data.coordinate.longitude > 0) {
                [weakSelf.results addObject:data];
            }
        }
        
        // footer
        if (pois.count >= 20) {
            if (self.pageIndex == 1) {
                [self.searchDisplayController.searchResultsTableView addFooterWithCallback:^{
                    [weakSelf searchPOIByKeyword:keyword isLoadMore:YES];
                }];
            }
        }
        else {
            if (self.pageIndex > 1) {
                [self.searchDisplayController.searchResultsTableView removeFooter];
            }
        }
        
        [weakSelf.searchDisplayController.searchResultsTableView reloadData];
        
    } failuredBlock:^(NSArray *pois, KDMapOperationType type) {
        if ([self.searchDisplayController.searchResultsTableView isFooterRefreshing]) {
            [self.searchDisplayController.searchResultsTableView footerEndRefreshing];
            [self.searchDisplayController.searchResultsTableView removeFooter];
        }
        
        if (type != KDMapOperationType_operating) {
            [KDPopup hideHUDInView:weakSelf.searchDisplayController.searchContentsController.view];
            [weakSelf.results removeAllObjects];
            for (KDLocationData *location in self.sourceData) {
                if ([location.name containSubString:self.searchBar.text] || [location.longAddress containSubString:self.searchBar.text]) {
                    [self.results addObject:location];
                }
            }
            [weakSelf.searchDisplayController.searchResultsTableView reloadData];
        }
        
    } isNeedReGeoCode:NO];
}

#pragma mark - getter -
- (KDSignInLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[KDSignInLocationManager alloc] init];
    }
    return _locationManager;
}

- (NSMutableArray *)results {
    if (!_results) {
        _results = [NSMutableArray new];
    }
    return _results;
}

@end
