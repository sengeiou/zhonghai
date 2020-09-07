//
//  KDStatusDataset.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-19.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDStatus.h"

// The container of status dataset 
@interface KDStatusDataset : NSObject

- (void)appendStatus:(KDStatus *)status;
- (void)insertStatus:(KDStatus *)status atIndex:(int)index;

//合并status，限制数量 50
- (void)mergeStatuses:(NSArray *)items atHead:(BOOL)head limit:(NSInteger)limit;
- (void)mergeStatuses:(NSArray *)items atHead:(BOOL)head limit:(NSInteger)limit configureBloc:(void(^)(NSArray * array))block;

// 没有限制数量
- (void)mergeStatuses:(NSArray *)items atHead:(BOOL)atHead;
- (void)mergeStatuses:(NSArray *)items atHead:(BOOL)atHead configureBloc:(void(^)(NSArray * array))block;


- (KDStatus *)statusAtIndex:(NSUInteger)index;
- (KDStatus *)statusById:(NSString *)statusId;

- (KDStatus *)lastStatus;
- (KDStatus *)firstStatus;
- (NSArray *)allStatuses;

- (NSUInteger)indexOfStatus:(KDStatus *)status;

- (NSUInteger)count;

- (KDStatus *)sinceStatus;//获取timeline的参数sinceId 的status，过滤id 为负(新创建还未成功发送)的情况

- (KDStatus *)maxStatus;//同上

- (BOOL)contains:(KDStatus*)status;
- (void)removeLastStatus;
- (void)removeStatusAtIndex:(int)index;
- (void)removeStatus:(KDStatus *)status;
- (void)removeAllStatuses;
- (void)replaceStatus:(KDStatus *)status withStatus:(KDStatus *)theStatus;
//删除微博
- (void)removeStatusesById:(NSArray *)statusId;

//- (KDStatus *)queryStatusWithFowardStateId:(NSArray *)statusId;

+ (void)cachedStatusesWithType:(KDTLStatusType)type
               completionBlock:(void (^)(NSArray *))completionBlock;
+ (void)cachedStatusesWithType:(KDTLStatusType)type limit:(NSUInteger) limit
               completionBlock:(void (^)(NSArray *))completionBlock;

@end
