//
//  KDAppSerachViewController.m
//  kdweibo
//
//  Created by 郑学明 on 14-4-19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDAppSerachViewController.h"
#import "KDSearchBar.h"
#import "KDAppViewCell.h"
#import "UIView+Blur.h"
#import "KDRefreshTableView.h"
#import "AppsClient.h"
#import "MBProgressHUD.h"
#import "KDApplicationTableViewCell.h"
#import "BOSSetting.h"

#import "KDAppListDataModel.h"
#import "KDAppDetailViewController.h"
#import "KDTitleNavView.h"
#define RecommendCount          -1      //表示所有
#define kTableviewCellHeight    70.f
#define kSearchbarHeight        44.0f   //搜索栏高度

@interface KDAppSerachViewController ()<KDSearchBarDelegate,KDRefreshTableViewDataSource, KDRefreshTableViewDelegate, MBProgressHUDDelegate, KDApplicationTableViewCellDelegate,KDTitleNavViewDelegate>
{
    AppsClient *recommendAppClient;   //获取推荐应用的通讯客户端
    AppsClient *canUseAppsClient;       //获取本企业可使用应用的通讯客户端
    NSMutableArray *filterAppArr;       //搜索过滤后的应用列表
    NSMutableArray *canUseAppArr;       //本企业可使用的应用列表
    BOOL isOpenBySearching;             //通过搜索框打开本界面
    BOOL searchBtnClicked;              //是否搜索按纽按下过
    
    
    NSMutableDictionary *appDic;       //分类好的app应用列表
    NSMutableArray *appTitleArray;     //分类好的app应用标题列表
}
@property (nonatomic, retain) KDSearchBar *searchBar;
@property (nonatomic, retain) KDRefreshTableView *tableView;
@property (nonatomic, retain) MBProgressHUD *appHud;
@property (nonatomic, retain) KDTitleNavView *titleNavView;
@end

@implementation KDAppSerachViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        filterAppArr = [[NSMutableArray alloc]init];
        canUseAppArr = [[NSMutableArray alloc]init];
        appDic = [[NSMutableDictionary alloc] init];
        appTitleArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (id)initWithSearch
{
    self = [super init];
    if(self)
    {
        isOpenBySearching = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //解决高度上升
//    if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)
//        self.edgesForExtendedLayout=UIRectEdgeNone;
    [self setupView];
    [self setupLeftBarButtonItem];
    [self queryCanUseApplications];
}


-(void)viewDidAppear:(BOOL)animated
{
    //先移除
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openCloudApp" object:nil];
    
    //再添加
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openCloudApp:) name:@"openCloudApp" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!self.isMovingToParentViewController)
    {
        [self setNavigationStyle:KDNavigationStyleNormal];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openCloudApp" object:nil];
}

-(void)openCloudApp:(NSNotification*)notification
{
    KDAppDataModel *appDM = [notification.object objectForKey:@"appDM"];
    if(appDM)
        [self openApp:appDM];
}

- (void)setupLeftBarButtonItem
{
    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    float width = kRightNegativeSpacerWidth;
    negativeSpacer.width = width;
    self.navigationItem.leftBarButtonItems = [NSArray
                                              arrayWithObjects:negativeSpacer,barButtonItem, nil];
}

- (void)back:(UIButton *)button
{
    BOOL cloudAppUrl = [[BOSSetting sharedSetting] getAppstoreurl].length>0;
    
    if(!cloudAppUrl || !self.webVC)
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    
    if ([self.webVC.webView canGoBack])
    {
        [self.webVC.webView goBack];
        return;
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
        
}

- (void) setupView
{
    //self.title = ASLocalizedString(@"KDAppSerachViewController_appstore");
    self.view.backgroundColor = [UIColor kdBackgroundColor1];//BOSCOLORWITHRGBA(0xEDEDED, 1.0);

    if([[BOSSetting sharedSetting] getAppstoreurl].length>0)
    {
        UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:@[ASLocalizedString(@"KDAppSerachViewController_company_app"),ASLocalizedString(@"KDAppSerachViewController_yun_app")]];
        segmentControl.frame = CGRectMake(0, 0, ScreenFullWidth/2, 26);
        segmentControl.tintColor = FC5;
        segmentControl.layer.cornerRadius = 5;
        segmentControl.layer.borderWidth = 1;
        segmentControl.layer.borderColor = segmentControl.tintColor.CGColor;
        segmentControl.layer.masksToBounds = YES;
        segmentControl.selectedSegmentIndex = 0;
        [segmentControl addTarget:self action:@selector(clickTab:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = segmentControl;
    }
    else
        self.title = ASLocalizedString(@"KDAppSerachViewController_appstore");
        
    
    //添加搜索框
    CGFloat offsetY = kd_StatusBarAndNaviHeight;
    CGRect frame = CGRectMake(0.0, offsetY, self.view.bounds.size.width, kSearchbarHeight);
//    UIImage *searchBGImage = [UIImage imageNamed:@"address_book_search_bg_v2.png"];
//    searchBGImage = [searchBGImage stretchableImageWithLeftCapWidth:(searchBGImage.size.width * 0.5)
//                                                       topCapHeight:(searchBGImage.size.height * 0.5)];
//    UIImageView *searchBarBGView = [[UIImageView alloc] initWithImage:searchBGImage];
//    searchBarBGView.frame = frame;
//    searchBarBGView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [self.view addSubview:searchBarBGView];
//    [searchBarBGView release];
    
  //  frame.size.height -= 1.0;
    
    KDSearchBar *searchBar = [[KDSearchBar alloc] initWithFrame:frame];
    self.searchBar = searchBar;
//    [searchBar release];
    
    _searchBar.placeHolder = ASLocalizedString(@"APP_SEARCH_PLACEHOLDER");
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = NO;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_searchBar];
    
  //  frame.size.height += 1.0;
    //添加列表框
    offsetY += frame.size.height;
    frame.origin.y = offsetY;
    frame.size.height = self.view.bounds.size.height - offsetY - kd_BottomSafeAreaHeight;
    _tableView = [[KDRefreshTableView alloc] initWithFrame:frame kdRefreshTableViewType:KDRefreshTableViewType_None];
    _tableView.dataSource = self;
    _tableView.delegate = self;
  //  _tableView.backgroundColor = RGBCOLOR(250,250,250);
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_tableView];
    
    if(isOpenBySearching)
    {
        [_searchBar becomeFirstResponder];
    }
    
    self.titleNavView = [[KDTitleNavView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];// autorelease];
    self.titleNavView.backgroundColor = [UIColor kdBackgroundColor2];
    self.titleNavView.selectedColor = FC5;
    self.titleNavView.titleArray = @[ASLocalizedString(@"KDAppSerachViewController_all")];
    self.titleNavView.delegate = self;
    _tableView.tableHeaderView = self.titleNavView;
}

-(void)clickTab:(UISegmentedControl *)sender
{
    NSLog(@"%zi",sender.selectedSegmentIndex);
    if(sender.selectedSegmentIndex == 1)
    {
        if(!self.webVC)
        {
            NSString *url = [NSString stringWithFormat:@"%@%@",[[BOSSetting sharedSetting] getAppstoreurl],@"/lightapp-store/AppList"];
            self.webVC = [[KDWebViewController alloc] initWithUrlString:url];
//            CGRect frame = self.webVC.view.frame;
//            frame.origin.y = 64;
//            self.webVC.view.frame = frame;
        }
        if(!self.webVC.view.superview)
            [self.view addSubview:self.webVC.view];
    }
    else
    {
        if(self.webVC.view.superview)
            [self.webVC.view removeFromSuperview];
    }
}

- (void) queryCanUseApplications
{
    [canUseAppArr removeAllObjects];
    
    if(canUseAppsClient == nil)
    {
        canUseAppsClient = [[AppsClient alloc] initWithTarget:self action:@selector(queryCanUseAppDidReceived:result:)];
    }
    
    if(_appHud == nil)
    {
        _appHud = [[MBProgressHUD alloc]initWithView:self.view];
        _appHud.labelText = ASLocalizedString(@"KDAppSerachViewController_loading_avaiable_app");
        _appHud.delegate = self;
        [self.view addSubview:_appHud];
        [_appHud show:YES];
    }
    
    [canUseAppsClient getAllApps];
}

- (void)queryRecommendApplications:(NSString *)searchKey
{
    if (recommendAppClient == nil)
    {
        recommendAppClient = [[AppsClient alloc] initWithTarget:self action:@selector(appRecommendationsDidReceived:result:)];
    }
    
    if(_appHud == nil)
    {
        _appHud = [[MBProgressHUD alloc]initWithView:self.view];
        _appHud.labelText = ASLocalizedString(@"KDAppSerachViewController_loading_all_app");
        _appHud.delegate = self;
        [self.view addSubview:_appHud];
        [_appHud show:YES];
    }
    [recommendAppClient searchAppsWithKey:searchKey];
    
}

- (void)appRecommendationsDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    [_appHud hide:YES];
    
    if (client.hasError ||
       (![result isKindOfClass:[BOSResultDataModel class]]) ||
       (!result.success || ![result.data isKindOfClass:[NSDictionary class]]))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationViewController_tips_1")message:ASLocalizedString(@"KDApplicationViewController_network_error")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alertView show];
        return;
    }
    KDAppListDataModel * appList = [[KDAppListDataModel alloc]initWithDictionary:result.data];//autorelease];
    [filterAppArr removeAllObjects];
    [filterAppArr addObjectsFromArray:appList.list];
    [_tableView reloadData];
}

-(void)queryCanUseAppDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    [_appHud hide:YES];
    if (![result isKindOfClass:[BOSResultDataModel class]] || !result.success || ![result.data isKindOfClass:[NSDictionary class]])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationViewController_tips_1")message:ASLocalizedString(@"KDApplicationViewController_network_error")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];// autorelease];
        [alertView show];
    }
    else{
        
        [appDic removeAllObjects];
        [appTitleArray removeAllObjects];
        KDAppListDataModel * appListDM = [[KDAppListDataModel alloc]initWithDictionary:result.data];
        
        __block NSMutableDictionary *appDicInBlcok = appDic;
        [appListDM.list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            KDAppDataModel *app = (KDAppDataModel *)obj;
            
            //添加到分类“全部”
            NSMutableArray *arrayAll = [appDicInBlcok objectForKey:ASLocalizedString(@"KDAppSerachViewController_all")];
            if(!arrayAll)
            {
                arrayAll = [[NSMutableArray alloc] init];
                [appDicInBlcok setObject:arrayAll forKey:ASLocalizedString(@"KDAppSerachViewController_all")];
//                [arrayAll release];
            }
            [arrayAll addObject:app];
            
            //添加到详细分类
            if(app.appClasses)
            {
                [app.appClasses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString *type = (NSString *)obj;
                    if(type.length == 0)
                        return ;
                    NSMutableArray *array  = [appDicInBlcok objectForKey:type];
                    if(!array)
                    {
                        array = [[NSMutableArray alloc] init];
                        [appDicInBlcok setObject:array forKey:type];
//                        [array release];
                    }
                    [array addObject:app];
                }];
            }
        }];
        
        //初始化标题
        __block NSMutableArray *appTitleArrayInBlock = appTitleArray;
        NSArray *titleArray = [result.data objectForKey:@"sortedTypes"];
        [titleArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *title = [obj objectForKey:@"appName"];
            if(title.length == 0)
                return ;
            NSArray *tempArray = [appDic objectForKey:title];
            if(tempArray.count == 0)
                return;
            [appTitleArrayInBlock addObject:title];
        }];
        
        [appTitleArray insertObject:ASLocalizedString(@"KDAppSerachViewController_all")atIndex:0];
        
        self.titleNavView.titleArray = appTitleArray;
        if (appTitleArray.count == 1) {
            _tableView.tableHeaderView = nil;
        } else {
            _tableView.tableHeaderView = self.titleNavView;
        }
        self.titleNavView.currentTitle = ASLocalizedString(@"KDAppSerachViewController_all");
        
        //[canUseAppArr removeAllObjects];
        //[canUseAppArr addObjectsFromArray:appListDM.list];
//        [appListDM release];
        [_tableView reloadData];

    }
}

- (void) openAppDetail:(KDAppDataModel *)appDM
{
    KDAppDetailViewController *appDetailVC = nil;
    appDetailVC = [[KDAppDetailViewController alloc]initWithAppDataModel:appDM];
    appDetailVC.hasFavorite = [self hasFavorite:appDM];
    if (searchBtnClicked == YES) {
        appDetailVC.sourceType = KDAppSourceTypeSearch;
    }
    else{
        appDetailVC.sourceType = KDAppSourceTypeCentre;
    }
    appDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:appDetailVC animated:YES];
//    [appDetailVC release];
}

//是否处于关键字搜索状态
- (BOOL) isSearch
{
    return searchBtnClicked;
}

//应用是否已经被添加到本地啦
- (BOOL)hasFavorite:(KDAppDataModel*)appDM
{
    if(appDM == nil)
        return NO;
    BOOL hasFavorite = NO;
    if (appDM.appType == KDAppTypePublic) {
        for (KDAppDataModel * appDataModel in _favoriteAppArr) {
            if ([appDM.pid isEqualToString:appDataModel.pid]) {
                return YES;
            }
            
        }
    }
    else{
        for (KDAppDataModel * appDataModel in _favoriteAppArr) {
            if ([appDM.appClientID isEqualToString:appDataModel.appClientID]) {
                return YES;
            }
            
        }
        
    }
    
    return hasFavorite;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.appHud.delegate = nil;
    self.appHud = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.tableView = nil;
    self.searchBar.delegate = nil;
    self.searchBar = nil;
    self.titleNavView = nil;
    //KD_RELEASE_SAFELY(filterAppArr);
    //KD_RELEASE_SAFELY(canUseAppArr);
    //KD_RELEASE_SAFELY(appDic);
    //KD_RELEASE_SAFELY(appTitleArray);
    //KD_RELEASE_SAFELY(recommendAppClient);
    //KD_RELEASE_SAFELY(canUseAppsClient);
    //[super dealloc];
}

//=======================================
#pragma mark - KDRefreshTableViewDataSource
//=======================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self isSearch])
        return [filterAppArr count];
    else
        return [canUseAppArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"recommCell2";
    KDApplicationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[KDApplicationTableViewCell alloc] initWithStyleSimple:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        cell.delegate = self;
    }
    KDAppDataModel *appDM = nil;
    if([self isSearch])
        appDM = [filterAppArr objectAtIndex:indexPath.row];
    else
        appDM = [canUseAppArr objectAtIndex:indexPath.row];
    [cell setAppInfo:appDM];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorLineSpace = 81.0;
    cell.isExist = [self hasFavorite:appDM];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableviewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableviewCellHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = RGBCOLOR(250, 250, 250);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
        
    } else {
        KDAppDataModel *appDM = nil;
        if ([self isSearch])
            appDM = [filterAppArr objectAtIndex:indexPath.row];
        else
            appDM = [canUseAppArr objectAtIndex:indexPath.row];
        [self openAppDetail:appDM];
        
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
    [_tableView kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.searchBar resignFirstResponder];
    [_tableView kdRefreshTableviewDidEndDraging:scrollView];
}

//=======================================
#pragma mark KDSearchBarDelegate
//=======================================
- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar
{
    //add
    [KDEventAnalysis event:event_application_add];
    [KDEventAnalysis eventCountly:event_application_add];
    [searchBar resignFirstResponder];
    if ([searchBar.text length] == 0 ) {
        return ;
    }
    searchBtnClicked = YES;
    [self queryRecommendApplications:searchBar.text];
    self.tableView.tableHeaderView = nil;
    [self.tableView reloadData];//这里是为了防止当headerview消失时，加载最后一行时导致溢出
}

- (void)searchBarTextDidBeginEditing:(KDSearchBar *)searchBar
{
    
}

- (void)searchBarTextDidEndEditing:(KDSearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidChange:(KDSearchBar *)searchBar
{
    if([searchBar.text isEqual:@""])
    {
        searchBtnClicked = NO;
        self.tableView.tableHeaderView = self.titleNavView;
        self.titleNavView.currentTitle=ASLocalizedString(@"KDAppSerachViewController_all");
        [_tableView reloadData];
    }
}

//=======================================
#pragma mark - MBProgressHUDDelegate
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
    [self openAppDetail:appDM];
}

-(void)openApp:(KDAppDataModel *)appDM
{
    if(self.openAppDelegate && [self.openAppDelegate respondsToSelector:@selector(goToAppWithDataModel:)])
       [self.openAppDelegate performSelectorOnMainThread:@selector(goToAppWithDataModel:) withObject:appDM waitUntilDone:YES];
}



//=======================================
#pragma mark - KDTitleNavViewDelegate
//=======================================
-(void)clickTitle:(NSString *)title inIndex:(int)index
{
    if([self isSearch])
        return;
    
    NSMutableArray *array = appDic[title];
    [canUseAppArr removeAllObjects];
    [canUseAppArr addObjectsFromArray:array];
    [self.tableView reloadData];
}
@end
