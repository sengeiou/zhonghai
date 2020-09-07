//
//  KDSearch.m
//  kdweibo
//
//  Created by Gil on 15/1/8.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSearch.h"
#import "UIImage+XT.h"
#import "T9.h"
#import "XTSearchCell.h"
#import "XTTimelineSearchCell.h"
#import "KDPublicAccountSearchCell.h"
#import "KDFileSearchCell.h"

//#import "KDDetail.h"
#import "XTChatViewController.h"
#import "XTTimelineViewController.h"
#import "XTPubAcctUserChatListViewController.h"
#import "XTFileDetailViewController.h"
#import "KDTimelineManager.h"
//#import "KDCustomSearchDisplayController.h"
//#import "KDPublicAccountCache.h"
#import "XTPersonDetailViewController.h"
#import "XTChatDetailViewController.h"
#import "XTChatViewController.h"
#import "UIColor+KDAddition.h"
#import "BOSSetting.h"
#import "ContactClient.h"
#import "SimplePersonListDataModel.h"
#import "MBProgressHUD.h"
#import "KDSearchTextModel.h"
#import "KDSearchTextCell.h"
#import "KDMoreSearchCell.h"
#import "KDSearchCommon.h"
#import "KDMoreSearchListViewController.h"

//static NSString *const kSearchTypeContact = @"contact";
//static NSString *const kSearchTypeGroup = @"group";
//static NSString *const kSearchTypePublic = @"public";
//static NSString *const kSearchTypeFile = @"file";
//static NSString *const kSearchTypeText = @"text";
static NSString *const KDMoreSearchCellIndentifier = @"KDMoreSearchCellIndentifier";

//#define KDMoreSearchCellRow 3
//#define KSearchTimeInterval 0.0
//#define KDSearchCellContentTextMaxWidth (ScreenFullWidth - 44.0 - (3 * [NSNumber kdDistance1]))


@interface KDSearch () <UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate,UISearchBarDelegate,XTFileDetailViewControllerDelegate,KDMoreSearchListViewControllerDelegate> {
    dispatch_queue_t _searchQueue;
    UIStatusBarStyle _statusBarStyle;
}

@property (nonatomic, strong) UISearchBar *searchBar;
//@property (nonatomic, strong) KDCustomSearchDisplayController *searchDisplayController;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;

@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) UIView *viewOverlay;
@property (nonatomic, strong) ContactClient *personSearchClient;
@property (nonatomic, copy) NSString *lastNetworkSearchText;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) ContactClient *searchTextClient;
@property (nonatomic, strong) ContactClient *searchFileClient;
@end


@implementation KDSearch

- (id)initWithContentsController:(UIViewController *)contentsController
{
    self = [super init];
    if (self) {
        _statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        _searchQueue = dispatch_queue_create("com.search.queue", NULL);
        
        [self setupSearchDisplayController:[self setupSearchBar:contentsController] contentsController:contentsController];
    }
    return self;
}


- (void)willAppear
{
    [[UIApplication sharedApplication] setStatusBarStyle:self.searchDisplayController.active ? UIStatusBarStyleDefault : _statusBarStyle animated:YES];
}
- (void)willDisappear
{
    [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle animated:YES];
}

-(void)getPersonSearchClient:(NSString *)text
{
    //提示框
    self.hud = [[MBProgressHUD alloc] initWithWindow:self.searchDisplayController.searchContentsController.view.window];
    self.hud.mode = MBProgressHUDModeText;
    [self.hud setLabelText:ASLocalizedString(@"XTChatSearchViewController_Searching")];
    self.hud.removeFromSuperViewOnHide = YES;
    [self.searchDisplayController.searchContentsController.view.window addSubview:self.hud];
    [self.hud show:YES];
    
    
    self.lastNetworkSearchText = text;
    
//    if (!self.results) {
//        self.results = [[NSMutableArray alloc] init];
//    }
//    else {
//        [self.results removeAllObjects];
//    }
    
//    if (text.length == 0) {
//        [self.searchDisplayController.searchResultsTableView reloadData];
//        return;
//    }
    
    if (_personSearchClient == nil) {
        _personSearchClient = [[ContactClient alloc ]initWithTarget:self action:@selector(getPersonSerchDidReceived:result:)];
    }
    //20实际不传
    //[_personSearchClient personSearchWithWord:text begin:0 count:20 isFilter:NO];
    //A.wang
    
    [_personSearchClient personNewSearchWithWord:text begin:0 count:20 isFilter:NO];
    
    
}


-(void)getPersonSerchDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    [self.hud removeFromSuperview];
    self.hud = nil;
    
    if (result.success && result.data && !client.hasError && [result isKindOfClass:[BOSResultDataModel class]])
    {
        SimplePersonListDataModel *personsList = [[SimplePersonListDataModel alloc] initWithDictionary:result.data];
        [self insertResults:personsList.list label:[NSString stringWithFormat:@"%ld",(long)kSearchTypeContact] atIndex:0];
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        
        __weak KDSearch *selfInBlock = self;
        NSString *text = self.lastNetworkSearchText;
        
        //会话搜索(只搜索双人会话和多人会话)
        dispatch_async(_searchQueue, ^{
            NSMutableArray *groups = [[NSMutableArray alloc] init];
            NSArray *groupsWithName = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupsWithLikeGroupName:text];
            NSArray *groupsWithIds = nil;
            if ([personsList.list count] > 0) {
                __block NSString *ids = [[NSString alloc] init];
                [personsList.list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
                    ids = [ids stringByAppendingFormat:@"'%@',",person.personId];
                }];
                ids = [ids substringToIndex:ids.length - 1];
                if (ids.length > 0) {
                    groupsWithIds = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupsWithIds:ids isPersonId:YES];
                }
            }
            
            //检索群组名称结果
            if ([groupsWithName count] > 0) {
                [groups addObjectsFromArray:groupsWithName];
            }
            
            //检索群组成员结果
            if ([groupsWithIds count] > 0)
            {
                //去重，GroupDataModal重写了isEquals
                [groupsWithIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     GroupDataModel *gdm = (GroupDataModel *)obj;
                     if(![groups containsObject:gdm])
                         [groups addObject:gdm];
                     else
                     {
                         //替换高亮信息
                         int index = (int)[groups indexOfObject:gdm];
                         if(index>=0 && index<groups.count)
                         {
                             GroupDataModel *gdm1 = groups[index];
                             gdm1.highlightMessage = [gdm.highlightMessage copy];
                         }
                     }
                     
                 }];
            }
            
            int count = [selfInBlock insertResults:groups label:[NSString stringWithFormat:@"%ld",(long)kSearchTypeGroup] atIndex:1];
            if (count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [selfInBlock.searchDisplayController.searchResultsTableView reloadData];
                });
            }
        });
        
        //订阅消息搜索
        dispatch_async(_searchQueue, ^{
            NSArray *publics = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicAccountsWithLikeName:text];
            int count = [selfInBlock insertResults:publics label:[NSString stringWithFormat:@"%ld",(long)kSearchTypePublic] atIndex:2];
            if (count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [selfInBlock.searchDisplayController.searchResultsTableView reloadData];
                });
            }
        });
        
        
        //文本消息搜索   -----开发ing-----
        dispatch_async(_searchQueue, ^{
            DLog(@"🍌🍌🍌🍌搜索了文本%@",self.searchBar.text);
            [selfInBlock.searchTextClient searchTextRecordListWithWord:self.searchBar.text Page:1 Count:10];
            
        });
        
        //我的文件搜索   -----开发ing-----
        dispatch_async(_searchQueue, ^{
            DLog(@"🍒🍒🍒🍒搜索了文件%@",self.searchBar.text);
            [selfInBlock.searchFileClient searchFileRecordListWithWord:self.searchBar.text Page:1 Count:10];
        });
        
    }
}



- (void)search:(NSString *)text
{
    if(!self.searchTextClient)
    {
        self.searchTextClient = [[ContactClient alloc]initWithTarget:self action:@selector(searchTextRecordListDidReceived:result:)];
    }
    
    if (!self.searchFileClient)
    {
        self.searchFileClient = [[ContactClient alloc]initWithTarget:self action:@selector(searchFileRecordListDidReceived:result:)];
    }
    
    if (!self.results) {
        self.results = [[NSMutableArray alloc] init];
    }
    else {
        [self.results removeAllObjects];
    }
    
    if (text.length == 0) {
        [self.searchDisplayController.searchResultsTableView reloadData];
        return;
    }
    
    __weak KDSearch *selfInBlock = self;
    
    //通讯录搜索(这里要修改，区分网络和本地通讯录) ------ waiting
    __block NSArray *contact = nil;
    if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
        [self getPersonSearchClient:text];
        return;
    }else{
        dispatch_async(_searchQueue, ^{
            contact = [[T9 sharedInstance] search:text];
            int count = [selfInBlock insertResults:contact label:[NSString stringWithFormat:@"%ld",(long)kSearchTypeContact] atIndex:0];
            if (count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [selfInBlock.searchDisplayController.searchResultsTableView reloadData];
                });
            }
            [self umeng:text];
        });
    }
    
    //会话搜索(只搜索双人会话和多人会话)
    dispatch_async(_searchQueue, ^{
        NSMutableArray *groups = [[NSMutableArray alloc] init];
        NSArray *groupsWithName = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupsWithLikeGroupName:text];
        NSArray *groupsWithIds = nil;
        if ([contact count] > 0) {
            __block NSString *ids = [[NSString alloc] init];
            [contact enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                T9SearchResult *searchResult = (T9SearchResult *)obj;
                ids = [ids stringByAppendingFormat:@"%d,",searchResult.userId];
            }];
            ids = [ids substringToIndex:ids.length - 1];
            if (ids.length > 0) {
                groupsWithIds = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupsWithIds:ids isPersonId:NO];
            }
        }
        
        //检索群组名称结果
        if ([groupsWithName count] > 0) {
            [groups addObjectsFromArray:groupsWithName];
        }
        
        //检索群组成员结果
        if ([groupsWithIds count] > 0)
        {
            //去重，GroupDataModal重写了isEquals
            [groupsWithIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 GroupDataModel *gdm = (GroupDataModel *)obj;
                 if(![groups containsObject:gdm])
                     [groups addObject:gdm];
                 else
                 {
                     //替换高亮信息
                     int index = (int)[groups indexOfObject:gdm];
                     if(index>=0 && index<groups.count)
                     {
                         GroupDataModel *gdm1 = groups[index];
                         gdm1.highlightMessage = [gdm.highlightMessage copy];
                     }
                 }
                 
             }];
        }
        
        int count = [selfInBlock insertResults:groups label:[NSString stringWithFormat:@"%ld",(long)kSearchTypeGroup] atIndex:1];
        if (count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [selfInBlock.searchDisplayController.searchResultsTableView reloadData];
            });
        }
    });
    
    //订阅消息搜索
    dispatch_async(_searchQueue, ^{
        NSArray *publics = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicAccountsWithLikeName:text];
        int count = [selfInBlock insertResults:publics label:[NSString stringWithFormat:@"%ld",(long)kSearchTypePublic] atIndex:2];
        if (count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [selfInBlock.searchDisplayController.searchResultsTableView reloadData];
            });
        }
    });
    
    
    //文本消息搜索   -----开发ing-----
    dispatch_async(_searchQueue, ^{
        DLog(@"🍌🍌🍌🍌搜索了文本%@",self.searchBar.text);
        [selfInBlock.searchTextClient searchTextRecordListWithWord:self.searchBar.text Page:1 Count:10];
        
    });
    
    //我的文件搜索   -----开发ing-----
    dispatch_async(_searchQueue, ^{
        DLog(@"🍒🍒🍒🍒搜索了文件%@",self.searchBar.text);
        [selfInBlock.searchFileClient searchFileRecordListWithWord:self.searchBar.text Page:1 Count:10];
    });
}

- (int)insertResults:(NSArray *)array label:(NSString *)label atIndex:(NSInteger)index
{
    int count = 0;
    if ([array count] > 0) {
        if ([self.results count] >= index) {
            [self.results insertObject:@{ label : array } atIndex:index];
        }
        else {
            [self.results insertObject:@{ label : array } atIndex:[self.results count]];
        }
        count = (int)[array count];
    }
    return count;
}

- (NSString *)titleForHeaderWithSection:(NSInteger)section
{
    NSDictionary *obj = [self.results objectAtIndex:section];
    NSString *key = [[obj allKeys] firstObject];
    if ([key integerValue] == kSearchTypeContact) {
        return ASLocalizedString(@"XTContactContentViewController_Contact");
    }
    else if ([key integerValue] == kSearchTypeGroup) {
        return ASLocalizedString(@"Chat_Group");
    }
    else if ([key integerValue] == kSearchTypePublic) {
        return ASLocalizedString(@"KDMoreSearchListViewController_Subscribe");
    }
    else if ([key integerValue] == kSearchTypeFile) {
        return ASLocalizedString(@"KDCommunityShareView_File");
    }
    else if([key integerValue] == KSearchTypeText)
    {
        return ASLocalizedString(@"KDMoreSearchListViewController_Chat_Record");
    }
    
    return @"";
}

#pragma mark - ContactClientDelegate

- (NSString *)highlightWithSearchString:(NSString *)searchString ContentString:(NSString *)contentString HighlightString:(NSString *)highlightString
{
    NSString *resultString = nil;
    
    if (highlightString)
    {
        NSString *tagHeaderString =@"<em class=\"highlight\">";
        
        NSRange rang = [highlightString rangeOfString:tagHeaderString];
        CGRect frame = [highlightString boundingRectWithSize:CGSizeMake(ScreenFullWidth, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:FS2} context:nil];
        
        if (rang.location >= 14 && frame.size.width > KDSearchCellContentTextMaxWidth)
        {
            NSString *tempString = highlightString;
            tempString = [highlightString substringFromIndex:rang.location];
            highlightString = [NSString stringWithFormat:@"...%@",tempString];
        }
        
        resultString = [highlightString stringByReplacingOccurrencesOfString:tagHeaderString withString:@"<font color=\"#3CBAFF\">"];
        NSString *tagFooterString = @"</em>";
        resultString = [resultString stringByReplacingOccurrencesOfString:tagFooterString withString:@"</font>"];
    }
    else
    {
        NSRange range = [[contentString lowercaseString] rangeOfString:searchString.lowercaseString];
        if (range.location != NSNotFound) {
            resultString = [contentString stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"<font color=\"#3CBAFF\">%@</font>", [contentString substringWithRange:range]]];
        }
    }
    
    return resultString;
}

#pragma mark --Private Method
//搜索文本信息
- (void)searchTextRecordListDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result == nil) {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    
    NSMutableArray *searchTextArray = [NSMutableArray arrayWithCapacity:10];
    if (result.success && [result.data isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *data = (NSDictionary *)result.data;
        
        for (NSDictionary *dict in data[@"list"])
        {
            NSString *highlight = [(NSArray *)dict[@"highlight"] firstObject];
            KDSearchTextModel *searchModel = [[KDSearchTextModel alloc]initWithDictionary:dict[@"group"]];
            [searchModel setMessageDataModel:dict[@"message"] Highlight:highlight];
            searchModel.highlightMessage = [self highlightWithSearchString:self.searchBar.text ContentString:dict[@"message"][@"content"] HighlightString:highlight];
            
            [searchTextArray addObject:searchModel];
        }
        
        if (searchTextArray.count > 0)
        {
            [self insertResults:searchTextArray label:[NSString stringWithFormat:@"%ld",(long)KSearchTypeText] atIndex:3];
        }
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

//搜索文件信息
- (void)searchFileRecordListDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result == nil) {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    
    NSMutableArray *searchFileArray = [NSMutableArray arrayWithCapacity:10];
    if (result.success && [result.data isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *data = (NSDictionary *)result.data;
        
        for (NSDictionary *dict in data[@"list"])
        {
            NSString *highlight = [(NSArray *)dict[@"highlight"] firstObject];
            MessageFileDataModel *searchModel = [[MessageFileDataModel alloc]initWithDictionary:[[dict objectForKey:@"message"] objectForKey:@"param"]];
            searchModel.highlightName = highlight;
            searchModel.fileSendTime = dict[@"message"][@"sendTime"];
            NSString *sendUserID = dict[@"message"][@"fromUserId"];
            
            searchModel.msgId = dict[@"message"][@"msgId"];
            searchModel.groupId = dict[@"group"][@"groupId"];
            
            searchModel.wbUserId  = sendUserID;//这里有问题    wbUserID需要查询本地数据库
            searchModel.highlightName = [self highlightWithSearchString:self.searchBar.text ContentString:dict[@"message"][@"content"] HighlightString:highlight];
            [searchFileArray addObject:searchModel];
        }
        
        if (searchFileArray.count > 0)
        {
            [self insertResults:searchFileArray label:[NSString stringWithFormat:@"%ld",(long)kSearchTypeFile] atIndex:4];
        }
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

#pragma mark - 组件初始化 & 样式 -

- (UISearchBar *)setupSearchBar:(UIViewController *)contentsController
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(.0, .0, contentsController.view.frame.size.width, 44.0)];
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

-(void)dealloc
{
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

- (void)setupSearchDisplayController:(UISearchBar *)searchBar contentsController:(UIViewController *)contentsController
{
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:contentsController];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsTableView.rowHeight = 68.0;
    self.searchDisplayController.searchResultsTableView.sectionHeaderHeight = 22.0;
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchDisplayController.searchResultsTableView.backgroundColor = contentsController.view.backgroundColor;
    
    if (@available(iOS 11.0, *)) {
        self.searchDisplayController.searchResultsTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
//        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}

#pragma mark - UISearchDisplayDelegate -

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    //
    //    [self.searchBar setShowsCancelButton:YES animated:YES];
    //    [[KDWeiboAppDelegate getAppDelegate].leveyTabBarController hidesTabBar:YES animated:YES];
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    //    [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle animated:YES];
    //
    //    [self.searchBar setShowsCancelButton:NO animated:YES];
    //    [self.searchBar setText:nil];
    //    [[KDWeiboAppDelegate getAppDelegate].leveyTabBarController hidesTabBar:NO animated:YES];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar setText:nil];
    
    if (self.blockEndSearching) {
        self.blockEndSearching();
    }
    if ([self.searchDisplayController.searchContentsController isKindOfClass:[XTTimelineViewController class]]) {
        ((XTTimelineViewController *)self.searchDisplayController.searchContentsController).stillHideTabBar = NO;
    }
    
}
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.results count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *obj = [self.results objectAtIndex:section];
    NSString *key = [[obj allKeys] firstObject];
    NSArray *sectionDataArray = obj[key];
    
    return  [self tableViewRowOfSectionHandle:sectionDataArray].count;
}

//section显示3行
- (NSArray *)tableViewRowOfSectionHandle:(NSArray *)sectionDataArray
{
    NSMutableArray *array = nil;
    
    NSRange range = NSMakeRange(0, KDMoreSearchCellRow);
    if (sectionDataArray.count > KDMoreSearchCellRow)
    {
        array =  [NSMutableArray arrayWithArray:[sectionDataArray subarrayWithRange:range]];
        [array addObject:ASLocalizedString(@"XTOrganizationViewController_More")];
    }
    else
    {
        array = [NSMutableArray arrayWithArray:sectionDataArray];
    }
    
    return (NSArray *)array;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *obj = [self.results objectAtIndex:indexPath.section];
    
    NSString *key = [[obj allKeys] firstObject];
    if ([key integerValue] == kSearchTypeContact) {
        NSArray *contacts = obj[key];
        if(contacts && [contacts count] > indexPath.row && indexPath.row != KDMoreSearchCellRow){
            XTSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
            if (cell == nil) {
                cell = [[XTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
            }
            
            NSArray *contacts = obj[key];
            if (contacts && [contacts count] > indexPath.row) {
                if([contacts[indexPath.row] isKindOfClass:[T9SearchResult class]])
                    cell.searchResult = contacts[indexPath.row];
                else
                    cell.person = contacts[indexPath.row];;
                cell.separateLineImageView.hidden = ((indexPath.section != ([self.results count] - 1)) && (indexPath.row == [contacts count] - 1));
            }
            return cell;
        }else if(indexPath.row == KDMoreSearchCellRow){
            KDMoreSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:KDMoreSearchCellIndentifier];
            if (!cell)
            {
                cell = [[KDMoreSearchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KDMoreSearchCellIndentifier];
            }
            return cell;
        }
        
    }
    else if ([key integerValue] == kSearchTypeGroup) {
        NSArray *groups = obj[key];
        if (groups && [groups count] > indexPath.row && indexPath.row != KDMoreSearchCellRow) {
            XTTimelineSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
            if (cell == nil) {
                cell = [[XTTimelineSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
            }
            cell.group = [self tableViewRowOfSectionHandle:groups][indexPath.row];
            cell.separatorLineStyle = [self cellSeparatorLineStyleWithIndexPath:indexPath DataArray:groups];
            return cell;
        }
        else if (indexPath.row == KDMoreSearchCellRow)
        {
            KDMoreSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:KDMoreSearchCellIndentifier];
            if (!cell)
            {
                cell = [[KDMoreSearchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KDMoreSearchCellIndentifier];
            }
            return cell;
        }
    }
    else if ([key integerValue] == kSearchTypePublic) {
        NSArray *publics = obj[key];
        if (publics && [publics count] > indexPath.row && indexPath.row != KDMoreSearchCellRow) {
            KDPublicAccountSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
            if (cell == nil) {
                cell = [[KDPublicAccountSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
            }
            cell.person = [self tableViewRowOfSectionHandle:publics][indexPath.row];
            cell.separatorLineStyle = [self cellSeparatorLineStyleWithIndexPath:indexPath DataArray:publics];
            return cell;
        }
        else if (indexPath.row == KDMoreSearchCellRow)
        {
            KDMoreSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:KDMoreSearchCellIndentifier];
            if (!cell)
            {
                cell = [[KDMoreSearchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KDMoreSearchCellIndentifier];
            }
            return cell;
        }
    }
    else if ([key integerValue] == kSearchTypeFile) {
        NSArray *files = obj[key];
        if (files && [files count] > indexPath.row && indexPath.row != KDMoreSearchCellRow) {
            KDFileSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
            if (cell == nil) {
                cell = [[KDFileSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
            }
            cell.file = [self tableViewRowOfSectionHandle:files][indexPath.row];
            cell.separatorLineStyle = [self cellSeparatorLineStyleWithIndexPath:indexPath DataArray:files];
            return cell;
        }
        else if (indexPath.row == KDMoreSearchCellRow)
        {
            KDMoreSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:KDMoreSearchCellIndentifier];
            if (!cell)
            {
                cell = [[KDMoreSearchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KDMoreSearchCellIndentifier];
            }
            return cell;
        }
    }else if([key integerValue] == KSearchTypeText){
        NSArray *textMessages = obj[key];
        if (textMessages && textMessages.count > indexPath.row && indexPath.row != KDMoreSearchCellRow)
        {
            KDSearchTextCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
            if (!cell)
            {
                cell = [[KDSearchTextCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
            }
            cell.searchModel = [textMessages objectAtIndex:indexPath.row];
            cell.separatorLineStyle = [self cellSeparatorLineStyleWithIndexPath:indexPath DataArray:textMessages];
            return cell;
        }
        else if (indexPath.row == KDMoreSearchCellRow)
        {
            KDMoreSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:KDMoreSearchCellIndentifier];
            if (!cell)
            {
                cell = [[KDMoreSearchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KDMoreSearchCellIndentifier];
            }
            return cell;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < KDMoreSearchCellRow)
    {
        return 68.0f;
    }
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), section == 0 ? 22.0f : 30.0f)];
    view.backgroundColor = [UIColor kdSubtitleColor];
    
    UIView *grayView = [[UIView alloc]init];
    grayView.frame = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), section == 0 ? 0.0f : 8.0f);
    grayView.backgroundColor = [UIColor kdBackgroundColor1];
    
    [view addSubview:grayView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], CGRectGetMaxY(grayView.frame), CGRectGetWidth(view.frame) - [NSNumber kdDistance1], 22.0f)];
    
    label.text = [NSString stringWithFormat:@"%@", [self titleForHeaderWithSection:section]];
    label.font = FS7;
    label.textColor = FC1;
    label.backgroundColor = view.backgroundColor;
    [view addSubview:label];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *obj = [self.results objectAtIndex:indexPath.section];
    
    if(indexPath.row < KDMoreSearchCellRow){
        NSString *key = [[obj allKeys] firstObject];
        if ([key integerValue] == kSearchTypeContact) {
            XTSearchCell *cell = (XTSearchCell *)[tableView cellForRowAtIndexPath:indexPath];
            PersonSimpleDataModel *person =  cell.person;
            if (person) {
                [self toPersonDetail:person];
            }
        }
        else if ([key integerValue] == kSearchTypeGroup) {
            XTTimelineSearchCell *cell = (XTTimelineSearchCell *)[tableView cellForRowAtIndexPath:indexPath];
            GroupDataModel *group =  [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:cell.group.groupId];
            if (group) {
                //公共号
                if (group.groupType == GroupTypePublic && [group.participant count] == 1) {
                    PersonSimpleDataModel *person = [group.participant firstObject];
                    if ([person isPublicAccount]) {
                        //KDPublicAccountDataModel *pubacc = [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:person.personId];
                        //					if (pubacc.manager) {
                        //						//管理员，进入代言人界面
                        //						[self toPublicList:pubacc];
                        //						return;
                        //					}
                        if(person.manager)
                        {
                            //管理员，进入代言人界面
                            [self toPublicList:person];
                            return;
                        }
                    }
                }
                [self toChat:group];
            }
        }
        else if ([key integerValue ] == kSearchTypePublic) {
            KDPublicAccountSearchCell *cell = (KDPublicAccountSearchCell *)[tableView cellForRowAtIndexPath:indexPath];
            //KDPublicAccountDataModel *person =  (KDPublicAccountDataModel *)cell.person;
            PersonSimpleDataModel *person =  (PersonSimpleDataModel *)cell.person;
            if (person.subscribe) {
                if (person.manager) {
                    //管理员，进入代言人界面
                    [self toPublicList:person];
                    return;
                }
                
                [self toChatWithPerson:person];
                return;
            }
            
            [self toPersonDetail:person];
        }
        else if ([key integerValue] == kSearchTypeFile) {
            KDFileSearchCell *cell = (KDFileSearchCell *)[tableView cellForRowAtIndexPath:indexPath];
            MessageFileDataModel *file = cell.file;
            if (file) {
                FileModel *fileDM = [[FileModel alloc] init];
                fileDM.fileId = file.file_id;
                fileDM.name = file.name;
                fileDM.uploadDate = file.uploadDate;
                fileDM.ext = file.ext;
                fileDM.size = file.size;
                
                [self toFileDetail:fileDM messageId:file.msgId groupId:file.groupId dedicatorId:file.wbUserId];
            }
        }else if([key integerValue] == KSearchTypeText){
            KDSearchTextCell *cell = (KDSearchTextCell *)[tableView cellForRowAtIndexPath:indexPath];
            KDSearchTextModel *searchModel = cell.searchModel;
            GroupDataModel *group =  [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:cell.searchModel.groupId];
            
            if (group)
            {
                [self toChatWithSearchModel:searchModel];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"会话群组不存在！")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil] show];
            }
        }
    }else{
        [self toMoreSearchListViewWithDictionary:obj];
    }
}

#pragma mark - PUSH VC -

- (void)toChatWithSearchModel:(KDSearchTextModel *)searchModel
{
    if (searchModel.groupId && searchModel.searchMessageData.msgId)
    {
        GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:searchModel.groupId];
        
        XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
        
        chatViewController.hidesBottomBarWhenPushed = YES;
        
        chatViewController.strScrollToMsgId = searchModel.searchMessageData.msgId;
        
        [self.searchDisplayController.searchContentsController.navigationController  pushViewController:chatViewController animated:YES];
    }
}

- (void)toMoreSearchListViewWithDictionary:(NSDictionary *)dictionary
{
    [self beforePush];
    KDMoreSearchListViewController *moreSearchListViewController = [[KDMoreSearchListViewController alloc]initWithDictionary:dictionary];
    moreSearchListViewController.delegate = self;
    moreSearchListViewController.hidesBottomBarWhenPushed = YES;
    moreSearchListViewController.searchWord = self.searchBar.text;
    switch ([[[dictionary allKeys] firstObject] integerValue])
    {
        case kSearchTypeContact:
            moreSearchListViewController.searchType = kSearchTypeContact;
            break;
        case kSearchTypeGroup:
            moreSearchListViewController.searchType = kSearchTypeGroup;
            break;
        case kSearchTypePublic:
            moreSearchListViewController.searchType = kSearchTypePublic;
            break;
        case KSearchTypeText:
            moreSearchListViewController.searchType = KSearchTypeText;
            break;
        case kSearchTypeFile:
            moreSearchListViewController.searchType = kSearchTypeFile;
            break;
            
        default:
            break;
    }
    
    [self.searchDisplayController.searchContentsController.navigationController pushViewController:moreSearchListViewController animated:YES];
}

- (void)beforePush
{
    [self.searchBar resignFirstResponder];
    if ([self.searchDisplayController.searchContentsController isKindOfClass:[XTTimelineViewController class]]) {
        ((XTTimelineViewController *)self.searchDisplayController.searchContentsController).stillHideTabBar = YES;
    }
}

- (void)toPersonDetail:(PersonSimpleDataModel *)person
{
    [self beforePush];
    //[KDDetail toDetailWithPerson:person inController:self.searchDisplayController.searchContentsController];
    self.searchDisplayController.searchContentsController.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    XTPersonDetailViewController*personDetail=[[XTPersonDetailViewController alloc]initWithSimplePerson:person with:NO];
    personDetail.hidesBottomBarWhenPushed = YES;
    [self.searchDisplayController.searchContentsController.navigationController pushViewController:personDetail animated:YES];
}

- (void)toChat:(GroupDataModel *)group
{
    [self beforePush];
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.searchDisplayController.searchContentsController.navigationController pushViewController:chatViewController animated:YES];
}

- (void)toChatWithPerson:(PersonSimpleDataModel *)person
{
    [self beforePush];
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:person];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.searchDisplayController.searchContentsController.navigationController pushViewController:chatViewController animated:YES];
}

- (void)toPublicList:(PersonSimpleDataModel *)person
{
    [self beforePush];
    //    XTPubAcctUserChatListViewController *publicTimelineViewController = [[XTPubAcctUserChatListViewController alloc] initWithPublicPerson:person];
    //    publicTimelineViewController.hidesBottomBarWhenPushed = YES;
    //    [self.searchDisplayController.searchContentsController.navigationController pushViewController:publicTimelineViewController animated:YES];
}

- (void)toFileDetail:(FileModel *)file messageId:(NSString *)msgId groupId:(NSString *)groupId dedicatorId:(NSString *)dedicatorId
{
    [self beforePush];
    XTFileDetailViewController *filePreviewVC = [[XTFileDetailViewController alloc] initWithFile:file];
    filePreviewVC.hidesBottomBarWhenPushed = YES;
    filePreviewVC.fileDetailFunctionType = XTFileDetailFunctionType_count;
    filePreviewVC.messageId = msgId;
    filePreviewVC.threadId = groupId;
    //    filePreviewVC.delegate = self;
    filePreviewVC.dedicatorId = dedicatorId;
    [self.searchDisplayController.searchContentsController.navigationController pushViewController:filePreviewVC animated:YES];
}

#pragma mark - XTFileDetailViewControllerDelegate -

- (void)fileForwardFinish:(XTFileDetailViewController *)controller
{
    [self.searchBar resignFirstResponder];
    [self.searchDisplayController setActive:NO animated:NO];
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
    [KDEventAnalysis event:event_contact_kpi attributes:@{label_contact_kpi_source : label_contact_kpi_source_search}];
}

#pragma mark - KDMoreSearchViewControllerDelegate
-(void)closeSearchUserInterface
{
    self.searchDisplayController.active = NO;
    [self hideViewOverlay];
    
    if ([self.searchDisplayController.searchContentsController isKindOfClass:[XTTimelineViewController class]]) {
        [((XTTimelineViewController *)self.searchDisplayController.searchContentsController).groupTableView setContentOffset:CGPointMake(.0, .0)];
    }
}

#pragma mark - overlay -
- (UIView *)viewOverlay {
    if (!_viewOverlay) {
        _viewOverlay = [[UIView alloc] initWithFrame:self.searchDisplayController.searchContentsController.view.bounds];
        _viewOverlay.userInteractionEnabled = NO;
        AddY(_viewOverlay.frame, kd_StatusBarAndNaviHeight);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_viewOverlay.bounds];
        //imageView.image = [UIImage imageNamed:@"bj_search.png"];
        imageView.backgroundColor = [UIColor kdBackgroundColor2];
        [_viewOverlay addSubview:imageView];
        
        UILabel *labelTitle = [UILabel new];
        labelTitle.textColor = [UIColor colorWithRGB:0x98A1A8];
        labelTitle.textAlignment = NSTextAlignmentCenter;
        labelTitle.font = FS3;
        labelTitle.text = ASLocalizedString(@"Search_you_can");
        [_viewOverlay addSubview:labelTitle];
        
        [labelTitle makeConstraints:^(MASConstraintMaker *make)
         {
             make.top.equalTo(_viewOverlay.top).with.offset(113);
             make.centerX.equalTo(_viewOverlay.centerX);
         }];
        
        UIView *viewLine = [UIView new];
        viewLine.backgroundColor = [UIColor kdBackgroundColor1];
        [_viewOverlay addSubview:viewLine];
        
        [viewLine makeConstraints:^(MASConstraintMaker *make)
         {
             make.width.mas_equalTo(200);
             make.height.mas_equalTo(0.5);
             make.top.equalTo(labelTitle.bottom).with.offset(11);
             make.centerX.equalTo(_viewOverlay.centerX);
         }];
        
        UIImageView *imageView0 = [UIImageView new];
        imageView0.image = [UIImage imageNamed:@"search_tip_contacts"];
        [_viewOverlay addSubview:imageView0];
        
        float fLeftPaddingImage= (ScreenFullWidth - 200)/2.0;
        [imageView0 makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(_viewOverlay.left).with.offset(fLeftPaddingImage-10);
             make.width.mas_equalTo(40);
             make.top.equalTo(labelTitle.bottom).with.offset(20);
             make.height.mas_equalTo(40);
         }];
        
        UIImageView *imageView1 = [UIImageView new];
        imageView1.image = [UIImage imageNamed:@"search_tip_chat"];
        [_viewOverlay addSubview:imageView1];
        
        [imageView1 makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(imageView0.right).with.offset(21);
             make.width.mas_equalTo(40);
             make.top.equalTo(labelTitle.bottom).with.offset(20);
             make.height.mas_equalTo(40);
         }];
        
        UIImageView *imageView2 = [UIImageView new];
        imageView2.image = [UIImage imageNamed:@"search_tip_file"];
        [_viewOverlay addSubview:imageView2];
        
        [imageView2 makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(imageView1.right).with.offset(21);
             make.width.mas_equalTo(40);
             make.top.equalTo(labelTitle.bottom).with.offset(20);
             make.height.mas_equalTo(40);
         }];
        
        UIImageView *imageView3 = [UIImageView new];
        imageView3.image = [UIImage imageNamed:@"search_tip_record"];
        [_viewOverlay addSubview:imageView3];
        
        [imageView3 makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(imageView2.right).with.offset(21);
             make.width.mas_equalTo(40);
             make.top.equalTo(labelTitle.bottom).with.offset(20);
             make.height.mas_equalTo(40);
         }];
        
        UILabel *label0 = [UILabel new];
        label0.font = FS6;
        label0.text = ASLocalizedString(@"XTContactContentViewController_Contact");
        label0.textColor = FC3;
        label0.textAlignment = NSTextAlignmentCenter;
        [_viewOverlay addSubview:label0];
        
//        float fLeftPaddingLabel = (ScreenFullWidth - 200)/2.0;
        
        [label0 makeConstraints:^(MASConstraintMaker *make)
         {
             make.centerX.equalTo(imageView0);
//             make.left.equalTo(_viewOverlay.left).with.offset(fLeftPaddingLabel-10);
//             make.width.mas_equalTo(65);
             make.top.equalTo(imageView0.bottom).with.offset(4);
         }];
        
        UILabel *label1 = [UILabel new];
        label1.font = FS6;
        label1.text = ASLocalizedString(@"Search_you_can_session");
        label1.textColor = FC3;
        label1.textAlignment = NSTextAlignmentCenter;
        [_viewOverlay addSubview:label1];
        
        [label1 makeConstraints:^(MASConstraintMaker *make)
         {
             make.centerX.equalTo(imageView1);
//             make.left.equalTo(label0.right).with.offset(1);
//             make.width.mas_equalTo(65);
             make.top.equalTo(imageView0.bottom).with.offset(4);
         }];
        
        UILabel *label2 = [UILabel new];
        label2.font = FS6;
        label2.text = ASLocalizedString(@"KDCommunityShareView_File");
        label2.textColor = FC3;
        label2.textAlignment = NSTextAlignmentCenter;
        [_viewOverlay addSubview:label2];
        
        [label2 makeConstraints:^(MASConstraintMaker *make)
         {
             make.centerX.equalTo(imageView2);
//             make.left.equalTo(label1.right).with.offset(1);
//             make.width.mas_equalTo(65);
             make.top.equalTo(imageView0.bottom).with.offset(4);
         }];
        
        UILabel *label3 = [UILabel new];
        label3.font = FS6;
        label3.text = ASLocalizedString(@"Search_you_can_session_records");
        label3.textColor = FC3;
        label3.textAlignment = NSTextAlignmentCenter;
        [_viewOverlay addSubview:label3];
        
        [label3 makeConstraints:^(MASConstraintMaker *make)
         {
             make.centerX.equalTo(imageView3);
//             make.left.equalTo(label2.right).with.offset(1);
//             make.width.mas_equalTo(65);
             make.top.equalTo(imageView0.bottom).with.offset(4);
         }];
        
    }
    return _viewOverlay;
}



#pragma mark - UISearchBarDelegate -

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.searchDisplayController setActive:YES animated:YES];
    [KDEventAnalysis event:event_session_search];
    
    if (self.blockBeginSearching) {
        self.blockBeginSearching();
    }
    
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    for(id cc in [searchBar.subviews[0] subviews])
//    {
//        if([cc isKindOfClass:[UIButton class]])
//        {
//            UIButton *btn = (UIButton *)cc;
//            [btn setTitle:ASLocalizedString(@"Global_Cancel")  forState:UIControlStateNormal];
//            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        }
//    }
    [self showViewOverlay];
}
- (void)showViewOverlay {
    [self.searchDisplayController.searchContentsController.view addSubview:self.viewOverlay];
}

- (void)hideViewOverlay {
    [self.viewOverlay removeFromSuperview];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self hideViewOverlay];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    if(![[BOSSetting sharedSetting] isNetworkOrgTreeInfo])
//    {
//        if (searchBar.text.length > 0) {
//            [self hideViewOverlay];
//        } else {
//            [self showViewOverlay];
//        }
//        
//        [self search:searchText];
//    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchtext = searchBar.text;
    if (searchtext.length > 0) {
        [self hideViewOverlay];
    } else {
        [self showViewOverlay];
    }
    
//    if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
//        [self getPersonSearchClient:searchtext];
//    }else{
        [self search:searchtext];
//    }
}

//- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if(![[BOSSetting sharedSetting] isNetworkOrgTreeInfo])
//        return YES;
//    
//    if ([text isEqualToString:@"\n"])
//    {
//        if (searchBar.text.length > 0) {
//            [self hideViewOverlay];
//        } else {
//            [self showViewOverlay];
//        }
//        
//        [self getPersonSearchClient:searchBar.text];
//    }
//    
//    return YES;
//}

- (KDTableViewCellSeparatorLineStyle)cellSeparatorLineStyleWithIndexPath:(NSIndexPath *)indexPath DataArray:(NSArray *)array
{
    if (((indexPath.section != ([self.results count] - 1)) && (indexPath.row == [array count] - 1))) {
        return KDTableViewCellSeparatorLineNone;
    }
    else if(indexPath.row == 2)
    {
        return KDTableViewCellSeparatorLineTop;
    }
    else
    {
        return KDTableViewCellSeparatorLineSpace;
    }
}

@end
