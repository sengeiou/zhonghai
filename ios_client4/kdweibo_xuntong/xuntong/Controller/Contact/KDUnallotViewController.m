//
//  KDUnallotViewController.m
//  kdweibo
//
//  Created by Gil on 15/2/11.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDUnallotViewController.h"
#import "XTContactOrganPersonCell.h"
#import "XTOrgTreeDataModel.h"
//#import "KDDetail.h"
#import "UIButton+XT.h"
#import "XTContactPersonMultipleChoiceCell.h"
#import "BOSConfig.h"
#import "KDWaterMarkAddHelper.h"
#import "XTPersonDetailViewController.h"


@interface KDUnallotViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) NSArray *orgPersons;
@property (nonatomic, strong) NSMutableSet *cellSetForPerson;

@property (nonatomic, strong) XTOpenSystemClient *orgClient;
@property (nonatomic, strong) XTOrgTreeDataModel *orgTreeData;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

//static const NSString *unallotPersonsOrgId = @"unallotPersons";

@implementation KDUnallotViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ASLocalizedString(@"KDChooseOrganizationViewController_UnallocaledPerson");
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    self.cellSetForPerson = [NSMutableSet set];
    
    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    [self.navigationItem.leftBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
    
    if (!self.selectedPersonsView) {
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Close")style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
        self.navigationItem.rightBarButtonItem = closeItem;
        [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 68.0f;
    [self.view addSubview:self.tableView];
    
//    _orgPersons = [NSArray new];
//    [self orgTreeInfo];
     [self.tableView reloadData];
    if ([[BOSSetting sharedSetting] openWaterMark:WaterMarkTypeContact]) {
        if (self.tableView.contentSize.height > ScreenFullHeight) {
            CGRect frame = CGRectMake(0, 0, ScreenFullWidth, ScreenFullHeight);
            [KDWaterMarkAddHelper coverOnView:self.view withFrame:frame];
        }
        else {
            [KDWaterMarkAddHelper coverOnView:self.view withFrame:self.view.frame];
        }
    }
    else {
        if (self.tableView.contentSize.height > ScreenFullHeight) {
            [KDWaterMarkAddHelper removeWaterMarkFromView:self.view];
        }
        else {
            [KDWaterMarkAddHelper removeWaterMarkFromView:self.tableView];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"unallotViewControllerReload" object:nil];

}

- (void)reloadTable {
    [self.tableView reloadData];
}

- (void)back
{
    NSArray *array = self.navigationController.viewControllers;
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close:(UIButton *)btn
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (MBProgressHUD *)hud {
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    return _hud;
}


#pragma mark - NetWork 

//- (XTOpenSystemClient *)orgClient {
//    if (_orgClient == nil) {
//        _orgClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(orgTreeInfoDidReceived:result:)];
//    }
//    return _orgClient;
//}
//
//
//- (void)orgTreeInfo {
//    
//    [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Waiting")];
//    [self.hud setMode:MBProgressHUDModeIndeterminate];
//    [self.hud show:YES];
//    
////    [self.orgClient getOrgCasvirPersonsWithOrgId:@"unallotPersons"];
//}
//
//
//- (void)orgTreeInfoDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result {
//  
//    if (client.hasError || ![result isKindOfClass:[BOSResultDataModel class]] || !result.success) {
//        NSString *error = ASLocalizedString(@"操作失败");
//        
//        if (client.hasError) {
//            error = client.errorMessage;
//        }
//        else {
//            if ([result isKindOfClass:[BOSResultDataModel class]]) {
//                error = result.error;
//            }
//        }
//        [self.hud setLabelText:error];
//        [self.hud setMode:MBProgressHUDModeText];
//        [self.hud hide:YES afterDelay:1.0];
//        return;
//    }
//    
//    [self.hud hide:YES];
//    
//    
//    XTOrgTreeDataModel *orgTreeDM = [[XTOrgTreeDataModel alloc] initWithDictionary:result.data];
//        self.orgTreeData = orgTreeDM;
//    
//    [self filterOrgTreeData];
//    self.orgPersons = self.orgTreeData.unallotPersons;
//    [self.tableView reloadData];
//    
////    if ([[BOSSetting sharedSetting] openWaterMark]) {
////        if (self.tableView.contentSize.height > ScreenFullHeight) {
////            CGRect frame = CGRectMake(0, 0, ScreenFullWidth, ScreenFullHeight);
////            [KDWaterMarkAddHelper coverOnView:self.view withFrame:frame];
////        }
////        else {
////            CGRect frame = CGRectMake(0, 0, ScreenFullWidth, self.tableView.contentSize.height);
////            [KDWaterMarkAddHelper coverOnView:self.tableView withFrame:frame];
////        }
////    }
////    else {
////        if (self.tableView.contentSize.height > ScreenFullHeight) {
////            [KDWaterMarkAddHelper removeWaterMarkFromView:self.view];
////        }
////        else {
////            [KDWaterMarkAddHelper removeWaterMarkFromView:self.tableView];
////        }
////    }
//}

- (void)setOrgPersons:(NSArray *)orgPersons
{
    if ([orgPersons count] > 0) {
//        [self filterOrgTreeData];
        _orgPersons = orgPersons;
       
    }

}

#pragma mark filter

- (void)filterOrgTreeData {
    if (_blockCurrentUser) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF == %@)", [BOSConfig sharedConfig].user.userId];
        NSArray *filterArray = [self.orgTreeData.personIds filteredArrayUsingPredicate:predicate];
        self.orgTreeData.personIds = filterArray;
        
        if ([self.orgTreeData.unallotPersons count] > 0) {
            NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"personId != %@", [BOSConfig sharedConfig].user.userId];
            NSArray *filterArray2 = [self.orgTreeData.unallotPersons filteredArrayUsingPredicate:predicate2];
            self.orgTreeData.unallotPersons = filterArray2;
        }
    }
}


#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_orgPersons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XTOrgPersonDataModel *orgPerson = nil;
    PersonSimpleDataModel *person = nil;
    
    if ([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]) {
        person = [_orgPersons objectAtIndex:indexPath.row];;
    }else
    {
        orgPerson = [_orgPersons objectAtIndex:indexPath.row];
        person = [KDCacheHelper personForKey:orgPerson.personId];
        if (person) {
            person.jobTitle = orgPerson.job;
        }
        //        if (orgPerson.isPartJob == 1) {
        //            person.jobTitle = orgPerson.job;
        //        }
        
    }
    
    if (self.selectedPersonsView) {
        //人员
        static NSString *CellIdentifier = @"cell-identifier";
        XTContactPersonMultipleChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[XTContactPersonMultipleChoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.separateLineSpace = KDTableViewCellSeparatorLineSpace;
            cell.showGrayStyle = YES;
            cell.isFromTask = self.selectedPersonsView.isFromTask;
        }
        
        if (person) {
            //            person.jobTitle = orgPerson.job;
            [cell setPerson:person];
            cell.checked = [self.selectedPersonsView.persons containsObject:person];
        }
        
        [self.cellSetForPerson addObject:cell];
        return cell;
    }
    
    static NSString *LeafCellIdentifier = @"LeafCellIdentifier";
    XTContactOrganPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:LeafCellIdentifier];
    if (cell == nil) {
        cell = [[XTContactOrganPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LeafCellIdentifier];
    }
    
    
    if (person) {
        //        person.jobTitle = orgPerson.job;
        [cell setPerson:person];
    }
    
    if (person.isPartJob == 1) {
        //                cell.showParttimeJob = YES;
        //        person.jobTitle = orgPerson.job;
    }else{
        cell.showParttimeJob = NO;
    }
    cell.separatorLineStyle = (indexPath.row == [_orgPersons count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
    
    [self.cellSetForPerson addObject:cell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XTOrgPersonDataModel *orgPerson = [self.orgPersons objectAtIndex:indexPath.row];
    PersonSimpleDataModel *person = [KDCacheHelper personForKey:orgPerson.personId];
//    PersonSimpleDataModel *person = [KDCacheHelper personForKey:orgPerson.personId];
//    
//    if (person == nil) {
//        return;
//    }
    
    if (orgPerson && !person) { //缓存找不到此人，但组织架构有此人
        person = (PersonSimpleDataModel *)orgPerson;
    }
    
    //未激活不给点
    if((![BOSSetting sharedSetting].supportNotMobile || self.selectedPersonsView.isFromTask) &&![person xtAvailable] && self.selectedPersonsView)
        return;
    
    if (self.selectedPersonsView) {
        XTContactPersonMultipleChoiceCell *cell = (XTContactPersonMultipleChoiceCell *)[tableView cellForRowAtIndexPath:indexPath];
        BOOL checked = cell.checked;
        
        //单选判断的操作
        if (checked == NO && self.selectedPersonsView.isMult == NO && [self.selectedPersonsView.persons count] > 0) {
            // bug 4260
            return;
            
//            [self.cellSetForPerson enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
//             {
//                 if ([obj respondsToSelector:@selector(setChecked:)])
//                 {
//                     [obj setChecked:NO];
//                 }
//             }];

        }
        cell.checked = !checked;
        
        if (checked)
        {
            [self.selectedPersonsView deletePerson:person];
        }
        else
        {
            if (checked == NO && self.selectedPersonsView.isMult == NO)
            {
                [self.selectedPersonsView deleteAllPerson];
                [self.selectedPersonsView addPerson:person];
            }
            else
            {
                [self.selectedPersonsView addPerson:person];
            }
        }
        return;
    }
    XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc]initWithSimplePerson:person with:NO];
    personDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personDetail animated:YES];

//    [KDDetail toDetailWithPerson:person inController:self];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"unallotViewControllerReload" object:nil];
}

@end
