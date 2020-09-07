//
//  KDRequestWrapper.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-9.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDRequestWrapper.h"

#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest+OAuth.h"

#import "KDXAuthAuthorization.h"

#import "KDConfigurationContext.h"
#import "KDUtility.h"
#import "NSString+Additions.h"
#import "OpenUDID.h"

NSString * const KKDDownloadFinished = @"isFinished";
NSString * const kKDImageScaleSizeKey = @"scaleSize";
NSString * const kKDIsRequestImageSourceKey = @"isRequestImageSource";
NSString * const kKDRequestImageCropTypeKey = @"imageCropType";

NSString * const kKDCustomUserInfoKey = @"customUserInfo";

@interface KDRequestWrapper ()

@property (nonatomic, retain) ASIHTTPRequest *httpRequest;

@end


@implementation KDRequestWrapper

@synthesize delegate=delegate_;

@synthesize authorization=authorization_;

@synthesize url=url_;
@synthesize method=method_;
@synthesize parameters=parameters_;
@synthesize requestHeaders=requestHeaders_;

@synthesize APIIdentifier=APIIdentifier_;
@synthesize priority=priority_;
@synthesize tag=tag_;

@synthesize httpRequest=httpRequest_;
@dynamic progressMonitor;

@synthesize isDownload=isDownload_;
@synthesize downloadDestinationPath=downloadDestinationPath_;
@dynamic downloadTemporaryPath;

@dynamic fingerprint;
@synthesize userInfo=userInfo_;

@synthesize didCompleteBlock=didCompleteBlock_;
@synthesize configBlock=configBlock_;

- (id) init {
    self = [super init];
    if(self){
        delegate_ = nil;
        
        authorization_ = nil;
        
        url_ = nil;
        method_ = nil;
        parameters_ = nil;
        requestHeaders_ = nil;
        
        APIIdentifier_ = KDAPIUndefined;
        priority_ = KDRequestPriorityNormal;
        tag_ = 0;
        
        httpRequest_ = nil;
        progressMonitor_ = nil;
        
        isDownload_ = NO;
        downloadTemporaryPath_ = nil;
        downloadDestinationPath_ = nil;
        
        userInfo_ = nil;
        
        didCompleteBlock_ = nil;
    }
    
    return self;
}

- (id) initWithURL:(NSString *)url method:(KDRequestMethod *)method parameters:(NSArray *)parameters requestHeaders:(NSDictionary *)requestHeaders {
    self = [self init];
    if(self){
        url_ = url;// retain];
        method_ = method;// retain];
                   parameters_ = parameters ;//retain];
                                  requestHeaders_ = requestHeaders;// retain];
    }
    
    return self;
}

- (id) initWithDelegate:(id<KDRequestWrapperDelegate>)delegate url:(NSString *)url method:(KDRequestMethod *)method parameters:(NSArray *)parameters requestHeaders:(NSDictionary *)requestHeaders identifier:(KDAPIIdentifer)identifier {
    self = [self initWithURL:url method:method parameters:parameters requestHeaders:requestHeaders];
    if(self){
        delegate_ = delegate;
        APIIdentifier_ = identifier;
    }
    
    return self;
}

//////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark User info

- (void) addUserInfoWithObject:(id)obj forKey:(NSString *)aKey {
	if(obj != nil && aKey != nil){
		if(userInfo_ == nil){
			userInfo_ = [[NSMutableDictionary alloc] init];
		}
        
        [userInfo_ setObject:obj forKey:aKey];
    }
}

- (void) removeUserInfoForKey:(NSString *)aKey {
	if(userInfo_ != nil && [userInfo_ count] > 0){
		[userInfo_ removeObjectForKey:aKey];
	}
}

- (void) removeAllUserInfo {
	if(userInfo_ != nil && [userInfo_ count] > 0){
		[userInfo_ removeAllObjects];
	}
}


////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark build http request

- (ASIPostFormat) postRequestFormDataFormat {
    BOOL containsFile = (parameters_ != nil && [KDRequestParameter containsFile:parameters_]) ? YES : NO;
    return containsFile ? ASIMultipartFormDataPostFormat : ASIURLEncodedPostFormat;
}

- (void) bindPostParametersToRequest:(ASIFormDataRequest *)request {
	if(parameters_ != nil){
        for(KDRequestParameter *param in parameters_){
            NSAssert(param.name != nil, @"The parameter name for POST request can not be nil.");
            
            if([param containsFile]){
                if([param isFile]){
                    [request addFile:param.filePath forKey:param.name];
                    
                }else {
                    [request addData:param.fileData forKey:param.name];
                }
                
            }else {
                [request addPostValue:param.value forKey:param.name];
            }
        }
	}
}

- (NSString *) bindGetParametersToURL:(NSString *)requestURL {
	NSString *newRequestURL = requestURL;
	if(parameters_ != nil && [parameters_ count] > 0){
		NSMutableString *pairs = [[NSMutableString alloc] init];
		
		NSInteger idx = 0;
		NSInteger count = [parameters_ count];
		
        for(KDRequestParameter *param in parameters_){
            NSAssert(param.name != nil, @"The parameter name for GET request can not be nil.");
            
            [pairs appendFormat:@"%@=%@", param.name, [param.value encodeAsURLWithEncoding:NSUTF8StringEncoding]];
			if(idx++ != count-1){
				[pairs appendString:@"&"];
			}
        }
        
        NSRange range = [newRequestURL rangeOfString:@"?" options:NSBackwardsSearch];
		NSString *format = (NSNotFound == range.location) ? @"?%@" : @"&%@";
        
		newRequestURL = [newRequestURL stringByAppendingFormat:format, pairs];
		
//		[pairs release];
        
        DLog(@"newRequestURL\n %@",newRequestURL);
        
	}
	
	return newRequestURL;
}

- (void) bindRequestHeaderFields {
    if(requestHeaders_ != nil && [requestHeaders_ count] > 0){
        NSEnumerator *enumerator = [requestHeaders_ keyEnumerator]; 
        NSString *key = nil;
        while((key = [enumerator nextObject]) != nil){
            [httpRequest_ addRequestHeader:key value:[requestHeaders_ objectForKey:key]];
        }
    }
    
    // TODO xxx if there are extra http request header fields, please put them at here
    // [httpRequest_ addRequestHeader:@"Accept" value:@"application/json"];
    static NSString *openUDID = nil;
    if(!openUDID || openUDID.length == 0) {
        openUDID = [OpenUDID value];
    }
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *appVersion = nil;
    NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    if (marketingVersionNumber && developmentVersionNumber) {
        if ([marketingVersionNumber isEqualToString:developmentVersionNumber]) {
            appVersion = marketingVersionNumber;
        } else {
            appVersion = [NSString stringWithFormat:@"%@ rv:%@",marketingVersionNumber,developmentVersionNumber];
        }
    } else {
        appVersion = (marketingVersionNumber ? marketingVersionNumber : developmentVersionNumber);
    }

    NSString *userAgentValue = [NSString stringWithFormat:@"deviceid:%@;os:iOS;osversion:%@;manufacturer:Apple;model:;network:;spn:;appversion:%@;screen:;", openUDID, @([UIDevice currentDevice].systemVersion.floatValue), appVersion];
    
    [httpRequest_ addRequestHeader:@"User-Agent" value:userAgentValue];
   
//    [request.requestHeaders setValue:@"81ba0dc3-39a0-11e6-8825-005056ac6b20" forKey:@"X-Requested-personId"];

}

- (void)bindRequestAuthorizationHeaderField {
    if(authorization_ != nil && [authorization_ isEnabled]){
        if(KDAuthorizationTypeXAuth == [authorization_ getAuthorizationType]){
            // Use thrid part oauth authorize, and skip KDAuthorization interface
            KDXAuthAuthorization *auth = (KDXAuthAuthorization *)authorization_;
            [httpRequest_ signRequestWithClientIdentifier:auth.consumerToken.keyToken
                                                   secret:auth.consumerToken.secretToken
                                          tokenIdentifier:auth.accessToken.keyToken
                                                   secret:auth.accessToken.secretToken
                                              usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];
            
        }else{
            // Just support basic authorization at now.
            NSString *authHeader = [authorization_ getAuthorizationHeader:self];
            [httpRequest_ addRequestHeader:@"Authorization" value:authHeader];
        }
    }
}

- (void) buildGetRequest:(NSString *)url {
    NSString *requestURL = url;
    if(parameters_ != nil) {
        // bind GET parameters
        requestURL = [self bindGetParametersToURL:requestURL];
    }
    
    ASIHTTPRequest *req = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:requestURL]];
    req.timeOutSeconds = 20.0;
    self.httpRequest = req;
//    [req release];
}

- (void) buildPostRequest:(NSString *)url {
    ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
	req.timeOutSeconds = 30.0;
    
    // bind POST parameters
	req.postFormat = [self postRequestFormDataFormat];
    [self bindPostParametersToRequest:req];
    
    self.httpRequest = req;
//    [req release];
}

// Just support GET and POST request now
- (void) buildHttpRequest {
    if(httpRequest_ == nil){
        if([method_ isPostMethod]){
            [self buildPostRequest:url_];
            
        }else {
            [self buildGetRequest:url_];
        }
        
        httpRequest_.tag = tag_;
        
        // request method
        [httpRequest_ setRequestMethod:method_.name];
        
        // request header fields
        [self bindRequestHeaderFields];
        
        // authorization header field
        [self bindRequestAuthorizationHeaderField];
        
        // if the device support multitasking mode
        if([[UIDevice currentDevice] isMultitaskingSupported]) {
            httpRequest_.shouldContinueWhenAppEntersBackground = YES;
        }
    }
}

- (ASIHTTPRequest *) getHttpRequest {
    // before you try to do anything on request, 
    // please make sure did call method buildHttpRequest at least once.
    if(httpRequest_ == nil){
        [self buildHttpRequest];
    }
    
    return httpRequest_;
}

// This method just only support POST action
// And try to collect all parameters content length
- (KDUInt64) postDataContentLength {
    KDUInt64 contentLength = 0;
    if([method_ isPostMethod] && parameters_ != nil){
        for(KDRequestParameter *param in parameters_){
            contentLength += [param postContentLength];
        }
    }
    
    return contentLength;
}


//////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark the fingerprint for request

- (void) generateRequestFingerprint {
    NSString *fingerprint = nil;
    if(APIIdentifier_ != KDAPIUndefined){
        fingerprint = [NSString stringWithFormat:@"%lu", (unsigned long)APIIdentifier_];
        
    }else {
        if(url_ != nil){
            fingerprint = [NSString stringWithFormat:@"%lu", (unsigned long)[url_ hash]];
            
        }else {
            fingerprint = [NSString stringWithFormat:@"%ld", time(NULL)];
        }
    }
    
    self.fingerprint = fingerprint;
}

- (void) setFingerprint:(NSString *)fingerprint {
    if(fingerprint_ != fingerprint){
//        [fingerprint_ release];
        fingerprint_ = [fingerprint copy];
    }
}

- (NSString *) fingerprint {
    if(fingerprint_ == nil){
        [self generateRequestFingerprint];
    }
    
    return fingerprint_;
}

- (KDRequestProgressMonitor *) progressMonitor {
    if(progressMonitor_ == nil){
        progressMonitor_ = [[KDRequestProgressMonitor alloc] initWithName:nil source:url_ maxBytes:NSURLResponseUnknownLength]; 
    }
    
    return progressMonitor_;
}

- (void) setDownloadTemporaryPath:(NSString *)downloadTemporaryPath {
    if(downloadTemporaryPath_ != downloadTemporaryPath){
//        [downloadTemporaryPath_ release];
        downloadTemporaryPath_ = downloadTemporaryPath;// retain];
    }
}

static NSUInteger kKDDownloadsGuardIndex = 0;

- (NSString *) downloadTemporaryPath {
    if(downloadTemporaryPath_ == nil){
        NSString *tempPath = [[KDUtility defaultUtility] searchDirectory:KDApplicationTemporaryDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];
        
        // generate an unique temporary filename at temporary directory
        NSString *filename = [NSString stringWithFormat:@"%ld_%@_%lu", time(NULL), [NSString randomStringWithWide:0x03], (unsigned long)kKDDownloadsGuardIndex++];
        self.downloadTemporaryPath = [tempPath stringByAppendingPathComponent:filename];
    }
    
    return downloadTemporaryPath_;
}

- (void) releaseBlocksOnMainThread {
    NSMutableArray *array = [NSMutableArray array];
    
    if(didCompleteBlock_ != nil){
        [array addObject:didCompleteBlock_];
        
//        [didCompleteBlock_ release];
        didCompleteBlock_ = nil;
    }
    
    if(configBlock_ != nil){
        [array addObject:configBlock_];
        
//        [configBlock_ release];
        configBlock_ = nil;
    }
    
    if([array count] > 0) {
        [[self class] performSelectorOnMainThread:@selector(releaseBlocks:) withObject:array waitUntilDone:[NSThread isMainThread]];
    }
}

// Always release the blocks on main thread
+ (void) releaseBlocks:(NSArray *)blocks {
    // the blocks will be release when this method did finish.
}

- (void) dealloc {
    delegate_ = nil;
    
    //KD_RELEASE_SAFELY(authorization_);
    
    //KD_RELEASE_SAFELY(url_);
    //KD_RELEASE_SAFELY(method_);
    //KD_RELEASE_SAFELY(parameters_);
    //KD_RELEASE_SAFELY(requestHeaders_);
    
    //KD_RELEASE_SAFELY(httpRequest_);
    //KD_RELEASE_SAFELY(progressMonitor_);
    
    //KD_RELEASE_SAFELY(downloadTemporaryPath_);
    //KD_RELEASE_SAFELY(downloadDestinationPath_);
    
    //KD_RELEASE_SAFELY(fingerprint_);
    //KD_RELEASE_SAFELY(userInfo_);
    
    [self releaseBlocksOnMainThread];
    
    //[super dealloc];
}

@end
