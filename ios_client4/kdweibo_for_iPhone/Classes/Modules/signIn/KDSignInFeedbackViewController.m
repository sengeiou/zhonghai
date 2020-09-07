//
//  KDSignInFeedbackViewController.m
//  kdweibo
//
//  Created by 张培增 on 2016/11/2.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSignInFeedbackViewController.h"
#import "KDSignInPhotoCell.h"
#import "KDPhotoSignInContentCell.h"
#import "KDPhotoPreviewController.h"
#import "KDSignInUtil.h"
#import "NSDate+Additions.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "KDPhotoUploadTask.h"

@interface KDSignInFeedbackViewController () <UITableViewDelegate, UITableViewDataSource, KDSignInPhotoCellDelegate, KDPhotoPreviewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, KDPhotoUploadTaskDelegate, KDSignInFeedbackMarkCellDelegate>

@property (nonatomic, strong) UITableView               *tableView;
@property (nonatomic, strong) KDSignInPhotoCell     *photoCell;
@property (nonatomic, strong) KDPhotoSignInContentCell  *contentCell;
@property (nonatomic, strong) KDSignInFeedbackMarkCell  *markCell;
@property (nonatomic, strong) UIImagePickerController   *imagePickerController;

@property (nonatomic, strong) NSMutableArray            *pickedImageCachePath;
@property (nonatomic, strong) NSMutableArray            *selectedImagesAssetUrl;
@property (nonatomic, strong) NSArray                   *feedbackMarkArray;
@property (nonatomic, strong) KDPhotoUploadTask         *uploadTask;

@property (nonatomic, assign) BOOL                      isCanSubmit;
@property (nonatomic, assign) CGFloat                   markCellHeight;

@end

@implementation KDSignInFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    self.title = ASLocalizedString(@"签到反馈");
    
    
    UIButton *backBtn = [UIButton backBtnInBlueNavWithTitle:ASLocalizedString(@"返回")];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];;
    
    UIButton *rightBtn = [UIButton blueBtnWithTitle:ASLocalizedString(@"提交")];
    [rightBtn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];;
    self.isCanSubmit = YES;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).with.insets(UIEdgeInsetsZero);
    }];
    
    if (safeString(self.signInRecord.exceptionFeedbackReason).length > 0) {
        [self getSignInFeedbackMarkArray];
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self setNavigationStyle:KDNavigationStyleBlue];
    
}

- (void)getSignInFeedbackMarkArray {
    
    NSArray *arr = [self.signInRecord.exceptionFeedbackReason componentsSeparatedByString:@","];
    NSMutableArray *result = [NSMutableArray array];
    
    NSInteger maxRow = 1;
    CGFloat maxWidth = 0.0;
    
    for (int i = 0; i < arr.count; i++) {
        NSString *mark = safeString([arr safeObjectAtIndex:i]);
        if (mark.length > 0) {
            KDSignInFeedbackMarkItemModel *model = [[KDSignInFeedbackMarkItemModel alloc] init];
            model.mark = mark;
            model.markWidth = ceilf([mark boundingRectWithSize:CGSizeMake(ScreenFullWidth - [NSNumber kdDistance1] * 4, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : FS5} context:nil].size.width);
            [result addObject:model];
            
            CGFloat itemWidth = model.markWidth + 2 * [NSNumber kdDistance1];
            if (maxWidth + itemWidth > ScreenFullWidth - 2 * [NSNumber kdDistance1]) {
                maxRow += 1;
                maxWidth = itemWidth + [NSNumber kdDistance1];
            }
            else {
                maxWidth += itemWidth + [NSNumber kdDistance1];
            }
        }
    }
    
    self.feedbackMarkArray = [result copy];
    self.markCellHeight = ceilf(40 + (FS5.lineHeight + [NSNumber kdDistance1]) * maxRow + [NSNumber kdDistance1] * (maxRow - 1));
    
}

#pragma mark - UITableViewDataSource && delegate -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 && self.feedbackMarkArray.count > 0 ? 2 : 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = self.contentCell;
        }
        else if (indexPath.row == 1 && self.feedbackMarkArray.count > 0) {
            cell = self.markCell;
        }
    }
    else if (indexPath.section == 1) {
        cell = self.photoCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 1 && self.feedbackMarkArray.count > 0) {
            return self.markCellHeight;
        }
        else {
            return 200;
        }
    }
    else if (indexPath.section == 1) {
        if (self.pickedImageCachePath && self.pickedImageCachePath.count>0) {
            return 100;
        }
        else {
            return 80;
        }
    }
    else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [NSNumber kdDistance2];
}

#pragma mark - getter -
- (NSMutableArray *)pickedImageCachePath {
    if(!_pickedImageCachePath) {
        _pickedImageCachePath = [NSMutableArray new];
    }
    return _pickedImageCachePath;
}

- (NSMutableArray *)selectedImagesAssetUrl {
    if (!_selectedImagesAssetUrl) {
        _selectedImagesAssetUrl = [NSMutableArray new];
    }
    return _selectedImagesAssetUrl;
}

- (NSArray *)feedbackMarkArray {
    if (!_feedbackMarkArray) {
        _feedbackMarkArray = [NSArray array];
    }
    return _feedbackMarkArray;
}

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = NO;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    return _imagePickerController;
}

- (KDSignInPhotoCell *)photoCell {
    if (!_photoCell) {
        _photoCell = [[KDSignInPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"photoCellIdentifier"];
        _photoCell.assetURLs = self.pickedImageCachePath;
        _photoCell.previewCelldelegate = self;
        _photoCell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
    }
    return  _photoCell;
}

- (KDPhotoSignInContentCell *)contentCell {
    if (!_contentCell) {
        _contentCell = [[KDPhotoSignInContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contentCellIdentifier"];
        _contentCell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        _contentCell.textView.placeholderColor = FC3;
        _contentCell.textView.placeholder = ASLocalizedString(@"请输入考勤状态异常的原因");
        _contentCell.textView.returnKeyType = UIReturnKeyDone;
        _contentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return _contentCell;
}

- (KDSignInFeedbackMarkCell *)markCell {
    if (!_markCell) {
        _markCell = [[KDSignInFeedbackMarkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"markCellIdentifier"];
        _markCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _markCell.delegate = self;
    }
    _markCell.markArray = self.feedbackMarkArray;
    return _markCell;
}

- (KDPhotoUploadTask *)uploadTask
{
    if(!_uploadTask)
    {
        _uploadTask = [[KDPhotoUploadTask alloc] init];
    }
    return _uploadTask;
}

//- (NSString *)getPlaceHolderWithSignInRecord:(KDSignInRecord *)record {
//    NSString *placeHolder = @"";
//    if (record && record.exceptionType) {
//        if ([record.exceptionType isEqualToString:@"LATE"]) {
//            placeHolder = ASLocalizedString(@"迟到");
//        }
//        else if ([record.exceptionType isEqualToString:@"EARLYLEAVE"]) {
//            placeHolder = ASLocalizedString(@"早退");
//        }
//        else if ([record.exceptionType isEqualToString:@"OUT_WORK"]) {
//            placeHolder = ASLocalizedString(@"外勤反馈");
//        }
//        else if ([record.exceptionType isEqualToString:@"ABSENCE"]) {
//            placeHolder = ASLocalizedString(@"未签到");
//        }
//        else {
//            placeHolder = ASLocalizedString(@"迟到早退");
//        }
//    }
//    return placeHolder;
//}

#pragma mark - KDSignInFeedbackMarkCellDelegate -
- (void)changeFeedbackMark:(NSString *)content {
    self.contentCell.textView.text = content;
    self.contentCell.textView.displayPlaceHolder = content.length > 0 ? NO : YES;
    [self.contentCell.textView setNeedsDisplay];
}

#pragma mark - KDSignInPhotoCellDelegate -
- (void)imagePostPreviewDidTapAtIndex:(NSUInteger)index {
    KDPhotoPreviewController *previewController = [[KDPhotoPreviewController alloc] init];
    [previewController clickedPreviewImageViewAtIndex:index assetArray:self.selectedImagesAssetUrl cacheArray:self.pickedImageCachePath];
    previewController.photoPreviewDelegate = self;
    [self presentViewController:previewController animated:YES completion:nil];
}

- (void)imagePostPreviewDidTapAddedButton:(BOOL)tap {
    [self presentImagePickerController];
}

#pragma mark - KDPhotoPreviewControllerDelegate -
- (void)photoPreviewDone:(BOOL)isDone info:(NSDictionary *)info previewController:(KDPhotoPreviewController *)preview {
    [preview dismissViewControllerAnimated:YES completion:nil];
    if (isDone) {
        [self handlePhotoPreviewResult:info];
    }
}

- (void)handlePhotoPreviewResult:(NSDictionary  *)info
{
    NSArray *assetArray = info[@"asset"];
    NSArray *chacheArray = info[@"cache"];
    
    if(assetArray && assetArray.count>0)
    {
        [self removeLocalCachedPickImageNotIn:chacheArray];
        [self.selectedImagesAssetUrl removeAllObjects];
        [self.selectedImagesAssetUrl addObjectsFromArray:assetArray];
        
        [self.pickedImageCachePath removeAllObjects];
        [self.pickedImageCachePath addObjectsFromArray:chacheArray];
    }else if(self.selectedImagesAssetUrl && self.selectedImagesAssetUrl.count>0)
    {
        [self.selectedImagesAssetUrl removeAllObjects];
        [self removeLocalCachedPickImage];
    }
    [_photoCell setAssetURLs:self.pickedImageCachePath];
    [self.tableView reloadData];
}

- (void)removeLocalCachedPickImageNotIn:(NSArray *)notRemoved {
    
    NSMutableSet *preSet = [NSMutableSet setWithArray:self.pickedImageCachePath];
    NSSet *notSet = [NSSet setWithArray:notRemoved];
    [preSet minusSet:notSet];
    NSArray *toRemoved = [preSet allObjects];
    for (NSString *path in toRemoved) {
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        }
    }
}

- (void)removeLocalCachedPickImage {
    for (NSString *path in self.pickedImageCachePath) {
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        }
    }
    
    [self.pickedImageCachePath removeAllObjects];
}

#pragma mark - UIImagePickerControllerDelegate -
- (void)presentImagePickerController {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            [KDPopup showAlertWithTitle:nil message:ASLocalizedString(@"该设备拍照功能受限,请在设备的“设置-隐私-相机”里面修改") buttonTitles:@[ASLocalizedString(@"确定")] onTap:nil];
            return;
        }
        self.imagePickerController = nil;//重置
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
    else {
        [KDPopup showAlertWithTitle:nil message:ASLocalizedString(@"该设备不支持拍照") buttonTitles:@[ASLocalizedString(@"确定")] onTap:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak KDSignInFeedbackViewController *weakSelf = self;
    [KDPopup showHUD:ASLocalizedString(@"正在增加水印") inView:picker.view];
    [KDEventAnalysis event:event_signin_nol_photo];
    CFStringRef mediaType = (__bridge CFStringRef)[info objectForKey:UIImagePickerControllerMediaType];
    if(UTTypeConformsTo(mediaType, kUTTypeImage)){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        BOOL isDeviceRear = true;
        if(picker.cameraDevice == UIImagePickerControllerCameraDeviceFront){
            image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
            isDeviceRear = false;
        }
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init]; //将获取的照片存入相册
        //图片加水印
        NSString *usernameStr = [BOSConfig sharedConfig].user.name ? [BOSConfig sharedConfig].user.name : @"";
        NSString *tipsStr = [NSString stringWithFormat:ASLocalizedString(@"KDOutDoorSignInViewController_mark_message"),[[NSDate date] formatWithFormatter:@"yyyy-MM-dd HH:mm"],usernameStr,@""];
        image = [KDSignInUtil addTextToImage:image locationName:@"" text:tipsStr deviceIsFrom:isDeviceRear];
        [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            if(error)
            {
                [KDPopup hideHUDInView:picker.view];
                [KDPopup showAlertWithTitle:ASLocalizedString(@"拍照存储失败") message:ASLocalizedString(@"请打开 设置-隐私-照片 来进行设置") buttonTitles:@[ASLocalizedString(@"确定")] onTap:^(NSInteger index) {
                    [picker dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            else
            {
                [weakSelf.selectedImagesAssetUrl addObject:[NSString stringWithFormat:@"%@", assetURL]];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakSelf savePickedImage:image];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [KDPopup hideHUDInView:picker.view];
                        [picker dismissViewControllerAnimated:YES completion:nil];
                        [weakSelf.photoCell setAssetURLs:weakSelf.pickedImageCachePath];
                        [weakSelf.tableView reloadData];
                    });
                });
            }
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [KDPopup hideHUDInView:picker.view];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)savePickedImage:(UIImage *)image {
    
    NSString *picturesPath = [[KDUtility defaultUtility] searchDirectory:KDPicturesDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];
    NSString *filename = [[NSDate date] formatWithFormatter:@"yyyyMMddHHmmss"];
    filename = [filename stringByAppendingFormat:@"_%@_photoSignIn", [NSString randomStringWithWide:6]];
    NSString *cachePath = [picturesPath stringByAppendingPathComponent:filename];
    [self.pickedImageCachePath addObject:cachePath];
    
    CGSize previewSize = CGSizeMake(800.0f, 600.0f);
    if(image.size.width > previewSize.width || image.size.height > previewSize.height){
        image = [image scaleToSize:previewSize type:KDImageScaleTypeFill];
    }
    
    NSData *data = UIImageJPEGRepresentation(image, 0.1);
    [[NSFileManager defaultManager] createFileAtPath:cachePath contents:data attributes:nil];
}

#pragma mark - buttonMethod -

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)submitBtnClicked:(id)sender {
    if (self.isCanSubmit) {
        if (self.contentCell.textView.text.length > 0) {
            [self uploadPhotoAction];
            self.isCanSubmit = NO;
        }
        else {
            [KDPopup showHUDToast:ASLocalizedString(@"请输入考勤状态异常的原因")];
        }
    }
    
}

- (void)uploadPhotoAction {
    [self.contentCell.textView resignFirstResponder];
    if (self.pickedImageCachePath && self.pickedImageCachePath.count > 0) {
        [KDPopup showHUD:ASLocalizedString(@"图片上传中...")];
        self.uploadTask.taskDelegate = self;
        [self.uploadTask startUploadActionWithCachePathArray:self.pickedImageCachePath];
    } else {
        [KDPopup hideHUD];
        self.uploadTask.taskDelegate = nil;
        [self feedbackWithPhotoId:nil];
    }
}

#pragma mark - KDPhotoUploadTaskDelegate
- (void)whenPhotoUploadTaskFailure:(NSDictionary *)dict task:(KDPhotoUploadTask *)task {
    task.taskDelegate = nil;
    [KDPopup hideHUD];
    self.isCanSubmit = YES;
    [KDPopup showAlertWithTitle:ASLocalizedString(@"图片上传失败") message:nil buttonTitles:@[ASLocalizedString(@"我知道了")] onTap:nil];
}

- (void)whenPhotoUploadTaskSuccess:(NSDictionary *)dict task:(KDPhotoUploadTask *)task {
    task.taskDelegate = nil;
    [KDPopup hideHUD];
    NSMutableArray *filesArray = dict[@"fileIds"];
    if (filesArray && filesArray.count > 0) {
        NSString *fileidStr = @"";
        for (int i = 0; i < filesArray.count; i++) {
            NSString *fileid = filesArray[i];
            if (i > 0 && i < filesArray.count) {
                fileidStr = [NSString stringWithFormat:@"%@,%@", fileidStr, fileid];
            } else if (i == 0) {
                fileidStr = [NSString stringWithFormat:@"%@", fileid];
            }
        }
        [self feedbackWithPhotoId:fileidStr];
    } else {
        self.isCanSubmit = YES;
        [KDPopup showAlertWithTitle:ASLocalizedString(@"图片上传失败") message:nil buttonTitles:@[ASLocalizedString(@"我知道了")] onTap:nil];
    }
}

#pragma mark - FeedbackInterface -
- (void)feedbackWithPhotoId:(NSString *)photoId {
    if (!_signInRecord) {
        return;
    }
    
    __weak KDSignInFeedbackViewController *weakSelf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if ( [response statusCode] == 200) {
            weakSelf.isCanSubmit = YES;
            [KDPopup showHUDSuccess:ASLocalizedString(@"反馈成功")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (weakSelf.jsBridgeBlock) {
                    weakSelf.jsBridgeBlock();
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });

        } else {
            weakSelf.isCanSubmit = YES;
            [KDPopup showHUDToast:ASLocalizedString(@"反馈失败,请重试")];
        }
    };
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"feedbackType" stringValue:self.signInRecord.exceptionType];
    [query setParameter:@"feedbackContent" stringValue:self.contentCell.textView.text];
    [query setParameter:@"photoId" stringValue:photoId];
    [query setParameter:@"signId" stringValue:self.signInRecord.singinId];
    
    [KDServiceActionInvoker invokeWithSender:weakSelf
                                  actionPath:@"/signId/:signInFeedback"
                                       query:query
                                 configBlock:nil
                             completionBlock:completionBlock];
    
    //签到迁移，暂时屏蔽
//    __weak KDSignInFeedbackViewController *weakSelf = self;
//    KDSignInFeedbackRequest *request = [[KDSignInFeedbackRequest alloc] initWithFeedbackType:self.signInRecord.exceptionType feedbackContent:self.contentCell.textView.text photoId:photoId signId:self.signInRecord.singinId];
//    [request startCompletionBlockWithSuccess:^(__kindof KDRequest * _Nonnull request) {
//        weakSelf.isCanSubmit = YES;
//        [KDPopup showHUDSuccess:ASLocalizedString(@"反馈成功")];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (weakSelf.jsBridgeBlock) {
//                weakSelf.jsBridgeBlock();
//            }
//            [weakSelf.navigationController popViewControllerAnimated:YES];
//        });
//    } failure:^(__kindof KDRequest * _Nonnull request) {
//        weakSelf.isCanSubmit = YES;
//        [KDPopup showHUDToast:ASLocalizedString(@"反馈失败,请重试")];
//    }];
}

#pragma mark - MemoryWarning -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
