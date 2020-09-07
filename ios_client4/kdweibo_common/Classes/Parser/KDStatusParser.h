//
//  KDStatusParser.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDBaseParser.h"
#import "KDStatus.h"

@class KDMentionMeStatus;
@class KDCommentMeStatus;
@class KDCommentStatus;
@class KDGroupStatus;

@interface KDStatusParser : KDBaseParser

// parse as normal status and forwarded status
- (KDStatus *)parseAsStatus:(NSDictionary *)body type:(KDTLStatusType)type;
- (NSArray *)parseAsStatuses:(NSArray *)body type:(KDTLStatusType)type;

- (NSArray *)parseAsStatusCountsList:(NSArray *)bodyList; // parse the forwards and comments count for statuses

// parse as mention me status
- (KDMentionMeStatus *)parseAsMentionMeStatus:(NSDictionary *)body;
- (NSArray *)parseAsMentionMeStatuses:(NSArray *)body;

// parse as comment me status
- (KDCommentMeStatus *)parseAsCommentMeStatus:(NSDictionary *)body;
- (NSArray *)parseAsCommentMeStatuses:(NSArray *)body;

// parse as comment status
- (KDCommentStatus *)parseAsCommentStatus:(NSDictionary *)body;
- (NSArray *)parseAsCommentStatuses:(NSArray *)body;

// parse as group status
- (KDGroupStatus *)parseAsGroupStatus:(NSDictionary *)body;
- (NSArray *)parseAsGroupStatuses:(NSArray *)body;

@end
