//
//  KDServiceActionDispatcher.h
//  kdweibo_common
//
//  Created by laijiandong on 12-10-24.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDServiceActionInvoker.h"

@class KDActionPathsConfigurator;
@class KDRequestWrapper;
@class KDResponseWrapper;

@interface KDServiceActionDispatcher : NSObject {
 @private
    KDActionPathsConfigurator *actionPathsConfigurator_;
    NSMutableDictionary *serviceHandlersMapping_; // the relationship with action path with service action handler
}

- (BOOL)isValidServiceActionInvoker:(KDServiceActionInvoker *)invoker;
- (void)dispatch:(KDServiceActionInvoker *)invoker;

@end
