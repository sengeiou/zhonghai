//
//  XTMyFileListViewController.m
//  kdweibo
//
//  Created by bird on 14-10-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTMyFileListViewController.h"
#import "KDRefreshTableView.h"
#import "XTWbClient.h"
#import "XTFileCell.h"
#import "XTFileDetailViewController.h"
#import "UIButton+XT.h"
#import "XTMyFilesViewController.h"
#import "KDWPSFileShareManager.h"
#import "KDMultiVoiceViewController.h"

@interface XTMyFileListViewController () <KDRefreshTableViewDataSource, KDRefreshTableViewDelegate>
@property (nonatomic, strong) KDRefreshTableView *myTableView;
@property (nonatomic, strong) XTWbClient         *client;
@property (nonatomic, strong) NSMutableArray     *filesArray;
@property (nonatomic,strong) UIButton *rightButton;

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) BOOL isFirstLoading;
@property (nonatomic, assign) BOOL isPreviewed;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

static NSString *rqType[] = {@"download", @"stow"};
//static NSString *titleType[] = {ASLocalizedString(@"我下载的"), ASLocalizedString(@"XTMyFileListViewController_MyCollect")};

#define SendBGHeight 55.0

@implementation XTMyFileListViewController
- (MBProgressHUD *)hud{
    if (!_hud) {
        UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
        _hud = [[MBProgressHUD alloc] initWithView:window];
        [window addSubview:_hud];
    }
    return _hud;
}
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _pageIndex = 1;
        _isFirstLoading = true;
        self.filesArray = [NSMutableArray array];
    }
    return self;
}
- (BOOL)isPreviewed{
    
    BOOL isPreviewed = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(isPreviewModel)]) {
        isPreviewed = [_delegate isPreviewModel];
    }
    
    _isPreviewed = isPreviewed;
    
    return isPreviewed;
}
- (void)loadView{
    
    [super loadView];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    bounds.size.height -= StatusBarHeight + NavigationBarHeight;
    UIView *view = [[UIView alloc] initWithFrame:bounds];
    self.view = view;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_fromType != 3) {
        if (_fromType == 0 ) {
            self.title = ASLocalizedString(@"XTMyFileListViewController_MyDownLoad");
        }
        else
        {
            self.title = ASLocalizedString(@"XTMyFileListViewController_MyCollect");
        }

    }
    //解决高度上升
//    if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)
//        self.edgesForExtendedLayout=UIRectEdgeNone;
    [KDWeiboAppDelegate setExtendedLayout:self];
    
    //文件传输助手过来的需要切换两种模式
    BOOL isFromSend = _delegate !=nil;
    
    //预览|发送模式按钮
    UIButton *rightBtn = [UIButton buttonWithTitle:self.isPreviewed?ASLocalizedString(@"XTFileListViewController_Send"): ASLocalizedString(@"XTFileListViewController_PreView")];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(previewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.hidden = !isFromSend;
    
    self.rightButton = rightBtn;
    [rightBtn sizeToFit];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = 0;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:space,rightItem, nil];
    
    UIButton *btn = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn]];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];//BOSCOLORWITHRGBADIVIDE255(250, 250, 250, 1.0);
    CGRect rect = self.view.bounds;
    if (!self.isPreviewed) {
        rect.size.height -= SendBGHeight;
    }
//    rect.origin.y = 64;
    KDRefreshTableView *tableView = [[KDRefreshTableView alloc] initWithFrame:rect kdRefreshTableViewType:KDRefreshTableViewType_Both style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setBackgroundColor:[UIColor clearColor]];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [tableView setBottomViewHidden:YES];
    
    self.myTableView = tableView;
    
    if(self.fromType == 0 || self.fromType == 3)
    [self getFiles];
    [tableView setFirstInLoadingState];
    
}

- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setNavigationStyle:KDNavigationStyleYellow];
    
    if(self.fromType == 1)
        [self getFiles];
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
        
        if (_fromType == 3 ) {
            if ([self.title isEqualToString:@"我下载的"]) {
                label.text = ASLocalizedString(@"XTMyFileListViewController_Record");
            }else
                 label.text = ASLocalizedString(@"XTMyFileListViewController_LongPress");
        }else
        {
             label.text = _fromType==0?ASLocalizedString(@"XTMyFileListViewController_Record"):ASLocalizedString(@"XTMyFileListViewController_LongPress");
        }

        [_backgroundView addSubview:label];
        
        [_myTableView addSubview:_backgroundView];
    }
    _backgroundView.hidden = NO;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - network methods

- (void)getFiles{

    NSInteger index = _pageIndex;
    NSInteger pageSize = 20;
    
    //当前刷新的数量要与当前文件数一致
    if (!_isFirstLoading) {
        pageSize = index * pageSize;
    }
    
    self.client = [[XTWbClient alloc] initWithTarget:self action:@selector(getFilesDidReceived:result:)];
    NSString *type = nil;
    if (_fromType == 3) {
        if ([self.title isEqualToString:@"我下载的"]) {
            type = @"download";
        }else
        {
            type = @"stow";
        }
    }
    else
    {
        type = rqType[_fromType];
    }
    [_client getFileListAtIndex:1 pageSize:pageSize type:type networkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId isFromSharePlay:self.fromType == 3];
}
- (void)getFilesDidReceived:(XTWbClient *)client result:(BOSResultDataModel *)result{

    [_myTableView finishedRefresh:YES];
    
    if (client.hasError || !result.success || ![result.data isKindOfClass:[NSArray class]]) {
        
        
        [self setBackgroud:[_filesArray count] == 0];
        
        return;
    }
    
    [_filesArray removeAllObjects];
    
    for (NSDictionary *dic in result.data) {
        DocumentFileModel *model = [[DocumentFileModel alloc] initWithDictionary:dic];
        [_filesArray addObject:model];
    }
    
    if ([(NSArray *)result.data count] < 20*_pageIndex) {
        [_myTableView setBottomViewHidden:YES];
    }
    else{
        [_myTableView setBottomViewHidden:NO];
    }
    
    if (_isFirstLoading) {
        _isFirstLoading = NO;
    }
    
    [self setBackgroud:[_filesArray count] == 0];
    
    [_myTableView reloadData];
}
- (void)getMoreFiles{

    NSInteger index = _pageIndex +1;
    NSInteger pageSize = 20;
    
    self.client = [[XTWbClient alloc] initWithTarget:self action:@selector(getMoreFilesDidReceived:result:)];
    [_client getFileListAtIndex:index pageSize:pageSize type:rqType[_fromType] networkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId isFromSharePlay:self.fromType == 3];
}
- (void)getMoreFilesDidReceived:(XTWbClient *)client result:(BOSResultDataModel *)result{

    [_myTableView finishedLoadMore];
    
    if (client.hasError || !result.success || ![result.data isKindOfClass:[NSArray class]]) {
        
        return;
    }
    
    _pageIndex ++;
    
    for (NSDictionary *dic in result.data) {
        DocumentFileModel *model = [[DocumentFileModel alloc] initWithDictionary:dic];
        [_filesArray addObject:model];
    }
    
    if ([(NSArray *)result.data count] < 20) {
        [_myTableView setBottomViewHidden:YES];
    }
    else{
        [_myTableView setBottomViewHidden:NO];
    }
    
    [_myTableView reloadData];
}

- (void)deleteFileWithFile:(DocumentFileModel *)file {
    if (self.fromType == 0) { // 我下载的
        self.client = [[XTWbClient alloc] initWithTarget:self action:@selector(removeDownloadDocDidReceived:result:)];
        [self.client removeDownloadDocWithFileId:file.fileId networkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId userId:[KDManagerContext globalManagerContext].userManager.currentUser.userId];
    }
    else if (self.fromType == 1) { // 我收藏的，取消收藏就可以移除
        self.client = [[XTWbClient alloc] initWithTarget:self action:@selector(cancelStowFileDidReceived:result:)];
        [self.client cancelStowFile:file.fileId];
    }
    [self.hud show:YES];
}
- (void)removeDownloadDocDidReceived:(XTWbClient *)client result:(BOSResultDataModel *)result{
    if (client.hasError || !result.success) {
        [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    [self.hud hide:YES];
    [self getFiles];
}
- (void)cancelStowFileDidReceived:(XTWbClient *)client result:(BOSResultDataModel *)result{
    if (client.hasError || !result.success) {
        [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    [self.hud hide:YES];
    [self getFiles];
}

#pragma mark - action
- (void)previewBtnClick:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(fileModelChanged)]) {
        [_delegate fileModelChanged];
        
        [_myTableView reloadData];
        
        CGRect tableFrame = _myTableView.frame;
        if (_isPreviewed) {
            //进入发送状态
            _rightButton.title = ASLocalizedString(@"XTFileListViewController_PreView");
            _isPreviewed = NO;
            tableFrame.size.height = CGRectGetHeight(self.view.bounds) - SendBGHeight;
        } else {
            //进入预览状态
            _rightButton.title = ASLocalizedString(@"XTFileListViewController_Send");
            _isPreviewed = YES;
            tableFrame.size.height = CGRectGetHeight(self.view.bounds);
        }
        [_rightButton sizeToFit];
        [UIView animateWithDuration:0.35 animations:^{
            _myTableView.frame = tableFrame;
        }];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView DataSources And Delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _filesArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *recentlyCell = @"recentlyCell";
    
    XTFileCell *cell = (XTFileCell *)[tableView dequeueReusableCellWithIdentifier:recentlyCell];
    if (cell == nil) {
        cell = [[XTFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recentlyCell];
    }
    cell.isPreview = self.isPreviewed;
    
    DocumentFileModel *file = [_filesArray objectAtIndex:indexPath.row];
    cell.file = file;
    
    cell.checked = NO;
    if (!_isPreviewed) {
        if (_delegate && [_delegate respondsToSelector:@selector(fileChecked:)]) {
            cell.checked = [_delegate fileChecked:file];
        }
    }
    
    if(_filesArray.count - 1 != indexPath.row){
        if(!_isPreviewed){
            cell.separatorLineInset = UIEdgeInsetsMake(0, 50, 0, 0);
        }else{
            cell.separatorLineInset = UIEdgeInsetsMake(0, 66, 0, 0);
        }
    }
    cell.separatorLineStyle = (_filesArray.count -1 == indexPath.row) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    //预览模式
    if (_isPreviewed) {
        
        DocumentFileModel *file = [_filesArray objectAtIndex:indexPath.row];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:file.fileId,@"id", file.fileName,@"fileName", [file.time formatWithFormatter:KD_DATE_ISO_8601_LONG_FORMATTER],@"uploadDate", file.fileExt,@"fileExt", [NSString stringWithFormat:@"%lu",(unsigned long)file.length], @"length",nil];
        FileModel *fileModel = [[FileModel alloc] initWithDictionary:dict];
        XTFileDetailViewController *filePreviewVC = [[XTFileDetailViewController alloc] initWithFile:fileModel];
        
        if (_fromType == 3) {
            if(fileModel.isFinished)
            {
                //已经下载完成 直接发起分享
                NSString *fileName = fileModel.name;
                if (!fileName || [fileName isEqualToString:@""]) {
                    fileName = [NSString stringWithFormat:@"/%@.%@", fileModel.fileId,fileModel.ext];
                }
                NSString *path = [[ContactUtils fileFilePathWithFileId:fileModel.fileId] stringByAppendingFormat:@".%@", fileModel.ext];
                [[KDWPSFileShareManager sharedInstance] startSharePlay:[NSData dataWithContentsOfFile:path] withFileName:fileModel.name];
                
                NSArray *viewsControllers = self.rt_navigationController.viewControllers;
                for (RTContainerController *viewController in viewsControllers) {
                    if([viewController.contentViewController isMemberOfClass:[KDMultiVoiceViewController class]])
                    {
                        [self.navigationController popToViewController:viewController.contentViewController animated:NO];
                        return;
                    }
                }
                
                return;
            }else{
                filePreviewVC.needDownLoadWhenViewWillAppear = XTFileDetailButtonType_makeDownloadAction;
                filePreviewVC.isFromSharePlayWPS = YES;
            }

        }
        filePreviewVC.hidesBottomBarWhenPushed = YES;
        filePreviewVC.bShouldNotPopToRootVC = YES;
        [self.navigationController pushViewController:filePreviewVC animated:YES];
    }
    //发送模式
    else {
        XTFileCell *cell = (XTFileCell *)[tableView cellForRowAtIndexPath:indexPath];
        BOOL checked = cell.checked;
        [cell setChecked:!checked animated:YES];
        
        if (_delegate && [_delegate respondsToSelector:@selector(fileDidSelected:)]) {
            DocumentFileModel *file = [_filesArray objectAtIndex:indexPath.row];
            
            if (checked){
                if ([_delegate respondsToSelector:@selector(fileDidReomved:)]) {
                    [_delegate fileDidReomved:file];
                }
            }
            else{
                
                if ([_delegate respondsToSelector:@selector(fileDidReomved:)]) {
                    [_delegate fileDidSelected:file];
                }
            }
        }
        
    }
 
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 移除
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:ASLocalizedString(@"Remove") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        DocumentFileModel *file =[ _filesArray objectAtIndex:indexPath.row];
        [self deleteFileWithFile:file];
    }];
    
    return @[deleteAction];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isPreviewed) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_myTableView kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [_myTableView kdRefreshTableviewDidEndDraging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}
#pragma mark - KDRefreshTableViewDelegate methods

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    
    [self getMoreFiles];
}
- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView{

    [self getFiles];
}
@end
