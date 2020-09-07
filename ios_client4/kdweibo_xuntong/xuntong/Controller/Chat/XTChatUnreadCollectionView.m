//
//  XTChatUnreadCollectionView.m
//  kdweibo
//
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "XTChatUnreadCollectionView.h"
#import "XTPersonDetailViewController.h"
#import "ContactClient.h"
#import "MBProgressHUD.h"
#import "CKSlideSwitchView.h"
#import "KDSubscribeCollectionView.h"

static NSString *unreadCollectionView = @"XTChatUnreadCollectionView";

@interface XTChatUnreadCollectionView () <CKSlideSwitchViewDelegate>
@property (nonatomic, strong) UIButton *sendImportantTextButton;

@property (nonatomic, strong) ContactClient *client;
@property (nonatomic, strong) ContactClient *notifyUnreadUsersClient;

@property (nonatomic, strong) NSMutableArray *readArray;
@property (nonatomic, strong) NSMutableArray *unreadArray;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) CKSlideSwitchView *slideSwitchView;

@property (nonatomic, strong) UIView *noReadButtomView;/** 未读的页面下面视图 */
@property (nonatomic, strong) UIButton *sendSMSToRemindButton;

@end

@implementation XTChatUnreadCollectionView

-(ContactClient *)client
{
    if (!_client)
    {
        _client = [[ContactClient alloc]initWithTarget:self action:@selector(clientDidReceive:result:)];
    }
    return _client;
}

-(ContactClient *)notifyUnreadUsersClient
{
    if (!_notifyUnreadUsersClient) {
        _notifyUnreadUsersClient = [[ContactClient alloc]initWithTarget:self action:@selector(notifyUnreadUsersClientDidReceive:result:)];
    }
    return _notifyUnreadUsersClient;
}

-(MBProgressHUD *)hud
{
    if (!_hud) {
        _hud = [[MBProgressHUD alloc]initWithView:self.view];
        _hud.mode = MBProgressHUDModeText;
        _hud.labelText = @"Some message...";
        _hud.margin = 10.f;
        [self.view addSubview:_hud];
    }
    return _hud;
}

-(void)dealloc
{
    //[super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"msgReadUpdate" object:nil];
    [_client cancelRequest];
    [_notifyUnreadUsersClient cancelRequest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgReadUpdate:) name:@"msgReadUpdate" object:nil];
    
    if (self.group.groupType == GroupTypeMany) {
        self.title = [NSString stringWithFormat:ASLocalizedString(@"XTChatUnreadCollectionView_Person_Num"), self.group.groupName,(unsigned long)([self.group.participant count] + 1)];
    } else {
        self.title = self.group.groupName;
    }
    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    
    self.noReadButtomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, CGRectGetWidth(self.view.frame), 44)];
    self.noReadButtomView.backgroundColor = [UIColor kdBackgroundColor2];
    self.noReadButtomView.clipsToBounds = YES;
    
    [self.view addSubview:self.noReadButtomView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Width(self.noReadButtomView.frame), 0.5)];
    lineView.backgroundColor = [UIColor kdDividingLineColor];
    [self.noReadButtomView addSubview:lineView];

    
    CGFloat height = CGRectGetHeight(self.view.frame)-kd_StatusBarAndNaviHeight;
    if ([[BOSSetting sharedSetting] sendSmsEnable]) {
        [self.client getMessageUreadDetailWithGroupId:self.groupId MsgId:self.msgId];
        height = CGRectGetHeight(self.view.frame)-110;
        self.noReadButtomView.hidden = NO;
    }else
    {
        self.noReadButtomView.hidden = YES;
    }
    _slideSwitchView = [[CKSlideSwitchView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, CGRectGetWidth(self.view.frame), height)];
    _slideSwitchView.tabItemTitleNormalColor = FC2;
    _slideSwitchView.tabItemTitleSelectedColor = FC5;
    _slideSwitchView.topScrollViewBackgroundColor = [UIColor kdBackgroundColor2];
    _slideSwitchView.tabItemShadowColor = FC5;
    _slideSwitchView.slideSwitchViewDelegate = self;
    [self.view addSubview:_slideSwitchView];
    
    
    CGFloat smsWidth = CGRectGetWidth(self.noReadButtomView.frame)/2;
    
    _sendSMSToRemindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendSMSToRemindButton setTitle:ASLocalizedString(@"XTChatUnreadCollectionView_MsgNotify") forState:UIControlStateNormal];
    [_sendSMSToRemindButton setTitleColor:FC5 forState:UIControlStateNormal];
    [_sendSMSToRemindButton setTitleColor:FC2 forState:UIControlStateHighlighted];
    [_sendSMSToRemindButton setTitleColor:FC2 forState:UIControlStateDisabled];
    _sendSMSToRemindButton.titleLabel.font = FS2;
    _sendSMSToRemindButton.frame = CGRectMake(CGRectGetWidth(self.noReadButtomView.frame)/4, 0.0, smsWidth, 44);
    [_sendSMSToRemindButton addTarget:self action:@selector(sendImportantTextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _sendSMSToRemindButton.layer.cornerRadius = 0;
    
//    if (![self msgNotityBtnCanPress]) {
////        [_sendSMSToRemindButton setTitleColor:FC3 forState:UIControlStateNormal];
////        _sendSMSToRemindButton.userInteractionEnabled = NO;
//         _sendSMSToRemindButton.enabled = NO;
//    }else {
//        _sendSMSToRemindButton.enabled = YES;
//    }
    [self.noReadButtomView addSubview:_sendSMSToRemindButton];
    
    for (UIGestureRecognizer *gesture in self.navigationController.view.gestureRecognizers)
    {
        if([gesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            [_slideSwitchView.rootScrollview.panGestureRecognizer requireGestureRecognizerToFail:gesture];
        }
    }
    
//    self.sendImportantTextButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"XTChatUnreadCollectionView_SendMsg")];
//    self.sendImportantTextButton.titleLabel.font = FS2;
//    self.sendImportantTextButton.frame = CGRectMake(0, self.view.frame.size.height - 44, CGRectGetWidth(self.view.frame), 44);
//    [self.sendImportantTextButton setCircle];
//    [self.sendImportantTextButton addTarget:self action:@selector(sendImportantTextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    self.sendImportantTextButton.layer.cornerRadius = 0;
    
//    [self.view addSubview:self.sendImportantTextButton];
    
    [_slideSwitchView reloadData];
}


-(void)clientDidReceive:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success)
    {
        NSDictionary *dic = result.data;
        NSArray *readArray = dic[@"readUsers"];
        NSArray *unreadArray = dic[@"unreadUsers"];
        BOOL smsNotify = [dic[@"smsNotify"] boolValue];
        if (self.bGrayRemindeButton) {
           _sendSMSToRemindButton.userInteractionEnabled = NO;
        }else {
            _sendSMSToRemindButton.enabled = smsNotify;
        }
        
        
        self.readArray = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonIds:readArray]];
        self.unreadArray = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonIds:unreadArray]];
        [self.slideSwitchView reloadData];
    }
}

-(void)notifyUnreadUsersClientDidReceive:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success)
    {
        NSMutableString *string = [NSMutableString stringWithFormat:ASLocalizedString(@"XTChatUnreadCollectionView_Sended")];
        PersonSimpleDataModel *model = [self.unreadArray firstObject];
        
        if (self.unreadArray.count == 1)
        {
            [string appendString:[NSString stringWithFormat:@"%@", model.personName]];
        }
        else
        {
            [string appendString:[NSString stringWithFormat:ASLocalizedString(@"%@等%d人"), model.personName, self.unreadArray.count]];
        }
        
        self.hud.labelText = string;
        self.hud.margin = 10.f;
        self.hud.yOffset = 150.f;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1];
        
//        [KDEventAnalysis event:event_unreadMessage_sendUnreadUsers];
    }
    else
    {
        self.hud.labelText = ASLocalizedString(@"XTChatUnreadCollectionView_Send_Fail");
        self.hud.margin = 10.0f;
        self.hud.yOffset = 150.0f;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1];
    }
}

#pragma mark - sendImportantTextButtonClicked
- (void)sendImportantTextButtonClicked:(UIButton *)sender
{
//    NSString *date = [[NSDate date] dz_stringValue];
   [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:self.msgId];
    sender.enabled = NO;
    //增加notifyType，值为voiceNotify为语音提醒，smsNotify（或者空）为短信提醒
//    NSString *notifyType = nil;
//    NSString *sendUnreadUsers_type = nil;
//    if ([sender.titleLabel.text isEqualToString:@"短信提醒"]) {
//        notifyType = @"smsNotify";
//        sendUnreadUsers_type = label_unreadMessage_sendUnreadUsers_type_sms;
        
//    }
//    if ([sender.titleLabel.text isEqualToString:@"电话提醒"]) {
//        notifyType = @"voiceNotify";
//        sendUnreadUsers_type = label_unreadMessage_sendUnreadUsers_type_tel;
//    }
//    [self.notifyUnreadUsersClient notifyUnreadUsersWithGroupId:self.groupId MsgId:self.msgId notifyType:notifyType];
    
//    [KDEventAnalysis event:event_unreadMessage_sendUnreadUsers attributes:@{label_unreadMessage_sendUnreadUsers_type : sendUnreadUsers_type}];

    [self.notifyUnreadUsersClient notifyUnreadUsersWithGroupId:self.groupId MsgId:self.msgId];
}

-(void)msgReadUpdate:(NSNotification *)sender
{
    [self.client getMessageUreadDetailWithGroupId:self.groupId MsgId:self.msgId];
//    NSArray *groupIds = sender.userInfo[@"groupIds"];
//    if (groupIds && [groupIds count] > 0 && [groupIds containsObject:self.groupId]) {
//        [self.client getMessageUreadDetailWithGroupId:self.groupId MsgId:self.msgId];
//    }
}

#pragma mark - setArray
-(void)setReadArray:(NSArray *)readArray UnreadArray:(NSArray *)unreadArray
{
    self.readArray = [NSMutableArray array];
    self.unreadArray = [NSMutableArray array];
    self.readArray = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonIds:readArray]];
    self.unreadArray = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonIds:unreadArray]];
}


#pragma mark - slideswitchdelegate
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView heightForTabItemForTopScrollview:(UIScrollView *)topScrollview
{
    return 40;
}

- (NSInteger)slideSwitchView:(CKSlideSwitchView *)slideSwitchView numberOfTabItemForTopScrollview:(UIScrollView *)topScrollview
{
    return 2;
}

- (NSString *)slideSwitchView:(CKSlideSwitchView *)slideSwitchView titleForTabItemForTopScrollviewAtIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            return ASLocalizedString(@"KDGroupFileTableView_Unread");
        }
            break;
        case 1:
        {
            return ASLocalizedString(@"KDGroupFileTableView_Readed");
        }
            break;
    }
    return nil;
}

- (UIView *)slideSwitchView:(CKSlideSwitchView *)slideSwitchView viewForRootScrollViewAtIndex:(NSInteger)index
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat minSpace = (ScreenFullWidth - 320)/3.0;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
    layout.minimumInteritemSpacing = minSpace;
    layout.minimumLineSpacing = 8;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, -200, ScreenFullWidth, 200)];
    headerView.backgroundColor = [UIColor kdBackgroundColor1];
    
    KDSubscribeCollectionView *collectionView = [[KDSubscribeCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.tag = index;
    collectionView.subscribeDataArray = (index == 0 ? self.unreadArray : self.readArray);
    collectionView.backgroundColor = [UIColor kdBackgroundColor2];
//    __weak XTChatUnreadCollectionView *weakSelf = self;
    collectionView.subscribeCellDelegate = ^(PersonSimpleDataModel *data){
//        [KDDetail toDetailWithPerson:data inController:weakSelf];
        XTPersonDetailViewController *viewController = [[XTPersonDetailViewController alloc] initWithPersonId:data.personId];
        [self.navigationController pushViewController:viewController animated:YES];
    };
    [collectionView addSubview:headerView];
    [collectionView reloadData];
    return collectionView;
}

- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView widthForTabItemForTopScrollview:(UIScrollView *)topScrollview
{
    return CGRectGetWidth(self.view.frame)/2.0;
}

- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView marginForTopScrollview:(UIScrollView *)topscrollview
{
    return 0;
}
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView heightOfShadowImageForTopScrollview:(UIScrollView *)topScrollview
{
    return  2;
}
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView fontSizeForTabItemForTopScrollview:(UIScrollView *)topScrollview
{
    return 16;
}

- (NSInteger)slideSwitchView:(CKSlideSwitchView *)slideSwitchView selectedTabItemIndexForFirstStartForTopScrollview:(UIScrollView *)topScrollview
{
    return 0;
}

- (BOOL)slideSwitchView:(CKSlideSwitchView *)slideSwitchView seperatorImageViewShowInTopScrollview:(UIScrollView *)topScrollview
{
    return YES;
}

- (void)slideSwitchView:(CKSlideSwitchView *)slideSwitchView currentIndex:(NSInteger)index
{
    CGRect orgFrame = self.noReadButtomView.frame;
    orgFrame.origin.y =  CGRectGetHeight(self.view.frame) + ((index == 0)? - orgFrame.size.height : 0);
    
    [UIView animateWithDuration:.2 animations:^{
        self.noReadButtomView.frame = orgFrame;
    }];
}

- (void)slideSwitchViewConfigRootScrollviewSuccess
{
    UIView *collectionView = [self.slideSwitchView findContentViewWithIndex:0];
    collectionView.frame = CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.height );
}

- (BOOL)msgNotityBtnCanPress
{
    NSDate *saveDate = [[NSUserDefaults standardUserDefaults] objectForKey:self.msgId];
    if (saveDate == nil) {
        return YES;
    }
    NSTimeInterval  oneDay = 24*60*60;  //1天的长度
    NSDate *date = [NSDate dateWithTimeInterval:oneDay sinceDate:saveDate];
    if ([date dz_earlierThan:[NSDate date]]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end

