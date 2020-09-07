//
//  KDDraftManager.m
//  kdweibo_common
//
//  Created by Tan Yingqi on 14-1-6.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "KDDraftManager.h"
#import "KDWeiboDAOManager.h"
#import "KDDatabaseHelper.h"


@implementation KDDraftManager

+ (KDDraftManager *)shareDraftManager {
    static KDDraftManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KDDraftManager alloc] init];
    });
    
    return manager;
}


- (void)deleteDrafts:(NSArray *)draftArray completionBlock:(void (^)(id result))block {
    if (!draftArray || [draftArray count] == 0) {
        return;
    }
    [KDDatabaseHelper inTransaction:(id)^(FMDatabase *fmdb, BOOL *rollBack) {
        id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
        id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
        __block BOOL success = YES;
        __block KDDraft * draft = nil;
        [draftArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            draft = obj;
            success = [draftDAO removeDraftWithId:draft.draftId database:fmdb];
            if (!success) {
                DLog(@"remove Darft failed");
                *stop = YES;
            }
            if (draft.type != KDDraftTypeCommentForStatus &&
                draft.type != KDDraftTypeCommentForComment &&
                draft.type != KDDraftTypeForwardStatus &&
                draft.type != KDDraftTypeShareSign) {
                if (!draft.groupId) { // 删除在数据库中对应的微博
                    [statusDAO removeStatusWithId:[NSString stringWithFormat:@"%ld",(long)draft.draftId] database:fmdb];
                }else {
                    [statusDAO removeGroupStatusWithId:[NSString stringWithFormat:@"%ld",(long)draft.draftId] database:fmdb];
                }
            }
            
        }];
        *rollBack = !success;
        return @(success);
    } completionBlock:^(id results) {
        if (block) {
            block(results);
        }
    
    }];
    
}


@end
