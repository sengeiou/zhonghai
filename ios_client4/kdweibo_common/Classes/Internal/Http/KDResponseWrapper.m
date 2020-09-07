//
//  KDResponseWrapper.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-9.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDResponseWrapper.h"

#import "KDRequestWrapper.h"

#import "SBJSON.h"

@implementation KDResponseWrapper

@synthesize requestWrapper=requestWrapper_;

- (id)init {
    self = [super init];
    if(self){
        requestWrapper_ = nil;
    }
    
    return self;
}

- (id)initWithRequestWrapper:(KDRequestWrapper *)requestWrapper {
    self = [self init];
    if(self){
        requestWrapper_ = requestWrapper;// retain];
    }
    
    return self;
}

- (int)statusCode {
    return [[requestWrapper_ getHttpRequest] responseStatusCode];
}

- (BOOL)isValidResponse {
    int statusCode = [self statusCode];
    
    // if the status code in boundary [200, 300). 
    // and then the response be treat as valid response result.
    return statusCode >= 200 && statusCode < 300;
}

- (BOOL)isNetworkUnavailable {
    return 0x00 == [self statusCode];
}

- (BOOL)isCancelled {
    BOOL cancelled = NO;
    NSError *error = [[requestWrapper_ getHttpRequest] error];
    if(error != nil && (ASIRequestCancelledErrorType == [error code])){
        cancelled = YES;
    }
    
    return cancelled;
}

- (NSString *)getResponseHeader:(NSString *)fieldName {
    NSDictionary *headerFields = [[requestWrapper_ getHttpRequest] responseHeaders];
    return (headerFields != nil) ? [headerFields objectForKey:fieldName] : nil;
}

- (NSDictionary *)getResponseHeaderFields {
    return [[requestWrapper_ getHttpRequest] responseHeaders];
}

- (NSString *)responseAsString {
    return [[requestWrapper_ getHttpRequest] responseString];
}

- (NSData *)responseData {
    return [[requestWrapper_ getHttpRequest] responseData];
}

- (id)responseAsJSONObject {
    id results = nil;
    
    // If the status code is 0 may be current network unvailable, so 
    int statusCode = [self statusCode];
    if (statusCode >= KDHTTPResponseCode_200) {
        NSError *error = nil;
        
        @try {
            Class clazz = NSClassFromString(@"NSJSONSerialization");
            if(clazz != Nil){
                results = [NSJSONSerialization JSONObjectWithData:[self responseData] options:0 error:&error];
                
            }else {
                SBJSON *jsonParser = [[SBJSON alloc] init];
                results = [jsonParser objectWithString:[self responseAsString] error:&error];
//                [jsonParser release];
            }
            
        } @catch (NSException *exception) {
            DLog(@"parse json did catch an exception:%@ \nresponseAsString:%@", exception, [self responseAsString]);
        }
        
        if(statusCode >200){
            DLog(@"httprequest not normal: \nresponseAsString:%@", [self responseAsString]);
        }
        if(error != nil){
            DLog(@"Can not build json object with error:%@", error);
            
        }
    }
    
    if([results isKindOfClass:[NSNull class]])
        results = nil;
    
	return results;
}

- (KDResponseDiagnosis *)responseDiagnosis {
    KDResponseDiagnosis *diagnosis = nil;
    if(![self isValidResponse]){
        diagnosis = [[KDResponseDiagnosis alloc] initWithResponseWrapper:self];// autorelease];
    }
    
    return diagnosis;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(requestWrapper_);
    
    //[super dealloc];
}

@end
