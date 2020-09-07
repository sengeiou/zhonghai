//
//  KDStatusExtraMessageDAO.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-5.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class KDStatusExtraMessage;

@protocol KDStatusExtraMessageDAO <NSObject>
@required

- (void)saveStatusExtraMessage:(KDStatusExtraMessage *)message database:(FMDatabase *)fmdb;
- (KDStatusExtraMessage *)queryStatusExtraMessageWithId:(NSString *)messageId database:(FMDatabase *)fmdb;

- (BOOL)removeStatusExtraMessageWithId:(NSString *)messageId database:(FMDatabase *)fmdb;
- (BOOL)removeAllStatusExtraMessagesInDatabase:(FMDatabase *)fmdb;

@end
