//
//  KDDBSchema.m
//  kdweibo_common
//
//  Created by shen kuikui on 13-7-5.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDDBSchema.h"

@implementation KDDBSchema

+ (NSDictionary *)tablesNameToSchema
{
    NSDictionary * dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"statuses_v2", [self statusSchema],
                          @"forwarded_statuses", [self forwardedStatusSchema],
                          @"mention_me_statuses", [self mentionMeSchema],
                          @"comment_me_statuses", [self commentMeSchema],
                          @"group_statuses_v2", [self groupStatusSchema],
                          @"extend_statuses", [self extendStatusSchema],
                          @"status_extra_messages", [self statusExtraMessagesSchema],
                          @"dm_thread_messages", [self dmThreadMessageSchema],
                          @"dm_threads", [self dmThreadSchema],
                          @"users", [self userSchema],
                          @"frequent_contacts", [self frequentContactsSchema],
                          @"Topic", [self topicSchema],
                          @"attachments", [self attachmentSchema],
                          @"unsend_messages", [self unsendMessageSchema],
                          @"drafts", [self draftSchema],
                          @"groups", [self groupSchema],
                          @"votes", [self voteSchema],
                          @"vote_options", [self voteOptionSchema],
                          @"downloads", [self downloadSchema],
                          @"images_source", [self imageSourceSchema],
                          @"ab_persons", [self abPersonSchema],
                          @"inboxSchema",[self inboxSchema],
                          @"todoSchema",[self todoSchema],
                          @"signinSchema", [self signinRecordSchema],
                          @"application", [self applicationSchema],
                          @"e_accounts", [self accountsSchema],
                          @"e_folders", [self foldersSchema],
                          @"e_emails", [self emailsSchema],
                          @"e_addresses", [self addressesSchema],
                          @"e_attachments", [self attachmentsSchema],
                          @"e_contacts", [self contactsSchema],
                          nil];
    
    return dic;// autorelease];
}

+ (NSString *)statusSchema
{
    static NSString * const statusSQL = @"CREATE TABLE IF NOT EXISTS statuses_v2 ("
    "id TEXT,"
    "user_id TEXT,"
    "content TEXT,"
    "source TEXT,"
    "forwarded_status_id TEXT,"
    "extend_status_id TEXT,"
    "extra_message_id TEXT,"
    "created_at DOUBLE,"
    "updated_at DOUBLE,"
    "favorited SMALLINT,"
    "truncated SMALLINT,"
    "liked     SMALLINT,"
    "latitude FLOAT,"
    "longitude FLOAT,"
    "address  TEXT,"
    "comments_count INTEGER,"
    "forwards_count INTEGER,"
    "liked_count  INTEGER,"
    "type SMALLINT,"
    "mask INTEGER,"
    "group_id TEXT,"
    "group_name TEXT,"
    "sending_state SMALLINT,"
	"PRIMARY KEY(id, type)"
    ");";
    
    return statusSQL;
}

+ (NSString *)forwardedStatusSchema
{
    static NSString * const forwardedStatusSQL = @"CREATE TABLE IF NOT EXISTS forwarded_statuses ("
    "id TEXT PRIMARY KEY,"
    "user_id TEXT,"
    "content TEXT,"
    "source TEXT,"
    "forwarded_status_id TEXT,"
    "extend_status_id TEXT,"
    "extra_message_id TEXT,"
    "created_at DOUBLE,"
    "updated_at DOUBLE,"
    "favorited SMALLINT,"
    "truncated SMALLINT,"
    "liked     SMALLINT,"
    "latitude FLOAT,"
    "longitude FLOAT,"
    "address TEXT,"
    "comments_count INTEGER,"
    "forwards_count INTEGER,"
    "liked_count  INTEGER,"
    "mask INTEGER"
    ");";
    
    return forwardedStatusSQL;
}

+ (NSString *)mentionMeSchema
{
    static NSString * const mentionMeStatusSQL = @"CREATE TABLE IF NOT EXISTS mention_me_statuses ("
    "id TEXT PRIMARY KEY,"
    "user_id TEXT,"
    "content TEXT,"
    "source TEXT,"
    "forwarded_status_id TEXT,"
    "extend_status_id TEXT,"
    "extra_message_id TEXT,"
    "created_at DOUBLE,"
    "updated_at DOUBLE,"
    "favorited SMALLINT,"
    "truncated SMALLINT,"
    "liked     SMALLINT,"
    "latitude FLOAT,"
    "longitude FLOAT,"
    "address TEXT,"
    "comments_count INTEGER,"
    "forwards_count INTEGER,"
    "liked_count  INTEGER,"
    "mask INTEGER,"
    "group_id TEXT,"
    "group_name TEXT"
    ");";
    
    return mentionMeStatusSQL;
}

+ (NSString *)commentMeSchema
{
    static NSString * const commentMeStatusSQL = @"CREATE TABLE IF NOT EXISTS comment_me_statuses ("
    "id TEXT PRIMARY KEY,"
    "user_id TEXT,"
    "content TEXT,"
    "source TEXT,"
    "forwarded_status_id TEXT,"
    "extend_status_id TEXT,"
    "extra_message_id TEXT,"
    "created_at DOUBLE,"
    "updated_at DOUBLE,"
    "favorited SMALLINT,"
    "truncated SMALLINT,"
    "liked     SMALLINT,"
    "latitude FLOAT,"
    "longitude FLOAT,"
    "address   TEXT,"
    "comments_count INTEGER,"
    "forwards_count INTEGER,"
    "liked_count  INTEGER,"
    "mask INTEGER,"
    "reply_status_id TEXT,"
    "reply_user_id TEXT,"
    "reply_screen_name TEXT,"
    "reply_status_text TEXT,"
    "reply_comment_text TEXT,"
    "group_id TEXT,"
    "group_name TEXT"
    ");";
    
    return commentMeStatusSQL;
}

+ (NSString *)groupStatusSchema
{
    static NSString * const groupStatusSQL = @"CREATE TABLE IF NOT EXISTS group_statuses_v2 ("
    "id TEXT PRIMARY KEY,"
    "user_id TEXT,"
    "content TEXT,"
    "source TEXT,"
    "forwarded_status_id TEXT,"
    "extend_status_id TEXT,"
    "extra_message_id TEXT,"
    "created_at DOUBLE,"
    "updated_at DOUBLE,"
    "favorited SMALLINT,"
    "truncated SMALLINT,"
    "liked SMALLINT,"
    "latitude FLOAT,"
    "longitude FLOAT,"
    "address TEXT,"
    "comments_count INTEGER,"
    "forwards_count INTEGER,"
    "liked_count   INTEGER,"
    "mask INTEGER,"
    "group_id TEXT,"
    "sending_state SMALLINT"
    ");";
    
    return groupStatusSQL;
}

+ (NSString *)extendStatusSchema
{
    static NSString * const extendStatusSQL = @"CREATE TABLE IF NOT EXISTS extend_statuses ("
    "id TEXT PRIMARY KEY,"
    "site TEXT,"
    "content TEXT,"
    "sender_name TEXT,"
    "fwd_sender_name TEXT,"
    "fwd_content TEXT,"
    "created_at INTEGER,"
    "forwarded_at INTEGER,"
    "mask INTEGER"
    ");";
    
    return extendStatusSQL;
}

+ (NSString *)statusExtraMessagesSchema
{
    static NSString * const statusExtraMessageSQL = @"CREATE TABLE IF NOT EXISTS status_extra_messages ("
    "id TEXT PRIMARY KEY,"
    "application_url TEXT,"
    "type TEXT,"
    "reference_id TEXT,"
    "tenant_id TEXT,"
    "exectors_id TEXT,"
    "exectors_name TEXT,"
    "visibility TEXT,"
    "needFinish_date DOUBLE, "
    "content TEXT"
    ");";
    
    return statusExtraMessageSQL;
}

+ (NSString *)dmThreadMessageSchema
{
    static NSString * const dmThreadMessageSQL = @"CREATE TABLE IF NOT EXISTS dm_thread_messages ("
    "message_id TEXT NOT NULL PRIMARY KEY,"
	"thread_id TEXT,"
    "message TEXT,"
    "created_at DOUBLE,"
    "is_system_message SMALLINT,"
    "unread SMALLINT,"
    "latitude FLOAT,"
    "longitude FLOAT,"
    "address  TEXT,"
    "sender_id TEXT,"
    "recipient_id TEXT,"
    "mask INTEGER"
    ");";
    
    return dmThreadMessageSQL;
}

+ (NSString *)dmThreadSchema
{
    static NSString * const dmThreadSQL = @"CREATE TABLE IF NOT EXISTS dm_threads ("
	"thread_id TEXT NOT NULL,"
	"subject TEXT,"
    "thread_avatar_url TEXT,"
	"created_at DOUBLE,"
	"updated_at DOUBLE,"
    "latest_dm_id TEXT,"
    "latest_dm_text TEXT,"
    "latest_dm_sender_id TEXT,"
    "unread_count INTEGER,"
    "participant_ids TEXT,"
    "participants_count INTEGER,"
    "participant_urls TEXT,"
    "public SMALLINT,"
    "is_Top BOOL,"
    "PRIMARY KEY(thread_id,is_Top)"
    ");";
    
    return dmThreadSQL;
}

+ (NSString *)userSchema
{
    static NSString * const userSQL = @"CREATE TABLE IF NOT EXISTS users ("
    "'user_id'                TEXT PRIMARY KEY,"
    "'name'                   TEXT,"
    "'screen_name'            TEXT,"
    "'email'					 TEXT,"
    "'profile_image_url'      TEXT,"
	"'followees'              INTEGER,"
	"'fans'                   INTEGER,"
	"'following'              INTEGER,"
	"'latitude'               DOUBLE,"
	"'longitude'				 DOUBLE,"
	"'locationAddress'        TEXT,"
	"'description'             TEXT,"
	"'statuses_count'         INTEGER,"
	"'favorites_count'       INTEGER,"
    "'department'            TEXT,"
    "'job'                   TEXT,"
    "'topic'                     INTEGER,"
    "'company_name'                   TEXT,"
    "'is_team_user' SMALLINT,"
    "'is_public_user' SMALLINT"
    ");";
    
    return userSQL;
}

+ (NSString *)frequentContactsSchema
{
    static NSString * const frequentContacts = @"CREATE TABLE IF NOT EXISTS frequent_contacts("
    "user_id        TEXT PRIMARY KEY,"
    "type           INTEGER"
    ")";
    
    return frequentContacts;
}

+ (NSString *)topicSchema
{
    static NSString * const topicSQL = @"CREATE TABLE IF NOT EXISTS Topic("
    "topicid TEXT NOT NULL,"
    "topicName TEXT,"
    "PRIMARY KEY(topicid)"
    ");";
    
    return topicSQL;
}

+ (NSString *)attachmentSchema
{
    static NSString * const attachmentSQL = @"CREATE TABLE IF NOT EXISTS attachments ("
    "id TEXT NOT NULL ,"
    "object_id TEXT NOT NULL,"
    "name TEXT,"
    "content_type TEXT,"
    "url TEXT,"
    "file_size INTEGER,"
    "PRIMARY KEY(id,object_id)"
    ");";
    
    return attachmentSQL;
}

+ (NSString *)unsendMessageSchema
{
    static NSString * const unsendMessageSQL = @"CREATE TABLE IF NOT EXISTS unsend_messages ("
    "message_id TEXT NOT NULL PRIMARY KEY,"
    "thread_id TEXT,"
    "message TEXT,"
    "created_at DOUBLE,"
    "file_path TEXT,"
    "latitude FLOAT,"
    "longitude FLOAT,"
    "address  TEXT,"
    "mask INTEGER"
    ");";
    
    return unsendMessageSQL;
}

+ (NSString *)draftSchema
{
    static NSString * const draftSQL = @"CREATE TABLE IF NOT EXISTS drafts("
    "id INTEGER PRIMARY KEY,"
    "type INTEGER,"
    "author_id TEXT,"
    "created_at DOUBLE,"
    "content TEXT,"
    "status_content TEXT,"
    "comment_on_status_id TEXT,"
    "comment_on_comment_id TEXT,"
    "reply_name TEXT,"
    "forwarded_id TEXT,"
    "group_id TEXT,"
    "group_name TEXT,"
    "image_data BLOB,"
    "mask INTEGER,"
    "latitude FLOAT,"
    "longitude FLOAT,"
    "address  TEXT,"
    "video_path TEXT,"
    "sending INTEGER,"
    "uploadedImages TEXT,"
    "do_extra_comment_or_forward  SMALLINT"
    ");";
    
    return draftSQL;
}

+ (NSString *)groupSchema
{
    static NSString * const groupSQL = @"CREATE TABLE IF NOT EXISTS groups ("
    "id TEXT PRIMARY KEY,"
    "name TEXT,"
    "profile_image_url TEXT,"
    "summary TEXT,"
    "bulletin TEXT,"
    "latestMsgContent TEXT,"
    "latestMsgDate DATE,"
    "type INTEGER,"
    "sorting_index INTEGER"
    ");";
    
    return groupSQL;
}

+ (NSString *)voteSchema
{
    static NSString * const voteSQL = @"CREATE TABLE IF NOT EXISTS votes("
    "vote_id TEXT PRIMARY KEY,"
    "name TEXT,"
    "author_id TEXT,"
    "max_vote_item_count INTEGER,"
    "participant_count INTEGER,"
    "created_time DOUBLE,"
    "closed_time DOUBLE,"
    "is_ended BOOL,"
    "selected_option_ids TEXT,"
    "state SMALLINT,"
    "min_vote_item_count INTEGER,"
    "canRevote BOOL"
    ");";
    
    return voteSQL;
}

+ (NSString *)voteOptionSchema
{
    static NSString * const voteOptionSQL = @"CREATE TABLE IF NOT EXISTS vote_options("
    "vote_id TEXT,"
    "option_id TEXT,"
    "name TEXT,"
    "count INTEGER,"
    "PRIMARY KEY(vote_id, option_id)"
    ");";
    
    return voteOptionSQL;
}

+ (NSString *)downloadSchema
{
    static NSString * const downloadSQL = @"CREATE TABLE IF NOT EXISTS downloads ("
    "'id'                      TEXT NOT NULL PRIMARY KEY ,"
    "'name'                    TEXT NOT NULL,"
    "'entity_id'               TEXT NOT NULL,"
    "'entity_type'             INTEGER  NOT NULL DEFAULT -1,"
    "'start_at'                DOUBLE,"
    "'end_at'                  DOUBLE,"
    "'url'                     TEXT NOT NULL,"
    "'path'                    TEXT,"
    "'temp_path'               TEXT,"
    "'downdload_state'         INTEGER   NOT NULL DEFAULT 0 ,"
    "'current_byte'            INTEGER NOT NULL DEFAULT 0,"
    "'max_byte'                INTEGER NOT NULL DEFAULT -1,"
    "'mime_type'               TEXT"
    ");";
    
    return downloadSQL;
}

+ (NSString *)imageSourceSchema
{
    static NSString * const imageSourceSQL = @"CREATE TABLE IF NOT EXISTS images_source ("
    "file_id  TEXT NOT NULL,"
    "entity_id TEXT NOT NULL,"
    "file_name TEXT,"
    "file_type TEXT,"
	"thumbnail TEXT,"
    "middle TEXT,"
	"original TEXT,"
    "is_upload BOOL,"
    "noRawUrl TEXT,"
    "PRIMARY KEY(file_id, entity_id)"
    ");";
    
    return imageSourceSQL;
}

+ (NSString *)abPersonSchema
{
    static NSString * const abPersonSQL = @"CREATE TABLE IF NOT EXISTS ab_persons ("
	"pid TEXT NOT NULL,"
    "user_id TEXT NOT NULL,"
	"name TEXT,"
    "job_title TEXT,"
	"department TEXT,"
    "emails TEXT,"
    "phones TEXT,"
    "mobiles TEXT,"
    "profile_image_url TEXT,"
    "network_id TEXT,"
    "favorited SMALLINT,"
    "type SMALLINT,"
    "sorting_time INTEGER,"
    "PRIMARY KEY(pid, type)"
    ");";
    
    return abPersonSQL;
}

+ (NSString *)inboxSchema
{
    static NSString * const inboxSQL = @"CREATE TABLE IF NOT EXISTS inbox ("
    "lId TEXT NOT NULL,"
    "refUserName TEXT,"
	"participants TEXT,"
    "networkId TEXT,"
	"unReadCount DOUBLE,"
    "updateTime DOUBLE,"
	"isUpdate BOOL,"
    "isNew BOOL,"
    "refId TEXT,"
    "latestFeed TEXT,"
    "type TEXT NOT NULL,"
    "itemsIdentifier TEXT,"
    "participantsPhoto TEXT,"
    "isUnRead BOOL,"
    "groupName TEXT,"
    "createTime DOUBLE,"
    "isDelete BOOL,"
    "groupId TEXT,"
    "refUserId TEXT,"
    "content TEXT,"
    "userId TEXT,"
    "senderUserId TEXT,"
    "PRIMARY KEY(lId , type)"
    ");";
    
    return inboxSQL;

}
+ (NSString *)todoSchema
{
    static NSString * const todoSQL = @"CREATE TABLE IF NOT EXISTS todo ("
    "fromId TEXT NOT NULL,"
    "todoId TEXT NOT NULL,"
    "fromType TEXT,"
	"networkId TEXT,"
    "actName TEXT,"
	"createDate DATE,"
    
    "contentHead TEXT,"
    "title TEXT,"
    "toUserId TEXT,"
    
    "fromUserId TEXT,"
    "connectType TEXT,"
    
    "updateDate DATE,"
    
    "actDate DATE,"
    
    "status TEXT,"
    
    "content TEXT,"
    
    "action TEXT,"
    
    "taskCommentCount TEXT,"
    
    "PRIMARY KEY(todoId)"

    ");";
    
    return todoSQL;
}

+ (NSString *)signinRecordSchema
{
    static NSString * const signinSQL = @"CREATE TABLE IF NOT EXISTS signin_record ("
    "singinId TEXT NOT NULL,"
    "featurename TEXT,"
    "content TEXT,"
    "status SMALLINT,"
    "singinTime DOUBLE,"
    "latitude FLOAT,"
    "longitude FLOAT,"
    "mbShare TEXT,"
    "recordType INT,"
    "photoIds TEXT,"
    "cachesUrl TEXT,"
    "inComany INT,"
    "clockInType TEXT,"
    "ssid TEXT,"
    "bssid TEXT,"
    "managerOid TEXT,"
    "manualType INT,"
    "org_latitude FLOAT,"
    "org_longitude FLOAT,"
    "address TEXT,"
    "PRIMARY KEY(singinId)"
    ");";
    
    return signinSQL;
}

+ (NSString *)applicationSchema
{
    static NSString * const applicationSQL = @"CREATE TABLE IF NOT EXISTS application("
    "appId TEXT PRIMARY KEY NOT NULL,"
    "desc TEXT,"
    "detailDesc TEXT,"
    "httpUrl TEXT,"
    "iconUrl TEXT,"
    "installUrl TEXT,"
    "key TEXT,"
    "mobileType TEXT,"
    "name TEXT,"
    "networkId TEXT,"
    "schemeUrl TEXT,"
    "tenantId TEXT,"
    "appVersion TEXT,"
    "needAuth BOOL"
    ");";
    
    return applicationSQL;
}


/////////////////////////////////////////////////////////////////////EMAIL TABLES/////////////////////////////////////////////////////////////////////////////////

+ (NSString *)accountsSchema
{
    static NSString * const accountsSQL = @"CREATE TABLE IF NOT EXISTS e_accounts ("
    "username TEXT PRIMARY KEY NOT NULL,"
    "type        SMALLINT,"
    "isDefaultAccount BOOL,"
    "isGetConfig BOOL,"
    "imapConfig TEXT,"
    "smtpConfig TEXT,"
    "pop3Config TEXT,"
    "profileImageURL TEXT,"
    "company TEXT,"
    "post TEXT,"
    "mobiles TEXT,"
    "phones TEXT,"
    "summary TEXT,"
    "name    TEXT,"
    "department TEXT"
    ");";
    return accountsSQL;
}
+ (NSString *)foldersSchema
{
    static NSString * const foldersSQL = @"CREATE TABLE IF NOT EXISTS e_folders ("
    "username TEXT PRIMARY KEY NOT NULL,"
    "folderPath TEXT NOT NULL,"
    "totalMessages SMALLINT,"
    "unReadMessages SMALLINT,"
    "firstUid    MEDIUMINT,"
    "largerUid  MEDIUMINT,"
    "littleUid  MEDIUMINT,"
    "isFolderGetAllEmail BOOL,"
    "isSynced BOOL"
    ");";
    return foldersSQL;
}

+ (NSString *)emailsSchema
{
    static NSString * const emailsSQL = @"CREATE TABLE IF NOT EXISTS e_emails ("
    "username TEXT NOT NULL,"
    "folderPath TEXT NOT NULL,"
    "senderName TEXT,"
    "senderAddress TEXT,"
    "subject TEXT,"
    "body TEXT,"
    "htmlBody TEXT,"
    "references1 TEXT,"
    "flags INT,"
    "uid MEDIUMINT NOT NULL,"
    "messageId TEXT,"
    "datetime  DATE NOT NULL,"
    "status  INT,"
    "PRIMARY KEY(uid, folderPath) "
    ");";
    return emailsSQL;
}
+ (NSString *)addressesSchema
{
    
    static NSString * const addressesSQL = @"CREATE TABLE IF NOT EXISTS e_addresses ("
    "name    TEXT,"
    "address TEXT NOT NULL,"
    "flag SMALLINT,"
    "folderPath TEXT,"
    "uid MEDIUMINT  NOT NULL,"
    "username TEXT NOT NULL"
    ");";
    return addressesSQL;
}
+ (NSString *)attachmentsSchema
{
    static NSString * const attachmentsSQL = @"CREATE TABLE IF NOT EXISTS e_attachments ("
    "uid MEDIUMINT NOT NULL,"
    "filename TEXT NOT NULL,"
    "contentType TEXT  NOT NULL,"
    "filePath TEXT,"
    "contentId TEXT,"
    "folder   TEXT,"
    "isDownloaded BOOL,"
    "type      INT,"
    "username TEXT NOT NULL,"
    "size      MEDIUMINT"
    ");";
    return attachmentsSQL;
}
+ (NSString *)contactsSchema
{
    static NSString * const contactsSQL = @"CREATE TABLE IF NOT EXISTS e_contacts ("
    "emailAddress TEXT ,"
    "emailName TEXT  ,"
    "type SMALLINT  ,"
    "emails TEXT  ,"
    "department TEXT  ,"
    "favorited BOOL  ,"
    "jobTitle TEXT  ,"
    "mobiles TEXT  ,"
    "networkId TEXT  ,"
    "phones TEXT  ,"
    "profileImageURL TEXT  ,"
    "userId          TEXT,"
    "name        TEXT"
    ");";
    return contactsSQL;
}
@end
