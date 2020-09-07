//
//  XTPersonDetailViewController.m
//  XT
//
//  Created by Gil on 13-7-24.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTPersonDetailViewController.h"
#import "UIButton+XT.h"
#import "ContactClient.h"
#import "XTPersonDetailCell.h"
#import "UIImage+XT.h"
#import "XTSMSHandle.h"
#import "XTTELHandle.h"
#import "XTMAILHandle.h"
#import "MBProgressHUD.h"
#import "AppsClient.h"
#import "XTDeleteService.h"
#import "BOSConfig.h"
#import "KDPersonDetailCell.h"
#import "XTOrganizationViewController.h"
#import "XTChatViewController.h"
#import "KDErrorDisplayView.h"
#import "KDDatabaseHelper.h"
#import "KDWeiboDAOManager.h"
#import "UIActionSheet+ButtonEnabled.h"
#import "NetworkUserController.h"
#import "BlogViewController.h"
#import "KDABPersonActionHelper.h"
#import "KDPersonHeaderBar.h"
#import "KDPersonFooterBar.h"

#import "KDWaterMarkAddHelper.h"
#import "NSString+Match.h"
#import "UIViewAdditions.h"

#define RIGHT_NAVIGATION_ITEM_ACTION_SHEET_TAG   (1912)
#define KD_PERSONDETAIL_CELLPHONE_TAG (1913)
#define KD_PERSONDETAIL_BOTTOM_PHONE_TAG (1914)
#define KD_PERSONDETAIL_VIEWERROR_TAG (1915)

@interface XTPersonDetailViewController ()<KDPersonDetailCellDelegate,KDPersonHeaderBarDelegate,KDPersonFooterBarDelegate,XTPersonHeaderViewDelegate>{
    XTOpenSystemClient * _openClient;
    
    BOOL didLoadWBUserInfo_;
    BOOL didCheckFollow_;     //检查对该用户是否已经关注
}

@property (nonatomic,strong) NSString *WBUserId; //原微博userId
@property (nonatomic,strong) NSString *XTUserId; //原迅通userId
@property (nonatomic,strong) NSString *screenName; //名字 例如@xxx
@property (nonatomic,strong) NSString *openId;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) XTPersonDetailHeaderView *headerView;
@property (nonatomic, strong) KDPersonHeaderBar *headerBar;
@property (nonatomic, strong) KDPersonFooterBar *footerBar;
@property (nonatomic, strong) UIButton *smsButton;
@property (nonatomic, strong) UIButton *xtButton;
@property (nonatomic, strong) NSArray  *buttons;
@property (nonatomic, strong) UIButton *favButton;
@property (nonatomic, strong) UIButton *chatviewButton;
@property (nonatomic, strong) UIButton *qrscanButton;
@property (nonatomic, strong) PersonDataModel *person;
@property (nonatomic, strong) ContactClient *personInfoClient;
@property (nonatomic, strong) ContactClient *favClient;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) AppsClient *attentionClient;
@property (nonatomic, assign) BOOL isfav;
@property (nonatomic, assign) BOOL isFollowing;

@property (nonatomic, strong) KDUser *user;

@property (nonatomic, strong) UIImageView *imageViewFilter; // 蒙版
@property (nonatomic, strong) UIButton *buttonFilterConfirm; // 蒙版确认按钮

@property (nonatomic, strong) NSMutableArray *jobArray; //职位数组


@property (nonatomic, strong) KDABPersonActionHelper *personHelper;
//是否折叠，默认为YES
@property (nonatomic, assign) BOOL isFold;


//用于取加载的数据索引
@property (nonatomic, assign) NSInteger dataIndex;

//全部的cell总数
@property (nonatomic, assign) NSInteger totalRow;
@property (nonatomic, strong) UIView *orgLeaderView;
@property (nonatomic, assign) BOOL isOrgLeaderViewExpand;
@end

@implementation XTPersonDetailViewController


- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.title = ASLocalizedString(@"XTPersonDetailViewController_Contact_Detail");
    }
    return self;
}

//微博userid初始化
- (id)initWithUserId:(NSString *)userId {
    self = [super init];
    if (self) {
        self.WBUserId = userId;
        self.isFromWeibo = YES;
    }
    return self;
}
//迅通userid初始化
- (id)initWithPersonId:(NSString *)personId
{
    self = [super init];
    if (self) {
        self.XTUserId = personId;
        [self restorePerson];
    }
    return self;
}

- (id)initWithScreenName:(NSString*)screenName {
    self = [super init];
    if (self) {
        
        self.screenName = screenName;
        self.isFromWeibo = YES;
    }
    return self;
}
- (id)initWithSimplePerson:(PersonSimpleDataModel *)person with:(BOOL)ispublic
{
    self = [self init];
    if (self) {
        self.ispublic = ispublic;
        
        PersonDataModel *personDM = nil;
        if (ispublic) {
            personDM = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicPersonSimple:person.personId];
            self.navigationItem.title=ASLocalizedString(@"KDPubAccDetailViewController_Detail");
            
        }
        else {
            personDM = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonDetailWithPerson:person];
            self.navigationItem.title = ASLocalizedString(@"XTPersonDetailViewController_Contact_Detail");
        }
        
        if (personDM) {
            if([person isKindOfClass:[PersonSimpleDataModel class]])
            {
                if(person.wbUserId.length>0)
                    personDM.wbUserId = person.wbUserId;
            }
            self.person = personDM;
        }
        else {
            self.person = [[PersonDataModel alloc] initWithPersonSimple:person];
        }
        if (ispublic) {
            _isfav = [self.person.subscribe isEqualToString:@"1"];
        }
        else {
            _isfav = NO;
        }
        
        self.WBUserId = self.person.wbUserId;
        
    }
    return self;
}

- (id)initWithSimplePerson:(PersonSimpleDataModel *)person
{
    return [self initWithSimplePerson:person with:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.ispublic)
    {
        _dataIndex = 0;
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [[UIApplication sharedApplication] setStatusBarStyle:(self.headerBar.backgroundView.alpha == 1) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self loadUser];
    [self checkFollow];
    
    if(!self.ispublic)
        self.navigationController.navigationBarHidden = YES;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if(!self.ispublic)
    {
//        self.isFold = NO;
        _dataIndex = 0;
        self.navigationController.navigationBarHidden = NO;
    }
}

//从本地持久化还原person
- (void)restorePerson {
    PersonDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonDetailWithPersonId:self.XTUserId];
    if (person) {
        self.person = person;
        self.WBUserId = self.person.wbUserId;
    }
    else {
        self.person = [[PersonDataModel alloc] init];
        self.person.personId = self.XTUserId;
    }
    self.ispublic = [self.person isPublicAccount];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isFold = YES;
    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, ScreenFullWidth, CGRectGetHeight(self.view.frame) - ([self isCurrentUser:self.person]?0:43.0)) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor kdBackgroundColor2];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    XTPersonDetailHeaderView *headerView = [[XTPersonDetailHeaderView alloc] initWithPerson:self.person withpublic:self.ispublic];
    headerView.delegate = self;
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
    [self.view addSubview:self.headerBar];
    [self.view addSubview:self.footerBar];
    self.footerBar.hidden = [self isCurrentUser:self.person] || !self.person.isVisible;
    if (!self.ispublic) {
        [self personInfo];
    }
    
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    if(self.ispublic) {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), 50.0f)];
        
        self.favButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_favButton addTarget:self action:@selector(addfav) forControlEvents:UIControlEventTouchUpInside];
        _favButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _favButton.frame = CGRectMake(6.5f, 0.0f, CGRectGetWidth(footer.frame) - 13.0f, CGRectGetHeight(footer.frame));
        _favButton.layer.masksToBounds = YES;
        _favButton.layer.cornerRadius = 5.0f;
        [self updateFavButton];
        
        [footer addSubview:self.favButton];
        self.tableView.tableFooterView = footer;
    }
    
    
//    if(!self.ispublic) {
//        //back button
//        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [backBtn setImage:[UIImage imageNamed:@"navigationItem_back"] forState:UIControlStateNormal];
//        [backBtn setImage:[UIImage imageNamed:@"navigationItem_back_hl"] forState:UIControlStateHighlighted];
//        [backBtn sizeToFit];
//        [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//        backBtn.frame = CGRectMake(5.0f, 2.0f +20.0f , CGRectGetWidth(backBtn.bounds), CGRectGetHeight(backBtn.bounds));
//        [self.view addSubview:backBtn];
//    }
    
    didLoadWBUserInfo_ = NO;
    
    // 蒙层
//    if (!_ispublic && ![[NSUserDefaults standardUserDefaults] boolForKey:@"PERSON_DETAIL_FILTER_SHOWN"] &&![self.person.personId isEqualToString:[[[BOSConfig sharedConfig]user]userId]])
//    {
//        [self.view addSubview:self.imageViewFilter];
//    }
//    [self updateWaterMark];
}

- (void)fetchPersonByOpenId
{
    if (self.openId) {
        if(_openClient == nil)
            _openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getPersonDidRecieve:result:)];//
        [_openClient getPersonByEid:[BOSConfig sharedConfig].user.eid
                          andOpenId:self.openId
                              token:[BOSConfig sharedConfig].user.token];
    }
    
}

- (void)getPersonDidRecieve:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    //[self personInfoDidReceived:nil result:result];
    
    PersonDataModel *person = [[PersonDataModel alloc] initWithDictionary:result.data];
    if (person.menu != nil && [person.menu isKindOfClass:[NSArray class]]) {
        person.menu = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:person.menu options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    
    self.person = person;
//    self.headerView.person = person;
    
    self.orgLeaderView = nil;
    [self.tableView reloadData];
    [self personInfo];
    //查数据库，更新 status，不然状态不同步
    PersonSimpleDataModel *aPerson = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonDetailWithPerson:person];
    self.person.status = aPerson.status;
  
}

- (void)addReplacementNavigationBarButton
{
    if ([self isInCompany] && ![self isCurrentUser:self.person] && self.person.isVisible) {
        //right button
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"更多"];
        
        [rightBtn setImage:image forState:UIControlStateNormal];
        [rightBtn setImage:image forState:UIControlStateHighlighted];
        [rightBtn sizeToFit];
        [rightBtn addTarget:self action:@selector(rightBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        rightBtn.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - CGRectGetWidth(rightBtn.bounds) - 18.0f, 2.0f +  30.0f, CGRectGetWidth(rightBtn.bounds)+12, CGRectGetHeight(rightBtn.bounds));
        rightBtn.layer.cornerRadius = CGRectGetHeight(rightBtn.bounds)/2;
        rightBtn.layer.masksToBounds = YES;
        //rightBtn.backgroundColor = (self.person.gender==2?[UIColor kdGradientFemaleStartColor]:[UIColor kdGradientMaleStartColor]);
        [self.view addSubview:rightBtn];
    }

}

- (BOOL)isInCompany
{
    BOOL isCompany;
    if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
        return YES;
    }
    //从微博进则用wbuserid做判断，否则用personid
    if (_isFromWeibo)
    {
        isCompany =  [[NSNumber numberWithBool:([[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonDetailWithWebPersonId:self.WBUserId] != nil)] boolValue];
    }
    else
    {
        isCompany =  [self.person isInCompany];
    }
    return isCompany;
}
- (void)updateFavButton
{
    if(_isfav) {
        [_favButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_favButton setTitle:ASLocalizedString(@"XTPersonDetailViewController_Attention_Cancel")forState:UIControlStateNormal];
        _favButton.backgroundColor = [UIColor whiteColor];
        _favButton.layer.borderColor = RGBCOLOR(0xa9, 0xa9, 0xa9).CGColor;
        _favButton.layer.borderWidth = 0.2f;
    }else {
        [_favButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _favButton.backgroundColor = RGBCOLOR(32, 192, 0);
        _favButton.layer.borderWidth = 0.0f;
        [_favButton setTitle:ASLocalizedString(@"XTPersonDetailViewController_Attention")forState:UIControlStateNormal];
    }
    _favButton.hidden = ![self.person.canUnsubscribe isEqualToString:@"1"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPerson:(PersonDataModel *)person
{
    if (_person != person) {
        _person = person;
    }
    
    //    self.smsButton.enabled = person.canSms;
}

#pragma mark - get
/*
 - (UIButton *)smsButton
 {
 if (_smsButton == nil) {
 _smsButton = [UIButton buttonWithType:UIButtonTypeCustom];
 [_smsButton setFrame:CGRectMake(0.0, 0.0, 130.0, 43.0)];
 [_smsButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
 [_smsButton setTitle:ASLocalizedString(@"XTPersonDetailViewController_Send_Msg")forState:UIControlStateNormal];
 [_smsButton setTitleColor:BOSCOLORWITHRGBA(0x7A7A7A, 1.0) forState:UIControlStateNormal];
 [_smsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
 [_smsButton setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0xF0F0F0, 1.0)] forState:UIControlStateNormal];
 [_smsButton setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0x7A7A7A, 1.0)] forState:UIControlStateHighlighted];
 [_smsButton addTarget:self action:@selector(smsAction) forControlEvents:UIControlEventTouchUpInside];
 _smsButton.layer.borderColor = BOSCOLORWITHRGBA(0x7A7A7A, 1.0).CGColor;
 _smsButton.layer.borderWidth = 1.0;
 _smsButton.enabled = self.person.canSms;
 }
 return _smsButton;
 }
 
 - (UIButton *)xtButton
 {
 if (_xtButton == nil) {
 _xtButton = [UIButton buttonWithType:UIButtonTypeCustom];
 [_xtButton setFrame:CGRectMake(0.0, 0.0, 130.0, 43.0)];
 [_xtButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
 [_xtButton setTitle:@"" forState:UIControlStateNormal];
 [_xtButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
 [_xtButton setTitleColor:BOSCOLORWITHRGBA(0xD3E4F0, 1.0) forState:UIControlStateHighlighted];
 [_xtButton setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0x00AAF0, 1.0)] forState:UIControlStateNormal];
 [_xtButton setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0x0088C0, 1.0)] forState:UIControlStateHighlighted];
 [_xtButton addTarget:self action:@selector(xtAction) forControlEvents:UIControlEventTouchUpInside];
 }
 return _xtButton;
 }
 
 - (NSArray *)buttons
 {
 if (_buttons == nil) {
 _buttons = [[NSArray alloc] initWithObjects:self.smsButton, self.xtButton, nil];
 }
 return _buttons;
 }
 */
- (MBProgressHUD *)hud
{
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    return _hud;
}

- (BOOL)isCurrentUser:(PersonDataModel *)person
{
    return [[BOSConfig sharedConfig].user.userId isEqualToString:person.personId];
}

#pragma mark - btn
- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonTapped:(UIButton *)btn
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:ASLocalizedString(@"Global_Cancel")destructiveButtonTitle:nil
                                                    otherButtonTitles:ASLocalizedString(@"XTPersonDetailViewController_Send_Tip"),ASLocalizedString(@"XTPersonDetailViewController_Save"), nil];
    actionSheet.tag = RIGHT_NAVIGATION_ITEM_ACTION_SHEET_TAG;
    [actionSheet setButtonAtIndex:0 toEnabled:(self.person.wbUserId.length > 0 && ![self isCurrentUser:self.person])];
    [actionSheet showInView:self.view];
}

-(void)smsAction
{
    NSMutableArray *phones = [NSMutableArray array];
    for (ContactDataModel *contactDM in _person.contact) {
        if (contactDM.ctype == ContactCellPhone) {
            [phones addObject:contactDM.cvalue];
        }
    }
    
    if ([phones count] == 1) {
        [XTSMSHandle sharedSMSHandle].controller = self;
        [[XTSMSHandle sharedSMSHandle] smsWithPhoneNumbel:[phones objectAtIndex:0]];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ASLocalizedString(@"XTPersonDetailViewController_Send_Msg")delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *phone in phones) {
        [actionSheet addButtonWithTitle:phone];
    }
    [actionSheet addButtonWithTitle:ASLocalizedString(@"Global_Cancel")];
    [actionSheet setCancelButtonIndex:[phones count]];
    [actionSheet showInView:self.tableView];
}

- (void)qrscanDetail:(id)sender
{
    //    XTQscanDetailViewController*qrscan = [[XTQscanDetailViewController alloc] initWithperson:self.person action:nil];
    //    [self.navigationController pushViewController:qrscan animated:YES];
}

- (void)xtAction
{
    [KDEventAnalysis event:event_contact_info_sendmsg];
    if (self.person) {
        XTChatViewController *chat = [[XTChatViewController alloc] initWithParticipant:self.person];
        [self.navigationController pushViewController:chat animated:YES];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTPersonDetailViewController_Fail")message:ASLocalizedString(@"XTPersonDetailViewController_GetPersonInfo_Fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark -- Phone
-(void)cellPhoneClick:(NSString *)phone
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:phone
                                                             delegate:self
                                                    cancelButtonTitle:ASLocalizedString(@"Global_Cancel")destructiveButtonTitle:nil
                                                    otherButtonTitles:ASLocalizedString(@"XTPersonDetailViewController_Call"),ASLocalizedString(@"XTPersonDetailViewController_SendMsg"), nil];
    actionSheet.tag = KD_PERSONDETAIL_CELLPHONE_TAG;
    [actionSheet showInView:self.view];
}



- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
     if(actionSheet.tag == KD_PERSONDETAIL_VIEWERROR_TAG){
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == RIGHT_NAVIGATION_ITEM_ACTION_SHEET_TAG) {
//        if(buttonIndex == 0) {
//            //关注或取消关注
        //            //add
//        [KDEventAnalysis event:event_personal_add_tofollow];
//        [KDEventAnalysis eventCountly:event_personal_add_tofollow];
//            if(self.isFollowing) {
//                [self destoryFriendship];
//            }else {
//                [self createFriendship];
//            }
//        }
//        else
        if(buttonIndex == 0) {
            //发送名片
            //add
            [KDEventAnalysis event: event_personal_send_card];
            [KDEventAnalysis eventCountly: event_personal_send_card];
            NSMutableString *content = [NSMutableString stringWithFormat:@"%@\n", self.person.personName];
            
            for(ContactDataModel *cdm in self.person.contact) {
                [content appendString:[NSString stringWithFormat:@"%@ %@", [cdm formatedTextName], cdm.cvalue]];
            }
            
            [XTSMSHandle sharedSMSHandle].controller = self;
            [[XTSMSHandle sharedSMSHandle] smsWithPhoneNumbel:nil content:content];
        }
        else if(buttonIndex == 1) {
            //保存到本地通讯录
            
            //add
            [KDEventAnalysis event: event_personal_save_local];
            //add
            [KDEventAnalysis eventCountly: event_personal_save_local];
            KDABPerson *person = [[KDABPerson alloc] init];
            person.pId = self.person.personId;
            person.name = self.person.personName;
            person.jobTitle = self.person.jobTitle;
            person.department = self.person.department;
            NSMutableArray *mobiles = [NSMutableArray array];
            NSMutableArray *emails = [NSMutableArray array];
            NSMutableArray *others = [NSMutableArray array];
            for(ContactDataModel *contact in self.person.contact)
            {
                if(contact.ctype == ContactEmail)
                    [emails addObject:contact.cvalue];
                
                if(contact.ctype == ContactCellPhone || contact.ctype == ContactHomePhone)
                {
                    if([contact.cvalue isEqualToString:self.person.defaultPhone])
                       [mobiles insertObject:contact.cvalue atIndex:0];
                    else
                        [mobiles addObject:contact.cvalue];
                }
                
                if(contact.ctype > ContactEmail)
                   [others addObject:contact.cvalue];
            }
            
            person.mobiles = mobiles;
            person.emails = emails;
            person.others = others;
            
            person.profileImageURL = self.person.photoUrl;
            //预防KDABPersonActionHelper被释放
            self.personHelper = [[KDABPersonActionHelper alloc] initWithViewController:self];
            self.personHelper.pickedPerson = person;
            [self.personHelper addToLocalAddressBookStore];
        }
        
    }else if(actionSheet.tag == KD_PERSONDETAIL_CELLPHONE_TAG){
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:ASLocalizedString(@"XTPersonDetailViewController_Call")]) {
            [[XTTELHandle sharedTELHandle] telWithPhoneNumbel:actionSheet.title];
        }
        else if ([title isEqualToString:ASLocalizedString(@"XTPersonDetailViewController_SendMsg")]) {
            [XTSMSHandle sharedSMSHandle].controller = self;
           [[XTSMSHandle sharedSMSHandle] smsWithPhoneNumbel:actionSheet.title];
        }
    }else if(actionSheet.tag == KD_PERSONDETAIL_BOTTOM_PHONE_TAG){
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
            [[XTTELHandle sharedTELHandle] telWithPhoneNumbel:title];
        }
        
    }else {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            NSString *phone = [actionSheet buttonTitleAtIndex:buttonIndex];
            [XTSMSHandle sharedSMSHandle].controller = self;
            [[XTSMSHandle sharedSMSHandle] smsWithPhoneNumbel:phone];
        }
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}

- (void)updateWaterMark {
    if ([[BOSSetting sharedSetting] openWaterMark:WaterMarkTypeContact]) {
            CGRect frame = CGRectMake(0, CGRectGetHeight(self.headerView.frame), self.tableView.contentSize.width, self.tableView.contentSize.height - CGRectGetHeight(self.headerView.frame) - 38);
            [KDWaterMarkAddHelper coverOnView:self.tableView withFrame:frame];
        }
    else {
            [KDWaterMarkAddHelper removeWaterMarkFromView:self.tableView];
    }
}


#pragma mark - person info

- (void)personInfo
{
    if (self.person.personId) {
        if (self.personInfoClient == nil) {
            self.personInfoClient = [[ContactClient alloc] initWithTarget:self action:@selector(personInfoDidReceived:result:)];
        }
        [self.personInfoClient getPersonInfoWithPersonID:self.person.personId type:nil];
        
    }
}

- (void)personInfoDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success) {
        PersonDataModel *person = [[PersonDataModel alloc] initWithDictionary:result.data];
        if (person.menu != nil && [person.menu isKindOfClass:[NSArray class]]) {
            person.menu = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:person.menu options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        }
        self.person = person;
        self.WBUserId = self.person.wbUserId;
        if(!self.ispublic)
        {
            [self addReplacementNavigationBarButton];
        }
        [self loadUser];
        [self checkFollow];
        self.headerView.person = person;

        self.person.parttimejob = person.parttimejob;
        
        //根据partimejob.jobType进行排序，1为兼职，0为主职
        ParttimejobDataModel *mainJob = nil;
        NSMutableArray *partTimeJob = [[NSMutableArray alloc]init];
        for (ParttimejobDataModel *partTime in self.person.parttimejob)
        {
            if (partTime.jobType == 0)
            {
                mainJob = partTime;
            }
            else
            {
                [partTimeJob addObject:partTime];
            }
        }
        if (mainJob != nil) {
            [partTimeJob insertObject:mainJob atIndex:0];
        }
        
        [self.tableView reloadData];
        [self updateFootBar];
        self.footerBar.hidden = [self isCurrentUser:self.person] || !self.person.isVisible;
        [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonContacts:person];
        PersonSimpleDataModel *personSimple = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:person.personId];
        personSimple.parttimejob = self.person.parttimejob;
        //插入职位表
        [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonJob:personSimple];

    }else if([result.error isEqualToString:@"通讯录访问次数较多，请核实是否本人行为"]){
        //A.wang 通讯录访问限制
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTPersonDetailViewController_Fail")message:@"通讯录访问次数较多，请核实是否本人行为" delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        alert.tag = KD_PERSONDETAIL_VIEWERROR_TAG;
        [alert show];
        return;
        
    }
    
    else
    {
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTPersonDetailViewController_Fail")message:ASLocalizedString(@"XTPersonDetailViewController_GetInfo_Fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        //        [alert show];
    }
      [self updateWaterMark];
}

-(UIView *)orgLeaderView
{
    if(_orgLeaderView == nil)
    {
        _orgLeaderView = [[UIView alloc] init];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor kdTextColor2];
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        titleLabel.text = @"部门负责人";
        [_orgLeaderView addSubview:titleLabel];
        
        __weak __typeof(_orgLeaderView) weakView = _orgLeaderView;
        [titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakView.mas_left).offset(15);
            make.top.equalTo(weakView.mas_top).offset(20);
            make.width.mas_equalTo(80);
        }];
        
        if(self.person.orgLeaders.count == 1)
        {
            XTPersonHeaderView *headerView = [[XTPersonHeaderView alloc] init];
            headerView.person = self.person.orgLeaders.firstObject;
            headerView.personNameLabel.hidden = YES;
            headerView.delegate = self;
            [_orgLeaderView addSubview:headerView];
            
            [headerView makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(titleLabel.mas_right).offset(30);
                make.top.equalTo(weakView.mas_top).offset(5);
                make.width.mas_equalTo(44);
                make.height.mas_equalTo(44);
            }];
            
            UILabel *personNameLabel = [[UILabel alloc] init];
            personNameLabel.backgroundColor = [UIColor clearColor];
            personNameLabel.textColor = FC1;
            personNameLabel.font = [UIFont systemFontOfSize:14.0f];
            personNameLabel.text = headerView.person.personName;
            [_orgLeaderView addSubview:personNameLabel];
            
            [personNameLabel makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(headerView.mas_right).offset(10);
                make.centerY.equalTo(headerView.mas_centerY).offset(0);
                make.width.mas_equalTo(80);
                make.height.mas_equalTo(20);
            }];
        }
        else
        {
            UIView *lastView = titleLabel;
            UIView *lastRowView = nil;
            for(NSUInteger i = 0,count = self.person.orgLeaders.count;i<(self.isOrgLeaderViewExpand?count:3) && i<count ;i++)
            {
                PersonSimpleDataModel *person = self.person.orgLeaders[i];
                XTPersonHeaderView *headerView = [[XTPersonHeaderView alloc] init];
                headerView.person = person;
                headerView.delegate = self;
                [_orgLeaderView addSubview:headerView];
                
                [headerView makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(lastView.mas_right).offset(20);
                    
                    if(lastRowView)
                        make.top.equalTo(lastRowView.mas_bottom).offset(20);
                    else
                        make.top.equalTo(weakView.mas_top).offset(10);
                        
                    make.width.mas_equalTo(48);
                    make.height.mas_equalTo(68);
                }];
                
                if((i+1)%3 == 0)
                {
                    lastView = titleLabel;
                    lastRowView = headerView;
                }
                else
                    lastView = headerView;
            }
            
            if(self.person.orgLeaders.count > 3)
            {
                UIButton *orgLeaderExpandBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [orgLeaderExpandBtn setImage:[UIImage imageNamed:@"person_detail_fold"] forState:UIControlStateNormal];
                [orgLeaderExpandBtn setImage:[UIImage imageNamed:@"person_detail_unfold"] forState:UIControlStateSelected];
                [orgLeaderExpandBtn addTarget:self action:@selector(orgLeaderExpandClick:) forControlEvents:UIControlEventTouchUpInside];
                orgLeaderExpandBtn.selected = self.isOrgLeaderViewExpand;
                [_orgLeaderView addSubview:orgLeaderExpandBtn];
                
                [orgLeaderExpandBtn makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(weakView.mas_right).offset(-5);
                    make.centerY.equalTo(weakView.mas_centerY).offset(0);
                    make.width.mas_equalTo(30);
                    make.height.mas_equalTo(30);
                }];
            }
        }
    }
    return _orgLeaderView;
}

-(void)orgLeaderExpandClick:(UIButton *)sender
{
    self.isOrgLeaderViewExpand = !self.isOrgLeaderViewExpand;
    [self.orgLeaderView removeFromSuperview];
    self.orgLeaderView = nil;
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:([self.tableView numberOfSections]-1)] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];
}

-(void)personHeaderClicked:(XTPersonHeaderView *)headerView person:(PersonSimpleDataModel *)person
{
    XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc]initWithSimplePerson:person with:NO];// autorelease];
    [self.navigationController pushViewController:personDetail animated:YES];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    return _ispublic ? 1 : 2;
    NSInteger jobCount = 0;
    if ([self.person.parttimejob count] > 0) {
        jobCount = 1;
    }
    NSInteger num = 1 + jobCount + [self contactSection];
    if(self.person.orgLeaders.count > 0)
        num++;
    return _ispublic ? 1:num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_ispublic)
    {
        return 1;
    }
    else
    {
        //判断是否为联系资料
        if (section != [self contactSection])// [self.person.parttimejob count])
        {
            //orgleader
            if (self.person.orgLeaders.count > 0 && section == ([self.tableView numberOfSections]-1))
            {
                return 1;
            }
            
            __block NSInteger count = 0;
            if ([self.person.parttimejob count] > 0)
            {
                [self.person.parttimejob enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *  stop) {
                    ParttimejobDataModel *partTimeJobModel = obj;
                    count += partTimeJobModel.totalSection;
                }];
            
            }
            if (count <= 3 ) {
                return count;
            }else
            {
                if (self.isFold) {
                    return 4;
                }
                _totalRow =count ;
                return count + 1;
            }
            
        }
        else
            return [self.person.contact count];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth, 8)];
    view.backgroundColor = [UIColor kdBackgroundColor1];
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //orgleader
    if (self.person.orgLeaders.count > 0 && indexPath.section == ([self.tableView numberOfSections]-1))
    {
        if(self.person.orgLeaders.count == 1)
            return 64;
        else
        {
            NSUInteger row = self.person.orgLeaders.count/3+(self.person.orgLeaders.count%3==0?0:1);
            return (self.isOrgLeaderViewExpand?(row*88):88);
        }
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_ispublic) {
        static NSString *CellIdentifier1 = @"CellIdentifier";
        
        KDPersonDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            cell = [[KDPersonDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
            
            cell.contentEdgeInsets = UIEdgeInsetsMake(0, 7.5, 0, 7.5);
            cell.delegate = self;
            cell.backgroundColor = MESSAGE_CT_COLOR;
            
            UIView *selectBgView = [[UIView alloc] initWithFrame:CGRectZero];
            selectBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            selectBgView.backgroundColor = BOSCOLORWITHRGBA(0xdddddd, 1.0f);
            cell.selectedBackgroundView = selectBgView;
            
            cell.accessoryImageView.hidden = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            cell.nameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            cell.nameLabel.textColor = [UIColor blackColor];
        }
        
        ContactDataModel *contact = [[ContactDataModel alloc] init];
        contact.ctext = ASLocalizedString(@"XTPersonDetailViewController_Msg");
        contact.cvalue = nil;
        contact.ctype = ContactOther;
        
        cell.isBottom = YES;
        
        cell.contact = contact;
        
        return cell;
    }
    else
    {
        if (self.person.orgLeaders.count > 0 && indexPath.section == ([self.tableView numberOfSections]-1))
        {
            static NSString * cellIdentifierOrg = @"CellIdentifierOrg";
            
            KDTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifierOrg];
            if(!cell) {
                cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierOrg];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
//            cell.delegate = self;
            cell.backgroundColor = MESSAGE_CT_COLOR;

            [self.orgLeaderView removeFromSuperview];
            [cell.contentView addSubview:self.orgLeaderView];
            [self.orgLeaderView makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(cell.contentView);
            }];
            return cell;
        }
        
        
        static NSString * cellIdentifier2 = @"CellIdentifier2";
        
        KDPersonDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_%ld_%ld",cellIdentifier2,indexPath.row,indexPath.section]];
        if(!cell) {
            cell = [[KDPersonDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%@_%ld_%ld",cellIdentifier2,indexPath.row,indexPath.section]];
             }
            cell.contentEdgeInsets = UIEdgeInsetsMake(0, 7.5, 0, 7.5);
            cell.delegate = self;
            cell.backgroundColor = MESSAGE_CT_COLOR;
            
            UIView *selectBgView = [[UIView alloc] initWithFrame:CGRectZero];
            selectBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            selectBgView.backgroundColor = RGBCOLOR(240, 241, 241);
            cell.selectedBackgroundView = selectBgView;
       

//        cell.isBottom = (indexPath.section == 1) && (indexPath.row == self.person.contact.count + 1);
        if (cell.dataIndex != 1000) {
            _dataIndex = cell.dataIndex;
        }
        ContactDataModel *contact = nil;
        ParttimejobDataModel *partTimeJobModel = nil;
        if ([self.person.parttimejob count] >= 1 && indexPath.section != [self contactSection] )//count)
        {
            NSInteger lastIndex = 0;
            for (NSInteger i = 0; i< _dataIndex; i++) {
                ParttimejobDataModel *partTimeJobModel = [self.person.parttimejob objectAtIndex:i];;
                lastIndex += partTimeJobModel.totalSection;
            }
            cell.pressImageView.hidden = YES;
            partTimeJobModel = [self.person.parttimejob objectAtIndex:_dataIndex];
            cell.dataIndex = _dataIndex;
            NSInteger rowIndex = indexPath.row - lastIndex ;
            if (partTimeJobModel.totalSection == 3) {
                switch (rowIndex) {
                    case 0:
                        contact = [[ContactDataModel alloc] init];
                        contact.ctext = ASLocalizedString(@"XTPersonDetailViewController_Organtion");
                        contact.cvalue = partTimeJobModel.eName;
                        contact.ctype = ContactOther;
                        break;
                    case 1:
                        contact = [[ContactDataModel alloc] init];
                        contact.ctext = ASLocalizedString(@"XTPersonDetailViewController_Department");
                        contact.cvalue = partTimeJobModel.department;
                        contact.ctype = ContactOther;
                        cell.showOrganization = YES;
                        break;
                    case 2:
                        contact = [[ContactDataModel alloc] init];
                        contact.ctext = ASLocalizedString(@"XTPersonDetailViewController_Position");
                        contact.cvalue = partTimeJobModel.jobTitle;
                        contact.ctype = ContactOther;
                        if (_dataIndex < [self.person.parttimejob count] - 1) {
                             _dataIndex ++ ;
                        }
                        break;
                    default:
                        break;
                }

            }else
            {
                switch (rowIndex) {
                    case 0:
                        contact = [[ContactDataModel alloc] init];
                        contact.ctext = ASLocalizedString(@"XTPersonDetailViewController_Department");
                        contact.cvalue = partTimeJobModel.department;
                        contact.ctype = ContactOther;
                        cell.showOrganization = YES;
                        break;
                    case 1:
                        contact = [[ContactDataModel alloc] init];
                        contact.ctext = ASLocalizedString(@"XTPersonDetailViewController_Position");
                        contact.cvalue = partTimeJobModel.jobTitle;
                        contact.ctype = ContactOther;
                        if (_dataIndex < [self.person.parttimejob count] - 1) {
                            _dataIndex ++ ;
                        }
                        break;
                    default:
                        break;
                }

            }
            if (indexPath.row >= 3) {
                if ((self.isFold  && indexPath.row == 3) || (!self.isFold && indexPath.row == _totalRow )) {
                     cell.pressImageView.hidden = NO;
                    contact = [[ContactDataModel alloc] init];
                    contact.ctext = nil;
                    contact.cvalue = nil;
                    contact.ctype = ContactOther;
                    if (self.isFold) {
                        cell.pressImageView.image = [UIImage imageNamed:@"person_detail_fold"];
                    }
                    else if (indexPath.row != 0) {
                        cell.pressImageView.image = [UIImage imageNamed:@"person_detail_unfold"];
                    }
                    cell.contact = contact;
                    cell.accessoryImageView.hidden = YES;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                }
            }
        }
        else
        {
            contact = [self.person.contact objectAtIndex:indexPath.row];
        }
        // ＝count则为通讯录部分
        
        if(indexPath.section != [self contactSection] && cell.showOrganization) {
            cell.accessoryImageView.hidden = ![self.person isInCompany] || !self.person.isVisible;
            cell.selectionStyle = [self.person isInCompany] ? UITableViewCellSelectionStyleGray : UITableViewCellSelectionStyleNone;
            if (partTimeJobModel.department.length == 0) {
                cell.accessoryImageView.hidden = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }else {
            if(contact.ctype == ContactCellPhone || contact.ctype == ContactHomePhone || contact.ctype == ContactEmail){
                cell.accessoryImageView.hidden = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }else{
                cell.accessoryImageView.hidden = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        cell.contact = contact;
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = MESSAGE_CT_COLOR;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ParttimejobDataModel *partTimeJobModel = nil;
    if ([self.person.parttimejob count] > 0 && indexPath.section != [self contactSection]){
        
        if (self.person.orgLeaders.count > 0 && indexPath.section == ([self.tableView numberOfSections]-1))
            return;
        
        if (indexPath.row >= 3) {
            //折叠状态，第四行是折叠行 or //展开状态，最后一行是折叠行
            if ((self.isFold && indexPath.row == 3) || (!self.isFold && indexPath.row == _totalRow)) {
                self.isFold = !self.isFold;
                _dataIndex = 0;
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [self.headerView layoutHeaderViewForScrollViewOffset:self.tableView.contentOffset];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self updateWaterMark];
                });
                return;
            }
        }
//        if(self.person.isVisible)
//            partTimeJobModel = [self.person.parttimejob objectAtIndex:indexPath.section-1];
//        else
//            partTimeJobModel = [self.person.parttimejob objectAtIndex:indexPath.section];
        
        KDPersonDetailCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        partTimeJobModel = [self.person.parttimejob objectAtIndex:cell.dataIndex];
        if(cell.showOrganization) {
//            if(_ispublic) {
//                XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:self.person];
//                chatViewController.isHistory = YES;
//                [self.navigationController pushViewController:chatViewController animated:YES];
//            }else
            {
                if ([self.person isInCompany]) {
                    [KDEventAnalysis event:event_contact_info_department];
                    if(self.person.isVisible)
                    {
                        if (partTimeJobModel.department.length == 0) {
                            return;
                        }
                        XTOrganizationViewController *ovc = [[XTOrganizationViewController alloc] initWithOrgId:partTimeJobModel.orgId isOnlySingleOrganization:YES];
                        ovc.partnerType = partTimeJobModel.partnerType;
                        [self.navigationController pushViewController:ovc animated:YES];
                    }
                }
            }
        }

    }
    else
    {
        if(_ispublic) {
            XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:self.person];
            chatViewController.isHistory = YES;
            [self.navigationController pushViewController:chatViewController animated:YES];
        }else{
            ContactDataModel *model = [self.person.contact objectAtIndex:indexPath.row];
            if (model.ctype == ContactCellPhone) {
                NSLog(@"123");
                [self cellPhoneClick:model.cvalue];
            }else if(model.ctype == ContactHomePhone){
                [[XTTELHandle sharedTELHandle] telWithPhoneNumbel:model.cvalue];
            }else if(model.ctype == ContactEmail){
                [XTMAILHandle sharedMAILHandle].controller = self;
                [[XTMAILHandle sharedMAILHandle] mailWithEmailAddress:model.cvalue];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != [self contactSection])
    {
        return YES;
    }
    else
    {
        return indexPath.row < [self.person.contact count]? YES : NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)){
        return YES;
    }
    else if (action == @selector(delete:)) {
        return NO;
    }
    else if(action == @selector(cut:)){
        return NO;
    }
    else if(action == @selector(paste:)){
        return NO;
    }
    else if(action == @selector(select:)){
        return NO;
    }
    else if(action == @selector(selectAll:)){
        return NO;
    }
    else
    {
        return [super canPerformAction:action withSender:sender];
    }
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    // if ((indexPath.section == 1) || indexPath.row < [self.person.contact count] + 2) {
    NSString *stringToCopy = nil;
    if (indexPath.section != [self contactSection]) {
        ParttimejobDataModel *parttime = self.person.parttimejob[indexPath.section-1];
        if(indexPath.row == 0) {
            if (![parttime.eName isEqualToString:@""]&& parttime.eName.length > 0)
                stringToCopy = parttime.eName;
            else
                stringToCopy = parttime.department;
        }else if(indexPath.row == 1) {
            if (![parttime.eName isEqualToString:@""]&& parttime.eName.length > 0)
                stringToCopy = parttime.department;
            else
                stringToCopy = parttime.jobTitle;
        }else if(indexPath.row == 2) {
            stringToCopy = parttime.jobTitle;
        }
    }
    else {
        ContactDataModel *contact = [self.person.contact objectAtIndex:indexPath.row];
        stringToCopy = contact.cvalue;
    }
    
    if (stringToCopy && action == @selector(copy:)) {
        [UIPasteboard generalPasteboard].string = stringToCopy;
        
    }
    //}
}

#pragma mark - XTPersonDetailHeaderViewDelegate
- (void)personDetailHeaderViewFavoritedButtonPressed:(XTPersonDetailHeaderView *)headerView
{
    if (self.person.personId.length == 0) {
        return;
    }
    
    [KDEventAnalysis event:event_contact_info_favorite];
    
    [self.person toggleFavor];
    [headerView setPerson:self.person];
    
    if (self.favClient == nil) {
        self.favClient = [[ContactClient alloc] initWithTarget:self action:@selector(favDidReceived:result:)];
    }
    
    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    [self.favClient toFavorWithID:headerView.person.personId flag:[headerView.person hasFavor] ? 0 : 1];
}

-(void)personDetailHeaderViewAttentionButtonPressed:(XTPersonDetailHeaderView *)headerView
{
    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.hud show:YES];
    
    if(self.isFollowing) {
        [self destoryFriendship];
    }else {
        [self createFriendship];
    }
}

//- (void)personDetailHeaderViewFollowButtonPressed:(XTPersonDetailHeaderView *)headerView
//{
//    if([self.headerView isFollowing]) {
//        [self destoryFriendship];
//    }else {
//        [self createFriendship];
//    }
//}

- (void)personDetailHeaderViewSendCarteButtonPressed:(XTPersonDetailHeaderView *)headerView
{
    NSMutableString *content = [NSMutableString stringWithFormat:@"%@\n", self.person.personName];
    
    for(ContactDataModel *cdm in self.person.contact) {
        [content appendString:[NSString stringWithFormat:@"%@ %@", [cdm formatedTextName], cdm.cvalue]];
    }
    
    [XTSMSHandle sharedSMSHandle].controller = self;
    [[XTSMSHandle sharedSMSHandle] smsWithPhoneNumbel:nil content:content];
}

- (void)personDetailHeaderViewSendMessageButtonPressed:(XTPersonDetailHeaderView *)headerView
{
    [self xtAction];
}

#pragma mark - KDPersonDetailCellDelegate Methods
- (void)personDetailCellEmailButtonPressed:(KDPersonDetailCell *)cell
{
    [KDEventAnalysis event:event_contact_info_email];
    [XTMAILHandle sharedMAILHandle].controller = self;
    [[XTMAILHandle sharedMAILHandle] mailWithEmailAddress:cell.contact.cvalue];
}

- (void)personDetailCellMessageButtonPressed:(KDPersonDetailCell *)cell
{
    [KDEventAnalysis event:event_contact_info_message];
    [XTSMSHandle sharedSMSHandle].controller = self;
    [[XTSMSHandle sharedSMSHandle] smsWithPhoneNumbel:cell.contact.cvalue];
}

- (void)personDetailCellPhoneButtonPressed:(KDPersonDetailCell *)cell
{
    [KDEventAnalysis event:event_contact_info_phone];
    [[XTTELHandle sharedTELHandle] telWithPhoneNumbel:cell.contact.cvalue];
}

#pragma mark  -- KDPersonFooterBarDelegate Methods
-(void)personFooterViewMsgButtonPressed:(UIView *)view{
    //add
    [KDEventAnalysis eventCountly:event_personal_send_message];
    [KDEventAnalysis event:event_personal_send_message];
    [self xtAction];
}

-(void)personFooterViewPhoneButtonPressed:(UIView *)view{
    //add
    [KDEventAnalysis eventCountly: event_personal_call_phone];
    [KDEventAnalysis event: event_personal_call_phone];
    NSMutableArray *mobiles = [NSMutableArray array];
    for(ContactDataModel *contact in self.person.contact)
    {
        if(contact.ctype == ContactCellPhone || contact.ctype == ContactHomePhone ||  contact.ctype == ContactAccount)
        {
            if ([contact.cvalue isContainLetter] || [contact.cvalue isContainChinese]) {
                continue;
            }
            
            if([contact.cvalue isEqualToString:self.person.defaultPhone])
                [mobiles insertObject:contact.cvalue atIndex:0];
            else
                [mobiles addObject:contact.cvalue];
        }
    }
    if([mobiles count] < 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"XTPersonDetailViewController_NoNum")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    __block UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ASLocalizedString(@"XTPersonDetailViewController_Call")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")destructiveButtonTitle:nil otherButtonTitles:nil];
    [mobiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [actionSheet addButtonWithTitle:obj];
    }];
    actionSheet.tag = KD_PERSONDETAIL_BOTTOM_PHONE_TAG;
    [actionSheet showInView:self.view];
    
}

- (void)favDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    BOOL exists = [[XTDataBaseDao sharedDatabaseDaoInstance] updatePersonStatus:self.person];
    NSString *prompt = [self.person hasFavor] ? ASLocalizedString(@"KDABActionTabBar_tips_1"): ASLocalizedString(@"KDABPersonDetailsViewController_tips_3");
    if (client.hasError || !result.success) {
        [self.person toggleFavor];
        [self.headerView setPerson:self.person];
//        if (!exists) {
//            [self.hud setLabelText:ASLocalizedString(@"XTPersonDetailViewController_Collect")];
//        }else{
        [self.hud setLabelText:[prompt stringByAppendingString:ASLocalizedString(@"XTPersonDetailViewController_Fail")]];
//        }
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    
    [self.hud setLabelText:[self.person hasFavor]?ASLocalizedString(@"KDABPersonDetailsViewController_fav_suc"):ASLocalizedString(@"KDABPersonDetailsViewController_unfav_suc")];
    [self.hud setMode:MBProgressHUDModeText];
    [self.hud hide:YES afterDelay:1.0];
}

- (void)personDetailHeaderViewDepartmentButtonPressed:(XTPersonDetailHeaderView *)headerView
{
    [[KDWeiboAppDelegate getAppDelegate].XT contactToOrganizationWithOrgId:headerView.person.orgId];
}

- (void)personDetailHeaderViewFriendsButtonPressed:(XTPersonDetailHeaderView *)headerView
{
    if(_user) {
        NetworkUserController *friends = [[NetworkUserController alloc] initWithNibName:nil bundle:nil];
        friends.isFollowee = YES;
        friends.owerUser = _user;
//        friends.navigationItem.title = ASLocalizedString(@"XTPersonDetailViewController_Attention");
        friends.subTitle = ASLocalizedString(@"XTPersonDetailViewController_Attention");
        [friends loadUserData];
        [self.navigationController pushViewController:friends animated:YES];
    }
}

- (void)personDetailHeaderViewFansButtonPressed:(XTPersonDetailHeaderView *)headerView
{
    if(_user) {
        NetworkUserController *fans = [[NetworkUserController alloc] initWithNibName:nil bundle:nil];
        fans.isFollowee = NO;
        fans.owerUser = _user;
//        fans.navigationItem.title = ASLocalizedString(@"XTPersonDetailViewController_Fun");
        fans.subTitle = ASLocalizedString(@"XTPersonDetailViewController_Fun");
        [fans loadUserData];
        [self.navigationController pushViewController:fans animated:YES];
    }
}

- (void)personDetailHeaderViewStatusButtonPressed:(XTPersonDetailHeaderView *)headerView
{
    if(_user) {
        BlogViewController *blog = [[BlogViewController alloc] initWithNibName:nil bundle:nil];
        blog.user = _user;
        blog.subTitle = ASLocalizedString(@"XTPersonDetailViewController_WB");
//        blog.navigationItem.title = ASLocalizedString(@"XTPersonDetailViewController_WB");
        [blog loadUserData];
        [self.navigationController pushViewController:blog animated:YES];
    }
}

#pragma mark - attention
-(void)addfav{
    if (self.person.personId.length == 0) {
        return;
    }
    
    if (self.attentionClient == nil) {
        self.attentionClient = [[AppsClient alloc] initWithTarget:self action:@selector(attentionDidReceived:result:)];
    }
    if (_isfav) {
        [KDEventAnalysis event:event_pubacc_favorite_off];
        [self.attentionClient attention:self.person.personId withdata:@"0"];
    }else
    {
        [KDEventAnalysis event:event_pubacc_favorite_on];
        [self.attentionClient attention:self.person.personId withdata:@"1"];
    }
    [self.hud setLabelText:ASLocalizedString(@"XTPersonalFilesController_Wait")];
    [self.hud show:YES];
}

-(void)backPopView
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)deleteGroupwithgroupId:(NSString*)groupId
{
    if ([[XTDataBaseDao sharedDatabaseDaoInstance] setPrivateGroupListToDeleteWithGroupId:groupId]) {
        [[XTDeleteService shareService] deleteGroupWithGroupId:groupId];
    }
}

- (void)attentionDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        [self.hud setLabelText:ASLocalizedString(@"XTPersonDetailViewController_Fail")];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    else if (result.success) {
        if (_isfav) {
            self.person.subscribe = @"0";
            if ([[XTDataBaseDao sharedDatabaseDaoInstance] updatePublicPersonSimpleSetsubscribe:self.person]) {
                _isfav = NO;
                
                NSString *groupId = [[XTDataBaseDao sharedDatabaseDaoInstance] queryGroupIdWithPublicPersonId:self.person.personId];
                [self deleteGroupwithgroupId:groupId];
                [self.hud setLabelText:ASLocalizedString(@"XTPersonDetailViewController_Attention_Cancel_Success")];
                
            }
            else {
                [self.hud setLabelText:ASLocalizedString(@"XTPersonDetailViewController_Attention_Cancel_Fail")];
            }
        }
        else {
            self.person.subscribe = @"1";
            if ([[XTDataBaseDao sharedDatabaseDaoInstance] updatePublicPersonSimpleSetsubscribe:self.person]) {
                _isfav = YES;
                [self.hud setLabelText:ASLocalizedString(@"XTPersonDetailViewController_Attention_Success")];
                
            }
            else {
                [self.hud setLabelText:ASLocalizedString(@"XTPersonDetailViewController_Attention_Fail")];
            }
        }
        [self updateFavButton];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadData" object:nil];
        [_tableView reloadData];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
    }
}

#pragma mark - KDWeibo network
- (void)loadUser
{
    
    if (KD_IS_BLANK_STR(self.WBUserId) && KD_IS_BLANK_STR(self.screenName)) {
        return;
    }
    
    if (didLoadWBUserInfo_) {
        return;
    }
    
    didLoadWBUserInfo_ = YES;
    
    __weak XTPersonDetailViewController *pvc = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results != nil) {
            KDUser *user = (KDUser *)results;
            pvc.user = user;
            if (KD_IS_BLANK_STR(pvc.WBUserId)) {
                pvc.WBUserId = user.userId;
                [pvc checkFollow];
            }
//            [pvc.headerView setFollowCount:user.friendsCount FansCount:user.followersCount StatusesCount:user.statusesCount];
            if (pvc.isFromWeibo) {  //如果从微博相关页面进入
                if (user.openId) { //如果有迅通id
                    self.openId = user.openId;
                    [pvc fetchPersonByOpenId];
                    
                }else {
                    //提示出错
                    // [KDErrorDisplayView showErrorMessage:ASLocalizedString(@"XTPersonDetailViewController_GetInfo_Fail")inView:pvc.view.window];
                }
            }
            
            // update current user
            [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                [userDAO saveUser:(KDUser *)results database:fmdb];
                
                return nil;
                
            } completionBlock:nil];
            
        } else {
            if (![response isCancelled]) {
                
            }
        }
    };
    
    NSString *actionPath = @"/users/:show";
    KDQuery *query = [KDQuery query];
    //[query setParameter:@"id" stringValue:self.WBUserId];
    if (!KD_IS_BLANK_STR(self.screenName)) {
        [query setParameter:@"screen_name" stringValue:self.screenName];
    }else if(!KD_IS_BLANK_STR(self.WBUserId)) {
        actionPath = @"/users/:showById";
        [query setProperty:self.WBUserId forKey:@"userId"];
    }
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)createFriendship {
    
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:self.person.wbUserId];
    
    __weak XTPersonDetailViewController *pvc = self;
//    pvc.headerView.followButton.enabled = NO;
//    [pvc.headerView setShowFollowActivityView:YES];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [pvc _handleFriendshipResponse:response withResults:results];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/friendships/:create" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)destoryFriendship {
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:self.person.wbUserId];
    
    __weak XTPersonDetailViewController *pvc = self;
//    pvc.headerView.followButton.enabled = NO;
//    [pvc.headerView setShowFollowActivityView:YES];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [pvc _handleFriendshipResponse:response withResults:results];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/friendships/:destroy" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)checkFollow {
    if (KD_IS_BLANK_STR(self.WBUserId)) {
        return;
    }
    if (didCheckFollow_) {
        return;
    }
    didCheckFollow_ = YES;
    NSString *currentUserId = [KDManagerContext globalManagerContext].userManager.currentUserId;
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"user_a" stringValue:currentUserId]
     setParameter:@"user_b" stringValue:self.WBUserId];
    
    __weak XTPersonDetailViewController *pvc = self;
//    pvc.headerView.followButton.enabled = NO;
//    [pvc.headerView setShowFollowActivityView:YES];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
//                [pvc.headerView setFollowing:[(NSNumber *)results boolValue]];
                pvc.isFollowing = [(NSNumber *)results boolValue];
            }
        } else {
            if (![response isCancelled]) {
                //                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                //                                              inView:pvc.view.window];
            }
        }
        
//        [pvc.headerView setShowFollowActivityView:NO];
//        pvc.headerView.followButton.enabled = YES;
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/friendships/:exists" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)_handleFriendshipResponse:(KDResponseWrapper *)response withResults:(id)results {
    if([response isValidResponse]) {
        if (results != nil) {
            [self.hud setLabelText:self.isFollowing ? ASLocalizedString(@"XTPersonDetailViewController_Attention_Cancel_Success"):ASLocalizedString(@"XTPersonDetailViewController_Attention_Success")];
            [self.hud setMode:MBProgressHUDModeText];
            [self.hud hide:YES afterDelay:1.0];
            
            KDUser *user = (KDUser *)results;
            
//            self.headerView.isFollowing = !self.headerView.isFollowing;
            self.isFollowing = !self.isFollowing;
            
            // update current user info into database
            [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                [userDAO saveUser:user database:fmdb];
                
                return nil;
                
            } completionBlock:nil];
        }
    } else {
        
        [self.hud setLabelText:self.isFollowing ? ASLocalizedString(@"XTPersonDetailViewController_Attention_Cancel_Fail"):ASLocalizedString(@"XTPersonDetailViewController_Attention_Fail")];
        [self.hud setMode:MBProgressHUDModeText];
        [self.hud hide:YES afterDelay:1.0];
        
        if (![response isCancelled]) {
            [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage] inView:self.view.window];
        }
    }
    
//    self.headerView.followButton.enabled = YES;
//    [self.headerView setShowFollowActivityView:NO];
}

- (UIImageView *)imageViewFilter
{
    if (!_imageViewFilter)
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectFullScreenWithoutNavigationBar];
        imageView.image = [UIImage imageNamed:@"user_img_newcollect"];
        _imageViewFilter = imageView;
        //[_imageViewFilter sizeToFit];
        [_imageViewFilter addSubview:self.buttonFilterConfirm];
        _imageViewFilter.userInteractionEnabled = YES;

    }
    return _imageViewFilter;
}

- (void)buttonFilterConfirmPressed
{
    self.imageViewFilter.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PERSON_DETAIL_FILTER_SHOWN"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIButton *)buttonFilterConfirm
{
    if (!_buttonFilterConfirm)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:ASLocalizedString(@"KDApplicationViewController_tips_i_know")forState:UIControlStateNormal];
        [button setBackgroundColor:BOSCOLORWITHRGBA(0x1A85FF,1.0)];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [button.titleLabel setTextColor:[UIColor whiteColor]];
        [button setFrame:CGRectMake(72, 240, 183, 44)];
        button.layer.cornerRadius = 5.0f;
        [button addTarget:self action:@selector(buttonFilterConfirmPressed) forControlEvents:UIControlEventTouchUpInside];
        _buttonFilterConfirm = button;
    }
    return _buttonFilterConfirm;
}


#pragma  mark -- view 
- (KDPersonHeaderBar *)headerBar {
    if (_headerBar == nil) {
        _headerBar = [[KDPersonHeaderBar alloc] initWithFrame:CGRectMake(.0, .0, CGRectGetWidth(self.view.bounds), 64.0) backBtnTitle:@" "];
        _headerBar.delegate = self;
    }
    return _headerBar;
}

- (KDPersonFooterBar *)footerBar {
    if (_footerBar == nil) {
        _footerBar = [[KDPersonFooterBar alloc] initWithFrame:CGRectMake(.0, CGRectGetHeight(self.view.bounds) - 44.0, CGRectGetWidth(self.view.bounds), 44.0)];
        _footerBar.delegate = self;
        [self updateFootBar];
    }
    return _footerBar;
}

-(void)updateFootBar
{
    if(self.person.gender == 2)
    {
        [_footerBar.msgButton setBackgroundImage:[UIImage imageWithColor:[UIColor kdGradientFemaleStartColor]] forState:UIControlStateNormal];
        [_footerBar.callButton setBackgroundImage:[UIImage imageWithColor:[UIColor kdGradientFemaleStartColor]] forState:UIControlStateNormal];
    }
    else
    {
        [_footerBar.msgButton setBackgroundImage:[UIImage imageWithColor:[UIColor kdGradientMaleStartColor]] forState:UIControlStateNormal];
        [_footerBar.callButton setBackgroundImage:[UIImage imageWithColor:[UIColor kdGradientMaleStartColor]] forState:UIControlStateNormal];
    }
}


#pragma mark - KDPersonHeaderBarDelegate -

- (void)personHeaderBarBackButtonPressed:(UIView *)view {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    __weak XTPersonDetailViewController *selfInBlock = self;
    [UIView animateWithDuration:.25 animations:^{
//        selfInBlock.headerBar.backgroundView.alpha = (scrollView.contentOffset.y > CGRectGetHeight(selfInBlock.headerView.bounds) - CGRectGetHeight(selfInBlock.headerBar.bounds) ? 1 : 0);
    } completion:^(BOOL finished) {
//        [[UIApplication sharedApplication] setStatusBarStyle:(selfInBlock.headerBar.backgroundView.alpha == 1) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent];
    }];
    
    [self.headerView layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
}

-(NSUInteger)contactSection
{
    if(self.person.isVisible)
        return 0;
    else
        return NSUIntegerMax;
}

@end
