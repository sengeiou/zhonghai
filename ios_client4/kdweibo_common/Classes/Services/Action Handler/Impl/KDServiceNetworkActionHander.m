//
//  KDServiceNetworkActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceNetworkActionHander.h"

#define KD_SERVICE_NETWORK_ACTION_PATH	@"/network/"

@implementation KDServiceNetworkActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_NETWORK_ACTION_PATH;
}

- (void)list:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"network/list.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 NSArray *communities = [self _parseCommunities:response];
                 [super didFinishInvoker:invoker results:communities request:request response:response];
             }];
}

- (void)selectByDomain:(KDServiceActionInvoker *)invoker {
    
}

// MARK: 新退出工作圈流程--当用户是工作圈管理员的时候, 是否需要指定接任管理员的人选接口
- (void)isNeedNextAdmin:(KDServiceActionInvoker *)invoker
{
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY
                 serviceURL:@"team/isNeedNextAdmin.json"];
    [super doGet:invoker
      configBlock:nil
 didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed)
    {
     id result = [response responseAsJSONObject];
     [super didFinishInvoker:invoker results:result request:request response:response];
    }];
}


- (void)teamSignOut:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"team/sign-out.json"];
    
    [super doPost:invoker
      configBlock:nil
 didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    id result = [response responseAsJSONObject];
    [super didFinishInvoker:invoker results:result request:request response:response];
}];

}
//获取收到的加入团队邀请
- (void)teamInvitations:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"team/list/inviteed-teams.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 NSArray *communities = [self _parseCommunitiesWithErrorCode:response];
                 [super didFinishInvoker:invoker results:communities request:request response:response];
             }];
}

//申请加入团队
- (void)applyJoinTeam:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"team/apply-join-team.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed){
                 id result = [response responseAsJSONObject];
                 
                 [super didFinishInvoker:invoker results:result request:request response:response];
             }];
}

//（忽略团队/接受邀请加入团队）
- (void)processTeamInvitation:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"team/accept-inviteing.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 id msg = [response responseAsJSONObject];
                 
                 [super didFinishInvoker:invoker results:msg request:request response:response];
             }];
}

//创建团队
- (void)createTeam:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"team/create.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 id result = [response responseAsJSONObject];
                 
                 [super didFinishInvoker:invoker results:result request:request response:response];
             }];
}

//搜索团队
- (void)searchTeam:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"team/search.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 NSArray *communities = [self _parseCommunitiesWithErrorCode:response];
                 [super didFinishInvoker:invoker results:communities request:request response:response];
             }];
}

//撤销申请（加入团队）
- (void)cancelApplying:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"team/cancel-applying.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 id result = [response responseAsJSONObject];
                 
                 [super didFinishInvoker:invoker results:result request:request response:response];
             }];
}

//申请中的团队列表
- (void)applyingTeams:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"team/list/applying-join-teams.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 NSArray *list = [self _parseCommunitiesWithErrorCode:response];
                 
                 [super didFinishInvoker:invoker results:list request:request response:response];
    }];
}

//邀请加入团队
- (void)inviteToTeam:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"team/invite.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 id result = nil;
                 
                 NSDictionary *dic = [response responseAsJSONObject];
                 if(dic) {
                     NSArray *data = [dic objectForKey:@"data"];
                     if(data && [data isKindOfClass:[NSArray class]] && data.count > 0) {
                         KDCompositeParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDCompositeParser class]];
                         result = [parser parseAsABRecord:data];
                     }
                 }
                 
                 [super didFinishInvoker:invoker results:result request:request response:response];
             }];
}

- (void)getInvitationURL:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"invite/getShortLink.json"];
    
    [super doGet:invoker configBlock:nil
      didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
           // NSArray *communities = [self _parseCommunities:response];
          // [super didFinishInvoker:invoker results:communities request:request response:response];
          
          id result = nil;
          
          NSDictionary *dic = [response responseAsJSONObject];
          if(dic) {
              NSDictionary *data = [dic objectForKey:@"data"];
              result = data;
          }
         [super didFinishInvoker:invoker results:result request:request response:response];

     }];
    

}
- (void)getInvitePersonInfo:(KDServiceActionInvoker *)invoker {
    
    [super doGet:invoker configBlock:nil
didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    
    id result = [response responseAsJSONObject];
    
    [super didFinishInvoker:invoker results:result request:request response:response];
    
}];
    
    
}

//获取团队列表
- (void)tree_list:(KDServiceActionInvoker *)invoker
{
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"network/tree_list.json"];
    
    [super doGet:invoker configBlock:nil
didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    NSArray *communities = [self _parseCommunities:response];
    [super didFinishInvoker:invoker results:communities request:request response:response];
}];
    
    
}

- (NSArray *)_parseCommunities:(KDResponseWrapper *)response {
    if (![response isValidResponse]) return nil;

    NSArray *communities = nil;
    NSArray *bodyList = [response responseAsJSONObject];
    if (bodyList != nil) {
        KDCompositeParser *parser = [super parserWithClass:[KDCompositeParser class]];
        communities = [parser parseAsCommunities:bodyList];
    }
    
    return communities;
}

- (NSArray *)_parseCommunitiesWithErrorCode:(KDResponseWrapper *)response {
    if (![response isValidResponse]) return nil;
    
    NSArray *communities = nil;
    NSArray *bodyList = [(NSDictionary *)[response responseAsJSONObject] objectForKey:@"data"];
    if (bodyList != nil && ![bodyList isKindOfClass:[NSNull class]]) {
        KDCompositeParser *parser = [super parserWithClass:[KDCompositeParser class]];
        communities = [parser parseAsCommunities:bodyList];
    }
    
    return communities;
}

@end
