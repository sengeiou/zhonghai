//
//  KDImagePostPreviewView.m
//  kdweibo
//
//  Created by 王 松 on 13-6-20.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDImagePostPreviewView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Additions.h"
#import "UIColor+Extension.h"
#import <QuartzCore/QuartzCore.h>

#define kImageSize CGSizeMake(70.0f,70.0f)
#define kImageInset (float)8.0f
#define kImageViewTagPre (int)100
#define kTempVideoBgTag (int)10002
#define kAddButtonTag (int)10003
#define kTempFileBgTag (int)10004

@interface KDImagePostPreviewView ()
{
    NSString *videoSize;
}

@end

@implementation KDImagePostPreviewView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_assetURLs);
    //KD_RELEASE_SAFELY(_videoThumbnail);
    //KD_RELEASE_SAFELY(_fileDataModel);
    //[super dealloc];
}

- (void)setFileDataModel:(MessageFileDataModel *)fileDataModel {
    if (_fileDataModel != fileDataModel) {
//        [_fileDataModel release];
        _fileDataModel = fileDataModel;// retain];
        [self setupFileView];
        if (_fileDataModel == nil) {
            UIView *bgView = [self viewWithTag:kTempFileBgTag];
            [bgView removeFromSuperview];
        }
    }
}

- (void)setupFileView {
    UIView *bgView = [[UIView alloc] init];
    bgView.tag = kTempFileBgTag;
    bgView.backgroundColor = RGBCOLOR(237.f, 237.f, 237.f);
    bgView.userInteractionEnabled = YES;
    [self addSubview:bgView];
    
    UIImageView *fileImage = [[UIImageView alloc] init];// autorelease];
    fileImage.image = [UIImage imageNamed:[XTFileUtils thumbnailImageWithExt:self.fileDataModel.ext]];
    [bgView addSubview:fileImage];
    
    UIButton *deleteImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteImage setImage:[UIImage imageNamed:@"app_btn_delete_normal"] forState:UIControlStateNormal];
    [deleteImage setImage:[UIImage imageNamed:@"app_btn_delete_press"] forState:UIControlStateHighlighted];
    [deleteImage addTarget:self action:@selector(deleteFile) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:deleteImage];
    
    UILabel *fileName = [UILabel new] ;//autorelease];
    fileName.text = self.fileDataModel.name;
    fileName.font = FS4;
    fileName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [bgView addSubview:fileName];
    
    UILabel *fileSize = [UILabel new];// /autorelease];
    fileSize.text = [XTFileUtils fileSize:self.fileDataModel.size];
    fileSize.font = FS4;
    [bgView addSubview:fileSize];
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(bgView.superview);
        make.height.mas_equalTo(50);
    }];
    
    [fileImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(fileImage.superview).with.offset(8);
        make.centerY.equalTo(fileImage.superview);
        make.width.height.mas_equalTo(40);
    }];
    
    [deleteImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(deleteImage.superview.trailing).with.offset(-28);
        make.centerY.equalTo(deleteImage.superview);
        make.width.height.mas_equalTo(20);
    }];
    
    [fileName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(fileImage.trailing).with.offset(8);
        make.top.equalTo(fileName.superview).with.offset(8);
        make.trailing.equalTo(deleteImage.leading).with.offset(-8);
    }];
    
    [fileSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(fileImage.trailing).with.offset(8);
        make.bottom.equalTo(fileSize.superview).with.offset(-8);
        make.trailing.equalTo(deleteImage.leading).with.offset(-8);
        
    }];
    [self setNeedsLayout];
}

- (void)deleteFile {
    UIView *bgView = [self viewWithTag:kTempFileBgTag];
    [bgView removeFromSuperview];
    
    if ([self.delegate respondsToSelector:@selector(deleteFileClicked)]) {
        [self.delegate deleteFileClicked];
    }
}

- (void)setAssetURLs:(NSArray *)images
{
    if (_assetURLs != images) {
        //KD_RELEASE_SAFELY(_assetURLs);
    }
    _assetURLs = images;// retain];
    [self setupView];
}

- (void)setVideoThumbnail:(UIImage *)videoThumbnail withSize:(NSString *)size
{
    videoSize = size;
    [self setVideoThumbnail:videoThumbnail];
}

- (void)setVideoThumbnail:(UIImage *)videoThumbnail
{
    if (_videoThumbnail != videoThumbnail) {
        //KD_RELEASE_SAFELY(_videoThumbnail);
    }
    _videoThumbnail = videoThumbnail ;//retain];
    [self setupVideoThumbnailView];
}

- (void)setShowAddedButton:(BOOL)showAddedButton
{
    _showAddedButton = showAddedButton;
}

- (void)setupVideoThumbnailView
{
    CGRect frame = self.frame;
    
    frame.size.height = 96. + kImageInset * 2;
    self.frame = frame;
    
    for (UIView *temp in [self subviews]) {
        if ([temp isKindOfClass:[UIImageView class]]) {
            [temp removeFromSuperview];
        }
    }
    _showAddedButton = NO;
    [self setAddButton];
    
    UIView *bgView = [self viewWithTag:kTempVideoBgTag];
    [bgView removeFromSuperview];
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(5, kImageInset, frame.size.width - 25, kImageSize.height + kImageInset * 2)];
    bgView.tag = kTempVideoBgTag;
    bgView.backgroundColor = RGBCOLOR(237.f, 237.f, 237.f);
    [self addSubview:bgView];
    
    CGRect rect = CGRectZero;
    rect.origin.x = kImageInset;
    rect.origin.y = kImageInset;
    rect.size = kImageSize;
    
    UIView *clickView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, bgView.frame.size.width - 50.f, bgView.frame.size.height)];
    [bgView addSubview:clickView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.layer.borderColor = [UIColor blackColor].CGColor;
    imageView.layer.borderWidth = 1.f;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.image = self.videoThumbnail;
    [bgView addSubview:imageView];
    
    if (videoSize.length > 0) {
        UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90.f, 35.0f, 80.f, 20.f)];
        sizeLabel.backgroundColor = [UIColor clearColor];
        sizeLabel.font = [UIFont systemFontOfSize:16.f];
        sizeLabel.textColor = [UIColor blackColor];
        sizeLabel.text = videoSize;
        [bgView addSubview:sizeLabel];
//        [sizeLabel release];
        UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(90.f, 55.0f, 80.f, 20.f)];
        hintLabel.backgroundColor = [UIColor clearColor];
        hintLabel.font = [UIFont systemFontOfSize:16.f];
        hintLabel.textColor = [UIColor colorWithRed:50.f / 255.f green:50.f / 255.f blue:50.f / 255.f alpha:1.0f];
        hintLabel.text = ASLocalizedString(@"KDImagePostPreviewView_check");
        [bgView addSubview:hintLabel];
//        [hintLabel release];
    }
    
    UIImageView *playImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoplay_s.png"]];
    playImage.frame = CGRectMake((imageView.frame.size.width - 33.0f) / 2., (imageView.frame.size.height - 33.0f) / 2., 33.0f, 33.0f);
    [imageView addSubview:playImage];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setImage:[UIImage imageNamed:@"video_delete.png"] forState:UIControlStateNormal];
    deleteBtn.frame =  CGRectMake(bgView.frame.size.width - 50.f - 10.f, (bgView.frame.size.height - 50.f) / 2.f, 50.0f, 50.0f);
    [deleteBtn addTarget:self action:@selector(deleteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:deleteBtn];
    
    //KD_RELEASE_SAFELY(bgView);
    
    if ([self.delegate respondsToSelector:@selector(videoThumbnailDidTapped)]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(videoThumbnailDidTapped)];
        tap.numberOfTapsRequired = 1;
        [clickView addGestureRecognizer:tap];
//        [tap release];
    }
    
//    [imageView release];
//    [playImage release];
//    [clickView release];
    [self setNeedsLayout];
}

- (void)setupView
{
    CGRect frame = self.frame;
    int count = (int)self.assetURLs.count;
    if(self.showAddedButton && count > 0) {
        count = count + 1;
    }
    
    frame.size.height = (kImageSize.height + kImageInset) * ((int)(count + 3) / 4);
    self.frame = frame;
    int index = 0;
    
    UIView *bgView = [self viewWithTag:kTempVideoBgTag];
    [bgView removeFromSuperview];
    
    for (UIView *temp in [self subviews]) {
        if ([temp isKindOfClass:[UIImageView class]]) {
            [temp removeFromSuperview];
        }
    }
    
    [self setAddButton];
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    
    for (NSString *url in _assetURLs) {
        
        [assetLibrary assetForURL:[NSURL URLWithString:url] resultBlock:^(ALAsset *asset)  {
            UIImage *image =[UIImage imageWithCGImage:asset.thumbnail];
            
            //            dispatch_async(dispatch_get_main_queue(), ^{
            
            CGRect rect = CGRectZero;
            rect.origin.x = (index % 4 + 1) * kImageInset + kImageSize.width * (index % 4);
            rect.origin.y = ((index + 4) / 4) * (kImageSize.height + kImageInset) - kImageSize.height;
            rect.size = kImageSize;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
            imageView.image = image;
            imageView.tag = kImageViewTagPre + index;
            [self addSubview:imageView];
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapped:)];
            tap.numberOfTapsRequired = 1;
            [imageView addGestureRecognizer:tap];
            
//            [tap release];
//            [imageView release];
            //            });
            
        }failureBlock:^(NSError *error) {
            NSLog(@"error=%@",error);
        }
         ];
        
        index ++;
    }
//    [assetLibrary release];
    [self setNeedsLayout];
}

- (void)didTapped:(UIGestureRecognizer *)recognizer
{
    UIView *view = recognizer.view;
    if ([self.delegate respondsToSelector:@selector(imagePostPreview:didTapAtIndex:)]) {
        [self.delegate imagePostPreview:self didTapAtIndex:view.tag - kImageViewTagPre];
    }
}

- (void)setAddButton
{
    UIButton *addButton = (UIButton *)[self viewWithTag:kAddButtonTag];
    if (!addButton) {
        addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.tag = kAddButtonTag;
        [addButton setImage:[UIImage imageNamed:@"gallery_add_photo.png"] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addButton];
    }
    int count = (int)self.assetURLs.count;
    addButton.frame = CGRectMake((count % 4) * (kImageSize.height + kImageInset) + kImageInset, self.frame.size.height - kImageSize.height, kImageSize.width, kImageSize.height);
    addButton.hidden = !self.showAddedButton;
}

- (void)addBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(imagePostPreview:didTapAddedButton:)]) {
        [self.delegate imagePostPreview:self didTapAddedButton:YES];
    }
}

- (void)deleteBtnClicked
{
    UIView *bgView = [self viewWithTag:kTempVideoBgTag];
    [bgView removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(deleteButtonClicked)]) {
        [self.delegate deleteButtonClicked];
    }
}

@end
