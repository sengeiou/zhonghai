//
//  KDThumbnailView3.h
//  kdweibo
//
//  Created by Tan Yingqi on 14-1-13.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDImageSourceProtocol.h"

#import "KDWeiboServicesContext.h"
#import "KDStatus.h"

@class KDThumbnailView3;
@protocol KDThumbnailViewDelegate3 <NSObject>
@optional

- (void)thumbnailView:(KDThumbnailView3 *)thumbnailView didLoadThumbnail:(UIImage *)thumbnail;
- (void)thumbnailView:(KDThumbnailView3 *)thumbnailView didLoadThumbnailFromDisk:(UIImage *)thumbnail;
- (void)didTapOnThumbnailView:(KDThumbnailView3 *)thumbnailView userInfo:(id)userInfo;

@end


@class KDThumbnailGridView3;

@interface KDThumbnailView3 : UIButton {

@private
//    id<KDThumbnailViewDelegate3> delegate_;
    id<KDImageDataSource> imageDataSource_;
    KDImageSize *thumbnailSize_;

    KDThumbnailGridView3 *thumbnailView_;
    UILabel *infoLabel_;
    UIActivityIndicatorView *activityView_;

    BOOL hasThumbnail_;
    BOOL loadThumbnail_;
}

@property (nonatomic, assign) id<KDThumbnailViewDelegate3> delegate;
@property (nonatomic, retain) id<KDImageDataSource> imageDataSource;
@property (nonatomic, retain) KDImageSize *thumbnailSize;

@property (nonatomic, retain, readonly) KDThumbnailGridView3 *thumbnailView;

@property (nonatomic, assign, readonly) BOOL hasThumbnail;
@property (nonatomic, assign) BOOL  loadThumbnail;
@property (nonatomic, assign, readonly) BOOL hasVideo;
@property (nonatomic, retain) KDStatus *status;


+ (id) thumbnailViewWithSize:(KDImageSize *)size;

+ (id) thumbnailViewWithStatus:(KDStatus *)status;



// sub-classes override it if need

//- (void)setImageDataSourceWithNoLoading:(id<KDImageDataSource>)imageDataSource;
//- (void)setImageDataSource:(id<KDImageDataSource>)imageDataSource withType:(KDCacheImageType)type;
+ (CGSize)thumbnailSizeWithImageDataSource:(id<KDImageDataSource>)imageDataSource;
+ (CGSize)thumbnailSizeWithImageDataSource:(id<KDImageDataSource>)imageDataSource showAll:(BOOL) showAll;
+ (CGSize)defaultMinimalThumbnailSize;
+(CGSize)thumbnailDefaultSize;

@end


