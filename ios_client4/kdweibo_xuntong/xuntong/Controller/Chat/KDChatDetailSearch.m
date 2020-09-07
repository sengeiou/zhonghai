//
//  KDChatDetailSearch.m
//  kdweibo
//
//  Created by liwenbo on 16/2/18.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDChatDetailSearch.h"
#import "XTContactPersonViewCell.h"
#import "XTPersonDetailViewController.h"

@interface KDChatDetailSearch () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;

@property  NSArray *results;
@property (nonatomic, strong) UIView *viewOverlay;
@property (nonatomic, strong) UIViewController *contentController;
@end

static NSString *cellIdentifier = @"cellIdentifier";

@implementation KDChatDetailSearch

-(void)dealloc {
    if(@available(iOS 11.0, *))
    {
        [self.searchBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                if([obj1 isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
                {
                    [obj1 removeObserver:self forKeyPath:@"backgroundColor"];
                    [obj1 removeObserver:self forKeyPath:@"image"];
                }
            }];
        }];
    }
}

- (id)initWithContentsController:(UIViewController *)contentsController {
    self = [super init];
    if (self) {
        self.isDelete = NO;
        self.contentController = contentsController;
        [self setupSearchDisplayController:[self setupSearchBar:contentsController] contentsController:contentsController];
        [self.searchDisplayController.searchResultsTableView registerClass:[XTContactPersonViewCell class] forCellReuseIdentifier:cellIdentifier];
        
    }
    return self;
}

- (UISearchBar *)setupSearchBar:(UIViewController *)contentsController {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, ScreenFullWidth, 44.0)];
    searchBar.delegate = self;
    [searchBar setCustomPlaceholder:ASLocalizedString(@"KDSearchBar_Search")];
    self.searchBar = searchBar;
    
    if(@available(iOS 11.0, *))
    {
        [self.searchBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                if([obj1 isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
                {
                    [obj1 addObserver:self forKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew context:nil];
                    [obj1 addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
                }
            }];
        }];
    }
    
    return searchBar;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"image"])
    {
        UIImageView *imageView = object;
        if(![imageView.backgroundColor.htmlHexString isEqualToString:FC6.htmlHexString])
        {
            imageView.backgroundColor = FC6;
            imageView.image = [UIImage imageWithColor:FC6];
        }
    }
}

- (void)setupSearchDisplayController:(UISearchBar *)searchBar contentsController:(UIViewController *)contentsController {
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:contentsController];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsTableView.rowHeight = 68.0;
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchDisplayController.searchResultsTableView.backgroundColor = contentsController.view.backgroundColor;
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar setText:nil];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self.searchBar resignFirstResponder];
    self.results = nil;
}

#pragma mark - TableViewDelegate && DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XTContactPersonViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    PersonSimpleDataModel *person = self.results[indexPath.row];
    cell.person = person;
    cell.separatorLineStyle = (indexPath.row == [self.results count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PersonSimpleDataModel *person = self.results[indexPath.row];
    
    XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:person with:NO];
    personDetail.hidesBottomBarWhenPushed = YES;
    [self.contentController.navigationController pushViewController:personDetail animated:YES];
}

#pragma mark - UISearchBarDelegate -

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [KDEventAnalysis event:event_session_search];
    [self.searchDisplayController setActive:YES animated:YES];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self showViewOverlay];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self hideViewOverlay];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar.text.length > 0)
    {
        [self hideViewOverlay];
    }
    else
    {
        [self showViewOverlay];
    }
    
    [self search:searchText];
}

- (void)search:(NSString *)text
{
    if (text.length == 0)
    {
        self.results = nil;
        [self.searchDisplayController.searchResultsTableView reloadData];
        return;
    }

    [self searchWithArray:self.dataArray Text:text];

}

- (void)searchWithArray:(NSArray *)array Text:(NSString *)text
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.personName CONTAINS[cd] %@", text];
    self.results = [self.dataArray filteredArrayUsingPredicate:pred];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - overlay -
- (void)cancelSearch
{
    self.searchBar.text = @"";
    [self.searchDisplayController.searchResultsTableView reloadData];
    [self.searchDisplayController setActive:NO animated:YES];
    [self.searchBar endEditing:YES];
    [self hideViewOverlay];
}

- (void)showViewOverlay {
    [self.searchDisplayController.searchContentsController.view addSubview:self.viewOverlay];
}

- (void)hideViewOverlay {
    [self.viewOverlay removeFromSuperview];
}

- (UIView *)viewOverlay {
    if (!_viewOverlay) {
        _viewOverlay = [[UIView alloc] initWithFrame:self.searchDisplayController.searchContentsController.view.bounds];
        _viewOverlay.userInteractionEnabled = NO;
        AddY(_viewOverlay.frame, kd_StatusBarAndNaviHeight);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_viewOverlay.bounds];
        imageView.image = [UIImage imageNamed:@"bj_search.png"];
        [_viewOverlay addSubview:imageView];
    }
    return _viewOverlay;
}


- (BOOL)isManager:(PersonSimpleDataModel *)person
{
    if ([self.group.managerIds containsObject:person.wbUserId] || [self.group.managerIds containsObject:[NSString stringWithFormat:@"%@_ext",person.wbUserId]])
    {
        return YES;
    }
    if ([self.group.managerIds containsObject:person.personId])
    {
        return YES;
    }
    return NO;
}


@end
