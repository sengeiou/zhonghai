//
//  KDThumbnailView2.h
//  kdweibo
//
//  Created by 王 松 on 13-7-2.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>

#import "KDImageSourceProtocol.h"

#import "KDWeiboServicesContext.h"


@protocol KDThumbnailViewDelegate2;

@class KDThumbnailGridView;

@interface KDThumbnailView2 : UIButton {
@private
//    id<KDThumbnailViewDelegate2> delegate_;
//    id<KDImageDataSource> imageDataSource_;
    KDImageSize *thumbnailSize_;
    
    KDThumbnailGridView *thumbnailView_;
    UILabel *infoLabel_;
    UIActivityIndicatorView *activityView_;
    
    BOOL hasThumbnail_;
    BOOL loadThumbnail_;
}

@property (nonatomic, assign) id<KDThumbnailViewDelegate2> delegate;
@property (nonatomic, retain) id<KDImageDataSource> imageDataSource;
@property (nonatomic, retain) KDImageSize *thumbnailSize;

@property (nonatomic, retain, readonly) KDThumbnailGridView *thumbnailView;

@property (nonatomic, assign, readonly) BOOL hasThumbnail;
@property (nonatomic, assign) BOOL loadThumbnail;
@property (nonatomic, assign, readonly) BOOL hasVideo;
@property (nonatomic, retain) KDStatus *status;


+ (id) thumbnailViewWithSize:(KDImageSize *)size;

+ (id) thumbnailViewWithStatus:(KDStatus *)status;


- (void)loadThumbnailFromDisk;

// sub-classes override it if need
- (KDCacheImageType) cacheImageType;
- (UIImage *)defaultThumbnail;

- (void)setImageDataSourceWithNoLoading:(id<KDImageDataSource>)imageDataSource;
- (void)setImageDataSource:(id<KDImageDataSource>)imageDataSource withType:(SDWebImageScaleOptions)type;
+ (CGSize)thumbnailSizeWithImageDataSource:(id<KDImageDataSource>)imageDataSource;
+ (CGSize)thumbnailSizeWithImageDataSource:(id<KDImageDataSource>)imageDataSource showAll:(BOOL) showAll;
+ (CGSize)defaultMinimalThumbnailSize;
+(CGSize)thumbnailDefaultSize;

@end


@protocol KDThumbnailViewDelegate2 <NSObject>
@optional

- (void)thumbnailView:(KDThumbnailView2 *)thumbnailView didLoadThumbnail:(UIImage *)thumbnail;
- (void)thumbnailView:(KDThumbnailView2 *)thumbnailView didLoadThumbnailFromDisk:(UIImage *)thumbnail;
- (void)didTapOnThumbnailView:(KDThumbnailView2 *)thumbnailView userInfo:(id)userInfo;

@end