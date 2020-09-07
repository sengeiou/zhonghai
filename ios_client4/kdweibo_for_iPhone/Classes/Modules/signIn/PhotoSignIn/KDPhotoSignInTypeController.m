//
//  KDPhotoSignInTypeController.m
//  kdweibo
//
//  Created by lichao_liu on 15/3/13.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPhotoSignInTypeController.h"
#import "UIView+Blur.h"


@interface KDPhotoSignInTypeController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation KDPhotoSignInTypeController

- (void)loadView {
    [super loadView];
        self.view.backgroundColor = MESSAGE_BG_COLOR;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 60;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyleBlue];
    
    UIButton *leftBtn = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [leftBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
//    
//    UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    updateBtn.frame = CGRectMake(0.0, 0.0, 49.0, 30.0);
//    
//    updateBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
//    [updateBtn setTitle:ASLocalizedString(@"完成")forState:UIControlStateNormal];
//    [updateBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
//    
//    [updateBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
//    
//     UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:updateBtn];
//    
//    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
//                                         initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                         target:nil action:nil];
//    negativeSpacer.width = kRightNegativeSpacerWidth;
//    self.navigationItem.rightBarButtonItems = [NSArray
//                                               arrayWithObjects:negativeSpacer1,rightItem, nil];
    
    self.navigationItem.title = ASLocalizedString(@"KDPhotoSignInTypeController_word_type");
}

- (void)setNavigationStyleBlue{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController.navigationBar setBarTintColor:FC5];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS1}];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"app_img_backgroud"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 21, 0, 21)] forBarMetrics:UIBarMetricsDefault];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)done:(id)sender
{
   if(self.changeSignInTypeBlock)
   {
       self.changeSignInTypeBlock(self.signInType);
   }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
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
    
    if ((indexPath.row == 0 && self.signInType == KDPhotoSignInType_OfficeWork) || (indexPath.row == 1 && self.signInType == KDPhotoSignInType_FieldPersonnel)) {
        ((UIImageView *)cell.accessoryView).image = [UIImage imageNamed:@"icon_tick_blue"];
    }else {
        ((UIImageView *)cell.accessoryView).image = nil;
    }
    cell.textLabel.textColor = MESSAGE_TOPIC_COLOR;
    cell.textLabel.text = indexPath.row == 0 ? ASLocalizedString(@"内勤"): ASLocalizedString(@"外勤");
    cell.textLabel.backgroundColor = [UIColor clearColor];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.signInType == KDPhotoSignInType_FieldPersonnel)
    {
        self.signInType = KDPhotoSignInType_OfficeWork;
    }
    else if(self.signInType == KDPhotoSignInType_OfficeWork)
    {
        self.signInType = KDPhotoSignInType_FieldPersonnel;
    }
    [self.tableView reloadData];
    
    if(self.changeSignInTypeBlock)
    {
        self.changeSignInTypeBlock(self.signInType);
    }
    [self.navigationController popViewControllerAnimated:YES];

}

@end
