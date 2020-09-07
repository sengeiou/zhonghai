//
//  KDTeamRequestHelper.m
//  kdweibo
//
//  Created by shen kuikui on 13-11-8.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTeamRequestHelper.h"
#import "KDWeiboServices.h"
#import "KDManagerContext.h"
#import "KDServiceActionInvoker.h"
#import "KDWeiboServicesContext.h"


@implementation KDTeamRequestHelper

+ (id)sharedTeamRequestHelper
{
    static KDTeamRequestHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KDTeamRequestHelper alloc] init];
    });
    
    return sharedInstance;
}

- (void)fetchTeamInvitationWithFinishedBlock:(KDTeamRequestFinishedBlock)block
{
    KDQuery *query = [KDQuery query];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if(block) {
            block(results);
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:self
                                  actionPath:@"/network/:teamInvitations"
                                       query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)fetchMyApplyingTeamWithFinishedBlock:(KDTeamRequestFinishedBlock)block
{
    KDQuery *query = [KDQuery query];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if(block) {
            block(results);
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:self
                                  actionPath:@"/network/:applyingTeams"
                                       query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)fetchAllMyTeamsWithFinishedBlock:(KDTeamRequestFinishedBlock)block
{
    KDQuery *query = [KDQuery query];
    //TODO:add team memebers.
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if(block) {
            block(results);
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:self
                                  actionPath:@"/network/:tree_list"
                                       query:query
                                 configBlock:nil completionBlock:completionBlock];
}

@end
