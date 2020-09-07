//
//  KDAttachmentDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDAttachmentDAOImpl.h"
#import "KDAttachment.h"

@implementation KDAttachmentDAOImpl

- (void)saveAttachment:(KDAttachment *)attachment database:(FMDatabase *)fmdb {
    if (attachment != nil) {
        [self saveAttachments:@[attachment] database:fmdb];
    }
}

- (void)saveAttachments:(NSArray *)attachments database:(FMDatabase *)fmdb {
    if (attachments == nil || [attachments count] == 0) return;
    
    NSString *sql = @"REPLACE INTO attachments(id, object_id, name, content_type, url, file_size)"
                     " VALUES(?, ?, ?, ?, ?, ?);";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    for (KDAttachment *item in attachments) {
        int idx = 1;
        
        [stmt bindString:item.fileId atIndex:idx++];
        [stmt bindString:item.objectId atIndex:idx++];
        [stmt bindString:item.filename atIndex:idx++];
        [stmt bindString:item.contentType atIndex:idx++];
        [stmt bindString:item.url atIndex:idx++];
        
        [stmt bindUnsignedLongLong:item.fileSize atIndex:idx++];
        
        // step
        if (![stmt step]) {
            DLog(@"Can not save attachment with id=%@", item.fileId);
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
}

- (NSArray *)attachmentsWithResultSet:(FMResultSet *)rs {
    KDAttachment *item = nil;
    NSMutableArray *attachments = [NSMutableArray array];
    
    while ([rs next]) {
        item = [[KDAttachment alloc] init];
        
        int idx = 0;
        item.fileId = [rs stringForColumnIndex:idx++];
        item.filename = [rs stringForColumnIndex:idx++];
        item.contentType = [rs stringForColumnIndex:idx++];
        item.url = [rs stringForColumnIndex:idx++];
        item.fileSize = [rs unsignedLongLongIntForColumnIndex:idx];
        
        [attachments addObject:item];
    }
    
    return attachments;
}

- (NSArray *)queryAttachmentsWithObjectId:(NSString *)objectId database:(FMDatabase *)fmdb {
    if (objectId == nil) return nil;
    
    NSString *sql = @"SELECT id, name, content_type, url, file_size FROM attachments WHERE object_id=?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, objectId];
    NSArray *attactments = [self attachmentsWithResultSet:rs];
    [attactments setValue:objectId forKeyPath:@"objectId"];
    
    [rs close];
    
    return attactments;
}

- (BOOL)removeAttachmentsForObjectId:(NSString *)objectId database:(FMDatabase *)fmdb {
    if (objectId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM attachments WHERE object_id=?;", objectId];
}

@end
