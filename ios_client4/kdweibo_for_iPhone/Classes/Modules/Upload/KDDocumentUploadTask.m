//
//  KDDocumentUpload.m
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-16.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDDocumentUploadTask.h"

@implementation KDDocumentUploadTask
@synthesize fetchedFileId = fetchedFileId_;
@synthesize uploadingDocPath = uploadingDocPath_;
@synthesize actionPath = actionPath_;

- (NSString *)fetchedFileId {
    if (self.subTasks) {
        NSMutableArray *fileids =[NSMutableArray array];
        for (KDDocumentUploadTask *task in self.subTasks) {
            if (!task.fetchedFileId) {
                return @"";
            }
            [fileids addObject:task.fetchedFileId];
        }
        return [fileids componentsJoinedByString:@","];
    }
    return fetchedFileId_;
}


- (void)main {
    [self startUpload];
}

- (void)taskDidSuccess {
    if ([self isCanceled]||[self isFailed]) {
        return;
    }
    if (!self.subTasks) {
        if ([self documentType] && !self.disableShowingProgress) {
            MTStatusBarOverlay *overlay = [[KDWeiboAppDelegate getAppDelegate] getOverlay];
            float percent = (float)([self indexAmongBrothers] + 1)/[self brothersCount];
            percent = percent > 1.0f?1.0f:percent;
            NSString *message = [NSString stringWithFormat:ASLocalizedString(@"KDDocumentUploadTask_upload"),[self documentType],(int)(percent *100),@"%"];
            [overlay postImmediateMessage:message animated:NO];
        }
    }
    [super taskDidSuccess];
}


- (NSString *)documentType {
    return ASLocalizedString(@"KDDocumentUploadTask_attachment");
}
- (void)startUpload {
    /**
     *  如果是分享文件到动态，此时文件已经在服务器，不需要以下上传的操作了，直接使用这个fileId就好了
     *  alanwong
     */
    if(self.fetchedFileId) {
        [self  taskDidSuccess];
        return;
    }
   
    if (!self.uploadingDocPath ||![[NSFileManager defaultManager] fileExistsAtPath:self.uploadingDocPath]|| !self.actionPath) {
        [self taskDisFailed];
        return;
    }
    
    
    
    __block KDDocumentUploadTask *task = self;// retain];
        KDQuery *query = [KDQuery query];
        [query setParameter:@"pic" filePath:self.uploadingDocPath];
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            if([response isValidResponse]){
                if (results) {
                     task.fetchedFileId = results;
                     [task  taskDidSuccess];
                }else {
                    [task taskDisFailed];
                }
            }
            else {
                if (![response isCancelled]) {
                    [task taskDisFailed];
                }else {
                    [task taskDidCanceled];
                }                
            }
//            [task release];
        };
        
        [KDServiceActionInvoker invokeWithSender:self actionPath:self.actionPath query:query
                                     configBlock:nil completionBlock:completionBlock];
}

- (NSString *)actionPath {
    if (!actionPath_) {
        actionPath_ = [@"/upload/:multipleDoc" copy];
    }
    return actionPath_;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(fetchedFileId_);
    //KD_RELEASE_SAFELY(uploadingDocPath_);
    //KD_RELEASE_SAFELY(actionPath_);
    //[super dealloc];
}

- (void)cancel {
    if (!self.subTasks) {
        DLog(@"cancel... doc. ");
        [KDServiceActionInvoker cancelInvokersWithSender:self];
        [self taskDidCanceled];
    }
}

- (void)progress:(KDRequestProgressMonitor *)progressMonitor {
    if ([self documentType] && ![self isFailed] && !self.disableShowingProgress) {
        MTStatusBarOverlay *overlay = [[KDWeiboAppDelegate getAppDelegate] getOverlay];
        float base = (float)[self indexAmongBrothers]/[self brothersCount];
        float percent = base + [progressMonitor finishedPercent] *(1/(float)[self brothersCount]);
        percent = percent > 1.0f?1.0f:percent;
        DLog(@"base = %f",(float)[self indexAmongBrothers]/[self brothersCount]);
        DLog(@"part = %f",[progressMonitor finishedPercent]);
        NSString *message = [NSString stringWithFormat:ASLocalizedString(@"KDDocumentUploadTask_upload"),[self documentType],(int)(percent *100),@"%"];
        [overlay postImmediateMessage:message animated:NO];
    }
}

- (NSInteger)indexAmongBrothers {
    NSInteger index = 0;
    if (!self.subTasks) {
        if (self.superTask) {
           index =  [self.superTask.subTasks indexOfObject:self];
        }
    }
    return index;
}
- (NSInteger)brothersCount {
    NSInteger count = 1;
    if (!self.subTasks) {
        if (self.superTask) {
            count = [self.superTask.subTasks count];
        }
    }
    return count;
}
@end
