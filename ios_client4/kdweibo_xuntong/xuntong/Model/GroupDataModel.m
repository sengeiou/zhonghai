//
//  GroupListDataModel.m
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "GroupDataModel.h"
#import "PersonSimpleDataModel.h"
#import "RecordDataModel.h"
#import "NSDictionary+Additions.h"
#import "KDCacheHelper.h"
#import "KDAgoraSDKManager.h"
#import "BOSConfig.h"

@implementation GroupDataModel

-(id)init
{
    self = [super init];
    if (self) {
        _groupId = [[NSString alloc] init];
        _groupType = GroupTypeDouble;
        _groupName = [[NSString alloc] init];
        _participant = [[NSMutableArray alloc] init];
        _unreadCount = 0;
        _lastMsg = [[RecordDataModel alloc] init];
        _status = 3;
        _lastMsgId = [[NSString alloc] init];
        _lastMsgSendTime = [[NSString alloc] init];
        _menu=[[NSString alloc] init];
        _updateTime = [[NSString alloc] init];
        _fold = YES;
        //_draft = [[NSString alloc]init];
        _participantIds = [[NSMutableArray alloc] init];
        _managerIds = [[NSArray alloc] init];
        _lastIgnoreNotifyScore = 0;
        _updateScore = 0;
        _userCount = 0;
    }
    return self;
}

-(id)initWithParticipantId:(PersonSimpleDataModel *)participant
{
    self = [self init];
    if (self) {
        if (participant.personId) {
            [self.participantIds addObject:participant.personId];
        }
    }
    return self;
}

-(id)initWithParticipant:(PersonSimpleDataModel *)participant
{
    self = [self init];
    if (self) {
        
        [self.participant addObject:participant];
    }
    return self;
}


-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id groupId = [dict objectForKey:@"groupId"];
        if (![groupId isKindOfClass:[NSNull class]] && groupId) {
            self.groupId = groupId;
        }
        
        id groupType = [dict objectForKey:@"groupType"];
        if (![groupType isKindOfClass:[NSNull class]] && groupType) {
            self.groupType = [groupType intValue];
        }
        
        id groupName = [dict objectForKey:@"groupName"];
        if (![groupName isKindOfClass:[NSNull class]] && groupName) {
            self.groupName = groupName;
        }
        
        
        id managerIds = [dict objectForKey:@"managerIds"];
        if (![managerIds isKindOfClass:[NSNull class]] && managerIds) {
            if ([managerIds isKindOfClass:[NSArray class]]) {
                self.managerIds = managerIds;
            }
        }
        id mCallStatus = [dict objectForKey:@"mcallStatus"];
        if(![mCallStatus isKindOfClass:[NSNull class]] && mCallStatus)
        {
            self.mCallStatus = [mCallStatus integerValue];
        }else{
            self.mCallStatus = 0;
        }
        
        //grouplist participant 字段已废弃 706 participantIds第一次才有值
        id participantIds = [dict objectForKey:@"participantIds"];
        
        //为了兼容创建组保留这个字段706
        id participant = [dict objectForKey:@"participant"];
        if (![participant isKindOfClass:[NSNull class]] && participant ) {
            for (id persoDic in participant) {
                PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:persoDic];
                [self.participantIds addObject:person.personId];
                [self.participant addObject:person];
            }
        }
       
        
        
        if (![participantIds isKindOfClass:[NSNull class]] && participantIds && [participantIds isKindOfClass:[NSArray class]]) {
            self.participantIds = [NSMutableArray arrayWithArray:participantIds];
//            NSArray *participants = [NSMutableArray array];
//            NSMutableArray *participantsIds = [NSMutableArray array];
            self.participant = [[NSMutableArray alloc]initWithArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonIds:participantIds]];
            for (id each in participantIds) {
                PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPersonWithPersonId:each];
                // 若后台修改了公共号的分享状态，则需要更新数据库
                if ([person isPublicAccount]) {
                    PersonSimpleDataModel *cachePubPerson = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicAccountWithId:person.personId];
                    if (cachePubPerson && cachePubPerson.share != person.share) {
                        [[XTDataBaseDao sharedDatabaseDaoInstance] updatePublicPersonSimpleSetShareStatus:person.share withPersonId:person.personId];
                    }
                }
            
//                [participants addObject:person];
//                [participantsIds addObject:person.personId];
            }
        
//            //为了做兼容
//            if (self.participantIds == nil || !([self.participantIds count] > 0)) {
//                self.participantIds = participantsIds;
//            }
        }
        
        id unreadCount = [dict objectForKey:@"unreadCount"];
        if (![unreadCount isKindOfClass:[NSNull class]] && unreadCount) {
            self.unreadCount = [unreadCount intValue];
            if ([unreadCount intValue] < 0) {
                self.unreadCount = 0;
            }
        }
        
        id lastMsg = [dict objectForKey:@"lastMsg"];
        if (![lastMsg isKindOfClass:[NSNull class]] && lastMsg) {
            RecordDataModel *record = [[RecordDataModel alloc] initWithDictionary:lastMsg];
            self.lastMsg = record;
        }
    
        id manager = [dict objectForKey:@"manager"];
        if (![manager isKindOfClass:[NSNull class]] && manager) {
            self.manager = [manager intValue];
        }
        
        id status = [dict objectForKey:@"status"];
        if (![status isKindOfClass:[NSNull class]] && status) {
            self.status = [status intValue];
        }
        
        id lastMsgId = [dict objectForKey:@"lastMsgId"];
        if (![lastMsgId isKindOfClass:[NSNull class]] && lastMsgId != nil) {
            self.lastMsgId = lastMsgId;
        }
        id lastMsgSendTime = [dict objectForKey:@"lastMsgSendTime"];
        if (![lastMsgSendTime isKindOfClass:[NSNull class]] && lastMsgSendTime != nil) {
            self.lastMsgSendTime = lastMsgSendTime;
        }
        
        id fold = [dict objectForKey:@"fold"];
        if (![fold isKindOfClass:[NSNull class]] && fold != nil) {
            self.fold = [fold boolValue];
        }
        
        id headerUrl = [dict objectForKey:@"headerUrl"];
        if (![headerUrl isKindOfClass:[NSNull class]] && headerUrl != nil) {
            self.headerUrl = headerUrl;
        }
        
        id partnerType = [dict objectForKey:@"partnerType"];
        if (![partnerType isKindOfClass:[NSNull class]] && partnerType != nil) {
            self.partnerType = [partnerType integerValue];
        }
        
        id dissolveDate = [dict objectForKey:@"dissolveDate"];
        if (![dissolveDate isKindOfClass:[NSNull class]] && dissolveDate != nil) {
            self.dissolveDate = dissolveDate;
        }
        
        id updateScore = [dict objectForKey:@"updateScore"];
        if (![updateScore isKindOfClass:[NSNull class]] && updateScore != nil) {
            self.updateScore = [updateScore integerValue];
        }
        
        id userCount = [dict objectForKey:@"userCount"];
        if (![userCount isKindOfClass:[NSNull class]] && userCount != nil) {
            self.userCount = [userCount integerValue];
        }
        NSDictionary *dictParam = [dict objectNotNSNullForKey:@"param"];
        if (dictParam) {
            self.param = dictParam;
        }
        
        self.lastMsgDesc = [self lastMsgDescWithRecord:self.lastMsg];
    }
    return self;
}
- (NSString *)lastMsgDescWithRecord:(RecordDataModel *)record {
    NSString *content = nil;
    
    if (record.content.length > 0) {
        if (record.msgType == MessageTypeEvent) {
            content = @"";
        }
        else {
            content = record.content;
        }
    }
    else if (record.msgType == MessageTypeSpeech) {
        content = ASLocalizedString(@"KDPublicTopCell_Voice");
    }
    else if (record.msgType == MessageTypePicture) {
        content = ASLocalizedString(@"KDPublicTopCell_Pic");
    }
    // 点对点对话。 即2个人对话时，不需要显示对方名字.
    NSMutableString *messageText = [NSMutableString string];
    
    if (content.length > 0) {
        if (self.groupType != GroupTypeDouble && record.msgType != MessageTypeSystem) {
            if (record.nickname.length > 0) {
                if(self.groupType != GroupTypePublic)
                {
                    [messageText appendString:record.nickname];
                    [messageText appendString:@":"];
                }
            }
            else {
                if ([[BOSConfig sharedConfig].user.userId isEqualToString:record.fromUserId]) {
                    [messageText appendString:[NSString stringWithFormat:@"%@:",ASLocalizedString(@"KDMeVC_me")]];
                }
                else {
                    if (record.fromUserId.length > 0) {
                        PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPublicAccountWithId:record.fromUserId];
                        if (!person) {
                            person = [self participantForKey:record.fromUserId];
                        }
                        if (person && ![person isPublicAccount] && person.personName.length > 0) {
                            [messageText appendString:person.personName];
                            [messageText appendString:@":"];
                        }
                    }
                }
            }
        }
        [messageText appendString:[content dz_stringByTrimmingWhitespaceAndNewlines]];
    }
    
    return messageText;
}


- (NSTimeInterval)lastMCallStartTimeInterval
{
    return [self getMCallStartTimeInterval];
}

- (NSString *)mCallCreator
{
    _mCallCreator = [self.param objectNotNSNullForKey:@"mcallCreator"];
    
    return _mCallCreator;
}

- (NSInteger)micDisable
{
    if(self.param)
    {
        id micDisable = [self.param objectNotNSNullForKey:@"micDisable"];
        if(micDisable)
        {
            _micDisable = [micDisable integerValue];
        }else{
            _micDisable = 0;
        }
    }else{
        _micDisable = 0;
    }
    return _micDisable;
}

- (NSInteger)recordStatus
{
    if(self.param)
    {
        id recordStatus = [self.param objectNotNSNullForKey:@"recordStatus"];
        if(recordStatus)
        {
            _recordStatus = [recordStatus integerValue];
        }else{
            _recordStatus = 0;
        }
    }else{
        _recordStatus = 0;
    }
    return _recordStatus;
}

- (NSInteger)undoCount
{
    if(self.param)
    {
        id undoCount = [self.param objectNotNSNullForKey:@"undoCount"];
        if(undoCount)
        {
            _undoCount = [undoCount integerValue];
        }else{
            _undoCount = 0;
        }
    }else{
        _undoCount = 0;
    }
    return _undoCount;
}

- (NSInteger)notifyUnreadCount
{
    if(self.param)
    {
        id notifyUnreadCount = [self.param objectNotNSNullForKey:@"notifyUnreadCount"];
        if(notifyUnreadCount)
        {
            _notifyUnreadCount = [notifyUnreadCount integerValue];
        }else{
            _notifyUnreadCount = 0;
        }
    }else{
        _notifyUnreadCount = 0;
    }
    return _notifyUnreadCount;
}

- (NSInteger)lastIgnoreNotifyScore
{
    if(self.param)
    {
        id lastIgnoreNotifyScore = [self.param objectNotNSNullForKey:@"lastIgnoreNotifyScore"];
        if(lastIgnoreNotifyScore)
        {
            _lastIgnoreNotifyScore = [lastIgnoreNotifyScore integerValue];
        }else{
            _lastIgnoreNotifyScore = 0;
        }
    }else{
        _lastIgnoreNotifyScore = 0;
    }
    return _lastIgnoreNotifyScore;
}
#pragma mark - method
- (PersonSimpleDataModel *)firstParticipant {
    if ([self.participantIds count] == 0) {
        return nil;
    }
    
    NSString *participantId = [self.participantIds firstObject];
    return [KDCacheHelper personForKey:participantId];
}

- (PersonSimpleDataModel *)participantForKey:(NSString *)key {
    if (key.length == 0) {
        return nil;
    }
    return [KDCacheHelper personForKey:key];
}

- (BOOL)isPublicGroup{
    return _participant.count == 1 && [[_participant firstObject] isPublicAccount];
}

- (BOOL)isExternalGroup {
    if (self.groupId.length == 0) {
        return self.participantIds.count == 1 && [[self.participantIds firstObject] isExternalPerson];
    }
    return [self.groupId isExternalGroup];
}

- (BOOL)isManager {
    if ([self.managerIds count] == 0) {
        return NO;
    }
    
    if ([self.managerIds containsObject:[BOSConfig sharedConfig].user.userId]) {
        return YES;
    }
    
    if ([self.managerIds containsObject:[BOSConfig sharedConfig].user.wbUserId]) {
        return YES;
    }
    
    if ([self.managerIds containsObject:[[BOSConfig sharedConfig].user externalPersonId]]) {
        return YES;
    }
    return NO;
}

- (BOOL)chatAvailable
{
    BOOL result = NO;
    switch (self.groupType) {
        case GroupTypeSubGroup:
        case GroupTypePublicNoInteractive:
        case GroupTypeMessageNotification:
            result = NO;
            break;
        case GroupTypePublicMany:
        case GroupTypePublic:
        {
            PersonSimpleDataModel *person = [self.participant lastObject];
            
            //文件传输助手
            if([person.personId isEqualToString:kFilePersonId])
                return YES;
            
            result = self.status & 1;
            if (result)
            {
                if (person != nil)
                {
                    result = [person accountAvailable];
                }
            }

            //前者判断是公共号，后者判断是公共号发言人跟用户会话
            return  ([person.personId hasPrefix:@"XT"]?(person.state == 2):YES) && (person.reply?[person.reply boolValue]:YES) && result;
        }
            break;
        case GroupTypeMany:
            result = self.status & 1;
            if (result) {
                for (PersonSimpleDataModel *person in self.participant) {
                    result = [person accountAvailable];
                    if (result) {
                        break;
                    }
                }
            }
            break;
        case GroupTypeDouble:
            result = self.status & 1;
            if (result) {
                PersonSimpleDataModel *person = [self.participant lastObject];
                if (person != nil) {
                    result = [person accountAvailable];
                }
//            if (result) {
//                NSString *personId = [self.participantIds firstObject];
//                if (personId != nil) {
//                    PersonSimpleDataModel *person = [KDCacheHelper personForKey:personId];
//                    result = [person accountAvailable];
//                }
            }
            break;
        default:
            break;
    }
    
    return result;
}

- (BOOL)actionAvailable
{
    return [self chatAvailable];
}

- (BOOL)pushOpened
{
    return (self.status >> 1) & 1;
}

- (void)togglePush
{
    self.status ^= 0x2;
}

- (BOOL)isTop
{
    return (self.status >> 2) & 1;
}

- (void)toggleTop
{
    self.status ^= 0x4;
}


- (BOOL)isFavorite
{
    return (self.status >> 3) & 1;
}

- (void)toggleFavorite
{
    self.status ^= 0x8;
}

- (BOOL)qrCodeOpened
{
    return (self.status >> 7) & 1;
}

- (void)toggleQRCode
{
    self.status ^= 0x80;
}

- (BOOL)slienceOpened
{
    return (self.status >> 8) & 1;
}

- (void)toggleslience
{
    self.status ^= 0x100;
}

- (BOOL)abortAddPersonOpened
{
    return (self.status >> 6) & 1;
}

- (void)toggleAbortAddPerson
{
    self.status ^= 0x40;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[GroupDataModel class]]) {
        return NO;
    }
    GroupDataModel *group = (GroupDataModel *)object;
    return [self.groupId isEqualToString:group.groupId];
}

- (KDAgoraMultiCallGroupType)getAgoraMultiCallGroup
{
    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
    if(self.mCallStatus == 1)
    {
        if(agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel && [agoraSDKManager.currentGroupDataModel.groupId isEqualToString:self.groupId])
        {
            return KDAgoraMultiCallGroupType_joined;
        }else if([self chatAvailable]){
            return  KDAgoraMultiCallGroupType_noJoined;
        }else
        {
            return KDAgoraMultiCallGroupType_none;
        }
    }else{
        return KDAgoraMultiCallGroupType_none;
    }
}

- (NSString *)getChannelId
{
    if(self.param)
    {
        NSString *channelId= self.param[@"channelId"];
        if(channelId)
        {
            return channelId;
        }
    }
    return self.groupId;
}

- (NSTimeInterval)getMCallStartTimeInterval
{
    id startTime = [self.param objectNotNSNullForKey:@"lastMCallStartTime"];
    NSTimeInterval startTimeInterval = 0;
    if(startTime)
    {
        startTimeInterval = [startTime longLongValue];
    }
    if(startTimeInterval == 0)
    {
        startTime = [self.param objectNotNSNullForKey:@"mcallStartTime"];
        if(startTime)
        {
            startTimeInterval = [startTime longLongValue];
        }
    }
    return startTimeInterval;
}


//临时封装成person
-(PersonSimpleDataModel *)packageToPerson
{
    PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] init];
    person.personId = self.groupId;
    person.personName = self.groupName;
    person.photoUrl = self.headerUrl;
    person.partnerType = self.partnerType;
    person.status = 15;
    person.group = self;
    return person;
}

- (int)iNotifyType {
    NSString *strNotifyType = [self.param objectNotNSNullForKey:@"notifyType"];
    
    if (strNotifyType) {
        _iNotifyType = strNotifyType.intValue;
    }
    return _iNotifyType;
}

// 是否有@提及
- (BOOL)isNotifyTypeAt {
    return self.iNotifyType == 1;
    
}

// 是否有新公告
- (BOOL)isNotifyTypeNotice {
    return self.iNotifyType == 4;
}


-(BOOL)allowInnerShare
{
    if(self.groupType >= GroupTypePublic && self.groupType <= GroupTypeTodo)
    {
        PersonSimpleDataModel *person = [self.participant firstObject];
        if(!person)
            person = self.firstParticipant;
        return [person allowInnerShare];
    }
    else
    {
        return [[BOSSetting sharedSetting] allowMsgInnerMobileShare];
    }
}


-(BOOL)allowOuterShare
{
    if(self.groupType >= GroupTypePublic && self.groupType <= GroupTypeTodo)
    {
        PersonSimpleDataModel *person = [self.participant firstObject];
        if(!person)
            person = self.firstParticipant;
        return [person allowOuterShare];
    }
    else
    {
        return [[BOSSetting sharedSetting] allowMsgOuterMobileShare];
    }
}

@end
