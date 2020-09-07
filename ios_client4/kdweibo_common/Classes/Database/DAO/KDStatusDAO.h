//
//  KDStatusDAO.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-5.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class KDCommentMeStatus;
@class KDMentionMeStatus;
@class KDGroupStatus;

#import "KDStatus.h"

@protocol KDStatusDAO <NSObject>
@required

/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark normal statuses

- (void)saveStatus:(KDStatus *)status database:(FMDatabase *)fmdb;
- (void)saveStatuses:(NSArray *)statuses database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;

- (void)updateStatusCounts:(NSArray *)statusCounts database:(FMDatabase *)fmdb;
- (void)updateLiked:(BOOL)liked statusId:(NSString *)theId database:(FMDatabase *)fmdb;
- (void)updateFavorite:(BOOL)favorite statusId:(NSString *)statusId database:(FMDatabase *)fmdb;
- (NSArray *)queryStatusesWithTLType:(KDTLStatusType)type limit:(NSUInteger)limit database:(FMDatabase *)fmdb;

- (BOOL)removeStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb;
- (BOOL)removeAllStatusesInDatabase:(FMDatabase *)fmdb;

//zgbin:动态-数据库加字段
- (void)addFieldWithFMDatabase:(FMDatabase *)fmdb;
//zgbin:end

/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark forwarded statuses

- (void)saveForwardedStatus:(KDStatus *)status database:(FMDatabase *)fmdb;
- (void)saveForwardedStatuses:(NSArray *)statuses database:(FMDatabase *)fmdb;

- (KDStatus *)queryForwardedStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb;

- (BOOL)removeForwardedStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb;
- (BOOL)removeAllForwardedStatusesInDatabase:(FMDatabase *)fmdb;


/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark mention me statuses

- (void)saveMentionMeStatus:(KDMentionMeStatus *)status database:(FMDatabase *)fmdb;
- (void)saveMentionMeStatuses:(NSArray *)statuses database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;

- (void)updateMentionMeStatusCounts:(NSArray *)statusCounts database:(FMDatabase *)fmdb;

- (NSArray *)queryMentionMeStatusesWithLimit:(NSUInteger)limit database:(FMDatabase *)fmdb;

- (BOOL)removeMentionMeStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb;
- (BOOL)removeAllMentionMeStatusesInDatabase:(FMDatabase *)fmdb;


/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark comment me statuses

- (void)saveCommentMeStatus:(KDCommentMeStatus *)status database:(FMDatabase *)fmdb;
- (void)saveCommentMeStatuses:(NSArray *)statuses database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;

- (void)updateCommentMeStatusCounts:(NSArray *)statusCounts database:(FMDatabase *)fmdb;

- (NSArray *)queryCommentMeStatusesWithLimit:(NSUInteger)limit database:(FMDatabase *)fmdb;

- (BOOL)removeCommentMeStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb;
- (BOOL)removeAllCommentMeStatusesInDatabase:(FMDatabase *)fmdb;


/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark group statuses

- (void)saveGroupStatus:(KDGroupStatus *)status database:(FMDatabase *)fmdb;
- (void)saveGroupStatuses:(NSArray *)statuses database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;
- (void)updateGroupStatusFavorite:(BOOL)favorite groupStatusId:(NSString *)sid database:(FMDatabase *)fmdb;
- (NSArray *)queryGroupStatusesWithGroupId:(NSString *)groupId limit:(NSUInteger)limit database:(FMDatabase *)fmdb;

- (BOOL)removeGroupStatusWithId:(NSString *)statusId database:(FMDatabase *)fmdb;
- (BOOL)removeAllGroupStatusesInDatabase:(FMDatabase *)fmdb;


- (void)removeAllDataFromDatabase:(FMDatabase *)fmdb;

@end

