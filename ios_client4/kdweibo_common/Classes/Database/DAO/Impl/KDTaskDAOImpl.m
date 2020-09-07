//
//  KDTaskDAOImpl.m
//  kdweibo_common
//
//  Created by Tan yingqi on 13-7-5.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDTaskDAOImpl.h"
#import "KDTask.h"
#import "KDWeiboDAOManager.h"
@implementation KDTaskDAOImpl
- (void)saveTasks:(NSArray *)tasks database:(FMDatabase *)fmdb rollback:(BOOL *)rollback {
    NSString *sql = @"REPLACE INTO tasks(taskId, content, needFinish_date,"
    " create_date, visibility,longitude, group_id, group_name, notify_by_sms) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
   
    int idx;
    for (KDTask *t in tasks) {
        idx = 1;
        [stmt bindString:t.taskNewId atIndex:idx++];
        [stmt bindString:t.content atIndex:idx++];
        [stmt bindDouble:[t.needFinishDate timeIntervalSince1970] atIndex:idx++];
        [stmt bindDouble:[t.createDate timeIntervalSince1970] atIndex:idx++];
        [stmt bindString:t.visibility atIndex:idx++];;
        [stmt bindString:t.groupId atIndex:idx++];
        [stmt bindString:t.groupName atIndex:idx++];

        // step
        if ([stmt step]) {
            KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
            [[manager userDAO] saveUsers:t.executors database:fmdb];
        } else {
            *rollback = YES; // rollback
            
            DLog(@"Can not save task with id=%@",t.taskNewId);
            
            break;
        }
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
    
    // clear the expired dm messages for specificed thread. (just keep latest 20 items)
    if (![self cleanExpiredTasks:fmdb]) {
        DLog(@"Can not clean expired tasks");
    }

}

- (BOOL)cleanExpiredTasks:(FMDatabase *)db {
    NSString *sql = @"DELETE FROM tasks  WHERE  create_date < (SELECT MIN(tmp.create_date)"
    " FROM (SELECT create_date FROM tasks ORDER BY create_date DESC LIMIT ?) AS tmp);";
    
    return [db executeUpdate:sql,  @(50)];
}
@end
