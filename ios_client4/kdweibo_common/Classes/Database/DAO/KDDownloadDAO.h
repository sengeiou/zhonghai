//
//  KDDownloadDAO.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class KDDownload;

@protocol KDDownloadDAO <NSObject>
@required

- (void)saveDownload:(KDDownload *)download database:(FMDatabase *)fmdb;
- (void)saveDownloads:(NSArray *)downloads database:(FMDatabase *)fmdb;

- (NSArray *)queryDownloadsWithAttachmentId:(NSString *)attachmentId database:(FMDatabase *)fmdb;
- (NSArray *)queryAllFinishedDownloads:(NSInteger)state database:(FMDatabase *)fmdb;

- (BOOL)removeDownloadWithId:(NSString *)downloadId database:(FMDatabase *)fmdb;
- (BOOL)removeAllDownloadsInDatabase:(FMDatabase *)fmdb;

@end
