//
//  XTDataBaseDao.m
//  XT
//
//  Created by Gil on 13-7-31.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//
#import "NSJSONSerialization+KDCategory.h"
#import "XTDataBaseDao.h"
#import "BOSFileManager.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "T9SearchPerson.h"

#import "MFAppDataModel.h"
#import "MFWebAppDataModel.h"

#import "XTDatabaseTableManager.h"
#import "BOSConfig.h"
#import "T9Utils.h"
#import "NSJSONSerialization+KDCategory.h"

#import "KDToDoMessageDataModel.h"
#import "XTSetting.h"


@interface XTDataBaseDao ()
@property (strong, nonatomic) NSString *openId;
@property (strong, nonatomic) NSString *eId;
@property (nonatomic, copy) NSString *databasePath;
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@end

@implementation XTDataBaseDao

#define TABLE_GROUP [self tableNameWithTableType:XTTableTypePrivateGroup]
#define TABLE_PUBLIC_GROUP [self tableNameWithTableType:XTTableTypePublicGroup]
#define TABLE_MESSAGE [self tableNameWithTableType:XTTableTypeMessage]
#define TABLE_T9_PERSON [self tableNameWithTableType:XTTableTypePerson]
#define TABLE_PUBLIC_PERSON [self tableNameWithTableType:XTTableTypePublicAccount]
#define TABLE_PARTICIPANT [self tableNameWithTableType:XTTableTypeParticipant]
#define TABLE_CONTACT [self tableNameWithTableType:XTTableTypeContact]
#define TABLE_PERSONAL_APP [self tableNameWithTableType:XTTableTypeApplication]
#define TABLE_RECENTLY [self tableNameWithTableType:XTTableTypeRecently]
//todo
#define TABLE_TODO          [self tableNameWithTableType : XTTableTypeToDo]
#define TABLE_MSGREADSTATE  [self tableNameWithTableType : XTTableTypeMessageReadState]

//职位表 add by lee
#define TABLE_JOB [self tableNameWithTableType:XTTableTypeJob]

//标记
#define TABLE_MARK             [self tableNameWithTableType : XTTableTypeMark]
#define TABLE_MARK_EVENT       [self tableNameWithTableType : XTTableTypeMarkEvent]

//签到提醒
#define TABLE_SIGNINREMIND  [self tableNameWithTableType : XTTableTypeSignInRemind]

+ (XTDataBaseDao *)sharedDatabaseDaoInstance
{
    static dispatch_once_t pred;
    static XTDataBaseDao *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[XTDataBaseDao alloc] init];
    });
    return instance;
}

- (void)setOpenId:(NSString *)openId eId:(NSString *)eId
{
    
    NSParameterAssert(openId);
    NSParameterAssert(eId);
    
    //切换了账号
    if (![openId isEqualToString:self.openId]) {
        
        self.openId = openId;
        self.databasePath = [BOSFileManager xuntongDBPathWithOpenId:openId];
        if (self.databasePath) {
            self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.databasePath];
        }
        
        self.eId = eId;
        [self createTablesAndIndexs];
        
        return;
    }
    
    //同一个账号，切换了企业
    if (![eId isEqualToString:self.eId]) {
        self.eId = eId;
        [self createTablesAndIndexs];
    }
}
- (BOOL)tableExists:(NSString*)tableName FMDatabase:(FMDatabase*)db
{
    NSString * sql = [NSString stringWithFormat:@"select sql from sqlite_master where tbl_name = '%@' and type = 'table';",tableName];
    FMResultSet *rs = [db executeQuery:sql];
    
    BOOL returnBool = [rs next];
    
    //close and free object
    [rs close];
    
    return returnBool;
}
- (NSString *)tableNameWithTableType:(XTTableType)tableType
{
    return [XTDatabaseTableManager tableNameWithTableType:tableType eId:self.eId];
}

- (BOOL)createTablesAndIndexs {
    
    __block BOOL result = YES;
    
    //新建表
    [self.databaseQueue inTransaction: ^(FMDatabase *db, BOOL *rollback) {
#if DEBUG
        db.logsErrors = YES;
#endif
        
        //判断是否存在todo列表 为了兼容旧数据的待办信息
        if (![self tableExists:TABLE_TODO FMDatabase:db]) {
            [[XTSetting sharedSetting] setUpdateTime:nil];
            [[XTSetting sharedSetting] saveSetting];
        }
        //建表
        NSString *sql = nil;
        for (int i = XTTableTypeMin + 1; i < XTTableTypeMax; i++) {
            sql = [XTDatabaseTableManager createTableSQLWithTableType:i eId:self.eId];
            result = result && [db executeUpdate:sql];
        }
        
        //建索引
        //person表上personId唯一性索引
        sql = [NSString stringWithFormat:@"CREATE UNIQUE INDEX IF NOT EXISTS %@_unique_personId ON %@(\'personId\');",TABLE_T9_PERSON,TABLE_T9_PERSON];
        result = result && [db executeUpdate:sql];
        //publicaccount表上personId唯一性索引
        sql = [NSString stringWithFormat:@"CREATE UNIQUE INDEX IF NOT EXISTS %@_unique_personId ON %@(\'personId\');",TABLE_PUBLIC_PERSON,TABLE_PUBLIC_PERSON];
        result = result && [db executeUpdate:sql];
        
        // APP由升级更新到最新版本时, 由于不会走建表的流程, 所以通过追加字段的方式添加.
        // 草稿
        BOOL hasColumn = [self existFieldInTable:TABLE_GROUP fieldName:@"draft" db:db];
        if (!hasColumn) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'draft' VARCHAR", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        // @提及 Message的type
        if (![self existFieldInTable:TABLE_MESSAGE fieldName:@"notifyType" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'notifyType' INTEGER NOT NULL DEFAULT (0)", TABLE_MESSAGE];
            result = result && [db executeUpdate:sql];
        }
        // @提及 Message的desc
        if (![self existFieldInTable:TABLE_MESSAGE fieldName:@"notifyDesc" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'notifyDesc' VARCHAR", TABLE_MESSAGE];
            result = result && [db executeUpdate:sql];
        }
        // @提及 PrivateGroup的type
        if (![self existFieldInTable:TABLE_GROUP fieldName:@"notifyType" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'notifyType' INTEGER NOT NULL DEFAULT (0)", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        // @提及 PrivateGroup的desc
        if (![self existFieldInTable:TABLE_GROUP fieldName:@"notifyDesc" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'notifyDesc' VARCHAR", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        
        // 表情的标示 Message的emojiType
        if (![self existFieldInTable:TABLE_MESSAGE fieldName:@"emojiType" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'emojiType' VARCHAR", TABLE_MESSAGE];
            result = result && [db executeUpdate:sql];
        }
        
        // 应用表添加公共号字段 KDAppDataModel的pid
        if (![self existFieldInTable:TABLE_PERSONAL_APP fieldName:@"pid" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'pid' VARCHAR", TABLE_PERSONAL_APP];
            result = result && [db executeUpdate:sql];
        }
        
        // 应用表添加公共号字段 KDAppDataModel的deleteAble
        if (![self existFieldInTable:TABLE_PERSONAL_APP fieldName:@"deleteAble" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'deleteAble' VARCHAR", TABLE_PERSONAL_APP];
            result = result && [db executeUpdate:sql];
        }
        
        // 应用表添加公共号字段 KDAppDataModel的FIOSLaunchParams
        if (![self existFieldInTable:TABLE_PERSONAL_APP fieldName:@"FIOSLaunchParams" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'FIOSLaunchParams' VARCHAR", TABLE_PERSONAL_APP];
            result = result && [db executeUpdate:sql];
        }
        //应用类型
        if (![self existFieldInTable:TABLE_PERSONAL_APP fieldName:@"appClasses" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'appClasses' VARCHAR", TABLE_PERSONAL_APP];
            result = result && [db executeUpdate:sql];
        }
        
        //公共号会话组表增加几个字段
        if (![self existFieldInTable:TABLE_PUBLIC_GROUP fieldName:@"personId" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'personId' VARCHAR;", TABLE_PUBLIC_GROUP];
            result = result && [db executeUpdate:sql];
        }
        if (![self existFieldInTable:TABLE_PUBLIC_GROUP fieldName:@"personName" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'personName' VARCHAR;", TABLE_PUBLIC_GROUP];
            result = result && [db executeUpdate:sql];
        }
        if (![self existFieldInTable:TABLE_PUBLIC_GROUP fieldName:@"defaultPhone" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'defaultPhone' VARCHAR;", TABLE_PUBLIC_GROUP];
            result = result && [db executeUpdate:sql];
        }
        if (![self existFieldInTable:TABLE_PUBLIC_GROUP fieldName:@"department" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'department' VARCHAR;", TABLE_PUBLIC_GROUP];
            result = result && [db executeUpdate:sql];
        }
        if (![self existFieldInTable:TABLE_PUBLIC_GROUP fieldName:@"photoUrl" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'photoUrl' VARCHAR;", TABLE_PUBLIC_GROUP];
            result = result && [db executeUpdate:sql];
        }
        if (![self existFieldInTable:TABLE_PUBLIC_GROUP fieldName:@"personStatus" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'personStatus' INTEGER DEFAULT 0;", TABLE_PUBLIC_GROUP];
            result = result && [db executeUpdate:sql];
        }
        if (![self existFieldInTable:TABLE_PUBLIC_GROUP fieldName:@"jobTitle" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'jobTitle' VARCHAR;", TABLE_PUBLIC_GROUP];
            result = result && [db executeUpdate:sql];
        }
        if (![self existFieldInTable:TABLE_PUBLIC_GROUP fieldName:@"wbUserId" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'wbUserId' VARCHAR;", TABLE_PUBLIC_GROUP];
            result = result && [db executeUpdate:sql];
        }
        
        //  公共号表增加share字段
        if (![self existFieldInTable:TABLE_PUBLIC_PERSON fieldName:@"share" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'share' INTEGER DEFAULT (1);", TABLE_PUBLIC_PERSON];
            result = result && [db executeUpdate:sql];
        }
        
        //公共号增加remind字段
        if (![self existFieldInTable:TABLE_PUBLIC_PERSON fieldName:@"remind" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'remind' INTEGER DEFAULT (1);", TABLE_PUBLIC_PERSON];
            result = result && [db executeUpdate:sql];
        }
        
        // TABLE_PUBLIC_PERSON + lastMsgDesc
        if (![self existFieldInTable:TABLE_PUBLIC_PERSON fieldName:@"lastMsgDesc" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'lastMsgDesc' VARCHAR", TABLE_PUBLIC_PERSON];
            result = result && [db executeUpdate:sql];
        }
        
        
        
        //  Person表增加share字段
        if (![self existFieldInTable:TABLE_T9_PERSON fieldName:@"share" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'share' INTEGER DEFAULT (1);", TABLE_T9_PERSON];
            result = result && [db executeUpdate:sql];
        }
        
        
        //Gil privateGroup表增加showInTimeline字段，表示某个会话组是否在timeline中显示（当用户删除组时设置此标志为false）
        if (![self existFieldInTable:TABLE_GROUP fieldName:@"showInTimeline" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'showInTimeline' INTEGER DEFAULT (1);", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        
        //  person表增加isAdmin字段
        if (![self existFieldInTable:TABLE_T9_PERSON fieldName:@"isAdmin" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'isAdmin' INTEGER DEFAULT (0)", TABLE_T9_PERSON];
            result = result && [db executeUpdate:sql];
        }
        
        // Group + headerUrl
        if (![self existFieldInTable:TABLE_GROUP fieldName:@"headerUrl" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'headerUrl' VARCHAR", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        // privategroup + menu
        if (![self existFieldInTable:TABLE_GROUP fieldName:@"menu" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'menu' VARCHAR", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        // privateGroupTableParams + param
        if (![self existFieldInTable:TABLE_GROUP fieldName:@"param" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'param' VARCHAR", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        
        // privateGroupTableParams + participantIds
        if (![self existFieldInTable:TABLE_GROUP fieldName:@"participantIds" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'participantIds' VARCHAR", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        
        // Group + lastMsgDesc
        if (![self existFieldInTable:TABLE_GROUP fieldName:@"lastMsgDesc" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'lastMsgDesc' VARCHAR", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        
        // Group + todoStatus
        if (![self existFieldInTable:TABLE_GROUP fieldName:@"todoStatus" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'todoStatus' VARCHAR", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        // Group + updateScore
        if (![self existFieldInTable:TABLE_GROUP fieldName:@"updateScore" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'updateScore' VARCHAR", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        //是否需要更新人员
        // Group + needUdate
        if (![self existFieldInTable:TABLE_GROUP fieldName:@"localUpdateScore" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'localUpdateScore' VARCHAR", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        
        //是否需要更新人员
        // Group + needUdate
        if (![self existFieldInTable:TABLE_GROUP fieldName:@"userCount" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'userCount' VARCHAR", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        
        // privateGroupTableParams + participant
        //        if (![self existFieldInTable:TABLE_GROUP fieldName:@"participant" db:db]) {
        //            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'participant' VARCHAR", TABLE_GROUP];
        //            result = result && [db executeUpdate:sql];
        //        }
        //
        // TABLE_MESSAGE + important
        if (![self existFieldInTable:TABLE_MESSAGE fieldName:@"important" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'important' VARCHAR", TABLE_MESSAGE];
            result = result && [db executeUpdate:sql];
        }
        // TABLE_MESSAGE + headerUrl
        if (![self existFieldInTable:TABLE_MESSAGE fieldName:@"sourceMsgId" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'sourceMsgId' VARCHAR", TABLE_MESSAGE];
            result = result && [db executeUpdate:sql];
        }
        
        // TABLE_MESSAGE + fold
        if (![self existFieldInTable:TABLE_PUBLIC_PERSON fieldName:@"fold" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'fold' VARCHAR", TABLE_PUBLIC_PERSON];
            result = result && [db executeUpdate:sql];
        }
        
        // TABLE_MESSAGE + fromClientId
        if (![self existFieldInTable:TABLE_MESSAGE fieldName:@"fromClientId" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'fromClientId' VARCHAR", TABLE_MESSAGE];
            result = result && [db executeUpdate:sql];
        }
        
        
        // TODO_TABLE + xtMsgId
        if (![self existFieldInTable:TABLE_TODO fieldName:@"xtMsgId" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'xtMsgId' VARCHAR", TABLE_TODO];
            result = result && [db executeUpdate:sql];
        }
        // TODO_TABLE + score
        if (![self existFieldInTable:TABLE_TODO fieldName:@"score" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'score' VARCHAR", TABLE_TODO];
            result = result && [db executeUpdate:sql];
        }
        
        // TABLE_MESSAGE + isOriginalPic
        if (![self existFieldInTable:TABLE_MESSAGE fieldName:@"isOriginalPic" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'isOriginalPic' VARCHAR", TABLE_MESSAGE];
            result = result && [db executeUpdate:sql];
        }
        
        // TABLE_MESSAGE + fromUserPhoto //消息发送者头像
        if (![self existFieldInTable:TABLE_MESSAGE fieldName:@"fromUserPhoto" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'fromUserPhoto' VARCHAR", TABLE_MESSAGE];
            result = result && [db executeUpdate:sql];
        }
        // TABLE_MESSAGE + fromUserName;//消息发送者姓名
        if (![self existFieldInTable:TABLE_MESSAGE fieldName:@"fromUserName" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'fromUserName' VARCHAR", TABLE_MESSAGE];
            result = result && [db executeUpdate:sql];
        }
        
        if(![self existFieldInTable:TABLE_GROUP fieldName:@"mCallStatus" db:db])
        {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'mCallStatus' INTEGER DEFAULT (0);", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        //6.0.3 private_group表增加micDisable liulichao
        if(![self existFieldInTable:TABLE_GROUP fieldName:@"micDisable" db:db])
        {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'micDisable' INTEGER DEFAULT (0);", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        
        // privateGroupTableParams + managerIds
        if (![self existFieldInTable:TABLE_GROUP fieldName:@"managerIds" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'managerIds' VARCHAR", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        
        //商务伙伴字段paramType
        if(![self existFieldInTable:TABLE_T9_PERSON fieldName:@"partnerType" db:db])
        {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'partnerType' INTEGER DEFAULT (0);", TABLE_T9_PERSON];
            result = result && [db executeUpdate:sql];
        }
        
        if(![self existFieldInTable:TABLE_GROUP fieldName:@"partnerType" db:db])
        {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'partnerType' INTEGER DEFAULT (0);", TABLE_GROUP];
            result = result && [db executeUpdate:sql];
        }
        
        //6.0.3 T9表增加oid
        if(![self existFieldInTable:TABLE_T9_PERSON fieldName:@"oid" db:db])
        {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'oid' VARCHAR", TABLE_T9_PERSON];
            result = result && [db executeUpdate:sql];
        }
        
        //6.0.3 T9表增加orgId
        if(![self existFieldInTable:TABLE_T9_PERSON fieldName:@"orgId" db:db])
        {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'orgId' VARCHAR", TABLE_T9_PERSON];
            result = result && [db executeUpdate:sql];
        }
        
        
        //公共号状态字段
        if(![self existFieldInTable:TABLE_PUBLIC_PERSON fieldName:@"state" db:db])
        {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'state' INTEGER DEFAULT (2);", TABLE_PUBLIC_PERSON];
            result = result && [db executeUpdate:sql];
        }
        
        //公共号增加hisNews字段
        if (![self existFieldInTable:TABLE_PUBLIC_PERSON fieldName:@"hisNews" db:db]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'hisNews' INTEGER DEFAULT (0);", TABLE_PUBLIC_PERSON];
            result = result && [db executeUpdate:sql];
        }
        
        
        //性别
        if(![self existFieldInTable:TABLE_T9_PERSON fieldName:@"gender" db:db])
        {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD 'gender' INTEGER DEFAULT (0);", TABLE_T9_PERSON];
            result = result && [db executeUpdate:sql];
        }
    }];
    
    return result;
    
}


- (BOOL)existFieldInTable:(NSString*)tablename fieldName:(NSString*)field
                       db:(FMDatabase *)db
{
    BOOL hasColumn = NO;
    NSString * sql = [NSString stringWithFormat:@"select sql from sqlite_master where tbl_name = '%@' and type = 'table';",tablename];
    FMResultSet *rs = [db executeQuery:sql];
    if ([rs next]) {
        NSString *tableCreateSQL = [rs stringForColumnIndex:0];
        hasColumn = ([tableCreateSQL rangeOfString:field].location != NSNotFound);
    }
    [rs close];
    return hasColumn;
}

- (BOOL)deleteAllData {
    
    __block BOOL result = YES;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        for (int i = XTTableTypeMin + 1; i < XTTableTypeMax; i++) {
            NSString *tableName = [self tableNameWithTableType:i];
            result = result && [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@;", tableName]];
        }
    }];
    
    return result;
}

- (BOOL)deleteAllDataExpectPersonTabale
{
    __block BOOL result = YES;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        for (int i = XTTableTypeMin + 1; i < XTTableTypeMax; i++) {
            NSString *tableName = [self tableNameWithTableType:i];
            if (![tableName isEqualToString:TABLE_T9_PERSON]) {
                result = result && [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@;", tableName]];
            }
        }
    }];
    
    return result;
}
#pragma mark - private group

- (NSArray *)queryPrivateGroupList:(NSString **)unreadCount
{
    NSMutableArray *groups = [NSMutableArray array];
    NSMutableArray *groupIds = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        //查询所有的会话记录，包括它的最后一条消息
        NSString * sql = [NSString stringWithFormat:@"SELECT\n\ta.groupId,\n\ta.groupType,\n\ta.groupName,\n\ta.unreadCount,\n\ta.lastMsgId,\n\ta.partnerType,\n\tb.fromUserId,\n\ta.lastMsgSendTime,\n\tb.msgType,\n\tb.msgLen,\n\tb.content,\n\tb.status AS \'bStatus\',\n\tb.direction,\n\tb.requestType,\n\tb.fromUserNickName,\n\ta.updateTime,\n\ta.status AS \'aStatus\',\n\ta.fold,\n\ta.draft,\n\ta.headerUrl,\n\ta.param,\n\ta.participantIds\nFROM\n\t%@ a\nLEFT JOIN %@ b ON a.lastMsgId = b.msgId\nWHERE\n\t((a.status >> 3) & 1)\nORDER BY\n\ta.lastMsgSendTime DESC;", TABLE_GROUP, TABLE_MESSAGE];
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            GroupDataModel *group = [self loadGroupWithResultSet:rs];
            [groups addObject:group];
        }
    }];
    
    //参与人 personId 列表
    NSMutableDictionary *paticipants = [[NSMutableDictionary alloc] initWithDictionary:[self loadPaticipantIds:groupIds]];
    
    NSMutableSet *personIds = [[NSMutableSet alloc] init];
    for (NSArray *paticipant in [paticipants allValues]) {
        [personIds addObjectsFromArray:paticipant];
    }
    NSDictionary *persons = [[NSDictionary alloc] initWithDictionary:[self loadPersons:[personIds allObjects]]];
    
    int count = 0;
    for (GroupDataModel *group in groups) {
        count += group.unreadCount;
        NSArray *paticipantIds = [paticipants objectForKey:group.groupId];
        for (NSString *paticipantId in paticipantIds) {
            PersonSimpleDataModel *person = [persons objectForKey:paticipantId];
            if (person != nil) {
                [group.participant addObject:person];
            }
        }
    }
    
    if (unreadCount != nil) {
        *unreadCount = [NSString stringWithFormat:@"%d",count];
    }
    
    return groups;
}

- (NSArray *)queryFavoriteGroupList:(NSString **)unreadCount
{
    NSMutableArray *groups = [NSMutableArray array];
    NSMutableArray *groupIds = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        //        //查询所有的会话记录，包括它的最后一条消息
        //        NSString *sql = @"SELECT a.groupId,a.groupType,a.groupName,a.unreadCount,a.lastMsgId,\nb.fromUserId,a.lastMsgSendTime,b.msgType,b.msgLen,b.content,\nb.status as \'bStatus\',b.direction,b.requestType,b.fromUserNickName,\na.updateTime,a.status as \'aStatus\'";
        //        sql = [sql stringByAppendingString:@",a.menu,a.fold"];
        //        sql = [sql stringByAppendingFormat:@" FROM %@ a left join %@ b on a.lastMsgId = b.msgId",TABLE_GROUP,TABLE_MESSAGE];
        //        sql = [sql stringByAppendingString:@" WHERE ((a.status >> 3) & 1)"];//是否已收藏的判断
        //        sql = [sql stringByAppendingString:@" Order by a.lastMsgSendTime Desc;"];
        //查询收藏的会话记录，包括它的最后一条消息
        
        NSString * sql = [NSString stringWithFormat:@"SELECT\n\t*\nFROM\n\t%@\nWHERE\n\t((status >> 3) & 1)\nORDER BY\n\tlastMsgSendTime DESC;", TABLE_GROUP];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            GroupDataModel *group = [self loadGroupWithResultSet:rs];
            [groups addObject:group];
            [groupIds addObject:group.groupId];
        }
        [rs close];
    }];
    
    //参与人 personId 列表
    NSMutableDictionary *paticipants = [[NSMutableDictionary alloc] initWithDictionary:[self loadPaticipantIds:groupIds]];
    
    NSMutableSet *personIds = [[NSMutableSet alloc] init];
    for (NSArray *paticipant in [paticipants allValues]) {
        [personIds addObjectsFromArray:paticipant];
    }
    NSDictionary *persons = [[NSDictionary alloc] initWithDictionary:[self loadPersons:[personIds allObjects]]];
    
    int count = 0;
    for (GroupDataModel *group in groups) {
        count += group.unreadCount;
        NSArray *paticipantIds = [paticipants objectForKey:group.groupId];
        for (NSString *paticipantId in paticipantIds) {
            PersonSimpleDataModel *person = [persons objectForKey:paticipantId];
            if (person != nil) {
                [group.participant addObject:person];
            }
        }
    }
    
    if (unreadCount != nil) {
        *unreadCount = [NSString stringWithFormat:@"%d",count];
    }
    
    return groups;
}



- (GroupDataModel *)queryPrivateGroupWithPerson:(PersonSimpleDataModel *)person
{
    __block GroupDataModel *group = nil;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString * sql = [NSString stringWithFormat:@"SELECT\n\t*\nFROM\n\t%@\nWHERE\n\tparticipantIds LIKE ?", TABLE_GROUP];
        if (![person isPublicAccount]) {
            sql = [sql stringByAppendingFormat:@"\nAND groupType = %d\n", GroupTypeDouble];
        }
        sql = [sql stringByAppendingString:@"LIMIT 1;\n"];
        
        FMResultSet *rs = [db executeQuery:sql, [NSString stringWithFormat:@"%%%@%%",person.personId]];
        if ([rs next]) {
            group = [self loadGroupWithResultSet:rs];
        }
        [rs close];
        
        //成员信息
        [group.participant addObject:person];
        //706 去重
        if (![group.participantIds containsObject:person.personId]) {
            [group.participantIds addObject:person.personId];
        }
        
    }];
    
    return group;
    
}

//特别定制一个查询来填坑，只查询group(从通讯录或者发现进老板开讲数据异常)
- (GroupDataModel *)queryPrivateGroupWithPersonForPublic:(PersonSimpleDataModel *)person
{
    __block GroupDataModel *group = nil;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString * sql = [NSString stringWithFormat:@"Select * from %@ where groupId Like ?", TABLE_GROUP];
        sql = [sql stringByAppendingString:@"LIMIT 1;\n"];
        
        FMResultSet *rs = [db executeQuery:sql, [NSString stringWithFormat:@"%%%@%%",person.personId]];
        if ([rs next]) {
            group = [self loadGroupWithResultSet:rs];
            if(group)
                [group.participant addObject:person];
            
        }
        [rs close];
    }];
    
    return group;
    
}

- (GroupDataModel *)queryPrivateGroupWithGroupId:(NSString *)groupId
{
    __block GroupDataModel *group = nil;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        //        NSString *sql = [NSString stringWithFormat:@"SELECT\n\ta.groupId,\n\ta.groupType,\n\ta.groupName,\n\ta.unreadCount,\n\ta.lastMsgId,\n\tb.fromUserId,\n\ta.lastMsgSendTime,\n\tb.msgType,\n\tb.msgLen,\n\tb.content,\n\tb.status AS \'bStatus\',\n\tb.direction,\n\tb.requestType,\n\tb.fromUserNickName,\n\ta.updateTime,\n\ta.status AS \'aStatus\',\n\ta.fold,\n\ta.draft,\n\ta.headerUrl,\n\ta.param,\n\ta.participantIds,\n\tmCallStatus,\n\tmicDisable\nFROM\n\t%@ a\nLEFT JOIN %@ b ON a.lastMsgId = b.msgId\nWHERE\n\ta.groupId = ?;", TABLE_GROUP, TABLE_MESSAGE];
        NSString *sql = [NSString stringWithFormat:@"SELECT\n\t*\nFROM\n\t%@\nWHERE\n\tgroupId = ?;", TABLE_GROUP];
        FMResultSet *rs = [db executeQuery:sql, groupId];
        if ([rs next]) {
            group = [self loadGroupWithResultSet:rs];
            [self queryParticipant:group db:db];
        }
        [rs close];
    }];
    
    return group;
    
}

- (GroupDataModel *)queryPrivateGroupWithGroupName:(NSString *)groupName
{
    return [self queryPrivateGroupWithGroupNameOrId:groupName byId:NO];
}

- (GroupDataModel *)queryPrivateGroupWithGroupNameOrId:(NSString *)value byId:(BOOL)byId
{
    __block GroupDataModel *group = nil;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString * field = byId ? @"groupId": @"groupName";
        NSString *sql = @"SELECT a.groupId,a.groupType,a.groupName,a.unreadCount,\
        a.lastMsgId,b.fromUserId,a.lastMsgSendTime,b.msgType,\
        b.msgLen,b.content,b.status as 'bStatus',b.direction,\
        b.requestType,b.fromUserNickName, \
        a.updateTime,a.status as 'aStatus',a.fold,a.menu,a.partnerType";
        sql = [sql stringByAppendingFormat:@" FROM %@ a left join %@ b \
               on a.lastMsgId = b.msgId \
               Where a.%@ = ?;"
               ,TABLE_GROUP,TABLE_MESSAGE,field];
        
        FMResultSet *rs = [db executeQuery:sql,value];
        if ([rs next]) {
            
            group = [[GroupDataModel alloc] init];
            group.groupId = [rs stringForColumnIndex:0];
            group.groupType = [rs intForColumnIndex:1];
            group.groupName = [rs stringForColumnIndex:2];
            group.unreadCount = [rs intForColumnIndex:3];
            
            //last message
            NSString *msgId = [rs stringForColumnIndex:4];
            if (msgId.length > 0) {
                
                RecordDataModel *record = [[RecordDataModel alloc] init];
                record.msgId = msgId;
                record.fromUserId = [rs stringForColumnIndex:5];
                record.sendTime = [rs stringForColumnIndex:6];
                record.msgType = [rs intForColumnIndex:7];
                record.msgLen = [rs intForColumnIndex:8];
                record.content = [rs stringForColumnIndex:9];
                record.status = [rs intForColumnIndex:10];
                record.msgDirection = [rs intForColumnIndex:11];
                record.msgRequestState =  [rs intForColumnIndex:12];
                record.nickname = [rs stringForColumnIndex:13];
                record.groupId = group.groupId;
                
                group.lastMsg = record;
                group.lastMsgId = record.msgId;
                group.lastMsgSendTime = record.sendTime;
                
            }
            
            group.updateTime = [rs stringForColumnIndex:14];
            group.status = [rs intForColumnIndex:15];
            group.fold = [rs intForColumnIndex:16];
            group.menu = [rs stringForColumnIndex:17];
            group.partnerType = [rs intForColumnIndex:18];
            
            //参与人信息
            [self queryParticipant:group db:db];
            
        }
        [rs close];
    }];
    
    return  group;
}


- (GroupDataModel *)queryPublicGroupWithPublicPersonId:(NSString *)personId
{
    __block GroupDataModel *group = nil;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        //        NSString * sql = [NSString stringWithFormat:@"SELECT\n\ta.groupId,\n\ta.groupType,\n\ta.groupName,\n\ta.unreadCount,\n\ta.lastMsgId,\n\tb.fromUserId,\n\ta.lastMsgSendTime,\n\tb.msgType,\n\tb.msgLen,\n\tb.content,\n\tb.status AS \'bStatus\',\n\tb.direction,\n\tb.requestType,\n\tb.fromUserNickName,\n\ta.updateTime,\n\ta.status AS \'aStatus\',\n\ta.fold,\n\ta.draft,\n\ta.headerUrl,\n\ta.param,\n\ta.participantIds,\n\tmCallStatus,\n\tmicDisable\nFROM\n\t%@ a\nLEFT JOIN %@ b ON a.lastMsgId = b.msgId\nWHERE\n\ta.participantIds LIKE ?\nLIMIT 1;", TABLE_GROUP, TABLE_MESSAGE];
        NSString * sql = [NSString stringWithFormat:@"SELECT\n\t*\nFROM\n\t%@\nWHERE\n\tparticipantIds LIKE ? and groupType = 3;",TABLE_GROUP];
        
        
        FMResultSet *rs = [db executeQuery:sql, [NSString stringWithFormat:@"%%%@%%",personId]];
        while ([rs next]) {
            group = [self loadGroupWithResultSet:rs];
            if([group isPublicGroup])
                break;
        }
        [rs close];
        
    }];
    
    return group;
}

- (NSArray *)queryPrivateTypeManyGroupList
{
    NSMutableArray *groups = [NSMutableArray array];
    NSMutableArray *groupIds = [NSMutableArray array];
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString * sql = [NSString stringWithFormat:@"SELECT\n\t*\nFROM\n\t%@\nWHERE\n\tgroupType = ?\nAND showInTimeline = 1\nAND (status & 1)\nORDER BY\n\tlastMsgSendTime DESC;", TABLE_GROUP];
        FMResultSet *rs = [db executeQuery:sql, [NSNumber numberWithInt:GroupTypeMany]];
        while ([rs next]) {
            GroupDataModel *group = [self loadGroupWithResultSet:rs];
            [groups addObject:group];
            [groupIds addObject:group.groupId];
        }
        [rs close];
    }];
    
    //参与人 personId 列表
    NSMutableDictionary *paticipants = [[NSMutableDictionary alloc] initWithDictionary:[self loadPaticipantIds:groupIds]];
    
    NSMutableSet *personIds = [[NSMutableSet alloc] init];
    for (id paticipant in [paticipants allValues]) {
        if ([paticipant isKindOfClass:[NSArray class]]) {
            if (([(NSArray *)paticipant count] > 0)) {
                [personIds addObjectsFromArray:paticipant];
            }
        }
    }
    NSDictionary *persons = [[NSDictionary alloc] initWithDictionary:[self loadPersons:[personIds allObjects]]];
    
    int count = 0;
    for (GroupDataModel *group in groups) {
        count += group.unreadCount;
        NSArray *paticipantIds = [paticipants objectForKey:group.groupId];
        if ([paticipantIds isKindOfClass:[NSArray class]] && [paticipantIds count] > 0) {
            for (NSString *paticipantId in paticipantIds) {
                PersonSimpleDataModel *person = [persons objectForKey:paticipantId];
                if (person != nil) {
                    [group.participant addObject:person];
                }
            }
        }
    }
    
    return groups;
    
}

- (NSArray *)queryPrivateGroupsWithLikeGroupName:(NSString *)groupName {
    __block NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString * sql = [NSString stringWithFormat:@"SELECT\n\tgroupId,\n\tgroupType,\n\tgroupName,\n\tunreadCount,\n\theaderUrl,\n\tpartnerType\nFROM\n\t%@\nWHERE\n\tshowInTimeline = 1\nAND (groupType = ? OR groupType = ?)\nAND groupName LIKE ?\nORDER BY\n\tlastMsgSendTime DESC;", TABLE_GROUP];
        
        FMResultSet *rs = [db executeQuery:sql, @(GroupTypeDouble), @(GroupTypeMany), [NSString stringWithFormat:@"%%%@%%", groupName]];
        while ([rs next]) {
            GroupDataModel *group = [[GroupDataModel alloc] init];
            group.groupId = [rs stringForColumnIndex:0];
            group.groupType = [rs intForColumnIndex:1];
            
            group.groupName = [rs stringForColumnIndex:2];
            NSRange range = [[group.groupName lowercaseString] rangeOfString:groupName.lowercaseString];
            if (range.location != NSNotFound) {
                group.highlightGroupName = [group.groupName stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"<font color=\"#06A3EC\">%@</font>", [group.groupName substringWithRange:range]]];
            }
            
            group.unreadCount = [rs intForColumnIndex:3];
            group.headerUrl = [rs stringForColumnIndex:4];
            group.partnerType = [rs intForColumnIndex:5];
            [groups addObject:group];
        }
        [rs close];
    }];
    
    return groups;
}

- (NSArray *)queryPrivateGroupsWithIds:(NSString *)ids isPersonId:(BOOL)isPersonId {
    __block NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSMutableArray * persons = [NSMutableArray array];
        NSString *sql = nil;
        if(isPersonId)
            sql = [NSString stringWithFormat:@"SELECT\n\tpersonId,\n\tpersonName\nFROM\n\t%@\nWHERE\n\tpersonId In %@;", TABLE_T9_PERSON, [NSString stringWithFormat:@"(%@)", ids]];
        else
            sql = [NSString stringWithFormat:@"SELECT\n\tpersonId,\n\tpersonName\nFROM\n\t%@\nWHERE\n\tid IN %@;", TABLE_T9_PERSON,[NSString stringWithFormat:@"(%@)", ids]];
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
            person.personId = [rs stringForColumnIndex:0];
            person.personName = [rs stringForColumnIndex:1];
            [persons addObject:person];
        }
        [rs close];
        
        [persons enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
            PersonSimpleDataModel *person = obj;
            
            NSString *str = ASLocalizedString(@"ContainMember");
            NSString *sql1 = [NSString stringWithFormat:@"SELECT\n\tgroupId,\n\tgroupType,\n\tgroupName,\n\tunreadCount,\n\theaderUrl,\n\tpartnerType,\n\tparticipantIds\nFROM\n\t%@\nWHERE\n\tgroupId in (select groupId from %@ where personId = ?)\nAND showInTimeline = 1\nORDER BY\n\tlastMsgSendTime DESC;", TABLE_GROUP,TABLE_PARTICIPANT];
            FMResultSet *rs1 = [db executeQuery:sql1, [NSString stringWithFormat:@"%@", person.personId]];
            while ([rs1 next]) {
                GroupDataModel *group = [[GroupDataModel alloc] init];
                
                group.groupId = [rs1 stringForColumnIndex:0];
                group.groupType = [rs1 intForColumnIndex:1];
                group.groupName = [rs1 stringForColumnIndex:2];
                group.unreadCount = [rs1 intForColumnIndex:3];
                group.headerUrl = [rs1 stringForColumnIndex:4];
                group.partnerType = [rs1 intForColumnIndex:5];
                NSString *participantIds = [rs1 stringForColumn:@"participantIds"];
                if (participantIds) {
                    NSArray *tempParticipantIds = [NSJSONSerialization JSONObjectWithData:[participantIds dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if (tempParticipantIds && [tempParticipantIds isKindOfClass:[NSArray class]]) {
                        group.participantIds = [NSMutableArray arrayWithArray:tempParticipantIds];
                    }
                }
                
                if ([groups containsObject:group]) {
                    GroupDataModel *tempGroup = [groups objectAtIndex:[groups indexOfObject:group]];
                    if (person.personName) {
                        if (tempGroup.highlightMessage) {
                            tempGroup.highlightMessage = [tempGroup.highlightMessage stringByAppendingFormat:@"、<font color=\"#06A3EC\">%@</font>", person.personName];
                        }
                        else {
                            
                            tempGroup.highlightMessage = [NSString stringWithFormat:@"%@ <font color=\"#06A3EC\">%@</font>",str,person.personName];
                        }
                    }
                }
                else {
                    if (person.personName) {
                        group.highlightMessage = [NSString stringWithFormat:@"%@<font color=\"#06A3EC\">%@</font>",str, person.personName];
                    }
                    [groups addObject:group];
                }
            }
            [rs1 close];
        }];
    }];
    
    return groups;
}


///33333333245235623456w456345
- (BOOL)insertUpdatePrivateGroupList:(GroupListDataModel *)groupList
{
    if (groupList == nil || [groupList.list count] == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    
    //    __weak __typeof(self) weakSelf = self;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        [groupList.list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            GroupDataModel *group = (GroupDataModel *)obj;
            RecordDataModel *record = group.lastMsg;
            
            //查询会话的更新时间
            NSString *sql = [NSString stringWithFormat:@"SELECT updateTime FROM %@ where groupId = ?;",TABLE_GROUP];
            
            FMResultSet *rs = [db executeQuery:sql,group.groupId];
            if ([rs next]) {
                group.updateTime = [rs stringForColumnIndex:0];
            }
            [rs close];
            
            
            //更新Group表
            
            // 查询草稿
            sql = [NSString stringWithFormat:@"SELECT draft FROM %@ WHERE groupId = ?;",TABLE_GROUP];
            FMResultSet *rs1 = [db executeQuery:sql, group.groupId];
            if ([rs1 next]) {
                group.draft = [rs1 stringForColumnIndex:0];
            }
            [rs1 close];
            
            NSString *insert = [NSString stringWithFormat:@"INSERT\nOR REPLACE INTO %@ (\n\tgroupId,\n\tgroupType,\n\tgroupName,\n\tunreadCount,\n\tlastMsgId,\n\tupdateTime,\n\tlastMsgSendTime,\n\tstatus,\n\tfold,\n\tdraft,\n\tshowInTimeline,\n\theaderUrl,\n\tparam,\n\tparticipantIds,\n\tmCallStatus,\n\tmicDisable,\n\tmanagerIds,\n\tpartnerType,\n\tlastMsgDesc,\n\ttodoStatus,\n\tupdateScore,\n\tlocalUpdateScore,\n\tuserCount\n)\nVALUES\n\t(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", TABLE_GROUP];
            NSString *param = nil;
            if (group.param) {
                param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:group.param options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
            }
            NSString *participantIds = nil;
            //第一次拉grouplist有这个字段
            if (group.participantIds) {
                participantIds = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:group.participantIds options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
            }
            NSString *managerIds = nil;
            if (group.managerIds) {
                managerIds = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:group.managerIds options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
            }
            [db executeUpdate:insert, group.groupId, @(group.groupType), group.groupName, @(group.unreadCount), group.lastMsgId, group.updateTime, group.lastMsgSendTime, @(group.status), @(group.fold), group.draft, @(1), group.headerUrl, param,participantIds,@(group.mCallStatus),@(group.micDisable),managerIds,@(group.partnerType),group.lastMsgDesc,record.todoStatus,[NSString stringWithFormat:@"%ld",group.updateScore],[NSString stringWithFormat:@"%ld",group.localUpdateScore],[NSString stringWithFormat:@"%ld",group.userCount]];
            
            
            //去掉by lee
            //            //更新Record表
            //            if (group.lastMsg.msgId.length > 0) {
            //                [group.lastMsg setGroupId:group.groupId];
            //                if (group.lastMsg.msgType == MessageTypeSystem ||
            //                    group.lastMsg.msgType == MessageTypeCall ||
            //                    group.lastMsg.msgType == MessageTypeText) {
            //                    [group.lastMsg setStatus:MessageStatusRead];
            //                }
            //                [group.lastMsg setMsgRequestState:MessageRequestStateSuccess];
            //                [self insertRecord:group.lastMsg toUserId:@"" needUpdateGroup:YES publicId:nil db:db];
            //            }
            if (group.participantIds.count > 0) {
                [group.participantIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString *personId = (NSString *)obj;
                    PersonSimpleDataModel *person  = [self loadPersonWithPersonId:personId db:db];
                    [self insertPersonSimple:person lastContactTime:group.groupType == GroupTypeDouble ? group.lastMsgSendTime : nil db:db];
                    if ([person isPublicAccount])
                    {
                        person.manager = (group.manager == 1);
                        //                        PersonSimpleDataModel *pubPerson = [self queryPublicAccountWithId:person.personId];
                        //                        person.remind = pubPerson.remind;
                        //                        person.state = pubPerson.state;
                        //                        person.reply = pubPerson.reply;
                        //                        person.share = pubPerson.share;
                        //                        person.hisNews = pubPerson.hisNews;
                        [self insertPublicPersonSimple2:person db:(FMDatabase *)db];
                        if ([person.personId isEqualToString:@"XT-10000"]) {
                            [self insertPersonSimple:person lastContactTime:group.lastMsgSendTime db:db];
                        }
                    }
                }];
            }
            //更新参与人关系表 第一次安装拉的时候更新的
            [self updateParticipantWithGroupId:group.groupId personIDs:group.participantIds db:db];
            
        }];
        
        result = !db.hadError;
    }];
    
    return result;
}


- (BOOL)updatePrivateGroupListWithUpdateTime:(NSString *)updateTime withGroupId:(NSString *)groupId
{
    return [self updateGroupListWithUpdateTime:updateTime withGroupId:groupId withPublicId:nil];
}

- (BOOL)updatePrivateGroupListWithStatus:(int)status withGroupId:(NSString *)groupId
{
    if (groupId.length == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *update = [NSString stringWithFormat:@"UPDATE %@ SET status = ? Where groupId = ?;",TABLE_GROUP];
        result = [db executeUpdate:update,[NSNumber numberWithInt:status],groupId];
        
    }];
    
    return result;
}

- (BOOL)setPrivateGroupListToDeleteWithGroupId:(NSString *)groupId
{
    return [self deleteGroupAndRecordsWithGroupId:groupId publicId:nil realDel:NO];
}

- (NSString *)queryLastContentExcludeEventMessageWithGroupId:(NSString *)groupId
{
    __block NSString *content = nil;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT content FROM %@ \nWHERE groupId = ? AND msgType != ?\nORDER BY sendTime DESC\nLIMIT 1;",TABLE_MESSAGE];
        
        FMResultSet *rs = [db executeQuery:sql,groupId,[NSNumber numberWithInt:MessageTypeEvent]];
        if ([rs next]) {
            content = [rs stringForColumnIndex:0];
        }
        [rs close];
        
    }];
    
    return content;
}

- (NSString *)queryDraftWithGroupId:(NSString *)groupId
{
    __block NSString *strResult = nil;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = [NSString stringWithFormat:@"SELECT draft FROM %@ \nWHERE groupId = ?;",TABLE_GROUP];
        FMResultSet *rs = [db executeQuery:sql,groupId];
        if ([rs next])  {
            strResult = [rs stringForColumnIndex:0];
        }
        [rs close];
    }];
    
    return strResult;
}

- (BOOL)updateDraft:(NSString *)strDraft withGroupId:(NSString *)groupId
{
    if (groupId.length == 0) {
        return NO;
    }
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"UPDATE %@ SET draft = ? Where groupId = ?;",TABLE_GROUP];
        result = [db executeUpdate:update,strDraft,groupId];
    }];
    return result;
}

- (BOOL)removeDraftWithGroupId:(NSString *)groupId
{
    return [self updateDraft:nil withGroupId:groupId];
}


- (BOOL)updateNotifyType:(int)iNotifyType notifyDesc:(NSString *)strNotifyDesc withGroupId:(NSString *)groupId
{
    if (groupId.length == 0) {
        return NO;
    }
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"UPDATE %@ SET notifyType = ?, notifyDesc = ? Where groupId = ?;",TABLE_GROUP];
        result = [db executeUpdate:update,[NSNumber numberWithInt:iNotifyType],strNotifyDesc,groupId];
    }];
    return result;
}


- (void)updateNotifyToEmptyWithGroupId:(NSString *)groupId
{
    // 检测是否还有未读的@信息, 如果没有未读了, 则把privategroup的相应字段置为空
    if ([[self queryNotifyRecordsWithGroupId:groupId] count] == 0)
    {
        [self updateNotifyType:0 notifyDesc:@"" withGroupId:groupId];
    }
}

#pragma mark - public group

- (NSArray *)queryPublicGroupListWithPublicId:(NSString *)publicId
{
    NSMutableArray *groups = [NSMutableArray array];
    if (publicId == nil) {
        return groups;
    }
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        
        //查询所有的会话记录，包括它的最后一条消息
        //        NSString * sql = @"SELECT groupId,groupType,groupName,unreadCount,lastMsgId,\nb.fromUserId,a.lastMsgSendTime,b.msgType,b.msgLen,b.content,\nb.status as \'bStatus\',b.direction,b.requestType,b.fromUserNickName,\na.updateTime,a.status as \'aStatus\',\na.personId,a.personName,a.defaultPhone,a.department, \na.photoUrl,a.personStatus,a.jobTitle,a.wbUserId";
        NSString * sql = @"SELECT \n\tgroupId,\n\tgroupType,\n\tgroupName,\n\tunreadCount,\n\tlastMsgId,\n\tlastMsgSendTime,\n\tupdateTime,\n\tstatus,\n\tpersonId,\n\tpersonName,\n\tdefaultPhone,\n\tdepartment, \n\tphotoUrl,\n\tpersonStatus,\n\tjobTitle,\n\twbUserId,\n\tlastMsgDesc\n";
        sql = [sql stringByAppendingFormat:@" FROM %@ ", TABLE_PUBLIC_GROUP];
        sql = [sql stringByAppendingFormat:@" Where publicId = '%@'", publicId];
        sql = [sql stringByAppendingString:@"Order by lastMsgSendTime Desc limit 1000;"];
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            GroupDataModel *group = [[GroupDataModel alloc] init];
            
            group.groupId = [rs stringForColumnIndex:0];
            group.groupType = [rs intForColumnIndex:1];
            group.groupName = [rs stringForColumnIndex:2];
            group.unreadCount = [rs intForColumnIndex:3];
            group.lastMsgId = [rs stringForColumn:@"lastMsgId"];
            group.lastMsgSendTime = [rs stringForColumn:@"lastMsgSendTime"];
            //last message
            //            NSString *msgId = [rs stringForColumnIndex:4];
            //            if (msgId.length > 0) {
            //                RecordDataModel *record = [[RecordDataModel alloc] init];
            //                record.msgId = msgId;
            //                record.fromUserId = [rs stringForColumnIndex:5];
            //                record.sendTime = [rs stringForColumnIndex:6];
            //                record.msgType = [rs intForColumnIndex:7];
            //                record.msgLen = [rs intForColumnIndex:8];
            //                record.content = [rs stringForColumnIndex:9];
            //                record.status = [rs intForColumnIndex:10];
            //                record.msgDirection = [rs intForColumnIndex:11];
            //                record.msgRequestState =  [rs intForColumnIndex:12];
            //                record.nickname = [rs stringForColumnIndex:13];
            //                record.groupId = group.groupId;
            //
            //                group.lastMsg = record;
            //                group.lastMsgId = record.msgId;
            //                group.lastMsgSendTime = record.sendTime;
            //            }
            
            group.updateTime = [rs stringForColumn:@"updateTime"];
            group.status = [rs intForColumn:@"status"];
            group.lastMsgDesc = [rs stringForColumn:@"lastMsgDesc"];
            
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
            person.personId = [rs stringForColumn:@"personId"];
            person.personName = [rs stringForColumn:@"personName"];
            person.defaultPhone = [rs stringForColumn:@"defaultPhone"];
            person.department = [rs stringForColumn:@"department"];
            person.photoUrl = [rs stringForColumn:@"photoUrl"];
            person.status = [rs intForColumn:@"status"];
            person.jobTitle = [rs stringForColumn:@"jobTitle"];
            person.wbUserId = [rs stringForColumn:@"wbUserId"];
            group.participant = [NSMutableArray arrayWithObject:person];
            
            [groups addObject:group];
        }
        [rs close];
    }];
    
    return groups;
}

- (BOOL)insertUpdatePublicGroupList:(GroupListDataModel *)groupList withPublicId:(NSString *)publicId
{
    if (publicId == nil) {
        return NO;
    }
    if (groupList == nil || [groupList.list count] == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        [groupList.list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            GroupDataModel *group = (GroupDataModel *)obj;
            
            //查询会话的更新时间
            NSString *sql = [NSString stringWithFormat:@"SELECT updateTime FROM %@ where groupId = ?;",TABLE_PUBLIC_GROUP];
            
            FMResultSet *rs = [db executeQuery:sql,group.groupId];
            if ([rs next]) {
                group.updateTime = [rs stringForColumnIndex:0];
            }
            [rs close];
            
            //更新PublicGroup表
            PersonSimpleDataModel *person = nil;
            if ([group.participant count] > 0) {
                person = [group.participant firstObject];
            }
            NSString *insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (groupId,groupType,groupName,unreadCount,lastMsgId,publicId,updateTime,lastMsgSendTime,status,personId,personName,defaultPhone,department,photoUrl,personStatus,jobTitle,wbUserId,lastMsgDesc) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",TABLE_PUBLIC_GROUP];
            [db executeUpdate:insert,group.groupId,[NSNumber numberWithInt:group.groupType],group.groupName,[NSNumber numberWithInt:group.unreadCount],group.lastMsgId,publicId,group.updateTime,group.lastMsgSendTime,[NSNumber numberWithInt:person.status],person.personId,person.personName,person.defaultPhone,person.department,person.photoUrl,[NSNumber numberWithInt:person.status],person.jobTitle,person.wbUserId,group.lastMsgDesc];
            
            //            //更新Record表
            //            if (![@"" isEqualToString:group.lastMsg.msgId]) {
            //                [group.lastMsg setGroupId:group.groupId];
            //                if (group.lastMsg.msgType == MessageTypeSystem ||
            //                    group.lastMsg.msgType == MessageTypeCall ||
            //                    group.lastMsg.msgType == MessageTypeText) {
            //                    [group.lastMsg setStatus:MessageStatusRead];
            //                }
            //                [group.lastMsg setMsgRequestState:MessageRequestStateSuccess];
            //                [self insertRecord:group.lastMsg toUserId:@"" needUpdateGroup:YES publicId:publicId db:db];
            //            }
            
        }];
        
        //将公共帐号的成员也存入到PersonSimple表中(团队除外)
        if (![publicId isEqualToString:@"XT-10000"]) {
            [groupList.publicMember enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self insertPersonSimple:obj lastContactTime:nil db:db];
            }];
        }
        
        result = !db.hadError;
    }];
    
    return result;
}

- (BOOL)updatePublicGroupListWithUpdateTime:(NSString *)updateTime withGroupId:(NSString *)groupId withPublicId:(NSString *)publicId
{
    if (publicId == nil) {
        publicId = @"";
    }
    return [self updateGroupListWithUpdateTime:updateTime withGroupId:groupId withPublicId:publicId];
}

- (BOOL)setPublicGroupListToDeleteWithGroupId:(NSString *)groupId withPublicId:(NSString *)publicId
{
    return [self deleteGroupAndRecordsWithGroupId:groupId publicId:publicId realDel:YES];
}

#pragma mark - group

- (NSDictionary *)loadPersons:(NSArray *)personIds
{
    NSMutableDictionary *persons = [NSMutableDictionary dictionary];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin, \
                         photoUrl,status,department,jobTitle,wbUserId,isAdmin \
                         ,subscribe,canUnsubscribe,note,reply,menu,share,partnerType,oid,gender from %@ Where personId in ('%@');",TABLE_T9_PERSON,[personIds componentsJoinedByString:@"','"]];
        
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
            
            person.userId = [rs intForColumnIndex:0];
            person.personId = [rs stringForColumnIndex:1];
            person.personName = [rs stringForColumnIndex:2];
            person.defaultPhone = [rs stringForColumnIndex:3];
            person.fullPinyin = [rs stringForColumnIndex:4];
            person.photoUrl = [rs stringForColumnIndex:5];
            person.status = [rs intForColumnIndex:6];
            person.department = [rs stringForColumnIndex:7];
            person.jobTitle = [rs stringForColumnIndex:8];
            person.wbUserId = [rs stringForColumnIndex:9];
            person.isAdmin = ([rs intForColumnIndex:10] == 1);
            person.subscribe = [rs stringForColumnIndex:11];
            person.canUnsubscribe = [rs stringForColumnIndex:12];
            person.note = [rs stringForColumnIndex:13];
            person.reply = [rs stringForColumnIndex:14];
            person.menu = [rs stringForColumnIndex:15];
            person.share = [rs intForColumnIndex:16];
            person.partnerType = [rs intForColumnIndex:17];
            person.oid = [rs stringForColumn:@"oid"];
            person.gender = [rs intForColumn:@"gender"];
            
            [persons setObject:person forKey:person.personId];
            
        }
        [rs close];
    }];
    
    return persons;
}

- (NSMutableDictionary *)loadPaticipantIds:(NSArray *)groupIds
{
    NSMutableDictionary *paticipants = [NSMutableDictionary dictionary];
    for (NSString *groupId in groupIds) {
        [paticipants setObject:[NSNull null] forKey:groupId];
    }
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"select personId,groupId from %@ Where groupId in ('%@');",TABLE_PARTICIPANT,[groupIds componentsJoinedByString:@"','"]];
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *groupId = [rs stringForColumnIndex:1];
            
            id personIds = [paticipants objectForKey:groupId];
            if ([personIds isKindOfClass:[NSNull class]]) {
                personIds = [NSMutableArray array];
                [paticipants setObject:personIds forKey:groupId];
            }
            [personIds addObject:[rs stringForColumnIndex:0]];
        }
        [rs close];
    }];
    return paticipants;
}

/**
 * 如果该personid不存在，才写入，否则不做更新，以原有信息为准
 */
- (BOOL)insertPublicPersonSimple2:(PersonSimpleDataModel *)person db:(FMDatabase *)db
{
    BOOL result = YES;
    //先判断该personid是否存在
    NSString * sql = [NSString stringWithFormat:@"select personid from %@ where personid = '%@';",TABLE_PUBLIC_PERSON,person.personId];
    FMResultSet *rs = [db executeQuery:sql];
    BOOL hasPerson = NO;
    if ([rs next]) {
        hasPerson = YES;
    }
    [rs close];
    
    if(!hasPerson)
    {
        sql = [NSString stringWithFormat:@"INSERT INTO %@ (personId,personName,defaultPhone,department,fullPinyin,photoUrl,status,jobTitle,note,reply,subscribe,canUnsubscribe,menu,manager,share,fold,hisNews) VALUES ('%@','%@','%@','%@','%@','%@',%d,'%@','%@','%@','%@','%@','%@',%d,%d,%d,%d);",TABLE_PUBLIC_PERSON,person.personId,person.personName,person.defaultPhone,person.department,person.fullPinyin,person.photoUrl,person.status,person.jobTitle,person.note,person.reply,person.subscribe,person.canUnsubscribe,person.menu,
               (person.manager?1:0),(person.share),(person.fold?1:0),(person.hisNews?1:0)];
        result = [db executeUpdate:sql];
    }
    else {
        sql = [NSString stringWithFormat:@"UPDATE %@ SET manager = %d WHERE personId = '%@';",TABLE_PUBLIC_PERSON,(person.manager?1:0),person.personId];
        result = [db executeUpdate:sql];
    }
    return result;
}

//使用publicId来区分更新哪张表，如果publicId=nil，则更新Group表，否则更新PublicGroup表
- (BOOL)updateGroupListWithUpdateTime:(NSString *)updateTime withGroupId:(NSString *)groupId withPublicId:(NSString *)publicId
{
    if (groupId.length == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *update = nil;
        if (publicId == nil) {
            //更新Group表
            update = [NSString stringWithFormat:@"UPDATE %@ SET updateTime = ? Where groupId = ?;",TABLE_GROUP];
            result = [db executeUpdate:update,updateTime.length==0?@"":updateTime,groupId];
        }else{
            //更新PublicGroup表
            update = [NSString stringWithFormat:@"UPDATE %@ SET updateTime = ? Where groupId = ? And publicId = ?;",TABLE_PUBLIC_GROUP];
            result = [db executeUpdate:update,updateTime.length==0?@"":updateTime,groupId,publicId];
        }
        
    }];
    
    return result;
}

//使用publicId来区分更新哪张表，如果publicId=nil，则更新Group表，否则更新PublicGroup表
- (BOOL)deleteGroupAndRecordsWithGroupId:(NSString *)groupId publicId:(NSString *)publicId realDel:(BOOL)realDel
{
    BOOL result = [self deleteGroupWithGroupId:groupId publicId:publicId realDel:realDel];
    if (realDel) {
        result = result && [self deleteRecordsWithGroupId:groupId];
    }
    return result;
}

- (BOOL)deleteGroupWithGroupId:(NSString *)groupId publicId:(NSString *)publicId realDel:(BOOL)realDel
{
    if (groupId.length == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *delete = nil;
        if (!realDel) {
            //我的组列表，在timeline列表上删除时标志为Timeline不可见（并非真删除）
            delete = [NSString stringWithFormat:
                      @"UPDATE %@ SET showInTimeline = 0 Where groupId = ?;"
                      ,TABLE_GROUP];
            result = [db executeUpdate:delete,groupId];
        }
        else {
            //意见反馈是真删除
            //退出多人会话时是真删除
            delete = [NSString stringWithFormat:
                      @"DELETE FROM %@ WHERE groupId = ?; \
                      DELETE FROM %@ WHERE groupId = ?;"
                      ,publicId == nil ? TABLE_GROUP : TABLE_PUBLIC_GROUP,TABLE_PARTICIPANT];
            result = [db executeUpdate:delete,groupId,groupId];
        }
        
    }];
    
    return result;
}

- (BOOL)updateGroupListWithGroup:(GroupDataModel *)group withPublicId:(NSString *)publicId
{
    if (group.groupId.length == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        //更新Group或者PublicGroup表的unreadCount
        result = [self updateGroupListWithUnreadCount:0 withGroupId:group.groupId withPublicId:publicId db:db];
    }];
    
    return result;
}

//使用publicId来区分更新哪张表，如果publicId=nil，则更新Group表，否则更新PublicGroup表
- (BOOL)updateGroupListWithUnreadCount:(int)unreadCount withGroupId:(NSString *)groupId withPublicId:(NSString *)publicId db:(FMDatabase *)db
{
    NSString *update = nil;
    if (publicId == nil) {
        //更新Group表
        update = [NSString stringWithFormat:@"UPDATE %@ SET unreadCount = ? Where groupId = ?;",TABLE_GROUP];
        return [db executeUpdate:update,[NSNumber numberWithInt:unreadCount],groupId];
    }else{
        //更新PublicGroup表
        update = [NSString stringWithFormat:@"UPDATE %@ SET unreadCount = ? Where groupId = ? And publicId = ?;",TABLE_PUBLIC_GROUP];
        return [db executeUpdate:update,[NSNumber numberWithInt:unreadCount],groupId,publicId];
    }
}

#pragma mark - Person

- (void)queryParticipant:(GroupDataModel *)group db:(FMDatabase *)db
{
    NSString *sql = [NSString stringWithFormat:@"SELECT a.id,a.personId,a.personName,a.defaultPhone,a.fullPinyin,a.photoUrl,a.status,a.department,a.jobTitle,a.wbUserId,a.isAdmin,a.subscribe,a.canUnsubscribe,a.note,a.reply,a.menu,a.share,a.partnerType,a.oid,a.gender FROM %@ a left join %@ b on b.personId = a.personId where b.groupId = ?;",TABLE_T9_PERSON,TABLE_PARTICIPANT];
    
    FMResultSet *rs = [db executeQuery:sql,group.groupId];
    while ([rs next]) {
        
        PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
        
        person.userId = [rs intForColumnIndex:0];
        person.personId = [rs stringForColumnIndex:1];
        person.personName = [rs stringForColumnIndex:2];
        person.defaultPhone = [rs stringForColumnIndex:3];
        person.fullPinyin = [rs stringForColumnIndex:4];
        person.photoUrl = [rs stringForColumnIndex:5];
        person.status = [rs intForColumnIndex:6];
        person.department = [rs stringForColumnIndex:7];
        person.jobTitle = [rs stringForColumnIndex:8];
        person.wbUserId = [rs stringForColumnIndex:9];
        person.isAdmin = ([rs intForColumnIndex:10] == 1);
        person.subscribe = [rs stringForColumnIndex:11];
        person.canUnsubscribe = [rs stringForColumnIndex:12];
        person.note = [rs stringForColumnIndex:13];
        person.reply = [rs stringForColumnIndex:14];
        person.menu = [rs stringForColumnIndex:15];
        person.share = [rs intForColumnIndex:16];
        person.partnerType = [rs intForColumnIndex:17];
        
        person.oid = [rs stringForColumn:@"oid"];
        person.gender = [rs intForColumn:@"gender"];
        
        [group.participant addObject:person];
        
    }
    [rs close];
}

- (BOOL)updateParticipantWithGroupId:(NSString *)groupId personIDs:(NSArray *)persons db:(FMDatabase *)db
{
    __block BOOL result = NO;
    
    //将旧的全部删除
    NSString *delete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE groupId = ?;",TABLE_PARTICIPANT];
    result = [db executeUpdate:delete,groupId];
    
    //插入新的记录
    [persons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        //        PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
        NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ (groupId,personId) VALUES (?,?);",TABLE_PARTICIPANT];
        //        result = result && [db executeUpdate:insert,groupId,person.personId];
        result = result && [db executeUpdate:insert,groupId,(NSString *)obj];
    }];
    
    return result;
}

- (int)initializeWithDataFilePath:(NSString *)filePath updateTime:(NSString *__autoreleasing *)updateTime
{
    if (filePath.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return 0;
    }
    
    __block NSString *tempUpdateTime = nil;
    __block int count = 0;
    NSString *myPersonId = [BOSConfig sharedConfig].currentUser.personId;
    __block BOOL includeme = NO;
    
    FILE *fp;
    if ((fp = fopen([filePath UTF8String], "r")) == NULL) {
        BOSERROR(@"Fail to read t9 data.");
    }
    else {
        
        [self.databaseQueue inTransaction: ^(FMDatabase *db, BOOL *rollback) {
            
#if DEBUG
            db.logsErrors = YES;
#endif
            
            int length = 1024;
            char buf[length];      /*缓冲区*/
            int len;             /*行字符个数*/
            NSMutableString *line = [NSMutableString string];
            //逐行读取
            while (fgets(buf, length, fp) != NULL) {
                
                len = (int)strlen(buf);
                
                if (len == length - 1 && buf[len - 1] != '\n') {
                    NSString *bufString = [NSString stringWithUTF8String:buf];
                    if (bufString.length > 0) {
                        [line appendString:bufString];
                    }
                    continue;
                }
                else {
                    NSString *bufString = [NSString stringWithUTF8String:buf];
                    if (bufString.length > 0) {
                        [line appendString:bufString];
                    }
                }
                
                id obj = [NSJSONSerialization JSONObjectWithData:[line dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if (!obj || ![obj isKindOfClass:[NSDictionary class]]) {
                    BOSERROR(@"Json parser t9 data error. line = %@", line);
                    [line setString:@""];
                    continue;
                }
                
                NSString *personId = [obj objectForKey:@"id"];
                if (personId.length > 0) {
                    PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:obj];
                    person.fullPinyin = [[person.fullPinyin stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]uppercaseString];
                    //新增或更新
                    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (personId,personName,defaultPhone,department,fullPinyin,photoUrl,status,jobTitle,wbUserId,isAdmin,partnerType,oid,orgId,gender) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?);", TABLE_T9_PERSON];
                    [db executeUpdate:sql, person.personId, person.personName, person.defaultPhone, person.department, person.fullPinyin, person.photoUrl, [NSNumber numberWithInt:person.status], person.jobTitle, person.wbUserId,@(person.isAdmin?1:0),@(person.partnerType),person.oid,person.orgId,@(person.gender)];
                    
                    
                    //新增或更新
                    NSString *sql1 = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (personId,orgId,eName,jobType,jobTitle,department) VALUES (?,?,?,?,?,?);", TABLE_JOB];
                    for (ParttimejobDataModel *parttimeJob in person.parttimejob) {
                        [db executeUpdate:sql1, person.personId, parttimeJob.orgId, parttimeJob.eName, @(parttimeJob.jobType?1:0), parttimeJob.jobTitle, parttimeJob.department];
                    }
                    
                    //是否包含自己
                    if (!includeme && [personId isEqualToString:myPersonId]) {
                        includeme = YES;
                    }
                }
                else {
                    id value = [obj objectForKey:@"count"];
                    if (![value isKindOfClass:[NSNull class]] && value) {
                        count = [value intValue];
                    }
                    else {
                        value = [obj objectForKey:@"updateTime"];
                        if (![value isKindOfClass:[NSNull class]] && value != nil) {
                            tempUpdateTime = value;
                        }
                    }
                }
                
                [line setString:@""];
            }
        }];
        
        //关闭文件
        fclose(fp);
    }
    
    if (includeme) {
        [BOSConfig sharedConfig].currentUser = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:myPersonId];
    }
    
    if (updateTime && tempUpdateTime) {
        *updateTime = tempUpdateTime;
    }
    return count;
}

- (PersonSimpleDataModel *)queryPersonWithPersonId:(NSString *)personId
{
    __block PersonSimpleDataModel *person = nil;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin,photoUrl,status,department,jobTitle,wbUserId,isAdmin \
                         ,subscribe,canUnsubscribe,note,reply,menu,share,partnerType,oid,orgId,gender \
                         FROM %@ Where personId = ?;",TABLE_T9_PERSON];
        
        FMResultSet *rs = [db executeQuery:sql,personId];
        if ([rs next]) {
            
            person = [[PersonSimpleDataModel alloc] init];
            
            [person setUserId:[rs intForColumnIndex:0]];
            [person setPersonId:[rs stringForColumnIndex:1]];
            [person setPersonName:[rs stringForColumnIndex:2]];
            [person setDefaultPhone:[rs stringForColumnIndex:3]];
            [person setFullPinyin:[rs stringForColumnIndex:4]];
            [person setPhotoUrl:[rs stringForColumnIndex:5]];
            [person setStatus:[rs intForColumnIndex:6]];
            [person setDepartment:[rs stringForColumnIndex:7]];
            [person setJobTitle:[rs stringForColumnIndex:8]];
            [person setWbUserId:[rs stringForColumnIndex:9]];
            [person setIsAdmin:([rs intForColumnIndex:10] == 1)];
            person.subscribe = [rs stringForColumnIndex:11];
            person.canUnsubscribe = [rs stringForColumnIndex:12];
            person.note = [rs stringForColumnIndex:13];
            person.reply = [rs stringForColumnIndex:14];
            person.menu = [rs stringForColumnIndex:15];
            person.share = [rs intForColumnIndex:16];
            person.partnerType = [rs intForColumnIndex:17];
            
            person.oid = [rs stringForColumn:@"oid"];
            person.orgId = [rs stringForColumn:@"orgId"];
            person.gender = [rs intForColumn:@"gender"];
        }
        [rs close];
        
        
        
        //        if (personId != nil) {
        //            NSString *jobSqlStatement = [NSString stringWithFormat:@"SELECT orgId,eName,jobType,jobTitle,department from %@ where personId = ?;",TABLE_JOB];
        //            FMResultSet *rs2 = [db executeQuery:jobSqlStatement,personId];
        //            if ([rs2 next]) {
        //
        //                ParttimejobDataModel *job = [[ParttimejobDataModel alloc] init];
        //
        //                [job setOrgId:[rs2 stringForColumnIndex:0]];
        //                [job setEName:[rs2 stringForColumnIndex:1]];
        //                [job setJobType:[rs2 stringForColumnIndex:2]];
        //                [job setJobTitle:[rs2 stringForColumnIndex:3]];
        //                [job setDepartment:[rs2 stringForColumnIndex:4]];
        //
        //                [person.parttimejob addObject:job];
        //            }
        //            [rs2 close];
        //        }
        //
        
    }];
    
    return person;
}

- (PersonSimpleDataModel *)queryPersonDetailWithWebPersonId:(NSString *)webUserId{
    __block PersonSimpleDataModel *person = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin,photoUrl,status,department,jobTitle,wbUserId,isAdmin \
                         ,subscribe,canUnsubscribe,note,reply,menu,share,partnerType,oid,orgId,gender \
                         FROM %@ Where wbUserId = ?;",TABLE_T9_PERSON];
        
        FMResultSet *rs = [db executeQuery:sql,webUserId];
        if ([rs next]) {
            
            person = [[PersonSimpleDataModel alloc] init];
            
            [person setUserId:[rs intForColumnIndex:0]];
            [person setPersonId:[rs stringForColumnIndex:1]];
            [person setPersonName:[rs stringForColumnIndex:2]];
            [person setDefaultPhone:[rs stringForColumnIndex:3]];
            [person setFullPinyin:[rs stringForColumnIndex:4]];
            [person setPhotoUrl:[rs stringForColumnIndex:5]];
            [person setStatus:[rs intForColumnIndex:6]];
            [person setDepartment:[rs stringForColumnIndex:7]];
            [person setJobTitle:[rs stringForColumnIndex:8]];
            [person setWbUserId:[rs stringForColumnIndex:9]];
            [person setIsAdmin:([rs intForColumnIndex:10] == 1)];
            person.subscribe = [rs stringForColumnIndex:11];
            person.canUnsubscribe = [rs stringForColumnIndex:12];
            person.note = [rs stringForColumnIndex:13];
            person.reply = [rs stringForColumnIndex:14];
            person.menu = [rs stringForColumnIndex:15];
            person.share = [rs intForColumnIndex:16];
            person.partnerType = [rs intForColumnIndex:17];
            
            person.oid = [rs stringForColumn:@"oid"];
            
            person.orgId = [rs stringForColumn:@"orgId"];
            person.gender = [rs intForColumn:@"gender"];
        }
        [rs close];
    }];
    
    return person;
}

- (NSArray *)queryPersonWithWbPersonIds:(NSArray *)wbPersonIds {
    NSMutableArray *persons = [NSMutableArray array];
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSMutableArray * personIdsWithSingleQuotes = [NSMutableArray array];
        for (NSString *pid in wbPersonIds) {
            [personIdsWithSingleQuotes addObject:[NSString stringWithFormat:@"%@%@%@", [pid hasPrefix:@"'"] ? @"" : @"'", pid, [pid hasSuffix:@"'"] ? @"" : @"'"]];
        }
        
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ Where (status & 1) and  wbUserId IN (%@);", TABLE_T9_PERSON, [personIdsWithSingleQuotes componentsJoinedByString:@","]];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]) {
            PersonSimpleDataModel *person = [self loadPersonWithResultSet:rs];
            [persons addObject:person];
        }
        
        [rs close];
    }];
    
    return persons;
}


- (NSArray *)queryValidPersonWithPersonIds:(NSArray *)personIds
{
    NSMutableArray *persons = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db){
#if DEBUG
        db.logsErrors = YES;
#endif
        NSMutableArray *personIdsWithSingleQuotes = [NSMutableArray array];
        for(NSString *pid in personIds) {
            [personIdsWithSingleQuotes addObject:[NSString stringWithFormat:@"%@%@%@", [pid hasPrefix:@"'"] ? @"" : @"'", pid, [pid hasSuffix:@"'"] ? @"" : @"'"]];
        }
        
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin,photoUrl,status,department,jobTitle,wbUserId,isAdmin \
                         ,subscribe,canUnsubscribe,note,reply,menu,share,partnerType,oid,gender \
                         FROM %@ Where personId IN (%@);", TABLE_T9_PERSON, [personIdsWithSingleQuotes componentsJoinedByString:@","]];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]) {
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
            
            [person setUserId:[rs intForColumnIndex:0]];
            [person setPersonId:[rs stringForColumnIndex:1]];
            [person setPersonName:[rs stringForColumnIndex:2]];
            [person setDefaultPhone:[rs stringForColumnIndex:3]];
            [person setFullPinyin:[rs stringForColumnIndex:4]];
            [person setPhotoUrl:[rs stringForColumnIndex:5]];
            [person setStatus:[rs intForColumnIndex:6]];
            [person setDepartment:[rs stringForColumnIndex:7]];
            [person setJobTitle:[rs stringForColumnIndex:8]];
            [person setWbUserId:[rs stringForColumnIndex:9]];
            [person setIsAdmin:([rs intForColumnIndex:10] == 1)];
            person.subscribe = [rs stringForColumnIndex:11];
            person.canUnsubscribe = [rs stringForColumnIndex:12];
            person.note = [rs stringForColumnIndex:13];
            person.reply = [rs stringForColumnIndex:14];
            person.menu = [rs stringForColumnIndex:15];
            person.share = [rs intForColumnIndex:16];
            person.partnerType = [rs intForColumnIndex:17];
            
            person.oid = [rs stringForColumn:@"oid"];
            person.gender = [rs intForColumn:@"gender"];
            
            
            if ([person accountAvailable]) {
                [persons addObject:person];
            }
        }
        
        [rs close];
    }];
    
    return persons;
}

- (NSArray *)queryPersonWithPersonIds:(NSArray *)personIds
{
    NSMutableArray *persons = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db){
#if DEBUG
        db.logsErrors = YES;
#endif
        NSMutableArray *personIdsWithSingleQuotes = [NSMutableArray array];
        for(NSString *pid in personIds) {
            [personIdsWithSingleQuotes addObject:[NSString stringWithFormat:@"%@%@%@", [pid hasPrefix:@"'"] ? @"" : @"'", pid, [pid hasSuffix:@"'"] ? @"" : @"'"]];
        }
        
        
        //        NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin,photoUrl,status,department,jobTitle,wbUserId,isAdmin,subscribe,canUnsubscribe,note,reply,menu,share FROM %@ Where personId IN (%@);", TABLE_T9_PERSON, [personIdsWithSingleQuotes componentsJoinedByString:@","]];
        //
        FMResultSet *rs ;
        //        for (int i = 0; i< [personIds count]; i++) {
        NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin,photoUrl,status,department,jobTitle,wbUserId,isAdmin,subscribe,canUnsubscribe,note,reply,menu,share,partnerType,oid,gender FROM %@ Where personId IN (%@);", TABLE_T9_PERSON, [personIdsWithSingleQuotes componentsJoinedByString:@","]];
        
        
        rs = [db executeQuery:sql];
        while ([rs next]) {
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
            
            [person setUserId:[rs intForColumnIndex:0]];
            [person setPersonId:[rs stringForColumnIndex:1]];
            [person setPersonName:[rs stringForColumnIndex:2]];
            [person setDefaultPhone:[rs stringForColumnIndex:3]];
            [person setFullPinyin:[rs stringForColumnIndex:4]];
            [person setPhotoUrl:[rs stringForColumnIndex:5]];
            [person setStatus:[rs intForColumnIndex:6]];
            [person setDepartment:[rs stringForColumnIndex:7]];
            [person setJobTitle:[rs stringForColumnIndex:8]];
            [person setWbUserId:[rs stringForColumnIndex:9]];
            [person setIsAdmin:([rs intForColumnIndex:10] == 1)];
            person.subscribe = [rs stringForColumnIndex:11];
            person.canUnsubscribe = [rs stringForColumnIndex:12];
            person.note = [rs stringForColumnIndex:13];
            person.reply = [rs stringForColumnIndex:14];
            person.menu = [rs stringForColumnIndex:15];
            person.share = [rs intForColumnIndex:16];
            
            person.partnerType = [rs intForColumnIndex:17];
            
            person.oid = [rs stringForColumn:@"oid"];
            person.gender = [rs intForColumn:@"gender"];
            
            
            [persons addObject:person];
        }
        //        }
        [rs close];
    }];
    
    return persons;
}

- (NSArray *)queryPersonIdsWithPersonIds:(NSArray *)personIds
{
    NSMutableArray *personNewIds = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db){
#if DEBUG
        db.logsErrors = YES;
#endif
        NSMutableArray *personIdsWithSingleQuotes = [NSMutableArray array];
        for(NSString *pid in personIds) {
            [personIdsWithSingleQuotes addObject:[NSString stringWithFormat:@"%@%@%@", [pid hasPrefix:@"'"] ? @"" : @"'", pid, [pid hasSuffix:@"'"] ? @"" : @"'"]];
        }
        
        
        NSString *sql = [NSString stringWithFormat:@"SELECT personId FROM %@ Where personId IN (%@);", TABLE_T9_PERSON, [personIdsWithSingleQuotes componentsJoinedByString:@","]];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]) {
            NSString *personId = [rs stringForColumnIndex:0];
            if (personId.length > 0) {
                [personNewIds addObject:personId];
            }
        }
        
        [rs close];
    }];
    
    return personNewIds;
}

//更新头像照片信息
- (BOOL)updatePublicPersonSimpleSetPhotoUrl:(NSString *)personID PhotoUrl:(NSString *)photoUrl
{
    if (personID == nil) {
        return NO;
    }
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"UPDATE %@ Set photoUrl = ? WHERE wbUserId = ?;",TABLE_T9_PERSON];
        
        result = [db executeUpdate:update,photoUrl,personID];
    }];
    return result;
}



//人员搜索栏查询
- (NSArray *)searchPersonsWithSearchText:(NSString *)searchText
{
    NSMutableArray *result = [NSMutableArray array];
    
    BOOL hasHanzi = NO;
    for(int i = 0; i < [searchText length]; i++){
        int a = [searchText characterAtIndex:i];
        if( a > 0x4E00 && a < 0x9FFF){
            hasHanzi = YES;
            break;
        }
    }
    if (hasHanzi) {
        [result addObjectsFromArray:[self searchPersonsWithHanzi:searchText]];
        return result;
    }
    
    BOOL isPhoneNumber = YES;
    for (int i = 0; i < [searchText length]; i++) {
        char c = [searchText characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            continue;
        } else {
            isPhoneNumber = NO;
        }
    }
    if (isPhoneNumber) {
        [result addObjectsFromArray:[self searchPersonsWithPhoneNumber:searchText]];
        return result;
    }
    
    return result;
}

//电话
- (NSArray *)searchPersonsWithPhoneNumber:(NSString *)phoneNumber
{
    NSMutableArray *persons = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin,\
                         photoUrl,status,department,jobTitle FROM %@ \
                         Where defaultPhone like '%%%@%%';",TABLE_T9_PERSON,phoneNumber];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
            
            [person setUserId:[rs intForColumnIndex:0]];
            [person setPersonId:[rs stringForColumnIndex:1]];
            [person setPersonName:[rs stringForColumnIndex:2]];
            [person setDefaultPhone:[rs stringForColumnIndex:3]];
            [person setFullPinyin:[rs stringForColumnIndex:4]];
            [person setPhotoUrl:[rs stringForColumnIndex:5]];
            [person setStatus:[rs intForColumnIndex:6]];
            [person setDepartment:[rs stringForColumnIndex:7]];
            [person setJobTitle:[rs stringForColumnIndex:8]];
            
            [persons addObject:person];
        }
        [rs close];
    }];
    
    return persons;
}

//中文(姓名和部门）
- (NSArray *)searchPersonsWithHanzi:(NSString *)hanzi
{
    NSMutableArray *persons = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin,\
                         photoUrl,status,department,jobTitle FROM %@ \
                         Where personName like '%%%@%%' or department like '%%%@%%';",TABLE_T9_PERSON,hanzi,hanzi];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
            
            [person setUserId:[rs intForColumnIndex:0]];
            [person setPersonId:[rs stringForColumnIndex:1]];
            [person setPersonName:[rs stringForColumnIndex:2]];
            [person setDefaultPhone:[rs stringForColumnIndex:3]];
            [person setFullPinyin:[rs stringForColumnIndex:4]];
            [person setPhotoUrl:[rs stringForColumnIndex:5]];
            [person setStatus:[rs intForColumnIndex:6]];
            [person setDepartment:[rs stringForColumnIndex:7]];
            [person setJobTitle:[rs stringForColumnIndex:8]];
            
            [persons addObject:person];
        }
        [rs close];
    }];
    
    return persons;
}

- (NSArray *)queryAllContactPersonsContainPublic:(BOOL)isContain;
{
    NSMutableArray *persons = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin,photoUrl,status,department,jobTitle,wbUserId,isAdmin,subscribe,canUnsubscribe,note,reply,menu,share,partnerType,oid,gender\nFROM %@ \nWHERE(personId not like \'XT-%%\' And personId not like \'EXT_%%\')And (status > 0) ",TABLE_T9_PERSON];
        
        if (isContain) {
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"UNION SELECT id,personId,personName,defaultPhone,fullPinyin,photoUrl,status,department,jobTitle,wbUserId,isAdmin,subscribe,canUnsubscribe,note,reply,menu,share,partnerType,oid,gender \nFROM %@ \nWHERE personId = \'XT-10000\' ",TABLE_T9_PERSON]];
        }
        
        
        sql = [sql stringByAppendingString:@";"];
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
            
            [person setUserId:[rs intForColumnIndex:0]];
            [person setPersonId:[rs stringForColumnIndex:1]];
            [person setPersonName:[rs stringForColumnIndex:2]];
            [person setDefaultPhone:[rs stringForColumnIndex:3]];
            [person setFullPinyin:[rs stringForColumnIndex:4]];
            if ([person.personId isEqualToString:@"XT-10000"]) {
                [person setFullPinyin:@"Y"];
            }
            [person setPhotoUrl:[rs stringForColumnIndex:5]];
            [person setStatus:[rs intForColumnIndex:6]];
            [person setDepartment:[rs stringForColumnIndex:7]];
            [person setJobTitle:[rs stringForColumnIndex:8]];
            [person setWbUserId:[rs stringForColumnIndex:9]];
            [person setIsAdmin:([rs intForColumnIndex:10] == 1)];
            person.subscribe = [rs stringForColumnIndex:11];
            person.canUnsubscribe = [rs stringForColumnIndex:12];
            person.note = [rs stringForColumnIndex:13];
            person.reply = [rs stringForColumnIndex:14];
            person.menu = [rs stringForColumnIndex:15];
            person.share = [rs intForColumnIndex:16];
            
            person.partnerType = [rs intForColumnIndex:17];
            person.oid = [rs stringForColumn:@"oid"];
            person.gender = [rs intForColumn:@"gender"];
            
            [persons addObject:person];
        }
        [rs close];
    }];
    
    return persons;
}


- (NSArray *)queryRecentPersonsWithLimitNumber:(int)limit isContainPublic:(BOOL)isContain
{
    NSMutableArray *persons = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT a.id,a.personId,a.personName,a.defaultPhone,a.fullPinyin,a.photoUrl,a.status,a.department,a.jobTitle,a.wbUserId,isAdmin,subscribe,canUnsubscribe,note,reply,menu,share,partnerType,oid,gender \nFROM %@ a, %@ b\nWHERE a.personId = b.personId AND a.status > 0\nOrder by b.lastContactTime Desc",TABLE_T9_PERSON,TABLE_RECENTLY];
        if (limit > 0) {
            sql = [sql stringByAppendingFormat:@"\nlimit %d",limit];
        }
        sql = [sql stringByAppendingString:@";"];
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
            
            [person setUserId:[rs intForColumnIndex:0]];
            [person setPersonId:[rs stringForColumnIndex:1]];
            [person setPersonName:[rs stringForColumnIndex:2]];
            [person setDefaultPhone:[rs stringForColumnIndex:3]];
            [person setFullPinyin:[rs stringForColumnIndex:4]];
            [person setPhotoUrl:[rs stringForColumnIndex:5]];
            [person setStatus:[rs intForColumnIndex:6]];
            [person setDepartment:[rs stringForColumnIndex:7]];
            [person setJobTitle:[rs stringForColumnIndex:8]];
            [person setWbUserId:[rs stringForColumnIndex:9]];
            [person setIsAdmin:([rs intForColumnIndex:10] == 1)];
            person.subscribe = [rs stringForColumnIndex:11];
            person.canUnsubscribe = [rs stringForColumnIndex:12];
            person.note = [rs stringForColumnIndex:13];
            person.reply = [rs stringForColumnIndex:14];
            person.menu = [rs stringForColumnIndex:15];
            person.share = [rs intForColumnIndex:16];
            person.partnerType = [rs intForColumnIndex:17];
            
            person.oid = [rs stringForColumn:@"oid"];
            person.gender = [rs intForColumn:@"gender"];
            if (isContain == NO && [person.personId isEqualToString:@"XT-10000"]) {
                continue;
            }
            
            [persons addObject:person];
        }
        [rs close];
    }];
    
    return persons;
}

- (BOOL)deleteRecentlyContact:(NSArray *)personIds
{
    if(personIds.count == 0) {
        return NO;
    }
    
    __block BOOL result = YES;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = nil;
        
        if(personIds.count == 1) {
            sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE personId='%@'", TABLE_RECENTLY, personIds[0]];
        }else {
            NSMutableArray *personIdsWithSingleQuotes = [NSMutableArray arrayWithCapacity:personIds.count];
            
            for(NSString *personId in personIds) {
                [personIdsWithSingleQuotes addObject:[NSString stringWithFormat:@"'%@'", personId]];
            }
            
            sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE personId IN (%@)", TABLE_RECENTLY, [personIdsWithSingleQuotes componentsJoinedByString:@","]];
        }
        
        result = result && [db executeUpdate:sql];
    }];
    
    return result;
}

- (NSArray *)queryFavPersons
{
    NSMutableArray *persons = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin,photoUrl,\
                         status,department,jobTitle,wbUserId,isAdmin,subscribe,canUnsubscribe,note,reply,menu,share,partnerType,oid,gender FROM %@ \
                         Where (personId not like 'XT-%%' And personId not like 'EXT_%%') \
                         And ((status >> 2) & 1) \
                         Order by fullPinyin Asc;",TABLE_T9_PERSON];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
            
            [person setUserId:[rs intForColumnIndex:0]];
            [person setPersonId:[rs stringForColumnIndex:1]];
            [person setPersonName:[rs stringForColumnIndex:2]];
            [person setDefaultPhone:[rs stringForColumnIndex:3]];
            [person setFullPinyin:[rs stringForColumnIndex:4]];
            [person setPhotoUrl:[rs stringForColumnIndex:5]];
            [person setStatus:[rs intForColumnIndex:6]];
            [person setDepartment:[rs stringForColumnIndex:7]];
            [person setJobTitle:[rs stringForColumnIndex:8]];
            [person setWbUserId:[rs stringForColumnIndex:9]];
            [person setIsAdmin:([rs intForColumnIndex:10] == 1)];
            person.subscribe = [rs stringForColumnIndex:11];
            person.canUnsubscribe = [rs stringForColumnIndex:12];
            person.note = [rs stringForColumnIndex:13];
            person.reply = [rs stringForColumnIndex:14];
            person.menu = [rs stringForColumnIndex:15];
            person.share = [rs intForColumnIndex:16];
            person.partnerType = [rs intForColumnIndex:17];
            
            person.oid = [rs stringForColumn:@"oid"];
            person.gender = [rs intForColumn:@"gender"];
            
            [persons addObject:person];
        }
        [rs close];
    }];
    
    return persons;
}

- (BOOL)deletePublicPersonSimpleSetall
{
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *delete = [NSString stringWithFormat:
                            @"DELETE FROM %@;",TABLE_PUBLIC_PERSON];
        result = [db executeUpdate:delete];
        
    }];
    
    return result;
}

- (BOOL)updatePublicPersonSimpleSetsubscribe:(PersonSimpleDataModel *)person
{
    if (person == nil) {
        return NO;
    }
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"UPDATE %@ Set subscribe = ? WHERE personId = ?;",TABLE_PUBLIC_PERSON];
        
        result = [db executeUpdate:update,person.subscribe,person.personId];
    }];
    return result;
}


- (BOOL)insertPublicPersonSimple:(PersonSimpleDataModel *)person
{
    if (person == nil) {
        return NO;
    }
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (personId,personName,defaultPhone,department,fullPinyin,photoUrl,status,jobTitle,note,reply,subscribe,canUnsubscribe,menu,manager,share,fold,state,hisNews) VALUES ('%@','%@','%@','%@','%@','%@',%d,'%@','%@','%@','%@','%@','%@',%d,%d,%d,%d,%d);",TABLE_PUBLIC_PERSON,person.personId,person.personName,person.defaultPhone,person.department,person.fullPinyin,person.photoUrl,person.status,person.jobTitle,person.note,person.reply,person.subscribe,person.canUnsubscribe,person.menu,
                         (person.manager?1:0),(person.share),(person.fold?1:0),person.state,(person.hisNews?1:0)];
        result = [db executeUpdate:sql];
    }];
    return result;
}

- (PersonDataModel*)queryPublicPersonSimple:(NSString *)personId
{
    __block PersonDataModel *personDetail = nil;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ Where personId = '%@';",TABLE_PUBLIC_PERSON,personId];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            personDetail = [[PersonDataModel alloc] init];
            
            [personDetail setPersonId:[rs stringForColumn:@"personId"]];
            [personDetail setPersonName:[rs stringForColumn:@"personName"]];
            [personDetail setPhotoUrl:[rs stringForColumn:@"photoUrl"]];
            [personDetail setNote:[rs stringForColumn:@"note"]];
            [personDetail setReply:[rs stringForColumn:@"reply"]];
            [personDetail setSubscribe:[rs stringForColumn:@"subscribe"]];
            [personDetail setCanUnsubscribe:[rs stringForColumn:@"canUnsubscribe"]];
            [personDetail setMenu:[rs stringForColumn:@"menu"]];
            [personDetail setManager:([rs intForColumn:@"manager"] == 1)];
            [personDetail setStatus:[rs intForColumn:@"status"]];
            [personDetail setState:[rs intForColumn:@"state"]];
            [personDetail setShare:[rs intForColumn:@"share"]];
            [personDetail setFold:([rs intForColumn:@"fold"] == 1)];
            [personDetail setRemind:[rs intForColumn:@"remind"] == 1];
            [personDetail setHisNews:[rs intForColumn:@"hisNews"] == 1];
        }
        [rs close];
    }];
    return personDetail;
}

-  (NSArray *)queryAllPublicPersonSimple
{
    NSMutableArray *persons = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ",TABLE_PUBLIC_PERSON];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
            
            [person setPersonId:[rs stringForColumn:@"personId"]];
            [person setPersonName:[rs stringForColumn:@"personName"]];
            [person setPhotoUrl:[rs stringForColumn:@"photoUrl"]];
            [person setNote:[rs stringForColumn:@"note"]];
            [person setReply:[rs stringForColumn:@"reply"]];
            [person setSubscribe:[rs stringForColumn:@"subscribe"]];
            [person setCanUnsubscribe:[rs stringForColumn:@"canUnsubscribe"]];
            [person setMenu:[rs stringForColumn:@"menu"]];
            [person setManager:([rs intForColumn:@"manager"] == 1)];
            [person setStatus:[rs intForColumn:@"status"]];
            [person setShare:[rs intForColumn:@"share"]];
            [person setFold:([rs intForColumn:@"fold"] == 1)];
            [person setRemind:[rs intForColumn:@"remind"] == 1];
            [person setHisNews:[rs intForColumn:@"hisNews"] == 1];
            [persons addObject:person];
        }
        [rs close];
    }];
    return persons;
}

- (NSArray *)queryPublicAccounts
{
    NSMutableArray *persons = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin,photoUrl,\
                         status,department,jobTitle,wbUserId,isAdmin,subscribe,canUnsubscribe,note,reply,menu,share,partnerType,oid,gender FROM %@ \
                         Where ((status >> 3) & 1) \
                         Order by personName Asc;",TABLE_T9_PERSON];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
            
            [person setUserId:[rs intForColumnIndex:0]];
            [person setPersonId:[rs stringForColumnIndex:1]];
            [person setPersonName:[rs stringForColumnIndex:2]];
            [person setDefaultPhone:[rs stringForColumnIndex:3]];
            [person setFullPinyin:[rs stringForColumnIndex:4]];
            [person setPhotoUrl:[rs stringForColumnIndex:5]];
            [person setStatus:[rs intForColumnIndex:6]];
            [person setDepartment:[rs stringForColumnIndex:7]];
            [person setJobTitle:[rs stringForColumnIndex:8]];
            [person setWbUserId:[rs stringForColumnIndex:9]];
            [person setIsAdmin:([rs intForColumnIndex:10] == 1)];
            person.subscribe = [rs stringForColumnIndex:11];
            person.canUnsubscribe = [rs stringForColumnIndex:12];
            person.note = [rs stringForColumnIndex:13];
            person.reply = [rs stringForColumnIndex:14];
            person.menu = [rs stringForColumnIndex:15];
            person.share = [rs intForColumnIndex:16];
            person.partnerType = [rs intForColumnIndex:17];
            
            person.oid = [rs stringForColumn:@"oid"];
            person.gender = [rs intForColumn:@"gender"];
            
            [persons addObject:person];
        }
        [rs close];
    }];
    
    return persons;
}

- (NSArray *)queryPublicAccountsWithLikeName:(NSString *)name {
    __block NSMutableArray *pubAccts = [NSMutableArray array];
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString * sql = [NSString stringWithFormat:@"SELECT\n\t*\nFROM\n\t%@\nWHERE\n\tpersonName LIKE ?\nAND (\n\tsubscribe = 1\n\tOR canUnsubscribe = 1\n);", TABLE_PUBLIC_PERSON];
        FMResultSet *rs = [db executeQuery:sql, [NSString stringWithFormat:@"%%%@%%", name]];
        while ([rs next]) {
            PersonSimpleDataModel *pubAcct = [self loadPublicAccountWithResultSet:rs];
            NSRange range = [[pubAcct.personName lowercaseString] rangeOfString:name.lowercaseString];
            if (range.location != NSNotFound) {
                pubAcct.highlightName = [pubAcct.personName stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"<font color=\"#06A3EC\">%@</font>", [pubAcct.personName substringWithRange:range]]];
            }
            [pubAccts addObject:pubAcct];
        }
        [rs close];
    }];
    return pubAccts;
}

- (BOOL)updatePublicPersonSimpleSetShareStatus:(int)share withPersonId:(NSString *)personId {
    if (!personId) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"UPDATE %@ Set share = ? WHERE personId = ?;",TABLE_PUBLIC_PERSON];
        
        result = [db executeUpdate:update,@(share),personId];
    }];
    return result;
}

- (PersonDataModel *)queryPersonDetailWithPersonId:(NSString *)personId
{
    PersonDataModel *person = [self privateQueryPersonDetailWithPersonId:personId];
    if (person == nil) {
        person = [[PersonDataModel alloc] init];
        person.personId = personId;
    }
    return person;
}



- (PersonDataModel *)queryPersonDetailWithPerson:(PersonSimpleDataModel *)person
{
    PersonDataModel *personDetail = [self privateQueryPersonDetailWithPersonId:person.personId];
    if (personDetail == nil) {
        personDetail = [[PersonDataModel alloc] init];
        [personDetail setPersonId:person.personId];
        [personDetail setPersonName:person.personName];
        [personDetail setDefaultPhone:person.defaultPhone];
        [personDetail setJobTitle:person.jobTitle];
        [personDetail setDepartment:person.department];
        [personDetail setPhotoUrl:person.photoUrl];
        [personDetail setStatus:person.status];
        
        if ([person.defaultPhone length]) {
            ContactDataModel *contactDM = [[ContactDataModel alloc] init];
            [contactDM setCtext:ASLocalizedString(@"电话")];
            [contactDM setCtype:ContactCellPhone];
            [contactDM setCvalue:person.defaultPhone];
            [personDetail.contact addObject:contactDM];
        }
        //        if ([person.]) {
        //            ParttimejobDataModel *jobDM = [[ParttimejobDataModel alloc] init];
        //            [jobDM setOrgId:person.];
        //            [jobDM setEName:person.];
        //            [jobDM setDepartment:person.department];
        //            [jobDM setJobTitle:person.jobTitle];
        //            [jobDM setJobType:];
        //
        //            [personDetail.parttimejob addObject:jobDM];
        //        }
    }
    return personDetail;
}

- (PersonDataModel *)privateQueryPersonDetailWithPersonId:(NSString *)personId
{
    __block PersonDataModel *personDetail = nil;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin,photoUrl,status,department,jobTitle,wbUserId,isAdmin,subscribe,canUnsubscribe,note,reply,menu,share,partnerType,oid,gender FROM %@ Where personId = ?;",TABLE_T9_PERSON];
        
        FMResultSet *rs = [db executeQuery:sql,personId];
        if ([rs next]) {
            
            personDetail = [[PersonDataModel alloc] init];
            
            [personDetail setUserId:[rs intForColumnIndex:0]];
            [personDetail setPersonId:[rs stringForColumnIndex:1]];
            [personDetail setPersonName:[rs stringForColumnIndex:2]];
            [personDetail setDefaultPhone:[rs stringForColumnIndex:3]];
            [personDetail setFullPinyin:[rs stringForColumnIndex:4]];
            [personDetail setPhotoUrl:[rs stringForColumnIndex:5]];
            [personDetail setStatus:[rs intForColumnIndex:6]];
            [personDetail setDepartment:[rs stringForColumnIndex:7]];
            [personDetail setJobTitle:[rs stringForColumnIndex:8]];
            [personDetail setWbUserId:[rs stringForColumnIndex:9]];
            [personDetail setIsAdmin:([rs intForColumnIndex:10] == 1)];
            personDetail.subscribe = [rs stringForColumnIndex:11];
            personDetail.canUnsubscribe = [rs stringForColumnIndex:12];
            personDetail.note = [rs stringForColumnIndex:13];
            personDetail.reply = [rs stringForColumnIndex:14];
            personDetail.menu = [rs stringForColumnIndex:15];
            personDetail.share = [rs intForColumnIndex:16];
            personDetail.partnerType = [rs intForColumnIndex:17];
            personDetail.oid = [rs stringForColumn:@"oid"];
            personDetail.gender = [rs intForColumn:@"gender"];
            
        }
        [rs close];
        
        if (personDetail != nil) {
            
            NSString *contactSqlStatement = [NSString stringWithFormat:@"SELECT type,text,value from %@ where personId = ?;",TABLE_CONTACT];
            FMResultSet *rs1 = [db executeQuery:contactSqlStatement,personId];
            if ([rs1 next]) {
                
                ContactDataModel *contact = [[ContactDataModel alloc] init];
                
                [contact setCtype:[rs1 intForColumnIndex:0]];
                [contact setCtext:[rs1 stringForColumnIndex:1]];
                [contact setCvalue:[rs1 stringForColumnIndex:2]];
                
                [personDetail.contact addObject:contact];
            }
            [rs1 close];
        }
    }];
    
    return personDetail;
}

- (BOOL)insertPersonContacts:(PersonDataModel *)person
{
    if (person.personId.length == 0 || [person.contact count] == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *deleteContact = [NSString stringWithFormat:@"DELETE FROM %@ WHERE personId = ?;",TABLE_CONTACT];
        result = [db executeUpdate:deleteContact,person.personId];
        
        [person.contact enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ContactDataModel *contact = (ContactDataModel *)obj;
            NSString *insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (personId,type,text,value) VALUES (?,?,?,?);",TABLE_CONTACT];
            result = result && [db executeUpdate:insert,person.personId,[NSNumber numberWithInt:contact.ctype],contact.ctext,contact.cvalue];
        }];
        
    }];
    
    return result;
}

//插入职位表
- (BOOL)insertPersonJob:(PersonSimpleDataModel *)person
{
    if (person.personId.length == 0 || [person.parttimejob count] == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *deleteContact = [NSString stringWithFormat:@"DELETE FROM %@ WHERE personId = ?;",TABLE_JOB];
        result = [db executeUpdate:deleteContact,person.personId];
        
        [person.parttimejob enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            ParttimejobDataModel *parttimeJob = (ParttimejobDataModel *)obj;
            NSString *insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (personId,orgId,eName,jobType,jobTitle,department) VALUES (?,?,?,?,?,?);", TABLE_JOB];
            
            result = result && [db executeUpdate:insert, person.personId, parttimeJob.orgId, parttimeJob.eName, @(parttimeJob.jobType?1:0), parttimeJob.jobTitle, parttimeJob.department];;
        }];
        
    }];
    
    return result;
}

- (BOOL)updatePersonStatus:(PersonSimpleDataModel *)person
{
    if (person.personId.length == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        //        NSString *updateStatus = [NSString stringWithFormat:@"UPDATE %@ Set status = ? WHERE personId = ?;",TABLE_T9_PERSON];
        //        result = [db executeUpdate:updateStatus,[NSNumber numberWithInt:person.status],person.personId];
        BOOL existsPerson = [self personExist:person.personId db:db];
        if (existsPerson) {
            NSString *updateStatus = [NSString stringWithFormat:@"UPDATE %@ Set status = ? WHERE personId = ?;",TABLE_T9_PERSON];
            result = [db executeUpdate:updateStatus,[NSNumber numberWithInt:person.status],person.personId];
        }
        
    }];
    
    return result;
}

- (BOOL)insertPersonSimple:(PersonSimpleDataModel *)person
{
    if (person == nil) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self insertPersonSimple:person lastContactTime:nil db:db];
    }];
    return result;
}

- (BOOL)personExist:(NSString*)personId db:(FMDatabase *)db
{
    BOOL result = NO;
    NSString * queryPerson = [NSString stringWithFormat:@"select count(1) from %@ where personId = ?;",TABLE_T9_PERSON];
    FMResultSet * rs = [db executeQuery:queryPerson,personId];
    if([rs next])
    {
        result = [rs intForColumnIndex:0] > 0;
    }
    [rs close];
    
    return result;
}

- (BOOL)insertPersonSimple:(PersonSimpleDataModel *)person lastContactTime:(NSString *)lastContactTime db:(FMDatabase *)db
{
    if (person.personName.length == 0) {
        return NO;
    }
    
    NSString * sql = nil;
    BOOL result = NO;
    if ([self personExist:person.personId db:db])
    {
        sql = [NSString stringWithFormat:@"update %@ set personName = ?,defaultPhone = ?,department=?,jobTitle=?,photoUrl=?,status=?,fullPinyin=?,wbUserId=?,isAdmin=?,menu=?,note=?,canUnsubscribe=?,reply=?,subscribe=?,share=?,partnerType=?,oid=?,orgId=?,gender=? where personId = '%@';",TABLE_T9_PERSON,person.personId];
        result = [db executeUpdate:sql,person.personName,person.defaultPhone,person.department,person.jobTitle,person.photoUrl,[NSNumber numberWithInt:person.status],person.fullPinyin,person.wbUserId,@(person.isAdmin?1:0),person.menu,person.note,person.canUnsubscribe,person.reply,person.subscribe,@(person.share),@(person.partnerType),person.oid,person.orgId,@(person.gender)];
    }
    else
    {
        NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (personId,personName,defaultPhone,department,jobTitle,photoUrl,status,fullPinyin,wbUserId,isAdmin,menu,note,canUnsubscribe,reply,subscribe,share,partnerType,oid,orgId,gender) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",TABLE_T9_PERSON];
        result = [db executeUpdate:sql,person.personId,person.personName,person.defaultPhone,person.department,person.jobTitle,person.photoUrl,[NSNumber numberWithInt:person.status],person.fullPinyin,person.wbUserId,@(person.isAdmin?1:0),person.menu,person.note,person.canUnsubscribe,person.reply,person.subscribe,@(person.share),@(person.partnerType),person.oid,person.orgId,@(person.gender)];
    }
    
    if (lastContactTime && ![person.personId isEqualToString:[BOSConfig sharedConfig].user.userId]) {
        NSString *sql1 = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (personId,lastContactTime) VALUES (?,?)",TABLE_RECENTLY];
        result = result && [db executeUpdate:sql1,person.personId,lastContactTime];
    }
    
    return result;
}

#pragma mark - Particpant

- (NSString *)queryGroupIdWithPublicPersonId:(NSString *)personId
{
    __block NSString *groupId = nil;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT groupId from %@ where personId = ?",TABLE_PARTICIPANT];
        
        FMResultSet *rs = [db executeQuery:sql,personId];
        if ([rs next]) {
            groupId = [rs stringForColumnIndex:0];
        }
        
        [rs close];
        
    }];
    
    return groupId;
}

- (NSString *)queryPersonIdWithGroupId:(NSString *)groupId
{
    __block NSString *personId = nil;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT personId from %@ where groupId = ?",TABLE_PARTICIPANT];
        
        FMResultSet *rs = [db executeQuery:sql,groupId];
        if ([rs next]) {
            personId = [rs stringForColumnIndex:0];
        }
        
        [rs close];
        
    }];
    
    return personId;
}

- (NSArray *)queryPersonWithOids:(NSArray *)oids {
    NSMutableArray *persons = [NSMutableArray array];
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSMutableArray * personIdsWithSingleQuotes = [NSMutableArray array];
        for (NSString *oid in oids) {
            [personIdsWithSingleQuotes addObject:[NSString stringWithFormat:@"%@%@%@", [oid hasPrefix:@"'"] ? @"" : @"'", oid, [oid hasSuffix:@"'"] ? @"" : @"'"]];
        }
        
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ Where oid IN (%@);", TABLE_T9_PERSON, [personIdsWithSingleQuotes componentsJoinedByString:@","]];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            PersonSimpleDataModel *person = [self loadPersonWithResultSet:rs];
            [persons addObject:person];
        }
        [rs close];
    }];
    
    return persons;
}

- (BOOL)deleteParticpantWithPersonIdArray:(NSArray *)personIdArray groupId:(NSString *)groupId
{
    if (personIdArray.count == 0 || groupId.length == 0) {
        return NO;
    }
    
    NSMutableString *personIdsString = [NSMutableString string];
    [personIdArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [personIdsString appendFormat:@"'%@'",obj];
        if(idx != personIdArray.count - 1)
            [personIdsString appendString:@","];
    }];
    
    
    __block BOOL result = YES;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        [db shouldCacheStatements];
        [personIdArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            result = result && [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ Where groupId = ? and personId = ?;",TABLE_PARTICIPANT],groupId,obj];
        }];
        //result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ Where groupId = ? and personId in (?);",TABLE_PARTICIPANT],groupId,personIdsString];
        
    }];
    return result;
}

- (BOOL)addParticpantWithPersonIdArray:(NSArray *)personIdArray groupId:(NSString *)groupId
{
    if (personIdArray.count == 0 || groupId.length == 0) {
        return NO;
    }
    
    __block BOOL result = YES;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        [db shouldCacheStatements];
        [personIdArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            result = result && [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (groupId,personId) VALUES (?,?);",TABLE_PARTICIPANT],groupId,obj];
        }];
        
    }];
    
    return result;
}

#pragma mark - Message

- (NSArray *)queryNotifyRecordsWithGroupId:(NSString *)groupId
{
    NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback){
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = [NSString stringWithFormat:@"SELECT  msgId,fromUserId,sendTime,msgType,\
                         msgLen,content,status,direction,requestType,fromUserNickName,param,notifyType,notifyDesc \
                         FROM %@\
                         WHERE status = 0 AND notifyType = 1 AND groupId = '%@' Order by sendTime Desc",TABLE_MESSAGE, groupId];
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next])
        {
            RecordDataModel *record = [[RecordDataModel alloc] init];
            record.msgId = [rs stringForColumnIndex:0];
            record.fromUserId = [rs stringForColumnIndex:1];
            record.sendTime = [rs stringForColumnIndex:2];
            record.msgType = [rs intForColumnIndex:3];
            record.msgLen = [rs intForColumnIndex:4];
            record.content = [rs stringForColumnIndex:5];
            record.status = [rs intForColumnIndex:6];
            record.msgDirection = [rs intForColumnIndex:7];
            record.msgRequestState = [rs intForColumnIndex:8];
            record.nickname = [rs stringForColumnIndex:9];
            record.groupId = groupId;
            record.iNotifyType = [rs intForColumnIndex:11];
            record.strNotifyDesc = [rs stringForColumnIndex:12];
            NSString *paramString = [rs stringForColumnIndex:10];
            if (paramString.length > 0)
            {
                MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithJSONString:paramString type:record.msgType];
                record.param = param;
            }
            [records addObject:record];
        }
        [rs close];
    }];
    
    return records;
}
// 分页查询消息
- (NSArray *)queryRecordWithGroupId:(NSString *)groupId toUserId:(NSString *)toUserId publicId:(NSString *)publicId count:(int)count msgId:(NSString *)strMsgId direction:(MessagePagingDirection)direction
{
    if (groupId.length == 0 && toUserId.length == 0)
    {
        return [NSMutableArray array];
    }
    
    if (count <= 0)
    {
        count = 100;
    }
    NSMutableArray *records = [NSMutableArray array];
    [self.databaseQueue inDatabase: ^(FMDatabase *db)
     {
#if DEBUG
         db.logsErrors = YES;
#endif
         //查询对话记录
         NSString * sql = [NSString stringWithFormat:@"SELECT a.msgId,a.fromUserId,a.sendTime,a.msgType,\
                           a.msgLen,a.content,a.status,a.direction,a.requestType,a.fromUserNickName,a.param,a.notifyType,a.notifyDesc,a.emojiType,a.important,a.sourceMsgId,a.fromClientId,b.unreadCount,a.isOriginalPic,a.fromUserPhoto,a.fromUserName FROM %@ AS a LEFT OUTER JOIN %@ AS b ON a.msgId = b.msgId Where ", TABLE_MESSAGE, TABLE_MSGREADSTATE];
         if (strMsgId.length > 0)
         {
             if (direction == MessagePagingDirectionNew)
             {
                 sql = [sql stringByAppendingFormat:@"a.msgType != %d and a.sendTime > (select sendTime from %@ where msgId = '%@') and (", MessageTypeEvent, TABLE_MESSAGE, strMsgId];
             }
             else if (direction == MessagePagingDirectionOld)
             {
                 sql = [sql stringByAppendingFormat:@"a.msgType != %d and a.sendTime < (select sendTime from %@ where msgId = '%@') and (", MessageTypeEvent, TABLE_MESSAGE, strMsgId];
             }
             else {
                 sql = [sql stringByAppendingFormat:@"a.msgType != %d and a.sendTime >= (select sendTime from %@ where msgId = '%@') and (", MessageTypeEvent, TABLE_MESSAGE, strMsgId];
             }
         }
         else {
             sql = [sql stringByAppendingFormat:@"a.msgType != %d and (", MessageTypeEvent];
         }
         if (groupId.length > 0) {
             sql = [sql stringByAppendingFormat:@"a.groupId = '%@'", groupId];
         }
         else {
             if (toUserId.length > 0) {
                 sql = [sql stringByAppendingFormat:@"a.toUserId = '%@'", toUserId];
             }
         }
         sql = [sql stringByAppendingString:@") Order by a.sendTime Desc, a.direction ASC, a.rowId Desc"];
         
         sql = [sql stringByAppendingFormat:@" limit %d;", count];
         
         //避免使用or,会导致放弃索引遍历全表
         if (groupId.length > 0 && toUserId.length > 0) {
             sql = [sql stringByAppendingFormat:@" UNION SELECT a.msgId,a.fromUserId,a.sendTime,a.msgType,\
                    a.msgLen,a.content,a.status,a.direction,a.requestType,a.fromUserNickName,a.param,a.notifyType,a.notifyDesc,a.emojiType,a.important,a.sourceMsgId,a.fromClientId,a.fromUserPhoto,a.fromUserName,b.unreadCount FROM %@ AS a LEFT OUTER JOIN %@ AS b ON a.msgId = b.msgId Where", TABLE_MESSAGE, TABLE_MSGREADSTATE];
             sql = [sql stringByAppendingFormat:@" a.msgType != %d and", MessageTypeEvent];
             sql = [sql stringByAppendingFormat:@" a.toUserId = '%@'", toUserId];
             sql = [sql stringByAppendingString:@" Order by a.sendTime Desc, a.direction ASC, a.rowId Desc"];
             sql = [sql stringByAppendingFormat:@" limit %d;", count];
         }
         
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) {
             RecordDataModel *record = [[RecordDataModel alloc] init];
             
             record.msgId = [rs stringForColumnIndex:0];
             record.fromUserId = [rs stringForColumnIndex:1];
             record.sendTime = [rs stringForColumnIndex:2];
             record.msgType = [rs intForColumnIndex:3];
             record.msgLen = [rs intForColumnIndex:4];
             record.content = [rs stringForColumnIndex:5];
             record.status = [rs intForColumnIndex:6];
             record.msgDirection = [rs intForColumnIndex:7];
             record.msgRequestState = [rs intForColumnIndex:8];
             record.nickname = [rs stringForColumnIndex:9];
             record.groupId = groupId;
             
             record.iNotifyType = [rs intForColumnIndex:11];
             record.strNotifyDesc = [rs stringForColumnIndex:12];
             record.strEmojiType = [rs stringForColumnIndex:13];
             record.bImportant = [rs boolForColumnIndex:14];
             record.sourceMsgId = [rs stringForColumn:@"sourceMsgId"];
             record.msgUnreadCount = [[rs stringForColumn:@"unreadCount"] integerValue];
             record.fromClientId = [rs stringForColumn:@"fromClientId"];
             record.isOriginalPic = [rs stringForColumn:@"isOriginalPic"];
             record.fromUserPhoto =[rs stringForColumn:@"fromUserPhoto"];
             record.fromUserName =[rs stringForColumn:@"fromUserName"];
             NSString *paramString = [rs stringForColumnIndex:10];
             if (paramString.length > 0) {
                 MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithJSONString:paramString type:record.msgType];
                 record.param = param;
             }
             
             [records addObject:record];
             
         }
         [rs close];
     }];
    return records;
}

- (NSString *)queryMsgIdOfLatest:(BOOL)bLatest
                     WithGroupId:(NSString *)groupId
                        toUserId:(NSString *)toUserId
                        publicId:(NSString *)publicId

{
    if (groupId.length == 0 && toUserId.length == 0)
    {
        return @"";
    }
    
    __block NSString *msgId = @"";
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db)
     {
#if DEBUG
         db.logsErrors = YES;
#endif
         
         //查询对话记录
         NSString * sql = [NSString stringWithFormat:@"SELECT a.msgId FROM %@ AS a LEFT OUTER JOIN %@ AS b ON a.msgId = b.msgId Where ", TABLE_MESSAGE, TABLE_MSGREADSTATE];
         
         sql = [sql stringByAppendingFormat:@"a.msgType != %d and (", MessageTypeEvent];
         if (groupId.length > 0) {
             sql = [sql stringByAppendingFormat:@"a.groupId = '%@'", groupId];
         }
         else {
             if (toUserId.length > 0) {
                 sql = [sql stringByAppendingFormat:@"a.toUserId = '%@'", toUserId];
             }
         }
         sql = [sql stringByAppendingFormat:@") Order by a.sendTime %@ limit 1;", bLatest ? @"DESC" : @"ASC"];
         
         //避免使用or,会导致放弃索引遍历全表
         if (groupId.length > 0 && toUserId.length > 0) {
             sql = [sql stringByAppendingFormat:@" UNION SELECT a.msgId FROM %@ AS a LEFT OUTER JOIN %@ AS b ON a.msgId = b.msgId Where",TABLE_MESSAGE, TABLE_MSGREADSTATE];
             sql = [sql stringByAppendingFormat:@" a.msgType != %d and", MessageTypeEvent];
             sql = [sql stringByAppendingFormat:@" a.toUserId = '%@'", toUserId];
             sql = [sql stringByAppendingFormat:@" Order by a.sendTime %@ limit 1;", bLatest ? @"DESC" : @"ASC"];
         }
         
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next])
         {
             msgId = [rs stringForColumnIndex:0];
         }
         [rs close];
     }];
    
    return msgId;
}


-(NSArray *)queryRecordWithGroupId:(NSString *)groupId toUserId:(NSString *)toUserId sendTime:(NSString *)sendTime count:(int)count
{
    if (groupId.length == 0 && toUserId.length == 0) {
        return [NSMutableArray array];
    }
    if (count <= 0) {
        count = 100;
    }
    
    NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        //查询对话记录
        NSString *sql = [NSString stringWithFormat:@"SELECT msgId,fromUserId,sendTime,msgType,\
                         msgLen,content,status,direction,requestType,fromUserNickName,param,notifyType,notifyDesc, emojiType, important, sourceMsgId, isOriginalPic  \
                         FROM %@\
                         Where ",TABLE_MESSAGE];
        sql = [sql stringByAppendingFormat:@"msgType != %d and (",MessageTypeEvent];
        if (groupId.length > 0) {
            sql = [sql stringByAppendingFormat:@"groupId = '%@'",groupId];
            
        }else{
            if (toUserId.length > 0) {
                sql = [sql stringByAppendingFormat:@"toUserId = '%@'",toUserId];
            }
        }
        
        if(sendTime.length > 0){
            sql = [sql stringByAppendingFormat:@") and sendTime >= '%@'",sendTime];
        }
        sql = [sql stringByAppendingString:@" Order by sendTime ASC, direction ASC, rowId Desc"];
        //        sql = [sql stringByAppendingFormat:@" limit %d,%d;",page,count];
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            
            RecordDataModel *record = [[RecordDataModel alloc] init];
            
            record.msgId = [rs stringForColumnIndex:0];
            record.fromUserId = [rs stringForColumnIndex:1];
            record.sendTime = [rs stringForColumnIndex:2];
            record.msgType = [rs intForColumnIndex:3];
            record.msgLen = [rs intForColumnIndex:4];
            record.content = [rs stringForColumnIndex:5];
            record.status = [rs intForColumnIndex:6];
            record.msgDirection = [rs intForColumnIndex:7];
            record.msgRequestState = [rs intForColumnIndex:8];
            record.nickname = [rs stringForColumnIndex:9];
            record.groupId = groupId;
            
            record.iNotifyType = [rs intForColumnIndex:11];
            record.strNotifyDesc = [rs stringForColumnIndex:12];
            record.strEmojiType = [rs stringForColumnIndex:13];
            record.bImportant = [rs boolForColumnIndex:14];
            record.sourceMsgId = [rs stringForColumn:@"sourceMsgId"];
            record.isOriginalPic = [rs stringForColumn:@"isOriginalPic"];
            record.msgUnreadCount = [[rs stringForColumn:@"unreadCount"] integerValue];
            NSString *paramString = [rs stringForColumnIndex:10];
            if (paramString.length > 0) {
                MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithJSONString:paramString type:record.msgType];
                record.param = param;
            }
            
            [records addObject:record];
            
        }
        [rs close];
    }];
    
    return  records;
    
}

- (NSArray *)queryRecordWithGroupId:(NSString *)groupId toUserId:(NSString *)toUserId publicId:(NSString *)publicId page:(int)page count:(int)count
{
    if (groupId.length == 0 && toUserId.length == 0) {
        return [NSMutableArray array];
    }
    
    if (page < 0) {
        page = 0;
    }
    if (count <= 0) {
        count = 100;
    }
    NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        //查询对话记录
        NSString *sql = [NSString stringWithFormat:@"SELECT a.msgId,a.fromUserId,a.sendTime,a.msgType,\
                         a.msgLen,a.content,a.status,a.direction,a.requestType,a.fromUserNickName,a.param,a.notifyType,a.notifyDesc, a.emojiType, a.important, a.sourceMsgId , a.isOriginalPic,a.fromClientId,b.unreadCount,b.press \
                         FROM %@ AS a LEFT OUTER JOIN %@ AS b\
                         ON a.msgId=b.msgId ",TABLE_MESSAGE,TABLE_MSGREADSTATE];
        sql = [sql stringByAppendingFormat:@" WHERE A.msgType != %d and (",MessageTypeEvent];
        if (groupId.length > 0) {
            sql = [sql stringByAppendingFormat:@"a.groupId = '%@'",groupId];
        }else{
            if (toUserId.length > 0) {
                sql = [sql stringByAppendingFormat:@"a.toUserId = '%@'",toUserId];
            }
        }
        sql = [sql stringByAppendingString:@") Order by a.sendTime Desc, a.direction ASC, a.rowId Desc"];
        sql = [sql stringByAppendingFormat:@" limit %d,%d;",page,count];
        //避免使用or,会导致放弃索引遍历全表
        //        if (groupId.length > 0 && toUserId.length > 0) {
        //            sql = [sql stringByAppendingFormat:@" UNION SELECT msgId,fromUserId,sendTime,msgType,\
        //                   msgLen,content,status,direction,requestType,fromUserNickName,param,notifyType,notifyDesc \
        //                   FROM %@\
        //                   Where",TABLE_MESSAGE];
        //            sql = [sql stringByAppendingFormat:@" msgType != %d and",MessageTypeEvent];
        //            sql = [sql stringByAppendingFormat:@" toUserId = '%@'",toUserId];
        //            sql = [sql stringByAppendingString:@" Order by sendTime Desc, direction ASC, rowId Desc"];
        //            sql = [sql stringByAppendingFormat:@" limit %d,%d;",page,count];
        //        }
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            
            RecordDataModel *record = [[RecordDataModel alloc] init];
            
            record.msgId = [rs stringForColumnIndex:0];
            record.fromUserId = [rs stringForColumnIndex:1];
            record.sendTime = [rs stringForColumnIndex:2];
            record.msgType = [rs intForColumnIndex:3];
            record.msgLen = [rs intForColumnIndex:4];
            record.content = [rs stringForColumnIndex:5];
            record.status = [rs intForColumnIndex:6];
            record.msgDirection = [rs intForColumnIndex:7];
            record.msgRequestState = [rs intForColumnIndex:8];
            record.nickname = [rs stringForColumnIndex:9];
            record.groupId = groupId;
            
            record.iNotifyType = [rs intForColumnIndex:11];
            record.strNotifyDesc = [rs stringForColumnIndex:12];
            record.strEmojiType = [rs stringForColumnIndex:13];
            record.bImportant = [rs boolForColumnIndex:14];
            record.sourceMsgId = [rs stringForColumn:@"sourceMsgId"];
            record.isOriginalPic = [rs stringForColumn:@"isOriginalPic"];
            record.fromClientId = [rs stringForColumn:@"fromClientId"];
            NSString *paramString = [rs stringForColumnIndex:10];
            record.sourceMsgId = [rs stringForColumn:@"sourceMsgId"];
            record.msgUnreadCount = [[rs stringForColumn:@"unreadCount"] integerValue];
            //            record.fromClientId = [rs stringForColumn:@"fromClientId"];
            if (paramString.length > 0) {
                MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithJSONString:paramString type:record.msgType];
                record.param = param;
            }
            
            [records addObject:record];
            
        }
        [rs close];
    }];
    
    return  records;
}

- (NSArray *)queryRecordsWithGroupId:(NSString *)groupId toUserId:(NSString *)toUserId publicId:(NSString *)publicId fromMsgId:(NSString *)strMsgId
{
    if (groupId.length == 0 && toUserId.length == 0) {
        return [NSMutableArray array];
    }
    NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        //查询对话记录
        NSString *sql = [NSString stringWithFormat:@"SELECT msgId,fromUserId,sendTime,msgType,\
                         msgLen,content,status,direction,requestType,fromUserNickName,param,notifyType,notifyDesc,  emojiType, important, sourceMsgId, isOriginalPic,fromClientId\
                         FROM  %@\
                         Where ",TABLE_MESSAGE];
        sql = [sql stringByAppendingFormat:@"msgType != %d and sendTime >= (select sendTime from %@ where msgId = '%@') and (",MessageTypeEvent, TABLE_MESSAGE, strMsgId];
        if (groupId.length > 0) {
            sql = [sql stringByAppendingFormat:@"groupId = '%@'",groupId];
            
        }else{
            if (toUserId.length > 0) {
                sql = [sql stringByAppendingFormat:@"toUserId = '%@'",toUserId];
            }
        }
        sql = [sql stringByAppendingString:@") Order by sendTime Desc, direction ASC, rowId Desc;"];
        
        //避免使用or,会导致放弃索引遍历全表
        if (groupId.length > 0 && toUserId.length > 0) {
            sql = [sql stringByAppendingFormat:@" UNION SELECT msgId,fromUserId,sendTime,msgType,\
                   msgLen,content,status,direction,requestType,fromUserNickName,param,notifyType,notifyDesc,emojiType , important \
                   FROM %@\
                   Where",TABLE_MESSAGE];
            sql = [sql stringByAppendingFormat:@" msgType != %d and",MessageTypeEvent];
            sql = [sql stringByAppendingFormat:@" toUserId = '%@'",toUserId];
            sql = [sql stringByAppendingString:@" Order by sendTime Desc, direction ASC, rowId Desc;"];
        }
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            
            RecordDataModel *record = [[RecordDataModel alloc] init];
            
            record.msgId = [rs stringForColumnIndex:0];
            record.fromUserId = [rs stringForColumnIndex:1];
            record.sendTime = [rs stringForColumnIndex:2];
            record.msgType = [rs intForColumnIndex:3];
            record.msgLen = [rs intForColumnIndex:4];
            record.content = [rs stringForColumnIndex:5];
            record.status = [rs intForColumnIndex:6];
            record.msgDirection = [rs intForColumnIndex:7];
            record.msgRequestState = [rs intForColumnIndex:8];
            record.nickname = [rs stringForColumnIndex:9];
            record.groupId = groupId;
            
            record.iNotifyType = [rs intForColumnIndex:11];
            record.strNotifyDesc = [rs stringForColumnIndex:12];
            record.strEmojiType = [rs stringForColumnIndex:13];
            record.bImportant = [rs boolForColumnIndex:14];
            record.sourceMsgId = [rs stringForColumn:@"sourceMsgId"];
            record.isOriginalPic = [rs stringForColumn:@"isOriginalPic"];
            record.fromClientId = [rs stringForColumn:@"fromClientId"];
            record.msgUnreadCount = [[rs stringForColumn:@"unreadCount"] integerValue];
            
            NSString *param = [rs stringForColumn:@"param"];
            if(param)
            {
                id jsonResult = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if (jsonResult)
                {
                    MessageParamDataModel *paramDM = [[MessageParamDataModel alloc] initWithDictionary:jsonResult type:record.msgType];
                    record.param = paramDM;
                }
            }
            
            [records addObject:record];
            
        }
        [rs close];
    }];
    
    return  records;
}

- (NSArray *)queryAllDocumentsWithGroupId:(NSString *)groupId
                                 toUserId:(NSString *)toUserId
                                pageIndex:(NSInteger)pageIndex
                                 isAtEnd : (BOOL *)isAtEnd{
    if(groupId.length == 0 && toUserId == 0){
        return [NSMutableArray array];
    }
    
    if(pageIndex < 0)
        pageIndex = 0;
    
    NSInteger pageOffset = pageIndex * 50;
    
    __block NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *groupSql = [NSString stringWithFormat:@"(\n\t\tSELECT\n\tmsgId,\n\tfromUserId,\n\tsendTime,\n\tmsgType,\n\tmsgLen,\n\tcontent,\n\tstatus,\n\tdirection,\n\trequestType,\n\tfromUserNickName,\n\tparam\nFROM\n\t%@\nWHERE\n",TABLE_MESSAGE];
        if(groupId.length > 0){
            groupSql = [groupSql stringByAppendingFormat:@"\t\t\tgroupId = '%@'\n",groupId];
        }
        
        else if (toUserId.length > 0){
            groupSql = [groupSql stringByAppendingFormat:@"\t\t\ttoUserId = '%@'\n",toUserId];
        }
        groupSql = [groupSql stringByAppendingString:@")"];
        
        NSString *sql = [NSString stringWithFormat:@"\n    SELECT\n  msgId,\n  fromUserId,\n  sendTime,\n  msgType,\n  msgLen,\n  content,\n  status,\n  direction,\n  requestType,\n  fromUserNickName,\n  param\nFROM\n  %@\nWHERE\n  msgType = %d\n  AND (\n    param LIKE \'%%\"ext\" : \"xlsx\"%%\'\n    OR param LIKE \'%%\"ext\" : \"xls\"%%\'\n    OR param like \'%%\"ext\" : \"doc\"%%\'\n    OR param Like \'%%\"ext\" : \"docx\"%%\'\n    OR param LIKE \'%%\"ext\" : \"ppt\"%%\'\n    OR param Like \'%%\"ext\" : \"pptx\"%%\'\n    OR param LIKE \'%%\"ext\" : \"html\"%%\'\n    OR param LIKE \'%%\"ext\" : \"pdf\"%%\'\n    OR param LIKE \'%%\"ext\" : \"txt\"%%\'\n  )\nORDER BY\n  sendTime DESC", groupSql, MessageTypeFile];
        
        
        NSString *countSql = [NSString stringWithFormat:@"SELECT\n\tcount(1)\nFROM\n\t(\n\t\t%@\n\t)\n",sql];
        
        //判断当前文档数量是否已经到达数量底部
        int count = 0;
        FMResultSet *countRS = [db executeQuery:countSql];
        if ([countRS next]) {
            count = [countRS intForColumnIndex:0];
        }
        [countRS close];
        if(count <= pageOffset + 50){
            *isAtEnd = YES;
        }
        else{
            *isAtEnd = NO;
        }
        sql = [sql stringByAppendingFormat:@"\n\t\tLIMIT 50\n\tOFFSET\n\t%ld\n\t",(long)pageOffset];
        
        
        FMResultSet *recordSet = [db executeQuery:sql];
        while ([recordSet next]) {
            //TODO:把recordSet封装，添加到records中返回
            DLog(@"%@",[recordSet stringForColumnIndex:0]);
            RecordDataModel *record = [[RecordDataModel alloc] init];
            record.msgId = [recordSet stringForColumnIndex:0];
            record.fromUserId = [recordSet stringForColumnIndex:1];
            record.sendTime = [recordSet stringForColumnIndex:2];
            record.msgType = [recordSet intForColumnIndex:3];
            record.msgLen = [recordSet intForColumnIndex:4];
            record.content = [recordSet stringForColumnIndex:5];
            record.status = [recordSet intForColumnIndex:6];
            record.msgDirection = [recordSet intForColumnIndex:7];
            record.msgRequestState = [recordSet intForColumnIndex:8];
            record.nickname = [recordSet stringForColumnIndex:9];
            record.groupId = groupId;
            
            NSString *paramString = [recordSet stringForColumnIndex:10];
            if (paramString.length > 0) {
                MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithJSONString:paramString type:record.msgType];
                record.param = param;
            }
            
            [records insertObject:record atIndex:0];
            
        }
        [recordSet close];
    }];
    
    return records;
}

- (NSArray *)queryAllPicturesWithGroupId:(NSString *)groupId
                                toUserId:(NSString *)toUserId
                               pageIndex:(NSInteger)pageIndex
                                isAtEnd : (BOOL *)isAtEnd{
    if(groupId.length == 0 && toUserId == 0){
        return [NSMutableArray array];
    }
    
    if(pageIndex < 0)
        pageIndex = 0;
    
    NSInteger pageOffset = pageIndex * 50;
    
    __block NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *groupSql = [NSString stringWithFormat:@"(\n\t\tSELECT\n\tmsgId,\n\tfromUserId,\n\tsendTime,\n\tmsgType,\n\tmsgLen,\n\tcontent,\n\tstatus,\n\tdirection,\n\trequestType,\n\tfromUserNickName,\n\tparam\n,\n\temojiType\nFROM\n\t%@\nWHERE\n",TABLE_MESSAGE];
        if(groupId.length > 0){
            groupSql = [groupSql stringByAppendingFormat:@"\t\t\tgroupId = '%@'\n",groupId];
        }
        
        else if (toUserId.length > 0){
            groupSql = [groupSql stringByAppendingFormat:@"\t\t\ttoUserId = '%@'\n",toUserId];
        }
        groupSql = [groupSql stringByAppendingString:@")"];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT\n\tmsgId,\n\tfromUserId,\n\tsendTime,\n\tmsgType,\n\tmsgLen,\n\tcontent,\n\tstatus,\n\tdirection,\n\trequestType,\n\tfromUserNickName,\n\tparam\n,\n\temojiType\nFROM\n\t%@\nWHERE\n\tmsgType = %d\n\nUNION ALL\n\nSELECT\n\tmsgId,\n\tfromUserId,\n\tsendTime,\n\tmsgType,\n\tmsgLen,\n\tcontent,\n\tstatus,\n\tdirection,\n\trequestType,\n\tfromUserNickName,\n\tparam\n,\n\temojiType\nFROM\n\t%@\nWHERE\n\tmsgType = %d\n\tAND (\n\t\tparam LIKE \'%%\"ext\" : \"png\"%%\'\n\t\tOR param LIKE \'%%\"ext\" : \"jpeg\"%%\'\n\t\tOR param LIKE \'%%\"ext\" : \"jpg\"%%\'\n\t\tOR param LIKE \'%%\"ext\" : \"bmp\"%%\'\n\t\tOR param LIKE \'%%\"ext\" : \"gif\"%%\'\n\t)\n\nORDER BY\n\tsendTime DESC", groupSql, MessageTypePicture,groupSql,MessageTypeFile];
        
        
        NSString *countSql = [NSString stringWithFormat:@"SELECT\n\tcount(1)\nFROM\n\t(\n\t\t%@\n\t)\n",sql];
        
        //判断当前文档数量是否已经到达数量底部
        int count = 0;
        FMResultSet *countRS = [db executeQuery:countSql];
        if ([countRS next]) {
            count = [countRS intForColumnIndex:0];
        }
        [countRS close];
        if(count <= pageOffset + 50){
            *isAtEnd = YES;
        }
        else{
            *isAtEnd = NO;
        }
        sql = [sql stringByAppendingFormat:@"\n\t\tLIMIT 50\n\tOFFSET\n\t%ld\n\t",(long)pageOffset];
        
        
        FMResultSet *recordSet = [db executeQuery:sql];
        while ([recordSet next]) {
            //TODO:把recordSet封装，添加到records中返回
            DLog(@"%@",[recordSet stringForColumnIndex:0]);
            RecordDataModel *record = [[RecordDataModel alloc] init];
            record.msgId = [recordSet stringForColumnIndex:0];
            record.fromUserId = [recordSet stringForColumnIndex:1];
            record.sendTime = [recordSet stringForColumnIndex:2];
            record.msgType = [recordSet intForColumnIndex:3];
            record.msgLen = [recordSet intForColumnIndex:4];
            record.content = [recordSet stringForColumnIndex:5];
            record.status = [recordSet intForColumnIndex:6];
            record.msgDirection = [recordSet intForColumnIndex:7];
            record.msgRequestState = [recordSet intForColumnIndex:8];
            record.nickname = [recordSet stringForColumnIndex:9];
            record.groupId = groupId;
            
            
            NSString *paramString = [recordSet stringForColumnIndex:10];
            if (paramString.length > 0) {
                MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithJSONString:paramString type:record.msgType];
                record.param = param;
            }
            record.strEmojiType = [recordSet stringForColumnIndex:11];
            [records insertObject:record atIndex:0];
            
        }
        
    }];
    
    return records;
}

- (NSArray *)queryAllContentWithGroupId:(NSString *)groupId
                               toUserId:(NSString *)toUserId
                                content:(NSString *)content
                              pageIndex:(NSInteger)pageIndex
                               isAtEnd : (BOOL *)isAtEnd{
    if(groupId.length == 0 && toUserId == 0){
        return [NSMutableArray array];
    }
    
    if(pageIndex < 0)
        pageIndex = 0;
    
    NSInteger pageOffset = pageIndex * 50;
    
    __block NSMutableArray *records = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *groupSql = [NSString stringWithFormat:@"SELECT\n\tmsgId,\n\tfromUserId,\n\tsendTime,\n\tmsgType,\n\tmsgLen,\n\tcontent,\n\tstatus,\n\tdirection,\n\trequestType,\n\tfromUserNickName,\n\tparam\nFROM\n\t%@\nWHERE\n",TABLE_MESSAGE];
        
        NSString *partSQL = nil;
        if(groupId.length > 0){
            partSQL = [NSString stringWithFormat:@"(\t\t\tgroupId = '%@'",groupId];
        }
        else if (toUserId.length > 0){
            partSQL = [NSString stringWithFormat:@"(\t\t\ttoUserId = '%@'",toUserId];
        }
        partSQL = [partSQL stringByAppendingFormat:@" AND content LIKE \'%%%@%%\') \n\nORDER BY\n\tsendTime DESC",content];
        groupSql = [groupSql stringByAppendingString:partSQL];
        
        NSString *sql = [NSString stringWithFormat:@"\n\tSELECT *\n\tFROM\n\t%@\n\tWHERE%@",TABLE_MESSAGE,partSQL];
        
        
        NSString *countSql = [NSString stringWithFormat:@"SELECT\n\tcount(1)\nFROM\n\t(\n\t\t%@\n\t)\n",sql];
        
        //判断当前文档数量是否已经到达数量底部
        int count = 0;
        FMResultSet *countRS = [db executeQuery:countSql];
        if ([countRS next]) {
            count = [countRS intForColumnIndex:0];
        }
        [countRS close];
        if(count <= pageOffset + 50){
            *isAtEnd = YES;
        }
        else{
            *isAtEnd = NO;
        }
        groupSql = [groupSql stringByAppendingFormat:@"\n\t\tLIMIT 50\n\tOFFSET\n\t%ld\n\t",(long)pageOffset];
        
        
        FMResultSet *recordSet = [db executeQuery:groupSql];
        while ([recordSet next]) {
            DLog(@"%@",[recordSet stringForColumnIndex:0]);
            RecordDataModel *record = [[RecordDataModel alloc] init];
            record.msgId = [recordSet stringForColumnIndex:0];
            record.fromUserId = [recordSet stringForColumnIndex:1];
            record.sendTime = [recordSet stringForColumnIndex:2];
            record.msgType = [recordSet intForColumnIndex:3];
            record.msgLen = [recordSet intForColumnIndex:4];
            record.content = [recordSet stringForColumnIndex:5];
            record.status = [recordSet intForColumnIndex:6];
            record.msgDirection = [recordSet intForColumnIndex:7];
            record.nickname = [recordSet stringForColumnIndex:8];
            record.msgRequestState = [recordSet intForColumnIndex:11];
            record.groupId = groupId;
            
            NSString *paramString = [recordSet stringForColumnIndex:10];
            if (paramString.length > 0) {
                MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithJSONString:paramString type:record.msgType];
                record.param = param;
            }
            
            [records insertObject:record atIndex:0];
            
        };
    }];
    return records;
}



- (NSArray *)queryAllPicturesWithGroupId:(NSString *)groupId
                                toUserId:(NSString *)toUserId
                                   msgId:(NSString *)msgId
                                sendTime:(NSString *)sendTime
                                   index:(NSString *__autoreleasing *)index
{
    if (groupId.length == 0 && toUserId.length == 0) {
        return [NSMutableArray array];
    }
    
    __block NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        //查询图片记录和图片文件
        NSString *groupSql = [NSString stringWithFormat:@"(\n\t\tSELECT\n\t\t\tmsgId,\n\t\t\tmsgType,\n\t\t\tparam,\n\t\t\tsendTime,\n\t\t\tisOriginalPic,\n\temojiType,\n\t\t\tmsgLen,\n\t\t\tdirection\n\t\tFROM\n\t\t\t%@\n\t\tWHERE\n",TABLE_MESSAGE];
        if (groupId.length > 0) {
            groupSql = [groupSql stringByAppendingFormat:@"\t\t\tgroupId = '%@'\n", groupId];
        }
        else if (toUserId.length > 0) {
            groupSql = [groupSql stringByAppendingFormat:@"\t\t\ttoUserId = '%@'\n",toUserId];
        }
        groupSql = [groupSql stringByAppendingString:@"    )"];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT\n\tmsgId,\n\tmsgType,\n\tparam,\n\tsendTime,\n\tisOriginalPic,\n\temojiType,\n\tmsgLen,\n\tdirection\nFROM\n\t%@\nWHERE\n\tmsgType = %d\n\nUNION ALL\n\nSELECT\n\tmsgId,\n\tmsgType,\n\tparam,\n\tsendTime,\n\tisOriginalPic,\n\temojiType,\n\tmsgLen,\n\tdirection\nFROM\n\t%@\nWHERE\n\tmsgType = %d\n\tAND (\n\t\tparam LIKE \'%%\"ext\" : \"png\"%%\'\n\t\tOR param LIKE \'%%\"ext\" : \"jpeg\"%%\'\n\t\tOR param LIKE \'%%\"ext\" : \"jpg\"%%\'\n\t\tOR param LIKE \'%%\"ext\" : \"bmp\"%%\'\n\t\tOR param LIKE \'%%\"ext\" : \"gif\"%%\'\n\t)\n\nORDER BY\n\tsendTime DESC",groupSql,MessageTypePicture,groupSql,MessageTypeFile];
        
        NSString *countSql = [NSString stringWithFormat:@"SELECT\n\tcount(1)\nFROM\n\t(\n\t\t%@\n\t)\nWHERE\n\tsendTime >= \'%@\';",sql,sendTime];
        
        //如果当前图片在最新的500张图片之内，则可浏览最新的500张图片；否则只能浏览当前图片
        int max = 500;
        int count = 0;
        FMResultSet *countRS = [db executeQuery:countSql];
        if ([countRS next]) {
            count = [countRS intForColumnIndex:0];
        }
        [countRS close];
        if (count > max) {
            sql = [NSString stringWithFormat:@"SELECT\n\tmsgId,\n\tmsgType,\n\tparam,\n\tsendTime\nFROM\n\t%@\nWHERE\n\tmsgId = \'%@\';",TABLE_MESSAGE,msgId];
        }
        else {
            sql = [NSString stringWithFormat:@"%@\nLIMIT %d;",sql,max];
        }
        
        FMResultSet *rs = [db executeQuery:sql];
        int record_index = 0;
        NSString *record_index_string = nil;
        while ([rs next]) {
            RecordDataModel *record = [[RecordDataModel alloc] init];
            record.msgId = [rs stringForColumnIndex:0];
            //            NSLog(@"%@",[rs stringForColumnIndex:0]);
            
            record.msgType = [rs intForColumnIndex:1];
            record.isOriginalPic = [rs stringForColumn:@"isOriginalPic"];
            record.msgDirection = [rs intForColumn:@"direction"];
            record.msgLen = [rs intForColumn:@"msgLen"];
            record.strEmojiType = [rs stringForColumn:@"emojiType"];
            if([record.strEmojiType isEqualToString:@"original"]){
                continue;
            }
            if (record.msgType == MessageTypeFile) {
                NSString *param = [rs stringForColumnIndex:2];
                if (param.length > 0) {
                    id jsonResult = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    record.param = [[MessageParamDataModel alloc] initWithDictionary:jsonResult type:record.msgType];
                }
            }
            record.groupId = groupId;
            [records insertObject:record atIndex:0];
            
            if (record_index_string == nil && record.msgId.length > 0 && [msgId isEqualToString:record.msgId]) {
                record_index_string = [NSString stringWithFormat:@"%d",record_index];
            }
            record_index ++;
        }
        if (index) {
            *index = [NSString stringWithFormat:@"%lu",[records count] - 1 - [record_index_string intValue]];
        }
        [rs close];
    }];
    
    return  records;
}

- (BOOL)insertRecord:(RecordDataModel *)record toUserId:(NSString *)toUserId needUpdateGroup:(BOOL)needUpdateGroup publicId:(NSString *)publicId
{
    return [self insertRecord:record toUserId:toUserId needUpdateGroup:needUpdateGroup publicId:publicId db:nil];
}

- (void)insertRecords:(NSArray *)records publicId:(NSString *)publicId
{
    
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        __block int recordCount = (int)[records count];
        [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            RecordDataModel *record = (RecordDataModel *)obj;
            //添加这两个字段，为了不影响消息显示
            KDToDoMessageDataModel *todoMsg =(KDToDoMessageDataModel *)obj;
            record.fromUserName = todoMsg.fromUserName;
            record.fromUserPhoto = todoMsg.fromUserPhoto;
            [self insertRecord:record toUserId:@"" needUpdateGroup:idx == recordCount - 1 publicId:publicId db:db];
        }];
        
    }];
}

- (BOOL)insertRecord:(RecordDataModel *)record toUserId:(NSString *)toUserId needUpdateGroup:(BOOL)needUpdateGroup publicId:(NSString *)publicId db:(FMDatabase *)db
{
    if (record == nil)
        return NO;
    
    __block BOOL result = NO;
    //如果存在groupId，则不插入toUserId，否则私人模式和公共模式的数据会混乱
    if (toUserId == nil || record.groupId.length > 0) {
        toUserId = @"";
    }
    NSString *insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (msgId,fromUserId,sendTime,msgType,msgLen,content,status,direction,groupId,toUserId,requestType,fromUserNickName,param,notifyType,notifyDesc,emojiType,important,sourceMsgId,isOriginalPic,fromClientId,fromUserPhoto,fromUserName) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",TABLE_MESSAGE];
    
    NSString *paramString = @"";
    if (record.param) {
        paramString = record.param.paramString;
    }
    NSString *sourceMsgId = @"";
    if (record.sourceMsgId == nil || [record.sourceMsgId isKindOfClass:[NSNull class]] ||record.sourceMsgId.length <= 0)
    {
        NSData *strData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:strData];
        NSArray *list = [dic objectForKey:@"list"];
        NSDictionary *listDic = [list firstObject];
        sourceMsgId = [listDic objectForKey:@"msgid"];
    }
    else
    {
        sourceMsgId = record.sourceMsgId;
    }
    
    // 处理@提及的已读未读
    //    if (record.iNotifyType != 0)
    //    {
    //        record.status = MessageStatusUnread;
    //    }
    
    if (db != nil) {
        
        result = [db executeUpdate:insert,record.msgId,record.fromUserId,record.sendTime,[NSNumber numberWithInt:record.msgType],[NSNumber numberWithInt:record.msgLen],record.content,[NSNumber numberWithInt:record.status],[NSNumber numberWithInt:record.msgDirection],record.groupId,toUserId,[NSNumber numberWithInt:record.msgRequestState],record.nickname,paramString,[NSNumber numberWithInt:record.iNotifyType],record.strNotifyDesc, record.strEmojiType, @(record.bImportant), record.sourceMsgId,record.isOriginalPic,record.fromClientId,record.fromUserPhoto,record.fromUserName];
    } else {
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            
#if DEBUG
            db.logsErrors = YES;
#endif
            
            result = [db executeUpdate:insert,record.msgId,record.fromUserId,record.sendTime,[NSNumber numberWithInt:record.msgType],[NSNumber numberWithInt:record.msgLen],record.content,[NSNumber numberWithInt:record.status],[NSNumber numberWithInt:record.msgDirection],record.groupId,toUserId,[NSNumber numberWithInt:record.msgRequestState],record.nickname,paramString,[NSNumber numberWithInt:record.iNotifyType],record.strNotifyDesc, record.strEmojiType, @(record.bImportant), record.sourceMsgId,record.isOriginalPic,record.fromClientId,record.fromUserPhoto,record.fromUserName];
        }];
    }
    
    if (needUpdateGroup && record.msgId.length > 0 && record.sendTime.length > 0 && record.groupId.length > 0) {
        NSString *update = [NSString stringWithFormat:@"Update %@ Set lastMsgId = ?,lastMsgSendTime = ? Where groupId = ?;",publicId == nil ? TABLE_GROUP : TABLE_PUBLIC_GROUP];
        if (db != nil) {
            result = result && [db executeUpdate:update,record.msgId,record.sendTime,record.groupId];
        } else {
            [self.databaseQueue inDatabase:^(FMDatabase *db) {
                
#if DEBUG
                db.logsErrors = YES;
#endif
                
                result = result && [db executeUpdate:update,record.msgId,record.sendTime,record.groupId];
            }];
        }
    }
    
    return result;
}

- (BOOL)deleteRecordWithMsgId:(NSString *)msgId
{
    if (msgId.length == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSArray *msgIdArray = [msgId componentsSeparatedByString:@","];
        NSMutableString *msgIdsStr = [[NSMutableString alloc] init];
        for(NSInteger i = 0;i<msgIdArray.count;i++)
        {
            NSString *msg = msgIdArray[i];
            if(msg.length == 0)
                continue;
            [msgIdsStr appendFormat:@"'%@'",msgIdArray[i]];
            if(i!=msgIdArray.count-1)
                [msgIdsStr appendString:@","];
        }
        if(msgIdsStr.length > 0)
        {
            NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM %@ Where msgId in (%@);", TABLE_MESSAGE, msgIdsStr];
            result = [db executeUpdate:sqlStr];
        }
        
    }];
    
    return result;
}

-(NSDictionary *)queryMsgDicWithMsgId:(NSString *)msgId
{
    if (msgId.length == 0) {
        return nil;
    }
    
    NSMutableDictionary *msgDic = [NSMutableDictionary dictionary];
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ Where msgId = ?",TABLE_MESSAGE];
        FMResultSet *resultSet = [db executeQuery:sql,msgId];
        while ([resultSet next]) {
            NSDictionary *dic = [resultSet resultDictionary];
            [msgDic setObject:[dic objectForKey:@"fromClientId"] forKey:@"clientMsgId"];
            [msgDic setObject:[dic objectForKey:@"content"] forKey:@"content"];
            [msgDic setObject:[dic objectForKey:@"direction"] forKey:@"direction"];
            [msgDic setObject:@"null" forKey:@"fileKey"];
            [msgDic setObject:[dic objectForKey:@"fromClientId"] forKey:@"fromClientId"];
            [msgDic setObject:[dic objectForKey:@"fromUserId"] forKey:@"fromUserId"];
            [msgDic setObject:[dic objectForKey:@"isOriginalPic"] forKey:@"isOriginalPic"];
            [msgDic setObject:[dic objectForKey:@"msgId"] forKey:@"msgId"];
            [msgDic setObject:[dic objectForKey:@"msgLen"] forKey:@"msgLen"];
            [msgDic setObject:[dic objectForKey:@"msgType"] forKey:@"msgType"];
            [msgDic setObject:[dic objectForKey:@"fromUserNickName"] forKey:@"nickname"];
            NSString *param = [dic objectForKey:@"param"];
            id paramObj = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            [msgDic setObject:paramObj?paramObj:@"" forKey:@"param"];
            [msgDic setObject:[dic objectForKey:@"sendTime"] forKey:@"sendTime"];
            [msgDic setObject:[dic objectForKey:@"sourceMsgId"] forKey:@"sourceMsgId"];
            [msgDic setObject:[dic objectForKey:@"status"] forKey:@"status"];
            [msgDic setObject:@"null" forKey:@"todoStatus"];
            break;
        }
    }];
    
    return msgDic;
}

- (BOOL)deleteRecordsWithGroupId:(NSString *)groupId
{
    if (groupId.length == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ Where groupId = ?;",TABLE_MESSAGE],groupId];
    }];
    
    return result;
}

- (BOOL)updateAllRecordsToReadWithGroup:(GroupDataModel *)group
{
    if (group.groupId.length == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *update = [NSString stringWithFormat:@"UPDATE %@ SET status = ? WHERE groupId = ?;",TABLE_MESSAGE];
        result = [db executeUpdate:update,[NSNumber numberWithInt:MessageStatusRead],group.groupId];
        
        //更新未读数
        result = result && [self updateGroupListWithUnreadCount:0 withGroupId:group.groupId withPublicId:nil db:db];
    }];
    
    return result;
}

- (BOOL)updateNotifyRecordStatusWithMsgId:(NSString *)msgId groupId:(NSString *)groupId
{
    if (msgId.length == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *update = [NSString stringWithFormat:@"UPDATE %@ SET status = ? WHERE msgId = ?;",TABLE_MESSAGE];
        result = [db executeUpdate:update,[NSNumber numberWithInt:MessageStatusRead],msgId];
        
        
        
        
    }];
    
    [self updateNotifyToEmptyWithGroupId:groupId];
    
    return result;
}

- (NSArray *)queryFilesWithLikeName:(NSString *)name {
    __block NSMutableArray *files = [[NSMutableArray alloc] init];
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString * sql = [NSString stringWithFormat:@"SELECT\n\ta.param,\n\ta.sendTime,\n\tb.personName,\n\ta.msgId,\n\ta.groupId,\n\tb.wbUserId\nFROM\n\t%@ a\nLEFT JOIN %@ b\nWHERE\n\tmsgType = ?\nAND content LIKE ?\nAND a.fromUserId = b.personId\nORDER BY\n\tsendTime DESC;", TABLE_MESSAGE, TABLE_T9_PERSON];
        
        FMResultSet *rs = [db executeQuery:sql, [NSNumber numberWithInt:MessageTypeFile], [NSString stringWithFormat:@"%%%@%%", name]];
        while ([rs next]) {
            NSString *param = [rs stringForColumnIndex:0];
            if (param.length > 0) {
                id jsonObject = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding]];
                if (jsonObject && [jsonObject isKindOfClass:[NSDictionary class]]) {
                    MessageFileDataModel *file = [[MessageFileDataModel alloc] initWithDictionary:jsonObject];
                    
                    NSRange range = [[file.name lowercaseString] rangeOfString:name.lowercaseString];
                    if (range.location != NSNotFound) {
                        file.highlightName = [file.name stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"<font color=\"#06A3EC\">%@</font>", [file.name substringWithRange:range]]];
                    }
                    
                    file.fileSendTime = [rs stringForColumnIndex:1];
                    file.fileSendPersonName = [rs stringForColumnIndex:2];
                    file.msgId = [rs stringForColumnIndex:3];
                    file.groupId = [rs stringForColumnIndex:4];
                    file.wbUserId = [rs stringForColumnIndex:5];
                    [files addObject:file];
                }
            }
        }
        [rs close];
    }];
    
    return files;
}


#pragma mark - Personal App

//- (BOOL)insertPersonalApp:(id)appDM withAppType:(int)appType
//{
//    if (appDM == nil) {
//        return NO;
//    }
//    MFAppDataModel *appDataModel = nil;
//    MFWebAppDataModel *webAppDataModel = nil;
//    __block BOOL result = NO;
//    if (appType == 1 || appType == 3 || appType == 4) {
//        appDataModel = [[MFAppDataModel alloc] initWithDictionary:appDM];
//
//        [self.databaseQueue inDatabase:^(FMDatabase *db) {
//
//#if DEBUG
//            db.logsErrors = YES;
//#endif
//
//            NSString *deleteApps = [NSString stringWithFormat:@"DELETE FROM %@ WHERE appClientId = ?;",TABLE_PERSONAL_APP];
//            result = [db executeUpdate:deleteApps, appDataModel.appClientID];
//            NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ (appClientId, appType, appName, appLogo, appClientSchema, appWebURL, appDldURL) VALUES (?,?,?,?,?,?,?);",TABLE_PERSONAL_APP];
//            NSString *strType = [NSString stringWithFormat:@"%d", appDataModel.appType];
//            result = result && [db executeUpdate:insert, appDataModel.appClientID, strType, appDataModel.appName, appDataModel.appLogo, appDataModel.appClientSchema, @"", appDataModel.appDldURL];
//        }];
//
//    } else if (appType == 2) {
//        webAppDataModel = [[MFWebAppDataModel alloc] initWithDictionary:appDM];
//
//        [self.databaseQueue inDatabase:^(FMDatabase *db) {
//
//#if DEBUG
//            db.logsErrors = YES;
//#endif
//            NSString *deleteApps = [NSString stringWithFormat:@"DELETE FROM %@ WHERE appClientId = ?;",TABLE_PERSONAL_APP];
//            result = [db executeUpdate:deleteApps, webAppDataModel.appClientID];
//            NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ (appClientId, appType, appName, appLogo, appWebURL, appDldURL) VALUES (?,?,?,?,?,?);",TABLE_PERSONAL_APP];
//            NSString *strType = [NSString stringWithFormat:@"%d", webAppDataModel.appType];
//            result = result && [db executeUpdate:insert, webAppDataModel.appClientID, strType, webAppDataModel.appName, webAppDataModel.appLogo, webAppDataModel.webURL, @""];
//        }];
//
//    } else {
//        return NO;
//    }
//
//    return result;
//}

//- (BOOL)insertPersonalApp2:(id)appDM withAppType:(int)appType
//{
//    if (appDM == nil) {
//        return NO;
//    }
//    MFAppDataModel *appDataModel = appDM;
//    MFWebAppDataModel *webAppDataModel = appDM;
//    __block BOOL result = NO;
//    if (appType == 1 || appType == 3 || appType == 4) {
//        //        appDataModel = [[MFAppDataModel alloc] initWithDictionary:appDM];
//        [self.databaseQueue inDatabase:^(FMDatabase *db) {
//
//#if DEBUG
//            db.logsErrors = YES;
//#endif
//
//            NSString *deleteApps = [NSString stringWithFormat:@"DELETE FROM %@ WHERE appClientId = ?;",TABLE_PERSONAL_APP];
//            result = [db executeUpdate:deleteApps, appDataModel.appClientID];
//            NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ (appClientId, appType, appName, appLogo, appClientSchema, appWebURL, appDldURL) VALUES (?,?,?,?,?,?,?);",TABLE_PERSONAL_APP];
//            NSString *strType = [NSString stringWithFormat:@"%d", appDataModel.appType];
//            result = result && [db executeUpdate:insert, appDataModel.appClientID, strType, appDataModel.appName, appDataModel.appLogo, appDataModel.appClientSchema, @"", appDataModel.appDldURL];
//        }];
//
//    } else if (appType == 2) {
//        //        webAppDataModel = [[MFWebAppDataModel alloc] initWithDictionary:appDM];
//
//        [self.databaseQueue inDatabase:^(FMDatabase *db) {
//
//#if DEBUG
//            db.logsErrors = YES;
//#endif
//            NSString *deleteApps = [NSString stringWithFormat:@"DELETE FROM %@ WHERE appClientId = ?;",TABLE_PERSONAL_APP];
//            result = [db executeUpdate:deleteApps, webAppDataModel.appClientID];
//            NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ (appClientId, appType, appName, appLogo, appWebURL, appDldURL) VALUES (?,?,?,?,?,?);",TABLE_PERSONAL_APP];
//            NSString *strType = [NSString stringWithFormat:@"%d", webAppDataModel.appType];
//            result = result && [db executeUpdate:insert, webAppDataModel.appClientID, strType, webAppDataModel.appName, webAppDataModel.appLogo, webAppDataModel.webURL, @""];
//        }];
//
//    } else {
//        return NO;
//    }
//
//    return result;
//}

- (BOOL)insertPersonalAppDataModel:(KDAppDataModel * )appDM{
    if (appDM == nil) {
        return NO;
    }
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *deleteApps = [NSString stringWithFormat:@"DELETE FROM %@ WHERE appClientId = ?;",TABLE_PERSONAL_APP];
        result = [db executeUpdate:deleteApps, appDM.appClientID];
        
        NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ (appClientId, appType, appName, appLogo, appClientSchema, appWebURL, appDldURL, pid, deleteAble, FIOSLaunchParams,appClasses) VALUES (?,?,?,?,?,?,?,?,?,?,?);",TABLE_PERSONAL_APP];
        NSString *strType = [NSString stringWithFormat:@"%d", appDM.appType];
        NSString *appClasses = @"";
        if(appDM.appClasses.count > 0)
            appClasses = appDM.appClasses.firstObject;
        if (appDM.appType == KDAppTypePublic) {
            result = result && [db executeUpdate:insert, appDM.pid, strType, appDM.appName, appDM.appLogo, appDM.appClientSchema, (appDM.webURL == nil ? @"":appDM.webURL), appDM.downloadURL, appDM.pid, appDM.deleteAble, appDM.FIOSLaunchParams,appClasses];
        }
        else{
            result = result && [db executeUpdate:insert, appDM.appClientID, strType, appDM.appName, appDM.appLogo, appDM.appClientSchema, (appDM.webURL == nil ? @"":appDM.webURL), appDM.downloadURL, appDM.pid, appDM.deleteAble, appDM.FIOSLaunchParams,appClasses];
        }
    }];
    return result;
    
}

-(BOOL)deleteAllPersonApps
{
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        //暂时先屏蔽删除本地原生应用
        NSString *deleteApps = [NSString stringWithFormat:@"DELETE FROM %@ ;",TABLE_PERSONAL_APP];
        result = [db executeUpdate:deleteApps];
    }];
    
    return result;
}


- (BOOL)deletePersonalApp:(NSString *)appId
{
    if ([appId length] == 0) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *deleteApps = [NSString stringWithFormat:@"DELETE FROM %@ WHERE appClientId = ?;",TABLE_PERSONAL_APP];
        result = [db executeUpdate:deleteApps,appId];
    }];
    
    return result;
}


- (NSArray *)queryPersonalAppsID
{
    NSMutableArray *appIds = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT appClientId FROM %@;",TABLE_PERSONAL_APP];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *appId = [NSString stringWithFormat:@"%@", [rs stringForColumnIndex:0]];
            [appIds addObject:appId];
        }
        [rs close];
        
    }];
    
    return appIds;
}


- (NSArray *)queryPersonalApps
{
    NSMutableArray *appArr = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db)
     {
         
#if DEBUG
         db.logsErrors = YES;
#endif
         
         NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@;",TABLE_PERSONAL_APP];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) {
             NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:6];
             if([rs stringForColumnIndex:0])
             {
                 [dic setObject:[rs stringForColumnIndex:0] forKey:@"appClientId"];
             }
             if([rs stringForColumnIndex:1])
             {
                 [dic setObject:[rs stringForColumnIndex:1] forKey:@"appType"];
             }
             if([rs stringForColumnIndex:2])
             {
                 [dic setObject:[rs stringForColumnIndex:2] forKey:@"appName"];
             }
             if([rs stringForColumnIndex:3])
             {
                 [dic setObject:[rs stringForColumnIndex:3] forKey:@"appLogo"];
             }
             else
             {
                 [dic setObject:@"" forKey:@"appLogo"];
             }
             if([rs stringForColumnIndex:4])
             {
                 [dic setObject:[rs stringForColumnIndex:4] forKey:@"appClientSchema"];
             }
             if([rs stringForColumnIndex:5])
             {
                 [dic setObject:[rs stringForColumnIndex:5] forKey:@"webURL"];
             }
             if([rs stringForColumnIndex:6])
             {
                 [dic setObject:[rs stringForColumnIndex:6] forKey:@"downloadURL"];
             }
             
             if([rs stringForColumn:@"appClasses"])
             {
                 [dic setObject:@[[rs stringForColumn:@"appClasses"]] forKey:@"appClasses"];
             }
             [appArr addObject:dic];
         }
         [rs close];
         
     }];
    
    return appArr;
}


- (NSArray *)queryPersonalAppList{
    NSMutableArray *appArr = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db)
     {
         
#if DEBUG
         db.logsErrors = YES;
#endif
         
         NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@;",TABLE_PERSONAL_APP];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) {
             KDAppDataModel * appDM = [[KDAppDataModel alloc]init];
             if([rs stringForColumnIndex:1])
             {
                 appDM.appType = [[rs stringForColumnIndex:1] intValue];
                 
             }
             if (appDM.appType == KDAppTypePublic) {
                 //如果是公共号应用，主键是pid，否则是appClientId
                 if([rs stringForColumnIndex:0])
                 {
                     appDM.pid = [rs stringForColumnIndex:0];
                 }
             }
             else{
                 if([rs stringForColumnIndex:0])
                 {
                     appDM.appClientID = [rs stringForColumnIndex:0];
                 }
             }
             if([rs stringForColumnIndex:2])
             {
                 appDM.appName = [rs stringForColumnIndex:2];
             }
             if([rs stringForColumnIndex:3])
             {
                 appDM.appLogo = [rs stringForColumnIndex:3] ;
             }
             if([rs stringForColumnIndex:4])
             {
                 appDM.appClientSchema = [rs stringForColumnIndex:4];
             }
             if([rs stringForColumnIndex:5])
             {
                 appDM.webURL = [rs stringForColumnIndex:5];
             }
             if([rs stringForColumnIndex:6])
             {
                 appDM.downloadURL = [rs stringForColumnIndex:6];
             }
             if ([rs stringForColumnIndex:7]) {
                 appDM.pid = [rs stringForColumnIndex:7];
             }
             if ([rs stringForColumnIndex:8]) {
                 appDM.deleteAble = [rs stringForColumnIndex:8];
             }
             if ([rs stringForColumnIndex:9]) {
                 appDM.FIOSLaunchParams = [rs stringForColumnIndex:9];
             }
             if([rs stringForColumn:@"appClasses"])
             {
                 appDM.appClasses = @[[rs stringForColumn:@"appClasses"]];
             }
             [appArr addObject:appDM];
         }
         [rs close];
         
     }];
    
    return appArr;
}

- (NSArray *)queryAllUsers
{
    NSMutableArray *users = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id,fullPinyin,personId FROM %@ \
                         Where (personId not like 'XT-%%' And personId not like 'EXT_%%') And status > 0 And fullPinyin is not null;",TABLE_T9_PERSON];
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            T9SearchPerson *user = [[T9SearchPerson alloc] init];
            user.userId = [rs intForColumnIndex:0];
            [user setFullPinyin:[rs stringForColumnIndex:1]];
            user.personId = [rs stringForColumnIndex:2];
            [users addObject:user];
        }
        [rs close];
    }];
    
    return users;
}

-  (NSArray *)queryUsersWithPhoneNumber:(NSString *)phoneNumber
{
    NSMutableArray *users = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"Select id,defaultPhone from %@ \
                         Where defaultPhone like '%%%@%%' And (personId not like 'XT-%%' And personId not like 'EXT_%%') And status > 0;",TABLE_T9_PERSON,phoneNumber];
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            int userId = [rs intForColumnIndex:0];
            NSString *defaultPhone = [rs stringForColumnIndex:1];
            NSRange phoneRange = [defaultPhone rangeOfString:phoneNumber];
            int weight = 1;
            if (phoneRange.length > 6) {
                weight = (phoneRange.length*1.0/defaultPhone.length)*10000;
            }
            T9SearchResult *user = [[T9SearchResult alloc] initWithUserId:userId matchLength:[NSArray arrayWithObjects:[NSNumber numberWithInt:(int)phoneRange.location],[NSNumber numberWithInt:(int)phoneRange.location+(int)phoneRange.length], nil] weight:weight type:T9ResultTypePhoneNumber];
            [users addObject:user];
        }
        [rs close];
    }];
    
    return users;
}

- (NSArray *)queryUsersWithName:(NSString *)name
{
    NSMutableArray *users = [NSMutableArray array];
    if (name == nil) {
        return users;
    }
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString * username = name;
        username = [username stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *sql = [NSString stringWithFormat:@"SELECT id,personName FROM %@ Where personName like '%%%@%%' And (personId not like 'XT-%%' And personId not like 'EXT_%%') And status > 0;",TABLE_T9_PERSON,username];
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            int userId = [rs intForColumnIndex:0];
            NSString *personName = [rs stringForColumnIndex:1];
            NSRange nameRange = [personName rangeOfString:username options:NSCaseInsensitiveSearch];
            int weight = (nameRange.length*1.0/personName.length)*10000;
            if (nameRange.location == 0) {
                weight += 10;
            }
            T9SearchResult *user = [[T9SearchResult alloc] initWithUserId:userId matchLength:[NSArray arrayWithObjects:[NSNumber numberWithInt:(int)nameRange.location],[NSNumber numberWithInt:(int)(nameRange.location+nameRange.length)], nil] weight:weight type:T9ResultTypeHanzi];
            [users addObject:user];
        }
        [rs close];
    }];
    
    return users;
}

- (PersonSimpleDataModel *)queryPersonWithResult:(T9SearchResult *)searchResult
{
    __block PersonSimpleDataModel *person = nil;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin,photoUrl,status,department,jobTitle,wbUserId,isAdmin,subscribe,canUnsubscribe,note,reply,menu,share,partnerType,oid,orgId,gender FROM %@ Where id = ?;",TABLE_T9_PERSON];
        
        
        FMResultSet *rs = [db executeQuery:sql,[NSNumber numberWithInt:searchResult.userId]];
        if ([rs next]) {
            
            person = [[PersonSimpleDataModel alloc] init];
            [person setUserId:[rs intForColumnIndex:0]];
            [person setPersonId:[rs stringForColumnIndex:1]];
            [person setPersonName:[rs stringForColumnIndex:2]];
            [person setDefaultPhone:[rs stringForColumnIndex:3]];
            [person setFullPinyin:[rs stringForColumnIndex:4]];
            [person setPhotoUrl:[rs stringForColumnIndex:5]];
            [person setStatus:[rs intForColumnIndex:6]];
            [person setDepartment:[rs stringForColumnIndex:7]];
            [person setJobTitle:[rs stringForColumnIndex:8]];
            [person setWbUserId:[rs stringForColumnIndex:9]];
            [person setIsAdmin:([rs intForColumnIndex:10] == 1)];
            [person setHighlightName:[searchResult calcHighlightName:person.personName]];
            [person setHighlightDefaultPhone:[searchResult calcHighlightPhone:person.defaultPhone]];
            [person setHighlightFullPinyin:[searchResult calcHighlightPinYin:person.fullPinyin]];
            person.subscribe = [rs stringForColumnIndex:11];
            person.canUnsubscribe = [rs stringForColumnIndex:12];
            person.note = [rs stringForColumnIndex:13];
            person.reply = [rs stringForColumnIndex:14];
            person.menu = [rs stringForColumnIndex:15];
            person.share = [rs intForColumnIndex:16];
            person.partnerType = [rs intForColumnIndex:17];
            person.oid = [rs stringForColumn:@"oid"];
            person.orgId = [rs stringForColumn:@"orgId"];
            person.gender = [rs intForColumn:@"gender"];
        }
        [rs close];
    }];
    
    return person;
}

//此返回有participant
- (NSArray *)queryPrivateGroupListWithLimit:(int)limit offset:(int)offset fold:(BOOL)fold
{
    NSMutableArray *groups = [NSMutableArray array];
    NSMutableArray *groupIds = [NSMutableArray array];
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        
        //查询所有的会话记录，包括它的最后一条消息
        
        
        NSString * sql = @"SELECT\n\t*\n";
        sql = [sql stringByAppendingFormat:@"FROM %@\n", TABLE_GROUP];
        sql = [sql stringByAppendingString:@"Where\n"];
        if (fold) {
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"fold = \'%d\' and groupType >= \'%d\'\n", 1, GroupTypePublic]];
        }
        else {
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"(( fold = \'%d\' and groupType >= \'%d\' ) or groupType < \'%d\' )\n", 0, GroupTypePublic, GroupTypePublic]];
        }
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@"AND showInTimeline = 1 AND groupType != \'%d\'\n",GroupTypeTodo]];
        sql = [sql stringByAppendingString:@"Order by ((status >> 2) & 1) DESC, lastMsgSendTime Desc\n"];
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@"LIMIT %d OFFSET %lu;", limit, (unsigned long)offset]];
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            GroupDataModel *group = [[GroupDataModel alloc] init];
            
            group.groupId = [rs stringForColumn:@"groupId"];
            group.groupType = [rs intForColumn:@"groupType"];
            group.groupName = [rs stringForColumn:@"groupName"];
            group.unreadCount = [rs intForColumn:@"unreadCount"];
            group.partnerType = [rs intForColumn:@"partnerType"];
            
            //last message
            NSString *msgId = [rs stringForColumn:@"lastMsgId"];
            group.lastMsgSendTime = [rs stringForColumn:@"lastMsgSendTime"];
            
            
            group.updateTime = [rs stringForColumn:@"updateTime"];
            group.status = [rs intForColumn:@"Status"];
            group.fold = [rs intForColumn:@"fold"];
            group.headerUrl = [rs stringForColumn:@"headerUrl"];
            group.draft = [rs stringForColumn:@"draft"];
            group.mCallStatus = [rs intForColumn:@"mCallStatus"];
            group.micDisable = [rs stringForColumn:@"micDisable"];
            group.lastMsgDesc = [rs stringForColumn:@"lastMsgDesc"];
            group.localUpdateScore = [[rs stringForColumn:@"localUpdateScore"] integerValue];
            group.updateScore = [[rs stringForColumn:@"updateScore"] integerValue];
            group.userCount = [[rs stringForColumn:@"userCount"] integerValue];
            //            group.lastMsg.todoStatus = [rs stringForColumn:@"todoStatus"];
            [groups addObject:group];
            [groupIds addObject:group.groupId];
            
            NSString *param = [rs stringForColumn:@"param"];
            if (param) {
                group.param = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            }
            NSString *participantIds = [rs stringForColumn:@"participantIds"];
            if (participantIds) {
                group.participantIds = [NSJSONSerialization JSONObjectWithData:[participantIds dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            }
            NSString *managerIds = [rs stringForColumn:@"managerIds"];
            if (managerIds) {
                group.managerIds = [NSJSONSerialization JSONObjectWithData:[managerIds dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            }
        }
        [rs close];
    }];
    //参与人 personId 列表
    NSMutableDictionary *paticipants = [[NSMutableDictionary alloc] initWithDictionary:[self loadPaticipantIds:groupIds]];
    NSMutableSet *personIds = [[NSMutableSet alloc] init];
    for (id paticipant in [paticipants allValues]) {
        if ([paticipant isKindOfClass:[NSArray class]] && [(NSArray *)paticipant count] > 0) {
            [personIds addObjectsFromArray:paticipant];
        }
    }
    NSDictionary *persons = [[NSDictionary alloc] initWithDictionary:[self loadPersons:[personIds allObjects]]];
    
    int count = 0;
    for (GroupDataModel *group in groups) {
        count += group.unreadCount;
        NSArray *paticipantIds = [paticipants objectForKey:group.groupId];
        if ([paticipantIds isKindOfClass:[NSArray class]]&&[paticipantIds count] > 0) {
            for (NSString *paticipantId in paticipantIds) {
                PersonSimpleDataModel *person = [persons objectForKey:paticipantId];
                if (fold) {
                    PersonSimpleDataModel *pubPerson = [self queryPublicAccountWithId:person.personId];
                    person.remind = pubPerson.remind;
                    person.state = pubPerson.state;
                    person.reply = pubPerson.reply;
                    person.share = pubPerson.share;
                    person.hisNews = pubPerson.hisNews;
                }
                if (person != nil) {
                    //防止公共号参与人不是第一个，
                    if ([person.personId hasPrefix:@"XT-"]) {
                        [group.participant insertObject:person atIndex:0];
                    }else
                    {
                        [group.participant addObject:person];
                    }
                }
            }
        }
        
    }
    return groups;
}

- (PersonSimpleDataModel *)loadPersonWithResultSet:(FMResultSet *)rs {
    PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
    person.userId = [rs intForColumn:@"id"];
    person.personId = [rs stringForColumn:@"personId"];
    person.personName = [rs stringForColumn:@"personName"];
    person.defaultPhone = [rs stringForColumn:@"defaultPhone"];
    person.fullPinyin = [rs stringForColumn:@"fullPinyin"];
    person.photoUrl = [rs stringForColumn:@"photoUrl"];
    person.status = [rs intForColumn:@"status"];
    person.department = [rs stringForColumn:@"department"];
    person.jobTitle = [rs stringForColumn:@"jobTitle"];
    person.wbUserId = [rs stringForColumn:@"wbUserId"];
    person.isAdmin = [rs boolForColumn:@"isAdmin"];
    person.eid = [rs stringForColumn:@"eid"];
    person.oid = [rs stringForColumn:@"oid"];
    person.partnerType = [rs stringForColumn:@"partnerType"];
    person.gender = [rs intForColumn:@"gender"];
    return person;
}

- (NSArray *)queryPrivateGroupListWithLimit:(int)limit offset:(int)offset
{
    return [self queryPrivateGroupListWithLimit:limit offset:offset fold:NO];
}

- (NSArray *)queryFoldPublicGroupListWithLimit:(int)limit offset:(int)offset
{
    return [self queryPrivateGroupListWithLimit:limit offset:offset fold:YES];
}

- (FoldPublicDataModel *)queryFoldPublicModel
{
    NSMutableString *sql = [@"SELECT unreadCount, latestMessage, latestMessageTime, groupName FROM " mutableCopy];
    
    [sql appendFormat:@"(\nSELECT\n\tsum(unreadCount) AS unreadCount\nFROM\n\t%@ \nWHERE\n\tfold = \'%d\'\n\tAND groupType >= \'%d\'\n),", TABLE_GROUP, 1, GroupTypePublic];
    
    //    [sql appendString:[NSString stringWithFormat:@" (SELECT b.lastMsgDesc AS latestMessage, b.msgType AS latestMessageType, b.sendTime AS latestMessageTime, a.groupName AS groupName FROM %@ a LEFT JOIN %@ b ON a.lastMsgId = b.msgId ", TABLE_GROUP, TABLE_MESSAGE]];
    [sql appendString:[NSString stringWithFormat:@" (SELECT lastMsgDesc AS latestMessage, lastMsgSendTime AS latestMessageTime, groupName AS groupName FROM %@ ", TABLE_GROUP]];
    
    [sql appendString:[NSString stringWithFormat:@" WHERE fold = '%d' AND groupType >= '%d' AND showInTimeline = 1", 1, GroupTypePublic]];
    [sql appendString:@" ORDER BY lastMsgSendTime DESC LIMIT 1);"];
    
    //     NSString *sql = [NSString stringWithFormat:@"SELECT\n\tunreadCount,\n\tlatestMessage,\n\tlatestMessageTime,\n\tgroupName\nFROM\n\t(\n\t\tSELECT\n\t\t\tsum(unreadCount) AS unreadCount\n\t\tFROM\n\t\t\t%@\n\t\tWHERE\n\t\t\tfold = ?\n\t\tAND groupType >= ?\n\t\tAND showInTimeline = 1\n\t),\n\t(\n\t\tSELECT\n\t\t\tlastMsgDesc AS latestMessage,\n\t\t\tlastMsgSendTime AS latestMessageTime,\n\t\t\tgroupName AS groupName\n\t\tFROM\n\t\t\t%@\n\t\tWHERE\n\t\t\tfold = ?\n\t\tAND groupType >= ?\n\t\tAND showInTimeline = 1\n\t\tORDER BY\n\t\t\tlastMsgSendTime DESC\n\t\tLIMIT 1\n\t);",TABLE_GROUP,TABLE_GROUP];
    __block FoldPublicDataModel *model = nil;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        FMResultSet *rs = [db executeQuery:sql];
        if ([rs next]) {
            model = [[FoldPublicDataModel alloc] init];
            model.unreadCount = [rs intForColumn:@"unreadCount"] > 0 ? [rs intForColumn:@"unreadCount"] : 0;
            model.latestMessage = [rs stringForColumn:@"latestMessage"];
            //            model.latestMessageType = [rs intForColumn:@"latestMessageType"];
            model.latestMessageTime = [rs stringForColumn:@"latestMessageTime"];
            model.groupName = [rs stringForColumn:@"groupName"];
        }
        [rs close];
    }];
    return model;
}

- (BOOL)deleteAllFoldPublicGroup
{
    __block BOOL flag = YES;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *groupSql = [NSString stringWithFormat:@"Update %@ Set showInTimeline = 0 where groupType >= '%d' and fold = '%d'", TABLE_GROUP, GroupTypePublic, 1];
        flag = [db executeUpdate:groupSql];
    }];
    
    return flag;
}

- (NSUInteger)queryXTTimelineUnreadCount
{
    __block int count = 0;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT\n\tsum(unreadCount)\nFROM\n\t%@\nWHERE showInTimeline = 1;", TABLE_GROUP];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        FMResultSet *rs = [db executeQuery:sql];
        if ([rs next]) {
            count = [rs intForColumnIndex:0] > 0 ? [rs intForColumnIndex:0] : 0;
        }
        [rs close];
    }];
    return count;
    
}

- (GroupDataModel *)loadGroupWithResultSet:(FMResultSet *)rs {
    
    GroupDataModel *group = [[GroupDataModel alloc] init];
    
    group.groupId = [rs stringForColumn:@"groupId"];
    group.groupType = [rs intForColumn:@"groupType"];
    group.groupName = [rs stringForColumn:@"groupName"];
    group.unreadCount = [rs intForColumn:@"unreadCount"];
    group.partnerType = [rs intForColumn:@"partnerType"];
    
    group.lastMsgId = [rs stringForColumn:@"lastMsgId"];
    group.lastMsgSendTime = [rs stringForColumn:@"lastMsgSendTime"];
    //last message
    //    NSString *msgId = [rs stringForColumn:@"lastMsgId"];
    //    if (msgId.length > 0) {
    //        RecordDataModel *record = [[RecordDataModel alloc] init];
    //        record.msgId = msgId;
    //        record.fromUserId = [rs stringForColumn:@"fromUserId"];
    //        record.sendTime = [rs stringForColumn:@"lastMsgSendTime"];
    //        record.msgType = [rs intForColumn:@"msgType"];
    //        record.msgLen = [rs intForColumn:@"msgLen"];
    //        record.content = [rs stringForColumn:@"content"];
    //        record.status = [rs intForColumn:@"bStatus"];
    //        record.msgDirection = [rs intForColumn:@"direction"];
    //        record.msgRequestState =  [rs intForColumn:@"requestType"];
    //        record.nickname = [rs stringForColumn:@"fromUserNickName"];
    //        record.groupId = group.groupId;
    //
    //        group.lastMsg = record;
    //        group.lastMsgId = record.msgId;
    //        group.lastMsgSendTime = record.sendTime;
    //    }
    
    group.updateTime = [rs stringForColumn:@"updateTime"];
    group.status = [rs intForColumn:@"Status"];
    group.fold = [rs intForColumn:@"fold"];
    group.headerUrl = [rs stringForColumn:@"headerUrl"];
    group.draft = [rs stringForColumn:@"draft"];
    //    [groups addObject:group];
    //    [groupIds addObject:group.groupId];
    
    NSString *param = [rs stringForColumn:@"param"];
    if (param) {
        group.param = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    }
    NSString *participantIds = [rs stringForColumn:@"participantIds"];
    if (participantIds) {
        NSArray *tempParticipantIds = [NSJSONSerialization JSONObjectWithData:[participantIds dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if (tempParticipantIds && [tempParticipantIds isKindOfClass:[NSArray class]]) {
            group.participantIds = [NSMutableArray arrayWithArray:tempParticipantIds];
        }
    }
    group.mCallStatus = [rs intForColumn:@"mCallStatus"];
    group.micDisable = [rs intForColumn:@"micDisable"];
    group.lastMsgDesc = [rs stringForColumn:@"lastMsgDesc"];
    //针对代办通知，其他普通会话组消息没啥用
    group.lastMsg.todoStatus =[rs stringForColumn:@"todoStatus"];
    group.localUpdateScore = [[rs stringForColumn:@"localUpdateScore"] integerValue];
    group.updateScore = [[rs stringForColumn:@"updateScore"] integerValue];
    group.userCount = [[rs stringForColumn:@"userCount"] integerValue];
    //    NSString *participantIds = [rs stringForColumn:@"participantIds"];
    //    if (participantIds) {
    //        group.participantIds = [NSJSONSerialization JSONObjectWithData:[participantIds dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    //    }
    //参与人信息
    
    NSString *managerIds = [rs stringForColumn:@"managerIds"];
    if (managerIds) {
        group.managerIds = [NSJSONSerialization JSONObjectWithData:[managerIds dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    }
    
    
    return group;
}
#pragma mark - toDoMsgState
- (NSMutableArray *)queryAllToDo
{
    NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY readState, sendTime DESC",TABLE_TODO];
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]) {
            KDToDoMessageDataModel *record = [[KDToDoMessageDataModel alloc] init];
            record.msgId = [rs stringForColumn:@"msgId"];
            record.XTMsgId = [rs stringForColumn:@"xtMsgId"];
            record.fromUserId = [rs stringForColumn:@"fromUserId"];
            record.sendTime = [rs stringForColumn:@"sendTime"];
            record.msgType = [rs intForColumn:@"msgType"];
            record.msgLen = [rs intForColumn:@"msgLen"];
            record.content = [rs stringForColumn:@"content"];
            record.status = [rs intForColumn:@"status"];
            record.msgDirection = [rs intForColumn:@"direction"];
            record.msgRequestState = [rs intForColumn:@"requestType"];
            record.nickname = [rs stringForColumn:@"fromUserNickName"];
            record.score = [rs stringForColumn:@"score"];
            NSString *paramString = [rs stringForColumn:@"param"];
            if (paramString.length > 0)
            {
                MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithJSONString:paramString type:record.msgType];
                record.param = param;
            }
            record.iNotifyType = [rs intForColumn:@"notifyType"];
            record.strNotifyDesc = [rs stringForColumn:@"notifyDesc"];
            record.strEmojiType = [rs stringForColumn:@"emojiType"];
            record.sourceMsgId = [rs stringForColumn:@"sourceMsgId"];
            record.readState = [rs stringForColumn:@"readState"];
            record.todoStatus = [rs stringForColumn:@"todoStatus"];
            
            record.appid = [rs stringForColumn:@"appid"];
            record.date = [rs stringForColumn:@"date"];
            record.name = [rs stringForColumn:@"name"];
            record.row = [rs stringForColumn:@"row"];
            record.text = [rs stringForColumn:@"text"];
            record.title = [rs stringForColumn:@"title"];
            record.url = [rs stringForColumn:@"url"];
            record.model = [rs stringForColumn:@"messageMode"];
            
            
            //            if (record.model == nil || [record.sourceMsgId isEqualToString:@""] || [record.sourceMsgId isKindOfClass:[NSNull class]])
            //            {
            //                record.cellType = KDToDoCellType_NotOperateAble;
            //            }
            //            else
            //            {
            //                record.cellType = KDToDoCellType_Operate_Hide;
            //            }
            
            if ([record.model isEqualToString:@"4"])
            {
                record.cellType = KDToDoCellType_Operate_Hide;
            }
            else
            {
                record.cellType = KDToDoCellType_NotOperateAble;
            }
            
            [records addObject:record];
        }
        [rs close];
    }];
    return records;
}

- (NSMutableArray *)queryToDomessageKind
{
    __block NSMutableArray *results = [NSMutableArray array];
    __block NSMutableDictionary *tempResults = [NSMutableDictionary dictionary];
    __block NSString *appid = nil;
    __block NSString *title = nil;
    __block NSString *name = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db)
     {
         NSInteger index = [[[NSUserDefaults standardUserDefaults]valueForKey:@"MenuSelect"] integerValue];
         NSString *sqlIndex = nil;
         if (index == 0) {
             sqlIndex = @"todoStatus = 'undo' AND ";
         }else if (index == 1)
         {
             sqlIndex = @"todoStatus = 'done' AND ";
             
         }else if (index == 2)
         {
             sqlIndex = @"(todoStatus = '' OR todoStatus is null) AND ";
         }else
         {
             sqlIndex = @"";
         }
         
         NSString *sql = [NSString stringWithFormat:@"SELECT appid,title,name FROM %@ WHERE %@fromUserId = 'XT-10001'",TABLE_TODO,sqlIndex];
         
         FMResultSet *rs = [db executeQuery:sql];
         
         while ([rs next])
         {
             appid = [rs stringForColumn:@"appid"];
             title = [rs stringForColumn:@"title"];
             name = [rs stringForColumn:@"name"];
             if (![appid isEqualToString:@""]) {   //@""是@提及
                 if (name.length > 0) {
                     [tempResults setObject:name forKey:title];
                 }
                 else {
                     if (title.length > 0) {
                         [tempResults setObject:@"" forKey:title];
                     }
                     else {
                         [tempResults setObject:@"" forKey:ASLocalizedString(@"KDToDoViewCell_text")];
                     }
                 }
             }
             else {
                 [tempResults setObject:@"" forKey:@"@提及"];
             }
             
         }
         [rs close];
     }];
    NSArray *tempArray = [tempResults allKeys];
    //    DLog("tempArray = %@", tempArray);
    
    __block NSString *tempName = nil;
    [tempArray enumerateObjectsUsingBlock:^(NSString *title, NSUInteger i, BOOL *stop)
     {
         tempName = [tempResults objectForKey:title];
         
         KDToDoMessageDataModel *model = [[KDToDoMessageDataModel alloc]init];
         model.title = title;
         model.name = tempName;
         [results addObject:model];
     }];
    return results;
}

- (NSMutableArray *)queryUndoDoMsg
{
    __block NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql = [NSString stringWithFormat:@"SELECT appid,title,name FROM %@ WHERE todoStatus = 'undo';",TABLE_TODO];
         
         FMResultSet *rs = [db executeQuery:sql];
         
         while ([rs next]) {
             KDToDoMessageDataModel *record = [[KDToDoMessageDataModel alloc] init];
             record.appid = [rs stringForColumn:@"appid"];
             record.name = [rs stringForColumn:@"name"];
             record.title = [rs stringForColumn:@"title"];
             [records addObject:record];
         }
         [rs close];
     }];
    return records;
}

- (NSMutableArray *)queryAllUndoDoMsg
{
    __block NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db)
     {
         //         NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM %@  WHERE (status = '0' AND (todoStatus = '' OR todoStatus is null)) OR todoStatus = 'undo' ORDER BY sendTime DESC;",TABLE_TODO];
         NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM %@  WHERE todoStatus = 'undo' ORDER BY sendTime DESC;",TABLE_TODO];
         
         FMResultSet *rs = [db executeQuery:sql];
         
         while ([rs next]) {
             KDToDoMessageDataModel *record = [[KDToDoMessageDataModel alloc] init];
             
             record.readState = [rs stringForColumn:@"readState"];
             record.todoStatus = [rs stringForColumn:@"todoStatus"];
             
             record.msgId = [rs stringForColumn:@"msgId"];
             record.fromUserId = [rs stringForColumn:@"fromUserId"];
             record.sendTime = [rs stringForColumn:@"sendTime"];
             record.msgType = [rs intForColumn:@"msgType"];
             record.msgLen = [rs intForColumn:@"msgLen"];
             record.content = [rs stringForColumn:@"content"];
             record.status = [rs intForColumn:@"status"];
             record.msgDirection = [rs intForColumn:@"direction"];
             record.groupId = [rs stringForColumn:@"groupId"];
             record.msgRequestState = [rs intForColumn:@"requestType"];
             record.nickname = [rs stringForColumn:@"fromUserNickName"];
             record.iNotifyType = [rs intForColumn:@"notifyType"];
             record.strNotifyDesc = [rs stringForColumn:@"notifyDesc"];
             record.strEmojiType = [rs stringForColumn:@"emojiType"];
             record.bImportant = [rs boolForColumn:@"important"];
             record.sourceMsgId = [rs stringForColumn:@"sourceMsgId"];
             
             NSString *paramString = [rs stringForColumn:@"param"];
             
             if (paramString.length > 0)
             {
                 MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithJSONString:paramString type:record.msgType];
                 record.param = param;
                 
                 NSData *strData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
                 NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:strData];
                 
                 //model
                 record.model = [NSString stringWithFormat:@"%d", [[dic objectForKey:@"model"] intValue]];
                 if ([record.model isEqualToString:@"4"])
                 {
                     record.cellType = KDToDoCellType_Operate_Hide;
                 }
                 else
                 {
                     record.cellType = KDToDoCellType_NotOperateAble;
                 }
                 
                 //list
                 NSArray *list = [dic objectForKey:@"list"];
                 NSDictionary *listDic = [list firstObject];
                 record.appid = [listDic objectForKey:@"appid"];
                 record.date = [listDic objectForKey:@"date"];
                 record.name = [listDic objectForKey:@"name"];
                 record.row = [listDic objectForKey:@"row"];
                 record.text = [listDic objectForKey:@"text"];
                 record.title = [listDic objectForKey:@"title"];
                 record.url = [listDic objectForKey:@"url"];
                 
                 //防止list中漏掉下三项,将param中得下三项存储到record中
                 id tempAppId = [dic objectForKey:@"appid"];
                 if (![tempAppId isKindOfClass:[NSNull class]] && tempAppId)
                 {
                     record.appid = tempAppId;
                 }
                 
                 id tempTitle = [dic objectForKey:@"title"];
                 if (![tempTitle isKindOfClass:[NSNull class]] && tempTitle)
                 {
                     record.title = tempTitle;
                 }
                 
                 id tempName = [dic objectForKey:@"name"];
                 if (![tempName isKindOfClass:[NSNull class]] && tempName) {
                     record.name = tempName;
                 }
             }
             
             [records addObject:record];
         }
         [rs close];
     }];
    return records;
}
- (NSMutableArray *)queryAllDoneMsg
{
    __block NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db)
     {
         //通知类消息不进来
         //         NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM %@ WHERE (status = '1' AND (todoStatus = '' OR todoStatus is null)) OR todoStatus = 'done' ORDER BY sendTime DESC ;",TABLE_TODO];
         NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM %@ WHERE todoStatus = 'done' ORDER BY sendTime DESC ;",TABLE_TODO];
         FMResultSet *rs = [db executeQuery:sql];
         
         while ([rs next]) {
             KDToDoMessageDataModel *record = [[KDToDoMessageDataModel alloc] init];
             
             record.readState = [rs stringForColumn:@"readState"];
             record.todoStatus = [rs stringForColumn:@"todoStatus"];
             
             record.msgId = [rs stringForColumn:@"msgId"];
             record.fromUserId = [rs stringForColumn:@"fromUserId"];
             record.sendTime = [rs stringForColumn:@"sendTime"];
             record.msgType = [rs intForColumn:@"msgType"];
             record.msgLen = [rs intForColumn:@"msgLen"];
             record.content = [rs stringForColumn:@"content"];
             record.status = [rs intForColumn:@"status"];
             record.msgDirection = [rs intForColumn:@"direction"];
             record.groupId = [rs stringForColumn:@"groupId"];
             record.msgRequestState = [rs intForColumn:@"requestType"];
             record.nickname = [rs stringForColumn:@"fromUserNickName"];
             record.iNotifyType = [rs intForColumn:@"notifyType"];
             record.strNotifyDesc = [rs stringForColumn:@"notifyDesc"];
             record.strEmojiType = [rs stringForColumn:@"emojiType"];
             record.bImportant = [rs boolForColumn:@"important"];
             record.sourceMsgId = [rs stringForColumn:@"sourceMsgId"];
             record.score = [rs stringForColumn:@"score"];
             
             NSString *paramString = [rs stringForColumn:@"param"];
             
             if (paramString.length > 0)
             {
                 MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithJSONString:paramString type:record.msgType];
                 record.param = param;
                 
                 NSData *strData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
                 NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:strData];
                 
                 //model
                 record.model = [NSString stringWithFormat:@"%d", [[dic objectForKey:@"model"] intValue]];
                 if ([record.model isEqualToString:@"4"])
                 {
                     record.cellType = KDToDoCellType_Operate_Hide;
                 }
                 else
                 {
                     record.cellType = KDToDoCellType_NotOperateAble;
                 }
                 
                 //list
                 NSArray *list = [dic objectForKey:@"list"];
                 NSDictionary *listDic = [list firstObject];
                 record.appid = [listDic objectForKey:@"appid"];
                 record.date = [listDic objectForKey:@"date"];
                 record.name = [listDic objectForKey:@"name"];
                 record.row = [listDic objectForKey:@"row"];
                 record.text = [listDic objectForKey:@"text"];
                 record.title = [listDic objectForKey:@"title"];
                 record.url = [listDic objectForKey:@"url"];
                 
                 //防止list中漏掉下三项,将param中得下三项存储到record中
                 id tempAppId = [dic objectForKey:@"appid"];
                 if (![tempAppId isKindOfClass:[NSNull class]] && tempAppId)
                 {
                     record.appid = tempAppId;
                 }
                 
                 id tempTitle = [dic objectForKey:@"title"];
                 if (![tempTitle isKindOfClass:[NSNull class]] && tempTitle)
                 {
                     record.title = tempTitle;
                 }
                 
                 id tempName = [dic objectForKey:@"name"];
                 if (![tempName isKindOfClass:[NSNull class]] && tempName) {
                     record.name = tempName;
                 }
             }
             
             [records addObject:record];
         }
         [rs close];
     }];
    return records;
}

- (BOOL)deleteAllToDo
{
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@;",TABLE_TODO];
        result = [db executeUpdate:deleteSql];
    }];
    
    return result;
}
- (void)updateToDoWhenHasMsgIdWithStatus:(NSString *)readState MsgId:(NSString *)msgId
{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        //这里不是sourceMsgId应该是readState，只是做个测试
        NSString *update = [NSString stringWithFormat:@"Update %@ Set status = ? Where msgId = ?;",TABLE_TODO];
        //        NSLog(@"update = ------------%@", [NSString stringWithFormat:@"Update %@ Set status = %@ Where msgId = %@;",TABLE_TODO, readState, msgId]);
        BOOL d = [db executeUpdate:update, readState, msgId];
        NSLog(@"%d", d);
    }];
}

- (void)updateToDoWhenHasMsgIdWithDoneState:(NSString *)doneState MsgId:(NSString *)msgId
{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        //这里不是sourceMsgId应该是readState，只是做个测试
        NSString *update = [NSString stringWithFormat:@"Update %@ Set todoStatus = ? Where msgId = ?;",TABLE_TODO];
        //        NSLog(@"update = ------------%@", [NSString stringWithFormat:@"Update %@ Set todoStatus = %@ Where msgId = %@;",TABLE_TODO, doneState, msgId]);
        BOOL d = [db executeUpdate:update, doneState, msgId];
        NSLog(@"%d", d);
    }];
}

- (void)updateToDoWhenHasSourceMsgIdWithReadState:(NSString *)readState SourceMsgId:(NSString *)sourceMsgId
{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"Update %@ Set readState = ? Where msgId = ?;",TABLE_TODO];
        //        NSLog(@"update = ------------%@", [NSString stringWithFormat:@"Update %@ Set readState = %@ Where msgId = %@;",TABLE_TODO, readState, sourceMsgId]);
        BOOL d = [db executeUpdate:update, readState, sourceMsgId];
        NSLog(@"%d", d);
    }];
}

- (void)updateToDoWhenHasSourceMsgIdWithDoneState:(NSString *)doneState SourceMsgId:(NSString *)sourceMsgId
{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"Update %@ Set todoStatus = ? Where msgId = ?;",TABLE_TODO];
        //        NSLog(@"update = ------------%@", [NSString stringWithFormat:@"Update %@ Set todoStatus = %@ Where msgId = %@;",TABLE_TODO, doneState, sourceMsgId]);
        BOOL d = [db executeUpdate:update, doneState, sourceMsgId];
        NSLog(@"%d", d);
    }];
}

- (void)insertToDoRecords:(NSArray *)records
{
    __block BOOL result = NO;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             KDToDoMessageDataModel *record = (KDToDoMessageDataModel *)obj;
             result = [self insertToDoRecord:record db:db];
             if (!result) {
                 *stop = YES;
             }
         }];
    }];
}

//RecordDataModel的init方法要改，加入对sourceMsgId的支持，加入readState和doneState两个字段，试试查询的方法
- (BOOL)insertToDoRecord:(KDToDoMessageDataModel *)record db:(FMDatabase *)db
{
    if (record == nil)
        return NO;
    
    __block BOOL result = NO;
    NSString *insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (msgId,xtMsgId,fromUserId,sendTime,msgType,msgLen,content,status,direction,groupId,toUserId,requestType,fromUserNickName,param,notifyType,notifyDesc,emojiType,important,sourceMsgId,appid,date,name,row,text,title,url,messageMode,readState,todoStatus,score) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",TABLE_TODO];
    
    NSString *paramString = @"";
    if (record.param)
    {
        paramString = record.param.paramString;
    }
    
    NSString *readAndDoneState = @"";
    //    id firstDownload = [[NSUserDefaults standardUserDefaults] objectForKey:@"TheFirstTimePullAllToDoMsg"];
    //    if ((firstDownload == nil) || (firstDownload == 0))
    //    {
    //        readAndDoneState = @"Done";
    //    }
    //    else
    //    {
    //        readAndDoneState = @"Undo";
    //    }
    if (db != nil)
    {
        //@"XT-10001"
        result = [db executeUpdate:insert,record.msgId,record.XTMsgId,record.fromUserId,record.sendTime,[NSNumber numberWithInt:record.msgType],[NSNumber numberWithInt:record.msgLen],record.content,[NSNumber numberWithInt:record.status],[NSNumber numberWithInt:record.msgDirection],record.groupId,@"",[NSNumber numberWithInt:record.msgRequestState],record.nickname,paramString,[NSNumber numberWithInt:record.iNotifyType],record.strNotifyDesc, record.strEmojiType,@(record.bImportant),record.sourceMsgId,record.appid,record.date,record.name,record.row,record.text,record.title,record.url,record.model,readAndDoneState,record.todoStatus,record.score];
    }
    else
    {
        [self.databaseQueue inDatabase:^(FMDatabase *db)
         {
             
#if DEBUG
             db.logsErrors = YES;
#endif
             //@"XT-10001"
             result = [db executeUpdate:insert,record.msgId,record.fromUserId,record.sendTime,[NSNumber numberWithInt:record.msgType],[NSNumber numberWithInt:record.msgLen],record.content,[NSNumber numberWithInt:record.status],[NSNumber numberWithInt:record.msgDirection],record.groupId,@"",[NSNumber numberWithInt:record.msgRequestState],record.nickname,paramString,[NSNumber numberWithInt:record.iNotifyType],record.strNotifyDesc, record.strEmojiType,@(record.bImportant),record.sourceMsgId,record.appid,record.date,record.name,record.row,record.text,record.title,record.url,record.model,readAndDoneState,record.todoStatus,record.score];
         }];
    }
    
    return result;
}

- (BOOL)appendToDoMessageWithRecord:(RecordDataModel *)record db:(FMDatabase *)db
{
    __block BOOL result = NO;
    
    NSString *paramString = @"";
    MessageNewsDataModel *paramObject = nil;
    MessageNewsEachDataModel *each = nil;
    if (record.param)
    {
        paramString = record.param.paramString;
        paramObject = record.param.paramObject;
        each = paramObject.newslist.firstObject;
    }
    
    NSString *insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (msgId,fromUserId,sendTime,msgType,msgLen,content,status,direction,groupId,toUserId,requestType,fromUserNickName,param,notifyType,notifyDesc,emojiType,important,sourceMsgId,appid,date,name,text,title,url,messageMode) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);", TABLE_TODO];
    if (db != nil)
    {
        result = [db executeUpdate:insert, record.msgId, record.fromUserId, record.sendTime, [NSNumber numberWithInt:record.msgType], [NSNumber numberWithInt:record.msgLen], record.content, [NSNumber numberWithInt:record.status], [NSNumber numberWithInt:record.msgDirection], record.groupId, @"", [NSNumber numberWithInt:record.msgRequestState], record.nickname, paramString, [NSNumber numberWithInt:record.iNotifyType], record.strNotifyDesc, record.strEmojiType, @(record.bImportant), record.sourceMsgId, each.appId, each.date, each.name, each.text, each.title, each.url, [NSString stringWithFormat:@"%d", paramObject.model]];
    }
    else
    {
        [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
            db.logsErrors = YES;
#endif
            result = [db executeUpdate:insert, record.msgId, record.fromUserId, record.sendTime, [NSNumber numberWithInt:record.msgType], [NSNumber numberWithInt:record.msgLen], record.content, [NSNumber numberWithInt:record.status], [NSNumber numberWithInt:record.msgDirection], record.groupId, @"", [NSNumber numberWithInt:record.msgRequestState], record.nickname, paramString, [NSNumber numberWithInt:record.iNotifyType], record.strNotifyDesc, record.strEmojiType, @(record.bImportant), record.sourceMsgId, each.appId, each.date, each.name, each.text, each.title, each.url, [NSString stringWithFormat:@"%d", paramObject.model]];
        }];
    }
    
    return result;
}

- (NSMutableArray *)queryPageOfToDoRecordWithSql:(NSString *)sql
{
    NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next])
        {
            KDToDoMessageDataModel *record = [[KDToDoMessageDataModel alloc] init];
            
            record.readState = [rs stringForColumn:@"readState"];
            record.todoStatus = [rs stringForColumn:@"todoStatus"];
            
            record.msgId = [rs stringForColumn:@"msgId"];
            record.fromUserId = [rs stringForColumn:@"fromUserId"];
            record.sendTime = [rs stringForColumn:@"sendTime"];
            record.msgType = [rs intForColumn:@"msgType"];
            record.msgLen = [rs intForColumn:@"msgLen"];
            record.content = [rs stringForColumn:@"content"];
            record.status = [rs intForColumn:@"status"];
            record.msgDirection = [rs intForColumn:@"direction"];
            record.groupId = [rs stringForColumn:@"groupId"];
            record.msgRequestState = [rs intForColumn:@"requestType"];
            record.nickname = [rs stringForColumn:@"fromUserNickName"];
            record.iNotifyType = [rs intForColumn:@"notifyType"];
            record.strNotifyDesc = [rs stringForColumn:@"notifyDesc"];
            record.strEmojiType = [rs stringForColumn:@"emojiType"];
            record.bImportant = [rs boolForColumn:@"important"];
            record.sourceMsgId = [rs stringForColumn:@"sourceMsgId"];
            record.score = [rs stringForColumn:@"score"];
            NSString *paramString = [rs stringForColumn:@"param"];
            
            if (paramString.length > 0)
            {
                MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithJSONString:paramString type:record.msgType];
                record.param = param;
                
                NSData *strData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:strData];
                
                //model
                record.model = [NSString stringWithFormat:@"%d", [[dic objectForKey:@"model"] intValue]];
                if ([record.model isEqualToString:@"4"])
                {
                    record.cellType = KDToDoCellType_Operate_Hide;
                }
                else
                {
                    record.cellType = KDToDoCellType_NotOperateAble;
                }
                
                //list
                NSArray *list = [dic objectForKey:@"list"];
                NSDictionary *listDic = [list firstObject];
                record.appid = [listDic objectForKey:@"appid"];
                record.date = [listDic objectForKey:@"date"];
                record.name = [listDic objectForKey:@"name"];
                record.row = [listDic objectForKey:@"row"];
                record.text = [listDic objectForKey:@"text"];
                record.title = [listDic objectForKey:@"title"];
                record.url = [listDic objectForKey:@"url"];
                
                //防止list中漏掉下三项,将param中得下三项存储到record中
                id tempAppId = [dic objectForKey:@"appid"];
                if (![tempAppId isKindOfClass:[NSNull class]] && tempAppId)
                {
                    record.appid = tempAppId;
                }
                
                id tempTitle = [dic objectForKey:@"title"];
                if (![tempTitle isKindOfClass:[NSNull class]] && tempTitle)
                {
                    record.title = tempTitle;
                }
                
                id tempName = [dic objectForKey:@"name"];
                if (![tempName isKindOfClass:[NSNull class]] && tempName) {
                    record.name = tempName;
                }
            }
            
            [records addObject:record];
        }
        [rs close];
    }];
    
    return records;
}
- (BOOL)deleteAllPublicAccounts {
    __block BOOL result = NO;
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id != ? OR id != ? OR id != ?;", TABLE_PUBLIC_PERSON];
        result = [db executeUpdate:sql, kYZJPersonId, kTodoPersonId, kFilePersonId];
    }];
    return result;
}

//- (NSArray *)queryPublicAccountsWithLikeName:(NSString *)name {
//    __block NSMutableArray *pubAccts = [NSMutableArray array];
//
//    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
//#if DEBUG
//        db.logsErrors = YES;
//#endif
//
//        NSString * sql = [NSString stringWithFormat:@"SELECT\n\t*\nFROM\n\t%@\nWHERE\n\tpersonName LIKE ?\nAND (\n\tsubscribe = 1\n\tOR canUnsubscribe = 1\n);", TABLE_PUBLIC_PERSON];
//        FMResultSet *rs = [db executeQuery:sql, [NSString stringWithFormat:@"%%%@%%", name]];
//        while ([rs next]) {
//            PersonSimpleDataModel *pubAcct = [self loadPublicAccountWithResultSet:rs];
//            NSRange range = [[pubAcct.personName lowercaseString] rangeOfString:name.lowercaseString];
//            if (range.location != NSNotFound) {
//                pubAcct.highlightName = [pubAcct.personName stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"<font color=\"#06A3EC\">%@</font>", [pubAcct.personName substringWithRange:range]]];
//            }
//            [pubAccts addObject:pubAcct];
//        }
//        [rs close];
//    }];
//    return pubAccts;
//}

- (BOOL)insertPublicAccounts:(NSArray *)pubAccts {
    if ([pubAccts count] == 0) {
        return NO;
    }
    __block BOOL result = YES;
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        [pubAccts enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
            PersonSimpleDataModel *pubAcct = obj;
            NSString *sql = [NSString stringWithFormat:@"INSERT\nOR REPLACE INTO %@ (\n\tpersonId,\n\tpersonName,\n\tdefaultPhone,\n\tdepartment,\n\tfullPinyin,\n\tphotoUrl,\n\tstatus,\n\tjobTitle,\n\tnote,\n\treply,\n\tsubscribe,\n\tcanUnsubscribe,\n\tmenu,\n\tmanager,\n\tshare,\n\tfold,\n\tremind,\n\tstate,\n\thisNews)\nVALUES\n\t(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);", TABLE_PUBLIC_PERSON];
            result = [db executeUpdate:sql, pubAcct.personId,pubAcct.personName,pubAcct.defaultPhone,pubAcct.department,pubAcct.fullPinyin,pubAcct.photoUrl,@(pubAcct.status),pubAcct.jobTitle,pubAcct.note,pubAcct.reply,pubAcct.subscribe,pubAcct.canUnsubscribe,pubAcct.menu,@(pubAcct.manager), @(pubAcct.share), @(pubAcct.fold),@(pubAcct.remind),@(pubAcct.state),@(pubAcct.hisNews)];
        }];
    }];
    return result;
}


//代办状态
- (BOOL)insertToDoStateWithSourceMsgId:(NSString *)sourceMsgId ReadState:(NSString *)readState DoneState:(NSString *)doneState
{
    __block BOOL result = YES;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        //这里不是sourceMsgId应该是readState，只是做个测试
        NSString *update = [NSString stringWithFormat:@"Update %@ Set readState = ? Where msgId = ?;",TABLE_TODO];
        //        NSLog(@"update = ------------%@", [NSString stringWithFormat:@"Update %@ Set readState = %@ Where msgId = %@;",TABLE_TODO, readState, sourceMsgId]);
        result = [db executeUpdate:update, readState, sourceMsgId];
        NSLog(@"%d", result);
        
    }];
    
    return result;
}

- (PersonSimpleDataModel *)queryPublicAccountWithId:(NSString *)personId {
    __block PersonSimpleDataModel *pubAcct = nil;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@ Where personId = ?;", TABLE_PUBLIC_PERSON];
        FMResultSet *rs = [db executeQuery:sql, personId];
        if ([rs next]) {
            pubAcct = [self loadPublicAccountWithResultSet:rs];
        }
        [rs close];
    }];
    return pubAcct;
}
- (void)insertToDoStateWithArray:(NSMutableArray *)array
{
    [array enumerateObjectsUsingBlock:^(NSString *sourceMsgId, NSUInteger i, BOOL *stop)
     {
         [self insertToDoStateWithSourceMsgId:sourceMsgId ReadState:@"Yes" DoneState:@""];
     }];
}

- (void)updateToDoWithSourceMsgId:(NSString *)sourceMsgId ReadState:(NSString *)readState
{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"Update %@ Set readState = ? Where msgId = ?;",TABLE_TODO];
        //        DLog(@"update = ------------%@", [NSString stringWithFormat:@"Update %@ Set readState = %@ Where msgId = %@;",TABLE_TODO, readState, sourceMsgId]);
        [db executeUpdate:update, readState, sourceMsgId];
    }];
}
- (void)updateToDoWithSourceMsgId:(NSString *)msgId doneState:(NSString *)doneState
{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"Update %@ Set todoStatus = ? Where msgId = ?;",TABLE_TODO];
        //        DLog(@"update = ------------%@", [NSString stringWithFormat:@"Update %@ Set todoStatus = %@ Where msgId = %@;",TABLE_TODO, doneState, msgId]);
        [db executeUpdate:update, doneState, msgId];
    }];
}
- (NSMutableArray *)queryAllToDoMsgId
{
    NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = [NSString stringWithFormat:@"SELECT msgId FROM %@ WHERE fromUserId = 'XT-10001';",TABLE_TODO];
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next])
        {
            NSString *tempString = [rs stringForColumn:@"msgId"];
            
            if (tempString == nil || [tempString isKindOfClass:[NSNull class]])
            {
                continue;
            }
            
            [records addObject:tempString];
        }
        [rs close];
    }];
    return records;
}

- (BOOL)deleteToDoDataWithMsgId:(NSString *)msgId
{
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        
        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE msgId = ?;",TABLE_TODO];
        NSString *deleteSql1 = [NSString stringWithFormat:@"DELETE FROM %@ WHERE msgId = ?;",TABLE_MESSAGE];
        result = [db executeUpdate:deleteSql,msgId];
        result = [db executeUpdate:deleteSql1,msgId];
        
    }];
    return result;
}


- (PersonSimpleDataModel *)loadPublicAccountWithResultSet:(FMResultSet *)rs {
    PersonSimpleDataModel *pubAcct = [[PersonSimpleDataModel alloc] init];
    pubAcct.personId = [rs stringForColumn:@"personId"];
    pubAcct.personName = [rs stringForColumn:@"personName"];
    pubAcct.photoUrl = [rs stringForColumn:@"photoUrl"];
    pubAcct.status = [rs intForColumn:@"status"];
    pubAcct.note = [rs stringForColumn:@"note"];
    pubAcct.subscribe = [rs stringForColumn:@"subscribe"];
    pubAcct.canUnsubscribe = [rs stringForColumn:@"canUnsubscribe"];
    pubAcct.menu = [rs stringForColumn:@"menu"];
    pubAcct.manager = [rs boolForColumn:@"manager"];
    pubAcct.share = [rs intForColumn:@"share"];
    pubAcct.fold = [rs boolForColumn:@"fold"];
    pubAcct.remind = [rs boolForColumn:@"remind"];
    pubAcct.state = [rs intForColumn:@"state"];
    pubAcct.reply = [rs stringForColumn:@"reply"];
    pubAcct.hisNews = [rs boolForColumn:@"hisNews"];
    return pubAcct;
}

#pragma mark - 消息已读未读
-(void)insertMessageUnreadStateWithGroupId:(NSString *)groupId MsgId:(NSString *)msgId UnreadCount:(NSNumber *)unreadCount
{
    __block BOOL finded = NO;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE msgId = '%@';", TABLE_MSGREADSTATE, msgId];
    //    DLog(@"sql = %@", sql);
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next])
        {
            finded = [rs stringForColumn:@"groupId"].length > 0 ? YES : NO;
        }
        [rs close];
    }];
    
    __block BOOL state = NO;
    
    if (finded == YES)
    {
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
            db.logsErrors = YES;
#endif
            NSString *update = [NSString stringWithFormat:@"Update %@ Set unreadCount = ? Where msgId = ?;",TABLE_MSGREADSTATE];
            state = [db executeUpdate:update, [NSString stringWithFormat:@"%ld", [unreadCount integerValue]], msgId];
        }];
    }
    else
    {
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
            db.logsErrors = YES;
#endif
            NSString *insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (groupId,msgId,unreadCount) VALUES (?,?,?);",TABLE_MSGREADSTATE];
            state = [db executeUpdate:insert, groupId, msgId, [NSString stringWithFormat:@"%ld",[unreadCount integerValue]]];
        }];
    }
}

-(NSMutableDictionary *)queryMsgUnreadStateWithGroupId:(NSString *)groupId
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE groupId = '%@';", TABLE_MSGREADSTATE, groupId];
    
    NSMutableDictionary *records = [NSMutableDictionary dictionary];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next])
        {
            NSString *groupId = [rs stringForColumn:@"groupId"];
            NSString *msgId = [rs stringForColumn:@"msgId"];
            NSString *unreadCount = [rs stringForColumn:@"unreadCount"];
            NSString *press = [rs stringForColumn:@"press"];
            if (press == nil)
            {
                NSDictionary *dic = @{@"groupId":groupId, @"msgId":msgId, @"unreadCount":unreadCount};
                [records setObject:dic forKey:msgId];
            }
            else
            {
                NSDictionary *dic = @{@"groupId":groupId, @"msgId":msgId, @"unreadCount":unreadCount, @"press":press};
                [records setObject:dic forKey:msgId];
            }
        }
        [rs close];
    }];
    
    return records;
}

-(NSDictionary *)queryMsgUnreadStateWithMsgId:(NSString *)msgId
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE msgId = '%@';", TABLE_MSGREADSTATE, msgId];
    
    __block NSDictionary *dic = nil;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next])
        {
            NSString *groupId = [rs stringForColumn:@"groupId"];
            NSString *msgId = [rs stringForColumn:@"msgId"];
            NSString *unreadCount = [rs stringForColumn:@"unreadCount"];
            NSString *press = [rs stringForColumn:@"press"];
            if (press == nil)
            {
                dic = @{@"groupId":groupId, @"msgId":msgId, @"unreadCount":unreadCount};
            }
            else
            {
                dic = @{@"groupId":groupId, @"msgId":msgId, @"unreadCount":unreadCount, @"press":press};
            }
        }
        [rs close];
    }];
    
    return dic;
}

-(BOOL)deleteMsgUnreadStateWithGroupId:(NSString *)groupId
{
    __block BOOL result = YES;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        result = result && [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE groupId = '%@';", TABLE_MSGREADSTATE, groupId]];
        
    }];
    
    return result;
}

-(BOOL)deleteMsgUnreadStateWithMsgId:(NSString *)msgId
{
    __block BOOL result = YES;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        result = result && [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE msgId = '%@';", TABLE_MSGREADSTATE, msgId]];
        
    }];
    
    return result;
}

-(BOOL)updateMsgUnreadStateWithMsgId:(NSString *)msgId UnreadUserCount:(NSInteger)unreadUserCount
{
    __block BOOL state = NO;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"Update %@ Set unreadCount = ? Where msgId = ?;",TABLE_MSGREADSTATE];
        //        DLog(@"update = ------------%@", [NSString stringWithFormat:@"Update %@ Set unreadCount = %ld Where msgId = %@;",TABLE_MSGREADSTATE, unreadUserCount, msgId]);
        state = [db executeUpdate:update, [NSString stringWithFormat:@"%ld", (long)unreadUserCount], msgId];
    }];
    
    return state;
}

-(BOOL)updateMsgPressStateWithMsgId:(NSString *)msgId PressState:(NSString *)pressState
{
    __block BOOL state = NO;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"Update %@ Set press = ? Where msgId = ?;",TABLE_MSGREADSTATE];
        //        DLog(@"update = ------------%@", [NSString stringWithFormat:@"Update %@ Set press = %@ Where msgId = %@;",TABLE_MSGREADSTATE, pressState, msgId]);
        state = [db executeUpdate:update, pressState, msgId];
    }];
    
    if (state == YES)
    {
        DLog(@"state = yes");
    }
    else
    {
        DLog(@"state = no");
    }
    
    return state;
}

- (BOOL)updateUnreadCountWithGroupId:(NSString *)groupId UnreadCount:(NSUInteger)unreadCount
{
    __block BOOL state = NO;
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"Update %@ Set unreadCount = ? Where groupId = ?;",TABLE_GROUP];
        //        DLog(@"update = ------------%@", [NSString stringWithFormat:@"Update %@ Set unreadCount = %ld Where msgId = %@;",TABLE_MSGREADSTATE, unreadUserCount, msgId]);
        state = [db executeUpdate:update, @(unreadCount),groupId];
    }];
    
    return state;
}

- (BOOL)queryUnreadUndoMsg
{
    __block BOOL result = NO;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        //        BOOL stat = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE todoStatus = 'undo';", TABLE_TODO]];
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE todoStatus = 'undo';", TABLE_TODO]];
        while ([rs next])
        {
            result = YES;
        }
        [rs close];
    }];
    
    return result;
}

- (BOOL)queryUnreadNotificationMsg
{
    __block BOOL result = NO;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        FMResultSet *rs =  [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE (todoStatus is null OR todoStatus = '') AND status = '0';", TABLE_TODO]];
        while ([rs next])
        {
            result = YES;
        }
        [rs close];
    }];
    
    return result;
    
}

- (NSMutableArray *)queryUnreadNotificationMsgNum
{
    __block NSMutableArray *records = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *rs =  [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE (todoStatus is null OR todoStatus = '') AND status = '0';", TABLE_TODO]];
         while ([rs next]) {
             KDToDoMessageDataModel *record = [[KDToDoMessageDataModel alloc] init];
             record.appid = [rs stringForColumn:@"appid"];
             record.name = [rs stringForColumn:@"name"];
             record.title = [rs stringForColumn:@"title"];
             [records addObject:record];
         }
         [rs close];
     }];
    return records;
}

- (BOOL)deleteAllNotifyMsg
{
    __block BOOL result = NO;
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE todoStatus is null OR todoStatus = '';",TABLE_TODO];
        result = [db executeUpdate:sql];
    }];
    return result;
}
- (BOOL)deleteAllUndoMsg
{
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE todoStatus = 'undo';",TABLE_TODO];
        result = [db executeUpdate:sql];
    }];
    return result;
}
- (BOOL)queryUnreadUndoMsgWithTitle:(NSString *)title
{
    __block BOOL result = NO;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        //        BOOL stat = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE todoStatus = 'undo';", TABLE_TODO]];
        NSString *titleSql = @"title";
        if (title == nil || [title isEqualToString:@""]) {
            titleSql = @"appid";
        }
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE  %@ = '%@' AND todoStatus = 'undo';",TABLE_TODO,titleSql,title]];
        while ([rs next])
        {
            result = YES;
        }
        [rs close];
    }];
    
    return result;
}

- (BOOL)queryUnreadNotificationMsgWithTitle:(NSString *)title
{
    __block BOOL result = NO;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *titleSql = @"title";
        if (title == nil || [title isEqualToString:@""]) {
            titleSql = @"appid";
        }
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE  %@ = '%@'  AND (todoStatus is null OR todoStatus = '') AND status = '0';",TABLE_TODO,titleSql, title]];
        while ([rs next])
        {
            result = YES;
        }
        
        [rs close];
    }];
    
    return result;
    
}

- (BOOL)updateUndoMsgWithLastIgnoreNotifyScore:(NSString *)lastIgnoreNotifyScore
{
    __block BOOL state = NO;
    
    //存在且更新成功则yes
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"Update %@ Set status = ? Where score <= ?;",TABLE_TODO];
        state = [db executeUpdate:update, @"1", lastIgnoreNotifyScore];
    }];
    //不存在则no
    return state;
}
//- (BOOL)insertPersonContactWithPersons:(NSArray *)persons {
//    if ([persons count] == 0) {
//        return NO;
//    }
//
//    __block BOOL result = YES;
//    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
//#if DEBUG
//        db.logsErrors = YES;
//#endif
//        [persons enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
//            PersonDataModel *person = obj;
//
//            if (person.personId.length > 0 && [person.contactArray count] > 0) {
//                NSString *sql = nil;
//                if ([self personExist:person.personId db:db]) {
//                    sql = [NSString stringWithFormat:@"UPDATE %@\nSET personName = ?, defaultPhone = ?, department =?, jobTitle =?, photoUrl =?, status =?, fullPinyin =?, wbUserId =?, isAdmin =?, eid =?, oid =?, contact =?\nWHERE\n\tpersonId = ?;", TABLE_T9_PERSON];
////                    result = [db executeUpdate:sql, person.personName, person.defaultPhone, person.department, person.jobTitle, person.photoUrl, [NSNumber numberWithInt:person.status], person.fullPinyin, person.wbUserId, @(person.isAdmin ? 1 : 0), person.eid, person.oid, [person contactsJSONString], person.personId];
//                }
//                else {
//                    sql = [NSString stringWithFormat:@"INSERT\nOR REPLACE INTO %@ (\n\tpersonId,\n\tpersonName,\n\tdefaultPhone,\n\tdepartment,\n\tjobTitle,\n\tphotoUrl,\n\tstatus,\n\tfullPinyin,\n\twbUserId,\n\tisAdmin,\n\teid,\n\toid,\n\tcontact\n)\nVALUES\n\t(\n\t\t?,?,?,?,?,?,?,?,?,?,?,?,?\n\t);", TABLE_T9_PERSON];
////                    result = [db executeUpdate:sql, person.personId, person.personName, person.defaultPhone, person.department, person.jobTitle, person.photoUrl, [NSNumber numberWithInt:person.status], person.fullPinyin, person.wbUserId, @(person.isAdmin ? 1 : 0), person.eid, person.oid, [person contactsJSONString]];
//                }
//            }
//        }];
//    }];
////  const NSString *personTableParams = @"(\n\t\'id\' INTEGER PRIMARY KEY AUTOINCREMENT DEFAULT NULL, \n\t\'personId\' VARCHAR DEFAULT NULL, \n\t\'personName\' VARCHAR, \n\t\'defaultPhone\' VARCHAR, \n\t\'department\' VARCHAR, \n\t\'fullPinyin\' VARCHAR, \n\t\'photoUrl\' VARCHAR, \n\t\'status\' INTEGER DEFAULT 0, \n\t\'jobTitle\' VARCHAR,\n\t\'note\' VARCHAR, \n\t\'reply\' VARCHAR, \n\t\'subscribe\' VARCHAR, \n\t\'canUnsubscribe\' VARCHAR, \n\t\'menu\' VARCHAR, \n\t\'wbUserId\' VARCHAR,\n\t\'isAdmin\' INTEGER DEFAULT (0),\n\t\'share\' INTEGER DEFAULT (1)\n);";
//    return result;
//}
//
// 插入标记
- (BOOL)insertMarks:(NSArray *)marks {
    if ([marks count] == 0) {
        return NO;
    }
    __block BOOL result = YES;
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        [marks enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
            KDMarkModel *model = obj;
            NSString *sql = nil;
            sql = [NSString stringWithFormat:@"INSERT\nOR REPLACE INTO %@ (\nid,\ntitle,\ntitleDesc,\nheadUrl,\ntype,\ntext,\nimgUrl,\nicon,\nheader,\nuri,\nupdateTime,\nhumanReadableUpdateTime\n)\nVALUES\n(\n?,?,?,?,?,?,?,?,?,?,?,?\n);", TABLE_MARK];
            result = [db executeUpdate:sql, model.id, model.title, model.titleDesc, model.headUrl, @(model.type), model.text, model.imgUrl, model.icon, model.header, model.uri, model.updateTime, model.humanReadableUpdateTime];
        }];
    }];
    return result;
}
// 标记和日历事件关联表
- (BOOL)insertMarkEventWithMarkId:(NSString *)markId eventId:(NSString *)eventId {
    if (markId.length == 0 || eventId.length == 0) {
        return NO;
    }
    __block BOOL result = YES;
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = [NSString stringWithFormat:@"INSERT\nOR REPLACE INTO %@ (\nmarkId,\neventId\n)\nVALUES\n(\n?,?\n);", TABLE_MARK_EVENT];
        result = [db executeUpdate:sql, markId, eventId];
    }];
    return result;
}
// 清空标记表
- (BOOL)clearMarkTable {
    __block BOOL result = NO;
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@;", TABLE_MARK]];
    }];
    return result;
}
// 删除标记
- (BOOL)deleteMarkWithMarkId:(NSString *)markId {
    __block BOOL result = YES;
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id=?;",TABLE_MARK];
        result = [db executeUpdate:sql, markId];
    }];
    return result;
}


- (GroupDataModel *)queryTodoMsgInXT
{
    __block GroupDataModel *group = nil;
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = [NSString stringWithFormat:@"SELECT\n\t*\nFROM\n\t%@\nWHERE\n\tgroupId LIKE '%%XT-10001%%';", TABLE_GROUP];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            group = [self loadGroupWithResultSet:rs];
            [self queryParticipant:group db:db];
        }
    }];
    return group;
}

// 查询标记分页
- (NSArray *)queryMarksFromUpdateTime:(NSString *)lastUpdateTime pageCount:(int)page {
    NSMutableArray *mArray = [NSMutableArray array];
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString * sql = [NSString stringWithFormat:@"SELECT\na.id,\na.title,\na.titleDesc,\na.headUrl,\na.type,\na.text,\na.imgUrl,\na.icon,\na.header,\na.uri,\na.updateTime,\na.humanReadableUpdateTime,\nb.eventId\nFROM\n%@ AS a\n", TABLE_MARK];
        
        sql = [sql stringByAppendingFormat:@"LEFT JOIN %@ AS b \nON\na.id = b.markId\n", TABLE_MARK_EVENT];
        if (lastUpdateTime.length > 0) {
            sql = [sql stringByAppendingFormat:@"WHERE a.updateTime < %@\n", lastUpdateTime];
        }
        if (page > 0) {
            sql = [sql stringByAppendingFormat:@"LIMIT %d", page];
        }
        
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]) {
            KDMarkModel *model = [[KDMarkModel alloc] initWithDict:nil];
            model.id = [rs stringForColumn:@"id"];
            model.title = [rs stringForColumn:@"title"];
            model.titleDesc = [rs stringForColumn:@"titleDesc"];
            model.headUrl = [rs stringForColumn:@"headUrl"];
            model.type = [rs intForColumn:@"type"];
            model.text = [rs stringForColumn:@"text"];
            model.imgUrl = [rs stringForColumn:@"imgUrl"];
            model.icon = [rs stringForColumn:@"icon"];
            model.header = [rs stringForColumn:@"header"];
            model.uri = [rs stringForColumn:@"uri"];
            model.updateTime = [rs stringForColumn:@"updateTime"];
            model.humanReadableUpdateTime = [rs stringForColumn:@"humanReadableUpdateTime"];
            model.localEventId = [rs stringForColumn:@"eventId"];
            [mArray addObject:model];
        }
        [rs close];
    }];
    
    return mArray;
}

- (NSArray *)searchTodoMsgWithSearchText:(NSString *)searchText type:(NSUInteger)todoType lastMsgId:(NSString *)lastMsgId
{
    NSMutableArray *result = [NSMutableArray array];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *todoStatusSql = nil;
        switch (todoType) {
            case 0:
                
                todoStatusSql = @"todoStatus = 'undo'";
                
                break;
            case 1:
                
                todoStatusSql = @"todoStatus = 'done'";
                
                break;
            case 2:
                
                todoStatusSql = @"(todoStatus is null OR todoStatus = '')";
                
                break;
                
            default:
                break;
        }
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ Where (title like '%%%@%%' or content like '%%%@%%' or text like '%%%@%%') AND %@ ORDER BY sendTime DESC LIMIT 20",TABLE_TODO,searchText,searchText,searchText,todoStatusSql];
        if(lastMsgId.length > 0)
        {
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ Where (title like '%%%@%%' or content like '%%%@%%' or text like '%%%@%%') AND %@ AND sendTime < (select sendTime from %@ where msgId = '%@') ORDER BY sendTime DESC LIMIT 20",TABLE_TODO,searchText,searchText,searchText,todoStatusSql,TABLE_TODO,lastMsgId];
        }
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]) {
            KDToDoMessageDataModel *record = [[KDToDoMessageDataModel alloc] init];
            record.msgId = [rs stringForColumn:@"msgId"];
            record.XTMsgId = [rs stringForColumn:@"xtMsgId"];
            record.fromUserId = [rs stringForColumn:@"fromUserId"];
            record.sendTime = [rs stringForColumn:@"sendTime"];
            record.msgType = [rs intForColumn:@"msgType"];
            record.msgLen = [rs intForColumn:@"msgLen"];
            record.content = [rs stringForColumn:@"content"];
            record.status = [rs intForColumn:@"status"];
            record.msgDirection = [rs intForColumn:@"direction"];
            record.msgRequestState = [rs intForColumn:@"requestType"];
            record.nickname = [rs stringForColumn:@"fromUserNickName"];
            record.score = [rs stringForColumn:@"score"];
            NSString *paramString = [rs stringForColumn:@"param"];
            if (paramString.length > 0)
            {
                MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithJSONString:paramString type:record.msgType];
                record.param = param;
            }
            record.iNotifyType = [rs intForColumn:@"notifyType"];
            record.strNotifyDesc = [rs stringForColumn:@"notifyDesc"];
            record.strEmojiType = [rs stringForColumn:@"emojiType"];
            record.sourceMsgId = [rs stringForColumn:@"sourceMsgId"];
            record.readState = [rs stringForColumn:@"readState"];
            record.todoStatus = [rs stringForColumn:@"todoStatus"];
            
            record.appid = [rs stringForColumn:@"appid"];
            record.date = [rs stringForColumn:@"date"];
            record.name = [rs stringForColumn:@"name"];
            record.row = [rs stringForColumn:@"row"];
            record.text = [rs stringForColumn:@"text"];
            record.title = [rs stringForColumn:@"title"];
            record.url = [rs stringForColumn:@"url"];
            record.model = [rs stringForColumn:@"messageMode"];
            
            
            if ([record.model isEqualToString:@"4"])
            {
                record.cellType = KDToDoCellType_Operate_Hide;
            }
            else
            {
                record.cellType = KDToDoCellType_NotOperateAble;
            }
            
            [result addObject:record];
        }
        [rs close];
    }];
    return result;
}

- (BOOL)updateUndoMsgWithId:(NSString *)msgId
{
    __block BOOL state = NO;
    
    //存在且更新成功则yes
    if ([self checkExitUndoMsg:msgId]) {
        [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
            db.logsErrors = YES;
#endif
            NSString *update = [NSString stringWithFormat:@"Update %@ Set todoStatus = ? Where msgId = ?;",TABLE_TODO];
            state = [db executeUpdate:update, @"done", msgId];
        }];
        
    }
    //不存在则no
    return state;
}
-(BOOL)checkExitUndoMsg:(NSString *)msgId
{
    __block BOOL result = NO;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE  msgId = '%@'  AND todoStatus = 'undo';",TABLE_TODO,msgId]];
        while ([rs next])
        {
            
            result = YES;
        }
        
        [rs close];
    }];
    
    return result;
    
}

#pragma mark - 签到提醒 -

- (BOOL)addSignInRemindWithRemindId:(NSString *)remindId isRemind:(BOOL)isRemind remindTime:(NSString *)remindTime repeatType:(NSInteger)repeatType
{
    __block BOOL result = YES;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (remindId,isRemind,remindTime,repeatType) VALUES (?,?,?,?);",TABLE_SIGNINREMIND];
        result = [db executeUpdate:update,remindId,[NSString stringWithFormat:@"%d",isRemind?1:0], remindTime,@(repeatType)];
    }];
    
    return result;
}

- (BOOL)addSignInRemindList:(NSArray *)remindList
{
    __block BOOL result = NO;
    
    [self.databaseQueue inTransaction: ^(FMDatabase *db, BOOL *rollback) {
#if DEBUG
        db.logsErrors = YES;
#endif
        
        [remindList enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
            
            KDSignInRemind *remind = (KDSignInRemind *)obj;
            
            NSString *insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (remindId,isRemind,remindTime,repeatType) VALUES (?,?,?,?);",TABLE_SIGNINREMIND];
            [db executeUpdate:insert, remind.remindId,[NSString stringWithFormat:@"%d", remind.isRemind ? 1 : 0], remind.remindTime, @(remind.repeatType)];
            
        }];
        
        result = !db.hadError;
    }];
    
    return result;
}

- (BOOL)updateSignInRemindWithRemindId:(NSString *)remindId isRemind:(BOOL)isRemind remindTime:(NSString *)remindTime repeatType:(NSInteger)repeatType
{
    __block BOOL result = YES;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"Update %@ Set isRemind = ?,remindTime = ?,repeatType = ? Where remindId = ?;",TABLE_SIGNINREMIND];
        result = [db executeUpdate:update,[NSString stringWithFormat:@"%d",isRemind?1:0], remindTime,@(repeatType),remindId];
    }];
    
    return result;
}

- (NSArray *)querySignInRemind{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY remindTime;", TABLE_SIGNINREMIND];
    
    __block NSMutableArray *array = [NSMutableArray new];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
#if DEBUG
        db.logsErrors = YES;
#endif
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next])
        {
            KDSignInRemind *remind = [KDSignInRemind new];
            
            remind.remindId = [rs stringForColumn:@"remindId"];
            remind.remindTime = [rs stringForColumn:@"remindTime"];
            remind.repeatType = [rs intForColumn:@"repeatType"];
            remind.isRemind = [[rs stringForColumn:@"isRemind"] integerValue] == 1 ? YES : NO;
            [array addObject:remind];
            
        }
        [rs close];
    }];
    
    return array;
    
}

- (BOOL)deleteSignInRemindWithRemindId:(NSString *)remindId
{
    __block BOOL result = YES;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"DELETE FROM %@ where remindId=?;",TABLE_SIGNINREMIND];
        result = [db executeUpdate:update,remindId];
    }];
    
    return result;
    
}

- (BOOL)deleteAllSignInRemind
{
    __block BOOL result = YES;
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *update = [NSString stringWithFormat:@"DELETE FROM %@;",TABLE_SIGNINREMIND];
        result = [db executeUpdate:update];
    }];
    
    return result;
    
}


- (NSInteger)queryGroupLastUpdateScoreWithGroupId:(NSString *)groupId;
{
    if(groupId.length == 0 ){
        return nil;
    }
    
    __block NSInteger lastUpdateScore = 0;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = [NSString stringWithFormat:@"SELECT lastUpdateScore FROM %@ \nWHERE groupId = ?;",TABLE_GROUP];
        FMResultSet *rs = [db executeQuery:sql,groupId];
        if ([rs next]) {
            lastUpdateScore = [[rs stringForColumn:@"lastUpdateScore"]integerValue];
        }
        [rs close];
    }];
    return lastUpdateScore;
}

- (NSInteger)queryGroupLocalUpdateScoreWithGroupId:(NSString *)groupId
{
    if(groupId.length == 0 ){
        return nil;
    }
    
    __block NSInteger localUpdateScore = 0;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *sql = [NSString stringWithFormat:@"SELECT localUpdateScore FROM %@ \nWHERE groupId = ?;",TABLE_GROUP];
        FMResultSet *rs = [db executeQuery:sql,groupId];
        if ([rs next]) {
            localUpdateScore = [[rs stringForColumn:@"localUpdateScore"] integerValue];
        }
        [rs close];
    }];
    return localUpdateScore;
}

- (void)updateGroupLocalUpdateScoreWithGroupId:(NSString *)groupId updateScore:(NSString*) updateScore
{
    if(groupId.length == 0 || updateScore.length == 0){
        return ;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *updateScoreSql = [NSString stringWithFormat:@"Update %@ Set localUpdateScore = ? Where groupId = ?;",TABLE_GROUP];
        result = [db executeUpdate:updateScoreSql,updateScore,groupId];
    }];
}

- (NSMutableArray *)queryGroupParticipateWithGroupId:(NSString *)groupId
{
    __block NSMutableArray *paticipantId = [NSMutableArray new];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"select personId from %@ Where groupId = ?;",TABLE_PARTICIPANT];
        
        FMResultSet *rs = [db executeQuery:sql,groupId];
        while ([rs next]) {
            
            [paticipantId addObject:[rs stringForColumn:@"personId"]];
        }
        [rs close];
    }];
    return paticipantId;
}
- (NSMutableArray *)queryGroupParticipatePersonsWithIds:(NSArray *)participantIds
{
    __block NSMutableArray *paticipant = [NSMutableArray new];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [participantIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PersonSimpleDataModel *person  = [self loadPersonWithPersonId:(NSString *)obj db:db];
            if (person) {
                [paticipant addObject:person];
            }
            
        }];
    }];
    return paticipant;
}

- (void)updateGroupParticipantWithGroupId:(NSString *)groupId participantIdArray:(NSArray *)participantIds
{
    if(participantIds.count == 0){
        return ;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
#if DEBUG
        db.logsErrors = YES;
#endif
        NSString *participantId  = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:participantIds options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        NSString *updateScoreSql = [NSString stringWithFormat:@"Update %@ Set participantIds = ? Where groupId = ?;",TABLE_GROUP];
        result = [db executeUpdate:updateScoreSql,participantId,groupId];
    }];
}

- (PersonSimpleDataModel *)loadPersonWithPersonId:(NSString *)personId db:(FMDatabase *)db
{
    PersonSimpleDataModel *person = nil;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT id,personId,personName,defaultPhone,fullPinyin,photoUrl,status,department,jobTitle,wbUserId,isAdmin \
                     ,subscribe,canUnsubscribe,note,reply,menu,share,partnerType,oid,orgId,gender \
                     FROM %@ Where personId = ?;",TABLE_T9_PERSON];
    
    FMResultSet *rs = [db executeQuery:sql,personId];
    if ([rs next]) {
        
        person = [[PersonSimpleDataModel alloc] init];
        
        [person setUserId:[rs intForColumnIndex:0]];
        [person setPersonId:[rs stringForColumnIndex:1]];
        [person setPersonName:[rs stringForColumnIndex:2]];
        [person setDefaultPhone:[rs stringForColumnIndex:3]];
        [person setFullPinyin:[rs stringForColumnIndex:4]];
        [person setPhotoUrl:[rs stringForColumnIndex:5]];
        [person setStatus:[rs intForColumnIndex:6]];
        [person setDepartment:[rs stringForColumnIndex:7]];
        [person setJobTitle:[rs stringForColumnIndex:8]];
        [person setWbUserId:[rs stringForColumnIndex:9]];
        [person setIsAdmin:([rs intForColumnIndex:10] == 1)];
        person.subscribe = [rs stringForColumnIndex:11];
        person.canUnsubscribe = [rs stringForColumnIndex:12];
        person.note = [rs stringForColumnIndex:13];
        person.reply = [rs stringForColumnIndex:14];
        person.menu = [rs stringForColumnIndex:15];
        person.share = [rs intForColumnIndex:16];
        person.partnerType = [rs intForColumnIndex:17];
        
        person.oid = [rs stringForColumn:@"oid"];
        person.orgId = [rs stringForColumn:@"orgId"];
        person.gender = [rs intForColumn:@"gender"];
    }
    [rs close];
    
    return person;
}
@end

