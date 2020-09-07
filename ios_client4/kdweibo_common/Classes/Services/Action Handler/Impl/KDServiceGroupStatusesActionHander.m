//
//  KDServiceGroupStatusesActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceGroupStatusesActionHander.h"
#import "KDDraft.h"
#import "NSString+Additions.h"
#import "KDVideoCaptureManager.h"

#define KD_SERVICE_GROUP_STATUSES_ACTION_PATH	@"/group/statuses/"

@implementation KDServiceGroupStatusesActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_GROUP_STATUSES_ACTION_PATH;
}

- (void)bindDraft:(KDDraft *)draft toQuery:(KDQuery *)query {
    switch (draft.type) {
        case KDDraftTypeNewStatus:
        {
            [query setParameter:@"group_id" stringValue:draft.groupId];
            [query setParameter:@"status" stringValue:draft.content];
            if(draft.address != nil && draft.address.length >0) {
                [query setParameter:@"lat" floatValue:(float)draft.coordinate.latitude];
                [query setParameter:@"long" floatValue:(float)draft.coordinate.longitude];
                [query setParameter:@"address" stringValue:draft.address];
            }
            NSString *fileids = [draft.uploadedImages componentsJoinedByString:@","];
            [query setParameter:@"fileids" stringValue:fileids];
            [query setParameter:@"pic" filePath:nil];
            
        }
            break;
            
        case KDDraftTypeForwardStatus:
        {
            [[[query setParameter:@"status" stringValue:draft.content]
                     setParameter:@"id" stringValue:draft.commentForStatusId]
                     setParameter:@"is_comment" stringValue:@"0"];
        }
            break;
            
        case KDDraftTypeCommentForStatus:
        case KDDraftTypeCommentForComment:
        {
            NSString *fileids = [draft.uploadedImages componentsJoinedByString:@","];
            [query setParameter:@"fileids" stringValue:fileids];
            [query setParameter:@"pic" filePath:nil];
            
            [[[[query setParameter:@"comment" stringValue:draft.content]
                      setParameter:@"id" stringValue:draft.commentForStatusId]
                      setParameter:@"cid" stringValue:draft.commentForCommentId]
                      setParameter:@"comment_ori" stringValue:@"0"];
        }
            break;
            
        default:
            break;
    }
}

- (void)bindData:(NSData *)data toQuery:(KDQuery *)query {
    if (data != nil) {
        [query setParameter:@"pic" fileData:data];
    }
}

- (void)bindImage:(NSString *)imagePath toQuery:(KDQuery *)query {
    if (imagePath != nil) {
        [query setParameter:@"pic" filePath:imagePath];
    }
}

- (void)comment:(KDServiceActionInvoker *)invoker {
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    [self bindDraft:draft toQuery:invoker.query];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"group/statuses/comment.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseStatuses:response type:KDTLStatusTypeComment
                           completionBlock:^(NSArray *statuses){
                               [super didFinishInvoker:invoker results:statuses request:request response:response];
                           }];             }];
}

- (void)counts:(KDServiceActionInvoker *)invoker {
    
}

- (void)destroyById:(KDServiceActionInvoker *)invoker {
    
}

- (void)periodTimeline:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"group/statuses/period_timeline.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseGroupStatuses:response
                                completionBlock:^(NSArray *statuses){
                                    [super didFinishInvoker:invoker results:statuses
                                                    request:request response:response];
                               }];
             }];
}

- (void)periodTimelineByCursor:(KDServiceActionInvoker *)invoker {
    
}

- (void)repost:(KDServiceActionInvoker *)invoker {
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    [self bindDraft:draft toQuery:invoker.query];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"group/statuses/repost.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseStatuses:response type:KDTLStatusTypeForwarded
                           completionBlock:^(NSArray *statuses){
                               [super didFinishInvoker:invoker results:statuses request:request response:response];
                           }];
             }];
}

- (void)showById:(KDServiceActionInvoker *)invoker {
    
}

- (void)timeline:(KDServiceActionInvoker *)invoker {
    
}

- (void)timelineByCursor:(KDServiceActionInvoker *)invoker {
    
}

- (void)update:(KDServiceActionInvoker *)invoker {
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    [self bindDraft:draft toQuery:invoker.query];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"group/statuses/update.json"];
    
    [super doPost:invoker configBlock:nil

     didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
       [self _asyncParseStatuses:response type:KDTLStatusTypePublic
               completionBlock:^(NSArray *statuses){
                   [super didFinishInvoker:invoker results:statuses request:request response:response];
               }];
 }];
    
}

- (void)upload:(KDServiceActionInvoker *)invoker {
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    
    int uploadIndex = (int)draft.uploadIndex;
    if ([draft.uploadedImages count] > 0) {
        uploadIndex = (int)[draft.uploadedImages count] - 1;
        draft.uploadIndex = uploadIndex;
    }
    int imageCount = (int)draft.assetURLs.count;
    
    if ([draft hasVideo]) {
        [self uploadVideo:invoker type:KDTLStatusTypePublic];
        return;
    }
    
    if (uploadIndex >= imageCount - 1) {
        [self update:invoker];
    }else {
        [self uploadImages:invoker type:KDTLStatusTypePublic];
    }
    
}

- (void)uploadImages:(KDServiceActionInvoker *)invoker type:(NSUInteger)type
{
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    
    draft.uploadIndex += 1;
    
    NSArray *paths = [draft propertyForKey:kKDDraftImageAttachmentPathPropertyKey];
    
    [self bindImage:[paths objectAtIndex:draft.uploadIndex] toQuery:invoker.query];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]){
            if (results) {
                DLog(@"success = %@", [response responseAsString]);
                [draft.uploadedImages addObject:results];
                [self postSendingProgress:draft];
                if (draft.uploadIndex >= draft.assetURLs.count - 1) {
                    switch (type) {
                        case KDTLStatusTypePublic:
                            [self update:invoker];
                            break;
                        case KDTLStatusTypeComment:
                            [self comment:invoker];
                            break;
                            
                        default:
                            break;
                    }
                    
                }else {
                    [self uploadImages:invoker type:type];
                }
            }else {
                //Failed
                DLog(@"-------%@", [response responseAsString]);
            }
            
        }
        else {
            if (![response isCancelled]) {
                DLog(@"-------%@", [response responseAsString]);
            }
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/upload/:multipleDoc" query:invoker.query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)uploadVideo:(KDServiceActionInvoker *)invoker type:(NSUInteger)type
{
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    
    NSString *path = draft.videoPath;
    
    draft.uploadIndex += 1;
    
    switch (draft.uploadIndex) {
        case 0:
        {
            UIImage *image = [KDVideoCaptureManager thumbnailImageForVideo:[NSURL fileURLWithPath:path] atTime:0.];
            [self bindData:UIImageJPEGRepresentation(image, 1.0) toQuery:invoker.query];
        }
            break;
            
        case 1:
        {
            [invoker.query setParameter:@"pic" filePath:path];
        }
            break;
            
        default:
            break;
    }
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]){
            if (results) {
                DLog(@"success = %@", [response responseAsString]);
                [draft.uploadedImages addObject:results];
                [self postSendingProgress:draft];
                if (draft.uploadIndex >= 1) {
                    switch (type) {
                        case KDTLStatusTypePublic:
                            [self update:invoker];
                            break;
                        case KDTLStatusTypeComment:
                            [self comment:invoker];
                            break;
                            
                        default:
                            break;
                    }
                    
                }else {
                    [self uploadVideo:invoker type:type];
                }
            }else {
                //Failed
                DLog(@"-------%@", [response responseAsString]);
            }
            
        }
        else {
            if (![response isCancelled]) {
                
            }
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/upload/:multipleDoc" query:invoker.query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)uploadComment:(KDServiceActionInvoker *)invoker {
    
    
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    
    int uploadIndex = (int)draft.uploadIndex;
    int imageCount =(int)draft.assetURLs.count;
    
    if ([draft.uploadedImages count] > 0) {
        uploadIndex =(int)[draft.uploadedImages count] - 1;
        draft.uploadIndex = uploadIndex;
    }
    
    if ([draft hasVideo]) {
        [self uploadVideo:invoker type:KDTLStatusTypeComment];
        return;
    }
    
    if (uploadIndex >= imageCount - 1) {
        [self comment:invoker];
    }else {
        [self uploadImages:invoker type:KDTLStatusTypeComment];
    }
}


// parse the statuses of timeline with specificed group from response
- (void)_asyncParseGroupStatuses:(KDResponseWrapper *)response completionBlock:(void (^)(NSArray *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *statuses = nil;
        
        NSArray *bodyList = [response responseAsJSONObject];
        if (bodyList != nil) {
            KDStatusParser *parser = [super parserWithClass:[KDStatusParser class]];
            statuses = [parser parseAsGroupStatuses:bodyList];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(statuses);
        });
    });
}
// parse the statuses of timeline from response
- (void)_asyncParseStatuses:(KDResponseWrapper *)response type:(KDTLStatusType)type
            completionBlock:(void (^)(NSArray *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *statuses = nil;
        id obj = [response responseAsJSONObject];
        NSArray *bodyList = nil;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            bodyList = @[obj];
        }else if ([obj isKindOfClass:[NSArray class]]) {
            bodyList = (NSArray *)[response responseAsJSONObject];
        }
        if (bodyList != nil) {
            KDStatusParser *parser = [super parserWithClass:[KDStatusParser class]];
            
            switch (type) {
                case KDTLStatusTypeUndefined:
                case KDTLStatusTypePublic:
                case KDTLStatusTypeFriends:
                case KDTLStatusTypeHotComment:
                case KDTLStatusTypeForwarded:
                    statuses = [parser parseAsStatuses:bodyList type:type];
                    break;
                    
                case KDTLStatusTypeMentionMe:
                    statuses = [parser parseAsMentionMeStatuses:bodyList];
                    break;
                    
                case KDTLStatusTypeCommentMe:
                    statuses = [parser parseAsCommentMeStatuses:bodyList];
                    break;
                case KDTLStatusTypeComment:
                    statuses = [parser parseAsCommentStatuses:bodyList];
                default:
                    break;
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(statuses);
        });
    });
}

- (void)postSendingProgress:(KDDraft *)draft
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    if([draft hasVideo]) {
        [info setObject:[NSNumber numberWithFloat:(((float)draft.uploadIndex + 1) / 2)] forKey:@"progress"];
    }else {
        [info setObject:[NSNumber numberWithFloat:(((float)draft.uploadIndex + 1) / (draft.assetURLs.count))] forKey:@"progress"];
    }
    [info setObject:[NSString stringWithFormat:@"temp_%ld", (long)draft.draftId] forKey:@"statusId"];
    [info setObject:draft forKey:@"draft"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kKDServiceStatusesProgressNotification object:info];
}

@end
