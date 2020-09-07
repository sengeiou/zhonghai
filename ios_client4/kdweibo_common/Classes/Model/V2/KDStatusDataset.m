//
//  KDStatusDataset.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-19.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDStatusDataset.h"

#import "KDDBManager.h"
#import "KDWeiboDAOManager.h"

@interface KDStatusDataset ()

@property(nonatomic, retain) NSMutableArray *statuses;

@end

@implementation KDStatusDataset

@synthesize statuses=statuses_;

- (id)init {
    self = [super init];
    if (self) {
        statuses_ = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusAttrUpdate:) name:kKDStatusAttributionShouledUpdated object:nil];
    }
    
    return self;
}


- (void)statusAttrUpdate:(NSNotification *)notification {
    KDStatus *status = [[notification userInfo] objectForKey:@"status"];
    if (status) {
        KDStatus *statusInDataset = [self statusById:status.statusId];
        if (statusInDataset != status && [status.statusId isEqualToString:statusInDataset.statusId]) { //如果修改的status 不再当前Dataset 中，并且id 相等。
            statusInDataset.forwardsCount = status.forwardsCount;
            statusInDataset.commentsCount = status.commentsCount;
            statusInDataset.likedCount = status.likedCount;
            statusInDataset.liked = status.liked;
            statusInDataset.favorited = status.favorited;
        }
    }
}

- (NSUInteger)count {
    return [statuses_ count];
}

- (KDStatus *)statusAtIndex:(NSUInteger)index {
    if (!statuses_ ||[statuses_ count] == 0  ) {
        return nil;
    }
    return [statuses_ objectAtIndex:index];
}

- (KDStatus *)statusById:(NSString *)statusId {
    if (statusId == nil) return nil;
    
    KDStatus *target = nil;
    for (KDStatus *s in statuses_) {
        if ([s.statusId isEqualToString:statusId]) {
            target = s;
            break;
        }
    }
    
    return target;
}

- (KDStatus *)lastStatus {
    return [statuses_ lastObject];
}

- (KDStatus *)firstStatus {
    if([statuses_ count] == 0) return nil;
    
    return [statuses_ objectAtIndex:0];
}

- (NSArray *)allStatuses {
    return statuses_;
}

- (BOOL)contains:(KDStatus*)status {
    return [statuses_ containsObject:status];
}

- (void)removeStatusAtIndex:(int)index {
    [statuses_ removeObjectAtIndex:index];
}

- (void)removeAllStatuses {
    [statuses_ removeAllObjects];
}

- (void)removeStatus:(KDStatus *)status {
    if (status != nil) {
        [statuses_ removeObject:status];
    }
}

- (void)removeStatusesById:(NSArray *)statusId
{
    KDStatus *delStatusInDataSet = nil;
    NSMutableArray *delStatusArray = [NSMutableArray array];
    for (NSString *delStatusId in statusId) {
        delStatusInDataSet = [self statusById:delStatusId];
        [self queryStatusWithFowardStateId:delStatusInDataSet];
        if (delStatusInDataSet) {
            [delStatusArray addObject:delStatusInDataSet];
        }
    }
    if ([delStatusArray count] >0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kKDStatusShouldDeleted object:self userInfo:@{@"status": delStatusArray}];
    }
    
}


- (void)queryStatusWithFowardStateId:(KDStatus *)status
{
    if (status == nil) return ;
    for (KDStatus *s in statuses_) {
        if ([s.forwardedStatus.statusId isEqualToString:status.statusId]) {
            s.replyScreenName = nil;
            s.forwardedStatus.author = nil;
            s.forwardedStatus.text = ASLocalizedString(@"KDStatusDataset_weibo_delete");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"delectCache" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:s,@"status", nil]];
        }
    }
}


- (void)removeLastStatus {
    [statuses_ removeLastObject];
}

- (void)appendStatus:(KDStatus *)status {
    [statuses_ addObject:status];
}

- (void)insertStatus:(KDStatus *)status atIndex:(int)index {
    KDStatus *theStatus = [self statusById:status.statusId];
    if (theStatus) {
        [self replaceStatus:theStatus withStatus:status];
    }
    else {
        [statuses_ insertObject:status atIndex:index];
    }
}


- (void)mergeStatuses:(NSArray *)items atHead:(BOOL)head limit:(NSInteger)limit configureBloc:(void(^)(NSArray * array))block {
    if([items count] == 0) return;
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSInteger index = NSNotFound;
    KDStatus *statusInDataSet = nil;
    NSMutableArray *outArray = [NSMutableArray array];
    for (KDStatus *status in items) {
        statusInDataSet = [self statusById:status.statusId];
        if (statusInDataSet) {
            index = [self indexOfStatus:statusInDataSet];
            [outArray addObject:statusInDataSet];
        }
        if (index != NSNotFound) {
            [indexSet addIndex:index];
        }
    }
    //添加之前，删除原来相同id 的status
    if (block) {
        if (outArray && [outArray count] >0) {
            block(outArray);
        }
    }
    if ([indexSet count] >0) {
        [self.statuses removeObjectsAtIndexes:indexSet];
    }
    
    if(head){
        NSMutableArray *temp = [NSMutableArray arrayWithArray:items];
        [temp addObjectsFromArray:self.statuses];
        self.statuses = temp;
        
    }else {
        [statuses_ addObjectsFromArray:items];
    }
    
    NSUInteger boundary = 50;
    if(limit > 0){
        boundary = limit;
    }
    
    NSUInteger count = [statuses_ count];
    if(head && count > boundary){
        // If insert items at head, so the statuses at tail must be remove
        NSRange range = NSMakeRange(boundary, count - boundary);
        [statuses_ removeObjectsInRange:range];
    }
}

- (void)mergeStatuses:(NSArray *)items atHead:(BOOL)head limit:(NSInteger)limit {
    if([items count] == 0) return;
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSInteger index = NSNotFound;
    KDStatus *statusInDataSet = nil;
    for (KDStatus *status in items) {
        statusInDataSet = [self statusById:status.statusId];
        if (statusInDataSet) {
            index = [self indexOfStatus:statusInDataSet];
        }
        if (index != NSNotFound) {
            [indexSet addIndex:index];
        }
    }
    //添加之前，删除原来相同id 的status
    if ([indexSet count] >0) {
        [self.statuses removeObjectsAtIndexes:indexSet];
    }
    
    if(head){
        NSMutableArray *temp = [NSMutableArray arrayWithArray:items];
        [temp addObjectsFromArray:self.statuses];
        self.statuses = temp;
        
    }else {
        [statuses_ addObjectsFromArray:items];
    }
    
    NSUInteger boundary = 50;
    if(limit > 0){
        boundary = limit;
    }
    
    NSUInteger count = [statuses_ count];
    if(head && count > boundary){
        // If insert items at head, so the statuses at tail must be remove
        NSRange range = NSMakeRange(boundary, count - boundary);
        [statuses_ removeObjectsInRange:range];
    }
}

- (void)mergeStatuses:(NSArray *)items atHead:(BOOL)atHead {
    if(atHead) {
        for(KDStatus *st in items) {
            for(KDStatus *status in statuses_) {
                if([status.statusId isEqualToString:st.statusId]) {
                    [statuses_ removeObject:status];
                    break;
                }
            }
        }
        
        [statuses_ insertObjects:items atIndexes:[NSIndexSet indexSetWithIndexesInRange:(NSRange){0,items.count}]];
    } else {
        [statuses_ addObjectsFromArray:items];
    }
}

- (void)mergeStatuses:(NSArray *)items atHead:(BOOL)atHead configureBloc:(void(^)(NSArray * array))block {
    if(atHead) {
        NSMutableArray *outArray = nil;
        for(KDStatus *st in items) {
            for(KDStatus *status in statuses_) {
                if([status.statusId isEqualToString:st.statusId]) {
                    if (!outArray) {
                        outArray = [NSMutableArray array];
                    }
                    [outArray addObject:status];
                    [statuses_ removeObject:status];
                    break;
                }
            }
        }
        
        [statuses_ insertObjects:items atIndexes:[NSIndexSet indexSetWithIndexesInRange:(NSRange){0,items.count}]];
        if (block && outArray) {
            block(outArray);
        }
    } else {
        [statuses_ addObjectsFromArray:items];
    }
}


- (NSUInteger)indexOfStatus:(KDStatus *)status {
    if (status == nil) return NSNotFound;
    
    return [statuses_ indexOfObject:status];
}

- (void)replaceStatus:(KDStatus *)status withStatus:(KDStatus *)theStatus {
    if (status && [self contains:status]) {
        //
        NSInteger index = [statuses_ indexOfObject:status];
        [statuses_ replaceObjectAtIndex:index withObject:theStatus];
    }
}

- (KDStatus *)sinceStatus {
    KDStatus *status = nil;
    for (status in self.statuses) {
        if (![status.statusId hasPrefix:@"-"]&& status.sendingState ==  KDStatusSendingStateNone) {//必须是从服务器取回来的
            break;
        }
    }
    return status;
}

- (KDStatus *)maxStatus {
    KDStatus *status = nil;
    for (status in [self.statuses reverseObjectEnumerator]) {
        if (![status.statusId hasPrefix:@"-"] && status.sendingState ==  KDStatusSendingStateNone) {
            break;
        }
    }
    return status;
    
}

///////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Utlity methods

+ (void)cachedStatusesWithType:(KDTLStatusType)type limit:(NSUInteger) limit
               completionBlock:(void (^)(NSArray *))completionBlock {
    // execute the query in sub thread to avoid block main thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        __block NSArray *statuses = nil;
        
        [[KDDBManager sharedDBManager].fmdbQueue inDatabase:^(FMDatabase *fmdb){
            id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
            
            //zgbin:数据库加字段
            [statusDAO addFieldWithFMDatabase:fmdb];
            //end
            
            switch (type) {
                case KDTLStatusTypeCommentMe:
                    statuses = [statusDAO queryCommentMeStatusesWithLimit:limit database:fmdb];
                    break;
                    
                case KDTLStatusTypeMentionMe:
                    statuses = [statusDAO queryMentionMeStatusesWithLimit:limit database:fmdb];
                    break;
                    
                default:
                    statuses = [statusDAO queryStatusesWithTLType:type limit:limit database:fmdb];
                    break;
            }
        }];
        if (completionBlock != nil) {
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                completionBlock(statuses);
                
            });
        }
    });
}

+ (void)cachedStatusesWithType:(KDTLStatusType)type
               completionBlock:(void (^)(NSArray *))completionBlock {
    // execute the query in sub thread to avoid block main thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        __block NSArray *statuses = nil;
        
        [[KDDBManager sharedDBManager].fmdbQueue inDatabase:^(FMDatabase *fmdb){
            id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
            
            //zgbin:数据库加字段
            [statusDAO addFieldWithFMDatabase:fmdb];
            //end
            
            switch (type) {
                case KDTLStatusTypeCommentMe:
                    statuses = [statusDAO queryCommentMeStatusesWithLimit:20 database:fmdb];
                    break;
                    
                case KDTLStatusTypeMentionMe:
                    statuses = [statusDAO queryMentionMeStatusesWithLimit:20 database:fmdb];
                    break;
                    
                default:
                    statuses = [statusDAO queryStatusesWithTLType:type limit:50 database:fmdb];
                    break;
            }
        }];
        if (completionBlock != nil) {
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                completionBlock(statuses);
                
            });
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //KD_RELEASE_SAFELY(statuses_);
    
    //[super dealloc];
}

@end

