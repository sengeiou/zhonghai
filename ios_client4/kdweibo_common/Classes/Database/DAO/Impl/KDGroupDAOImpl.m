//
//  KDGroupDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDGroupDAOImpl.h"
#import "KDGroup.h"

@implementation KDGroupDAOImpl

- (NSArray *)_groupsWithResultSet:(FMResultSet *)rs {
    NSMutableArray *groups = [NSMutableArray array];
    KDGroup *group = nil;
    int idx;
    while ([rs next]) {
        group = [[KDGroup alloc] init];
        
        idx = 0;
        group.groupId = [rs stringForColumnIndex:idx++];
        group.name = [rs stringForColumnIndex:idx++];
        group.profileImageURL = [rs stringForColumnIndex:idx++];
        group.summary = [rs stringForColumnIndex:idx++];
        group.bulletin = [rs stringForColumnIndex:idx++];
        group.latestMsgContent = [rs stringForColumnIndex:idx++];
        group.latestMsgDate = [rs dateForColumnIndex:idx++];
        
        group.type = [rs intForColumnIndex:idx++];
        
        [groups addObject:group];
    }
    
    return groups;
}

- (void)saveGroups:(NSArray *)groups database:(FMDatabase *)fmdb rollback:(BOOL *)rollback {
    if (groups == nil || [groups count] == 0) return;
    
    // for now, The client request up to 60 groups from server at once,
    // And the groups will be ignored when the user has over 60 groups.
    // Which these groups will be ignored depend sorting logic on server side.
    // So, remove the cached groups before any save action
    
    if (![self removeAllGroupsInDatabase:fmdb]) {
        DLog(@"Try to remove all groups before save latest groups did fail.");
    }
    
    NSString *sql = @"REPLACE INTO groups(id, name, profile_image_url, summary, bulletin, latestMsgContent, latestMsgDate,"
                     " type, sorting_index) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    for (KDGroup *item in groups) {
        idx = 1;
        
        [stmt bindString:item.groupId atIndex:idx++];
        [stmt bindString:item.name atIndex:idx++];
        [stmt bindString:item.profileImageURL atIndex:idx++];
        [stmt bindString:item.summary atIndex:idx++];
        [stmt bindString:item.bulletin atIndex:idx++];
        [stmt bindString:item.latestMsgContent atIndex:idx++];
        [stmt bindDate:item.latestMsgDate atIndex:idx++];
        
        [stmt bindInt:item.type atIndex:idx++];
        [stmt bindInt:(int)item.sortingIndex atIndex:idx++];
        
        // step
        if (![stmt step]) {
            *rollback = YES; // rollback
            
            DLog(@"Can not save group with id=%@", item.groupId);
            
            break;
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
}

- (KDGroup *)queryGroupWithId:(NSString *)groupId database:(FMDatabase *)fmdb {
    if (groupId == nil) return nil;
    
    KDGroup *group = nil;
    NSString *sql = @"SELECT id, name, profile_image_url, summary, bulletin, latestMsgContent, latestMsgDate, type FROM groups WHERE id=?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, groupId];
    NSArray *items = [self _groupsWithResultSet:rs];
    if (items != nil && [items count] > 0) {
        group = items[0];
    }
    
    [rs close];
    
    return group;
}

- (NSArray *)queryGroupsWithLimit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"SELECT id, name, profile_image_url, summary, bulletin, latestMsgContent, latestMsgDate, type FROM groups"
                     " ORDER BY sorting_index ASC LIMIT ?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, @(limit)];
    NSArray *groups = [self _groupsWithResultSet:rs];
    [rs close];
    
    return groups;
}

- (BOOL)removeAllGroupsInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM groups;"];
}

@end
