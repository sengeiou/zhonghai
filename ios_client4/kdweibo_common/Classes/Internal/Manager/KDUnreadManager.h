//
//  KDUnreadManager.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-8-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDXTUnread.h"
#import "KDUnread.h"
#import "KDRequestWrapper.h"
@protocol KDUnreadListener;

////////////////////////////////////////////////////////////////////////
typedef enum {
    KDUnreadTypeWeibo = 0x01,
    KDUnreadTypeXuntong
}KDUnreadType;

@interface KDMockUnreadListener : NSObject {
@private
//    id<KDUnreadListener> listener_; // weak reference
}

@property(nonatomic, assign) id<KDUnreadListener> listener;

@end

@interface KDXTMockUnreadListener : NSObject {
@private
//    id<KDUnreadListener> listener_; // weak reference
}

@property(nonatomic, assign) id<KDUnreadListener> listener;

@end

////////////////////////////////////////////////////////////////////////

@interface KDUnreadManager : NSObject <KDRequestWrapperDelegate,UIAlertViewDelegate> {
 @private
    KDUnread *unread_;
    KDXTUnread *xtUnread_;
    NSMutableArray *listeners_;
    
    NSMutableArray *xtListeners_;
    
    NSTimer *repeatTimer_;
    NSTimeInterval interval_;
    
    BOOL loading_; // the flag mark get unread count is going
}

@property(nonatomic, retain, readonly) KDUnread *unread;
@property(nonatomic, retain, readonly) KDXTUnread *xtUnread;
- (void)addUnreadListener:(id<KDUnreadListener>)listener;
- (void)removeUnreadListener:(id<KDUnreadListener>)listener;

- (void)addXTUnreadListener:(id<KDUnreadListener>)listener;
- (void)removeXTUnreadListener:(id<KDUnreadListener>)listener;

- (void)start:(BOOL)delay;
- (void)stop;
- (void)reset;
- (void)notify;

- (NSInteger)timelineBadgeValue;
- (NSInteger)messageBadgeValue;

- (void)didChangeTimelineBadgeValue:(BOOL)reset;
- (void)didChangeMessageBadgeValue:(BOOL)resetMentions resetComments:(BOOL)resetComments resetDM:(BOOL)resetDM;
- (void)didChangeDMBadgeValue:(NSInteger)badgeValue;
- (void)didChangeAllGroupsUnread:(BOOL)reset;
- (void)didChangeGroupsBadgeValue:(BOOL)reset groupId:(NSString *)groupId;
- (void)changeFollowersBadgeValue:(BOOL)reset;
- (void)didChangePublicTimelineBadge:(BOOL)rest;
- (void)didChangeFriendTimelineBadge:(BOOL)rest;
- (void)changeApplicationBadgeValue;
- (void)decreaseNewFunctionsNum;
- (void)didChangeInboxBadgeValue:(NSInteger)badgeValue;
- (void)didChangeUndoBadgeValue:(NSInteger)badgeValue;
- (void)didChangeInvitedBadgeValue:(NSInteger)badgeValue;
@end


////////////////////////////////////////////////////////////////////////////////


@protocol KDUnreadListener <NSObject>
 @optional
- (void)unreadManager:(KDUnreadManager *)unreadManager unReadType:(KDUnreadType)unReadType;

@end

