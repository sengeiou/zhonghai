//
//  UIImage+Additions.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-23.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "UIImage+Additions.h"

const float kKDJPEGThumbnailQuality         = 0.75; // thumbnail quality as JPEG format
const float kKDJPEGPreviewImageQuality      = 1.0; // preview image quality as JPEG format
const float kKDJPEGBlurPreviewImageQuality  = 0.0; // blur preview image quality as JPEG format

@implementation UIImage (KD_Utility)

- (UIImage *) fastCropToSize:(CGSize)size {
    return [self fastCropToSize:size type:KDImageScaleTypeFill];
}

- (UIImage *) fastCropToSize:(CGSize)size type:(KDImageScaleType)type {
    if(self == nil) return nil;
    return [self scaleToSize:size type:type];
}

- (UIImage *) generateThumbnailWithSize:(CGSize)size {
    return [self fastCropToSize:size];
}

- (UIImage *) generatePreviewImageWithSize:(CGSize)size {
    return [self fastCropToSize:size];
}

- (UIImage *) generateBlurPreviewImageWithSize:(CGSize)size {
    return [self fastCropToSize:size];
}

- (NSData *) asJPEGDataWithQuality:(float)quality {
    if(self == nil) return nil;
    
    if(quality < 0.0) {
        quality = 0.0;
    }
    
    if(quality > 1.0) {
        quality = 1.0; 
    }
    
    return UIImageJPEGRepresentation(self, quality);
}

- (UIImage *) scaleToSize:(CGSize)newSize type:(KDImageScaleType)type {
    ///add by shenkuikui 2013年04月02日18:57:58
    //@begin
    if(newSize.width == MAXFLOAT && newSize.height == MAXFLOAT) {
        return self;
    }
    //@end
    
	CGFloat width, height;
	CGSize imageSize = self.size;
	CGFloat factor = 0.0;
	
	CGSize finalSize = CGSizeZero;
	if(imageSize.width > imageSize.height+0.01){
		finalSize = CGSizeMake(MAX(newSize.width, newSize.height), MIN(newSize.width, newSize.height));
	}else {
		finalSize = CGSizeMake(MIN(newSize.width, newSize.height), MAX(newSize.width, newSize.height));
	}
	
	if(KDImageScaleTypeFit == type) {
		if(imageSize.width+0.01<imageSize.height){
			width = MIN(imageSize.width, finalSize.width);
			height = width/imageSize.width*imageSize.height;
			
		}else {
			height = MIN(imageSize.height, finalSize.height);
			width = height/imageSize.height*imageSize.width;
		}
		
	}else{
		if(imageSize.width > finalSize.width+0.01 || imageSize.height > finalSize.height+0.01){
			
			if(imageSize.width > imageSize.height){
				factor = finalSize.width/imageSize.width;
				width = finalSize.width;
				height = factor*imageSize.height;
				
			}else {
				factor = finalSize.height/imageSize.height;
				height = finalSize.height;
				width = factor*imageSize.width;
			}
			
		}else {
			width = imageSize.width;
			height = imageSize.height;
		}
	}
	
	finalSize = CGSizeMake(floorf(width), floorf(height));
    
    if (CGSizeEqualToSize(finalSize, self.size)) {
        return self;
    }
	
	UIGraphicsBeginImageContext(finalSize);
	
	[self drawInRect:CGRectMake(0.0, 0.0, finalSize.width, finalSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return newImage;
}

//返回 size 为 800X600 的image
+ (UIImage *)normalizedLocalImage:(UIImage *)image {
    UIImage *finalImage = image;
    CGSize previewSize = CGSizeMake(800.0f, 600.0f);
    if(image.size.width > previewSize.width || image.size.height > previewSize.height){
        finalImage = [image scaleToSize:previewSize type:KDImageScaleTypeFill];
    }
    return finalImage;
 
}

- (UIImage *) maskWithImage:(UIImage *)maskImage {
    if(self == nil){
        return nil;
    }
    
    if(maskImage == nil){
        return self;
    }
        
    CGRect rect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    [self drawInRect:rect];
    [maskImage drawInRect:rect];
    
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return maskedImage;
}


+(UIImage *)stretchableImageWithImageName:(NSString *)imageName
                             leftCapWidth:(NSInteger)leftCapWidth
                             topCapHeight:(NSInteger)topCapHeight
{
    if(imageName == nil)
        return nil;
    UIImage * imageByName = [UIImage imageNamed:imageName];
    if (imageByName == nil) {
        return nil;
    }
     UIImage * stretchableImage  = [imageByName stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    return stretchableImage;
}


+ (UIImage *)stretchableImageWithImageName:(NSString *)imageName resizableImageWithCapInsets:(UIEdgeInsets)insets {
    if(imageName == nil)
        return nil;
    UIImage * imageByName = [UIImage imageNamed:imageName];
    if (imageByName == nil) {
        return nil;
    }
    if ([imageByName respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        imageByName = [imageByName resizableImageWithCapInsets:insets];
    }else {
        imageByName = [imageByName stretchableImageWithLeftCapWidth:insets.left topCapHeight:insets.top];
    }
    return imageByName;
}

-(UIImage *)imageAtRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    return subImage;
}

+ (UIImage*) imageByFileEntension:(NSString *)fileName isBig:(BOOL)isBig {
    //pdf,doc,docx,xls,xlsx,ppt,pptx,txt
    NSString *extension = [[fileName pathExtension] lowercaseString];
    NSString *iconName = @"doc";
  
    if ([extension isEqualToString:@"doc"]||
        [extension isEqualToString:@"docx"]) {
        iconName = @"word";
    }
    else  if ([extension isEqualToString:@"xls"]||
        [extension isEqualToString:@"xlsx"]) {
        iconName = @"excel";
    }
    else if ([extension isEqualToString:@"ppt"]||
        [extension isEqualToString:@"pptx"]) {
        iconName = @"ppt";
    }
    else if ([extension isEqualToString:@"pdf"]) {
        iconName = @"pdf";
    }
    else  if ([extension isEqualToString:@"rar"]||
        [extension isEqualToString:@"zip"]) {
        iconName = @"zip";
    }
    else if ([extension isEqualToString:@"txt"]) {
        iconName = @"txt";
    }
    
    if (isBig) {
        iconName = [iconName stringByAppendingString:@"_big"];
    }
    return [self imageNamed:iconName];
}

+(UIImage *)rotateImage:(UIImage *)aImage
{
    CGImageRef imgRef = aImage.CGImage;
    UIImageOrientation orient = aImage.imageOrientation;
    UIImageOrientation newOrient = UIImageOrientationUp;
    switch (orient) {
        case 3://竖拍 home键在下
            newOrient = UIImageOrientationRight;
            break;
        case 2://倒拍 home键在上
            newOrient = UIImageOrientationLeft;
            break;
        case 0://左拍 home键在右
            newOrient = UIImageOrientationUp;
            break;
        case 1://右拍 home键在左
            newOrient = UIImageOrientationDown;
            break;
        default:
            newOrient = UIImageOrientationRight;
            break;
    }
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGFloat ratio = 0;
    if ((width > 1024) || (height > 1024)) {
        if (width >= height) {
            ratio = 1024/width;
        }
        else {
            ratio = 1024/height;
        }
        width *= ratio;
        height *= ratio;
    }
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = 1;
    CGFloat boundHeight;
    switch(newOrient)
    {
        case UIImageOrientationUp:
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
            
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (newOrient == UIImageOrientationRight || newOrient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end


