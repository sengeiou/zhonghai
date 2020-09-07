//
//  KDAttachmentDAO.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class KDAttachment;

@protocol KDAttachmentDAO <NSObject>
@required

- (void)saveAttachment:(KDAttachment *)attachment database:(FMDatabase *)fmdb;
- (void)saveAttachments:(NSArray *)attachments database:(FMDatabase *)fmdb;

- (NSArray *)queryAttachmentsWithObjectId:(NSString *)objectId database:(FMDatabase *)fmdb;

- (BOOL)removeAttachmentsForObjectId:(NSString *)objectId database:(FMDatabase *)fmdb;

@end
