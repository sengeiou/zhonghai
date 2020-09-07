//
//  KDServiceInboxActionHander.m
//  kdweibo_common
//
//  Created by bird on 13-7-1.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDServiceInboxActionHander.h"
#import "KDInboxParser.h"
#define KD_SERVICE_DM_ACTION_PATH	@"/inbox/"

@implementation KDServiceInboxActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_DM_ACTION_PATH;
}

- (void)messages:(KDServiceActionInvoker *)invoker
{
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"inbox/messages.json"];
    
    [super doGet:invoker
            configBlock:nil
        didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
            
                    [self _asyncParseThreads:response
                                completionBlock:^(id info){
                                    [super didFinishInvoker:invoker results:info request:request response:response];}];
            }];
}

- (void)_asyncParseThreads:(KDResponseWrapper *)response completionBlock:(void (^)(id))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

        id content = [response responseAsJSONObject];
        KDInboxParser   *parser = [[KDInboxParser alloc] init] ;//autorelease];
        [parser parse:content];
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(parser);
        });
    });
}
@end
