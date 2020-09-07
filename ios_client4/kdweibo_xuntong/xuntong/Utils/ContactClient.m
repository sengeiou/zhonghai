//
//  ContactClient.m
//  ContactsLite
//
//  Created by kingdee eas on 12-11-20.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "ContactClient.h"
#import "BOSSetting.h"
#import "BOSConfig.h"
#import "KDWeiboServicesContext.h"
#import "KDConfigurationContext.h"

@implementation ContactClient

-(NSDictionary *)header
{
    NSString *openToken = [BOSConfig sharedConfig].user.token;
    if (!openToken) {
        openToken = @"";
    }
    return [NSDictionary dictionaryWithObject:openToken forKey:@"openToken"];
}

#pragma mark - method

// 以下为测试接口
-(void)sendLogFileWithPhone:(NSString *)phone upload:(NSData *)file fileName:(NSString *)fileName contentType:(NSString *)contentType logType:(NSString *)logType
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:safeString(phone) forKey:@"phone"];
    [params setObject:safeString(fileName) forKey:@"uploadFileName"];
    [params setObject:safeString(contentType) forKey:@"uploadContentType"];
    [params setObject:safeString(logType) forKey:@"logType"];
    if (file) {
        [params setObject:file forKey:@"upload"];
    }
    [super post:@"xuntong/ecLite/convers/sendLogFile.action" body:params header:[self header]];
}

-(void)personSearchWithWord:(NSString *)word begin:(int)iBegin count:(int)iCount isFilter:(BOOL)isFilter
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (iBegin < 0) {
        iBegin = 0;
    }
    [params setObject:[NSString stringWithFormat:@"%d",iBegin] forKey:@"begin"];
    if (iCount < 0) {
        iCount = 0;
    }
    //    [params setObject:[NSString stringWithFormat:@"%d",iCount] forKey:@"count"];
    [params setObject:[super checkNullOrNil:word] forKey:@"word"];
    // isFilter表示是否过滤还未生成账号(无wbUserId)的未激活人员
    [params setObject:isFilter?@"1":@"0" forKey:@"isfilter"];
    [super post:EMPSERVERURL_LITESEARCH body:params header:[self header]];
}

-(void)personNewSearchWithWord:(NSString *)word begin:(int)iBegin count:(int)iCount isFilter:(BOOL)isFilter
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (iBegin < 0) {
        iBegin = 0;
    }
    [params setObject:[NSString stringWithFormat:@"%d",iBegin] forKey:@"begin"];
    if (iCount < 0) {
        iCount = 0;
    }
    //    [params setObject:[NSString stringWithFormat:@"%d",iCount] forKey:@"count"];
    [params setObject:[super checkNullOrNil:word] forKey:@"word"];
    // isFilter表示是否过滤还未生成账号(无wbUserId)的未激活人员
    [params setObject:isFilter?@"1":@"0" forKey:@"isfilter"];
    [super post:EMPSERVERURL_searchPage body:params header:[self header]];
}

-(void)getFavoriteListWithID:(NSString *)ID begin:(int)iBegin count:(int)iCount {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:ID] forKey:@"id"];
    if (iBegin < 0) {
        iBegin = 0;
    }
    [params setObject:[NSString stringWithFormat:@"%d",iBegin] forKey:@"begin"];
    if (iCount < 0) {
        iCount = 0;
    }
    [params setObject:[NSString stringWithFormat:@"%d",iCount] forKey:@"count"];
    [super post:EMPSERVERURL_FAVORLIST body:params header:[self header]];
}

-(void)toFavorWithID:(NSString *)ID flag:(int)flag {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:ID] forKey:@"id"];
    if (flag < 0) {
        flag = 0;
    }
    [params setObject:[NSString stringWithFormat:@"%d",flag] forKey:@"flag"];
    [super post:EMPSERVERURL_FAVOR body:params header:[self header]];
}

- (void)getTotalUnreadNum {
    [super post:EMPSERVERURL_UNREADTOTAL body:nil header:[self header]];
}

- (void)checkNeedUpdateWithUpdatetime:(NSString *)updateTime pubUpdateTime:(NSString *)pubUpdateTime pubAccount:(NSDictionary *)pubAccount
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:updateTime] forKey:@"updateTime"];
    [params setObject:[super checkNullOrNil:pubUpdateTime] forKey:@"pubUpdateTime"];
    if (pubAccount != nil) {
        [params setObject:pubAccount forKey:@"pubAccount"];
    }
    [self setBaseUrlString:[BOSSetting sharedSetting].url];
    [super post:EMPSERVERURL_NEEDUPDATE body:params header:[self header]];
}

//- (void)unreadCountWithUserIds:(NSArray *)userIds updatetime:(NSString *)updateTime pubAcctUpdateTime:(NSString *)pubAcctUpdateTime
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
//    [params setObject:[super checkNullOrNil:updateTime] forKey:@"updateTime"];
//    if ([userIds count] > 0) {
//        [params setObject:userIds forKey:@"userId"];
//    }
//    if (pubAcctUpdateTime.length > 0) {
//        [params setObject:pubAcctUpdateTime forKey:@"pubAcctUpdateTime"];
//    }
//    [self setBaseUrlString:[BOSSetting sharedSetting].url];
//    [super post:EMPSERVERURL_UNREADCOUNT body:params header:[self header]];
//}

- (void)unreadCountWithUserIds:(NSArray *)userIds
                    updatetime:(NSString *)updateTime
             pubAcctUpdateTime:(NSString *)pubAcctUpdateTime
         msgLastReadUpdateTime:(NSString *)msgLastReadUpdateTime
          msgLastDelUpdateTime:(NSString *)msgLastDelUpdateTime
       lastCleanDataUpdateTime:(NSString *)lastCleanDataUpdateTime
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:updateTime] forKey:@"updateTime"];
    if ([userIds count] > 0) {
        
        //userId
        if ([userIds count] > 0)
        {
            [params setObject:userIds forKey:@"userId"];
        }
        
        //pubAcctUpdateTime
        if (pubAcctUpdateTime.length > 0)
        {
            [params setObject:pubAcctUpdateTime forKey:@"pubAcctUpdateTime"];
        }
        
        //msgLastReadUpdateTime
        if (msgLastReadUpdateTime == nil || msgLastReadUpdateTime.length == 0)
        {
            [params setObject:@"" forKey:@"msgLastReadUpdateTime"];
        }
        else
        {
            [params setObject:msgLastReadUpdateTime forKey:@"msgLastReadUpdateTime"];
        }
        
        
        //msgLastDelUpdateTime
        if ( msgLastDelUpdateTime.length > 0)
        {
            [params setObject:msgLastDelUpdateTime forKey:@"msgLastDelUpdateTime"];
            
        }
        else
        {
            [params setObject:@"" forKey:@"msgLastDelUpdateTime"];
        }
        //lastClearDataUpdateTime
        if ( lastCleanDataUpdateTime.length > 0)
        {
            [params setObject:lastCleanDataUpdateTime forKey:@"lastClearDataUpdateTime"];
            
        }
        else
        {
            //zgbin:
            [params setObject:@"" forKey:@"lastCleanDataUpdateTime"];
        }
        
        //zgbin:加角标
        if ([BOSConfig sharedConfig].user.eid.length > 0) {
            [params setObject:[BOSConfig sharedConfig].user.eid forKey:@"eId"];
        } else {
            [params setObject:@"" forKey:@"eId"];
        }
        if ([BOSConfig sharedConfig].user.phone.length > 0) {
            [params setObject:[BOSConfig sharedConfig].user.phone forKey:@"account"];
        } else {
            [params setObject:@"" forKey:@"account"];
        }
        [params setObject:@"1012244" forKey:@"appIds"];
        //zgbin:end
        
        [params setObject:[XTSetting sharedSetting].groupExitUpdateTime forKey:@"groupExitUpdateTime"];
        
        
        [super post:EMPSERVERURL_UNREADCOUNT body:params header:[self header]];
    }
}

-(void)update:(NSString *)lastUpdateTime
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (lastUpdateTime) {
        [params setObject:lastUpdateTime forKey:@"lastUpdateTime"];
    }
    [super post:EMPSERVERURL_UPDATE body:params header:[self header]];
}

-(void)update2:(NSString *)lastUpdateTime
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (lastUpdateTime) {
        [params setObject:lastUpdateTime forKey:@"lastUpdateTime"];
    }
    [super post:EMPSERVERURL_UPDATE2 body:params header:[self header]];
}

#pragma mark - private mode

- (void)getGroupListWithUpdateTime:(NSString *)lastUpdateTime
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[super checkNullOrNil:lastUpdateTime] forKey:@"lastUpdateTime"];
    [params setObject:@(YES) forKey:@"useMS"];
    [super post:EMPSERVERURL_GROUPLIST body:params header:[self header]];
}

- (void)getGroupListWithUpdateTime:(NSString *)lastUpdateTime offset:(NSInteger)offset count:(NSInteger)count;{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[super checkNullOrNil:lastUpdateTime] forKey:@"lastUpdateTime"];
    [params setObject:[NSString stringWithFormat:@"%ld",(long)offset] forKey:@"offset"];
    [params setObject:[NSString stringWithFormat:@"%ld",(long)count] forKey:@"count"];
    [params setObject:@(YES) forKey:@"useMS"];
    [super post:EMPSERVERURL_GROUPLIST body:params header:[self header]];
    
}


- (void)getRecordTimeLineWithGroupID:(NSString *)groupID userId:(NSString *)userId updateTime:(NSString *)lastUpdateTime
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:groupID] forKey:@"groupId"];
    [params setObject:[super checkNullOrNil:userId] forKey:@"userId"];
    [params setObject:[super checkNullOrNil:lastUpdateTime] forKey:@"lastUpdateTime"];
    [super post:EMPSERVERURL_RECORDTIMELINE body:params header:[self header]];
}

- (void)toSendMsgWithGroupID:(NSString *)groupID toUserID:(NSString *)toUserID msgType:(int)msgType content:(NSString *)content msgLent:(int)msgLen param:(NSString *)param clientMsgId:(NSString *)clientMsgId
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    [params setObject:[super checkNullOrNil:groupID] forKey:@"groupId"];
    [params setObject:[super checkNullOrNil:toUserID] forKey:@"toUserId"];
    
    if (msgType < 0) {
        msgType = 0;
    }
    [params setObject:[NSString stringWithFormat:@"%d",msgType] forKey:@"msgType"];
    [params setObject:[super checkNullOrNil:content] forKey:@"content"];
    
    if (msgLen < 0) {
        msgLen = 0;
    }
    [params setObject:[NSString stringWithFormat:@"%d",msgLen] forKey:@"msgLen"];
    
    if (param != nil) {
        [params setObject:param forKey:@"param"];
    }
    [params setObject:[super checkNullOrNil:clientMsgId] forKey:@"clientMsgId"];
    
    [super post:EMPSERVERURL_MESSAGESEND body:params header:[self header]];
}

- (void)getContentWithMsgID:(NSString *)msgID {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:msgID] forKey:@"msgId"];
    [super post:EMPSERVERURL_GETCONTENT body:params header:[self header]];
}

- (void)getPersonInfoWithPersonID:(NSString *)personID type:(NSString *)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:personID] forKey:@"id"];
    if (type) {
        [params setObject:type forKey:@"type"];
    }
    [super post:EMPSERVERURL_PERSONINFO body:params header:[self header]];
}

-(void)inviteUser:(NSString *)userId sms:(int)sms
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[super checkNullOrNil:userId] forKey:@"userId"];
    [params setObject:[NSString stringWithFormat:@"%d",sms] forKey:@"sms"];
    [super post:EMPSERVERURL_INVITE body:params header:[self header]];
}

-(void)sendFileWithGroupId:(NSString *)groupId toUserId:(NSString *)toUserId msgType:(int)msgType msgLen:(int)msgLen upload:(NSData *)file fileExt:(NSString *)fileExt param:(NSString *)param clientMsgId:(NSString *)clientMsgId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
    if (groupId) {
        [params setObject:groupId forKey:@"groupId"];
    }
    if (toUserId) {
        [params setObject:toUserId forKey:@"toUserId"];
    }
    [params setObject:[NSString stringWithFormat:@"%d",msgType] forKey:@"msgType"];
    [params setObject:[NSString stringWithFormat:@"%d",msgLen] forKey:@"msgLen"];
    if (file) {
        [params setObject:file forKey:@"upload"];
    }
    if (fileExt) {
        [params setObject:fileExt forKey:@"fileExt"];
    }
    if (param != nil) {
        [params setObject:param forKey:@"param"];
    }
    [params setObject:[super checkNullOrNil:clientMsgId] forKey:@"clientMsgId"];
    [super post:EMPSERVERURL_SENDFILE body:params header:[self header]];
}

-(void)getFileWithMsgId:(NSString *)msgId groupId:(NSString *)groupId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [super post:EMPSERVERURL_GETFILE body:params header:[self header]];
}

#pragma mark - public mode

- (void)publicGroupList:(NSString *)publicId updateTime:(NSString *)lastUpdateTime
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:publicId] forKey:@"publicId"];
    [params setObject:[super checkNullOrNil:lastUpdateTime] forKey:@"lastUpdateTime"];
    [super post:EMPSERVERURL_PUBLIC_GROUPLIST body:params header:[self header]];
}

- (void)publicRecordTimeline:(NSString *)publicId groupId:(NSString *)groupId updateTime:(NSString *)lastUpdateTime
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:publicId] forKey:@"publicId"];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:[super checkNullOrNil:lastUpdateTime] forKey:@"lastUpdateTime"];
    [super post:EMPSERVERURL_PUBLIC_RECORDTIMELINE body:params header:[self header]];
}


- (void)publicRecordHistory:(NSString *)publicId andLastDate:(NSString *)lastDate
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    //    [params setObject:[super checkNullOrNil:[BOSSetting sharedSetting].cust3gNo] forKey:@"current3gNo"];
    [params setObject:[BOSConfig sharedConfig].user.userId forKey:@"currentUserId"];
    [params setObject:[super checkNullOrNil:publicId] forKey:@"pubaccId"];
    [params setObject:@(10) forKey:@"pageSize"];
    [params setObject:lastDate?lastDate:@"" forKey:@"lastUpdateTime"];
    [super post:EMPSERVERURL_PUBLIC_HISTORY body:params header:[self header]];
}


- (void)publicSendWithGroupId:(NSString *)groupId publicId:(NSString *)publicId msgType:(int)msgType content:(NSString *)content msgLent:(int)msgLen clientMsgId:(NSString *)clientMsgId
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:[super checkNullOrNil:publicId] forKey:@"publicId"];
    
    if (msgType < 0) {
        msgType = 0;
    }
    [params setObject:[NSString stringWithFormat:@"%d",msgType] forKey:@"msgType"];
    [params setObject:[super checkNullOrNil:content] forKey:@"content"];
    
    if (msgLen < 0) {
        msgLen = 0;
    }
    [params setObject:[NSString stringWithFormat:@"%d",msgLen] forKey:@"msgLen"];
    [params setObject:[super checkNullOrNil:clientMsgId] forKey:@"clientMsgId"];
    [super post:EMPSERVERURL_PUBLIC_SEND body:params header:[self header]];
}

-(void)publicGetContent:(NSString *)publicId msgId:(NSString *)msgId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:publicId] forKey:@"publicId"];
    [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
    [super post:EMPSERVERURL_PUBLIC_GETCONTENT body:params header:[self header]];
}

-(void)publicSendFileWithPublicId:(NSString *)publicId groupId:(NSString *)groupId toUserId:(NSString *)toUserId msgType:(int)msgType msgLen:(int)msgLen upload:(NSData *)file fileExt:(NSString *)fileExt clientMsgId:(NSString *)clientMsgId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:7];
    if (publicId) {
        [params setObject:publicId forKey:@"publicId"];
    }
    if (groupId) {
        [params setObject:groupId forKey:@"groupId"];
    }
    if (toUserId) {
        [params setObject:toUserId forKey:@"toUserId"];
    }
    [params setObject:[NSString stringWithFormat:@"%d",msgType] forKey:@"msgType"];
    [params setObject:[NSString stringWithFormat:@"%d",msgLen] forKey:@"msgLen"];
    if (file) {
        [params setObject:file forKey:@"upload"];
    }
    if (fileExt) {
        [params setObject:fileExt forKey:@"fileExt"];
    }
    [params setObject:[super checkNullOrNil:clientMsgId] forKey:@"clientMsgId"];
    [super post:EMPSERVERURL_PUBLIC_SENDFILE body:params header:[self header]];
}

-(void)publicGetFileWithPublicId:(NSString *)publicId msgId:(NSString *)msgId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    if (publicId) {
        [params setObject:publicId forKey:@"publicId"];
    }
    [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
    [super post:EMPSERVERURL_PUBLIC_GETFILE body:params header:[self header]];
}

//********/群组/********//

- (void)creatGroupWithUserIds:(NSArray *)ids groupName:(NSString *)groupName{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [params setObject:ids forKey:@"userIds"];
    if (groupName.length > 0) {
        [params setObject:groupName forKey:@"groupName"];
    }
    
    [super post:EMPSERVERURL_CREATGROUP body:params header:[self header]];
}//创建群组

- (void)addGroupUserWithGroupId:(NSString *)groupId userIds:(NSArray *)ids{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [params setObject:groupId forKey:@"groupId"];
    [params setObject:ids forKey:@"userIds"];
    [params setObject:@"false" forKey:@"returnParticipantsDetail"];
    [super post:EMPSERVERURL_ADDGROUPUSER body:params header:[self header]];
}//添加成员
- (void)delGroupUserWithGroupId:(NSString *)groupId userId:(NSArray *)idstr{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [params setObject:groupId forKey:@"groupId"];
    [params setObject:idstr forKey:@"userId"];
    [params setObject:@"false" forKey:@"returnParticipantsDetail"];
    [super post:EMPSERVERURL_DELGROUPUSER body:params header:[self header]];
}//删除成员

- (void)updateGroupNameWithGroupID:(NSString *)groupID groupName:(NSString *)groupName{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:groupID forKey:@"groupId"];
    [params setObject:groupName forKey:@"name"];
    [super post:EMPSERVERURL_UPDATEGROUPNAME body:params header:[self header]];
}//更新组名
- (void)delHistoryRecordWithGoupID:(NSString *)groupID{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:groupID forKey:@"groupId"];
    
    [super post:EMPSERVERURL_DELHISTORYRECORD body:params header:[self header]];
}//删除记录
- (void)markAllReadWithGroupID:(NSString *)groupID{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:groupID forKey:@"groupId"];
    [super post:EMPSERVERURL_MARKALLREAD body:params header:[self header]];
}//标记已读

// 会话组置顶
- (void)toggleGroupTopWithGroupId:(NSString *)groupID status:(NSInteger)status
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:groupID forKey:@"groupId"];
    [params setObject:[NSString stringWithFormat:@"%ld", (long)status] forKey:@"status"];
    [super post:EMPSERVERURL_TOGGLEGROUPTOP body:params header:[self header]];
}

//********/群组/********//

//-(void)getSmallImageWithMsgId:(NSString *)msgId
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
//    [params setObject:@"90" forKey:@"width"];
//    [params setObject:@"90" forKey:@"height"];
//    [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
//    [super post:EMPSERVERURL_GETIMAGE body:params header:[self header]];
//}
//
//-(void)getBigImageWithMsgId:(NSString *)msgId imageWith:(NSString*)weith imageHeight:(NSString*)height
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
//    [params setObject:weith forKey:@"width"];
//    [params setObject:height forKey:@"height"];
//    [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
//    [super post:EMPSERVERURL_GETIMAGE body:params header:[self header]];
//}
//
//-(void)publicGetSmallImageWithPublicId:(NSString *)publicId msgId:(NSString *)msgId
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
//    [params setObject:@"90" forKey:@"width"];
//    [params setObject:@"90" forKey:@"height"];
//    if (publicId) {
//        [params setObject:publicId forKey:@"publicId"];
//    }
//    [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
//    [super post:EMPSERVERURL_PUBLIC_GETIMAGE body:params header:[self header]];
//}
//
//-(void)publicGetBigImageWithPublicId:(NSString *)publicId msgId:(NSString *)msgId
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
//    [params setObject:@"640" forKey:@"width"];
//    [params setObject:@"1096" forKey:@"height"];
//    if (publicId) {
//        [params setObject:publicId forKey:@"publicId"];
//    }
//    [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
//    [super post:EMPSERVERURL_PUBLIC_GETIMAGE body:params header:[self header]];
//}

-(void)togglePushWithGroupId:(NSString *)groupId status:(int)status
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:[NSString stringWithFormat:@"%d",status] forKey:@"status"];
    [super post:EMPSERVERURL_TOGGLEPUSH body:params header:[self header]];
}

-(void)toggleFavoriteWithGroupId:(NSString *)groupId status:(int)status
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:[NSString stringWithFormat:@"%d",status] forKey:@"status"];
    [super post:EMPSERVERURL_TOGGLEFAVORITE body:params header:[self header]];
}

-(void)toggleQRCodeWithGroupId:(NSString *)groupId status:(int)status
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:[NSString stringWithFormat:@"%d",status] forKey:@"status"];
    [super post:EMPSERVERURL_TOGGLEQRCODE body:params header:[self header]];
}

//- (void)orgTreeInfoWithOrgId:(NSString *)orgId eid:(NSString *)eid
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
//    [params setObject:@"123456" forKey:@"token"];
//    [params setObject:[super checkNullOrNil:eid] forKey:@"eid"];
//    [params setObject:[super checkNullOrNil:orgId] forKey:@"orgId"];
//    [params setObject:[NSNumber numberWithInt:0] forKey:@"begin"];
//    [params setObject:[NSNumber numberWithInt:0] forKey:@"count"];
//    [super post:EMPSERVERURL_ORGTREEINFO body:params header:[self header]];
//}

- (void)orgTreeInfoWithOrgId:(NSString *)orgId andPartnerType:(NSInteger)partnerType isFilter:(BOOL)isFilter
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[super checkNullOrNil:orgId] forKey:@"orgId"];
    [params setObject:@(partnerType==1?1:0) forKey:@"partnerType"];
    // isFilter表示是否过滤还未生成账号(无wbUserId)的未激活人员
    [params setObject:isFilter?@"1":@"0" forKey:@"isfilter"];
    [super post:EMPSERVERURL_ORGTREEINFO body:params header:[self header]];
}

- (void)share:(NSString *)version
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[super checkNullOrNil:version] forKey:@"version"];
    [super post:EMPSERVERURL_SHARE body:params header:[self header]];
}

- (void)delGroupWithGroupId:(NSString *)groupId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [super post:EMPSERVERURL_DELGROUP body:params header:[self header]];
}

- (void)delMessageWithGroupId:(NSString *)groupId msgId:(NSString *)msgId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
    [super post:EMPSERVERURL_DELMESSAGE body:params header:[self header]];
}

- (void)delMessageWithPublicId:(NSString *)publicId groupId:(NSString *)groupId msgId:(NSString *)msgId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:publicId] forKey:@"publicId"];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
    [super post:EMPSERVERURL_PUBLIC__DELMESSAGE body:params header:[self header]];
}
- (void)cancelMessageWithGroupId:(NSString *)groupId msgId:(NSString *)msgId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
    [params setObject:[NSString stringWithFormat:@"%zi",[[BOSSetting sharedSetting] canCancelMessage]] forKey:@"canCancelMsgMin"];
    [super post:EMPSERVERURL_CANCELMSG body:params header:[self header]];
}

- (void)cancelMessageWithPublicId:(NSString *)publicId groupId:(NSString *)groupId msgId:(NSString *)msgId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:publicId] forKey:@"publicId"];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
    [super post:EMPSERVERURL_PUBLIC_CANCELMSG body:params header:[self header]];
}

//搜索会话文本信息
- (void)searchTextRecordListWithWord:(NSString *)textWord Page:(int)page Count:(int)count
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (textWord != nil && ![textWord isKindOfClass:[NSNull class]])
    {
        [params setObject:textWord forKey:@"word"];
    }
    
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    
    [params setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    
    [super post:EMPSERVERURL_SEARCHTEXTRECORDLIST body:params header:[self header]];
}

//多方通话的状态变更通知接口
- (void)startOrStopMyCallWithGroupId:(NSString *)groupId status:(NSInteger)status channelId:(NSString *)channelId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (groupId != nil && ![groupId isKindOfClass:[NSNull class]])
    {
        [params setObject:groupId forKey:@"groupId"];
    }
    [params setObject:@(status) forKey:@"status"];
    if(status == 0 && channelId)
    {
        [params setObject:channelId forKey:@"channelId"];
    }
    if(status == 1)
    {
        [KDEventAnalysis event:event_Voicon_start];
    }
    [super post:EMPSERVERURL_MYCALL body:params header:[self header]];
}

- (void)queryGroupInfoWithGroupId:(NSString *)groupId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (groupId != nil && ![groupId isKindOfClass:[NSNull class]])
    {
        [params setObject:groupId forKey:@"groupId"];
    }
    
    [super post:EMPSERVERURL_GROUPINFO body:params header:[self header]];
}

-(void)stopMuteMyCallWithGroupId:(NSString *)groupId
                          status:(NSInteger)status
                       channelId:(NSString *)channelId
                      micDisable:(NSInteger)micDisable
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (groupId != nil && ![groupId isKindOfClass:[NSNull class]])
    {
        [params setObject:groupId forKey:@"groupId"];
    }
    [params setObject:@(status) forKey:@"status"];
    if(status == 0 && channelId)
    {
        [params setObject:channelId forKey:@"channelId"];
    }
    if(status == 1)
    {
        [KDEventAnalysis event:event_Voicon_start];
    }
    
    [params setObject:@(micDisable) forKey:@"micDisable"];
    [super post:EMPSERVERURL_MYCALL body:params header:[self header]];
    
}

- (void)mCallRecordStateChangedWithGroundId:(NSString *)groupId
                                     status:(NSInteger)status
                                  channelId:(NSString *)channelId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (groupId != nil && ![groupId isKindOfClass:[NSNull class]])
    {
        [params setObject:groupId forKey:@"groupId"];
    }
    [params setObject:@(status) forKey:@"status"];
    
    
    [params setObject:channelId forKey:@"channelId"];
    [super post:EMPSERVERURL_MCALLRECORD body:params header:[self header]];
}



//搜索会话文件信息
- (void)searchFileRecordListWithWord:(NSString *)textWord Page:(int)page Count:(int)count
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (textWord != nil && ![textWord isKindOfClass:[NSNull class]])
    {
        [params setObject:textWord forKey:@"word"];
    }
    
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    
    [params setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    
    [super post:EMPSERVERURL_SEARCHFILERECORDLIST body:params header:[self header]];
}

//获取消息已读未读列表
- (void)getMessageUreadListWithLastUpdateTime:(NSString *)lastUpdateTime
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (lastUpdateTime == nil || lastUpdateTime == 0)
    {
        [params setObject:@"" forKey:@"lastUpdateTime"];
    }
    else
    {
        [params setObject:[super checkNullOrNil:lastUpdateTime] forKey:@"lastUpdateTime"];
    }
    
    [super post:EMPSERVERURL_MSGREADLIST body:params header:[self header]];
}

- (void)getMessageUreadDetailWithGroupId:(NSString *)groupId MsgId:(NSString *)msgId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (groupId != nil && ![groupId isKindOfClass:[NSNull class]])
    {
        [params setObject:groupId forKey:@"groupId"];
    }
    
    if (msgId != nil && ![msgId isKindOfClass:[NSNull class]])
    {
        [params setObject:msgId forKey:@"messageId"];
    }
    
    [super post:EMPSERVERURL_MSGREADDETAIL body:params header:[self header]];
}

-(void)notifyUnreadUsersWithGroupId:(NSString *)groupId MsgId:(NSString *)msgId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (groupId != nil && ![groupId isKindOfClass:[NSNull class]])
    {
        [params setObject:groupId forKey:@"groupId"];
    }
    
    if (msgId != nil && ![msgId isKindOfClass:[NSNull class]])
    {
        [params setObject:msgId forKey:@"messageId"];
    }
    
    [super post:EMPSERVERURL_NOTIFYUNREADUSERS body:params header:[self header]];
}



- (void)getExitGroupsWithLastUpdateTime:(NSString *)lastUpdateTime
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:lastUpdateTime forKey:@"lastUpdateTime"];
    [super post:EMPSERVERURL_GETEXITGROUPS body:params header:[self header]];
}

- (void)getMsgListWithGroupId:(NSString *)groupId
                       userId:(NSString *)userId
                        msgId:(NSString *)msgId
                         type:(NSString *)type
                        count:(NSString *)count
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:safeString(groupId) forKey:@"groupId"];
    [params setObject:safeString(userId) forKey:@"userId"];
    [params setObject:safeString(msgId) forKey:@"msgId"];
    [params setObject:safeString(type) forKey:@"type"];
    [params setObject:safeString(count) forKey:@"count"];
    [params setObject:@(YES) forKey:@"useMS"];
    [super post:EMPSERVERURL_MSGLIST body:params header:[self header]];
}

- (void)getPublicSpeakerMsgListWithGroupId:(NSString *)groupId
                                    userId:(NSString *)userId
                                     msgId:(NSString *)msgId
                                      type:(NSString *)type
                                     count:(NSString *)count
                                  publicId:(NSString *)publicId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:safeString(publicId) forKey:@"publicId"];
    [params setObject:safeString(groupId) forKey:@"groupId"];
    [params setObject:safeString(userId) forKey:@"userId"];
    [params setObject:safeString(msgId) forKey:@"msgId"];
    [params setObject:safeString(type) forKey:@"type"];
    [params setObject:safeString(count) forKey:@"count"];
    [params setObject:@(YES) forKey:@"useMS"];
    [super post:EMPSERVERURL_PUBLIC_SPEAKER_MSGLIST body:params header:[self header]];
}

#pragma mark - super

-(id)initWithTarget:(id)target action:(SEL)action
{
    //gil wait BOSConnect4DirectURL EMPServer上了之后要改回BOSConnect4ActionParam
    BOSConnectFlags connectFlags = {BOSConnect4DirectURL,BOSConnectNotEncryption,BOSConnectResponseAllowCompressed,BOSConnectRequestBodyNotCompressed,NO};
    //    if ([BOSConfig sharedConfig].bSecurity) {
    //        connectFlags._securityType = BOSConnectEncryption;
    //        //设置加密Key
    //        [super setDesKey:[BOSConfig sharedConfig].secretKey];
    //    }
    self = [super initWithTarget:target action:action connectionFlags:connectFlags];
    if (self) {
        [super setBaseUrlString:[BOSSetting sharedSetting].url];
    }
    return self;
}
// 转让管理员
- (void)transferManagerWithGroupId:(NSString *)groupId managerId:(NSString *)managerId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:[super checkNullOrNil:managerId] forKey:@"managerId"];
    [super post:EMPSERVERURL_TRANSFERMANAGER body:params header:[self header]];
}

- (void)getPerSonAuthorityWithGroupId:(NSString *)groupId;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [super post:EMPSERVERURL_GETPERSONAUTHORITY body:params header:[self header]];
}
- (void)getPerSonAuthorityWithPersonIds:(NSArray *)personIds;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if ([personIds count] > 0) {
        [params setObject:personIds forKey:@"userIds"];
    }
    [super post:EMPSERVERURL_GETPERSONAUTHORITY body:params header:[self header]];
}
- (void)getCloudPassportWithUserId:(NSString *)userId;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[super checkNullOrNil:userId] forKey:@"userId"];
    
    KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
    NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
    [self setBaseUrlString:baseURL];
    [super post:SNSAPI_CLOUDPASSPORT body:params header:[self header]];
}
//获取勿扰状态
- (void)getDoNorDisturb
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [super post:EMPSERVERURL_GETDONORDISTURB body:params header:[self header]];
}
//设置勿扰时间
- (void)updateDoNotDisturbWithEnable:(BOOL)enable from:(NSString *)fromTime to:(NSString *)toTime
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (enable)
    {
        [params setObject:[NSNumber numberWithInteger:1] forKey:@"enable"];
    }
    else
    {
        [params setObject:[NSNumber numberWithInteger:0] forKey:@"enable"];
    }
    [params setObject:fromTime forKey:@"from"];
    [params setObject:toTime forKey:@"to"];
    [super post:EMPSERVERURL_UPDATEDONORDISTURB body:params header:[self header]];
}

// 获取真实消息内容
- (void)getNotraceMsgInfoWithGroupId:(NSString *)groupId msgId:(NSString *)msgId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:safeString(groupId) forKey:@"groupId"];
    [params setObject:safeString(msgId) forKey:@"msgId"];
    [super post:EMPSERVERURL_MSGINFO body:params header:[self header]];
}

// 删除真实消息内容
- (void)deleteNotraceMsgInfoWithGroupId:(NSString *)groupId msgId:(NSString *)msgId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:safeString(groupId) forKey:@"groupId"];
    [params setObject:safeString(msgId) forKey:@"msgId"];
    [super post:EMPSERVERURL_DELMSG body:params header:[self header]];
}
- (void)getExitGroupListWithlLastUpdateTime:(NSString *)lastUpdateTime
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[super checkNullOrNil:lastUpdateTime] forKey:@"lastUpdateTime"];
    [super post:EMPSERVERURL_EXITGROUPLIST body:params header:[self header]];
    
}

- (void)getTodoMsgListWithGroupId:(NSString *)groupId
                           userId:(NSString *)userId
                            msgId:(NSString *)msgId
                             type:(NSString *)type
                            score:(NSString *)score
                         todoType:(NSString *)todoType
                            count:(NSString *)count
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:safeString(groupId) forKey:@"groupId"];
    [params setObject:safeString(userId) forKey:@"userId"];
    [params setObject:safeString(msgId) forKey:@"msgId"];
    [params setObject:safeString(type) forKey:@"type"];
    [params setObject:safeString(todoType) forKey:@"todoType"];
    [params setObject:safeString(score) forKey:@"score"];
    [params setObject:safeString(count) forKey:@"count"];
    [params setObject:@(YES) forKey:@"useMS"];
    [super post:EMPSERVERURL_TODOMSGLIST body:params header:[self header]];
}

- (void)hasDelMsgWithLastUpdateTime:(NSString *)lastUpdateTime
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:lastUpdateTime forKey:@"lastUpdateTime"];
    [params setObject:@(YES) forKey:@"useMS"];
    [super post:EMPSERVERURL_HASMSGDEL body:params header:[self header]];
    
}
//解散群组
- (void)dissolveGroupWithGroupId:(NSString *)groupId {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [params setObject:safeString(groupId) forKey:@"groupId"];
    [super post:EMPSERVERURL_DISSOLVEGROUP body:params header:[self header]];
}

- (void)setGroupStatusWithGroupId:(NSString *)groupId
                              key:(NSString *)key
                            value:(int)value {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:[super checkNullOrNil:key] forKey:@"key"];
    [params setObject:@(value) forKey:@"value"];
    [super post:EMPSERVERURL_SETGROUPSTATUS body:params header:[self header]];
}
- (void)searchTodoMsgWithGroupId:(NSString *)groupId
                           msgId:(NSString *)msgId
                           count:(NSInteger)count
                        todoType:(NSString*)type
                        criteria:(NSString*)keyWord
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:safeString(groupId) forKey:@"groupId"];
    [params setObject:safeString(msgId) forKey:@"msgId"];
    [params setObject:safeString(type) forKey:@"todoType"];
    [params setObject:[NSString stringWithFormat:@"%ld",(long)count] forKey:@"count"];
    [params setObject:safeString(keyWord) forKey:@"criteria"];
    [super post:EMPSERVERURL_SEARCHTODOMSG body:params header:[self header]];
}
- (void)verifyMsgStatusWithGroupId:(NSString *)groupId
                            userId:(NSString *)userId
                             msgId:(NSString *)msgId
                        todoStatus:(NSString *)todoStatus
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (groupId.length > 0) {
        [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    }
    if (userId.length > 0) {
        [params setObject:[super checkNullOrNil:userId] forKey:@"userId"];
    }
    if (msgId.length > 0) {
        [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
    }
    if (todoStatus.length > 0) {
        [params setObject:[super checkNullOrNil:todoStatus] forKey:@"todoStatus"];
    }
    [super post:verifyMsgStatus body:params header:[self header]];
}

- (void)ignoreUndoMessageWithGroupId:(NSString *)groupId MsgId:(NSString *)msgId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:[super checkNullOrNil:msgId] forKey:@"msgId"];
    [super post:IGNOREUNDOMSG body:params header:[self header]];
}

- (void)markedNotifyMsgReadWithGroupId:(NSString *)groupId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:@"notify" forKey:@"todoType"];
    [super post:MARKEDNOTIFYMSG body:params header:[self header]];
}

- (void)getPersonsWithWBUserIds:(NSArray *)ids{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [params setObject:ids forKey:@"userIds"];
    
    [super post:EMPSERVERURL_GETPERSONSBYWBUSERIDS body:params header:[self header]];
}

- (void)getRelatePersonsWithLastPersonScore:(NSString *)lastPersonScore
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:lastPersonScore] forKey:@"lastPersonScore"];
    [params setObject:@"100" forKey:@"count"];
    [super post:GETRELATEDPERSONS body:params header:[self header]];
}
- (void)getGroupUsersWithGroupId:(NSString *)groupId LastPersonScore:(NSString*)lastPersonScore
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:[super checkNullOrNil:lastPersonScore] forKey:@"lastUpdateScore"];
    [params setObject:[super checkNullOrNil:groupId] forKey:@"groupId"];
    [params setObject:@"200" forKey:@"count"];
    [super post:EMPSERVERURL_GETGROUPUSERS body:params header:[self header]];
}

@end

