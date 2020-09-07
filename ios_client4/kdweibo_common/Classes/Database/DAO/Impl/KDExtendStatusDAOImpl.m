//
//  KDExtendStatusDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-5.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDExtendStatusDAOImpl.h"
#import "KDWeiboDAOManager.h"
#import "KDExtendStatus.h"

@implementation KDExtendStatusDAOImpl

- (void)_saveExtendStatusExtraSource:(KDExtendStatus *)status database:(FMDatabase *)fmdb {
    // save images
    if (status.extraSourceMask & KDExtraSourceMaskImages) {
        KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
        [[manager compositeImageSourceDAO] saveCompositeImageSource:status.compositeImageSource entityId:status.statusId database:fmdb];
    }
}

- (void)_queryExtendStatusExtraSource:(KDExtendStatus *)status database:(FMDatabase *)fmdb {
    // retrieve images
    if (status.extraSourceMask & KDExtraSourceMaskImages) {
        KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
        status.compositeImageSource = [[manager compositeImageSourceDAO] queryCompositeImageSourceWithEntityId:status.statusId database:fmdb];
    }
}

- (void)saveExtendStatus:(KDExtendStatus *)status database:(FMDatabase *)fmdb {
    if (status == nil) return;
    
    NSString *sql = @"REPLACE INTO extend_statuses(id, site, content, sender_name, fwd_sender_name,"
                     " fwd_content, created_at, forwarded_at, mask) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx = 1;
    [stmt bindString:status.statusId atIndex:idx++];
    [stmt bindString:status.site  atIndex:idx++];
    [stmt bindString:status.content atIndex:idx++];
    [stmt bindString:status.senderName atIndex:idx++];
    [stmt bindString:status.forwardedSenderName atIndex:idx++];
    [stmt bindString:status.forwardedContent atIndex:idx++];
    
    [stmt bindInt:(int)status.createdAt atIndex:idx++];
    [stmt bindInt:(int)status.forwardedAt atIndex:idx++];
    [stmt bindInt:(int)status.extraSourceMask atIndex:idx++];
    
    // step
    if ([stmt step]) {
        [self _saveExtendStatusExtraSource:status database:fmdb];
        
    } else {
        DLog(@"Can not save extend status with id=%@", status.statusId);
    }
    
    // finalize prepared statement
    [stmt close];
}

- (KDExtendStatus *)queryExtendStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb {
    if (statusId == nil) return nil;
    
    NSString *sql = @"SELECT site, content, sender_name, fwd_sender_name, fwd_content, created_at,"
                     " forwarded_at, mask FROM extend_statuses WHERE id = ?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, statusId];
    
    KDExtendStatus *s = nil;
    if ([rs next]) {
        s = [[KDExtendStatus alloc] init];// autorelease];
        
        int idx = 0;
        s.statusId = statusId;
        s.site = [rs stringForColumnIndex:idx++];
        s.content = [rs stringForColumnIndex:idx++];
        s.senderName = [rs stringForColumnIndex:idx++];
        s.forwardedSenderName = [rs stringForColumnIndex:idx++];
        s.forwardedContent = [rs stringForColumnIndex:idx++];
        
        s.createdAt = [rs intForColumnIndex:idx++];
        s.forwardedAt = [rs intForColumnIndex:idx++];
        s.extraSourceMask = [rs intForColumnIndex:idx++];
        
        if (s.extraSourceMask) {
            [self _queryExtendStatusExtraSource:s database:fmdb];
        }
    }
    
    [rs close];
    
    return s;
}

- (BOOL)removeExtendStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb {
    if (statusId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM extend_statuses WHERE id=?;", statusId];
}

- (BOOL)removeAllExtendStatusesInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM extend_statuses;"];
}

@end
