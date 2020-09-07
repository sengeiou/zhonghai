//
//  KDRequestSendQueue.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDRequestQueue.h"

/*
 * this class use to send data to server. For instance, post new weibo status, post direct message, post group status, 
 * comment status, forward status etc.
 * It's means no matter how many new weibo status in the queue, All of them run as serial. But also support post the other type messages to server. 
 */

@interface KDRequestSendQueue : KDRequestQueue

@end
