//
//  KDServiceCollectionActionHander.m
//  kdweibo_common
//
//  Created by kingdee on 14-8-14.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "KDServiceCollectionActionHander.h"

#define KD_SERVICE_COLLECTION_ACTION_PATH @"/infocollect/"

@implementation KDServiceCollectionActionHander
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_COLLECTION_ACTION_PATH;
}

- (void)contact : (KDServiceActionInvoker *)invoker{
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"infocollect/contact.json"];
    
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed) {
        
        NSDictionary *response = nil;
        if ([responseWrapper isValidResponse]) {
            response = responseWrapper.responseAsJSONObject;
        }
        
        [super didFinishInvoker:invoker results:response request:requestWrapper response:responseWrapper];
    }];
}

- (void)wifi : (KDServiceActionInvoker *)invoker{
    
}
@end
