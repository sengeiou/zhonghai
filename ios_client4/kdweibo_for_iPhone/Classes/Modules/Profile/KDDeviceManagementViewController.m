//
//  KDDeviceManagementViewController.m
//  kdweibo
//
//  Created by kingdee on 2019/5/20.
//  Copyright © 2019 www.kingdee.com. All rights reserved.
//

#import "KDDeviceManagementViewController.h"
#import "DeviceInfoModel.h"
#import "DeviceManageTableViewCell.h"

@interface KDDeviceManagementViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *remindArray;
@property (nonatomic, strong) XTOpenSystemClient *openSystemClient;
@property (nonatomic, strong) XTOpenSystemClient *deleteDeviceClient;

@property (nonatomic, strong) UIAlertView *alterView;
@end

@implementation KDDeviceManagementViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ASLocalizedString(@"设备管理");
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).with.insets(UIEdgeInsetsZero);
    }];
    [self getDevices];
}
-(XTOpenSystemClient *)openSystemClient
{
    if (!_openSystemClient)
    {
        _openSystemClient = [[XTOpenSystemClient alloc]initWithTarget:self action:@selector(getDevicesList:result:)];
    }
    return _openSystemClient;
}
-(XTOpenSystemClient *)deleteDeviceClient
{
    if (!_deleteDeviceClient)
    {
        _deleteDeviceClient = [[XTOpenSystemClient alloc]initWithTarget:self action:@selector(deleteDeviceDidReceived:result:)];
    }
    return _deleteDeviceClient;
}

- (void)getDevices{
   
    [self.openSystemClient getGrantDevices:[BOSSetting sharedSetting].userName];
}

- (void)getDevicesList:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        return;
    }
    
     [_remindArray removeAllObjects];
    
    for (NSDictionary *dic in result.data) {
        DeviceInfoModel *model = [[DeviceInfoModel alloc] initWithDictionary:dic];
        [_remindArray addObject:model];
    }
    
    [_tableView reloadData];
    
}

- (void)deleteDeviceDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || !result.success) {
        return;
    }
    
    [_remindArray removeObjectAtIndex:self.alterView.tag];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.alterView.tag inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
   
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        DeviceInfoModel *remind = self.remindArray[indexPath.row];
        if([[[UIDevice uniqueDeviceIdentifier] lowercaseString] isEqualToString:remind.deviceId]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前设备不能删除" delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
            return;
        }
        else {
            self.alterView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"是否删除设备"
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OKAY", @"")
                                              otherButtonTitles:ASLocalizedString(@"Global_Cancel"),nil];
            self.alterView.tag = indexPath.row;
            [self.alterView show];
            
        }
       
        
      
       // [KDSignInRemindManager setSignInRemind:remind operateType:2 block:^(BOOL success, NSString *remindId) {
           // if (success) {
               // [KDPopup showHUDSuccess:ASLocalizedString(@"删除成功")];
               // BOOL result = [[XTDataBaseDao sharedDatabaseDaoInstance] deleteSignInRemindWithRemindId:remind.remindId];
               // if (result) {
                    //[KDSignInRemindManager cancelSignInRemindWithRemind:remind];
               // }
           // }
           // else {
            //    [KDPopup showHUDToast:ASLocalizedString(@"删除失败")];
           // }
           // [self reloadTableView];
        //}];
    }
}
#pragma  mark - AlertView  Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        DeviceInfoModel *remind = self.remindArray[alertView.tag];
        [self.deleteDeviceClient deleteGrantDevice:[BOSSetting sharedSetting].userName deviceId:remind.deviceId];
    }
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier";
    DeviceManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[DeviceManageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
    }
    //__weak KDDeviceManagementViewController *weakSelf = self;
    //__block DeviceInfoModel *remind = self.remindArray[indexPath.row];
    cell.deviceModel = self.remindArray[indexPath.row];
    cell.separatorLineStyle = (indexPath.row == self.remindArray.count -1 ? KDTableViewCellSeparatorLineNone:KDTableViewCellSeparatorLineSpace);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.remindArray.count;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter -
- (NSMutableArray *)remindArray {
    if (!_remindArray) {
        _remindArray = [NSMutableArray array];
    }
    return _remindArray;
}

@end
