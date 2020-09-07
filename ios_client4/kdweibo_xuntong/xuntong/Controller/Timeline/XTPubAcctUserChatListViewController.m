//
//  XTPubAcctUserChatListViewController.m
//  kdweibo
//
//  Created by stone on 14-5-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTPubAcctUserChatListViewController.h"
#import "ContactLoginDataModel.h"
#import "UIButton+XT.h"
#import "NeedUpdateDataModel.h"
#import "XTSetting.h"
#import "ContactClient.h"

#define kPerPageSize (int)15

@interface XTPubAcctUserChatListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    dispatch_queue_t _dbReadQueue;
}

@property (nonatomic, strong) PubAccountDataModel *pubAccount;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL hasLoadPubGroupList;
@property (nonatomic, strong) PersonSimpleDataModel * pdm;
@property (nonatomic, strong) ContactClient *client;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, assign) CGPoint lastContentOffset;

-(void)pubGroupList;

@end

@implementation XTPubAcctUserChatListViewController



- (id)initWithPubAccount:(PubAccountDataModel *)pubAccount andPerson:(PersonSimpleDataModel *)pdm
{
    self = [super init];
    if (self) {
        self.navigationItem.title = pubAccount.name;
        self.pubAccount = pubAccount;
        self.pdm = pdm;
        self.hasLoadPubGroupList = NO;
    }
    return self;
}

- (id)initWithPubAccount2:(PubAccountDataModel *)pubAccount andPerson:(PersonSimpleDataModel *)pdm
{
    self = [super init];
    if (self) {
        self.navigationItem.title = pubAccount.name;
        self.pubAccount = pubAccount;
        self.pdm = pdm;
        self.hasLoadPubGroupList = YES;
    }
    return self;
}

- (id)initWithPublicPerson:(PersonSimpleDataModel *)person {
    self = [super init];
    
    if (self) {
        self.pdm = person;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.groups = nil;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dbReadQueue = dispatch_queue_create("com.publictimeline.queue", NULL);
    
    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    
    if(self.pdm)
    {
        UIButton *chatButton = [UIButton buttonWithTitle:ASLocalizedString(@"XTPubAcctUserChatListViewController_Speak")];
        [chatButton addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *chatItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
        UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = -15.f;
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:space,chatItem, nil];
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, ScreenFullWidth, ScreenFullHeight) style:UITableViewStylePlain];
    self.tableView.backgroundColor = BOSCOLORWITHRGBA(0xF0F0F0, 1.0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 66.0;
    [self.view addSubview:self.tableView];
    
    self.lastContentOffset = self.tableView.contentOffset;
    
    if(self.hasLoadPubGroupList)
    {
        [self reloadTable];
    }
    else
    {
        [self pubGroupList];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdate:) name:@"pubNeedUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"reloadPubTimeLineGroupTable" object:nil];
    
    self.navigationItem.title = ASLocalizedString(@"XTContactContentViewController_Tip_2");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pubNeedUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadPubTimeLineGroupTable" object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reloadTable];
}

- (void)chat:(UIButton *)btn
{
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:self.pdm];
    
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

-(void)needUpdate:(NSNotification *)notification
{
    [self pubGroupList];
//    id object = [notification object];
//    if (object != nil && [object isKindOfClass:[PubAccountList class]]) {
//        PubAccountList *account = (PubAccountList *)object;
//        for (PubAccount *pubAccount in account.list) {
//            if ([pubAccount.publicId isEqualToString:_pubAccount.publicId]) {
//                if (pubAccount.flag) {
//                    [self pubGroupList];
//                }
//                break;
//            }
//        }
//    }
}

#pragma mark - group list

-(void)pubGroupList
{
    if (self.client == nil) {
        self.client = [[ContactClient alloc] initWithTarget:self action:@selector(publicGroupListDidReceived:result:)];
    }
    [self.client publicGroupList:self.pubAccount.publicId updateTime:[[XTSetting sharedSetting].pubAccountsUpdateTimeDict objectForKey:self.pubAccount.publicId]];
}

- (void)publicGroupListDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    
    if (result.success && result.data) {
        GroupListDataModel *groupList = [[GroupListDataModel alloc] initWithDictionary:result.data];
        //更新updateTime
        if (![groupList.updateTime isEqualToString:@""]) {
            [[XTSetting sharedSetting].pubAccountsUpdateTimeDict setObject:groupList.updateTime forKey:self.pubAccount.publicId];
        }
        [[XTSetting sharedSetting] saveSetting];
        
        if ([groupList.list count] > 0) {
            
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePublicGroupList:groupList withPublicId:self.pubAccount.publicId];
            
            [self reloadTable];
        }
    }
    else
    {
        if(result.error && ![result.error isEqualToString:@""])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationViewController_tips_1")message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }
}

- (void)reloadTable
{
    dispatch_async(_dbReadQueue, ^{
        self.groups = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicGroupListWithPublicId:self.pubAccount.publicId]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self setBackgroud:_groups.count == 0];
        });
    });
}
- (void) setBackgroud:(BOOL)isLoad {
    
    if (!_backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        [_backgroundView setUserInteractionEnabled:YES];
        _backgroundView.backgroundColor = [UIColor clearColor];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"boss_speech_noList"]];
        [bgImageView sizeToFit];
        bgImageView.center = CGPointMake(_backgroundView.bounds.size.width * 0.5f, 137.5f);
        
        [_backgroundView addSubview:bgImageView];
        
        [_tableView addSubview:_backgroundView];
    }
    if (!isLoad) {
        _backgroundView.hidden = YES;
        return;
    }
    _backgroundView.hidden = NO;
    
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
//        cell.containingTableView = tableView;
	}
    
    GroupDataModel *groupDM = [self.groups objectAtIndex:indexPath.row];
    cell.group = groupDM;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupDataModel *groupDM = [self.groups objectAtIndex:indexPath.row];
    if (groupDM) {
        int mode = ChatPublicMode;
        XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:groupDM pubAccount:_pubAccount mode:mode];
        chatViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatViewController animated:YES];
    }
}

#pragma mark - UITableView Delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GroupDataModel *groupDM = [self.groups objectAtIndex:indexPath.row];
        if ([[XTDataBaseDao sharedDatabaseDaoInstance] setPublicGroupListToDeleteWithGroupId:groupDM.groupId withPublicId:_pubAccount.publicId]) {
            
            [self.groups removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y > self.lastContentOffset.y) {
        self.lastContentOffset = scrollView.contentOffset;
    }
}

@end
