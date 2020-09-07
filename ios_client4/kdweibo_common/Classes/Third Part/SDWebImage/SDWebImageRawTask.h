//
//  SDWebImageRawTask.h
//  kdweibo_common
//
//  Created by bird on 14-5-14.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"
#import "SDWebImageScale.h"

@interface SDWebImageRawTask : NSObject

typedef void(^SDWebImageRawCompletedBlock)(UIImage *image);

+ (SDWebImageRawTask *)shareRawTask;

- (void)rawImage:(UIImage *)image scale:(SDWebImageScaleOptions)scale done:(SDWebImageRawCompletedBlock)block;
@end
