//
//  KDRequestDispatcher.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDRequestQueueServices.h"
#import "KDRequestWrapper.h"

typedef  enum :NSUInteger {
    KDRequestDispatchTypeSend = 0x01,
    KDRequestDispatchTypeReceive,
    KDRequestDispatchTypeTransfer
}KDRequestDispatchType;



typedef enum : NSUInteger {
    KDRequestSendQueueMask = 1,
    KDRequestReceiveQueueMask = 1 << 1,
    KDRequestTransferQueueMask = 1 << 2
}KDRequestQueueMask;

#define KDRequestQueueMaskAll (KDRequestSendQueueMask | KDRequestReceiveQueueMask | KDRequestTransferQueueMask)


@interface KDRequestDispatcher : NSObject {
@private
    id<KDRequestQueueServices> sendQueue_;
    id<KDRequestQueueServices> receiveQueue_;
    id<KDRequestQueueServices, KDRequestQueueTransferServices> transferQueue_;
}

+ (KDRequestDispatcher *)globalRequestDispatcher;

- (void)dispatch:(KDRequestWrapper *)requestWrapper type:(KDRequestDispatchType)dispatchType;

// check the specific url does on transfer queue, may be download user's avatar, image, document etc...
- (BOOL)isOnRequestQueueWithTransferURL:(NSString *)url updatePriority:(BOOL)updatePriority;

- (BOOL)imageSourceTransferFinishedWithURLPrefix:(NSString *)urlPrefix;

- (void)cancelReceiveRequestWithTag:(NSInteger)tag mask:(KDRequestQueueMask)mask dropDelegate:(BOOL)drop;

- (void)cancelRequestsForReceiveTypeWithDelegate:(id<KDRequestWrapperDelegate>)delegate;

- (void)cancelRequestsWithAPIIdentifier:(KDAPIIdentifer)identifier;
- (void)cancelRequestsWithDelegate:(id<KDRequestWrapperDelegate>)delegate force:(BOOL)force;

- (void)cancelTransferingRequestWithDelegate:(id)delegate;
- (void)cancelTransferingRequestWithAPIIdentifier:(KDAPIIdentifer)identifier;
- (void)cancelTransferingRequestWithURLPrefix:(NSString *)urlPrefix;

- (void)removeAllRequestsInSendQueue;
- (void)removeAllRequestsInReceiveQueue;

- (void)removeAllRequests;

@end
