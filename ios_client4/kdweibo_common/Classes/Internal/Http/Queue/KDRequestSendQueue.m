//
//  KDRequestSendQueue.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDRequestSendQueue.h"

@implementation KDRequestSendQueue

// override
- (NSUInteger) maxConcurrencyCount {
    return 0x03;
}

// override
- (void) addRequestWrapper:(KDRequestWrapper *)requestWrapper {
    if([super isValidRequestWrapper:requestWrapper]){
        // check does exist
        if([super hasSameFingerprintInDataSource:runningRequests_ requestWrapper:requestWrapper]){
            [super addToPendingList:requestWrapper];
            
        }else {
            [super addToRunningList:requestWrapper];
        }
    }
}

// override
- (KDRequestWrapper *) optimalRequestWrapperFromPendingList {
    KDRequestWrapper *target = nil; 
    
    if([super hasPendingRequestWrapper]){
        if([pendingRequests_ count] > 0x01){
            if([runningRequests_ count] == 0){
                // If there is no any requests in the running list, 
                // Just pick the highest execute priority request wrapper from pending list
                return [super requestWrapperWithHighestPriorityFromSource:pendingRequests_];
                
            }else {
                // Collect the fingerprints from running list.
                NSMutableArray *fingerprints = [NSMutableArray arrayWithCapacity:[runningRequests_ count]];
                for(KDRequestWrapper *item in runningRequests_){
                    [fingerprints addObject:item.fingerprint];
                }
                
                NSMutableArray *targets = [NSMutableArray array];
                for(KDRequestWrapper *item in pendingRequests_){
                    BOOL found = NO;
                    for(NSString *fp in fingerprints){
                        if([fp isEqualToString:item.fingerprint]){
                            found = YES;
                            break;
                        }
                    }
                    
                    if(!found){
                        [targets addObject:item];
                    }
                }
                
                // Filter the results by fingerprints and then get the highest priority request wrapper.
                if([targets count] > 0){
                    target = [super requestWrapperWithHighestPriorityFromSource:targets];
                }
            }
            
        }else {
            target = [super anyRequestWrapperFromPendingList];
        }
    }
    
    return target;
}

- (void) dealloc {
    
    //[super dealloc];
}

@end
