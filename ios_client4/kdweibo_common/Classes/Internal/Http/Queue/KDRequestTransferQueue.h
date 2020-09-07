//
//  KDRequestTransferQueue.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDRequestQueue.h"
#import "KDImageOptimizationTask.h"

@interface KDRequestTransferQueue : KDRequestQueue <KDRequestQueueTransferServices, ASIProgressDelegate, KDImageOptimizationTaskDelegate> {
@private
    NSTimer *progressMonitorTimer_;
}

@end
