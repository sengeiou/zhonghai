//
//  KDUploadTask.h
//  kdweibo_common
//
//  Created by Tan yingqi on 13-5-15.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum :NSUInteger {
    
    KDUploadTaskStateReady = 0,
    KDUploadTaskStateDidStarted,
    KDUploadTaskUploading,
    KDUploadTaskStateSuccess,
    KDUploadTaskStateFailed,
    KDUploadTaskCanceling,
    KDUploadTaskCanceled
}KDUploadTaskState;

@interface KDUploadTask : NSObject
@property(nonatomic,strong)KDUploadTask *superTask;
@property(nonatomic,strong)KDUploadTask *dependency;
@property(nonatomic,strong)NSMutableArray *subTasks;
@property(nonatomic,strong)id entity;

- (void)taskWillStart;
- (void)taskDidSuccess;
- (void)taskDisFailed;
- (void)taskDidCanceled;
- (BOOL)isUploading;
- (BOOL)isStarted;
- (BOOL)isSuccess;
- (BOOL)isFailed;
- (BOOL)isCanceled;
- (BOOL)isReady;
- (void)startTask;
- (void)restart;
- (void)startCanceling;
- (void)cancel;
- (void)addSubTask:(KDUploadTask *)subTask;
@end
