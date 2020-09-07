//
//  XTDatabaseTableManager.m
//  kdweibo
//
//  Created by Gil on 14-4-17.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTDatabaseTableManager.h"

const NSString *createTableHeaderSQL = @"CREATE TABLE IF NOT EXISTS";

const NSString *privateGroupTableName = @"privategroup";
const NSString *publicGroupTableName = @"publicgroup";
const NSString *participantTableName = @"participant";
const NSString *personTableName = @"person";
const NSString *contactTableName = @"contact";
const NSString *publicAccountTableName = @"publicaccount";
const NSString *messageTableName = @"message";
const NSString *applicationTableName = @"application";
const NSString *recentlyTableName = @"recently";

const NSString *jobTableName = @"job";
const NSString *toDoTableName = @"todo";   //代办通知及以后的公共号逻辑
const NSString *messageReadStateTableName = @"kd_msg_readstate";


const NSString *signInRemindTableName = @"kd_signInRemind";

//标记相关的表
const NSString *markTableName = @"kd_mark";
const NSString *markEventTableName = @"kd_mark_event";

const NSString *privateGroupTableParams =  @"(\n  \t\'groupId\' VARCHAR PRIMARY KEY NOT NULL, \n  \t\'groupType\' INTEGER NOT NULL DEFAULT 1, \n  \t\'groupName\' VARCHAR, \n\t\'unreadCount\' INTEGER NOT NULL DEFAULT 0, \n\t\'lastMsgId\' VARCHAR, \n\t\'lastMsgSendTime\' VARCHAR, \n\t\'status\' INTEGER NOT NULL DEFAULT 3, \n\t\'updateTime\' VARCHAR,\n\t\'fold\' INTEGER NOT NULL DEFAULT 1, \n\t\'draft\' VARCHAR,\n\t\'showInTimeline\' INTEGER DEFAULT 1, \n\t\'headerUrl\' VARCHAR,\n\t\'param\' VARCHAR,\n\t\'participantIds\' VARCHAR,\n\t\'mCallStatus\' INTEGER DEFAULT (0),\n\t\'micDisable\' INTEGER DEFAULT (0),\n\t\'managerIds\' VARCHAR,\n\t\'lastMsgDesc\' VARCHAR,\n\t\'todoStatus\' VARCHAR\n);";
const NSString *publicGroupTableParams = @"(\n\t\'groupId\' VARCHAR PRIMARY KEY NOT NULL,\n\t\'publicId\' VARCHAR NOT NULL,\n\t\'groupType\' INTEGER NOT NULL  DEFAULT (1),\n\t\'groupName\' VARCHAR,\n\t\'unreadCount\' INTEGER NOT NULL  DEFAULT (0),\n\t\'lastMsgId\' VARCHAR,\n\t\'lastMsgSendTime\' VARCHAR,\n\t\'status\' INTEGER NOT NULL  DEFAULT (3),\n\t\'updateTime\' VARCHAR,\n\t\'personId\' VARCHAR, \n\t\'personName\' VARCHAR, \n\t\'defaultPhone\' VARCHAR, \n\t\'department\' VARCHAR, \n\t\'photoUrl\' VARCHAR, \n\t\'personStatus\' INTEGER DEFAULT 0, \n\t\'jobTitle\' VARCHAR,\n\t\'wbUserId\' VARCHAR,\n\t\'lastMsgDesc\' VARCHAR\n);";
const NSString *participantTableParams = @"(\n\t\'groupId\' VARCHAR NOT NULL ,\n\t\'personId\' VARCHAR NOT NULL\n);";
const NSString *personTableParams = @"(\n\t\'id\' INTEGER PRIMARY KEY AUTOINCREMENT DEFAULT NULL, \n\t\'personId\' VARCHAR DEFAULT NULL, \n\t\'personName\' VARCHAR, \n\t\'defaultPhone\' VARCHAR, \n\t\'department\' VARCHAR, \n\t\'fullPinyin\' VARCHAR, \n\t\'photoUrl\' VARCHAR, \n\t\'status\' INTEGER DEFAULT 0, \n\t\'jobTitle\' VARCHAR,\n\t\'note\' VARCHAR, \n\t\'reply\' VARCHAR, \n\t\'subscribe\' VARCHAR, \n\t\'canUnsubscribe\' VARCHAR, \n\t\'menu\' VARCHAR, \n\t\'wbUserId\' VARCHAR,\n\t\'isAdmin\' INTEGER DEFAULT (0),\n\t\'share\' INTEGER DEFAULT (1), \n\t\'oid\' VARCHAR, \n\t\'orgId\' VARCHAR\n);";
const NSString *contactTableParams = @"(\n\t\'personId\' VARCHAR NOT NULL DEFAULT \'\' ,\n\t\'text\' VARCHAR,\n\t\'value\' VARCHAR,\n\t\'type\' INTEGER NOT NULL  DEFAULT 0\n);";
const NSString *publicAccountTableParams = @"(\n\t\'id\' integer PRIMARY KEY AUTOINCREMENT DEFAULT NULL, \n\t\'personId\' varchar DEFAULT NULL, \n\t\'personName\' varchar, \n\t\'defaultPhone\' varchar, \n\t\'department\' varchar, \n\t\'fullPinyin\' varchar, \n\t\'photoUrl\' varchar, \n\t\'status\' integer DEFAULT 0, \n\t\'jobTitle\' varchar, \n\t\'note\' varchar, \n\t\'reply\' varchar, \n\t\'subscribe\' varchar, \n\t\'canUnsubscribe\' varchar, \n\t\'menu\' varchar, \n\t\'manager\' INTEGER DEFAULT (0),\n\t\'share\' INTEGER DEFAULT (1)\n,\n\t\'fold\' INTEGER DEFAULT (1)\n);";
const NSString *messageTableParams = @"(\n\t\'msgId\' VARCHAR PRIMARY KEY  NOT NULL,\n\t\'fromUserId\' VARCHAR,\n\t\'sendTime\' VARCHAR,\n\t\'msgType\' INTEGER NOT NULL  DEFAULT (0),\n\t\'msgLen\' INTEGER NOT NULL  DEFAULT (0),\n\t\'content\' VARCHAR,\n\t\'status\' INTEGER NOT NULL  DEFAULT (1),\n\t\'direction\' INTEGER DEFAULT (1),\n\t\'fromUserNickName\' VARCHAR,\n\t\'groupId\' VARCHAR,\n\t\'toUserId\' VARCHAR,\n\t\'requestType\' INTEGER NOT NULL  DEFAULT (0),\n\t\'param\' VARCHAR,\n\t\'notifyType\' INTEGER NOT NULL  DEFAULT (0),\n\t\'notifyDesc\' VARCHAR,\n\t\'emojiType\' VARCHAR,\n\t\'important\' INTEGER NOT NULL  DEFAULT (0)\n,\n\t\'sourceMsgId\' VARCHAR\n,\n\t\'fromClientId\' VARCHAR\n);";
const NSString *applicationTableParams = @"(\n\t\'appClientId\' VARCHAR PRIMARY KEY NOT NULL, \n\t\'appType\' VARCHAR, \n\t\'appName\' VARCHAR, \n\t\'appLogo\' VARCHAR, \n\t\'appClientSchema\' VARCHAR, \n\t\'appWebURL\' VARCHAR, \n\t\'appDldURL\' VARCHAR\n);";
const NSString *recentlyTableParams = @"(\n\t\'personId\'  PRIMARY KEY NOT NULL,\n\t\'lastContactTime\' VARCHAR\n);";

const NSString *jobTableParams = @"(\n\t\'id\' INTEGER PRIMARY KEY AUTOINCREMENT DEFAULT NULL,\n\t\'personId\' VARCHAR,\n\t\'orgId\' VARCHAR,\n\t\'eName\' VARCHAR,\n\t\'jobType\' INTEGER DEFAULT (0),\n\t\'jobTitle\' VARCHAR,\n\t\'department\' VARCHAR\n);";

//todo
//const NSString *toDoTableParams = @"(\n\t\'messageId\' VARCHAR PRIMARY KEY NOT NULL,\n\t\'readState\' VARCHAR\n,\n\t\'doneState\' VARCHAR\n);";
const NSString *toDoTableParams = @"(\n\t\'msgId\' VARCHAR PRIMARY KEY NOT NULL,\n\t\'xtMsgId\' VARCHAR,\n\t\'fromUserId\' VARCHAR,\n\t\'sendTime\' VARCHAR,\n\t\'msgType\' INTEGER NOT NULL  DEFAULT (0),\n\t\'msgLen\' INTEGER NOT NULL  DEFAULT (0),\n\t\'content\' VARCHAR,\n\t\'status\' INTEGER NOT NULL  DEFAULT (1),\n\t\'direction\' INTEGER DEFAULT (1),\n\t\'fromUserNickName\' VARCHAR,\n\t\'groupId\' VARCHAR,\n\t\'toUserId\' VARCHAR,\n\t\'requestType\' INTEGER NOT NULL  DEFAULT (0),\n\t\'param\' VARCHAR,\n\t\'notifyType\' INTEGER NOT NULL  DEFAULT (0),\n\t\'notifyDesc\' VARCHAR,\n\t\'emojiType\' VARCHAR\n,\n\t\'important\' INTEGER NOT NULL  DEFAULT (0)\n,\n\t\'sourceMsgId\' VARCHAR\n,\n\t\'readState\' VARCHAR\n,\n\t\'todoStatus\' VARCHAR\n,\n\t\'appid\' VARCHAR\n,\n\t\'row\' VARCHAR\n,\n\t\'name\' VARCHAR\n,\n\t\'text\' VARCHAR\n,\n\t\'title\' VARCHAR\n,\n\t\'url\' VARCHAR\n,\n\t\'date\' VARCHAR\n,\n\t\'messageMode\' VARCHAR\n,\n\t\'score\' VARCHAR\n);";

const NSString *messageReadStateParams = @"(\n\t\'msgId\' VARCHAR PRIMARY KEY NOT NULL,\n\t\'groupId\' VARCHAR\n,\n\t\'unreadCount\' VARCHAR\n,\n\t\'press\' VARCHAR\n);";



const NSString *markTableParams = @"(\n\'id\' VARCHAR PRIMARY KEY NOT NULL,\n\'title\' VARCHAR,\n\'titleDesc\' VARCHAR,\n\'headUrl\' VARCHAR,\n\'type\' INTEGER,\n\'text\' VARCHAR,\n\'imgUrl\' VARCHAR,\n\'icon\' VARCHAR,\n\'header\' VARCHAR,\n\'uri\' VARCHAR,\n\'updateTime\' VARCHAR,\n\'humanReadableUpdateTime\' VARCHAR\n);";
const NSString *markEventTableParams = @"(\n\'markId\' VARCHAR PRIMARY KEY NOT NULL,\n\'eventId\' VARCHAR\n);";

const NSString *signInRemindParams = @"(\n\t\'remindId\' VARCHAR PRIMARY KEY NOT NULL,\n\t\'isRemind\' VARCHAR\n,\n\t\'repeatType\' INTEGER,\n\t\'remindTime\' VARCHAR\n);";

static NSArray *tableNames = nil;
static NSArray *tableParams = nil;

@implementation XTDatabaseTableManager

+ (void)initialize
{
    tableNames = @[privateGroupTableName,publicGroupTableName,participantTableName,personTableName,contactTableName,publicAccountTableName,messageTableName,applicationTableName,recentlyTableName,jobTableName,toDoTableName,messageReadStateTableName,markTableName, markEventTableName,signInRemindTableName];
    
    tableParams = @[privateGroupTableParams,publicGroupTableParams,participantTableParams,personTableParams,contactTableParams,publicAccountTableParams,messageTableParams,applicationTableParams,recentlyTableParams,jobTableParams ,toDoTableParams,messageReadStateParams,markTableParams, markEventTableParams,signInRemindParams];
}

+ (NSString *)tableNameWithTableType:(XTTableType)tableType eId:(NSString *)eId
{
    if (eId.length == 0) {
        return nil;
    }
    if (tableType <= XTTableTypeMin) {
        return nil;
    }
    if (tableType >= XTTableTypeMax) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@_%@",tableNames[tableType],eId];
}

+ (NSString *)createTableSQLWithTableType:(XTTableType)tableType eId:(NSString *)eId
{
    if (eId.length == 0) {
        return nil;
    }
    if (tableType <= XTTableTypeMin) {
        return nil;
    }
    if (tableType >= XTTableTypeMax) {
        return nil;
    }
    NSString *sql = [createTableHeaderSQL stringByAppendingFormat:@" %@ ",[self tableNameWithTableType:tableType eId:eId]];
    sql = [sql stringByAppendingString:tableParams[tableType]];
    return sql;
}

@end
