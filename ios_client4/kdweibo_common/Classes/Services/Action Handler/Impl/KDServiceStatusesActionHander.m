//
//  KDServiceStatusesActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceStatusesActionHander.h"
#import "KDDraft.h"
#import "NSString+Additions.h"

#define KD_SERVICE_STATUSES_ACTION_PATH	@"/statuses/"

NSString * const kKDServiceStatusesProgressNotification = @"kKDServiceStatusesProgressNotification";

@implementation KDServiceStatusesActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_STATUSES_ACTION_PATH;
}

- (void)bindDraft:(KDDraft *)draft toQuery:(KDQuery *)query {
    switch (draft.type) {
        case KDDraftTypeShareSign:
        case KDDraftTypeNewStatus:
        {
            NSString *fileids = [draft.uploadedImages componentsJoinedByString:@","];
            [query setParameter:@"fileids" stringValue:fileids];
            [query setParameter:@"pic" filePath:nil];
            [query setParameter:@"status" stringValue:draft.content];
            if(draft.address != nil && draft.address.length >0) {
                [query setParameter:@"lat" floatValue:(float)draft.coordinate.latitude];
                [query setParameter:@"long" floatValue:(float)draft.coordinate.longitude];
                [query setParameter:@"address" stringValue:draft.address];
            }
           
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
            
            [[[query setParameter:@"comment" stringValue:draft.content]
                     setParameter:@"id" stringValue:draft.commentForStatusId]
                     setParameter:@"comment_ori" stringValue:@"0"];
            
            if (draft.commentForCommentId != nil) {
                [query setParameter:@"cid" stringValue:draft.commentForCommentId];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)bindData:(NSString *)imagePath toQuery:(KDQuery *)query {
    if (imagePath != nil) {
        [query setParameter:@"pic" filePath:imagePath];
    }
}

- (void)comment:(KDServiceActionInvoker *)invoker {
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    [self bindDraft:draft toQuery:invoker.query];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/comment.json"];
    
    [super doPost:invoker configBlock:nil

//             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
//                 KDStatus *status = nil;
//                 if([response isValidResponse]) {
//                     NSDictionary *dic = [response responseAsJSONObject];
//                     KDStatusParser *parser = [super parserWithClass:[KDStatusParser class]];
//                     status = [parser parseAsStatus:dic type:KDTLStatusTypePublic];
//                 }
//                 
//                 [super didFinishInvoker:invoker results:status request:request response:response];
//             }];
          didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
              [self _asyncParseStatuses:response type:KDTLStatusTypeComment
                        completionBlock:^(NSArray *statuses){
                            [super didFinishInvoker:invoker results:statuses request:request response:response];
                        }];
 }];

}

- (void)commentById:(KDServiceActionInvoker *)invoker {
    
}

- (void)comments:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/comments.json"];
    
    [super doGet:invoker configBlock:nil
           didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                    [self _asyncParseCommentStatuses:response
                           completionBlock:^(NSDictionary *info){
                               [super didFinishInvoker:invoker results:info
                                         request:request response:response];
                      }];
     }];
}

- (void)commentsByCursor:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/comments/cursor.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseCommentStatuses:response
                                  completionBlock:^(NSDictionary *info){
                                      [super didFinishInvoker:invoker results:info
                                                      request:request response:response];
                                  }];
             }];
}

- (void)commentByMe:(KDServiceActionInvoker *)invoker {
    
}

- (void)commentDestory:(KDServiceActionInvoker *)invoker {
    NSString *commentId = [invoker.query propertyForKey:@"commentId"];
    NSString *serviceURL = [NSString stringWithFormat:@"statuses/comments/destory/%@.json", commentId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 BOOL success = NO;
                 if ([response isValidResponse]) {
                     NSDictionary *body = [response responseAsJSONObject];
                     success = [body boolForKey:@"result"];
                 }
                 
                 [super didFinishInvoker:invoker results:@(success) request:request response:response];
             }];
}

- (void)commentsTimeline:(KDServiceActionInvoker *)invoker {
    
}

- (void)commentsToMe:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/comments_to_me.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseStatuses:response type:KDTLStatusTypeCommentMe
                           completionBlock:^(NSArray *statuses){
                               [super didFinishInvoker:invoker results:statuses request:request response:response];
                           }];
             }];
}

- (void)counts:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/counts.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseStatusCounts:response
                               completionBlock:^(NSArray *statusCountsList){
                                   [super didFinishInvoker:invoker results:statusCountsList
                                                   request:request response:response];
                               }];
             }];
}

- (void)destoryById:(KDServiceActionInvoker *)invoker {
    NSString *statusId = [invoker.query propertyForKey:@"statusId"];
    NSString *serviceURL = [NSString stringWithFormat:@"statuses/destroy/%@.json", statusId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 BOOL success = ([response isValidResponse]) ? YES : NO;
                 [super didFinishInvoker:invoker results:@(success) request:request response:response];
             }];
}

- (void)followers:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/followers.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseUsers:response completionBlock:^(NSDictionary *info){
                     [super didFinishInvoker:invoker results:info request:request response:response];
                 }];
             }];
}

- (void)followersById:(KDServiceActionInvoker *)invoker {
    
}

- (void)forwards:(KDServiceActionInvoker *)invoker {
    NSString *statusId = [invoker.query genericParameterForName:@"id"];
    NSString *serviceURL = [NSString stringWithFormat:@"statuses/forwards/%@.json", statusId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseStatuses:response type:KDTLStatusTypeUndefined
                           completionBlock:^(NSArray *statuses){
                               [super didFinishInvoker:invoker results:statuses request:request response:response];
                           }];
             }];
}

- (void)friends:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/friends.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseUsers:response completionBlock:^(NSDictionary *info){
                     [super didFinishInvoker:invoker results:info request:request response:response];
                 }];
             }];
}

- (void)friendsById:(KDServiceActionInvoker *)invoker {
    
}

- (void)friendsTimeline:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/friends_timeline.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseStatuses:response type:KDTLStatusTypeFriends
                           completionBlock:^(NSArray *statuses){
                               [super didFinishInvoker:invoker results:statuses request:request response:response];
                           }];
             }];
}

- (void)friendsTimelineByCursor:(KDServiceActionInvoker *)invoker {
    
}

- (void)mentions:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/mentions.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseStatuses:response type:KDTLStatusTypeMentionMe
                           completionBlock:^(NSArray *statuses){
                               [super didFinishInvoker:invoker results:statuses request:request response:response];
                           }];
             }];
}

- (void)publicTimeline:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/public_timeline.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseStatuses:response type:KDTLStatusTypePublic
                           completionBlock:^(NSArray *statuses){
                               [super didFinishInvoker:invoker results:statuses request:request response:response];
                           }];
             }];
}

- (void)hotComments:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/hotcmt.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseStatuses:response type:KDTLStatusTypeHotComment
                           completionBlock:^(NSArray *statuses){
                               [super didFinishInvoker:invoker results:statuses request:request response:response];
                           }];
             }];
}

- (void)bulletins:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/notice_timeline.json"];
    
    [super doGet:invoker configBlock:nil
didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    [self _asyncParseStatuses:response type:KDTLStatusTypeBulletin
              completionBlock:^(NSArray *statuses){
                  [super didFinishInvoker:invoker results:statuses request:request response:response];
              }];
}];
}

- (void)reply:(KDServiceActionInvoker *)invoker {
    
}

- (void)repost:(KDServiceActionInvoker *)invoker {
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    [self bindDraft:draft toQuery:invoker.query];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/repost.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {

                 [self _asyncParseStatuses:response type:KDTLStatusTypeForwarded
                           completionBlock:^(NSArray *statuses){
                               [super didFinishInvoker:invoker results:statuses request:request response:response];
                           }];
             }];
}

- (void)resetCount:(KDServiceActionInvoker *)invoker {
    
}

- (void)retweetById:(KDServiceActionInvoker *)invoker {
    
}

- (void)search:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/search.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseStatuses:response type:KDTLStatusTypeUndefined
                           completionBlock:^(NSArray *statuses){
                               [super didFinishInvoker:invoker results:statuses request:request response:response];
                           }];
             }];
}

- (void)showById:(KDServiceActionInvoker *)invoker {
    NSString *statusId = [invoker.query propertyForKey:@"statusId"];
    NSString *serviceURL = [NSString stringWithFormat:@"statuses/show/%@.json", statusId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDStatus *status = nil;
                 BOOL isExist = YES;
                 if ([response isValidResponse]) {
                     NSDictionary *body = [response responseAsJSONObject];
                     int statusCode = [body intForKey:@"status"];
                     if (404 == statusCode) {
                         isExist = NO; // try to show the details info about deleted status
                     } else {
                         KDStatusParser *parser = [super parserWithClass:[KDStatusParser class]];
                         status = [parser parseAsStatus:body type:KDTLStatusTypeUndefined];
                     }
                 }
                 
                 NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
                 if (status != nil) {
                     [info setObject:status forKey:@"status"];
                 }
                 
                 [info setObject:@(isExist) forKey:@"isExist"];
                 
                 [super didFinishInvoker:invoker results:info request:request response:response];
             }];
}

- (void)unread:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/v4/unread.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDUnread *unread = nil;
                 if ([response isValidResponse]) {
                     NSDictionary *body = [response responseAsJSONObject];
                     if (body != nil) {
                         KDCompositeParser *parser = [super parserWithClass:[KDCompositeParser class]];
                         unread = [parser parseAsUnread:body];
                     }
                 }
                 
                 [super didFinishInvoker:invoker results:unread request:request response:response];
             }];
}

//分享签到 -2013-10-21- 王松
- (void)sharesignin:(KDServiceActionInvoker *)invoker {
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    [self bindDraft:draft toQuery:invoker.query];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/share_sign.json"];
    [super doPost:invoker configBlock:nil
    didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        id result = nil;
        if ([response isValidResponse]) {
             NSDictionary *body = [response responseAsJSONObject];
            if (body) {
                BOOL success = [body[@"success"] boolValue];
                if (success) {
                    result = @(success);
                }
            }
        }
       [super didFinishInvoker:invoker results:result request:request response:response];
    }];
    
}

- (void)update:(KDServiceActionInvoker *)invoker {
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    [self bindDraft:draft toQuery:invoker.query];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/update.json"];
    
     [super doPost:invoker configBlock:nil

      didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        [self _asyncParseStatuses:response type:KDTLStatusTypePublic
                  completionBlock:^(NSArray *statuses){
                      [super didFinishInvoker:invoker results:statuses request:request response:response];
                  }];
      }];

}

//评论带图片
- (void)uploadComment:(KDServiceActionInvoker*)invoker {
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    [self bindDraft:draft toQuery:invoker.query];
    
    int uploadIndex = (int)draft.uploadIndex;
    if ([draft.uploadedImages count] > 0) {
        uploadIndex = (int)[draft.uploadedImages count] - 1;
        draft.uploadIndex = uploadIndex;
    }
    int imageCount = (int)draft.assetURLs.count;
    
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

- (void)sharesigninupload:(KDServiceActionInvoker *)invoker {
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    
    int uploadIndex = (int)draft.uploadIndex;
    if ([draft.uploadedImages count] > 0) {
        uploadIndex = (int)[draft.uploadedImages count] - 1;
        draft.uploadIndex = uploadIndex;
    }
    int imageCount = (int)draft.assetURLs.count;
    
    if ([draft hasVideo]) {
        [self uploadVideo:invoker type:KDTLStatusTypeShareSignin];
        return;
    }
    
    if (uploadIndex >= imageCount - 1) {
        [self sharesignin:invoker];
    }else {
        [self uploadImages:invoker type:KDTLStatusTypeShareSignin];
    }
    
}

- (void)uploadImages:(KDServiceActionInvoker *)invoker type:(NSUInteger)type
{
    KDDraft *draft = [invoker.query propertyForKey:@"draft"];
    
    draft.uploadIndex += 1;
    
    NSArray *paths = [draft propertyForKey:kKDDraftImageAttachmentPathPropertyKey];
    
    [self bindData:[paths objectAtIndex:draft.uploadIndex] toQuery:invoker.query];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]){
            if (results) {
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
                        case KDTLStatusTypeShareSignin:
                            [self sharesignin:invoker];
                            break;
                            
                        default:
                            break;
                    }
                    
                }else {
                    [self uploadImages:invoker type:type];
                }
            }else {
                //Failed
                DLog(@"%@", [response responseAsString]);
                [self _asyncParseStatuses:response type:KDTLStatusTypePublic
                          completionBlock:^(NSArray *statuses){
                              [super didFinishInvoker:invoker results:statuses request:request response:response];
                          }];
                return;
            }
            
        }
        else {
            [self _asyncParseStatuses:response type:KDTLStatusTypePublic
                          completionBlock:^(NSArray *statuses){
                              [super didFinishInvoker:invoker results:statuses request:request response:response];
                          }];
                return;
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
            NSArray *iamgePaths = [draft propertyForKey:kKDDraftImageAttachmentPathPropertyKey];
            
            [self bindData:[iamgePaths objectAtIndex:draft.uploadIndex] toQuery:invoker.query];
        }
            break;
            
        case 1:
        {
            [self bindData:path toQuery:invoker.query];
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
                        case KDTLStatusTypeShareSignin:
                            [self sharesignin:invoker];
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
                [self _asyncParseStatuses:response type:KDTLStatusTypePublic
                          completionBlock:^(NSArray *statuses){
                              [super didFinishInvoker:invoker results:statuses request:request response:response];
                          }];
                return;
            }
            
        }
        else {
            [self _asyncParseStatuses:response type:KDTLStatusTypePublic
                      completionBlock:^(NSArray *statuses){
                          [super didFinishInvoker:invoker results:statuses request:request response:response];
                      }];
            return;
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/upload/:multipleDoc" query:invoker.query
                                 configBlock:nil completionBlock:completionBlock];
}


- (void)userTimeline:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/user_timeline.json"];
    
    [super doGet:invoker configBlock:nil
            didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
            [self _asyncParseUserTimelineStatuses:response
                          completionBlock:^(NSDictionary *info){
                              [super didFinishInvoker:invoker results:info
                                              request:request response:response];
                          }];
      }];
}

- (void)userTimelineByCursor:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"statuses/user_timeline/cursor.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 [self _asyncParseUserTimelineStatuses:response
                                       completionBlock:^(NSDictionary *info){
                                           [super didFinishInvoker:invoker results:info
                                                           request:request response:response];
                                       }];
             }];
}

- (void)timelineById:(KDServiceActionInvoker *)invoker {
    
}

- (void)statusImage:(KDServiceActionInvoker *)invoker {
    // TODO: xxx retrieve url and call image handle
    NSString *url = [invoker.query propertyForKey:@"url"];
    KDImageSize *size = [invoker.query propertyForKey:@"size"];
    NSNumber *cacheType = [invoker.query propertyForKey:@"cacheType"];
    id userInfo = [invoker.query propertyForKey:@"userInfo"];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:nil];
    [invoker resetRequestURL:url];
    
    [super doTransfer:invoker isGet:YES
             configBlock:^(KDRequestWrapper *requestWrapper, ASIHTTPRequest *request) {
                 [requestWrapper addUserInfoWithObject:size forKey:kKDImageScaleSizeKey];
                 [requestWrapper addUserInfoWithObject:[NSNumber numberWithBool:YES] forKey:kKDIsRequestImageSourceKey];
                 [requestWrapper addUserInfoWithObject:cacheType forKey:kKDRequestImageCropTypeKey];
                 
                 if(userInfo != nil) {
                     [requestWrapper addUserInfoWithObject:userInfo forKey:kKDCustomUserInfoKey];
                 }
                 
                 requestWrapper.isDownload = YES;
                 
                 request.downloadDestinationPath = requestWrapper.downloadTemporaryPath;
             }
             didCompleteBlock:nil];
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
                case KDTLStatusTypeBulletin:
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

// parse the forwards and comments count for statuses
- (void)_asyncParseStatusCounts:(KDResponseWrapper *)response
                completionBlock:(void (^)(NSArray *))block {

    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *statuseCountsList = nil;
        
        NSArray *bodyList = [response responseAsJSONObject];
        if (bodyList != nil) {
            KDStatusParser *parser = [super parserWithClass:[KDStatusParser class]];
             statuseCountsList = [parser parseAsStatusCountsList:bodyList];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(statuseCountsList);
        });
    });
}

// parse the comment statuses from response
- (void)_asyncParseCommentStatuses:(KDResponseWrapper *)response
                   completionBlock:(void (^)(NSDictionary *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *comments = nil;
        NSArray *bodyList = nil;
        NSInteger nextCursor;
        id info = nil;
        id body = [response responseAsJSONObject];
        if ([body isKindOfClass:[NSDictionary class]]) {
             bodyList = [(NSDictionary *)body objectNotNSNullForKey:@"comments"];
             nextCursor = [(NSDictionary *)body integerForKey:@"next_cursor"];
            if (bodyList != nil) {
                KDStatusParser *parser = [super parserWithClass:[KDStatusParser class]];
                comments = [parser parseAsCommentStatuses:bodyList];
            }
             info = [NSMutableDictionary dictionaryWithCapacity:2];
            if (comments != nil) {
                [info setObject:comments forKey:@"comments"];
            }
            [info setObject:@(nextCursor) forKey:@"nextCursor"];
        }else if ([body isKindOfClass:[NSArray class]]) {
            bodyList = body;
            if (bodyList != nil) {
                KDStatusParser *parser = [super parserWithClass:[KDStatusParser class]];
                comments = [parser parseAsCommentStatuses:bodyList];
            }
            info = comments;
        }
       // NSDictionary *body = [response responseAsJSONObject];
       
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(info);
        });
    });
}

- (void)_asyncParseUserTimelineStatuses:(KDResponseWrapper *)response
                        completionBlock:(void (^)(NSDictionary *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *statuses = nil;
        
        id body = [response responseAsJSONObject];
        NSArray *bodyList =  nil;
        NSInteger nextCursor = -1;
        if ([body isKindOfClass:[NSDictionary class]]) {
            bodyList = [body objectNotNSNullForKey:@"statuses"];
            nextCursor = [body integerForKey:@"next_cursor"];
        }else if([body isKindOfClass:[NSArray class]]) {
            bodyList = body;
        }
        if (bodyList != nil) {
            KDStatusParser *parser = [super parserWithClass:[KDStatusParser class]];
            statuses = [parser parseAsStatuses:bodyList type:KDTLStatusTypeUndefined];
        }
        
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
        if (statuses != nil) {
            [info setObject:statuses forKey:@"statuses"];
        }
        if (nextCursor != -1) {
            [info setObject:@(nextCursor) forKey:@"nextCursor"];
        }
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(info);
        });
    });
}
// parse the user's friends and followers from response
- (void)_asyncParseUsers:(KDResponseWrapper *)response completionBlock:(void (^)(NSDictionary *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *users = nil;
        NSInteger nextCursor = -1;
        NSArray *bodyList = nil;
        id body = [response responseAsJSONObject];
        if([body isKindOfClass:[NSDictionary class]]) {
             bodyList = [(NSDictionary *)body objectNotNSNullForKey:@"users"];
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
        if (-1 != nextCursor) {
            [info setObject:@(nextCursor) forKey:@"nextCursor"];
        }
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(info);
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
