//
//  KDNewPhotoSignInController.m
//  kdweibo
//
//  Created by lichao_liu on 15/3/13.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDNewPhotoSignInController.h"
#import "KDPhotoSignInTypeController.h"
#import "KDPhotoPreviewController.h"

#import "HPTextViewInternal.h"
#import "KDSignInPoint.h"
#import "KDSignInPhotoCell.h"

#import "KDSignInRecord.h"
#import "KDDatabaseHelper.h"
#import "KDPhotoUploadTask.h"
#import "KDSigninRecordDAO.h"
#import "XTOpenSystemClient.h"
#import "KDSignInUtil.h"
#import "KDSignInManager.h"
#import "KDWeiboDAOManager.h"
//#import "KDChooseManager.h"
#import "KDSignInLogManager.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "UIImage+Additions.h"
#import "NSDate+Additions.h"

@interface KDPhotoSignInMarkCell : KDTableViewCell<UITextViewDelegate>

@property (nonatomic, strong) HPTextViewInternal *textView;
@property (nonatomic, strong) UIImageView *leftImageView;

@end

@implementation KDPhotoSignInMarkCell

- (void)layoutSubviews {
    [super layoutSubviews];
    self.leftImageView.frame = CGRectMake([NSNumber kdDistance1], 14, 14, 16);
    self.textView.frame = CGRectMake(CGRectGetMaxX(self.leftImageView.frame), 5, CGRectGetWidth(self.frame) - CGRectGetMaxX(self.leftImageView.frame)-6, CGRectGetHeight(self.frame) - 10);
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.leftImageView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sign_btn_location_press"]];
        [self.contentView addSubview:self.leftImageView];
        
        self.textView = [[HPTextViewInternal alloc] init];
        self.textView.placeholder = ASLocalizedString(@"备注当前位置");
        self.textView.placeholderColor = FC3;
        self.textView.displayPlaceHolder = YES;
        self.textView.font = FS4;
        self.textView.delegate = self;
        self.textView.layer.borderWidth = 0;
        self.textView.returnKeyType = UIReturnKeyDone;
        [self.contentView addSubview:self.textView];
    }
    return self;
}

#pragma mark -textviewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(HPTextViewInternal *)textView {
    textView.displayPlaceHolder = textView.text.length == 0;
    [textView setNeedsDisplay];
}

@end


@interface KDNewPhotoSignInController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,KDSignInPhotoCellDelegate,KDPhotoPreviewControllerDelegate,KDPhotoUploadTaskDelegate>

@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) KDTableViewCell *signInTypeCell;
@property (nonatomic, strong) KDPhotoSignInMarkCell *markCell;
@property (nonatomic, strong) KDSignInPhotoCell *photoCell;

@property (nonatomic, strong) NSMutableArray *selectedImagesAssetUrl;
@property (nonatomic, strong) NSMutableArray *pickedImageCachePath;

@property (nonatomic, assign) KDPhotoSignInType signInType;
@property (nonatomic, strong) KDPhotoUploadTask *uploadTask;
@property (nonatomic, strong) KDSignInPoint *signInPoint;

@end

@implementation KDNewPhotoSignInController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    CGRect frame = self.view.bounds;
    self.tableview = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    [self.view addSubview:self.tableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyleBlue];
    self.title = ASLocalizedString(@"拍照签到");
    
    UIButton *leftBtn = [UIButton blueBtnWithTitle:ASLocalizedString(@"取消")];
    [leftBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    UIButton *rightBtn = [UIButton blueBtnWithTitle:ASLocalizedString(@"确认")];
    [rightBtn addTarget:self action:@selector(signInSubmitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    
    [self.pickedImageCachePath addObject:self.cacheImagePath];
    [self.selectedImagesAssetUrl addObject:self.assetImageUrl];
    
    self.signInType = KDPhotoSignInType_FieldPersonnel;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_uploadTask) {
        _uploadTask.taskDelegate = nil;
    }
}

- (void)setNavigationStyleBlue{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController.navigationBar setBarTintColor:FC5];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS1}];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC6, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"app_img_backgroud"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 21, 0, 21)] forBarMetrics:UIBarMetricsDefault];
}

- (void)dealloc {
    if (_uploadTask) {
        _uploadTask.taskDelegate = nil;
    }
}

#pragma mark - getter -

- (KDPhotoUploadTask *)uploadTask {
    if (!_uploadTask) {
        _uploadTask = [[KDPhotoUploadTask alloc] init];
    }
    return _uploadTask;
}

- (KDSignInPhotoCell *)photoCell {
    if(!_photoCell) {
        _photoCell = [[KDSignInPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"photoCellIdentifier"];
        _photoCell.assetURLs = self.pickedImageCachePath;
        _photoCell.previewCelldelegate = self;
        _photoCell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    }
    return _photoCell;
}

- (KDPhotoSignInMarkCell *)markCell {
    if (!_markCell) {
        _markCell = [[KDPhotoSignInMarkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"markCellIdentifier"];
    }
    return  _markCell;
}

- (KDTableViewCell *)signInTypeCell {
    if (!_signInTypeCell) {
        _signInTypeCell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"signInTypeCell"];
        _signInTypeCell.textLabel.text = ASLocalizedString(@"签到类型");
        _signInTypeCell.textLabel.textColor = FC1;
        _signInTypeCell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
        _signInTypeCell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
        _signInTypeCell.detailTextLabel.textColor = FC5;
    }
    _signInTypeCell.detailTextLabel.text = self.signInType == KDPhotoSignInType_OfficeWork ? ASLocalizedString(@"内勤") : ASLocalizedString(@"外勤");
    return _signInTypeCell;
}

- (NSMutableArray *)selectedImagesAssetUrl {
    if (!_selectedImagesAssetUrl) {
        _selectedImagesAssetUrl = [NSMutableArray new];
    }
    return _selectedImagesAssetUrl;
}

- (NSMutableArray *)pickedImageCachePath {
    if (!_pickedImageCachePath) {
        _pickedImageCachePath = [NSMutableArray new];
    }
    return _pickedImageCachePath;
}

- (UIImagePickerController *)picker {
    if (!_picker) {
        _picker = [[UIImagePickerController alloc] init];
        _picker.delegate = self;
        _picker.allowsEditing = NO;
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    return _picker;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource -

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [NSNumber kdDistance2];
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
            cell = [self photoCell];
        }
        else if (indexPath.row == 1) {
            cell = [self markCell];
        }
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        cell = [self signInTypeCell];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (self.pickedImageCachePath && self.pickedImageCachePath.count > 0) {
            return 100;
        }
        return 80;
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    else if (section == 1) {
        return 1;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        __weak KDNewPhotoSignInController *weakSelf = self;
        KDPhotoSignInTypeController *controller = [[KDPhotoSignInTypeController alloc] init];
        controller.changeSignInTypeBlock = ^(KDPhotoSignInType type){
            if(type != self.signInType)
            {
                weakSelf.signInType = type;
                [self.tableview reloadData];
            }
        };
        controller.signInType = self.signInType;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.markCell.textView resignFirstResponder];
}

#pragma mark - ImagePickerController -

- (void)presentImagePickerController
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:ASLocalizedString(@"该设备拍照功能受限，请在设备的“设置-隐私-相机”里面修改")
                                                           delegate:nil
                                                  cancelButtonTitle:ASLocalizedString(@"确定")
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        self.picker = nil;
        [self presentViewController:self.picker animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView  alloc] initWithTitle:nil
                                                         message:ASLocalizedString(@"该设备不支持拍照")
                                                        delegate:nil
                                               cancelButtonTitle:ASLocalizedString(@"确定")
                                               otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - pickerControllerDelegate -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    __weak KDNewPhotoSignInController *weakSelf = self;
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
                        [weakSelf.tableview reloadData];
                    });
                });
            }
        }];
    }
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [KDPopup hideHUDInView:picker.view];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signInSubmitBtnClicked:(id)sender {
    [self.markCell.textView resignFirstResponder];
    if (self.selectedImagesAssetUrl && self.selectedImagesAssetUrl.count > 0) {
        if ([self.markCell.textView.text isEqualToString:@""] || self.markCell.textView.text.length == 0) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:ASLocalizedString(@"请输入备注信息")
                                  delegate:nil
                                  cancelButtonTitle:ASLocalizedString(@"确定")
                                  otherButtonTitles: nil];
            [alert show];
            return;
        }
        
        if ([KDReachabilityManager sharedManager].reachabilityStatus != KDReachabilityStatusNotReachable) {
            [self photoSignInAction];
        }
        else {
            [self saveFailureSignInRecordWithPhotoIds: nil];
            [self showError:self.view title:ASLocalizedString(@"数据成功保存到本地") block:^(){
                [self cancelAction:nil];
            }];
        }
        
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:ASLocalizedString(@"你当前没有拍照哦！")
                                                       delegate:nil
                                              cancelButtonTitle:ASLocalizedString(@"确定")
                                              otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - KDSignInPhotoCellDelegate -

- (void)imagePostPreviewDidTapAtIndex:(NSUInteger)index
{
    KDPhotoPreviewController *controller = [[KDPhotoPreviewController alloc] initWithNibName:nil bundle:nil];
    [controller clickedPreviewImageViewAtIndex:index assetArray:self.selectedImagesAssetUrl cacheArray:self.pickedImageCachePath];
    controller.photoPreviewDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)imagePostPreviewDidTapAddedButton:(BOOL)tap
{
    [self presentImagePickerController];
}

#pragma mark - removeCache -

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
        
        //        NSString *thumbnailPath = [self pickedImageLocalThumbnailCachePath:path];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        }
        
        //        if([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath]){
        //            [[NSFileManager defaultManager] removeItemAtPath:thumbnailPath error:NULL];
        //        }
    }
    
    [self.pickedImageCachePath removeAllObjects];
}

- (NSString *)pickedImageLocalThumbnailCachePath:(NSString *)imagePath {
    return [imagePath stringByAppendingString:@"_thumb"];
}

#pragma mark - KDPhotoUploadTaskDelegate
- (void)whenPhotoUploadTaskFailure:(NSDictionary *)dict task:(KDPhotoUploadTask *)task {
    task.taskDelegate = nil;
    [KDPopup showHUDToast:ASLocalizedString(@"图片上传失败,请重试")];
}

- (void)whenPhotoUploadTaskSuccess:(NSDictionary *)dict task:(KDPhotoUploadTask *)task {
    task.taskDelegate = nil;
    [self photoUploadTaskWithDict:dict];
}

- (void)photoUploadTaskWithDict:(NSDictionary *)dict {
    NSMutableArray *filesArray = dict[@"fileIds"];
    if (filesArray && filesArray.count > 0) {
        NSString *fileidStr =@"";
        for (int i = 0; i < filesArray.count; i++) {
            NSString *fileid = filesArray[i];
            if (i > 0 && i < filesArray.count) {
                fileidStr = [NSString stringWithFormat:@"%@,%@",fileidStr,fileid];
            }
            else if (i == 0) {
                fileidStr = [NSString stringWithFormat:@"%@",fileid];
            }
        }
        __weak KDNewPhotoSignInController *weakSelf = self;
        [self signinToServerPhotoIds:[fileidStr copy] block:^(BOOL success, KDSignInRecord *record) {
            if (success) {
                [KDPopup hideHUD];
                record.photoIds = fileidStr;
                [self saveRecords:@[record] date:[NSDate date] completionBlock:^(id results) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"KDAUTOWifiSignInSuccessNotification" object:nil];
                    [weakSelf signInSuccessPlaySound];
                }];
                [weakSelf showError:weakSelf.view title:ASLocalizedString(@"签到成功") block:^{
                    if (weakSelf.pickedImageCachePath && weakSelf.pickedImageCachePath.count > 0) {
                        [weakSelf removeLocalCachedPickImage];
                    }
                    if (weakSelf.selectedImagesAssetUrl && weakSelf.selectedImagesAssetUrl.count > 0) {
                        [weakSelf.selectedImagesAssetUrl removeAllObjects];
                    }
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            else {
                [KDPopup hideHUD];
                [self saveFailureSignInRecordWithPhotoIds:fileidStr];
                [self showError:self.view title:ASLocalizedString(@"数据成功保存到本地") block:^(){
                    [self cancelAction:nil];
                }];
            }
        }];
    }
    else {
        [KDPopup hideHUD];
        [self saveFailureSignInRecordWithPhotoIds:nil];
        [self showError:self.view title:ASLocalizedString(@"数据成功保存到本地") block:^(){
            [self cancelAction:nil];
        }];
    }
}

//有网络情况下
- (void)photoSignInAction {
    [KDPopup showHUD:ASLocalizedString(@"正在签到...")];
    self.uploadTask.taskDelegate = self;
    [self.uploadTask startUploadActionWithCachePathArray:self.pickedImageCachePath];
}


- (void)signinToServerPhotoIds:(NSString *)photoIds block:(void (^)(BOOL success, KDSignInRecord *record))block{
    
    __weak KDNewPhotoSignInController *weakSelf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results) {
            KDSignInRecord *record = ((NSArray *)([results objectForKey:@"singIns"])).firstObject;
            if (record) {
                if (safeString(record.featurename).length == 0) {
                    record.featurename = self.markCell.textView.text;
                }
                if (![KDSignInManager isFirstLauchPhotoSignIn]) {
                    record.content = ASLocalizedString(@"再也不担心老板扣工资了，拍照签到为咱提供了100%的呵护与保障，我爱死TA了！");
                    record.mbShare = record.content;
                    [KDSignInManager setIsFirstLauchPhotoSignIn:YES];
                    [self updateClockInWithSinginId:[record.singinId copy] mbShare:[record.mbShare copy] content:[record.content copy]];
                }
                if (block) { block(YES, record); }
            }
            else {
                if (block) { block(NO, nil); }
            }
        } else {
            if (block) {
                block(NO, nil);
            }
        }
    };
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"clockInType" stringValue:@"photo"];
    [query setParameter:@"remark" stringValue:self.markCell.textView.text];
    [query setParameter:@"photoId" stringValue:photoIds];
    [query setParameter:@"inCompany" integerValue:self.signInType];
    
    if(_signInPoint)
    {
        [query setParameter:@"longitude" doubleValue:_signInPoint.lng];
        [query setParameter:@"latitude" doubleValue:_signInPoint.lat];
        [query setParameter:@"featurename" stringValue:_signInPoint.positionName];
    }else{
        [query setParameter:@"longitude" doubleValue:0];
        [query setParameter:@"latitude" doubleValue:0];
    }
    
    
    [KDServiceActionInvoker invokeWithSender:weakSelf
                                  actionPath:@"/signId/:sign"
                                       query:query
                                 configBlock:nil
                             completionBlock:completionBlock];
    
    
//    KDSignInRecord *paramRecord = [[KDSignInRecord alloc] init];
//    paramRecord.featurename = self.markCell.textView.text;
//    paramRecord.photoIds = photoIds;
//    paramRecord.inCompany = self.signInType;
//    
//    KDSignInRequest *request = [[KDSignInRequest alloc] initWithSignInRecord:paramRecord signInType:2];
//    [request startCompletionBlockWithSuccess:^(__kindof KDRequest * _Nonnull request) {
//        if (request.response.responseObject && [request.response.responseObject isKindOfClass:[NSDictionary class]]) {
//            KDSignInRecord *record = [[KDSignInUtil parseSignInServerData:request.response.responseObject] objectForKey:@"record"];
//            if (record) {
//                if (kd_safeString(record.featurename).length == 0) {
//                    record.featurename = self.markCell.textView.text;
//                }
//                if (![KDSignInManager isFirstLauchPhotoSignIn]) {
//                    record.content = ASLocalizedString(@"再也不担心老板扣工资了，拍照签到为咱提供了100%的呵护与保障，我爱死TA了！");
//                    record.mbShare = record.content;
//                    [KDSignInManager setIsFirstLauchPhotoSignIn:YES];
//                    [self updateClockInWithSinginId:[record.singinId copy] mbShare:[record.mbShare copy] content:[record.content copy]];
//                }
//                if (block) { block(YES, record); }
//            }
//            else {
//                if (block) { block(NO, nil); }
//            }
//        }
//        else {
//            if (block) { block(NO, nil); }
//        }
//    } failure:^(__kindof KDRequest * _Nonnull request) {
//        if (block) { block(NO, nil); }
//    }];
}

#pragma mark - 更新微博信息
- (void)updateClockInWithSinginId:(NSString *)attendSetId mbShare:(NSString *)mbshare content:(NSString *)content {
    //签到迁移，暂时屏蔽
//    KDUpdateClockInRequest *request = [[KDUpdateClockInRequest alloc] initWithSinginId:attendSetId mbShare:mbshare content:content];
//    [request start];
}


- (void)saveRecords:(NSArray *)records date:(NSDate *)date completionBlock:(void (^)(id results))block {
    if (!date) {
        date = [NSDate date];
    }
    __block id results = nil;
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDSigninRecordDAO> signinDAO = [[KDWeiboDAOManager globalWeiboDAOManager] signinDAO];
        [signinDAO saveRecords:records withDate:date database:fmdb rollback:NULL];
        
        return results;
    } completionBlock:block];
}

- (void)signInSuccessPlaySound {
    [KDPopup showHUDToast:ASLocalizedString(@"签到成功")];
    static NSString *soundPath = nil;
    
    static NSURL *soundURL = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        soundPath = [[NSBundle mainBundle]
                     
                     pathForResource:@"Calypso" ofType:@"caf"];
        
        soundURL = [NSURL fileURLWithPath:soundPath];
        
    });
    
    SystemSoundID soundID;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundID);
    
    AudioServicesPlaySystemSound(soundID);
}


#pragma mark - photoPreviewDelegate -

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
    [self.tableview reloadData];
}

- (void)saveFailureSignInRecordWithPhotoIds:(NSString *)photoIds {
    [KDSignInLogManager sendSignInLogWithFailureType:KDSignInFailedTypeNormal errorMessage:[NSString stringWithFormat:ASLocalizedString(@"reason:拍照签到失败\n")]];
    
    KDSignInRecord *savedSignInRecord = [[KDSignInRecord alloc] init];
    savedSignInRecord.clockInType = @"photo";
    savedSignInRecord.inCompany = self.signInType;
    savedSignInRecord.longitude = 0;
    savedSignInRecord.latitude = 0;
    savedSignInRecord.status = -1;
    savedSignInRecord.featurename = self.markCell.textView.text;
    savedSignInRecord.message = self.markCell.textView.text;
    savedSignInRecord.singinTime = [NSDate date];
    savedSignInRecord.singinId = [NSString stringWithFormat:@"%@%f%lu",@"KD",[savedSignInRecord.singinTime timeIntervalSince1970],(unsigned long)[savedSignInRecord hash]];
    
    if (safeString(photoIds).length > 0) {
        savedSignInRecord.photoIds = photoIds;
    }
    else {
        if (self.pickedImageCachePath && self.pickedImageCachePath.count > 0) {
            NSString *cacheStr = @"";
            for (int i = 0; i < self.pickedImageCachePath.count; i++) {
                if (i == 0) {
                    cacheStr = self.pickedImageCachePath[0];
                }
                else {
                    cacheStr = [NSString stringWithFormat:@"%@,%@",cacheStr,self.pickedImageCachePath[i]];
                }
            }
            if (cacheStr && cacheStr.length > 0) {
                savedSignInRecord.cachesUrl = cacheStr;
            }
        }
    }
    
    [self saveRecords:@[savedSignInRecord] date:[NSDate date] completionBlock:^(id results){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KDAUTOWifiSignInSuccessNotification" object:nil];
    }];
    
}

- (void)showError:(UIView *)view title:(NSString *)title block:(void (^)())block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KDPopup showHUDSuccess:title];
    });
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [KDPopup hideHUD];
        if(block)
        {
            block();
        }
    });
}

@end
