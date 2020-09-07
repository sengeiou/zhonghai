//
//  KDPhotoTileViewCell.h
//  kdweibo
//
//  Created by laijiandong on 12-5-27.
//  Copyright 2012 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "KDTileViewCell.h"
#import "DACircularProgressView.h"
typedef enum {
	KDTileViewCellImageTypeError = 0x00,
	KDTileViewCellImageTypeDefault = 0x01,
	KDTileViewCellImageTypePreview,
	KDTileViewCellImageTypeBlurPreview,
	KDTileViewCellImageTypeThumbnail	
}KDTileViewCellImageType;



@protocol KDPhotoTileViewCellDelegate;



@interface KDPhotoTileViewCell : KDTileViewCell {
@protected
//    id<KDPhotoTileViewCellDelegate> delegate_;
	
	id userInfo_;
	KDTileViewCellImageType imageType_;
	BOOL showProgress_;
}

@property(nonatomic, weak) id<KDPhotoTileViewCellDelegate> delegate;

@property(nonatomic, retain) id userInfo;
@property(nonatomic, readonly) KDTileViewCellImageType imageType;
@property(nonatomic, assign) BOOL showProgress;

- (void)displayImage:(UIImage *)image imageType:(KDTileViewCellImageType)imageType;

@end


@protocol KDPhotoTileViewCellDelegate <NSObject>

@optional

- (void)displayRealImageInPhotoTileViewCell:(KDPhotoTileViewCell *)cell;
- (void)didTapInPhotoTileViewCell:(KDPhotoTileViewCell *)cell;

@end


////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDPhotoPreviewTileViewCell class

@interface KDPhotoPreviewTileViewCell : KDPhotoTileViewCell <UIScrollViewDelegate> {
@private
	UIScrollView *scrollView_;
	UIImageView *imageView_;
    DACircularProgressView *progressView_;
    
    NSUInteger tapCount_;
}

@property(nonatomic, retain, readonly) DACircularProgressView *progressView;

- (void)displayWithClearImage:(UIImage *)image imageType:(KDTileViewCellImageType)imageType;
- (UIImage *)previewImage;

- (void)setProgressViewWithVisible:(BOOL)visible;

- (BOOL)isDisplayRealImage;

@end

