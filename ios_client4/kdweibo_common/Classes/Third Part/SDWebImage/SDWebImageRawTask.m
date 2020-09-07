//
//  SDWebImageRawTask.m
//  kdweibo_common
//
//  Created by bird on 14-5-14.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "SDWebImageRawTask.h"
#import "UIImage+Additions.h"

@interface SDWebImageRawTask()
@property (SDDispatchQueueSetterSementics, nonatomic) dispatch_queue_t ioQueue;
@end

@implementation SDWebImageRawTask
+ (SDWebImageRawTask *)shareRawTask
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}


- (id)init {
    if ((self = [super init])) {
        // Create IO serial queue
        _ioQueue = dispatch_queue_create("com.hackemist.SDWebImageRaw", DISPATCH_QUEUE_SERIAL);
        
    }
    
    return self;
}
- (void)dealloc
{
    SDDispatchQueueRelease(_ioQueue);
}
- (void)rawImage:(UIImage *)image scale:(SDWebImageScaleOptions)scale done:(SDWebImageRawCompletedBlock)block
{
    if (scale == SDWebImageScaleNone) {
        if (block)
            block(image);
        
        return;
    }
    
    dispatch_async(self.ioQueue, ^{
    
        @autoreleasepool {
            UIImage *generatedImage = [image generateThumbnailWithSize:[SDWebImageScale sizeForScaleOption:scale]];
       
            dispatch_async(dispatch_get_main_queue(), ^{
                block(generatedImage);
            });
        }
    });
}
@end
