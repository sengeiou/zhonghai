//
//  KDTodoDAOImpl.m
//  kdweibo_common
//
//  Created by bird on 13-7-4.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDTodoDAOImpl.h"
#import "KDTodo.h"
#import "KDWeiboDAOManager.h"
#import "JSON.h"
@implementation KDTodoDAOImpl

- (void)saveTodoList:(NSArray *)list database:(FMDatabase *)fmdb rollback:(BOOL *)rollback
{
    if (list == nil || [list count] == 0) return;
    
    NSString *sql =  @"REPLACE INTO todo(todoId, fromId, fromType, networkId, actName,"
        " createDate, contentHead, title, toUserId, fromUserId,"
        " connectType, updateDate, actDate, status, content, action, taskCommentCount)"
        " VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    int idx;
    for (KDTodo *t in list) {
        idx = 1;
        if(t.todoId)
            [stmt bindString:t.todoId atIndex:idx++];
        else
            [stmt bindString:t.fromId atIndex:idx++];
            
        [stmt bindString:t.fromId atIndex:idx++];
        [stmt bindString:t.fromType  atIndex:idx++];
        [stmt bindString:t.networkId atIndex:idx++];
        
        [stmt bindString:t.actName atIndex:idx++];
        [stmt bindDate:t.createDate atIndex:idx++];
        
        [stmt bindString:t.contentHead atIndex:idx++];
        [stmt bindString:t.title atIndex:idx++];
        [stmt bindString:t.toUserId atIndex:idx++];
            
        
        [stmt bindString:t.fromUserId atIndex:idx++];
        
        [stmt bindString:t.connectType atIndex:idx++];
        [stmt bindDate:t.updateDate atIndex:idx++];
        [stmt bindDate:t.actDate atIndex:idx++];
        
        [stmt bindString:t.status atIndex:idx++];
        [stmt bindString:t.content atIndex:idx++];
        
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        
        for (Action *action in t.action) {
            NSDictionary *dic =[action dictionaryRepresentation];
            [array addObject:dic];
        }
        
        [stmt bindString:[array JSONRepresentation] atIndex:idx++];
            
        [stmt bindString:t.taskCommentCount atIndex:idx++];
        // step
        if ([stmt step]) {
            
            KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
            
            // save sender
            if (t.toUser && t.fromUser)
            {
                [[manager userDAO] saveUsers:@[t.toUser,t.fromUser] database:fmdb];
            }
        } else {
            *rollback = YES;
            
            DLog(@"Can not save todo with id=%@", t.fromId);
            
            break;
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
}
- (NSArray *)queryTodoWithType:(NSString *)type database:(FMDatabase *)fmdb
{
    if (type == nil) return nil;
    
    NSString *sql = nil;
    FMResultSet *rs =nil;
    if(type.length == 0)
    {
        sql = @"SELECT todoId, fromId, fromType, networkId, actName,"
        " createDate, contentHead, title, toUserId, fromUserId,"
        " connectType, updateDate, actDate, status, content, action, taskCommentCount"
        " FROM todo WHERE status = 30 or status = 50 ORDER BY createDate DESC";
        rs = [fmdb executeQuery:sql];
    }
    else
    {
        sql = @"SELECT todoId, fromId, fromType, networkId, actName,"
        " createDate, contentHead, title, toUserId, fromUserId,"
        " connectType, updateDate, actDate, status, content, action, taskCommentCount"
        " FROM todo WHERE status = ? ORDER BY updateDate DESC";
        rs = [fmdb executeQuery:sql, type];
    }
    
    
    KDTodo *m = nil;
    NSMutableArray *messages = [NSMutableArray array];
    
    int idx;
    while ([rs next]) {
        m = [[KDTodo alloc] init];
        
        idx = 0;
        m.todoId = [rs stringForColumnIndex:idx++];
        m.fromId = [rs stringForColumnIndex:idx++];
        m.fromType = [rs stringForColumnIndex:idx++];
        
        m.networkId = [rs stringForColumnIndex:idx++];
        m.actName = [rs stringForColumnIndex:idx++];
        m.createDate = [rs dateForColumnIndex:idx++];
        m.contentHead = [rs stringForColumnIndex:idx++];
        m.title = [rs stringForColumnIndex:idx++];
        m.toUserId = [rs stringForColumnIndex:idx++];
        
        m.fromUserId = [rs stringForColumnIndex:idx++];
        m.connectType = [rs stringForColumnIndex:idx++];
        m.updateDate = [rs dateForColumnIndex:idx++];
        m.actDate = [rs dateForColumnIndex:idx++];
        m.status = [rs stringForColumnIndex:idx++];
        m.content = [rs stringForColumnIndex:idx++];
        
        m.toUser = [KDUser userWithId:m.toUserId database:fmdb];
        m.fromUser = [KDUser userWithId:m.fromUserId database:fmdb];
        
        NSArray *array = [[rs stringForColumnIndex:idx++] JSONValue];
        NSMutableArray *actions = [NSMutableArray array];
        for (NSDictionary *dic in array) {
            [actions addObject:[Action modelObjectWithDictionary:dic]];
        }
        m.action = actions;
        m.taskCommentCount = [rs stringForColumnIndex:idx++];
        [messages addObject:m];
//        [m release];
    }
    
    [rs close];
    
    return messages;
}
- (BOOL)removeTodoWithID:(NSString *)todoId database:(FMDatabase *)fmdb;
{
    if (todoId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM todo WHERE todoId=?;", todoId];
}
- (BOOL)removeTodoWithType:(NSString *)type byTime:(NSDate *)time database:(FMDatabase *)fmdb
{
    if (type == nil || time == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM todo WHERE status=? AND updateDate <= ?;", type,time];

}

- (BOOL)removeTodoWithType:(NSString *)type database:(FMDatabase *)fmdb
{
    if (type == nil) return NO;
    
    if(type.length>0)
        return [fmdb executeUpdate:@"DELETE FROM todo WHERE status=?;", type];
    else
        return [fmdb executeUpdate:@"DELETE FROM todo WHERE status='30' or status='50';"];
        
}
- (NSArray *)queryTodo_database:(FMDatabase *)fmdb
{
    NSString *sql = @"SELECT todoId, fromId, fromType, networkId, actName,"
    " createDate, contentHead, title, toUserId, fromUserId,"
    " connectType, updateDate, actDate, status, content, action, taskCommentCount"
    " FROM todo ORDER BY updateDate DESC";
    
    FMResultSet *rs = [fmdb executeQuery:sql];
    
    KDTodo *m = nil;
    NSMutableArray *messages = [NSMutableArray array];
    
    int idx;
    while ([rs next]) {
        m = [[KDTodo alloc] init];
        
        idx = 0;
        m.todoId = [rs stringForColumnIndex:idx++];
        m.fromId = [rs stringForColumnIndex:idx++];
        m.fromType = [rs stringForColumnIndex:idx++];
        
        m.networkId = [rs stringForColumnIndex:idx++];
        m.actName = [rs stringForColumnIndex:idx++];
        m.createDate = [rs dateForColumnIndex:idx++];
        m.contentHead = [rs stringForColumnIndex:idx++];
        m.title = [rs stringForColumnIndex:idx++];
        m.toUserId = [rs stringForColumnIndex:idx++];
        
        m.fromUserId = [rs stringForColumnIndex:idx++];
        m.connectType = [rs stringForColumnIndex:idx++];
        m.updateDate = [rs dateForColumnIndex:idx++];
        m.actDate = [rs dateForColumnIndex:idx++];
        m.status = [rs stringForColumnIndex:idx++];
        m.content = [rs stringForColumnIndex:idx++];
        
        m.toUser = [KDUser userWithId:m.toUserId database:fmdb];
        m.fromUser = [KDUser userWithId:m.fromUserId database:fmdb];
        
        NSArray *array = [[rs stringForColumnIndex:idx++] JSONValue];
        NSMutableArray *actions = [NSMutableArray array];
        for (NSDictionary *dic in array) {
            [actions addObject:[Action modelObjectWithDictionary:dic]];
        }
        m.action = actions;
        m.taskCommentCount = [rs stringForColumnIndex:idx++];
        
        [messages addObject:m];
//        [m release];
    }
    
    [rs close];
    
    return messages;
}
- (BOOL)removeTodo_database:(FMDatabase *)fmdb
{
     return [fmdb executeUpdate:@"DELETE FROM todo;"];
}
@end
