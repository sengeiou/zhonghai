//
//  KDPhotoUploadTask.m
//  kdweibo
//
//  Created by lichao_liu on 1/27/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDPhotoUploadTask.h"
#import "KDConfigurationContext.h"


@interface KDPhotoUploadTask()
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) BOOL isEnterBackground;
@end

@implementation KDPhotoUploadTask

- (id)init
{
    if(self = [super init])
    {
//          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
//        [[NSNotificationCenter  defaultCenter] addObserver:self selector:@selector(cancelTask) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    return self;
}

- (void)goToBackground
{
    self.isEnterBackground = YES;
}

- (BOOL)isTaskRunning
{
    return self.isRunning;
}

- (void)cancelTask
{
    if(self.isEnterBackground)
    {
    self.isEnterBackground = NO;
    [self taskDidCanceled:self];
    }
}

- (void)startUploadActionWithCachePathArray:(NSMutableArray *)cachePathArray
{
    self.isRunning = YES;
    self.index = 0;
    __weak KDPhotoUploadTask *task = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(task.fileIdArray && task.fileIdArray.count>0)
        {
            [task.fileIdArray removeAllObjects];
        }else{
            task.fileIdArray = [NSMutableArray new];
        }
        if(task.dataArray && task.dataArray.count>0)
        {
            [task.dataArray removeAllObjects];
            [task.dataArray addObjectsFromArray:cachePathArray];
        }else{
            task.dataArray = [NSMutableArray new];
            [task.dataArray addObjectsFromArray:cachePathArray];
        }
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_t group = dispatch_group_create();
        for (NSString *original in cachePathArray)
        {
            dispatch_group_async(group, queue, ^{
                [task uploadPhotoActionWithPath:original];
            });
        }
        
    });
}

- (void)uploadPhotoActionWithPath:(NSString *)path
{
    __weak KDPhotoUploadTask *task = self ;
    if([KDReachabilityManager sharedManager].reachabilityStatus == KDReachabilityStatusNotReachable)
    {
        [self taskDisFailed:self];
        return;
    }
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"pic" filePath:path];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse] && task && task.taskDelegate){
            if (results) {
                [task.fileIdArray addObject:results];
                [task  taskDidSuccess:task];
            }else {
                [task taskDisFailed:task];
            }
        }
        else if(task && task.taskDelegate){
            if (![response isCancelled]) {
                [task taskDisFailed:task];
            }else {
                [task taskDidCanceled:task];
            }
        }
    };
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/upload/:multipleDoc" query:query
                                 configBlock:nil completionBlock:completionBlock];
}


- (void)taskDidSuccess:(KDPhotoUploadTask *)task
{
    DLog(@"拍照上传成功success");
    task.index ++;
    if(task.index == task.dataArray.count)
    {
        DLog(@"图片全部上传成功");
        task.index = 0;
        task.isRunning = NO;
        [task removeLocalCacheImages];
        NSDictionary *dict = @{@"successcount":@(task.fileIdArray.count),@"fileIds":[task.fileIdArray mutableCopy],@"failuredIndex":@(self.failuredIndex),@"failuredIndex":@(task.failuredIndex)};
        if(task.taskDelegate && [task.taskDelegate respondsToSelector:@selector(whenPhotoUploadTaskSuccess:task:)])
        {
            [task.taskDelegate whenPhotoUploadTaskSuccess:dict task:task];
        }
     }
}

- (void)taskDisFailed:(KDPhotoUploadTask *)task
{
    DLog(@"拍照上传失败FAILED");
    task.index ++;
    if(task.index == task.dataArray.count)
    {
//      [self removeLocalCacheImages];
        task.isRunning = NO;
        DLog(@"图片全部上传成功");
        task.index = 0;
        NSDictionary *dict;
        if(task.fileIdArray && task.fileIdArray.count>0)
        {
         dict = @{@"successcount":@(task.fileIdArray.count),@"fileIds":[task.fileIdArray mutableCopy],@"failuredIndex":@(self.failuredIndex)};
        }else{
        dict = @{@"successcount":@(task.fileIdArray.count),@"fileIds":[task.fileIdArray mutableCopy],@"failuredIndex":@(self.failuredIndex),@"cachePathArray":[task.dataArray mutableCopy]};
        }
        if(task.taskDelegate && [task.taskDelegate respondsToSelector:@selector(whenPhotoUploadTaskSuccess:task:)])
        {
            [task.taskDelegate whenPhotoUploadTaskSuccess:dict task:task];
        }
     }
}

- (void)taskDidCanceled:(KDPhotoUploadTask *)task
{
    task.isRunning = NO;
    [task.dataArray removeAllObjects];
    [task.fileIdArray removeAllObjects];
    task.index = 0;
    DLog(@"拍照上传取消canceled");
    [task taskDisFailed:task];
    
    if(task.taskDelegate && [task.taskDelegate respondsToSelector:@selector(whenPhotoUploadTaskFailure:task:)])
    {
        [task.taskDelegate whenPhotoUploadTaskFailure:nil task:self];
    }}

//- (KDCompositeImageSource *)compositeImageSourceByLocalImageSources:(NSArray *)sources {
//    if (!sources ||[sources count] == 0) {
//        return nil;
//    }
//    KDImageSource *imageSource;
//    NSMutableArray *imageSoures = [NSMutableArray array];
//    
//    UIImage* image = nil;
//    for (NSString *path in sources) {
//        imageSource = [[KDImageSource alloc] init];
//        
//        KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
//        NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
//        
//        NSURL *url = [NSURL URLWithString:baseURL];
//        
//        baseURL = [NSString stringWithFormat:@"http://%@",[url host]];
//        
//        baseURL = [baseURL stringByAppendingString:@"/microblog/filesvr/"];
//        
//        imageSource.thumbnail = [baseURL stringByAppendingFormat:@"%@?thumbnail",imageSource.fileId];
//        imageSource.middle = [baseURL stringByAppendingString:imageSource.fileId];
//        imageSource.original = [baseURL stringByAppendingFormat:@"%@?big",imageSource.fileId];
//        
//        image = [UIImage imageWithContentsOfFile:path];
//        
//        [[KDCache sharedCache] storeImage:image forURL:imageSource.original imageType:KDCacheImageTypeOrigin finishedBlock:^(BOOL finish) {
//            [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.original type:KDCacheImageTypePreview];
//            [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.original type:KDCacheImageTypePreviewBlur];
//            [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.middle type:KDCacheImageTypeMiddle];
//            [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.thumbnail type:KDCacheImageTypeThumbnail];
//            
//        }];
//        [imageSoures addObject:imageSource];
//        
//    }
//    if (imageSoures.count >0) {
//        return [[KDCompositeImageSource alloc] initWithImageSources:imageSoures];
//    }else {
//        DLog(@"can not create KDCompositeImageSource");
//        return nil;
//    }
//}

- (void)dealloc
{
    self.taskDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)removeLocalCacheImages
{
    if(self.dataArray && self.dataArray.count>0 && self.fileIdArray && self.fileIdArray.count>0)
    {
        for (NSString *cacheImageurl in self.dataArray) {
            if([[NSFileManager defaultManager] fileExistsAtPath:cacheImageurl])
            {
                [[NSFileManager defaultManager] removeItemAtPath:cacheImageurl error:NULL];
            }
        }
    }
}
@end
