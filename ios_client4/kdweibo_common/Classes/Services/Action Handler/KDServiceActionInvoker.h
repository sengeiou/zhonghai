//
//  KDServiceActionInvoker.h
//  kdweibo_common
//
//  Created by laijiandong on 12-10-24.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDObject.h"
#import "KDQuery.h"
#import "KDServiceActionPath.h"

@protocol KDRequestWrapperDelegate;
@class KDRequestWrapper;
@class KDResponseWrapper;


typedef void (^KDServiceActionDidCompleteBlock) (id results, KDRequestWrapper *request, KDResponseWrapper *response);


typedef enum : NSUInteger { 
    KDInvokerMaskNone = 0,
    
    // Specific the request with authorization on requesting
    KDInvokerMaskAuthNeed = 1 << 0,
    
    // Specific it is the base server request or community request.
    // The community request must with community domain in the url
    KDInvokerMaskCommunityRequest = 1 << 1,
    
}KDInvokerMask;


#define KD_INVOKER_MASK_BASE                KDInvokerMaskNone
#define KD_INVOKER_MASK_AUTH_BASE           KDInvokerMaskAuthNeed
#define KD_INVOKER_MASK_AUTH_COMMUNITY     (KDInvokerMaskAuthNeed | KDInvokerMaskCommunityRequest)


typedef enum : NSUInteger {
    KDInvokerTranferTypeSend = 1, // Send
    KDInvokerTranferTypeReceive, // Receive
    KDInvokerTranferTypeTransfer, // Transfer
}KDInvokerTranferType;


@interface KDServiceActionInvoker : KDObject {
 @private
    
}

@property(nonatomic, assign) id sender;

// generally speaking, You can not assign any object for this property,
// this property reservered for action executor.
@property(nonatomic, assign) id<KDRequestWrapperDelegate> requestWrapperDelegate;

@property(nonatomic, retain, readonly) NSString *requestURL; // request url

@property(nonatomic, retain) KDServiceActionPath *servicePath;
@property(nonatomic, retain) KDQuery *query;
@property(nonatomic, retain) NSDictionary *requestHeaders;

@property(nonatomic, assign) KDInvokerMask mask;

@property(nonatomic, assign, readonly) NSUInteger serviceIdentifier; // generate by service path, it's same value for same service path
@property(nonatomic, assign) NSInteger tag; // generally speaking, the unique mask for any invoker

@property(nonatomic, copy) KDServiceActionDidCompleteBlock didCompleteBlock;

- (id)initWithSender:(id)sender serviceFullyPath:(NSString *)actionPath query:(KDQuery *)query;
- (id)initWithSender:(id)sender servicePath:(KDServiceActionPath *)servicePath query:(KDQuery *)query;

+ (id)invokerWithSender:(id)sender serviceFullyPath:(NSString *)serviceFullyPath query:(KDQuery *)query;


////////////////////////////////////////////////////////////////////////////////////////

/**
 *
 * Generally speaking, you can use the class methods at below to start service action invoke quickly.
 * @param sender - the service action caller, you can use it to cancel all the requests for it
 * @param path - the service action path, format like /auth/:accessToken
 * @param query - the request parameters for request
 * @param configBlock - the config block use to config invoker if need
 * @param completionBlock - the completion block used to handle the response when request did finish
 *
 */ 
+ (void)invokeWithSender:(id)sender actionPath:(NSString *)path query:(KDQuery *)query
             configBlock:(void (^)(KDServiceActionInvoker *))configBlock
         completionBlock:(KDServiceActionDidCompleteBlock)completionBlock;

/**
 *
 * The usage see invokeWithSender:actionPath:query:configBlock:completionBlock:
 * the difference is you can use the format parameters as string to replace KDQuery object.
 * the format like: a=b&c=d&e=f ('&' use to split the paramters and the '=' used to split parameter pair)
 */
+ (void)invokeWithSender:(id)sender actionPath:(NSString *)path parameters:(NSString *)params
             configBlock:(void (^)(KDServiceActionInvoker *))configBlock
         completionBlock:(KDServiceActionDidCompleteBlock)completionBlock;



////////////////////////////////////////////////////////////////////////////////////////

// cancel the invokers by sender
+ (void)cancelInvokersWithSender:(id)sender;

// cancel the invokers by fully action path
+ (void)cancelInvokersWithFullyAcionPath:(NSString *)fullyActionPath;


////////////////////////////////////////////////////////////////////////////////////////

// You can call this method to change request url manually, But you can not do it at most time.
- (void)resetRequestURL:(NSString *)url;

// Generally speaking, You should not call this method manually,
// And this method will invoked automatically by action handler on execute specificed handler
- (void)configWithMask:(KDInvokerMask)mask serviceURL:(NSString *)serviceURL;

- (BOOL)isAuthNeed; // return YES means this request need authorization on requesting, otherwise is NO (default is NO)
- (BOOL)isCommunityRequest; // return YES means it is a community request, otherwise it is a base request (default is NO)

- (BOOL)isValid; // validate the invoder is valid or not

+ (NSInteger)nextTagIndex;

@end
