//
//  KDServiceActionHander.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-24.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceActionHander.h"


#define KD_SERVICE_SEL_NAME_SUFFIX  @":"

@implementation KDServiceActionHander

+ (NSString *)supportedServiceActionPath {
    [NSException raise:@"Invalid implementation" format:@"The sub-classes must override this method"];
    return nil;
}

- (id)parserWithClass:(Class)clazz {
    return [[KDParserManager globalParserManager] parserWithClass:clazz];
}

- (SEL)selectorWithServiceName:(NSString *)serviceName {
    // format like  comments:
    // we don't check the service name is valid or not, because we did it before.
    NSString *selectorName = [serviceName stringByAppendingString:KD_SERVICE_SEL_NAME_SUFFIX];
    return NSSelectorFromString(selectorName);
}

- (BOOL)canRespondsToServiceName:(NSString *)serviceName {
    SEL selector = [self selectorWithServiceName:serviceName];
    return [self respondsToSelector:selector];
}

- (void)handle:(KDServiceActionInvoker *)invoker {
    NSString *serviceName = invoker.servicePath.serviceName;
    SEL selector = [self selectorWithServiceName:serviceName];

    [self performSelector:selector withObject:invoker];
}

- (void)doGet:(KDServiceActionInvoker *)invoker
        configBlock:(KDRequestWrapperConfigBlock)configBlock
        didCompleteBlock:(KDRequestWrapperDidCompleteBlock)completeblock {
    
    [self invoke:invoker isGet:YES type:KDInvokerTranferTypeReceive configBlock:configBlock didCompleteBlock:completeblock];
}

- (void)doPost:(KDServiceActionInvoker *)invoker
        configBlock:(KDRequestWrapperConfigBlock)configBlock
        didCompleteBlock:(KDRequestWrapperDidCompleteBlock)completeblock {
    
    [self invoke:invoker isGet:NO type:KDInvokerTranferTypeSend configBlock:configBlock didCompleteBlock:completeblock];
}

- (void)doTransfer:(KDServiceActionInvoker *)invoker
             isGet:(BOOL)isGet
        configBlock:(KDRequestWrapperConfigBlock)configBlock
        didCompleteBlock:(KDRequestWrapperDidCompleteBlock)completeblock {
    
    [self invoke:invoker isGet:isGet type:KDInvokerTranferTypeTransfer configBlock:configBlock didCompleteBlock:completeblock];
}

- (void)invoke:(KDServiceActionInvoker *)invoker
         isGet:(BOOL)isGet
          type:(NSUInteger)type
            configBlock:(KDRequestWrapperConfigBlock)configBlock
            didCompleteBlock:(KDRequestWrapperDidCompleteBlock)completeblock {
    
    id<KDWeiboServices> services = [[KDWeiboServicesContext defaultContext] getKDWeiboServices];
    KDRequestWrapper *request = [services toRequestWrapper:invoker isGet:isGet usingBlock:completeblock];
    
    NSLog(@"%@",request.url);
    if (configBlock != nil) {
        request.configBlock = configBlock;
    }
    
    [services doRequest:request transferType:type authNeed:[invoker isAuthNeed] communityNeed:[invoker isCommunityRequest]];
}

- (void)didFinishInvoker:(KDServiceActionInvoker *)invoker results:(id)results 
                 request:(KDRequestWrapper *)request response:(KDResponseWrapper *)response {
    if (invoker.didCompleteBlock != nil) {
        invoker.didCompleteBlock(results, request, response);
    }
}

@end
