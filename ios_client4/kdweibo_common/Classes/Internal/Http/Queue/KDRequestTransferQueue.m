//
//  KDRequestTransferQueue.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDRequestTransferQueue.h"

#import "KDRequestProgressMonitor.h"
#import "KDImageSize.h"

#import "KDCache.h"

#import "KDImageOptimizer.h"
#import "UIImage+Additions.h"
#import "KDReachabilityManager.h"


static const NSTimeInterval kKDRequestProgressMonitorNotifyTimeInterval = 1.0;

@implementation KDRequestTransferQueue

- (id) init {
    self = [super init];
    if(self){
        requestQueue_.showAccurateProgress = YES;
    }
    
    return self;
}

// override
- (NSUInteger) maxConcurrencyCount {
    // For the server run as well about on it's load balance,
    // About the file transfers queue just allows up to 2 connections at same time.
    // If the server is made by cluster, May be we can adjust the number of concurrency.
    BOOL wifiAvailable = NO;
    
#if TARGET_IPHONE_SIMULATOR
    wifiAvailable = YES;
    
#else
    
    wifiAvailable = ([KDReachabilityManager sharedManager].reachabilityStatus ==KDReachabilityStatusReachableViaWiFi);
    
#endif
    
    return wifiAvailable ? 0x02 : 0x01;
}

- (void) shouldChangeMaxConcurrentCount {
    NSUInteger count = [self maxConcurrencyCount];
    if(requestQueue_.maxConcurrentOperationCount != count){
        requestQueue_.maxConcurrentOperationCount = count;
    }
}

// override
- (void) addRequestWrapper:(KDRequestWrapper *)requestWrapper {
    if([self isValidRequestWrapper:requestWrapper]){
        ASIHTTPRequest *req = [requestWrapper getHttpRequest];
        [req setUseCookiePersistence:NO];
        
        if(requestWrapper.isDownload){
            req.downloadProgressDelegate = self;
            
        }else {
            req.uploadProgressDelegate = self;
        }
        
        if(requestWrapper.configBlock != nil){
            requestWrapper.configBlock(requestWrapper, req);
        }
        
        if([runningRequests_ count] < [self maxConcurrencyCount]){
            [self addToRunningList:requestWrapper];
            
        }else {
            [self addToPendingList:requestWrapper];
        }
    }
}

- (KDRequestWrapper *) requestWrapperFromDataSource:(NSArray *)dataSource matchFingerprint:(NSString *)fingerprint {
    for(KDRequestWrapper *item in dataSource){
        if([item.fingerprint isEqualToString:fingerprint]){
            return item;
        }
    }
    
    return nil;
}

// override
- (BOOL) isValidRequestWrapper:(KDRequestWrapper *)requestWrapper {
    if(![super isValidRequestWrapper:requestWrapper]) return NO;
    
    BOOL flag1 = NO;
    if([super hasSameFingerprintInDataSource:runningRequests_ requestWrapper:requestWrapper]){
        flag1 = YES;
    }
    
    BOOL flags2 = NO;
    if(!flag1){
        if([super hasSameFingerprintInDataSource:pendingRequests_ requestWrapper:requestWrapper]){
            flags2 = YES;
            
            // adjust the request wrapper
            KDRequestWrapper *cachedOne = [self requestWrapperFromDataSource:pendingRequests_ matchFingerprint:requestWrapper.fingerprint];
            cachedOne.priority = KDRequestPriorityHigh;
        }
    }
    
    // The request wrapper with transfer type just allows the request with unique fingerprint in the pending or running list.
    // For instance, If there are two requests try to download same avatar or document, The last request will be drop.
    // So, The fingerprint act as important role to make unique request for request wrappers with same type.
    if(flag1 || flags2){
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"There is exists same fingerpint in the pending or runing requests." forKey:kKDRequestQueueErrorDropRequestReasonKey];
        
        NSError *error = [NSError errorWithDomain:kKDRequestQueueErrorDomain code:0 userInfo:userInfo];
        [super dropRequest:requestWrapper error:error fromPendingList:NO];
        
        return NO;
    }
    
    return YES;
}

// override
- (KDRequestWrapper *) optimalRequestWrapperFromPendingList {
    return [super requestWrapperWithHighestPriorityFromSource:pendingRequests_];
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDRequestQueueTransferServices delegate method
- (BOOL)isImageSourceRequestFinishedWithURL:(NSString *)url
{
    if(url == nil) return YES;
    
    BOOL flag1 = NO;
    for(KDRequestWrapper *item in runningRequests_){
        // to ignore the get parameters
        if([item.url hasPrefix:url]){
            NSNumber *finished = [item.userInfo objectForKey:KKDDownloadFinished];
            if (finished && [finished boolValue])
                flag1 = YES;
            break;
        }
    }
    
    return flag1;
}
- (BOOL) isOnRequestQueueWithURL:(NSString *)url updatePriority:(BOOL)updatePriority {
    if(url == nil) return NO;
    
    BOOL flag1 = NO;
    for(KDRequestWrapper *item in runningRequests_){
        // to ignore the get parameters
        if([item.url hasPrefix:url]){
            flag1 = YES;
            break;
        }
    }
    
    BOOL flags2 = NO;
    if(!flag1){
        for(KDRequestWrapper *item in pendingRequests_){
            // to ignore the get parameters
            if([item.url hasPrefix:url]){
                flags2 = YES;
                
                // adjust the priority for request wrapper
                if(updatePriority){
                    item.priority = KDRequestPriorityHigh;
                }
                
                break;
            }
        }
    }
    
    return flag1 || flags2;
}

/////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark methods for downloading

- (void) deleteDownloadTempraryFileIfNeed:(KDRequestWrapper *)requestWrapper {
    NSString *path = [requestWrapper downloadTemporaryPath];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path]){
        NSError *error = nil;
        if(![fm removeItemAtPath:path error:&error]) {
            DLog(@"Can not delete the file with error:%@", error);
        }
    }
}

- (void) moveItemFromPath:(NSString *)srcPath toPath:(NSString *)toPath {
    if(srcPath == nil || toPath == nil) return;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:srcPath]){
        NSError *error = nil;
        if(![fm moveItemAtPath:srcPath toPath:toPath error:&error]){
            DLog(@"Can not move the file from %@ to %@ with error:%@", srcPath, toPath, error);
        }
    }
}
- (void) compressionGifImage:(KDRequestWrapper *)requestWrapper rawImage:(NSData *)data
{
    KDImageOptimizationTask *task = [[KDImageOptimizationTask alloc] initWithDelegate:self gif:data imageSize:[KDImageSize defaultGifImageSize] userInfo:requestWrapper];
    task.optimizationType = KDImageOptimizationTypeGif;
    
    task.completionBlock = ^(KDImageOptimizationTask *workingTask, id generateData){

        if (generateData !=nil) {
            
//            NSInteger cropType = [[requestWrapper.userInfo objectForKey:kKDRequestImageCropTypeKey] integerValue];
            NSData *data = generateData;
            
            [[KDCache sharedCache] storeImageData:data forURL:requestWrapper.url imageType:KDCacheImageTypeMiddle];
            [[KDCache sharedCache] storeImageData:data forURL:requestWrapper.url imageType:KDCacheImageTypePreview];

            
        }
    };
    
    [[KDImageOptimizer sharedImageOptimizer] addTask:task];
//    [task release];
    
    
    
}
- (void) compressionDownloadedImage:(KDRequestWrapper *)requestWrapper rawImage:(UIImage *)rawImage {
    NSInteger cropType = [[requestWrapper.userInfo objectForKey:kKDRequestImageCropTypeKey] integerValue];
    KDImageSize *imageSize = [requestWrapper.userInfo objectForKey:kKDImageScaleSizeKey];
    
    KDImageOptimizationTask *task = [[KDImageOptimizationTask alloc] initWithDelegate:self image:rawImage imageSize:imageSize userInfo:requestWrapper];
    task.optimizationType = cropType;
    
    task.completionBlock = ^(KDImageOptimizationTask *workingTask, id generatedImage){
        if(generatedImage != nil) {
            float quality = 0.75;
            switch (cropType) {
                case KDCacheImageTypeAvatar:
                case KDCacheImageTypeThumbnail:
                case KDCacheImageTypeMiddle:
                    quality = kKDJPEGThumbnailQuality;
                    break;
                    
                case KDCacheImageTypePreview:
                case KDCacheImageTypeOrigin:
                    quality = kKDJPEGPreviewImageQuality;
                    break;
                    
                case KDCacheImageTypePreviewBlur:
                    quality = kKDJPEGBlurPreviewImageQuality;
                    break;
                    
                default:
                    break;
            }
            
            NSData *data = [generatedImage asJPEGDataWithQuality:quality];
            if(data != nil) {
                if(KDCacheImageTypeAvatar == cropType){
                    [[KDCache sharedCache] storeAvatarWithData:data forURL:requestWrapper.url writeToDisk:YES];
                    
                }else {
                    [[KDCache sharedCache] storeImageData:data forURL:requestWrapper.url imageType:cropType];
                    
                    // generate the blur preview image
                    if(KDCacheImageTypePreview == cropType){
                        data = [generatedImage asJPEGDataWithQuality:kKDJPEGBlurPreviewImageQuality];
                        [[KDCache sharedCache] storeImage:rawImage forURL:requestWrapper.url imageType:KDCacheImageTypeOrigin];
                        [[KDCache sharedCache] storeImageData:data forURL:requestWrapper.url imageType:KDCacheImageTypePreviewBlur];
                    }
                }
            }
        }
        
    };
    
    [[KDImageOptimizer sharedImageOptimizer] addTask:task];
//    [task release];
}


/////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark progress monitor timer

- (void) activeProgressMonitorWithRequest:(KDRequestWrapper *)requestWrapper contentLength:(KDUInt64)contentLength {
    [requestWrapper.progressMonitor requestWillStart];
    
    requestWrapper.progressMonitor.maxBytes = contentLength;
    
    if(progressMonitorTimer_ == nil){
        // start a timer to report the tranfering progress at per 1 second.
        progressMonitorTimer_ = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(progressMonitorTimerFire:) userInfo:nil repeats:YES];
    }
}

- (void) progressMonitorTimerFire:(NSTimer *)timer {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    for(KDRequestWrapper *item in runningRequests_){
        if((now - item.progressMonitor.lastNotifyTime + 0.001) > kKDRequestProgressMonitorNotifyTimeInterval){
            item.progressMonitor.lastNotifyTime = now;
            
            if(item.delegate != nil && [item.delegate respondsToSelector:@selector(requestWrapper:request:progressMonitor:)]){
                [item.delegate requestWrapper:item request:[item getHttpRequest] progressMonitor:item.progressMonitor];
            }
        }
    }
}

- (void) invalidProgressMonitorTimer {
    if(progressMonitorTimer_ != nil){
        [progressMonitorTimer_ invalidate];
        progressMonitorTimer_ = nil;
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - GIF AND OTHER IMAGE


#pragma mark -
#pragma mark override methods

// Override
- (void) requestDidFinish:(ASIHTTPRequest *)request {
    BOOL doCleanNow = YES;
    
    KDRequestWrapper *requestWrapper = [super mappedRequestWrapperForRequest:request];
    if(requestWrapper.userInfo != nil && [requestWrapper.userInfo objectForKey:kKDIsRequestImageSourceKey] != nil){
        KDImageSize *size = [requestWrapper.userInfo objectForKey:kKDImageScaleSizeKey];
        NSInteger imageType = [[[requestWrapper.userInfo objectForKey:kKDCustomUserInfoKey] objectAtIndex:0x02] integerValue];
        [requestWrapper addUserInfoWithObject:[NSNumber numberWithBool:YES] forKey:KKDDownloadFinished];
        
        switch (imageType) {
            case 0x00:
            {
                // check the image size is greater than defined image size
                UIImage *image = [UIImage imageWithContentsOfFile:requestWrapper.downloadTemporaryPath];
                if(image != nil){
                    NSInteger cropType = [[requestWrapper.userInfo objectForKey:kKDRequestImageCropTypeKey] integerValue];
                    
//                    if(KDCacheImageTypePreview == cropType) {
//                        [[KDCache sharedCache] storeImage:image forURL:requestWrapper.url imageType:KDCacheImageTypeOrigin];
//                    }
                    
                    if(image.size.width + 0.01 > size.width || image.size.height + 0.01 > size.height){
                        doCleanNow = NO;
                        
                        // start call image optimizer
                        [self compressionDownloadedImage:requestWrapper rawImage:image];
                        
                    }else {
                        // move downloaded to cached place directly
                        if(KDCacheImageTypeAvatar == cropType){
                            [[KDCache sharedCache] moveAvartarWithURL:requestWrapper.url srcPath:requestWrapper.downloadTemporaryPath];
                        }
                        else {
                            if(KDCacheImageTypePreview == cropType) {
                                [[KDCache sharedCache] storeImage:image forURL:requestWrapper.url imageType:KDCacheImageTypeOrigin];
                            }
                            [[KDCache sharedCache] moveImageWithURL:requestWrapper.url imageType:cropType srcPath:requestWrapper.downloadTemporaryPath ];
                        }
                    }
                }
            }
                break;
            case 0x01:
            {
                // check the image size is greater than defined image size
                NSData *data = [NSData dataWithContentsOfFile:requestWrapper.downloadTemporaryPath];
                if(data != nil){
                    doCleanNow = NO;
                    [self compressionGifImage:requestWrapper rawImage:data];
                }
                
            }
                break;
            default:
                break;
        }
    }
    
    if(doCleanNow){
        [super requestDidFinish:request];
    }
}


// Override
- (void) queueRequestDidStart:(ASIHTTPRequest *)request {
    KDRequestWrapper *requestWrapper = [super mappedRequestWrapperForRequest:request];
    if([requestWrapper.method isPostMethod]){
        [self activeProgressMonitorWithRequest:requestWrapper contentLength:[requestWrapper postDataContentLength]];
    }
}

// Override
- (void) queueRequest:(ASIHTTPRequest *)request didRecieveResponseHeaders:(NSDictionary *)responseHeaders {
    KDRequestWrapper *requestWrapper = [super mappedRequestWrapperForRequest:request];
    if([requestWrapper.method isGetMethod]){
        KDUInt64 contentLength = NSURLResponseUnknownLength;
        NSString *field = [responseHeaders objectForKey:@"Content-Length"];
        if(field != nil){
            contentLength = [field longLongValue];
        }
        
        [self activeProgressMonitorWithRequest:requestWrapper contentLength:contentLength];
    }
}

// Override
- (void) queueRequestDidFinish:(ASIHTTPRequest *)request {
    // Downloading
    KDRequestWrapper *requestWrapper = [super mappedRequestWrapperForRequest:request];
    BOOL isRequestImageSource = requestWrapper.userInfo != nil && [requestWrapper.userInfo objectForKey:kKDIsRequestImageSourceKey] != nil;
    if(requestWrapper.isDownload){
        // move the downloaded file to target path
        if(!isRequestImageSource && requestWrapper.downloadDestinationPath != nil){
            [self moveItemFromPath:requestWrapper.downloadTemporaryPath toPath:requestWrapper.downloadDestinationPath];
        }
        
        // delete the download temporary file
        [self deleteDownloadTempraryFileIfNeed:requestWrapper];
    }
}

// Override
- (void) queueNetworkQueueDidFinish:(ASINetworkQueue *)queue {
    [self invalidProgressMonitorTimer];
}

/////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark ASIProgressDelegate methods

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes {
	KDRequestWrapper *requestWrapper = [super mappedRequestWrapperForRequest:request];
    requestWrapper.progressMonitor.currentBytes += bytes;
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes {
	KDRequestWrapper *requestWrapper = [super mappedRequestWrapperForRequest:request];
    requestWrapper.progressMonitor.currentBytes += bytes;
}


/////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDImageOptimizationTask delegate methods

- (void) willDropImageOptimizationTask:(KDImageOptimizationTask *)task {
    [super requestDidFinish:[(KDRequestWrapper *)task.userInfo getHttpRequest]];
}

- (void) imageOptimizationTask:(KDImageOptimizationTask *)task didFinishedOptimizedImageWithInfo:(NSDictionary *)info {
    // No matter the image compression succeed or not.
    // Just call the super requestDidFinish: to make this request did finished.
    KDRequestWrapper *requestWrapper = task.userInfo;
    [super requestDidFinish:[requestWrapper getHttpRequest]];
}


- (void) dealloc {
    [self invalidProgressMonitorTimer];
    
    //[super dealloc];
}

@end

