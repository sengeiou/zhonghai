//
//  BOSConnect.m
//  Public
//
//  Created by Gil on 12-4-26.
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "BOSConnect.h"
#import "ASIHTTPRequest+OAuth.h"
#import "BOSPublicConfig.h"
#import "BOSLogger.h"
#import "BOSUtils.h"
#import "AlgorithmHelper.h"
#import "KDCommon.h"
//#import "KDURLPathManager.h"
#import "KDRequests.h"

//默认超时时间为30秒
#define kConnectDefaultTimeOut 30
@interface BOSConnect ()
//@property (nonatomic, strong) ASIHTTPRequest *httpRequest;
-(void)startRequestWithHeader:(NSDictionary *)header timeout:(NSTimeInterval)seconds;
@end

@implementation BOSConnect
@synthesize hasError = _hasError_;
@synthesize errorCode = _errorCode_;
@synthesize errorMessage = _errorMessage_;

static NSString *userAgent = nil;
static NSString *defaultUserAgent = nil;

#pragma mark - init and dealloc

- (id)init
{
    self = [super init];
    if (self) {
        //A.wang 增加了deviceId
        defaultUserAgent = [[NSString alloc] initWithFormat:@"%@/%@;%@ %@;Apple;%@;%@;deviceId:%@",XuntongAppClientId,[KDCommon clientVersion],[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion,[UIDevice platform],[KDCommon isJailBreak] == 1? @"true":@"false",[UIDevice uniqueDeviceIdentifier]];
        _shouldAppendUA = YES;
    }
    return self;
}

- (id)initWithTarget:(id)target action:(SEL)action
{
    BOSConnectFlags connectFlags = {BOSConnect4ActionParam,BOSConnectNotEncryption,BOSConnectResponseAllowCompressed,BOSConnectRequestBodyNotCompressed,NO};
    return [self initWithTarget:target action:action connectionFlags:connectFlags];
}

- (id)initWithTarget:(id)target action:(SEL)action connectionFlags:(BOSConnectFlags)connectFlags
{
    self = [self init];
    if (self) {
        _target_ = target;
        _action_ = action;
        _connectFlags_ = connectFlags;
        
        _hasError_ = NO;
        _errorCode_ = 0;
        
        
        self.bodyType = BOSConnectBodyWithJSON;
    }
    return self;
}

- (void)cancelRequest {
    if (_httpRequest_) {
        [[KDRequests sharedRequests].requests removeObject:_httpRequest_];
        [_httpRequest_ clearDelegatesAndCancel];
        _httpRequest_ = nil;
    }
}
-(void)dealloc {
    [self cancelRequest];
     _target_ = nil;
    _action_ = nil;
}

#pragma mark - post methods

-(void)post:(NSString *)urlStr
{
    [self post:urlStr body:nil header:nil timeout:kConnectDefaultTimeOut];
}

-(void)post:(NSString *)urlStr body:(id)body
{
    [self post:urlStr body:body header:nil timeout:kConnectDefaultTimeOut];
}

-(void)post:(NSString *)urlStr body:(id)body header:(NSDictionary *)header
{
    [self post:urlStr body:body header:header timeout:kConnectDefaultTimeOut];
}

-(void)post:(NSString *)urlStr body:(id)body header:(NSDictionary *)header timeout:(NSTimeInterval)seconds
{
    //组装url
    NSURL *url = nil;
    
    //检测URL是否合法
    BOSAssert(![_baseUrlString_ isKindOfClass:[NSNull class]] && _baseUrlString_, @"baseUrlString is null or nil.");
    BOSAssert(![urlStr isKindOfClass:[NSNull class]] && urlStr, @"urlStr is null or nil.");
    //检测body是否合法
    if (body != nil && ![body isKindOfClass:[NSData class]] && ![body isKindOfClass:[NSDictionary class]]) {
        //body必须是NSData或者NSDictionary类型
        [self performWithErrorCode:BOSConnectParseParamError objcet:nil];
        return;
    }
    
   
    
    //组装url
   url = [NSURL URLWithString:_baseUrlString_];
 
    if (_connectFlags_._connectType == BOSConnect4DirectURL) {
        //baseUrl+urlStr
        url = [NSURL URLWithString:[_baseUrlString_ stringByAppendingString:urlStr]];
    }
    _httpRequest_ = [[ASIFormDataRequest alloc] initWithURL:url];
    [_httpRequest_ setRequestMethod:@"POST"];
    [_httpRequest_ setShouldAttemptPersistentConnection:NO];
    BOSINFO(@"url:%@",url);

    
    if (body != nil) {
        if ([body isKindOfClass:[NSData class]]) {//data
            NSMutableDictionary *bodyParams = [NSMutableDictionary dictionary];
            [bodyParams setObject:userAgent != nil ? userAgent : defaultUserAgent forKey:@"ua"];
            if (_connectFlags_._connectType == BOSConnect4ActionParam) {
                [bodyParams setObject:urlStr forKey:@"url"];
            }
            BOSINFO(@"body:%@",bodyParams);
            if ([bodyParams.allKeys count] > 0) {
                NSDictionary *dataParams = [NSDictionary dictionaryWithObject:body forKey:@"data"];
                [self buildMutilPartRequestWithBody:bodyParams data:dataParams];
            }
            else if (self.bodyType == BOSConnectBodyWithParam) {
                [self buildKeyValueRequestWithBody:bodyParams];
            }
            else {
                [self buildStreamRequestWithData:body];
            }
        }else{//dictionary
            BOOL mutilPartRequest = NO;
            
            NSMutableDictionary *bodyParams = [NSMutableDictionary dictionary];
            if (_shouldAppendUA) {
                 [bodyParams setObject:userAgent != nil ? userAgent : defaultUserAgent forKey:@"ua"];
            }
//
            if (_connectFlags_._connectType == BOSConnect4ActionParam) {
                [bodyParams setValue:urlStr forKey:@"url"];
            }
            NSMutableDictionary *dataParams = [NSMutableDictionary dictionary];
            
            for (NSString *key in [body allKeys]) {
                id value = [body objectForKey:key];
                if ([value isKindOfClass:[NSData class]]) {
                    if (mutilPartRequest == NO) {
                        mutilPartRequest = YES;
                    }
                    [dataParams setValue:value forKey:key];
                }else{
                    [bodyParams setValue:value forKey:key];
                }
            }
            BOSINFO(@"body:%@",bodyParams);
            
            if (mutilPartRequest) {
                [self buildMutilPartRequestWithBody:bodyParams data:dataParams];
            }
            else if (self.bodyType == BOSConnectBodyWithParam) {
                [self buildKeyValueRequestWithBody:bodyParams];
            }
            else{
                [self buildJSONRequestWithBody:bodyParams];
            }
        }
    }else{
        NSMutableDictionary *bodyParams = [NSMutableDictionary dictionaryWithObject:userAgent != nil ? userAgent : defaultUserAgent forKey:@"ua"];
        BOSINFO(@"body:%@",bodyParams);
        [self buildJSONRequestWithBody:bodyParams];
    }
    
    [self startRequestWithHeader:header timeout:seconds];
}

-(void)buildJSONRequestWithBody:(NSDictionary *)bodyParams
{
//    NSString *requestString = @"{}";
    NSData *requestData = nil;
    if (bodyParams != nil) {
        requestData = [NSJSONSerialization dataWithJSONObject:bodyParams options:NSJSONWritingPrettyPrinted error:nil];
    }
    else {
        requestData = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
    }
    
//    if (_connectFlags_._securityType == BOSConnectEncryption) {
//        BOSAssert(_desKey_ != nil, @"DES Key is nil");
//        requestData = [NSMutableData dataWithData:[AlgorithmHelper des_Encrypt2Data:requestString key:_desKey_]];
//    }else{
//        requestData = [NSMutableData dataWithData:[requestString dataUsingEncoding:NSUTF8StringEncoding]];
//    }
    [_httpRequest_ addRequestHeader:@"Content-Type" value:@"application/json"];
    if (requestData) {
        [_httpRequest_ setPostBody:[NSMutableData dataWithData:requestData]];
    }
}

-(void)buildMutilPartRequestWithBody:(NSDictionary *)bodyParams data:(NSDictionary *)dataParams
{
    [(ASIFormDataRequest *)_httpRequest_ setPostFormat:ASIMultipartFormDataPostFormat];
    
    for (NSString *key in [bodyParams allKeys]) {
        NSString *value = [bodyParams objectForKey:key];
//        if (_connectFlags_._securityType == BOSConnectEncryption) {
//            BOSAssert(_desKey_ != nil, @"DES Key is nil");
//            value = [NSString stringWithUTF8String:[[AlgorithmHelper des_Encrypt2Data:value key:_desKey_] bytes]];
//        }
        [(ASIFormDataRequest *)_httpRequest_ addPostValue:value forKey:key];
    }
    
    for (NSString *dataKey in [dataParams allKeys]) {
        NSData *dataValue = [dataParams objectForKey:dataKey];
//        if (_connectFlags_._securityType == BOSConnectEncryption) {
//            BOSAssert(_desKey_ != nil, @"DES Key is nil");
//            dataValue = [NSMutableData dataWithData:[AlgorithmHelper des_Encrypt2Data:[NSString stringWithUTF8String:[dataValue bytes]] key:_desKey_]];
//        }
        [(ASIFormDataRequest *)_httpRequest_ addData:dataValue forKey:dataKey];
    }
}

-(void)buildStreamRequestWithData:(NSData *)data
{
    NSMutableData *dataValue = [NSMutableData dataWithData:data];
//    if (_connectFlags_._securityType == BOSConnectEncryption) {
//        BOSAssert(_desKey_ != nil, @"DES Key is nil");
//        dataValue = [NSMutableData dataWithData:[AlgorithmHelper des_Encrypt2Data:[NSString stringWithUTF8String:[dataValue bytes]] key:_desKey_]];
//    }
    [_httpRequest_ addRequestHeader:@"Content-Type" value:@"application/octet-stream"];
    [_httpRequest_ setPostBody:dataValue];
}

- (void)buildKeyValueRequestWithBody:(NSDictionary *)bodyParams {
    [_httpRequest_ addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    if (!bodyParams) {
        return;
    }
    
    if (![bodyParams isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    for (NSString *key in [bodyParams allKeys]) {
        NSString *value = [bodyParams objectForKey:key];
        [(ASIFormDataRequest *)_httpRequest_ addPostValue:value forKey:key];
    }
    
//    if (bodyParams) {
//        self.requestParams = bodyParams;
//    }
}

#pragma mark - get methods

-(void)get:(NSString *)urlStr params:(NSDictionary *)params header:(NSDictionary *)header timeout:(NSTimeInterval)seconds
{
    BOSAssert(![_baseUrlString_ isKindOfClass:[NSNull class]] && _baseUrlString_, @"baseUrlString is null or nil.");
    BOSAssert(![urlStr isKindOfClass:[NSNull class]] && urlStr, @"urlStr is null or nil.");
    
    NSString *httpUrlString = [_baseUrlString_ stringByAppendingString:urlStr];

    if (params != nil) {//组装url
        NSString *paramsString = @"?";
        for (int i = 0; i < [params count]; i++) {
            NSString *key = [params.allKeys objectAtIndex:i];
            id value = [params objectForKey:key];
            NSString *stringValue = nil;
            if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
                stringValue = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }else if ([value isKindOfClass:[NSNumber class]]){
                NSNumber *numberValue = (NSNumber *)value;
                stringValue = [numberValue stringValue];
            }else if ([value isKindOfClass:[NSString class]]){
                stringValue = value;
            }
            if (stringValue == nil) {
                [self performWithErrorCode:BOSConnectParseParamError objcet:nil];
                return;
            }else{
                paramsString = [paramsString stringByAppendingFormat:@"%@=%@",key,[BOSUtils urlEncode:stringValue]];
                if (i != [params count] - 1) {
                    paramsString = [paramsString stringByAppendingString:@"&"];
                }
            }
        }
        httpUrlString = [httpUrlString stringByAppendingString:paramsString];
    }
    
    if (userAgent != nil && [_baseUrlString_ length] > 0) {
        if (params == nil) {
            httpUrlString = [httpUrlString stringByAppendingFormat:@"?ua=%@",userAgent != nil ? userAgent : defaultUserAgent];
        } else {
            httpUrlString = [httpUrlString stringByAppendingFormat:@"&ua=%@",userAgent != nil ? userAgent : defaultUserAgent];
        }
    }
    BOSINFO(@"url:%@",httpUrlString);
    
    NSURL *url = [NSURL URLWithString:httpUrlString];
    _httpRequest_ = [[ASIHTTPRequest alloc] initWithURL:url];
    [_httpRequest_ setRequestMethod:@"GET"];
    [_httpRequest_ setShouldAttemptPersistentConnection:YES];
    
    [self startRequestWithHeader:header timeout:seconds];
}

-(void)get:(NSString *)urlStr params:(NSDictionary *)params header:(NSDictionary *)header
{
    [self get:urlStr params:params header:header timeout:kConnectDefaultTimeOut];
}

-(void)get:(NSString *)urlStr params:(NSDictionary *)params
{
    [self get:urlStr params:params header:nil timeout:kConnectDefaultTimeOut];
}

-(void)get:(NSString *)urlStr
{
    [self get:urlStr params:nil header:nil timeout:kConnectDefaultTimeOut];
}

#pragma mark - start request

-(void)startRequestWithHeader:(NSDictionary *)header timeout:(NSTimeInterval)seconds
{
    //设置超时时间
    if (seconds <= 0){
        seconds = kConnectDefaultTimeOut;
    }
    [_httpRequest_ setTimeOutSeconds:seconds];
    
    //设置http header
    if (header && [header isKindOfClass:[NSDictionary class]]) {
        BOSINFO(@"post-header:%@",header);
        for (id key in header.allKeys) {
            [_httpRequest_ addRequestHeader:key value:[header objectForKey:key]];
        }
    }
    
    //设置是否允许返回值使用gzip压缩
    if (_connectFlags_._compressedResponseType == BOSConnectResponseAllowCompressed) {
        [_httpRequest_ setAllowCompressedResponse:YES];
    }else{
        [_httpRequest_ setAllowCompressedResponse:NO];
    }
    //设置发送值是否使用gzip压缩
    if (_connectFlags_._compressedRequestType == BOSConnectRequestBodyCompressed) {
        [_httpRequest_ setShouldCompressRequestBody:YES];
    }else{
        [_httpRequest_ setShouldCompressRequestBody:NO];
    }
    
    //设置OAuth信息
    if (_connectFlags_.needOAuth) {
        [_httpRequest_ signRequestWithClientIdentifier:_connectOAuthInfo_.consumerKey secret:_connectOAuthInfo_.consumerSecret tokenIdentifier:_connectOAuthInfo_.oauthToken secret:_connectOAuthInfo_.oauthTokenSecret usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];
    }
    
    [_httpRequest_ setDelegate:self];
    [_httpRequest_ startAsynchronous];
}

#pragma mark - ASIHTTPRequestDelegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@",[request responseString]);
    
    int errorCode = [request responseStatusCode];
    if (errorCode < 400) {//正常，无错误
        errorCode = 0;
    }
    
    id result = nil;
    if (errorCode == 0) {
        NSString *contentType = [[request responseHeaders] objectForKey:@"Content-Type"];
        if (contentType == nil) {
            contentType = @"application/json";
        }
        NSRange range = [contentType rangeOfString:@"application/json" options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            //json
            NSString *responseString = [request responseString];;
            id jsonResult = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            if (jsonResult) {
                //如果是BOSResultDataModel对象
                if ([BOSResultDataModel isBOSResultDataModelClass:jsonResult]) {
                    BOSResultDataModel *bosResult = [[BOSResultDataModel alloc] initWithDictionary:jsonResult];
                    bosResult.dictJSON = jsonResult;
                    result = bosResult;
                    
                }else{
                    result = jsonResult;
                }
            }else{
                errorCode = BOSConnectParseResponseError;
            }
            BOSINFO(@"action:(%@) - data:%@",NSStringFromSelector(_action_),responseString);
        }else{
            //data
            NSData *responseData = [request responseData];
            result = responseData;
            BOSINFO(@"action:(%@) - data lenth:%.2fKB",NSStringFromSelector(_action_),[responseData length]/1024.0);
        }
    }
    [self performWithErrorCode:errorCode objcet:result];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self performWithErrorCode:(int)[[request error] code] objcet:nil];
}

-(void)performWithErrorCode:(int)errorCode objcet:(id)object
{
    [self cancelRequest];
    
    _errorCode_ = errorCode;
    _hasError_ = _errorCode_ == 0 ? NO : YES;
    
    if (_errorCode_ != 0) {
        switch (_errorCode_) {
            case BOSConnectParseResponseError:
                self.errorMessage = ASLocalizedString(@"KDInviteColleaguesViewController_server_error");
                break;
            case BOSConnectParseParamError:
                self.errorMessage = ASLocalizedString(@"KDInviteColleaguesViewController_server_error");
                break;
            case ASIConnectionFailureErrorType:
                self.errorMessage = ASLocalizedString(@"Data_Fail_Retry");
                break;
            case ASIRequestTimedOutErrorType:
                self.errorMessage = ASLocalizedString(@"Data_Fail_Retry");
                break;
            case ASIAuthenticationErrorType:
                self.errorMessage = ASLocalizedString(@"KDInviteColleaguesViewController_server_error");
                break;
            case ASIRequestCancelledErrorType:
                self.errorMessage = ASLocalizedString(@"Data_Fail_Retry");
                break;
            case ASIUnableToCreateRequestErrorType:
                self.errorMessage = ASLocalizedString(@"Data_Fail_Retry");
                break;
            case ASIInternalErrorWhileBuildingRequestType:
                self.errorMessage = ASLocalizedString(@"Data_Fail_Retry");
                break;
            case ASIInternalErrorWhileApplyingCredentialsType:
                self.errorMessage = ASLocalizedString(@"Data_Fail_Retry");
                break;
            case ASIFileManagementError:
                self.errorMessage = ASLocalizedString(@"Data_Fail_Retry");
                break;
            case ASITooMuchRedirectionErrorType:
                self.errorMessage = ASLocalizedString(@"KDInviteColleaguesViewController_server_error");
                break;
            case ASIUnhandledExceptionError:
                self.errorMessage = ASLocalizedString(@"Data_Fail_Retry");
                break;
            case ASICompressionError:
                self.errorMessage = ASLocalizedString(@"Data_Fail_Retry");
                break;
            case 400:
                self.errorMessage = ASLocalizedString(@"Data_Fail_Retry");
                break;
            case 401:
                self.errorMessage = ASLocalizedString(@"KDInviteColleaguesViewController_server_error");
                break;
            case 402:
                self.errorMessage = ASLocalizedString(@"KDInviteColleaguesViewController_server_error");
                break;
            case 403:
            case 406:
                self.errorMessage = ASLocalizedString(@"Data_Fail_Retry");
                break;
            case 404:
                self.errorMessage = ASLocalizedString(@"Data_Fail_Retry");
                break;
            case 500:
            case 501:
            case 502:
            case 503:
            default:
                self.errorMessage = ASLocalizedString(@"KDInviteColleaguesViewController_server_error");
                break;
        }
        BOSERROR(@"action:(%@),errorCode:%d,errorMessage:%@",NSStringFromSelector(_action_),_errorCode_,_errorMessage_);
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (_target_ && [_target_ respondsToSelector:_action_]) {
        [_target_ performSelector:_action_ withObject:self withObject:object];
    }
#pragma clang diagnostic pop
}

#pragma mark - set method

-(void)setBaseUrlString:(NSString *)baseUrlString
{
    if (_baseUrlString_ != baseUrlString) {
        _baseUrlString_ = baseUrlString;
    }
}

-(void)setOAuthInfo:(BOSConnectAuthDataModel *)oauthInfo
{
    if (_connectOAuthInfo_ != oauthInfo) {
        _connectOAuthInfo_ = oauthInfo;
    }
}

-(void)setDesKey:(NSString *)desKey
{
    if (_desKey_ != desKey) {
        _desKey_ = desKey;
    }
}

#pragma mark - util methods

- (NSString *)checkNullOrNil:(NSString *)str
{
    if ([str isKindOfClass:[NSNull class]] || str == nil) {
        return @"";
    }
    return str;
}

+ (void)setUAWithAppId:(int)appId name:(NSString *)instanceName
{
    if (appId < 0 || instanceName == nil) {
        return;
    }
    userAgent = [[NSString alloc] initWithFormat:@"%@;%d/%@",defaultUserAgent,appId,instanceName];
}

+ (NSString *)userAgent
{
    return userAgent != nil ? userAgent : defaultUserAgent;
}

@end
