//
//  KDGroupFileTableView.m
//  kdweibo
//
//  Created by lichao_liu on 9/15/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDGroupFileTableView.h"
#import "XTWbClient.h"
#import "KDFileInMessageDataModel.h"
#import "KDErrorDisplayView.h"
#import "MJRefresh.h"
#import "XTFileDetailViewController.h"
#import "XTPersonalFilesController.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "XTFileUtils.h"
#import "MJphotoUtils.h"
#import "KDConfigurationContext.h"

@interface KDGroupFileTableView()<XTFileDetailViewControllerDelegate,KDFileInMessageTableViewCellDelegate,ASIHTTPRequestDelegate>
@property (nonatomic, strong) UIView *tableviewBackgroundView;
@property (nonatomic, strong) XTWbClient *wbClient;
@property (nonatomic, strong) NSMutableArray *fileDataArray;
@property (nonatomic, strong) NSMutableArray *noReadDataArray;
@property (nonatomic, assign) NSInteger pageIndex;
@end

@implementation KDGroupFileTableView

- (NSMutableArray *)noReadDataArray
{
    if(!_noReadDataArray)
    {
        _noReadDataArray = [NSMutableArray new];
    }
    return _noReadDataArray;
}

- (NSMutableArray *)fileDataArray
{
    if(!_fileDataArray)
    {
        _fileDataArray = [NSMutableArray new];
    }
    return _fileDataArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.fileSource == KDGroupFileSource_recent)
    {
        if(self.noReadDataArray && self.noReadDataArray.count>0 && self.fileDataArray && self.fileDataArray.count>0)
        {
            return 2;
        }else if((!self.noReadDataArray|| self.noReadDataArray.count == 0) && (!self.fileDataArray || self.fileDataArray.count ==0))
        {
            return 0;
        }
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0 && self.noReadDataArray.count>0)
    {
        return self.noReadDataArray.count;
    }else{
        return self.fileDataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"KDFileInMessageTableViewCell";
    KDFileInMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        cell = [[KDFileInMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    KDFileInMessageDataModel *model = nil;
    BOOL isShowLine = YES;
    if(indexPath.section == 0 && self.noReadDataArray.count>0)
    {
        model = self.noReadDataArray[indexPath.row];
        if(indexPath.row == self.noReadDataArray.count -1)
        {
            isShowLine = NO;
        }
    }else if(self.fileDataArray.count>0)
    {
        model = self.fileDataArray[indexPath.row];
        if(indexPath.row == self.noReadDataArray.count -1)
        {
            isShowLine = NO;
        }
    }
    cell.delegate = self;
    [cell setCellInformation:model IndexPath:indexPath];
    cell.separatorLineStyle = isShowLine?KDTableViewCellSeparatorLineSpace:KDTableViewCellSeparatorLineNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    KDFileInMessageDataModel *model = nil;
    
    if (indexPath.section == 0) {
        if (self.noReadDataArray.count > 0) {
            model = [self.noReadDataArray objectAtIndex:indexPath.row];
            
            [self.noReadDataArray removeObjectAtIndex:indexPath.row];
            [self.fileDataArray insertObject:model atIndex:0];
            
             [self.controller setRedPointCountWithMutableArray:self.noReadDataArray.count];
            
            [self reloadData];
        }
        else {
            model = [self.fileDataArray objectAtIndex:indexPath.row];
        }
    }
    else if (indexPath.section == 1) {
        model = [self.fileDataArray objectAtIndex:indexPath.row];
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:model.fileId, @"id", model.fileName, @"fileName", model.time, @"uploadDate", model.fileExt, @"fileExt", model.length, @"length", @(model.encrypted), @"encrypted", nil];
    FileModel *fileModel = [[FileModel alloc] initWithDictionary:dict];
    XTFileDetailViewController *filePreviewVC = [[XTFileDetailViewController alloc] initWithFile:fileModel];
    filePreviewVC.hidesBottomBarWhenPushed = YES;
    filePreviewVC.fileDetailFunctionType = XTFileDetailFunctionType_count;
    filePreviewVC.threadId = self.groupId;
    filePreviewVC.messageId = model.messageId;
    PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:model.personId];
    filePreviewVC.dedicatorId = model.userId;
    filePreviewVC.dedicator = person;
    filePreviewVC.delegate = self;
    filePreviewVC.needDownLoadWhenViewWillAppear = XTFileDetailFunctionType_nomal;//model.fileHasOrNot ? XTFileDetailButtonType_open : XTFileDetailButtonType_download;
    [self.controller.navigationController pushViewController:filePreviewVC animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(self.fileSource == KDGroupFileSource_recent)
    {
        return 22;
    }else {
        return [NSNumber kdDistance2];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(self.fileSource == KDGroupFileSource_recent)
    {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 22)];
        header.backgroundColor = [UIColor kdSubtitleColor];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], 0, CGRectGetWidth(tableView.bounds) - 2 * [NSNumber kdDistance1], 22)];
        headerLabel.textColor = FC1;
        headerLabel.font = FS7;
        headerLabel.backgroundColor = [UIColor kdSubtitleColor];
        if (section == 0 && self.noReadDataArray.count>0) {
            headerLabel.text = ASLocalizedString(@"KDGroupFileTableView_Unread");
        }
        else {
            headerLabel.text = ASLocalizedString(@"KDGroupFileTableView_Readed");
        }
        [header addSubview:headerLabel];
        
        return header;
    }else{
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        return view;;
    }
}

- (void)setBackgroudHidden:(BOOL)isHidden
{
    if (!self.tableviewBackgroundView) {
        _tableviewBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.5*(CGRectGetWidth(self.frame)- 300), 122, 300, 76)];
        [_tableviewBackgroundView setUserInteractionEnabled:YES];
        _tableviewBackgroundView.backgroundColor = [UIColor clearColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableviewBackgroundView.frame), 21)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text =ASLocalizedString(@"KDGroupFileTableView_NoFile");
        titleLabel.font = FS3;
        titleLabel.textColor = FC2;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_tableviewBackgroundView addSubview:titleLabel];
        
        UIButton *btn = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDGroupFileTableView_UploadFile")];
        [btn addTarget:self action:@selector(createBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        btn.layer.cornerRadius = 6;
        btn.frame = CGRectMake( (_tableviewBackgroundView.frame.size.width - 100)/2, 36, 100, 44);
        [btn setCircle];
        [_tableviewBackgroundView addSubview:btn];
        
        
        [self addSubview:_tableviewBackgroundView];
    }
    _tableviewBackgroundView.hidden = isHidden;
}

- (void)createBtnClicked:(id)sender
{
    [self.controller upload:nil];
}

- (void)reloadTableView
{
    [self reloadData];
    if(self.fileSource == KDGroupFileSource_recent)
    {
        if(self.noReadDataArray.count>0)
        {
            [self.controller setRedPointCountWithMutableArray:self.noReadDataArray.count];
        }
    }
    if(self.fileDataArray.count == 0 && self.noReadDataArray.count == 0)
    {
        [self setBackgroudHidden:NO];
    }else{
        [self setBackgroudHidden:YES];
    }
}

- (void)loadData
{
    if(self.fileSource == KDGroupFileSource_recent)
    {
        [self addRecentHeader];
        [self.wbClient querySevendayFileWithNetWorkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId threadId:self.groupId desc:YES];
    }else{
        if(self.pageIndex == 0)
        {
            self.pageIndex = 1;
        }
        [self addHeader];
        [self.wbClient queryListMessageFileWithNetWorkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId threadId:self.groupId pageIndex:self.pageIndex pageSize:20 qryType:self.fileSource desc:YES];
    }
    [self headerBeginRefreshing];
}

- (XTWbClient *)wbClient {
    if (!_wbClient) {
        _wbClient = [[XTWbClient alloc] initWithTarget:self action:@selector(queryRecentDataDidReceived:result:)];
    }
    return _wbClient;
}

- (void)queryRecentDataDidReceived:(XTWbClient *)client result:(BOSResultDataModel *)result {
     [self headerEndRefreshing];
     [self footerEndRefreshing];
    if (result.success) {
        if(self.fileSource == KDGroupFileSource_recent)
        {
            NSArray *tempReadArray = [[result.dictJSON objectForKey:@"data"] objectForKey:@"readFile"];
            NSArray *tempNotReadArray = [[result.dictJSON objectForKey:@"data"] objectForKey:@"noReadFile"];
            if(self.fileDataArray.count>0)
            {
                [self.fileDataArray removeAllObjects];
            }
            if(self.noReadDataArray.count>0)
            {
                [self.noReadDataArray removeAllObjects];
            }
            __block KDFileInMessageDataModel *model = nil;
            if (![tempReadArray isKindOfClass:[NSNull class]] && tempNotReadArray != nil) {
                [tempReadArray enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger i, BOOL *stop) {
                    model = [[KDFileInMessageDataModel alloc] initWithDictionary:dic];
                    if(model && ![model isKindOfClass:[NSNull class]])
                    {
                        [self.fileDataArray addObject:model];
                    }
                }];
            }
            
            if (![tempNotReadArray isKindOfClass:[NSNull class]] && tempNotReadArray != nil) {
                [tempNotReadArray enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger i, BOOL *stop) {
                    model = [[KDFileInMessageDataModel alloc] initWithDictionary:dic];
                    if(model && ![model isKindOfClass:[NSNull class]]) {
                        [self.noReadDataArray addObject:model];
                    }
                }];
            }
        }else{
            if(self.pageIndex == 1)
            {
                if(self.fileDataArray.count >0)
                {
                    [self.fileDataArray removeAllObjects];
                }
                [self addHeader];
            }
            __block KDFileInMessageDataModel *model = nil;
            NSArray *tempArray = [result.dictJSON objectForKey:@"data"];
            if (![tempArray isKindOfClass:[NSNull class]] && tempArray)
            {
                for (NSInteger index = 0; index <tempArray.count; index++) {
                    model = [[KDFileInMessageDataModel alloc] initWithDictionary:tempArray[index]];
                    if(model)
                    {
                    [self.fileDataArray addObject:model];
                    }
                }
                if(self.fileDataArray.count >= self.pageIndex * 20)
                {
                    if(self.pageIndex == 1)
                    {
                        [self addFooter];
                    }
                }else if(self.pageIndex >1){
                    [self removeFooter];
                }
            }
    
        }
    }else{
        [KDErrorDisplayView showErrorMessage:ASLocalizedString(@"KDGroupFileTableView_LoadFail")inView:self];
    }
    [self reloadTableView];
}

- (void)addFooter
{
    __weak KDGroupFileTableView *weakSelf = self;
    [self addFooterWithCallback:^{
        [weakSelf loadMoreData:YES];
    }];
}

- (void)addHeader
{
    __weak KDGroupFileTableView *weakSelf = self;
    [self addHeaderWithCallback:^{
        [weakSelf loadMoreData:NO];
    }];
}

- (void)addRecentHeader
{
    __weak KDGroupFileTableView *weakSelf = self;
    [self addHeaderWithCallback:^{
         [weakSelf.wbClient querySevendayFileWithNetWorkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId threadId:weakSelf.groupId desc:YES];
    }];
}

- (void)loadMoreData:(BOOL)flag
{
    if(flag)
    {
    self.pageIndex ++;
    }else{
        self.pageIndex = 1;
    }
    [self.wbClient queryListMessageFileWithNetWorkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId threadId:self.groupId pageIndex:self.pageIndex pageSize:20 qryType:self.fileSource desc:YES];
}

- (void)dealloc
{
    self.wbClient = nil;
}


- (void)cell:(KDFileInMessageTableViewCell *)cell openOrDownloadFileWithModel:(KDFileInMessageDataModel *)model {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:model.fileId, @"id", model.fileName, @"fileName", model.time, @"uploadDate", model.fileExt, @"fileExt", model.length, @"length", @(model.encrypted), @"encrypted", nil];
    FileModel *fileModel = [[FileModel alloc] initWithDictionary:dict];
    XTFileDetailViewController *filePreviewVC = [[XTFileDetailViewController alloc] initWithFile:fileModel];
    filePreviewVC.hidesBottomBarWhenPushed = YES;
    filePreviewVC.fileDetailFunctionType = XTFileDetailFunctionType_count;
    filePreviewVC.threadId = self.groupId;
    filePreviewVC.messageId = model.messageId;
    filePreviewVC.dedicatorId = model.userId;
    filePreviewVC.delegate = self;
    filePreviewVC.needDownLoadWhenViewWillAppear = model.fileHasOrNot ? XTFileDetailButtonType_open : XTFileDetailButtonType_makeDownloadAction;
     [self.controller.navigationController pushViewController:filePreviewVC animated:YES];
    
    
    [self makeNoteForChangeRecentFileReadStateWithCell:cell Model:model];
}

- (void)cell:(KDFileInMessageTableViewCell *)cell personNameButtonPressedWithModel:(KDFileInMessageDataModel *)model {
        XTPersonalFilesController *personalFilesController = [[XTPersonalFilesController alloc] init];
        personalFilesController.personModel = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonDetailWithWebPersonId:model.userId];
        personalFilesController.threadId = self.groupId;
        [self.controller.navigationController pushViewController:personalFilesController animated:YES];
}

- (void)fileForwardFinish:(XTFileDetailViewController *)controller
{
    
}

- (void)controller:(XTFileDetailViewController *)controller downloadFinishedWithModel:(FileModel *)model
{
    if(self.fileSource == KDGroupFileSource_recent)
    {
        __block NSInteger theLocation = 0;
        __block KDFileInMessageDataModel *storeModel = nil;
        
        [self.noReadDataArray enumerateObjectsUsingBlock:^(KDFileInMessageDataModel *dataModel, NSUInteger i, BOOL *stop) {
            if ([dataModel.fileId isEqualToString:model.fileId]) {
                storeModel = dataModel;
                theLocation = i;
            }
        }];
        
        if (storeModel != nil && ![storeModel isKindOfClass:[NSNull class]]) {
            [self.noReadDataArray removeObjectAtIndex:theLocation];
            storeModel.fileHasOrNot = YES;
            [self.fileDataArray insertObject:storeModel atIndex:0];
        }
        
        [self.controller setRedPointCountWithMutableArray:self.noReadDataArray.count];
        [self reloadData];
    }else{
        __block NSInteger theLocation = 0;
        __block KDFileInMessageDataModel *storeModel = nil;
        
        [self.fileDataArray enumerateObjectsUsingBlock:^(KDFileInMessageDataModel *dataModel, NSUInteger i, BOOL *stop) {
            if ([dataModel.fileId isEqualToString:model.fileId]) {
                storeModel = dataModel;
                theLocation = i;
            }
        }];
        
        if (storeModel != nil && ![storeModel isKindOfClass:[NSNull class]])
        {
            storeModel.fileHasOrNot = YES;
            [self.fileDataArray replaceObjectAtIndex:theLocation withObject:storeModel];
        }
        [self reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:theLocation inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (void)makeNoteForChangeRecentFileReadStateWithCell:(KDFileInMessageTableViewCell *)cell Model:(KDFileInMessageDataModel *)model {
    NSIndexPath *path = [self indexPathForCell:cell];
 
        if (path.section == 0) {
            if (self.noReadDataArray.count > 0) {
                KDFileInMessageDataModel *theModel = [self.noReadDataArray objectAtIndex:path.row];
                theModel.fileHasOrNot = YES;
 
                [self.noReadDataArray removeObjectAtIndex:path.row];
                [self.fileDataArray insertObject:model atIndex:0];
                [self reloadData];
                
                [self.controller setRedPointCountWithMutableArray:self.noReadDataArray];
            }
        }
}

@end
