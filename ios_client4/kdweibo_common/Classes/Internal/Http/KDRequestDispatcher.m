//
//  KDRequestDispatcher.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDRequestDispatcher.h"

#import "KDRequestSendQueue.h"
#import "KDRequestReceiveQueue.h"
#import "KDRequestTransferQueue.h"

static KDRequestDispatcher *globalRequestDispatcher_ = nil;


@interface KDRequestDispatcher ()

@property (nonatomic, retain) id<KDRequestQueueServices> sendQueue;
@property (nonatomic, retain) id<KDRequestQueueServices> receiveQueue;
@property (nonatomic, retain) id<KDRequestQueueServices> transferQueue;

@end

@implementation KDRequestDispatcher

@synthesize sendQueue=sendQueue_;
@synthesize receiveQueue=receiveQueue_;
@synthesize transferQueue=transferQueue_;

- (id) init {
    self = [super init];
    if(self){
        sendQueue_ = [[KDRequestSendQueue alloc] init];
        receiveQueue_ = [[KDRequestReceiveQueue alloc] init];
        transferQueue_ = [[KDRequestTransferQueue alloc] init];
     }
    
    return self;
}

+ (KDRequestDispatcher *) globalRequestDispatcher {
    @synchronized([KDRequestDispatcher class]){
        if(globalRequestDispatcher_ == nil){
            globalRequestDispatcher_ = [[KDRequestDispatcher alloc] init]; 
        }
    }
    
    return globalRequestDispatcher_;
}

- (void)dispatch:(KDRequestWrapper *)requestWrapper type:(KDRequestDispatchType)dispatchType {
    switch (dispatchType) {
        case KDRequestDispatchTypeSend:
            [sendQueue_ addRequestWrapper:requestWrapper];
            break;
        
        case KDRequestDispatchTypeReceive:
            [receiveQueue_ addRequestWrapper:requestWrapper];
            break;
            
        case KDRequestDispatchTypeTransfer:
            [transferQueue_ addRequestWrapper:requestWrapper];
            break;    
            
        default:
            // can not happens, if reached here, invalid dispatch type
            break;
    }
}

- (BOOL)isOnRequestQueueWithTransferURL:(NSString *)url updatePriority:(BOOL)updatePriority {
    return [transferQueue_ isOnRequestQueueWithURL:url updatePriority:updatePriority];
}

- (void)cancelReceiveRequestWithTag:(NSInteger)tag mask:(KDRequestQueueMask)mask dropDelegate:(BOOL)drop {
    if (KDRequestSendQueueMask & mask) {
        [sendQueue_ cancelRequestWithTag:tag dropDelegate:drop];
    }
    
    if (KDRequestReceiveQueueMask & mask) {
        [receiveQueue_ cancelRequestWithTag:tag dropDelegate:drop];
    }
    
    if (KDRequestTransferQueueMask & mask) {
        [transferQueue_ cancelRequestWithTag:tag dropDelegate:drop];
    }
}

// Sometimes, If user enter in an view controller, and some GET request is going for this view controller.
// And then, User back to previous view controller, and some GET requests relative to this view controller 
// should be cancelled before it was been release.
// For instance, User view the details of weibo status, And the comments for this status will be listing now.
// User did back to previous view controller and listing comments not finished. And that time, The GET requests
// for that view controller should be cancelled.
- (void)cancelRequestsForReceiveTypeWithDelegate:(id<KDRequestWrapperDelegate>)delegate {
    [receiveQueue_ cancelRequestsWithDelegate:delegate];
}

- (void)cancelRequestsWithAPIIdentifier:(KDAPIIdentifer)identifier {
    [sendQueue_ cancelRequestsWithIdentifier:identifier];
    [receiveQueue_ cancelRequestsWithIdentifier:identifier];
}

- (void)cancelRequestsWithDelegate:(id<KDRequestWrapperDelegate>)delegate force:(BOOL)force {
    [sendQueue_ cancelRequestsWithDelegate:delegate];
    [receiveQueue_ cancelRequestsWithDelegate:delegate];
    
    // Generally speaking, The transfer queue shoudn't be cancelled because of this queue used for file transfering.
    // For instance, download image, user avatar and any document from server etc.
    // but if logout action happens, or something not need maintains transfering, this parameter can be 'YES'
    if(force){
        [transferQueue_ cancelRequestsWithDelegate:delegate];
    }
}

- (void)cancelTransferingRequestWithAPIIdentifier:(KDAPIIdentifer)identifier {
    [transferQueue_ cancelRequestsWithIdentifier:identifier];
}

- (void)cancelTransferingRequestWithDelegate:(id)delegate {
    [transferQueue_ cancelRequestsWithDelegate:delegate];
}

- (void)cancelTransferingRequestWithURLPrefix:(NSString *)urlPrefix {
    [transferQueue_ cancelRequestWithURLPrefix:urlPrefix];
}
- (BOOL)imageSourceTransferFinishedWithURLPrefix:(NSString *)urlPrefix {
    return  [transferQueue_ isImageSourceRequestFinishedWithURL:urlPrefix];
}
- (void)removeAllRequestsInSendQueue {
    [sendQueue_ removeAllRequests];
}

- (void)removeAllRequestsInReceiveQueue {
    [receiveQueue_ removeAllRequests];
}

- (void)removeAllRequests {
    [sendQueue_ removeAllRequests];
    [receiveQueue_ removeAllRequests];
    [transferQueue_ removeAllRequests];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(sendQueue_);
    //KD_RELEASE_SAFELY(receiveQueue_);
    //KD_RELEASE_SAFELY(transferQueue_);
    
    //[super dealloc];
}

@end
