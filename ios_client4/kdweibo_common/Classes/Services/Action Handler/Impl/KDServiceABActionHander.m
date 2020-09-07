//
//  KDServiceABActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-27.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceABActionHander.h"

#define KD_SERVICE_ACCOUNT_ACTION_PATH	@"/ab/"

@implementation KDServiceABActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_ACCOUNT_ACTION_PATH;
}

- (void)recentlyListSimple:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY
                 serviceURL:@"addressbook/recently_contact_simple.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseABPersons:response type:KDABPersonTypeRecently completionBlock:^(NSArray *results){
                     [super didFinishInvoker:invoker results:results request:request response:response];
                 }];
             }];
}

- (void)memberListSimple:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY
                 serviceURL:@"addressbook/member_list_simple.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseABPersons:response type:KDABPersonTypeAll completionBlock:^(NSArray *results){
                     [super didFinishInvoker:invoker results:results request:request response:response];
                 }];
             }];
}

- (void)favoritedListSimple:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY
                 serviceURL:@"addressbook/favorite_list_simple.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseABPersons:response type:KDABPersonTypeFavorited completionBlock:^(NSArray *results){
                     [super didFinishInvoker:invoker results:results request:request response:response];
                 }];
             }];
}

- (void)searchListSimple:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY
                 serviceURL:@"addressbook/search_simple.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseABPersons:response type:KDABPersonTypeAll completionBlock:^(NSArray *results){
                     [super didFinishInvoker:invoker results:results request:request response:response];
                 }];
             }];
}

- (void)favorite:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY
                 serviceURL:@"addressbook/favorite.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 if ([response isValidResponse]) {
                     BOOL result = [self _parseToggleFavoritedResult:response];
                     [super didFinishInvoker:invoker results:@(result) request:request response:response];
                 }
             }];
}

- (void)unfavorite:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY
                 serviceURL:@"addressbook/unfavorite.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 BOOL result = [self _parseToggleFavoritedResult:response];
                 [super didFinishInvoker:invoker results:@(result) request:request response:response];
             }];
}

- (void)personByUserId:(KDServiceActionInvoker *)invoker {
    NSString *userId = [invoker.query propertyForKey:@"userId"];
    NSString *serviceURL = [NSString stringWithFormat:@"addressbook/%@.json", userId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed){
                 [self _asyncParseABPerson:response completionBlock:^(NSArray *results){
                     [super didFinishInvoker:invoker results:results request:request response:response];
                 }];
             }];
}

- (void)_asyncParseABPerson:(KDResponseWrapper *)response completionBlock:(void(^)(NSArray *result))block {
    if(![response isValidResponse]) {
        if(block) {
            block(nil);
        }
        return;
    }
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSDictionary *dic = [response responseAsJSONObject];
        NSArray *result = nil;
        if(dic) {
            KDABPersonParser *parser = [super parserWithClass:[KDABPersonParser class]];
            result = [parser parse:@[[dic objectForKey:@"addressbook"]] type:KDABPersonTypeAll];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(){
            block(result);
        });
    });
}

- (void)_asyncParseABPersons:(KDResponseWrapper *)response type:(KDABPersonType)type
            completionBlock:(void (^)(NSArray *))block {
    
    // validate the response at first
    if (![response isValidResponse]) {
        block(nil);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *results = nil;
        
        NSArray *personList = nil;
        id body = [response responseAsJSONObject];
        if (body != nil) {
            if (type == KDABPersonTypeAll || type == KDABPersonTypeFavorited) {
                personList = [(NSDictionary *)body objectNotNSNullForKey:@"list"];
                
            } else {
                personList = body;
            }
            
            KDABPersonParser *parser = [super parserWithClass:[KDABPersonParser class]];
            results = [parser parse:personList type:type];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(){
            block(results);
        });
    });
}

- (BOOL)_parseToggleFavoritedResult:(KDResponseWrapper *)response {
    BOOL result = NO;
    if ([response isValidResponse]) {
        NSDictionary *info = [response responseAsJSONObject];
        if (info != nil) {
            result = [info boolForKey:@"result"];
        }
    }
    
    return result;
}

@end
