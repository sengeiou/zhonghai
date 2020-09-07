//
//  KDServiceActionPathTest.m
//  kdweibo
//
//  Created by laijiandong on 12-10-25.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDServiceActionPathTest.h"
#import "KDServiceActionPath.h"
#import "KDWeiboServicesContext.h"

@implementation KDServiceActionPathTest

- (void)setUp {
    [super setUp];
}

- (void)testBuildServiceActionPath {
    // blank string
    KDServiceActionPath *obj = [KDServiceActionPath serviceActionPath:@""];
    STAssertNil(obj, @"The action path can not create with blank string");

    // nil obj
    obj = [KDServiceActionPath serviceActionPath:nil];
    STAssertNil(obj, @"The action path can not create with blank string");
    
    // invalid action path lenth
    obj = [KDServiceActionPath serviceActionPath:@"a/:b"];
    STAssertNil(obj, @"The minimal length of action path must greater than 4");
    
    // action path not with divider symbol :
    obj = [KDServiceActionPath serviceActionPath:@"/apa/b"];
    STAssertNil(obj, @"action path not with divider symbol :");
    
    // action path can not end with divider symbol :
    obj = [KDServiceActionPath serviceActionPath:@"/apa/b:"];
    STAssertNil(obj, @"action path can not end with divider symbol :");
    
    obj = [KDServiceActionPath serviceActionPath:@"/statuses/:update"];
    STAssertEqualObjects(obj.actionPath, @"/statuses/", @"invalid action path");
    STAssertEqualObjects(obj.serviceName, @"update", @"invalid service name");
    
    obj = [KDServiceActionPath serviceActionPath:@"/statuses/:update:abc:cl"];
    STAssertNotNil(obj, @"this is valid action path");
}

- (void)tearDown {
    [super tearDown];
}

@end
