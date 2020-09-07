//
//  KDServiceClientActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceClientActionHander.h"
#import "KDAppVersionUpdates.h"
#import "SBJsonParser.h"

#define KD_SERVICE_CLIENT_ACTION_PATH	@"/client/"

@implementation KDServiceClientActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_CLIENT_ACTION_PATH;
}

- (void)uploadCrashReport:(KDServiceActionInvoker *)invoker {
    // unsupport now.
}

- (void)shareUpdates:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"client/share_client_update.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 // drop response at now
                 [super didFinishInvoker:invoker results:nil request:request response:response];
             }];
}

- (void)checkUpdates:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"passport/getUpgradeInfo.json"];
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDAppVersionUpdates *updates = nil;
                 if ([response isValidResponse]) {
                     NSDictionary *body = [response responseAsJSONObject];
                     if (body != nil) {
                         KDCompositeParser *parser = [super parserWithClass:[KDCompositeParser class]];
                         updates = [parser parseAsAppVersionUpdates:body];
                     }
                 }
                 
                 [super didFinishInvoker:invoker results:updates request:request response:response];
             }];
}

- (void)storeDevice:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"client/store_device.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 // drop response at now
                 [super didFinishInvoker:invoker results:nil request:request response:response];
             }];
}

- (void)removeDevice:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"client/remove_device.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 // drop response at now
                 [super didFinishInvoker:invoker results:nil request:request response:response];
             }];
}

- (void)userApplications:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"client/user_applications.json"];
    
    [super doGet:invoker
             configBlock:nil
               didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                   NSArray *apps = nil;
                   
                   if ([response isValidResponse]) {
                       NSArray *bodyList = [response responseAsJSONObject];
                       if (bodyList != nil) {
                           KDCompositeParser *parser = [super parserWithClass:[KDCompositeParser class]];
                           apps = [parser parseAsClientApplications:bodyList];
                       }
                   }
                   
                   [super didFinishInvoker:invoker results:apps request:request response:response];
               }];
}

- (void)applicationAccessToken:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"client/fire_invoke_url.json"];
    
    [super doGet:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        [super didFinishInvoker:invoker results:[[response responseAsJSONObject] stringForKey:@"auth_param"] request:request response:response];
    }];
}

@end
