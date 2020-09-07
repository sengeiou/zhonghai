//
//  XTGroupTimelineViewController.m
//  XT
//
//  Created by Gil on 13-7-24.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTGroupTimelineViewController.h"
#import "UIButton+XT.h"
//#import "AppDelegate.h"
#import "XTContactPersonMultipleChoiceCell.h"

@interface XTGroupTimelineViewController ()

@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSMutableArray *persons;

@end

@implementation XTGroupTimelineViewController


- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.title = ASLocalizedString(@"XTGroupTimelineViewController_Choose");
        _groups = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateTypeManyGroupList]];
        _persons = [NSMutableArray array];
        [_groups enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GroupDataModel *groupData = obj;
            PersonSimpleDataModel *person = [groupData packageToPerson];
            [_persons addObject:person];
        }];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //返回按钮
    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)setExitedGroup:(GroupDataModel *)exitedGroup
{
    if (exitedGroup) {
        [_persons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PersonSimpleDataModel *personData = obj;
            if ([exitedGroup.groupId isEqualToString:personData.personId]) {
                [_groups removeObjectAtIndex:idx];
                [_persons removeObjectAtIndex:idx];
            }
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, ScreenFullWidth, ScreenFullHeight-(self.selectPersonsView?44:0)) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor kdBackgroundColor1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 73.0;
    [self.view addSubview:self.tableView];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate and Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
//	XTTimelineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[XTTimelineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//       // cell.containingTableView = tableView;
//	}
//    cell.shouldHideUnreadImage = YES;
//    GroupDataModel *groupDM = [self.groups objectAtIndex:indexPath.row];
//    cell.group = groupDM;
//    
//    return cell;
    
    PersonSimpleDataModel *person = [_persons objectAtIndex:indexPath.row];
    XTContactPersonMultipleChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if(!cell ){
        cell = [[XTContactPersonMultipleChoiceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.person =  person;
    if(self.selectPersonsView)
    {
        cell.hideCheckView = NO;
        cell.checked = [self.selectPersonsView.persons containsObject:person];
    }
    else
        cell.hideCheckView = YES;


    //            UIImageView*line = [[UIImageView alloc] initWithImage:[XTImageUtil cellSeparateLineImage]];
    //            line.frame = CGRectMake(0, 0, ScreenFullWidth, 1);
    //            [cell addSubview:line];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XTContactPersonMultipleChoiceCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //语音会议邀请另外显示 置灰且不可点
    cell.checked = !cell.checked;
    if (_delegate && [_delegate respondsToSelector:@selector(groupTimeline:group:)]) {
        [_delegate groupTimeline:self group:[self.groups objectAtIndex:indexPath.row]];
    }
}

@end
