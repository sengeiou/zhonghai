//
//  KDUnread.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-20.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDObject.h"


typedef enum {
    KDUnReadLastVisitTypeNone = 0x00,
    KDUnReadLastVisitTypeMention,
    KDUnReadLastVisitTypeComment,
    KDUnReadLastVisitTypeDirectMessage,
    KDUnReadLastVisitTypeTodo
}KDUnReadLastVisitType;

@interface KDUnread : KDObject {
 @private
    // The community id mark the unread badge values for specific community
    NSString *communityId_;
    
    NSInteger newStatus_;
    NSInteger publicStatuses_;
    NSInteger friendsStatuses_;
    
    NSInteger mentions_;
    NSInteger comments_;
    NSInteger directMessages_;
    
    NSInteger followers_;
    NSInteger members_;
    
    NSInteger notices_;

    NSMutableDictionary *groupStatuses_;
    NSMutableDictionary *communityUnreads_;
    NSMutableDictionary *communityNotices_;
    
    NSInteger fuctions_;
    NSInteger newVersion_;
    
    NSInteger  inboxTotal_;
    NSInteger  undoTotal_;
    NSInteger  inviteTotal_;
}

@property (nonatomic, copy) NSString *communityId;
//新微博
@property (nonatomic, assign) NSInteger newStatus;
//大厅微博
@property (nonatomic, assign) NSInteger publicStatuses;
//关注的微博
@property (nonatomic, assign) NSInteger friendsStatuses;
//提及
@property (nonatomic, assign) NSInteger mentions;
//评论
@property (nonatomic, assign) NSInteger comments;
//短邮
@property (nonatomic, assign) NSInteger directMessages;
//粉丝
@property (nonatomic, assign) NSInteger followers;

@property (nonatomic, assign) NSInteger members;

@property (nonatomic, assign) NSInteger notices;

@property (nonatomic, retain) NSMutableDictionary *groupStatuses;
@property (nonatomic, retain) NSMutableDictionary *communityUnreads;
@property (nonatomic, retain) NSMutableDictionary *communityNotices;

@property (nonatomic, assign) NSInteger functions;
@property (nonatomic, assign) NSInteger newVersion;

@property (nonatomic, copy)   NSString *lastVisitorName;
@property (nonatomic, assign) KDUnReadLastVisitType lastVisitType;
@property (nonatomic, assign) NSInteger inboxTotal;
@property (nonatomic, assign) NSInteger undoTotal;
@property (nonatomic, assign) NSInteger inviteTotal;



//最近更新的小组消息
@property (nonatomic, retain) NSString *latestGroupMsgContent;
//最近更新的inbox消息
@property (nonatomic, retain) NSString *latestInboxMsgContent;
//最近更新的小组消息时间
@property (nonatomic, assign) NSTimeInterval latestInboxMsgDate;
//最近更新的inbox消息时间
@property (nonatomic, assign) NSTimeInterval latestGroupMsgDate;

//根据时间判断是否有新消息
@property (nonatomic, assign, readonly) BOOL hasNewgroupStatuses;

@property (nonatomic, retain) NSString *latestStatusMsgHeadUrl;

- (NSInteger)unreadForGroupId:(NSString *)groupId;
- (void)resetUnreadWithGroupId:(NSString *)groupId;

-(void)resetAllGroupUnreadCount;
- (NSInteger)groupsAllUnreadCount;

- (NSInteger)unreadForCommunityId:(NSString *)communityId;
- (void)resetUnreadWithCommunityId:(NSString *)communityId;
- (NSInteger)communitiesAllUnreadCount;

- (NSInteger)noticeForCommunityId:(NSString *)communityId;
- (void)resetNoticeWithCommunityId:(NSString *)communityId;
- (NSInteger)communitiesAllNoticeCount;

- (BOOL)canChangeUnreadBadgeValue;
- (void)reset;

- (NSString *)lastVisitMessage;
- (NSUInteger)lastVisitCount;

/*
    除当前所在社区，其他社区的消息数目
*/
- (NSInteger)otherCommunityNoticesCount;
/**
 *  保存小组最后一次的时间及内容
 */
- (void)saveGroupStatusUnread;
/**
 *  保存inbox最后一次的时间及内容
 */
- (void)saveInboxUnread;
@end
