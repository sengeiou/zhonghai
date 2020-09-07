//
//  KDServiceActionExecutor.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-24.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceActionExecutor.h"
#import "KDServiceActionDispatcher.h"
#import "KDRequestDispatcher.h"

@interface KDServiceActionExecutor ()

@property(nonatomic, retain) KDServiceActionDispatcher *dispatcher;
@property(nonatomic, retain) NSMutableArray *invokers;

@end

@implementation KDServiceActionExecutor

@synthesize dispatcher=dispatcher_;
@synthesize invokers=invokers_;

- (id)init {
    self = [super init];
    if (self) {
        dispatcher_ = [[KDServiceActionDispatcher alloc] init];
        invokers_ = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)execute:(KDServiceActionInvoker *)invoker {
    if (invoker != nil && [invoker isValid]) {
        // also make sure not put same invoker twice
        if (NSNotFound == [invokers_ indexOfObject:invoker]) {
            if ([dispatcher_ isValidServiceActionInvoker:invoker]) {
                // make the current action executor as request delegate
                invoker.requestWrapperDelegate = self;
                
                // cache the invoker
                [invokers_ addObject:invoker];
                
                [dispatcher_ dispatch:invoker];
            }
        
        } else {
            DLog(@"Can not put same invoker more than one. invoker=%@", invoker);
        }
    }
}

- (void)cancelInvokerWithSender:(id)sender {
    // cancel the request by service sender
    if (sender != nil && invokers_ != nil) {
        // look up the invokers from same sender
        NSMutableArray *hits = [NSMutableArray array];
        for (KDServiceActionInvoker *invoker in invokers_) {
            if (invoker.sender == sender) {
                [hits addObject:invoker];
            }
        }
        
        [self _cancelRequestWithInvokers:hits];
    }
}

- (void)cancelInvokerWithServiceFullyPath:(NSString *)fullyPath {
    // cancel the request by service fully path
    if (fullyPath != nil && invokers_ != nil) {
        NSMutableArray *hits = [NSMutableArray array];
        for (KDServiceActionInvoker *invoker in invokers_) {
            if ([invoker.servicePath isEqualsToFullyActionPath:fullyPath]) {
                [hits addObject:invoker];
            }
        }
        
        [self _cancelRequestWithInvokers:hits];
    }
}

// remove all invokers from observer array
- (void)cleanAllInvokers {
    if ([invokers_ count] > 0) {
        [invokers_ removeAllObjects];
    }
}


//////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (void)_cancelRequestWithInvokers:(NSArray *)hits {
    if (hits != nil && [hits count] > 0) {
        KDRequestDispatcher *rd = [KDRequestDispatcher globalRequestDispatcher];
        for (KDServiceActionInvoker *hit in hits) {
            [rd cancelReceiveRequestWithTag:hit.tag mask:KDRequestReceiveQueueMask dropDelegate:NO];
        }
    }
}

- (void)_didFinishRequestWrapper:(KDRequestWrapper *)req {
    if (invokers_ != nil) {
        // look up the invoker which it has same tag as request wrapper
        BOOL found = NO;
        NSInteger idx = 0;
        for (KDServiceActionInvoker *invoker in invokers_) {
            if (invoker.tag == req.tag) {
                found = YES;
                
                break;
            }
            
            idx++;
        }
        
        // remove target from invokers array
        if (found) {
            [invokers_ removeObjectAtIndex:idx];
        }
    }
}


//////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDRequestWrapper delegate methods

- (void)didDropRequestWrapper:(KDRequestWrapper *)requestWrapper error:(NSError *)error {
    [self _didFinishRequestWrapper:requestWrapper];
}

- (void)requestWrapper:(KDRequestWrapper *)requestWrapper
          responseWrapper:(KDResponseWrapper *)responseWrapper
            requestDidFinish:(ASIHTTPRequest *)request {
    
    [self _didFinishRequestWrapper:requestWrapper];
}

- (void) requestWrapper:(KDRequestWrapper *)requestWrapper request:(ASIHTTPRequest *)request progressMonitor:(KDRequestProgressMonitor *)progressMonitor
{

    for (KDServiceActionInvoker *invoker in invokers_) {
        if (invoker.tag == request.tag) {
            if (invoker.sender && [invoker.sender respondsToSelector:@selector(progress:)]) {
                [invoker.sender performSelector:@selector(progress:) withObject:progressMonitor];
            }
        }
    }
}

- (BOOL)isVideoSourceRequestWrapper:(KDRequestWrapper *)requestWrapper
{
    BOOL isVideo = [[[requestWrapper userInfo] valueForKey:@"VideoFlag"] boolValue];
    return isVideo;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(dispatcher_);
    //KD_RELEASE_SAFELY(invokers_);
    
    //[super dealloc];
}

@end
