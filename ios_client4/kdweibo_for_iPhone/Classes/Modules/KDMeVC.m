//
//  KDMeVC.m
//  kdweibo
//
//  Created by DarrenZheng on 14-10-10.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDMeVC.h"
#import "KDMeTableViewCell.h"
#import "KDUserManager.h"
#import "KDMeIconTableViewCell.h"
#import "KDSettingViewController.h"
#import "ContactConfig.h"
#import "XTChatViewController.h"
#import "LoginDataModel.h"
#import "ContactLoginDataModel.h"
#import "XTPubAcctUserChatListViewController.h"
#import "KDRecommendViewController.h"
#import "KDCreateTeamViewController.h"
#import "ProfileViewController2.h"
#import "BOSConfig.h"
#import "KDCompanyChoseViewController.h"
#import "KDDatabaseHelper.h"
#import "KDWeiboDAOManager.h"    


@interface KDMeVC () <UITableViewDataSource, UITableViewDelegate, XTCompanyDelegate>

@property (nonatomic, strong) UITableView *tableViewMain;
@property (nonatomic, strong) KDUser *user;
@property (nonatomic, strong) XTOpenSystemClient *client;
@property (nonatomic, strong) NSArray *arrayCompanyDataModels;

@property (nonatomic, assign) BOOL bAdmin; // 是否企业管理员


@end

@implementation KDMeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getCurrentUser];
    
    [self.view addSubview:self.tableViewMain];
    self.navigationItem.title = ASLocalizedString(@"KDMeVC_me");
    [self.view setBackgroundColor:MESSAGE_BG_COLOR];
    
    // test only 等接口
    self.bAdmin = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableViewMain reloadData];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}


- (UITableView *)tableViewMain
{
    if (!_tableViewMain)
    {
        _tableViewMain = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenFullWidth, MainHeight - NavigationBarHeight - TabBarHeight)
                                                     style:UITableViewStyleGrouped];
        _tableViewMain.dataSource = self;
        _tableViewMain.delegate = self;
    }
    return _tableViewMain;
}

- (KDUser *)user
{
    if (!_user)
    {
        KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
        _user = userManager.currentUser;
    }
    return _user;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.bAdmin ? 4 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int iNum = 0;
    
    if (self.bAdmin)
    {
        switch (section)
        {
            case 0:
                iNum = 2;
                break;
                
            case 1:
                iNum = 1;
                break;
                
            case 2:
                iNum = 1;
                break;
                
            case 3:
                iNum = 3;
                break;
                
                
            default:
                break;
        }
    }
    else
    {
        switch (section)
        {
            case 0:
                iNum = 2;
                break;
                
            case 1:
                iNum = 1;
                break;
                
            case 2:
                iNum = 3;
                break;
                
                
            default:
                break;
        }
    }
    
    return iNum;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"KDMeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        if ((indexPath.section == 0) && (indexPath.row == 0))
        {
            cell = [[KDMeIconTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:CellIdentifier];
            
        }
        else
        {
            cell = [[KDMeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:CellIdentifier];
        }
        cell.backgroundColor = [UIColor whiteColor];
        
        if ((indexPath.section == 0) && (indexPath.row == 1))
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
    }
    if ((indexPath.section == 0) && (indexPath.row == 0))
    {
        KDMeIconTableViewCell *meIconCell = (KDMeIconTableViewCell *)cell;
        [meIconCell.imageViewIcon setImageWithURL:[NSURL URLWithString:self.user.profileImageUrl]];
        meIconCell.labelTitle.text = self.user.username;
        meIconCell.labelSubTitle.text = self.user.companyName;
        
        meIconCell.bAdmin = self.bAdmin;
        
        
    }
    else
    {
        KDMeTableViewCell *meCell = (KDMeTableViewCell *)cell;
        
        void (^setupCell)(NSString *, NSString *) = ^(NSString *strImage, NSString *strTitle) {
            meCell.imageViewIcon.image = [UIImage imageNamed:strImage];
            meCell.labelTitle.text = strTitle;
        };
        
        if (self.bAdmin)
        {
            switch (indexPath.section)
            {
                case 0:
                {
                    if (indexPath.row == 1)
                    {
                        setupCell(@"me_img_qhgzq",ASLocalizedString(@"KDMeVC_change_com"));
                    }
                }
                    break;
                    
                case 1:
                {
                    if (indexPath.row == 0)
                    {
                        setupCell(@"me_img_assistance",ASLocalizedString(@"KDMeVC_admin_ass"));
                    }
                }
                    break;
                    
                case 2:
                {
                    if (indexPath.row == 0)
                    {
                        setupCell(@"me_img_create",ASLocalizedString(@"KDMeVC_create_com"));
                    }
                }
                    break;
                    
                case 3:
                {
                    if (indexPath.row == 0)
                    {
                        setupCell(@"me_img_feedback",ASLocalizedString(@"意见反馈"));
                    }
                    else if (indexPath.row == 1)
                    {
                        setupCell(@"me_img_setting",ASLocalizedString(@"KDLeftTeamMenuViewController_setting"));
                    }
                    else
                    {
                        setupCell(@"me_img_tuijian",ASLocalizedString(@"KDMeVC_recommand"));
                    }
                }
                    break;
                    
                    
                default:
                    break;
            }
            
        }
        else
        {
            switch (indexPath.section)
            {
                case 0:
                {
                    if (indexPath.row == 1)
                    {
                        setupCell(@"me_img_qhgzq",ASLocalizedString(@"KDMeVC_change_com"));
                    }
                }
                    break;
                    
                case 1:
                {
                    if (indexPath.row == 0)
                    {
                        setupCell(@"me_img_create",ASLocalizedString(@"KDMeVC_create_com"));
                    }
                }
                    break;
                    
                case 2:
                {
                    if (indexPath.row == 0)
                    {
                        setupCell(@"me_img_feedback",ASLocalizedString(@"意见反馈"));
                    }
                    else if (indexPath.row == 1)
                    {
                        setupCell(@"me_img_setting",ASLocalizedString(@"KDLeftTeamMenuViewController_setting"));
                    }
                    else
                    {
                        setupCell(@"me_img_tuijian",ASLocalizedString(@"KDMeVC_recommand"));
                    }
                }
                    break;
                    
                    
                default:
                    break;
            }
            
        }
        
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float fHeight;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            fHeight = 90;
        }
        else
        {
            fHeight = 45;
        }
    }
    else
    {
        fHeight = 45;
    }
    
    return fHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 15;
    else
        return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    void (^creatCampany)() = ^ {
        //创建新的工作圈
        KDCreateTeamViewController *createTeamVC = [[KDCreateTeamViewController alloc] initWithNibName:nil bundle:nil];
        createTeamVC.didSignIn = YES;
        createTeamVC.fromType = KDCreateTeamFromTypeDidLogin;
        [self.navigationController pushViewController:createTeamVC animated:YES];
    };
    
    void (^threeCondition)() = ^ {
        if (indexPath.row == 0)
        {
            // 意见反馈
            PubAccountDataModel *pubAccount = [[ContactConfig sharedConfig].publicAccountList.list firstObject];
            UIViewController *controller = nil;
            if (pubAccount.manager)
            {
                controller = [[XTPubAcctUserChatListViewController alloc] initWithPubAccount:pubAccount andPerson:nil];
            }
            else
            {
                controller = [[XTChatViewController alloc] initWithPubAccount:pubAccount];
            }
            controller.hidesBottomBarWhenPushed = YES;
            if (pubAccount.manager)
            {
                controller.navigationItem.title = pubAccount.name;
            }
            else
            {
                controller.navigationItem.title = ASLocalizedString(@"意见反馈");
            }
            
            [self.navigationController pushViewController:controller animated:YES];
        }
        else if (indexPath.row == 1)
        {
            //设置
            KDSettingViewController *settingVC= [[KDSettingViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:settingVC animated:YES];
        }
        else
        {
            //推荐
            KDRecommendViewController *recommmendVC = [[KDRecommendViewController alloc] init];
            [self.navigationController pushViewController:recommmendVC animated:YES];
        }
        
    };
    
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            //点击头像 -> 个人设置
            
            [KDEventAnalysis event:event_settings_personal_open attributes:@{label_settings_personal_open_source: label_settings_personal_open_source_sidebar}];
            ProfileViewController2 *profileVC = [[ProfileViewController2 alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:profileVC animated:YES];
            
            
            
        }
        else
        {
            //切换工作圈
            
            // elist接口
            if (!_client)
            {
                _client = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getElistReceived:result:)];
            }
            [_client elistWithToken:[BOSConfig sharedConfig].user.token];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
        }
    }
    
    if (self.bAdmin)
    {
        if (indexPath.section == 1)
        {
            // 管理员助手
        }
        
        if (indexPath.section == 2)
        {
            creatCampany();
        }
        
        if (indexPath.section == 3)
        {
            threeCondition();
        }
        
    }
    else
    {
        if (indexPath.section == 1)
        {
            creatCampany();
        }
        
        if (indexPath.section == 2)
        {
            threeCondition();
        }
    }
    
    
    
}

#pragma mark - elist callback -

- (void)getElistReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //netWorkFlags_.isGettingCommunity = 0;
    
    if (![result isKindOfClass:[BOSResultDataModel class]] || client.hasError)
    {
        return;
    }
    
    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    
    NSMutableArray *eList = [NSMutableArray array];
    NSArray *currentCommunity = communityManager.joinedCommpanies;
    
    for (NSDictionary * dict in result.data) {
        CompanyDataModel *model = [[CompanyDataModel alloc] initWithDictionary:dict] ;
        if (model.user.status == 1 || model.user.status == 3) {
            
            [eList addObject:model];
            
            for (CompanyDataModel *cm in currentCommunity) {
                
                if ([cm.eid isEqualToString:model.eid]) {
                    model.unreadCount = cm.unreadCount;
                    model.wbUnreadCount = cm.wbUnreadCount;
                    
                    break;
                }
            }
        }
    }
    
    //  workGroupInfoView_.groups = eList;
    
    //[self updateTitlViewTipAnimation];
    
    communityManager.joinedCommpanies = eList;
    [communityManager storeCompanies];
    [communityManager updateWithCompanies:eList currentDomain:[BOSSetting sharedSetting].cust3gNo];
    // self.workGroupInfoView.groups = eList;
    
    //--------------------------------------------------
    // CompanyDataModel -> XTOpenCompanyDataModel
    //--------------------------------------------------
    NSMutableArray *mArrayXTOpenCompanyDataModels = [NSMutableArray new];
    NSMutableArray *mArrayXTAuthstrCompanyDataModels = [NSMutableArray new];
    
    for (CompanyDataModel *cdm in eList)
    {
        XTOpenCompanyDataModel *xTCompanyModel = [XTOpenCompanyDataModel new];
        xTCompanyModel.companyId = cdm.eid;
        xTCompanyModel.companyName = cdm.name;
        
        if (cdm.user.status == 1)
        {
            [mArrayXTOpenCompanyDataModels addObject:xTCompanyModel];
        }
        else
        {
            [mArrayXTAuthstrCompanyDataModels addObject:xTCompanyModel];
        }
    }
    
    self.arrayCompanyDataModels = eList;
    
    XTOpenCompanyListDataModel *companyList = [[XTOpenCompanyListDataModel alloc]init];
    
    companyList.openId = [BOSConfig sharedConfig].user.openId;
    companyList.companys = [mArrayXTOpenCompanyDataModels copy];
    companyList.authstrCompanys = [mArrayXTAuthstrCompanyDataModels copy];
    
    if (companyList.companys.count > 0)
    {
        // 选择工作圈
        KDCompanyChoseViewController *ctr = [[KDCompanyChoseViewController alloc] init];
        ctr.delegate = self;
        ctr.dataModel = companyList;
        [self.navigationController pushViewController:ctr animated:YES];
    }
    
}


- (void)companyDidSelect:(id)viewController company:(XTOpenCompanyDataModel *)company
{
    CompanyDataModel *companyDataModel;
    for (CompanyDataModel *cdm in self.arrayCompanyDataModels)
    {
        if ([company.companyId isEqualToString:cdm.eid])
        {
            companyDataModel = cdm;
        }
    }
    KDWeiboAppDelegate *appDelegate = (KDWeiboAppDelegate *)[KDWeiboAppDelegate getAppDelegate];
    [appDelegate changeNetWork:companyDataModel finished:^(BOOL finished) {
    }];
}


- (void)getCurrentUser {
    
    KDUser *user = [[[KDManagerContext globalManagerContext] userManager] currentUser];
    
    if (!user) {
        __block KDUser *dbUser = nil;
        NSString *userId = [[[KDManagerContext globalManagerContext] userManager] currentUserId];
        [KDUser syncUserWithId:userId completionBlock:^(KDUser *user){
            dbUser = user;
        }];
        user = dbUser;
    }
    if (!user)
    {
        NSString *userId = [[[KDManagerContext globalManagerContext] userManager] currentUserId];
        [self fetchRemoteCurrentUser:userId];
    }
    else
    {
        self.user = user;
        
    }
}

- (void)fetchRemoteCurrentUser:(NSString *)userId
{
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:userId];
    
    __block KDMeVC *lcvc = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        lcvc.user = results;
        // update current user
        [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
            id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
            [userDAO saveUser:(KDUser *)results database:fmdb];
            
            return nil;
            
        } completionBlock:nil];
        
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/users/:show" query:query
                                 configBlock:nil completionBlock:completionBlock];
}



@end
