//
//  KDTodoClient.h
//  kdweibo
//
//  Created by lichao_liu on 16/3/17.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOSConnect.h"

// OPENAPI CLIENT
@interface KDTodoClient : BOSConnect


#define openapi_mark_create @"/msgassist/message/mark/create.json"
- (void)createMarkWithMarkType:(int)markType
                     messageId:(NSString *)messageId
                        todoId:(NSString *)todoId
                       groupId:(NSString *)groupId
                         appId:(NSString *)appId
                         title:(NSString *)title
                          text:(NSString *)text
                           url:(NSString *)url
                        fileId:(NSString *)fileId
                          icon:(NSString *)icon;

#define openapi_mark_delete @"/msgassist/message/mark/delete.json"
- (void)deleteMarkWithId:(NSString *)markId ;// personId:(NSString *)personId;

#define openapi_mark_list @"/msgassist/message/mark/list.json"
- (void)queryMarkListWithId:(NSString *)markId
                   pageSize:(int)pageSize
                  direction:(int)direction;
                  // personId:(NSString *)personId;


#define openapi_create_merge @"/msgassist/message/merge/create.json"
- (void)createMergeWithGroupId:(NSString *)groupId
                   mergeMsgIds:(NSArray *)msgIds;

#define openapi_get_merge @"/msgassist/message/merge/get.json"
- (void)getMergeWithMergeId:(NSString *)mergeId;

#define EMPSERVERURL_INNERQRURL @"/invite/c/innerGroupQrcode/shareInfo.json"
- (void)getInnerQRUrlWithGroupId:(NSString *)groupId;


@end