//
//  KDSearchForXTChatViewController.m
//  kdweibo
//
//  Created by 陈彦安 on 15/5/12.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSearchForXTChatViewController.h"

#import "UIImage+XT.h"
#import "T9.h"
#import "XTSearchCell.h"
#import "XTTimelineSearchCell.h"
//#import "KDPublicAccountSearchCell.h"
//#import "KDFileSearchCell.h"

//#import "KDDetail.h"
#import "XTChatViewController.h"
#import "XTTimelineViewController.h"
#import "XTPubAcctUserChatListViewController.h"
#import "XTFileDetailViewController.h"
#import "KDTimelineManager.h"
//#import "KDPublicAccountCache.h"
#import "KDCustomSearchDisplayController.h"
#import "XTContactPersonMultipleChoiceCell.h"
#import "UIColor+KDAddition.h"


static NSString *const kSearchTypeContact = @"contact";
static NSString *const kSearchTypeGroup = @"group";
static NSString *const kSearchTypePublic = @"public";
static NSString *const kSearchTypeFile = @"file";

@interface KDSearchForXTChatViewController () <UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate,UISearchBarDelegate,XTFileDetailViewControllerDelegate> {
    dispatch_queue_t _searchQueue;
    UIStatusBarStyle _statusBarStyle;
}
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) KDCustomSearchDisplayController *searchDisplayController;

@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) UIView *viewOverlay;
@property (nonatomic, strong) UIImageView *bottomLineView;
@end


@implementation KDSearchForXTChatViewController
- (id)initWithContentsController:(UIViewController *)contentsController
{
    self = [super init];
    if (self) {
        _statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        _searchQueue = dispatch_queue_create("com.search.queue", NULL);
        
        [self setupSearchDisplayController:[self setupSearchBar:contentsController] contentsController:contentsController];
        _isMult = YES;
        _pType = 1;
        
    }
    return self;
}

- (void)search:(NSString *)text
{
    if (text.length == 0)
    {
        [self.searchDisplayController.searchResultsTableView reloadData];
        return;
    }
    
    //通讯录搜索
    dispatch_async(_searchQueue, ^
    {
        [self searchWithArray:self.dataArray Text:text];
        [self umeng:text];
    });
}

#pragma mark - 组件初始化 & 样式 -
- (UISearchBar *)setupSearchBar:(UIViewController *)contentsController
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(.0, .0, contentsController.view.frame.size.width, 44.0)];
    searchBar.delegate = self;
    
    //背景颜色
    searchBar.backgroundImage = [UIImage imageWithColor:MESSAGE_BG_COLOR];
    if ([searchBar respondsToSelector:@selector(barTintColor)]) {
        searchBar.barTintColor = [UIColor KDGrayColor];
    }
    else {
        searchBar.tintColor = [UIColor KDGrayColor];
    }
    
    //搜索按钮和删除按钮
    UIImage *searchImage = [UIImage imageNamed:@"common_btn_search.png"];
    [searchBar setImage:searchImage forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    UIImage *clearImage = [UIImage imageNamed:@"common_btn_delete"];
    [searchBar setImage:clearImage forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    //搜索框背景
    UIImage *backgroundImage = [UIImage imageNamed:@"common_img_search_bg"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width * 0.5 topCapHeight:backgroundImage.size.height * 0.5];
    [searchBar setSearchFieldBackgroundImage:backgroundImage forState:UIControlStateNormal];
    //placeholder and text
    searchBar.placeholder = ASLocalizedString(@" KDSearchBar_Search");
    [[UILabel appearanceWhenContainedIn:[searchBar class], nil] setTextColor:BOSCOLORWITHRGBA(0xAEAEAE, 1.0f)];
    [[UILabel appearanceWhenContainedIn:[searchBar class], nil] setFont:[UIFont systemFontOfSize:14.0]];
    [[UILabel appearanceWhenContainedIn:[searchBar class], nil] setTextAlignment:UIControlContentVerticalAlignmentCenter];
    [[UITextField appearanceWhenContainedIn:[searchBar class], nil] setTextColor:BOSCOLORWITHRGBA(0xAEAEAE, 1.0f)];
    [[UITextField appearanceWhenContainedIn:[searchBar class], nil] setFont:[UIFont systemFontOfSize:14.0]];
    [[UITextField appearanceWhenContainedIn:[searchBar class], nil] setTextAlignment:UIControlContentVerticalAlignmentCenter];
    [[UIBarButtonItem appearanceWhenContainedIn:[searchBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor KDBlueColor]} forState:UIControlStateNormal];
    
    self.searchBar = searchBar;
    
    return searchBar;
}

- (void)setupSearchDisplayController:(UISearchBar *)searchBar contentsController:(UIViewController *)contentsController
{
    self.searchDisplayController = [[KDCustomSearchDisplayController alloc] initWithSearchBar:searchBar contentsController:contentsController];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsTableView.rowHeight = 68.0;
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - UISearchDisplayDelegate
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[KDWeiboAppDelegate getAppDelegate].leveyTabBarController hidesTabBar:YES animated:YES];
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle animated:YES];
    [[KDWeiboAppDelegate getAppDelegate].leveyTabBarController hidesTabBar:YES animated:YES];
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar setText:nil];
    
}
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.searchBar resignFirstResponder];
    self.results = nil;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell-identifier";
    XTContactPersonMultipleChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[XTContactPersonMultipleChoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.separateLineImageView.hidden = YES;
        
        UIImageView*line = [[UIImageView alloc] initWithImage:[XTImageUtil cellSeparateLineImage]];
        line.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1);
        [cell addSubview:line];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == self.results.count - 1)
        {
            self.bottomLineView = [[UIImageView alloc]initWithImage:[XTImageUtil cellSeparateLineImage]];
            self.bottomLineView.frame = CGRectMake(0, 68, [UIScreen mainScreen].bounds.size.width, 1);
            [self.bottomLineView removeFromSuperview];
            [cell addSubview:self.bottomLineView];
        }
        else
        {
            [self.bottomLineView removeFromSuperview];
        }
    }
    
    PersonSimpleDataModel *person = self.results[indexPath.row];
    cell.person = person;
    cell.checked = [self.selectedPersonsView.persons containsObject:person];
    cell.pType = self.pType;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonSimpleDataModel *model = self.results[indexPath.row];
    
    if (self.pType == 2 && model.partnerType == 1) { // 商务伙伴不可选
        return;
    }
    if (self.pType == 3 && model.partnerType == 0) { // 内部员工不可选
        return;
    }
    XTContactPersonMultipleChoiceCell *cell = (XTContactPersonMultipleChoiceCell *)[tableView cellForRowAtIndexPath:indexPath];
    BOOL checked = cell.checked;
    if (checked == NO && self.selectedPersonsView.isMult == NO && [self.selectedPersonsView.persons count] > 0) {
        return;
    }
    
    if ([self.selectedPersonsView.persons containsObject:model])
    {
        [self.selectedPersonsView deletePerson:model];
        cell.checked = NO;
    }
    else
    {
        [self.selectedPersonsView addPerson:model];
        cell.checked = YES;
    }
}

#pragma mark - UISearchBarDelegate -
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //[KDEventAnalysis event:event_session_search];
    [self.searchDisplayController setActive:YES animated:YES];
    [[KDWeiboAppDelegate getAppDelegate].leveyTabBarController hidesTabBar:YES animated:YES];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self showViewOverlay];
    [[KDWeiboAppDelegate getAppDelegate].leveyTabBarController hidesTabBar:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self hideViewOverlay];
    [[KDWeiboAppDelegate getAppDelegate].leveyTabBarController hidesTabBar:YES animated:YES];
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

#pragma mark - overlay -
- (void)showViewOverlay
{
    [self.searchDisplayController.searchContentsController.view addSubview:self.viewOverlay];
}

- (void)hideViewOverlay
{
    [self.viewOverlay removeFromSuperview];
}

- (UIView *)viewOverlay
{
    if (!_viewOverlay)
    {
        _viewOverlay = [[UIView alloc] initWithFrame:self.searchDisplayController.searchContentsController.view.frame];
        AddY(_viewOverlay.frame, 22);

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_viewOverlay.frame];
        imageView.image = [UIImage imageNamed:@"bj_search.png"];
        AddY(imageView.frame, -42);
        [_viewOverlay addSubview:imageView];
    }
    return _viewOverlay;
}

#pragma mark - umeng
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
    //[KDEventAnalysis event:event_contact_kpi attributes:@{label_contact_kpi_source : label_contact_kpi_source_search}];
}

#pragma mark - search
-(void)searchWithArray:(NSArray *)array Text:(NSString *)text
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.personName CONTAINS[cd] %@",text];
    self.results = [self.dataArray filteredArrayUsingPredicate:pred];
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.searchDisplayController.searchResultsTableView reloadData];
        NSLog(@"self.results.count = %lu", (unsigned long)self.results.count);
    });
}
@end
