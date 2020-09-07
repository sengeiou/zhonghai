//
//  KDCleanDataViewController.m
//  kdweibo
//
//  Created by wenjie_lee on 15/7/22.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDCleanDataViewController.h"
#import "UIView+Blur.h"
#import "KDCommon.h"
#import "CleanDataTableViewCell.h"
#import "BOSFileManager.h"
#import "BOSConfig.h"
#import "ContactUtils.h"
#define KD_VIEW_HEIGHT 43

#define PicturesPath      [[KDUtility defaultUtility] searchDirectory:KDPicturesDirectory inDomainMask:KDTemporaryDomainMask needCreate:NO]
#define DownloadsPath     [[KDUtility defaultUtility] searchDirectory:KDDownloadDocument inDomainMask:KDTemporaryDomainMask needCreate:NO]
#define DownloadFilePath  [[BOSFileManager currentUserPathWithOpenId:[BOSConfig sharedConfig].user.openId] stringByAppendingPathComponent:kFileDirectoryName]

#define XtAudioPath       [[BOSFileManager currentUserPathWithOpenId:[BOSConfig sharedConfig].user.openId] stringByAppendingPathComponent:kRecorderDirectoryName]
#define AudioPath         [[KDUtility defaultUtility] searchDirectory:KDDownloadAudio inDomainMask:KDTemporaryDomainMask  needCreate:NO]
#define VideoPath         [[KDUtility defaultUtility] searchDirectory:KDVideosDirectory inDomainMask:KDTemporaryDomainMask needCreate:NO]

const int GB = 1024 * 1024 * 1024;//定义GB的计算常量
const int MB = 1024 * 1024;//定义MB的计算常量
const int KB = 1024;//定义KB的计算常量

//static NSString * const typeName[]  = {@"图片",@"文档",@"语音消息",@"微博视频"};
static NSString * const typeImages[]  = {@"icon-photo",@"icon-file",@"icon-sound",@"icon-video"};

@interface KDCleanDataViewController ()
{
    UITableView *_tableView;
    UIView *_toolBarView;
    UIButton *_deleteBtn;
    UIButton *_selectBtn;
    UILabel *_totalSizeOfFileLabel;
    BOOL    _selected;
    KDInt64 _totalSize;
    NSMutableArray *_selectArray;
}
@property (nonatomic, retain) NSArray *typeName;
@end

@implementation KDCleanDataViewController
- (id)init
{
    self = [super init];
    if (self) {
        self.title = ASLocalizedString(@"KDCleanDataViewController_clean_memory");
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    self.typeName = @[ASLocalizedString(@"KDCleanDataViewController_photo"),ASLocalizedString(@"KDCleanDataViewController_file"),ASLocalizedString(@"KDCleanDataViewController_voice"),ASLocalizedString(@"KDCleanDataViewController_video")];
    CGRect frame = [UIScreen mainScreen].bounds;
    _tableView = [[UITableView alloc]initWithFrame:frame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor kdTableViewBackgroundColor];
    [self.view addSubview:_tableView];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    CGFloat offsetY = self.view.bounds.size.height - KD_VIEW_HEIGHT - kd_BottomSafeAreaHeight;
    frame.origin.y = offsetY;
    frame.origin.x -=2;
    frame.size.width +=4;
    frame.size.height = KD_VIEW_HEIGHT+2;
    UIView *aView = [[UIView alloc] initWithFrame:frame];
    aView.backgroundColor = [UIColor colorWithRGB:0xFFFFFF];
    [aView addBorderAtPosition:KDBorderPositionTop];
    aView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview: aView];
    _toolBarView = aView;
//    [aView release];
    
    //selectBtn
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.titleLabel.font = [UIFont systemFontOfSize:16];
    btn1.bounds = CGRectMake(10, 0, 70, 30);
    [btn1 setTitle:ASLocalizedString(@"KDCleanDataViewController_all")forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor colorWithRGB:0x44BBFC] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    CGPoint center1 = CGPointZero;
    center1.y = CGRectGetMidY(_toolBarView.bounds);
    center1.x = 37;
    btn1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    btn1.center = center1;
    btn1.layer.cornerRadius = 5.f;
    btn1.layer.masksToBounds = YES;
    [_toolBarView addSubview:btn1];
    _selectBtn = btn1;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    btn.bounds = CGRectMake(0, 0, 54, 30);
    [btn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:ASLocalizedString(@"KDCleanDataViewController_del")forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRGB:0xFF3E3E] forState:UIControlStateNormal];
    CGPoint center = CGPointZero;
    center.y = CGRectGetMidY(_toolBarView.bounds);
    center.x = _toolBarView.bounds.size.width - CGRectGetMidX(btn.bounds) - 9;
    btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    btn.center = center;
    btn.layer.cornerRadius = 5.f;
    btn.layer.masksToBounds = YES;
    [_toolBarView addSubview:btn];
    _deleteBtn= btn;
    _deleteBtn.enabled = NO;

    _totalSizeOfFileLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_toolBarView.frame) -120, CGRectGetHeight(_toolBarView.frame))];
    _totalSizeOfFileLabel.backgroundColor = [UIColor clearColor];
    _totalSizeOfFileLabel.font = [UIFont systemFontOfSize:12.f];
    _totalSizeOfFileLabel.textAlignment = NSTextAlignmentCenter;
    _totalSizeOfFileLabel.textColor = [UIColor colorWithRGB:0x98A1A8];
    CGPoint center2= CGPointZero;
    center2.y = CGRectGetMidY(_toolBarView.bounds);
    center2.x = CGRectGetWidth(_toolBarView.bounds)/ 2.f;
    _totalSizeOfFileLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _totalSizeOfFileLabel.center = center2;
    _totalSizeOfFileLabel.layer.cornerRadius = 5.f;
    _totalSizeOfFileLabel.layer.masksToBounds = YES;
    [_toolBarView addSubview:_totalSizeOfFileLabel];
    _totalSizeOfFileLabel.hidden = YES;
    
    _selectArray = [[NSMutableArray alloc]init];
    
    [self calculateCacheSizeWithIndex:100];
    
}
-(void)selectAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (!btn.selected) {
        [btn setTitle:ASLocalizedString(@"KDCleanDataViewController_all")forState:UIControlStateNormal];
        _totalSize = 0;
    }
    else
    {
       [btn setTitle:ASLocalizedString(@"KDCleanDataViewController_cancel_all")forState:UIControlStateNormal];
        _totalSize= sizeOfAudios + sizeOfDownloads +sizeOfDownloadsFile +sizeOfPictures +sizeOfSDWebImages + sizeOfXTAudios;
    }
    for (NSInteger i = 0; i < 4; i++) {
        CleanDataTableViewCell *cell = (CleanDataTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell setChecked:btn.selected animated:YES];
    }
   
    [self showTip:_totalSize];
    
}
-(void)deleteAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    for (NSInteger i = 0; i < 4; i++) {
        CleanDataTableViewCell *cell = (CleanDataTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (cell.checked) {
            switch (i) {
                case 0:
                {
                    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^(void){
                        [[SDImageCache sharedImageCache] clearMemory];
                        [self removeCachewithPath:PicturesPath andCellIndex: 0];
                    }];
                }
                    break;
                case 1:
                {
                    [KDCacheUtlities asyncRemovePath:DownloadFilePath
                                       finishedBlock:^(BOOL success, NSError *error){
                                           [self removeCachewithPath:DownloadsPath andCellIndex: 1];
                    }];
                }
                    break;
                case 2:
                {
                    [KDCacheUtlities asyncRemovePath:XtAudioPath
                                       finishedBlock:^(BOOL success, NSError *error){
                                           [self removeCachewithPath:AudioPath andCellIndex: 2];
                                       }];
                }
                    break;
                case 3:
                {
                    [self removeCachewithPath:VideoPath andCellIndex: 3];
                }
                    break;
                default:
                    break;
        }
    }
    }
    //先全选 再逐个取消的时候，当 totalsize为0 则按钮显示全选，删除按钮可按
//    [self showTip:0];
    [_deleteBtn setTitleColor:RGBCOLOR(255, 180, 176) forState:UIControlStateNormal];
    _deleteBtn.enabled = NO;
    _selectBtn.selected = NO;
    [_selectBtn setTitle:ASLocalizedString(@"KDCleanDataViewController_all")forState:UIControlStateNormal];
    _totalSizeOfFileLabel.hidden = YES;
    
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHud.labelText = ASLocalizedString(@"XTChatDetailViewController_Delete_Success");
    progressHud.mode = MBProgressHUDModeText;
    [progressHud hide:YES afterDelay:1.0];
    
}

//可释放空间提示
- (void)showTip:(KDInt64)size
{
    [_deleteBtn setTitleColor:RGBCOLOR(255, 62, 62) forState:UIControlStateNormal];
    _deleteBtn.enabled = YES;
    _totalSizeOfFileLabel.hidden = NO;
    _totalSizeOfFileLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDCleanDataViewController_can_release"),[self byteConversionGBMBKB:size]];
    
    
    
    //如果自选为全部，则按钮显示取消全选，并且删除按钮不可按
//    if (size > 0) {
//        [_deleteBtn setTitleColor:RGBCOLOR(255, 62, 62) forState:UIControlStateNormal];
//        _deleteBtn.enabled = YES;
//        _totalSizeOfFileLabel.hidden = NO;
//        _totalSizeOfFileLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDCleanDataViewController_can_release"),[self byteConversionGBMBKB:size]];
//    }
//    else
//    {
//        //先全选 再逐个取消的时候，当 totalsize为0 则按钮显示全选，删除按钮可按
//        [_deleteBtn setTitleColor:RGBCOLOR(255, 180, 176) forState:UIControlStateNormal];
//        _deleteBtn.enabled = NO;
//        _selectBtn.selected = NO;
//        [_selectBtn setTitle:ASLocalizedString(@"KDCleanDataViewController_all")forState:UIControlStateNormal];
//        _totalSizeOfFileLabel.hidden = YES;
//        _totalSize = 0;
//    }
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CleanDataTableViewCell";
    CleanDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[CleanDataTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
   
    KDInt64 size = 0;
    switch (indexPath.row) {
        case 0:
            size = sizeOfPictures + sizeOfSDWebImages;
            break;
        case 1:
            size = sizeOfDownloadsFile;
            break;
        case 2:
            size = sizeOfAudios + sizeOfXTAudios;
            break;
        case 3:
            size = sizeOfVideos;
            break;
        default:
            break;
    }
    cell.checked = NO;
    [cell displayWithText:self.typeName[indexPath.row] Image:typeImages[indexPath.row] andSize:[self byteConversionGBMBKB:size]];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 109/2.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CleanDataTableViewCell *cell = (CleanDataTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    BOOL checked = cell.checked;
    KDInt64 size = 0;
    switch (indexPath.row) {
        case 0:
            size = sizeOfPictures + sizeOfSDWebImages;
            break;
        case 1:
            size = sizeOfDownloadsFile;
            break;
        case 2:
            size = sizeOfAudios + sizeOfXTAudios;
            break;
        case 3:
            size = sizeOfVideos;
            break;
        default:
            break;
    }
    if (!checked) {
        _totalSize += size;
        [_selectArray addObject:cell];
    }
    else
    {
        _totalSize -= size;
        [_selectArray removeObject:cell];
    }
    [cell setChecked:!checked animated:YES];
    
    //为了处理全选与否的按钮显示
    if ([_selectArray count] == 4 ) {
        _selectBtn.selected = NO;
        [_selectBtn setTitle:ASLocalizedString(@"KDCleanDataViewController_cancel_all")forState:UIControlStateNormal];
    }
    else
    {
        _selectBtn.selected = NO;
        [_selectBtn setTitle:ASLocalizedString(@"KDCleanDataViewController_all")forState:UIControlStateNormal];
    }
   
    [self showTip:_totalSize];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row== 3 ) {
        cell.separatorInset = UIEdgeInsetsMake(10, 0, 0, 0);
    }
}

- (void)calculateCacheSizeWithIndex:(NSInteger)index {
    
    sizeOfDownloads = 0;
    sizeOfPictures = 0;
    sizeOfVideos = 0;
    sizeOfAudios = 0;
    sizeOfXTAudios = 0;
    sizeOfSDWebImages = 0;
    sizeOfDownloadsFile = 0;

    __block NSInteger tasksMask = 7; // mark as 6 task
    
    // calculate the size of downloads cache folder
    KDUtility *utility = [KDUtility defaultUtility];
    
    // calculate the size of pictures cache folder
    NSString *picturesPath = [utility searchDirectory:KDPicturesDirectory inDomainMask:KDTemporaryDomainMask needCreate:NO];
    [KDCacheUtlities asyncCalculateFolderSize:picturesPath
                               cancelledBlock:^(void) {
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }
                                finishedBlock:^(KDUInt64 totalSize, NSUInteger count) {
                                    tasksMask--;
                                    sizeOfPictures = totalSize;
                                }];
    //calculate the size of xt audio cache folder
    NSString *sdWebImagePath = [[SDImageCache sharedImageCache] getCachPath];
    [KDCacheUtlities asyncCalculateFolderSize:sdWebImagePath
                               cancelledBlock:^(void){
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }finishedBlock:^(KDUInt64 totalSize, NSUInteger count){
                                   tasksMask--;
                                   sizeOfSDWebImages = totalSize;
//                                   if (sizeOfPictures + sizeOfSDWebImages > 0 )
//                                   if (index == 0) {
//                                       _totalSize -= sizeOfPictures + sizeOfSDWebImages;
//                                   }
                                       [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                                   }

                               }];
    NSString *downloadsPath = [utility searchDirectory:KDDownloadDocument inDomainMask:KDTemporaryDomainMask needCreate:NO];
    [KDCacheUtlities asyncCalculateFolderSize:downloadsPath
                               cancelledBlock:^(void) {
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }
                                finishedBlock:^(KDUInt64 totalSize, NSUInteger count) {
                                    tasksMask--;
                                    sizeOfDownloads = totalSize;
                                }];
    //xuntong 下的file文件
    NSString *dowonFile = [[BOSFileManager currentUserPathWithOpenId:[BOSConfig sharedConfig].user.openId] stringByAppendingPathComponent:kFileDirectoryName];
    [KDCacheUtlities asyncCalculateFolderSize:dowonFile
                               cancelledBlock:^(void){
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }finishedBlock:^(KDUInt64 totalSize, NSUInteger count){
                                   tasksMask--;
                                   sizeOfDownloadsFile = totalSize;
//                                   if (index == 1) {
//                                       _totalSize -= sizeOfDownloads + sizeOfDownloadsFile;
//                                   }
//                                   if (sizeOfDownloadsFile + sizeOfDownloads > 0 ) {
                                      [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                                   }

                               }];
    //calculate the size of audio cache folder
    NSString *audiosPath = [utility searchDirectory:KDDownloadAudio inDomainMask:KDTemporaryDomainMask needCreate:NO];
    [KDCacheUtlities asyncCalculateFolderSize:audiosPath
                               cancelledBlock:^{
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }
                                finishedBlock:^(KDUInt64 totalSize, NSUInteger count) {
                                    tasksMask--;
                                    sizeOfAudios = totalSize;
                                }];
    //calculate the size of xt audio cache folder
    NSString *xtAudioPath = [[BOSFileManager currentUserPathWithOpenId:[BOSConfig sharedConfig].user.openId] stringByAppendingPathComponent:kRecorderDirectoryName];
    [KDCacheUtlities asyncCalculateFolderSize:xtAudioPath
                               cancelledBlock:^(void){
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }finishedBlock:^(KDUInt64 totalSize, NSUInteger count){
                                   tasksMask--;
                                   sizeOfXTAudios = totalSize;
//                                   if (index == 2) {
//                                       _totalSize -= sizeOfXTAudios;
//                                   }
//                                   if (sizeOfVideos + sizeOfXTAudios > 0) {
                                       [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                                   }
                               }];

    
    // calculate the size of pictures cache folder
    NSString *videosPath = [utility searchDirectory:KDVideosDirectory inDomainMask:KDTemporaryDomainMask needCreate:NO];
    [KDCacheUtlities asyncCalculateFolderSize:videosPath
                               cancelledBlock:^(void) {
                                   BOOL flag = profileControllerFlags_.pausedCalculateCacheSize == 1;
                                   return flag;
                               }
                                finishedBlock:^(KDUInt64 totalSize, NSUInteger count) {
                                    tasksMask--;
                                    sizeOfVideos = totalSize;
//                                    if (index == 3) {
//                                        _totalSize -= sizeOfVideos;
//                                    }
                                    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                                }];
}
- (void)removeCachewithPath:(NSString *)path andCellIndex:(NSInteger) index {
        [KDCacheUtlities asyncRemovePath:path
                           finishedBlock:^(BOOL success, NSError *error){
                               [self calculateCacheSizeWithIndex:index];
                                }];
    [[KDWeiboAppDelegate getAppDelegate] clearCacheAndCookie];
}


#pragma mark -
#pragma mark UIAlertViewDelegate methods




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString*)byteConversionGBMBKB:(KDInt64 )KSize
{
   if (KSize / GB >= 1)//如果当前Byte的值大于等于1GB
       return [NSString stringWithFormat:@"%.2fGB",KSize / (float)GB];//将其转换成GB
   else if (KSize / MB >= 1)//如果当前Byte的值大于等于1MB
       return [NSString stringWithFormat:@"%.2fMB",KSize / (float)MB];//将其转换成MB
   else if (KSize / KB >= 1)//如果当前Byte的值大于等于1KB
       return [NSString stringWithFormat:@"%.2fKB",KSize / (float)KB];//将其转换成KB
   else
       return [NSString stringWithFormat:@"%lliB",KSize];//显示Byte值
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
