//
//  RecommendTableView.m
//  EMPNativeContainer
//
//  Created by Gil on 13-3-15.
//  Copyright (c) 2013年 Kingdee.com. All rights reserved.
//

#import "RecommendViewController.h"
#import "RecommendAppListCell.h"
#import "MCloudClient.h"
#import "RecommendAppDetailViewController.h"
#import "BOSImageNames.h"

#define RecommendCount 20

@interface RecommendViewController ()
@property (nonatomic,retain) UITableView *recommendTableView;
@property (nonatomic,retain) MCloudClient *recommendClient;
@property (nonatomic,retain) MBProgressHUD *recommendHud;
@property (nonatomic,assign) int begin;
@property (nonatomic,assign) BOOL end;
@property (nonatomic,retain) NSMutableArray *recommendList;
@end

@implementation RecommendViewController

- (id)initWithRecommendType:(RecommendType)type
{
    self = [super init];
    if (self) {
        _type = type;
        _begin = 0;
        _end = YES;
        _recommendList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    if (_type == RecommendTypeField) {
        self.navigationItem.title = ASLocalizedString(@"RecommendAppDetailViewController_Recommend");
    }else{
        self.navigationItem.title = ASLocalizedString(@"RecommendViewController_All");
    }

    
    if (_type == RecommendTypeField) {
        UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [otherButton setBackgroundImage:[UIImage imageNamed:IMAGE_BUTTON_NAVDONE] forState:UIControlStateNormal];
        [otherButton setBackgroundImage:[UIImage imageNamed:IMAGE_BUTTON_NAVDONE_HIGHLIGHT] forState:UIControlStateHighlighted];
        [otherButton setFrame:CGRectMake(0.0, 0.0, 50, 30)];
        [otherButton setTitle:ASLocalizedString(@"KDAppSerachViewController_all")forState:UIControlStateNormal];
        [otherButton addTarget:self action:@selector(other) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *otherItem = [[UIBarButtonItem alloc] initWithCustomView:otherButton];
        self.navigationItem.rightBarButtonItem = otherItem;
//        [otherItem release];
    }
    
    CGRect frame = self.view.bounds;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            frame.size.width = 768;
            frame.size.height = 1004;
        }else{
            frame.size.width = 1024;
            frame.size.height = 748;
        }
    }
    frame.size.height -= 44.0;
    
    _recommendTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _recommendTableView.backgroundColor = [UIColor clearColor];
    _recommendTableView.delegate = self;
    _recommendTableView.dataSource = self;
    [self.view addSubview:_recommendTableView];
    
    [self appRecommendations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //BOSRELEASE_recommendTableView);
    //BOSRELEASE_recommendClient);
    //BOSRELEASE_recommendList);
    //BOSRELEASE_recommendHud);
    //[super dealloc];
}

//- (void)back
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

#pragma mark - appRecommendations

- (void)appRecommendations
{
    if (_recommendClient == nil) {
        _recommendClient = [[MCloudClient alloc] initWithTarget:self action:@selector(appRecommendationsDidReceived:result:)];
    }
    if (_recommendHud == nil) {
        _recommendHud = [[MBProgressHUD alloc] initWithView:self.view];
        _recommendHud.labelText = ASLocalizedString(@"RefreshTableFootView_Loading");
        _recommendHud.delegate = self;
        [self.view addSubview:_recommendHud];
        [_recommendHud show:YES];
    }
    [_recommendClient appRecommendationsWithType:_type begin:_begin count:RecommendCount];
}

- (void)appRecommendationsDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    [_recommendHud hide:YES];
    
    if (client.hasError) {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (!result.success || ![result.data isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    RecommendAppListDataModel *appList = [[RecommendAppListDataModel alloc] initWithDictionary:result.data type:RecommendAppDataModelType];// autorelease];
    _begin += RecommendCount;
    _end = appList.end;
    [_recommendList addObjectsFromArray:appList.list];
    [_recommendTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _end ? [_recommendList count] : [_recommendList count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RecommendAppListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RecommendAppListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
    }
    
    if (indexPath.row == [_recommendList count]) {
        [cell setAppInfo:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        RecommendAppDataModel *app = [_recommendList objectAtIndex:indexPath.row];
        [cell setAppInfo:app];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [_recommendList count]) {
        return 44.0;
    }
    return 88.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_recommendList count]) {
        RecommendAppDataModel *app = [_recommendList objectAtIndex:indexPath.row];
        if (app.detailURL != nil && ![@"" isEqualToString:app.detailURL]) {
            self.hidesBottomBarWhenPushed = YES;
            RecommendAppDetailViewController *detail = [[RecommendAppDetailViewController alloc] initWithRecommendAppDataModel:app];// autorelease];
            [self.navigationController pushViewController:detail animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [_recommendList count])
    {
        [self appRecommendations];
    }
    return;
}

#pragma mark - other

- (void)other
{
    self.hidesBottomBarWhenPushed = YES;
    RecommendViewController *recommend = [[RecommendViewController alloc] initWithRecommendType:RecommendTypeOther];// autorelease];
    [self.navigationController pushViewController:recommend animated:YES];
}

#pragma mark - MBHUD

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    hud = nil;
}

@end
