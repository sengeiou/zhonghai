//
//  KDResponseDiagnosis.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-9.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDResponseDiagnosis.h"


#import "KDRequestWrapper.h"
#import "KDResponseWrapper.h"
#import "KDReachabilityManager.h"

@implementation KDResponseDiagnosis

@synthesize responseWrapper=responseWrapper_;

- (id) init {
    self = [super init];
    if(self){
        responseWrapper_ = nil;
        statusCode_ = -1;
    }
    
    return self;
}

- (id) initWithResponseWrapper:(KDResponseWrapper *)responseWrapper {
    self = [self init];
    if(self){
        responseWrapper_ = responseWrapper;// retain];
        statusCode_ = [responseWrapper_ statusCode];
    }
    
    return self;
}

- (BOOL) resourceNotFound {
    return statusCode_ == KDHTTPResponseCode_404;
}

- (NSString *) getCauseDescription {
    NSString *cause = nil;
    
    switch (statusCode_) {
        case KDHTTPResponseCode_304:
            cause = @"There was no new data to return.";
            break;
            
        case KDHTTPResponseCode_400:
            cause = @"The request was invalid. An accompanying error message will explain why.";
            break;
            
        case KDHTTPResponseCode_401:
            cause = @"Authentication credentials were missing or incorrect.";
            break;
            
        case KDHTTPResponseCode_403:
            cause = @"The request is understood, but it has been refused.";
            break;
            
        case KDHTTPResponseCode_404:
            cause = @"The URI requested is invalid or the resource requested, such as a user, does not exist.";
            break;
            
        case KDHTTPResponseCode_413:
            cause = @"A parameter list is too long.";
            break;
            
        case KDHTTPResponseCode_500:
            cause = @"Something is broken. (Internal server error, please report to developers work for server side.)";
            break;
            
        case KDHTTPResponseCode_502:
            cause = @"kdweibo is down or being upgraded.";
            break;
            
        case KDHTTPResponseCode_503:
            cause = @"The kdweibo servers are up, but overloaded with requests. Try again later.";
            break;
            
        default:
            cause = @"";
    }
    
    return [NSString stringWithFormat:@"%d:%@", statusCode_, cause];
}

- (BOOL)isNetworkAvailable {
//    Reachability *r = [Reachability reachabilityWithHostName:@"www.kingdee.com"];
//    switch ([r currentReachabilityStatus]) {
//        case ReachableViaWiFi:
//        case ReachableViaWWAN:
//            return YES;
//            break;
//        case NotReachable:
//        default:
//            return NO;
//            break;
//    }
    return [[KDReachabilityManager sharedManager] isReachable];
}

- (NSString *)networkErrorMessage {
    NSString *errMessage = ASLocalizedString(@"KDInviteColleaguesViewController_server_error");
    
    if (0 == statusCode_ && ![self isNetworkAvailable]) {
        errMessage = ASLocalizedString(@"DATALOAD_FAIL_PLZ_RETRY");
    }else {
        //已提bug，去掉code 王松 2013-12-18
        NSDictionary *error = [responseWrapper_ responseAsJSONObject];
        NSString *reason = [error objectForKey:@"reason"];
        NSString *message = [error objectForKey:@"message"];
        NSString *code = [NSString stringWithFormat:@"%ld", [[error objectForKey:@"code"] integerValue]];
        
        if(code && code.length > 0) {
            errMessage = [self reasonForCode:code];
        }else if(statusCode_ == 403) {
            errMessage = ASLocalizedString(@"KDInviteColleaguesViewController_server_error");
        }
        
        if(!errMessage) {
            if([self hasChineseInString:reason]){
                errMessage = reason;
            }else if([self hasChineseInString:message]) {
                errMessage = message;
            }else {
                errMessage = ASLocalizedString(@"DATALOAD_FAIL_PLZ_RETRY");
            }
        }
    }

    return errMessage;
}

- (BOOL)hasChineseInString:(NSString *)string
{
    BOOL isChinese = NO;
    for(NSInteger index = 0; index < [string length]; index++) {
        unichar c = [string characterAtIndex:index];
        if(c > 0x4e00 && c < 0x9fff) {
            isChinese = YES;
            break;
        }
    }
    
    return isChinese;
}

- (NSString *)reasonForCode:(NSString *)code
{
    if(!codeToReason_) {
        codeToReason_ = [[NSDictionary alloc] initWithObjectsAndKeys:
                         ASLocalizedString(@"创建团队失败，最多只允许创建3个团队!"), @"40361",
                         ASLocalizedString(@"申请加入团队失败，您已经申请加入该团队啦!"), @"40362",
                         ASLocalizedString(@"您已没有访问当前公司的权限，请切换工作圈后重试"), @"403",
                         nil];
    }
    
    return [codeToReason_ objectForKey:code];
}

- (NSString *) getErrorMessage {
    if(![responseWrapper_ isValidResponse]){
        NSMutableString *message = [NSMutableString string];
        if (statusCode_ != -1) {
            [message appendFormat:@"caused by:%@\n", [self getCauseDescription]];
        }
        
        ASIHTTPRequest *request = [responseWrapper_.requestWrapper getHttpRequest];
        NSString *path = [request.url path];
        if(path != nil ){
            [message appendFormat:@"request - %@\n", path];
        }
        
        NSError *error = request.error;
        if(error != nil){
            [message appendFormat:@"error - %@\n", error];
        }
        
        return message;
    }
    
    return nil;
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(responseWrapper_);
    
    //[super dealloc];
}

@end
