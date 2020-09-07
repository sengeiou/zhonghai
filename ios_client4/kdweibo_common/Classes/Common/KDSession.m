//
//  KDSession.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-29.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDSession.h"

#import "KDWeiboServicesContext.h"
#import "KDManagerContext.h"

#define KD_SESSION_TIMELINE_TYPE    @"kd:user_selected_timeline_type"
#define KD_READ_PATTERN             @"kd:read_pattern"


NSString * const KDRemoteNotificationUserInfoKey = @"com.kingdee.remote_notification.userinfo";
NSString * const KDLocalNotificationInfoKey = @"com.kingdee.local_notification_info";

static KDSession *globalSession_ = nil;

@implementation KDSession

@synthesize timelinePresentationPattern = timelinePresentationPattern_;
@synthesize timelineType = timelineType_;

- (id)init {
    self = [super init];
    if(self){
        // initialized as company activity 
       
        KDTimelinePresentationPattern presentationPattern = KDTimelinePresentationPatternImagePreview;
        [self getTimelinePresentaionPattern:&presentationPattern];
        timelinePresentationPattern_ = presentationPattern;
    }
    
    return self;
}

+ (KDSession *)globalSession {
    
    if(globalSession_ == nil){
        globalSession_ = [[KDSession alloc] init];
    }
    
    return globalSession_;
}

+ (void)setGlobalSession:(KDSession *)globalSession {
    if(globalSession_ != globalSession){
//        [globalSession_ release];
        globalSession_ = globalSession;// retain];
    }
}

- (void)resetTimelineTypeFromLocal {
    KDTLStatusType type = KDTLStatusTypePublic;
    [[KDSession globalSession] getTimelineType:&type];
    [KDSession globalSession].timelineType = type;
}

- (void)setUnsendedStatus:(KDStatus *)unsendedStatus {
    KDCommunity *currentComutnity = [[[KDManagerContext globalManagerContext] communityManager] currentCommunity];
    [self setProperty:unsendedStatus forKey:[NSString stringWithFormat:@"%@_un_sended",currentComutnity.communityId]];
}

- (KDStatus *)unsendedStatus {
     KDCommunity *currentComutnity = [[[KDManagerContext globalManagerContext] communityManager] currentCommunity];
     return [self propertyForKey:[NSString stringWithFormat:@"%@_un_sended",currentComutnity.communityId]];
}

- (BOOL)getTimelineType:(KDTLStatusType *)timelineType {
    BOOL found = NO;
    
    NSNumber *obj = [self getPropertyForKey:KD_SESSION_TIMELINE_TYPE fromMemoryCache:NO];
    if(obj != nil){
        found = YES;
        
        if(timelineType != NULL){
            *timelineType = [obj integerValue];
        }
    }
    
    return found;
}

- (void)saveTimelineType:(KDTLStatusType)timelineType {
    if (timelineType == KDTLStatusTypeBulletin || timelineType == KDTLStatusTypeHotComment) {
        return;
    }
    [self saveProperty:[NSNumber numberWithInteger:timelineType] forKey:KD_SESSION_TIMELINE_TYPE storeToMemoryCache:NO];
}

- (BOOL)getTimelinePresentaionPattern:(KDTimelinePresentationPattern *)presentationPattern {
    BOOL found = NO;
    
    NSNumber *obj = [self getPropertyForKey:KD_READ_PATTERN fromMemoryCache:NO];
    if(obj != nil){
        found = YES;
        
        if(presentationPattern != NULL){
            *presentationPattern = [obj integerValue];
        }
    }
    
    return found;
}

-  (void)saveTimelinePresentationPattern:(KDTimelinePresentationPattern)presentationPattern {
    timelinePresentationPattern_ = presentationPattern;
    [self saveProperty:[NSNumber numberWithInteger:presentationPattern] forKey:KD_READ_PATTERN storeToMemoryCache:NO];
}

- (id)getPropertyForKey:(NSString *)key fromMemoryCache:(BOOL)fromMemoryCache {
    id obj = nil;
    if(key != nil){
        if(fromMemoryCache){
            obj = [super propertyForKey:key];
        }
        
        if(obj == nil) {
            id<KDAppUserDefaultsProtocol> userDefault = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
            obj = [userDefault objectForKey:key];
        }
    }
    
    return obj;
}

- (void)saveProperty:(id)object forKey:(NSString *)key storeToMemoryCache:(BOOL)storeToMemoryCache {
    if(object != nil && key != nil){
        id<KDAppUserDefaultsProtocol> userDefault = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
        [userDefault storeObject:object forKey:key];
    }
    
    if(storeToMemoryCache){
        [super setProperty:object forKey:key];
    }
}

- (void)removePropertyForKey:(NSString *)key clearCache:(BOOL)clearCache {
    if (key != nil) {
        [super setProperty:nil forKey:key];
    
        if (clearCache) {
            id<KDAppUserDefaultsProtocol> userDefault = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
            [userDefault removeObjectForKey:key];
        }
    }
}

- (void)clearSessionOnSignOut {
    timelineType_ = KDTLStatusTypePublic;
    timelinePresentationPattern_ = KDTimelinePresentationPatternImagePreview;
    [self removePropertyForKey:KD_SESSION_TIMELINE_TYPE clearCache:YES];

    [self removePropertyForKey:KD_READ_PATTERN clearCache:YES];


    // remove user is signing flag
    [self setProperty:nil forKey:KD_PROP_USER_IS_SIGNING_KEY];

}

- (void)dealloc {
    //[super dealloc];
}

@end
