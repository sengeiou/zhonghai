//
//  KDSigninMedalModel.m
//  kdweibo
//
//  Created by shifking on 16/3/26.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSigninMedalModel.h"

@implementation KDSigninMedalModel
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        id alert = [dictionary objectForKey:@"alert"];
        id picUrl = [dictionary objectForKey:@"picUrl"];
        id detailAddress = [dictionary objectForKey:@"detailAddress"];
        id leftBtnText = [dictionary objectForKey:@"leftBtnText"];
        id rightBtnText = [dictionary objectForKey:@"rightBtnText"];
        id title = [dictionary objectForKey:@"title"];
        id content = [dictionary objectForKey:@"content"];
        id priority = [dictionary objectForKey:@"priority"];
        id alertType = [dictionary objectForKey:@"alertType"];
        id points = [dictionary objectForKey:@"points"];
        id rank = [dictionary objectForKey:@"rank"];
        id medalLevel = [dictionary objectForKey:@"medalLevel"];
        id appId = [dictionary objectForKey:@"appId"];

        if (![alert isKindOfClass:[NSNull class]] && alert) {
            self.alertEnable = [alert boolValue];
        }
        if (![picUrl isKindOfClass:[NSNull class]] && picUrl) {
            self.picUrl = picUrl;
        }
        if (![detailAddress isKindOfClass:[NSNull class]] && detailAddress) {
            self.detailAddress = detailAddress;
        }
        if (![leftBtnText isKindOfClass:[NSNull class]] && leftBtnText) {
            self.leftBtnText = leftBtnText;
        }
        if (![rightBtnText isKindOfClass:[NSNull class]] && rightBtnText) {
            self.rightBtnText = rightBtnText;
        }
        if (![title isKindOfClass:[NSNull class]] && title) {
            self.title = title;
        }
        else {
            self.title = @"";
        }
        if (![content isKindOfClass:[NSNull class]] && content) {
            self.content = content;
        }
        else {
            self.content = @"";
        }
        if (![priority isKindOfClass:[NSNull class]] && priority) {
            self.priority = [priority integerValue];
        }
        if (![alertType isKindOfClass:[NSNull class]] && alertType) {
            self.alertType = [alertType integerValue];
        }
        if (![points isKindOfClass:[NSNull class]] && points) {
            self.points = [points integerValue];
        }
        if (![rank isKindOfClass:[NSNull class]] && rank) {
            self.rank = [rank integerValue];
        }
        if (![medalLevel isKindOfClass:[NSNull class]] && medalLevel) {
            self.medalLevel = [medalLevel integerValue];
        }
        if (![appId isKindOfClass:[NSNull class]] && appId) {
            self.appId = appId;
        }
    }
    
    return self;
}

@end
