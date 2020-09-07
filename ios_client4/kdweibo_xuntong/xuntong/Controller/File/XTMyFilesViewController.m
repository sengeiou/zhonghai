//
//  XTMyFilesViewController.m
//  kdweibo
//
//  Created by bird on 14-10-15.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTMyFilesViewController.h"
#import "KDRefreshTableView.h"
#import "XTWbClient.h"
#import "XTFileCell.h"
#import "XTFileDetailViewController.h"
#import "NSDate+Additions.h"
#import "XTMyFileListViewController.h"
#import "AppsClient.h"
#import "XTFileListViewController.h"
#import "UIButton+XT.h"
#import "KDMultiVoiceViewController.h"
#import "KDWPSFileShareManager.h"
#import "KDWebViewController.h"

@interface MyFileSortCell : KDTableViewCell

@property (nonatomic, strong) UIImageView   *iconView;
@property (nonatomic, strong) UILabel       *contentLabel;
@property (nonatomic, strong) UIView        *bottomLineView;
@property (nonatomic, strong) UIImageView   *arrowImageView;
@end

@implementation MyFileSortCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
	{
		// content view created lazily
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.iconView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_iconView];
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.contentLabel.font = [UIFont systemFontOfSize:16.f];
        self.contentLabel.textColor = [UIColor blackColor];
        [self.contentLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_contentLabel];
        
        self.bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bottomLineView.backgroundColor = MESSAGE_LINE_COLOR;
//        [self.contentView addSubview:_bottomLineView];
        
        self.arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.arrowImageView setImage:[UIImage imageNamed:@"common_img_vector"]];
        [self.arrowImageView sizeToFit];
        [self.contentView addSubview:_arrowImageView];
        
        //[self.contentView setBackgroundColor:[UIColor kdBackgroundColor2]];
        
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGRect frame = self.iconView.frame;
    frame.origin.x = 12.f;
    frame.origin.y = (CGRectGetHeight(bounds) - CGRectGetHeight(frame))*0.5f;
    _iconView.frame = frame;
    
    frame.origin.x = CGRectGetMaxX(frame) + 10.f;
    frame.origin.y = (CGRectGetHeight(bounds)- 22.f)*0.5f;
    frame.size.width = CGRectGetWidth(bounds) - frame.origin.x - 22.f;
    frame.size.height = 22.f;
    _contentLabel.frame = frame;
    
    frame.origin.x = self.separatorLineInset.left;
    frame.origin.y = CGRectGetHeight(bounds) - 0.5f;
    frame.size.width = CGRectGetWidth(bounds)- self.separatorLineInset.left - self.separatorLineInset.right;
    frame.size.height = 0.5f;
    _bottomLineView.frame = frame;
    
    frame = self.arrowImageView.frame;
    frame.origin.x = CGRectGetWidth(bounds) - 22.f;
    frame.origin.y = (CGRectGetHeight(bounds) - CGRectGetHeight(frame)) *0.5f;
    _arrowImageView.frame = frame;
}
@end

#define kFileTransPublicAccountID   @"XT-0060b6fb-b5e9-4764-a36d-e3be66276586"
#define SendBGHeight 55.0

@interface XTMyFilesViewController () <KDRefreshTableViewDataSource, KDRefreshTableViewDelegate>
@property (nonatomic, strong) KDRefreshTableView *myTableView;
@property (nonatomic, strong) NSMutableArray *recentlyFiles;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *images;
//@property (nonatomic, strong) NSArray *imagesSend;
@property (nonatomic, assign) BOOL          isGetting;
@property (nonatomic, assign) BOOL          isSucced;
@property (nonatomic, strong) XTWbClient    *client;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) AppsClient         *appsClient;
@property (nonatomic, strong) MBProgressHUD      *hud;

@property (nonatomic,assign) BOOL allowSend;
@property (nonatomic,assign) BOOL isPreviewed;
@property (nonatomic,strong) UIImageView *sendBGView;
@property (nonatomic,strong) UIButton *sendBtn;
@property (nonatomic,strong) UIButton *rightButton;
@property (nonatomic,strong) NSMutableArray *selectedFiles;
@end

@implementation XTMyFilesViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.titles = @[ASLocalizedString(@"XTMyFilesViewController_Send_To_Computer"),ASLocalizedString(@"XTFileListViewController_MyUpload"),ASLocalizedString(@"XTMyFileListViewController_MyDownLoad"),ASLocalizedString(@"XTMyFileListViewController_MyCollect")];
        self.images = @[@"doc_tip_transfer",@"doc_tip_upload",@"doc_tip_download",@"doc_tip_favorite"];
//        self.imagesSend = @[@"doc_tip_transfer",@"doc_tip_upload",@"doc_tip_download",@"doc_tip_favorite"];
        self.recentlyFiles = [NSMutableArray array];
        self.selectedFiles = [NSMutableArray array];
        _currentIndex = 1;
    }
    return self;
}
- (void)dealloc{
    
    if(self.sendBGView.superview)
        [self.sendBGView removeFromSuperview];
}
//- (void)loadView{
//    
//    [super loadView];
//    
//    CGRect bounds = [[UIScreen mainScreen] bounds];
//    bounds.size.height -= StatusBarHeight + NavigationBarHeight;
//    UIView *view = [[UIView alloc] initWithFrame:bounds];
//    self.view = view;
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if(self.fromJSBridge)
//    {
//    }
    
    
    // Do any additional setup after loading the view.
    self.title = ASLocalizedString(@"XTMyFilesViewController_MyFile");
    UIButton *backBtn = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    [self.navigationItem.leftBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
    
    if (_fromType == 0) {
        self.title = ASLocalizedString(@"XTMyFilesViewController_ChooseFile");
    }

    _allowSend = _fromType ==0;
    _isPreviewed = !_allowSend;
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //预览|发送模式按钮
    UIButton *rightBtn = [UIButton buttonWithTitle:ASLocalizedString(@"XTFileListViewController_PreView")];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(modelChage) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.hidden = !_allowSend;
    self.rightButton = rightBtn;
    [rightBtn sizeToFit];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = 0;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:space,rightItem, nil];
    CGRect rect = self.view.bounds;
//    rect.origin.y = 64.0;
//    rect.size.height -= 64.0;
    if (_allowSend) {
        rect.size.height -= SendBGHeight;
    }
    
    KDRefreshTableView *tableView = [[KDRefreshTableView alloc] initWithFrame:rect kdRefreshTableViewType:KDRefreshTableViewType_Footer style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setBackgroundColor:[UIColor clearColor]];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [tableView setBottomViewHidden:YES];
    
    self.myTableView = tableView;
    
    if (_allowSend) {
        
        self.sendBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight([[UIScreen mainScreen] bounds]) - SendBGHeight, ScreenFullWidth, SendBGHeight)];
        //self.sendBGView.image = [[UIImage imageNamed:@"InputBoard_Backgroud"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 10, 4, 20)];
        self.sendBGView.backgroundColor = FC6;
        self.sendBGView.userInteractionEnabled = YES;
        // bug 4070
//        [[UIApplication sharedApplication].keyWindow addSubview:self.sendBGView];
        [[[UIApplication sharedApplication].windows firstObject] addSubview:self.sendBGView];
        
        //发送按钮
        self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.sendBtn.backgroundColor = RGBACOLOR(23, 131, 253, 1.0f);
        self.sendBtn.alpha = 0.5;
        self.sendBtn.layer.cornerRadius = 5.0f;
        self.sendBtn.layer.masksToBounds = YES;
        if (_fromJSBridge == NO) {
            [self.sendBtn setTitle:ASLocalizedString(@"Global_Send")forState:UIControlStateNormal];
            [self.sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
        }else {
            [self.sendBtn setTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Sure")forState:UIControlStateNormal];
            [self.sendBtn addTarget:self action:@selector(returnWebArgc) forControlEvents:UIControlEventTouchUpInside];
            
        }
        [self.sendBtn setTitleColor:[UIColor colorWithRGB:0x3cbaff] forState:UIControlStateNormal];
        self.sendBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        self.sendBtn.frame = CGRectMake((ScreenFullWidth - 70) / 2, 15.0, 70.0, 30.0);
        [self.sendBGView addSubview:self.sendBtn];
    }
    
    [self getFiles];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.sendBGView.hidden = YES;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //切换为黄色
    [self setNavigationStyle:KDNavigationStyleYellow];
}

- (void)getFiles{

    _isGetting = YES;
    self.client = [[XTWbClient alloc] initWithTarget:self action:@selector(recentlyFilesDidReceived:result:)];
//    [_client getFileListAtIndex:_currentIndex pageSize:20 type:@"recent" networkId:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (void)recentlyFilesDidReceived:(XTWbClient *)client result:(BOSResultDataModel *)result{
    
    _isGetting = NO;
    
    if ([_myTableView isLoading]) {
        [_myTableView finishedLoadMore];
    }
    
    if (client.hasError || !result.success) {
        
        _isSucced = NO;
        
        if (_recentlyFiles.count == 0) {
            [_myTableView setBottomViewHidden:YES];
        }
    }
    else
    {
        if ([result.data isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in result.data) {
                DocumentFileModel *model = [[DocumentFileModel alloc] initWithDictionary:dic];
                [_recentlyFiles addObject:model];
            }
            
            _isSucced = YES;
            
            if ([(NSArray *)result.data count] < 20) {
                [_myTableView setBottomViewHidden:YES];
            }
            else{
                [_myTableView setBottomViewHidden:NO];
                _currentIndex ++;
            }
        }
        else{
        
            _isSucced = NO;
            
            if (_recentlyFiles.count == 0) {
                [_myTableView setBottomViewHidden:YES];
            }
        }
    }
    
    
    [_myTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - action
- (void)modelChage
{
    CGRect frame = self.sendBGView.frame;
    CGRect tableFrame = self.myTableView.frame;
    if (_isPreviewed) {
        //进入发送状态
        _rightButton.title = ASLocalizedString(@"XTFileListViewController_PreView");
        self.isPreviewed = NO;
        frame.origin.y = CGRectGetHeight([[UIScreen mainScreen] bounds]) - SendBGHeight;
        tableFrame.size.height = CGRectGetHeight(self.view.bounds) - SendBGHeight;
        [self changSendButtonState];
        self.title = ASLocalizedString(@"XTMyFilesViewController_ChooseFile");
    } else {
        //进入预览状态
        _rightButton.title = ASLocalizedString(@"XTFileListViewController_Send");
        self.isPreviewed = YES;
        frame.origin.y = CGRectGetHeight([[UIScreen mainScreen] bounds]);
        tableFrame.size.height = CGRectGetHeight(self.view.bounds);
        [_selectedFiles removeAllObjects];
        self.title = ASLocalizedString(@"XTMyFilesViewController_MyFile");
    }
    [_rightButton sizeToFit];
    [UIView animateWithDuration:0.35 animations:^{
        self.sendBGView.frame = frame;
        self.myTableView.frame = tableFrame;
    }];
    [self.myTableView reloadData];
}
- (void)selectFile:(DocumentFileModel *)file{

    BOOL isExist = NO;
    DocumentFileModel *model = nil;
    for (model in _selectedFiles) {
        if ([model.fileId isEqualToString:file.fileId]) {
            isExist = YES;
            break;
        }
    }
    
    if (!isExist) {

        [_selectedFiles addObject:file];
    }
   
    [self changSendButtonState];
}
- (void)removeFile:(DocumentFileModel *)file{
    
    BOOL isExist = NO;
    DocumentFileModel *model = nil;
    for (model in _selectedFiles) {
        if ([model.fileId isEqualToString:file.fileId]) {
            isExist = YES;
            break;
        }
    }
    
    if (isExist) {
        
        [_selectedFiles removeObject:model];
    }
    
    [self changSendButtonState];
}

- (void)sendBtnClick:(id)sender
{
    if(self.sendBGView.superview)
        [self.sendBGView removeFromSuperview];
    
    for (DocumentFileModel *file in _selectedFiles) {
        [self.delegate performSelector:@selector(sendShareFile:) withObject:[file dictionaryFromFileModel]];
    }
    for (UIViewController *temp in self.navigationController.viewControllers) {
        if ([temp isKindOfClass:[XTChatViewController class]]) {
            [self.navigationController popToViewController:temp animated:NO];
        }
    }
}

-(void)returnWebArgc {
    [self.JSBridgeDelegate theSelectedFiles:_selectedFiles];
    [self.sendBGView removeFromSuperview];
    [self.navigationController popToViewController:self.fromViewController animated:YES];
}

- (void)changSendButtonState
{
    if ([_selectedFiles count] == 0) {
        self.sendBtn.userInteractionEnabled = NO;
        self.sendBtn.alpha = 0.5;
    } else {
        self.sendBtn.userInteractionEnabled = YES;
        self.sendBtn.alpha = 1.0;
    }
}


#pragma mark - Button Action

- (void)back:(UIButton *)btn
{
    [self setNavigationStyle:KDNavigationStyleNormal];
    
    if (_fromJSBridge == YES) {
        if(![self.navigationController.viewControllers.firstObject isKindOfClass:[KDWebViewController class]])
            [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    if (!_isPreviewed && _fromType == 0) {
        [self modelChage];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 打开文件助手

//传文件到电脑
- (void)openFileTrans:(PersonSimpleDataModel*)ps
{
    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:ps];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)fileTrans
{
    [self setNavigationStyle:KDNavigationStyleNormal];
    
    PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicPersonSimple:kFileTransPublicAccountID];
    if(person)
    {
        [self openFileTrans:person];
        return;
    }
    
    self.appsClient = [[AppsClient alloc] initWithTarget:self action:@selector(getPubAccountDidReceived:result:)];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
    hud.mode = MBProgressHUDModeText;
    [hud setLabelText:ASLocalizedString(@"XTMyFilesViewController_Doing")];
    hud.removeFromSuperViewOnHide = YES;
    [self.view.window addSubview:hud];
    [hud show:YES];
    
    self.hud = hud;
    
    [_appsClient getPublicAccount:kFileTransPublicAccountID];
}

-(void)getPubAccountDidReceived:(AppsClient *)client result:(BOSResultDataModel *)result
{
    [_hud hide:YES];
    
    if (result.success)
    {
        if(result.data)
        {
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:result.data];
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonSimple:person];
            if ([person isPublicAccount]) {
                [[XTDataBaseDao sharedDatabaseDaoInstance]insertPublicPersonSimple:person];
            }
            [self openFileTrans:person];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationViewController_tips_1")message:ASLocalizedString(@"KDApplicationViewController_network_error")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - UITableView DataSources And Delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 2;
    return 1; // 最近文件不要了
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        NSInteger count = 3;
        if (_fromType == 1) {
            count ++;
        }
        return count;
    }
    
    if ((_isGetting && _recentlyFiles.count == 0) || (!_isSucced && _recentlyFiles.count == 0) || (_isSucced && _recentlyFiles.count == 0)) {
        return 1;
    }
    return _recentlyFiles.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (_isGetting || !_isSucced || (_isSucced && _recentlyFiles.count == 0)) {
            return CGRectGetHeight(tableView.bounds) - 4*65.f - 25.f;
        }
    }

    return 68.f;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && _isGetting) {
        
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[cell viewWithTag:0x99];
        indicatorView.center = CGPointMake(CGRectGetMidX(cell.bounds), CGRectGetHeight(cell.bounds) *0.5f);
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *SortCell = @"SortCell";
    
    if (indexPath.section == 0) {
        MyFileSortCell *cell = [tableView dequeueReusableCellWithIdentifier:SortCell];
        if (cell == nil) {
            cell = [[MyFileSortCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SortCell];
        }
        if(_isPreviewed) {
            if (_allowSend || _fromType== 2) {
                cell.iconView.image = [UIImage imageNamed:_images[indexPath.row+1]];
            }else {
                cell.iconView.image = [UIImage imageNamed:_images[indexPath.row]];
            }
            
        }
        else {
            cell.iconView.image = [UIImage imageNamed:_images[indexPath.row+1]];
        }
        
        [cell.iconView sizeToFit];
        
        NSInteger row = indexPath.row;
        if (_fromType == 0 || _fromType == 2) {
            row ++;
        }
        cell.contentLabel.text = _titles[row];
        cell.separatorLineInset = UIEdgeInsetsMake(0, 66, 0, 0);
        cell.separatorLineStyle = (indexPath.row == [_images count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
        
        return cell;
    }
    
    
    if (_isGetting && _recentlyFiles.count == 0) {
    
        static NSString *GetingCell = @"GetingCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GetingCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GetingCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UITableViewCellStyleDefault];
            indicatorView.hidesWhenStopped = YES;
            indicatorView.tag = 0x99;
            [cell addSubview:indicatorView];
        }
        
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[cell viewWithTag:0x99];
        if (![indicatorView isAnimating]) {
            [indicatorView startAnimating];
        }
        
        return cell;
    }
    else if((!_isSucced && _recentlyFiles.count == 0) || (_isSucced && _recentlyFiles.count == 0)){
    
        static NSString *tipsCell = @"tipsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tipsCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tipsCell];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:14.f];
            label.textColor =  MESSAGE_DATE_COLOR;
            label.tag = 0x99;
            [cell addSubview:label];
        }
        UILabel *label = (UILabel *)[cell viewWithTag:0x99];
        label.frame = cell.bounds;
        label.text = !_isSucced?ASLocalizedString(@"XTMyFilesViewController_Reload"):ASLocalizedString(@"XTMyFilesViewController_No_CurrentFile");
        
        return cell;
    }
    
    static NSString *recentlyCell = @"recentlyCell";
    
    XTFileCell *cell = (XTFileCell *)[tableView dequeueReusableCellWithIdentifier:recentlyCell];
    if (cell == nil) {
        cell = [[XTFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recentlyCell];
    }
    
    cell.isPreview = _isPreviewed;
    
    DocumentFileModel *file = [_recentlyFiles objectAtIndex:indexPath.row];
    cell.file = file;
    cell.checked = NO;
    
    if(indexPath.row != [_recentlyFiles count] - 1){
        if(!_isPreviewed){
            cell.separatorLineInset = UIEdgeInsetsMake(0, 50, 0, 0);
        }else{
            cell.separatorLineInset = UIEdgeInsetsMake(0, 66, 0, 0);
        }
    }
    cell.separatorLineStyle = (indexPath.row == [_recentlyFiles count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
    
    for (DocumentFileModel *model in _selectedFiles) {
        if ([model.fileId isEqualToString:file.fileId]) {
            cell.checked = YES;
            break;
        }
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 8.0f;
    }
    return 25.f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    if (section == 1) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 25.f)];
        label.backgroundColor = self.view.backgroundColor;
        label.font = [UIFont systemFontOfSize:12.f];
        label.textColor = MESSAGE_NAME_COLOR;
        label.text = ASLocalizedString(@"XTMyFilesViewController_Current");
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 24.5f, CGRectGetWidth(tableView.bounds), 0.5f)];
        line.backgroundColor = [UIColor clearColor];
        [label addSubview:line];
        return label;
    }
    else
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 25.f)];
        label.backgroundColor = self.view.backgroundColor;
        return label;
    }
    
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.sendBGView.hidden = NO;
    
    if (indexPath.section == 1) {
        
        if (_recentlyFiles.count >0) {
            
            if (_isPreviewed) {
             
                DocumentFileModel *file = [_recentlyFiles objectAtIndex:indexPath.row];
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:file.fileId,@"id", file.fileName,@"fileName", [file.time formatWithFormatter:KD_DATE_ISO_8601_LONG_FORMATTER],@"uploadDate", file.fileExt,@"fileExt", [NSString stringWithFormat:@"%lu",(unsigned long)file.length], @"length",nil];
                FileModel *fileModel = [[FileModel alloc] initWithDictionary:dict];
                XTFileDetailViewController *filePreviewVC = [[XTFileDetailViewController alloc] initWithFile:fileModel];
                filePreviewVC.bShouldNotPopToRootVC = YES;
                filePreviewVC.hidesBottomBarWhenPushed = YES;
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
            else{
                
                DocumentFileModel *file = [_recentlyFiles objectAtIndex:indexPath.row];
 
                XTFileCell *cell = (XTFileCell *)[tableView cellForRowAtIndexPath:indexPath];
                BOOL checked = cell.checked;
                [cell setChecked:!checked animated:YES];
                
                if (checked)
                    [self removeFile:file];
                else
                    [self selectFile:file];
            }
        }
        else if (!_isSucced && _recentlyFiles.count == 0) {
            
            [self getFiles];
            
            [_myTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }

    }
    else{
    
        NSInteger row = indexPath.row;
        if (_fromType == 0 || _fromType == 2) {
            row ++;
        }
        
        if (row == 2 || row == 3) {
            
            
            XTMyFileListViewController *ctr  = [[XTMyFileListViewController alloc] init];
            if (_fromType == 0) {
                ctr.delegate  = self;
            }
            if (_fromType == 2) {
                //为了区分 3为共享ppt
                ctr.fromType = 3;
                if (row == 2) {
//                    [KDEventAnalysis event:event_myfile_download];
                    ctr.title = @"我下载的";
                }
                else{
                     ctr.title = @"我收藏的";
                    [KDEventAnalysis event:event_myfile_favorite];
                }
            }else
            {
                ctr.fromType = row -2;
            }
            [self.navigationController pushViewController:ctr animated:YES];
        }
        else if(row == 0){
            
            [self fileTrans];
            
            [KDEventAnalysis event:event_myfile_extrans];
        }
        else if(row == 1){
        
            XTFileListViewController *fileListVC = [[XTFileListViewController alloc] initWithFolderId:@"0"];
            if (_fromType == 0) {
                fileListVC.delegate  = self;
            }else if (_fromType == 2)
            {
                fileListVC.fromType = 2;
            }
            fileListVC.hidesBottomBarWhenPushed = YES;
            [fileListVC.backTitleArr addObject:ASLocalizedString(@"XTMyFilesViewController_MyFile")];  //用self.navigationItem.title会闪退
            [fileListVC.backFolderIDArr addObject:@"root"];
            fileListVC.parentID = [fileListVC.backFolderIDArr lastObject];
            [self.navigationController pushViewController:fileListVC animated:YES];
            
            [KDEventAnalysis event:event_myfile_upload];
        }
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
    
    [self getFiles];
}

#pragma mark - XTMyFilesViewControllerDelegate
- (void)fileModelChanged{
    [self modelChage];
}
- (void)fileDidSelected:(DocumentFileModel *)file{

    [self selectFile:file];
    
    [_myTableView reloadData];
}
- (void)fileDidReomved:(DocumentFileModel *)file{

    [self removeFile:file];
    
    [_myTableView reloadData];
}
- (BOOL)fileChecked:(DocumentFileModel *)file{
    BOOL isExist = NO;
    for (DocumentFileModel *model in _selectedFiles) {
        if ([model.fileId isEqualToString:file.fileId]) {
            isExist = YES;
            break;
        }
    }
    
    return isExist;
}
- (BOOL)isPreviewModel{
    return _isPreviewed;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


//支持旋转
-(BOOL)shouldAutorotate
{
    return YES;
}
@end
