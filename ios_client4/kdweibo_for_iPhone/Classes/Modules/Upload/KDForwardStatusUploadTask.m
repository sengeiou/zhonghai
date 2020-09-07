//
//  KDForwardStatusUploadTask.m
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-13.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDForwardStatusUploadTask.h"

@implementation KDForwardStatusUploadTask


- (NSString *)actionPath {
    if (!actionPath_) {
        if (status_.groupId) {
            actionPath_ =  [[NSString alloc] initWithString:@"/group/statuses/:repost"];
        }else {
            actionPath_ =  [[NSString alloc] initWithString:@"/statuses/:repost"];
        }
    }
    return actionPath_;
}

- (KDQuery *)query {
    if (!query_) {
        query_ = [super query];
        
        [query_ setParameter:@"is_comment" intValue:self.draft.doExtraCommentOrForward];
        [[query_ setParameter:@"status" stringValue:status_.text]
         setParameter:@"id" stringValue:status_.forwardedStatus.statusId];
    }
    return query_;
}

- (NSString *)processingMessage {
    return ASLocalizedString(@"KDForwardStatusUploadTask_tran");
}
- (NSString *)errorMessage {
    return ASLocalizedString(@"KDForwardStatusUploadTask_tran_fail");
}
- (NSString *)successMsg {
    return ASLocalizedString(@"KDForwardStatusUploadTask_tran_suc");
}


@end
