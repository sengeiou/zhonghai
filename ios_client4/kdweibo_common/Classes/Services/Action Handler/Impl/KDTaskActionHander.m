//
//  KDTaskActionHander.m
//  kdweibo_common
//
//  Created by Tan yingqi on 13-7-3.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDTaskActionHander.h"
#define KD_SERVICE_TASK_ACTION_PATH	@"/task/"

@implementation KDTaskActionHander
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_TASK_ACTION_PATH;
}
- (void)taskById:(KDServiceActionInvoker *)invoker {
    NSString *taskId = [invoker.query propertyForKey:@"id"];
    NSString *serviceURL = [NSString stringWithFormat:@"task/show/%@.json", taskId];
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doGet:invoker configBlock:nil
                    didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
                        NSDictionary *result = nil;
                  if ([response isValidResponse]) {
                   NSDictionary *body = [response responseAsJSONObject];
                  if (body != nil) {
                   // int code = [body intForKey:@"code"];
                    BOOL sucess = [body boolForKey:@"success"];
                    if (sucess) {
                        KDTask *task = nil;
                        NSDictionary *detailDic = [body objectNotNSNullForKey:@"detail"];
                        if (detailDic) {
                            KDTaskParser *parser = [super parserWithClass:[KDTaskParser class]];
                            task = [parser parse:detailDic];
                        }
                        if (task) {
                            result = @{@"success":@(sucess),@"task":task};
                        }else {
                            result = @{@"success":@(sucess)};
                        }
                    }else {
                        NSString *errorMsg = [body stringForKey:@"errormsg"];
                        if (errorMsg) {
                            result = @{@"success":@(sucess),@"errormsg":errorMsg};
                        }else  {
                            result = @{@"success":@(sucess)};
                        }
                    }
                }
            }
               [super didFinishInvoker:invoker results:result request:request response:response];
    }];
}

- (void)list:(KDServiceActionInvoker *)invoker {
    NSString *status = [invoker.query propertyForKey:@"status"];
    NSString *serviceURL = [NSString stringWithFormat:@"task/list/%@.json", status];
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    
    [super doGet:invoker configBlock:nil
       didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
       NSMutableArray  *tasks = nil;
       if ([response isValidResponse]) {
        NSDictionary *body = [response responseAsJSONObject];
        if (body != nil) {
            // int code = [body intForKey:@"code"];
            BOOL sucess = [body boolForKey:@"success"];
            if (sucess) {
                NSArray *listArray = [body objectNotNSNullForKey:@"list"];
                if (listArray) {
                    tasks = [NSMutableArray arrayWithCapacity:0];
                    KDTask *task = nil;
                    for (NSDictionary *dic in listArray) {
                        KDTaskParser *parser = [super parserWithClass:[KDTaskParser class]];
                        task = [parser parse:dic];
                        [tasks addObject:task];
                    }
                  
                }
            }
        }
    }
    [super didFinishInvoker:invoker results:tasks request:request response:response];
}];
}


- (void)create:(KDServiceActionInvoker *)invoker {
    NSString *serviceURL =@"task/create.json";
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    [self doGeneralPost:invoker];

}

- (void)convertWithComment:(KDServiceActionInvoker *)invoker {
    NSString *serviceURL =@"task/create/comment.json";
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    [self doGeneralPost:invoker];
    
}

- (void)convertWithStatus:(KDServiceActionInvoker *)invoker {
    NSString *serviceURL =@"task/create/microblog.json";
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    [self doGeneralPost:invoker];
}

- (void)convertWithDirectMessage:(KDServiceActionInvoker *)invoker {
    NSString *serviceURL =@"task/create/dm.json";
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    [self doGeneralPost:invoker];
    
}

- (void)update:(KDServiceActionInvoker *)invoker {
    NSString *taskId = [invoker.query propertyForKey:@"id"];
    NSString *serviceURL = [NSString stringWithFormat:@"task/update/%@.json",taskId];
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    [self doGeneralPost:invoker];
}

- (void)finish:(KDServiceActionInvoker *)invoker {
    NSString *taskId = [invoker.query propertyForKey:@"id"];
    NSString *serviceURL = [NSString stringWithFormat:@"task/finish/%@.json",taskId];
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    [self doGeneralPost:invoker];
    
}

- (void)cancelfinishtasknew:(KDServiceActionInvoker *)invoker {
    NSString *taskId = [invoker.query propertyForKey:@"id"];
    NSString *serviceURL = [NSString stringWithFormat:@"task/cancelfinishtasknew/%@.json",taskId];
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    [self doGeneralPost:invoker];
}

- (void)removetasknew:(KDServiceActionInvoker *)invoker {
    NSString *taskId = [invoker.query propertyForKey:@"taskNewId"];
    NSString *serviceURL = [NSString stringWithFormat:@"task/removeTask/%@.json",taskId];
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:serviceURL];
    [self doGeneralPost:invoker];
}


- (void)doGeneralPost:(KDServiceActionInvoker *)invoker {
    [super doPost:invoker configBlock:nil
 didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
     BOOL success = NO;
     NSString *msg = nil;
     KDTask *task = nil;
     if ([response isValidResponse]) {
         NSDictionary *body = [response responseAsJSONObject];
         if (body) {
             success = [body boolForKey:@"success"];
             msg = [body stringForKey:@"errormsg"];
             KDTaskParser *parser = [super parserWithClass:[KDTaskParser class]];
             NSDictionary *taskDic = [body objectNotNSNullForKey:@"task"];
             task = [parser parse:taskDic];
         }
     }
     NSMutableDictionary *result = [NSMutableDictionary dictionary];
//     if (msg) {
//         result = @{@"success":@(success),@"errormsg":msg};
//     }else {
//         result = @{@"success":@(success)};
//     }
     [result setObject:@(success) forKey:@"success"];
     if (msg) {
         [result setObject:msg forKey:@"errormsg"];
     }
     if (task) {
         [result setObject:task forKey:@"task"];
     }
     [super didFinishInvoker:invoker results:result request:request response:response];
 }];
}

@end
