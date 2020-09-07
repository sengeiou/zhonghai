//
//  KDSearchForXTChatViewController.m
//  kdweibo
//
//  Created by 陈彦安 on 15/5/12.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSearchForXTChatViewController.h"
#import "XTContactPersonMultipleChoiceCell.h"
#import "T9.h"

@interface KDSearchForXTChatViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate> {
    dispatch_queue_t _searchQueue;
}
@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) UISearchDisplayController *searchDisplayController;

@property(nonatomic, strong) NSArray *results;
@property(nonatomic, strong) UIView *viewOverlay;
@end


@implementation KDSearchForXTChatViewController

- (id)initWithContentsController:(UIViewController *)contentsController {
    self = [super init];
    if (self) {
        _searchQueue = dispatch_queue_create("com.search.queue", NULL);
        
        [self setupSearchDisplayController:[self setupSearchBar:contentsController] contentsController:contentsController];
        [self.searchDisplayController.searchResultsTableView registerClass:[XTContactPersonMultipleChoiceCell class] forCellReuseIdentifier:@"Cell"];
        _isMult = YES;
        _pType = 1;
        
    }
    return self;
}

- (void)search:(NSString *)text {
    if (text.length == 0) {
        self.results = nil;
        [self.searchDisplayController.searchResultsTableView reloadData];
        return;
    }
    
    //通讯录搜索
    dispatch_async(_searchQueue, ^{
        [self searchWithArray:self.dataArray Text:text];
        [self umeng:text];
    });
}

#pragma mark - 组件初始化 & 样式 -

- (UISearchBar *)setupSearchBar:(UIViewController *)contentsController {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, contentsController.view.frame.size.width, 44.0)];
    searchBar.delegate = self;
    [searchBar setCustomPlaceholder:ASLocalizedString(@"KDSearchBar_Search")];
    self.searchBar = searchBar;
    return searchBar;
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

#pragma mark - UITableViewDataSource & UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    XTContactPersonMultipleChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[XTContactPersonMultipleChoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    PersonSimpleDataModel *person = self.results[indexPath.row];
    cell.showGrayStyle = (self.type == KDChooseContentNormal);
    cell.isFromTask = self.selectedPersonsView.isFromTask;
    cell.person = person;
    cell.checked = [self.selectedPersonsView.persons containsObject:person];
//    cell.separatorLineStyle = (indexPath.row == [self.results count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
    cell.pType = self.pType;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonSimpleDataModel *model = self.results[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    //未激活不给点
    if(![BOSSetting sharedSetting].supportNotMobile &&![model xtAvailable] && self.type == KDChooseContentNormal)
        return;

    
    if (self.pType == 2 && model.partnerType == 1) { // 商务伙伴不可选
        return;
    }
    if (self.pType == 3 && model.partnerType == 0) { // 内部员工不可选
        return;
    }
    XTContactPersonMultipleChoiceCell *cell = (XTContactPersonMultipleChoiceCell *) [tableView cellForRowAtIndexPath:indexPath];
    BOOL checked = cell.checked;
    if (checked == NO && self.selectedPersonsView.isMult == NO && [self.selectedPersonsView.persons count] > 0) {
        return;
    }

    if ([self.selectedPersonsView.persons containsObject:model]) {
        [self.selectedPersonsView deletePerson:model];
        cell.checked = NO;
    }
    else {
        [self.selectedPersonsView addPerson:model];
        cell.checked = YES;
    }
}

#pragma mark - UISearchBarDelegate -

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [KDEventAnalysis event:event_session_search];
    [self.searchDisplayController setActive:YES animated:YES];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self showViewOverlay];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self hideViewOverlay];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length > 0) {
        [self hideViewOverlay];
    }
    else {
        [self showViewOverlay];
    }
    
    [self search:searchText];
}

#pragma mark - overlay -

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
        AddY(_viewOverlay.frame, 64);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_viewOverlay.bounds];
        imageView.image = [UIImage imageNamed:@"bj_search"];
        [_viewOverlay addSubview:imageView];
    }
    return _viewOverlay;
}

#pragma mark - umeng

- (void)umeng:(NSString *)text {
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
    [KDEventAnalysis event:event_contact_kpi attributes:@{label_contact_kpi_source : label_contact_kpi_source_search}];
}

#pragma mark - search

- (void)searchWithArray:(NSArray *)array Text:(NSString *)text {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.personName CONTAINS[cd] %@", text];
    self.results = [self.dataArray filteredArrayUsingPredicate:pred];
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //    });
}
@end
