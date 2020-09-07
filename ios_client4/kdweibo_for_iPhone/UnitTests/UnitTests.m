//
//  UnitTests.m
//  UnitTests
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "UnitTests.h"
#import "KDCommonTest.h"

#import "KDBasicAuthorization.h"
#import "KDNullAuthorization.h"

#import "KDVersion.h"

@implementation UnitTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void) testBasicAuthorization {
    KDBasicAuthorization *basic1 = [[[KDBasicAuthorization alloc] initWithIdentifier:@"systemdebug@kingdee.com" password:@"123456"] autorelease];
    KDBasicAuthorization *basic2 = [[[KDBasicAuthorization alloc] initWithIdentifier:@"systemdebug@kingdee.com" password:@"147852"] autorelease];
    
    STAssertFalse([basic1 isEqual:basic2], nil);
    
    NSString *header1 = [basic1 getAuthorizationHeader:nil];
    NSString *header2 = [basic2 getAuthorizationHeader:nil];
    
    NSLog(@"header1=%@ header2=%@", header1, header2);
    
    STAssertFalse([header1 isEqualToString:header2], nil);
}

- (void) testNullAuthorization {
    KDNullAuthorization *singleton = [KDNullAuthorization getInstance];
    KDNullAuthorization *null1 = [[[KDNullAuthorization alloc] init] autorelease];
    
    STAssertFalse([singleton isEqual:null1], nil);
}

@end
