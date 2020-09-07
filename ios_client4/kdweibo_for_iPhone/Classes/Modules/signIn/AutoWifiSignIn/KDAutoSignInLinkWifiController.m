//
//  KDAutoSignInLinkWifiController.m
//  kdweibo
//
//  Created by lichao_liu on 1/12/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDAutoSignInLinkWifiController.h"
#import "UIView+Blur.h"
#import "KDErrorDisplayView.h"
#import "KDAutoWifiSignInPromtView.h"
@interface KDAutoSignInLinkWifiController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableview;
@end

@implementation KDAutoSignInLinkWifiController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = MESSAGE_BG_COLOR;
    
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
                                                 style:UITableViewStylePlain];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    [self.view addSubview:self.tableview];
    
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableview.frame), 80)];
    footView.backgroundColor = [UIColor clearColor];
    
    UIButton *linkBtn = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(footView.frame) - 280)/2,20, 280, 40)];
    linkBtn.backgroundColor = BOSCOLORWITHRGBA(0x1A85FF, 1.0f);
    [linkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [linkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [linkBtn addTarget:self action:@selector(whenLinkBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [linkBtn setTitle:ASLocalizedString(@"关联WIFI")forState:UIControlStateNormal];
    [footView addSubview:linkBtn];
    
    [self.tableview setTableFooterView:footView];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = ASLocalizedString(@"关联WIFI");
    self.navigationItem.leftBarButtonItems = [KDCommon leftNavigationItemWithTarget:self action:@selector(backAction:)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (void)setSsid:(NSString *)ssid bssid:(NSString *)bssid attendSetId:(NSString *)attendSetId featureName:(NSString *)featureName
{
    self.ssid = ssid;
    self.bssid = bssid;
    self.attendSetId = attendSetId;
    self.featureName = featureName;
    [self.tableview reloadData];
}

#pragma mark - tableviewDelegate & datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addBorderAtPosition:KDBorderPositionTop|KDBorderPositionBottom];
    }
    
    if(indexPath.section == 0)
    {
        cell.textLabel.text = self.featureName;
        cell.imageView.hidden = NO;
        cell.imageView.image = [UIImage imageNamed:@"autowifiFeatureIcon"];
    }else if(indexPath.section == 1)
    {
        cell.textLabel.text = self.ssid;
        cell.imageView.hidden = YES;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableview.frame), 60)];
    sectionView.backgroundColor = [UIColor clearColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 60)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:15];
    if(section == 0)
    {
        titleLabel.text = ASLocalizedString(@"KDAutoSignInLinkWifiController_sign_point");
    }else if(section == 1)
    {
        titleLabel.text = ASLocalizedString(@"KDAutoSignInLinkWifiController_wifi");
    }else{
        return nil;
    }
    [sectionView addSubview:titleLabel];
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)whenLinkBtnClicked:(UIButton *)sender
{
    __unsafe_unretained KDAutoSignInLinkWifiController *weakSelf = self;
    [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
    [MBProgressHUD HUDForView:weakSelf.view].labelText = ASLocalizedString(@"KDAutoSignInLinkWifiController_connecting");
    [self relationWifiWithAttendSetWithSsid:self.ssid bssid:self.bssid attendSetId:self.attendSetId block:^(BOOL success, NSString *ssid, NSString *attendName,NSInteger type) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        if(success)
        {
            //关联wifi成功
            [weakSelf showLinkPointToNotification:ssid AttendName:attendName];
        }else{
            if(type == 1)
            {
                [self showError:ASLocalizedString(@"KDAutoSignInLinkWifiController_connect_suc")block:^(){
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
            }else
                [self showError:ASLocalizedString(@"KDAutoSignInLinkWifiController_connect_fail")block:nil];
        }
        
    }];
    
}

- (void)showLinkPointToNotification:(NSString *)ssid AttendName:(NSString *)attendName
{
//    KDAutoWifiSignInPromtView * inputView = [[KDAutoWifiSignInPromtView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
//    __unsafe_unretained KDAutoSignInLinkWifiController *weakSelf = self;
//       [inputView setBlock:^(BOOL isNotifieveryOne) {
//        if(isNotifieveryOne)
//        {
//            [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
//            [MBProgressHUD HUDForView:weakSelf.view].labelText = ASLocalizedString(@"正在发送中...");
//            [self notifieveryOneWithSsid:ssid attendName:attendName block:^(BOOL success) {
//                [self showError:ASLocalizedString(@"发送成功")block:^(){
//                    [weakSelf.navigationController popViewControllerAnimated:YES];
//                }];
//            }];
//            
//        }else{
//         }
//    } ssid:self.ssid promtType:KDAutoWifiSignInPromtViewType_showlink];
//    [self.navigationController.view addSubview:inputView];
//    inputView = nil;
 }

//关联wifi
- (void)relationWifiWithAttendSetWithSsid:(NSString *)ssid bssid:(NSString *)bssid attendSetId:(NSString *)attendSetId block:(void (^)(BOOL success,NSString *ssid,NSString *attendName,NSInteger type))block
{
    __unsafe_unretained KDAutoSignInLinkWifiController *weakSelf = self ;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results) {
            BOOL success = [[results objectForKey:@"success"] boolValue];
            NSDictionary *data = [results objectForKey:@"data"];
            if(success)
            {
                NSString *attendName = nil;
                
                if (block) {
                    attendName = data[@"attendName"];
                    block(YES, ssid,attendName,2);
                }
            }else{
               NSInteger type = [data[@"type"] integerValue];
                block(NO,nil,nil,type);
            }
        } else {
            if (block) {
                block(NO, nil,nil,0);
            }
        }
     };
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"ssid" stringValue:ssid];
    [query setParameter:@"bssid" stringValue:bssid];
    [query setParameter:@"attendSetId" stringValue:attendSetId];
    [KDServiceActionInvoker invokeWithSender:weakSelf actionPath:@"/signId/:relationWifiWithAttendSet" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)showError:(NSString *)error block:(void (^)())block
{
    __unsafe_unretained KDAutoSignInLinkWifiController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        [MBProgressHUD HUDForView:weakSelf.view].labelText = error;
    });
    double delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        if(block)
        {
            block();
        }
    });

}

#pragma mark - 通知所有员工
- (void)notifieveryOneWithSsid:(NSString *)ssid attendName:(NSString *)attendName block:(void(^)(BOOL success))block
{
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if(block)
        {
            block(YES);
        }
    };
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"ssid" stringValue:ssid];
    [query setParameter:@"attendName" stringValue:attendName];
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/signId/:notifyNetworkAfterRelation" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}

- (void)backAction:(id)sender {
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
