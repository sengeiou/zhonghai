//
//  KDEmailConfigureActionHander.m
//  kdweibo_common
//
//  Created by bird on 13-10-21.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDEmailConfigureActionHander.h"

#define KD_SERVICE_TASK_ACTION_PATH	@"/rest/"

@implementation KDEmailConfigureActionHander

+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_TASK_ACTION_PATH;
}

- (void)getConfigInfo:(KDServiceActionInvoker *)invoker
{
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"rest/emails/config"];
    
    [super doGet:invoker configBlock:nil
didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    
    NSDictionary *body = nil;
    if ([response isValidResponse]) {
        body = [response responseAsJSONObject];
    }
    [super didFinishInvoker:invoker results:body request:request response:response];
}];
}

- (void)postConfigInfo:(KDServiceActionInvoker *)invoker
{
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"rest/emails/config"];
    
    [super doPost:invoker configBlock:nil
 didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    
    NSDictionary *body = nil;
    if ([response isValidResponse]) {
        body = [response responseAsJSONObject];
    }
    [super didFinishInvoker:invoker results:body request:request response:response];
}];
}
@end
