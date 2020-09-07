//
//  KDWIFIListController.m
//  kdweibo
//
//  Created by lichao_liu on 1/27/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDWIFIListController.h"
#import "KDWifiCell.h"

@interface KDWIFIListController()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableview;
 @end

@implementation KDWIFIListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(ASLocalizedString(@"KDWIFIListController_WIFI"), nil);
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationItem.leftBarButtonItems = [KDCommon leftNavigationItemWithTarget:self action:@selector(sureBtnClicked:)];
}

- (void)addRightBarItem
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:ASLocalizedString(@"Global_Sure")forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button sizeToFit];
    button.contentMode = UIViewContentModeScaleAspectFit;
    [button addTarget:self action:@selector(sureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    float width = kRightNegativeSpacerWidth;
    negativeSpacer.width = width + 5.f;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,rightBarButtonItem, nil];
}
    
- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = MESSAGE_BG_COLOR;
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width , self.view.bounds.size.height)];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.backgroundColor = [UIColor clearColor];
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableview];
    _tableview.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
}

#pragma mark - tableviewdelegate & datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    KDWifiCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        cell = [[KDWifiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
       
    }
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dict = self.wifiArray[indexPath.row];
    if([dict[@"type"] integerValue] == 0)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.wifiSsidStr = dict[@"ssid"];
    
    id isrename = dict[@"isrename"];
    if(isrename && ![isrename isKindOfClass:[NSNull class]] && [isrename isEqualToString:@"isRename"])
    {
        [cell setWifiBssid:dict[@"bssid"]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.wifiArray.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *dict = self.wifiArray[indexPath.row];
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithDictionary:dict];
    if([dict[@"type"] integerValue] == 0)
    {
        dict1[@"type"] = @(1);
    }else{
        dict1[@"type"] = @(0);
    }
    [self.wifiArray replaceObjectAtIndex:indexPath.row withObject:dict1];
    [self.tableview reloadData];
}

- (void)sureBtnClicked:(UIButton *)sender
{
    if(self.block)
    {
        self.block([self.wifiArray mutableCopy]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goBack:(UIButton *)btn
{
    if(self.block)
    {
        self.block([self.wifiArray mutableCopy]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
