//
//  KDStatusExtraMessage.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-4.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDObject.h"
extern NSString * const kKDStatusExtraMessageConnector;
extern NSString * const kKDStatusExtraMessageVote;
extern NSString * const kKDStatusExtraMessagePraise;
extern NSString * const kKDStatusExtraMessageBulletin;
extern NSString * const kKDStatusExtraMessageFreshman;

extern NSString * const kKDStatusExtraMessageProperties;
extern NSString * const kKDStatusExtraMessageTemporaryProperties;

@interface KDStatusExtraMessage : KDObject

@property(nonatomic, retain) NSString *extraId;
@property(nonatomic, retain) NSString *applicationURL;
@property(nonatomic, retain) NSString *type;

//referenceId: may be vote id;
@property(nonatomic, retain) NSString *referenceId;

@property(nonatomic, retain) NSString *tenantId;

//for task
@property(nonatomic, retain) NSString *exectorId;
@property(nonatomic, retain) NSString *visibility;
@property(nonatomic, assign) NSTimeInterval  needFinishDate;
@property(nonatomic, retain) NSString *exctorName;
@property(nonatomic, retain) NSString *content;

- (BOOL)isConnector;
- (BOOL)isVote;
- (BOOL)isPraise;
- (BOOL)isBulletin;
- (BOOL)isFreshman;
- (BOOL)isTask;
- (BOOL)shouldShowTaskDetail:(NSString*)userId;
// format status extra message and append to specific content if need
// it just support (Praise, Bulletin, Freshman), and return nil for the other message type. 
+ (NSString *)formatExtraMessage:(KDStatusExtraMessage *)message appendToContent:(NSString *)content;

@end
