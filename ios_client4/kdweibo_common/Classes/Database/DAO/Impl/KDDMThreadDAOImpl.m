//
//  KDDMThreadDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDDMThreadDAOImpl.h"
#import "KDDMThread.h"
#import "KDUser.h"

#import "KDWeiboDAOManager.h"

@implementation KDDMThreadDAOImpl

#define KD_DM_THREAD_AVATAR_URL_SEPARATOR    @"__kdsp__"

- (BOOL)_cleanExpiredThreadWithLimit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"DELETE FROM dm_threads WHERE is_Top =? AND thread_id NOT IN (SELECT thread_id FROM unsend_messages) AND updated_at < (SELECT MIN(tmp.updated_at)"
    " FROM (SELECT updated_at FROM dm_threads ORDER BY updated_at DESC LIMIT ?) AS tmp);";
    
    return [fmdb executeUpdate:sql, @(NO),@(limit)];

}

- (NSString *)_combineAvatarURLs:(NSArray *)avatarURLs {
    NSString *urls = nil;
    if (avatarURLs != nil) {
        urls = [avatarURLs componentsJoinedByString:KD_DM_THREAD_AVATAR_URL_SEPARATOR];
    }
    
    return urls;
}

- (NSArray *)_splitAvatarURLs:(NSString *)urls {
    return (urls != nil) ? [urls componentsSeparatedByString:KD_DM_THREAD_AVATAR_URL_SEPARATOR] : nil;
}

- (NSArray *)_dmThreadsWithResultSet:(FMResultSet *)rs database:(FMDatabase *)fmdb {
    KDDMThread *t = nil;
    NSMutableArray *threads = [NSMutableArray array];
    
    int idx;
    while ([rs next]) {
        t = [[KDDMThread alloc] init];
        
        idx = 0;
        t.threadId = [rs stringForColumnIndex:idx++];
        t.subject = [rs stringForColumnIndex:idx++];
        t.avatarURL = [rs stringForColumnIndex:idx++];
        
        t.createdAt = [rs doubleForColumnIndex:idx++];
        t.updatedAt = [rs doubleForColumnIndex:idx++];
        
        t.latestDMId = [rs stringForColumnIndex:idx++];
        t.latestDMText = [rs stringForColumnIndex:idx++];
        t.latestDMSenderId = [rs stringForColumnIndex:idx++];
        
        t.unreadCount = [rs intForColumnIndex:idx++];
        t.participantIDs = [rs stringForColumnIndex:idx++];
        t.participantsCount = [rs intForColumnIndex:idx++];
        t.participantAvatarURLs = [self _splitAvatarURLs:[rs stringForColumnIndex:idx++]];
        t.isPublic = [rs boolForColumnIndex:idx++];
        t.isTop = [rs boolForColumnIndex:idx++];

        
        [threads addObject:t];
    }
    
    // retrieve latest direct message sender for each thread
    if (threads != nil && [threads count] > 0) {
        for (KDDMThread *t in threads) {
            t.latestSender = [KDUser userWithId:t.latestDMSenderId database:fmdb];
        }
    }
    
    return threads;
}

- (BOOL)_dMThreadExistWithId:(NSString *)threadId isTop:(BOOL)top database:(FMDatabase *)fmdb
{
    if (threadId == nil) return FALSE;
    
    NSString *sql = @"SELECT count(*) FROM dm_threads WHERE thread_id=? AND is_Top=?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql,threadId,@(top)];
    
    int count = 0;
    while ([rs next]) {
        count = [rs intForColumnIndex:0];
    }
    [rs close];
    
    if (count == 0)  return FALSE;
    
    return TRUE;
    
}

- (BOOL)removeTopDMThreads_database:(FMDatabase *)fmdb
{
    return [fmdb executeUpdate:@"DELETE FROM dm_threads WHERE is_Top=?",@(YES)];
}
- (BOOL)resetTopStatus_database:(FMDatabase *)fmdb
{
    return [fmdb executeUpdate:@"UPDATE dm_threads SET is_Top = ? WHERE is_Top = ?", @(NO), @(YES)];
}
- (BOOL)setTopDMThreadWithId:(NSString *)threadId database:(FMDatabase *)fmdb
{
    if ([self _dMThreadExistWithId:threadId isTop:YES database:fmdb])
        return [self removeDMThreadWithId:threadId isTop:NO database:fmdb];
    else
        return [fmdb executeUpdate:@"UPDATE dm_threads SET is_Top = ? WHERE thread_id = ?", @(YES), threadId];
}
- (BOOL)cancelTopDMThreadWithId:(NSString *)threadId database:(FMDatabase *)fmdb
{
    if ([self _dMThreadExistWithId:threadId isTop:NO database:fmdb])
        return [self removeDMThreadWithId:threadId isTop:YES database:fmdb];
    else
        return [fmdb executeUpdate:@"UPDATE dm_threads SET is_Top = ? WHERE thread_id = ?", @(NO), threadId];
}


- (void)saveDMThreads:(NSArray *)threads database:(FMDatabase *)fmdb rollback:(BOOL *)rollback {
    if (threads == nil || [threads count] == 0) return;
    
    NSString *sql = @"REPLACE INTO dm_threads(thread_id, subject, thread_avatar_url, created_at,"
    " updated_at, latest_dm_id, latest_dm_text, latest_dm_sender_id, unread_count,"
    " participant_ids, participants_count, participant_urls, public, is_Top)"
    " VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    int idx;
    for (KDDMThread *t in threads) {
        idx = 1;
        [stmt bindString:t.threadId atIndex:idx++];
        [stmt bindString:t.subject  atIndex:idx++];
        [stmt bindString:t.avatarURL atIndex:idx++];
        
        [stmt bindDouble:t.createdAt atIndex:idx++];
        [stmt bindDouble:t.updatedAt atIndex:idx++];
        
        [stmt bindString:t.latestDMId atIndex:idx++];
        [stmt bindString:t.latestDMText atIndex:idx++];
        [stmt bindString:t.latestDMSenderId atIndex:idx++];
        
        [stmt bindInt:(int)t.unreadCount atIndex:idx++];
        
        [stmt bindString:t.participantIDs atIndex:idx++];
        [stmt bindInt:(int)t.participantsCount atIndex:idx++];
        [stmt bindString:[self _combineAvatarURLs:t.participantAvatarURLs] atIndex:idx++];
        [stmt bindBool:t.isPublic atIndex:idx++];
        [stmt bindBool:t.isTop atIndex:idx++];
        
        // step
        if ([stmt step]) {
            KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
            
            // save the sender of last direct message
            [[manager userDAO] saveUser:t.latestSender database:fmdb];
            
        } else {
            *rollback = YES;
            
            DLog(@"Can not save dm thread with id=%@", t.threadId);
            
            break;
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
    
    if (![self _cleanExpiredThreadWithLimit:20 database:fmdb]) {
        NSLog(@"can't clean expired threads");
    }
}



- (KDDMThread *)queryDMThreadWithId:(NSString *)threadId database:(FMDatabase *)fmdb {
    if (threadId == nil) return nil;
    
    NSString *sql = @"SELECT thread_id, subject, thread_avatar_url, created_at, updated_at,"
    " latest_dm_id, latest_dm_text, latest_dm_sender_id, unread_count,"
    " participant_ids, participants_count, participant_urls, public, is_Top"
    " FROM dm_threads WHERE thread_id = ?";
    
    FMResultSet *rs = [fmdb executeQuery:sql, threadId];
    
    KDDMThread *thread = nil;
    NSArray *items = [self _dmThreadsWithResultSet:rs database:fmdb];
    
    if (items != nil && [items count] > 0) {
        thread = items[0];
    }
    
    [rs close];
    
    return thread;
}

- (NSArray *)queryTopDMThreads_database:(FMDatabase *)fmdb{
    
    NSString *sql = @"SELECT thread_id, subject, thread_avatar_url, created_at, updated_at,"
    " latest_dm_id, latest_dm_text, latest_dm_sender_id, unread_count,"
    " participant_ids, participants_count, participant_urls, public, is_Top"
    " FROM dm_threads WHERE is_Top=? ORDER BY updated_at DESC";
    
    FMResultSet *rs = [fmdb executeQuery:sql,@(YES)];
    NSArray *threads = [self _dmThreadsWithResultSet:rs database:fmdb];
    [rs close];
    
    return threads;
}

- (NSArray *)queryDMThreadsWithLimit:(NSInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"SELECT thread_id, subject, thread_avatar_url, created_at, updated_at,"
    " latest_dm_id, latest_dm_text, latest_dm_sender_id, unread_count,"
    " participant_ids, participants_count, participant_urls, public, is_Top"
    " FROM dm_threads WHERE is_Top=? ORDER BY updated_at DESC LIMIT ?";
    
    FMResultSet *rs = [fmdb executeQuery:sql,@(NO),@(limit)];
    NSArray *threads = [self _dmThreadsWithResultSet:rs database:fmdb];
    [rs close];
    
    return threads;
}

- (BOOL)removeDMThreadWithId:(NSString *)threadId isTop:(BOOL)isTop database:(FMDatabase *)fmdb
{
    if (threadId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM dm_threads WHERE thread_id=? AND is_Top=?;", threadId,@(isTop)];
}

- (BOOL)removeDMThreadWithId:(NSString *)threadId database:(FMDatabase *)fmdb {
    if (threadId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM dm_threads WHERE thread_id=?;", threadId];
}

- (BOOL)removeAllDMThreadsInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM dm_threads;"];
}

@end
