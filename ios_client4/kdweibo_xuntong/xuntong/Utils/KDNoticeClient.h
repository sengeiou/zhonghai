//
//  KDNoticeClient.h
//  kdweibo
//
//  Created by kingdee on 17/4/17.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "BOSConnect.h"

@interface KDNoticeClient : BOSConnect
#define EMPSERVERURL_NOTICE_CREATE @"/ecLite/convers/notice/create.action"
- (void)createNoticeWithGroupId:(NSString *)groupId title:(NSString *)title content:(NSString *)content;

#define EMPSERVERURL_NOTICE_NEWEST @"/ecLite/convers/notice/newest.action"
- (void)newestNoticeWithGroupId:(NSString *)groupId;

#define EMPSERVERURL_NOTICE_LIST @"/ecLite/convers/notice/list.action"
- (void)listNoticeWithGroupId:(NSString *)groupId noticeId:(NSString *)noticeId count:(NSString *)count;

#define EMPSERVERURL_NOTICE_DELETE @"/ecLite/convers/notice/delete.action"
- (void)deleteNoticeWithNoticeId:(NSString *)noticeId;
@end
