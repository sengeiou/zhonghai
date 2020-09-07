//
//  KDServiceGroupActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceGroupActionHander.h"
#import "KDCacheUtlities.h"

#define KD_SERVICE_GROUP_ACTION_PATH	@"/group/"

@implementation KDServiceGroupActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_GROUP_ACTION_PATH;
}

- (void)details:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"group/detail.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDGroup *group = [self _parseGroup:response];
                 [super didFinishInvoker:invoker results:group request:request response:response];
             }];
}

- (void)joined:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"group/joined.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseGroups:response completionBlock:^(NSArray *groups){
                     [super didFinishInvoker:invoker results:groups request:request response:response];
                 }];
             }];
}

- (void)list:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"group/list.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 // TODO: add the implementation in the future
             }];
}

- (void)members:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"group/members.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseGroupMembers:response completionBlock:^(NSDictionary *info) {
                     [super didFinishInvoker:invoker results:info request:request response:response];
                 }];
             }];
}

- (void)groupAvatar:(KDServiceActionInvoker *)invoker {
    // TODO: xxx retrieve url and call image handle
    NSString *url = [invoker.query propertyForKey:@"url"];
    KDImageSize *size = [invoker.query propertyForKey:@"size"];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:nil];
    [invoker resetRequestURL:url];
    
    [super doTransfer:invoker isGet:YES
          configBlock:^(KDRequestWrapper *requestWrapper, ASIHTTPRequest *request) {
              [requestWrapper addUserInfoWithObject:size forKey:kKDImageScaleSizeKey];
              [requestWrapper addUserInfoWithObject:[NSNumber numberWithBool:YES] forKey:kKDIsRequestImageSourceKey];
              [requestWrapper addUserInfoWithObject:@(KDCacheImageTypeAvatar) forKey:kKDRequestImageCropTypeKey];
              
              requestWrapper.isDownload = YES;
              
              request.downloadDestinationPath = requestWrapper.downloadTemporaryPath;
          }
     didCompleteBlock:nil];
}

// parse the details info about group from response
- (KDGroup *)_parseGroup:(KDResponseWrapper *)response {
    if (![response isValidResponse]) return nil;
    
    KDGroup *group = nil;
    NSDictionary *body = [response responseAsJSONObject];
    if (body != nil) {
        KDGroupParser *parser = [super parserWithClass:[KDGroupParser class]];
        NSArray *groups = [parser parseAsGroupList:@[body]];
        if (groups != nil && [groups count] > 0) {
            group = groups[0];
        }
    }
    
    return group;
}

// parse the joined groups from response
- (void)_asyncParseGroups:(KDResponseWrapper *)response completionBlock:(void (^)(NSArray *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *groups = nil;
        
        NSArray *bodyList = [response responseAsJSONObject];
        if (bodyList != nil) {
            KDGroupParser *parser = [super parserWithClass:[KDGroupParser class]];
            groups = [parser parseAsGroupList:bodyList];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(groups);
        });
    });
}

// parse the group members from response
- (void)_asyncParseGroupMembers:(KDResponseWrapper *)response completionBlock:(void (^)(NSDictionary *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *users = nil;
        NSInteger nextCursor = -1;
        NSArray *bodyList = nil;
        
        id body = [response responseAsJSONObject];
        if ([body isKindOfClass:[NSDictionary class]]) {
            bodyList = [body objectNotNSNullForKey:@"users"];
            nextCursor = [body integerForKey:@"next_cursor"];
        }else if ([body isKindOfClass:[NSArray class]]) {
            bodyList = body;
        }
        
        if (bodyList != nil) {
            KDUserParser *parser = [super parserWithClass:[KDUserParser class]];
            users = [parser parseAsUserListSimple:bodyList];
        }
        
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
        if (users != nil) {
            [info setObject:users forKey:@"users"];
        }
        if (nextCursor != -1) {
            [info setObject:@(nextCursor) forKey:@"nextCursor"];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(info);
        });
    });
}

@end
