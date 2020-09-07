//
//  KDDownloadFile.m
//  kdweibo
//
//  Created by wenjie_lee on 16/8/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//





//
//  KDDocument.m
//  kdweibo
//
//  Created by Tan yingqi on 7/26/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDDownloadFile.h"
#import "KDUtility.h"
#import "KDAttachment.h"

#define KD_ATTACHMENT_FILE_SIZE   @"file_size"
#define KD_ATTACHMENT_FILE_NAME   @"file_name"
#define KD_ATTACHMENT_CREATE_AT   @"creat_at"

@implementation KDDownloadFile
@synthesize downloadId = downloadId_;
@synthesize url = url_;
@synthesize name = name_;
@synthesize entityId = entityId_;
@synthesize entityType = entityType_;
@synthesize startAt = startAt_;
@synthesize endAt = endAt_;
@synthesize path = path_;
@synthesize tempPath = tempPath_;
@synthesize downloadState = downloadState_;
@synthesize currentByte = currentByte_;
@synthesize maxByte = maxByte_;
@synthesize mimeType = mimeType_;


+ (NSString *)defaultDownloadDirectory {
    return [[KDUtility defaultUtility] searchDirectory:KDDownloadDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];
}

+ (NSString *)defaultDownloadDocDir {
    return  [[KDUtility defaultUtility] searchDirectory:KDDownloadDocument inDomainMask:KDTemporaryDomainMask needCreate:YES];
}

+ (NSString *)defaultDownloadDocTempDir {
    return [[KDUtility defaultUtility] searchDirectory:KDDownloadDocumentTemp inDomainMask:KDTemporaryDomainMask needCreate:YES];
}

- (id) init {
    self = [super init];
    if (self) {
        //
        //downloadId_ = NULL;
        entityType_ = -1;
        downloadState_ = KDDownloadStateNot;
        
    }
    return self;
}

+ (void) downloadsWithData:(NSArray *)data finishBlock:(detectionFinishedBlock)finishBlock
{
    if ([date count ] > 0) {
        <#statements#>
    }
}


+ (void)determinState:(NSMutableArray *)array finishBlock:(void (^)(NSArray *array))finishBlock {
    if (array) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSFileManager *fileManager = [ NSFileManager defaultManager];
            for (KDDownload *download in array) {
                if ([fileManager fileExistsAtPath:download.path]) {
                    download.downloadState = KDDownloadStateSuccess;
                    //                    NSLog(@"fileExsit");
                }else if ([fileManager fileExistsAtPath:download.tempPath]) {
                    download.downloadState = KDDownloadStateFailed;
                    //                    NSLog(@"fileNotExsit...");
                }
            }
            if (finishBlock != nil) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    finishBlock(array);
                });
            }
        });
    }
    
}



+ (NSString *)configFileURL {
    return [[KDDownload defaultDownloadDocDir] stringByAppendingPathComponent:@"config_download.plist"];
}

+ (NSMutableDictionary *)configPlist {
    static NSMutableDictionary *configPlist_ = nil;
    
    if(!configPlist_) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isExist = [fileManager fileExistsAtPath:[KDDownload configFileURL]];
        
        if(!isExist) {
            configPlist_ = [[NSMutableDictionary alloc] initWithCapacity:3];
            [fileManager createFileAtPath:[KDDownload configFileURL] contents:nil attributes:nil];
        }else {
            configPlist_ = [[NSMutableDictionary alloc] initWithContentsOfFile:[KDDownload configFileURL]];
        }
        
        if(configPlist_ == nil) {
            configPlist_ = [[NSMutableDictionary alloc] initWithCapacity:3];
        }
    }
    
    return configPlist_;
}

//+ (KDDownload *) downloadFromPersistenceWithAttachmentId:(NSString *)attachmentId {
//    KDDownload *downloader = nil;
//    id<KDDownloadProvider> downloadProvider = [[KDProviderContext defaultProviderContext] getDownloadProvider];
//    NSArray *array = [downloadProvider downloadWithAttachmentId:attachmentId];
//    if (array && [array count] > 0) {
//        downloader =  [array lastObject];
//    }
//    return downloader;
//}


+ (BOOL) deleteFromPersisten:(KDDownload *)download {
    NSMutableDictionary *configPlist = [self configPlist];
    
    NSDictionary *info = [configPlist objectForKey:download.downloadId];
    
    NSString *fileName = [info objectForKey:KD_ATTACHMENT_FILE_NAME];
    NSString *fileURL = [[KDDownload defaultDownloadDocDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", download.downloadId, [fileName pathExtension]]];
    
    NSError *error;
    BOOL succeed = [[NSFileManager defaultManager] removeItemAtPath:fileURL error:&error];
    
    if(succeed) {
        [configPlist removeObjectForKey:download.downloadId];
        
        return [configPlist writeToFile:[self configFileURL] atomically:YES];
    } else {
        NSLog(@"remove file error : %@", error);
    }
    
    return succeed;
}

+ (NSArray *) allDownloadedDocuments {
    NSMutableDictionary *configPlist = [self configPlist];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:configPlist.count];
    
    for(NSString *fileId in [configPlist allKeys]) {
        KDDownload *downLoad = [[KDDownload alloc] init];
        downLoad.downloadId = fileId;
        
        NSDictionary *info = [configPlist objectForKey:fileId];
        
        downLoad.name = [info objectForKey:KD_ATTACHMENT_FILE_NAME];
        downLoad.maxByte = [[info objectForKey:KD_ATTACHMENT_FILE_SIZE] intValue];
        downLoad.endAt = [[info objectForKey:KD_ATTACHMENT_CREATE_AT] doubleValue];
        downLoad.path = [[KDDownload defaultDownloadDocDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", downLoad.downloadId, [downLoad.name pathExtension]]];
        
        [result addObject:downLoad];
        [downLoad release];
    }
    
    return result;
}

+ (BOOL) deleteAllDownloadsFromPersistence {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL result = NO;
    NSError *removeError = nil;
    
    result = [fileManager removeItemAtPath:[KDDownload defaultDownloadDocDir] error:&removeError];
    
    if(removeError) {
        DLog(@"removeError:%@", removeError);
    }
    
    return result;
}

+ (void) saveDownloads:(NSArray *)downloads {
    NSAssert(downloads != nil, @"The downloads can not be nil.");
    
    for(KDDownload *downLoad in downloads) {
        if(![downLoad.name hasSuffix:@".amr"] && ![downLoad.name hasSuffix:@".mp4"]) {
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:downLoad.name, KD_ATTACHMENT_FILE_NAME,
                                  @(downLoad.maxByte), KD_ATTACHMENT_FILE_SIZE,
                                  @(downLoad.endAt), KD_ATTACHMENT_CREATE_AT, nil];
            [[KDDownload configPlist] setObject:info forKey:downLoad.downloadId];
        }
    }
    
    [[KDDownload configPlist] writeToFile:[KDDownload configFileURL] atomically:YES];
}

- (void)insertToDB {
    [KDDownload saveDownloads:[NSArray arrayWithObject:self]];
}

- (NSUInteger)identifier {
    return [downloadId_ hash];
}


- (void)loadPath {
    NSString *pesistceName = [downloadId_ stringByAppendingFormat:@".%@",[name_ pathExtension]];
    if([name_ hasSuffix:@".amr"]) {
        self.path = [[[KDUtility defaultUtility] searchDirectory:KDDownloadAudio inDomainMask:KDTemporaryDomainMask needCreate:YES] stringByAppendingPathComponent:pesistceName];
        self.tempPath = [[[KDUtility defaultUtility] searchDirectory:KDDownloadAudioTemp inDomainMask:KDTemporaryDomainMask needCreate:YES] stringByAppendingPathComponent:downloadId_];
    } else if([name_ hasSuffix:@".mp4"]) {
        self.path = [[[KDUtility defaultUtility] searchDirectory:KDVideosDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES] stringByAppendingPathComponent:pesistceName];
        self.tempPath = [[[KDUtility defaultUtility] searchDirectory:KDDownloadVideosTempDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES] stringByAppendingPathComponent:pesistceName];
    } else {
        self.path =  [[KDDownload defaultDownloadDocDir] stringByAppendingPathComponent:pesistceName];
        self.tempPath = [[KDDownload defaultDownloadDocTempDir] stringByAppendingPathComponent:downloadId_];
    }
}

- (void)determinState {
    NSFileManager *fileManager = [ NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:self.path]) {
        self.downloadState = KDDownloadStateSuccess;
        //        NSLog(@"fileExsit");
    }else if ([fileManager fileExistsAtPath:self.tempPath]) {
        self.downloadState = KDDownloadStateFailed;
        //        NSLog(@"fileNotExsit...");
    }
    
}


+ (void)grabExistingDowndsWithfinishBlock:(void(^)(NSArray *array))finishBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSArray *downloads = [KDDownload allDownloadedDocuments];
        NSMutableArray *array  = [NSMutableArray array];
        NSFileManager *fileManager = [ NSFileManager defaultManager];
        for (KDDownload *download in downloads) {
            if ([fileManager fileExistsAtPath:download.path]) {
                [array addObject:download];
            }
        }
        array = [array count]>0?array:nil;
        if (finishBlock != nil) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                finishBlock(array);
            });
        }
        
    });
    
}

+ (void) downloadsWithAttachemnts:(NSArray *)attachemnts Status:(KDStatus *)status finishBlock:(detectionFinishedBlock)finishBlock {
    [KDDownload downloadsWithAttachemnts:attachemnts statusId:status.statusId finishBlock:finishBlock];
}

+ (void) downloadsWithAttachemnts:(NSArray *)attachemnts statusId:(NSString *)statusId finishBlock:(detectionFinishedBlock)finishBlock
{
    if (attachemnts == nil) {
        return;
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[attachemnts count]];
    KDDownload *download = nil;
    for (KDAttachment *attachment in attachemnts) {
        download = [[KDDownload alloc] init];
        download.downloadId = attachment.fileId;
        download.entityId = statusId;
        download.url = attachment.url;
        download.mimeType = attachment.contentType;
        download.name = attachment.filename;
        download.maxByte = attachment.fileSize;
        download.entityType = KDDownloadEntityTypeStatus;
        [download loadPath];
        
        [array addObject:download];
        [download release];
    }
    
    [KDDownload determinState:array finishBlock:finishBlock];
}

+ (void) downloadsWithAttachemnts:(NSArray *)attachemnts diretMessage:(KDDMMessage *)message finishBlock:(detectionFinishedBlock)finishBlock {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[attachemnts count]];
    KDDownload *download = nil;
    
    for (KDAttachment *attachment in attachemnts) {
        download = [[KDDownload alloc] init];
        download.downloadId = attachment.fileId;
        download.entityId = message.messageId;
        download.url = attachment.url;
        download.mimeType = attachment.contentType;
        download.name = attachment.filename;
        download.maxByte = attachment.fileSize;
        download.entityType = KDDownloadEntityTypeMessage;
        [download loadPath];
        
        [array addObject:download];
        [download release];
    }
    
    [KDDownload determinState:array finishBlock:finishBlock];
}

- (void) startDownload {
    self.downloadState = KDDownloadStateDownloading;
    self.startAt = [[NSDate date] timeIntervalSince1970];
    [self insertToDB];
    
}

- (void) downloadFailed {
    self.downloadState = KDDownloadStateFailed;
    self.endAt = [[NSDate date] timeIntervalSince1970];
    [self insertToDB];
    
}

- (void) downloadSucceed {
    self.downloadState = KDDownloadStateSuccess;
    self.endAt = [[NSDate date] timeIntervalSince1970];
    [self insertToDB];
}

- (void) downloadCancled {
    self.downloadState = KDDownloadStateCancled;
    self.endAt = [[NSDate date] timeIntervalSince1970];
    [self insertToDB];
    
}

- (BOOL) isDownloading {
    
    return (self.downloadState == KDDownloadStateDownloading);
}

- (BOOL) isCancled {
    
    return (self.downloadState == KDDownloadStateCancled);
}

- (BOOL) isSuccess {
    
    return (self.downloadState == KDDownloadStateSuccess);
}

- (BOOL) isFailed {
    return (self.downloadState == KDDownloadStateFailed);
    
}

//ipad 的右挡板交换时用 iphone 忽略
- (NSString *)id_ {
    return downloadId_;
}

- (void) dealloc {
    KD_RELEASE_SAFELY(name_);
    KD_RELEASE_SAFELY(downloadId_);
    KD_RELEASE_SAFELY(entityId_);
    KD_RELEASE_SAFELY(url_);
    KD_RELEASE_SAFELY(path_);
    KD_RELEASE_SAFELY(tempPath_);
    KD_RELEASE_SAFELY(mimeType_);
    [super dealloc];
}

@end
