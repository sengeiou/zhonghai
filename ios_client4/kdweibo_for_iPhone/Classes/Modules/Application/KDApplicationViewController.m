//
//  KDApplicationViewController.m
//  kdweibo
//
//  Created by stone on 14-4-19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDApplicationViewController.h"
#import "UIView+Blur.h"
#import "AppsClient.h"
#import "KDWebViewController.h"
#import "XTQRScanViewController.h"
#import "XTChatViewController.h"
#import "XTQRLoginViewController.h"
#import "BOSSetting.h"
#import "BOSConfig.h"
#import "KDSignInViewController.h"

#import "AppsClient.h"
#import "KDAppListDataModel.h"
#import "KDAppDetailViewController.h"

#import "XTMyFilesViewController.h"


#import "KDApplicationQueryAppsHelper.h"
#import "BOSConfig.h"
#import "KDSignInManager.h"
#import "KDSignInViewController.h"
#import "AlgorithmHelper.h"
#import "KDPubAccDetailViewController.h"
#import "KDAppSerachViewController.h"

#import "AlgorithmHelper.h"
#import "UIViewController+DZCategory.h"

#import "KDTodoListViewController.h"
#import "KDSubscribeViewController.h"

#import "BuluoSDK.h"
#import "BuluoObject.h"
#import "KDAppCollectionView.h"
#import "KDAppCollectionViewCell.h"
#import "KDAppColectionHeaderView.h"
#import "SDWebImageManager.h"

#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR 1
#elif TARGET_OS_IPHONE
#define SIMULATOR 0
#endif

#define kQRScanName                 @"QRScan"
#define kFileTransName              @"FileTrans"
#define kFileTransPublicAccountID   @"XT-0060b6fb-b5e9-4764-a36d-e3be66276586"
#define kImageDefaultIcon           @"app_default_icon.png"
#define kNFReloadAppView            @"Notify_ReloadAppView"
#define kNFAddApp                   @"Personal_App_Add"
#define kNFremoveApp                @"Personal_App_Delete"
#define kKeyAppClientID             @"appClientId"
#define kKeyAppType                 @"appType"
#define kKeyAppName                 @"appName"
#define kKeyAppLogo                 @"appLogo"
#define kKeyAppClientSchema         @"appClientSchema"
#define kKeyWebURL                  @"webURL"
#define kKeyAppDldURL               @"appDldURL"
#define kKeyAppDownloadURL          @"downloadURL"
#define kKeyAppFrom                 @"from"
#define kAppViewOrigin(x,y)         CGRectMake(x, y, kAppViewWidth, kAppViewHeight)
#define kAppIconWidth               48.0f                       //已添加应用图标宽
#define kAppIconHeight              48.0f                       //已添加应用图标高
#define kTopMargin                  6.0f                        //最上边的间距
#define kInternalAppClientID        @"-1"                       //内置应用的id标识  tips:已失效，目前内置应用都由后台配置，不用强制赋值

#define MAX_COUNT_INLINE 4 //(isiPhone6Plus||isiPad?4:3) //单行图标数量


//for JSBridge
static NSMutableArray *showAppIDArrForJs;


static NSString * const kAppCollectionViewCellID = @"AppCollectionViewCell";
//static NSString * const kAppEnterAppConnectCellID = @"AppEnterAppConnectCell";
static NSString * const kAppCollectionHeaderViewID = @"AppCollectionHeaderView";
//static NSString * const kCycleBannerCollectionViewCellID = @"CycleBannerCollectionViewCell";
static NSString * const kApplicationViewIsNotCategoryState = @"ApplicationViewIsNotCategoryState";

@interface KDApplicationViewController ()<KDRefreshTableViewDataSource, KDRefreshTableViewDelegate, UIGestureRecognizerDelegate, XTQRScanViewControllerDelegate, MBProgressHUDDelegate, UIAlertViewDelegate,KDAppCollectionViewCellDelegate,UICollectionViewDelegate,UICollectionViewDataSource,KDAppCollectionViewDelegate>
{
    NSMutableArray *favoriteAppArr;         //本地收藏应用的数组
    NSMutableArray *favoriteAppIDArr;       //本地收藏应用的id数组
    
    NSString *downloadURL;                  //安装应用的地址
    AppsClient *publicAcctClient;           //获取公号信息的通讯客户端
    AppsClient *recommendAppClient;         //获取推荐应用的通讯客户端
    AppsClient *addUserAppClient;           //添加用户APP的通讯客户端
    AppsClient *deleteUserAppClient;        //删除用户APP的通讯客户端
    AppsClient *userAppClient;              //用户应用的通讯客户端
    AppsClient * attentionAppClient;        //关注公共号应用的通讯客户端
    AppsClient *qrcodeAppClient;
    MCloudClient *defaultAppClient;         //获取默认应用的通讯客户端
}
@property (nonatomic, retain) KDRefreshTableView *tableView;    //推荐应用的表格视图
@property (nonatomic, retain) MBProgressHUD *appHud;            //等待进度器
@property (nonatomic, retain) NSArray *titles;
@property (nonatomic, retain) AppsClient *buluoSdkAccount;
@property (nonatomic, retain) UIButton *addBtn;
@property (nonatomic, retain) UIButton *editFinishedButton;
@property (nonatomic, retain) NSArray *leftBarButtonItems;
@property (nonatomic, retain) AppsClient *sortAppListClient;



//当前显示应用的id数组
@property (nonatomic, strong) NSMutableArray *showAppIDArr;
//当前显示应用的数组(收藏 + 默认 + 固定)
@property (nonatomic, strong) NSMutableArray *showAppArr;

/// 应用列表
@property (nonatomic, strong) KDAppCollectionView *appCollectionView;
@property (nonatomic, strong) UIButton *moreAppsButton;
/// 分类名
@property (nonatomic, strong) NSMutableArray *categorysNameArray;
/// 分类数据
@property (nonatomic, strong) NSMutableDictionary *categorysDict;
@property (nonatomic, strong) MASConstraint *appCollectionViewBottomConstraint;

/// 是否在分类模式
@property (nonatomic, assign) BOOL isCategoryState;

@property (nonatomic, strong) SDImageCache *imageCache;
@property (nonatomic, strong) UIImage *appPlaceholderImage;
@property (nonatomic, copy) NSString *sortTypesKey;
@property (nonatomic, strong) NSIndexPath *deleteIndexPath;//要删除的indexpath
@end

@implementation KDApplicationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        favoriteAppArr = [[NSMutableArray alloc]initWithCapacity:1];
        favoriteAppIDArr = [[NSMutableArray alloc]initWithCapacity:1];
        self.showAppIDArr = [[NSMutableArray alloc]initWithCapacity:1];
        self.showAppArr = [[NSMutableArray alloc]initWithCapacity:1];
        _titles = [[NSArray alloc]init];
    }
    return self;
}


- (UIButton *)editFinishedButton {
    if (!_editFinishedButton) {
        _editFinishedButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"Global_Done")];
        _editFinishedButton.frame = CGRectMake(0, 0, 80, 24);
        _editFinishedButton.titleLabel.font = FS7;
        [_editFinishedButton addTarget:self action:@selector(finishEdit:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _editFinishedButton;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setEditingState:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = ASLocalizedString(@"KDApplicationViewController_app");
    if(!self.isMovingToParentViewController)
    {
        [self setNavigationStyle:KDNavigationStyleNormal];
    }

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.appCollectionView.isSorting = NO;
    [self.appCollectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isCategoryState = [BOSSetting sharedSetting].classifiedDisplay;
    self.titles =@[ASLocalizedString(@"KDApplicationQueryAppsHelper_sign"),ASLocalizedString(@"KDApplicationQueryAppsHelper_file"),ASLocalizedString(@"KDApplicationQueryAppsHelper_task"),ASLocalizedString(@"KDApplicationViewController_public")];
    
    // Do any additional setup after loading the view.
    [self setupView];
    [self getShowApplication];
    [self queryUserAppList];    //用户私有应用
   
    //注册广播
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAppView) name:kNFReloadAppView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addApp:) name:kNFAddApp object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeApp:) name:kNFremoveApp object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addOneApp:) name:@"AddApp" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteOneApp:) name:@"appViewDelete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadApplist:) name:@"reLoadApplist" object:nil];
}

- (void)reloadApplist:(NSNotification *)notification
{
    if(!self.appCollectionView.isSorting || (notification.object && [notification.object isEqualToString:@"delete"]))
    {
        [self queryUserAppList];    //用户私有应用
    }

}

- (void)setupView
{
    self.view.backgroundColor = [UIColor kdBackgroundColor2];//BOSCOLORWITHRGBA(kAppViewBGColor, 1.0);
    CGFloat bottomOffset = -49;
    [self.view addSubview:self.appCollectionView];
    [self.appCollectionView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(0);
        make.left.right.equalTo(self.view);
        self.appCollectionViewBottomConstraint = make.bottom.equalTo(self.view).with.offset(bottomOffset);
    }];
}

- (void)getShowApplication
{
    [self.showAppIDArr removeAllObjects];
    [self.showAppArr removeAllObjects];
    
    [favoriteAppArr removeAllObjects];
    NSArray * arrTmpModel = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonalAppList];
    for(KDAppDataModel * appDM in arrTmpModel)
    {
        NSString * strClientID = appDM.appClientID;
        if(![self.showAppIDArr containsObject:strClientID])
        {
            [favoriteAppArr addObject:appDM];
        }
    }
    [self.showAppArr addObjectsFromArray:favoriteAppArr];
    
    [favoriteAppIDArr removeAllObjects];
    NSArray * arrTempID = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonalAppsID];
    for(NSString * sID in arrTempID)
    {
        if(![self.showAppIDArr containsObject:sID])
        {
            [favoriteAppIDArr addObject:sID];
        }
    }
    [self.showAppIDArr addObjectsFromArray:favoriteAppIDArr];
    
   
    //更新下类型
    [self updateSortTypes];
    
    //处理下yunapp的id
    showAppIDArrForJs = [NSMutableArray array];// retain];
    [self.showAppArr enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
        KDAppDataModel *appDM = obj;
        if(appDM.appType == KDAppTypeYunApp)
            [showAppIDArrForJs addObject:appDM.appClientID];
    }];
}

//更新下类型
-(void)updateSortTypes
{
    //    appId = 124;
    //    appName = "\U52a0\U62ff\U5927";
    //    appTypeSortNum = 3;
    //    id = 52;
    
    NSArray *sortTypesArray = [[NSUserDefaults standardUserDefaults] arrayForKey:self.sortTypesKey];
    NSMutableArray *categorysNameArray = [NSMutableArray array];
    [sortTypesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [categorysNameArray addObject:[obj objectForKey:@"appName"]];
    }];
    self.categorysNameArray  = categorysNameArray;
    
    
    NSMutableDictionary *categorysDict = [NSMutableDictionary dictionary];
    for (KDAppDataModel *appDM in self.showAppArr) {
        NSString *categoryName = self.categorysNameArray.firstObject;
        if(appDM.appClasses.count > 0 && appDM.appClasses.firstObject != nil)
            categoryName = appDM.appClasses.firstObject;
        if(!categoryName)
            categoryName = @"";
        NSMutableArray *mutableArray = [categorysDict objectForKey:categoryName];
        if (!mutableArray) {
            mutableArray = [NSMutableArray array];
            [categorysDict setObject:mutableArray forKey:categoryName];
        }
        
        [mutableArray addObject:appDM];
    }
    self.categorysDict = categorysDict;
    
    //移除空的类型
    __weak __typeof(self) weakSelf = self;
    NSMutableArray *needRemoveCategorysNameArray = [NSMutableArray array];
    [self.categorysNameArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![weakSelf.categorysDict.allKeys containsObject:obj])
            [needRemoveCategorysNameArray addObject:obj];
    }];
    
    [needRemoveCategorysNameArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.categorysNameArray removeObject:obj];
    }];
}


- (KDAppDataModel *)createAppDataModelWithName:(NSString*)appName
                                    andAppLogo:(NSString*)appLogo
                                  andClassName:(NSString*)appClassName
{
    KDAppDataModel * appDM = [[KDAppDataModel alloc]init];
    appDM.appClientID = kInternalAppClientID;
    appDM.appType = 1;
    appDM.appName = appName;
    appDM.appLogo = appLogo;
    appDM.appClientSchema = appClassName;
    return appDM;// autorelease];
}

//查询用户自己的applist
- (void)queryUserAppList
{
    if(userAppClient == nil){
        userAppClient = [[AppsClient alloc] initWithTarget:self action:@selector(appUserListDidReceived:result:)];
    }
    
    [userAppClient queryAppList];
}

- (void)appUserListDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    if (result.success) {
        NSArray *sortTypes = [[result.dictJSON objectForKey:@"data"] objectForKey:@"sortedTypes"];
        if(sortTypes.count > 0)
            [[NSUserDefaults standardUserDefaults] setObject:sortTypes forKey:self.sortTypesKey];
        else
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.sortTypesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSArray *array = [[result.dictJSON objectForKey:@"data"] objectForKey:@"list"];
        [self addPersonAppsFromWebIntoDataBase:array];
        [self getShowApplication];
        [self.appCollectionView reloadData];
    }
}

-(AppsClient *)sortAppListClient
{
    if(_sortAppListClient == nil){
        _sortAppListClient = [[AppsClient alloc] initWithTarget:self action:@selector(sortAppListDidReceived:result:)];
    }
    return _sortAppListClient;
}


- (void)sortAppListDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    [KDPopup hideHUDInView:self.view];
    if (result.success)
    {
        //先清掉本地数据
        [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllPersonApps];
        [self.showAppArr enumerateObjectsUsingBlock:^(KDAppDataModel *model, NSUInteger i, BOOL *stop) {
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonalAppDataModel:model];
        }];
        
        //重新拉去列表
        [self reloadApplist:nil];
    }
    else
    {
        if(result.error.length > 0)
            [KDPopup showHUDToast:result.error];
        else
            [KDPopup showHUDToast:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        [self getShowApplication];
        [self.appCollectionView reloadData];
    }
}

-(void)addPersonAppsFromWebIntoDataBase:(NSArray *)appDataModels
{
    NSMutableArray *finalArray = [NSMutableArray array];
    [appDataModels enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger i, BOOL *stop)
     {
         [finalArray addObject:[[KDAppDataModel alloc]initWithDictionary:dic]];
     }];
    
    //先清掉本地数据
    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllPersonApps];
    
    [finalArray enumerateObjectsUsingBlock:^(KDAppDataModel *model, NSUInteger i, BOOL *stop) {
        [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonalAppDataModel:model];
    }];
}

-(void)addUserApp:(KDAppDataModel *)app
{
    if(addUserAppClient == nil){
        addUserAppClient = [[AppsClient alloc] initWithTarget:self action:@selector(addUserAppDidReceived:result:)];
    }
    
    [addUserAppClient postOneApp:app];
}

-(void)addUserYunApp:(KDAppDataModel *)app
{
    if(addUserAppClient == nil){
        addUserAppClient = [[AppsClient alloc] initWithTarget:self action:@selector(addUserAppDidReceived:result:)];
    }
    
    [addUserAppClient postCloudApp:app];
}

-(void)addUserAppDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    if(result.success){
        return ;
    }else{
        DLog(@"KDApplicationViewController_add_fail");
    }
}

- (void)addApp:(NSNotification *)note
{
    KDAppDataModel * appDM = [[note userInfo]objectForKey:@"appDM"];
    [self doAddingAppHandle:appDM];
}

-(void)addOneApp:(NSNotification *)note
{
    BOOL isYunApp = [[[note userInfo] objectForKey:@"isYunApp"] boolValue];
    
    KDAppDataModel * appDM = [[note userInfo]objectForKey:@"appDM"];
    if(isYunApp)
        [self addUserYunApp:appDM];
    else
        [self addUserApp:appDM];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tabBarSelectedOnce
{
    //[self queryDefaultApp];
    //[self sortRecommendApps];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNFReloadAppView object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNFAddApp object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNFremoveApp object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddApp" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appViewDelete" object:nil];
    
    self.tableView = nil;
    self.appCollectionView = nil;
    self.appHud = nil;
    
    //KD_RELEASE_SAFELY(recommendAppArr);
    //KD_RELEASE_SAFELY(publicAcctClient);
    //KD_RELEASE_SAFELY(recommendAppClient);
    //KD_RELEASE_SAFELY(defaultAppClient);
    //KD_RELEASE_SAFELY(favoriteAppArr);
    //KD_RELEASE_SAFELY(favoriteAppIDArr);
    //KD_RELEASE_SAFELY(defaultAppArr);
    //KD_RELEASE_SAFELY(showAppIDArr);
    //KD_RELEASE_SAFELY(showAppArr);
    //KD_RELEASE_SAFELY(downloadURL);
    //KD_RELEASE_SAFELY(addUserAppClient);
    //KD_RELEASE_SAFELY(deleteUserAppClient);
    //KD_RELEASE_SAFELY(qrcodeAppClient);
    //KD_RELEASE_SAFELY(_buluoSdkAccount);
    //[super dealloc];
}

//=======================================
#pragma mark - Notification
//=======================================
- (void)doAddingAppHandle:(KDAppDataModel * )appDM
{
    [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonalAppDataModel:appDM];
    [self getShowApplication];
    [self.appCollectionView reloadData];
    //[self queryUserAppList];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)attentionPublicAppWithId:(NSString *)pid{
    if (pid == nil) {
        return ;
    }
    if (attentionAppClient == nil)
    {
        attentionAppClient = [[AppsClient alloc] initWithTarget:nil action:nil];
    }
    [attentionAppClient attention:pid withdata:@"1"];
    
}

-(void)queryQrcodeInfoWithURL:(NSString *)url
{
    if (url == nil) {
        return;
    }
    
    if (qrcodeAppClient  == nil) {
        qrcodeAppClient = [[AppsClient alloc ]initWithTarget:self action:@selector(queryQRcodeInfoDidReceived:result:)];
    }
    
    [qrcodeAppClient queryQrcodeInfo:url];
}



- (void)removeApp:(NSNotification *)note
{
    NSString *appClientID = [[note userInfo] objectForKey:kKeyAppClientID];
    if([appClientID isEqualToString:kInternalAppClientID])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationViewController_tips_warn")message:ASLocalizedString(@"KDApplicationViewController_cannot_del")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[XTDataBaseDao sharedDatabaseDaoInstance] deletePersonalApp:appClientID];
    [self getShowApplication];
    [self.appCollectionView reloadData];
}

//删除用户APP
-(void)deleteOneApp:(NSNotification *)note
{
    KDAppDataModel * appDM = [[note userInfo]objectForKey:@"appDM"];
    [self deleteUserApp:appDM];
}

-(void)deleteUserApp:(KDAppDataModel *)app
{
    if(deleteUserAppClient == nil){
        deleteUserAppClient =[[AppsClient alloc] initWithTarget:self action:@selector(deleteUserAppDidReceived:result:)];
    }
    
    [deleteUserAppClient deleteOneApp:app];
}

- (void)deleteUserAppDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    if(result.success)
    {
        KDAppDataModel *appDM;
        if (self.isCategoryState)
        {
            NSString *categorysName = self.categorysNameArray[self.deleteIndexPath.section];
            NSMutableArray *appsArray = [self.categorysDict objectForKey:categorysName];
            appDM = appsArray[self.deleteIndexPath.item];
            [appsArray removeObjectAtIndex:self.deleteIndexPath.item];
            [self.showAppArr removeObject:appDM];
            if(appDM.appClientID)
                [self.showAppIDArr removeObject:appDM.appClientID];
            
            if(appsArray.count == 0)
            {
                //更新下类型
                [self updateSortTypes];
                [self.appCollectionView reloadData];
//                NSString *categoryName = self.categorysNameArray[self.deleteIndexPath.section];
//                [self.categorysDict removeObjectForKey:self.categorysNameArray[self.deleteIndexPath.section]];
//                [self.categorysNameArray removeObjectAtIndex:self.deleteIndexPath.section];
//
//
//                //重新存一下类型数组
//                 NSMutableArray *sortTypesArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:self.sortTypesKey]];
//                 for(NSDictionary *sortTypeDic in sortTypesArray)
//                 {
//                     if([[sortTypeDic objectForKey:@"appName"] isEqualToString:categoryName])
//                     {
//                         [sortTypesArray removeObject:sortTypeDic];
//                         break;
//                     }
//                 }
//
//                if(sortTypesArray.count > 0)
//                    [[NSUserDefaults standardUserDefaults] setObject:sortTypesArray forKey:self.sortTypesKey];
//                else
//                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.sortTypesKey];
//                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        else
        {
            appDM = self.showAppArr[self.deleteIndexPath.item];
            [self.showAppArr removeObjectAtIndex:self.deleteIndexPath.item];
        }
        [self.appCollectionView reloadData];
    }
    else
    {
        if(result.error.length > 0)
            [KDPopup showHUDToast:result.error];
        else
            [KDPopup showHUDToast:@"网络异常，删除失败"];
    }
    self.deleteIndexPath = nil;
}

-(void)queryQRcodeInfoDidReceived:(AppsClient *)client result:(id)result
{
    BOOL isSuccess = [result objectForKey:@"success"];
    if (isSuccess) {
        NSString *pid = [result objectForKey:@"pid"];
        //NSString *qrcodeurl = [result objectForKey:@"qrcodeurl"];
        if ([pid length] > 0) {
            KDPubAccDetailViewController *viewController = [[KDPubAccDetailViewController alloc] initWithPubAcctId:pid];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        
    }else{
        
    }
}


//包括默认已显示的应用
- (BOOL)hasFavorite:(KDAppDataModel*)appDM
{
    if(appDM == nil)
        return NO;
    BOOL hasFavorite = NO;
    if (appDM.appType == KDAppTypePublic) {
        for (KDAppDataModel * appDataModel in self.showAppArr) {
            if ([appDM.pid isEqualToString:appDataModel.pid]) {
                return YES;
            }
            
        }
    }
    else{
        for (KDAppDataModel * appDataModel in self.showAppArr) {
            if ([appDM.appClientID isEqualToString:appDataModel.appClientID]) {
                return YES;
            }
            
        }
        
    }
    
    return hasFavorite;
}

- (void) openAppDetail:(KDAppDataModel *)appDM
{
    KDAppDetailViewController *appDetailVC = nil;
    appDetailVC = [[KDAppDetailViewController alloc] initWithAppDataModel:appDM];
    appDetailVC.hasFavorite = [self hasFavorite:appDM];
    appDetailVC.sourceType = KDAppSourceTypeRecommend;
    appDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:appDetailVC animated:YES];
}

- (void)goToWebAppWithURL:(NSString *)url
{
    if (url.length == 0) {
        return;
    }
    
    KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:url];
    webVC.title = ASLocalizedString(@"KDApplicationViewController_lightapp");
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}

//=======================================
#pragma mark - PersonalAppViewDelegate
//=======================================
- (void)longPressAppView
{
    if(!self.appCollectionView.isSorting)
    {
        [self setEditingState:YES];
    }
}

-(void)setEditingState:(BOOL)isEditing
{
    if(isEditing)
    {
        self.appCollectionView.isSorting = YES;
        [self.addBtn removeFromSuperview];
        [KDWeiboAppDelegate getAppDelegate].tabBarController.tabBar.hidden = YES;
        self.title = ASLocalizedString(@"KDOrganiztionCell_Edit");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editFinishedButton];
        self.leftBarButtonItems = self.navigationItem.leftBarButtonItems;
        self.navigationItem.leftBarButtonItems = nil;
    }
    else
    {
        self.appCollectionView.isSorting = NO;
        [KDWeiboAppDelegate getAppDelegate].tabBarController.tabBar.hidden = NO;
        self.title = ASLocalizedString(@"KDApplicationViewController_app");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.moreAppsButton];
        if(self.leftBarButtonItems)
            self.navigationItem.leftBarButtonItems = self.leftBarButtonItems;
    }
}

/**
 *  打开本地应用
 *
 */
- (void)openInternalApp:(KDAppDataModel *)appDataModel
{
    NSString *internalAppName = appDataModel.iosSchdeme;
    if ([internalAppName hasPrefix:@"signIn"]) {
//        //签到打开次数
//        [KDEventAnalysis event:event_app_signin_open];
//        UIViewController *vc = [[KDSignInViewController alloc] init] ;//autorelease];
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
        
        BOOL newUserGuide = NO;
        
        //签到用户引导逻辑：新用户，每个工作圈只引导1次
        NSString *urlString = appDataModel.detailURL;
        if (urlString && ![urlString isEqualToString:@""]) {
            if (//[self isNewUser:@"2016-12-01 00:00:00"] &&
                ![[KDUserDefaults sharedInstance] isFlagConsumed:KDIsSignInGuide]) {
                [[KDUserDefaults sharedInstance] consumeFlag:KDIsSignInGuide];
                newUserGuide = YES;
            }
        }
        
        if (newUserGuide == NO) {
            UIViewController *destinationController = [[KDSignInViewController alloc] init];
            [KDEventAnalysis event:event_app_signin_open];
            destinationController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:destinationController animated:YES];
        }
        else {
            //跳转到签到用户引导
            NSString *appendStr = [NSString stringWithFormat:@"?isAdmin=%@&eid=%@", [[BOSConfig sharedConfig].user isAdmin]?@"true":@"false", [BOSConfig sharedConfig].user.eid];
            urlString = [urlString stringByAppendingString:appendStr];
            urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            KDWebViewController *applightWebVC = [[KDWebViewController alloc] initWithUrlString:urlString];
            applightWebVC.hidesBottomBarWhenPushed = YES;
            //applightWebVC.adminNewUserGuidePage = YES;
            __weak __typeof(applightWebVC) weak_webvc = applightWebVC;
            __weak __typeof(self) weakself = self;
            applightWebVC.getLightAppBlock = ^() {
                if(weak_webvc && !weak_webvc.bPushed){
                    weak_webvc.color4NavBg = @"#43BBFC";
                    weak_webvc.color4processBg = @"#46E7FF";
                    [weakself.navigationController pushViewController:weak_webvc animated:YES];
                }
            };

            [self.navigationController pushViewController:applightWebVC animated:YES];
        }

    }
    else if ([internalAppName hasPrefix:@"file"]) {
        //我的文件打开次数
        [KDEventAnalysis event:event_app_dochelper_open];
        [KDEventAnalysis event:event_app_myfile];
        XTMyFilesViewController *ctr = [[XTMyFilesViewController alloc] init];
        ctr.fromType = 1;
        [self.navigationController pushViewController:ctr animated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"APP_MAIN_DOC_New_FEATURE"];
    }
    else if ([internalAppName hasPrefix:@"todolist"]) {
        //任务打开次数
        [KDEventAnalysis event:event_app_tasks_open];
        UIViewController *vc = [[KDTodoListViewController alloc] init];// autorelease];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([internalAppName hasPrefix:@"pubacc"]) {
        //公共号
        UIViewController *vc = [[KDSubscribeViewController alloc] init];// autorelease];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([internalAppName hasPrefix:@"qrScan"]) {
        //扫一扫
        [self qrScan];
    }
}

- (void)qrScan
{
#if SIMULATOR
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDApplicationViewController_un_support_scan")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
        return;
    }
#endif
    
    
    
    //获取对摄像头的访问权限
    //if (isAboveiOS7)
    //{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDApplicationViewController_cannot_camera")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alertView show];
//        [alertView release];
        return;
    }
    //}
    
    [KDEventAnalysis event:event_scan_open attributes:@{label_scan_open: label_scan_open_application}];
    
    XTQRScanViewController *qrScanController = [[XTQRScanViewController alloc] init];
    qrScanController.delegate = self;
    qrScanController.controller = self;
    UINavigationController *qrScanNavController = [[UINavigationController alloc] initWithRootViewController:qrScanController];
    [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:qrScanNavController animated:YES completion:nil];
}

- (void)fileTrans
{
    PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:kFileTransPublicAccountID];
    if(person)
    {
        [self openFileTrans:person];
        return;
    }
    
    if(publicAcctClient == nil)
        publicAcctClient = [[AppsClient alloc] initWithTarget:self action:@selector(getPubAccountDidReceived:result:)];
    
    if (_appHud == nil)
    {
        _appHud = [[MBProgressHUD alloc] initWithView:self.view];
        _appHud.labelText = ASLocalizedString(@"KDApplicationViewController_loading_file_ass");
        _appHud.delegate = self;
        [self.view addSubview:_appHud];
        [_appHud show:YES];
    }
    
    [publicAcctClient getPublicAccount:kFileTransPublicAccountID];
}

-(void)getPubAccountDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    [_appHud hide:YES];
    
    if (result.success)
    {
        if(result.data)
        {
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:result.data];// autorelease];
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertPublicPersonSimple:person];
            [self openFileTrans:person];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationViewController_tips_1")message:ASLocalizedString(@"KDApplicationViewController_network_error")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alertView show];
//        [alertView release];
    }
}

- (void)openFileTrans:(PersonSimpleDataModel*)ps
{
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:ps];// autorelease];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

//=======================================
#pragma mark - XTQRScanViewControllerDelegate
//=======================================
- (void)qrScanViewController:(XTQRScanViewController *)controller loginCode:(int)qrLoginCode result:(NSString *)result
{
    [[KDWeiboAppDelegate getAppDelegate].tabBarController dismissViewControllerAnimated:NO completion:^
     {
         if (qrLoginCode > 0)
         {
             if (qrLoginCode == QRPubAccScan) {
                 NSString *url = [result  stringByReplacingOccurrencesOfString:@"qrcodecreate" withString:@"pubqrcode"];
                 [self queryQrcodeInfoWithURL:url];
             }else{
                 XTQRLoginViewController *login = [[XTQRLoginViewController alloc] initWithURL:result qrLoginCode:qrLoginCode];
                 login.hidesBottomBarWhenPushed = YES;
                 [self.navigationController pushViewController:login animated:YES];
//                 [login release];
             }
         }
     }];
}

- (void)loadWebViewControllerWithUrl:(NSString *)url
{
    if (url.length == 0) {
        return;
    }
    
    KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:url];//autorelease];
    webVC.hidesBottomBarWhenPushed = YES;
    webVC.isOnlyOpenInBrowser = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)qrScanViewControllerDidCancel:(XTQRScanViewController *)controller
{
    [[KDWeiboAppDelegate getAppDelegate].tabBarController dismissViewControllerAnimated:YES completion:nil];
}

//=======================================
#pragma mark - UIAlertViewDelegate
//=======================================
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
    }
}

//=======================================
#pragma mark UIGestureRecognizerDelegate
//=======================================
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"])
    {
        return NO;
    }
    return YES;
}

- (void)openSearchViewController
{
    KDAppSerachViewController * ks = [[KDAppSerachViewController alloc]init];// autorelease];
    ks.favoriteAppArr = self.showAppArr;
    ks.openAppDelegate = self;
    [self.navigationController pushViewController:ks animated:NO];
}


//=======================================
#pragma mark MBProgressHUDDelegate
//=======================================
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    self.appHud = nil;
}

//=======================================
#pragma mark - KDApplicationTableViewCellDelegate
//=======================================
- (void)viewDetail:(KDAppDataModel*)appDM
{
    //推荐位应用点击次数
    [KDEventAnalysis event:event_app_recommend_open];
    [self openAppDetail:appDM];
}

//=======================================
#pragma mark - KDPersonalAppViewDelegate
//=======================================

- (void)goToAppWithDataModel:(KDAppDataModel *)appDM
{
    //所有应用的打开次数
    if(appDM.appClientID)
    {
        [KDEventAnalysis event:event_applicatioin_click_count attributes:@{ @"appName": appDM.appName,@"appId":appDM.appClientID}];
        [KDEventAnalysis eventCountly:event_applicatioin_click_count attributes:@{ @"appName": appDM.appName,@"appId":appDM.appClientID}];
    }
    else if(appDM.appID)
    {
        [KDEventAnalysis event:event_applicatioin_click_count attributes:@{ @"appName": appDM.appName,@"appId":appDM.appID}];
        [KDEventAnalysis eventCountly:event_applicatioin_click_count attributes:@{ @"appName": appDM.appName,@"appId":appDM.appID}];
    }
    else
    {
        [KDEventAnalysis event:event_applicatioin_click_count attributes:@{ @"appName": appDM.appName}];
        [KDEventAnalysis eventCountly:event_applicatioin_click_count attributes:@{ @"appName": appDM.appName}];
    }
//    [KDEventAnalysis event:event_applicatioin_click_count];
    //if([appDM.appClientID isEqualToString:kInternalAppClientID])
    if (appDM.appType == KDAppTypeSpecial)
    {
        [self openInternalApp:appDM];
        return;
    }
    else if (appDM.appType == KDAppTypeWeb || appDM.appType == KDAppTypeLight || appDM.appType == KDAppTypeYunApp)
    {
        [self openLightApp:appDM];
        return;
    }
    else if(appDM.appType == 5){
        [self openPublicApp:appDM];
        return;
    }
    
    
    NSRange findRange = [appDM.appClientSchema rangeOfString:@"p?"];
    NSURL *url = nil;
    NSString *creatSchema = nil;
    if (findRange.length >0)
    {
        NSString *token = nil;
        token = [NSString stringWithFormat:@"%@,%@,%@,%@,%@",[BOSConfig sharedConfig].user.openId,[BOSConfig sharedConfig].user.wbUserId,[BOSConfig sharedConfig].user.oauthToken,[BOSConfig sharedConfig].user.token,[BOSConfig sharedConfig].user.oauthTokenSecret];
        
        NSString *url = [AlgorithmHelper des_Encrypt:token key:@"erewre%#@$%^$%YRT"];
        
        //升级到新版加密方法后，会出现一些换行符，去除掉
        url = [url stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        //进行url特殊字符处理
        NSCharacterSet *URLBase64CharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"/+=\n"] invertedSet];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:URLBase64CharacterSet];
        
        
        NSString *prefix = [appDM.appClientSchema substringToIndex:findRange.location];
        //SSOToken
        creatSchema = [prefix stringByAppendingFormat:@"p?%@",url];
        BOSDEBUG(ASLocalizedString(@"KDApplicationViewController_protcol"),creatSchema);
        
    }
    else
    {
        creatSchema = appDM.appClientSchema;
    }
    url = [NSURL URLWithString:creatSchema];
    
    if (!isAboveiOS9)
    {
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
        }else
        {
            if (appDM.downloadURL && ![appDM.downloadURL isEqual:@""])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDApplicationViewController_uninstall")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"Global_Sure"),nil];
                [alertView show];
//                [alertView release];
                downloadURL = [[NSString alloc] initWithString:appDM.downloadURL];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationViewController_tips_warn")message:ASLocalizedString(@"KDApplicationViewController_link_error")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                [alert show];
//                [alert release];
            }

        }
            
    }
    else
    {
        if (![[UIApplication sharedApplication]openURL:url]) {
            if (appDM.downloadURL && ![appDM.downloadURL isEqual:@""])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDApplicationViewController_uninstall")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"Global_Sure"),nil];
                [alertView show];
//                [alertView release];
                downloadURL = [[NSString alloc] initWithString:appDM.downloadURL];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationViewController_tips_warn")message:ASLocalizedString(@"KDApplicationViewController_link_error")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                [alert show];
//                [alert release];
            }

        }
    }
}

- (void)openLightApp:(KDAppDataModel *)appDM
{
    //appID 与 appClientID的关系是 去掉后两位，因为本地库没有appID字段的临时做法。
    //    NSString * appID = [NSString stringWithFormat:@"%.0f",appDM.appClientID / 100];
    //yunapp1后面是跟着11
    NSString *appID = [appDM.appClientID substringToIndex:[appDM.appClientID length] - 2];
    if (appID.length == 0) {
        return;
    }
    
    if ([appID isEqualToString:LightAppId_WXSQ]) {
        [self getBuluoAccount];
        return;
    }
    
    KDWebViewController *applightWebVC = [[KDWebViewController alloc] initWithUrlString:@"" appId:appID];
    applightWebVC.appType = appDM.appType;//为了yunapp
    applightWebVC.title = appDM.appName;
    applightWebVC.hidesBottomBarWhenPushed = YES;
    __weak __typeof(applightWebVC) weak_webvc = applightWebVC;
    __weak __typeof(self) weak_controller = self;
    applightWebVC.getLightAppBlock = ^() {
        if(weak_webvc && !weak_webvc.bPushed){
            [weak_controller.navigationController pushViewController:weak_webvc animated:YES];
        }
    };
    if ([appDM.appName isEqualToString:ASLocalizedString(@"KDApplicationViewController_yihubaiying")]) {
        //一呼百应打开次数
        [KDEventAnalysis event:event_app_mass_response_open];
    }
}

-(void)openPublicApp:(KDAppDataModel * )appDM{
    if (!appDM.pid || [appDM.pid length] == 0) {
        return ;
    }
    //不管如何 直接拉数据
//    PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicPersonSimple:appDM.pid];
//    if(person)
//    {
//        [self openFileTrans:person];
//        return;
//    }
//    
    if(publicAcctClient == nil)
        publicAcctClient = [[AppsClient alloc] initWithTarget:self action:@selector(getPubAccountDidReceived:result:)];
    
    if (_appHud == nil)
    {
        _appHud = [[MBProgressHUD alloc] initWithView:self.view];
        _appHud.labelText = ASLocalizedString(@"KDApplicationViewController_loading_resource");
        _appHud.delegate = self;
        [self.view addSubview:_appHud];
        [_appHud show:YES];
    }
    
    [publicAcctClient getPublicAccount:appDM.pid];
    
}


+(NSMutableArray *)getShowAppIDArrForJs
{
    return showAppIDArrForJs;
}

- (void)getBuluoAccount {
    if (!self.buluoSdkAccount) {
        self.buluoSdkAccount = [[AppsClient alloc] initWithTarget:self action:@selector(getBuluoAccountDidReceived:result:)];
    }
    [self.buluoSdkAccount getBuluoAccountWithEid:[BOSConfig sharedConfig].user.eid Oid:[BOSConfig sharedConfig].user.oId];
}

-(void)getBuluoAccountDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result {
    
    if (result.success){
        if(result.data){
            NSDictionary *data = result.data[@"params"];
            NSString *token = safeString([data objectForKey:@"token"]);
            NSString *tokenSecret = safeString([data objectForKey:@"tokenSecret"]);
            if (token.length > 0 && tokenSecret.length > 0) {
                OpenUser *user = [[OpenUser alloc] init];
                user.mId = data[@"buluoUserId"];
                user.networkId = data[@"buluoNetworkId"];
                
                KDWebViewController *applightWebVC = [[KDWebViewController alloc] initWithUrlString:nil OpenUser:user];
                applightWebVC.color4NavBg = safeString([data objectForKey:@"titleBgColor"]);
                applightWebVC.color4processBg = safeString([data objectForKey:@"titlePbColor"]);
                [self.navigationController pushViewController:applightWebVC animated:YES];
                return;
            }
        }
    }
    // 失败处理
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:ASLocalizedString(@"获取帐号信息失败") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionSure = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:actionSure];
    [self presentViewController:alertVC animated:YES completion:nil];
}


#pragma AppCollectionView

-(NSString *)sortTypesKey
{
    if(_sortTypesKey == nil)
        _sortTypesKey = [NSString stringWithFormat:@"%@_%@",@"sortTypesKey",[BOSConfig sharedConfig].user.userId];
    return _sortTypesKey;
}

- (SDImageCache *)imageCache {
    if (!_imageCache) {
        _imageCache = [[SDImageCache alloc] initWithNamespace:@"kdweibo_sdimage_app"];
    }
    
    return _imageCache;
}

- (UIImage *)appPlaceholderImage {
    if (!_appPlaceholderImage) {
        _appPlaceholderImage = [UIImage imageNamed:@"app_default_icon"];//[[UIImage imageNamed:@"app_default_icon"] kd_imageWithCornerRadius:KApplicationCornerRadius(kAppIconWidth) rect:CGRectMake(0, 0, kAppIconWidth, kAppIconHeight)];
    }
    
    return _appPlaceholderImage;
}

- (KDAppCollectionView *)appCollectionView {
    if (!_appCollectionView) {
        _appCollectionView = [[KDAppCollectionView alloc] init];
        _appCollectionView.delegate = self;
        _appCollectionView.dataSource = self;
        _appCollectionView.kdDelegate = self;
        _appCollectionView.enableSorting = YES;
        _appCollectionView.clipsToBounds = NO;
        
        [_appCollectionView registerClass:[KDAppCollectionViewCell class]
               forCellWithReuseIdentifier:kAppCollectionViewCellID];
//        [_appCollectionView registerClass:[KDAppEnterAppConnectCell class] forCellWithReuseIdentifier:kAppEnterAppConnectCellID];
//        [_appCollectionView registerClass:[KDCycleBannerCollectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCycleBannerCollectionViewCellID];
        [_appCollectionView registerClass:[KDAppColectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kAppCollectionHeaderViewID];
    }
    
    return _appCollectionView;
}

- (UIButton *)moreAppsButton {
    if (!_moreAppsButton) {
        _moreAppsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreAppsButton setFrame:CGRectMake(0, 0, 80, 24)];
        [_moreAppsButton setImage:[UIImage imageNamed:@"app_btn_more_normal"] forState:UIControlStateNormal];
        [_moreAppsButton setImage:[UIImage imageNamed:@"app_btn_more_press"] forState:UIControlStateHighlighted];
        [_moreAppsButton setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
        [_moreAppsButton setTitle:ASLocalizedString(@"更多应用") forState:UIControlStateNormal];
        [_moreAppsButton setTitleColor:[UIColor colorWithRGB:0x030303 alpha:1] forState:UIControlStateNormal];
        [_moreAppsButton setTitleColor:[UIColor colorWithRGB:0x030303 alpha:0.5] forState:UIControlStateHighlighted];
        [_moreAppsButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
        [_moreAppsButton setBackgroundColor:FC6];
        [_moreAppsButton.titleLabel setFont:FS7];
        [_moreAppsButton addTarget:self action:@selector(openSearchViewController) forControlEvents:UIControlEventTouchUpInside];
        
        _moreAppsButton.layer.cornerRadius = 12;
        _moreAppsButton.layer.masksToBounds = YES;
        _moreAppsButton.layer.borderWidth = 0.5;
        _moreAppsButton.layer.borderColor = UIColorFromRGB(0xB9C7D2).CGColor;
    }
    
    return _moreAppsButton;
}



#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger result = self.categorysNameArray.count;
    if (!self.isCategoryState) {
        result = 1;
    }
    
//    if (self.shouldShowEnterAppsConnect && self.enterAppsConnectArray.count > 0) {
//        result += 2;
//    }
    
    return result;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    // 显示企业应用接入
//    if (self.shouldShowEnterAppsConnect
//        && ((self.isCategoryState && section == (NSInteger)self.categorysNameArray.count + 1)
//            || (!self.isCategoryState && section == 2))) {
//            return self.enterAppsConnectArray.count;
//        }
    
    if (!self.isCategoryState && section == 0) {
        return self.showAppArr.count;
    }
    
    if (self.isCategoryState && section  < self.categorysNameArray.count) {
        //分组内的app个数
        NSArray *appsArray = [self.categorysDict objectForKey:self.categorysNameArray[section]];
        return appsArray.count;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    KDAppCollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:kAppCollectionViewCellID forIndexPath:indexPath];
    
    KDAppDataModel *appDM;
    if (self.isCategoryState) {
        if (indexPath.section < (NSInteger)self.categorysNameArray.count) {
            NSArray *appsArray = [self.categorysDict objectForKey:self.categorysNameArray[indexPath.section]];
            if (indexPath.item < (NSInteger)appsArray.count) {
                appDM = appsArray[indexPath.item];
            }
        }
    } else {
        appDM = self.showAppArr[indexPath.item];
    }
    
    cell.nameLabel.text = appDM.appName;
    [self imageView:cell.logoImageView setImageWithURL:appDM.appLogo appName:appDM.appName];
    
//    cell.redDot.hidden = !appDM.isNew;
    
    cell.delegate = self;
    cell.isDeleteStatus = self.appCollectionView.isSorting;
    
    NSIndexPath *movingIndexPath = self.appCollectionView.currentMovingIndexPath;
    if (movingIndexPath && movingIndexPath.section == indexPath.section && movingIndexPath.row == indexPath.row) {
        cell.contentView.alpha = 0;
    } else {
        cell.contentView.alpha = 1;
    }
    
    return cell;
}

- (void)imageView:(UIImageView *)imageView setImageWithURL:(NSString *)imageURL appName:(NSString *)appName {
    NSString *sdDiskKey = [NSString stringWithFormat:@"kdweibo_sdimage_app_%@", appName];
    NSString *timeParam = safeString([imageURL.queryComponents objectForKey:@"t"]);
    if (timeParam.length > 0) {
        sdDiskKey = [sdDiskKey stringByAppendingFormat:@"_%@", timeParam];
    }
    
    UIImage *appImage = [self.imageCache imageFromDiskCacheForKey:sdDiskKey];
    [imageView cancelCurrentImageLoad];
    
    if (appImage) {
        imageView.image = appImage;
        imageView.layer.cornerRadius = KApplicationCornerRadius(kAppIconWidth);
        imageView.layer.masksToBounds = YES;
    } else {
        __weak __typeof(self) weakSelf = self;
        __weak __typeof(imageView) weakImageView = imageView;
        [imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:self.appPlaceholderImage options:SDWebImageRetryFailed | SDWebImageHighPriority completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType) {
            if (image) {
                NSString *cacheStr = [[SDWebImageManager sharedManager] cacheKeyForURL:url imageScale:SDWebImageScaleNone];
                
                if (cacheStr) {
                    [[SDImageCache sharedImageCache] queryDiskCacheForKey:cacheStr done:^(UIImage *image, SDImageCacheType cacheType) {
                        if (image) {
                            [[SDImageCache sharedImageCache] removeImageForKey:cacheStr fromDisk:YES];
                        }
                    }];
                }
                [weakSelf.imageCache storeImage:image forKey:sdDiskKey];
                weakImageView.image = image;
                weakImageView.layer.cornerRadius = KApplicationCornerRadius(kAppIconWidth);
                weakImageView.layer.masksToBounds = YES;
            }
        }];
    }
}

- (BOOL)moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath
                toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section != destinationIndexPath.section) {
        return NO;
    }
    
//    self.hasEdited = YES;
    
    if (self.isCategoryState) {
        NSMutableArray *appsArray = [self.categorysDict objectForKey:self.categorysNameArray[sourceIndexPath.section]];
        KDAppDataModel *appDM = appsArray[sourceIndexPath.item];
        KDAppDataModel *destinationAppDM = appsArray[destinationIndexPath.item];
        [appsArray removeObjectAtIndex:sourceIndexPath.item];
        [appsArray insertObject:appDM atIndex:destinationIndexPath.item];
        
        //总排序数组
        NSUInteger destinationAppDMInShowArrIndex = [self.showAppArr indexOfObject:destinationAppDM];
        if(destinationAppDMInShowArrIndex < self.showAppArr.count)
        {
            [self.showAppArr removeObject:appDM];
            [self.showAppArr insertObject:appDM atIndex:destinationAppDMInShowArrIndex];
        }
    } else {
        KDAppDataModel *appDM = self.showAppArr[sourceIndexPath.item];
        [self.showAppArr removeObjectAtIndex:sourceIndexPath.item];
        [self.showAppArr insertObject:appDM atIndex:destinationIndexPath.item];
    }
    
    [self.appCollectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    
    return YES;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        KDCycleBannerCollectionView *bannerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kCycleBannerCollectionViewCellID forIndexPath:indexPath];
//        bannerView.bannerView.delegate = self;
//        self.bannerScrollView = bannerView.bannerView;
//        [self.bannerScrollView reloadData];
//        
//        return bannerView;
//    }
    
    KDAppColectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kAppCollectionHeaderViewID forIndexPath:indexPath];
    if (self.isCategoryState && indexPath.section < (NSInteger)self.categorysNameArray.count) {
        headerView.label.text = self.categorysNameArray[indexPath.section];
    } else {
        headerView.label.text = @"";
    }
    
    return headerView;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.appCollectionView.isSorting) {
        return NO;
    }
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = YES;
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = NO;
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.appCollectionView.isSorting)
        return;
    
    KDAppDataModel *appDM;
    if (self.isCategoryState) {
        NSMutableArray *appsArray = [self.categorysDict objectForKey:self.categorysNameArray[indexPath.section]];
        appDM = appsArray[indexPath.item];
    } else {
        appDM = self.showAppArr[indexPath.item];
    }
    
    [self goToAppWithDataModel:appDM];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        if (self.adsDataModels.count <= 0) {
//            return CGSizeZero;
//        }
//        
//        return CGSizeMake(ScreenFullWidth, KApplicationAdsViewHeight);
//    }
//    
//    if (self.shouldShowEnterAppsConnect
//        && (( self.isCategoryState && section > (NSInteger)self.categorysNameArray.count)
//            || (!self.isCategoryState && section > 1))) {
//            return CGSizeMake(ScreenFullWidth, 20);
//        }
//    
    if (!self.isCategoryState && section == 0) {
        return CGSizeZero;
    }
    
    return CGSizeMake(ScreenFullWidth, 30);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGFloat spacing = (ScreenFullWidth - layout.itemSize.width * MAX_COUNT_INLINE - 16) / (MAX_COUNT_INLINE + 1) - 1;
    
//    if (section == 0) {  // Banner
//        return UIEdgeInsetsMake(0, 0, 0, 0);
//    }
//
//    if (self.shouldShowEnterAppsConnect
//        && ((self.isCategoryState && section > (NSInteger)self.categorysNameArray.count)
//            || (!self.isCategoryState && section > 1))) {
//            return UIEdgeInsetsMake(0, 0, 0, 0);
//        }
//    
//    if (section == 1) {
//        if (self.adsDataModels.count > 0 && !self.isCategoryState) {
//            return UIEdgeInsetsMake(7, 8 + spacing, 18, 8 + spacing);
//        } else if (self.adsDataModels.count <= 0 && !self.isCategoryState) {
//            return UIEdgeInsetsMake(12, 8 + spacing, 18, 8 + spacing);
//        }
//        return UIEdgeInsetsMake(0, 8 + spacing, 18, 8 + spacing);
//    }
    
    return UIEdgeInsetsMake(kTopMargin, 8 + spacing, 18, 8 + spacing);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.shouldShowEnterAppsConnect
//        && ((self.isCategoryState && indexPath.section > (NSInteger)self.categorysNameArray.count)
//            || (!self.isCategoryState && indexPath.section > 1))) {
//            return [KDAppEnterAppConnectCell size];
//        }
    
    return [KDAppCollectionViewCell size];
}

#pragma mark - KDAppCollectionViewDelegate

- (void)cellDidLongPressed:(KDAppCollectionViewCell *)cell {
//    if ([BOSSetting sharedSetting].isPersonalNetwork || BOS_CONFIG.isAppEditLimited) {
//        return;
//    }
    
    self.appCollectionView.isSorting = !self.appCollectionView.isSorting;
    
    [self changeVisibleCellsState];
    [self setEditingState:self.appCollectionView.isSorting];
}

- (void)changeVisibleCellsState {
    for (KDAppCollectionViewCell *cell in self.appCollectionView.subviews) {
        if ([cell isKindOfClass:[KDAppCollectionViewCell class]]) {
            cell.isDeleteStatus = self.appCollectionView.isSorting;
        }
    }
}


- (void)finishEdit:(UIButton *)sender {
    // 拖拽中不允许完成
    if (self.appCollectionView.currentMovingIndexPath) {
        return;
    }
    
    //切换回正常状态
    [self setEditingState:NO];
    self.appCollectionView.isSorting = NO;
    [self changeVisibleCellsState];
    
    [KDPopup showHUDInView:self.view];
    
    //提交排序请求
    NSMutableArray *appIdArray = [NSMutableArray arrayWithCapacity:self.showAppArr.count];
    [self.showAppArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KDAppDataModel *model = obj;
        if(model.appType == KDAppTypePublic)
        {
            if(model.pid)
                [appIdArray addObject:model.pid];
        }
        else
        {
            if(model.appClientID)
            {
                NSString *appID = [model.appClientID substringToIndex:[model.appClientID length] - 2];
                [appIdArray addObject:appID];
            }
        }
    }];

    [self.sortAppListClient sortAppListWithAppIds:appIdArray];
}


#pragma mark - KDAppCollectionViewCellDelegate

- (void)collectionViewCellDeleteButtonDidPressed:(KDAppCollectionViewCell *)cell {
    if (self.showAppArr.count <= 0) {
        return;
    }
    
    NSIndexPath *indexPath = [self.appCollectionView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    
    KDAppDataModel *appDM;
    if (self.isCategoryState) {
        NSMutableArray *appsArray = [self.categorysDict objectForKey:self.categorysNameArray[indexPath.section]];
        appDM = appsArray[indexPath.item];
    } else {
        appDM = self.showAppArr[indexPath.item];
    }
    
//    // 不可删除时弹警告
//    if (![appDM.deleteAble isEqualToString:@"Yes"]) {
//        [KDPopup showHUDToast:ASLocalizedString(@"企业管理员已设置该应用为不可编辑") inView:self.view];
//        return;
//    }
    
//    __weak __typeof(self) weakSelf = self;
//    NSString *deleteMessage;
//    if (BOS_CONFIG.currentUserHasAppPrivilege) {
//        deleteMessage = ASLocalizedString(@"隐藏该应用后，你可到应用中心-已开通栏中将该应用显示回工作台");
//    } else {
//        deleteMessage = ASLocalizedString(@"隐藏该应用后，你可到更多应用中将该应用显示回工作台");
//    }
    
    //删除app
    self.deleteIndexPath = indexPath;
    [self deleteUserApp:appDM];
    
//    [KDPopup showAlertWithTitle:@"" message:deleteMessage buttonTitles:@[ASLocalizedString(@"取消"), ASLocalizedString(@"隐藏")] onTap:^(NSInteger index) {
//        if (index != 0) {
//            if (!weakSelf.isCategoryState && indexPath.row >= (NSInteger)self.showAppArr.count) {
//                return;
//            }
//            
//            if (weakSelf.isCategoryState) {
//                if (indexPath.section > (NSInteger)weakSelf.categorysNameArray.count) {
//                    return;
//                }
//                
//                NSMutableArray *appsArray =
//                [weakSelf.categorysDict objectForKey:weakSelf.categorysNameArray[indexPath.section - 1]];
//                
//                if (indexPath.row >= (NSInteger)appsArray.count) {
//                    return;
//                }
//            }
//            
//            [weakSelf deleteUserApp:appDM];
////            [weakSelf deleteAppData:appDM];
////            weakSelf.hasEdited = YES;
//            
//            //            NSIndexPath *aIndexPath = [weakSelf.appCollectionView indexPathForCell:cell];
//            //            if (aIndexPath && aIndexPath.section == indexPath.section && aIndexPath.item == indexPath.item) {
//            //                [weakSelf.appCollectionView performBatchUpdates:^{
//            //                    [weakSelf.appCollectionView deleteItemsAtIndexPaths:@[ indexPath ]];
//            //                } completion:^(BOOL finished) { }];
//            //            } else {
//            [weakSelf.appCollectionView reloadData];
//            //            }
//        }
//    }];
}


@end
