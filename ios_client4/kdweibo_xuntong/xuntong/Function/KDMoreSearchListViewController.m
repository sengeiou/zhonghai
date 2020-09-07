//
//  KDMoreSearchListViewController.m
//  kdweibo
//
//  Created by sevli on 15/8/5.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDMoreSearchListViewController.h"

#import "XTSearchCell.h"
#import "XTTimelineSearchCell.h"
#import "KDPublicAccountSearchCell.h"
#import "KDFileSearchCell.h"
#import "KDMoreSearchCell.h"

//#import "KDDetail.h"
#import "XTChatViewController.h"
#import "XTTimelineViewController.h"
#import "XTPubAcctUserChatListViewController.h"
#import "XTFileDetailViewController.h"
#import "KDTimelineManager.h"
#import "KDPublicAccountCache.h"
#import "KDPubAccDetailViewController.h"
#import "XTPersonDetailViewController.h"
#import "T9.h"

#import "ContactClient.h"
#import "BOSSetting.h"

#import "KDSearch.h"
#import "KDSearchTextCell.h"

#import "MJRefresh.h"
#import "KDSearchTextModel.h"

@interface KDMoreSearchListViewController ()<UITableViewDataSource,UITableViewDelegate,XTFileDetailViewControllerDelegate,UITextFieldDelegate>
@property (nonatomic, strong) NSDictionary *dataDictionary;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) dispatch_queue_t  searchQueue;


@property (nonatomic, strong) ContactClient *client;
@property (nonatomic, strong) KDSearch *search;

@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) BOOL isSearching;

@end

@implementation KDMoreSearchListViewController


-(instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _dataDictionary = dictionary;
        _currentPage = 1;
        self.isSearching = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    self.title = [self chooseTitle];
    
    _searchQueue = dispatch_queue_create("com.search.KDMoreSearchListViewController", NULL);
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (NSString *)chooseTitle
{
    NSString *key = [[self.dataDictionary allKeys] firstObject];
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

#pragma mark - CancelSearch
- (void)cancelSearch
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeSearchUserInterface)])
    {
        [self.delegate closeSearchUserInterface];
    }
}

#pragma mark - UserInterface

- (void)initUI
{
    UIButton *rightBtn = [UIButton normalBtnWithTile:ASLocalizedString(@"KDChooseOrganizationViewController_Close")];
    [rightBtn addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    //[self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
    
    
    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:backBtn]];
    
    
    if (!self.client)
    {
        self.client = [[ContactClient alloc]initWithTarget:self action:@selector(loadMoreSearchDidReceived:result:)];
    }
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.frame = CGRectMake(0, -1, ScreenFullWidth, ScreenFullHeight - 64.f);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    //网络通讯录的时候,禁止下拉
    if(self.searchType == kSearchTypeContact && [[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
        self.tableView.bounces = NO;
    }
    
    __weak __typeof(self) weakSelf = self;
    
    if (self.searchType == KSearchTypeText || self.searchType == kSearchTypeFile)
    {
        [self.tableView addFooterWithCallback:^{
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf loadMore];
            });
        }];
    }
    
    [self.tableView addHeaderWithCallback:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf refreshCurrentPageWithType:weakSelf.searchType];
        });
    }];
    
    self.tableView.footerRefreshingText = ASLocalizedString(@"KDStatusDetailViewController_loading");
    self.tableView.headerRefreshingText = ASLocalizedString(@"KDStatusDetailViewController_refreshing");
}

- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

//下拉刷新界面
- (void)refreshCurrentPageWithType:(KDSearchType)searchType
{
    switch (searchType){
        case kSearchTypeContact:
        {
            [self refreshContact];
        }
            break;
            
        case kSearchTypeGroup:
        {
            [self refreshGroup];
        }
            break;
            
        case kSearchTypePublic:
        {
            [self refreshPublic];
        }
            break;
            
        case KSearchTypeText:
        {
            [self refreshText];
        }
            break;
            
        case kSearchTypeFile:
        {
            [self refreshFile];
        }
            break;
            
        default:
            break;
    }
    
}

//刷新通讯录搜索
- (void)refreshContact
{
    __weak __typeof(self) weakSelf = self;
    NSArray *contact = [[T9 sharedInstance] search:self.searchWord];
    NSString *key = [NSString stringWithFormat:@"%ld",(long)kSearchTypeContact];
    NSDictionary *dataDict = @{key : contact};
    
    if (contact.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataDictionary = dataDict;
            [weakSelf.tableView reloadData];
            [weakSelf.tableView headerEndRefreshing];
        });
    }
    [self umeng:self.searchWord];
}

//刷新多人会话搜索
- (void)refreshGroup
{
    __weak __typeof(self) weakSelf = self;
    __block NSArray *contact = nil;
    dispatch_async(_searchQueue, ^{
        contact = [[T9 sharedInstance] search:self.searchWord];
        NSMutableArray *groups = [[NSMutableArray alloc] init];
        NSArray *groupsWithName = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupsWithLikeGroupName:self.searchWord];
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
        
        if ([groupsWithName count] > 0) {
            [groups addObjectsFromArray:groupsWithName];
        }
//        if ([groupsWithIds count] > 0) {
//            [groups addObjectsFromArray:groupsWithIds];
//        }
        
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
        NSString *key = [NSString stringWithFormat:@"%ld",(long)kSearchTypeGroup];
        NSDictionary *dataDict = @{key : groups};
        
        if (groups > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.dataDictionary = dataDict;
                [weakSelf.tableView reloadData];
                [weakSelf.tableView headerEndRefreshing];
            });
        }
    });
}

//刷新订阅信息搜索
- (void)refreshPublic
{
    __weak __typeof(self) weakSelf = self;
    NSArray *publics = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicAccountsWithLikeName:self.searchWord];
    
    NSString *key = [NSString stringWithFormat:@"%ld",(long)kSearchTypePublic];
    NSDictionary *dataDict = @{key : publics};
    if (publics.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataDictionary = dataDict;
            [weakSelf.tableView reloadData];
            [weakSelf.tableView headerEndRefreshing];
        });
    }
    [self umeng:self.searchWord];
}

//刷新文本搜索
- (void)refreshText
{
    self.currentPage = 1;
    [self searchMoreWithType:KSearchTypeText page:self.currentPage];
}

//刷新文件搜索
- (void)refreshFile
{
    self.currentPage = 1;
    [self searchMoreWithType:kSearchTypeFile page:self.currentPage];
}

//上拉加载更多
- (void)loadMore
{
    self.currentPage ++;
    [self searchMoreWithType:self.searchType page:self.currentPage];
}

- (void)searchMoreWithType:(KDSearchType)searchType page:(int)page
{
    if (self.isSearching) {
        //为了保险起见，不能同时搜索
        return;
    }
    self.isSearching = YES;
    
    if (searchType == KSearchTypeText)
    {
        [self.client searchTextRecordListWithWord:self.searchWord Page:page Count:10];
    }
    else if(searchType == kSearchTypeFile)
    {
        [self.client searchFileRecordListWithWord:self.searchWord Page:page Count:10];
    }
}


- (void)loadMoreSearchDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result == nil || ![result isKindOfClass:[BOSResultDataModel class]]) {
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
        //出错的时候，如果是上拉加载更多，则减去1
        if (self.currentPage > 1) {
            self.currentPage --;
        }
        self.isSearching = NO;
        return;
    }
    
    if (result.success && [result.data isKindOfClass:[NSDictionary class]])
    {
        NSMutableArray *searchArray = [NSMutableArray arrayWithCapacity:10];
        NSDictionary *data = (NSDictionary *)result.data;
        
        [self shouldHideTableviewFooterRefreshWithDictionary:data];
        
        if (self.searchType == kSearchTypeFile)//文件
        {
            for (NSDictionary *dict in data[@"list"])
            {
                NSDictionary *messageDict = [dict objectForKey:@"message"];
                if(messageDict && ![messageDict isKindOfClass:[NSNull class]])
                {
                    NSString *highlight = [(NSArray *)dict[@"highlight"] firstObject];
                    MessageFileDataModel *searchModel = [[MessageFileDataModel alloc]initWithDictionary:[messageDict objectForKey:@"param"]];
                    searchModel.highlightName = highlight;
                    searchModel.fileSendTime = messageDict[@"sendTime"];
                    NSString *sendUserID = messageDict[@"fromUserId"];
                    searchModel.wbUserId = sendUserID;
//                    PersonSimpleDataModel *fileSender = [KDCacheHelper personForKey:sendUserID];
                    searchModel.highlightName = [self highlightWithSearchString:self.searchWord ContentString:messageDict[@"content"] HighlightString:highlight];
//                    searchModel.fileSendPersonName = fileSender.personName;
                    NSString *msgIdID = messageDict[@"msgId"];
                    if(msgIdID && ![msgIdID isKindOfClass:[NSNull class]])
                    {
                        searchModel.msgId = msgIdID;
                    }
                    NSDictionary *groupDict = dict[@"group"];
                    if(groupDict && ![groupDict isKindOfClass:[NSNull class]])
                    {
                        NSString *groupIdStr = groupDict[@"groupId"];
                        if(groupIdStr && ![groupIdStr isKindOfClass:[NSNull class]])
                        {
                            searchModel.groupId = groupIdStr;
                        }
                    }
                    
                    [searchArray addObject:searchModel];
                }
            }
        }
        else if(self.searchType == KSearchTypeText)//文本
        {
            for (NSDictionary *dict in data[@"list"])
            {
                NSString *highlight = [(NSArray *)dict[@"highlight"] firstObject];
                KDSearchTextModel *searchModel = [[KDSearchTextModel alloc]initWithDictionary:dict[@"group"]];
                [searchModel setMessageDataModel:dict[@"message"] Highlight:highlight];
                searchModel.highlightMessage = [self highlightWithSearchString:self.searchWord ContentString:dict[@"message"][@"content"] HighlightString:highlight];
                
                [searchArray addObject:searchModel];
            }
        }
        
        if (searchArray.count > 0)
        {
            NSString *key = [NSString stringWithFormat:@"%ld",(long)_searchType];
            
            NSMutableArray *muaArray = nil;
            
            if (self.currentPage == 1)
            {
                muaArray = [NSMutableArray arrayWithArray:searchArray];
            }
            else
            {
                NSArray *array = self.dataDictionary[[[self.dataDictionary allKeys] firstObject]];
                muaArray = [NSMutableArray arrayWithArray:array];
                [muaArray addObjectsFromArray:searchArray];
            }
            
            NSDictionary *dict = @{key : muaArray};
            self.dataDictionary = dict;
        }
        
        [self.tableView reloadData];
    }
    else {
        //出错的时候，如果是上拉加载更多，则减去1
        if (self.currentPage > 1) {
            self.currentPage --;
        }
    }
    
    [self.tableView headerEndRefreshing];
    [self.tableView footerEndRefreshing];
    self.isSearching = NO;
}

- (NSString *)highlightWithSearchString:(NSString *)searchString ContentString:(NSString *)contentString HighlightString:(NSString *)highlightString
{
    NSString *resultString = nil;
    
    if (highlightString)
    {
        //        "<em class=\"highlight\">test</em>001.doc"
        NSString *tagHeaderString =@"<em class=\"highlight\">";
        
        NSRange rang = [highlightString rangeOfString:tagHeaderString];
        
        if (rang.location >= 10)
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
- (void)shouldHideTableviewFooterRefreshWithDictionary:(NSDictionary *)dataDict
{
    if ([dataDict[@"hasMore"] integerValue] == 0)
    {
        [self.tableView setFooterHidden:YES];
    }
    else
    {
        [self.tableView setFooterHidden:NO];
    }
}

#pragma mark - TableViewDelegate && DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[self.dataDictionary allKeys] firstObject];
    NSArray *array = self.dataDictionary[key];
    return array.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self.dataDictionary allKeys] firstObject];
    //通讯录
    if ([key integerValue] == kSearchTypeContact) {
        NSArray *contacts = self.dataDictionary[key];
        if (contacts && [contacts count] > indexPath.row )
        {
            XTSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
            if (cell == nil) {
                cell = [[XTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
            }
            
            if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
                cell.person = [contacts objectAtIndex:indexPath.row];
            }else{
                cell.searchResult = contacts[indexPath.row];
            }
//            cell.separatorLineStyle = (indexPath.row == [contacts count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
            return cell;
        }
    }
    //多人群组
    else if ([key integerValue] == kSearchTypeGroup) {
        
        NSArray *groups = self.dataDictionary[key];
        if (groups && [groups count] > indexPath.row  ) {
            XTTimelineSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
            if (cell == nil) {
                cell = [[XTTimelineSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
            }
            cell.group = groups[indexPath.row];
            cell.separatorLineStyle = (indexPath.row == [groups count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
            return cell;
        }
    }
    //订阅
    else if ([key integerValue] == kSearchTypePublic) {
        
        NSArray *publics = self.dataDictionary[key];
        if (publics && [publics count] > indexPath.row ) {
            KDPublicAccountSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
            if (cell == nil) {
                cell = [[KDPublicAccountSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
            }
            cell.person = publics[indexPath.row];
            cell.separatorLineStyle = (indexPath.row == [publics count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
            return cell;
        }
    }
    //文件
    else if ([key integerValue] == kSearchTypeFile) {
        
        NSArray *files = self.dataDictionary[key];
        if (files && [files count] > indexPath.row ) {
            KDFileSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
            if (cell == nil) {
                cell = [[KDFileSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
            }
            cell.file = files[indexPath.row];
            cell.separatorLineStyle = (indexPath.row == [files count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
            return cell;
        }
    }
    //聊天记录
    else if ([key integerValue] == KSearchTypeText)
    {
        NSArray *textMessages = self.dataDictionary[key];
        
        KDSearchTextCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
        if (!cell)
        {
            cell = [[KDSearchTextCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
        }
        cell.searchModel = [textMessages objectAtIndex:indexPath.row];
        cell.separatorLineStyle = (indexPath.row == [textMessages count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *key = [[self.dataDictionary allKeys] firstObject];
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
            if (group.groupType == GroupTypePublic && [group.participantIds count] == 1) {
                PersonSimpleDataModel *person = [group firstParticipant];
                if ([person isPublicAccount]) {
                    KDPublicAccountDataModel *pubacc = [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:person.personId];
                    if (pubacc.manager) {
                        //管理员，进入代言人界面
                        [self toPublicList:pubacc];
                        return;
                    }
                }
            }
            [self toChat:group];
        }
    }
    else if ([key integerValue] == kSearchTypePublic) {
        KDPublicAccountSearchCell *cell = (KDPublicAccountSearchCell *)[tableView cellForRowAtIndexPath:indexPath];
        KDPublicAccountDataModel *person =  (KDPublicAccountDataModel *)cell.person;
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
    }
    else if ([key integerValue] == KSearchTypeText)
    {
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
    
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68.0f;
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
        
        [self.navigationController  pushViewController:chatViewController animated:YES];
    }
}


- (void)beforePush
{
    
}

- (void)toPersonDetail:(PersonSimpleDataModel *)person
{
    [self beforePush];
    XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc]initWithSimplePerson:person with:NO];
    personDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personDetail animated:YES];
//    [KDDetail toDetailWithPerson:person inController:self];
}


- (void)toChat:(GroupDataModel *)group
{
    [self beforePush];
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)toChatWithPerson:(PersonSimpleDataModel *)person
{
    [self beforePush];
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:person];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)toPublicList:(PersonSimpleDataModel *)person
{
    [self beforePush];
    XTPubAcctUserChatListViewController *publicTimelineViewController = [[XTPubAcctUserChatListViewController alloc] initWithPublicPerson:person];
    publicTimelineViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:publicTimelineViewController animated:YES];
}

- (void)toFileDetail:(FileModel *)file messageId:(NSString *)msgId groupId:(NSString *)groupId dedicatorId:(NSString *)dedicatorId
{
    [self beforePush];
    XTFileDetailViewController *filePreviewVC = [[XTFileDetailViewController alloc] initWithFile:file];
    filePreviewVC.hidesBottomBarWhenPushed = YES;
    filePreviewVC.fileDetailFunctionType = XTFileDetailFunctionType_count;
    filePreviewVC.messageId = msgId;
    filePreviewVC.threadId = groupId;
    filePreviewVC.dedicatorId = dedicatorId;
//    PersonSimpleDataModel *model = [KDCacheHelper personForKey:dedicatorId];
//    if(model)
//    {
//        filePreviewVC.dedicatorId = model.wbUserId;
//    }
    
    filePreviewVC.delegate = self;
    filePreviewVC.fileDetailSourceType = XTFileDetailSourceTypeSearch;
    [self.navigationController pushViewController:filePreviewVC animated:YES];
}

- (void)umeng:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    
    T9SearchTextType type = [T9 calcSearchType:text];
    if (type == T9SearchTextChinese) {
        [KDEventAnalysis event:event_contact_search_type attributes:@{ label_contact_search_type_type : label_contact_search_type_type_chinese }];
    }
    else if (type == T9SearchTextNumber) {
        [KDEventAnalysis event:event_contact_search_type attributes:@{ label_contact_search_type_type : label_contact_search_type_type_number }];
    }
    else {
        [KDEventAnalysis event:event_contact_search_type attributes:@{ label_contact_search_type_type : label_contact_search_type_type_pinyin }];
    }
    [KDEventAnalysis event:event_contact_kpi attributes:@{ label_contact_kpi_source : label_contact_kpi_source_search }];
}

@end
