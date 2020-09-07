//
//  KDSignInRemindController.m
//  kdweibo
//
//  Created by lichao_liu on 9/8/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDSignInRemindController.h"
#import "KDNewSigninRemindController.h"
#import "KDSignInRemindManager.h"
#import "UIButton+KDV7.h"
//#import "KDSetSignInRemindRequest.h"
//#import "KDGetSignInRemindListRequest.h"

@interface KDSignInRemindController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *remindArray;
@property (nonatomic, strong) UIView *emptyView;
@end

@implementation KDSignInRemindController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = ASLocalizedString(@"签到提醒");
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"sign_btn_add_normal"] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"sign_btn_add_press"] forState:UIControlStateHighlighted];

    [rightBtn sizeToFit];
    [rightBtn addTarget:self action:@selector(addSignInRemindBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.sectionHeaderHeight = 8.0;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).with.insets(UIEdgeInsetsZero);
    }];
    
    [self getSignInRemindList];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        KDSignInRemind *remind = self.remindArray[indexPath.row];
        [KDPopup showHUD];
        [KDSignInRemindManager setSignInRemind:remind operateType:2 block:^(BOOL success, NSString *remindId) {
            if (success) {
                [KDPopup showHUDSuccess:ASLocalizedString(@"删除成功")];
                BOOL result = [[XTDataBaseDao sharedDatabaseDaoInstance] deleteSignInRemindWithRemindId:remind.remindId];
                if (result) {
                    [KDSignInRemindManager cancelSignInRemindWithRemind:remind];
                }
            }
            else {
                [KDPopup showHUDToast:ASLocalizedString(@"删除失败")];
            }
            [self reloadTableView];
        }];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier";
    KDSignInRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[KDSignInRemindCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
    }
    __weak KDSignInRemindController *weakSelf = self;
    __block KDSignInRemind *remind = self.remindArray[indexPath.row];
    cell.switchValueChangedBlock = ^(BOOL isOn){
        //[KDEventAnalysis event:event_signInRemind];
        remind.isRemind = isOn;
        [KDPopup showHUD];
        [KDSignInRemindManager setSignInRemind:remind operateType:1 block:^(BOOL success, NSString *remindId) {
            if (success) {
                [KDPopup showHUDSuccess:ASLocalizedString(@"设置成功")];
                
                BOOL result = [[XTDataBaseDao sharedDatabaseDaoInstance] updateSignInRemindWithRemindId:remind.remindId isRemind:isOn remindTime:remind.remindTime repeatType:remind.repeatType];
                if(result) {
                    [weakSelf.remindArray replaceObjectAtIndex:indexPath.row withObject:remind];
                    [KDSignInRemindManager updateSignInRemindWithRemind:remind];
                }
            }
            else {
                [KDPopup showHUDToast:ASLocalizedString(@"设置失败")];
                [self reloadTableView];
            }
        }];
    };
    cell.remind = self.remindArray[indexPath.row];
    cell.separatorLineStyle = (indexPath.row == self.remindArray.count -1 ? KDTableViewCellSeparatorLineNone:KDTableViewCellSeparatorLineSpace);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSignInRemind *remind = [self.remindArray objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self gotoNewSignInRemindControllerWithRemind:remind];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.remindArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)addSignInRemindBtnClicked:(id)sender
{
    [self gotoNewSignInRemindControllerWithRemind:nil];
}

- (void) setBackgroud:(BOOL)ishidden
{
    if (ishidden)
    {
        if(_emptyView)
        {
            _emptyView.hidden = YES;
        }
        return;
    }
    else
    {
        if (!_emptyView) {
            
            _emptyView = [[UIView alloc] initWithFrame:self.view.bounds];
            _emptyView.backgroundColor = [UIColor kdBackgroundColor2];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.5*(CGRectGetHeight(_emptyView.frame)- 83-64 -33-44) , self.view.bounds.size.width, 30.0f)];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font =FS3;
            label.textColor = FC2;
            label.text = ASLocalizedString(@"你可以设置多个提醒以免忘记签到");
            [_emptyView addSubview:label];
            
            UIButton *addSignInPointBtn = [UIButton blueBtnWithTitle_V7:ASLocalizedString(@"新建提醒")];
            [addSignInPointBtn addTarget:self action:@selector(addSignInRemindBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            addSignInPointBtn.titleLabel.font = FS3;
            addSignInPointBtn.frame = CGRectMake((CGRectGetWidth(_emptyView.frame)- 100)*0.5, CGRectGetMaxY(label.frame)+9, 100, 44);
            addSignInPointBtn.layer.cornerRadius = 22;
            [_emptyView addSubview:addSignInPointBtn];
            
            [_tableView addSubview:_emptyView];
        }
        _emptyView.hidden = NO;
    }
    
}


- (void)gotoNewSignInRemindControllerWithRemind:(KDSignInRemind *)remind
{
    KDNewSigninRemindController *newRemindController = [[KDNewSigninRemindController alloc] initWithNibName:NSStringFromClass([KDNewSigninRemindController class]) bundle:nil];
    if (remind) {
        newRemindController.signInRemind = remind;
    }
    [self.navigationController pushViewController:newRemindController animated:YES];
}

- (void)reloadTableView
{
    if (self.remindArray.count > 0) {
        [self.remindArray removeAllObjects];
    }
    
    NSArray *remindArray = [[XTDataBaseDao sharedDatabaseDaoInstance] querySignInRemind];
    if(remindArray.count > 0) {
        [self.remindArray addObjectsFromArray:remindArray];
        [self setBackgroud:YES];
    }
    else {
        [self setBackgroud:NO];
    }
    
    [self.tableView reloadData];
}

- (void)getSignInRemindList {
    [KDPopup showHUDInView:self.view];
    [KDSignInRemindManager getSignInRemindListFromServerWithblock:^(BOOL success) {
        [KDPopup hideHUDInView:self.view];
        [self reloadTableView];
        [KDSignInRemindManager updateSignInReminds:self.remindArray];
    }];
}

#pragma mark - getter -
- (NSMutableArray *)remindArray {
    if (!_remindArray) {
        _remindArray = [NSMutableArray array];
    }
    return _remindArray;
}

@end
