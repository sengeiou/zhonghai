//
//  KDThumbnailView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-29.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDImageSourceProtocol.h"

#import "KDWeiboServicesContext.h"

@protocol KDThumbnailViewDelegate;


@interface KDThumbnailView : UIButton <KDImageSourceLoader> {
@private
//    id<KDThumbnailViewDelegate> delegate_;
//    id<KDImageDataSource> imageDataSource_;
    KDImageSize *thumbnailSize_;
    
    UIImageView *thumbnailView_;
    UILabel *infoLabel_;
    UIActivityIndicatorView *activityView_;
    
    BOOL hasThumbnail_;
    BOOL loadThumbnail_;
}

@property (nonatomic, assign) id<KDThumbnailViewDelegate> delegate;
@property (nonatomic, retain) id<KDImageDataSource> imageDataSource;
@property (nonatomic, retain) KDImageSize *thumbnailSize;

@property (nonatomic, retain, readonly) UIImageView *thumbnailView;

@property (nonatomic, assign, readonly) BOOL hasThumbnail;
@property (nonatomic, assign) BOOL loadThumbnail;
@property (nonatomic, retain) KDStatus *status;


+ (id) thumbnailViewWithSize:(KDImageSize *)size;

- (void)loadThumbnailFromDisk;

// sub-classes override it if need
- (SDWebImageScaleOptions)cacheImageType;
- (UIImage *)defaultThumbnail;
- (BOOL)hasVideo;

- (void)setImageDataSourceWithNoLoading:(id<KDImageDataSource>)imageDataSource;

+ (CGSize)thumbnailSizeWithImageDataSource:(id<KDImageDataSource>)imageDataSource;
+ (CGSize)defaultMinimalThumbnailSize;
+(CGSize)thumbnailDefaultSize;

@end


@protocol KDThumbnailViewDelegate <NSObject>
@optional

- (void)thumbnailView:(KDThumbnailView *)thumbnailView didLoadThumbnail:(UIImage *)thumbnail;
- (void)thumbnailView:(KDThumbnailView *)thumbnailView didLoadThumbnailFromDisk:(UIImage *)thumbnail;
- (void)didTapOnThumbnailView:(KDThumbnailView *)thumbnailView userInfo:(id)userInfo;

@end

