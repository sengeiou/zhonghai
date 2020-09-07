//
//  KDServiceActionExecutor.h
//  kdweibo_common
//
//  Created by laijiandong on 12-10-24.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDRequestWrapper.h"
#import "KDServiceActionInvoker.h"

@class KDServiceActionDispatcher;

@interface KDServiceActionExecutor : NSObject <KDRequestWrapperDelegate> {
 @private
    KDServiceActionDispatcher *dispatcher_;
    NSMutableArray *invokers_; // the service invokers
}

- (void)execute:(KDServiceActionInvoker *)invoker;

// the sender it's the service caller, may be an view controller normally
- (void)cancelInvokerWithSender:(id)sender;

// the format like: /statuses/:comments_by_cursor
- (void)cancelInvokerWithServiceFullyPath:(NSString *)fullyPath;

@end
