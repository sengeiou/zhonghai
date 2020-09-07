//
//  KDRequestQueue.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"

#import "KDRequestQueue.h"
#import "KDResponseWrapper.h"
#import "NSString+Additions.h"
#import "KDWeiboLoginService.h"
#import "NSDictionary+Additions.h"

NSString * const kKDRequestQueueErrorDomain = @"com.kdweibo.KDRequestQueue";
NSString * const kKDRequestQueueErrorDropRequestReasonKey = @"reason";


@interface KDRequestQueue ()

@property (nonatomic, retain) ASINetworkQueue *requestQueue;

@property (nonatomic, retain) NSMutableArray *pendingRequests;
@property (nonatomic, retain) NSMutableArray *runningRequests;

- (void) invokeRequestWrapperDelegateSelector:(SEL)selector onObject:(id)object param1:(id)param1 param2:(id)param2 param3:(id)param3;

@end


@implementation KDRequestQueue

@synthesize requestQueue=requestQueue_;

@synthesize pendingRequests=pendingRequests_;
@synthesize runningRequests=runningRequests_;

- (id) init {
    self = [super init];
    if(self){
        pendingRequests_ = [[NSMutableArray alloc] init];
        runningRequests_ = [[NSMutableArray alloc] init];
        
        // setup network request queue
        requestQueue_ = [[ASINetworkQueue alloc] init];
        requestQueue_.delegate = self;
        requestQueue_.shouldCancelAllRequestsOnFailure = NO;
        requestQueue_.requestDidStartSelector = @selector(requestDidStart:);
        requestQueue_.requestDidReceiveResponseHeadersSelector = @selector(request:didRecieveResponseHeaders:);
        requestQueue_.requestDidFinishSelector = @selector(requestDidFinish:);
        requestQueue_.requestDidFailSelector = @selector(requestDidFail:);
        requestQueue_.queueDidFinishSelector = @selector(networkQueueDidFinish:);
        
        [requestQueue_ setMaxConcurrentOperationCount:[self maxConcurrencyCount]];
    }
    
    return self;
}

- (BOOL) isConcurrencySupport {
    return [self maxConcurrencyCount] > 0x01;
}

- (NSUInteger) maxConcurrencyCount {
    return 0x01;
}

// the sub-classes should override three methods if need at below
- (void) addRequestWrapper:(KDRequestWrapper *)requestWrapper {
    
}

- (BOOL) hasRunningTasks {
    return [requestQueue_ operationCount] > 0;
}

- (BOOL) isValidRequestWrapper:(KDRequestWrapper *)requestWrapper {
    BOOL isValid = YES;
    if(requestWrapper.url == nil){
        isValid = NO;
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"The request url can not be nil." forKey:kKDRequestQueueErrorDropRequestReasonKey];
        
        NSError *error = [NSError errorWithDomain:kKDRequestQueueErrorDomain code:0 userInfo:userInfo];
        [self dropRequest:requestWrapper error:error fromPendingList:NO];
    }
    
    return isValid;
}

- (BOOL) hasSameFingerprintInDataSource:(NSArray *)dataSource requestWrapper:(KDRequestWrapper *)requestWrapper {
    BOOL exists = NO;
    if(dataSource != nil){
        for(KDRequestWrapper *item in dataSource){
            if([item.fingerprint isEqualToString:requestWrapper.fingerprint]){
                exists = YES;
                
                break;
            }
        }
    }
    
    return exists;
}

- (void) dropRequest:(KDRequestWrapper *)requestWrapper error:(NSError *)error fromPendingList:(BOOL)fromPendingList {
    [self invokeRequestWrapperDelegateSelector:@selector(didDropRequestWrapper:error:) 
                                      onObject:requestWrapper.delegate 
                                        param1:requestWrapper 
                                        param2:error 
                                        param3:nil];
}

- (void) addRequestToNetworkQueue:(KDRequestWrapper *)requestWrapper {
    [requestQueue_ addOperation:[requestWrapper getHttpRequest]];
    if([requestQueue_ isSuspended]){
        [requestQueue_ setSuspended:NO];
    }
}

- (void) addToPendingList:(KDRequestWrapper *)requestWrapper {
    [pendingRequests_ addObject:requestWrapper];
}

- (void) addToRunningList:(KDRequestWrapper *)requestWrapper {
    [runningRequests_ addObject:requestWrapper];
    // start network request
    [self addRequestToNetworkQueue:requestWrapper];
}

- (BOOL) migrateRequestWraperFromPendingToRunning:(KDRequestWrapper *)requestWrapper {
    BOOL succeed = NO;
    if(NSNotFound != [pendingRequests_ indexOfObject:requestWrapper]){
        [self addToRunningList:requestWrapper];
        [pendingRequests_ removeObject:requestWrapper];
        
        succeed = YES;
    }
    
    return succeed;
}

- (BOOL) hasPendingRequestWrapper {
    return [pendingRequests_ count] > 0x00;
}

- (KDRequestWrapper *) anyRequestWrapperFromPendingList {
    return ([self hasPendingRequestWrapper]) ? [pendingRequests_ objectAtIndex:0x00] : nil;
}

// scan request wrapper with the highest priority from pending list
- (KDRequestWrapper *) requestWrapperWithHighestPriorityFromSource:(NSArray *)dataSource {
    KDRequestWrapper *target = nil;
    if(dataSource != nil){
        NSUInteger count = [dataSource count];
        if(count > 0x00){
            target = [dataSource objectAtIndex:0x00];
            
            KDRequestWrapper *temp = nil;
            NSInteger idx = 1;
            for(; idx < count; idx++){
                temp = [dataSource objectAtIndex:idx];
                if(temp.priority > target.priority){
                    target = temp;
                }
            }
        }
    }
    
    return target;
}

- (KDRequestWrapper *) optimalRequestWrapperFromPendingList {
    return [self anyRequestWrapperFromPendingList];
}

- (void) cancelASIHTTPRequestsWithRequestWrappers:(NSArray *)requestWrappers {
    if([requestQueue_ operationCount] > 0){
        NSArray *requests = [requestQueue_ operations];
        for(ASIHTTPRequest *req in requests){
            for(KDRequestWrapper *requestWrapper in requestWrappers){
                if([requestWrapper getHttpRequest] == req){
                    [req cancel];
                    break;
                }
            }
        }
    }
}

- (void)cancelRequestWithTag:(NSInteger)tag dropDelegate:(BOOL)drop {
    // remove from pending list
    NSMutableArray *targets = [NSMutableArray array];
    for (KDRequestWrapper *hit in pendingRequests_) {
        if (hit.tag == tag) {
            [targets addObject:hit];
        }
    }
    
    if ([targets count] > 0) {
        [pendingRequests_ removeObjectsInArray:targets];
        [targets removeAllObjects];
    }
    
    // remove from running list
    for (KDRequestWrapper *hit in runningRequests_) {
        if(hit.tag == tag){
            [targets addObject:hit];
            
            if (drop) {
                // drop the delegate to make the callback method not invoked on cancel mapped network request.
                hit.delegate = nil;
            }
        }
    }
    
    if ([targets count] > 0) {
        // cancel the network requests on running
        [self cancelASIHTTPRequestsWithRequestWrappers:targets];
    }
}

- (void) cancelRequestsWithIdentifier:(NSInteger)identifier {
    // remove from pending list
    NSMutableArray *targets = [NSMutableArray array];
    for(KDRequestWrapper *hit in pendingRequests_){
        if(hit.APIIdentifier == identifier){
            [targets addObject:hit];
        }
    }
    
    if([targets count] > 0){
        [pendingRequests_ removeObjectsInArray:targets];
        [targets removeAllObjects];
    }
    
    // remove from running list
    for(KDRequestWrapper *hit in runningRequests_){
        if(hit.APIIdentifier == identifier){
            [targets addObject:hit];
            
            // drop the delegate to make the callback method not invoked on cancel mapped network request.
            hit.delegate = nil;
        }
    }
    
    if([targets count] > 0){
        // cancel the network requests on running
        [self cancelASIHTTPRequestsWithRequestWrappers:targets];
    }
}

- (void) cancelRequestsWithDelegate:(id<KDRequestWrapperDelegate>)delegate {
    // remove from pending list
    NSMutableArray *targets = [NSMutableArray array];
    for(KDRequestWrapper *hit in pendingRequests_){
        if(hit.delegate == delegate){
            [targets addObject:hit];
        }
    }
    
    if([targets count] > 0){
        [pendingRequests_ removeObjectsInArray:targets];
        [targets removeAllObjects];
    }
    
    // remove from running list
    for(KDRequestWrapper *hit in runningRequests_){
        if(hit.delegate == delegate){
            [targets addObject:hit];
            
            // drop the delegate to make the callback method not invoked on cancel mapped network request.
            hit.delegate = nil;
        }
    }
    
    if([targets count] > 0){
        // cancel the network requests on running
        [self cancelASIHTTPRequestsWithRequestWrappers:targets];
    }
}

- (void)cancelRequestWithURLPrefix:(NSString *)urlPrefix {
    if (urlPrefix == nil || [urlPrefix length] == 0) return;
    
    // remove from pending list
    NSMutableArray *targets = [NSMutableArray array];
    for(KDRequestWrapper *hit in pendingRequests_){
//        if ([hit.url hasPrefix:urlPrefix]) {
//            [targets addObject:hit];
//        }
        if([[hit.url MD5DigestKey] isEqualToString:urlPrefix]) {
            [targets addObject:hit];
        }
    }
    
    if([targets count] > 0){
        [pendingRequests_ removeObjectsInArray:targets];
        [targets removeAllObjects];
    }
    
    // remove from running list
    for (KDRequestWrapper *hit in runningRequests_) {
//        if ([hit.url hasPrefix:urlPrefix]) {
//            [targets addObject:hit];
//            
//            // drop the delegate to make the callback method not invoked on cancel mapped network request.
//            hit.delegate = nil;
//        }
        if([[hit.url MD5DigestKey] isEqualToString:urlPrefix]) {
            [targets addObject:hit];
            
            hit.delegate = nil;
        }
    }
    
    if([targets count] > 0){
        // cancel the network requests on running
        [self cancelASIHTTPRequestsWithRequestWrappers:targets];
    }
}

- (KDRequestWrapper *) mappedRequestWrapperForRequest:(ASIHTTPRequest *)request {
    KDRequestWrapper *requestWrapper = nil;
    for(KDRequestWrapper *item in runningRequests_){
        // just validate the memory address to check is same object
        if([item getHttpRequest] == request){
            requestWrapper = item;
            break;
        }
    }
    
    return requestWrapper;
}

- (void) removeRequestWrapperDelegateForRequest:(ASIHTTPRequest *)request {
    KDRequestWrapper *requestWrapper = [self mappedRequestWrapperForRequest:request];
    if(requestWrapper != nil){
        requestWrapper.delegate = nil;
    }
}

- (void) cancelAllRequests {
	if([requestQueue_ operationCount] > 0){
        NSArray *requests = [requestQueue_ operations];
        for(ASIHTTPRequest *req in requests){
            [self removeRequestWrapperDelegateForRequest:req];
            [req cancel];
        }
    }
}

- (void) removeAllRequests {
    [pendingRequests_ removeAllObjects];
    
    // The running list will be clear up by network queue callback method.
    [self cancelAllRequests];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark The sub-classes should override these methods if need.

- (void) queueRequestDidStart:(ASIHTTPRequest *)request {
    // Do nothing
}

- (void) queueRequest:(ASIHTTPRequest *)request didRecieveResponseHeaders:(NSDictionary *)responseHeaders {
	// Do nothing
}

- (void) queueRequestDidFinish:(ASIHTTPRequest *)request {
	// Do nothing
}

- (void) queueRequestDidFail:(ASIHTTPRequest *)request {
	// Do nothing
}

- (void) queueNetworkQueueDidFinish:(ASINetworkQueue *)queue {
	// Do nothing
}


///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) invokeRequestWrapperDelegateSelector:(SEL)selector onObject:(id)object param1:(id)param1 param2:(id)param2 param3:(id)param3 {
    if(object != nil && [object respondsToSelector:selector]){
        NSMethodSignature *methodSignature = [object methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:object];
        [invocation setSelector:selector];
        [invocation setArgument:&param1 atIndex:0x02];
        
        if(param2 != nil)
            [invocation setArgument:&param2 atIndex:0x03];
        
        if(param3 != nil)
            [invocation setArgument:&param3 atIndex:0x04];
        
        [invocation invoke];
    }
}

- (void) didFinishASIHTTPRequest:(ASIHTTPRequest *)request failed:(BOOL)failed {
    KDRequestWrapper *requestWrapper = [self mappedRequestWrapperForRequest:request];
    KDResponseWrapper *responseWrapper = [[KDResponseWrapper alloc] initWithRequestWrapper:requestWrapper];// autorelease];
    
    // execute request wrapper block
    if(requestWrapper.didCompleteBlock != nil){
        requestWrapper.didCompleteBlock(requestWrapper, responseWrapper, failed);
    }
    
    // call request wrapper delegate's method
    if (requestWrapper.delegate != nil) {
        [self invokeRequestWrapperDelegateSelector:@selector(requestWrapper:responseWrapper:requestDidFinish:) 
                                          onObject:requestWrapper.delegate 
                                            param1:requestWrapper 
                                            param2:responseWrapper 
                                            param3:request];
    }
}

- (void) cleanFinishedRequest:(ASIHTTPRequest *)request {
    KDRequestWrapper *requestWrapper = [self mappedRequestWrapperForRequest:request];
    [runningRequests_ removeObject:requestWrapper];
    
    // load next request wrapper from pending list
    KDRequestWrapper *optimalRequestWrapper = [self optimalRequestWrapperFromPendingList];
    if(optimalRequestWrapper != nil){
        [self migrateRequestWraperFromPendingToRunning:optimalRequestWrapper];
    }
}

#pragma mark -
#pragma mark ASI http request delegate methods

- (void) requestDidStart:(ASIHTTPRequest *)request {
    // call request wrapper delegate's method
    KDRequestWrapper *requestWrapper = [self mappedRequestWrapperForRequest:request];
    [self invokeRequestWrapperDelegateSelector:@selector(requestWrapper:requestDidStart:) 
                                      onObject:requestWrapper.delegate 
                                        param1:requestWrapper 
                                        param2:request 
                                        param3:nil];
	[self queueRequestDidStart:request];
}

- (void) request:(ASIHTTPRequest *)request didRecieveResponseHeaders:(NSDictionary *)responseHeaders {
    // call request wrapper delegate's method
    KDRequestWrapper *requestWrapper = [self mappedRequestWrapperForRequest:request];
    [self invokeRequestWrapperDelegateSelector:@selector(requestWrapper:request:didRecieveResponseHeaders:) 
                                      onObject:requestWrapper.delegate 
                                        param1:requestWrapper 
                                        param2:request 
                                        param3:responseHeaders];
    
	[self queueRequest:request didRecieveResponseHeaders:responseHeaders];
}
- (void) requestDidFinish:(ASIHTTPRequest *)request {
    // call request wrapper delegate's method
    [self didFinishASIHTTPRequest:request failed:NO];
    
	[self queueRequestDidFinish:request];
    
    [self cleanFinishedRequest:request];
}

- (void) requestDidFail:(ASIHTTPRequest *)request {
    // call request wrapper delegate's method
	[self didFinishASIHTTPRequest:request failed:YES];
    
    [self queueRequestDidFail:request];
    
    [self cleanFinishedRequest:request];
}

- (void) networkQueueDidFinish:(ASINetworkQueue *)queue {
	[self queueNetworkQueueDidFinish:queue];
}

- (void) dealloc {
    if(requestQueue_ != nil){
        [self cancelAllRequests];
        
        //KD_RELEASE_SAFELY(requestQueue_);
    }
    
    //KD_RELEASE_SAFELY(pendingRequests_);
    //KD_RELEASE_SAFELY(runningRequests_);
    
    //[super dealloc];
}

@end
