//
//  RecordListDataModel.m
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "RecordListDataModel.h"
#import "RecordDataModel.h"
#import "KDToDoMessageDataModel.h"

@implementation RecordListDataModel

- (id)init {
    self = [super init];
    if (self) {
        _groupId = [[NSString alloc] init];
        _updateTime = [[NSString alloc] init];
        _count = 0;
        _list = [[NSMutableArray alloc]init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id groupId = [dict objectForKey:@"groupId"];
        id updateTime = [dict objectForKey:@"updateTime"];
        id count = [dict objectForKey:@"count"];
        id list = [dict objectForKey:@"list"];
        id unreadCount = [dict objectForKey:@"unreadCount"];
        id undoCount = [dict objectForKey:@"undoCount"];
        id notifyUnreadCount = [dict objectForKey:@"notifyUnreadCount"];
        id lastIgnoreNotifyScore = [dict objectForKey:@"lastIgnoreNotifyScore"];
        if (![groupId isKindOfClass:[NSNull class]] && groupId) {
            self.groupId = groupId;
        }
        if (![updateTime isKindOfClass:[NSNull class]] && updateTime) {
            self.updateTime = updateTime;
        }
        if (![count isKindOfClass:[NSNull class]] && count) {
            self.count = [count intValue];
        }
        
        
        if (![count isKindOfClass:[NSNull class]] && count) {
            self.unreadCount = [unreadCount intValue];
        }
        if (![undoCount isKindOfClass:[NSNull class]] && undoCount) {
            self.undoCount = [undoCount intValue];
        }

        if (![notifyUnreadCount isKindOfClass:[NSNull class]] && notifyUnreadCount) {
            self.notifyUnreadCount = [notifyUnreadCount intValue];
        }
        if (![lastIgnoreNotifyScore isKindOfClass:[NSNull class]] && lastIgnoreNotifyScore) {
            self.lastIgnoreNotifyScore = [lastIgnoreNotifyScore integerValue];
        }
        
        if (![list isKindOfClass:[NSNull class]] && list && [list isKindOfClass:[NSArray class]]) {
            for (id each in list) {
                KDToDoMessageDataModel *record = [[KDToDoMessageDataModel alloc] initWithDictionary:each];
                [record setGroupId:_groupId];
                [self.list addObject:record];
            }
        }
    }
    return self;
}
- (id)initForToDoWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id groupId = [dict objectForKey:@"groupId"];
        id updateTime = [dict objectForKey:@"updateTime"];
        id count = [dict objectForKey:@"count"];
        id list = [dict objectForKey:@"list"];
        id unreadCount = [dict objectForKey:@"unreadCount"];
        id undoCount = [dict objectForKey:@"undoCount"];
        id notifyUnreadCount = [dict objectForKey:@"notifyUnreadCount"];
        id lastIgnoreNotifyScore = [dict objectForKey:@"lastIgnoreNotifyScore"];
        
        if (![groupId isKindOfClass:[NSNull class]] && groupId) {
            self.groupId = groupId;
        }
        if (![updateTime isKindOfClass:[NSNull class]] && updateTime) {
            self.updateTime = updateTime;
        }
        if (![count isKindOfClass:[NSNull class]] && count) {
            self.count = [count intValue];
        }
        
        if (![unreadCount isKindOfClass:[NSNull class]]) {
            self.unreadCount = [unreadCount intValue];
        }
        if (![undoCount isKindOfClass:[NSNull class]] && undoCount) {
            self.undoCount = [undoCount intValue];
        }
        
        if (![notifyUnreadCount isKindOfClass:[NSNull class]] && notifyUnreadCount) {
            self.notifyUnreadCount = [notifyUnreadCount intValue];
        }
        if (![lastIgnoreNotifyScore isKindOfClass:[NSNull class]] && lastIgnoreNotifyScore) {
            self.lastIgnoreNotifyScore = [lastIgnoreNotifyScore integerValue];
        }
        if (![list isKindOfClass:[NSNull class]] && list && [list isKindOfClass:[NSArray class]]) {
            for (id each in list) {
                KDToDoMessageDataModel *record = [[KDToDoMessageDataModel alloc]initWithDictionary:each];
                [record setGroupId:_groupId];
                [self.list addObject:record];
            }
        }
    }
    return self;
}
@end
