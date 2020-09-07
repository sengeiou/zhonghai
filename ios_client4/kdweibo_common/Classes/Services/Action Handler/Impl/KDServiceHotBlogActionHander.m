//
//  KDServiceHotBlogActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceHotBlogActionHander.h"

#define KD_SERVICE_HOT_BLOG_ACTION_PATH	@"/hot_blog/"

@implementation KDServiceHotBlogActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_HOT_BLOG_ACTION_PATH;
}

- (void)comment:(KDServiceActionInvoker *)invoker {
    
}

- (void)forward:(KDServiceActionInvoker *)invoker {
    
}

@end
