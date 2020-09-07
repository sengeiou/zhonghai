//
//  KDDBSchema.h
//  kdweibo_common
//
//  Created by shen kuikui on 13-7-5.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDDBSchema : NSObject

+ (NSDictionary *)tablesNameToSchema;

//create statuses_v2 table
+ (NSString *)statusSchema;

//create forwarded_statuses table
+ (NSString *)forwardedStatusSchema;

//create mention_me_statuses table
+ (NSString *)mentionMeSchema;

//create comment_me_statuse table;
+ (NSString *)commentMeSchema;

//create group_statuses_v2 table;
+ (NSString *)groupStatusSchema;

//create extend_statuses table
+ (NSString *)extendStatusSchema;

//create status_extra_messages table
+ (NSString *)statusExtraMessagesSchema;

//create dm_thread_messages table
+ (NSString *)dmThreadMessageSchema;

//create dm_threads table
+ (NSString *)dmThreadSchema;

//create users table
+ (NSString *)userSchema;

//create Topic table
+ (NSString *)topicSchema;

//create attachments table
+ (NSString *)attachmentSchema;

//create unsend_messages table
+ (NSString *)unsendMessageSchema;

//create drafts table
+ (NSString *)draftSchema;

//create groups table
+ (NSString *)groupSchema;

//create votes table
+ (NSString *)voteSchema;

//create vote_options table
+ (NSString *)voteOptionSchema;

//create downloads table
+ (NSString *)downloadSchema;

//create images_source table;
+ (NSString *)imageSourceSchema;

//create ab_persons table
+ (NSString *)abPersonSchema;

//create inbox table
+ (NSString *)inboxSchema;

//create signinRecord table
+ (NSString *)signinRecordSchema;

//create application table
+ (NSString *)applicationSchema;

/*
==========================================EMAIL TABLE=======================================================
 
                            Created at 2013-10-23  by  xiongyuxiang
 
*/

//create accounts table
+ (NSString *)accountsSchema;

//create folders table
+ (NSString *)foldersSchema;

//create emails table
+ (NSString *)emailsSchema;

//create addressses table

+ (NSString *)addressesSchema;

//create attachments table
+ (NSString *)attachmentsSchema;

//create contacts table
+ (NSString *)contactsSchema;
@end
