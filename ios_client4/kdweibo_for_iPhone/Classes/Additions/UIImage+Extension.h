//
//  UIImage+Extension.h
//  kdweibo
//
//  Created by gordon_wu on 14-4-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LBBlurredImageCompletionBlock)(UIImage *image,NSError *error);

extern NSString *const kLBBlurredImageErrorDomain;

extern CGFloat   const kLBBlurredImageDefaultBlurRadius;

enum LBBlurredImageError {
    LBBlurredImageErrorFilterNotAvailable = 0,
};




@interface UIImage (Extension)

+ (UIImage *)capture:(UIView *) view;

+ (void)setImageToBlur: (UIImage *)image
            blurRadius: (CGFloat)blurRadius
       completionBlock: (LBBlurredImageCompletionBlock) completion;

@end
