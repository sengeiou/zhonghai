//
//  KDImageUploadTask.m
//  kdweibo
//
//  Created by Tan yingqi on 13-5-17.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDImageUploadTask.h"
//#import "KDUpload.h"
#import "KDImageSource.h"
#import "KDImageItem.h"
#import "KDUtility.h"

#import "NSString+Additions.h"
#import "NSDate+Additions.h"
#import "UIImage+Additions.h"

#import "KDCache.h"
#import "KDConfigurationContext.h"

@implementation KDImageUploadTask
@synthesize imageSource = imageSource_;

+ (KDImageUploadTask *)imageUploadTaskWithImageSource:(KDImageSource *)imageSource {
    KDImageUploadTask *task = [[[self class] alloc] init];
    task.imageSource = imageSource;
   // imageItem.delegate = task;
    return task;// autorelease];
}

+ (KDImageUploadTask *)imageUploadTaskWithCompositeImageSource:(KDCompositeImageSource *)source {
    return [[self class] imageUploadTaskWithImageSourceArray:source.imageSources];
}

+ (KDImageUploadTask *)imageUploadTaskWithImageSourceArray:(NSArray *)array {
    if (!array || [array count] == 0) {
        return nil;
    }
    KDImageUploadTask * task = [[[self class] alloc] init];// autorelease];
    for (KDImageSource *theImageSource in array) {
            //[task.subTasks addObject:[KDImageUploadTask imageUploadTaskWithImageItem:item]];
             [task addSubTask:[[self class] imageUploadTaskWithImageSource:theImageSource]];
    }
    return task;
}

- (NSString *)uploadingDocPath {
    if (!uploadingDocPath_) {
        uploadingDocPath_ = [[KDCacheUtlities  imageFullPathForCacheKey:[KDCache cacheKeyForURL:self.imageSource.original] imageType:KDCacheImageTypeOrigin] copy];

    }
    return uploadingDocPath_;
}

- (void)taskDidSuccess {
    if ([self isCanceled] ||[self isFailed]) {
        return;
    }
    if (!self.subTasks) {
        KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
        NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
        NSURL *url = [NSURL URLWithString:baseURL];
        baseURL = [NSString stringWithFormat:@"http://%@",[url host]];
        baseURL = [baseURL stringByAppendingString:@"/microblog/filesvr/"];
        
        NSString *thumbial = [baseURL stringByAppendingFormat:@"%@?thumbnail",self.fetchedFileId];
        NSString *middle = [baseURL stringByAppendingString:self.fetchedFileId];
        NSString *original = [baseURL stringByAppendingFormat:@"%@?big",self.fetchedFileId];
       // UIImage *image = [UIImage imageWithContentsOfFile:self.uploadingDocPath];
        
        //[[KDCache sharedCache] storeImage:image forURL:original imageType:KDCacheImageTypeOrigin];
        [[KDCache sharedCache] linkImageFromURL:self.imageSource.original sourceType:KDCacheImageTypeOrigin toURL:original type:KDCacheImageTypePreview];
        [[KDCache sharedCache] linkImageFromURL:self.imageSource.original sourceType:KDCacheImageTypeOrigin toURL:original type:KDCacheImageTypePreview];
        [[KDCache sharedCache] linkImageFromURL:self.imageSource.original sourceType:KDCacheImageTypeOrigin toURL:original type:KDCacheImageTypePreviewBlur];
        [[KDCache sharedCache] linkImageFromURL:self.imageSource.original sourceType:KDCacheImageTypeOrigin toURL:middle type:KDCacheImageTypeMiddle];
        [[KDCache sharedCache] linkImageFromURL:self.imageSource.original sourceType:KDCacheImageTypeOrigin toURL:thumbial type:KDCacheImageTypeThumbnail];
     
    }
   
    [super taskDidSuccess];
}

- (NSString *)documentType {
    return ASLocalizedString(@"KDEvent_Picture");
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(imageSource_);
    //[super dealloc];
}

@end
