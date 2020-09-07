//
//  XTPublicListViewController.m
//  XT
//
//  Created by mark on 14-1-11.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//
#define APPVIEWWIDTH  78.0
#define APPVIEWHEIGHT 100.0
#define APPVIEWORIGIN(x,y)  CGRectMake(x, y, APPVIEWWIDTH, APPVIEWHEIGHT)
#define BGHEIGHT MainHeight-44

#import "XTPublicListViewController.h"
#import "BOSSetting.h"
#import "BOSConfig.h"
#import "BOSUtils.h"
#import "UIButton+XT.h"
#import "XTPersonDetailViewController.h"
#import "UIImage+XT.h"
#import "ContactLoginDataModel.h"
#import "XTPubAcctUserChatListViewController.h"
#import "XTSetting.h"
#import "ContactClient.h"

@interface XTPublicListViewController ()
{
    ContactClient * _contactClient;
    PersonSimpleDataModel * _publicDM;
}

@end

@implementation XTPublicListViewController
@synthesize hud;
- (id)init
{
    self = [super init];
    if (self) {
       self.title = ASLocalizedString(@"XTPublicListViewController_EnterPrise");
        [self.view setBackgroundColor:[UIColor kdBackgroundColor1]];
        appBgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, BGHEIGHT+ Adjust_Offset_Xcode5)];
        self.view.backgroundColor = BOSCOLORWITHRGBA(0xf2f4f8, 1.0);
        [self.view addSubview:appBgScrollView];
        //加载数据
        self.attentionArr = [[NSMutableArray alloc]initWithCapacity:1];
        
        UIButton *shareBtn = [UIButton buttonWithTitle:ASLocalizedString(@"KDSubscribeViewController_Refresh")];
        [shareBtn addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
        
        buttonBackGroundView = [[UIView alloc]initWithFrame:CGRectMake(10, 6, 300, 34)];
        buttonBackGroundView.backgroundColor = [UIColor clearColor];
        buttonBackGroundView.layer.borderColor = RGBCOLOR(147, 150, 154).CGColor;
        buttonBackGroundView.layer.borderWidth = 1.0f;
        buttonBackGroundView.layer.cornerRadius = 5.0f;
        buttonBackGroundView.clipsToBounds = YES;
        
        leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 150, 34);
        [leftButton setTitle:ASLocalizedString(@"XTPublicListViewController_My")forState:UIControlStateNormal];
        [leftButton setTitle:ASLocalizedString(@"XTPublicListViewController_My")forState:UIControlStateHighlighted];
        [leftButton setTitle:ASLocalizedString(@"XTPublicListViewController_My")forState:UIControlStateSelected];
        [leftButton setTitleColor:RGBCOLOR(140, 140, 140) forState:UIControlStateNormal];
        [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [leftButton.titleLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
        [leftButton setBackgroundImage:nil forState:UIControlStateNormal];
        [leftButton setBackgroundImage:[UIImage imageWithColor:RGBACOLOR(147, 150, 154, 1.f)] forState:UIControlStateHighlighted];
        [leftButton setBackgroundImage:[UIImage imageWithColor:RGBACOLOR(147, 150, 154, 1.f)] forState:UIControlStateSelected];
        [leftButton addTarget:self action:@selector(leftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        leftButton.selected = YES;
        leftButton.userInteractionEnabled  = NO;
        [buttonBackGroundView addSubview:leftButton];
        
        rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(150, 0, 150, 34);
        [rightButton setTitle:ASLocalizedString(@"XTPublicListViewController_Book")forState:UIControlStateNormal];
        [rightButton setTitle:ASLocalizedString(@"XTPublicListViewController_Book")forState:UIControlStateHighlighted];
        [rightButton setTitle:ASLocalizedString(@"XTPublicListViewController_Book")forState:UIControlStateSelected];
        [rightButton setTitleColor:RGBCOLOR(140, 140, 140) forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [rightButton.titleLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
        [rightButton setBackgroundImage:nil forState:UIControlStateNormal];
        [rightButton setBackgroundImage:[UIImage imageWithColor:RGBACOLOR(147, 150, 154, 1.f)] forState:UIControlStateHighlighted];
        [rightButton setBackgroundImage:[UIImage imageWithColor:RGBACOLOR(147, 150, 154, 1.f)] forState:UIControlStateSelected];
        [rightButton addTarget:self action:@selector(rightButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [buttonBackGroundView addSubview:rightButton];
        [appBgScrollView addSubview:buttonBackGroundView];

        CALayer *lineLayer = [self genLine];
        lineLayer.frame = CGRectMake(0, 46, 320, 0.5);
        [appBgScrollView.layer addSublayer:lineLayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getwithFMdb) name:@"loadData" object:nil];
        self.hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.hud];
        [self getPublicInfo];
    }
    return self;
}

- (CALayer *)genLine
{
    CALayer *line = [CALayer layer];
    line.backgroundColor = RGBCOLOR(203, 203, 203).CGColor;
    
    return line;
}

-(void)publicAttentionadd:(NSNotification*)noti
{
    NSString*publicID=[noti object];
    for (int i=0; i<self.publiclist.count; i++) {
        PersonSimpleDataModel *bean=[self.publiclist objectAtIndex:i];
        if ([publicID isEqualToString:bean.personId]) {
            bean.subscribe=@"1";
            [self.attentionArr insertObject:bean atIndex:i];
            return;
        }
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.attentionArr forKey:@"attentionArr"];
    [defaults setValue:self.publiclist forKey:@"publiclist"];
    [defaults synchronize];
    [self loadAppView:self.attentionArr];
}

-(void)publicAttentiondelete:(NSNotification*)noti
{
    NSString*publicID=[noti object];
    for (int i=0; i<self.attentionArr.count; i++) {
        PersonSimpleDataModel *bean=[self.attentionArr objectAtIndex:i];
        if ([publicID isEqualToString:bean.personId]) {
            bean.subscribe=@"0";
            [self.attentionArr removeObject:bean];
            return;
        }
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.attentionArr forKey:@"attentionArr"];
    [defaults setValue:self.publiclist forKey:@"publiclist"];
    [defaults synchronize];
    [self loadAppView:self.attentionArr];
}

- (void)reload
{
    [KDEventAnalysis event:event_contact_pubacc_refresh];
    if (!_getAppClient) {
        _getAppClient = [[AppsClient alloc] initWithTarget:self action:@selector(getPublicListDidReceived:result:)];
    }
    [_getAppClient getPublicList];
    [self.hud setLabelText:ASLocalizedString(@"XTPersonalFilesController_Wait")];
    [self.hud show:YES];
}


-(void)getPublicInfo
{
    NSDate*lastdate=[[NSUserDefaults standardUserDefaults]objectForKey:@"senddata"];
    NSDate*senddate=[NSDate date];
    NSTimeInterval time=[senddate timeIntervalSinceDate:lastdate];
    //大于24小时才会请求一次数据插入数据库，或者每次都走数据库读取
    if (time > 3600*24 || lastdate==nil) {
        //获取推荐应用列表
        if (!_getAppClient) {
            _getAppClient = [[AppsClient alloc] initWithTarget:self action:@selector(getPublicListDidReceived:result:)];
        }
        [_getAppClient getPublicList];
        [self.hud setLabelText:ASLocalizedString(@"XTPersonalFilesController_Wait")];
        [self.hud show:YES];
    }else
    {
        [self getwithFMdb];
    }
}

-(void)getwithFMdb
{
    NSMutableArray *t_array = [[NSMutableArray alloc] init];
    NSMutableArray *c_array = [[NSMutableArray alloc] init];
    NSArray*array=[[XTDataBaseDao sharedDatabaseDaoInstance]queryAllPublicPersonSimple];
    for (int i=0; i< array.count; i++) {
        PersonSimpleDataModel *t_record = [array objectAtIndex:i];
        if ([[t_record.subscribe description]isEqualToString:@"1"]) {
            [t_array addObject:t_record];
        }else
        {
            if ([[t_record.canUnsubscribe description] isEqualToString:@"1"]) {
                [c_array addObject:t_record];
            }
        }
    }
    self.attentionArr = t_array;
    self.publiclist = c_array;
    [self leftButtonPressed];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)attentionlist:(id)data
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.attentionArr=[defaults objectForKey:@"attentionArr"];
    self.publiclist=[defaults objectForKey:@"publiclist"];
    [self loadAppView:self.attentionArr];
}

-(void)getPublicListDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    //BOSDEBUG(@"data:%@",result.data);
    [self.hud hide:YES];
    if (result.success) {
        if ([[XTDataBaseDao sharedDatabaseDaoInstance] deletePublicPersonSimpleSetall]) {
            NSMutableArray *t_array = [[NSMutableArray alloc] init];
            NSMutableArray *c_array = [[NSMutableArray alloc] init];
            for (id each in result.data) {
                PersonSimpleDataModel *t_record = [[PersonSimpleDataModel alloc] initWithDictionary:each];
                //中文
                t_record.photoUrl = [t_record.photoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                //插入person表
                [[XTDataBaseDao sharedDatabaseDaoInstance] insertPublicPersonSimple:t_record];
                if ([[t_record.subscribe description]isEqualToString:@"1"]) {
                    [t_array addObject:t_record];
                }else
                {
                    if ([[t_record.canUnsubscribe description]isEqualToString:@"1"]) {
                        [c_array addObject:t_record];
                    }
                }
            }
            [[NSUserDefaults standardUserDefaults]setObject:[NSDate date] forKey:@"senddata"];
            self.attentionArr = t_array;
            [self reloadDBdata:self.attentionArr];
            self.publiclist = c_array;
            [self leftButtonPressed];
        }
    }else
    {
        [self getwithFMdb];
    }
}

-(void)reloadDBdata:(NSMutableArray*)personIds
{
    NSString *unreadCountString = nil;
    NSMutableArray*publicgroups = [[NSMutableArray alloc]init];
    NSMutableArray*timelinegroups = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupList:&unreadCountString]];
    
    for (PersonSimpleDataModel *pubPerson in personIds) {
        //查询关注公共号对应的groupid
        GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:pubPerson];
        if (group) {
            [publicgroups addObject:group.groupId];
        }
    }
    
    for (GroupDataModel*group in timelinegroups) {
        if(group.groupType >= GroupTypePublic)
        {
            NSString *publicId = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonIdWithGroupId:group.groupId];
            if (![publicgroups containsObject:group.groupId] && [self isDeletablePublicId:publicId]) {
                [[XTDataBaseDao sharedDatabaseDaoInstance] setPrivateGroupListToDeleteWithGroupId:group.groupId];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadGroupTable" object:self userInfo:nil];
    
}

- (BOOL)isDeletablePublicId:(NSString *)publicId
{
    //文件助手和讯通团队
    return !([publicId isEqualToString:@"XT-0060b6fb-b5e9-4764-a36d-e3be66276586"] || [publicId isEqualToString:@"XT-10000"]);
}

#pragma Load App

-(void)loadAppView:(NSMutableArray*)array
{
    for (id view in [appBgScrollView subviews]) {
        [view removeFromSuperview];
    }
//    [appBgScrollView addSubview:leftButton];
//    [appBgScrollView addSubview:rightButton];
    [appBgScrollView addSubview:buttonBackGroundView];
    
    float nextOriginX = 4.0;
    float nextOriginY = 64.0;
    int myAppNum = 0;
    for (int i = 0; i<[array count]; i++) {
        PersonSimpleDataModel *appDM = [array objectAtIndex:i];
        AppView *aView = [[AppView alloc] initWithpersonDataModel:appDM frame:APPVIEWORIGIN(nextOriginX, nextOriginY)];
        aView.delegate = self;
    
        [appBgScrollView addSubview:aView];
        //金蝶应用
        nextOriginX += APPVIEWWIDTH;
        if (nextOriginX > APPVIEWWIDTH*3 + 18.0) {
            nextOriginX = 4.0;
            nextOriginY += APPVIEWHEIGHT;
        }
    }
    
    int height = ceil(([array count] - myAppNum) / 3.0) * APPVIEWHEIGHT + 55;
    if (height < BGHEIGHT) {
        height = BGHEIGHT;
    }
    [appBgScrollView setContentSize:CGSizeMake(300, height)];
    
}

- (void)photoclick:(PersonSimpleDataModel *)publicDM
{
    if (leftButton.selected == YES) {
        if (publicDM.personId) {
            if(publicDM.manager)
            {
                [self pubGroupList:publicDM];
            }
            else
            {
                [self openChatViewController:publicDM];
            }
        }
    }
    else {
        XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:publicDM with:YES];
        personDetail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:personDetail animated:YES];
    }
}

- (void)openChatViewController:(PersonSimpleDataModel *)publicDM
{
    //mod by stone 现在需要打开后回到本页面，说不准哪天需要改回来，代码先注释保留
    //            [[KDWeiboAppDelegate getAppDelegate].XT timelineToChatWithPerson:publicDM];
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:publicDM];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

-(void)pubGroupList:(PersonSimpleDataModel *)publicDM
{
    if (_contactClient == nil) {
        _contactClient = [[ContactClient alloc] initWithTarget:self action:@selector(publicGroupListDidReceived:result:)];
    }
    [_contactClient publicGroupList:publicDM.personId updateTime:[[XTSetting sharedSetting].pubAccountsUpdateTimeDict objectForKey:publicDM.personId]];
    [self.hud setLabelText:ASLocalizedString(@"KDSubscribeViewController_Load")];
    [self.hud show:YES];
    _publicDM = publicDM;
}

- (void)publicGroupListDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    [self.hud hide:YES];
    if (result.success && result.data) {
        GroupListDataModel *groupList = [[GroupListDataModel alloc] initWithDictionary:result.data];
        //更新updateTime
        if (![groupList.updateTime isEqualToString:@""]) {
            [[XTSetting sharedSetting].pubAccountsUpdateTimeDict setObject:groupList.updateTime forKey:_publicDM.personId];
        }
        [[XTSetting sharedSetting] saveSetting];
        if ([groupList.list count] > 0)
        {
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertUpdatePublicGroupList:groupList withPublicId:_publicDM.personId];
        }
        //管理员，打开消息页面
        PubAccountDataModel *publAccountDataModel = [[PubAccountDataModel alloc] init];
        publAccountDataModel.publicId = _publicDM.personId;
        publAccountDataModel.name = _publicDM.personName;
        XTPubAcctUserChatListViewController *publicTimelineViewController = [[XTPubAcctUserChatListViewController alloc] initWithPubAccount2:publAccountDataModel andPerson:_publicDM];
        [self.navigationController pushViewController:publicTimelineViewController animated:YES];
    }
    else
    {
        [self openChatViewController:_publicDM];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


#pragma mark - Button Callback

- (void)leftButtonPressed
{
    leftButton.selected = YES;
    leftButton.userInteractionEnabled = NO;
    rightButton.selected = NO;
    rightButton.userInteractionEnabled = YES;
    [self loadAppView:self.attentionArr];
}

- (void)rightButtonPressed
{
    rightButton.selected = YES;
    rightButton.userInteractionEnabled = NO;
    leftButton.selected = NO;
    leftButton.userInteractionEnabled = YES;
    [self loadAppView:self.publiclist];
}

@end
