//
//  KDSession.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-29.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDObject.h"
#import "KDStatus.h"

#define KD_PROP_3RD_AUTH_QUERY_KEY                     @"kd:3rd_auth_query"

#define KD_PROP_USER_IS_SIGNING_KEY                    @"kd:user_is_signing"
#define KD_3RD_AUTH_DOMAIN_NAME                        @"kd:3rd_auth_domain_name"
#define KD_PRO_LOCAION_USE_NOTIFICAITON                @"kd:location_use_notification"
#define KD_VERSION_UPDATE_KEY                          @"kd:version_update"
#define KD_VEDIO_KEY                                   @"kd:vedio_new_function"

#define KD_LAST_SHOW_GUIDE_VERSION_KEY                     @"kd:last_show_guide_version_key"

#define KD_LEFT_INBOX_NEW_KEY                          @"kd:left_inbox_new_function"
#define KD_LEFT_TODO_NEW_KEY                           @"kd:left_todo_new_function"
#define KD_LEFT_SIGNIN_NEW_KEY                         @"kd:left_signin_new_function"

#define KD_TEAM_SHOW_TIPS_VIEW_KEY                     @"kd:team_show_tips_view"

#define KD_OPEN_UDID_KEY                               @"kd:open_udid_key"

UIKIT_EXTERN NSString * const KDRemoteNotificationUserInfoKey;
UIKIT_EXTERN NSString * const KDLocalNotificationInfoKey;

//enum {
//    KDTimelineTypeCompanyActivity = 0x01,
//    KDTimelineTypeFriendsTimeline,
//    KDTimelineTypePopularDiscussion
//};

//typedef NSUInteger KDTimelineType;

enum {
    KDTimelinePresentationPatternImagePreview = 0,  //预览图模式
    KDTimelinePresentationPatternOnlyWords           //经典模式（仅有文字）
    
};
typedef NSUInteger KDTimelinePresentationPattern;

@interface KDSession : KDObject {
 @private
    KDTLStatusType timelineType_;
    KDTimelinePresentationPattern  timelinePresentationPattern_;
}

@property(nonatomic, assign) KDTLStatusType timelineType;
@property(nonatomic, assign) KDTimelinePresentationPattern timelinePresentationPattern;
@property(nonatomic, retain) KDStatus *unsendedStatus;

+ (KDSession *)globalSession;

+ (void)setGlobalSession:(KDSession *)globalSession;

- (void)resetTimelineTypeFromLocal; //从本地初始type

- (BOOL)getTimelineType:(KDTLStatusType *)timelineType;

- (void)saveTimelineType:(KDTLStatusType)timelineType;

- (BOOL)getTimelinePresentaionPattern:(KDTimelinePresentationPattern *)presentationPattern;

-  (void)saveTimelinePresentationPattern:(KDTimelinePresentationPattern)presentationPattern;

- (id)getPropertyForKey:(NSString *)key fromMemoryCache:(BOOL)fromMemoryCache;
- (void)saveProperty:(id)object forKey:(NSString *)key storeToMemoryCache:(BOOL)storeToMemoryCache;
- (void)removePropertyForKey:(NSString *)key clearCache:(BOOL)clearCache;

- (void)clearSessionOnSignOut;

@end
