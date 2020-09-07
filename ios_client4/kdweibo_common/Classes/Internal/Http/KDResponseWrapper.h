//
//  KDResponseWrapper.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-9.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDResponseDiagnosis.h"

@class KDRequestWrapper;

// More about http response status code. please visit http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html

enum {
    KDHTTPResponseCode_200 = 200, // OK: The request has succeeded.
    
    KDHTTPResponseCode_300 = 300, // Multiple Choices: 
    KDHTTPResponseCode_302 = 302, // Found: The requested resource resides temporarily under a different URI. 
    KDHTTPResponseCode_304 = 304, // Not Modified: There was no new data to return.
    
    KDHTTPResponseCode_400 = 400, // Bad Request: The request could not be understood by the server due to malformed syntax.
    KDHTTPResponseCode_401 = 401, // Not Authorized: The request requires user authentication.
    KDHTTPResponseCode_403 = 403, // Forbidden: The server understood the request, but is refusing to fulfill it.
    KDHTTPResponseCode_404 = 404, // Not Found: The server has not found anything matching the Request-URI.
    KDHTTPResponseCode_406 = 406, // Not Acceptable:
    KDHTTPResponseCode_413 = 413, // Request Entity Too Large:
    KDHTTPResponseCode_420 = 420,
    
    KDHTTPResponseCode_500 = 500, // Internal Server Error: Something is broken.
    KDHTTPResponseCode_502 = 502, // Bad Gateway: kdweibo server is down or being upgraded.
    KDHTTPResponseCode_503 = 503, // Service Unavailable: The kdweibo servers are up, but overloaded with requests.
};


@interface KDResponseWrapper : NSObject {
@private
    KDRequestWrapper *requestWrapper_;
}

@property (nonatomic, retain, readonly) KDRequestWrapper *requestWrapper;

- (id)initWithRequestWrapper:(KDRequestWrapper *)requestWrapper;

- (int)statusCode;
- (BOOL)isValidResponse;
- (BOOL)isNetworkUnavailable;
- (BOOL)isCancelled;

- (NSString *)getResponseHeader:(NSString *)fieldName;
- (NSDictionary *)getResponseHeaderFields;

// please make sure call isValidResponse method to check response status before call below methods
- (NSString *)responseAsString;
- (NSData *)responseData;
- (id)responseAsJSONObject;

// the reponse diagnosis just work on the response is invalid, otherwise always return nil.
- (KDResponseDiagnosis *)responseDiagnosis;

@end
