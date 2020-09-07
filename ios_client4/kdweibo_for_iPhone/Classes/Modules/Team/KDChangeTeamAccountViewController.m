//
//  KDChangeTeamAccountViewController.m
//  kdweibo
//
//  Created by kingdee on 16/7/8.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDChangeTeamAccountViewController.h"

#import "KDChangeTeamTableViewCell.h"

#import "TeamAccountModel.h"
#import "UserDataModel.h"
#import "KDMainUserDataModel.h"
#import "UIImageView+WebCache.h"
#import "XTLoginService.h"
#import "KDAuthViewController.h"
#import "XTTimelineViewController.h"

@interface KDChangeTeamAccountViewController ()
@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSArray *dataSource;
@property (nonatomic, strong)NSString *selectedTeamName;

@end

@implementation KDChangeTeamAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setUpDataSource];
    [self setUpTableView];
    self.title = ASLocalizedString(@"KDLeftTeamMenuViewController_change_team_account");
}

- (void)initData {
    self.selectedTeamName = [BOSConfig sharedConfig].user.name;
}

- (void)setUpDataSource {
    NSMutableArray *mutbaleArray = [NSMutableArray array];
    NSArray *teamAccount = [BOSConfig sharedConfig].user.teamAccount;
    [teamAccount enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TeamAccountModel *teamAcc = [[TeamAccountModel alloc] initWithDictionary:obj];
        if (teamAcc.status == 1 || teamAcc.status == 3) {
            [mutbaleArray addObject:teamAcc];
        }
    }];
    
    self.dataSource = [mutbaleArray copy];
}

- (void)setUpTableView {
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[KDChangeTeamTableViewCell class] forCellReuseIdentifier:[KDChangeTeamTableViewCell reuseIdentifier]];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self.tableView.superview);
        
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDChangeTeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[KDChangeTeamTableViewCell reuseIdentifier] forIndexPath:indexPath];
    cell.accessoryView.hidden = YES;
    cell.teamNameLabel.textColor = FC1;
    if (indexPath.row == 0) {
        KDMainUserDataModel *mainUser = [BOSConfig sharedConfig].mainUser;
        cell.teamNameLabel.text = mainUser.name;
        [cell.teamHeadView setImageWithURL:[NSURL URLWithString:mainUser.photoUrl]];
        
        if ([mainUser.name isEqualToString:self.selectedTeamName]) {
            cell.accessoryView.hidden = NO;
            cell.teamNameLabel.textColor = [UIColor colorWithHexRGB:@"0x00a9ff"];
        }
    }
    else {
        TeamAccountModel *teamAccount = self.dataSource[indexPath.row - 1];
        cell.teamNameLabel.text = teamAccount.name;
        [cell.teamHeadView setImageWithURL:[NSURL URLWithString:teamAccount.photoURL]];
        
        if ([teamAccount.name isEqualToString:self.selectedTeamName]) {
            cell.accessoryView.hidden = NO;
            cell.teamNameLabel.textColor = [UIColor colorWithHexRGB:@"0x00a9ff"];
        }
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [KDChangeTeamTableViewCell rowHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        TeamAccountModel *teamAccount = nil;
        if ([self.selectedTeamName isEqualToString:[BOSConfig sharedConfig].mainUser.name]) {
            return;
        }
        self.selectedTeamName = [BOSConfig sharedConfig].mainUser.name;
        [self.tableView reloadData];
        // 调登陆接口，切换数据
        [self changeTeam:indexPath withTeamAccount:teamAccount];
    }
    else {
        TeamAccountModel *seletedTeam = self.dataSource[indexPath.row - 1];
        if ([self.selectedTeamName isEqualToString:seletedTeam.name]) {
            return;
        }
        self.selectedTeamName = seletedTeam.name;
        [self.tableView reloadData];
        // 调登陆接口，切换数据
        [self changeTeam:indexPath withTeamAccount:seletedTeam];
    }
    
}

- (void)changeTeam:(NSIndexPath *)indexPath withTeamAccount:(TeamAccountModel *)teamAccount {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = ASLocalizedString(@"KDLeftTeamMenuViewController_change_team_account");
    [[KDNotificationChannelCenter defaultCenter] closeChannel];
    if (indexPath.row == 0) {
        // 切回主账号
        [XTLoginService xtLoginInEId:[BOSConfig sharedConfig].mainUser.eid finishBlock:^(BOOL success) {
            if (success) {
                [hud hide:YES];
                [[KDWeiboAppDelegate getAppDelegate] resetMainView];
            } else {
                hud.labelText = ASLocalizedString(@"KDLeftTeamMenuViewController_change_team_account_fail");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                    [[KDWeiboAppDelegate getAppDelegate] resetMainView];
                });
            }
        }];
    } else {
        // 切换到团队账号
        [XTLoginService xtLoginInToken:teamAccount.openToken finishBlock:^(BOOL success) {
            if (success) {
                [hud hide:YES];
                // 团队账号不支持多语言，所以切换成功后需要将语言设置为中文状态
                [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
                [[KDWeiboAppDelegate getAppDelegate] resetMainView];
            } else {
                hud.labelText = ASLocalizedString(@"KDLeftTeamMenuViewController_change_team_account_fail");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                    [[KDWeiboAppDelegate getAppDelegate] resetMainView];
                });
            }
        }];
    }
}

@end
