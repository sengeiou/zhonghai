//
//  KDServiceAuthActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceAuthActionHander.h"
#import "KDAuthToken.h"

#define KD_SERVICE_AUTH_ACTION_PATH	@"/auth/"

@implementation KDServiceAuthActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_AUTH_ACTION_PATH;
}

- (void)accessToken:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"oauth/access_token"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDAuthToken *authToken = [self _parseAsAuthToken:response];
                 [super didFinishInvoker:invoker results:authToken request:request response:response];
             }];
}

- (void)webLoginToken:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"oauth/weblogin_token"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDAuthToken *authToken = [self _parseAsAuthToken:response];
                 [super didFinishInvoker:invoker results:authToken request:request response:response];
             }];
}



- (KDAuthToken *)_parseAsAuthToken:(KDResponseWrapper *)response {
    KDAuthToken *authToken = nil;
    if([response isValidResponse]){
        NSString *responseString = [response responseAsString];
        authToken = [KDAuthToken authTokenWithString:responseString];
    }
    
    return authToken;
}

@end
