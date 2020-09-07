//
//  KDImageOptimizer.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-15.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"

#import "KDImageOptimizer.h"

#import "UIImage+Additions.h"
#import "NSData+GIF.h"
static KDImageOptimizer *sharedImageOptimizer_ = nil;

// About the memory useage and other things.
// make the image working queue works as serial mode
static const NSUInteger kKDImageOptimizerDefaultMaxConcurrencyCount = 0x01;

static NSString * const kKDImageOptimalizationTaskKey = @"imageOptimalizationTask";
static NSString * const kKDImageOptimalizationTaskImageKey = @"imageOptimalizationTaskImage";


@interface KDImageOptimizer ()

@property (nonatomic, retain) NSOperationQueue *queue;

@property (nonatomic, retain) NSMutableArray *waitingTasks;
@property (nonatomic, retain) NSMutableArray *runningTasks;

@end

@implementation KDImageOptimizer

@synthesize queue=queue_;
@synthesize waitingTasks=waitingTasks_;
@synthesize runningTasks=runningTasks_;

- (id) init {
    self = [super init];
    if(self){
        queue_ = nil;
        
        runningTasks_ = nil;
        waitingTasks_ = nil;
    }
    
    return self;
}

+ (KDImageOptimizer *) sharedImageOptimizer {
    @synchronized([KDImageOptimizer class]){
        if(sharedImageOptimizer_ == nil) {
            sharedImageOptimizer_ = [[KDImageOptimizer alloc] init];
        }
    }
    
    return sharedImageOptimizer_;
}

- (BOOL) hasWaitingTasks {
    return waitingTasks_ != nil && [waitingTasks_ count] > 0;
}

- (BOOL) hasRunningTasks {
    return runningTasks_ != nil && [runningTasks_ count] > 0;
}

- (BOOL) hasSameTask:(KDImageOptimizationTask *)task dataSource:(NSArray *)dataSource {
    // check does exists same object
    NSUInteger idx = [dataSource indexOfObject:task];
    if(NSNotFound != idx){
        return YES;
    }
    
    return NO;
}

- (BOOL) hasSameTaskBaseCacheKey:(NSString *)cacheKey dataSource:(NSArray *)dataSource {
    // check does exists same object base on the cache key
    for(KDImageOptimizationTask *t in dataSource){
        if([t.cacheKey isEqualToString:cacheKey]){
            return YES;
        }
    }
    
    return NO;
}

- (KDImageOptimizationTask *) mappedImageOptimizationTask:(KDImageOptimizationTask *)srcTask fromDataSource:(NSArray *)dataSource {
    NSUInteger idx = [dataSource indexOfObject:srcTask];
    if(NSNotFound != idx){
        return srcTask;
    }
    
    for(KDImageOptimizationTask *t in dataSource){
        if([t.cacheKey isEqualToString:srcTask.cacheKey]){
            return t;
        }
    }
    
    return nil;
}

- (BOOL) isWaitingTask:(KDImageOptimizationTask *)task {
    if([self hasSameTask:task dataSource:waitingTasks_]) return YES;
    
    return [self hasSameTaskBaseCacheKey:task.cacheKey dataSource:waitingTasks_];
}

- (BOOL) isRunningTask:(KDImageOptimizationTask *)task {
    if([self hasSameTask:task dataSource:runningTasks_]) return YES;
    
    return [self hasSameTaskBaseCacheKey:task.cacheKey dataSource:runningTasks_];
}

- (void) willDropImageOptimizationTask:(KDImageOptimizationTask *)task {
    if (task.delegate != nil) {
        [task.delegate willDropImageOptimizationTask:task];
    }
}

- (void) addTask:(KDImageOptimizationTask *)task {
    if(task == nil) return;
    
    // initilization the waiting list before any task
    BOOL flag1 = NO;
    if(waitingTasks_ == nil){
        flag1 = YES;
        waitingTasks_ = [[NSMutableArray alloc] init];
    }
    
    BOOL flag2 = NO;
    if(runningTasks_ == nil){
        flag2 = YES;
        runningTasks_ = [[NSMutableArray alloc] init];
    }
    
    // check the task is running on the queue
    if(!flag2 && [self isRunningTask:task]){
        // Don't add same task into the queue
        [self willDropImageOptimizationTask:task];
        return;
    }
    
    // check the task is waiting for in the list
    if(!flag1 && [self isWaitingTask:task]){
        // Don't add same task into the waiting list and adjust the request priority
        KDImageOptimizationTask *target = [self mappedImageOptimizationTask:task fromDataSource:waitingTasks_];
        target.priority = KDImageOptimizationPriorityHigh;
        
        [self willDropImageOptimizationTask:task];
        return;
    }
    
    if([runningTasks_ count] < kKDImageOptimizerDefaultMaxConcurrencyCount){
        [runningTasks_ addObject:task];
        [self addTaskIntoWorkingQueue:task];
        
    }else {
        [waitingTasks_ addObject:task];
    }
}

- (KDImageOptimizationTask *) optimalTaskFromWaitingList {
    if([waitingTasks_ count] < 0x01) return nil;
    
    KDImageOptimizationTask *optimalTask = [waitingTasks_ objectAtIndex:0x00];
    
    NSInteger idx = 0x01;
    KDImageOptimizationTask *temp = nil;
    for(; idx < [waitingTasks_ count]; idx++){
        temp = [waitingTasks_ objectAtIndex:idx];
        
        if(temp.priority > optimalTask.priority){
            optimalTask = temp;
        }
    }
    
    return optimalTask;
}

- (void) startNextTaskIfNeed {
    // start next task from waiting list
    KDImageOptimizationTask *task = [self optimalTaskFromWaitingList];
    if(task != nil) {
        [runningTasks_ addObject:task];
        [waitingTasks_ removeObject:task];
        
        [self addTaskIntoWorkingQueue:task];
        
    }else {
        // release the work queue when all tasks did finished
        //KD_RELEASE_SAFELY(waitingTasks_);
        //KD_RELEASE_SAFELY(runningTasks_);
        
        [self disableWorkingQueue];
    }
}

- (void) addTaskIntoWorkingQueue:(KDImageOptimizationTask *)task {
    // notify the delegate the optimilization will begin
    if(task.delegate != nil && [task.delegate respondsToSelector:@selector(willStartImageOptimizationTask:)]){
        [task.delegate willStartImageOptimizationTask:task];
    }
    
    // make sure the working queue does exists before start task
    if(queue_ == nil) {
        queue_ = [[NSOperationQueue alloc] init];
        queue_.maxConcurrentOperationCount = kKDImageOptimizerDefaultMaxConcurrencyCount;
    }
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        id generatedImage = nil;
        
        if (task.optimizationType != KDImageOptimizationTypeGif) {
            
            UIImage *rawImage = [task getRawImage];
            if(rawImage != nil) {
                // step 1: fast crop the image to defined size
                switch (task.optimizationType) {
                    case KDImageOptimizationTypeThumbnail:
                    case KDImageOptimizationTypeMiddle:
                        generatedImage = [rawImage generateThumbnailWithSize:task.imageSize.size];
                        break;
                        
                    case KDImageOptimizationTypePreview:
                        generatedImage = [rawImage generatePreviewImageWithSize:task.imageSize.size];
                        break;
                        
                    case KDImageOptimizationTypePreviewBlur:
                        generatedImage = [rawImage generateBlurPreviewImageWithSize:task.imageSize.size];
                        break;
                        
                    case KDImageOptimizationTypeMinimumOptimal:
                        generatedImage = [rawImage fastCropToSize:task.imageSize.size type:KDImageScaleTypeFit];
                        break;
                        
                    default:
                        generatedImage = [rawImage fastCropToSize:task.imageSize.size];
                        break;
                }
            }
        }
        else
        {
            NSData *rawData = [task getGifData];
            if (rawData != nil) {
                rawData = [rawData rawGIF_ToSize:task.imageSize.size];
            }
            generatedImage = rawData;
        }
        
        
        // step 2: invoke the completion block if need
        if(task.completionBlock != nil){
            task.completionBlock(task, generatedImage);
        }
        
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:task, kKDImageOptimalizationTaskKey,
                              ((generatedImage != nil) ? generatedImage : [NSNull null]), kKDImageOptimalizationTaskImageKey, nil];
        
        [self performSelectorOnMainThread:@selector(didFinishImageOptimizationTask:) withObject:info waitUntilDone:[NSThread isMainThread]];
        
    }];
    
    [queue_ addOperation:blockOperation];
    
    if([queue_ isSuspended]){
        [queue_ setSuspended:NO];
    }
}
- (void) didFinishImageOptimizationTask:(NSDictionary *)info {
    KDImageOptimizationTask *task = [info objectForKey:kKDImageOptimalizationTaskKey];
    id imageObj = [info objectForKey:kKDImageOptimalizationTaskImageKey];
    if([NSNull null] == imageObj){
        imageObj = nil;
    }
    
    // notify delegate if need
    if(task.delegate != nil){
        NSMutableDictionary *delegateInfo = [NSMutableDictionary dictionary];
        if(imageObj != nil){
            [delegateInfo setObject:imageObj forKey:kKDImageOptimizationTaskCropedImage];
        }
        
        [task.delegate imageOptimizationTask:task didFinishedOptimizedImageWithInfo:delegateInfo];
    }
    
    // remove from running list
    [runningTasks_ removeObject:task];
    
    [self startNextTaskIfNeed];
}

- (void) removeAllTasks {
    //KD_RELEASE_SAFELY(waitingTasks_);
    
    [self disableWorkingQueue];
    
    //KD_RELEASE_SAFELY(runningTasks_);
}

- (void) disableWorkingQueue {
    if(queue_ != nil){
        if([queue_ operationCount] > 0){
            [queue_ cancelAllOperations];
        }
        
        [queue_ setSuspended:YES];
        
        //KD_RELEASE_SAFELY(queue_);
    }
}

- (void) dealloc {
    [self disableWorkingQueue];
    
    //KD_RELEASE_SAFELY(waitingTasks_);
    //KD_RELEASE_SAFELY(runningTasks_);
    
    //[super dealloc];
}

@end
