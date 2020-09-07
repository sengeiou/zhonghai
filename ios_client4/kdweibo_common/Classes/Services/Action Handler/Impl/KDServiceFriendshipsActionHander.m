//
//  KDServiceFriendshipsActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceFriendshipsActionHander.h"

#define KD_SERVICE_FRIENDSHIPS_ACTION_PATH	@"/friendships/"

@implementation KDServiceFriendshipsActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_FRIENDSHIPS_ACTION_PATH;
}

- (void)create:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"friendships/create.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDUser *user = [self _parseAsUser:response];
                 [super didFinishInvoker:invoker results:user request:request response:response];
             }];
}

- (void)createById:(KDServiceActionInvoker *)invoker {
    
}

- (void)destroy:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"friendships/destroy.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDUser *user = [self _parseAsUser:response];
                 [super didFinishInvoker:invoker results:user request:request response:response];
             }];
}

- (void)destroyById:(KDServiceActionInvoker *)invoker {
    
}

- (void)exists:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"friendships/exists.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 BOOL isFriendNow = NO;
                 if ([response isValidResponse]) {
                     NSDictionary *body = [response responseAsJSONObject];
                     if (body != nil) {
                         isFriendNow = [body boolForKey:@"friends"];
                     }
                 }
                 
                 [super didFinishInvoker:invoker results:@(isFriendNow) request:request response:response];
             }];
}

- (void)show:(KDServiceActionInvoker *)invoker {
    
}

- (KDUser *)_parseAsUser:(KDResponseWrapper *)response {
    KDUser *user = nil;
    if ([response isValidResponse]) {
        NSDictionary *body = [response responseAsJSONObject];
        if (body != nil) {
            KDUserParser *parser = [super parserWithClass:[KDUserParser class]];
            user = [parser parse:body withStatus:NO];
        }
    }
    
    return user;
}

@end
