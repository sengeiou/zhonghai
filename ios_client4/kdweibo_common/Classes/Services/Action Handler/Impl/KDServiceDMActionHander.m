//
//  KDServiceDMActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceDMActionHander.h"

#define KD_SERVICE_DM_ACTION_PATH	@"/dm/"

@implementation KDServiceDMActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_DM_ACTION_PATH;
}

- (void)addParticipant:(KDServiceActionInvoker *)invoker {
    NSString *threadId = [invoker.query propertyForKey:@"threadId"];
    NSString *serviceURL = [NSString stringWithFormat:@"direct_messages/thread/%@/add_participant.json", threadId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        KDDMThread *thread = nil;
        if ([response isValidResponse]) {
            NSDictionary *body = [response responseAsJSONObject];
            if (body != nil) {
                KDDMThreadParser *parser = [super parserWithClass:[KDDMThreadParser class]];
                NSArray *items = [parser parse:@[body]];
                if (items != nil && [items count] > 0) {
                    thread = items[0];
                }
            }
        }
        
        [super didFinishInvoker:invoker results:thread request:request response:response];
    }];
}

- (void)deleteParticipant:(KDServiceActionInvoker *)invoker {
    NSString *threadId = [invoker.query propertyForKey:@"threadId"];
    NSString *serviceURL = [NSString stringWithFormat:@"direct_messages/kick_participant/%@.json", threadId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        NSDictionary *body  = nil;
        NSNumber *result = nil;
        if ([response isValidResponse]) {
            body = [response responseAsJSONObject];
            if (body) {
                result = @([body boolForKey:@"result" defaultValue:NO]);
            }
        }
        [super didFinishInvoker:invoker results:result request:request response:response];
    }];
}

- (void)quitThread:(KDServiceActionInvoker *)invoker {
    NSString *threadId = [invoker.query propertyForKey:@"threadId"];
    NSString *serviceURL = [NSString stringWithFormat:@"direct_messages/quit_thread/%@.json", threadId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        NSDictionary *body  = nil;
        NSNumber *result = nil;
        if ([response isValidResponse]) {
            body = [response responseAsJSONObject];
            if (body) {
                result = @([body boolForKey:@"result" defaultValue:NO]);
            }
        }
        [super didFinishInvoker:invoker results:result request:request response:response];
    }];
    
}

- (void)dm:(KDServiceActionInvoker *)invoker {
    
}

- (void)newMessage:(KDServiceActionInvoker *)invoker {
    
}

- (void)more:(KDServiceActionInvoker *)invoker {
    
}

- (void)newMulti:(KDServiceActionInvoker *)invoker {
    BOOL hasAttachments = [[invoker.query propertyForKey:@"hasAttachments"] boolValue];
    
    if (hasAttachments) {
        [self upload:invoker];
        
    } else {
        [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"direct_messages/new_multi.json"];
        
        [super doPost:invoker configBlock:nil
     didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
         DLog(@"successs...");
         KDDMMessage *message = [self _parseAsDMMessage:response];
         [super didFinishInvoker:invoker results:message request:request response:response];
     }];
    }
}

- (void)reply:(KDServiceActionInvoker *)invoker {
    
}

- (void)sent:(KDServiceActionInvoker *)invoker {
    
}

- (void)upload:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"direct_messages/upload.json"];
    
    [super doTransfer:invoker isGet:NO configBlock:nil
     didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
         KDDMMessage *message = [self _parseAsDMMessage:response];
         [super didFinishInvoker:invoker results:message request:request response:response];
     }];
}

- (void)threadById:(KDServiceActionInvoker *)invoker {
    NSString *threadId = [invoker.query genericParameterForName:@"threadId"];
    NSString *serviceURL = [NSString stringWithFormat:@"direct_messages/thread/%@.json", threadId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doGet:invoker
     configBlock:nil
     didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    KDDMThread *thread = nil;
    if([response isValidResponse]) {
        NSDictionary *dic = response.responseAsJSONObject;
        KDDMThreadParser *parser = [super parserWithClass:[KDDMThreadParser class]];
        thread = [parser parseSingle:dic];
    }
    [super didFinishInvoker:invoker results:thread request:request response:response];
   }];
}

- (void)deleteThreadById:(KDServiceActionInvoker *)invoker {
    NSString *threadId = [invoker.query genericParameterForName:@"threadId"];
    NSString *serviceURL = [NSString stringWithFormat:@"direct_messages/delete_thread/%@.json",threadId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doPost:invoker
      configBlock:nil
 didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
     NSDictionary *dic = nil;
     if([response isValidResponse]) {
         dic = response.responseAsJSONObject;
     }
     [super didFinishInvoker:invoker results:dic request:request response:response];
 }];
}

- (void)topThreadById:(KDServiceActionInvoker *)invoker {
    NSString *threadId = [invoker.query genericParameterForName:@"threadId"];
    NSString *serviceURL = [NSString stringWithFormat:@"direct_messages/top_thread/%@.json",threadId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doPost:invoker
      configBlock:nil
 didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
     NSDictionary *dic = nil;
     if([response isValidResponse]) {
         dic = response.responseAsJSONObject;
     }
     [super didFinishInvoker:invoker results:dic request:request response:response];
 }];
}

- (void)cancelTopThreadById:(KDServiceActionInvoker *)invoker {
    NSString *threadId = [invoker.query genericParameterForName:@"threadId"];
    NSString *serviceURL = [NSString stringWithFormat:@"direct_messages/cancel_top_thread/%@.json",threadId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doPost:invoker
      configBlock:nil
 didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
     NSDictionary *dic = nil;
         if([response isValidResponse]) {
        dic = response.responseAsJSONObject;
         }
     [super didFinishInvoker:invoker results:dic request:request response:response];
 }];
}
- (void)threadByIdAddParticipant:(KDServiceActionInvoker *)invoker {
    
}

- (void)threadMessages:(KDServiceActionInvoker *)invoker {
    NSString *threadId = [invoker.query genericParameterForName:@"threadId"];
    NSString *serviceURL = [NSString stringWithFormat:@"direct_messages/thread/%@/messages.json", threadId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doGet:invoker configBlock:nil
didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    [self _asyncParseDMMessages:response
                completionBlock:^(NSArray *messages){
                    [super didFinishInvoker:invoker results:messages request:request response:response];
                }];
}];
}

- (void)threadByIdNewMessage:(KDServiceActionInvoker *)invoker {
    BOOL hasAttachments = [[invoker.query propertyForKey:@"hasAttachments"] boolValue];
    if (hasAttachments) {
        [self upload:invoker];
        
    } else {
        NSString *threadId = [invoker.query propertyForKey:@"threadId"];
        NSString *serviceURL = [NSString stringWithFormat:@"direct_messages/thread/%@/new_msg.json", threadId];
        
        [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
        
        [super doPost:invoker configBlock:nil
     didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
         KDDMMessage *message = [self _parseAsDMMessage:response];
         [super didFinishInvoker:invoker results:message request:request response:response];
     }];
    }
}

- (void)threads:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"direct_messages/threads.json"];
    
    [super doGet:invoker configBlock:nil
didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    [self _asyncParseThreads:response
             completionBlock:^(NSDictionary *info){
                 [super didFinishInvoker:invoker results:info request:request response:response];
             }];
}];
}

- (void)topThreads:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"direct_messages/threads_top.json"];
    
    [super doGet:invoker configBlock:nil
didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    [self _asyncParseTopThreads:response
                completionBlock:^(NSDictionary *info){
                    [super didFinishInvoker:invoker results:info request:request response:response];
                }];
  }];
}

- (void)threadParticipants:(KDServiceActionInvoker *)invoker {
    NSString *threadId = [invoker.query propertyForKey:@"threadId"];
    NSString *serviceURL = [NSString stringWithFormat:@"direct_messages/thread/%@.json", threadId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doGet:invoker configBlock:nil
    didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    [self _asyncParseThreadParticipants:response
                        completionBlock:^(id results){
                            [super didFinishInvoker:invoker results:results request:request response:response];
                        }];
}];
}

- (void)threadsMore:(KDServiceActionInvoker *)invoker {
    
}

- (void)threadsNew:(KDServiceActionInvoker *)invoker {
    
}

- (void)updateSubject:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"direct_messages/update_subject.json"];
    
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


////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (KDDMMessage *)_parseAsDMMessage:(KDResponseWrapper *)response {
    KDDMMessage *m = nil;
    
    if ([response isValidResponse]) {
        NSDictionary *body = [response responseAsJSONObject];
        KDDMMessageParser *parser = [super parserWithClass:[KDDMMessageParser class]];
        m = [parser parseAsDMMessage:body];
    }
    
    return m;
}

- (void)_asyncParseDMMessages:(KDResponseWrapper *)response completionBlock:(void (^)(NSArray *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *messages = nil;
        
        NSArray *bodyList = [response responseAsJSONObject];
        if (bodyList != nil) {
            KDDMMessageParser *parser = [super parserWithClass:[KDDMMessageParser class]];
            messages = [parser parseAsDMMessageList:bodyList];
            
            // TODO: sort the dm messages if need
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(messages);
        });
    });
}

- (void)_asyncParseTopThreads:(KDResponseWrapper *)response completionBlock:(void (^)(NSDictionary *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        BOOL hasUnreadCount = NO;
        NSInteger unreadCount = 0;
        
        NSArray *threads = nil;
        NSArray *topThreads = nil;
        // if the request with time range limit (eg: since_time or max_time).
        // then the NSDictionary will be returned, if no with time range,
        // generally speaking. when retrieve direct message threads at first time,
        // then the NSArray will be returnd.
        id content = [response responseAsJSONObject];
        if (content != nil) {
            NSArray *bodyList = nil;
            NSArray *topList = nil;
            if ([content isKindOfClass:[NSDictionary class]]) {
                NSDictionary *body = (NSDictionary *)content;
                
                hasUnreadCount = YES;
                unreadCount = [body integerForKey:@"total_unread"];
                
                bodyList = [body objectNotNSNullForKey:@"threads"];
                topList = [body objectNotNSNullForKey:@"topThreads"];
            } else if ([content isKindOfClass:[NSArray class]]) {
                bodyList = content;
            }
            if (topList != nil) {
                KDDMThreadParser *parser = [super parserWithClass:[KDDMThreadParser class]];
                topThreads = [parser parseTop:topList];
            }
            if (bodyList != nil) {
                KDDMThreadParser *parser = [super parserWithClass:[KDDMThreadParser class]];
                threads = [parser parse:bodyList];
                
            }
        }
        
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:(hasUnreadCount ? 2 : 1)];
        //[info setObject:threads?threads:[NSNull null] forKey:@"threads"];
        if (threads) {
            [info setObject:threads forKey:@"threads"];
        }
        if (topThreads) {
            [info setObject:topThreads forKey:@"topThreads"];
        }
        
        if (hasUnreadCount) {
            [info setObject:@(unreadCount) forKey:@"unreads"];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(info);
        });
    });
}
- (void)_asyncParseThreads:(KDResponseWrapper *)response completionBlock:(void (^)(NSDictionary *))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        BOOL hasUnreadCount = NO;
        NSInteger unreadCount = 0;
        
        NSArray *threads = nil;
        
        // if the request with time range limit (eg: since_time or max_time).
        // then the NSDictionary will be returned, if no with time range,
        // generally speaking. when retrieve direct message threads at first time,
        // then the NSArray will be returnd.
        id content = [response responseAsJSONObject];
        if (content != nil) {
            NSArray *bodyList = nil;
            
            if ([content isKindOfClass:[NSDictionary class]]) {
                NSDictionary *body = (NSDictionary *)content;
                
                hasUnreadCount = YES;
                unreadCount = [body integerForKey:@"total_unread"];
                
                bodyList = [body objectNotNSNullForKey:@"threads"];
                
            } else if ([content isKindOfClass:[NSArray class]]) {
                bodyList = content;
            }
            
            if (bodyList != nil) {
                KDDMThreadParser *parser = [super parserWithClass:[KDDMThreadParser class]];
                threads = [parser parse:bodyList];
            }
        }
        
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:(hasUnreadCount ? 2 : 1)];
        //[info setObject:threads?threads:[NSNull null] forKey:@"threads"];
        if (threads) {
            [info setObject:threads forKey:@"threads"];
        }
        
        if (hasUnreadCount) {
            [info setObject:@(unreadCount) forKey:@"unreads"];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(info);
        });
    });
}

- (void)_asyncParseThreadParticipants:(KDResponseWrapper *)response completionBlock:(void (^)(id))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *users = nil;
        
        NSDictionary *body = [response responseAsJSONObject];
        id thread = [NSNull null];
        
        NSArray *bodyList = [body objectNotNSNullForKey:@"participants"];
        NSDictionary *returnDic = nil;
        if (bodyList != nil) {
            KDDMThreadParser *threadParser = [super parserWithClass:[KDDMThreadParser class]];
            thread = [threadParser parseSingle:body];
            KDUserParser *userParser = [super parserWithClass:[KDUserParser class]];
            users = [userParser parseAsUserListSimple:bodyList];
        }
        BOOL isMyThread = [body boolForKey:@"isMyThread" defaultValue:NO];
        returnDic = @{@"isMyThread": @(isMyThread),@"thread":thread, @"user":users?users:[NSNull null]};
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(returnDic);
        });
    });
}

@end
