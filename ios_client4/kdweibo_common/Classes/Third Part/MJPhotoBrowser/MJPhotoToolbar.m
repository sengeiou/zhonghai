//
//  MJPhotoToolbar.m
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJPhotoToolbar.h"
#import "MJPhoto.h"
#import "MBProgressHUD+Add.h"
#import "UIButton+Additions.h"
#import "MJPhotoView.h"

@interface MJPhotoToolbar() <MJPhotoViewDelegate>
{
    // 显示页码
    UILabel *_indexLabel;
    UIButton *_saveImageBtn;
    UIButton *_zoomBtn;
    
    BOOL _isOriginMode;
    
    MJPhotoView* _originView;
}
@end

@implementation MJPhotoToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isOriginMode = NO;
        _canSavePhoto = YES;
    }
    return self;
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    if (_photos.count > 1) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [UIFont boldSystemFontOfSize:16];
        _indexLabel.frame = CGRectMake(0, 0, 80, 25) ;
        _indexLabel.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _indexLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _indexLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        _indexLabel.layer.borderWidth = 1;
        _indexLabel.layer.cornerRadius = CGRectGetHeight(_indexLabel.frame)/2;
        _indexLabel.layer.masksToBounds = YES;
        [self addSubview:_indexLabel];
    }
    
    // 保存图片按钮
    // action
//    _saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_saveImageBtn addImageWithName:@"segment_black_button_bg.png" forState:UIControlStateNormal isBackground:YES];
//    [_saveImageBtn addImageWithName:@"gallery_save_icon.png" forState:UIControlStateNormal isBackground:NO];
//    [_saveImageBtn addImageWithName:@"gallery_save_icon_highlighted.png" forState:UIControlStateHighlighted isBackground:NO];
//    [_saveImageBtn addImageWithName:@"gallery_save_icon_disable.png" forState:UIControlStateDisabled isBackground:NO];
//    [_saveImageBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
//    _saveImageBtn.frame = CGRectMake(self.frame.size.width - 40.0f, 5.0f, 30.0f, 30.0f);
//    [self addSubview:_saveImageBtn];
//    
//    
//    _zoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_zoomBtn addImageWithName:@"segment_black_button_bg.png" forState:UIControlStateNormal isBackground:YES];
//    [_zoomBtn addImageWithName:@"segment_black_button_highlighted_bg.png" forState:UIControlStateHighlighted isBackground:YES];
//    [_zoomBtn addImageWithName:@"preview_zoomin_icon.png" forState:UIControlStateNormal isBackground:NO];
//    [_zoomBtn addTarget:self action:@selector(showOrDismissOriginalView) forControlEvents:UIControlEventTouchUpInside];
//    _zoomBtn.frame = CGRectMake(self.frame.size.width - 80.0f, 5.0f, 30.0f, 30.0f);
    
//    [self addSubview:_zoomBtn];

}

- (void)saveImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MJPhoto *photo = _photos[_currentPhotoIndex];
        UIImageWriteToSavedPhotosAlbum(photo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}
- (void)showOrDismissOriginalView
{
    if (_isOriginMode) {
        
        if (self.superview != nil) {
            [_zoomBtn setImage:[UIImage imageNamed:@"preview_zoomin_icon.png"] forState:UIControlStateNormal];
            [_originView removeFromSuperview];
            
            if (self.canSavePhoto) {
                _saveImageBtn.hidden = NO;
            } else {
                _saveImageBtn.hidden = YES;
            }
            [_indexLabel setHidden:NO];
            
            _isOriginMode = NO;
        }
        
    }
    else
    {
        if(self.superview != nil) {
            [_zoomBtn setImage:[UIImage imageNamed:@"preview_zoomout_icon.png"] forState:UIControlStateNormal];
            
            if (_originView == nil) {
                _originView = [[MJPhotoView alloc] initWithFrame:self.superview.bounds];
                _originView.mode = MJPhotoViewModeOriginal;
            }
            _originView.photoViewDelegate = self;
            
            MJPhoto *photo = _photos[_currentPhotoIndex];
            
            MJPhoto *tPhoto = [[MJPhoto alloc] init];
            tPhoto.originUrl = photo.originUrl;
            tPhoto.url = photo.url;
            tPhoto.image = nil;
            tPhoto.srcImageView = photo.srcImageView;
            tPhoto.placeholder = photo.image?photo.image:photo.srcImageView.image;
            tPhoto.firstShow = NO;
            
            [_originView setPhoto:tPhoto];
            
            [self.superview insertSubview:_originView belowSubview:self];
            
            [_saveImageBtn setHidden:YES];
            [_indexLabel setHidden:YES];
            
            _isOriginMode = YES;
        }
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [MBProgressHUD showSuccess:ASLocalizedString(@"KDVideoPickerViewController_save_fail")toView:nil];
    } else {
        MJPhoto *photo = _photos[_currentPhotoIndex];
        photo.save = YES;
        _saveImageBtn.enabled = NO;
        [MBProgressHUD showSuccess:ASLocalizedString(@"SavePhoto_Success")toView:nil];
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    if (_photos.count > 0) {
        
        // 更新页码
        _indexLabel.text = [NSString stringWithFormat:@" %lu / %lu  ", (unsigned long)_currentPhotoIndex + 1, (unsigned long)_photos.count];
        
        CGRect frame = _indexLabel.frame;
        [_indexLabel sizeToFit];
        frame.size.width = MAX(_indexLabel.frame.size.width,60);
        _indexLabel.frame = frame;
        _indexLabel.center = CGPointMake(self.bounds.size.width/2, _indexLabel.center.y);
        
        
        MJPhoto *photo = _photos[_currentPhotoIndex];
        // 按钮
        _saveImageBtn.enabled = photo.image != nil && !photo.save;
    }
}

- (void)setCanSavePhoto:(BOOL)canSavePhoto {
    _canSavePhoto = canSavePhoto;
    if (canSavePhoto) {
        _saveImageBtn.hidden = NO;
    } else {
        _saveImageBtn.hidden = YES;
    }
}

#pragma mark 
- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView
{
    
}
- (void)photoViewSingleTap:(MJPhotoView *)photoView
{
    if (_photoBrowser) {
        [_photoBrowser originalViewWillDissmiss];
    }
    photoView.backgroundColor = [UIColor clearColor];
}
- (void)photoViewDidEndZoom:(MJPhotoView *)photoView
{
    if (_photoBrowser) {
        [_photoBrowser originalViewDidDissmiss];
    }
    [_originView removeFromSuperview];
}

@end
