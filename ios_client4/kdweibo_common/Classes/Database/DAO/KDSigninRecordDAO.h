//
//  KDSigninRecordDAO.h
//  kdweibo_common
//
//  Created by 王松 on 13-8-25.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class KDSignInRecord;

@protocol KDSigninRecordDAO <NSObject>

- (void)saveRecord:(KDSignInRecord *)status withDate:(NSDate *)date database:(FMDatabase *)fmdb;
- (void)saveRecords:(NSArray *)record withDate:(NSDate *)date database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;

- (void)updateRecordCounts:(NSArray *)counts database:(FMDatabase *)fmdb;
- (NSArray *)queryRecordsWithLimit:(NSUInteger)limit withDate:(NSDate *)date database:(FMDatabase *)fmdb;

- (BOOL)removeRecordWithId:(NSString *)statusId database:(FMDatabase *)fmdb;
- (BOOL)removeAllRecordsInDatabase:(FMDatabase *)fmdb;

- (NSMutableArray *)queryFailuredSignInRecordsWithLimit:(NSUInteger)limit withDate:(NSDate *)date database:(FMDatabase *)fmdb;

@end
