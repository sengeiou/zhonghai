//
//  KDAuthorizationTest.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDAuthorizationTest.h"

#import "KDBasicAuthorization.h"
#import "KDNullAuthorization.h"

@implementation KDAuthorizationTest

- (void) setUp {
    [super setUp];
}

- (void) testAuthoricationEnabled {
    KDBasicAuthorization *basic = [[KDBasicAuthorization alloc] initWithIdentifier:@"fake" password:@"123"];
    KDNullAuthorization *null = [KDNullAuthorization getInstance];
    
    STAssertTrue([basic isEnabled], @"basic authorization did not enabled.");
    STAssertFalse([null isEnabled], @"null authorization did enabled.");
    
    [basic release];
}

- (void) tearDown {
    [super tearDown];
}

@end
