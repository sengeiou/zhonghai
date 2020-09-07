//
//  KDServiceAccountActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceAccountActionHander.h"
#import "KDCacheUtlities.h"

#define KD_SERVICE_ACCOUNT_ACTION_PATH	@"/account/"

@implementation KDServiceAccountActionHander

// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_ACCOUNT_ACTION_PATH;
}
- (void)cloudPassport:(KDServiceActionInvoker *)invoker{
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE
                 serviceURL:@"passport/cloudPassport.json"];
    
    [super doPost:invoker configBlock:nil
   didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
       if ([response isValidResponse]) {
           NSDictionary *info = [response responseAsJSONObject];
           if (info != nil) {
               NSString *cloudPassport =[info valueForKey:@"cloudpassport"];
               [super didFinishInvoker:invoker results:cloudPassport request:request response:response];
           }
       }
 }];
}
- (void)updateProfile:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY
                 serviceURL:@"account/update_profile.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDUser *user = [self _parseAsUser:response];
                 [super didFinishInvoker:invoker results:user request:request response:response];
             }];
}

- (void)updateProfileImage:(KDServiceActionInvoker *)invoker  {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY
                 serviceURL:@"account/update_profile_image.json"];
    
    [super doPost:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDUser *user = [self _parseAsUser:response];
                 [super didFinishInvoker:invoker results:user request:request response:response];
             }];
}

- (void)verifyCredentials:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE
                 serviceURL:@"account/verify_credentials.json"];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDUser *user = [self _parseAsUser:response];
                 [super didFinishInvoker:invoker results:user request:request response:response];
             }];
}

- (void)verifyCredentialsWithDomain:(KDServiceActionInvoker *)invoker {
    NSString *domain = [invoker.query genericParameterForName:@"domain_name"];
    NSString *suffix = [NSString stringWithFormat:@"%@/account/verify_credentials.json", domain];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE
                 serviceURL:suffix];
    
    [super doGet:invoker configBlock:nil
             didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                 KDUser *user = [self _parseAsUser:response];
                 [super didFinishInvoker:invoker results:user request:request response:response];
             }];
}

- (void)accountAvatar:(KDServiceActionInvoker *)invoker {
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

- (KDUser *)_parseAsUser:(KDResponseWrapper *)response {
    KDUser *user = nil;
    if ([response isValidResponse]) {
        NSDictionary *info = [response responseAsJSONObject];
        if (info != nil) {
            KDUserParser *parser = [self parserWithClass:[KDUserParser class]];
            user = [parser parse:info withStatus:NO];
        }
    }
    
    return user;
}

#pragma mark
#pragma makr 注册相关

/**
 *  使用邮箱重设密码
 *
 *  @param invoker 保含了 email
 */
- (void)resetPassordWithEmail:(KDServiceActionInvoker *)invoker {
    
    NSString *serviceURL = @"public/email-find-passwd.json";
    [invoker configWithMask:KD_INVOKER_MASK_BASE serviceURL:serviceURL];
    [invoker.query setParameter:@"email" stringValue:[invoker.query propertyForKey:@"email"]];
    
    [super doPost:invoker configBlock:nil
 didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
     NSDictionary *result = nil;
     if ([response isValidResponse]) {
         NSDictionary *body = [response responseAsJSONObject];
         if (body != nil) {
             result = body;
         }
     }
     [super didFinishInvoker:invoker results:result request:request response:response];
 }];
}

/**
 *  向指定手机发送验证码
 *
 *  @param invoker
 */
- (void)getCodeWithPhone:(KDServiceActionInvoker *)invoker {
    
    NSString *serviceURL = @"public/mobile-find-passwd.json";
    
    
    NSNumber *type = [invoker.query propertyForKey:@"type"];
    //注册时发送短信
    if ([type isEqual:@(0)]) {
        serviceURL = @"public/apply-regist.json";
    }
    
    [invoker configWithMask:KD_INVOKER_MASK_BASE serviceURL:serviceURL];
    [invoker.query setParameter:@"mobile" stringValue:[invoker.query propertyForKey:@"mobile"]];
    
    [super doPost:invoker configBlock:nil
 didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
     NSDictionary *result = nil;
     if ([response isValidResponse]) {
         NSDictionary *body = [response responseAsJSONObject];
         if (body != nil) {
             result = body;
         }
     }
     [super didFinishInvoker:invoker results:result request:request response:response];
 }];
}

/**
 *  验证code有效性
 *
 *  @param invoker
 */
- (void)verifyCodeWithSerial:(KDServiceActionInvoker *)invoker {
    
    NSString *serviceURL = @"public/validate-code.json";
    
    NSString *type = [invoker.query propertyForKey:@"type"];
    //注册时发送短信
    if ([type isEqual:@(0)]) {
        serviceURL = @"public/regist.json";
        [invoker.query setParameter:@"x" stringValue:[invoker.query propertyForKey:@"x"]];
    }
    
    [invoker configWithMask:KD_INVOKER_MASK_BASE serviceURL:serviceURL];
    [invoker.query setParameter:@"vcode" stringValue:[invoker.query propertyForKey:@"vcode"]];
    [invoker.query setParameter:@"serial" stringValue:[invoker.query propertyForKey:@"serial"]];
    
    [super doPost:invoker configBlock:nil
 didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
     NSDictionary *result = nil;
     if ([response isValidResponse]) {
         NSDictionary *body = [response responseAsJSONObject];
         if (body != nil) {
             result = body;
         }
     }
     [super didFinishInvoker:invoker results:result request:request response:response];
 }];
}

- (void)resetAccountPassword:(KDServiceActionInvoker *)invoker {
    
    NSString *serviceURL = @"public/reset-passwd.json";
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:serviceURL];
    [invoker.query setParameter:@"password" stringValue:[invoker.query propertyForKey:@"password"]];
    [invoker.query setParameter:@"serial" stringValue:[invoker.query propertyForKey:@"serial"]];
    [invoker.query setParameter:@"token" stringValue:[invoker.query propertyForKey:@"token"]];
    
    [super doPost:invoker configBlock:nil
 didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
     NSDictionary *result = nil;
     if ([response isValidResponse]) {
         NSDictionary *body = [response responseAsJSONObject];
         if (body != nil) {
             result = body;
         }
     }
     [super didFinishInvoker:invoker results:result request:request response:response];
 }];
}

- (void)setPassword:(KDServiceActionInvoker *)invoker {
    
    NSString *serviceURL = @"users/set_passwd.json";
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:serviceURL];
    [invoker.query setParameter:@"passwd" stringValue:[invoker.query propertyForKey:@"password"]];
    
    [super doPost:invoker configBlock:nil
 didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
     NSDictionary *result = nil;
     if ([response isValidResponse]) {
         NSDictionary *body = [response responseAsJSONObject];
         if (body != nil) {
             result = body;
         }
     }
     [super didFinishInvoker:invoker results:result request:request response:response];
 }];
}

- (void)checkHasSetPassword:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_BASE serviceURL:@"users/check_has_set_password.json"];
    
    [super doGet:invoker configBlock:nil
didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    NSDictionary *result = nil;
    if ([response isValidResponse]) {
        NSDictionary *body = [response responseAsJSONObject];
        if (body != nil) {
            result = body;
        }
    }
    [super didFinishInvoker:invoker results:result request:request response:response];
}];
}

@end
