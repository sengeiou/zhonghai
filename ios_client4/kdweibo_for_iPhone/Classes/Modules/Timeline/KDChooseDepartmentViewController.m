//
//  KDChooseDepartmentViewController.m
//  kdweibo
//
//  Created by DarrenZheng on 14-7-10.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDChooseDepartmentViewController.h"
#import "KDChooseDepartmentTableViewCell.h"
#import "BOSConfig.h"
#import "KDChooseDepartmentBottomBarView.h"
#import "NSDictionary+Additions.h"
#import "KDNotOrganizationView.h"
//#import "KDAddOrganiztionViewController.h"

//#import "KDProfileViewController.h"
#import "MBProgressHUD+Add.h"
#import "KDOrganizationSelectView.h"
#import "KDWebViewController.h"
#import "KDTableViewHeaderFooterView.h"

@interface KDChooseDepartmentViewController ()
<UITableViewDataSource, UITableViewDelegate, KDChooseDepartmentTableViewCellDelegate, KDChooseDepartmentBottomBarViewDelegate, UIAlertViewDelegate , KDOrganizationSelectViewDataDelegate , KDOrganizationSelectViewDelegate>


@property (strong, nonatomic)  UITableView *tableViewMain;

@property(nonatomic, strong) NSMutableArray *mArrayFiltedData;
@property(nonatomic, strong) XTOpenSystemClient *client;
@property(nonatomic, assign) BOOL bIsRootVC;
@property(nonatomic, assign) int iClassNumber;

@property (strong , nonatomic) KDOrganizationSelectView *organiztionSelectView;
@property (strong , nonatomic) UILabel *rootCompanyLab;
@property (strong , nonatomic) UIView *headerContentView;
@property (strong , nonatomic) KDChooseDepartmentBottomBarView *bottomView;   //底部view
@property (strong , nonatomic) UIBarButtonItem *backButtonItem;
@property (strong , nonatomic) NSMutableArray *organiztionStack;    //部门跳转路径队列
@property (nonatomic, strong) NSMutableArray *selectedDepModels;    //选中的部门队列
@property (strong , nonatomic) KDChooseDepartmentModel *lastCheckModel;

@property (strong , nonatomic) KDNotOrganizationView *notOrgView;

@end


@implementation KDChooseDepartmentViewController


- (void)dealloc {
    [_client cancelRequest];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _organiztionStack = [[NSMutableArray alloc] init];
    KDChooseDepartmentModel *root = [[KDChooseDepartmentModel alloc] init];
    root.strName = [BOSConfig sharedConfig].user.companyName;
    [_organiztionStack addObject:root];
    self.title = ASLocalizedString(@"组织架构");
    //    _selectedDepModels = [[NSMutableArray alloc] init];
    [self.view setBackgroundColor:[UIColor kdBackgroundColor1]];
    [self.view addSubview:self.headerContentView];
    
    if (self.fromType == KDChooseDepartmentVCFromType_SelectAppPermission) {
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"关闭") style:UIBarButtonItemStylePlain target:self action:@selector(closeAction:)];
        self.navigationItem.rightBarButtonItem = closeItem;
        
    } else {
        self.navigationItem.leftBarButtonItem = self.backButtonItem;
    }
    
    [self.view addSubview:self.tableViewMain];
    [self.view addSubview:self.bottomView];
    [self masMake];
    
    self.iClassNumber = 0;
    [self getOrgById:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)masMake {
    [self.headerContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).with.offset(20.0);
        make.left.right.mas_equalTo(self.view).with.offset(0);
        make.height.mas_equalTo(48);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.left.right.bottom.mas_equalTo(self.view).with.offset(0);
    }];
    
    [self.tableViewMain mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerContentView.bottom).with.offset(0);
        make.left.right.mas_equalTo(self.view).with.offset(0);
        make.bottom.mas_equalTo(self.bottomView.top).with.offset(0);
    }];
}


#pragma mark - Util
- (void)updateDepartmentChecked {
    for (KDChooseDepartmentModel *dep in self.mArrayFiltedData) {
        for (KDChooseDepartmentModel *alreadyChooseDep in self.selectedDepModels) {
            if ([dep isEqual:alreadyChooseDep]) {
                dep.checked = YES;
                break;
            }
        }
    }
}

/**
 *  跳转部门
 *
 *  @param parentModel 表示跳转的部门model,parentModel= nil 表示根组织
 */
- (void)changeDepartmentWithParentModel:(KDChooseDepartmentModel *)parentModel {
    self.parentModel = parentModel;
    
    if (!self.bIsRootVC) {
        self.title = self.parentModel.strName;
        self.cacheLongName = [self.cacheLongName stringByAppendingString:[self.parentModel.strName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        self.cacheLongName = [self.cacheLongName stringByAppendingString:@"!"];
        [self.mArrayFiltedData removeAllObjects];
        [self getOrgById:parentModel.strID];
        self.organiztionSelectView.hidden = NO;
        self.rootCompanyLab.hidden = YES;
        
        if (self.fromType == KDChooseDepartmentVCFromType_SelectAppPermission) {
            self.navigationItem.leftBarButtonItem = self.backButtonItem;
        }
    }
    else {
        self.title = ASLocalizedString(@"组织架构");
        [self.mArrayFiltedData removeAllObjects];
        [self getOrgById:nil];
        self.organiztionSelectView.hidden = YES;
        self.rootCompanyLab.hidden = NO;
        
        if (self.fromType == KDChooseDepartmentVCFromType_SelectAppPermission) {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    [self.organiztionSelectView reloadData];
}

/**
 *  是否选中当前所有部门（全选）
 */
- (BOOL)isSelectCurrentAllDepartmentModel {
    if ([self bIsRootVC]) return NO;
    for (KDChooseDepartmentModel *dep in self.mArrayFiltedData) {
        if (dep.checked == NO) {
            return NO;
        }
    }
    return YES;
}

/**
 *  全选或者取消全选
 */
- (void)selectOrDeselectAllDepartment:(BOOL)select {
    for (KDChooseDepartmentModel *dep in self.mArrayFiltedData) {
        dep.checked = select;
    }
    if (select) {
        for (KDChooseDepartmentModel *mode in self.mArrayFiltedData) {
            if (![_selectedDepModels containsObject:mode]) {
                [_selectedDepModels addObject:mode];
            }
        }
    }
    else {
        for (KDChooseDepartmentModel *mode in self.mArrayFiltedData) {
            if ([_selectedDepModels containsObject:mode]) {
                [_selectedDepModels removeObject:mode];
            }
        }
    }
    [self.bottomView reloadDataWithDepartments:_selectedDepModels];
    [self.tableViewMain reloadData];
}

/**
 *  选择部门（单选），不支持取消选择
 *
 *  @param model 所选部门model
 */
- (void)selectDepartment:(KDChooseDepartmentModel *)model {
    if (_lastCheckModel) _lastCheckModel.checked = NO;
    model.checked = YES;
    _lastCheckModel = model;
    [_selectedDepModels removeAllObjects];
    [_selectedDepModels addObject:model];
    [self.bottomView reloadDataWithDepartments:_selectedDepModels];
    [self.tableViewMain reloadData];
}

/**
 *  选择或取消选择部门（多选）
 *
 *  @param model 所选部门model
 */
- (void)selectOrDeselectDepartment:(KDChooseDepartmentModel *)model {
    if (!model) return;
    if (!model.checked) {
        [_selectedDepModels addObject:model];
    }
    else {
        [_selectedDepModels removeObject:model];
    }
    model.checked = !model.checked;
    [self.bottomView reloadDataWithDepartments:_selectedDepModels];
    [self.tableViewMain reloadData];
}

#pragma mark - Event Response
- (void)backAction:(UIButton *)button {
    if (self.bIsRootVC) {
        if ([self.rt_navigationController.viewControllers count] == 1) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else {
        self.iClassNumber--;
        [_organiztionStack removeLastObject];
        KDChooseDepartmentModel *model = _organiztionStack.lastObject;
        if (self.bIsRootVC) {
            model = nil;
        }
        [self changeDepartmentWithParentModel:model];
    }
}

- (void)closeAction:(UIButton *)button {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View Datasource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isMulti  && !self.bIsRootVC) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isMulti && !self.bIsRootVC && section == 0) {
        return 1;
    }
    return self.mArrayFiltedData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *departCellID = @"DepartCellID";
    KDChooseDepartmentTableViewCell *cell = (KDChooseDepartmentTableViewCell *) [tableView dequeueReusableCellWithIdentifier:departCellID];
    if (!cell) {
        cell = [[KDChooseDepartmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:departCellID];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ( self.isMulti && indexPath.section == 0 && !self.bIsRootVC) {
        //全选cell
        cell.labelDepartment.text = ASLocalizedString(@"全选");
        cell.labelPersonCount.text = nil;
        cell.bShouldShowAccessoryIndicator = NO;
        cell.checked = [self isSelectCurrentAllDepartmentModel];
        cell.accessoryStyle = KDTableViewCellAccessoryStyleNone;
        cell.separatorLineStyle = KDTableViewCellSeparatorLineTop;
    }
    else {
        KDChooseDepartmentModel *model = self.mArrayFiltedData[indexPath.row];
        cell.labelDepartment.text = model.strName;
        
        //        if (self.fromType == KDChooseDepartmentVCFromType_JSBridge) {
        //            cell.labelPersonCount.text = (model.personCount > 0) ? [NSString stringWithFormat:@"%ld",model.personCount] : nil;
        //        }
        cell.labelPersonCount.text = (model.personCount >= 0) ? [NSString stringWithFormat:@"%ld",(long)model.personCount] : nil;
        
        if (model.checked) {
            cell.checked = YES;
        }
        else {
            cell.checked = NO;
        }
        cell.index = (int) indexPath.row;
        cell.model = model;
        cell.bShouldShowAccessoryIndicator = !model.bIsLeaf;
        
        if(indexPath.row +1 == self.mArrayFiltedData.count)
        {
            cell.separatorLineStyle = KDTableViewCellSeparatorLineTop;
        }else{
            cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        }
        if (!model.bIsLeaf) {
            cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
        }
        else
        {
            cell.accessoryStyle = KDTableViewCellAccessoryStyleNone;
        }
        
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KDChooseDepartmentTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.isMulti && indexPath.section == 0 && !self.bIsRootVC){
        //全选cell
        [self selectOrDeselectAllDepartment:!cell.checked];
    }
    else {
        KDChooseDepartmentModel *model = self.mArrayFiltedData[indexPath.row];
        if (!model.bIsLeaf) {
            _iClassNumber++;
            [self.organiztionStack addObject:model];
            [self changeDepartmentWithParentModel:model];
        }
        else {
            if(self.isMulti) {
                [self selectOrDeselectDepartment:model];
            }
            else {
                [self selectDepartment:model];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.fromType == KDChooseDepartmentVCFromType_Native) {
        return [KDTableViewHeaderFooterView heightWithStyle:KDTableViewHeaderFooterViewStyleGrayWhite];
    }
    else if (self.isMulti && section == 1) {
        return 8;
    }
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (self.fromType == KDChooseDepartmentVCFromType_Native) {
        KDTableViewHeaderFooterView *view = [[KDTableViewHeaderFooterView alloc] initWithStyle:KDTableViewHeaderFooterViewStyleGrayWhite];
        view.title = ASLocalizedString(@"从以下组织选择");
        return view;
    }
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - Cell Delegate

- (void)buttonCheckboxPressed:(KDChooseDepartmentModel *)model index:(NSInteger)modelIndex title:(NSString *)title{
    if ([title isEqualToString:ASLocalizedString(@"全选")]) {
        if ([self isSelectCurrentAllDepartmentModel]) {
            [self selectOrDeselectAllDepartment:NO];
        }
        else {
            [self selectOrDeselectAllDepartment:YES];
        }
        [self.tableViewMain reloadData];
        return ;
    }
    if (_isMulti == NO) {
        [self selectDepartment:model];
    }
    else {
        [self selectOrDeselectDepartment:model];
    }
    
}


#pragma mark - bottom view delegate

- (void)buttonConfirmPressed {
    KDChooseDepartmentModel *model = self.bottomView.departmentModels[0];
    if (model) {
        //[self.navigationController popToViewController:AppWindowControllers[2] animated:YES];
        
        self.cacheLongName = [self.cacheLongName stringByAppendingString:[model.strName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        if (self.fromType != KDChooseDepartmentVCFromType_EditPerson && self.delegate && [self.delegate respondsToSelector:@selector(didChooseDepartmentModels:longName:)])
        {
            //管理员在"我"页面设置部门
//            if ([self.delegate isKindOfClass:[KDProfileViewController class]] || [self.delegate isKindOfClass:[KDWebViewController class]] || [self.delegate isKindOfClass:[KDCreateSignInGroupViewController class]] || self.fromType == KDChooseDepartmentVCFromType_SelectAppPermission)
//            {
//                [self.delegate didChooseDepartmentModels:self.bottomView.departmentModels longName:self.cacheLongName];
//                [self dismissSelf];
//                return;
//            }
            
//            NSString *tip = ASLocalizedString(@"确定调动当前人员部门?");
//            if (_isPartTime) {
//                tip = ASLocalizedString(@"确定兼职当前部门?");
//            }
//            //部门调动
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"温馨提示") message:tip delegate:self cancelButtonTitle:ASLocalizedString(@"取消") otherButtonTitles:ASLocalizedString(@"确定"), nil];
//            alert.tag = 10002;
//            [alert show];
            
            
            if (self.fromType == KDChooseDepartmentVCFromType_EditPerson) {
                [self.delegate didChooseDepartmentForEditPer:_bottomView.departmentModels longName:self.cacheLongName];
            }
            else{
                [self.delegate didChooseDepartmentModels:_bottomView.departmentModels longName:self.cacheLongName];
            }
            
            if ([self.delegate isKindOfClass:[UIViewController class]]) {
                [self.navigationController popToViewController:(UIViewController *) self.delegate animated:YES];
            }
            else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
            
            return;
        }
        
        if (self.fromType == KDChooseDepartmentVCFromType_EditPerson && self.delegate && [self.delegate respondsToSelector:@selector(didChooseDepartmentForEditPer:longName:)]) {
            
            NSString *tip = ASLocalizedString(@"确定兼职当前部门?");
            
            //部门调动
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"温馨提示") message:tip delegate:self cancelButtonTitle:ASLocalizedString(@"取消") otherButtonTitles:ASLocalizedString(@"确定"), nil];
            alert.tag = 10002;
            [alert show];
            return;
        }
    }
}

- (void)dismissSelf {
    if ([self.rt_navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - 请求组织结构回调

- (void)getOrgById:(NSString *)orgid {
    if (_client == nil) {
        _client = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getChildredOrgByOrgIdDidReceive:result:)];
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //签到迁移，暂时屏蔽
    [_client getOrgByOrgID:orgid];
}

- (void)getChildredOrgByOrgIdDidReceive:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (client.hasError || !result || ![result isKindOfClass:[BOSResultDataModel class]] || !result.success) {
        NSString *error = ASLocalizedString(@"获取组织架构失败");
        if (client.hasError) {
            error = client.errorMessage;
        }
        else if ([result isKindOfClass:[BOSResultDataModel class]] && result.error.length > 0) {
            error = result.error;
        }
        UIAlertView *alrert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:nil cancelButtonTitle:ASLocalizedString(@"确定") otherButtonTitles:nil];
        [alrert show];
        return;
    }
    
    NSMutableArray *mArrayData = [NSMutableArray new];
    for (NSDictionary *dict in result.data) {
        KDChooseDepartmentModel *model = [[KDChooseDepartmentModel alloc] initWithDictionary:dict];
        [mArrayData addObject:model];
    }
    
    self.mArrayFiltedData = mArrayData;
    [self updateDepartmentChecked];
//签到迁移，暂时屏蔽
//    if ([self.mArrayFiltedData count] == 0) {
//        UserDataModel *currentUser = [BOSConfig sharedConfig].user;
//        _notOrgView = [[KDNotOrganizationView alloc] initWithFrame:self.view.bounds style:ContactStyleShowRecently isAdmin:currentUser.isAdmin isCustomer:NO];
//        if (currentUser.isAdmin == YES) {
//            __weak KDChooseDepartmentViewController *weakVC = self;
//            [_notOrgView setHandleBlock:^{
//                [weakVC addOrganiztion];
//            }];
//        }
//        
//        [self.view addSubview:_notOrgView];
//    }
    [self.tableViewMain reloadData];
}

//- (void)addOrganiztion
//{
//    KDAddOrganiztionViewController *viewController = [[KDAddOrganiztionViewController alloc]initWithNibName:@"KDAddOrganiztionViewController" bundle:nil];
//    [viewController addOrgWithParentId:@"" getResultBlock:^(BOOL succcess) {
//        if (succcess) {
//            [self getOrgById:nil];
//            if (_notOrgView && _notOrgView.superview) {
//                [_notOrgView removeFromSuperview];
//            }
//        }
//    }];
//    [self.navigationController pushViewController:viewController animated:YES];
//}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10002 && buttonIndex != alertView.cancelButtonIndex)
    {
        if (self.fromType == KDChooseDepartmentVCFromType_EditPerson) {
            [self.delegate didChooseDepartmentForEditPer:_bottomView.departmentModels longName:self.cacheLongName];
        }
        else{
            [self.delegate didChooseDepartmentModels:_bottomView.departmentModels longName:self.cacheLongName];
        }
        
        if ([self.delegate isKindOfClass:[UIViewController class]]) {
            [self.navigationController popToViewController:(UIViewController *) self.delegate animated:YES];
        }
        else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark - KDOrganizationSelectViewDelegate && KDOrganizationSelectViewDataDelegate
- (void)organiztionSelectView:(KDOrganizationSelectView *)view didSelectedAtIndex:(NSUInteger)index {
    if (index == _organiztionStack.count - 1) {
        return;
    }
    
    KDChooseDepartmentModel *item = self.organiztionStack[index];
    NSUInteger stackCount = _organiztionStack.count;
    
    for (NSInteger i = index + 1; i < stackCount; i++) {
        [_organiztionStack removeLastObject];
        _iClassNumber--;
    }
    [self changeDepartmentWithParentModel:item];
}

- (NSUInteger)numberOfItemsInOraganizationSelectView:(KDOrganizationSelectView *)view {
    return self.organiztionStack.count;
}

- (NSString *)organiztionSelectView:(KDOrganizationSelectView *)view itemViewAtIndex:(NSUInteger)index {
    KDChooseDepartmentModel *item = [self.organiztionStack objectAtIndex:index];
    return item.strName;
}


#pragma mark - setter & getter

- (void)setSelectedDepartments:(NSArray *)selectedDepartments {
    self.selectedDepModels = [selectedDepartments mutableCopy];
    [self.bottomView reloadDataWithDepartments:self.selectedDepModels];
}

- (NSMutableArray *)mArrayFiltedData {
    if (!_mArrayFiltedData) {
        _mArrayFiltedData = [[NSMutableArray alloc] init];
    }
    return _mArrayFiltedData;
}

- (UITableView *)tableViewMain {
    if (!_tableViewMain) {
        _tableViewMain = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, ScreenFullWidth, MainHeight - NavigationBarHeight+20) style:UITableViewStylePlain];
        _tableViewMain.dataSource = self;
        _tableViewMain.delegate = self;
        _tableViewMain.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableViewMain.backgroundColor = [UIColor kdBackgroundColor1];
        _tableViewMain.rowHeight = 44;
    }
    return _tableViewMain;
}

- (UIView *)headerContentView {
    if (_headerContentView) return _headerContentView;
    _headerContentView =[[UIView alloc] init];
    _headerContentView.backgroundColor = [UIColor whiteColor];
    if (!_rootCompanyLab) {
        _rootCompanyLab = [[UILabel alloc] init];
        _rootCompanyLab.text = [BOSConfig sharedConfig].user.companyName;
    }
    
    if (!_organiztionSelectView) {
        _organiztionSelectView = [[KDOrganizationSelectView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 48)];
        _organiztionSelectView.delegate = self;
        _organiztionSelectView.dataDelegate = self;
        _organiztionSelectView.backgroundColor = [UIColor whiteColor];
        _organiztionSelectView.hidden = YES;
    }
    
    [_headerContentView addSubview:_rootCompanyLab];
    [_headerContentView addSubview:_organiztionSelectView];
    [_rootCompanyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(_headerContentView).with.offset(0);
        make.left.mas_equalTo(_headerContentView).with.offset([NSNumber kdDistance1]);
    }];
    [_organiztionSelectView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(_headerContentView).with.offset(0);
    }];
    return _headerContentView;
}

- (KDChooseDepartmentBottomBarView *)bottomView {
    if (_bottomView) return _bottomView;
    _bottomView = [[KDChooseDepartmentBottomBarView alloc] init];
    _bottomView.delegate = self;
    _bottomView.isMutil = self.isMulti;
    return _bottomView;
}

- (UIBarButtonItem *)backButtonItem {
    if (_backButtonItem) return _backButtonItem;
    UIButton *button = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"返回")];
    [button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    _backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return _backButtonItem;
}

- (NSMutableArray *)selectedDepModels {
    if (!_selectedDepModels) {
        _selectedDepModels = [NSMutableArray array];
    }
    
    return _selectedDepModels;
}


- (BOOL)bIsRootVC {
    return self.iClassNumber == 0;
}


@end
