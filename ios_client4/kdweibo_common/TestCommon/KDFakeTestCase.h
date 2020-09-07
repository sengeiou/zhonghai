//
//  KDFakeTestCase.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-13.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

// this class use to disable test case class.
// for inatance, If you wanna make A test case class not need run test case at next time.
// you can change the class A inherited from KDFakeTestCase.
// This solution not good enough now. (Please fix it in the future)

// eg:
//
// @interface A : SenTestCase
// ->
// @interface A : KDFakeTestCase
//

@interface KDFakeTestCase : NSObject

- (void)setUp;
- (void)tearDown;

@end
