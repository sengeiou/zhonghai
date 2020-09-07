//
//  KDThreadRequst.m
//  KDWebPluginDemo
//
//  Created by gordon_wu on 14-3-14.
//  Copyright (c) 2014年 gordon_wu. All rights reserved.
//

#import "KDThreadRequst.h"

@implementation KDThreadRequst


- (void)requestFinished {
    
#if DEBUG_REQUEST_STATUS || DEBUG_THROTTLING
    NSLog(@"[STATUS] Request finished: %@",self);
#endif
    if ([self error] || [self mainRequest]) {
        return;
    }
  
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    
    // Your code
      [super reportFinished];
#pragma clang diagnostic pop
}


@end
