//
//  KDInboxDAOImpl.m
//  kdweibo_common
//
//  Created by bird on 13-7-1.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDInboxDAOImpl.h"
#import "KDWeiboDAOManager.h"
#import "KDInbox.h"
#import "JSON.h"
@implementation KDInboxDAOImpl

- (BOOL)inboxExistWithId:(NSString *)inboxId database:(FMDatabase *)fmdb
{
    if (inboxId == nil)   return FALSE;
    
    NSString *sql = @"SELECT count(*) FROM inbox WHERE lId = ?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql,inboxId];
    
    int count = 0;
    while ([rs next]) {
        
        count = [rs intForColumnIndex:0];
    }
    [rs close];
    
    if (count == 0)  return FALSE;
    
    return TRUE;
}
- (void)saveInboxList:(NSArray *)list database:(FMDatabase *)fmdb rollback:(BOOL *)rollback
{
    if (list == nil || [list count] == 0) return;
    
    NSString *sql = @"REPLACE INTO inbox(lId ,refUserName, participants, networkId, unReadCount,"
    " updateTime, isUpdate, isNew, refId, latestFeed,"
    " type, itemsIdentifier, participantsPhoto, isUnRead, groupName, createTime, isDelete, groupId, refUserId, content, userId, senderUserId)"
    " VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    int idx;
    for (KDInbox *t in list) {
        
//        if ([self inboxExistWithId:t._id database:fmdb])
//            [self removeInboxByInboxId:t._id database:fmdb];
        
        idx = 1;
        [stmt bindString:t._id atIndex:idx++];
        [stmt bindString:t.refUserName atIndex:idx++];
        [stmt bindString:[t.participants JSONRepresentation]  atIndex:idx++];
        [stmt bindString:t.networkId atIndex:idx++];
        
        [stmt bindDouble:t.unReadCount atIndex:idx++];
        [stmt bindDouble:t.updateTime atIndex:idx++];
        
        [stmt bindBool:t.isUpdate atIndex:idx++];
        [stmt bindBool:t.isNew atIndex:idx++];

        [stmt bindString:t.refId atIndex:idx++];
        [stmt bindString:[[t.latestFeed dictionaryRepresentation] JSONRepresentation] atIndex:idx++];
        [stmt bindString:t.type atIndex:idx++];
        [stmt bindString:t.itemsIdentifier atIndex:idx++];
        [stmt bindString:[t.participantsPhoto JSONRepresentation] atIndex:idx++];
        [stmt bindBool:t.isUnRead atIndex:idx++];
        [stmt bindString:t.groupName atIndex:idx++];
        [stmt bindDouble:t.createTime atIndex:idx++];
        [stmt bindBool:t.isDelete atIndex:idx++];
        [stmt bindString:t.groupId atIndex:idx++];
        [stmt bindString:t.refUserId atIndex:idx++];
        [stmt bindString:t.content atIndex:idx++];
        [stmt bindString:t.userId atIndex:idx++];
        [stmt bindString:t.latestFeed.senderUser.userId atIndex:idx++];
        // step
        if ([stmt step]) {
            
            if (t.latestFeed.senderUser) {
                
                KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
                // save sender
                [[manager userDAO] saveUsers:@[t.latestFeed.senderUser] database:fmdb];
            }
            
        } else {
            *rollback = YES;
            
            DLog(@"Can not save inbox with id=%@", t.refId);
            
            break;
        }
        // reset parameters
        [stmt reset];
    }
    
    [self _cleanExpiredInboxWithType:@"Comment" limit:20 database:fmdb];
    [self _cleanExpiredInboxWithType:@"Metion" limit:20 database:fmdb];
    // finalize prepared statement
    
    [stmt close];

}


- (NSArray *)queryInbox_database:(FMDatabase *)fmdb
{
    
    NSString *sql = @"SELECT lId ,refUserName, participants, networkId, unReadCount,"
    " updateTime, isUpdate, isNew, refId, latestFeed,"
    " type, itemsIdentifier, participantsPhoto, isUnRead, groupName, createTime, isDelete, groupId, refUserId, content, userId, senderUserId"
    " FROM inbox ORDER BY updateTime DESC";
    
    FMResultSet *rs = [fmdb executeQuery:sql];
    
    KDInbox *m = nil;
    NSMutableArray *messages = [NSMutableArray array];
    
    int idx;
    while ([rs next]) {
        m = [[KDInbox alloc] init];
        
        idx = 0;
        m._id = [rs stringForColumnIndex:idx++];
        m.refUserName = [rs stringForColumnIndex:idx++];
        m.participants = [[rs stringForColumnIndex:idx++] JSONValue];
        
        m.networkId = [rs stringForColumnIndex:idx++];
        m.unReadCount = [rs doubleForColumnIndex:idx++];
        m.updateTime = [rs doubleForColumnIndex:idx++];
        
        m.isUpdate = [rs boolForColumnIndex:idx++];
        m.isNew = [rs boolForColumnIndex:idx++];
        m.refId = [rs stringForColumnIndex:idx++];
        m.latestFeed = [[LatestFeed alloc] initWithDictionary:[[rs stringForColumnIndex:idx++] JSONValue]];// autorelease];
        m.type = [rs stringForColumnIndex:idx++];
        m.itemsIdentifier = [rs stringForColumnIndex:idx++];
        m.participantsPhoto = [[rs stringForColumnIndex:idx++] JSONValue];
        m.isUnRead = [rs boolForColumnIndex:idx++];
        m.groupName = [rs stringForColumnIndex:idx++];
        m.createTime = [rs doubleForColumnIndex:idx++];
        m.isDelete = [rs boolForColumnIndex:idx++];
        m.groupId = [rs stringForColumnIndex:idx++];
        m.refUserId = [rs stringForColumnIndex:idx++];
        m.content = [rs stringForColumnIndex:idx++];
        m.userId = [rs stringForColumnIndex:idx++];
    
        m.latestFeed.senderUser = [KDUser userWithId:[rs stringForColumnIndex:idx++] database:fmdb];
        
        
        [messages addObject:m];
    }
    
    [rs close];
    
    return messages;

    
}
- (NSArray *)queryInboxWithType:(NSString *)type database:(FMDatabase *)fmdb {
    if (type == nil) return nil;
    
    NSString *sql = @"SELECT lId ,refUserName, participants, networkId, unReadCount,"
    " updateTime, isUpdate, isNew, refId, latestFeed,"
    " type, itemsIdentifier, participantsPhoto, isUnRead, groupName, createTime, isDelete, groupId, refUserId, content, userId, senderUserId"
    " FROM inbox WHERE type = ? ORDER BY updateTime DESC";
    
    FMResultSet *rs = [fmdb executeQuery:sql, type];
    
    KDInbox *m = nil;
    NSMutableArray *messages = [NSMutableArray array];
    int idx;
    while ([rs next]) {
        m = [[KDInbox alloc] init];
        
        idx = 0;
        m._id = [rs stringForColumnIndex:idx++];
        m.refUserName = [rs stringForColumnIndex:idx++];
        m.participants = [[rs stringForColumnIndex:idx++] JSONValue];
        
        m.networkId = [rs stringForColumnIndex:idx++];
        m.unReadCount = [rs doubleForColumnIndex:idx++];
        m.updateTime = [rs doubleForColumnIndex:idx++];
        
        m.isUpdate = [rs boolForColumnIndex:idx++];
        m.isNew = [rs boolForColumnIndex:idx++];
        m.refId = [rs stringForColumnIndex:idx++];
        m.latestFeed = [[LatestFeed alloc] initWithDictionary:[[rs stringForColumnIndex:idx++] JSONValue]];// autorelease];
        m.type = [rs stringForColumnIndex:idx++];
        m.itemsIdentifier = [rs stringForColumnIndex:idx++];
        m.participantsPhoto = [[rs stringForColumnIndex:idx++] JSONValue];
        m.isUnRead = [rs boolForColumnIndex:idx++];
        m.groupName = [rs stringForColumnIndex:idx++];
        m.createTime = [rs doubleForColumnIndex:idx++];
        m.isDelete = [rs boolForColumnIndex:idx++];
        m.groupId = [rs stringForColumnIndex:idx++];
        m.refUserId = [rs stringForColumnIndex:idx++];
        m.content = [rs stringForColumnIndex:idx++];
        m.userId = [rs stringForColumnIndex:idx++];
        
        m.latestFeed.senderUser = [KDUser userWithId:[rs stringForColumnIndex:idx++] database:fmdb];
        
        
        [messages addObject:m];
    }
    
    [rs close];
    
    return messages;
}
- (BOOL)updateInboxStatusWithStatusId:(NSString *)statusId database:(FMDatabase *)fmdb
{
    return [fmdb executeUpdate:@"UPDATE inbox SET isUnread = ?, unReadCount = 0 WHERE refId = ?", @(NO), statusId];
}
- (BOOL)updateInboxStatusWithId:(NSString *)inboxId database:(FMDatabase *)fmdb
{
    return [fmdb executeUpdate:@"UPDATE inbox SET isUnread = ?, unReadCount = 0 WHERE lId = ?", @(NO), inboxId];
}
- (BOOL)removeInbox_database:(FMDatabase *)fmdb {
    
    return [fmdb executeUpdate:@"DELETE FROM inbox;"];
}
- (BOOL)removeInboxWithType:(NSString *)type database:(FMDatabase *)fmdb {
    if (type == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM inbox WHERE type=?;", type];
}
- (BOOL)removeInboxByInboxId:(NSString *)inboxId database:(FMDatabase *)fmdb
{
    if (inboxId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM inbox WHERE lId = ?;", inboxId];

}
- (BOOL)removeInboxByUpdateTime:(double)timeAt database:(FMDatabase *)fmdb
{
    return [fmdb executeUpdate:@"DELETE FROM inbox WHERE updateTime <= ?;", @(timeAt)];
}

- (BOOL)_cleanExpiredInboxWithType:(NSString *)type limit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"DELETE FROM inbox WHERE type =? AND updateTime < (SELECT MIN(tmp.updateTime)"
    " FROM (SELECT updateTime FROM inbox WHERE type=? ORDER BY updateTime DESC LIMIT ?) AS tmp);";
    
    return [fmdb executeUpdate:sql, type, type, @(limit)];
}

//针对inbox优化添加新的处理方法 -- 黄伟彬
- (void)saveAllTypeInboxList:(NSArray *)list database:(FMDatabase *)fmdb rollback:(BOOL *)rollback{
    
    if (list == nil || [list count] == 0) return;
    
    NSString *sql = @"REPLACE INTO inbox(lId ,refUserName, participants, networkId, unReadCount,"
    " updateTime, isUpdate, isNew, refId, latestFeed,"
    " type, itemsIdentifier, participantsPhoto, isUnRead, groupName, createTime, isDelete, groupId, refUserId, content, userId, senderUserId)"
    " VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    int idx;
    for (KDInbox *t in list) {
        
//        if ([self inboxExistWithId:t._id database:fmdb])
//            [self removeInboxByInboxId:t._id database:fmdb];
        
        idx = 1;
        [stmt bindString:t._id atIndex:idx++];
        [stmt bindString:t.refUserName atIndex:idx++];
        [stmt bindString:[t.participants JSONRepresentation]  atIndex:idx++];
        [stmt bindString:t.networkId atIndex:idx++];
        
        [stmt bindDouble:t.unReadCount atIndex:idx++];
        [stmt bindDouble:t.updateTime atIndex:idx++];
        
        [stmt bindBool:t.isUpdate atIndex:idx++];
        [stmt bindBool:t.isNew atIndex:idx++];
        
        [stmt bindString:t.refId atIndex:idx++];
        [stmt bindString:[[t.latestFeed dictionaryRepresentation] JSONRepresentation] atIndex:idx++];
        
//在type后面加All信息
        NSMutableString * typeString =  [NSMutableString stringWithString:t.type];
        [typeString appendString:@"All"];
        [stmt bindString:typeString atIndex:idx++];
        
        
        [stmt bindString:t.itemsIdentifier atIndex:idx++];
        [stmt bindString:[t.participantsPhoto JSONRepresentation] atIndex:idx++];
        [stmt bindBool:t.isUnRead atIndex:idx++];
        [stmt bindString:t.groupName atIndex:idx++];
        [stmt bindDouble:t.createTime atIndex:idx++];
        [stmt bindBool:t.isDelete atIndex:idx++];
        [stmt bindString:t.groupId atIndex:idx++];
        [stmt bindString:t.refUserId atIndex:idx++];
        [stmt bindString:t.content atIndex:idx++];
        [stmt bindString:t.userId atIndex:idx++];
        [stmt bindString:t.latestFeed.senderUser.userId atIndex:idx++];
        // step
        if ([stmt step]) {
            
            if (t.latestFeed.senderUser) {
                
                KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
                // save sender
                [[manager userDAO] saveUsers:@[t.latestFeed.senderUser] database:fmdb];
            }
            
        } else {
            *rollback = YES;
            
            DLog(@"Can not save inbox with id=%@", t.refId);
            
            break;
        }
        // reset parameters
        [stmt reset];
    }
    
    [self _cleanExpiredAllTypeInboxWithLimit:20 database:fmdb];
    
    [stmt close];

    
}

- (NSArray *)queryAllTypeInboxwithDatabase:(FMDatabase *)fmdb{
    NSString *sql = @"SELECT lId ,refUserName, participants, networkId, unReadCount,"
    " updateTime, isUpdate, isNew, refId, latestFeed,"
    " type, itemsIdentifier, participantsPhoto, isUnRead, groupName, createTime, isDelete, groupId, refUserId, content, userId, senderUserId"
    " FROM inbox WHERE type = 'CommentAll' OR type = 'MetionAll' ORDER BY updateTime DESC";
    
    FMResultSet *rs = [fmdb executeQuery:sql];
    
    KDInbox *m = nil;
    NSMutableArray *messages = [NSMutableArray array];
    
    int idx;
    while ([rs next]) {
        m = [[KDInbox alloc] init];
        
        idx = 0;
        m._id = [rs stringForColumnIndex:idx++];
        m.refUserName = [rs stringForColumnIndex:idx++];
        m.participants = [[rs stringForColumnIndex:idx++] JSONValue];
        
        m.networkId = [rs stringForColumnIndex:idx++];
        m.unReadCount = [rs doubleForColumnIndex:idx++];
        m.updateTime = [rs doubleForColumnIndex:idx++];
        
        m.isUpdate = [rs boolForColumnIndex:idx++];
        m.isNew = [rs boolForColumnIndex:idx++];
        m.refId = [rs stringForColumnIndex:idx++];
        m.latestFeed = [[LatestFeed alloc] initWithDictionary:[[rs stringForColumnIndex:idx++] JSONValue]];// autorelease];
    //    m.type = [rs stringForColumnIndex:idx++];
        NSMutableString * typeString = [NSMutableString stringWithString:[rs stringForColumnIndex:idx++]];
        NSRange tempRange = [typeString rangeOfString:@"All"];
        if (tempRange.length > 0) {
            [typeString deleteCharactersInRange:[typeString rangeOfString:@"All"]];
        }
     
        m.type = typeString;
        m.itemsIdentifier = [rs stringForColumnIndex:idx++];
        m.participantsPhoto = [[rs stringForColumnIndex:idx++] JSONValue];
        m.isUnRead = [rs boolForColumnIndex:idx++];
        m.groupName = [rs stringForColumnIndex:idx++];
        m.createTime = [rs doubleForColumnIndex:idx++];
        m.isDelete = [rs boolForColumnIndex:idx++];
        m.groupId = [rs stringForColumnIndex:idx++];
        m.refUserId = [rs stringForColumnIndex:idx++];
        m.content = [rs stringForColumnIndex:idx++];
        m.userId = [rs stringForColumnIndex:idx++];
        
        m.latestFeed.senderUser = [KDUser userWithId:[rs stringForColumnIndex:idx++] database:fmdb];
        
        
        [messages addObject:m];

    }
    
    [rs close];
    
    return messages;

}

//保持All数据不超过20条
- (BOOL)_cleanExpiredAllTypeInboxWithLimit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"DELETE FROM inbox WHERE type like '%All' AND updateTime < (SELECT MIN(tmp.updateTime)"
    " FROM (SELECT updateTime FROM inbox WHERE type like '%All' ORDER BY updateTime DESC LIMIT ?) AS tmp);";
    
    return [fmdb executeUpdate:sql, @(limit)];
}
@end
