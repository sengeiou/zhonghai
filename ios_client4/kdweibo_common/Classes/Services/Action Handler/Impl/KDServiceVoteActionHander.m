//
//  KDServiceVoteActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceVoteActionHander.h"

#define KD_SERVICE_VOTE_ACTION_PATH	@"/vote/"

@implementation KDServiceVoteActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_VOTE_ACTION_PATH;
}

- (void)resultById:(KDServiceActionInvoker *)invoker {
    NSString *voteId = [invoker.query propertyForKey:@"voteId"];
    NSString *serviceURL = [NSString stringWithFormat:@"vote/result/%@.json", voteId];
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 NSMutableDictionary *info = nil;
                 if ([response isValidResponse]) {
                     KDVote *vote = nil;
                     NSDictionary *body = [response responseAsJSONObject];
                     if (body != nil) {
                         int code = [body intForKey:@"code"];
                         
                         KDVoteParser *parser = [super parserWithClass:[KDVoteParser class]];
                         vote = [parser parse:body];
                         
                         info = [NSMutableDictionary dictionaryWithCapacity:2];
                         
                         if (vote != nil) {
                             [info setObject:vote forKey:@"vote"];
                         }
                         
                         [info setObject:@(code) forKey:@"code"];
                     }
                     
                 }
                 // execute callback if need
                 [super didFinishInvoker:invoker results:info request:request response:response];
             }];
}

- (void)vote:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"vote/vote.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 BOOL success = ([response isValidResponse]) ? YES : NO;
                 [super didFinishInvoker:invoker results:@(success) request:request response:response];
             }];
}

- (void)share:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"vote/share.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 BOOL success = ([response isValidResponse]) ? YES : NO;
                 [super didFinishInvoker:invoker results:@(success) request:request response:response];
             }];
}
- (void)voteLatest:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"vote/last.json"];
    [super doGet:invoker configBlock:nil
      didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    // NSArray *communities = [self _parseCommunities:response];
    NSMutableArray *lastestVotes = [NSMutableArray array];
    if ([response isValidResponse]) {
        NSArray *result = [response responseAsJSONObject];
        
        KDVote *vote = nil;
        KDVoteParser *parser = [super parserWithClass:[KDVoteParser class]];
        for (id obj in result){
            vote = [parser parse:obj];
            [lastestVotes addObject:vote];
        }
     }
       else {
        lastestVotes = nil;
    }
    [super didFinishInvoker:invoker results:lastestVotes request:request response:response];
    }];
}
@end
