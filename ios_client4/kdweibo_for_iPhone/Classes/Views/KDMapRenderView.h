//
//  KDMapRenderView.h
//  kdweibo
//
//  Created by Tan yingqi on 13-3-11.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDImageSourceProtocol.h"

@protocol KDMapRenderViewDelegate;
@interface KDMapRenderView : UIView {
@private
//    id<KDMapRenderViewDelegate> delegate_;
    id<KDImageDataSource> imageDataSource_;
    KDImageSize *mapRenderViewSize_;    
    UIImageView *imageView_;
}

@property (nonatomic, assign) id<KDMapRenderViewDelegate> delegate;
@property (nonatomic, retain) id<KDImageDataSource> imageDataSource;
@property (nonatomic, retain) KDImageSize *mapRenderViewSize;

@property (nonatomic, retain, readonly) UIImageView *imageView;

- (SDWebImageScaleOptions) cacheImageType;
@end


@protocol KDMapRenderViewDelegate <NSObject>
@optional

- (void)mapRenderView:(KDMapRenderView *)view  didLoadImage:(UIImage *)image;
- (void)didTapOnMapRenderView:(KDMapRenderView *)thumbnailView userInfo:(id)userInfo;

@end