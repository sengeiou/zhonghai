//
//  KDCompositeParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-11.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCompositeParser.h"
#import "KDUnread.h"
#import "KDAppVersionUpdates.h"
#import "KDApplication.h"
#import "KDCommunity.h"
#import "KDTopic.h"
#import "KDStatusParser.h"
#import "KDABRecord.h"

@implementation KDCompositeParser

- (KDAppVersionUpdates *)parseAsAppVersionUpdates:(NSDictionary *)body {
    if (body == nil || [body count] == 0) return nil;
    
    KDAppVersionUpdates *updates = [[KDAppVersionUpdates alloc] init];// autorelease];
    updates.buildNumber = [body stringForKey:@"buildNo"];
    updates.version = [body stringForKey:@"version"];
    updates.updateURL = [body stringForKey:@"fileUrl"];
    updates.commentURL = [body stringForKey:@"commentUrl"];
    updates.updatePolicy = [body intForKey:@"updatePolicy"];
    updates.changes = [body objectNotNSNullForKey:@"changes"];
    updates.forceUpdateNo = [body objectForKey:@"forceUpdateNo"];
    updates.desc = [body objectForKey:@"desc"];
    
    return updates;
}

- (NSArray *)parseAsClientApplications:(NSArray *)bodyList {
    NSUInteger count = 0;
    if (bodyList == nil || (count = [bodyList count]) == 0) return nil;

    KDApplication *app = nil;
    NSMutableArray *apps = [NSMutableArray arrayWithCapacity:count];
    for (NSDictionary *body in bodyList) {
        app = [[KDApplication alloc] init];
        
        app.desc = [body stringForKey:@"desc"];
        app.detailDesc = [body stringForKey:@"detailDesc"];
        app.httpUrl = [body stringForKey:@"httpUrl"];
        app.iconUrl = [body stringForKey:@"iconUrl"];
        app.appId = [body stringForKey:@"id"];
        app.installUrl = [body stringForKey:@"installUrl"];
        app.key = [body stringForKey:@"key"];
        app.mobileType = [body stringForKey:@"mobileType"];
        app.name = [body stringForKey:@"name"];
        app.networkId = [body stringForKey:@"networkId"];
        app.schemeUrl = [body stringForKey:@"schemeUrl"];
        app.tenantId = [body stringForKey:@"tenantid"];
        app.appVersion = [body stringForKey:@"version"];
        app.needAuth = [body boolForKey:@"needAuth"];
        
        [apps addObject:app];
//        [app release];
    }
    
    return apps;
}

- (KDUnread *)parseAsUnread:(NSDictionary *)body {
    if (body == nil || [body count] == 0) return nil;
    
    KDUnread *unread = [[KDUnread alloc] init];// autorelease];
    
    unread.newStatus = [body integerForKey:@"new_status"];
    unread.publicStatuses = [body integerForKey:@"public_statuses"];
    unread.friendsStatuses = [body integerForKey:@"friends_statuses"];
    
    unread.mentions = [body integerForKey:@"mentions"];
    unread.comments = [body integerForKey:@"comments"];
    unread.directMessages = [body integerForKey:@"dm"];
    NSDictionary *inbox = [body objectNotNSNullForKey:@"inbox"];
    if (inbox != nil) {
        unread.inboxTotal = [inbox integerForKey:@"total"];
    }
    NSDictionary *todo = [body objectNotNSNullForKey:@"todo"];
    if (todo != nil) {
        //修改KSSP-13236 王松 2013-12-25
        unread.undoTotal = [todo integerForKey:@"unreadCount"];
    }
    
    NSDictionary *invite = [body objectNotNSNullForKey:@"invite"];
    if (invite != nil) {
        unread.inviteTotal = [invite integerForKey:@"undoCount"];
    }
    
    unread.followers = [body integerForKey:@"followers"];
    unread.members = [body integerForKey:@"members"];
    
    unread.notices = [body integerForKey:@"notices"];
    
    unread.lastVisitorName = [body stringForKey:@"lastMessageUserName"];
    
    unread.latestGroupMsgContent = [body stringForKey:@"latestGroupMsgContent"];
    unread.latestInboxMsgContent = [body stringForKey:@"latestInboxMsgContent"];
    unread.latestInboxMsgDate = [[NSDate dateWithTimeIntervalSince1970:[body doubleForKey:@"latestInboxMsgDate"] / 1000] timeIntervalSince1970];
    unread.latestGroupMsgDate = [[NSDate dateWithTimeIntervalSince1970:[body doubleForKey:@"latestGroupMsgDate"] / 1000] timeIntervalSince1970];
    
    NSString *lastType = [body stringForKey:@"lastMessageType"];
    unread.lastVisitType = KDUnReadLastVisitTypeNone;
    
    if([lastType isEqualToString:@"Comment"])
        unread.lastVisitType = KDUnReadLastVisitTypeComment;
    else if([lastType isEqualToString:@"Mention"])
        unread.lastVisitType = KDUnReadLastVisitTypeMention;
    else if([lastType isEqualToString:@"PrivateMessage"])
        unread.lastVisitType = KDUnReadLastVisitTypeDirectMessage;
    
    NSDictionary *info = [body objectNotNSNullForKey:@"group_statuses"];
    if (info != nil) {
        unread.groupStatuses = [NSMutableDictionary dictionaryWithDictionary:info];
    }
    
    info = [body objectNotNSNullForKey:@"communityUnreads"];
    if (info != nil) {
        unread.communityUnreads = [NSMutableDictionary dictionaryWithDictionary:info];
    }
    
    info = [body objectNotNSNullForKey:@"communityNotices"];
    if (info != nil) {
        unread.communityNotices = [NSMutableDictionary dictionaryWithDictionary:info];
    }
    unread.latestStatusMsgHeadUrl = [body stringForKey:@"latestStatusMsgHeadUrl"];
    return unread;
}

- (NSArray *)parseAsCommunities:(NSArray *)bodyList {
    NSUInteger count = 0;
    if (bodyList == nil || (count = [bodyList count]) == 0) return nil;
    
    KDCommunity *c = nil;
    NSMutableArray *communities = [NSMutableArray arrayWithCapacity:count];
    for (NSDictionary *body in bodyList) {
        c = [[KDCommunity alloc] init];
        
        c.communityId = [body stringForKey:@"id"];
        c.name = [body stringForKey:@"name"];
        c.subDomainName = [body stringForKey:@"sub_domain_name"];
        c.url = [body stringForKey:@"url"];
        c.logoURL = [body stringForKey:@"logo_url"];
        c.inviter = [body stringForKey:@"inviter"];
        c.code = [body stringForKey:@"code" defaultValue:@""];
        c.isAdmin = [body boolForKey:@"isAdmin"];
        c.isAllowInto = [body boolForKey:@"isALLowInto" defaultValue:YES];
        c.isApply = [body boolForKey:@"isApply" defaultValue:NO];
        NSString *type = [body stringForKey:@"subType"];
        c.communityType = [KDCommunity convertCommunityTypeFromString:type];
        
        [communities addObject:c];
//        [c release];
    }
    
    return communities;
}

- (NSArray *)parseAsTopics:(NSArray *)bodyList {
    NSUInteger count = 0;
    if (bodyList == nil || (count = [bodyList count]) == 0) return nil;
    
    KDTopic *t = nil;
    NSMutableArray *topics = [NSMutableArray arrayWithCapacity:count];
    for (NSDictionary *body in bodyList) {
        t = [[KDTopic alloc] init];
        
        t.topicId = [body stringForKey:@"id"];
        t.name = [body stringForKey:@"name"];
        t.internalAd = [body stringForKey:@"internalAd"];
        t.truncatedName = [body stringForKey:@"truncatedName"];
        t.isNew = [body boolForKey:@"new"];
        t.isHot = [body boolForKey:@"hot"];
        NSDictionary *statusBody = [body objectNotNSNullForKey:@"status"];
        if(statusBody != nil) {
            KDStatusParser *parser = [super parserWithClass:[KDStatusParser class]];
            t.latestStatus = [parser parseAsStatus:statusBody type:KDTLStatusTypeUndefined];
        }

        [topics addObject:t];
//        [t release];
    }
    
    return topics;
}

- (NSArray *)parseAsABRecord:(NSArray *)bodyList {
    if(!bodyList || [bodyList count] == 0) return nil;
    
    NSMutableArray *records = [NSMutableArray arrayWithCapacity:bodyList.count];
    for(NSDictionary *dic in bodyList) {
        KDABRecord *record = [[KDABRecord alloc] init];
        
        record.name = [dic stringForKey:@"name"];
        record.phoneNumber = [dic stringForKey:@"mobile"];
        
        NSString *stateStr = [dic stringForKey:@"status"];
        
        if([stateStr isEqualToString:@"UN_ACTIVED"]) {
            record.state = KDABRecordState_Unactived;
        }else if([stateStr isEqualToString:@"ACTIVED"]) {
            record.state = KDABRecordState_Actived;
        }else if([stateStr isEqualToString:@"PENDING"]) {
            record.state = KDABRecordState_Peding;
        }else if([stateStr isEqualToString:@"HAS_JOINED"]) {
            record.state = KDABRecordState_Joined;
        }else {
            record.state = KDABRecordState_Default;
        }
        
        
        [records addObject:record];
//        [record release];
    }
    
    return records;
}

@end
