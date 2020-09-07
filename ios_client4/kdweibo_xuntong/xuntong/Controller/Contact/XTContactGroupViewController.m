//
//  XTContactGroupViewController.m
//  XT
//
//  Created by kingdee eas on 14-1-22.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import "XTContactGroupViewController.h"
#import "UIButton+XT.h"
//#import "AppDelegate.h"
#import "XTTimelineCell.h"


@interface XTContactGroupViewController ()

@property (nonatomic, strong) NSMutableArray *groups;

@end

@implementation XTContactGroupViewController


- (id)init
{
    self = [super init];
    if (self)
    {
        self.navigationItem.title = ASLocalizedString(@"XTContactContentViewController_MulChat");
        NSString *unreadCountString = nil;
        self.groups = [NSMutableArray arrayWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryFavoriteGroupList:&unreadCountString]];
        
        if (self.groups.count == 0)
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 80, 220, 40)];
            label.backgroundColor = [UIColor clearColor];
            label.text = ASLocalizedString(@"XTContactGroupViewController_Tip_1");
            label.font = [UIFont systemFontOfSize:14];
            SetCenterX(label.center, ScreenFullWidth/2);
            label.textColor = MESSAGE_NAME_COLOR;
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            [self.view addSubview:label];
            
            // 空页面加个图
            UIImageView *imageViewFilter = [[UIImageView alloc]initWithFrame: CGRectMake(0, 110, ScreenFullWidth, ScreenFullHeight)];
//            imageViewFilter.image = [UIImage imageNamed:@"college_img_huihua_blank"];
            NSString *imageName = ASLocalizedString(@"XTContactGroupViewController_ImageName");
            imageViewFilter.image = [UIImage imageNamed:imageName];
            [imageViewFilter sizeToFit];
//            SetY(imageViewFilter.frame, 50);
            SetCenterX(imageViewFilter.center, ScreenFullWidth/2);

            imageViewFilter.contentMode = UIViewContentModeScaleAspectFit;
            
            UIScrollView *scrollViewContent = [[UIScrollView alloc]initWithFrame:isAboveiPhone5 ? CGRectFullScreenWithoutNavigationBar : CGRectMake(0, 0, ScreenFullWidth, ScreenFullHeight-NavigationBarHeight-StatusBarHeight)];
            scrollViewContent.backgroundColor = [UIColor clearColor];
            scrollViewContent.contentSize = CGSizeMake(scrollViewContent.contentSize.width, CGRectGetMaxY(imageViewFilter.frame)+20);
            [scrollViewContent addSubview:label];
            [scrollViewContent addSubview:imageViewFilter];
            
            [self.view addSubview:scrollViewContent];
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = BOSCOLORWITHRGBA(0xF0F0F0, 1.0);
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, ScreenFullWidth, MainHeight-NavigationBarHeight+Adjust_Offset_Xcode5) style:UITableViewStylePlain];
    self.tableView.backgroundColor = BOSCOLORWITHRGBA(0xF0F0F0, 1.0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 65.0f;
    [self.view addSubview:self.tableView];
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
    
	XTTimelineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[XTTimelineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.containingTableView = tableView;
	}
    
    GroupDataModel *groupDM = [self.groups objectAtIndex:indexPath.row];
    cell.group = groupDM;
//    cell.description.hidden = YES;
     cell.separatorLineStyle = (indexPath.row == [self.groups count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GroupDataModel *groupDM = [self.groups objectAtIndex:indexPath.row];
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:groupDM pubAccount:nil mode:ChatPrivateMode];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

@end
