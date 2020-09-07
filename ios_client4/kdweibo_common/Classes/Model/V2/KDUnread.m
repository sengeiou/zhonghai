//
//  KDUnread.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-20.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDUnread.h"
#import "KDCommunity.h"
#import "KDManagerContext.h"
#import "KDSession.h"
#import "KDWeiboDAOManager.h"
#import "KDDatabaseHelper.h"
#import "KDWeiboServicesContext.h"

#define KD_LAST_GROUP_STATUS_UNREAD_DATE    @"kd.groupstatus.unread_date"
#define KD_LAST_GROUP_STATUS_UNREAD         @"kd.groupstatus.unread"
#define KD_LAST_INBOX_UNREAD_DATE           @"kd.inbox.unread_date"
#define KD_LAST_INBOX_UNREAD                @"kd.inbox.unread"

@implementation KDUnread
@synthesize communityId=communityId_;

@synthesize newStatus=newStatus_;
@synthesize publicStatuses=publicStatuses_;
@synthesize friendsStatuses=friendsStatuses_;

@synthesize mentions=mentions_;
@synthesize comments=comments_;
@synthesize directMessages=directMessages_;

@synthesize followers=followers_;
@synthesize members=members_;

@synthesize notices=notices_;

@synthesize groupStatuses=groupStatuses_;
@synthesize communityUnreads=communityUnreads_;
@synthesize communityNotices=communityNotices_;
@synthesize functions = fuctions_;
@synthesize newVersion = newVersion_;

@synthesize lastVisitorName = lastVisitorName_;
@synthesize lastVisitType = lastVisitType_;
@synthesize inboxTotal = inboxTotal_;
@synthesize latestGroupMsgContent = latestGroupMsgContent_;
@synthesize latestGroupMsgDate = latestGroupMsgDate_;
@synthesize latestInboxMsgContent = latestInboxMsgContent_;
@synthesize latestInboxMsgDate = latestInboxMsgDate_;
@synthesize inviteTotal = inviteTotal_;
@synthesize latestStatusMsgHeadUrl = latestStatusMsgHeadUrl_;

- (id)init {
    self = [super init];
    if (self) {
        fuctions_ = [KDCommon initNewFunctionFlag];
        newVersion_ = [KDCommon hasNewClientVersion] ? 1 : 0;
    }
    
    return self;
}

- (NSInteger)countForKey:(NSString *)key inDataSource:(NSDictionary *)dataSource {
    if(key != nil && dataSource != nil){
        NSNumber *count = [dataSource objectForKey:key];
        if(count != nil){
            return [count unsignedIntegerValue];
        }
    }
    
    return 0;
}

- (void)resetKey:(NSString *)key inDataSource:(NSMutableDictionary *)dataSource {
    if(dataSource != nil && key != nil && [dataSource objectForKey:key] != nil){
        [dataSource setObject:[NSNumber numberWithInteger:0] forKey:key];
    }
}

- (NSInteger)allUnreadCountInDataSource:(NSDictionary *)dataSource {
    NSInteger count = 0;
    if(dataSource != nil && [dataSource count] > 0){
        NSArray *values = [dataSource allValues];
        for(NSNumber *item in values){
            count += [item integerValue];
        }
    }
    
    return count;
}

- (NSInteger)unreadForGroupId:(NSString *)groupId {
    return [self countForKey:groupId inDataSource:groupStatuses_];
}

- (void)resetUnreadWithGroupId:(NSString *)groupId {
    [self resetKey:groupId inDataSource:groupStatuses_];
}

- (void)resetAllGroupUnreadCount {
    [self setGroupStatuses:nil];
}
- (NSInteger)groupsAllUnreadCount {
    return [self allUnreadCountInDataSource:groupStatuses_];
}

- (NSInteger)unreadForCommunityId:(NSString *)communityId {
    return [self countForKey:communityId inDataSource:communityUnreads_];
}

- (void)resetUnreadWithCommunityId:(NSString *)communityId {
    [self resetKey:communityId inDataSource:communityUnreads_];
}

- (NSInteger)communitiesAllUnreadCount {
    return [self allUnreadCountInDataSource:communityUnreads_];
}

- (NSInteger)noticeForCommunityId:(NSString *)communityId {
    return [self countForKey:communityId inDataSource:communityNotices_];
}

- (void)resetNoticeWithCommunityId:(NSString *)communityId {
    [self resetKey:communityId inDataSource:communityNotices_];
}

- (NSInteger)communitiesAllNoticeCount {
    return [self allUnreadCountInDataSource:communityNotices_];
}

- (BOOL)canChangeUnreadBadgeValue {
    // just check the community id is current community
    NSString *communityId = [KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId;
    if([communityId_ isEqualToString:communityId]){
        return YES;
    }
    
    return NO;
}

- (NSString *)unreadLastVisitTypeToString:(KDUnReadLastVisitType)type {
    
    switch (type) {
        case KDUnReadLastVisitTypeNone:
            return nil;
            break;
        case KDUnReadLastVisitTypeComment:
            return NSLocalizedString(@"UNREAD_COMMENT_YOU", @"");
            break;
        case KDUnReadLastVisitTypeDirectMessage:
            return NSLocalizedString(@"UNREAD_DIRECTMESSAGE_YOU", @"");
            break;
        case KDUnReadLastVisitTypeMention:
            return NSLocalizedString(@"UNREAD_MENTION_YOU", @"");
            break;
        default:
            break;
    }
    
    return @"";
}

- (NSString *)lastVisitMessage {
    return [self unreadLastVisitTypeToString:self.lastVisitType];
}

- (NSUInteger)lastVisitCount {
    if(lastVisitType_ == KDUnReadLastVisitTypeMention) {
        return self.mentions;
    }else if(lastVisitType_ == KDUnReadLastVisitTypeDirectMessage) {
        return self.directMessages;
    }else if(lastVisitType_ == KDUnReadLastVisitTypeComment) {
        return self.comments;
    }
    
    return 0;
}

//-(void)setDirectMessages:(NSInteger)directMessages {
//    [KDDatabaseHelper inDatabase:^id(FMDatabase *fmdb){
//        id<KDDMMessageDAO> messageDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmMessageDAO];
//        BOOL result = [messageDAO hasUnsendMessageInDatabase:fmdb];
//        return @(result);
//    }completionBlock:^(id results){
//        BOOL has = [(NSNumber*)results boolValue];
//        if (has){
//            directMessages_ = -1;
//        }else {
//            directMessages_ = directMessages;
//        }
//    }];
//
//}

- (void)setGroupStatuses:(NSMutableDictionary *)groupStatuses
{
    if (groupStatuses_ != groupStatuses) {
//        [groupStatuses_ release];
        groupStatuses_ = groupStatuses;// retain];
    }
}

- (NSString *)currentCommunityId
{
    
    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
    return communityManager.currentCompany.eid;
}

- (BOOL)hasNewgroupStatuses
{
    KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    NSTimeInterval lastUnread = [userDefaultsAdapter doubleForKey:[self keyWithPrefix:KD_LAST_GROUP_STATUS_UNREAD_DATE]];
    
    return latestGroupMsgDate_ && latestGroupMsgDate_ > lastUnread;
}

- (void)saveGroupStatusUnread
{
    KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    [userDefaultsAdapter storeObject:@(self.latestGroupMsgDate) forKey:[self keyWithPrefix:KD_LAST_GROUP_STATUS_UNREAD_DATE]];
    [userDefaultsAdapter storeObject:self.latestGroupMsgContent forKey:[self keyWithPrefix:KD_LAST_GROUP_STATUS_UNREAD]];
}

- (void)saveInboxUnread
{
    KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    [userDefaultsAdapter storeObject:@(self.latestInboxMsgDate) forKey:[self keyWithPrefix:KD_LAST_INBOX_UNREAD_DATE]];
    [userDefaultsAdapter storeObject:self.latestInboxMsgContent forKey:[self keyWithPrefix:KD_LAST_INBOX_UNREAD]];
}
- (NSInteger)otherCommunityNoticesCount
{
    NSInteger count = 0;
    for (NSString *key in [communityNotices_ allKeys]) {
        if ([key isEqualToString:[self currentCommunityId]])
            continue;
        count += [self noticeForCommunityId:key];
    }
    return count;
}
//////////////////////////// 如果内容为空，显示上次的内容begin

- (NSString *)latestInboxMsgContent
{
    if (!latestInboxMsgContent_) {
//        [latestInboxMsgContent_ release];
        KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
        latestInboxMsgContent_ = [userDefaultsAdapter stringForKey:[self keyWithPrefix:KD_LAST_INBOX_UNREAD]];// retain];
    }
    return latestInboxMsgContent_;
}

- (NSString *)latestGroupMsgContent
{
    if (!latestGroupMsgContent_) {
//        [latestGroupMsgContent_ release];
        KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
        latestGroupMsgContent_ = [userDefaultsAdapter stringForKey:[self keyWithPrefix:KD_LAST_GROUP_STATUS_UNREAD]];// retain];
    }
    return latestGroupMsgContent_;
}

- (NSTimeInterval)latestInboxMsgDate
{
    if (latestInboxMsgDate_ <= 0) {
        KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
        latestInboxMsgDate_ = [userDefaultsAdapter doubleForKey:[self keyWithPrefix:KD_LAST_INBOX_UNREAD_DATE]];
    }
    return latestInboxMsgDate_;

}

- (NSTimeInterval)latestGroupMsgDate
{
    if (latestGroupMsgDate_ <= 0) {
        KDAppUserDefaultsAdapter *userDefaultsAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
        latestGroupMsgDate_ = [userDefaultsAdapter doubleForKey:[self keyWithPrefix:KD_LAST_GROUP_STATUS_UNREAD_DATE]];
    }
    return latestGroupMsgDate_;

}

- (NSString *)keyWithPrefix:(NSString *)key
{
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    NSString *userId = userManager.currentUserId;
    return [NSString stringWithFormat:@"%@_%@_%@", [self currentCommunityId], userId, key];
}


//////////////////////////// 如果内容为空，显示上次的内容 end

// Reset all value to zero
- (void)reset {
    newStatus_ = 0;
    publicStatuses_ = 0;
    friendsStatuses_ = 0;
    
    mentions_ = 0;
    comments_ = 0;
    directMessages_ = 0;
    
    followers_ = 0;
    members_ = 0;
    
    notices_ = 0;
    fuctions_ = 0;
    inboxTotal_ = 0;
    inviteTotal_ = 0;
    undoTotal_ = 0;
    
    latestGroupMsgDate_ = 0;
    latestInboxMsgDate_ = 0;
    
    lastVisitType_ = KDUnReadLastVisitTypeNone;
    
    //KD_RELEASE_SAFELY(latestStatusMsgHeadUrl_);
    //KD_RELEASE_SAFELY(communityNotices_);
    //KD_RELEASE_SAFELY(communityUnreads_)
    //KD_RELEASE_SAFELY(lastVisitorName_);
    //KD_RELEASE_SAFELY(groupStatuses_);
    //KD_RELEASE_SAFELY(latestGroupMsgContent_);
    //KD_RELEASE_SAFELY(latestInboxMsgContent_);
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(communityId_);
    //KD_RELEASE_SAFELY(lastVisitorName_);
    //KD_RELEASE_SAFELY(groupStatuses_);
    //KD_RELEASE_SAFELY(communityUnreads_);
    //KD_RELEASE_SAFELY(communityNotices_);
    //KD_RELEASE_SAFELY(latestGroupMsgContent_);
    //KD_RELEASE_SAFELY(latestInboxMsgContent_);
    //KD_RELEASE_SAFELY(latestStatusMsgHeadUrl_);
    //[super dealloc];
}

@end
