//
//  KDOutDoorSignInViewController.m
//  kdweibo
//
//  Created by lichao_liu on 9/22/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import "KDOutDoorSignInViewController.h"
#import "KDSignInPointCell.h"
#import "KDSignInPhotoCell.h"
#import "KDPhotoPreviewController.h"
#import "KDPhotoUploadTask.h"
#import "KDImagePostPreviewView.h"
#import "NSDate+Additions.h"
#import "KDPhotoSignInContentCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BOSConfig.h"
#import "KDSignInUtil.h"
#import "KDTableViewHeaderFooterView.h"

@interface KDOutDoorSignInViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,KDPhotoUploadTaskDelegate,KDPhotoPreviewControllerDelegate,KDSignInPhotoCellDelegate>
@property (nonatomic, strong) KDSignInPointCell *signInPointCell;
@property (nonatomic, strong) KDSignInPhotoCell *photoCell;
@property (nonatomic, strong) KDPhotoSignInContentCell *markCell;
@property (nonatomic, strong) NSMutableArray *pickedImageCachePath;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *selectedImagesAssetUrl;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) KDPhotoUploadTask *uploadTask;

@property (strong , nonatomic) UITableViewCell *hadChooseCell;
@property (assign , nonatomic) OutDoor_Type chooseType;

@end

@implementation KDOutDoorSignInViewController

- (NSMutableArray *)selectedImagesAssetUrl
{
    if(!_selectedImagesAssetUrl)
    {
        _selectedImagesAssetUrl = [NSMutableArray new];
    }
    return _selectedImagesAssetUrl;
}

- (NSMutableArray *)pickedImageCachePath
{
    if(!_pickedImageCachePath)
    {
        _pickedImageCachePath = [NSMutableArray new];
    }
    return _pickedImageCachePath;
}

- (UIImagePickerController *)picker
{
    if(!_picker)
    {
        _picker = [[UIImagePickerController alloc] init];
        _picker.delegate = self;
        _picker.allowsEditing = NO;
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    return _picker;
}

- (KDSignInPointCell *)signInPointCell
{
    if(!_signInPointCell)
    {
        _signInPointCell= [[KDSignInPointCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"signinPointCell"];
        _signInPointCell.accessoryStyle = KDTableViewCellAccessoryStyleNone;
        _signInPointCell.iconImageView.image = [UIImage imageNamed:@"sign_tip_location"];
        _signInPointCell.locationLabel.text = self.locationData.name;
        _signInPointCell.detailLabel.text = self.locationData.address;
        _signInPointCell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    }
    return _signInPointCell;
}

- (KDSignInPhotoCell *)photoCell
{
    if(!_photoCell)
    {
        _photoCell = [[KDSignInPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"photoCellIdentifier"];
        _photoCell.assetURLs = self.pickedImageCachePath;
        _photoCell.previewCelldelegate = self;
        _photoCell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
    }
    return _photoCell;
}

- (KDPhotoSignInContentCell *)markCell
{
    if(!_markCell)
    {
        _markCell = [[KDPhotoSignInContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"markCellIdentifier"];
        _markCell.separatorLineStyle = KDTableViewCellSeparatorLineNone;
        _markCell.textView.returnKeyType = UIReturnKeyDone;
    }
    return  _markCell;
}

- (KDPhotoUploadTask *)uploadTask
{
    if(!_uploadTask)
    {
        _uploadTask = [[KDPhotoUploadTask alloc] init];
    }
    return _uploadTask;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = ASLocalizedString(@"外勤签到");
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    UIButton *rightBtn = [UIButton blueBtnWithTitle:ASLocalizedString(@"提交")];
    [rightBtn addTarget:self action:@selector(signInSubmitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    
    self.tableview = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.tableview.scrollEnabled = NO;
    
    [self.view addSubview:self.tableview];
    
    _chooseType = OutDoor_Type_None;
}


- (void)signInSubmitBtnClicked:(id)sender
{
    [self uploadPhotoAction];
}

#pragma mark - tableviewDelegate & datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(indexPath.section == 0 )
    {
        if(indexPath.row == 0)
        {
            cell = [self signInPointCell];
        }else if(indexPath.row == 1)
        {
            cell = [self photoCell];
        }
        
    }else if(indexPath.section == 1 && indexPath.row == 0)
    {
        cell = [self markCell];
    }
    else if (indexPath.section == 2) {
        static NSString *cellIdentifier = @"cellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"task_editor_select"]];
            imageView.frame = CGRectMake(12, 12, 22, 22);
            imageView.tag = 0x80;
            [cell.contentView addSubview:imageView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 12, 12, 130, 22)];
            label.textColor = FC1;
            label.font = FS6;
            label.tag = 0x81;
            [cell.contentView addSubview:label];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            ((KDTableViewCell *)cell).separatorLineStyle = KDTableViewCellSeparatorLineSpace;
            
        }
        UILabel *lab = (UILabel *)[cell.contentView viewWithTag:0x81];
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:0x80];
        if (indexPath.row == 0) {
            if (self.chooseType == OutDoor_Type_CUSTOMER_VISIT) {
                imageView.image = [UIImage imageNamed:@"task_editor_finish"];
            }
            else {
                imageView.image = [UIImage imageNamed:@"task_editor_select"];
            }
            lab.text = ASLocalizedString(@"客户跟进");
        }
        if (indexPath.row == 1) {
            if (self.chooseType == OutDoor_Type_LOOK_STORE) {
                imageView.image = [UIImage imageNamed:@"task_editor_finish"];
            }
            else {
                imageView.image = [UIImage imageNamed:@"task_editor_select"];
            }
            lab.text = ASLocalizedString(@"门店巡访");
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            return 68;
        }else if(indexPath.row == 1)
        {
            if(self.pickedImageCachePath && self.pickedImageCachePath.count>0)
            {
                return 100;
            }else {
                return 80;
            }
        }
    }else if(indexPath.section == 1)
    {
        return 80;
    }
    else  if (indexPath.section == 2) {
        return 12 * 2 + 22;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;//3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 2;
    }else if(section ==1)
    {
        return 1;
    }
    else if(section == 2) {
        return 2;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section != 2) {
        return [NSNumber kdDistance2];
    }
    return [KDTableViewHeaderFooterView heightWithStyle:KDTableViewHeaderFooterViewStyleGrayWhite];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 2) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
    KDTableViewHeaderFooterView *view = [[KDTableViewHeaderFooterView alloc] initWithStyle:KDTableViewHeaderFooterViewStyleGrayWhite];
    view.title = ASLocalizedString(@"选择需要创建的外勤工作事项");
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2) {
        if (self.hadChooseCell) {
            UIImageView *imageView = (UIImageView *)[self.hadChooseCell.contentView viewWithTag:0x80];
            imageView.image = [UIImage imageNamed:@"task_editor_select"];
        }
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:0x80];
        
        if (indexPath.row == 0) {
            _chooseType = OutDoor_Type_CUSTOMER_VISIT;
        }
        else {
            _chooseType = OutDoor_Type_LOOK_STORE;
        }
        
        if ([self.hadChooseCell isEqual: cell]) {
            _chooseType = OutDoor_Type_None;
            imageView.image = [UIImage imageNamed:@"task_editor_select"];
            _hadChooseCell = nil;
        }
        else {
            imageView.image = [UIImage imageNamed:@"task_editor_finish"];
            self.hadChooseCell = cell;
        }
    }
}

- (void)presentImagePickerController
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:ASLocalizedString(@"该设备拍照功能受限,请在设备的“设置-隐私-相机”里面修改")
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

#pragma mark - pickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak KDOutDoorSignInViewController *weakSelf = self;
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
        image = [KDSignInUtil addTextToImage:image locationName:self.locationData.name text:tipsStr deviceIsFrom:isDeviceRear];
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

- (void)presentPreviewController:(UIViewController *)picker
{
    [KDPopup hideHUDInView:picker.view];
    KDPhotoPreviewController *controller = [[KDPhotoPreviewController alloc] init];
    [controller clickedPreviewImageViewAtIndex:self.pickedImageCachePath.count -1 assetArray:self.selectedImagesAssetUrl cacheArray:self.pickedImageCachePath];
    controller.photoPreviewDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [KDPopup hideHUDInView:picker.view];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isCompressed:(NSData *)data
{
    float size = data.length / 1024.;
    return size > 200.f;
}

#pragma mark - KDSignInPhotoCellDelegate
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


- (void)handlePreviewResult:(NSDictionary *)info
{
    NSArray *cacheAssetURLs = [info objectForKey:@"CachedAssetURLs"];
    NSArray *cacheImageURLs = [info objectForKey:@"CachedImageURLs"];
    
    if ([cacheAssetURLs count] > 0) {
        [self removeLocalCachedPickImageNotIn:cacheImageURLs];
        [self.selectedImagesAssetUrl removeAllObjects];
        [self.selectedImagesAssetUrl addObjectsFromArray:cacheAssetURLs];
        
        [self.pickedImageCachePath removeAllObjects];
        [self.pickedImageCachePath addObjectsFromArray:cacheImageURLs];
    }else {
        [self.selectedImagesAssetUrl removeAllObjects];
        [self removeLocalCachedPickImage];
    }
    [_photoCell setAssetURLs:self.selectedImagesAssetUrl];
    [self.tableview reloadData];
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

- (NSString *)pickedImageLocalThumbnailCachePath:(NSString *)imagePath {
    return [imagePath stringByAppendingString:@"_thumb"];
}

#pragma mark - photoPreviewDelegate
- (void)photoPreviewDone:(BOOL)isDone info:(NSDictionary *)info previewController:(KDPhotoPreviewController *)preview
{
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

#pragma mark - KDPhotoUploadTaskDelegate

- (void)whenPhotoUploadTaskFailure:(NSDictionary *)dict task:(KDPhotoUploadTask *)task {
    task.taskDelegate = nil;
    [KDPopup hideHUD];
    self.completeBlock(self.markCell.textView.text, nil, [self getCacheStr] , _chooseType);
    [self.navigationController popViewControllerAnimated:YES];
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
        self.completeBlock(self.markCell.textView.text, fileidStr, nil,_chooseType);
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        self.completeBlock(self.markCell.textView.text, nil, [self getCacheStr] , _chooseType);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *)getCacheStr {
    NSString *str = nil;
    if (self.pickedImageCachePath && self.pickedImageCachePath.count > 0) {
        for (int i = 0; i < self.pickedImageCachePath.count; i++) {
            if (i == 0) {
                str = [self.pickedImageCachePath objectAtIndex:0];
            } else {
                str = [NSString stringWithFormat:@"%@,%@", str, [self.pickedImageCachePath objectAtIndex:i]];
            }
        }
    }
    if (str) {
        return [str copy];
    }
    return str;
}

- (void)uploadPhotoAction {
    [self.markCell.textView resignFirstResponder];
    if (self.pickedImageCachePath && self.pickedImageCachePath.count > 0) {
        [KDPopup showHUD:ASLocalizedString(@"图片上传中...")];
        self.uploadTask.taskDelegate = self;
        [self.uploadTask startUploadActionWithCachePathArray:self.pickedImageCachePath];
    } else {
        [KDPopup hideHUD];
        self.uploadTask.taskDelegate = nil;
        self.completeBlock(self.markCell.textView.text, nil, nil , _chooseType);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.markCell.textView resignFirstResponder];
}
@end
