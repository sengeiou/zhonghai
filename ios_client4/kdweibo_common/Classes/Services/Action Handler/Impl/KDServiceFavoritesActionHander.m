//
//  KDServiceFavoritesActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceFavoritesActionHander.h"

#define KD_SERVICE_FAVORITES_ACTION_PATH	@"/favorites/"

@implementation KDServiceFavoritesActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_FAVORITES_ACTION_PATH;
}

- (void)favorites:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"favorites.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseFavoritedStatuses:response
                                    completionBlock:^(NSArray *statuses){
                                        [super didFinishInvoker:invoker results:statuses
                                                        request:request response:response];
                                    }];
             }];
}

- (void)create:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"favorites/create.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 BOOL success = NO;
                 BOOL favorited = NO;
                 if([response isValidResponse]){
                     success = YES; // favorite status was succeed
                     
                 } else {
                     if(KDHTTPResponseCode_400 == [response statusCode]){
                         NSDictionary *info = [response responseAsJSONObject];
                         if(info != nil && 400 == [info intForKey:@"status"]) {
                             favorited = YES; // try to favorite status which it was favorited before
                         }
                     }
                 }
                 
                 NSDictionary *info = @{@"success" : @(success), @"favorited" : @(favorited)};
                 [super didFinishInvoker:invoker results:info request:request response:response];
             }];
}

- (void)destoryById:(KDServiceActionInvoker *)invoker {
    NSString *entityId = [invoker.query propertyForKey:@"entityId"];
    NSString *serviceURL = [NSString stringWithFormat:@"favorites/destroy/%@.json", entityId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 BOOL success = ([response isValidResponse]) ? YES : NO;
                 [super didFinishInvoker:invoker results:@(success) request:request response:response];
             }];
}

- (void)destoryBatch:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"favorites/destroy_batch.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 // TODO: add the implementation in the future
             }];
}

- (void)_asyncParseFavoritedStatuses:(KDResponseWrapper *)response completionBlock:(void (^)(NSArray *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *statuses = nil;
        
        NSArray *bodyList = [response responseAsJSONObject];
        if (bodyList != nil) {
            KDStatusParser *parser = [super parserWithClass:[KDStatusParser class]];
            statuses = [parser parseAsStatuses:bodyList type:KDTLStatusTypeFavorited];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(statuses);
        });
    });
}

@end
