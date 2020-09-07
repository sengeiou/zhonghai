//
//  KDDMThreadDAO.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class KDDMThread;

@protocol KDDMThreadDAO <NSObject>
@required

- (void)saveDMThreads:(NSArray *)threads database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;

- (KDDMThread *)queryDMThreadWithId:(NSString *)threadId database:(FMDatabase *)fmdb;
- (NSArray *)queryDMThreadsWithLimit:(NSInteger)limit database:(FMDatabase *)fmdb;
- (NSArray *)queryTopDMThreads_database:(FMDatabase *)fmdb;

- (BOOL)removeDMThreadWithId:(NSString *)threadId database:(FMDatabase *)fmdb;
- (BOOL)removeAllDMThreadsInDatabase:(FMDatabase *)fmdb;
- (BOOL)setTopDMThreadWithId:(NSString *)threadId database:(FMDatabase *)fmdb;
- (BOOL)cancelTopDMThreadWithId:(NSString *)threadId database:(FMDatabase *)fmdb;
- (BOOL)resetTopStatus_database:(FMDatabase *)fmdb;
- (BOOL)removeTopDMThreads_database:(FMDatabase *)fmdb;


@end
