//
//  KDRequestReceiveQueue.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDRequestReceiveQueue.h"

@implementation KDRequestReceiveQueue

// override
- (NSUInteger) maxConcurrencyCount {
    return 0x05;
}

// override
- (void) addRequestWrapper:(KDRequestWrapper *)requestWrapper {
    if ([self isValidRequestWrapper:requestWrapper]) {
        [self addToRunningList:requestWrapper];
    
    } else {
        DLog(@"The request with url=%@ is invalid", requestWrapper.url);
    }
}

// override
- (BOOL) isValidRequestWrapper:(KDRequestWrapper *)requestWrapper {
    if(![super isValidRequestWrapper:requestWrapper]) return NO;
    
    // The receive type request wrapper just allow the request with unique fingerprint in the running list.
    // For instance, If there are two requests try to list comments for status, The last request will be drop.
    // So, The fingerprint act as important role to make unique request for request wrappers with same type.
    if([super hasSameFingerprintInDataSource:runningRequests_ requestWrapper:requestWrapper]){
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"There is exists same fingerpint in the runing requests list." forKey:kKDRequestQueueErrorDropRequestReasonKey];
        
        NSError *error = [NSError errorWithDomain:kKDRequestQueueErrorDomain code:0 userInfo:userInfo];
        [super dropRequest:requestWrapper error:error fromPendingList:NO];
        
        return NO;
    }
    
    return YES;
}

// override
- (KDRequestWrapper *) optimalRequestWrapperFromPendingList {
    // there is not exists any requests in pending list for receive type.
    return nil;
}

- (void) dealloc {
    //[super dealloc];
}

@end
