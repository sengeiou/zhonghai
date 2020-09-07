//
//  KDWeiboServicesImpl.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDWeiboServicesImpl.h"

#import "KDRequestDispatcher.h"
#import "KDServiceActionInvoker.h"

#import "KDConfigurationContext.h"
#import "KDWeiboServicesContext.h"

#import "KDBasicAuthorization.h"
#import "KDDownload.h"
#import "KDImageSize.h"

#import "KDCacheUtlities.h"
#import "NSString+Additions.h"

#import "KDXAuthAuthorization.h"
#import "KDWeiboLoginService.h"
#import "KDManagerContext.h"
#import "KDDBManager.h"

@implementation KDWeiboServicesImpl

@synthesize authorization=authorization_;

@synthesize currentCommunityDomain=currentCommunityDomain_;

- (id)init {
    self = [super init];
    if(self){
        authorization_ = nil;
        
        currentCommunityDomain_ = nil;
    }
    
    return self;
}

- (id)initWithAuthorization:(id<KDAuthorization>)authorization {
    self = [super init];
    if(self){
        authorization_ = authorization ;//retain];
    }
    
    return self;
}

- (NSString *)getOAuthConsumerKey {
    return [[[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance] getOAuthConsumerKey];
}

- (NSString *)baseURL {
    return [[KDWeiboServicesContext defaultContext] serverBaseURL];
}

- (NSString *)baseSNSURL {
    return [[KDWeiboServicesContext defaultContext] serverSNSBaseURL];
}

- (NSString *)bindAppKeyWithSuffix:(NSString *)suffix {
    NSString *pattern = (suffix != nil) ? suffix : @"";
    NSRange range = [pattern rangeOfString:@"?" options:NSBackwardsSearch];
    pattern = [pattern stringByAppendingFormat:@"%@source=%@", ((NSNotFound == range.location) ? @"?" : @"&"), [self getOAuthConsumerKey]];
    
    return pattern;
}

- (NSString *)baseURLWithSuffix:(NSString *)suffix {
    return [NSString stringWithFormat:@"%@/%@", [self baseSNSURL], [self bindAppKeyWithSuffix:suffix]];
}

- (NSString *)communityURLWithSuffix:(NSString *)suffix {
    return [NSString stringWithFormat:@"%@/%@/%@", [self baseSNSURL], currentCommunityDomain_, [self bindAppKeyWithSuffix:suffix]];
}


//////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark authorization methods

- (void)updateAuthorization:(id<KDAuthorization>)authorization {
    self.authorization = authorization;
}

- (void)updateWithBasicAuthorization:(NSString *)identifer passcode:(NSString *)passcode {
    KDBasicAuthorization *basicAuthorization = [[KDBasicAuthorization alloc] initWithIdentifier:identifer password:passcode];
    self.authorization = basicAuthorization;
//    [basicAuthorization release];
}


//////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark build request wrapper methods

- (KDRequestWrapper *)buildRequestWrapper:(id<KDRequestWrapperDelegate>)delegate url:(NSString *)url
                                   method:(KDRequestMethod *)method parameters:(NSArray *)parameters
                           requestHeaders:(NSDictionary *)requestHeaders
                          completionBlock:(KDRequestWrapperDidCompleteBlock)completionBlock
                               identifier:(KDAPIIdentifer)identifier {
    
    KDRequestWrapper *requestWrapper = [[KDRequestWrapper alloc] initWithDelegate:delegate url:url method:method parameters:parameters requestHeaders:requestHeaders identifier:identifier] ;//autorelease];
    
    if(completionBlock != nil){
        requestWrapper.didCompleteBlock = completionBlock;
    }
    
    return requestWrapper;
}

- (KDRequestWrapper *)buildRequestWrapper:(id<KDRequestWrapperDelegate>)delegate url:(NSString *)url
                                   method:(KDRequestMethod *)method parameters:(NSArray *)parameters
                           requestHeaders:(NSDictionary *)requestHeaders identifier:(KDAPIIdentifer)identifier{
    
    return [self buildRequestWrapper:delegate url:url method:method parameters:parameters
                      requestHeaders:requestHeaders completionBlock:nil identifier:identifier];
}

- (KDRequestWrapper *)buildRequestWrapper:(id<KDRequestWrapperDelegate>)delegate url:(NSString *)url 
                                    method:(KDRequestMethod *)method parameters:(NSArray *)parameters 
                                identifier:(KDAPIIdentifer)identifier {
    
    return [self buildRequestWrapper:delegate url:url method:method
                          parameters:parameters requestHeaders:nil completionBlock:nil identifier:identifier];
}


- (void)bindUserInfoForImageRequest:(KDRequestWrapper *)requestWrapper imageSize:(KDImageSize *)size
                          cacheType:(KDCacheImageType)cacheType {
    [requestWrapper addUserInfoWithObject:size forKey:kKDImageScaleSizeKey];
    [requestWrapper addUserInfoWithObject:[NSNumber numberWithBool:YES] forKey:kKDIsRequestImageSourceKey];
    [requestWrapper addUserInfoWithObject:[NSNumber numberWithInteger:cacheType] forKey:kKDRequestImageCropTypeKey];
    [requestWrapper addUserInfoWithObject:[NSNumber numberWithBool:NO] forKey:KKDDownloadFinished];
    
    requestWrapper.isDownload = YES;
    requestWrapper.configBlock = ^(KDRequestWrapper *requestWrapper, ASIHTTPRequest *request){
        request.downloadDestinationPath = requestWrapper.downloadTemporaryPath;
    };
}

- (void)dispatch:(KDRequestWrapper *)requestWrapper type:(KDRequestDispatchType)type authNeed:(BOOL)authNeed communityNeed:(BOOL)communityNeed{
    
    if (authNeed) {
        requestWrapper.authorization = authorization_;
    }
    
    BOOL needDispath = YES;
    if (communityNeed) {
        
        if ([authorization_ getAuthorizationType] == KDAuthorizationTypeXAuth) {
            
            KDXAuthAuthorization *auth = (KDXAuthAuthorization *)authorization_;
            
            if (!auth || (!auth.accessToken || ![auth.accessToken isValid])) {
                
                needDispath = NO;
                KDWeiboLoginFinishedBlock block = ^(BOOL success, NSString *error)
                {
                    if(success) {
                        // set authorization if need
                        requestWrapper.authorization = authorization_;
                        [[KDRequestDispatcher globalRequestDispatcher] dispatch:requestWrapper type:type];
                 
                        NSString *eid = [[[KDManagerContext globalManagerContext] userManager].verifyCache objectNotNSNullForKey:@"eid"];
                        
                        [[KDDBManager sharedDBManager] tryConnectToCommunity:eid];
                        
                        KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
                        KDUser *currentUser = userManager.currentUser;
                        userManager.currentUser = nil;
                        userManager.currentUser = currentUser;

                    }
                    else
                    {
                        if (requestWrapper.delegate && [requestWrapper.delegate respondsToSelector:@selector(didDropRequestWrapper:error:)]) {
                            [requestWrapper.delegate didDropRequestWrapper:requestWrapper error:nil];
                        }
                        
                        KDResponseWrapper *responseWrapper = [[KDResponseWrapper alloc] initWithRequestWrapper:requestWrapper];// autorelease];
                        
                        // execute request wrapper block
                        if(requestWrapper.didCompleteBlock != nil){
                            requestWrapper.didCompleteBlock(requestWrapper, responseWrapper, YES);
                        }
                        
                    }
                    
                };
                
                NSString *userName = [[[KDManagerContext globalManagerContext] userManager].verifyCache objectNotNSNullForKey:@"userName"];
                NSString *password = [[[KDManagerContext globalManagerContext] userManager].verifyCache objectNotNSNullForKey:@"password"];
                [KDWeiboLoginService signInUser:userName password:password finishBlock:block];
            }
        }


    }
    
    if (needDispath) {
        
        [[KDRequestDispatcher globalRequestDispatcher] dispatch:requestWrapper type:type];
    }
}

- (void)doSend:(KDRequestWrapper *)requestWrapper authNeed:(BOOL)authNeed communityNeed:(BOOL)communityNeed{
    [self dispatch:requestWrapper type:KDRequestDispatchTypeSend authNeed:authNeed communityNeed:communityNeed];
}

- (void)doReceive:(KDRequestWrapper *)requestWrapper authNeed:(BOOL)authNeed communityNeed:(BOOL)communityNeed{
    [self dispatch:requestWrapper type:KDRequestDispatchTypeReceive authNeed:authNeed communityNeed:communityNeed];
}

- (void)doTransfer:(KDRequestWrapper *)requestWrapper authNeed:(BOOL)authNeed communityNeed:(BOOL)communityNeed{
    [self dispatch:requestWrapper type:KDRequestDispatchTypeTransfer authNeed:authNeed communityNeed:communityNeed];
}

- (void)doCancleTransferWithDlelete:(id<KDRequestWrapperDelegate>)delegate {
    [[KDRequestDispatcher globalRequestDispatcher] cancelTransferingRequestWithDelegate:delegate];
}

- (void)doCanleTransferWithAPIIdentifer:(KDAPIIdentifer)identifier {
    [[KDRequestDispatcher globalRequestDispatcher] cancelTransferingRequestWithAPIIdentifier:identifier];
}


///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark generic methods

- (void)doPost:(NSString *)url delegate:(id<KDRequestWrapperDelegate>)delegate authNeed:(BOOL)auth
        params:(NSArray *)params identifier:(KDAPIIdentifer)identifier
          usingBlock:(KDRequestWrapperDidCompleteBlock)block {
    KDRequestWrapper *requestWrapper = [self buildRequestWrapper:nil url:url method:[KDRequestMethod POST]
                                                      parameters:params identifier:identifier];
    requestWrapper.delegate = delegate;
    
    if (block != nil) {
        requestWrapper.didCompleteBlock = block;
    }
    
    [self doSend:requestWrapper authNeed:auth communityNeed:NO];
}

- (void)doGet:(NSString *)url delegate:(id<KDRequestWrapperDelegate>)delegate authNeed:(BOOL)authNeed
         params:(NSArray *)params identifier:(KDAPIIdentifer)identifier
         usingBlock:(KDRequestWrapperDidCompleteBlock)block {
    KDRequestWrapper *requestWrapper = [self buildRequestWrapper:nil url:url method:[KDRequestMethod GET]
                                                      parameters:params identifier:identifier];
    requestWrapper.delegate = delegate;
    
    if (block != nil) {
        requestWrapper.didCompleteBlock = block;
    }
    
    [self doSend:requestWrapper authNeed:authNeed communityNeed:NO];
}

- (void)doCommunityServicePost:(NSString *)urlSuffix delegate:(id<KDRequestWrapperDelegate>)delegate params:(NSArray *)params identifier:(KDAPIIdentifer)identifier usingBlock:(KDRequestWrapperDidCompleteBlock)block {
    
    NSString *url = [self communityURLWithSuffix:urlSuffix];
    [self doPost:url delegate:delegate authNeed:YES params:params
            identifier:identifier usingBlock:block];
}

- (void)doCommunityServiceGet:(NSString *)urlSuffix delegate:(id<KDRequestWrapperDelegate>)delegate
                       params:(NSArray *)params identifier:(KDAPIIdentifer)identifier
                   usingBlock:(KDRequestWrapperDidCompleteBlock)block {
    
    NSString *url = [self communityURLWithSuffix:urlSuffix];
    [self doGet:url delegate:delegate authNeed:YES params:params
            identifier:identifier usingBlock:block];
}

- (KDRequestWrapper *)toRequestWrapper:(KDServiceActionInvoker *)invoker
                                 isGet:(BOOL)isGet
                            usingBlock:(KDRequestWrapperDidCompleteBlock)block {
    
    KDRequestMethod *method = isGet ? [KDRequestMethod GET] : [KDRequestMethod POST];
    NSArray *params = [invoker.query toRequestParameters];
    NSUInteger identifier = invoker.serviceIdentifier;
    
    KDRequestWrapper *requestWrapper = [[KDRequestWrapper alloc] initWithDelegate:invoker.requestWrapperDelegate
                                                                               url:invoker.requestURL method:method
                                                                        parameters:params requestHeaders:invoker.requestHeaders
                                                                        identifier:identifier];// autorelease];
    
    requestWrapper.tag = invoker.tag;
    
    /*
        auth 统一放到方法中配置
     - (void)dispatch:(KDRequestWrapper *)requestWrapper type:(KDRequestDispatchType)type authNeed:(BOOL)authNeed
     */
    
    /*
    if([invoker isAuthNeed]) {
        // set authorization if need
        requestWrapper.authorization = authorization_;
    }
     */
    
    if(block != nil){
        requestWrapper.didCompleteBlock = block;
    }
    
    return requestWrapper;
}

- (void)doRequest:(KDRequestWrapper *)requestWrapper transferType:(NSUInteger)type authNeed:(BOOL)authNeed communityNeed:(BOOL)communityNeed{
    if (KDInvokerTranferTypeReceive == type) {
        [self doReceive:requestWrapper authNeed:authNeed communityNeed:communityNeed];
        
    } else if (KDInvokerTranferTypeSend == type) {
        [self doSend:requestWrapper authNeed:authNeed communityNeed:communityNeed];
        
    } else {
        [self doTransfer:requestWrapper authNeed:authNeed communityNeed:communityNeed];
    }
}

- (void)accountAvatar:(id<KDRequestWrapperDelegate>)delegate url:(NSString *)url scaleToSize:(KDImageSize *)size {
    KDRequestWrapper *requestWrapper = [self buildRequestWrapper:delegate url:url method:[KDRequestMethod GET]
                                                      parameters:nil identifier:KDAPIUndefined];
    
    [self bindUserInfoForImageRequest:requestWrapper imageSize:size cacheType:KDCacheImageTypeAvatar];
    [self doTransfer:requestWrapper authNeed:YES communityNeed:NO];
}

- (void)statusesImageSource:(id<KDRequestWrapperDelegate>)delegate url:(NSString *)url
                  cacheType:(NSUInteger)cacheType scaleToSize:(KDImageSize *)size userInfo:(id)userInfo {
    KDRequestWrapper *requestWrapper = [self buildRequestWrapper:delegate url:url method:[KDRequestMethod GET]
                                                      parameters:nil identifier:KDAPIUndefined];
    
    [self bindUserInfoForImageRequest:requestWrapper imageSize:size cacheType:cacheType];
    if(userInfo != nil) {
        [requestWrapper addUserInfoWithObject:userInfo forKey:kKDCustomUserInfoKey];
    }
    
    [self doTransfer:requestWrapper authNeed:YES communityNeed:NO];
}


- (void)groupAvatar:(id<KDRequestWrapperDelegate>)delegate url:(NSString *)url scaleToSize:(KDImageSize *)size {
    KDRequestWrapper *requestWrapper = [self buildRequestWrapper:delegate url:url method:[KDRequestMethod GET]
                                                      parameters:nil identifier:KDAPIUndefined];
    
    [self bindUserInfoForImageRequest:requestWrapper imageSize:size cacheType:KDCacheImageTypeAvatar];
    [self doTransfer:requestWrapper authNeed:YES communityNeed:NO];
}


/////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark download services methods

- (void)startDownloadWithDownload:(KDDownload *)download delegate:(id<KDRequestWrapperDelegate>)delegate {
    NSString *downloadUrl = [[download url]stringByAdjustingToValidURLSuffix];
    NSString *theUrl = [self communityURLWithSuffix:downloadUrl];
    KDRequestWrapper *requestWrapper = [self buildRequestWrapper:delegate url:theUrl method:[KDRequestMethod GET] parameters:nil identifier:[download identifier]];
    [requestWrapper setDownloadDestinationPath:[download path]];
    [requestWrapper setDownloadTemporaryPath:[download tempPath]];
    requestWrapper.isDownload = YES;
    [requestWrapper addUserInfoWithObject:download forKey:kKDCustomUserInfoKey];
    requestWrapper.configBlock = ^(KDRequestWrapper *requestWrapper, ASIHTTPRequest *request){
        request.downloadDestinationPath = requestWrapper.downloadDestinationPath;
        request.temporaryFileDownloadPath = requestWrapper.downloadTemporaryPath;
    };

    [self doTransfer:requestWrapper authNeed:YES communityNeed:NO];
}
- (void)startDownloadWithDownload:(KDDownload *)download delegate:(id<KDRequestWrapperDelegate>)delegate completionBlock:(KDRequestWrapperDidCompleteBlock)block {
    NSString *downloadUrl = [[download url]stringByAdjustingToValidURLSuffix];
    NSString *theUrl = [self communityURLWithSuffix:downloadUrl];
//    KDRequestWrapper *requestWrapper = [self buildRequestWrapper:delegate url:theUrl method:[KDRequestMethod GET] parameters:nil identifier:[download identifier]];
    KDRequestWrapper *requestWrapper = [ self buildRequestWrapper:delegate url:theUrl method:[KDRequestMethod GET] parameters:nil requestHeaders:nil completionBlock:block identifier:[download identifier]];
    [requestWrapper setDownloadDestinationPath:[download path]];
    [requestWrapper setDownloadTemporaryPath:[download tempPath]];
    requestWrapper.isDownload = YES;
    [requestWrapper addUserInfoWithObject:download forKey:kKDCustomUserInfoKey];
    requestWrapper.configBlock = ^(KDRequestWrapper *requestWrapper, ASIHTTPRequest *request){
        request.downloadDestinationPath = requestWrapper.downloadDestinationPath;
        request.temporaryFileDownloadPath = requestWrapper.downloadTemporaryPath;
    };
    
    [self doTransfer:requestWrapper authNeed:YES communityNeed:NO];
}
- (void)cancleAllDownloadWithDlegate:(id<KDRequestWrapperDelegate>)delegate {
    [self doCancleTransferWithDlelete:delegate];
}

- (void)cancleDownload:(KDDownload *)download {
    NSUInteger identifer = [download identifier];
    [self doCanleTransferWithAPIIdentifer:identifer]; 
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(authorization_);
    //KD_RELEASE_SAFELY(currentCommunityDomain_);
    
    //[super dealloc];
}

@end
