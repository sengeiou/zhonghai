//
//  KDMessageHandler.h
//  kdweibo
//
//  Created by 王 松 on 14-5-19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "ASINetworkQueue.h"

#import "KDMessageModel.h"

#import "SendDataModel.h"

typedef void (^ KDMessageHandlerBlock)(KDMessageModel *message, BOSResultDataModel *result);

@interface KDMessageHandler : ASINetworkQueue

@property(nonatomic,strong)AFURLSessionManager *afManager;

+ (instancetype)messageHandler;

- (void)sendMessage:(KDMessageModel *)message chatMode:(ChatMode)mode block:(KDMessageHandlerBlock)block;

@end
