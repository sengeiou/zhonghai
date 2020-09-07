//
//  KDWorkDayPickerViewController.m
//  kdweibo
//
//  Created by Tan yingqi on 13-8-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDWorkDayPickerViewController.h"

@interface KDWorkDayPickerViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation KDWorkDayPickerViewController


- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.rowHeight = 60;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ASLocalizedString(@"重复周期");
    
    UIButton *rightBtn = [UIButton blueBtnWithTitle:ASLocalizedString(@"确定")];
    [rightBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}


- (void)done:(id)sender {
    if(self.workDayPickerBlock)
    {
        self.workDayPickerBlock(self.repeatType);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentify = @"Cell";
    KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentify];
    if (cell == nil) {
        cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentify];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        cell.accessoryView = imageView;
    }
    
    if (self.repeatType & (KDSignInRemindRepeatSun << (indexPath.row + 1) % 7)){
        ((UIImageView *) cell.accessoryView).image = [UIImage imageNamed:@"task_editor_finish"];
    } else {
        ((UIImageView *) cell.accessoryView).image = [UIImage imageNamed:@"task_editor_select"];
    }
    cell.textLabel.textColor = FC1;
    cell.textLabel.text = [NSString stringWithFormat:ASLocalizedString(@"周%@"), chineseWeek[indexPath.row]];
    if(indexPath.row == 6)
    {
        cell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
    }else{
        cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.repeatType ^= (KDSignInRemindRepeatSun << ((indexPath.row + 1) % 7));
    [self.tableView reloadData];
}


@end
