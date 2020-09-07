//
//  KDImageOptimizationTask.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-15.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDImageOptimizationTask.h"
#import "KDRequestWrapper.h"
#import "NSString+Additions.h"

NSString * const kKDImageOptimizationTaskCropedImage = @"image";

@implementation KDImageOptimizationTask

@synthesize delegate=delegate_;

@synthesize imagePath=imagePath_;
@synthesize image=image_;
@synthesize data=data_;

@synthesize optimizationType=optimizationType_;
@synthesize imageSize=imageSize_;
@synthesize priority=priority_;

@dynamic cacheKey;

@synthesize completionBlock=completionBlock_;

@synthesize userInfo=userInfo_;

- (id) init {
    self = [super init];
    if(self){
        delegate_ = nil;
        
        imagePath_ = nil;
        image_ = nil;
        
        optimizationType_ = KDImageOptimizationTypeNormal;
        imageSize_ = nil;
        priority_ = KDImageOptimizationPriorityNormal;
        
        cacheKey_ = nil;
        
        completionBlock_ = nil;
        
        userInfo_ = nil;
    }
    
    return self;
}

- (id) initWithDelegate:(id<KDImageOptimizationTaskDelegate>)delegate imagePath:(NSString *)imagePath imageSize:(KDImageSize *)imageSize userInfo:(id)userInfo {
    self = [self init];
    if(self){
        delegate_ = delegate;
        
        imagePath_ = imagePath;// retain];
        imageSize_ = imageSize;// retain];
        userInfo_ =userInfo;// retain];
    }
    
    return self;
}

- (id) initWithDelegate:(id<KDImageOptimizationTaskDelegate>)delegate image:(UIImage *)image imageSize:(KDImageSize *)imageSize userInfo:(id)userInfo {
    self = [self init];
    if(self){
        delegate_ = delegate;
        
        image_ = image;// retain];
        imageSize_ = imageSize;// retain];
        userInfo_ = userInfo ;//retain];
    }
    
    return self;
}
- (id) initWithDelegate:(id<KDImageOptimizationTaskDelegate>)delegate
                    gif:(NSData *)data
              imageSize:(KDImageSize *)imageSize
               userInfo:(id)userInfo;
{
    if ([self init]) {
        delegate_ = delegate;
        data_ = data;// retain];
        imageSize_ = imageSize;// retain];
                      userInfo_ = userInfo ;//retain];
        optimizationType_ = KDImageOptimizationTypeGif;
    }
    return self;
}
- (UIImage *) getRawImage {
    if(image_ != nil){
        return image_;
    }
    
    if(imagePath_ != nil){
        return [UIImage imageWithContentsOfFile:imagePath_];
    }
    if (data_) {
        return [UIImage imageWithData:data_];
    }
    
    return nil;
}
- (NSData *) getGifData
{
    if (data_)
        return data_;
    if (imagePath_) {
        return [NSData dataWithContentsOfFile:imagePath_];
    }
    return nil;
}
- (NSString *) cacheKey {
    if(cacheKey_ == nil){
        NSString *key = nil;
        if(image_ != nil){
            key = [NSString stringWithFormat:@"%lu", (unsigned long)[image_ hash]];
        
        }else if(imagePath_ !=nil) {
            key = [imagePath_ MD5DigestKey];
        }
        else
        {
            if ([userInfo_ isKindOfClass:[KDRequestWrapper class]]) {
                NSString *url = ((KDRequestWrapper *)userInfo_).url;
                key = [url MD5DigestKey];
            }
            else
                key = [NSString stringWithFormat:@"%ld", time(NULL)];
        }
        cacheKey_ = key;// retain];
    }
    return cacheKey_;
}

- (void) releaseBlocksOnMainThread {
    NSArray *blocks = nil;
    if(completionBlock_ != nil){
        blocks = [NSArray arrayWithObject:completionBlock_];
        
//        [completionBlock_ release];
        completionBlock_ = nil;
    }
    
    if(blocks != nil && [blocks count] > 0){
        [[self class] performSelectorOnMainThread:@selector(releaseBlocks:) withObject:blocks waitUntilDone:[NSThread isMainThread]];
    }
}

+ (void) releaseBlocks:(NSArray *)blocks {
    // Do nothing, when this method did finished, The blocks will auto release
}

- (void) dealloc {
    delegate_ = nil;
    
    [self releaseBlocksOnMainThread];
    
    //KD_RELEASE_SAFELY(data_);
    //KD_RELEASE_SAFELY(imagePath_);
    //KD_RELEASE_SAFELY(image_);
    
    //KD_RELEASE_SAFELY(imageSize_);
    
    //KD_RELEASE_SAFELY(cacheKey_);
    //KD_RELEASE_SAFELY(userInfo_);
    
    //[super dealloc];
}

@end
