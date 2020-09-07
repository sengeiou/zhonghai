//
//  PubGroupListViewController.m
//  ContactsLite
//
//  Created by Gil on 12-12-25.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "XTPublicTimelineViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ContactLoginDataModel.h"
#import "ContactClient.h"
#import "GroupListDataModel.h"
#import "ContactConfig.h"
#import "PersonDataModel.h"
#import "GroupDataModel.h"
#import "RecordDataModel.h"
#import "XTChatViewController.h"
#import "XTSetting.h"
#import "UIButton+XT.h"
#import "XTPersonDetailViewController.h"
#import "XTPublicListViewController.h"
#import "XTDeleteService.h"
#import "XTPubAcctUserChatListViewController.h"
#import "ContactClient.h"
#import "MBProgressHUD.h"
#import "KDSubscribeViewController.h"

#define kPerPageSize (int)15

@interface XTPublicTimelineViewController ()
{
    dispatch_queue_t _dbReadQueue;
    ContactClient * _contactClient;
    MBProgressHUD * _hud;
    PersonSimpleDataModel * _personDM;
    GroupDataModel * _groupDM;
}

@property (nonatomic, strong) ContactClient *client;
@property (nonatomic, strong) ContactClient *markAllMsgClient;
@property (nonatomic, strong) ContactClient *toggleGroupTopClient;

@property (nonatomic, assign) CGPoint lastContentOffset;

@property (nonatomic, strong) GroupDataModel *targetGroup;

@end

@implementation XTPublicTimelineViewController


- (id)init
{
    self = [super init];
    if (self) {
        self.groups = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _dbReadQueue = dispatch_queue_create("com.publictimeline.queue", NULL);
    
    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDSubscribeViewController_Read_subscribe")style:UIBarButtonItemStylePlain target:self action:@selector(pubDetail:)];
    UIBarButtonItem *rightNegativeSpacer = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                            target:nil action:nil];
    rightNegativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:rightNegativeSpacer,rightItem, nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 68.0;
    [self.view addSubview:self.tableView];
    
    self.lastContentOffset = self.tableView.contentOffset;
    
    self.groups = [NSMutableArray array];
    [self reloadTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be     recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = ASLocalizedString(@"XTContactContentViewController_Tip_2");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"reloadPubTimeLineGroupTable" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadPubTimeLineGroupTable" object:nil];
    
    [self.tableView setEditing:NO];
    
    // 从此界面返回消息界面，折叠公众号为已读
    [XTSetting sharedSetting].foldPublicAccountPressed = YES;
    [[XTSetting sharedSetting] saveSetting];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reloadTable];
}

- (void)pubDetail:(UIButton *)btn
{
    //add
    [KDEventAnalysis event:event_pubacc_subscribe];
    [KDEventAnalysis eventCountly:event_pubacc_subscribe];
    KDSubscribeViewController *publiclistViewController = [[KDSubscribeViewController alloc] init];
    publiclistViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:publiclistViewController animated:YES];
//    XTPublicListViewController*publiclistViewController = [[XTPublicListViewController alloc] init];
//    publiclistViewController.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:publiclistViewController animated:YES];
}

#pragma mark - group list

- (void)reloadTable
{
    dispatch_async(_dbReadQueue, ^{
        int limit = 100;//self.groups.count > 0 ? (int)self.groups.count : kPerPageSize;
        NSMutableArray*array = [[[XTDataBaseDao sharedDatabaseDaoInstance] queryFoldPublicGroupListWithLimit:limit offset:0] mutableCopy];
        [self.groups removeAllObjects];
        [self.groups addObjectsFromArray:array];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark - UITableViewDelegate and Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    XTTimelineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[XTTimelineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    GroupDataModel *groupDM = [self.groups objectAtIndex:indexPath.row];
    cell.imageViewTop.hidden = !groupDM.isTop;
    cell.group = groupDM;
    cell.separatorLineStyle = (indexPath.row == [self.groups count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupDataModel *groupDM = [self.groups objectAtIndex:indexPath.row];
    if (groupDM) {
        PersonSimpleDataModel *person = [groupDM.participant firstObject];
        if(person && person.isPublicAccount && [self checkIsPublicAccManager:groupDM])
        {//公共号 & 管理员
            [self pubGroupList:person group:groupDM];
        }
        else
        {
            [self openChatViewController:groupDM];
        }
        
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupDataModel *model = self.groups[indexPath.row];
    self.targetGroup = model;
    
    // 删除
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:ASLocalizedString(@"KDCommentCell_delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        GroupDataModel *groupDM = [self.groups objectAtIndex:indexPath.row];
        if ([[XTDataBaseDao sharedDatabaseDaoInstance] setPublicGroupListToDeleteWithGroupId:groupDM.groupId withPublicId:nil]) {
            
            [[XTDeleteService shareService] deleteGroupWithGroupId:groupDM.groupId];
            
            __weak XTPublicTimelineViewController *weakSelf = self;
            dispatch_async(_dbReadQueue, ^{
                [weakSelf.groups removeObjectAtIndex:indexPath.row];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            });
        }

    }];
    
    // 标为已读
    UITableViewRowAction *readAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:ASLocalizedString(@"XTTimelineViewController_Read") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [KDEventAnalysis event:event_session_settings_markread];
        if (self.markAllMsgClient == nil) {
            self.markAllMsgClient = [[ContactClient alloc] initWithTarget:self action:@selector(markAllReadDidReceived:result:)];
        }
        
        [self.markAllMsgClient markAllReadWithGroupID:model.groupId];
        
    }];
    readAction.backgroundColor = [UIColor orangeColor];
    
    // 置顶
    UITableViewRowAction *topAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:(model.isTop) ? ASLocalizedString(@"XTTimelineViewController_Top_Cancel") : ASLocalizedString(@"XTTimelineViewController_Top") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (self.toggleGroupTopClient == nil) {
            self.toggleGroupTopClient = [[ContactClient alloc] initWithTarget:self action:@selector(toggleGroupTopDidReceived:result:)];
        }
        
        if (model.isTop) {
            [KDEventAnalysis event:event_session_top_cancel];
        } else {
            [KDEventAnalysis event:event_session_top_set];
            [self.groups exchangeObjectAtIndex:indexPath.row withObjectAtIndex:0];
            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
            [tableView moveRowAtIndexPath:indexPath toIndexPath:firstIndexPath];
        }
        
        [self.toggleGroupTopClient toggleGroupTopWithGroupId:model.groupId status:!model.isTop];
            
    }];
    topAction.backgroundColor = [UIColor lightGrayColor];
    
    return (model.unreadCount > 0) ? @[deleteAction,readAction,topAction] : @[deleteAction,topAction];
}

- (void)markAllReadDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"XTTimelineViewController_Read_Fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    [[XTDataBaseDao sharedDatabaseDaoInstance] updateAllRecordsToReadWithGroup:self.targetGroup];
    self.markAllMsgClient = nil;
    [self reloadTable];
}

- (void)toggleGroupTopDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"XTTimelineViewController_Top_Fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    [self.targetGroup toggleTop];
    [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithStatus:self.targetGroup.status withGroupId:self.targetGroup.groupId];
    self.toggleGroupTopClient = nil;
    [self reloadTable];
}

//判断当前用户是否指定公号的管理员
- (BOOL)checkIsPublicAccManager:(GroupDataModel *)publicGroup
{
    PersonSimpleDataModel *person = [publicGroup.participant firstObject];
    PersonDataModel * pm =
    [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicPersonSimple:person.personId];
    if(pm == nil)
        return NO;
    else
        return pm.manager;
}

- (void)openChatViewController:(GroupDataModel *)groupDM
{
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:groupDM pubAccount:nil mode:ChatPrivateMode];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

-(void)pubGroupList:(PersonSimpleDataModel *)personDM group:(GroupDataModel *)groupDM
{
    if (_contactClient == nil)
    {
        _contactClient = [[ContactClient alloc] initWithTarget:self action:@selector(publicGroupListDidReceived:result:)];
    }
    [_contactClient publicGroupList:personDM.personId updateTime:[[XTSetting sharedSetting].pubAccountsUpdateTimeDict objectForKey:personDM.personId]];
    if(_hud == nil)
    {
        _hud = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:_hud];
    }
    [_hud setLabelText:ASLocalizedString(@"KDSubscribeViewController_Load")];
    [_hud show:YES];
    
    _personDM = personDM;
    _groupDM = groupDM;
}

- (void)publicGroupListDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    [_hud hide:YES];
    if (result.success && result.data) {
        GroupListDataModel *groupList = [[GroupListDataModel alloc] initWithDictionary:result.data];
        //更新updateTime
        if (![groupList.updateTime isEqualToString:@""])
        {
            [[XTSetting sharedSetting].pubAccountsUpdateTimeDict setObject:groupList.updateTime forKey:_personDM.personId];
        }
        [[XTSetting sharedSetting] saveSetting];
        if ([groupList.list count] > 0)
        {
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePublicGroupList:groupList withPublicId:_personDM.personId];
        }
        //管理员，打开消息页面
        PubAccountDataModel *publAccountDataModel = [[PubAccountDataModel alloc] init];
        publAccountDataModel.publicId = _personDM.personId;
        publAccountDataModel.name = _personDM.personName;
        publAccountDataModel.state = _personDM.state;
        XTPubAcctUserChatListViewController *publicTimelineViewController = [[XTPubAcctUserChatListViewController alloc] initWithPubAccount:publAccountDataModel andPerson:_personDM];
        [self.navigationController pushViewController:publicTimelineViewController animated:YES];
    }
    else
    {
        [self openChatViewController:_groupDM];
    }
}

#pragma mark - UITableView Delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{/*
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GroupDataModel *groupDM = [self.groups objectAtIndex:indexPath.row];
        if ([[XTDataBaseDao sharedDatabaseDaoInstance] setPublicGroupListToDeleteWithGroupId:groupDM.groupId withPublicId:nil]) {
            
            [[XTDeleteService shareService] deleteGroupWithGroupId:groupDM.groupId];
            
            __weak XTPublicTimelineViewController *weakSelf = self;
            dispatch_async(_dbReadQueue, ^{
                [weakSelf.groups removeObjectAtIndex:indexPath.row];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            });
        }
    }*/
}

/*  http://192.168.0.22/jira/browse/KSSP-15351
    时间线上去掉头像点击打开详情，改为进入会话。
 
#pragma mark - XTGroupHeaderImageViewDelegate

- (void)groupHeaderClicked:(XTGroupHeaderImageView *)headerImageView person:(PersonSimpleDataModel *)person
{
    if ([person isPublicAccount]) {
        XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:person with:YES];
        personDetail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:personDetail animated:YES];
        
    } else {
        XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:person with:NO];
        personDetail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:personDetail animated:YES];
    }

}
 */

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(self.groups == nil || [self.groups count] == 0)
        return;
    
    if (self.lastContentOffset.y <= scrollView.contentOffset.y) {
        dispatch_async(_dbReadQueue, ^{
            NSArray *temp = [[XTDataBaseDao sharedDatabaseDaoInstance] queryFoldPublicGroupListWithLimit:kPerPageSize offset:(int)self.groups.count];
            [self.groups addObjectsFromArray:temp];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y > self.lastContentOffset.y) {
        self.lastContentOffset = scrollView.contentOffset;
    }
}

- (void)dealloc
{
//    _tableView.delegate = nil;
//    _tableView.dataSource = nil;
}

@end
