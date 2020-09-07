//
//  KDPickedImage.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-2.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDPickedImage.h"

#import "KDUtility.h"

#import "NSString+Additions.h"
#import "UIImage+Additions.h"

@interface KDPickedImage ()

@property (nonatomic, retain) UIImage *thumbnail;

@end


@implementation KDPickedImage

@synthesize delegate=delegate_;

@synthesize pickedImage=pickedImage_;
@synthesize thumbnail=thumbnail_;

@synthesize cachePath=cachePath_;
@synthesize thumbnailPath=thumbnailPath_;

@synthesize optimalSize=optimalSize_;
@synthesize thumbnailSize=thumbnailSize_;

@synthesize generateThumbnail=generateThumbnail_;
@synthesize highResolutionEnable=highResolutionEnable_;
@synthesize diskCacheEnable=diskCacheEnable_;

- (id) init {
    self = [super init];
    if(self){
        delegate_ = nil;
        
        pickedImage_ = nil;
        thumbnail_ = nil;
        
        cachePath_ = nil;
        thumbnailPath_ = nil;
        
        optimalSize_ = nil;
        thumbnailSize_ = nil;
        
        generateThumbnail_ = YES;
        highResolutionEnable_ = YES;
        diskCacheEnable_ = YES;
    }
    
    return self;
}

- (id) initWithImage:(UIImage *)pickedImage {
    self = [self init];
    if(self){
        self.pickedImage = pickedImage;
    }
    
    return self;
}

- (NSString *) cachePath:(BOOL)usingDefault {
    static NSUInteger guardIndex = 0;
    
    if(cachePath_ == nil && usingDefault){
        NSString *path = [[KDUtility defaultUtility] searchDirectory:KDApplicationTemporaryDirectory 
                                                        inDomainMask:KDTemporaryDomainMask needCreate:YES];
        
        // generate an unique temporary filename at temporary directory
        NSString *filename = [NSString stringWithFormat:@"%ld_%@_%lu", time(NULL), [NSString randomStringWithWide:0x03], (unsigned long)guardIndex++];
        
        self.cachePath = [path stringByAppendingPathComponent:filename];
    }
    
    return cachePath_;
}

- (UIImage *) thumbnail {
    if(thumbnail_ == nil){
        if(thumbnailSize_ != nil && (pickedImage_.size.width < thumbnailSize_.width 
                                     || pickedImage_.size.height < thumbnailSize_.height)){
            self.thumbnail = [[KDUtility defaultUtility] isHighResolutionDevice] ? [UIImage imageWithCGImage:pickedImage_.CGImage scale:[UIScreen mainScreen].scale orientation:pickedImage_.imageOrientation] : pickedImage_;
        }
    }
    
    return thumbnail_;
}

- (NSString *) thumbnailPath {
    if(thumbnailPath_ == nil){
        NSString *path = [self cachePath:YES]; 
        self.thumbnailPath = [path stringByAppendingString:@"_thumbnail"];
    }
    
    return thumbnailPath_;
}

- (void) optimal {
    if(pickedImage_ != nil && optimalSize_ != nil){
        KDImageOptimizationTask *task = [[KDImageOptimizationTask alloc] initWithDelegate:self image:pickedImage_ imageSize:optimalSize_ userInfo:nil];
        
        task.completionBlock = ^(KDImageOptimizationTask *task, UIImage *generatedImage) {
            self.pickedImage = generatedImage;
            
            if(generatedImage != nil && generateThumbnail_ && thumbnailSize_ != nil){
                if(generatedImage.size.width > thumbnailSize_.width 
                   || generatedImage.size.height > thumbnailSize_.height){
                
                    UIImage *image = [generatedImage fastCropToSize:thumbnailSize_.size];
                    if(image != nil) {
                        // If current device is high resolution device, make sure to create high resolution image
                        
                        self.thumbnail = [[KDUtility defaultUtility] isHighResolutionDevice] ? [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:image.imageOrientation] : image;
                    }
                }
            }
        };
        
        [[KDImageOptimizer sharedImageOptimizer] addTask:task];
//        [task release];
    }
}

- (void) store {
    if(diskCacheEnable_ && pickedImage_ != nil){
        NSString *path = [self cachePath:YES];
        NSData *data = [pickedImage_ asJPEGDataWithQuality:kKDJPEGPreviewImageQuality];
        if(data != nil){
            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        }
    }
}

- (void) remove {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if(thumbnailPath_ != nil){
        if([fm fileExistsAtPath:thumbnailPath_]){
            [fm removeItemAtPath:thumbnailPath_ error:NULL];
        }
    }
    
    if(cachePath_ != nil){
        if([fm fileExistsAtPath:cachePath_]){
            [fm removeItemAtPath:cachePath_ error:NULL];
        }
    }
}

- (void) notify {
    if(delegate_ != nil && [delegate_ respondsToSelector:@selector(didFinishOptimalPickedImage:)]){
        [delegate_ didFinishOptimalPickedImage:self];
    }
}

/////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDImageOptimizationTask delegate method

- (void) willDropImageOptimizationTask:(KDImageOptimizationTask *)task {
    [self notify];
}

- (void) imageOptimizationTask:(KDImageOptimizationTask *)task didFinishedOptimizedImageWithInfo:(NSDictionary *)info {
    [self notify];
}

- (void) dealloc {
    delegate_ = nil;
    
    [self remove];
    
    //KD_RELEASE_SAFELY(pickedImage_);
    //KD_RELEASE_SAFELY(thumbnail_);
    
    //KD_RELEASE_SAFELY(cachePath_);
    //KD_RELEASE_SAFELY(thumbnailPath_);
    
    //KD_RELEASE_SAFELY(optimalSize_);
    //KD_RELEASE_SAFELY(thumbnailSize_);
    
    //[super dealloc];
}

@end
