//
//  KDStatusDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-5.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDStatusDAOImpl.h"
#import "KDWeiboDAOManager.h"

#import "KDUser.h"
#import "KDCommentMeStatus.h"
#import "KDMentionMeStatus.h"
#import "KDGroupStatus.h"
#import "KDStatusCounts.h"

static NSString * const kDAOStatusAuthorId = @"aId";
static NSString * const kDAOStatusForwardedStatusId = @"fwd_statusId";
static NSString * const kDAOStatusExtendStatusId = @"extend_statusId";
static NSString * const kDAOStatusExtraMessageId = @"extra_messageId";

@interface KDStatusDAOImpl ()
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@end

@implementation KDStatusDAOImpl

//zgbin:动态-给数据库加字段
+ (KDStatusDAOImpl *)sharedStatusDAOInstance
{
    static dispatch_once_t pred;
    static KDStatusDAOImpl *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[KDStatusDAOImpl alloc] init];
    });
    return instance;
}

- (void)addField {
    __block BOOL result = YES;
    
    //新建表
    [self.databaseQueue inTransaction: ^(FMDatabase *db, BOOL *rollback) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = nil;
        // APP由升级更新到最新版本时, 由于不会走建表的流程, 所以通过追加字段的方式添加.
        //应用表添加字段 microBlogCommentsJsonstr
        if (![self existFieldInTable:@"statuses_v2" fieldName:@"likeUserInfosJsonstr" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'likeUserInfosJsonstr' VARCHAR", @"statuses_v2"];
            result = result && [db executeUpdate:sql];
        }
        //应用表添加字段 likeUserInfosJsonstr
        if (![self existFieldInTable:@"statuses_v2" fieldName:@"microBlogCommentsJsonstr" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'microBlogCommentsJsonstr' VARCHAR", @"statuses_v2"];
            result = result && [db executeUpdate:sql];
        }
        
    }];
}

- (void)addFieldWithFMDatabase:(FMDatabase *)fmdb{
    BOOL result = YES;
    NSString *sql = nil;
    // APP由升级更新到最新版本时, 由于不会走建表的流程, 所以通过追加字段的方式添加.
    //应用表添加字段 microBlogCommentsJsonstr
    if (![self existFieldInTable:@"statuses_v2" fieldName:@"likeUserInfosJsonstr" db:fmdb]) {
        sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'likeUserInfosJsonstr' VARCHAR", @"statuses_v2"];
        result = result && [fmdb executeUpdate:sql];
    }
    //应用表添加字段 likeUserInfosJsonstr
    if (![self existFieldInTable:@"statuses_v2" fieldName:@"microBlogCommentsJsonstr" db:fmdb]) {
        sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'microBlogCommentsJsonstr' VARCHAR", @"statuses_v2"];
        result = result && [fmdb executeUpdate:sql];
    }
}
//zgbin:end

- (void)_saveStatusProperties:(KDStatus *)status database:(FMDatabase *)fmdb {
    KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
    
    // save author
    [[manager userDAO] saveUser:status.author database:fmdb];
    
    if (status.forwardedStatus != nil) {
        // save forwarded status
        [[manager statusDAO] saveForwardedStatus:status.forwardedStatus database:fmdb];
    }
    
    if (status.extendStatus != nil) {
        // save extend status
        [[manager extendStatusDAO] saveExtendStatus:status.extendStatus database:fmdb];
    }
    
    // save status extra message
    if (status.extraMessage != nil) {
        [[manager statusExtraMessageDAO] saveStatusExtraMessage:status.extraMessage database:fmdb];
    }
    
    // save status extra content
    if (status.extraSourceMask) {
        [self _saveStatusExtraSource:status database:fmdb];
    }
}

- (void)_queryStatusProperties:(KDStatus *)status info:(NSDictionary *)info database:(FMDatabase *)fmdb {
    KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
    
    NSString *entityId = nil;
    
    // query author
    if ((entityId = [info objectForKey:kDAOStatusAuthorId]) != nil) {
        status.author = [KDUser userWithId:entityId database:fmdb];
    }
    
    // query forwarded status
    if ((entityId = [info objectForKey:kDAOStatusForwardedStatusId]) != nil) {
        status.forwardedStatus = [[manager statusDAO] queryForwardedStatusWithId:entityId database:fmdb];
    }
    
    // query extend status
    if ((entityId = [info objectForKey:kDAOStatusExtendStatusId]) != nil) {
        status.extendStatus = [[manager extendStatusDAO] queryExtendStatusWithId:entityId database:fmdb];
    }
    
    // query status extra message
    if ((entityId = [info objectForKey:kDAOStatusExtraMessageId]) != nil) {
        status.extraMessage = [[manager statusExtraMessageDAO] queryStatusExtraMessageWithId:entityId database:fmdb];
    }
    
    // query status extra content
    if (status.extraSourceMask) {
        [self _queryStatusExtraSource:status database:fmdb];
    }
}


- (void)_saveStatusExtraSource:(KDStatus *)status database:(FMDatabase *)fmdb {
    // save images
    if (status.extraSourceMask & KDExtraSourceMaskImages) {
        KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
        [[manager compositeImageSourceDAO] saveCompositeImageSource:status.compositeImageSource entityId:status.statusId database:fmdb];
    }
    
    // save documents
    if (status.extraSourceMask & KDExtraSourceMaskDocuments) {
        KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
        [[manager attachmentDAO] saveAttachments:status.attachments database:fmdb];
    }
}

- (void)_queryStatusExtraSource:(KDStatus *)status database:(FMDatabase *)fmdb {
    // retrieve images
    if (status.extraSourceMask & KDExtraSourceMaskImages) {
        KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
        status.compositeImageSource = [[manager compositeImageSourceDAO] queryCompositeImageSourceWithEntityId:status.statusId database:fmdb];
    }
    
    // retrieve documents
    if (status.extraSourceMask & KDExtraSourceMaskDocuments) {
        KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
        status.attachments = [[manager attachmentDAO] queryAttachmentsWithObjectId:status.statusId database:fmdb];
    }
}

- (NSDictionary *)_statusQueryInfoWithAuthorId:(NSString *)authorId forwardedStatusId:(NSString *)forwardedStatusId
                                extendStatusId:(NSString *)extendStatusId extraMessageId:(NSString *)extraMessageId {
    NSMutableDictionary *queryInfo = [NSMutableDictionary dictionary];
    
    // author id
    if (authorId != nil) [queryInfo setObject:authorId forKey:kDAOStatusAuthorId];
    
    // forwarded status id
    if (forwardedStatusId != nil) [queryInfo setObject:forwardedStatusId forKey:kDAOStatusForwardedStatusId];
    
    // extend status id
    if (extendStatusId != nil) [queryInfo setObject:extendStatusId forKey:kDAOStatusExtendStatusId];
    
    // extra message id
    if (extraMessageId != nil) [queryInfo setObject:extraMessageId forKey:kDAOStatusExtraMessageId];
    
    
    return queryInfo;
}


/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark normal statuses

- (void)saveStatus:(KDStatus *)status database:(FMDatabase *)fmdb {
    if (status == nil) return;
    
    BOOL rollback = NO; // ignore
    [self saveStatuses:@[status] database:fmdb rollback:&rollback];
}

- (void)saveStatuses:(NSArray *)statuses database:(FMDatabase *)fmdb rollback:(BOOL *)rollback {
    if (statuses == nil || [statuses count] == 0) return;
    
    NSString *sql = @"REPLACE INTO statuses_v2(id, user_id, content, source, forwarded_status_id,"
    " extend_status_id, extra_message_id, created_at, updated_at, favorited,"
    " truncated, liked,latitude,longitude, address, comments_count, forwards_count,liked_count, type, mask, group_id,group_name, sending_state)"
    " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?);";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    for (KDStatus *s in statuses) {
        idx = 1;
        [stmt bindString:s.statusId atIndex:idx++];
        [stmt bindString:s.author.userId atIndex:idx++];
        [stmt bindString:s.text atIndex:idx++];
        [stmt bindString:s.source atIndex:idx++];
        
        [stmt bindString:((s.forwardedStatus != nil) ? s.forwardedStatus.statusId : nil) atIndex:idx++];
        [stmt bindString:((s.extendStatus != nil) ? s.extendStatus.statusId : nil) atIndex:idx++];
        [stmt bindString:((s.extraMessage != nil) ? s.extraMessage.extraId : nil) atIndex:idx++];
        
        [stmt bindDate:s.createdAt atIndex:idx++];
        [stmt bindDate:s.updatedAt atIndex:idx++];
        
        [stmt bindBool:s.favorited atIndex:idx++];
        [stmt bindBool:s.truncated atIndex:idx++];
        [stmt bindBool:s.liked atIndex:idx++];
        
        [stmt bindFloat:s.latitude atIndex:idx++];
        [stmt bindFloat:s.longitude atIndex:idx++];
        [stmt bindString:s.address atIndex:idx++];
        
        [stmt bindInt:(int)s.commentsCount atIndex:idx++];
        [stmt bindInt:(int)s.forwardsCount atIndex:idx++];
        [stmt bindInt:(int)s.likedCount atIndex:idx++];
        
        [stmt bindInt:s.type atIndex:idx++];
        [stmt bindInt:(int)s.extraSourceMask atIndex:idx++];
        [stmt bindString:s.groupId atIndex:idx++];
        [stmt bindString:s.groupName atIndex:idx++];
        [stmt bindInt:s.sendingState atIndex:idx++];
        
        // step
        if ([stmt step]) {
            [self _saveStatusProperties:s database:fmdb];
            
        } else {
            *rollback = YES;
            
            DLog(@"Can not save status with id=%@", s.statusId);
            
            break;
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
    
    // just think all the status in array has same type
    KDStatus *temp = statuses[0];
    
    // clean the expired statuses. (just keep latest 50)
    if (![self _cleanExpiredStatusesWithTLType:temp.type limit:50 database:fmdb]) {
        DLog(@"clean the expired statuses with specificed type=%d did fail.", temp.type);
    }
}

- (void)updateStatusCounts:(NSArray *)statusCounts database:(FMDatabase *)fmdb {
    if (statusCounts == nil || [statusCounts count] == 0) return;
    //zgbin:加字段
    //    NSString *sql = @"UPDATE statuses_v2 SET comments_count=?, forwards_count=?,liked_count=? WHERE id=?";
    NSString *sql = @"UPDATE statuses_v2 SET comments_count=?, forwards_count=?, liked_count=?, microBlogCommentsJsonstr=?, likeUserInfosJsonstr=? WHERE id=?";
    //zgbin:end
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    for (KDStatusCounts *sc in statusCounts) {
        idx = 1;
        
        [stmt bindInt:(int)sc.commentsCount atIndex:idx++];
        [stmt bindInt:(int)sc.forwardsCount atIndex:idx++];
        [stmt bindInt:(int)sc.likedCount atIndex:idx++];
        
        //zgbin:加字段
        NSString *microBlogCommentsJsonstr = [self jsonStringWithArray:sc.microBlogComments];
        NSString *likeUserInfosJsonstr = [self jsonStringWithArray:sc.likeUserInfos];
        [stmt bindString:microBlogCommentsJsonstr atIndex:idx++];
        [stmt bindString:likeUserInfosJsonstr atIndex:idx++];
        //zgbin:end
        
        [stmt bindString:sc.statusId atIndex:idx++];
        
        // step
        if (![stmt step]) {
            DLog(@"Can not update status counts with id=%@", sc.statusId);
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
}

- (void)updateLiked:(BOOL)liked statusId:(NSString *)theId database:(FMDatabase *)fmdb {
    if (theId == nil || theId.length == 0) {
        return;
    }
    
    NSString *sql = @"UPDATE statuses_v2 SET liked=? WHERE id=?";
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx = 1;
    
    
    [stmt bindBool:liked atIndex:idx++];
    [stmt bindString:theId atIndex:idx++];
    // step
    if (![stmt step]) {
        DLog(@"Can not update status liked with id=%@",theId);
    }
    
    // reset parameters
    [stmt reset];
    
    
    // finalize prepared statement
    [stmt close];
}

- (void)updateFavorite:(BOOL)favorite statusId:(NSString *)statusId database:(FMDatabase *)fmdb {
    if(!statusId || statusId.length == 0) return;
    
    [fmdb executeUpdate:@"UPDATE statuses_v2 SET favorite=? WHERE id=?", @(favorite), statusId];
}

- (KDStatus *)queryStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb {
    if (statusId == nil) return nil;
    
    //    NSString *sql = @"SELECT id, user_id, content, source, forwarded_status_id, extend_status_id,"
    //    " extra_message_id, created_at, updated_at, favorited, truncated, latitude,"
    //    " longitude,address, comments_count, forwards_count, mask"
    //    " FROM forwarded_statuses WHERE id=?;";
    
    
    NSString *sql = @"SELECT id, user_id, content, source, forwarded_status_id, extend_status_id,"
    " extra_message_id, created_at, updated_at, favorited, truncated, liked, latitude,"
    " longitude,address, comments_count, forwards_count,liked_count, type, mask,group_id,group_name,sending_state"
    " FROM statuses_v2  WHERE id=?;";
    
    KDStatus *s = nil;
    FMResultSet *rs = [fmdb executeQuery:sql, statusId];
    if ([rs next]) {
        s = [[KDStatus alloc] init];// autorelease];
        
        int idx = 0;
        s.statusId = [rs stringForColumnIndex:idx++];
        NSString *authorId = [rs stringForColumnIndex:idx++];
        s.text = [rs stringForColumnIndex:idx++];
        s.source = [rs stringForColumnIndex:idx++];
        
        NSString *forwardedStatusId = [rs stringForColumnIndex:idx++];
        NSString *extendStatusId = [rs stringForColumnIndex:idx++];
        NSString *extraMessageId = [rs stringForColumnIndex:idx++];
        
        s.createdAt = [rs dateForColumnIndex:idx++];
        s.updatedAt = [rs dateForColumnIndex:idx++];
        
        s.favorited = [rs boolForColumnIndex:idx++];
        s.truncated = [rs boolForColumnIndex:idx++];
        s.liked = [rs boolForColumnIndex:idx++];
        s.latitude = [rs doubleForColumnIndex:idx++];
        s.longitude = [rs doubleForColumnIndex:idx++];
        s.address = [rs stringForColumnIndex:idx++];
        s.commentsCount = [rs intForColumnIndex:idx++];
        s.forwardsCount = [rs intForColumnIndex:idx++];
        s.likedCount = [rs intForColumnIndex:idx++];
        s.type = [rs intForColumnIndex:idx++];
        s.extraSourceMask = [rs intForColumnIndex:idx++];
        s.groupId = [rs stringForColumnIndex:idx++];
        s.groupName = [rs stringForColumnIndex:idx++];
        s.sendingState = [rs intForColumnIndex:idx++];
        
        // query the properties of status
        NSDictionary *queryInfo = [self _statusQueryInfoWithAuthorId:authorId forwardedStatusId:forwardedStatusId
                                                      extendStatusId:extendStatusId extraMessageId:extraMessageId];
        
        [self _queryStatusProperties:s info:queryInfo database:fmdb];
    }
    
    [rs close];
    
    return s;
    
}

- (NSArray *)queryStatusesWithTLType:(KDTLStatusType)type limit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    
    //zgbin:加字段
    NSString *sql = @"SELECT id, user_id, content, source, forwarded_status_id, extend_status_id,"
    " extra_message_id, created_at, updated_at, favorited,truncated,liked,latitude,"
    " longitude,address, comments_count, forwards_count,liked_count, type, mask,group_id,group_name,sending_state,microBlogCommentsJsonstr,likeUserInfosJsonstr"
    " FROM statuses_v2 WHERE type=? ORDER BY created_at DESC LIMIT ?;";
    
    //    NSString *sql = @"SELECT id, user_id, content, source, forwarded_status_id, extend_status_id,"
    //    " extra_message_id, created_at, updated_at, favorited,truncated,liked,latitude,"
    //    " longitude,address, comments_count, forwards_count,liked_count, type, mask,group_id,group_name,sending_state"
    //    " FROM statuses_v2 WHERE type=? ORDER BY created_at DESC LIMIT ?;";
    //zgbin:end
    
    
    FMResultSet *rs = [fmdb executeQuery:sql, @(type), @(limit)];
    
    KDStatus *s = nil;
    NSMutableArray *statuses = [NSMutableArray array];
    int idx = 0;
    while ([rs next]) {
        idx = 0;
        s = [[KDStatus alloc] init];
        
        
        s.statusId = [rs stringForColumnIndex:idx++];
        NSString *authorId = [rs stringForColumnIndex:idx++];
        s.text = [rs stringForColumnIndex:idx++];
        s.source = [rs stringForColumnIndex:idx++];
        
        NSString *forwardedStatusId = [rs stringForColumnIndex:idx++];
        NSString *extendStatusId = [rs stringForColumnIndex:idx++];
        NSString *extraMessageId = [rs stringForColumnIndex:idx++];
        
        s.createdAt = [rs dateForColumnIndex:idx++];
        s.updatedAt = [rs dateForColumnIndex:idx++];
        
        s.favorited = [rs boolForColumnIndex:idx++];
        s.truncated = [rs boolForColumnIndex:idx++];
        s.liked = [rs boolForColumnIndex:idx++];
        //DLog(@"s.liked = %d",s.liked);
        
        s.latitude = [rs doubleForColumnIndex:idx++];
        s.longitude = [rs doubleForColumnIndex:idx++];
        s.address = [rs stringForColumnIndex:idx++];
        
        s.commentsCount = [rs intForColumnIndex:idx++];
        s.forwardsCount = [rs intForColumnIndex:idx++];
        s.likedCount = [rs intForColumnIndex:idx++];
        
        s.type = [rs intForColumnIndex:idx++];
        s.extraSourceMask = [rs intForColumnIndex:idx++];
        s.groupId = [rs stringForColumnIndex:idx++];
        s.groupName = [rs stringForColumnIndex:idx++];
        s.sendingState = [rs intForColumnIndex:idx++];
        
        //zgbin:查询加的字段数据
        NSString *microBlogCommentsJsonstr = [rs stringForColumnIndex:idx++];
        s.microBlogComments = [self arrayWithJsonString:microBlogCommentsJsonstr];
        NSString *likeUserInfosJsonstr = [rs stringForColumnIndex:idx++];
        s.likeUserInfos = [self arrayWithJsonString:likeUserInfosJsonstr];
        //zgbin:end
        
        NSDictionary *queryInfo = [self _statusQueryInfoWithAuthorId:authorId forwardedStatusId:forwardedStatusId
                                                      extendStatusId:extendStatusId extraMessageId:extraMessageId];
        
        [self _queryStatusProperties:s info:queryInfo database:fmdb];
        
        [statuses addObject:s];
        //        [s release];
    }
    
    [rs close];
    
    return statuses;
}

- (BOOL)removeStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb {
    if (statusId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM statuses_v2 WHERE id=?;", statusId];
}

- (BOOL)_cleanExpiredStatusesWithTLType:(KDTLStatusType)type limit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"DELETE FROM statuses_v2 WHERE type=? AND created_at < (SELECT MIN(tmp.created_at)"
    " FROM (SELECT created_at FROM statuses_v2 WHERE type=? ORDER BY created_at DESC LIMIT ?) AS tmp);";
    
    return [fmdb executeUpdate:sql, @(type), @(type), @(limit)];
}

- (BOOL)removeAllStatusesInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM statuses_v2;"];
}


/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark forwarded statuses

- (void)saveForwardedStatus:(KDStatus *)status database:(FMDatabase *)fmdb {
    if (status == nil) return;
    
    [self saveForwardedStatuses:@[status] database:fmdb];
}

- (void)saveForwardedStatuses:(NSArray *)statuses database:(FMDatabase *)fmdb {
    if (statuses == nil || [statuses count] == 0) return;
    
    NSString *sql = @"REPLACE INTO forwarded_statuses(id, user_id, content, source, forwarded_status_id,"
    " extend_status_id, extra_message_id, created_at, updated_at, favorited,"
    " truncated,liked, latitude, longitude, address, comments_count, forwards_count,liked_count, mask)"
    " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    for (KDStatus *s in statuses) {
        idx = 1;
        [stmt bindString:s.statusId atIndex:idx++];
        [stmt bindString:s.author.userId atIndex:idx++];
        [stmt bindString:s.text atIndex:idx++];
        [stmt bindString:s.source atIndex:idx++];
        
        [stmt bindString:((s.forwardedStatus != nil) ? s.forwardedStatus.statusId : nil) atIndex:idx++];
        [stmt bindString:((s.extendStatus != nil) ? s.extendStatus.statusId : nil) atIndex:idx++];
        [stmt bindString:((s.extraMessage != nil) ? s.extraMessage.extraId : nil) atIndex:idx++];
        
        [stmt bindDate:s.createdAt atIndex:idx++];
        [stmt bindDate:s.updatedAt atIndex:idx++];
        
        [stmt bindBool:s.favorited atIndex:idx++];
        [stmt bindBool:s.truncated atIndex:idx++];
        [stmt bindBool:s.liked atIndex:idx++];
        [stmt bindFloat:s.latitude atIndex:idx++];
        [stmt bindFloat:s.longitude atIndex:idx++];
        [stmt bindString:s.address atIndex:idx++];
        
        [stmt bindInt:(int)s.commentsCount atIndex:idx++];
        [stmt bindInt:(int)s.forwardsCount atIndex:idx++];
        [stmt bindInt:(int)s.likedCount atIndex:idx++];
        
        [stmt bindInt:(int)s.extraSourceMask atIndex:idx++];
        
        // step
        if ([stmt step]) {
            [self _saveStatusProperties:s database:fmdb];
            
        } else {
            DLog(@"Can not save forwarded status with id=%@", s.statusId);
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
}

- (KDStatus *)queryForwardedStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb {
    if (statusId == nil) return nil;
    
    NSString *sql = @"SELECT id, user_id, content, source, forwarded_status_id, extend_status_id,"
    " extra_message_id, created_at, updated_at, favorited, truncated,liked, latitude,"
    " longitude,address, comments_count, forwards_count,liked_count, mask"
    " FROM forwarded_statuses WHERE id=?;";
    
    KDStatus *s = nil;
    FMResultSet *rs = [fmdb executeQuery:sql, statusId];
    if ([rs next]) {
        s = [[KDStatus alloc] init];// autorelease];
        
        int idx = 0;
        s.statusId = [rs stringForColumnIndex:idx++];
        NSString *authorId = [rs stringForColumnIndex:idx++];
        s.text = [rs stringForColumnIndex:idx++];
        s.source = [rs stringForColumnIndex:idx++];
        
        NSString *forwardedStatusId = [rs stringForColumnIndex:idx++];
        NSString *extendStatusId = [rs stringForColumnIndex:idx++];
        NSString *extraMessageId = [rs stringForColumnIndex:idx++];
        
        s.createdAt = [rs dateForColumnIndex:idx++];
        s.updatedAt = [rs dateForColumnIndex:idx++];
        
        s.favorited = [rs boolForColumnIndex:idx++];
        s.truncated = [rs boolForColumnIndex:idx++];
        s.liked = [rs boolForColumnIndex:idx++];
        
        s.latitude = [rs doubleForColumnIndex:idx++];
        s.longitude = [rs doubleForColumnIndex:idx++];
        s.address = [rs stringForColumnIndex:idx++];
        s.commentsCount = [rs intForColumnIndex:idx++];
        s.forwardsCount = [rs intForColumnIndex:idx++];
        s.likedCount = [rs intForColumnIndex:idx++];
        
        s.extraSourceMask = [rs intForColumnIndex:idx++];
        
        // query the properties of status
        NSDictionary *queryInfo = [self _statusQueryInfoWithAuthorId:authorId forwardedStatusId:forwardedStatusId
                                                      extendStatusId:extendStatusId extraMessageId:extraMessageId];
        
        [self _queryStatusProperties:s info:queryInfo database:fmdb];
    }
    
    [rs close];
    
    return s;
}

- (BOOL)removeForwardedStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb {
    if (statusId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM forwarded_statuses WHERE id=?;", statusId];
}

- (BOOL)removeAllForwardedStatusesInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM forwarded_statuses;"];
}


/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark mention me statuses

- (void)saveMentionMeStatus:(KDMentionMeStatus *)status database:(FMDatabase *)fmdb {
    if (status == nil) return;
    
    BOOL rollback = NO;
    [self saveMentionMeStatuses:@[status] database:fmdb rollback:&rollback];
}

- (void)saveMentionMeStatuses:(NSArray *)statuses database:(FMDatabase *)fmdb rollback:(BOOL *)rollback {
    if (statuses == nil || [statuses count] == 0) return;
    
    NSString *sql = @"REPLACE INTO mention_me_statuses(id, user_id, content, source, forwarded_status_id,"
    " extend_status_id, extra_message_id, created_at, updated_at, favorited,"
    " truncated,liked, latitude, longitude, address,comments_count, forwards_count, liked_count, mask, group_id, group_name)"
    " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    for (KDMentionMeStatus *s in statuses) {
        idx = 1;
        [stmt bindString:s.statusId atIndex:idx++];
        [stmt bindString:s.author.userId atIndex:idx++];
        [stmt bindString:s.text atIndex:idx++];
        [stmt bindString:s.source atIndex:idx++];
        
        [stmt bindString:((s.forwardedStatus != nil) ? s.forwardedStatus.statusId : nil) atIndex:idx++];
        [stmt bindString:((s.extendStatus != nil) ? s.extendStatus.statusId : nil) atIndex:idx++];
        [stmt bindString:((s.extraMessage != nil) ? s.extraMessage.extraId : nil) atIndex:idx++];
        
        [stmt bindDate:s.createdAt atIndex:idx++];
        [stmt bindDate:s.updatedAt atIndex:idx++];
        
        [stmt bindBool:s.favorited atIndex:idx++];
        [stmt bindBool:s.truncated atIndex:idx++];
        [stmt bindBool:s.liked atIndex:idx++];
        [stmt bindFloat:s.latitude atIndex:idx++];
        [stmt bindFloat:s.longitude atIndex:idx++];
        [stmt bindString:s.address atIndex:idx++];
        
        [stmt bindInt:(int)s.commentsCount atIndex:idx++];
        [stmt bindInt:(int)s.forwardsCount atIndex:idx++];
        [stmt bindInt:(int)s.likedCount atIndex:idx++];
        
        [stmt bindInt:(int)s.extraSourceMask atIndex:idx++];
        
        [stmt bindString:s.groupId atIndex:idx++];
        [stmt bindString:s.groupName atIndex:idx++];
        
        // step
        if ([stmt step]) {
            [self _saveStatusProperties:s database:fmdb];
            
        } else {
            *rollback = YES;
            
            DLog(@"Can not save mention me status with id=%@", s.statusId);
            
            break;
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
    
    // clean the expired mention me statuses. (just keep latest 20)
    if (![self _cleanExpiredMentionMeStatusesWithLimit:20 database:fmdb]) {
        DLog(@"clean the expired mention me statuses did fail.");
    }
}

- (void)updateMentionMeStatusCounts:(NSArray *)statusCounts database:(FMDatabase *)fmdb {
    if (statusCounts == nil || [statusCounts count] == 0) return;
    
    NSString *sql = @"UPDATE mention_me_statuses SET comments_count=?, forwards_count=?,liked_count = ? WHERE id=?";
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    for (KDStatusCounts *sc in statusCounts) {
        idx = 1;
        
        [stmt bindString:sc.statusId atIndex:idx++];
        [stmt bindInt:(int)sc.commentsCount atIndex:idx++];
        [stmt bindInt:(int)sc.forwardsCount atIndex:idx++];
        [stmt bindInt:(int)sc.likedCount atIndex:idx++];
        // step
        if (![stmt step]) {
            DLog(@"Can not update mention me status counts with id=%@", sc.statusId);
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
}

- (NSArray *)queryMentionMeStatusesWithLimit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"SELECT id, user_id, content, source, forwarded_status_id, extend_status_id,"
    " extra_message_id, created_at, updated_at, favorited, truncated,liked,latitude,"
    " longitude, address,comments_count, forwards_count,liked_count, mask, group_id, group_name"
    " FROM mention_me_statuses ORDER BY created_at DESC LIMIT ?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, @(limit)];
    
    KDMentionMeStatus *s = nil;
    NSMutableArray *statuses = [NSMutableArray array];
    
    while ([rs next]) {
        s = [[KDMentionMeStatus alloc] init];
        
        int idx = 0;
        s.statusId = [rs stringForColumnIndex:idx++];
        NSString *authorId = [rs stringForColumnIndex:idx++];
        s.text = [rs stringForColumnIndex:idx++];
        s.source = [rs stringForColumnIndex:idx++];
        
        NSString *forwardedStatusId = [rs stringForColumnIndex:idx++];
        NSString *extendStatusId = [rs stringForColumnIndex:idx++];
        NSString *extraMessageId = [rs stringForColumnIndex:idx++];
        
        s.createdAt = [rs dateForColumnIndex:idx++];
        s.updatedAt = [rs dateForColumnIndex:idx++];
        
        s.favorited = [rs boolForColumnIndex:idx++];
        s.truncated = [rs boolForColumnIndex:idx++];
        s.liked = [rs boolForColumnIndex:idx++];
        
        s.latitude = [rs doubleForColumnIndex:idx++];
        s.longitude = [rs doubleForColumnIndex:idx++];
        s.address = [rs stringForColumnIndex:idx++];
        
        s.commentsCount = [rs intForColumnIndex:idx++];
        s.forwardsCount = [rs intForColumnIndex:idx++];
        s.likedCount = [rs intForColumnIndex:idx++];
        
        s.extraSourceMask = [rs intForColumnIndex:idx++];
        
        s.groupId = [rs stringForColumnIndex:idx++];
        s.groupName = [rs stringForColumnIndex:idx++];
        
        NSDictionary *queryInfo = [self _statusQueryInfoWithAuthorId:authorId forwardedStatusId:forwardedStatusId
                                                      extendStatusId:extendStatusId extraMessageId:extraMessageId];
        
        [self _queryStatusProperties:s info:queryInfo database:fmdb];
        
        [statuses addObject:s];
        //        [s release];
    }
    
    [rs close];
    
    return statuses;
}

- (BOOL)removeMentionMeStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb {
    if (statusId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM mention_me_statuses WHERE id=?;", statusId];
}

- (BOOL)_cleanExpiredMentionMeStatusesWithLimit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"DELETE FROM mention_me_statuses WHERE created_at < (SELECT MIN(tmp.created_at)"
    " FROM (SELECT created_at FROM mention_me_statuses ORDER BY created_at DESC LIMIT ?) AS tmp);";
    
    return [fmdb executeUpdate:sql, @(limit)];
}

- (BOOL)removeAllMentionMeStatusesInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM mention_me_statuses;"];
}


/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark comment me statuses

- (void)saveCommentMeStatus:(KDCommentMeStatus *)status database:(FMDatabase *)fmdb {
    if (status == nil) return;
    
    BOOL rollback = NO; // ignore it
    [self saveCommentMeStatuses:@[status] database:fmdb rollback:&rollback];
}

- (void)saveCommentMeStatuses:(NSArray *)statuses database:(FMDatabase *)fmdb rollback:(BOOL *)rollback {
    if (statuses == nil || [statuses count] == 0) return;
    
    NSString *sql = @"REPLACE INTO comment_me_statuses(id, user_id, content, source, forwarded_status_id,"
    " extend_status_id, extra_message_id, created_at, updated_at, favorited,liked,"
    " truncated, latitude, longitude, comments_count, forwards_count, liked_count, mask,"
    " reply_status_id, reply_user_id, reply_screen_name, reply_status_text,"
    " reply_comment_text, group_id, group_name) VALUES (?, ?, ?, ?, ?, ?, ?,"
    " ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    for (KDCommentMeStatus *s in statuses) {
        idx = 1;
        [stmt bindString:s.statusId atIndex:idx++];
        [stmt bindString:s.author.userId atIndex:idx++];
        [stmt bindString:s.text atIndex:idx++];
        [stmt bindString:s.source atIndex:idx++];
        
        [stmt bindString:((s.forwardedStatus != nil) ? s.forwardedStatus.statusId : nil) atIndex:idx++];
        [stmt bindString:((s.extendStatus != nil) ? s.extendStatus.statusId : nil) atIndex:idx++];
        [stmt bindString:((s.extraMessage != nil) ? s.extraMessage.extraId : nil) atIndex:idx++];
        
        [stmt bindDate:s.createdAt atIndex:idx++];
        [stmt bindDate:s.updatedAt atIndex:idx++];
        
        [stmt bindBool:s.favorited atIndex:idx++];
        [stmt bindBool:s.truncated atIndex:idx++];
        [stmt bindBool:s.liked atIndex:idx++];
        
        [stmt bindFloat:s.latitude atIndex:idx++];
        [stmt bindFloat:s.longitude atIndex:idx++];
        
        [stmt bindInt:(int)s.commentsCount atIndex:idx++];
        [stmt bindInt:(int)s.forwardsCount atIndex:idx++];
        [stmt bindInt:(int)s.likedCount atIndex:idx++];
        
        [stmt bindInt:(int)s.extraSourceMask atIndex:idx++];
        
        [stmt bindString:s.replyStatusId atIndex:idx++];
        [stmt bindString:s.replyUserId atIndex:idx++];
        [stmt bindString:s.replyScreenName atIndex:idx++];
        [stmt bindString:s.replyStatusText atIndex:idx++];
        [stmt bindString:s.replyCommentText atIndex:idx++];
        
        [stmt bindString:s.groupId atIndex:idx++];
        [stmt bindString:s.groupName atIndex:idx++];
        
        // step
        if ([stmt step]) {
            [self _saveStatusProperties:s database:fmdb];
            if (s.status) {
                if (!s.status.groupId) {
                    [self saveStatus:s.status database:fmdb];
                }else {
                    [self saveGroupStatus:(KDGroupStatus*)s.status database:fmdb];
                }
            }
            
        } else {
            *rollback = YES;
            
            DLog(@"Can not save comment me status with id=%@", s.statusId);
            
            break;
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
    
    // clean the expired comment me statuses. (just keep latest 20)
    if (![self _cleanExpiredCommentMeStatusesWithLimit:20 database:fmdb]) {
        DLog(@"clean the expired comment me statuses did fail.");
    }
}

- (void)updateCommentMeStatusCounts:(NSArray *)statusCounts database:(FMDatabase *)fmdb {
    if (statusCounts == nil || [statusCounts count] == 0) return;
    
    NSString *sql = @"UPDATE comment_me_statuses SET comments_count=?, forwards_count=?,liked_count WHERE id=?";
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    for (KDStatusCounts *sc in statusCounts) {
        idx = 1;
        
        [stmt bindString:sc.statusId atIndex:idx++];
        [stmt bindInt:(int)sc.commentsCount atIndex:idx++];
        [stmt bindInt:(int)sc.forwardsCount atIndex:idx++];
        [stmt bindInt:(int)sc.likedCount atIndex:idx++];
        // step
        if (![stmt step]) {
            DLog(@"Can not update comment me status counts with id=%@", sc.statusId);
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
}

- (NSArray *)queryCommentMeStatusesWithLimit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"SELECT id, user_id, content, source, forwarded_status_id, extend_status_id,"
    " extra_message_id, created_at, updated_at, favorited, truncated,liked,latitude,"
    " longitude, comments_count, forwards_count,liked_count, mask, reply_status_id,"
    " reply_user_id, reply_screen_name, reply_status_text, reply_comment_text, group_id, group_name"
    " FROM comment_me_statuses ORDER BY created_at DESC LIMIT ?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, @(limit)];
    
    KDCommentMeStatus *s = nil;
    NSMutableArray *statuses = [NSMutableArray array];
    
    while ([rs next]) {
        s = [[KDCommentMeStatus alloc] init];
        
        int idx = 0;
        s.statusId = [rs stringForColumnIndex:idx++];
        NSString *authorId = [rs stringForColumnIndex:idx++];
        s.text = [rs stringForColumnIndex:idx++];
        s.source = [rs stringForColumnIndex:idx++];
        
        NSString *forwardedStatusId = [rs stringForColumnIndex:idx++];
        NSString *extendStatusId = [rs stringForColumnIndex:idx++];
        NSString *extraMessageId = [rs stringForColumnIndex:idx++];
        
        s.createdAt = [rs dateForColumnIndex:idx++];
        s.updatedAt = [rs dateForColumnIndex:idx++];
        
        s.favorited = [rs boolForColumnIndex:idx++];
        s.truncated = [rs boolForColumnIndex:idx++];
        s.liked = [rs boolForColumnIndex:idx++];
        
        s.latitude = [rs doubleForColumnIndex:idx++];
        s.longitude = [rs doubleForColumnIndex:idx++];
        
        s.commentsCount = [rs intForColumnIndex:idx++];
        s.forwardsCount = [rs intForColumnIndex:idx++];
        s.likedCount = [rs intForColumnIndex:idx++];
        
        s.extraSourceMask = [rs intForColumnIndex:idx++];
        
        s.replyStatusId = [rs stringForColumnIndex:idx++];
        s.replyUserId = [rs stringForColumnIndex:idx++];
        s.replyScreenName = [rs stringForColumnIndex:idx++];
        s.replyStatusText = [rs stringForColumnIndex:idx++];
        s.replyCommentText = [rs stringForColumnIndex:idx++];
        
        s.groupId = [rs stringForColumnIndex:idx++];
        s.groupName = [rs stringForColumnIndex:idx++];
        
        // query the properties of status
        NSDictionary *queryInfo = [self _statusQueryInfoWithAuthorId:authorId forwardedStatusId:forwardedStatusId
                                                      extendStatusId:extendStatusId extraMessageId:extraMessageId];
        
        [self _queryStatusProperties:s info:queryInfo database:fmdb];
        if (s.replyStatusId) {
            if (s.groupId) {
                s.status = [self queryGroupStatusesWithStatusId:s.replyStatusId database:fmdb];
            }else {
                s.status = [self queryStatusWithId:s.replyStatusId database:fmdb];
            }
        }
        [statuses addObject:s];
        //        [s release];
    }
    
    [rs close];
    
    return statuses;
}

- (BOOL)removeCommentMeStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb {
    if (statusId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM comment_me_statuses WHERE id=?;", statusId];
}

- (BOOL)_cleanExpiredCommentMeStatusesWithLimit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"DELETE FROM comment_me_statuses WHERE created_at < (SELECT MIN(tmp.created_at)"
    " FROM (SELECT created_at FROM comment_me_statuses ORDER BY created_at DESC LIMIT ?) AS tmp);";
    
    return [fmdb executeUpdate:sql, @(limit)];
}

- (BOOL)removeAllCommentMeStatusesInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM comment_me_statuses;"];
}


/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark group statuses

- (void)saveGroupStatus:(KDGroupStatus *)status database:(FMDatabase *)fmdb {
    if (status == nil) return;
    
    BOOL rollback = NO; // ignore
    [self saveGroupStatuses:@[status] database:fmdb rollback:&rollback];
}

- (void)saveGroupStatuses:(NSArray *)statuses database:(FMDatabase *)fmdb rollback:(BOOL *)rollback {
    if (statuses == nil || [statuses count] == 0) return;
    
    NSString *sql = @"REPLACE INTO group_statuses_v2(id, user_id, content, source, forwarded_status_id,"
    " extend_status_id, extra_message_id, created_at, updated_at, favorited,"
    " truncated, liked, latitude, longitude, address, comments_count, forwards_count,liked_count, mask, group_id,sending_state)"
    " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    for (KDStatus *s in statuses) {
        idx = 1;
        [stmt bindString:s.statusId atIndex:idx++];
        [stmt bindString:s.author.userId atIndex:idx++];
        [stmt bindString:s.text atIndex:idx++];
        [stmt bindString:s.source atIndex:idx++];
        
        [stmt bindString:((s.forwardedStatus != nil) ? s.forwardedStatus.statusId : nil) atIndex:idx++];
        [stmt bindString:((s.extendStatus != nil) ? s.extendStatus.statusId : nil) atIndex:idx++];
        [stmt bindString:((s.extraMessage != nil) ? s.extraMessage.extraId : nil) atIndex:idx++];
        
        [stmt bindDate:s.createdAt atIndex:idx++];
        [stmt bindDate:s.updatedAt atIndex:idx++];
        
        [stmt bindBool:s.favorited atIndex:idx++];
        [stmt bindBool:s.truncated atIndex:idx++];
        [stmt bindBool:s.liked atIndex:idx++];
        
        [stmt bindFloat:s.latitude atIndex:idx++];
        [stmt bindFloat:s.longitude atIndex:idx++];
        [stmt bindString:s.address atIndex:idx++];
        
        [stmt bindInt:(int)s.commentsCount atIndex:idx++];
        [stmt bindInt:(int)s.forwardsCount atIndex:idx++];
        [stmt bindInt:(int)s.likedCount atIndex:idx++];
        
        [stmt bindInt:(int)s.extraSourceMask atIndex:idx++];
        [stmt bindString:s.groupId atIndex:idx++];
        [stmt bindInt:s.sendingState atIndex:idx++];
        
        // step
        if ([stmt step]) {
            [self _saveStatusProperties:s database:fmdb];
            
        } else {
            *rollback = YES;
            
            DLog(@"Can not save group status with id=%@", s.statusId);
            
            break;
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
    
    // we just think all the group statuses has same group id in array.
    KDGroupStatus *temp = statuses[0];
    
    // clean the expired group statuses. (just keep latest 50)
    if (![self _cleanExpiredGroupStatuses:temp.groupId limit:50 database:fmdb]) {
        DLog(@"clean the expired group statuses did fail.");
    }
}

- (void)updateGroupStatusFavorite:(BOOL)favorite groupStatusId:(NSString *)sid database:(FMDatabase *)fmdb {
    if(!sid || sid.length == 0) return;
    
    [fmdb executeUpdate:@"UPDATE group_statuses_v2 SET favorited=? WHERE id=?", @(favorite), sid];
}

- (NSArray *)queryGroupStatusesWithGroupId:(NSString *)groupId limit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    if (groupId == nil) return nil;
    
    NSString *sql = @"SELECT id, user_id, content, source, forwarded_status_id, extend_status_id,"
    " extra_message_id, created_at, updated_at, favorited, truncated,liked, latitude,"
    " longitude,address,comments_count, forwards_count,liked_count,mask,sending_state"
    " FROM group_statuses_v2 WHERE group_id=? ORDER BY updated_at DESC LIMIT ?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, groupId, @(limit)];
    
    KDGroupStatus *s = nil;
    NSMutableArray *statuses = [NSMutableArray array];
    
    while ([rs next]) {
        s = [[KDGroupStatus alloc] init];
        
        int idx = 0;
        s.statusId = [rs stringForColumnIndex:idx++];
        NSString *authorId = [rs stringForColumnIndex:idx++];
        s.text = [rs stringForColumnIndex:idx++];
        s.source = [rs stringForColumnIndex:idx++];
        
        NSString *forwardedStatusId = [rs stringForColumnIndex:idx++];
        NSString *extendStatusId = [rs stringForColumnIndex:idx++];
        NSString *extraMessageId = [rs stringForColumnIndex:idx++];
        
        s.createdAt = [rs dateForColumnIndex:idx++];
        s.updatedAt = [rs dateForColumnIndex:idx++];
        
        s.favorited = [rs boolForColumnIndex:idx++];
        s.truncated = [rs boolForColumnIndex:idx++];
        s.liked = [rs boolForColumnIndex:idx++];
        
        s.latitude = [rs doubleForColumnIndex:idx++];
        s.longitude = [rs doubleForColumnIndex:idx++];
        s.address = [rs stringForColumnIndex:idx++];
        
        s.commentsCount = [rs intForColumnIndex:idx++];
        s.forwardsCount = [rs intForColumnIndex:idx++];
        s.likedCount = [rs intForColumnIndex:idx++];
        
        s.extraSourceMask = [rs intForColumnIndex:idx++];
        s.sendingState = [rs  intForColumnIndex:idx++];
        
        s.groupId = groupId;
        
        // query the properties of status
        NSDictionary *queryInfo = [self _statusQueryInfoWithAuthorId:authorId forwardedStatusId:forwardedStatusId
                                                      extendStatusId:extendStatusId extraMessageId:extraMessageId];
        
        [self _queryStatusProperties:s info:queryInfo database:fmdb];
        
        [statuses addObject:s];
        //        [s release];
    }
    
    [rs close];
    
    return statuses;
}

- (KDGroupStatus *)queryGroupStatusesWithStatusId:(NSString *)groupId database:(FMDatabase *)fmdb {
    if (groupId == nil) return nil;
    
    NSString *sql = @"SELECT id, user_id, content, source, forwarded_status_id, extend_status_id,"
    " extra_message_id, created_at, updated_at, favorited, truncated, liked,latitude,"
    " longitude,address,comments_count, forwards_count,liked_count, mask,sending_state"
    " FROM group_statuses_v2 WHERE id=?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, groupId];
    
    KDGroupStatus *s = nil;
    
    if ([rs next]) {
        s = [[KDGroupStatus alloc] init];
        
        int idx = 0;
        s.statusId = [rs stringForColumnIndex:idx++];
        NSString *authorId = [rs stringForColumnIndex:idx++];
        s.text = [rs stringForColumnIndex:idx++];
        s.source = [rs stringForColumnIndex:idx++];
        
        NSString *forwardedStatusId = [rs stringForColumnIndex:idx++];
        NSString *extendStatusId = [rs stringForColumnIndex:idx++];
        NSString *extraMessageId = [rs stringForColumnIndex:idx++];
        
        s.createdAt = [rs dateForColumnIndex:idx++];
        s.updatedAt = [rs dateForColumnIndex:idx++];
        
        s.favorited = [rs boolForColumnIndex:idx++];
        s.truncated = [rs boolForColumnIndex:idx++];
        s.liked = [rs boolForColumnIndex:idx++];
        
        s.latitude = [rs doubleForColumnIndex:idx++];
        s.longitude = [rs doubleForColumnIndex:idx++];
        s.address = [rs stringForColumnIndex:idx++];
        
        s.commentsCount = [rs intForColumnIndex:idx++];
        s.forwardsCount = [rs intForColumnIndex:idx++];
        s.likedCount = [rs intForColumnIndex:idx++];
        
        s.extraSourceMask = [rs intForColumnIndex:idx++];
        s.sendingState = [rs intForColumnIndex:idx++];
        
        s.groupId = groupId;
        
        // query the properties of status
        NSDictionary *queryInfo = [self _statusQueryInfoWithAuthorId:authorId forwardedStatusId:forwardedStatusId
                                                      extendStatusId:extendStatusId extraMessageId:extraMessageId];
        
        [self _queryStatusProperties:s info:queryInfo database:fmdb];
        
    }
    
    [rs close];
    
    return s ;//autorelease];
}

- (BOOL)removeGroupStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb {
    if (statusId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM group_statuses_v2 WHERE id=?;", statusId];
}

- (BOOL)_cleanExpiredGroupStatuses:(NSString *)groupId limit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"DELETE FROM group_statuses_v2 WHERE group_id=? AND created_at < (SELECT MIN(tmp.created_at)"
    " FROM (SELECT created_at FROM group_statuses_v2 WHERE group_id=?"
    " ORDER BY created_at DESC LIMIT ?) AS tmp);";
    
    return [fmdb executeUpdate:sql, groupId, groupId, @(limit)];
}

- (BOOL)removeAllGroupStatusesInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM group_statuses_v2;"];
}


- (void)removeAllDataFromDatabase:(FMDatabase *)fmdb
{
    [fmdb executeUpdate:@"DELETE FROM statuses_v2;"];
    [fmdb executeUpdate:@"DELETE FROM forwarded_statuses;"];
    [fmdb executeUpdate:@"DELETE FROM mention_me_statuses;"];
    [fmdb executeUpdate:@"DELETE FROM comment_me_statuses;"];
    [fmdb executeUpdate:@"DELETE FROM group_statuses_v2;"];
}

//zgbin:start
- (BOOL)existFieldInTable:(NSString*)tablename fieldName:(NSString*)field
                       db:(FMDatabase *)db
{
    BOOL hasColumn = NO;
    NSString * sql = [NSString stringWithFormat:@"select sql from sqlite_master where tbl_name = '%@' and type = 'table';",tablename];
    FMResultSet *rs = [db executeQuery:sql];
    if ([rs next]) {
        NSString *tableCreateSQL = [rs stringForColumnIndex:0];
        hasColumn = ([tableCreateSQL rangeOfString:field].location != NSNotFound);
    }
    [rs close];
    return hasColumn;
}

//数组转换成json字符串
- (NSString *)jsonStringWithArray:(NSArray *)array{
    if ([array isKindOfClass:[NSNull class]] || array == nil) {
        array = [[NSArray alloc] init];
    }
    
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&err];
    if (jsonData == nil) {
        return nil;
    }
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

//json字符串转换成数组
- (NSArray *)arrayWithJsonString:(NSString *)jsonString{
    NSError *error = nil;
    NSData *data = [isVaildStr(jsonString) dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (jsonObject != nil && error == nil) {
        return jsonObject;
    } else {
        //解析错误
        return nil;
    }
}

#pragma mark 合法字符串
NSString* isVaildStr(NSString*value)
{
    if ([value isKindOfClass:[NSNumber class]]) {
        
        
        return [NSString stringWithFormat:@"%.f",[value doubleValue]];
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"<null>"]) {
            return @"";
        }
    }
    
    if (value && ![value isEqual:[NSNull null]] && value != nil && ((NSString*)value).length != 0) {
        return value;
    }
    return @"";
    
}
//zgbin:end
@end

