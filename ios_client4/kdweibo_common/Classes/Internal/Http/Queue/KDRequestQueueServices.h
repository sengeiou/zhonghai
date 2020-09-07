//
//  KDRequestQueueServices.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KDRequestWrapperDelegate;
@class KDRequestWrapper;

@protocol KDRequestQueueServices <NSObject>
@required

- (void)addRequestWrapper:(KDRequestWrapper *)requestWrapper;
- (BOOL)hasRunningTasks;

// if drop is YES, then the request delegate can not responds delegate methods
- (void)cancelRequestWithTag:(NSInteger)tag dropDelegate:(BOOL)drop;
- (void)cancelRequestsWithIdentifier:(NSInteger)identifier;
- (void)cancelRequestsWithDelegate:(id<KDRequestWrapperDelegate>)delegate;
- (void)cancelRequestWithURLPrefix:(NSString *)urlPrefix;
- (void)removeAllRequests;

@end


@protocol KDRequestQueueTransferServices <NSObject>
@required

- (void)shouldChangeMaxConcurrentCount;
- (BOOL)isOnRequestQueueWithURL:(NSString *)url updatePriority:(BOOL)updatePriority;
- (BOOL)isImageSourceRequestFinishedWithURL:(NSString *)url;
@end

