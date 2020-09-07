//
//  KDDocument.h
//  kdweibo
//
//  Created by Tan yingqi on 7/26/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDCommon.h"
#import "KDStatus.h"
#import "KDDMMessage.h"

typedef enum {
    KDDownloadEntityTypeStatus = 0,
    KDDownloadEntityTypeMessage,
}KDDowndEntityType;

typedef enum {
    KDDownloadStateNot = 0,
    KDDownloadStateDownloading,
    KDDownloadStateSuccess,
    KDDownloadStateFailed,
    KDDownloadStateCancled,
    KDDownloadStateDirty,
    KDDownloadStateBlocked
}KDDownloadState;

typedef void  (^detectionFinishedBlock)(NSArray *array);

@interface KDDownload : NSObject{
    NSString *downloadId_;    //与attahmentId关联
    NSString *name_;
    NSString *entityId_;       //与statusId和messageId关联
    KDDowndEntityType  entityType_;
    NSTimeInterval startAt_;
    NSTimeInterval endAt_;
    NSString *url_;
    NSString *path_;
    NSString *tempPath_;
    KDDownloadState downloadState_;
    KDUInt64 currentByte_;
    KDUInt64 maxByte_;
    NSString *mimeType_;    
}

@property (nonatomic, copy) NSString *downloadId;
@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,copy) NSString *entityId;
@property (nonatomic ,assign) KDDowndEntityType entityType;
@property (nonatomic ,assign) NSTimeInterval startAt;
@property (nonatomic ,assign) NSTimeInterval endAt;
@property (nonatomic ,copy) NSString *url;
@property (nonatomic ,copy) NSString *path;
@property (nonatomic ,copy) NSString *tempPath;
@property (assign) KDDownloadState downloadState;
@property (nonatomic ,assign) KDUInt64 currentByte;
@property (nonatomic ,assign) KDUInt64 maxByte;
@property (nonatomic ,copy)  NSString *mimeType;

+ (NSString *)defaultDownloadDocDir;
//+ (KDDownload *) downloadFromPersistenceWithAttachmentId:(NSString *)attachmentId;
+ (BOOL) deleteFromPersisten:(KDDownload *)download;
+ (BOOL) deleteAllDownloadsFromPersistence;
+ (NSArray *) allDownloadedDocuments;
- (void)insertToDB;
- (void)loadPath;
- (NSUInteger)identifier;
+ (void) downloadsWithAttachemnts:(NSArray *)attachemnts Status:(KDStatus *)status finishBlock:(detectionFinishedBlock)finishBlock;
+ (void) downloadsWithAttachemnts:(NSArray *)attachemnts diretMessage:(KDDMMessage *)message  finishBlock:(detectionFinishedBlock)finishBlock;
+ (void) downloadsWithAttachemnts:(NSArray *)attachemnts statusId:(NSString *)statusId finishBlock:(detectionFinishedBlock)finishBlock;
+ (void)grabExistingDowndsWithfinishBlock:(detectionFinishedBlock)finishBlock;
- (void)determinState;
- (void) startDownload;
- (void) downloadFailed;
- (void) downloadSucceed;
- (void) downloadCancled;
- (BOOL) isDownloading;
- (BOOL) isCancled;
- (BOOL) isFailed;
- (BOOL) isSuccess;
+ (void) downloadsWithAttachemnts:(KDAttachment *)attachemnts finishBlock:(detectionFinishedBlock)finishBlock;
@end
