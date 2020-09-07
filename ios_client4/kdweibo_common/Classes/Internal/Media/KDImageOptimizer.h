//
//  KDImageOptimizer.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-15.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDImageOptimizationTask.h"

@protocol KDImageOptimizerDelegate;

@interface KDImageOptimizer : NSObject {
@private
    NSOperationQueue *queue_;
    
    NSMutableArray *waitingTasks_;
    NSMutableArray *runningTasks_;
}

+ (KDImageOptimizer *) sharedImageOptimizer;

- (BOOL) hasWaitingTasks;
- (BOOL) hasRunningTasks;

- (void) addTask:(KDImageOptimizationTask *)task;
- (void) removeAllTasks;

@end


@protocol KDImageOptimizerDelegate <NSObject>
@optional

- (void) imageOptimizer:(KDImageOptimizer *)imageOptimizer;

@end
