//
//  XTChatDetailViewController.m
//  XT
//
//  Created by Gil on 13-7-9.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTChatDetailViewController.h"
#import "GroupDataModel.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+XT.h"
#import "UIImage+XT.h"
#import "ContactClient.h"
#import "MBProgressHUD.h"
#import "XTCell.h"
#import "MBSwitch.h"
#import "BOSConfig.h"
#import "KDFileInMessageViewController.h"
#import "KDChooseContentCollectionViewController.h"
#import "XTContactContentViewController.h"
#import "KDChatMemberViewController.h"
// cell
#import "KDChatDetailHeaderCell.h"
#import "KDChatDetailSearchcell.h"
#import "KDChatDetailMemberCell.h"

#import "UITableView+TopWhiteBackground.h"
#import "KDMyQRViewController.h"
#import "KDAgoraSDKManager.h"
#import "XTGroupManagerViewController.h"

#define DELETE_MEMBER_ALERT_TAG 2001



@implementation XTChatDetailModel

@end

@interface XTChatDetailViewController ()
<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, XTSelectPersonsViewDelegate>

@property (nonatomic, strong) UISwitch *pushSwitchButton; // 消息提醒
@property (nonatomic, strong) UISwitch *favSwitchButton; // 设为重要群组

@property (nonatomic, strong) MBProgressHUD *hud;
// networks
@property (nonatomic, strong) ContactClient *deleteAllMsgClient;
@property (nonatomic, strong) ContactClient *quitClient;
@property (nonatomic, strong) ContactClient *togglePushClient;
@property (nonatomic, strong) ContactClient *toggleFavClient;
@property (nonatomic, strong) ContactClient *createChatClient;
@property (nonatomic, strong) ContactClient *addPersonClient;
@property (nonatomic, strong) ContactClient *deletePersonClient;
@property (nonatomic, strong) ContactClient *dissolveClient;

@property (nonatomic, strong) UITableView *tableViewMain;

@property (nonatomic, assign) BOOL bIsGroupMany;
@property (nonatomic, assign) BOOL bIsGroupDouble;
// cells
@property (nonatomic, strong) KDChatDetailHeaderCell *headerCell;
@property (nonatomic, strong) KDChatDetailSearchCell *searchCell;

@property (nonatomic, strong) KDTableViewCell *memberNumberCell;
@property (nonatomic, strong) KDChatDetailMemberCell *memberCell;

@property (nonatomic, strong) KDTableViewCell *noticeCell;  //群公告
@property (nonatomic, strong) KDTableViewCell *groupManagerCell;  //群管理
@property (nonatomic, strong) KDTableViewCell *alertMessageCell;
@property (nonatomic, strong) KDTableViewCell *saveToFavCell;  // 设为重要群组
@property (nonatomic, strong) KDTableViewCell *clearAllMessageCell;
@property (nonatomic, strong) KDTableViewCell *abortAddPersonModeCell;
@property (nonatomic, strong) KDTableViewCell *quitCurrentGroupCell;//退出群组
@property (nonatomic, strong) KDTableViewCell *dissolveGroupCell;//解散群组

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) KDChooseContentType *chooseContentType;
@property (nonatomic, strong) PersonSimpleDataModel *managerPersonSimpleDataModel;

@end

@implementation XTChatDetailViewController

- (BOOL)bIsGroupMany
{
    return self.group.groupType == GroupTypeMany;
}

- (BOOL)bIsGroupDouble
{
    return self.group.groupType == GroupTypeDouble;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (id)initWithGroup:(GroupDataModel *)group
{
    self = [super init];
    if (self) {
        self.title = ASLocalizedString(@"XTChatDetailViewController_Chat_Info");
        self.group = group;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpQrCode];//二维码
    self.memberCell.group = self.group;
    [self setUpDataSource];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    [self setUpQrCode];//二维码
    [self.view addSubview:self.tableViewMain];
    
    [self.tableViewMain makeConstraints:^(MASConstraintMaker *make)
     {
         make.edges.equalTo(self.view).with.insets(UIEdgeInsetsZero);
     }];
}

- (void) setUpDataSource {
    [self.dataSource removeAllObjects];
    
    XTChatDetailModel *(^modelFactory)(KDTableViewCell *, id) = ^(KDTableViewCell *cell, id block) {
        XTChatDetailModel *chatDetailModel = [[XTChatDetailModel alloc] init];
        chatDetailModel.modelCell = cell;
        chatDetailModel.block = block;
        return chatDetailModel;
    };
    
    __weak __typeof(self) weakSelf = self;
    
    XTChatDetailModel *headerImageModel = modelFactory(self.headerCell, nil);
    XTChatDetailModel *searchModel = modelFactory(self.searchCell, nil);
    
    XTChatDetailModel *memberCountModel = modelFactory(self.memberNumberCell, ^{
        KDChatMemberViewController *chatMemberController = [[KDChatMemberViewController alloc] init];
        chatMemberController.chooseContentDelegate = self;
        chatMemberController.group = weakSelf.group;
        chatMemberController.type = KDChatMemberViewControllerTypeNormal;
        [weakSelf.navigationController pushViewController:chatMemberController animated:YES];
    });
    XTChatDetailModel *memberModel = modelFactory(self.memberCell, nil);
    
    
    //群管理
    XTChatDetailModel *groupManagerModel = modelFactory(self.groupManagerCell, ^{
        //add
        [KDEventAnalysis event: event_group_manage_count];
        [KDEventAnalysis eventCountly: event_group_manage_count];
        [weakSelf gotoGroupManger];
    });
    
    //群公告
    XTChatDetailModel *noticeModel = modelFactory(self.noticeCell, ^{
        [weakSelf performSelector:@selector(noticeBtnPressed) withObject:nil];
    });
    
    //消息提醒
    XTChatDetailModel *alertMessageModel = modelFactory(self.alertMessageCell,nil);
    
    //保存到通讯录(设为重要群组)
    XTChatDetailModel *saveToFavModel = modelFactory(self.saveToFavCell,nil);
    
    //仅管理员添加成员模式
    XTChatDetailModel *abortAddPersonModeModel = modelFactory(self.abortAddPersonModeCell,nil);
    
    //清空聊天记录
    XTChatDetailModel *clearAllMessageModel = modelFactory(self.clearAllMessageCell,^{
        //add
        [KDEventAnalysis event: event_dialog_group_clear_history];
        [KDEventAnalysis eventCountly: event_dialog_group_clear_history];
        [weakSelf performSelector:@selector(deleteAllMsgBtnPressed:) withObject:nil];
    });
    
    // 退出群组
    XTChatDetailModel *quitCurrentGroupModel = modelFactory(self.quitCurrentGroupCell, ^{
        //add
        [KDEventAnalysis event: event_dialog_group_quit];
         [KDEventAnalysis eventCountly: event_dialog_group_quit];
        [weakSelf quitBtnPressed:nil];
    });
    
    //解散群组
    XTChatDetailModel *dissolveGroupModel = modelFactory(self.dissolveGroupCell, ^{
        //add
        [KDEventAnalysis event: event_dialog_group_disband];
        [KDEventAnalysis eventCountly: event_dialog_group_disband];
        [weakSelf performSelector:@selector(dissolveBtnPressed) withObject:nil];
    });
    
    [self.dataSource addObject:@[headerImageModel, searchModel]];
    [self.dataSource addObject:@[memberCountModel, memberModel]];
    if (self.bIsGroupMany)
    {
        if ([self.group isManager])
            [self.dataSource addObject:@[groupManagerModel]];
        [self.dataSource addObject:@[noticeModel, alertMessageModel, saveToFavModel]];
        if([self.group abortAddPersonOpened])
            [self.dataSource addObject:@[abortAddPersonModeModel]];
        [self.dataSource addObject:@[clearAllMessageModel]];
        [self.dataSource addObject:@[quitCurrentGroupModel]];
        if ([self.group isManager]) {
            [self.dataSource addObject:@[dissolveGroupModel]];
        }
    }
    else
    {
        [self.dataSource addObject:@[alertMessageModel]];
        [self.dataSource addObject:@[clearAllMessageModel]];
    }
    [self.tableViewMain reloadData];
}

-(void)gotoGroupManger
{
    XTGroupManagerViewController *managerVC = [[XTGroupManagerViewController alloc] init];
    managerVC.group = self.group;
    [self.navigationController pushViewController:managerVC animated:YES];
}

-(void)setUpQrCode
{
    //群组二维码
    if([self.group qrCodeOpened] && self.group.groupType != GroupTypeDouble && ![self.group abortAddPersonOpened])
    {
        UIButton *qrBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [qrBtn setImage:[UIImage imageNamed:@"qrcode"] forState:UIControlStateNormal];
        [qrBtn addTarget:self action:@selector(jumpGroupQR:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:qrBtn]];
    }
    else
        [self.navigationItem setRightBarButtonItem:nil];
}

- (void)jumpGroupQR:(UIButton *)sender {
    //add
    [KDEventAnalysis event: event_dialog_group_qrcode];
    [KDEventAnalysis eventCountly: event_dialog_group_qrcode];
    KDMyQRViewController *vc = [[KDMyQRViewController alloc] initWithNibName:@"KDMyQRViewController" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    vc.group = self.group;
    vc.title = ASLocalizedString(@"XTChatDetailViewController_group_QR");
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setGroup:(GroupDataModel *)group
{
    _group = group;
    
    [self setUpDataSource];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.memberCell.group = group;
    });
}


#pragma mark - 修改群组名称
- (void)changeGroupName:(id)sender
{
    if (self.bIsGroupDouble) {
        return;
    }
    //add
    [KDEventAnalysis event: event_dialog_group_name_modify];
    [KDEventAnalysis eventCountly: event_dialog_group_name_modify];
    XTModifyGroupNameViewController *modifyViewController = [[XTModifyGroupNameViewController alloc] initWithGroup:self.group];
    modifyViewController.delegate = self;
    modifyViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:modifyViewController animated:YES];
}


#pragma mark - XTModifyGroupNameViewControllerDelegate

- (void)modifyGroupNameDidFinish:(XTModifyGroupNameViewController *)controller groupName:(NSString *)groupName
{
    [KDEventAnalysis event:event_session_settings_namemodify_ok];
    self.group.groupName = groupName;
    [self.headerCell setNameLabelValue:groupName];
}

#pragma mark - click加号
- (void)groupParticipantsViewAddPerson {
    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentAdd];
    contentViewController.delegate = self;
    contentViewController.isFromConversation = YES;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [self presentViewController:contentNav animated:YES completion:nil];
}

#pragma mark - click减号
- (void)groupParticipantsViewDeletePerson {
    KDChooseContentCollectionViewController *choosePersonViewController = [[KDChooseContentCollectionViewController alloc] initWithNibName:nil bundle:nil];
    XTSelectPersonsView *selectPersonsView = [[XTSelectPersonsView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.navigationController.view.frame) - 44.0f, self.view.frame.size.width, 44.0f)];
    selectPersonsView.delegate = self;
    selectPersonsView.isMult = YES;
    choosePersonViewController.bShowSelectAll = YES;
    choosePersonViewController.type = KDChooseContentDelete;
    self.chooseContentType = KDChooseContentDelete;
    choosePersonViewController.selectedPersonsView = selectPersonsView;
    choosePersonViewController.selectedPersonsView.delegate = self;
    
//        NSMutableArray *mArrayParticipant = [NSMutableArray array];
//        [self.group.participantIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
//            PersonSimpleDataModel *person = [self.group participantForKey:obj];
//            if (person)//未过滤已经注销人员
//            {
//                [mArrayParticipant addObject:person];
//            }
//        }];
//        choosePersonViewController.collectionDatas = mArrayParticipant;
    //706 兼容加人后第一次进来为空
    if ( self.group.participant.count == 0) {
        [self.group.participantIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            self.group.participant = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance]queryPersonWithPersonIds:self.group.participantIds]];
        }];
    }
    choosePersonViewController.collectionDatas = self.group.participant;
    choosePersonViewController.title = ASLocalizedString(@"XTChatDetailViewController_delete_person");
    [self.navigationController.view addSubview:selectPersonsView];
    [self.navigationController pushViewController:choosePersonViewController animated:YES];
}

- (void)deletePerson:(NSArray *)personId
{
    if (self.deletePersonClient == nil) {
        self.deletePersonClient = [[ContactClient alloc] initWithTarget:self action:@selector(deletePersonDidReceived:result:)];
    }
    
    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    [self.deletePersonClient delGroupUserWithGroupId:self.group.groupId userId:personId];
}

- (void)deletePersonDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        [self.hud setLabelText:ASLocalizedString(@"XTChatDetailViewController_Delete_Fail")];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    
    [self.hud setLabelText:ASLocalizedString(@"XTChatDetailViewController_Delete_Success")];
    [self.hud setMode:MBProgressHUDModeText];
    [self.hud hide:YES afterDelay:1.0];
    
    [self.group.participant removeObjectsInArray:self.selectedPersons];
    [self.group.participantIds removeObjectsInArray:[self.selectedPersons valueForKeyPath:@"personId"]];
     
     __weak __typeof(self) weakSelf = self;
    NSMutableArray *personIdArray = [NSMutableArray array];
     [self.selectedPersons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
         //生成人员id列表
         [personIdArray addObject:person.personId];
     }];
    
    //把删除人员移除组参与人
    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteParticpantWithPersonIdArray:personIdArray groupId:weakSelf.group.groupId];
    
    if (result.data && [result.data isKindOfClass:[NSDictionary class]]) {
        //修改 返回“<nsnull>”
        id obj = result.data[@"groupName"];
        if(!KD_IS_NULL_JSON_OBJ(obj))
        {
            NSString *groupName = (NSString *) obj;
            if (groupName.length > 0) {
                self.group.groupName = groupName;
            }
        }
    }
    
    self.memberCell.group = self.group;
    [self.memberNumberCell setNeedsLayout];
}

#pragma mark - XTChooseContentViewControllerDelegate

- (void)chooseContentView:(XTChooseContentViewController *)controller persons:(NSArray *)persons
{
    [KDEventAnalysis event:event_session_settings_adduser];
    
    NSMutableArray *selectedPersons = [NSMutableArray array];
    NSMutableArray *personIds = [NSMutableArray array];
    [persons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
        if (![self.group.participant containsObject:person]
            && ![person.personId isEqualToString:[BOSConfig sharedConfig].user.userId]) {
            [selectedPersons addObject:person];
            [personIds addObject:person.personId];
        }
    }];
    
    if ([personIds count] == 0) {
        return;
    }
    self.selectedPersons = selectedPersons;
    
    if (self.group.groupType == GroupTypeDouble) {
        if ([self.group.participant count] > 0) {
            PersonSimpleDataModel *person = [self.group.participant objectAtIndex:0];
            [personIds addObject:person.personId];
        }
        [self createChatWithPersonIds:personIds];
    } else {
        [self addPersons:personIds];
    }
}

- (void)addPersons:(NSArray *)personIds
{
    if (self.addPersonClient == nil) {
        self.addPersonClient = [[ContactClient alloc] initWithTarget:self action:@selector(addPersonDidReceived:result:)];
    }
    
    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    [self.addPersonClient addGroupUserWithGroupId:self.group.groupId userIds:personIds];
}

- (void)addPersonDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        if(result.error.length > 0)
        {
           [self.hud setLabelText:result.error];
        }
        else
        {
            [self.hud setLabelText:ASLocalizedString(@"XTChatDetailViewController_Add_Fail")];
        }
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    
    [self.hud hide:YES];
    
//    [self.group.participant addObjectsFromArray:self.selectedPersons];
    [self.memberNumberCell setNeedsLayout];
    self.chatViewController.group = self.group;
    
    if (result.data && [result.data isKindOfClass:[NSDictionary class]]) {
        //修改 返回“<nsnull>”
        id obj = result.data[@"groupName"];
        if(!KD_IS_NULL_JSON_OBJ(obj))
        {
            NSString *groupName = (NSString *) obj;
            if (groupName.length > 0) {
                self.group.groupName = groupName;
            }
            
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createChatWithPersonIds:(NSArray *)personIds
{
    if (self.createChatClient == nil) {
        self.createChatClient = [[ContactClient alloc] initWithTarget:self action:@selector(createChatDidReceived:result:)];
    }
    
    self.hud.labelText = ASLocalizedString(@"XTChatDetailViewController_Creat");
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.hud show:YES];
    
    [self.createChatClient creatGroupWithUserIds:personIds groupName:nil];
}

- (void)createChatDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        if(result.error.length > 0)
            [self.hud setLabelText:result.error];
        else
            [self.hud setLabelText:ASLocalizedString(@"XTChatDetailViewController_Creat_Fail")];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    
    [self.hud hide:YES];
    
    GroupDataModel *groupDM = [[GroupDataModel alloc] initWithDictionary:result.data];
    groupDM.isNewGroup = YES;
    [[KDWeiboAppDelegate getAppDelegate].XT timelineToChatWithGroup:groupDM withMsgId:nil];
}

#pragma mark - getter

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

- (UISwitch *)favSwitchButton
{
    if (_favSwitchButton == nil) {
        _favSwitchButton = [UISwitch new];
        _favSwitchButton.onTintColor = FC5;
        [_favSwitchButton setOn:[self.group isFavorite] animated:YES];
        [_favSwitchButton addTarget:self action:@selector(toggleFavorite) forControlEvents:UIControlEventValueChanged];
    }
    return _favSwitchButton;
}



- (MBProgressHUD *)hud
{
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    return _hud;
}

#define DELETE_BUTTON_TAG 999
- (void)deleteAllMsgBtnPressed:(UIButton *)btn
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:ASLocalizedString(@"XTChatDetailViewController_Delete")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"Global_Sure"), nil];
    alert.tag = DELETE_BUTTON_TAG;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == DELETE_BUTTON_TAG) {
        if (buttonIndex == 1) {
            [self deleteAllMsg];
            self.chatViewController.isSendingFile = YES;
        }
    }
    else if (alertView.tag == DELETE_MEMBER_ALERT_TAG)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            NSArray *personIds = [[NSArray alloc] init];
            NSMutableArray *persons = [NSMutableArray array];
            [self.selectedPersons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
                        if ([self.group.participant containsObject:person]) {
                            [persons addObject:person.personId];
                        }
                    }];
            personIds = [persons copy];
            
            [self deletePerson:personIds];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)deleteAllMsg
{
    [KDEventAnalysis event:event_session_settings_clear];
    if (self.deleteAllMsgClient == nil) {
        self.deleteAllMsgClient = [[ContactClient alloc] initWithTarget:self action:@selector(delHistoryDidReceived:result:)];
    }
    
    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    [self.deleteAllMsgClient delHistoryRecordWithGoupID:self.group.groupId];
}

- (void)delHistoryDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    
    [self.hud setLabelText:ASLocalizedString(@"XTChatDetailViewController_Success")];
    [self.hud setMode:MBProgressHUDModeText];
    [self.hud hide:YES afterDelay:1.0];
    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecordsWithGroupId:self.group.groupId];
}

- (void)quitBtnPressed:(UIButton *)btn
{
    [KDEventAnalysis event:event_session_settings_quit];
    if (self.quitClient == nil) {
        self.quitClient = [[ContactClient alloc] initWithTarget:self action:@selector(quitDidReceived:result:)];
    }
    
    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    [self.quitClient delGroupUserWithGroupId:self.group.groupId userId:@[[BOSConfig sharedConfig].user.userId]];
}

- (void)quitDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    
    [self.hud setLabelText:ASLocalizedString(@"XTChatDetailViewController_Success")];
    [self.hud setMode:MBProgressHUDModeText];
    [self.hud hide:YES afterDelay:1.0];
    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteGroupAndRecordsWithGroupId:self.group.groupId publicId:nil realDel:YES];
    // 为了与解散群组区分开来 bug 9019
    self.chatViewController.group.status = 0;
    [self performSelector:@selector(quitFinish) withObject:nil afterDelay:1.0];
}

- (void)quitFinish
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)togglePush
{
//    NSDictionary *attr = @{label_session_settings_alert: self.pushSwitchButton.on ? label_session_settings_alert_on : label_session_settings_alert_off};
//    [KDEventAnalysis event:event_session_settings_alert attributes:attr];
    //add
    [KDEventAnalysis event: event_dialog_group_message_free];
    [KDEventAnalysis eventCountly: event_dialog_group_message_free];
    if (!self.group.groupId || self.group.groupId.length == 0) {
        [KDPopup showHUDToast:@"本设置暂不生效。请与TA发过一条消息后重试"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pushSwitchButton setOn:!self.pushSwitchButton.on animated:YES];
        });
        return;
    }
//    [KDPopup showHUD:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    
    
//    [self.group togglePush];
    
    if (self.togglePushClient == nil) {
        self.togglePushClient = [[ContactClient alloc]initWithTarget:self action:@selector(togglePushDidReceived:result:)];
    }
    
    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    [self.togglePushClient togglePushWithGroupId:self.group.groupId status:!self.pushSwitchButton.on];
}

- (void)togglePushDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success) {
        [self.group togglePush];
        NSString *desc = [self.group pushOpened] ?ASLocalizedString(@"XTChatDetailViewController_close") : ASLocalizedString(@"XTChatDetailViewController_open");
//        [KDPopup showHUDSuccess:desc];
        [self.hud setLabelText:desc];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithStatus:self.group.status withGroupId:self.group.groupId];
    } else {
        [self.pushSwitchButton setOn:!self.pushSwitchButton.on animated:YES];
        [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
//       [KDPopup showHUDToast:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
    }
}



-(void)toggleFavorite
{
//    NSDictionary *attr = @{label_session_settings_favorite: self.pushSwitchButton.on ? label_session_settings_favorite_on : label_session_settings_favorite_off};
//    [KDEventAnalysis event:event_session_settings_favorite attributes:attr];
//    
    //add
    [KDEventAnalysis event:event_dialog_group_set_important];
    [KDEventAnalysis eventCountly:event_dialog_group_set_important];
    [self.group toggleFavorite];
    
    if (self.toggleFavClient == nil) {
        self.toggleFavClient = [[ContactClient alloc]initWithTarget:self action:@selector(toggleFavoriteDidReceived:result:)];
    }
    
    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    
    [self.toggleFavClient toggleFavoriteWithGroupId:self.group.groupId status:self.favSwitchButton.on];
}

- (void)toggleFavoriteDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        [self.group toggleFavorite];
        
        [self.favSwitchButton removeTarget:self action:@selector(toggleFavorite) forControlEvents:UIControlEventValueChanged];
        [self.favSwitchButton setOn:!self.pushSwitchButton.on animated:YES];
        [self.favSwitchButton addTarget:self action:@selector(toggleFavorite) forControlEvents:UIControlEventValueChanged];
        
        [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    
    [self.hud hide:YES];
    [[XTDataBaseDao sharedDatabaseDaoInstance] updatePrivateGroupListWithStatus:self.group.status withGroupId:self.group.groupId];
}


#pragma mark - 解散群组
- (void)dissolveBtnPressed {
    [KDPopup showAlertWithTitle:nil message:ASLocalizedString(@"XTChatDetailViewController_dissolve_group_tip") buttonTitles:@[ASLocalizedString(@"Global_Cancel"),ASLocalizedString(@"XTChatDetailViewController_dissolve_group")] onTap:^(NSInteger index) {
        if (index == 1) {
            [self dissolveGroup];
        }
    }];
}

- (void)dissolveGroup {
    if (self.dissolveClient == nil) {
        self.dissolveClient = [[ContactClient alloc] initWithTarget:self action:@selector(dissolveDidReceived:result:)];
    }
    [KDPopup showHUD: ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    if ([self.group isManager]) {
        [self.dissolveClient dissolveGroupWithGroupId:self.group.groupId];
    }
}

- (void)dissolveDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result {
    if (client.hasError || !result.success) {
        NSString *error = [self errorWithClient:client result:result];
        if (!error) {
            error = ASLocalizedString(@"KDChooseOrganizationViewController_Error");
        }
        [KDPopup showHUDToast:error];
        return;
    }
    [KDPopup showHUDSuccess:ASLocalizedString(@"XTChatDetailViewController_Success")];
    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteGroupAndRecordsWithGroupId:self.group.groupId publicId:nil realDel:YES];
    [self performSelector:@selector(dissolveFinish) withObject:nil afterDelay:1.0];
}

- (void)dissolveFinish {
    if ([[KDApplicationQueryAppsHelper shareHelper] getGroupTalkStatus]) {
        if (self.group.mCallStatus != 0) {
            KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
            if ([self.group.mCallCreator isEqualToString:[BOSConfig sharedConfig].user.userId]) {
                // 发起人
                [agoraSDKManager sendQuitChannelMessageWithChannelId:agoraSDKManager.currentGroupDataModel ?[agoraSDKManager.currentGroupDataModel getChannelId]:nil];
            } else {
                // 参会人
                [agoraSDKManager leaveChannel];
                [agoraSDKManager agoraLogout];
            }
        }
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 群组公告
- (void)noticeBtnPressed {
//    [KDEventAnalysis event:session_settings_groupnotice];
    [self.chatViewController.noticeController toListVC];
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
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 158;
    }
    if (indexPath.section == 1 && indexPath.row == 1) {
        return 56;
    }
    return 44.0f;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return section==0?0.2:[NSNumber kdDistance2];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.bIsGroupMany) {
        if (section == self.dataSource.count - 1)
        {
            return [NSNumber kdDistance2];
        }
    }
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [UIView new];
    sectionView.backgroundColor = [UIColor clearColor];
    return sectionView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *sectionView = [UIView new];
    sectionView.backgroundColor = [UIColor clearColor];
    return sectionView;
}

#pragma mark - cell 配置

- (KDChatDetailHeaderCell *)headerCell {
    if (!_headerCell) {
        _headerCell = [[KDChatDetailHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_headerCell"];
        
        _headerCell.extImageView.hidden = !self.group.partnerType;
        
        [_headerCell setNameLabelValue:self.group.groupName];
        
        _headerCell.editGroupNameBtn.hidden = self.bIsGroupDouble;
        
        __weak __typeof(self) weakSelf = self;
        _headerCell.block = ^(){
            [weakSelf changeGroupName:nil];
        };
        if (self.group.groupType == GroupTypeDouble) {
            PersonSimpleDataModel *person = nil;
            if ([self.group.participant count] > 0) {
                person = [self.group.participant firstObject];
            }
            else {
                person = [self.group firstParticipant];
            }
            
            NSString *strPhotoUrl = person.photoUrl;
            if (strPhotoUrl == nil) {
                strPhotoUrl = @"";
            } else {
                if ([strPhotoUrl rangeOfString:@"?"].location != NSNotFound) {
                    strPhotoUrl = [strPhotoUrl stringByAppendingString:@"&spec=180"];
                }
            }
            
            [_headerCell.groupHeaderImageView setImageWithURL:[NSURL URLWithString:strPhotoUrl] placeholderImage:[UIImage imageNamed:@"user_default_portrait"]];
        } else {
            [_headerCell.groupHeaderImageView setImageWithURL:[NSURL URLWithString:self.group.headerUrl] placeholderImage:[UIImage imageNamed:@"group_default_portrait"]];
        }
        _headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _headerCell.separatorLineStyle = KDTableViewCellSeparatorLineTop;
    }
    
    return _headerCell;
}

- (KDChatDetailSearchCell *)searchCell {
    if (!_searchCell) {
        _searchCell = [[KDChatDetailSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_searchCell"];
        __weak __typeof(self) weakSelf = self;
        _searchCell.actionBlock = ^(KDChatDetailSearchType type){
            if (type == KDChatDetailSearchType_File) {
                [weakSelf buttonFilePressed];
            }else if (type == KDChatDetailSearchType_Picture){
                [weakSelf buttonPicPressed];
            }else if (type == KDChatDetailSearchType_Message){
                [weakSelf buttonSearchPressed];
            }
        };
        _searchCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return _searchCell;
}

- (KDTableViewCell *)memberNumberCell {
    if(!_memberNumberCell) {
        _memberNumberCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"_memberNumberCell"];
        _memberNumberCell.textLabel.text = ASLocalizedString(@"XTChatDetailViewController_total_members");
        _memberNumberCell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
        _memberNumberCell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
    }
    _memberNumberCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",self.group.userCount];
//    _memberNumberCell.detailTextLabel.text = [NSString stringWithFormat:@"%zi", self.group.participantIds.count+((self.group.participantIds.count == 1 && [self.group.participantIds.firstObject isEqualToString:[BOSConfig sharedConfig].currentUser.personId])?0:1)];
//    _memberNumberCell.detailTextLabel.text = [NSString stringWithFormat:@"%zi", self.group.participantIds.count];
    
    return _memberNumberCell;
}

- (KDTableViewCell *)noticeCell {
    if (!_noticeCell) {
        _noticeCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noticeCell"];
        _noticeCell.textLabel.text = ASLocalizedString(@"Notice_Group");
        _noticeCell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        _noticeCell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
    }
    return _noticeCell;
}

- (KDTableViewCell *)groupManagerCell {
    if (!_groupManagerCell) {
        _groupManagerCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noticeCell"];
        _groupManagerCell.textLabel.text = ASLocalizedString(@"Manager_Group");
        _groupManagerCell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        _groupManagerCell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
    }
    return _groupManagerCell;
}


- (KDChatDetailMemberCell *)memberCell {
    if (!_memberCell) {
        _memberCell = [[KDChatDetailMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_memberCell"];
        __weak __typeof(self) weakSelf = self;
        _memberCell.block = ^(KDChatDetailMemberType type, PersonSimpleDataModel *person){
            switch (type)
            {
                case KDChatDetailMemberType_Add:
                {
//                    weakSelf.operationType = KDChatPersonOperationType_add;
                    [weakSelf groupParticipantsViewAddPerson];
                }
                    break;
                case KDChatDetailMemberType_Person:
                {
//                    [KDEventAnalysis event:session_settings_user];
                    KDChatMemberViewController *chatMemberController = [[KDChatMemberViewController alloc] init];
                    chatMemberController.chooseContentDelegate = weakSelf;
                    chatMemberController.group = weakSelf.group;
                    chatMemberController.type = KDChatMemberViewControllerTypeNormal;
                    [weakSelf.navigationController pushViewController:chatMemberController animated:YES];
                }
                    break;
                case KDChatDetailMemberType_Delete:
                {
//                    weakSelf.operationType = KDChatPersonOperationType_delete;
//                    [KDEventAnalysis event:event_session_manager_delete];
                    [weakSelf groupParticipantsViewDeletePerson];
                }
                    break;
                default:
                    break;
            }
        };
        _memberCell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
        _memberCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _memberCell.group = self.group;
    }
    return _memberCell;
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
- (KDTableViewCell *)saveToFavCell
{
    if(!_saveToFavCell)
    {
        _saveToFavCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_saveToFavCell"];
        _saveToFavCell.textLabel.text = ASLocalizedString(@"XTChatDetailViewController_Saver");
        _saveToFavCell.accessoryView = self.favSwitchButton;
        _saveToFavCell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
    }
    return _saveToFavCell;
}


- (KDTableViewCell *)clearAllMessageCell
{
    if(!_clearAllMessageCell)
    {
        _clearAllMessageCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_clearAllMessageCell"];
        _clearAllMessageCell.textLabel.text = ASLocalizedString(@"XTChatDetailViewController_Clean");
        _clearAllMessageCell.textLabel.textAlignment = NSTextAlignmentLeft;
        _clearAllMessageCell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
    }
    return _clearAllMessageCell;
}

- (KDTableViewCell *)abortAddPersonModeCell
{
    if(!_abortAddPersonModeCell)
    {
        _abortAddPersonModeCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_abortAddPersonModeCell"];
        _abortAddPersonModeCell.textLabel.text = ASLocalizedString(@"已开启仅管理员添加成员模式");
        _abortAddPersonModeCell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _abortAddPersonModeCell;
}


- (KDTableViewCell *)quitCurrentGroupCell {
    if(!_quitCurrentGroupCell) {
        _quitCurrentGroupCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_quitCurrentGroupCell"];
        _quitCurrentGroupCell.textLabel.text = ASLocalizedString(@"XTChatDetailViewController_Logout");
        _quitCurrentGroupCell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _quitCurrentGroupCell;
}

- (KDTableViewCell *)dissolveGroupCell {
    if (!_dissolveGroupCell) {
        _dissolveGroupCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_dissolveGroupCell"];
        _dissolveGroupCell.textLabel.text = ASLocalizedString(@"XTChatDetailViewController_dissolve_group");
        _dissolveGroupCell.textLabel.textColor = [UIColor redColor];
        _dissolveGroupCell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _dissolveGroupCell;
}

#pragma mark - click 工具栏（文件、图片、搜索）

- (void)buttonFilePressed {
    //add
    [KDEventAnalysis event: event_dialog_group_file];
    [KDEventAnalysis eventCountly: event_dialog_group_file];
    KDFileInMessageViewController *controller = [[KDFileInMessageViewController alloc]init];
    [controller setGroupId:self.group.groupId];
    [controller setChatViewController:self.chatViewController];
    controller.fileInMessageType = KDFileInMessageType_file;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)buttonPicPressed {
    //add
    [KDEventAnalysis event:event_dialog_group_pic];
    [KDEventAnalysis eventCountly:event_dialog_group_pic];
    KDFileInMessageViewController *controller = [[KDFileInMessageViewController alloc]init];
    [controller setGroupId:self.group.groupId];
    [controller setChatViewController:self.chatViewController];
    controller.fileInMessageType = KDFileInMessageType_picture;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)buttonSearchPressed {
    //add
    [KDEventAnalysis event:event_dialog_group_search];
    [KDEventAnalysis eventCountly:event_dialog_group_search];
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:self.group pubAccount:nil mode:ChatPrivateMode];
    chatViewController.hidesBottomBarWhenPushed = YES;
    chatViewController.bSearchingMode = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

#pragma mark - XTSelectPersonsViewDelegate
- (void)selectPersonViewDidConfirm:(NSMutableArray *)persons
{
    //删除人员
    if (self.chooseContentType == KDChooseContentDelete)
    {
        [KDEventAnalysis event:event_session_settings_deleteuser];
        
        self.selectedPersons = persons;
        
        NSArray *personIds = [persons valueForKeyPath:@"personId"];
        
        if ([personIds containsObject:[BOSConfig sharedConfig].user.userId] || [personIds containsObject:[[BOSConfig sharedConfig].user externalPersonId]])
        {
            [self quitBtnPressed:nil];
            return;
        }
        
        NSString *titleString = (persons.count == 1) ? [NSString stringWithFormat:ASLocalizedString(@"XTChatDetailViewController_delete_person_sure"),[(PersonSimpleDataModel *)persons.firstObject personName]] : [NSString stringWithFormat:ASLocalizedString(@"XTChatDetailViewController_delete_persons_sure"),[(PersonSimpleDataModel *)persons.firstObject personName],(unsigned long)persons.count];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString message:@"" delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel") otherButtonTitles:ASLocalizedString(@"Global_Sure"), nil];
        alert.tag = DELETE_MEMBER_ALERT_TAG;
        [alert show];
    }
}


#pragma - mark Client Error
- (NSString *)errorWithClient:(ContactClient *)client result:(BOSResultDataModel *)result {
    NSString *error = nil;
    if (client.hasError) {
        error = client.errorMessage;
    } else if ([result isKindOfClass:[BOSResultDataModel class]] && result.error.length > 0) {
        error = result.error;
    }
    return error;
}
@end
