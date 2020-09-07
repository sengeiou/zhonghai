//
//  KDSignInPointsController.m
//  kdweibo
//
//  Created by lichao_liu on 1/19/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDSignInPointsController.h"
#import "KDAddOrUpdateSignInPointController.h"
#import "UIView+Blur.h"
#import "KDRefreshTableView.h"


@interface KDSignInPointsController ()<KDRefreshTableViewDataSource,KDAddOrUpdateSignInPointControllerDelegate,KDRefreshTableViewDelegate>
@property (nonatomic, strong)KDRefreshTableView *tableView;
@property (nonatomic, strong) NSMutableArray *signInPointsArray;
@property (nonatomic, strong) UIView *backgroundView;
@end

@implementation KDSignInPointsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [KDEventAnalysis event:event_signin_set_signpoint];
    [self addLeftNavItem];
    if(self.sourceType == KDSignInPointsSouceType_settingController)
    {
    [self addRightNavgationItem];
    }
    _signInPointsArray = [NSMutableArray new];
    self.view.backgroundColor = BOSCOLORWITHRGBA(0xFAFAFA, 1.0);
    self.navigationItem.title = ASLocalizedString(@"KDSignInPointsController_navigationItem_title");
    
    self.tableView = [[KDRefreshTableView alloc] initWithFrame:self.view.bounds kdRefreshTableViewType:KDRefreshTableViewType_Header style:UITableViewStylePlain];
    self.tableView.backgroundColor = MESSAGE_BG_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView setBottomViewHidden:YES];
    
//    [self.tableView setFirstInLoadingState];
//    [self querySignInPoints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView setFirstInLoadingState];
    [self querySignInPoints];
}

- (void)loadView
{
    [super loadView];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    bounds.size.height -= StatusBarHeight + NavigationBarHeight;
    UIView *view = [[UIView alloc] initWithFrame:bounds];
    self.view = view;
}



- (void)addLeftNavItem
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    [btn setBackgroundImage:[UIImage imageNamed:@"navigationItem_back.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"navigationItem_back_hl.png"] forState:UIControlStateHighlighted];
    
    [btn sizeToFit];
    
    [btn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer.width = kLeftNegativeSpacerWidth;
    self.navigationItem.leftBarButtonItems = [NSArray
                                              arrayWithObjects:negativeSpacer,leftItem, nil];
}


- (void)addRightNavgationItem
{
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setTitle:ASLocalizedString(@"添加")forState:UIControlStateNormal];
    [saveBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [saveBtn sizeToFit];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlEventTouchUpInside];
    [saveBtn addTarget:self action:@selector(addSignInPointAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil ];
    spaceItem.width = 7;
    self.navigationItem.rightBarButtonItems = @[spaceItem,closeItem];
}

- (void)backAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addSignInPointAction:(UIButton *)sender
{
    KDAddOrUpdateSignInPointController *controller = [[KDAddOrUpdateSignInPointController alloc] init];
    controller.addOrUpdateSignInPointType = KDAddOrUpdateSignInPointType_add;
    controller.delegate = self;
//    controller.sourceType = KDAddOrUpdateSignInPointSource_signinPointController;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)querySignInPoints
{
    __unsafe_unretained KDSignInPointsController *weakSelf = self ;
    [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES].labelText =ASLocalizedString(@"KDSignInPointsController_HUD_labelText");
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [weakSelf.tableView  finishedRefresh:YES];
        if (results) {
            BOOL success = [[results objectForKey:@"success"] boolValue];
            
            if(success)
            {
                if(self.signInPointsArray && self.signInPointsArray.count>0)
                {
                    [self.signInPointsArray removeAllObjects];
                }
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                 NSArray *datas = [results objectForKey:@"data"];
                if(datas && ![datas isKindOfClass:[NSNull class]] && datas.count>0)
                {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [weakSelf.signInPointsArray  addObjectsFromArray:[weakSelf parseSignInPoints:datas]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView reloadData];
                            if(weakSelf.signInPointsArray && weakSelf.signInPointsArray.count>0)
                            {
                                [weakSelf setBackgroud:NO];
                            }else{
                                [weakSelf setBackgroud:YES];
                            }
                        });
                    });
                }else{
                    [self.tableView reloadData];
                    [weakSelf setBackgroud:YES];
                }
            }else{
                [weakSelf showError:weakSelf.view title:ASLocalizedString(@"KDSignInPointsController_Loding_Fail")];
                if(!weakSelf.signInPointsArray || weakSelf.signInPointsArray.count == 0)
                {
                    [weakSelf setBackgroud:YES];
                }
            }
        } else {
            [weakSelf showError:weakSelf.view title:ASLocalizedString(@"KDSignInPointsController_Loding_Fail")];
            if(!weakSelf.signInPointsArray || weakSelf.signInPointsArray.count == 0)
            {
                [weakSelf setBackgroud:YES];
            }
        }
    };
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"start" integerValue:1];
    [query setParameter:@"limit" integerValue:1000];
    [query setParameter:@"page_index" integerValue:1];
    [KDServiceActionInvoker invokeWithSender:weakSelf actionPath:@"/signId/:listAttendanceSets" query:query
                                 configBlock:nil completionBlock:completionBlock];

}

- (void)showError:(UIView *)view title:(NSString *)title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD HUDForView:view].labelText = title;
    });
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MBProgressHUD hideAllHUDsForView:view animated:YES];
    });
}

- (NSArray *)parseSignInPoints:(NSArray *)array {
    NSArray *returnArray = nil;
    if (array && [array count] >0) {
        NSMutableArray *theArray = [NSMutableArray array];
        KDSignInPoint *signInPoint = nil;
        for (NSDictionary *dic in array) {
            signInPoint = [[KDSignInPoint alloc] initWithDictionary:dic];
            if (signInPoint) {
                [theArray addObject:signInPoint];
            }
        }
        returnArray = [NSArray arrayWithArray:theArray];
    }
    return returnArray;
}

#pragma mark - tableviewDelegate & datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.sourceType == KDSignInPointsSouceType_settingController)
    {
    KDAddOrUpdateSignInPointController *signInPointController = [[KDAddOrUpdateSignInPointController alloc] init];
    signInPointController.signInPoint = self.signInPointsArray[indexPath.row];
    signInPointController.addOrUpdateSignInPointType = KDAddOrUpdateSignInPointType_update;
    signInPointController.rowIndex = indexPath.row;
    signInPointController.delegate = self;
    [self.navigationController pushViewController:signInPointController animated:YES];
    }else if(self.sourceType == KDSignInPointsSouceType_photoController)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectSignInPoint:)])
        {
            [self.delegate didSelectSignInPoint:self.signInPointsArray[indexPath.row]];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        if(!self.sourceType == KDSignInPointsSouceType_photoController)
        {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    cell.imageView.image = [UIImage imageNamed:@"autowifiFeatureIcon"];
    KDSignInPoint *signInPoint = self.signInPointsArray[indexPath.row];
    cell.textLabel.text = signInPoint.positionName;
     if(indexPath.row >=0 && indexPath.row <= self.signInPointsArray.count)
     {
         [cell addBorderAtPosition:KDBorderPositionBottom | KDBorderPositionTop];
     }else if(indexPath.row == 0)
     {
         [cell addBorderAtPosition:KDBorderPositionTop];
     }else if(indexPath.row == self.signInPointsArray.count -1)
     {
         [cell addBorderAtPosition:KDBorderPositionBottom];
     }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.signInPointsArray.count;
}

- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView
{
    [self querySignInPoints];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_tableView kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [_tableView kdRefreshTableviewDidEndDraging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void) setBackgroud:(BOOL)isLoad {
    
    if (!isLoad) {
        _backgroundView.hidden = YES;
        return;
    }
    
    if (!_backgroundView) {
        
        _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _backgroundView.backgroundColor = [UIColor clearColor];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud"]];
        [bgImageView sizeToFit];
        bgImageView.center = CGPointMake(_backgroundView.bounds.size.width * 0.5f, 137.5f);
        
        [_backgroundView addSubview:bgImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(bgImageView.frame) + 15.0f, self.view.bounds.size.width, 38.0f)];
        label.numberOfLines = 0;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15.0f];
        label.textColor = MESSAGE_NAME_COLOR;
        label.text = ASLocalizedString(@"KDSignInPointsController_label_text");
        
        [_backgroundView addSubview:label];
        
        [_tableView addSubview:_backgroundView];
    }
    _backgroundView.hidden = NO;
    
}

#pragma mark - KDAddOrUpdateSignInPointControllerDelegate
- (void)addOrUpdateSignInPointSuccess:(KDSignInPoint *)signInPoint signInPointType:(KDAddOrUpdateSignInPointType)signInPointType rowIndex:(NSInteger)index
{
//    if(signInPointType == KDAddOrUpdateSignInPointType_add)
//    {
//        if(!self.signInPointsArray || self.signInPointsArray.count == 0)
//        {
//            [self setBackgroud:NO];
//        }
//        [self.signInPointsArray insertObject:signInPoint atIndex:0];
//        
//        [self.tableView beginUpdates];
//        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
//        [self.tableView endUpdates];
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//        
//    }else if(signInPointType == KDAddOrUpdateSignInPointType_update)
//    {
//        [self.signInPointsArray replaceObjectAtIndex:index withObject:signInPoint];
//        
//        [self.tableView beginUpdates];
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [self.tableView endUpdates];
//    }else if(signInPointType == KDAddOrUpdateSignInPointType_delete)
//    {
//        [self.signInPointsArray removeObjectAtIndex:index];
//        
//        [self.tableView beginUpdates];
//        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [self.tableView endUpdates];
//        
//        if(!self.signInPointsArray || self.signInPointsArray.count == 0)
//        {
//            [self setBackgroud:YES];
//        }
//    }
}
@end
