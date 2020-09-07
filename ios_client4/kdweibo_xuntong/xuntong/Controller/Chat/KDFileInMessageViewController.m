//
//  KDFileInMessageViewController.m
//  kdweibo
//
//  Created by janon on 15/3/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDFileInMessageViewController.h"
#import "KDFileInMessageDataModel.h"
#import "ContactUtils.h"
#import "XTUnreadImageView.h"
#import "CKSlideSwitchView.h"
#import "KDGroupFileTableView.h"

@interface KDFileInMessageViewController () <CKSlideSwitchViewDelegate>
@property(nonatomic, strong) UIImageView *redPointImageView;
@property(nonatomic, strong) UILabel *redPointLabel;
@property (strong , nonatomic) XTUnreadImageView *unreadFileImageView;
@property (nonatomic, strong) CKSlideSwitchView *slideSwitchView;
@end

@implementation KDFileInMessageViewController


- (XTUnreadImageView *)unreadFileImageView{
    if(_unreadFileImageView) return _unreadFileImageView;
    _unreadFileImageView = [[XTUnreadImageView alloc] initWithParentView:self.slideSwitchView];
    _unreadFileImageView.hidden = YES;
    _unreadFileImageView.unreadCount = 0;
    SetOrigin(_unreadFileImageView.frame,ScreenFullWidth/8.0 + 20, 7);
    return _unreadFileImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = ASLocalizedString(@"KDFileInMessageViewController_File");
    [self setAutomaticallyAdjustsScrollViewInsets:NO];

    [self.view setBackgroundColor:[UIColor kdBackgroundColor1]];
    UIBarButtonItem *uploadItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDFileInMessageViewController_UpLoad")style:UIBarButtonItemStylePlain target:self action:@selector(upload:)];
    self.navigationItem.rightBarButtonItem = uploadItem;
    [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
    
    _slideSwitchView = [[CKSlideSwitchView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - kd_StatusBarAndNaviHeight)];
    _slideSwitchView.tabItemTitleNormalColor = FC2;
    _slideSwitchView.tabItemTitleSelectedColor = FC5;
    _slideSwitchView.topScrollViewBackgroundColor = [UIColor kdBackgroundColor2];
    _slideSwitchView.tabItemShadowColor = FC5;
    _slideSwitchView.slideSwitchViewDelegate = self;
    
    [self.view addSubview:_slideSwitchView];
    [_slideSwitchView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationStyle:KDNavigationStyleNormal];
}

- (void)setRedPointCountWithMutableArray:(NSInteger)count {
    self.unreadFileImageView.hidden = count <= 0;

    if (count > 0 && count < 99) {
        self.unreadFileImageView.unreadCount = (int)count;
        SetOrigin(self.unreadFileImageView.frame,ScreenFullWidth/8.0 + 20, 7);
    }
    else if (count > 99) {
        self.unreadFileImageView.unreadCount = 0;
        SetFrame(self.unreadFileImageView.frame,  ScreenFullWidth/8.0 + 20, 7, 9, 9);
    }
}

#pragma mark - upload

- (void)upload:(id)sender {
    XTMyFilesViewController *fileListVC = [[XTMyFilesViewController alloc] init];
    fileListVC.hidesBottomBarWhenPushed = YES;
    fileListVC.delegate = self.chatViewController;
    fileListVC.fromType = 0;
    [self.navigationController pushViewController:fileListVC animated:YES];
}

#pragma mark - slideswitchdelegate
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView heightForTabItemForTopScrollview:(UIScrollView *)topScrollview
{
    return 40;
}

- (NSInteger)slideSwitchView:(CKSlideSwitchView *)slideSwitchView numberOfTabItemForTopScrollview:(UIScrollView *)topScrollview
{
    return 4;
}

- (NSString *)slideSwitchView:(CKSlideSwitchView *)slideSwitchView titleForTabItemForTopScrollviewAtIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            return ASLocalizedString(@"KDFileInMessageViewController_Current");
        }
            break;
        case 1:
        {
            return ASLocalizedString(@"KDFileInMessageViewController_Doc");
        }
            break;
        case 2:
        {
            return ASLocalizedString(@"KDEvent_Picture");
        }
            break;
        case 3:
        {
            return ASLocalizedString(@"KDFileInMessageViewController_Other");
        }
            break;
    }
    return nil;
}

- (UIView *)slideSwitchView:(CKSlideSwitchView *)slideSwitchView viewForRootScrollViewAtIndex:(NSInteger)index
{
    KDGroupFileTableView *tableView = [[KDGroupFileTableView alloc] init];
    tableView.groupId = self.groupId;
    KDGroupFileSource fileSource  = KDGroupFileSource_other;
    switch (index) {
        case 0:
            fileSource = KDGroupFileSource_recent;
            break;
        case 1:
            fileSource = KDGroupFileSource_document;
            break;
        case 2:
            fileSource = KDGroupFileSource_picture;
            break;
        case 3:
            fileSource = KDGroupFileSource_other;
        default:
            break;
    }
    tableView.fileSource = fileSource;
    tableView.dataSource = tableView;
    tableView.delegate = tableView;
    tableView.separatorColor = [UIColor clearColor];
    tableView.backgroundColor = [UIColor kdBackgroundColor1];
    tableView.controller = self;
    [tableView loadData];
    return tableView;
}

- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView widthForTabItemForTopScrollview:(UIScrollView *)topScrollview
{
    return CGRectGetWidth(self.view.frame)/4.0;
}

- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView marginForTopScrollview:(UIScrollView *)topscrollview
{
    return 0;
}
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView heightOfShadowImageForTopScrollview:(UIScrollView *)topScrollview
{
    return  2;
}

- (NSInteger)slideSwitchView:(CKSlideSwitchView *)slideSwitchView selectedTabItemIndexForFirstStartForTopScrollview:(UIScrollView *)topScrollview
{
    return self.fileInMessageType ? self.fileInMessageType : 0;
}

- (BOOL)slideSwitchView:(CKSlideSwitchView *)slideSwitchView seperatorImageViewShowInTopScrollview:(UIScrollView *)topScrollview
{
    return YES;
}

@end
