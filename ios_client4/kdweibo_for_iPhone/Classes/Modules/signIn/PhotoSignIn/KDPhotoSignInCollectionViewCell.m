//
//  KDPhotoSignInCollectionViewCell.m
//  kdweibo
//
//  Created by lichao_liu on 15/3/16.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPhotoSignInCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
 
@interface KDPhotoSignInImageView : UIImageView
@property (nonatomic, strong) KDImageSource *imageSource;
@property (nonatomic, assign) id<PhotoSignInCollectionViewCellDelegate> cellDelegate;
@property (nonatomic, assign) NSInteger sourceIndex;
@end

@implementation KDPhotoSignInImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.layer.cornerRadius = 3;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
//        self.contentMode = UIViewContentModeCenter;
        self.clipsToBounds = YES;
//        self.contentMode = UIViewContentModeScaleAspectFit;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenImageViewClicked:)];
        [self addGestureRecognizer:tapGesture];
     }
    return self;
}

- (void)whenImageViewClicked:(id)sender
{
    if(self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(whenImageViewClickedWithSource:atIndex:)])
    {
        [self.cellDelegate whenImageViewClickedWithSource:self.imageSource atIndex:self.sourceIndex];
    }
}

- (void)setImageSource:(KDImageSource *)imageSource
{
    _imageSource = imageSource;
    [self loadThumbnail];
}


- (void)loadThumbnail
{
    NSURL *ImgUrl = [NSURL URLWithString:_imageSource.original];
    __weak KDPhotoSignInImageView *weakImageViewSelf = self;
        [self setImageWithURL:ImgUrl placeholderImage:[UIImage imageNamed:@"Cell_Thumbnail_Left"] scale:SDWebImageScalePreView options:SDWebImageLowPriority | SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType){
           if(image && image!= nil)
           {
               weakImageViewSelf.image = image;
           }
        }];
}

@end

@interface KDPhotoSignInCollectionViewCell()
@property (nonatomic, strong)KDPhotoSignInImageView *phtoSignInImageView;

@end

@implementation KDPhotoSignInCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.phtoSignInImageView = [[KDPhotoSignInImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        [self.contentView addSubview:self.phtoSignInImageView];

        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setCacheIndex:(NSInteger)cacheIndex
{
    _cacheIndex = cacheIndex;
    self.phtoSignInImageView.sourceIndex = cacheIndex;
}
- (void)setImageSouce:(KDImageSource *)imageSouce
{
    _imageSouce = imageSouce;
    self.phtoSignInImageView.imageSource = imageSouce;
}

- (void)setCacheImageUrl:(NSString *)cacheImageUrl
{
    _cacheImageUrl = cacheImageUrl;
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:cacheImageUrl];
    
    if(data)
    self.phtoSignInImageView.image  =  [UIImage imageWithData:data];
    else {
        self.phtoSignInImageView.image = [UIImage imageNamed:@"Cell_Thumbnail_Left"];
    }
}


- (void)setCellDelegate:(id<PhotoSignInCollectionViewCellDelegate>)cellDelegate
{
    _cellDelegate = cellDelegate;
    self.phtoSignInImageView.cellDelegate = cellDelegate;
}
@end
