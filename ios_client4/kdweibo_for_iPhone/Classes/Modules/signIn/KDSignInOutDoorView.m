//
//  KDSignInOutDoorView.m
//  kdweibo
//
//  Created by 王 松 on 14-1-7.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDSignInOutDoorView.h"
#import "UIView+Blur.h"
#import <QuartzCore/QuartzCore.h>
#import "KDAnimationFactory.h"
#import "HPTextViewInternal.h"
#import "KDImagePostPreviewView.h"
#import "KDPhotoPreviewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BOSConfig.h"
#import "NSDate+Additions.h"
@interface KDSignInOutDoorView ()<UITextViewDelegate, UIGestureRecognizerDelegate,KDImagePostPreviewViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,KDPhotoPreviewControllerDelegate,KDPhotoUploadTaskDelegate>
//{
//    UIWindow *keyWindow;
//}

@property (nonatomic, retain) UIWindow *alertWindow;

@property (nonatomic, retain) UIWindow *oldKeyWindow;

@property (nonatomic, retain) UIButton *submitButton;

@property (nonatomic, retain) UIView *bgView;

@property (nonatomic, retain) UIView *mainView;

@property (nonatomic, retain) UILabel *titleLabel;

@property (nonatomic, retain) UILabel *locationLabel;

@property (nonatomic, retain) HPTextViewInternal *contentView;

@property (nonatomic, copy) KDSignInOutDoorViewBlock completeBlock;

@property (nonatomic, strong) KDImagePostPreviewView *imagePreviewView;

@property (nonatomic, strong) UIImagePickerController *picker;

@property (nonatomic, assign) KDSignInViewController *controller;

@property (nonatomic, strong) NSMutableArray *selectedImagesAssetUrl;

@property (nonatomic, strong) NSMutableArray *pickedImageCachePath;

@property (nonatomic, assign) BOOL isCanceled;

@property (nonatomic, strong) UIView *alphaView;

@end

@implementation KDSignInOutDoorView

- (KDPhotoUploadTask *)uploadTask
{
    if(!_uploadTask)
    {
        _uploadTask = [[KDPhotoUploadTask alloc] init];
    }
    return _uploadTask;
}
- (NSMutableArray *)selectedImagesAssetUrl
{
    if(!_selectedImagesAssetUrl)
    {
        _selectedImagesAssetUrl = [NSMutableArray new];
    }
    return _selectedImagesAssetUrl;
}
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}
- (NSMutableArray *)pickedImageCachePath
{
    if(!_pickedImageCachePath)
    {
        _pickedImageCachePath = [NSMutableArray new];
    }
    return _pickedImageCachePath;
}


- (id)initWithTitle:(NSString *)title controller:(KDSignInViewController *)controller
{
    if (self = [self initWithFrame:CGRectZero]) {
        _titleLabel.text = title;
        self.controller = controller;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)setupViews
{
    _bgView = [[UIView alloc] initWithFrame:CGRectZero];
    _bgView.backgroundColor = RGBACOLOR(0.f, 0.f, 0.f, 0.4);
    [self addSubview:_bgView];
    
    _mainView = [[UIView alloc] initWithFrame:CGRectMake((ScreenFullWidth-300.f)/2, (ScreenFullHeight-350)/2, 300.f, 350.f)];
    _mainView.backgroundColor = MESSAGE_BG_COLOR;
    [self addSubview:_mainView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)] ;//autorelease];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];// autorelease];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    tap1.numberOfTapsRequired = 1;
    tap1.delegate = self;
    [_bgView addGestureRecognizer:tap];
    [_mainView addGestureRecognizer:tap1];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(_mainView.frame), 50.f)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont systemFontOfSize:20.f];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleLabel addBorderAtPosition:KDBorderPositionBottom];
    [_mainView addSubview:_titleLabel];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"singin_icon_delete_on.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.frame = CGRectMake(CGRectGetWidth(_mainView.frame) - 40.f - 5.f, 5.f, 40, 40);
    [_mainView addSubview:closeButton];
    
    UIView *locationView = [[UIView alloc] initWithFrame:CGRectMake(10.f, CGRectGetMaxY(_titleLabel.frame) + 10.f, CGRectGetWidth(_mainView.frame) - 20.f, 60.f)] ;//autorelease];
    [locationView setBackgroundColor:[UIColor whiteColor]];
    UIImageView *locationIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location_option_cell_icon.png"]];// autorelease];
    locationIconView.frame = CGRectMake(10.f, (CGRectGetHeight(locationView.frame) - CGRectGetHeight(locationIconView.frame)) * 0.5f, CGRectGetWidth(locationIconView.frame), CGRectGetHeight(locationIconView.frame));
    [locationView addSubview:locationIconView];
    
    _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(locationIconView.frame) + 5.f, 0.f, CGRectGetWidth(locationView.frame) - CGRectGetMaxX(locationIconView.frame) - 10.f, CGRectGetHeight(locationView.frame))];
    _locationLabel.backgroundColor = [UIColor clearColor];
    _locationLabel.font = [UIFont systemFontOfSize:17.f];
    _locationLabel.textColor = MESSAGE_NAME_COLOR;
    [locationView addSubview:_locationLabel];
    
    [locationView addBorderAtPosition:KDBorderPositionAll];
    [_mainView addSubview:locationView];
    
    _contentView = [[HPTextViewInternal alloc] initWithFrame:CGRectMake(10.f, CGRectGetMaxY(locationView.frame) + 10.f, CGRectGetWidth(_mainView.frame) - 20.f, 160.f)];
    _contentView.placeholder = ASLocalizedString(@"KDSignInOutDoorView_contentView_placeholder");
    _contentView.placeholderColor = RGBCOLOR(174.f, 174.f, 174.f);
    _contentView.displayPlaceHolder = YES;
    _contentView.layer.cornerRadius = 3.f;
    _contentView.layer.masksToBounds = YES;
    _contentView.layer.borderWidth = 0.5f;
    _contentView.font = [UIFont systemFontOfSize:18.f];
    _contentView.layer.borderColor = RGBCOLOR(203.f, 203.f, 203.f).CGColor;
    _contentView.delegate = self;
    [_mainView addSubview:_contentView];
    
    _submitButton = [UIButton buttonWithType:UIButtonTypeCustom] ;//retain];
    [_submitButton setTitle:ASLocalizedString(@"KDBindEmailViewController_submit")forState:UIControlStateNormal];
    [_submitButton setBackgroundImage:[UIImage imageNamed:@"signon_btn_bg_v2.png"] forState:UIControlStateNormal];
    [_submitButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
    _submitButton.layer.masksToBounds = YES;
    _submitButton.layer.cornerRadius = 5.f;
    _submitButton.frame = CGRectMake((CGRectGetWidth(_mainView.frame) - 100.f) * 0.5f, CGRectGetHeight(_mainView.frame) - 45.f, 100.f, 30.f);
    [_mainView addSubview:_submitButton];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _bgView.frame = self.bounds;
}

- (void)showWithLocation:(NSString *)location block:(void (^)(NSString *content,NSString *photoIds,NSString *cacheStr)) block
{
    
    self.oldKeyWindow = [UIApplication sharedApplication].keyWindow;
    self.locationLabel.text = location;
    self.completeBlock = block;
    UIWindow *keyWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    keyWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    keyWindow.opaque = NO;
    keyWindow.windowLevel = UIWindowLevelAlert;
    
    CGRect rect = keyWindow.bounds;
    self.frame = rect;
    
    self.alphaView = [[UIView alloc] initWithFrame:keyWindow.bounds];
    self.alphaView.backgroundColor = [UIColor blackColor];
    self.alphaView.alpha = 0.7;
    [keyWindow addSubview:self.alphaView];
    
    [keyWindow addSubview:self];
    [keyWindow makeKeyAndVisible];
    self.alertWindow = keyWindow;
//    [keyWindow release];
    
    
    [self.bgView.layer addAnimation:[KDAnimationFactory windowFadeInAnimationWithDuration:0.25] forKey:@"fadeIn"];
    [self.mainView.layer addAnimation:[KDAnimationFactory alertShowAnimationWithDuration:0.27] forKey:@"show"];
}

#pragma mark
#pragma mark keyboard notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    rect = [self convertRect:rect toView:nil];
    
    CGFloat keyboardHeight = rect.size.height;
    CGFloat maxY = [UIScreen mainScreen].bounds.size.height - keyboardHeight - 10.f;
    CGFloat minY = maxY - CGRectGetHeight(self.mainView.frame);
    
    CGRect frame = self.mainView.frame;
    frame.origin.y = minY;
    self.mainView.frame = frame;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect frame = self.mainView.frame;
    frame.origin.y = 75.f;
    self.mainView.frame = frame;
}

- (void)hideKeyBoard
{
    [self.contentView resignFirstResponder];
}

- (void)hide:(id)sender
{
    CAAnimation *animation = [KDAnimationFactory alertDismissAnimationWithDuration:0.25];
    animation.delegate = self;
    [self.mainView.layer addAnimation:animation forKey:@"dismiss"];
    [self.bgView.layer addAnimation:[KDAnimationFactory windowFadeOutAnimationWithDuration:0.25] forKey:@"fadeOut"];
    if (sender == self.submitButton && self.completeBlock) {
        [self uploadPhotoAction];
    }else{
        [MBProgressHUD hideAllHUDsForView:self.alertWindow animated:YES];
        [self.alphaView removeFromSuperview];
        [self.alertWindow removeFromSuperview];
        [MBProgressHUD hideAllHUDsForView:self.controller.view animated:YES];
        [self.mainView removeFromSuperview];
        [self.bgView removeFromSuperview];
        self.alertWindow.hidden = YES;
        self.alertWindow = nil;
        if(self.pickedImageCachePath && self.pickedImageCachePath.count>0)
        {
            self.isCanceled = YES;
            [self removeLocalCachedPickImage];
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

- (void)uploadPhotoAction
{
    
    if(self.pickedImageCachePath && self.pickedImageCachePath.count>0)
    {
        [MBProgressHUD showHUDAddedTo:self.alertWindow animated:YES];
        [MBProgressHUD HUDForView:self.alertWindow].labelText = ASLocalizedString(@"KDSignInOutDoorView_HUD_labelText");
        self.uploadTask.taskDelegate = self;
        [self.uploadTask startUploadActionWithCachePathArray:self.pickedImageCachePath];
    }else{
        if(self.pickedImageCachePath && self.pickedImageCachePath.count>0)
        {
            [MBProgressHUD hideAllHUDsForView:self.controller.view animated:YES];
        }
        [MBProgressHUD hideAllHUDsForView:self.alertWindow animated:YES];
        [self.alphaView removeFromSuperview];
        self.alertWindow.hidden = YES;
        self.alertWindow = nil;
        self.completeBlock(self.contentView.text,nil,nil);
    }
}

#pragma mark
#pragma mark - CAAnimation Delegate Method
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.mainView.layer removeAnimationForKey:@"dismiss"];
    [self.bgView.layer removeAnimationForKey:@"fadeOut"];
    
    [self.oldKeyWindow makeKeyAndVisible];
    [self.alertWindow removeFromSuperview];
    self.alertWindow = nil;
    
    if(self.pickedImageCachePath && self.pickedImageCachePath.count>0)
    {
        if(!self.isCanceled)
        {
            [MBProgressHUD showHUDAddedTo:self.controller.view animated:YES];
        }
    }
}


- (void)handlePreviewResult:(NSDictionary *)info
{
    NSArray *cacheAssetURLs = [info objectForKey:@"asset"];
    NSArray *cacheImageURLs = [info objectForKey:@"cache"];
    
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
    [self.imagePreviewView setAssetURLs:self.pickedImageCachePath];
}
- (void)removeLocalCachedPickImageNotIn:(NSArray *)notRemoved {
    
    NSMutableSet *preSet = [NSMutableSet setWithArray:self.pickedImageCachePath];
    NSSet *notSet = [NSSet setWithArray:notRemoved];
    [preSet minusSet:notSet];
    
    NSArray *toRemoved = [preSet allObjects];
    
    for (NSString *path in toRemoved) {
        
        //        NSString *thumbnailPath = [self pickedImageLocalThumbnailCachePath:path];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        }
        
        //        if([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath]){
        //            [[NSFileManager defaultManager] removeItemAtPath:thumbnailPath error:NULL];
        //        }
    }
}
#pragma mark
#pragma mark - textView Delegate Method
- (void)textViewDidChange:(HPTextViewInternal *)textView
{
    textView.displayPlaceHolder = textView.text.length == 0;
    [textView setNeedsDisplay];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isMemberOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - KDImagePostPreviewViewDelegate
- (void)imagePostPreview:(KDImagePostPreviewView *)imagePostPreview didTapAtIndex:(NSUInteger)index
{
    //    self.alertWindow.hidden = YES;
    //    self.hidden = YES;
    self.alpha = 0;
    self.alertWindow.alpha = 0;
    KDPhotoPreviewController *photoPreviewCtl = [[KDPhotoPreviewController alloc] initWithNibName:nil bundle:nil];
    [photoPreviewCtl clickedPreviewImageViewAtIndex:index assetArray:self.selectedImagesAssetUrl cacheArray:self.pickedImageCachePath];
    photoPreviewCtl.photoPreviewDelegate = self;
    [self.controller presentViewController:photoPreviewCtl animated:YES completion:nil];
}


- (void)presentPreviewController:(UIViewController *)picker
{
    
    self.alertWindow.alpha = 0;
    self.alpha = 0;
    [MBProgressHUD hideAllHUDsForView:picker.view animated:YES];
    
    KDPhotoPreviewController *photoPreviewCtl = [[KDPhotoPreviewController alloc] initWithNibName:nil bundle:nil];
    [photoPreviewCtl clickedPreviewImageViewAtIndex:self.selectedImagesAssetUrl.count - 1 assetArray:self.selectedImagesAssetUrl cacheArray:self.pickedImageCachePath];
    photoPreviewCtl.photoPreviewDelegate = self;
    
    picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [picker dismissViewControllerAnimated:NO completion:nil];
    [self.controller presentViewController:photoPreviewCtl animated:YES completion:nil];
}
#pragma mark - KDPhotoUploadTaskDelegate
- (void)whenPhotoUploadTaskFailure:(NSDictionary *)dict task:(KDPhotoUploadTask *)task
{
    task.taskDelegate = nil;
    self.isCanceled = YES;
    [MBProgressHUD hideAllHUDsForView:self.alertWindow animated:YES];
    if(self.pickedImageCachePath && self.pickedImageCachePath.count>0)
    {
        [MBProgressHUD hideAllHUDsForView:self.controller.view animated:YES];
    }
    NSMutableArray *filesArray =  dict[@"fileIds"];
    if(filesArray && filesArray.count>0)
    {
        NSString *fileidStr =@"";
        for (int i =0;i<filesArray.count;i++) {
            NSString *fileid = filesArray[i];
            if(i>0 && i<filesArray.count)
            {
                fileidStr = [NSString stringWithFormat:@"%@,%@",fileidStr,fileid];
            }else if(i== 0)
            {
                fileidStr = [NSString stringWithFormat:@"%@",fileid];
            }
        }
        self.completeBlock(self.contentView.text,fileidStr,nil);
    }else{
        self.completeBlock(self.contentView.text,nil,[self getCacheStr]);
    }
}

- (void)whenPhotoUploadTaskSuccess:(NSDictionary *)dict task:(KDPhotoUploadTask *)task
{
    task.taskDelegate = nil;
    [MBProgressHUD hideAllHUDsForView:self.alertWindow animated:YES];
    if(self.pickedImageCachePath && self.pickedImageCachePath.count>0)
    {
        [MBProgressHUD hideAllHUDsForView:self.controller.view animated:YES];
    }
    NSMutableArray *filesArray =  dict[@"fileIds"];
    if(filesArray && filesArray.count>0)
    {
        NSString *fileidStr =@"";
        for (int i =0;i<filesArray.count;i++) {
            NSString *fileid = filesArray[i];
            if(i>0 && i<filesArray.count)
            {
                fileidStr = [NSString stringWithFormat:@"%@,%@",fileidStr,fileid];
            }else if(i== 0)
            {
                fileidStr = [NSString stringWithFormat:@"%@",fileid];
            }
        }
        self.completeBlock(self.contentView.text,fileidStr,nil);
    }else{
        self.completeBlock(self.contentView.text,nil,[self getCacheStr]);
    }
}

#pragma mark - pickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    __weak KDSignInOutDoorView *weakSelf = self;
    [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
    [MBProgressHUD HUDForView:picker.view].labelText = ASLocalizedString(@"正在增加水印");
    [KDEventAnalysis event:event_signin_photo];
    CFStringRef mediaType = (__bridge CFStringRef)[info objectForKey:UIImagePickerControllerMediaType];
    if(UTTypeConformsTo(mediaType, kUTTypeImage)){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init]; //将获取的照片存入相册
        //图片加水印
        NSString *usernameStr = [BOSConfig sharedConfig].user.name ? [BOSConfig sharedConfig].user.name : @"";
        NSString *tipsStr = [NSString stringWithFormat:ASLocalizedString(@"%@ %@ %@签到"),[[NSDate date] formatWithFormatter:@"yyyy-MM-dd HH:mm"],usernameStr,KD_APPNAME];
        image = [self addImage:image addImage:[UIImage imageNamed:@"photoSignInMark"] text:tipsStr locationText:self.locationLabel.text];
        [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                [MBProgressHUD hideAllHUDsForView:picker.view animated:YES];
                [weakSelf showError:weakSelf.picker.view title:ASLocalizedString(@"KDSignInOutDoorView_picker_view_title")block:^{
                    weakSelf.picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    [weakSelf.picker dismissViewControllerAnimated:YES completion:nil];
                    weakSelf.hidden = NO;
                    weakSelf.alpha = 1;
                    weakSelf.alertWindow.hidden = NO;
                    weakSelf.alertWindow.alpha = 1;
                }];
            }
            else
            {
                [weakSelf.selectedImagesAssetUrl addObject:[NSString stringWithFormat:@"%@", assetURL]];
                //            [weakSelf.imagePreviewView setAssetURLs:_pickedImageCachePath];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakSelf savePickedImage:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideAllHUDsForView:picker.view animated:YES];
                        //                    [MBProgressHUD hideAllHUDsForView:weakSelf.alertWindow animated:YES];
                        //                    [self presentPreviewController:picker];
                        [weakSelf.imagePreviewView setAssetURLs:weakSelf.pickedImageCachePath];
                        weakSelf.alertWindow.hidden = NO;
                        weakSelf.hidden = NO;
                        weakSelf.alertWindow.alpha = 1;
                        weakSelf.alpha = 1;
                        
                        picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                        [picker dismissViewControllerAnimated:NO completion:nil];
                        
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
    
    // original image
    CGSize previewSize = CGSizeMake(800.0f, 600.0f);
    if(image.size.width > previewSize.width || image.size.height > previewSize.height){
        image = [image scaleToSize:previewSize type:KDImageScaleTypeFill];
    }
    
    //    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    
    //    if ([self isCompressed:data]) {
    NSData  *data = UIImageJPEGRepresentation(image, 0.1);
    //    }
    [[NSFileManager defaultManager] createFileAtPath:cachePath contents:data attributes:nil];
}

- (UIImage *)addImage:(UIImage *)img addImage:(UIImage *)addImage text:(NSString *)mark locationText:(NSString *)locationStr
{
    int w = img.size.width;
    int h = img.size.height;
    UIGraphicsBeginImageContext(img.size);
    [[UIColor whiteColor] set];
    [img drawInRect:CGRectMake(0, 0, w, h)];
    
    
    BOOL isIos7OrLater = [[[UIDevice currentDevice]systemVersion] doubleValue] >=7 ? YES : NO;
    UIImage *bgImage = [UIImage imageNamed:@"photoSignInBg"];
    [bgImage drawInRect:CGRectMake(0,isIos7OrLater ?( h - 400):(h-170), w, isIos7OrLater ? 400:170)];
    NSInteger locationFont =  isIos7OrLater? 93:33;
    NSInteger markFont = isIos7OrLater ? 100 :37;
    CGSize locationSize = [locationStr sizeWithFont:[UIFont systemFontOfSize:locationFont] constrainedToSize:CGSizeMake(w- 143.5, 80)];
    CGSize markSize = [mark sizeWithFont:[UIFont systemFontOfSize:markFont] constrainedToSize:CGSizeMake(w -58.5  , 80)];
    
    CGFloat y = (w - markSize.width)*0.5 >0 ? (w - markSize.width)*0.5:0;
    
    [addImage drawInRect:CGRectMake(y,isIos7OrLater ?( h - 345) : (h- 130),isIos7OrLater ? 76 : 9.5*3,isIos7OrLater ? 104 : 13*3)];
    [locationStr drawInRect:CGRectMake(isIos7OrLater ?( y+85.5) : (y + 52),isIos7OrLater ?( h - 360):(h- 130), locationSize.width, 80) withFont:[UIFont systemFontOfSize: markFont]];
    
    [mark drawInRect:CGRectMake((w-markSize.width)*0.5 > 0 ? ((w-markSize.width)*0.5): 0,isIos7OrLater ?( h - 200):(h- 80), w - 58.5, 80) withFont:[UIFont systemFontOfSize:locationFont]];
    
    
    UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aimg;
}
- (void)imagePostPreview:(KDImagePostPreviewView *)imagePostPreview didTapAddedButton:(BOOL)tap
{
    
    [self presentImagePickerController];
}

- (void)presentImagePickerController
{
    //    [_contentView resignFirstResponder];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self.contentView resignFirstResponder];
        self.picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.controller presentViewController:self.picker animated:YES completion:nil];
        self.alertWindow.alpha = 0;
        self.alpha = 0;
        self.hidden = NO;
        self.alertWindow.hidden = NO;
        self.userInteractionEnabled = YES;
        self.alertWindow.userInteractionEnabled = YES;
    }else{
        [self showError:self.alertWindow title:ASLocalizedString(@"KDSignInOutDoorView_alertWindow_title")block:nil];
    }
}


- (void)showError:(UIView *)view title:(NSString *)title block:(void (^)())block
{
    double delayInSeconds = 3.5;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:view animated:YES];
        [MBProgressHUD HUDForView:view].labelText = title;
        
    });
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MBProgressHUD hideAllHUDsForView:view animated:YES];
        if(block)
        {
            block();
        }
    });
}

- (NSString *)getCacheStr
{
    NSString *str = nil;
    if(self.pickedImageCachePath && self.pickedImageCachePath.count>0)
    {
        for (int i =0; i<self.pickedImageCachePath.count; i++) {
            if(i == 0)
            {
                str = [self.pickedImageCachePath objectAtIndex:0];
            }else {
                str = [NSString stringWithFormat:@"%@,%@",str,[self.pickedImageCachePath objectAtIndex:i]];
            }
        }
    }
    if(str)
    {
        return [str copy];
    }
    return str;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //KD_RELEASE_SAFELY(_oldKeyWindow);
    //KD_RELEASE_SAFELY(_alertWindow);
    //KD_RELEASE_SAFELY(_submitButton);
    //KD_RELEASE_SAFELY(_bgView);
    //KD_RELEASE_SAFELY(_mainView);
    //KD_RELEASE_SAFELY(_titleLabel);
    //KD_RELEASE_SAFELY(_locationLabel);
    //KD_RELEASE_SAFELY(_contentView);
//    Block_release(_completeBlock);
    //[super dealloc];

}

@end
