//
//  KDPubAccDetailViewController.m
//  kdweibo
//
//  Created by wenbin_su on 15/9/15.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPubAccDetailViewController.h"
#import "KDPubAccHeaderView.h"
#import "AppsClient.h"
#import "XTDeleteService.h"
#import "KDPublicAccountCache.h"
#import "KDPubAccFooterView.h"
#import "ContactClient.h"
#import "XTPubAccHistoryViewController.h"
#import "XTChatViewController.h"

@interface KDPubAccDetailViewController () <UITableViewDelegate, UITableViewDataSource,KDPubAccFooterViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PersonSimpleDataModel *pubAcct;
@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, strong) KDPubAccHeaderView *headerView;

@property (nonatomic, strong) AppsClient *attentionClient;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign, getter = isAttention) BOOL attention;
@property (nonatomic, assign, getter= canSubscribe) BOOL canSubscribe;

@property (nonatomic, strong) KDTableViewCell *alertMessageCell;
@property (nonatomic, strong) KDTableViewCell *viewHistoryCell;
@property (nonatomic, strong) UISwitch *pushSwitchButton;
@property (nonatomic, strong ) UIButton *button;
@property (nonatomic ,strong) KDPubAccFooterView *footerView;
@property (nonatomic, strong) ContactClient *togglePushClient;
@property (nonatomic, assign) NSUInteger remindRow;
@end

@implementation KDPubAccDetailViewController

- (void)dealloc {
    //[super dealloc];
//    self.tableView.delegate = nil;
//    self.tableView.dataSource = nil;
//    [_attentionClient cancelRequest];
}

- (id)init {
    self = [super init];
    if (self) {
        self.title = ASLocalizedString(@"KDPubAccDetailViewController_Detail");
        self.remindRow = NSUIntegerMax;
    }
    return self;
}

- (id)initWithPubAcctId:(NSString *)pubAcctId {
    if (pubAcctId.length == 0) {
        return [self init];
    }
    
    KDPublicAccountDataModel *pubAcct = [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:pubAcctId completionBlock:^(BOOL success, NSArray *pubAccts) {
        
        //本地没数据这里会回调
        if(success && pubAccts.count > 0)
        {
            PersonSimpleDataModel *pubAcct = pubAccts.firstObject;
            self.pubAcct = pubAcct;
            self.attention = [self.pubAcct.subscribe isEqualToString:@"1"] ? true : false;
            self.canSubscribe = [self.pubAcct.canUnsubscribe isEqualToString:@"1"] ? true : false;
            [self.tableView reloadData];
            [self updateSubViews];
        }
    }];
    
    return [self initWithPubAcct:pubAcct];
}

- (id)initWithPubAcct:(PersonSimpleDataModel *)pubAcct {
    self = [self init];
    if (self) {
        if (pubAcct) {
            self.pubAcct = pubAcct;
            //没找到哪里设置为BOOL类型了，先这么处理，以后要修改 PersonSimpleDataModel 中两个字段的类型
//            if ([self.pubAcct.subscribe isKindOfClass:[NSString class]]) {
                 self.attention = [self.pubAcct.subscribe isEqualToString:@"1"] ? true : false;
//            }else{
//                self.attention = self.pubAcct.subscribe;
//            }
            
//            if([self.pubAcct.canUnsubscribe isKindOfClass:[NSString class]]){
                self.canSubscribe = [self.pubAcct.canUnsubscribe isEqualToString:@"1"] ? true : false;
//            }else{
//                self.canSubscribe = self.pubAcct.canUnsubscribe;
//            }
           
        }
    }
    return self;
}

- (id)initWithPubAcct:(PersonSimpleDataModel *)pubAcct andGroup:(GroupDataModel *)group
{
    self = [self init];
    if (!self) {
        return nil;
    }
    
    if (pubAcct) {
        self.pubAcct = pubAcct;
        self.attention = [self.pubAcct.subscribe isEqualToString:@"1"] ? true : false;
        self.canSubscribe = [self.pubAcct.canUnsubscribe isEqualToString:@"1"] ? true : false;
        
        
        //从会话列表进来的搜不到note
        PersonDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicPersonSimple:pubAcct.personId];
        PersonSimpleDataModel *personData = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPublicPersonSimple:pubAcct.personId];
        [group.participant addObject:personData];
        if (group.participant.count > 0) {
            if(person)
            {
                ((PersonSimpleDataModel *)(group.participant[0])).note = person.note;
                ((PersonSimpleDataModel *)(group.participant[0])).manager = person.manager;
                ((PersonSimpleDataModel *)(group.participant[0])).remind = person.remind;
                ((PersonSimpleDataModel *)(group.participant[0])).hisNews = person.hisNews;
            }

        }
    }
    
    if (group) {
        self.group = group;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle:KDNavigationStyleNormal];
    
    
    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    
    [KDEventAnalysis event:event_contact_pubacc_open];
    
    if ([self.group.groupId length] > 0) {
        GroupDataModel *model = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:self.group.groupId];
        if (model.status) {
            self.group = model;
            
            //从会话列表进来的搜不到note
            PersonDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicPersonSimple:self.pubAcct.personId];
            if(person)
            {
                ((PersonSimpleDataModel *)(self.group.participant[0])).note = person.note;
                ((PersonSimpleDataModel *)(self.group.participant[0])).manager = person.manager;
                ((PersonSimpleDataModel *)(self.group.participant[0])).remind = person.remind;
                ((PersonSimpleDataModel *)(self.group.participant[0])).hisNews = person.hisNews;
            }
        }
    }
    
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = self.footerView;
    [self updateSubViews];
}

#pragma mark - getter & setter -

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = self.view.backgroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (KDPubAccHeaderView *)headerView {
    if (_headerView == nil) {
        if ([self.pubAcct.note length] > 0) {
            _headerView = [[KDPubAccHeaderView alloc] initWithFrame:CGRectMake(.0, .0, ScreenFullWidth, 200.f)];
        }else{
            _headerView = [[KDPubAccHeaderView alloc] initWithFrame:CGRectMake(.0, .0, ScreenFullWidth, 100.f)];
        }
//        _headerView.delegate = self;
    }
    return _headerView;
}

- (KDPubAccFooterView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[KDPubAccFooterView alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth, 60)];
        _footerView.delegate = self;
    }
    
    return _footerView;
}

- (MBProgressHUD *)hud {
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    return _hud;
}

- (UISwitch *)pushSwitchButton
{
    if (_pushSwitchButton == nil) {
        _pushSwitchButton = [UISwitch new];
        
        _pushSwitchButton.onTintColor = FC5;
        [_pushSwitchButton setOn:![self.group pushOpened] animated:YES];
        [_pushSwitchButton addTarget:self action:@selector(togglePush) forControlEvents:UIControlEventValueChanged];
    }
    return _pushSwitchButton;
}

-(UIButton *)button
{
    if (_button == nil) {
        _button = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDPubAccDetailViewController_Book")];
        _button.frame = CGRectMake(12, 32, 200, 40);
        [_button setCircle];
    }
    
    return _button;
}

- (KDTableViewCell *)alertMessageCell
{
    if(!_alertMessageCell)
    {
        _alertMessageCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"alertMessageCell"];
        _alertMessageCell.textLabel.text = ASLocalizedString(@"KDPubAccDetailViewController_Tip");
        _alertMessageCell.accessoryView = self.pushSwitchButton;
        _alertMessageCell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    }
    return _alertMessageCell;
}

- (KDTableViewCell *)viewHistoryCell
{
    if(!_viewHistoryCell)
    {
        _viewHistoryCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"viewHistoryCell"];
        _viewHistoryCell.textLabel.text = ASLocalizedString(@"KDPubAccDetailViewController_View_History");
        _viewHistoryCell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    }
    return _viewHistoryCell;
}

#pragma mark - private -

- (void)updateSubViews {
    NSURL *imageURL = nil;
    if ([self.pubAcct hasHeaderPicture]) {
        NSString *url = self.pubAcct.photoUrl;
        if ([url rangeOfString:@"?"].location != NSNotFound) {
            url = [url stringByAppendingFormat:@"&spec=180"];
        }
        else {
            url = [url stringByAppendingFormat:@"?spec=180"];
        }
        imageURL = [NSURL URLWithString:url];
    }
    [self.headerView.photoView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"user_default_portrait"] scale:SDWebImageScaleThumbnail];
    
    self.headerView.nameLabel.text = self.pubAcct.personName;
    self.headerView.distributionLabel.hidden = (self.pubAcct.note.length == 0);
    self.headerView.noteLabel.hidden = self.headerView.distributionLabel.hidden;
    
    if (!self.headerView.noteLabel.hidden) {
        self.headerView.noteLabel.text = ([self.pubAcct.note isEqualToString:@"(null)"]?ASLocalizedString(@"NO_DATA_PUBLICK"):self.pubAcct.note);
        CGRect textRect = [self.pubAcct.note boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.tableView.bounds) - 2 * [NSNumber kdDistance1], CGRectGetHeight(self.tableView.bounds) - 213.5) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[self.headerView.noteLabel font]} context:nil];
        self.headerView.frame = CGRectMake(.0, .0, CGRectGetWidth(self.tableView.bounds), textRect.size.height + 163.5);
    }
    else {
        self.headerView.frame = CGRectMake(.0, .0, CGRectGetWidth(self.tableView.bounds), 102.5);
    }
    
    if (self.isAttention) {
        [self.footerView.attentionButton changeToWhite];
        [self.footerView.attentionButton setTitle:ASLocalizedString(@"KDPubAccDetailViewController_Cancel")forState:UIControlStateNormal];
        self.footerView.attentionButton.layer.borderColor = [UIColor kdDividingLineColor].CGColor;
        
        [self.footerView.attentionButton setTitleColor:FC4 forState:UIControlStateNormal];
        [self.footerView.attentionButton setTitleColor:[UIColor colorWithRGB:0xDA5050] forState:UIControlStateHighlighted];
    }
    else {
        [self.footerView.attentionButton changeToBlue];
        [self.footerView.attentionButton setTitle:ASLocalizedString(@"KDPubAccDetailViewController_Book")forState:UIControlStateNormal];
    }
//    self.headerView.attentionButton.hidden = !([self.pubAcct.canUnsubscribe isEqualToString:@"1"] ? YES : NO);
    self.footerView.attentionButton.hidden = (!self.canSubscribe && self.attention);
    
    self.footerView.adminTipsView.hidden = !self.pubAcct.manager;
    if(self.pubAcct.manager)
    {
        NSString *tips = [NSString stringWithFormat:ASLocalizedString(@"KDApplicationViewController_tips"),self.pubAcct.personName,self.pubAcct.personName,self.pubAcct.personName];
        [self.footerView setTipsLabelText:tips];
    }
    
    
    //重新布局
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = self.footerView;
    
    
    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [backBtn sizeToFit];
    [backBtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItems = @[barButtonItem];
}

-(void)goBack:(UIButton *)btn
{
    if(self.attention)
        [self.navigationController popViewControllerAnimated:YES];
    else
    {
        NSInteger count = self.navigationController.viewControllers.count;
        if(count>3 && [self.navigationController.viewControllers[count-2] isKindOfClass:[XTChatViewController class]])
        {
//            [self.navigationController popToViewController:self.navigationController.viewControllers[count-3] animated:YES completion:nil];
            [self.navigationController popToViewController:self.navigationController.viewControllers[count-3] animated:YES];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - attention -

- (void)attention {
    if (self.pubAcct.personId.length == 0) {
        return;
    }
    
    if (self.isAttention) {
        [KDEventAnalysis event:event_pubacc_favorite_off];
        [self.attentionClient attention:self.pubAcct.personId withdata:@"0"];
    }
    else {
        [KDEventAnalysis event:event_pubacc_favorite_on];
        [self.attentionClient attention:self.pubAcct.personId withdata:@"1"];
    }
    [self.hud setLabelText:ASLocalizedString(@"XTPersonalFilesController_Wait")];
    [self.hud show:YES];
}

- (AppsClient *)attentionClient {
    if (_attentionClient == nil) {
        _attentionClient = [[AppsClient alloc] initWithTarget:self action:@selector(attentionDidReceived:result:)];
    }
    return _attentionClient;
}

-(ContactClient *)togglePushClient
{
    if (_togglePushClient == nil) {
        _togglePushClient = [[ContactClient alloc] initWithTarget:self action:@selector(togglePushDidReceived:result:)];
    }
    
    return _togglePushClient;
}

- (void)togglePushDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        [self.group togglePush];
        
        [self.pushSwitchButton removeTarget:self action:@selector(togglePush) forControlEvents:UIControlEventValueChanged];
        [self.pushSwitchButton setOn:!self.pushSwitchButton.on animated:YES];
        [self.pushSwitchButton addTarget:self action:@selector(togglePush) forControlEvents:UIControlEventValueChanged];
        
        [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    
    [self.hud hide:YES];
    [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithStatus:self.group.status withGroupId:self.group.groupId];
}

- (void)attentionDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result {
    if (client.hasError || !result.success) {
        [self.hud setLabelText:(result.error.length>0?result.error:ASLocalizedString(@"KDPubAccDetailViewController_Fail"))];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    else if (result.success) {
        if (self.isAttention) {
            self.pubAcct.subscribe = @"0";
            if ([[XTDataBaseDao sharedDatabaseDaoInstance] updatePublicPersonSimpleSetsubscribe:self.pubAcct]) {
                self.attention = NO;
                
                NSString *groupId = [[XTDataBaseDao sharedDatabaseDaoInstance] queryGroupIdWithPublicPersonId:self.pubAcct.personId];
                [self deleteGroupwithgroupId:groupId];
                [self.hud setLabelText:ASLocalizedString(@"KDPubAccDetailViewController_Book_Cancel_Success")];
            }
            else {
                [self.hud setLabelText:ASLocalizedString(@"KDPubAccDetailViewController_Book_Cancel_Fail")];
            }
        }
        else {
            self.pubAcct.subscribe = @"1";
            if ([[XTDataBaseDao sharedDatabaseDaoInstance] updatePublicPersonSimpleSetsubscribe:self.pubAcct]) {
                self.attention = YES;
                [self.hud setLabelText:ASLocalizedString(@"KDPubAccDetailViewController_Book_Success")];
            }
            else {
                [self.hud setLabelText:ASLocalizedString(@"KDPubAccDetailViewController_Book_Fail")];
            }
        }
        
        [self updateSubViews];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadData" object:nil];
        
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        [self.tableView reloadData];
    }
}

- (void)deleteGroupwithgroupId:(NSString *)groupId {
    if ([[XTDataBaseDao sharedDatabaseDaoInstance] setPrivateGroupListToDeleteWithGroupId:groupId]) {
        [[XTDeleteService shareService] deleteGroupWithGroupId:groupId];
    }
}


#pragma mark -- action methods
-(void)togglePush
{
    [self.group togglePush];
    [self.togglePushClient togglePushWithGroupId:self.group.groupId status:!self.pushSwitchButton.on];
}

#pragma mark - KDPubAccHeaderViewDelegate -

- (void)pubAccHeaderViewAttentionButtonPressed:(KDPubAccHeaderView *)view {
    [self attention];
}

#pragma mark - KDPubAccFooterViewDelegate -
- (void)pubAccFooterViewAttentionButtonPressed:(KDPubAccFooterView *)view
{
    [self attention];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (self.isAttention && [self.group.groupId length] > 0 && self.pubAcct.remind) {
        self.remindRow = count;
        count ++;
    }
    
    //查看历史消息,文件传输助手没有该功能
    if(![self.group.groupId containsString:kFilePersonId] && (((PersonSimpleDataModel *)[self.group.participant firstObject]).hisNews || self.pubAcct.hisNews) && self.attention)
        count ++;
    return count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == self.remindRow)
        return self.alertMessageCell;
    else
        return self.viewHistoryCell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row != self.remindRow)
    {
        //查看历史消息
        XTPubAccHistoryViewController *vc = [[XTPubAccHistoryViewController alloc] init];
        vc.pubAcc = self.pubAcct;
        vc.group = self.group;
        vc.chatMode = ChatPrivateMode;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end

