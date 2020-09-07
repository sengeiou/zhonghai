//
//  XTGroupManagerViewController.m
//  kdweibo
//
//  Created by fang.jiaxin on 17/4/21.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "XTGroupManagerViewController.h"
#import "XTChatDetailViewController.h"
#import "KDChooseContentCollectionViewController.h"
#import "UITableView+TopWhiteBackground.h"
#import "KDMyQRViewController.h"

@interface XTGroupManagerViewController ()
<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,XTSelectPersonsViewDelegate>


@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UISwitch *groupQRSwitchButton; // 群组二维码
@property (nonatomic, strong) UISwitch *slienceSwitchButton;
@property (nonatomic, strong) UISwitch *abortAddPersonSwitchButton;


@property (nonatomic, strong) ContactClient *toggleQRCodeClient;
@property (nonatomic, strong) ContactClient *transferManagerClient;
@property (nonatomic, strong) ContactClient *slienceClient;
@property (nonatomic, strong) ContactClient *abortAddPersonClient;

@property (nonatomic, strong) UITableView *tableViewMain;


@property (nonatomic, strong) KDTableViewCell *groupQRCell; // 群组二维码
@property (nonatomic, strong) KDTableViewCell *transferManagerCell;
@property (nonatomic, strong) KDTableViewCell *slienceCell;
@property (nonatomic, strong) KDTableViewCell *abortAddPersonCell;


@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) PersonSimpleDataModel *managerPersonSimpleDataModel;
@end


@implementation XTGroupManagerViewController

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)setGroup:(GroupDataModel *)group
{
    _group = group;
    [self setUpDataSource];
}

- (MBProgressHUD *)hud
{
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    return _hud;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    self.title = ASLocalizedString(@"Manager_Group");
    
    [self.view addSubview:self.tableViewMain];
    
    [self.tableViewMain makeConstraints:^(MASConstraintMaker *make)
     {
         make.edges.equalTo(self.view).with.insets(UIEdgeInsetsZero);
     }];
}

- (void) setUpDataSource {
    [self.dataSource removeAllObjects];
    
    __weak __typeof(self) weakSelf = self;
    
    XTChatDetailModel *(^modelFactory)(KDTableViewCell *, id) = ^(KDTableViewCell *cell, id block) {
        XTChatDetailModel *chatDetailModel = [[XTChatDetailModel alloc] init];
        chatDetailModel.modelCell = cell;
        chatDetailModel.block = block;
        return chatDetailModel;
    };
    
    //转让管理员
    XTChatDetailModel *transferManagerModel = modelFactory(self.transferManagerCell,^{
        //add
        [KDEventAnalysis event: event_group_manage_transfer_admin];
        [KDEventAnalysis eventCountly: event_group_manage_transfer_admin];

        [weakSelf transferManager:nil];
    });
    
    //仅管理员添加成员
    XTChatDetailModel *abortAddPersonModel = modelFactory(self.abortAddPersonCell,nil);
    
    //群组二维码
    XTChatDetailModel *groupQRModel = modelFactory(self.groupQRCell,nil);
    
    //全员禁言
    XTChatDetailModel *slienceModel = modelFactory(self.slienceCell,nil);

    if([self.group abortAddPersonOpened])
        [self.dataSource addObject:@[transferManagerModel,abortAddPersonModel,slienceModel]];
    else
        [self.dataSource addObject:@[transferManagerModel,abortAddPersonModel,groupQRModel,slienceModel]];
        
    
    [self.tableViewMain reloadData];
}

#pragma mark - 转让管理员
- (void)transferManager:(id)sender
{
    KDChooseContentCollectionViewController *choosePersonViewController = [[KDChooseContentCollectionViewController alloc] initWithNibName:nil bundle:nil];
    XTSelectPersonsView *selectPersonsView = [[XTSelectPersonsView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.navigationController.view.frame) - 44.0f, self.view.frame.size.width, 44.0f)];
    selectPersonsView.delegate = self;
    selectPersonsView.isMult = NO;
    choosePersonViewController.bShowSelectAll = NO;
    choosePersonViewController.type = KDChooseContentTransferManager;
    choosePersonViewController.selectedPersonsView = selectPersonsView;
    choosePersonViewController.selectedPersonsView.delegate = self;
    
    //            NSMutableArray *mArrayParticipant = [NSMutableArray array];
    //            [self.group.participantIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
    //                PersonSimpleDataModel *person = [self.group participantForKey:obj];
    //                if (person)//未过滤已经注销人员
    //                {
    //                    [mArrayParticipant addObject:person];
    //                }
    //            }];
    //            choosePersonViewController.collectionDatas = mArrayParticipant;
    
    choosePersonViewController.collectionDatas = self.group.participant;
    choosePersonViewController.title = ASLocalizedString(@"XTChatDetailViewController_transferManager");
    [self.navigationController.view addSubview:selectPersonsView];
    [self.navigationController pushViewController:choosePersonViewController animated:YES];
}

#pragma mark - 群组二维码

- (UISwitch *)groupQRSwitchButton {
    if (!_groupQRSwitchButton) {
        _groupQRSwitchButton = [UISwitch new];
        _groupQRSwitchButton.onTintColor = FC5;
        [_groupQRSwitchButton setOn:[self.group qrCodeOpened] animated:YES];
        [_groupQRSwitchButton addTarget:self action:@selector(toggleGroupQR) forControlEvents:UIControlEventValueChanged];
    }
    return _groupQRSwitchButton;
}

- (void)toggleGroupQR {
    NSLog(@"群组二维码开启否----- %d", self.groupQRSwitchButton.on);
    //add
    [KDEventAnalysis event: event_group_manage_qrcode];
    [KDEventAnalysis eventCountly: event_group_manage_qrcode];
    
    [self.group toggleQRCode];
    
    if (self.toggleQRCodeClient == nil) {
        self.toggleQRCodeClient = [[ContactClient alloc]initWithTarget:self action:@selector(toggleQRCodeDidReceived:result:)];
    }
    
    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    [self.toggleQRCodeClient toggleQRCodeWithGroupId:self.group.groupId status:self.groupQRSwitchButton.on];
}

- (void)toggleQRCodeDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        [self.group toggleQRCode];
        
        [self.groupQRSwitchButton removeTarget:self action:@selector(toggleGroupQR) forControlEvents:UIControlEventValueChanged];
        [self.groupQRSwitchButton setOn:!self.groupQRSwitchButton.on animated:YES];
        [self.groupQRSwitchButton addTarget:self action:@selector(toggleGroupQR) forControlEvents:UIControlEventValueChanged];
        
        [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    
    [self.hud hide:YES];
    [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithStatus:self.group.status withGroupId:self.group.groupId];
}

#pragma mark - 全员禁言
- (UISwitch *)slienceSwitchButton {
    if (!_slienceSwitchButton) {
        _slienceSwitchButton = [UISwitch new];
        _slienceSwitchButton.onTintColor = FC5;
        [_slienceSwitchButton setOn:[self.group slienceOpened] animated:YES];
        [_slienceSwitchButton addTarget:self action:@selector(toggleSlience) forControlEvents:UIControlEventValueChanged];
    }
    return _slienceSwitchButton;
}

- (void)toggleSlience {
    NSLog(@"全员禁言开启否----- %d", self.slienceSwitchButton.on);
    
    //add
    [KDEventAnalysis event:event_dialog_group_manage_nospeak];
    [KDEventAnalysis eventCountly:event_dialog_group_manage_nospeak];
    [self.group toggleslience];
    
    if (self.slienceClient == nil) {
        self.slienceClient = [[ContactClient alloc]initWithTarget:self action:@selector(toggleSlienceDidReceived:result:)];
    }
    
    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    [self.slienceClient setGroupStatusWithGroupId:self.group.groupId key:@"banned" value:self.slienceSwitchButton.on ? 1 : 0];
}

- (void)toggleSlienceDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        [self.group toggleslience];
        
        [self.slienceSwitchButton removeTarget:self action:@selector(toggleSlience) forControlEvents:UIControlEventValueChanged];
        [self.slienceSwitchButton setOn:!self.slienceSwitchButton.on animated:YES];
        [self.slienceSwitchButton addTarget:self action:@selector(toggleSlience) forControlEvents:UIControlEventValueChanged];
        
        [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    
    [self.hud hide:YES];
    [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithStatus:self.group.status withGroupId:self.group.groupId];
}

#pragma mark - 仅管理员添加成员
- (UISwitch *)abortAddPersonSwitchButton {
    if (!_abortAddPersonSwitchButton) {
        _abortAddPersonSwitchButton = [UISwitch new];
        _abortAddPersonSwitchButton.onTintColor = FC5;
        [_abortAddPersonSwitchButton setOn:[self.group abortAddPersonOpened] animated:YES];
        [_abortAddPersonSwitchButton addTarget:self action:@selector(toggleAbortAddPerson) forControlEvents:UIControlEventValueChanged];
    }
    return _abortAddPersonSwitchButton;
}

- (void)toggleAbortAddPerson {
    NSLog(@"仅限管理员添加----- %d", self.abortAddPersonSwitchButton.on);
    //add
    [KDEventAnalysis event:event_group_manage_admin_add_member];
    [KDEventAnalysis eventCountly:event_group_manage_admin_add_member];
    [self.group toggleAbortAddPerson];
    
    //二维码显示开关
    [self setUpDataSource];
    if (self.abortAddPersonClient == nil) {
        self.abortAddPersonClient = [[ContactClient alloc]initWithTarget:self action:@selector(toggleAbortAddPersonDidReceived:result:)];
    }

    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    [self.abortAddPersonClient setGroupStatusWithGroupId:self.group.groupId key:@"addusermark" value:self.abortAddPersonSwitchButton.on ? 1 : 0];
}

- (void)toggleAbortAddPersonDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        [self.group toggleAbortAddPerson];
        
        [self.abortAddPersonSwitchButton removeTarget:self action:@selector(toggleAbortAddPerson) forControlEvents:UIControlEventValueChanged];
        [self.abortAddPersonSwitchButton setOn:!self.abortAddPersonSwitchButton.on animated:YES];
        [self.abortAddPersonSwitchButton addTarget:self action:@selector(toggleAbortAddPerson) forControlEvents:UIControlEventValueChanged];
        
        //恢复二维码开关原本状态
        [self setUpDataSource];
        
        [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    
    self.group.status = [[result.data objectForKey:@"status"] intValue];
    self.groupQRSwitchButton.on = [self.group qrCodeOpened];
    
    [self.hud hide:YES];
    [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithStatus:self.group.status withGroupId:self.group.groupId];
}

- (UITableView *)tableViewMain
{
    if (!_tableViewMain)
    {
        _tableViewMain = [UITableView new];
        _tableViewMain.dataSource = self;
        _tableViewMain.delegate = self;
        _tableViewMain.backgroundColor = [UIColor kdBackgroundColor1];
        _tableViewMain.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableViewMain.shouldShowTopWhiteBackground = YES;
    }
    return _tableViewMain;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [(XTChatDetailModel *)[(NSArray *)[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] modelCell];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XTChatDetailModel *model = (XTChatDetailModel *)[(NSArray *)[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (model.block)
    {
        void (^block)() = model.block;
        block();
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return [NSNumber kdDistance2];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [UIView new];
    sectionView.backgroundColor = [UIColor clearColor];
    return sectionView;
}

- (KDTableViewCell *)groupQRCell{
    if (!_groupQRCell) {
        _groupQRCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_groupQRCell"];
        _groupQRCell.textLabel.text = ASLocalizedString(@"XTChatDetailViewController_group_QR");
        _groupQRCell.accessoryView = self.groupQRSwitchButton;
        _groupQRCell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    }
    return _groupQRCell;
}

- (KDTableViewCell *)transferManagerCell {
    if (!_transferManagerCell) {
        _transferManagerCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_transferManagerCell"];
        _transferManagerCell.textLabel.text = ASLocalizedString(@"XTChatDetailViewController_transferManager");
        _transferManagerCell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        _transferManagerCell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
    }
    return _transferManagerCell;
}

- (KDTableViewCell *)slienceCell{
    if (!_slienceCell) {
        _slienceCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_slienceCell"];
        _slienceCell.textLabel.text = ASLocalizedString(@"全员禁言");
        _slienceCell.accessoryView = self.slienceSwitchButton;
        _slienceCell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    }
    return _slienceCell;
}

- (KDTableViewCell *)abortAddPersonCell{
    if (!_abortAddPersonCell) {
        _abortAddPersonCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_abortAddPersonCell"];
        _abortAddPersonCell.textLabel.text = ASLocalizedString(@"仅管理员添加成员");
        _abortAddPersonCell.accessoryView = self.abortAddPersonSwitchButton;
        _abortAddPersonCell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    }
    return _abortAddPersonCell;
}

#pragma mark - XTSelectPersonsViewDelegate
- (void)selectPersonViewDidConfirm:(NSMutableArray *)persons
{
    self.managerPersonSimpleDataModel = [persons objectAtIndex:0];
    if (self.transferManagerClient == nil) {
        self.transferManagerClient = [[ContactClient alloc] initWithTarget:self action:@selector(transferManagerDidReceived:result:)];
    }
    [self.hud show:YES];
    [self.transferManagerClient transferManagerWithGroupId:self.group.groupId managerId:self.managerPersonSimpleDataModel.personId];
    [self. navigationController popViewControllerAnimated:YES];
}

-(void)transferManagerDidReceived:(ContactClient *)client result:(BOSResultDataModel*)result
{
    if (client.hasError || !result.success) {
        if (result.error) {
            [self.hud setDetailsLabelText:result.error];
        } else {
            [self.hud setDetailsLabelText:ASLocalizedString(@"XTChatDetailViewController_transferManager_fail")];
        }
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    // 不能转让给未激活人员，后台已做处理
    //    if (![self.managerPersonSimpleDataModel accountAvailable]) {
    //        [self.hud setLabelText:ASLocalizedString(@"该人已注销，请更换转让对象")];
    //        [self.hud hide:YES afterDelay:1.0];
    //        return;
    //    }
    
    [self.hud setDetailsLabelText:ASLocalizedString(@"XTChatDetailViewController_transferManager_success")];
    [self.hud setMode:MBProgressHUDModeText];
    [self.hud hide:YES afterDelay:1.0];
    
    // 更新管理员
    if (result.data && [result.data isKindOfClass:[NSDictionary class]]) {
        id obj = result.data[@"managerIds"];
        if(!KD_IS_NULL_JSON_OBJ(obj))
        {
            self.group.managerIds = obj;
        }
    }
    
    [self performSelector:@selector(popToDetailVC) withObject:nil afterDelay:1.0];
}

-(void)popToDetailVC
{
    //不是管理员了不能处于这个界面
    [self.navigationController popViewControllerAnimated:YES];
}

@end
