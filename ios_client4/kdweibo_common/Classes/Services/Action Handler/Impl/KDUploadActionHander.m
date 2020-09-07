//
//  KDUploadActionHander.m
//  kdweibo_common
//
//  Created by Tan yingqi on 13-5-17.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDUploadActionHander.h"
#import "KDDraft.h"
#define KD_SERVICE_UPLOAD_ACTION_PATH	@"/upload/"
@implementation KDUploadActionHander
// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_UPLOAD_ACTION_PATH;
}
- (void)multipleDoc:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"multipart/upload.json"];
    [super doTransfer:invoker isGet:NO configBlock:^(KDRequestWrapper *requestWrapper, ASIHTTPRequest *request) {
        request.numberOfTimesToRetryOnTimeout = 0;
        KDDraft *draft = [invoker.query propertyForKey:@"draft"];
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:@([draft hasVideo] && draft.uploadIndex == 1) forKey:@"VideoFlag"];
        requestWrapper.userInfo = userInfo;
    }
     didCompleteBlock:^(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed) {
        NSString *uploadId = nil;
        if ([responseWrapper isValidResponse]) {
            NSDictionary *dic = [responseWrapper responseAsJSONObject];
            uploadId = [dic stringForKey:@"result"];
        }
        [super didFinishInvoker:invoker results:uploadId request:requestWrapper response:responseWrapper];

    }];

}

- (void)uploadVideo:(KDServiceActionInvoker *)invoker{
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"multipart/upload.json"];
    [super doTransfer:invoker isGet:NO configBlock:^(KDRequestWrapper *requestWrapper, ASIHTTPRequest *request) {
        request.numberOfTimesToRetryOnTimeout = 0;
         NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//        [userInfo setObject:@(0)forKey:@"VideoFlag"];
//        requestWrapper.userInfo = userInfo;
    }
     didCompleteBlock:^(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed) {
         NSString *uploadId = nil;
         if ([responseWrapper isValidResponse]) {
             NSDictionary *dic = [responseWrapper responseAsJSONObject];
             uploadId = [dic stringForKey:@"result"];
         }
         [super didFinishInvoker:invoker results:uploadId request:requestWrapper response:responseWrapper];
         
     }];
}
@end
