//
//  KDDocumentUpload.h
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-16.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDUploadTask.h"
#import "KDWeiboServicesContext.h"
#import "KDServiceActionInvoker.h"

@interface KDDocumentUploadTask : KDUploadTask {
    @protected
    NSString *fetchedFileId_;
    NSString *uploadingDocPath_;
    NSString *actionPath_;
}

@property (nonatomic, copy)NSString *fetchedFileId;
@property (nonatomic, readonly)NSString *uploadingDocPath;
@property (nonatomic, copy,readonly)NSString *actionPath;
@property (nonatomic, assign)BOOL disableShowingProgress;  //是否禁掉显示上传过程
- (void)progress:(KDRequestProgressMonitor *)progressMonitor;
- (NSInteger)indexAmongBrothers; //在supertask 的subtasks 中的index
- (NSInteger)brothersCount;//supertask 的subtask 数
- (NSString *)documentType;
@end
