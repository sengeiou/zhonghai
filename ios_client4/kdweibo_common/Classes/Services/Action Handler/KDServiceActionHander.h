//
//  KDServiceActionHander.h
//  kdweibo_common
//
//  Created by laijiandong on 12-10-24.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDServiceActionInvoker.h"
#import "KDRequestWrapper.h"
#import "KDWeiboServicesContext.h"
#import "KDWeiboDAOManager.h"
#import "KDParserManager.h"

typedef enum : NSUInteger {
    KDServiceRequestTypeGet = 0x01,
    KDServiceRequestTypePost,
    KDServiceRequestTypeTransfer,
    
}KDServiceRequestType;

extern NSString * const kKDServiceStatusesProgressNotification;


@interface KDServiceActionHander : NSObject {
 @private
    
}

// Sub-classes must override
+ (NSString *)supportedServiceActionPath;

// retrieve JSON parser for specificed class
- (id)parserWithClass:(Class)clazz;

- (BOOL)canRespondsToServiceName:(NSString *)serviceName;
- (void)handle:(KDServiceActionInvoker *)invoker;

- (void)doGet:(KDServiceActionInvoker *)invoker
        configBlock:(KDRequestWrapperConfigBlock)configBlock
        didCompleteBlock:(KDRequestWrapperDidCompleteBlock)completeblock;

- (void)doPost:(KDServiceActionInvoker *)invoker
        configBlock:(KDRequestWrapperConfigBlock)configBlock
        didCompleteBlock:(KDRequestWrapperDidCompleteBlock)completeblock;

- (void)doTransfer:(KDServiceActionInvoker *)invoker
             isGet:(BOOL)isGet
        configBlock:(KDRequestWrapperConfigBlock)configBlock
        didCompleteBlock:(KDRequestWrapperDidCompleteBlock)completeblock;
    

- (void)didFinishInvoker:(KDServiceActionInvoker *)invoker results:(id)results
                 request:(KDRequestWrapper *)request response:(KDResponseWrapper *)response;

@end
