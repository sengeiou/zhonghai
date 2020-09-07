//
//  KDRequestQueue.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDRequestQueueServices.h"

#import "ASINetworkQueue.h"
#import "KDRequestWrapper.h"


extern NSString * const kKDRequestQueueErrorDomain;
extern NSString * const kKDRequestQueueErrorDropRequestReasonKey;


@interface KDRequestQueue : NSObject <KDRequestQueueServices> {
@protected
    ASINetworkQueue *requestQueue_;
    
    NSMutableArray *pendingRequests_; // the requests waiting for run.
    NSMutableArray *runningRequests_; // the requests are running on the network queue. 
}

- (BOOL) isConcurrencySupport;

// sub-class should override if need, default is 1 and it's means run as serial
- (NSUInteger) maxConcurrencyCount;

// sub-class should override if need
- (BOOL) isValidRequestWrapper:(KDRequestWrapper *)requestWrapper;

// sub-class should override if need
- (BOOL) hasSameFingerprintInDataSource:(NSArray *)dataSource requestWrapper:(KDRequestWrapper *)requestWrapper;

- (BOOL) hasPendingRequestWrapper;

- (KDRequestWrapper *) anyRequestWrapperFromPendingList;
- (KDRequestWrapper *) requestWrapperWithHighestPriorityFromSource:(NSArray *)dataSource;

// sub-class should override if need. default is call method anyRequestWrapperFromPendingList
- (KDRequestWrapper *) optimalRequestWrapperFromPendingList;

- (void) addToPendingList:(KDRequestWrapper *)requestWrapper;
- (void) addToRunningList:(KDRequestWrapper *)requestWrapper;
- (BOOL) migrateRequestWraperFromPendingToRunning:(KDRequestWrapper *)requestWrapper;

- (void) dropRequest:(KDRequestWrapper *)request error:(NSError *)error fromPendingList:(BOOL)fromPendingList;

- (KDRequestWrapper *) mappedRequestWrapperForRequest:(ASIHTTPRequest *)request;

// The sub-classes should override these methods if need for monitor request status

- (void) requestDidFinish:(ASIHTTPRequest *)request;

- (void) queueRequestDidStart:(ASIHTTPRequest *)request;
- (void) queueRequest:(ASIHTTPRequest *)request didRecieveResponseHeaders:(NSDictionary *)responseHeaders;
- (void) queueRequestDidFinish:(ASIHTTPRequest *)request;
- (void) queueRequestDidFail:(ASIHTTPRequest *)request;
- (void) queueNetworkQueueDidFinish:(ASINetworkQueue *)queue;


@end
