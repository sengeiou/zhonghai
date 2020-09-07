//
//  UIImage+Additions.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-23.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>


typedef enum {
	KDImageScaleTypeFit = 0x01,  // MIN(w, h) as minmual value, and another value greater than this value.
	KDImageScaleTypeFill         // MAX(w, h) as maxumal value, and another value less than this value.
}KDImageScaleType;


extern const float kKDJPEGThumbnailQuality;
extern const float kKDJPEGPreviewImageQuality;
extern const float kKDJPEGBlurPreviewImageQuality;


@interface UIImage (KD_Utility)

- (UIImage *) fastCropToSize:(CGSize)size;
- (UIImage *) fastCropToSize:(CGSize)size type:(KDImageScaleType)type;

- (UIImage *) generateThumbnailWithSize:(CGSize)size;
- (UIImage *) generatePreviewImageWithSize:(CGSize)size;
- (UIImage *) generateBlurPreviewImageWithSize:(CGSize)size;

- (NSData *) asJPEGDataWithQuality:(float)quality;

- (UIImage *) maskWithImage:(UIImage *)maskImage;

- (UIImage *) scaleToSize:(CGSize)newSize type:(KDImageScaleType)type;

- (UIImage *)imageAtRect:(CGRect)rect;

//返回 size 为 800X600 的image
+ (UIImage *)normalizedLocalImage:(UIImage *)image;


// get stretchableImageByName
+ (UIImage *)stretchableImageWithImageName:(NSString *)imageName
                             leftCapWidth:(NSInteger)leftCapWidth
                             topCapHeight:(NSInteger)topCapHeight;

+ (UIImage *)stretchableImageWithImageName:(NSString *)imageName resizableImageWithCapInsets:(UIEdgeInsets)insets;

+ (UIImage *) imageByFileEntension:(NSString *)fileName isBig:(BOOL)isBig;

+(UIImage *)rotateImage:(UIImage *)aImage;
+ (UIImage *)imageWithColor:(UIColor *)color;
@end
