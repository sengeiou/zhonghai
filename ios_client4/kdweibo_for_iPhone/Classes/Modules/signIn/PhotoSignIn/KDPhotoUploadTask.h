//
//  KDPhotoUploadTask.h
//  kdweibo
//
//  Created by lichao_liu on 1/27/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol KDPhotoUploadTaskDelegate;

@interface KDPhotoUploadTask : NSObject
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *fileIdArray;
@property (nonatomic, assign) id<KDPhotoUploadTaskDelegate> taskDelegate;

@property (nonatomic, assign) NSInteger failuredIndex;//失败上传index

- (void)startUploadActionWithCachePathArray:(NSMutableArray *)cachePathArray;

- (BOOL)isTaskRunning;


@end


@protocol KDPhotoUploadTaskDelegate <NSObject>

- (void)whenPhotoUploadTaskSuccess:(NSDictionary *)dict task:(KDPhotoUploadTask *)task;
- (void)whenPhotoUploadTaskFailure:(NSDictionary *)dict task:(KDPhotoUploadTask *)task;

@end