//
//  KDServiceShareActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceShareActionHander.h"

#define KD_SERVICE_SHARE_ACTION_PATH	@"/share/"

@implementation KDServiceShareActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_SHARE_ACTION_PATH;
}

- (void)add:(KDServiceActionInvoker *)invoker {
    
}

- (void)count:(KDServiceActionInvoker *)invoker {
    
}

- (void)login:(KDServiceActionInvoker *)invoker {
    
}

@end
