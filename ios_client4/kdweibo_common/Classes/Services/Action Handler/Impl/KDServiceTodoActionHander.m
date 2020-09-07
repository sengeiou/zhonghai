//
//  KDServiceTodoActionHander.m
//  kdweibo_common
//
//  Created by bird on 13-7-4.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDServiceTodoActionHander.h"
#import "KDTodoParser.h"
#import "KDTodo.h"
#define KD_SERVICE_DM_ACTION_PATH	@"/todo/"
@implementation KDServiceTodoActionHander
// Override
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_DM_ACTION_PATH;
}

- (void)list:(KDServiceActionInvoker *)invoker
{
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"todo/list.json"];
    
    [super doGet:invoker
            configBlock:nil
        didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    
            [self _asyncParseThreads:response
                     completionBlock:^(id info){
                         
                         KDTodoParser *result = (KDTodoParser *)info;
                         NSString *status = [invoker.query genericParameterForName:@"status"];
                         for (KDTodo *p in result.items) {
                             if ([p isKindOfClass:[KDTodo class]])
                             {
                                 if(status.length!=0)
                                     p.status = status;
                             }
                         }
                         [super didFinishInvoker:invoker results:info request:request response:response];}];
            }];
}

- (void)updateStatus:(KDServiceActionInvoker *)invoker
{
    NSString *todoId = [invoker.query genericParameterForName:@"todoId"];
    NSString *serviceURL = [NSString stringWithFormat:@"todo/update-status/%@.json",todoId];
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doPost:invoker configBlock:nil
 didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
     
     NSMutableDictionary *dic = [NSMutableDictionary dictionary];
     if ([response isValidResponse])
     {
         NSDictionary *p = [response responseAsJSONObject];
         if ([p isKindOfClass:[NSDictionary class]])
             [dic addEntriesFromDictionary:[response responseAsJSONObject]];
         [dic setValue:todoId forKey:@"todoId"];
     }
     
     [super didFinishInvoker:invoker results:dic request:request response:response];
 }];
    
}
- (void)_asyncParseThreads:(KDResponseWrapper *)response completionBlock:(void (^)(id))block {
    if (![response isValidResponse]) {
        block(nil);
        
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        id content = [response responseAsJSONObject];
        
        KDTodoParser   *parser = [[KDTodoParser alloc] init];// autorelease];
        [parser parse:content];
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(parser);
        });
    });
}
@end
