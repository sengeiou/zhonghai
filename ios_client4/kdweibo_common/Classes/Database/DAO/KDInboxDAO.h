//
//  KDInboxDAO.h
//  kdweibo_common
//
//  Created by bird on 13-7-1.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//
#import <Foundation/Foundation.h>
@class FMDatabase;

@protocol KDInboxDAO   <NSObject>

@required

- (void)saveInboxList:(NSArray *)list database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;
- (NSArray *)queryInboxWithType:(NSString *)type database:(FMDatabase *)fmdb;
- (BOOL)removeInboxWithType:(NSString *)type database:(FMDatabase *)fmdb;
- (NSArray *)queryInbox_database:(FMDatabase *)fmdb;
- (BOOL)removeInbox_database:(FMDatabase *)fmdb;
- (BOOL)removeInboxByInboxId:(NSString *)inboxId database:(FMDatabase *)fmdb;
- (BOOL)removeInboxByUpdateTime:(double)timeAt database:(FMDatabase *)fmdb;
- (BOOL)updateInboxStatusWithId:(NSString *)inboxId database:(FMDatabase *)fmdb;
- (BOOL)updateInboxStatusWithStatusId:(NSString *)statusId database:(FMDatabase *)fmdb;


//针对inbox优化添加新的处理方法 -- 黄伟彬
- (void)saveAllTypeInboxList:(NSArray *)list database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;
- (NSArray *)queryAllTypeInboxwithDatabase:(FMDatabase *)fmdb;
@end
