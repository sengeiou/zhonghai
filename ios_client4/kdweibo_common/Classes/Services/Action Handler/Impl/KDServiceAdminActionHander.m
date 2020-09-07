//
//  KDServiceAdminActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceAdminActionHander.h"

#define KD_SERVICE_ADMIN_ACTION_PATH	@"/admin/"

@implementation KDServiceAdminActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_ADMIN_ACTION_PATH;
}

- (void)registerAccount:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_BASE serviceURL:@"admin/register.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 BOOL success = NO;
                 if([response isValidResponse]){
                     NSDictionary *body = [response responseAsJSONObject];
                     if (body != nil) {
                         success = [body boolForKey:@"success"];
                     }
                 }
                 
                 [super didFinishInvoker:invoker results:@(success) request:request response:response];
             }];
}

- (void)quickValidate:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_BASE serviceURL:@"admin/register_via_mailaccount.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
               NSDictionary *body = nil;
               if([response isValidResponse]) {
                   body = [response responseAsJSONObject];
               }
               
               [super didFinishInvoker:invoker results:body request:request response:response];
             }];
}

- (void)registerCodeInfo:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_BASE serviceURL:@"admin/register_code_info.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 NSDictionary *body = nil;
                 if([response isValidResponse]) {
                     body = [response responseAsJSONObject];
                 }
                 
                 [super didFinishInvoker:invoker results:body request:request response:response];
             }];
}

- (void)activeUser:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_BASE serviceURL:@"admin/active_user.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 NSDictionary *body = nil;
                 if([response isValidResponse]) {
                     body = [response responseAsJSONObject];
                 }
                 
                 [super didFinishInvoker:invoker results:body request:request response:response];
             }];
}

@end
