//
//  KDDownloadDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDDownloadDAOImpl.h"
#import "KDDownload.h"

@implementation KDDownloadDAOImpl

- (void)saveDownload:(KDDownload *)download database:(FMDatabase *)fmdb {
    if (download != nil) {
        [self saveDownloads:@[download] database:fmdb];
    }
}

- (void)saveDownloads:(NSArray *)downloads database:(FMDatabase *)fmdb {
    if (downloads == nil || [downloads count] == 0) return;
    
    NSString *sql = @"REPLACE INTO downloads(id, name, entity_id, entity_type, start_at, end_at,"
                     " url, path, temp_path, downdload_state, current_byte, max_byte, mime_type)"
                     " VALUES( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    for (KDDownload *d in downloads) {
        int idx = 1;
        
        [stmt bindString:d.downloadId atIndex:idx++];
        [stmt bindString:d.name atIndex:idx++];
        [stmt bindString:d.entityId atIndex:idx++];
        
        [stmt bindInt:d.entityType atIndex:idx++];
        [stmt bindDouble:d.startAt atIndex:idx++];
        [stmt bindDouble:d.endAt atIndex:idx++];
        
        [stmt bindString:d.url atIndex:idx++];
        [stmt bindString:d.path atIndex:idx++];
        [stmt bindString:d.tempPath atIndex:idx++];
        
        [stmt bindInt:d.downloadState atIndex:idx++];
        
        [stmt bindUnsignedLongLong:d.currentByte atIndex:idx++];
        [stmt bindUnsignedLongLong:d.maxByte atIndex:idx++];
        
        [stmt bindString:d.mimeType atIndex:idx++];
        
        // step
        if (![stmt step]) {
            DLog(@"Can not save download with id=%@", d.downloadId);
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
}

- (NSArray *)downloadsWithResultSet:(FMResultSet *)rs {
    KDDownload *d = nil;
    NSMutableArray *downloads = [NSMutableArray array];
    
    while ([rs next]) {
        d = [[KDDownload alloc] init];
        
        int idx = 0;
        d.downloadId = [rs stringForColumnIndex:idx++];
        d.name = [rs stringForColumnIndex:idx++];
        d.entityId = [rs stringForColumnIndex:idx++];
        d.entityType = [rs intForColumnIndex:idx++];
        
        d.startAt = [rs doubleForColumnIndex:idx++];
        d.endAt = [rs doubleForColumnIndex:idx++];
        
        d.url = [rs stringForColumnIndex:idx++];
        d.path = [rs stringForColumnIndex:idx++];
        d.tempPath = [rs stringForColumnIndex:idx++];
        
        d.downloadState = [rs intForColumnIndex:idx++];
        
        d.currentByte = [rs unsignedLongLongIntForColumnIndex:idx++];
        d.maxByte = [rs unsignedLongLongIntForColumnIndex:idx++];
        
        d.mimeType = [rs stringForColumnIndex:idx++];
        
        [downloads addObject:d];
    }
    
    return downloads;
}

- (NSArray *)queryDownloadsWithAttachmentId:(NSString *)attachmentId database:(FMDatabase *)fmdb {
    if (attachmentId == nil) return nil;
    
    NSString *sql = @"SELECT id, name, entity_id, entity_type, start_at, end_at, url , path,"
                     " temp_path, downdload_state, current_byte, max_byte, mime_type FROM downloads"
                     " WHERE id = ?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, attachmentId];
    NSArray *downloads = [self downloadsWithResultSet:rs];
    [rs close];
    
    return downloads;
}

- (NSArray *)queryAllFinishedDownloads:(NSInteger)state database:(FMDatabase *)fmdb {
    NSString *sql = @"SELECT id, name, entity_id, entity_type, start_at, end_at, url, path,"
                     " temp_path, downdload_state, current_byte, max_byte ,mime_type FROM downloads"
                     " WHERE downdload_state = ? ORDER BY end_at DESC;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, @(state)];
    NSArray *downloads = [self downloadsWithResultSet:rs];
    [rs close];
    
    return downloads;
}

- (BOOL)removeDownloadWithId:(NSString *)downloadId database:(FMDatabase *)fmdb {
    if (downloadId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM downloads WHERE id = ?;", downloadId];
}

- (BOOL)removeAllDownloadsInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM downloads;"];
}

@end
