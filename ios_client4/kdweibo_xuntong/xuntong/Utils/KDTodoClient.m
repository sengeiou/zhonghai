//
//  KDTodoClient.m
//  kdweibo
//
//  Created by lichao_liu on 16/3/17.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDTodoClient.h"
#import "BOSConfig.h"
#import "KDWeiboServicesContext.h"
#import "KDConfigurationContext.h"

@implementation KDTodoClient

- (NSDictionary *)wfHeader {
    NSString *openToken = [BOSConfig sharedConfig].user.token;
    NSString *personId = [BOSConfig sharedConfig].user.userId;
    NSString *eid = [BOSConfig sharedConfig].user.eid;
    if (!openToken) {
        openToken = @"";
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:openToken, @"openToken",personId,@"X-Requested-personId",eid,@"X-Requested-eid",nil];
    return dic;
}
-(id)initWithTarget:(id)target action:(SEL)action
{
    BOSConnectFlags connectFlags = {BOSConnect4DirectURL,BOSConnectNotEncryption,BOSConnectResponseAllowCompressed,BOSConnectRequestBodyNotCompressed,NO};
    self = [super initWithTarget:target action:action connectionFlags:connectFlags];
    if (self) {
        KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
        NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
        [self setBaseUrlString:baseURL];
    }
    return self;
}


- (void)createMarkWithMarkType:(int)markType
                     messageId:(NSString *)messageId
                        todoId:(NSString *)todoId
                       groupId:(NSString *)groupId
                         appId:(NSString *)appId
                         title:(NSString *)title
                          text:(NSString *)text
                           url:(NSString *)url
                        fileId:(NSString *)fileId
                          icon:(NSString *)icon{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary *innerParams = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:@(markType) forKey:@"markType"];
    [innerParams setObject:messageId forKey:@"messageId"];
    [innerParams setObject:todoId forKey:@"todoId"];
    [innerParams setObject:groupId forKey:@"groupId"];
    [innerParams setObject:appId forKey:@"appId"];
    [innerParams setObject:title forKey:@"title"];
    [innerParams setObject:text forKey:@"text"];
    [innerParams setObject:url forKey:@"uri"];
    [innerParams setObject:fileId forKey:@"fileId"];
    [innerParams setObject:icon forKey:@"icon"];
//    [innerParams setObject:[BOSConfig sharedConfig].currentUser.personId forKey:@"personId"];
    [params setObject:innerParams forKey:@"params"];
    
    [super post:openapi_mark_create body:params header:[self wfHeader]];
}

- (void)deleteMarkWithId:(NSString *)markId{ //personId:(NSString *)personId {
//    self.shouldSign = YES;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:markId forKey:@"id"];
    [super post:openapi_mark_delete body:params header:[self wfHeader]];
}

- (void)queryMarkListWithId:(NSString *)markId
                   pageSize:(int)pageSize
                  direction:(int)direction{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:markId forKey:@"id"];
    [params setObject:@(pageSize) forKey:@"pagesize"];
    [params setObject:@(direction) forKey:@"direction"];
    [super post:openapi_mark_list body:params header:[self wfHeader]];
}

- (void)createMergeWithGroupId:(NSString *)groupId
                   mergeMsgIds:(NSArray *)msgIds { 
    //self.shouldSign = YES;
    self.shouldAppendUA = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:safeString(groupId) forKey:@"groupId"];
    [params setObject:msgIds forKey:@"mergeMsgIds"];
    [super post:openapi_create_merge body:params header:[self wfHeader]];
}

- (void)getMergeWithMergeId:(NSString *)mergeId {
    //self.shouldSign = YES;
    self.shouldAppendUA = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:safeString(mergeId) forKey:@"mergeId"];
    [super post:openapi_get_merge body:params header:[self wfHeader]];
}


- (void)getInnerQRUrlWithGroupId:(NSString *)groupId {
    //self.shouldSign = YES;
    self.bodyType = BOSConnectBodyWithParam;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupId forKey:@"groupId"];
    [super post:EMPSERVERURL_INNERQRURL body:params header:[self wfHeader]];
}

@end
