//
//  KDDMMessageDAO.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class KDDMMessage;

@protocol KDDMMessageDAO <NSObject>
@required

- (void)saveDMMessages:(NSArray *)messages threadId:(NSString *)threadId
              database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;

- (NSArray *)queryDMMessagesWithThreadId:(NSString *)threadId limit:(NSUInteger)limit database:(FMDatabase *)fmdb;
- (NSString *)queryLatestDMMessageIdWithThreadId:(NSString *)threadId database:(FMDatabase *)fmdb;
- (BOOL)isExistsDMMessageWithId:(NSString *)messageId database:(FMDatabase *)fmdb;

- (BOOL)removeDMMessageWithId:(NSString *)messageId database:(FMDatabase *)fmdb;
- (BOOL)removeAllDMMessagesInDatabase:(FMDatabase *)fmdb;

//methods below for unsend message (audio)
- (void)saveUnsendDMMessages:(NSArray *)messages database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;

- (void)saveUnsendDMMessage:(KDDMMessage *)message database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;

- (void)updateUnsendDMMessagesWithThreadId:(NSString *)oldThreadId toNewThread:(NSString *)nThreadId database:(FMDatabase *)fmdb;

- (NSArray *)queryUnsendDMMessagesWithThreadId:(NSString *)threadId database:(FMDatabase *)fmdb;

- (NSArray *)queryAllThreadIdInUnsendDMMessageTableOfDatabase:(FMDatabase *)fmdb;

- (BOOL)removeUnsendDMMessageWithId:(NSString *)messageId database:(FMDatabase *)fmdb;

- (BOOL)removeUnsendDMMessageWithFilePath:(NSString *)filePath database:(FMDatabase *)fmdb;

- (BOOL)removeUnsendDMMessageWithThreadId:(NSString *)threadId database:(FMDatabase *)fmdb;

- (BOOL)hasUnsendMessageInDatabase:(FMDatabase *)fmdb;
@end
