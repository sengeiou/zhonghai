//
//  KDStatusUploadTask.m
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-12.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDStatusUploadTask.h"
#import "KDDatabaseHelper.h"
#import "KDWeiboDAOManager.h"
#import "KDCommentUploadTask.h"
#import "KDForwardStatusUploadTask.h"
#import "KDNormalStatusUploadTask.h"
#import "KDVideoCoverUploadTask.h"
#import "KDSignShareUploadTask.h"
#import "KDDraftManager.h"

@interface KDStatusUploadTask ()

@end

@implementation KDStatusUploadTask
@synthesize query = query_;
@synthesize actionPath = actionPath_;
@synthesize entity = status_;
@synthesize fetchedStatus = fetchedStaus_;
@synthesize draft = draft_;

+ (KDStatusUploadTask *)taskByDraft:(KDDraft *)draft status:(KDStatus *)status {
    KDStatusUploadTask *statusTask = nil;
    if (status.type == KDTLStatusTypeComment) {
        statusTask = [[KDCommentUploadTask alloc] init];// autorelease];
    }else if(status.type == KDTLStatusTypeForwarded) {
        statusTask = [[KDForwardStatusUploadTask alloc] init];;// autorelease];
    }else if(status.type == KDTLStatusTypeShareSignin) {
        statusTask = [[KDSignShareUploadTask alloc] init];// autorelease];
    }
    else {
        statusTask = [[KDNormalStatusUploadTask alloc] init];//; autorelease];
    }
    statusTask.draft = draft;
    statusTask.entity = status;
    return statusTask;
}

- (void)setEntity:(id)entity {
    if (status_ != entity) {
//        [status_ release];
        status_ = entity;// retain];
        KDDocumentUploadTask *documentUploadTask =[[KDDocumentUploadTask alloc] init] ;//autorelease];
        if (status_.extraSourceMask&KDExtraSourceMaskDocuments) { //视频
            KDVideoUploadTask *videoUploadTask = [KDVideoUploadTask videoUploadTaskWithAttachements:status_.attachments];
            if (videoUploadTask) {
                [documentUploadTask addSubTask:videoUploadTask];
            }
            if (status_.extraSourceMask&KDExtraSourceMaskImages) {
                KDVideoCoverUploadTask *coverTask = (KDVideoCoverUploadTask *)[KDVideoCoverUploadTask imageUploadTaskWithCompositeImageSource:status_.compositeImageSource];
                 //videoUploadTask.dependency = coverTask;
                [documentUploadTask addSubTask:coverTask];
            }
            
        }else if(status_.extraSourceMask &KDExtraSourceMaskImages) {
            KDImageUploadTask *imageUploadTask = [KDImageUploadTask imageUploadTaskWithCompositeImageSource:status_.compositeImageSource];
            if (imageUploadTask) {
                [documentUploadTask addSubTask:imageUploadTask];
            }
        }
        else {
            if (status_.attachments) {
                KDDocumentUploadTask *subTask;
                for (KDAttachment *attachemnt in status_.attachments) {
                    subTask = [[KDDocumentUploadTask alloc] init];// autorelease];
                    subTask.fetchedFileId = attachemnt.fileId;
                    subTask.disableShowingProgress = YES;
                    [documentUploadTask addSubTask:subTask];
                }
            }
        }
        
        if (!documentUploadTask.subTasks ||[documentUploadTask.subTasks count] == 0) {
             return;
        }
        self.dependency = documentUploadTask;
    }
}


- (void)handleResults:(id)results {
    self.fetchedStatus = results[0];
    self.fetchedStatus.sendingState = KDStatusSendingStateSuccess;
}

- (KDQuery *)query {
    if (!query_) {
        query_ = [KDQuery query];// retain];
        if (status_.groupId) {
            [query_ setParameter:@"group_id" stringValue:status_.groupId];
        }

//        if (status_.compositeImageSource && self.dependency) {
//            [query_ setParameter:@"fileids" stringValue:[(KDDocumentUploadTask *)self.dependency fetchedFileId]];
//        }
        
        /**
         *  分享文件时，只会有fileId，没有资源路径，所以不要判断compositeImageSource
         *
         *  alanwong
         *
         */
        if (self.dependency) {
            [query_ setParameter:@"fileids" stringValue:[(KDDocumentUploadTask *)self.dependency fetchedFileId]];
        }

        if (status_.address) {
            [query_ setParameter:@"lat" floatValue:status_.latitude];
            [query_ setParameter:@"long" floatValue:status_.longitude];
            [query_ setParameter:@"address" stringValue:status_.address];
        }
    }
    return query_;
}

- (void)main {
    if (!self.actionPath ||!self.query) {
        [self taskDisFailed];
        return;
    }
    __block KDStatusUploadTask *task = self ;//retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]){
            if (results) {
                [task handleResults:results];
                [task  taskDidSuccess];
            }else {
                [task taskDisFailed];
            }
        }
        else {
            if (![response isCancelled]) {
                [task taskDisFailed];
            }else { //被取消
                [task taskDidCanceled];
                //[task taskDisFailed];
            }
            
        }
//        [task release];
    };
 
    [KDServiceActionInvoker invokeWithSender:self actionPath:self.actionPath query:self.query
                                 configBlock:nil completionBlock:completionBlock];
    
}


- (void)taskWillStart {
    //发送之前先保存
    status_.sendingState = KDStatusSendingStateProcessing;
    [self saveStatus];
    [self sycDraftBeforeSend];
 
    if (self.draft &&  self.draft.type != KDDraftTypeForwardStatus && self.draft.type != KDDraftTypeShareSign) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kKDStatusOnPosting object:nil userInfo:@{@"status": status_}];
    }
    
    MTStatusBarOverlay *overlay = [[KDWeiboAppDelegate getAppDelegate] getOverlay];
    [overlay postImmediateMessage:[self processingMessage] animated:YES];
   
}

- (void)cancel {
      DLog(@"cancel....ssssss");
    [KDServiceActionInvoker cancelInvokersWithSender:self];
    [self taskDidCanceled];

}

- (KDDraft *)draft {
    if (!draft_) {
        if (status_ && [status_ statusId] && [[status_ statusId] hasPrefix:@"-"]) {
            __block KDDraft *draft = nil;
            //draft
            [KDDatabaseHelper inDatabase:^id(FMDatabase *fmdb) {
                id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
                NSArray *array = [draftDAO queryAllDraftsWithDraftId:[status_.statusId integerValue] database:fmdb];
                if (array && [array count] >0) {
                    draft = (KDDraft *)(array[0]);
//                    DLog(ASLocalizedString(@"从数据库获取draft 成功"));
                }
                return nil;
            }completionBlock:nil];
            draft_ = draft;// retain];
        }
      
    }
    return draft_;
}


- (void)taskDidSuccess {
    if ([self isCanceled]||[self isFailed]) {
        return;
    }
    MTStatusBarOverlay *overlay = [[KDWeiboAppDelegate getAppDelegate] getOverlay];
    [overlay postImmediateFinishMessage:[self successMsg] duration:1.0 animated:YES];
    
    [self saveFetchedStatus];
    [self sycDraftOnSuccess];
    [super taskDidSuccess];
}

- (void)taskDisFailed {
    [[KDSession globalSession] setUnsendedStatus:status_];
    
     status_.sendingState = KDStatusSendingStateFailed;
     MTStatusBarOverlay *overlay = [[KDWeiboAppDelegate getAppDelegate] getOverlay];
     [overlay postImmediateErrorMessage:[self errorMessage] duration:1.0 animated:YES];

    //同步草稿
     [self sycDraftOnFailed];
    
     [self saveStatus];
   
     [super taskDisFailed];
}

- (void)sycDraftOnSuccess {
    if (self.draft) {
        //删除数据库对应的draft
        [[KDDraftManager shareDraftManager] deleteDrafts:@[self.draft] completionBlock:nil];
    }
}


- (void)saveDraft {
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
        id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
        if (draft_.saved) {
            [draft_ realMask];
            [draftDAO updateDraft:draft_ database:fmdb];
            
        } else {
             [draftDAO saveDraft:draft_ database:fmdb];
        }
        return nil;
        
    } completionBlock:nil];

}

- (void)sycDraftBeforeSend {
    if (self.draft) {
        draft_.sending = YES;
        [self saveDraft];
    }
}

- (void)sycDraftOnFailed {
    if (self.draft) {
        draft_.sending = NO;
        [self saveDraft];
    }
}

- (void)saveStatus {
    if (status_ && [self shouldSaveStatus] ) {
        [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
            id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
            if ([status_ isGroup]) {
                [statusDAO saveGroupStatus:(KDGroupStatus *)status_ database:fmdb];
            }else {
                [statusDAO saveStatus:status_ database:fmdb];
            }
            return nil;
        } completionBlock:nil];
    }
}

- (void)saveFetchedStatus {
    if (self.fetchedStatus && [self shouldSaveStatus]) {
        [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
            id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
            if ([status_ isGroup]) {
                
                [statusDAO saveGroupStatus:(KDGroupStatus *)self.fetchedStatus database:fmdb];
            }else {
                [statusDAO saveStatus:self.fetchedStatus database:fmdb];
            }
            
            return nil;
        }completionBlock:nil];
    }

}

- (BOOL)shouldSaveStatus {
    return (self.draft.type!= KDDraftTypeShareSign &&
            self.draft.type!= KDDraftTypeCommentForComment&&
            self.draft.type!=KDDraftTypeCommentForStatus&&
            self.draft.type!=KDDraftTypeForwardStatus);
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(actionPath_);
    //KD_RELEASE_SAFELY(query_);
    //KD_RELEASE_SAFELY(status_);
    //KD_RELEASE_SAFELY(fetchedStaus_);
    //KD_RELEASE_SAFELY(draft_);
    //[super dealloc];
}

- (NSString *)processingMessage {
    return ASLocalizedString(@"KDStatusUploadTask_processingMessage");
}
- (NSString *)errorMessage {
    return ASLocalizedString(@"KDStatusUploadTask_errorMessage");
}
- (NSString *)successMsg {
    return ASLocalizedString(@"KDStatusUploadTask_successMsg");
}

@end
