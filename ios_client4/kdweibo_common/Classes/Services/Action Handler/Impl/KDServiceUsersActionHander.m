//
//  KDServiceUsersActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceUsersActionHander.h"

#define KD_SERVICE_USERS_ACTION_PATH	@"/users/"

@implementation KDServiceUsersActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_USERS_ACTION_PATH;
}

- (void)feedback:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"users/feedback.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 BOOL success = ([response isValidResponse]) ? YES : NO;
                 [super didFinishInvoker:invoker results:@(success) request:request response:response];
             }];
}

- (void)followedTopicNumber:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"users/followed_topic_num.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 NSUInteger forwards = 0;
                 if ([response isValidResponse]) {
                     NSDictionary *body = [response responseAsJSONObject];
                     if (body != nil && [body boolForKey:@"result"]) {
                         forwards = [body integerForKey:@"followed_topic_num"];
                     }
                 }
                 
                 [super didFinishInvoker:invoker results:@(forwards) request:request response:response];
             }];
}

- (void)members:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"users/members.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 // TODO: add the implementation in the future
             }];
}

- (void)search:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"users/search.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseUserListSimple:response completionBlock:^(NSArray *users){
                     [super didFinishInvoker:invoker results:users request:request response:response];
                 }];                 
             }];
}

- (void)show:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"users/show.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDUser *user = [self _parseUser:response];
                 [super didFinishInvoker:invoker results:user request:request response:response];
             }];
}

- (void)showById:(KDServiceActionInvoker *)invoker {
    NSString *userId = [invoker.query propertyForKey:@"userId"];
    NSString *serviceURL = [NSString stringWithFormat:@"users/show/%@.json", userId];
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDUser *user = [self _parseUser:response];
                 [super didFinishInvoker:invoker results:user request:request response:response];
             }];
}

- (void)alreadyInvitedPerson:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"users/list_invites.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 NSArray *records = nil;
                 if([response isValidResponse]) {
                     NSArray *bodyList = [response responseAsJSONObject]; 
                     if(bodyList) {
                         KDCompositeParser *parser = [super parserWithClass:[KDCompositeParser class]];
                         records = [parser parseAsABRecord:bodyList];
                     }
                 }
                 [super didFinishInvoker:invoker results:records request:request response:response];
             }];
}

- (void)frequentAtContacts:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"privatemessage/recentContacts4mention.json"];
    
    [super doGet:invoker configBlock:NULL didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed){
        [self _asyncParseUserListFrequent:response completionBlock:^(NSArray *users){
            [super didFinishInvoker:invoker results:users request:request response:response];
        }];
    }];
}

- (void)frequentDMContacts:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"privatemessage/recentContacts.json"];
    
    [super doGet:invoker configBlock:NULL didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed){
        [self _asyncParseUserListFrequent:response completionBlock:^(NSArray *users) {
            [super didFinishInvoker:invoker results:users request:request response:response];
        }];
    }];
}

-(void)wake:(KDServiceActionInvoker *)invoker{
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"users/wake.json"];
    
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        BOOL success = ([response isValidResponse]) ? YES : NO;
        [super didFinishInvoker:invoker results:@(success) request:request response:response];
 }];
}


////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (KDUser *)_parseUser:(KDResponseWrapper *)response {
    if (![response isValidResponse]) return nil;
    
    KDUser *user = nil;
    
    NSDictionary *body = [response responseAsJSONObject];
    if (body != nil) {
        KDUserParser *parser = [super parserWithClass:[KDUserParser class]];
        user = [parser parse:body withStatus:NO];
    }
    
    return user;
}

// parse the users
- (void)_asyncParseUserListSimple:(KDResponseWrapper *)response completionBlock:(void (^)(NSArray *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *users = nil;
        
        NSArray *bodyList = [response responseAsJSONObject];
        if (bodyList != nil) {
            KDUserParser *parser = [super parserWithClass:[KDUserParser class]];
            users = [parser parseAsUserListSimple:bodyList];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(users);
        });
    });
}

- (void)_asyncParseUserListFrequent:(KDResponseWrapper *)response completionBlock:(void(^)(NSArray *))block {
    if(![response isValidResponse]) {
        if(block) {
            block(nil);
        }
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *users = nil;
        
        NSDictionary *resp = [response responseAsJSONObject];
        NSArray *bodyList = [resp objectForKey:@"contacts"];
        if(!bodyList) {
            bodyList = [resp objectForKey:@"results"];
        }
        
        if(bodyList) {
            KDUserParser *parser = [super parserWithClass:[KDUserParser class]];
            users = [parser parseAsUserListSimple:bodyList];
        }
        
        if(block) {
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                block(users);
            });
        }
    });
}

@end
