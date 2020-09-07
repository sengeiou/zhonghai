//
//  KDWeiboLoginService.m
//  kdweibo
//
//  Created by bird on 14-4-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDWeiboLoginService.h"
#import "KDManagerContext.h"
#import "KDWeiboServicesContext.h"
#import "KDSession.h"
#import "KDDatabaseHelper.h"
#import "KDDBManager.h"
#import "KDWeiboServicesContext.h"
#import "KDXAuthAuthorization.h"
#import "KDWeiboGlobals.h"
#import "KDCacheUtlities.h"
#import "KDUtility.h"

@implementation KDWeiboLoginService

+ (void)verifyAccount_finishBlock:(KDWeiboLoginFinishedBlock)block {
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if(results != nil){
            KDUser *user = results;
            
            [KDManagerContext globalManagerContext].userManager.currentUser = user;
            [KDManagerContext globalManagerContext].userManager.currentUserId = user.userId;
            [KDManagerContext globalManagerContext].userManager.currentUserCompanyDomain = user.domain;
            
            [[KDManagerContext globalManagerContext].userManager storeUserData];
            
            [[KDManagerContext globalManagerContext].APNSManager registerForRemoteNotification];
            
            
            
            if (Test_Environment) {
                if (block) {
                    block(YES, nil);
                }
            }else {
                [self listJoinedCommunities_finishBlock:block];
            }
            
        } else {
            
            NSString *message = nil;
            if(![response isCancelled]){
                // verify account did failed
                message = NSLocalizedString(@"VERIFY_ACCOUNT_DID_FAIL", @"");
            }
            
            if (block)
                block(FALSE,message);
        }
    };
    
    NSString *actionPath = @"/account/:verifyCredentials";
    [KDServiceActionInvoker invokeWithSender:nil actionPath:actionPath query:nil
                                 configBlock:nil completionBlock:completionBlock];
}

+ (void)listJoinedCommunities_finishBlock:(KDWeiboLoginFinishedBlock)block {
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                NSArray *communities = results;
                
                // Generally speaking, the communities count always more than one,
                // But may be parse json has some problems
                if(communities != nil && [communities count] > 0){
                    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
                    
                    
                    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
                    
                    [communityManager updateWithCommunities:communities currentDomain:userManager.currentUserCompanyDomain];
                    
                    [communityManager storeCommunities];
                    
                    // check did connected to current community yet
                    if (![[KDDBManager sharedDBManager] isConnectingWithCommunity:communityManager.currentCommunity.communityId]) {
                        // connect to current community
                        [communityManager connectToCommunity:nil];
                    }
                    //必须要在这里保存，因为此时数据库才建立。。
                    KDUser *currentUser = userManager.currentUser;
                    userManager.currentUser = nil;
                    userManager.currentUser = currentUser;
                    
                    [userManager storeUserData];
                    
                    // register remote notification
                    [[KDManagerContext globalManagerContext].APNSManager registerForRemoteNotification];
                    
                    // set user is signing flag
                    [[KDSession globalSession] setProperty:[NSNumber numberWithBool:YES] forKey:KD_PROP_USER_IS_SIGNING_KEY];
                    
                    if (block)
                    {
                        block(TRUE, nil);
                        return ;
                    }
                    
                }
            }
        } else {
            
            NSString *message = nil;
            if(![response isCancelled]) {
                message = [response.responseDiagnosis networkErrorMessage];
            }
            if (block)
            {
                block(FALSE, message);
                return;
            }
        }
        if (block)
            block(FALSE, nil);
        
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/network/:list" query:nil
                                 configBlock:nil completionBlock:completionBlock];
}

+ (void)signInToken:(KDAuthToken *)authToken finishBlock:(KDWeiboLoginFinishedBlock)block
{
    if (authToken == nil) block(false, nil);
    
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    userManager.accessToken = authToken;
    [userManager updateAuthorizationForServicesContext];
    
    [self verifyAccount_finishBlock:block];
}

+ (void)signInUser:(NSString *)username  password:(NSString *)password finishBlock:(KDWeiboLoginFinishedBlock)block{
    
    if(username == nil || [username length] < 1 || password == nil || [password length] < 1)
    {
        if (block)
            block(false, nil);
        return;
    }
    
    // to make username case insensitive see jira issue KSSP-7722
    username = [username lowercaseString];
    
    KDXAuthAuthorization *genericAuth = [KDXAuthAuthorization xAuthorizationWithAccessToken:nil];
    [[[KDWeiboServicesContext defaultContext] getKDWeiboServices] updateAuthorization:genericAuth];
    
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"x_auth_username" stringValue:username]
      setParameter:@"x_auth_password" stringValue:password]
     setParameter:@"x_auth_mode" stringValue:@"client_auth"];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        KDAuthToken *authToken = nil;
        if (results != nil) {
            authToken = results;
        }
        
        if (authToken != nil) {
            // bind access auth token
            KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
            userManager.accessToken = authToken;
            [userManager updateAuthorizationForServicesContext];
            
            [self verifyAccount_finishBlock:block];
        }
        else
        {
            if (block)
                block(false, nil);
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/auth/:accessToken" query:query
                                 configBlock:nil completionBlock:completionBlock];
}
+ (void)thirdPartAuthorize_finishBlock:(KDWeiboLoginFinishedBlock)block {
    
    KDQuery *query = [[KDSession globalSession] propertyForKey:KD_PROP_3RD_AUTH_QUERY_KEY];
    
    NSString *token = [query genericParameterForName:@"third_token"];
    NSString *userName = [query genericParameterForName:@"user_name"];
    NSString *password = [query genericParameterForName:@"password"];
    if (token!=nil && [token length] >0) {
        NSLog(@"SSO use weblogin token [%@]", token);
        [self thirdPartAuthorize:token finishBlock:block];
    }else if(userName!=nil && [userName length] >0){
        NSLog(@"SSO use userName [%@], password [%@]",userName, password);
        [self signInUser:userName password:password finishBlock:block];
    }else {
        NSLog(@"Not login use sso.");
    }
    
}

+ (void)thirdPartAuthorize:(NSString*)token finishBlock:(KDWeiboLoginFinishedBlock)block{
    
    KDXAuthAuthorization *genericAuth = [KDXAuthAuthorization xAuthorizationWithAccessToken:nil];
    [[[KDWeiboServicesContext defaultContext] getKDWeiboServices] updateAuthorization:genericAuth];
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"ex_auth_logintoken" stringValue:token]
     setParameter:@"ex_auth_mode" stringValue:@"exchange_auth"];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        KDAuthToken *authToken = nil;
        if([response isValidResponse]){
            NSString *responseString = [response responseAsString];
            authToken = [KDAuthToken authTokenWithString:responseString];
        }
        
        if (authToken != nil) {
            // bind access auth token
            KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
            userManager.accessToken = authToken;
            [userManager updateAuthorizationForServicesContext];
            
            [self verifyAccount_finishBlock:block];
            
        } else {
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/auth/:accessToken" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

+ (void)clearLocalCacheWithFinishedBlock:(void (^) (BOOL success, NSError *error))block
{
  
}

+ (void)signOut
{
    NSLog(@"call %s", __func__);
    
    [[KDWeiboGlobals defaultWeiboGlobals] signOut];
}
@end
