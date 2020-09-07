//
//  KDServiceEventActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceEventActionHander.h"

#define KD_SERVICE_EVENT_ACTION_PATH	@"/event/"

@implementation KDServiceEventActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_EVENT_ACTION_PATH;
}

- (void)event:(KDServiceActionInvoker *)invoker {
    
}

- (void)message:(KDServiceActionInvoker *)invoker {
    
}

- (void)send:(KDServiceActionInvoker *)invoker {
    
}


- (void)pubOpen:(KDServiceActionInvoker *)invoker {
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"infocollect/pub_open.json"];
    
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        NSDictionary *body = nil;
        if([response isValidResponse]) {
            body = [response responseAsJSONObject];
        }
        
        [super didFinishInvoker:invoker results:body request:request response:response];
    }];
}


- (void)msgRead:(KDServiceActionInvoker *)invoker
{
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"infocollect/pub_msg_read.json"];
    
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        NSDictionary *body = nil;
        if([response isValidResponse]) {
            body = [response responseAsJSONObject];
        }
        
        [super didFinishInvoker:invoker results:body request:request response:response];
    }];
}

@end
