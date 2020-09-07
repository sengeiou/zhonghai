//
//  KDTopicDAOImpl.m
//  kdweibo_common
//
//  Created by shen kuikui on 13-2-22.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDTopicDAOImpl.h"
#import "KDTopic.h"

@implementation KDTopicDAOImpl

- (void)saveTopic:(KDTopic *)topic database:(FMDatabase *)fmdb {
    if(!topic) return;
    
    [self saveTopics:@[topic] database:fmdb];
}

- (void)saveTopics:(NSArray *)topics database:(FMDatabase *)fmdb {
    if(!topics || topics.count == 0) return;
    
    NSString *sql = @"REPLACE INTO topic(topicid,topicname) VALUES(?,?)";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    for(KDTopic *topic in topics) {
        assert([topic isKindOfClass:[KDTopic class]]);
        
        [stmt bindString:topic.topicId atIndex:1];
        [stmt bindString:topic.name atIndex:2];
        
        // step
        if (![stmt step]) {
            DLog(@"Can not save topic with id = %@", topic.topicId);
        }
        
        // reset parameters
        [stmt reset];
    }
    
    [stmt close];
}

- (void)removeTopic:(KDTopic *)topic database:(FMDatabase *)fmdb {
    if(!topic) return;
    
    [fmdb executeUpdate:@"DELETE FROM topic WHERE topicid=?;", topic.topicId];
}

- (BOOL)isTopicExists:(KDTopic *)topic database:(FMDatabase *)fmdb {
    if(!topic) return NO;
    
    FMResultSet *rs = [fmdb executeQuery:@"SELECT * FROM topic WHERE topicid=?;", topic.topicId];
    
    BOOL result = rs.next;
    
    [rs close];
    
    return result;
}


- (NSArray *)queryTopic_database:(FMDatabase *)fmdb{
    NSString *sql = @"SELECT topicid ,topicName FROM Topic";
    
    FMResultSet *rs = [fmdb executeQuery:sql];
    NSMutableArray *messages = [NSMutableArray array];
    KDTopic * topic = nil;
    int idx;
    while ([rs next]) {
        topic = [[KDTopic alloc]init];
        idx = 0;
        topic.topicId = [rs stringForColumnIndex:idx++];
        topic.name = [rs stringForColumnIndex:idx++];
       
        [messages addObject:topic];
//        [topic release];
       
    }
    [rs close];
    return messages;
    
}


@end
