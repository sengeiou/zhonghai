//
//  KDTopicDAO.h
//  kdweibo_common
//
//  Created by shen kuikui on 13-2-22.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KDTopic;
@class FMDatabase;

@protocol KDTopicDAO <NSObject>

@required
- (void)saveTopic:(KDTopic *)topic database:(FMDatabase *)fmdb;
- (void)saveTopics:(NSArray *)topics database:(FMDatabase *)fmdb;
- (void)removeTopic:(KDTopic *)topic database:(FMDatabase *)fmdb;
- (BOOL)isTopicExists:(KDTopic *)topic database:(FMDatabase *)fmdb;

//添加读取所有个人关注话题的方法  -- 黄伟彬
- (NSArray *)queryTopic_database:(FMDatabase *)fmdb;

@end
