//
//  KDWebSocket.h
//  kdweibo
//
//  Created by Gil on 15/12/1.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDNotificationChannelDelegate.h"

typedef void (^KDWebSocketConnectSuccessBlock) ();
typedef void (^KDWebSocketConnectFailedBlock) ();

@interface KDWebSocket : NSObject

@property (strong, nonatomic) KDWebSocketConnectSuccessBlock successBlock;
@property (strong, nonatomic) KDWebSocketConnectFailedBlock failedBlock;

@property (strong, nonatomic, readonly) dispatch_queue_t handleQueue;
@property (strong, nonatomic, readonly) NSMutableDictionary *cmdMap;

@property (weak, nonatomic) id<KDNotificationChannelDelegate> delegate;

- (void)open;
- (void)close;

- (void)sendPing;
- (void)sendMessage:(id)data;

@end
