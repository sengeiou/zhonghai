//
//  KDToDoContainorViewController.m
//  kdweibo
//
//  Created by janon on 15/4/6.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDToDoContainorViewController.h"
#import "KDToDoViewController.h"
#import "GroupDataModel.h"
#import "KDToDoFilterViewCell.h"
#import "KDToDoMessageDataModel.h"
#import "KDEventAnalysis.h"

typedef enum _MsgType{
    MsgTypeUndo = 0,     //待办
    MsgTypeMention = 1   //@
}MsgType;


@interface KDToDoContainorViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,KDToDoFilterViewCellDelegate,KDSearchBarDelegate>
{
    NSArray *_undoArray;
}
@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, strong) KDToDoViewController *todoController;
@property (nonatomic, assign) BOOL state; //添加的
@property (nonatomic, assign) BOOL funnelState;

@property (nonatomic, strong) NSMutableArray *informationArray;
@property (nonatomic, strong) NSMutableArray *selectedArray;

@property (nonatomic, strong) UIButton *funnelButton;
@property (nonatomic, strong) UIView *containorView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGRect collectionViewShowFrame;
@property (nonatomic, assign) CGRect collectionViewHideFrame;
@property (nonatomic, assign) CGRect containorViewShowFrame;
@property (nonatomic, assign) CGRect containorViewHideFrame;
@property (nonatomic, assign) CGRect sureButtonShowFrame;
@property (nonatomic, assign) CGRect sureButtonHideFrame;

@property (assign , nonatomic) NSInteger selectedInformation;

@property (nonatomic, strong) UIButton *searchButton; // 搜索按钮
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, assign) CGRect searchViewShowFrame;
@property (nonatomic, assign) CGRect searchViewHideFrame;

@property (nonatomic, strong) KDSearchBar *searchBar;//搜索

@property (nonatomic, assign) BOOL searchState;

@property (nonatomic, assign) BOOL filterState;//为了点过筛选以后点取消的界面显示问题。


@end

@implementation KDToDoContainorViewController
-(BOOL)state //添加的
{
    if (!_state)
    {
        _state = NO;
    }
    return _state;
}

-(BOOL)funnelState
{
    if (!_funnelState)
    {
        _funnelState = NO;
    }
    return _funnelState;
}

-(BOOL)searchState
{
    if (!_searchState)
    {
        _searchState = NO;
    }
    return _searchState;
}

-(instancetype)initWithGroup:(GroupDataModel *)group
{
    self = [super init];
    if (self)
    {
        self.group = group;
    }
    return self;
}

-(void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"KDTodomsgtable_0524"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"KDTodomsgtable_0524"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[XTDataBaseDao sharedDatabaseDaoInstance] deleteAllToDo];
    }
    [KDEventAnalysis event:event_session_open_todo];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:AppLanguage] isEqualToString:@"en"]) {
        self.title = ASLocalizedString(@"KDToDoContainorViewController_title");
    } else {
        self.title = self.group.groupName;
    }
    
    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:self.backBtnTitle];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItems = @[barButtonItem];

    self.collectionViewShowFrame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 224);
    self.collectionViewHideFrame = CGRectMake(0, -224-64, [UIScreen mainScreen].bounds.size.width, 224-64);
    self.containorViewShowFrame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    self.containorViewHideFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height * -1, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    self.informationArray = [NSMutableArray array];
    self.selectedArray = [NSMutableArray array];
    self.selectedInformation = -1;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 0;
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.collectionViewHideFrame collectionViewLayout:layout];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setAlpha:0];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView setShowsVerticalScrollIndicator:NO];
    [self.collectionView registerClass:[KDToDoFilterViewCell class] forCellWithReuseIdentifier:@"collectionCell"];
   [self.view addSubview:self.collectionView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(containorViewHideAction:)];
    self.containorView = [[UIView alloc] initWithFrame:self.containorViewHideFrame];
    [self.containorView setAlpha:0];
    [self.containorView addGestureRecognizer:tapGesture];
    [self.containorView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.containorView];
    
    [self.collectionView reloadData];
    
    
    self.searchViewShowFrame = CGRectMake(0, kd_StatusBarAndNaviHeight, [UIScreen mainScreen].bounds.size.width, ScreenFullHeight - kd_StatusBarAndNaviHeight - kd_BottomSafeAreaHeight);
    self.searchViewHideFrame = CGRectMake(0, -ScreenFullHeight-104, [UIScreen mainScreen].bounds.size.width, 0);
    self.searchView = [[UIView alloc] initWithFrame:self.searchViewHideFrame];
    [self.searchView setAlpha:0];
    [self.searchView addGestureRecognizer:tapGesture];
    [self.searchView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.searchView];
    
    
    
    
    self.searchBar = [[KDSearchBar alloc]initWithFrame:CGRectMake(0, 0, ScreenFullWidth, 44)];
    self.searchBar.delegate = self;
    [self.searchView addSubview:self.searchBar];
    NSString *text = [[NSUserDefaults standardUserDefaults]valueForKey:@"searchBarKeyWord"];
    if (text.length > 0) {
        self.searchBar.text = text;
    }

    [self setupRightItem];

    
    self.todoController = [[KDToDoViewController alloc] initWithGroup:self.group];
    NSString *todoStatus = @"";
    if (self.group.todoPriStatus.length > 0) {
        todoStatus = self.group.todoPriStatus;
    }else{
        RecordDataModel *record = self.group.lastMsg;
        todoStatus = record.todoStatus;
    }
    
    [self addChildViewController:self.todoController];
    [self.view addSubview:self.todoController.view];
    
    [self.view bringSubviewToFront:self.searchView];
    [self.view bringSubviewToFront:self.collectionView];
    [self.view insertSubview:self.containorView belowSubview:self.collectionView];
}

- (void)setupRightItem
{
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc]initWithCustomView:self.searchButton];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.funnelButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10.f;
    if (_searchState) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,searchItem, nil];
    }else if(_funnelState)
    {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,rightItem, nil];
    }else
    {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,rightItem,negativeSpacer,searchItem, nil];
    }

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}

-(void)containorViewHideAction:(UITapGestureRecognizer *)sender
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^
     {
         self.collectionView.alpha = 0;
         self.containorView.alpha = 0;
     } completion:^(BOOL finished) {
         self.collectionView.frame = self.collectionViewHideFrame;
         self.containorView.frame = self.containorViewHideFrame;
     }];
    self.state = NO;
    [self.funnelButton setTitle:ASLocalizedString(@"KDToDoContainorViewController_rightItem_title")forState:UIControlStateNormal];
}

-(void)searchClicked:(UIButton *)sender
{
    NSLog(@"searchClicked");
    //add
    [KDEventAnalysis event:event_todo_search];
    [KDEventAnalysis eventCountly:event_todo_search];
    if (self.searchState == NO) //添加的
    {
       NSInteger index = [[[NSUserDefaults standardUserDefaults] valueForKey:@"MenuSelect"] integerValue];
        switch (index) {
            case 0:
                self.title = @"待办搜索";
                break;
            case 1:
                self.title = @"已办搜索";
                break;
            case 2:
                self.title = @"通知搜索";
                break;
                
            default:
                break;
        }
        [self.view bringSubviewToFront:self.searchView];
        self.searchView.frame = self.searchViewShowFrame;
        self.containorView.frame = self.containorViewShowFrame;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^
         {
             self.searchView.alpha = 1;
             self.containorView.alpha = 0.7;
         } completion:nil];
//        self.todoController.state = KDToDoViewControllerType_Search;
        self.searchState = YES;
        [self.searchButton setImage:nil forState:UIControlStateNormal];
        [self.searchButton setTitle:ASLocalizedString(@"Global_Cancel")forState:UIControlStateNormal];
    }
    else
    {
        self.title = @"待办通知";
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^
         {
             self.searchView.alpha = 0;
             self.containorView.alpha = 0;
         } completion:^(BOOL finished) {
             self.searchView.frame = self.searchViewHideFrame;
             self.containorView.frame = self.containorViewHideFrame;
         }];
        [self.searchBar resignFirstResponder];
        self.searchState = NO;
        [self.searchButton setTitle:nil forState:UIControlStateNormal];
        [_searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    }
    [self setupRightItem];

}
-(void)funnelClicked:(UIButton *)sender
{
    //add
    [KDEventAnalysis event:event_todo_filter];
    [KDEventAnalysis eventCountly:event_todo_filter];
    if (self.state == NO) //添加的
    {
        [KDEventAnalysis event:event_session_open_select];
        [self setupInformationArray];
        
//        if(self.informationArray.count == 0)
//            return;
        if(self.informationArray.count == 0)
        {
            self.collectionView.frame = CGRectZero;
            self.containorView.frame = self.containorViewShowFrame;
        }else
        {
            self.collectionView.frame = self.collectionViewShowFrame;
            self.containorView.frame = self.containorViewShowFrame;
        }
        _funnelState = YES;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^
         {
             self.collectionView.alpha = 1;
             self.containorView.alpha = 0.7;
         } completion:nil];
        self.state = YES;
        [self.funnelButton setImage:nil forState:UIControlStateNormal];;
        [self.funnelButton setTitle:ASLocalizedString(@"Global_Cancel")forState:UIControlStateNormal];
        [self.collectionView reloadData];
    }
    else
    {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^
         {
             self.collectionView.alpha = 0;
             self.containorView.alpha = 0;
         } completion:^(BOOL finished) {
             if(self.informationArray.count > 0)
             {
                self.collectionView.frame = self.collectionViewHideFrame;
             }
             self.containorView.frame = self.containorViewHideFrame;
         }];
        self.state = NO;
        [self.funnelButton setTitle:nil forState:UIControlStateNormal];
        [self.funnelButton setImage:[UIImage imageNamed:@"filter" ] forState:UIControlStateNormal];
        if (!self.filterState) {
            _funnelState = NO;
            [self.collectionView reloadData];
        }
    }
    [self setupRightItem];
}

-(void)setupInformationArray
{

    NSArray *tempArray = [[XTDataBaseDao sharedDatabaseDaoInstance] queryToDomessageKind];
    
    //去除老数据微信红包
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title != %@", ASLocalizedString(@"KDToDoContainorViewController_")];
//    tempArray = [tempArray filteredArrayUsingPredicate:predicate];
    
//    KDToDoMessageDataModel *model = [[KDToDoMessageDataModel alloc]init];
//    [model setTitle:ASLocalizedString(@"KDToDoContainorViewController_model_title")];
//    [model setAppid:@""];
    [self.informationArray removeAllObjects];
//    [self.informationArray insertObject:model atIndex:0];
//    if ([_undoArray count] > 0) {
//        _undoArray = nil;
//    }
//    if ([_undoArray count] > 0 ) {
//        KDToDoMessageDataModel *undoModel = [[KDToDoMessageDataModel alloc]init];
//        [undoModel setTitle:ASLocalizedString(@"KDToDoContainorViewController_undoModel_title")];
//        [self.informationArray insertObject:undoModel atIndex:0];
//    }
    
    [tempArray enumerateObjectsUsingBlock:^(KDToDoMessageDataModel *theModel, NSUInteger i, BOOL *stop) {
//        if([theModel.title isEqualToString:ASLocalizedString(@"KDToDoContainorViewController_model_title")]){
//            [self.informationArray insertObject:theModel atIndex:0];
//        }else if(![theModel.todoStatus isEqualToString:@"undo"]){
            [self.informationArray addObject:theModel];
//        }
    }];

}

#pragma mark - UICollectionViewDelegate UICollectionViewDatasource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.informationArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   //如果有待办，则第一个按钮显示待办，否则显示@

    KDToDoFilterViewCell *cell = (KDToDoFilterViewCell *) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell setCellInformation:self.informationArray[indexPath.row] checkWithArray:self.selectedArray];

   return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(70, 100);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 8;
}

#pragma mark - notification
-(void)sureButtonClickedWithModel:(KDToDoMessageDataModel *)model
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^
     {
         self.collectionView.alpha = 0;
         self.containorView.alpha = 0;
     } completion:^(BOOL finished) {
         self.collectionView.frame = self.collectionViewHideFrame;
         self.containorView.frame = self.containorViewHideFrame;
         [self.todoController sortNewDataWithModel:model];
     }];
    self.state = NO;
    
    [self.funnelButton setTitle:ASLocalizedString(@"KDToDoContainorViewController_rightItem_title")forState:UIControlStateNormal];
}

#pragma mark - cellSelectAction
-(void)clickedWithCell:(KDToDoFilterViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    KDToDoMessageDataModel *model = [self.informationArray objectAtIndex:indexPath.row];
    self.filterState = YES;
    if ([self.selectedArray containsObject:model])
    {
//        [self.selectedArray removeObject:model];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^
         {
             self.collectionView.alpha = 0;
             self.containorView.alpha = 0;
         } completion:^(BOOL finished) {
             self.collectionView.frame = self.collectionViewHideFrame;
             self.containorView.frame = self.containorViewHideFrame;
         }];
        [_funnelButton setTitle:nil forState:UIControlStateNormal];
        [_funnelButton setImage:[UIImage imageNamed:@"filter" ] forState:UIControlStateNormal];
        self.state = NO;
        _funnelState = YES;
        _selectedInformation = -1;
//        self.title = ASLocalizedString(@"KDToDoContainorViewController_title");
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:AppLanguage] isEqualToString:@"en"]) {
            self.title = ASLocalizedString(@"KDToDoContainorViewController_title");
        } else {
            self.title = self.group.groupName;
        }
        self.todoController.type = KDToDoViewControllerType_Special;
        self.todoController.state = KDToDoViewControllerType_Special;
        [self.todoController sortNewDataWithModel:self.informationArray[indexPath.row]];
    }
    else
    {
        [self.selectedArray removeAllObjects];
        [self.selectedArray addObject:model];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^
         {
             self.collectionView.alpha = 0;
             self.containorView.alpha = 0;
         } completion:^(BOOL finished) {
             self.collectionView.frame = self.collectionViewHideFrame;
             self.containorView.frame = self.containorViewHideFrame;
         }];
        self.state = NO;
        self.funnelState = YES;
        self.todoController.type = KDToDoViewControllerType_Special;
        self.todoController.state = KDToDoViewControllerType_Special;
        [self.todoController sortNewDataWithModel:self.informationArray[indexPath.row]];
        [_funnelButton setTitle:nil forState:UIControlStateNormal];
        [_funnelButton setImage:[UIImage imageNamed:@"filter" ] forState:UIControlStateNormal];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - navi
- (BOOL)viewControllerShouldDismiss
{
    if (self.funnelState == NO)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
- (void)backBtnClick:(UIButton *)button
{
    if (_funnelState || _searchState)
    {
//        switch (self.todoController.state)
//        {
//            case KDToDoViewControllerType_Normal:
//            {
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//                break;
                
//            case KDToDoViewControllerType_Special:
//            {

              if (self.searchState) {
                 [self.searchBar resignFirstResponder];
                  [self.todoController.searchBar resignFirstResponder];
              }
        
             NSString *text = [[NSUserDefaults standardUserDefaults]valueForKey:@"searchBarKeyWord"];
             if (text.length > 0) {
                self.searchBar.text = text;
              }
               [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^
                {
                    self.collectionView.alpha = 0;
                    self.searchView.alpha = 0;
                    self.containorView.alpha = 0;
                } completion:^(BOOL finished) {
                    self.collectionView.frame = self.collectionViewHideFrame;
                    self.searchView.frame = self.searchViewHideFrame;
                    self.containorView.frame = self.containorViewHideFrame;
                }];
               [_funnelButton setTitle:nil forState:UIControlStateNormal];
               [_funnelButton setImage:[UIImage imageNamed:@"filter" ] forState:UIControlStateNormal];
               [self.searchButton setTitle:nil forState:UIControlStateNormal];
               [_searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
                _filterState = NO;
                _funnelState = NO;
                _searchState = NO;
                _selectedInformation = -1;
                [self.selectedArray removeAllObjects];
                [self setupRightItem];
                if ([[[NSUserDefaults standardUserDefaults]objectForKey:AppLanguage] isEqualToString:@"en"]) {
                    self.title = ASLocalizedString(@"KDToDoContainorViewController_title");
                } else {
                    self.title = self.group.groupName;
                }
                self.todoController.state = KDToDoViewControllerType_Normal;
                self.todoController.type = KDToDoViewControllerType_Normal;
                 NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"MenuSelect"];

        
                [self.todoController.todoArray removeAllObjects];
               if (index == 2) {
                   [self.todoController.tableView reloadData];
                }
                [self.todoController loadOnePageAtViewDidLoad];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - KDSearchBarDelegate
- (void)searchBar:(KDSearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length == 0) {
        searchBar.text = @"";
        //[tableView_ reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar {
    if ([self search:searchBar.text]) {
        [self.searchBar resignFirstResponder];
        self.navigationItem.rightBarButtonItems = nil;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^
         {
             self.searchView.alpha = 0;
             self.containorView.alpha = 0;
         } completion:^(BOOL finished) {
             self.searchView.frame = self.searchViewHideFrame;
             self.containorView.frame = self.containorViewHideFrame;
         }];
        self.todoController.type = KDToDoViewControllerType_Search;
        self.todoController.state = KDToDoViewControllerType_Search;
        self.todoController.searchKeyWord = searchBar.text;
        [self.todoController sortSearchDataWithText:searchBar.text];
    }
    
}

- (BOOL)search:(NSString *)text {
    BOOL succes = NO;
    NSString *string = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (string.length == 0) {
        return succes;
    }
    else
        return YES;
}

- (UIButton *)searchButton
{
    if (_searchButton == nil) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_searchButton setFrame:CGRectMake(-10.0, 0.0, 40, 40.0)];
        _searchButton.backgroundColor = [UIColor clearColor];
        [_searchButton.titleLabel setFont:FS5];
        [_searchButton setTitleColor:FC5 forState:UIControlStateNormal];
        [_searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(searchClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}
- (UIButton *)funnelButton
{
    if (_funnelButton == nil) {
        _funnelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_funnelButton setFrame:CGRectMake(-10.0, 0.0, 40, 40)];
//        [_funnelButton setTitle:ASLocalizedString(@"KDToDoContainorViewController_rightItem_title") forState:UIControlStateNormal];
        [_funnelButton.titleLabel setFont:FS5];
        [_funnelButton setTitleColor:FC5 forState:UIControlStateNormal];
        [_funnelButton setTitleColor:FC7 forState:UIControlStateHighlighted];
        [_funnelButton setImage:[UIImage imageNamed:@"filter" ] forState:UIControlStateNormal];
        _funnelButton.backgroundColor = [UIColor clearColor];
        
        [_funnelButton addTarget:self action:@selector(funnelClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _funnelButton;
}

@end
