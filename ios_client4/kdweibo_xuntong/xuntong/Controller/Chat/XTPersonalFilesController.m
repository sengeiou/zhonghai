//
//  XTPersonalFilesController.m
//  kdweibo
//
//  Created by lichao_liu on 15/3/9.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "XTPersonalFilesController.h"
#import "XTWbClient.h"
#import "XTFileCell.h"
#import "XTFileDetailViewController.h"
#import "NSDate+Additions.h"
#import "MJRefresh.h"
#import "XTFileUtils.h"
//#import "MJphotoUtils.h"
@interface XTPersonalFilesController()<UITableViewDataSource, UITableViewDelegate>
{
    NSInteger _pageSize;
}
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) XTWbClient *client;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSMutableArray *filesArray;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, assign) NSInteger pageIndex;
@end

@implementation XTPersonalFilesController

- (void)dealloc {
    //[_client cancelRequest];
}

- (NSMutableArray *)filesArray
{
    if(!_filesArray)
    {
        _filesArray = [NSMutableArray new];
    }
    return _filesArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.personModel.personName;
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-kd_StatusBarAndNaviHeight) style:UITableViewStylePlain];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableview];
    
    if(!self.client)
    {
        self.client = [[XTWbClient alloc] initWithTarget:self action:@selector(showalluploadfile:result:)];
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MBProgressHUD HUDForView:self.view].labelText = ASLocalizedString(@"XTPersonalFilesController_Wait");
    _pageSize = 20;
    [self addHeader];
    
    UIButton *backBtn = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setNavigationStyle:KDNavigationStyleYellow];
}

-(void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addHeader
{
    __weak XTPersonalFilesController * vc = self;
    [self.tableview addHeaderWithCallback:^{
        [vc refreshData];
    }];
    [self.tableview headerBeginRefreshing];
}

- (void)addFooter
{
    __weak XTPersonalFilesController * vc = self;
    [self.tableview addFooterWithCallback:^{
        [vc loadMore];
    }];
}

- (void)refreshData
{
    self.pageIndex = 1;
    [self queryAllFiles];
}

- (void)loadMore
{
    self.pageIndex ++;
    [self queryAllFiles];
}

- (void)queryAllFiles
{
    [self.client showAllUploadFileWithNetworkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId threadId:self.threadId dedicatorId:self.personModel.wbUserId pageIndex:self.pageIndex pageSize:_pageSize];
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
        label.font = [UIFont kdFont4];
        label.textColor = [UIColor kdTextColor2];
        label.text = ASLocalizedString(@"XTPersonalFilesController_NoFile");
        
        [_backgroundView addSubview:label];
        
        [self.tableview addSubview:_backgroundView];
    }
    _backgroundView.hidden = NO;
    
}

- (void)showalluploadfile:(XTWbClient *)client result:(BOSResultDataModel *)result
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.tableview headerEndRefreshing];
    [self.tableview footerEndRefreshing];
    if (client.hasError)
    {
        if(self.filesArray && self.filesArray.count>0)
        {
            [self setBackgroud:NO];
        }
        else
        {
        [self setBackgroud:YES];
        }
        return;
    }
    if (!result.success)
    {
        if(!self.filesArray || self.filesArray.count == 0)
        {
        [self setBackgroud:YES];
        }else
        {
        [self setBackgroud:NO];
        }
    }
    else
    {
         [self setBackgroud:NO];
        NSArray *files = result.data;
        if(self.pageIndex == 1)
        {
            if(self.filesArray && self.filesArray.count>0)
            {
                [self.filesArray removeAllObjects];
            }
        }
        if(files && ![files isKindOfClass:[NSNull class]] && files.count>0)
        {
            for (NSDictionary *dict in files)
            {
                DocumentFileModel *model = [[DocumentFileModel alloc] initWithDictionary:dict];
                [self.filesArray addObject:model];
            }
            if(self.filesArray.count>= self.pageIndex*_pageSize)
            {
                if(self.pageIndex == 1)
                {
                    [self addFooter];
                }
            }else{
                [self.tableview removeFooter];
            }
        }else{
            [self setBackgroud:YES];
            [self.tableview removeFooter];
        }
 
    }
      [self.tableview reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [NSNumber kdDistance2];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filesArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *recentlyCell = @"recentlyCell";
    
    XTFileCell *cell = (XTFileCell *)[tableView dequeueReusableCellWithIdentifier:recentlyCell];
    if (cell == nil) {
        cell = [[XTFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recentlyCell];
        cell.backgroundColor = MESSAGE_CT_COLOR;
    }

    DocumentFileModel *file = [self.filesArray objectAtIndex:indexPath.row];
    cell.file = file;
    cell.isPreview = YES;
    cell.separatorLineStyle = (self.filesArray.count -1 == indexPath.row) ? KDTableViewCellSeparatorLineTop: KDTableViewCellSeparatorLineSpace;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DocumentFileModel *file = [self.filesArray objectAtIndex:indexPath.row];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:file.fileId,@"id", file.fileName,@"fileName", [file.time formatWithFormatter:KD_DATE_ISO_8601_LONG_FORMATTER],@"uploadDate", file.fileExt,@"fileExt", [NSString stringWithFormat:@"%lu",(unsigned long)file.length], @"length",nil];//@(file.encrypted),@"encrypted",nil];
    FileModel *fileModel = [[FileModel alloc] initWithDictionary:dict];
    XTFileDetailViewController *filePreviewVC = [[XTFileDetailViewController alloc] initWithFile:fileModel];
    filePreviewVC.hidesBottomBarWhenPushed = YES;
    filePreviewVC.bShouldNotPopToRootVC = YES;
    [self.navigationController pushViewController:filePreviewVC animated:YES];
}

@end
