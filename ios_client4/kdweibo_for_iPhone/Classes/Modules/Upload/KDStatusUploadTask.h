//
//  KDStatusUploadTask.h
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-12.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDUploadTask.h"
#import "KDStatus.h"
#import "KDImageUploadTask.h"
#import "KDWeiboServicesContext.h"
#import "KDServiceActionInvoker.h"
#import "KDCommentStatus.h"
#import "KDVideoUploadTask.h"
#import "KDDraft.h"

@interface KDStatusUploadTask : KDUploadTask {
    @protected
    KDStatus *status_;
    NSString *actionPath_;
    KDQuery *query_;
}

@property(nonatomic,retain)KDStatus *fetchedStatus; //成功返回
@property(nonatomic,retain)NSString *actionPath;
@property(nonatomic,retain)KDQuery *query;
@property(nonatomic,retain)KDDraft *draft;

- (NSString *)processingMessage;
- (NSString *)errorMessage;
- (NSString *)successMsg;
//对网络请求返回的操作
- (void)handleResults:(id)results;

+ (KDStatusUploadTask *)taskByDraft:(KDDraft *)draft status:(KDStatus *)status;
@end
