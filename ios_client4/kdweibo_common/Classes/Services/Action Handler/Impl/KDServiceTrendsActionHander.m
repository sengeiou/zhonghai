//
//  KDServiceTrendsActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceTrendsActionHander.h"

#define KD_SERVICE_TRENDS_ACTION_PATH	@"/trends/"

@implementation KDServiceTrendsActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_TRENDS_ACTION_PATH;
}

- (void)trends:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"trends.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseTopics:response completionBlock:^(NSArray *topics){
                     [super didFinishInvoker:invoker results:topics request:request response:response];
                 }];
             }];
}

- (void)listDefault:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"trends/default.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseTopics:response completionBlock:^(NSArray *topics){
                     [super didFinishInvoker:invoker results:topics request:request response:response];
                 }];
             }];
}

- (void)all:(KDServiceActionInvoker *)invoker {
    
}

- (void)daily:(KDServiceActionInvoker *)invoker {
    
}

- (void)destroy:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"trends/destroy.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 BOOL success = NO;
                 if ([response isValidResponse]) {
                     NSDictionary *body = [response responseAsJSONObject];
                     if (body != nil) {
                         success = [body boolForKey:@"result"];
                     }
                 }
                 
                 [super didFinishInvoker:invoker results:@(success) request:request response:response];
             }];
}

- (void)detail:(KDServiceActionInvoker *)invoker {
    
}

- (void)follow:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"trends/follow.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 NSDictionary * bodyDic = nil;
                 if ([response isValidResponse]) {
                    bodyDic = [response responseAsJSONObject];
                 }
                 
                 [super didFinishInvoker:invoker results:bodyDic request:request response:response];
             }];
}

- (void)fresh:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"trends/fresh.json"];
    
    [super doGet:invoker configBlock:nil
       didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    [self _asyncParseTopics:response completionBlock:^(NSArray *topics){
        [super didFinishInvoker:invoker results:topics request:request response:response];
    }];
}];
}

- (void)month:(KDServiceActionInvoker *)invoker {
    
}

- (void)recently:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"trends/recently.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseTopics:response completionBlock:^(NSArray *topics){
                     [super didFinishInvoker:invoker results:topics request:request response:response];
                 }];
             }];
}

- (void)statuses:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"trends/statuses.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseStatuses:response completionBlock:^(NSArray *statuses){
                     [super didFinishInvoker:invoker results:statuses request:request response:response];
                 }];
             }];
}

- (void)weekly:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"trends/weekly.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseTopics:response completionBlock:^(NSArray *topics){
                     [super didFinishInvoker:invoker results:topics request:request response:response];
                 }];
             }];
}

- (void)search:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"trends/search.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseTopics:response completionBlock:^(NSArray *statuses){
                     [super didFinishInvoker:invoker results:statuses request:request response:response];
                 }];
             }];
}

-(void)has_followed:(KDServiceActionInvoker * )invoker{
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"trends/has_followed.json"];
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {

                 NSDictionary * responseDic = nil;
                 if ([response isValidResponse]) {
                     responseDic = [response responseAsJSONObject];
                 }
                 [super didFinishInvoker:invoker results:responseDic request:request response:response];
             }];
}

////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

// parse the topics
- (void)_asyncParseTopics:(KDResponseWrapper *)response completionBlock:(void (^)(NSArray *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *topics = nil;
        
        NSArray *bodyList = [response responseAsJSONObject];
        if (bodyList != nil) {
            KDCompositeParser *parser = [super parserWithClass:[KDCompositeParser class]];
            topics = [parser parseAsTopics:bodyList];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(topics);
        });
    });
}

// parse the statuses of timeline from response
- (void)_asyncParseStatuses:(KDResponseWrapper *)response completionBlock:(void (^)(NSArray *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *statuses = nil;
        
        NSArray *bodyList = [response responseAsJSONObject];
        if (bodyList != nil) {
            KDStatusParser *parser = [super parserWithClass:[KDStatusParser class]];
             statuses = [parser parseAsStatuses:bodyList type:KDTLStatusTypeUndefined];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(statuses);
        });
    });
}

@end
