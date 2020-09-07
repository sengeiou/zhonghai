//
//  KDNoticeClient.m
//  kdweibo
//
//  Created by kingdee on 17/4/17.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDNoticeClient.h"

@implementation KDNoticeClient

-(NSDictionary *)header
{
    NSString *openToken = [BOSConfig sharedConfig].user.token;
    if (!openToken) {
        openToken = @"";
    }
    return [NSDictionary dictionaryWithObject:openToken forKey:@"openToken"];
}

-(id)initWithTarget:(id)target action:(SEL)action
{
    BOSConnectFlags connectFlags = {BOSConnect4DirectURL,BOSConnectNotEncryption,BOSConnectResponseAllowCompressed,BOSConnectRequestBodyNotCompressed,NO};
    self = [super initWithTarget:target action:action connectionFlags:connectFlags];
    if (self) {
        [super setBaseUrlString:[BOSSetting sharedSetting].url];
    }
    return self;
}

- (void)createNoticeWithGroupId:(NSString *)groupId title:(NSString *)title content:(NSString *)content {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:safeString(groupId) forKey:@"groupId"];
    [params setObject:safeString(title) forKey:@"title"];
    [params setObject:safeString(content) forKey:@"content"];
    [super post:EMPSERVERURL_NOTICE_CREATE body:params header:[self header]];
}

- (void)newestNoticeWithGroupId:(NSString *)groupId {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:safeString(groupId) forKey:@"groupId"];
    [super post:EMPSERVERURL_NOTICE_NEWEST body:params header:[self header]];
}

- (void)listNoticeWithGroupId:(NSString *)groupId noticeId:(NSString *)noticeId count:(NSString *)count {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:safeString(groupId) forKey:@"groupId"];
    [params setObject:safeString(noticeId) forKey:@"noticeId"];
    [params setObject:safeString(count) forKey:@"count"];
    [super post:EMPSERVERURL_NOTICE_LIST body:params header:[self header]];
}

- (void)deleteNoticeWithNoticeId:(NSString *)noticeId {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:safeString(noticeId) forKey:@"noticeId"];
    [super post:EMPSERVERURL_NOTICE_DELETE body:params header:[self header]];
}

@end
