//
//  KDIrregularImageView.m
//  kdweibo
//
//  Created by shen kuikui on 12-12-27.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDIrregularImageView.h"

@implementation KDIrregularImageView

@synthesize image = image_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat height = self.bounds.size.height;
    
    CGContextTranslateCTM(context, 0.0f, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);

    CGContextSaveGState(context);
    
    if(maskImage_)
        CGContextClipToMask(context, maskImageFrame_, maskImage_);
    
    if(image_)
        CGContextDrawImage(context, self.bounds, image_.CGImage);
    
    CGContextRestoreGState(context);
}

- (void)setImage:(UIImage *)image {
//    [image retain];
//    [image_ release];
    image_ = image;
    
    [self setNeedsDisplay];
}

- (void)setMaskImage:(UIImage *)maskImage {
//    NSMutableData *data = [NSMutableData dataWithLength:maskImage.size.width * maskImage.size.height * 1];
//    
//    CGContextRef context = CGBitmapContextCreate([data mutableBytes], maskImage.size.width, maskImage.size.height, 8, maskImage.size.width, NULL, kCGImageAlphaOnly);
//    CGContextSetBlendMode(context, kCGBlendModeCopy);
//    
//    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, maskImage.size.width, maskImage.size.height), maskImage.CGImage);
//    CGContextRelease(context);
//    
//    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
//    
//    maskImage_ = CGImageMaskCreate(maskImage.size.width, maskImage.size.height, 8, 8, maskImage.size.width, dataProvider, NULL, YES);
    if(maskImage_) {
        CGImageRelease(maskImage_);
    }
    
    maskImage_ = CGImageRetain(maskImage.CGImage);
    
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    
    maskImageFrame_ = CGRectMake((width - maskImage.size.width) * 0.5f, (height - maskImage.size.height) * 0.5f, maskImage.size.width, maskImage.size.height);
}

- (void)dealloc {
//    if(maskImage_) CGImageRelease(maskImage_);
//    if  (image_) [image_ release];
    
    //[super dealloc];
}


@end
