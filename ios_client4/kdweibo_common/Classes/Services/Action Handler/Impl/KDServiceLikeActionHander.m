//
//  KDServiceLikeActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceLikeActionHander.h"
#import "KDStatusParser.h"
#import "KDLikeParser.h"

#define KD_SERVICE_LIKE_ACTION_PATH	@"/like/"

@implementation KDServiceLikeActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_LIKE_ACTION_PATH;
}

- (void)like:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"like.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 // TODO: add the implementation in the future
             }];
}

- (void)counts:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"like/counts.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 // TODO: add the implementation in the future
             }];
}

- (void)getLikers:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"like/likers.json"];
    
    [super doGet:invoker configBlock:nil
            didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    NSArray *likes = nil;
    
    if([response isValidResponse]) {
        KDLikeParser *parser = [super parserWithClass:[KDLikeParser class]];
        likes = [parser parserLikes:[response responseAsJSONObject]];
    }
    
    [super didFinishInvoker:invoker results:likes request:request response:response];
}];
}

- (void)create:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"like/create.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 // TODO: add the implementation in the future
                // KDStatus *status = nil;
                 BOOL success = NO;
                 if ([response isValidResponse]) {
                     NSDictionary *body = [response responseAsJSONObject];
                     id obj = [body objectForKey:@"result"];
                     if ([obj isKindOfClass:NSDictionary.class]) {
                         success = YES;
                     }
                 }
                 
                 [super didFinishInvoker:invoker results:@(success) request:request response:response];
                 
             }];
}

- (void)destoryById:(KDServiceActionInvoker *)invoker {
    NSString *entityId = [invoker.query propertyForKey:@"entityId"];
    NSString *serviceURL = [NSString stringWithFormat:@"like/destory/%@.json", entityId];
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 // TODO: add the implementation in the future
                 BOOL success = NO;
                 if ([response isValidResponse]) {
                     NSDictionary *body = [response responseAsJSONObject];
                     id obj = [body objectForKey:@"result"];
                     if ([obj isKindOfClass:NSDictionary.class]) {
                         success = YES;
                     }
                 }
                 
                 [super didFinishInvoker:invoker results:@(success) request:request response:response];
             }];
}

- (void)destroyBatch:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"like/destroy_batch.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 // TODO: add the implementation in the future
             }];
}

@end
