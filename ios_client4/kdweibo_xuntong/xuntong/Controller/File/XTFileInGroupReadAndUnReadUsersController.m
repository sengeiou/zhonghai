//
//  XTFileInGroupReadAndUnReadUsersController.m
//  kdweibo
//
//  Created by lichao_liu on 15/3/9.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "XTFileInGroupReadAndUnReadUsersController.h"
#import "XTPersonsCollectionViewCell.h"
//#import "KDDetail.h"
#import "XTWbClient.h"
#import "MJRefresh.h"
#import "XTPersonDetailViewController.h"

NSInteger const KDPageCollectionPageSize = 50;
NSString *const MJCollectionViewCellIdentifier = @"collectionViewCellIdentifier";


@interface XTFileInGroupReadAndUnReadUsersController()<UICollectionViewDataSource,UICollectionViewDelegate,XTPersonHeaderViewDelegate>
@property (nonatomic, strong) XTWbClient *client;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation XTFileInGroupReadAndUnReadUsersController

- (void)dealloc {
    //[_client cancelRequest];
}

- (NSMutableArray *)personArray
{
    if(!_personArray)
    {
        _personArray = [NSMutableArray new];
    }
    return _personArray;
}

- (XTWbClient *)client
{
    if(!_client)
    {
        _client = [[XTWbClient alloc] initWithTarget:self action:@selector(showAllReadUsers:result:)];
        
    }
    return _client;
}

- (void)loadView{
    
    [super loadView];
    self.view.backgroundColor = [UIColor kdBackgroundColor2];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(48, 64);
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 0, 20);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
}

- (void)queryReadUsersWithPageIndex:(NSInteger)pageIndex
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MBProgressHUD HUDForView:self.view].labelText = ASLocalizedString(@"XTPersonalFilesController_Wait");
    [self.client showAllReadUsersWithFileId:self.fileId networkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId threadId:self.threadId pageIndex:pageIndex pageSize:KDPageCollectionPageSize desc:@"desc" messageId:self.messageId];
}

- (void)showAllReadUsers:(XTWbClient *)client result:(BOSResultDataModel *)result
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.collectionView headerEndRefreshing];
    [self.collectionView footerEndRefreshing];
    if (client.hasError)
    {
        
    }
    else {
        if (!result.success)
        {
            
        }
        else
        {
            if(self.pageIndex == 0)
            {
                if(self.personArray && self.personArray.count>0)
                {
                    [self.personArray removeAllObjects];
                }
            }

            
            NSArray *userIdArray = result.data;
            if(userIdArray && ![userIdArray isKindOfClass:[NSNull class]] && userIdArray.count>0)
            {
                NSMutableArray *userSimpleArray = [NSMutableArray array];
                [userIdArray enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
                    PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
                    person.wbUserId = [obj objectForKey:@"userId"];
                    person.personId = [obj objectForKey:@"personId"];
                    person.personName = [obj objectForKey:@"name"];
                    person.photoUrl = [obj objectForKey:@"photoUrl"];
                    BOOL isOpen = [[obj objectForKey:@"hasOpened"] boolValue];
                    if(isOpen)
                        person.status = 3;
                    else
                        person.status = 7;
                    [userSimpleArray addObject:person];
                }];
                
                NSArray *users = userSimpleArray;//[[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithWbPersonIds:userIdArray];
                if(users && users.count>0)
                {
                    [self.personArray addObjectsFromArray:users];
                    if(self.personArray.count >= (self.pageIndex + 1) * KDPageCollectionPageSize)
                    {
                        if(self.pageIndex == 0)
                        {
                            [self addFooter];
                        }
                    }else{
                        [self.collectionView removeFooter];
                    }
                }
                else{
                    if(self.personArray && self.personArray.count>=KDPageCollectionPageSize)
                    {
                        [self.collectionView removeFooter];
                    }
                }
            }
        }
        
    }
    [self.collectionView reloadData];
    if(self.personArray && self.personArray.count == 0)
    {
        [self setBackgroud:YES];
    }else{
        [self setBackgroud: NO];
    }
}

- (void)refreshData
{
    self.pageIndex = 0;
    [self queryReadUsersWithPageIndex:self.pageIndex];
}

- (void)loadMore
{
    self.pageIndex ++;
    [self queryReadUsersWithPageIndex:self.pageIndex];
}

- (void) setBackgroud:(BOOL)isLoad {
    
    if (!isLoad) {
        _backgroundView.hidden = YES;
        return;
    }
    
    if (!_backgroundView) {
        
        _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _backgroundView.backgroundColor = [UIColor clearColor];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud"]];
        [bgImageView sizeToFit];
        bgImageView.center = CGPointMake(_backgroundView.bounds.size.width * 0.5f, 137.5f);
        
        [_backgroundView addSubview:bgImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(bgImageView.frame) + 15.0f, self.view.bounds.size.width, 38.0f)];
        label.numberOfLines = 0;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont kdFont4];
        label.textColor = [UIColor kdTextColor2];
        label.text = ASLocalizedString(@"XTFileInGroupReadAndUnReadUsersController_Tip_1");
        
        [_backgroundView addSubview:label];
        
        [self.collectionView addSubview:_backgroundView];
    }
    _backgroundView.hidden = NO;
    
}

- (void)viewDidLoad
{
     [super viewDidLoad];
     self.title = ASLocalizedString(@"XTFileInGroupReadAndUnReadUsersController_Tip_2");
     [self setupCollectionView];
     [self addHeader];
    
    UIButton *backBtn = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setNavigationStyle:KDNavigationStyleYellow];
}

-(void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)setupCollectionView
{
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[XTPersonsCollectionViewCell class] forCellWithReuseIdentifier:MJCollectionViewCellIdentifier];
}

- (void)addHeader
{
    __weak XTFileInGroupReadAndUnReadUsersController * vc = self;
    [self.collectionView addHeaderWithCallback:^{
        [vc refreshData];
    }];
    [self.collectionView headerBeginRefreshing];
}

- (void)addFooter
{
    __weak XTFileInGroupReadAndUnReadUsersController * vc = self;
    [self.collectionView addFooterWithCallback:^{
        [vc loadMore];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.personArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XTPersonsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MJCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.userInteractionEnabled = YES;
    cell.personSimpleModel = self.personArray[indexPath.row];
    cell.deleteDelegate = self;
    return cell;
}

#pragma mark
- (void)personHeaderClicked:(XTPersonHeaderView *)headerView person:(PersonSimpleDataModel *)person
{
   //[KDDetail toDetailWithPerson:person inController:self];
    XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:person with:NO];
    personDetail.isFromWeibo = YES;
    personDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personDetail animated:YES];
}
@end
