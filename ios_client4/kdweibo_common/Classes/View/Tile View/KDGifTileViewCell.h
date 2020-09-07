//
//  KDGifTileViewCell.h
//  kdweibo_common
//
//  Created by bird on 13-8-27.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDTileViewCell.h"
#import "DACircularProgressView.h"
typedef enum {
	KDGifViewCellImageTypeError = 0x00,
	KDGifViewCellImageTypeDefault = 0x01,
	KDGifViewCellImageTypePreview,
	KDGifViewCellImageTypeBlurPreview,
	KDGifViewCellImageTypeThumbnail
}KDGifViewCellImageType;

@protocol KDGifTileViewCellDelegate;

@interface KDGifTileViewCell : KDTileViewCell
{
    UIWebView   *webView_;
    
    DACircularProgressView *progressView_;
    NSUInteger tapCount_;
    
    BOOL showProgress_;
    
//    id<KDGifTileViewCellDelegate> delegate_;
    
    KDGifViewCellImageType imageType_;
    
    id userInfo_;
    NSString *jsIntervalID_;
}
@property(nonatomic, assign) id<KDGifTileViewCellDelegate> delegate;
@property(nonatomic, retain, readonly) DACircularProgressView *progressView;
@property(nonatomic, assign) BOOL showProgress;
@property(nonatomic, readonly) KDGifViewCellImageType imageType;
@property(nonatomic, retain) id userInfo;

- (void)startGif;
- (void)stopGif;
- (void)loadImageData:(NSData *)data imageType:(KDGifViewCellImageType)imageType;
- (void)setProgressViewWithVisible:(BOOL)visible;
- (BOOL)isDisplayGifImage;
@end

@protocol KDGifTileViewCellDelegate <NSObject>
- (void)didTapInGifTileViewCell:(KDGifTileViewCell *)cell;
- (void)didDisplayGifImageInGifTileViewCell:(KDGifTileViewCell *)cell;
@end