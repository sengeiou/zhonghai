//
//  KDStatusExtraMessageDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-5.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDStatusExtraMessageDAOImpl.h"
#import "KDStatusExtraMessage.h"

/*@property(nonatomic, retain) NSString *exectorId;
 @property(nonatomic, retain) NSString *visibility;
 @property(nonatomic, retain) NSDate  *needFinishDate;
 @property(nonatomic, retain) NSString *exctorName;
 @property(nonatomic, retain) NSString *content;
 
 */

@implementation KDStatusExtraMessageDAOImpl

- (void)saveStatusExtraMessage:(KDStatusExtraMessage *)message database:(FMDatabase *)fmdb {
    if (message == nil) return;
    
    NSString *sql = @"REPLACE INTO status_extra_messages(id, application_url, type, reference_id, tenant_id,exectors_id,exectors_name,visibility,needFinish_date,content)"
                     " VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?,?)";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx = 1;
    [stmt bindString:message.extraId atIndex:idx++];
    [stmt bindString:message.applicationURL  atIndex:idx++];
    [stmt bindString:message.type atIndex:idx++];
    [stmt bindString:message.referenceId atIndex:idx++];
    [stmt bindString:message.tenantId atIndex:idx++];
    [stmt bindString:message.exectorId atIndex:idx++];
    [stmt bindString:message.exctorName atIndex:idx++];
    [stmt bindString:message.visibility atIndex:idx++];
    [stmt bindDouble:message.needFinishDate atIndex:idx++];
    [stmt bindString:message.content atIndex:idx++];
    
    // step
    if (![stmt step]) {
        DLog(@"Can not save status extra message with id=%@", message.extraId);
    }
    
    // finalize prepared statement
    [stmt close];
}

- (KDStatusExtraMessage *)queryStatusExtraMessageWithId:(NSString *)messageId database:(FMDatabase *)fmdb {
    if (messageId == nil) return nil;
    
    NSString *sql = @"SELECT application_url, type, reference_id, tenant_id,exectors_id,exectors_name,visibility,needFinish_date,content FROM status_extra_messages WHERE id = ?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, messageId];
    
    KDStatusExtraMessage *m = nil;
    if ([rs next]) {
        m = [[KDStatusExtraMessage alloc] init];// autorelease];
        
        int idx = 0;
        m.extraId = messageId;
        m.applicationURL = [rs stringForColumnIndex:idx++];
        m.type = [rs stringForColumnIndex:idx++];
        m.referenceId = [rs stringForColumnIndex:idx++];
        m.tenantId = [rs stringForColumnIndex:idx++];
        m.exectorId = [rs stringForColumnIndex:idx++];
        m.exctorName = [rs stringForColumnIndex:idx++];
        m.visibility = [rs stringForColumnIndex:idx++];
        m.needFinishDate = [rs doubleForColumnIndex:idx++];
        m.content = [rs stringForColumnIndex:idx++];
    }
    
    [rs close];
    
    return m;
}

- (BOOL)removeStatusExtraMessageWithId:(NSString *)messageId database:(FMDatabase *)fmdb {
    if (messageId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM status_extra_messages WHERE id=?;", messageId];
}

- (BOOL)removeAllStatusExtraMessagesInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM status_extra_messages;"];
}

@end
