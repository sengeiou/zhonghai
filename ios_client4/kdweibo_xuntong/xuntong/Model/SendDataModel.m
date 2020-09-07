//
//  SendDataModel.m
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "SendDataModel.h"

@implementation SendDataModel

- (id)init {
    self = [super init];
    if (self) {
        _groupId = [[NSString alloc] init];
        _msgId = [[NSString alloc] init];
        _sendTime = [[NSString alloc] init];
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
        id msgId = [dict objectForKey:@"msgId"];
        id sendTime = [dict objectForKey:@"sendTime"];
        
        if (![groupId isKindOfClass:[NSNull class]] && groupId) {
            self.groupId = groupId;
        }
        if (![msgId isKindOfClass:[NSNull class]] && msgId) {
            self.msgId = msgId;
        }
        if (![sendTime isKindOfClass:[NSNull class]] && sendTime) {
            self.sendTime = sendTime;
        }
    }
    return self;
}

@end
