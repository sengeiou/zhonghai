//
//  KDDMMessageDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDDMMessageDAOImpl.h"

#import "KDDMMessage.h"
#import "KDWeiboDAOManager.h"
#import "KDAttachment.h"

@implementation KDDMMessageDAOImpl

- (void)_saveDMMessageExtraSource:(KDDMMessage *)message database:(FMDatabase *)fmdb {
    // save images
    if (message.extraSourceMask & KDExtraSourceMaskImages) {
        KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
        [[manager compositeImageSourceDAO] saveCompositeImageSource:message.compositeImageSource entityId:message.messageId database:fmdb];
    }
    
    // save documents
    if (message.extraSourceMask & KDExtraSourceMaskDocuments) {
        KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
        [[manager attachmentDAO] saveAttachments:message.attachments database:fmdb];
    }
}

- (void)_queryDMMessageExtraSource:(KDDMMessage *)message database:(FMDatabase *)fmdb {
    // retrieve images
    if (message.extraSourceMask & KDExtraSourceMaskImages) {
        KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
        message.compositeImageSource = [[manager compositeImageSourceDAO] queryCompositeImageSourceWithEntityId:message.messageId database:fmdb];
    }
    
    // retrieve documents
    if (message.extraSourceMask & KDExtraSourceMaskDocuments) {
        KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
        message.attachments = [[manager attachmentDAO] queryAttachmentsWithObjectId:message.messageId database:fmdb];
    }
}

- (void)saveDMMessages:(NSArray *)messages threadId:(NSString *)threadId
              database:(FMDatabase *)fmdb rollback:(BOOL *)rollback {
    if (threadId == nil || messages == nil || [messages count] == 0) return;
    
    NSString *sql = @"REPLACE INTO dm_thread_messages(message_id, thread_id, message, created_at,"
                     " is_system_message, unread, latitude, longitude, address, sender_id, recipient_id, mask) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    for (KDDMMessage *m in messages) {
        idx = 1;
        [stmt bindString:m.messageId atIndex:idx++];
        [stmt bindString:threadId  atIndex:idx++];
        [stmt bindString:m.message atIndex:idx++];
        
        [stmt bindDouble:m.createdAt atIndex:idx++];
        [stmt bindBool:m.isSystemMessage atIndex:idx++];
        [stmt bindBool:m.unread atIndex:idx++];
        [stmt bindFloat:m.latitude atIndex:idx++];
        [stmt bindFloat:m.longitude atIndex:idx++];
        [stmt bindString:m.address atIndex:idx++];
        
        [stmt bindString:m.sender.userId atIndex:idx++];
        [stmt bindString:m.recipient.userId atIndex:idx++];
        
        [stmt bindInt:(int)m.extraSourceMask atIndex:idx++];
        
        // step
        if ([stmt step]) {
            KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
            
            // save sender
            [[manager userDAO] saveUser:m.sender database:fmdb];
            
            [self _saveDMMessageExtraSource:m database:fmdb];
            
        } else {
            *rollback = YES; // rollback
            
            DLog(@"Can not save dm message with id=%@", m.messageId);
            
            break;
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
    
    // clear the expired dm messages for specificed thread. (just keep latest 20 items)
    if (![self cleanExpiredDMMessages:threadId limit:20 database:fmdb]) {
        DLog(@"Can not clean expired direct messages with specificed thread id=%@", threadId);
    }
}

- (NSArray *)queryDMMessagesWithThreadId:(NSString *)threadId limit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    if (threadId == nil) return nil;
    
    NSString *sql = @"SELECT message_id, message, created_at, is_system_message,"
                     " unread, latitude, longitude, address, sender_id, mask FROM dm_thread_messages"
                     " WHERE thread_id = ? ORDER BY created_at DESC limit ?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, threadId, @(limit)];
    
    KDDMMessage *m = nil;
    NSMutableArray *messages = [NSMutableArray array];
    
    int idx;
    while ([rs next]) {
        m = [[KDDMMessage alloc] init];
        
        idx = 0;
        m.messageId = [rs stringForColumnIndex:idx++];
        m.message = [rs stringForColumnIndex:idx++];
        
        m.createdAt = [rs doubleForColumnIndex:idx++];
        m.isSystemMessage = [rs boolForColumnIndex:idx++];
        m.unread = [rs boolForColumnIndex:idx++];
        m.latitude = [rs doubleForColumnIndex:idx++];
        m.longitude = [rs doubleForColumnIndex:idx++];
        m.address = [rs stringForColumnIndex:idx++];
        
        m.sender = [KDUser userWithId:[rs stringForColumnIndex:idx++] database:fmdb];
        m.extraSourceMask = [rs intForColumnIndex:idx++];
        
        if (m.extraSourceMask) {
            [self _queryDMMessageExtraSource:m database:fmdb];
        }
        
        [messages addObject:m];
    }
    
    [rs close];
    
    return messages;
}

- (NSString *)queryLatestDMMessageIdWithThreadId:(NSString *)threadId database:(FMDatabase *)fmdb {
    if (threadId == nil) return nil;
    
    NSString *sql = @"SELECT message_id FROM dm_thread_messages WHERE thread_id=?"
                     " ORDER BY created_at DESC LIMIT 1;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, threadId];
    NSString *messageId = ([rs next]) ? [rs stringForColumnIndex:0] : nil;
    [rs close];
    
    return messageId;
}

- (BOOL)isExistsDMMessageWithId:(NSString *)messageId database:(FMDatabase *)fmdb {
    if (messageId == nil) return NO;
    
    NSString *sql = @"SELECT COUNT(message_id) FROM dm_thread_messages WHERE message_id=?;";
    FMResultSet *rs = [fmdb executeQuery:sql, messageId];
    
    BOOL isExist = NO;
    if ([rs next]) {
        isExist = [rs intForColumnIndex:0] > 0;
    }
    
    [rs close];
    
    return isExist;
}

// each direct message thread only keep latest 20 messages.
- (BOOL)cleanExpiredDMMessages:(NSString *)threadId limit:(NSUInteger)limit database:(FMDatabase *)fmdb {
    NSString *sql = @"DELETE FROM dm_thread_messages WHERE thread_id = ? AND created_at <"
                     " (SELECT MIN(temp.created_at) FROM (SELECT created_at FROM dm_thread_messages"
                     " WHERE thread_id = ? ORDER BY created_at DESC LIMIT ?) AS temp);";
    
    return [fmdb executeUpdate:sql, threadId, threadId, @(limit)];
}

- (BOOL)removeDMMessageWithId:(NSString *)messageId database:(FMDatabase *)fmdb {
    if (messageId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM dm_thread_messages WHERE message_id=?;", messageId];
}

- (BOOL)removeAllDMMessagesInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM dm_thread_messages;"];
}


/************************************below methods for unsend message (audio)******************************************************/
- (void)saveUnsendDMMessages:(NSArray *)messages
                    database:(FMDatabase *)fmdb
                    rollback:(BOOL *)rollback
{
    if (messages == nil || [messages count] == 0) return;
    
    NSString *sql = @"REPLACE INTO unsend_messages(message_id, thread_id, message, created_at, mask,"
    "file_path, latitude, longitude, address) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    NSUInteger index = 0;
    for (KDDMMessage *m in messages) {
        idx = 1;
        [stmt bindString:m.messageId atIndex:idx++];
        [stmt bindString:m.threadId  atIndex:idx++];
        [stmt bindString:m.message atIndex:idx++];
        [stmt bindDouble:m.createdAt atIndex:idx++];
        [stmt bindInt:(int)m.extraSourceMask atIndex:idx++];
        
        NSString *filePath = nil;
        KDAttachment *attachment = [m.attachments lastObject];
        if([m hasAudio] && attachment) {
            filePath = attachment.url;
        }else {
            KDImageSource *is = [[m.compositeImageSource imageSources] lastObject];
            filePath = is.thumbnail;
        }
        [stmt bindString:filePath atIndex:idx++];
        [stmt bindFloat:m.latitude atIndex:idx++];
        [stmt bindFloat:m.longitude atIndex:idx++];
        [stmt bindString:m.address atIndex:idx++];
        
        // step
        if (![stmt step]) {
            
            if(rollback)
                *rollback = YES; // rollback
            
            DLog(@"Can not save dm message with id=%@", m.messageId);
            break;
        }
        [self _saveDMMessageExtraSource:m database:fmdb];
        // reset parameters
        [stmt reset];
        index++;
    }
    
    // finalize prepared statement
    [stmt close];
}

- (void)saveUnsendDMMessage:(KDDMMessage *)message  database:(FMDatabase *)fmdb rollback:(BOOL *)rollback {
    
    [self saveUnsendDMMessages:@[message] database:fmdb rollback:rollback];

}

- (void)updateUnsendDMMessagesWithThreadId:(NSString *)oldThreadId toNewThread:(NSString *)nThreadId database:(FMDatabase *)fmdb {
    if(oldThreadId == nil || nThreadId == nil) return;
    
    [fmdb executeUpdate:@"UPDATE unsend_messages SET thread_id = ? WHERE thread_id = ?", nThreadId, oldThreadId];
}

- (NSArray *)queryUnsendDMMessagesWithThreadId:(NSString *)threadId database:(FMDatabase *)fmdb {
    if(threadId == nil) return nil;
    
    NSString *sql = @"SELECT message_id, thread_id, message, created_at, mask, file_path, latitude, longitude, address FROM unsend_messages WHERE thread_id = ? ORDER BY created_at DESC";
    
    FMResultSet *rs = [fmdb executeQuery:sql, threadId];
    
    NSMutableArray *unsendMessages = [NSMutableArray arrayWithCapacity:rs.columnCount];
    
    while ([rs next]) {
        KDDMMessage *msg = [[KDDMMessage alloc] init];
        
        int idx = 0;
        
        msg.messageId = [rs stringForColumnIndex:idx++];
        msg.threadId = [rs stringForColumnIndex:idx++];
        msg.message = [rs stringForColumnIndex:idx++];
        msg.createdAt = [rs doubleForColumnIndex:idx++];
        msg.messageState = KDDMMessageStateUnsend;
        msg.unread = NO;
        
        msg.extraSourceMask = [rs intForColumnIndex:idx++];
        if (msg.extraSourceMask) {
            [self _queryDMMessageExtraSource:msg database:fmdb];
        }
        
        NSString *filePath = [rs stringForColumnIndex:idx++];
        if(filePath) {
            if([msg.message rangeOfString:ASLocalizedString(@"KDDMMessageDAOImpl_share_picture")].location != NSNotFound) {
                //photo
                KDImageSource *imageSource = [[KDImageSource alloc] init];
                imageSource.thumbnail = filePath;
                imageSource.middle = filePath;
                imageSource.original = filePath;
                msg.compositeImageSource = [[KDCompositeImageSource alloc] initWithImageSources:@[imageSource]];// autorelease];
//                [imageSource release];
            }else {
                KDAttachment *att = [[KDAttachment alloc] init];
                att.url = filePath;
                msg.attachments = [NSArray arrayWithObject:att];
//                [att release];
            }
        }
        
        msg.latitude = [rs doubleForColumnIndex:idx++];
        msg.longitude = [rs doubleForColumnIndex:idx++];
        msg.address = [rs stringForColumnIndex:idx++];
        
        [unsendMessages addObject:msg];
//        [msg release];
    }
    
    [rs close];
    
    return unsendMessages;
}

- (NSArray *)queryAllThreadIdInUnsendDMMessageTableOfDatabase:(FMDatabase *)fmdb {
    FMResultSet *rs = [fmdb executeQuery:@"SELECT DISTINCT thread_id FROM unsend_messages ORDER BY created_at DESC"];
    
    NSMutableArray *threadIds = [NSMutableArray arrayWithCapacity:2];
    while ([rs next]) {
        [threadIds addObject:[rs stringForColumnIndex:0]];
    }
    
    [rs close];
    
    return threadIds;
}

- (BOOL)removeUnsendDMMessageWithId:(NSString *)messageId database:(FMDatabase *)fmdb {
    if(messageId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM unsend_messages WHERE message_id = ?;", messageId];
}

- (BOOL)removeUnsendDMMessageWithFilePath:(NSString *)filePath database:(FMDatabase *)fmdb {
    if(filePath == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM unsend_messages WHERE file_path = ?", filePath];
}

- (BOOL)removeUnsendDMMessageWithThreadId:(NSString *)threadId database:(FMDatabase *)fmdb {
    if(threadId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM unsend_messages WHERE thread_id = ?", threadId];
}

- (BOOL)hasUnsendMessageInDatabase:(FMDatabase *)fmdb {
    FMResultSet *rs = [fmdb executeQuery:@"SELECT 1 FROM unsend_messages"];
    
    BOOL result = NO;
    if([rs next]) {
        result = YES;
    }
    
    [rs close];
    
    return result;
}

@end
