//
//  KDSignInRangeController.m
//  kdweibo
//
//  Created by lichao_liu on 15/4/13.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSignInRangeController.h"
#import "UIView+Blur.h"

@interface KDSignInRangeController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *rangeTypeArray;
@end

@implementation KDSignInRangeController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 60;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.tableView];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    footView.backgroundColor = [UIColor clearColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:footView.frame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = BOSCOLORWITHRGBA(0x818181, 1.0);
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = ASLocalizedString(@"KDSignInRangeController_titleLabel_text");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.tableView setTableFooterView:footView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = ASLocalizedString(@"签到范围");
    
     self.rangeTypeArray = @[@(KDSignInRangeType_100),@(KDSignInRangeType_150),@(KDSignInRangeType_200),@(KDSignInRangeType_250),@(KDSignInRangeType_300)];
    
    if(self.signInRangeType == 0)
    {
        self.signInRangeType = KDSignInRangeType_200;
    }
    [self.tableView reloadData];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rangeTypeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentify = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentify];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentify];
        cell.backgroundColor = MESSAGE_CT_COLOR;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 14)];
        cell.accessoryView = imageView;
         [cell addBorderAtPosition:KDBorderPositionBottom];
    }
    
    if (self.signInRangeType == [self.rangeTypeArray[indexPath.row] integerValue]) {
        ((UIImageView *)cell.accessoryView).image = [UIImage imageNamed:@"icon_tick_blue"];
    }else {
        ((UIImageView *)cell.accessoryView).image = nil;
    }
    cell.textLabel.textColor = MESSAGE_TOPIC_COLOR;
    cell.textLabel.text = [NSString stringWithFormat:ASLocalizedString(@"%ld米"),(long)[self.rangeTypeArray[indexPath.row] integerValue]];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.signInRangeType = [self.rangeTypeArray[indexPath.row] integerValue];
    [self.tableView reloadData];
    if(self.signInRangeChangeBlock)
    {
        self.signInRangeChangeBlock([self.rangeTypeArray[indexPath.row] integerValue]);
    }
     [self back:nil];
}

@end

