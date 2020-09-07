//
//  KDCommentUploadTask.m
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-13.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDCommentUploadTask.h"

@implementation KDCommentUploadTask

- (NSString *)actionPath {
    if (!actionPath_) {
    if (status_.groupId) {
        actionPath_ =  @"/group/statuses/:comment";
    }else {
        actionPath_ =  @"/statuses/:comment";
      }
    }
    return actionPath_;
}

- (KDQuery *)query {
    if (!query_) {
        query_ = [super query];
        [query_ setParameter:@"comment_ori" stringValue:@"0"];
        [query_ setParameter:@"comment" stringValue:status_.text];
        [query_ setParameter:@"foward" booleanValue:self.draft.doExtraCommentOrForward];
        
        if ([(KDCommentStatus *)status_ status]) { //如果该条评论属于某条微博
             [query_ setParameter:@"id" stringValue:[[(KDCommentStatus *)status_ status] statusId]];
             [query_ setParameter:@"cid" stringValue:status_.replyStatusId];
            
        }else {
            [query_ setParameter:@"id" stringValue:status_.replyStatusId];

        }
    }
    return query_;
}
- (NSString *)processingMessage {
    return ASLocalizedString(@"KDCommentUploadTask_sending");
}
- (NSString *)errorMessage {
    return ASLocalizedString(@"KDCommentUploadTask_send_suc");
}
- (NSString *)successMsg {
    return ASLocalizedString(@"KDCommentUploadTask_send_fail");
}
@end
