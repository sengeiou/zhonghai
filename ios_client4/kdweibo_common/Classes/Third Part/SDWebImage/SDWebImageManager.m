/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageManager.h"
#import <objc/message.h>
#import "SDWebImageRawTask.h"

@interface SDWebImageCombinedOperation : NSObject <SDWebImageOperation>

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
@property (copy, nonatomic) void (^cancelBlock)();
@property (strong, nonatomic) NSOperation *cacheOperation;

@end

@interface SDWebImageManager ()

@property (strong, nonatomic, readwrite) SDImageCache *imageCache;
@property (strong, nonatomic, readwrite) SDWebImageDownloader *imageDownloader;
@property (strong, nonatomic) NSMutableArray *failedURLs;
@property (strong, nonatomic) NSMutableArray *runningOperations;

@end

@implementation SDWebImageManager

+ (id)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        _imageCache = [self createCache];
        _imageDownloader = [SDWebImageDownloader new];
        _failedURLs = [NSMutableArray new];
        _runningOperations = [NSMutableArray new];
        
        NSArray *suffix = [NSArray arrayWithObjects:@"",@"_a",@"_t",@"_m",@"_p", nil];
        
        [self setCacheKeyFilter:^(NSURL *url, SDWebImageScaleOptions option) {
            NSString *string = [url absoluteString];
            return [string stringByAppendingString:suffix[option]];
        }];
    }
    return self;
}

- (SDImageCache *)createCache {
    return [SDImageCache sharedImageCache];
}

- (NSString *)cacheKeyForURL:(NSURL *)url imageScale:(SDWebImageScaleOptions)scale{
    if (self.cacheKeyFilter) {
        return self.cacheKeyFilter(url, scale);
    }
    else {
        return [url absoluteString];
    }
}
- (UIImage *)diskImageForURL:(NSURL *)url options:(SDWebImageScaleOptions)options
{
    NSString *key = [self cacheKeyForURL:url imageScale:options];
    
    return [self.imageCache imageFromDiskCacheForKey:key];
}
- (UIImage *)diskImageForURL:(NSURL *)url
{
    return [self diskImageForURL:url options:SDWebImageScaleNone];
}
- (BOOL)diskImageExistsForURL:(NSURL *)url {
    NSString *key = [self cacheKeyForURL:url imageScale:SDWebImageScaleNone];
    return [self.imageCache diskImageExistsWithKey:key];
}

- (BOOL)diskImageExistsForURL:(NSURL *)url imageScale:(SDWebImageScaleOptions)scale{
    NSString *key = [self cacheKeyForURL:url imageScale:scale];
    return [self.imageCache diskImageExistsWithKey:key];
}

//添加返回文件路径的方法
-(NSString * )diskImagePathForURL:(NSURL *)url imageScale:(SDWebImageScaleOptions)scale{
    NSString * diskImagePath = nil;
    NSString *key = [self cacheKeyForURL:url imageScale:scale];
    diskImagePath = [self.imageCache defaultCachePathForKey:key];
    return diskImagePath;
    
}

- (id <SDWebImageOperation>)downloadWithURL:(NSURL *)url
                                    options:(SDWebImageOptions)options
                                   progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                  completed:(SDWebImageCompletedWithFinishedBlock)completedBlock
{
    return [self downloadWithURL:url options:options imageScale:SDWebImageScaleNone progress:progressBlock completed:completedBlock];
}
- (id <SDWebImageOperation>)downloadWithURL:(NSURL *)url options:(SDWebImageOptions)options imageScale:(SDWebImageScaleOptions)scale progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedWithFinishedBlock)completedBlock {
    // Invoking this method without a completedBlock is pointless
    NSParameterAssert(completedBlock);

    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, XCode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }

    // Prevents app crashing on argument type error like sending NSNull instead of NSURL
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }

    __block SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];
    __weak SDWebImageCombinedOperation *weakOperation = operation;

    BOOL isFailedUrl = NO;
    @synchronized (self.failedURLs) {
        isFailedUrl = [self.failedURLs containsObject:url];
    }

    if (!url || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        dispatch_main_sync_safe(^{
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
            completedBlock(nil, error, url, SDImageCacheTypeNone, YES);
        });
        return operation;
    }

    @synchronized (self.runningOperations) {
        [self.runningOperations addObject:operation];
    }
    NSString *key = [self cacheKeyForURL:url imageScale:scale];

    operation.cacheOperation = [self.imageCache queryDiskCacheForKey:key done:^(UIImage *image, SDImageCacheType cacheType) {
        if (operation.isCancelled) {
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }

            return;
        }

        if ((!image || options & SDWebImageRefreshCached) && (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url])) {
            if (image && options & SDWebImageRefreshCached) {
                dispatch_main_sync_safe(^{
                    // If image was found in the cache bug SDWebImageRefreshCached is provided, notify about the cached image
                    // AND try to re-download it in order to let a chance to NSURLCache to refresh it from server.
                    completedBlock(image, nil, url ,cacheType, YES);
                });
            }

            // download if no image or requested to refresh anyway, and download allowed by delegate
            SDWebImageDownloaderOptions downloaderOptions = 0;
            if (options & SDWebImageLowPriority) downloaderOptions |= SDWebImageDownloaderLowPriority;
            if (options & SDWebImageProgressiveDownload) downloaderOptions |= SDWebImageDownloaderProgressiveDownload;
            if (options & SDWebImageRefreshCached) downloaderOptions |= SDWebImageDownloaderUseNSURLCache;
            if (options & SDWebImageContinueInBackground) downloaderOptions |= SDWebImageDownloaderContinueInBackground;
            if (options & SDWebImageHandleCookies) downloaderOptions |= SDWebImageDownloaderHandleCookies;
            if (options & SDWebImageAllowInvalidSSLCertificates) downloaderOptions |= SDWebImageDownloaderAllowInvalidSSLCertificates;
            if (options & SDWebImageHighPriority) downloaderOptions |= SDWebImageDownloaderHighPriority;
            if (image && options & SDWebImageRefreshCached) {
                // force progressive off if image already cached but forced refreshing
                downloaderOptions &= ~SDWebImageDownloaderProgressiveDownload;
                // ignore image read from NSURLCache if image if cached but force refreshing
                downloaderOptions |= SDWebImageDownloaderIgnoreCachedResponse;
            }
            id <SDWebImageOperation> subOperation = [self.imageDownloader downloadImageWithURL:url options:downloaderOptions progress:progressBlock completed:^(UIImage *downloadedImage,__unused NSData *data, NSError *error, BOOL finished) {
                if (weakOperation.isCancelled) {
                    dispatch_main_sync_safe(^{
                        completedBlock(nil, nil, url, SDImageCacheTypeNone, finished);
                    });
                }
                else if (error) {
                    dispatch_main_sync_safe(^{
                        completedBlock(nil, error, url,SDImageCacheTypeNone, finished);
                    });

                    if (error.code != NSURLErrorNotConnectedToInternet) {
                        @synchronized (self.failedURLs) {
                            [self.failedURLs addObject:url];
                        }
                    }
                }
                else {
                    BOOL cacheOnDisk = !(options & SDWebImageCacheMemoryOnly);

                    if (options & SDWebImageRefreshCached && image && !downloadedImage) {
                        // Image refresh hit the NSURLCache cache, do not call the completion block
                    }
                            // NOTE: We don't call transformDownloadedImage delegate method on animated images as most transformation code would mangle it
                    else if (downloadedImage && !downloadedImage.images ) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            
                            
                            if (finished) {
                                
                                SDWebImageRawCompletedBlock block = ^void(UIImage *transformedImage)
                                {
                                    if (transformedImage) {
                                        BOOL imageWasTransformed = ![transformedImage isEqual:downloadedImage];
                                        [self.imageCache storeImage:transformedImage forKey:key recalculateFromImage:imageWasTransformed imageData:data forKey:[self cacheKeyForURL:url imageScale:SDWebImageScaleNone] toDisk:cacheOnDisk];
                                    }
                                    
                                    dispatch_main_sync_safe(^{
                                        completedBlock(transformedImage, nil, url,SDImageCacheTypeNone, finished);
                                    });
                                };
                                
                                [[SDWebImageRawTask shareRawTask] rawImage:downloadedImage scale:scale done:block];
                            }
                            else
                            {
                                dispatch_main_sync_safe(^{
                                    completedBlock(downloadedImage, nil, url, SDImageCacheTypeNone, finished);
                                });
                            }
                            
                
//                            UIImage *transformedImage = [self.delegate imageManager:self transformDownloadedImage:downloadedImage withURL:url];

                         
                        });
                    }
                    else {
                        if (downloadedImage && finished) {
                            [self.imageCache storeImage:downloadedImage forKey:key recalculateFromImage:NO imageData:data forKey:[self cacheKeyForURL:url imageScale:SDWebImageScaleNone] toDisk:cacheOnDisk];
                        }

                        dispatch_main_sync_safe(^{
                            completedBlock(downloadedImage, nil, url, SDImageCacheTypeNone, finished);
                        });
                    }
                }

                if (finished) {
                    @synchronized (self.runningOperations) {
                        [self.runningOperations removeObject:operation];
                    }
                }
            }];
            operation.cancelBlock = ^{
                [subOperation cancel];
            };
        }
        else if (image) {
            dispatch_main_sync_safe(^{
                completedBlock(image, nil, url, cacheType, YES);
            });
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
        }
        else {
            // Image not in cache and download disallowed by delegate
            dispatch_main_sync_safe(^{
                completedBlock(nil, nil, url, SDImageCacheTypeNone, YES);
            });
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
        }
    }];

    return operation;
}


- (id <SDWebImageOperation>)downloadWithURL:(NSURL *)url
                                    options:(SDWebImageOptions)options
                                 imageScale:(SDWebImageScaleOptions)scale
                                   progress:(SDWebImageDownloaderProgressBlock)progressBlock
                        completedWithNSData:(SDWebImageCompletedWithFinishedBlockWithNSData)completedBlock{
    NSParameterAssert(completedBlock);
    
    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, XCode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }
    
    // Prevents app crashing on argument type error like sending NSNull instead of NSURL
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }
    
    __block SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];
    __weak SDWebImageCombinedOperation *weakOperation = operation;
    
    BOOL isFailedUrl = NO;
    @synchronized (self.failedURLs) {
        isFailedUrl = [self.failedURLs containsObject:url];
    }
    
    if (!url || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        dispatch_main_sync_safe(^{
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
            completedBlock(nil, nil, error, url, SDImageCacheTypeNone, YES);
            
        });
        return operation;
    }
    
    @synchronized (self.runningOperations) {
        [self.runningOperations addObject:operation];
    }
    NSString *key = [self cacheKeyForURL:url imageScale:scale];
    
    operation.cacheOperation = [self.imageCache queryDiskDataCacheForKey:key done:^(NSData *image, SDImageCacheType cacheType) {
        if (operation.isCancelled) {
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
            
            return;
        }
        
        if ((!image || options & SDWebImageRefreshCached) && (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url])) {
            if (image && options & SDWebImageRefreshCached) {
                dispatch_main_sync_safe(^{
                    // If image was found in the cache bug SDWebImageRefreshCached is provided, notify about the cached image
                    // AND try to re-download it in order to let a chance to NSURLCache to refresh it from server.
                    completedBlock(nil ,image, nil, url ,cacheType, YES);
                });
            }
            
            // download if no image or requested to refresh anyway, and download allowed by delegate
            SDWebImageDownloaderOptions downloaderOptions = 0;
            if (options & SDWebImageLowPriority) downloaderOptions |= SDWebImageDownloaderLowPriority;
            if (options & SDWebImageProgressiveDownload) downloaderOptions |= SDWebImageDownloaderProgressiveDownload;
            if (options & SDWebImageRefreshCached) downloaderOptions |= SDWebImageDownloaderUseNSURLCache;
            if (options & SDWebImageContinueInBackground) downloaderOptions |= SDWebImageDownloaderContinueInBackground;
            if (options & SDWebImageHandleCookies) downloaderOptions |= SDWebImageDownloaderHandleCookies;
            if (options & SDWebImageAllowInvalidSSLCertificates) downloaderOptions |= SDWebImageDownloaderAllowInvalidSSLCertificates;
            if (options & SDWebImageHighPriority) downloaderOptions |= SDWebImageDownloaderHighPriority;
            if (image && options & SDWebImageRefreshCached) {
                // force progressive off if image already cached but forced refreshing
                downloaderOptions &= ~SDWebImageDownloaderProgressiveDownload;
                // ignore image read from NSURLCache if image if cached but force refreshing
                downloaderOptions |= SDWebImageDownloaderIgnoreCachedResponse;
            }
            id <SDWebImageOperation> subOperation = [self.imageDownloader downloadImageWithURL:url options:downloaderOptions progress:progressBlock completed:^(UIImage *downloadedImage, NSData *data, NSError *error, BOOL finished) {
                if (weakOperation.isCancelled) {
                    dispatch_main_sync_safe(^{
                        completedBlock(nil,data , nil, url, SDImageCacheTypeNone, finished);
                    });
                }
                else if (error) {
                    dispatch_main_sync_safe(^{
                        completedBlock(nil, data, error, url,SDImageCacheTypeNone, finished);
                    });
                    
                    if (error.code != NSURLErrorNotConnectedToInternet) {
                        @synchronized (self.failedURLs) {
                            [self.failedURLs addObject:url];
                        }
                    }
                }
                else {
                    BOOL cacheOnDisk = !(options & SDWebImageCacheMemoryOnly);
                    
                    if (options & SDWebImageRefreshCached && image && !downloadedImage) {
                        // Image refresh hit the NSURLCache cache, do not call the completion block
                    }
                    // NOTE: We don't call transformDownloadedImage delegate method on animated images as most transformation code would mangle it
                    else if (downloadedImage && !downloadedImage.images ) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            
                            
                            if (finished) {
                                
                                SDWebImageRawCompletedBlock block = ^void(UIImage *transformedImage)
                                {
                                    if (transformedImage) {
                                        BOOL imageWasTransformed = ![transformedImage isEqual:downloadedImage];
                                        [self.imageCache storeImage:transformedImage forKey:key recalculateFromImage:imageWasTransformed imageData:data forKey:[self cacheKeyForURL:url imageScale:SDWebImageScaleNone] toDisk:cacheOnDisk];
                                    }
                                    
                                    dispatch_main_sync_safe(^{
                                        completedBlock(transformedImage, data, nil, url,SDImageCacheTypeNone, finished);
                                    });
                                };
                                
                                [[SDWebImageRawTask shareRawTask] rawImage:downloadedImage scale:scale done:block];
                            }
                            else
                            {
                                dispatch_main_sync_safe(^{
                                    completedBlock(downloadedImage, data, nil, url, SDImageCacheTypeNone, finished);
                                });
                            }
                            
                            
                            //                            UIImage *transformedImage = [self.delegate imageManager:self transformDownloadedImage:downloadedImage withURL:url];
                            
                            
                        });
                    }
                    else {
                        if (downloadedImage && finished) {
                            [self.imageCache storeImage:downloadedImage forKey:key recalculateFromImage:NO imageData:data forKey:[self cacheKeyForURL:url imageScale:SDWebImageScaleNone] toDisk:cacheOnDisk];
                        }
                        
                        dispatch_main_sync_safe(^{
                            completedBlock(downloadedImage,data, nil, url, SDImageCacheTypeNone, finished);
                        });
                    }
                }
                
                if (finished) {
                    @synchronized (self.runningOperations) {
                        [self.runningOperations removeObject:operation];
                    }
                }
            }];
            operation.cancelBlock = ^{
                [subOperation cancel];
            };
        }
        else if (image) {
            dispatch_main_sync_safe(^{
                completedBlock(nil,image, nil, url, cacheType, YES);
            });
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
        }
        else {
            // Image not in cache and download disallowed by delegate
            dispatch_main_sync_safe(^{
                completedBlock(nil, image, nil, url, SDImageCacheTypeNone, YES);
            });
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
        }
    }];
    
    return operation;

 
}

- (void)cancelAll {
    @synchronized (self.runningOperations) {
        [self.runningOperations makeObjectsPerformSelector:@selector(cancel)];
        [self.runningOperations removeAllObjects];
    }
}

- (BOOL)isRunning {
    return self.runningOperations.count > 0;
}

@end

@implementation SDWebImageCombinedOperation

- (void)setCancelBlock:(void (^)())cancelBlock {
    if (self.isCancelled) {
        if (cancelBlock) cancelBlock();
    }
    else {
        _cancelBlock = [cancelBlock copy];
    }
}

- (void)cancel {
    self.cancelled = YES;
    if (self.cacheOperation) {
        [self.cacheOperation cancel];
        self.cacheOperation = nil;
    }
    if (self.cancelBlock) {
        self.cancelBlock();
        self.cancelBlock = nil;
    }
}

@end
