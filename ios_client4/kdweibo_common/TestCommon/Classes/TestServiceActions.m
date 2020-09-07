//
//  TestServiceActions.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-17.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "TestServiceActions.h"
#import "KDServiceActionInvoker.h"

@implementation TestServiceActions

- (void)testAuthAction {
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"x_auth_username" stringValue:@"fake-username"]
             setParameter:@"x_auth_password" stringValue:@"fake-password"]
             setParameter:@"x_auth_mode" stringValue:@"client_auth"];
    
    KDServiceActionDidCompleteBlock block = ^(id results, KDRequestWrapper *req, KDResponseWrapper *res) {
        // TODO: xxx handle the response
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/auth/:accessToken" query:query
                                 configBlock:nil completionBlock:block];
}

@end
