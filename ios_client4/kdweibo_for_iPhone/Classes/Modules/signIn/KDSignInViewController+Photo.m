//
//  KDSignInViewController+Photo.m
//  kdweibo
//
//  Created by shifking on 16/4/21.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSignInViewController+Photo.h"
#import <objc/runtime.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "KDPhotoPreviewController.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "KDPhotoSignInPhotoCollectionView.h"
#import "KDPhotoSignInTipView.h"
#import "KDSignInUtil.h"
#import "NSDate+Additions.h"
#import "KDNewPhotoSignInController.h"

@interface KDSignInViewController()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, KDPhotoPreviewControllerDelegate, KDPhotoSignInPhotoCollectionViewDelegate>
@property (strong , nonatomic) KDPhotoSignInTipView *photoSignInTipView;

@end


@implementation KDSignInViewController (Photo)

#pragma mark - pickerControllerDelegate

- (void)addTipViewWithTip:(NSString *)tip {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.photoSignInTipView = [[KDPhotoSignInTipView alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.picker.view.frame), 44) title:tip block:nil];
        [self.picker.view addSubview:self.photoSignInTipView];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (self.photoSignInTipView) {
        [self.photoSignInTipView removeFromSuperview];
        self.photoSignInTipView = nil;
    }
    
    [KDPopup showHUD: ASLocalizedString(@"正在增加水印") inView:picker.view];
    [KDEventAnalysis event:event_signin_nol_photo];
    CFStringRef mediaType = (__bridge CFStringRef) [info objectForKey:UIImagePickerControllerMediaType];
    if (UTTypeConformsTo(mediaType, kUTTypeImage)) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        BOOL isDeviceRear = true;
        if(picker.cameraDevice == UIImagePickerControllerCameraDeviceFront){
            image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
            isDeviceRear = false;
        }
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init]; //将获取的照片存入相册
        //图片加水印
        NSString *usernameStr = [BOSConfig sharedConfig].user.name ? [BOSConfig sharedConfig].user.name : @"";
        NSString *tipsStr = [NSString stringWithFormat:ASLocalizedString(@"KDOutDoorSignInViewController_mark_message"), [[NSDate date] formatWithFormatter:@"yyyy-MM-dd HH:mm"], usernameStr,@""];
        image = [KDSignInUtil addTextToImage:image locationName:@"" text:tipsStr deviceIsFrom:isDeviceRear];
        [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation) image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                [KDPopup hideHUDInView:picker.view];
                [KDPopup showAlertWithTitle:ASLocalizedString(@"拍照存储失败") message:ASLocalizedString(@"请打开 设置-隐私-照片 来进行设置") buttonTitles:@[ASLocalizedString(@"确定")] onTap:^(NSInteger index) {
                    [picker dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *cacheStr = [self savePickedImage:image];
                    [KDPopup hideHUDInView:picker.view];
                    [picker dismissViewControllerAnimated:YES completion:^{
                        [self goingToPhtoSignInControllerWithCachePath:cacheStr assetUrlStr:[NSString stringWithFormat:@"%@", assetURL]];
                    }];
                });
            }
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.photoSignInTipView) {
        [self.photoSignInTipView removeFromSuperview];
        self.photoSignInTipView = nil;
    }
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)presentPreviewController:(UIViewController *)picker pickerImageCachePath:(NSString *)pickerdImageCachePath selectedAssetUrl:(NSString *)selectedAssetUrl {
    [KDPopup hideHUDInView:picker.view];
    KDPhotoPreviewController *photoPreviewCtl = [[KDPhotoPreviewController alloc] initWithNibName:nil bundle:nil];
    [photoPreviewCtl clickedPreviewImageViewAtIndex:0 assetArray:[@[selectedAssetUrl] copy] cacheArray:[@[pickerdImageCachePath] copy]];
    photoPreviewCtl.photoPreviewDelegate = self;
    photoPreviewCtl.isDeleteCache = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self presentViewController:photoPreviewCtl animated:YES completion:nil];
}

- (void)presentImagePickerController {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
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
        
        if (self.presentedViewController == nil) {
            self.picker = nil;
            [self presentViewController:self.picker animated:YES completion:nil];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:ASLocalizedString(@"该设备不支持拍照功能")
                                                       delegate:nil
                                              cancelButtonTitle:ASLocalizedString(@"确定")
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - KDPostPhotoPreviewDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)photoPreviewDone:(BOOL)isDone info:(NSDictionary *)info previewController:(KDPhotoPreviewController *)preview {
#pragma clang diagnostic pop
    [preview dismissViewControllerAnimated:YES completion:^{
        if (isDone) {
            if (info && ![info isKindOfClass:[NSNull class]]) {
                [self goingToPhtoSignInControllerWithCachePath:preview.cacheArray[0] assetUrlStr:preview.assetArray[0]];
            }
        }
    }];
    return;
}

- (NSString *)savePickedImage:(UIImage *)image {
    NSString *picturesPath = [[KDUtility defaultUtility] searchDirectory:KDPicturesDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];
    NSString *filename = [[NSDate date] formatWithFormatter:@"yyyyMMddHHmmss"];
    filename = [filename stringByAppendingFormat:@"_%@_photoSignIn", [NSString randomStringWithWide:6]];
    NSString *cachePath = [picturesPath stringByAppendingPathComponent:filename];
    
    // original image
    CGSize previewSize = CGSizeMake(800.0f, 600.0f);
    if (image.size.width > previewSize.width || image.size.height > previewSize.height) {
        image = [image scaleToSize:previewSize type:KDImageScaleTypeFill];
    }
    NSData *data = UIImageJPEGRepresentation(image, 0.1);
    [[NSFileManager defaultManager] createFileAtPath:cachePath contents:data attributes:nil];
    return cachePath;
}

- (void)goingToPhtoSignInControllerWithCachePath:(NSString *)path assetUrlStr:(NSString *)assetStr {
    KDNewPhotoSignInController *photoSignInController = [[KDNewPhotoSignInController alloc] init];
    RTRootNavigationController *navController = [[RTRootNavigationController alloc] initWithRootViewController:photoSignInController];
    
    photoSignInController.cacheImagePath = path;
    photoSignInController.assetImageUrl = assetStr;
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - KDPhotoSignInPhotoCollectionViewDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)whenPhotoClickedAtIndex:(NSInteger)index sourceArray:(NSMutableArray *)sourceArray isCache:(BOOL)isCache {
#pragma clang diagnostic pop
    if (!isCache) {
        NSMutableArray *photos = [NSMutableArray array];
        
        for (int i = 0; i < sourceArray.count; i++) {
            KDImageSource *source = [sourceArray objectAtIndex:i];
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString:source.original]; // 图片地址
            photo.originUrl = [NSURL URLWithString:source.noRawUrl];//原图地址
            
            if (source.isGifImage) {
                photo.isGif = YES;
            }
            
            [photos addObject:photo];
        }
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = index;
        browser.photos = photos;
        browser.bHideToolBar = YES;
        [browser show];
    }
    else {
        NSMutableArray *photos = [NSMutableArray array];
        
        for (int i = 0; i < sourceArray.count; i++) {
            NSString *sourceurl = [sourceArray objectAtIndex:i];
            MJPhoto *photo = [[MJPhoto alloc] init];
            NSData *data = [[NSData alloc] initWithContentsOfFile:sourceurl];
            if (data)
                photo.image = [UIImage imageWithData:data];
            else {
                photo.image = [UIImage imageNamed:@"image_placeholder_middle"];
            }
            [photos addObject:photo];
        }
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = index;
        browser.photos = photos;
        browser.bHideToolBar = YES;
        [browser show];
    }
}

#pragma mark - setter & getter 
- (UIImagePickerController *)picker {
    
    UIImagePickerController * pickerTemp = objc_getAssociatedObject(self, @selector(picker));
    if (pickerTemp) return pickerTemp;
    
    pickerTemp = [[UIImagePickerController alloc] init];
    pickerTemp.delegate = self;
    pickerTemp.allowsEditing = NO;
    pickerTemp.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerTemp.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    objc_setAssociatedObject(self, @selector(picker), pickerTemp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return pickerTemp;
}

- (void)setPicker:(UIImagePickerController *)picker {
    objc_setAssociatedObject(self, @selector(picker), picker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KDPhotoSignInTipView *)photoSignInTipView {
    KDPhotoSignInTipView *temp = objc_getAssociatedObject(self, @selector(photoSignInTipView));
    return temp;
}

- (void)setPhotoSignInTipView:(KDPhotoSignInTipView *)photoSignInTipView {
    objc_setAssociatedObject(self, @selector(photoSignInTipView), photoSignInTipView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
