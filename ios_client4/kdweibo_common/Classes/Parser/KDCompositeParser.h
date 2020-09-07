//
//  KDCompositeParser.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-11.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDBaseParser.h"

@class KDAppVersionUpdates;
@class KDUnread;

@interface KDCompositeParser : KDBaseParser

// parse as app version updates
- (KDAppVersionUpdates *)parseAsAppVersionUpdates:(NSDictionary *)body;

// parse as client applications list
- (NSArray *)parseAsClientApplications:(NSArray *)bodyList;

// parse as unread
- (KDUnread *)parseAsUnread:(NSDictionary *)body;

// parse as communities
- (NSArray *)parseAsCommunities:(NSArray *)bodyList;

// parse as topics
- (NSArray *)parseAsTopics:(NSArray *)bodyList;

// parse already invited person
- (NSArray *)parseAsABRecord:(NSArray *)bodyList;
@end
