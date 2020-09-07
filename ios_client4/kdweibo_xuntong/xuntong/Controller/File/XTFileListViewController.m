//
//  XTFileListViewController.m
//  XT
//
//  Created by kingdee eas on 13-11-1.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTFileListViewController.h"
#import "XTCloudClient.h"
#import "FileModel.h"
#import "XTFileUtils.h"
#import "XTChatViewController.h"
#import "XTFileDetailViewController.h"
#import "UIImage+XT.h"
#import "UIButton+XT.h"
#import "XTFileCell.h"
#import "KDWeiboAppDelegate.h"
#import "KDRefreshTableView.h"
#import "XTWbClient.h"
#import "MBProgressHUD.h"
#import "XTMyFilesViewController.h"
#import "KDWPSFileShareManager.h"
#import "KDMultiVoiceViewController.h"

#define SendBGHeight 55.0

@interface XTFileListViewController() <KDRefreshTableViewDataSource,KDRefreshTableViewDelegate>

@property (nonatomic,strong) KDRefreshTableView *tableView;
@property (nonatomic,copy)   NSString *titleText;
@property (nonatomic,strong) UIButton *backButton;

@property (nonatomic,strong) NSMutableArray *fileList;
@property (nonatomic,strong) NSMutableArray *foldList;
@property (nonatomic,strong) NSString *folderID;

@property (nonatomic,strong) UIButton *rightButton;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) XTWbClient *wbClient;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) BOOL isFirstLoading;
@property (nonatomic,assign) BOOL isPreviewed;
@property (nonatomic, strong) UIView *backgroundView;
@end

@implementation XTFileListViewController

- (id)initWithFolderId:(NSString *)folderID
{
    if (self = [super init]) {
        
        _folderID = [[NSString alloc] initWithFormat:@"%@", folderID];
        _parentID = [NSString new];
        _fileList = [[NSMutableArray alloc] initWithCapacity:4];
        _foldList = [[NSMutableArray alloc] init];
        _pageIndex = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFileListFinished:) name:Notify_FileList object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFileFinished:) name:Notify_DeleteFile object:nil];
        _backTitleArr = [[NSMutableArray alloc] initWithCapacity:1];
        _backFolderIDArr = [[NSMutableArray alloc] initWithCapacity:1];
        [_backFolderIDArr addObject:@"root"];
    }
    return self;
}
- (void)loadView{
    
    [super loadView];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    bounds.size.height -= StatusBarHeight + NavigationBarHeight;
    UIView *view = [[UIView alloc] initWithFrame:bounds];
    self.view = view;
}
- (BOOL)isPreviewed{

    BOOL isPreviewed = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(isPreviewModel)]) {
        isPreviewed = [_delegate isPreviewModel];
    }
    
    _isPreviewed = isPreviewed;
    
    return isPreviewed;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    self.view.backgroundColor = BOSCOLORWITHRGBADIVIDE255(250, 250, 250, 1.0);
    CGRect rect = self.view.bounds;
    if (!self.isPreviewed) {
        rect.size.height -= SendBGHeight;
    }
//    rect.origin.y = 64;
    self.tableView = [[KDRefreshTableView alloc] initWithFrame:rect kdRefreshTableViewType:KDRefreshTableViewType_Both style:UITableViewStylePlain];
    self.tableView.backgroundColor = MESSAGE_BG_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 65.0;
    [self.view addSubview:self.tableView];
    //多选
    self.tableView.allowsSelection = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.showsVerticalScrollIndicator = YES;
    
    self.title = ASLocalizedString(@"XTFileListViewController_MyUpload");
    self.titleText = ASLocalizedString(@"XTFileListViewController_MyUpload");
    
    [_tableView setFirstInLoadingState];
    [self getFiles];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //返回按钮
    self.backButton = [UIButton backBtnInBlueNavWithTitle:self.backBtnTitle];
    [self.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setNavigationStyle:KDNavigationStyleYellow];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (MBProgressHUD *)hud{
    if (!_hud) {
        UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
        _hud = [[MBProgressHUD alloc] initWithView:window];
        [window addSubview:_hud];
    }
    return _hud;
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
        label.text = ASLocalizedString(@"XTFileListViewController_Show");
        
        [_backgroundView addSubview:label];
        
        [_tableView addSubview:_backgroundView];
    }
    _backgroundView.hidden = NO;
    
}
#pragma mark - network methods
- (void)getFiles{
    
    NSInteger index = _pageIndex;
    NSInteger pageSize = 20;
    
    //当前刷新的数量要与当前文件数一致
    if (!_isFirstLoading) {
        pageSize = index * pageSize;
    }
    
    self.wbClient = [[XTWbClient alloc] initWithTarget:self action:@selector(getFilesDidReceived:result:)];
    [_wbClient getMyFileAtIndex:1 pageSize:pageSize networkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId docBox:_folderID isFromSharePlay:self.fromType == 2];
}
- (void)getFilesDidReceived:(XTWbClient *)client result:(BOSResultDataModel *)result{
    
    if (_hud) {
        [_hud hide:YES];
    }
    
    [_tableView finishedRefresh:YES];
    
    if (client.hasError || !result.success || ![result.data isKindOfClass:[NSDictionary class]]) {
        
        [self setBackgroud:([_fileList count] + [_foldList count])==0];
        
        return;
    }
    
    [_foldList removeAllObjects];
    [_fileList removeAllObjects];
    
    NSArray *folderInfo = [result.data objectForKey:@"docBoxs"];
    NSArray *fileInfo   = [result.data objectForKey:@"docInfos"];
    
    NSInteger folderCount = 0;
    NSInteger fileCount = 0;
    
    if ([folderInfo isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary *dic in folderInfo) {
            FoldModel *model = [[FoldModel alloc] initWithDictionary:dic];
            [_foldList addObject:model];
        }
        
        folderCount = folderInfo.count;
    }
    
    if ([fileInfo isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary *dic in fileInfo) {
            DocumentFileModel *model = [[DocumentFileModel alloc] initWithDictionary:dic formType:1];
            [_fileList addObject:model];
        }
        
        fileCount = fileInfo.count;
    }
  
    if (fileCount + folderCount < 20*_pageIndex) {
        [_tableView setBottomViewHidden:YES];
    }
    else{
        [_tableView setBottomViewHidden:NO];
    }
    
    if (_isFirstLoading) {
        _isFirstLoading = NO;
    }
    
    [self setBackgroud:([_fileList count] + [_foldList count])==0];
    
    [_tableView reloadData];
}
- (void)getMoreFiles{
    
    NSInteger index = _pageIndex +1;
    NSInteger pageSize = 20;
    
    self.wbClient = [[XTWbClient alloc] initWithTarget:self action:@selector(getMoreFilesDidReceived:result:)];
    [_wbClient getMyFileAtIndex:index pageSize:pageSize networkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId docBox:_folderID isFromSharePlay:self.fromType == 2];
}

- (void)getMoreFilesDidReceived:(XTWbClient *)client result:(BOSResultDataModel *)result{
    
    [_tableView finishedLoadMore];
    
    if (client.hasError || !result.success || ![result.data isKindOfClass:[NSDictionary class]]) {
        
        return;
    }
    
    _pageIndex ++;
    
    NSArray *folderInfo = [result.data objectForKey:@"docBoxs"];
    NSArray *fileInfo   = [result.data objectForKey:@"docInfos"];
    
    NSInteger folderCount = 0;
    NSInteger fileCount = 0;
    
    if ([folderInfo isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary *dic in folderInfo) {
            FoldModel *model = [[FoldModel alloc] initWithDictionary:dic];
            [_foldList addObject:model];
        }
        
        folderCount = folderInfo.count;
    }
    
    if ([fileInfo isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary *dic in fileInfo) {
            DocumentFileModel *model = [[DocumentFileModel alloc] initWithDictionary:dic];
            [_fileList addObject:model];
        }
        
        fileCount = fileInfo.count;
    }
    
    if (fileCount + folderCount < 20) {
        [_tableView setBottomViewHidden:YES];
    }
    else{
        [_tableView setBottomViewHidden:NO];
    }
    
    [_tableView reloadData];
}

- (void)deleteFileWithFile:(DocumentFileModel *)file {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:ASLocalizedString(@"Delete_File_Confirm") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Sure") style:UIPreviewActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.wbClient = [[XTWbClient alloc] initWithTarget:self action:@selector(deleteMyDocDidReceived:result:)];
        [self.wbClient deleteMyDocWithDocId:file.fileId docTypes:1 docBoxId:0 networkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId userId:[KDManagerContext globalManagerContext].userManager.currentUser.userId];
        [self.hud show:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Cancel") style:UIPreviewActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deleteMyDocDidReceived:(XTWbClient *)client result:(BOSResultDataModel *)result{
    if (client.hasError || !result.success) {
        [self.hud setLabelText:ASLocalizedString(@"KDChooseOrganizationViewController_Error")];
        [self.hud hide:YES afterDelay:1.0];
        return;
    }
    [self.hud hide:YES];
    [self getFiles];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_foldList count] + [_fileList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_foldList count]) {
        static NSString *FoldCellIdentifier = @"FoldCellIdentifier";
        XTFoldCell *cell = (XTFoldCell *)[tableView dequeueReusableCellWithIdentifier:FoldCellIdentifier];
        if (cell == nil) {
            cell = [[XTFoldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FoldCellIdentifier];
            cell.backgroundColor = [UIColor kdBackgroundColor2];//MESSAGE_CT_COLOR;
        }
        cell.fold = [_foldList objectAtIndex:indexPath.row];
        
        cell.separatorLineInset = UIEdgeInsetsMake(0, 66, 0, 0);
        cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        
        return cell;
    }
    else {
        static NSString *FileCellIdentifier = @"FileCellIdentifier";
        XTFileCell *cell = (XTFileCell *)[tableView dequeueReusableCellWithIdentifier:FileCellIdentifier];
        if (cell == nil) {
            cell = [[XTFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FileCellIdentifier];
            cell.backgroundColor = MESSAGE_CT_COLOR;
        }
        cell.isPreview = self.isPreviewed;
        int row =(int) (indexPath.row - [_foldList count]);
        DocumentFileModel *file = [_fileList objectAtIndex:row];
        cell.file = file;
        
        cell.checked = NO;
        if (!_isPreviewed) {
            if (_delegate && [_delegate respondsToSelector:@selector(fileChecked:)]) {
                cell.checked = [_delegate fileChecked:file];
            }
        }
        
        if(!_isPreviewed){
            cell.separatorLineInset = UIEdgeInsetsMake(0, 50, 0, 0);
        }else{
            cell.separatorLineInset = UIEdgeInsetsMake(0, 66, 0, 0);
        }
        cell.separatorLineStyle = (_foldList.count + _fileList.count - 1 == indexPath.row) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < [_foldList count]) {
        
        FoldModel *fold = [_foldList objectAtIndex:indexPath.row];
        [_backTitleArr addObject:self.titleText];
        self.navigationItem.title = fold.name;
        self.titleText = fold.name;
        
        _folderID = fold.foldId;
        _parentID = fold.fatherId;
        [_backFolderIDArr addObject:_parentID];
        [_fileList removeAllObjects];
        [_foldList removeAllObjects];
        _pageIndex = 1;
        
        [self.hud setLabelText:ASLocalizedString(@"XTFileListViewController_Wait")];
        [self.hud show:YES];
        
        [self getFiles];
    }
    else {
        //预览模式
        if (_isPreviewed) {
            
            DocumentFileModel *file = [_fileList objectAtIndex:indexPath.row - [_foldList count]];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:file.fileId,@"id", file.fileName,@"fileName", [file.time formatWithFormatter:KD_DATE_ISO_8601_LONG_FORMATTER],@"uploadDate", file.fileExt,@"fileExt", [NSString stringWithFormat:@"%lu",(unsigned long)file.length], @"length",nil];
            FileModel *fileModel = [[FileModel alloc] initWithDictionary:dict];
            XTFileDetailViewController *filePreviewVC = [[XTFileDetailViewController alloc] initWithFile:fileModel];
            filePreviewVC.hidesBottomBarWhenPushed = YES;
            filePreviewVC.bShouldNotPopToRootVC = YES;
            if(_fromType == 2)
            {
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

            [self.navigationController pushViewController:filePreviewVC animated:YES];
        }
        //发送模式
        else {
            XTFileCell *cell = (XTFileCell *)[tableView cellForRowAtIndexPath:indexPath];
            BOOL checked = cell.checked;
            [cell setChecked:!checked animated:YES];
            
            if (_delegate && [_delegate respondsToSelector:@selector(fileDidSelected:)]) {
                int row = (int)(indexPath.row - [_foldList count]);
                DocumentFileModel *file = [_fileList objectAtIndex:row];
                
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
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 删除
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:ASLocalizedString(@"Mark_delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        DocumentFileModel *file =[ _fileList objectAtIndex:indexPath.row - _foldList.count];
        [self deleteFileWithFile:file];
    }];
    
    return @[deleteAction];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < [_foldList count]) {
        return NO;
    } else {
        if (_isPreviewed) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_tableView kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [_tableView kdRefreshTableviewDidEndDraging:scrollView];
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
#pragma mark - Button Action

- (void)back:(UIButton *)btn
{
    if (![_parentID isEqualToString:@"root"]) {
        self.navigationItem.title = [_backTitleArr lastObject];
        self.titleText = [_backTitleArr lastObject];
        [_backTitleArr removeLastObject];
        [_fileList removeAllObjects];
        [_foldList removeAllObjects];
        
        [self.hud setLabelText:ASLocalizedString(@"XTFileListViewController_Wait")];
        [self.hud show:YES];
        
        _folderID = _parentID;
        [_backFolderIDArr removeLastObject];
        _parentID = [_backFolderIDArr lastObject];
        
        [self getFiles];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}



- (void)previewBtnClick:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(fileModelChanged)]) {
        [_delegate fileModelChanged];
        
        [self.tableView reloadData];
        
        CGRect tableFrame = self.tableView.frame;
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
            self.tableView.frame = tableFrame;
        }];
    }
}

@end
