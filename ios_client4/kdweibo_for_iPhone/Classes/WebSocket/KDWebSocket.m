//
//  KDWebSocket.m
//  kdweibo
//
//  Created by Gil on 15/12/1.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDWebSocket.h"
#import "SocketRocket/SRWebSocket.h"
#import "BOSConfig.h"
#import "BOSConnect.h"
//#import "KDURLPathManager.h"
#import "KDWebSocket+CMD.h"
#import "URL+MCloud.h"

typedef enum : NSUInteger {
    KDWebSocketNone,
    KDWebSocketConnecting,
    KDWebSocketConnected,
    KDWebSocketClosed,
} KDWebSocketConnectStatus;

static NSTimeInterval const CONNET_HEARTBEAT_SECOND = 45;//心跳时间45秒
static NSTimeInterval const CONNET_PONGLOSE_SECOND = 10;//10秒没收到pong，认为是假死
static NSTimeInterval const CONNET_TIMEOUT_SECOND = 30;//连接超时时间30秒

static NSTimeInterval const CONNET_DELAY_SECOND_1 = 1;            //第一次立即重连 1秒
static NSTimeInterval const CONNET_DELAY_SECOND_2 = 10;           //第二次延时10秒
static NSTimeInterval const CONNET_DELAY_SECOND_3 = 60;           //第三次延时1分钟 60
static NSTimeInterval const CONNET_DELAY_SECOND_4 = 2 * 60;       //第四次延时2分钟 2 * 60
static NSTimeInterval const CONNET_DELAY_SECOND_MORE = 10 * 60;   //第三次以上延时10分钟 10 * 60

@interface KDWebSocket () <SRWebSocketDelegate>
@property (strong, nonatomic) NSDictionary *headers;

@property (assign, nonatomic) KDWebSocketConnectStatus connectStatus;

@property (assign, nonatomic) BOOL shouldRetryConnect;//是否需要重连，如果是客户端主动关闭，则不需要重连
@property (assign, nonatomic) int retryConnectCount;//重连次数

@property (weak, nonatomic) NSTimer *taskTimer;
@property (strong, nonatomic) NSMutableDictionary *cmdMap;

@property (strong, nonatomic) dispatch_queue_t handleQueue;

@end

@implementation KDWebSocket {
    SRWebSocket *_webSocket;
}

- (void)dealloc {
    [self close];
}

- (id)init {
    self = [super init];
    if (self) {
        self.connectStatus = KDWebSocketNone;
        [self resetRetryConnectCount];
    }
    return self;
}

- (NSDictionary *)headers {
    if (_headers == nil) {
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        if ([BOSConfig sharedConfig].user.token.length > 0) {
            [headers setObject:[BOSConfig sharedConfig].user.token forKey:@"openToken"];
        }
        if ([BOSConnect userAgent].length > 0) {
            [headers setObject:[BOSConnect userAgent] forKey:@"User-Agent"];
        }
        if ([headers count] > 0) {
            _headers = headers;
        }
    }
    return _headers;
}

- (void)getWebSocket {
    if (_webSocket) {
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@//%@/xuntong/websocket",KD_WEBSOCKET,MCLOUD_IP];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[url stringByAppendingString:@"?useMS=true"]]];
    [self.headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    [request setTimeoutInterval:CONNET_TIMEOUT_SECOND];
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    _webSocket.delegate = self;
}

- (dispatch_queue_t)handleQueue {
    if (_handleQueue == nil) {
        _handleQueue = dispatch_queue_create("com.kdweibo.websocket.handle", NULL);
    }
    return _handleQueue;
}

#pragma mark - WebSocket Status -

- (void)open {
    if (self.connectStatus == KDWebSocketConnecting || self.connectStatus == KDWebSocketConnected) {
        return;
    }
    
    self.connectStatus = KDWebSocketConnecting;
    self.shouldRetryConnect = YES;
    
    [self getWebSocket];
    [_webSocket open];
    
    if (self.cmdMap == nil) {
        self.cmdMap = [NSMutableDictionary dictionary];
    }
}

- (void)close {
    self.shouldRetryConnect = NO;
    
	if (_webSocket.readyState != SR_CLOSING || _webSocket.readyState != SR_CLOSED) {
		[_webSocket close];
	}
}

- (void)sendPing {
    if (_webSocket.readyState == SR_OPEN) {
        [_webSocket sendPing:nil];
    }
}

- (void)sendMessage:(id)data {
    if (_webSocket.readyState == SR_OPEN) {
        [_webSocket send:data];
    }
}

//参考开源库的实现
- (BOOL)closeCodeIsValid:(int)closeCode {
    if (closeCode < 1000) {
        return NO;
    }
    
    if (closeCode >= 1000 && closeCode <= 1011) {
        if (closeCode == 1004 ||
            closeCode == 1005 ||
            closeCode == 1006) {
            return NO;
        }
        return YES;
    }
    
    if (closeCode >= 3000 && closeCode <= 3999) {
        return YES;
    }
    
    if (closeCode >= 4000 && closeCode <= 4999) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Retry -

- (void)_retryConnect {
    //如果需要重连，则去重连
    if (self.shouldRetryConnect) {
//		[KDEventAnalysis event:event_websocket attributes:@{@"type" : @"retry", @"number" : [NSString stringWithFormat:@"%@ - %d",[KDReachabilityManager sharedManager].reachabilityStatusDescription, self.retryConnectCount]}];
        [self open];
    }
}

- (void)retryConnect {
    
    if (!self.shouldRetryConnect) {
        return;
    }
    
    self.retryConnectCount ++;
    
	NSTimeInterval second = CONNET_DELAY_SECOND_MORE;
	if (self.retryConnectCount == 1) {
		second = CONNET_DELAY_SECOND_1;
	}
	else if (self.retryConnectCount == 2) {
		second = CONNET_DELAY_SECOND_2;
	}
	else if (self.retryConnectCount == 3) {
		second = CONNET_DELAY_SECOND_3;
	}
	else if (self.retryConnectCount == 4) {
		second = CONNET_DELAY_SECOND_4;
	}
    [self performSelector:@selector(_retryConnect) withObject:nil afterDelay:second];
    
    //连接失败回调启动轮询机制，但是重连机制还继续
	if (self.retryConnectCount > 0) {
		if (self.failedBlock) {
			self.failedBlock();
		}
	}
}

- (void)cancelRetryConnect {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_retryConnect) object:nil];
}

- (void)resetRetryConnectCount {
    self.retryConnectCount = 0;
}

- (void)connectOpened {
    self.connectStatus = KDWebSocketConnected;
    
    [self resetRetryConnectCount];
    
    [self startTask];
    
    if (self.successBlock) {
        self.successBlock();
    }
    
    //连接成功后主动查询一次状态
    [self queryAll];
}

- (void)connectClosed {
    
    [self cancelTask];
    
    //取消可能存在的重试任务
    [self cancelRetryConnect];
    [self cancelPongLoseListen];
    
    _webSocket.delegate = nil;
    _webSocket = nil;
    _headers = nil;
    
    if (self.cmdMap) {
        [self.cmdMap removeAllObjects];
    }
    
    self.connectStatus = KDWebSocketClosed;
    
    [self retryConnect];//重连
}

#pragma mark - 任务 -

//重复检查推下来的指令有没有执行完成，防止指令丢失
- (void)repeatCmd {
    if (self.cmdMap) {
        [self.cmdMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self handle:obj needRecord:NO];
        }];
    }
}

- (void)startPing {
    [self performSelector:@selector(pongLoseListen) withObject:nil afterDelay:CONNET_PONGLOSE_SECOND];
    [self sendPing];
}

- (void)task {
    [self startPing];
    [self repeatCmd];
}

- (void)startTask {
    if (self.taskTimer == nil) {
        self.taskTimer = [NSTimer scheduledTimerWithTimeInterval:CONNET_HEARTBEAT_SECOND target:self selector:@selector(task) userInfo:nil repeats:YES];
    }
}

- (void)cancelTask {
    if (self.taskTimer) {
        [self.taskTimer invalidate];
        self.taskTimer = nil;
    }
}

- (void)pongLoseListen {
    NSString *error = [NSString stringWithFormat:@"%@ - suspended",[KDReachabilityManager sharedManager].reachabilityStatusDescription];
//    [KDEventAnalysis event:event_websocket attributes:@{@"type" : @"suspended", @"pong" : error}];
//    
//    DDLogCommonInfo(@"WebSocket Suspended, error: %@", error);
    
    //关闭现有通道，转入重连机制
    [self connectClosed];
}

- (void)cancelPongLoseListen {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pongLoseListen) object:nil];
}

#pragma mark - SRWebSocketDelegate -

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
//    [KDEventAnalysis event:event_websocket attributes:@{@"type" : @"open"}];
    
    [self connectOpened];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"%@ - %@",[KDReachabilityManager sharedManager].reachabilityStatusDescription, error.description];
//    [KDEventAnalysis event:event_websocket attributes:@{@"type" : @"fail", @"error" : errorMsg}];
    
//    DDLogCommonInfo(@"WebSocket Fail, error: %@", errorMsg);
    
    [self connectClosed];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    //处理指令
    [self handle:message];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    NSDictionary *attributes = nil;
    NSString *reasonMsg = [NSString stringWithFormat:@"%@ - code:%ld,reason:%@", [KDReachabilityManager sharedManager].reachabilityStatusDescription, (long)code, reason];
    if ([self closeCodeIsValid:(int)code]) {
        //正常关闭不记录reason
        attributes = @{@"type" : @"close"};
    }
    else {
        attributes = @{@"type" : @"close", @"reason" : reasonMsg};
    }
//    [KDEventAnalysis event:event_websocket attributes:attributes];
//    
//    DDLogCommonInfo(@"WebSocket Close, reason: %@", reasonMsg);
    
    [self connectClosed];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    [self cancelPongLoseListen];
}

@end
