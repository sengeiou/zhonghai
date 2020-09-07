//
//  KDMediaMessageHandler.m
//  kdweibo
//
//  Created by wenjie_lee on 16/8/23.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDMediaMessageHandler.h"
#import "ContactConfig.h"
#import "BOSSetting.h"
#import "BOSUtils.h"
#import "XTFileUtils.h"
#import "ContactUtils.h"
#import "KDWeiboServicesContext.h"
#import "KDCommunityManager.h"
#import "KDCommunity.h"
#import "KDConfigurationContext.h"
#import "ASIHTTPRequest+OAuth.h"
#import "BOSConfig.h"


//定义请求超时时间
#define KDRequestTimeOut 20
#define PageSize 20

@interface KDMediaMessageHandler()

@property (nonatomic,copy) NSString *baseURL;

@end


@implementation KDMediaMessageHandler

+ (KDMediaMessageHandler*)sharedHandler
{
    static dispatch_once_t onceToken;
    static KDMediaMessageHandler *_messageHandler;
    dispatch_once(&onceToken, ^{
        _messageHandler = [[KDMediaMessageHandler alloc] init];
        [_messageHandler setMaxConcurrentOperationCount:1];
        [_messageHandler setShouldCancelAllRequestsOnFailure:NO];
        [_messageHandler go];
    });
    return _messageHandler;
}

//- (id)init
//{
//    self = [super init];
//    if (self) {
//        //要不要去掉networkId ?
//        _baseURL = [NSString stringWithFormat:@"%@/%@", [KDWeiboServicesContext defaultContext].serverSNSBaseURL, [KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId];
//        //        _baseURL = [NSString stringWithFormat:@"%@", [KDWeiboServicesContext defaultContext].serverSNSBaseURL];
//    }
//    return self;
//}
//
//#pragma mark ASIHttpRequestDelegate
//
////开始执行异步请求
//- (void)didStartASynchronousRequest
//{
//    self.request.timeOutSeconds = KDRequestTimeOut;
//    [self.request setDelegate:self];
//    [self.request setRequestMethod:@"GET"];
//    //签名
//    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
//    id<KDConfiguration> conf = [[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance];
//    [self.request signRequestWithClientIdentifier:[conf getOAuthConsumerKey]
//                                           secret:[conf getOAuthConsumerSecret]
//                                  tokenIdentifier:userManager.accessToken.keyToken
//                                           secret:userManager.accessToken.secretToken
//                                      usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];
//    [self.request startAsynchronous];
//}
//
//- (void)didStartUploadQueue
//{
//    [self.uploadQueue setShowAccurateProgress:YES];
//    self.uploadQueue.maxConcurrentOperationCount = 1;
//    [self.uploadQueue go];
//}
//
////终止请求
//- (void)stopRequest
//{
//    [self.request clearDelegatesAndCancel];
//}
//- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
//    
//    if (self.isDownloadingFile) {
//    }
//    
//}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.responseStatusCode != 200) {
        if ([self.requestType isEqualToString:@"getList"]) {
//            [self alertFailedRequestWithErrorMsg:ASLocalizedString(@"XTCloudClient_GetInfo_Fail")];
        }
        else if ([self.requestType isEqualToString:@"collectFile"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:Notify_CollectFile object:Result_Fail];
        }
        else {
            if (self.isDownloadingFile) {
                if ([self.delegate respondsToSelector:@selector(KDCloudAPI:didFailedDownloadWithError:)]) {
//                    [self.delegate KDCloudAPI:self didFailedDownloadWithError:nil];
                }
                
                if (request.downloadDestinationPath) {
                    [ASIHTTPRequest removeFileAtPath:request.downloadDestinationPath error:nil];
                }
            }
            else{
//                [self alertFailedRequestWithErrorMsg:ASLocalizedString(@"XTCloudClient_Fail")];
            }
            
        }
        return;
    }
//    if (self.isDownloadingFile) {
//        if ([self.delegate respondsToSelector:@selector(KDCloudAPI:didFinishedDownloadWithDownloadPath:)]) {
////            [self.delegate KDCloudAPI:self didFinishedDownloadWithDownloadPath:self.downloadPath];
//        }else
//        {
//    if (request.userInfo) {
//        
//        int errorCode = [request responseStatusCode];
//        if (errorCode < 400) {//正常，无错误
//            errorCode = 0;
//        }
//        
//        id result = nil;
//        if (errorCode == 0) {
//            NSString *responseString = [request responseString];;
//            id jsonResult = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//            if (jsonResult) {
//                result = jsonResult;
//            }else{
//                errorCode = BOSConnectParseResponseError;
//            }
//        }
//        
//        BOSResultDataModel *sendResult = [[BOSResultDataModel alloc] initWithDictionary:result];
//        
        finishBlock block = request.userInfo[@"ResultHandler"];
        if (block) {
            block(request.userInfo[@"downloadUrl"], YES);
        }
//        }
//    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    BOSDEBUG(@"requestFailed:%@ - %ld",error,(long)error.code);
//    if ([self.fileDelegate respondsToSelector:@selector(KDCloudAPI:didFailedDownloadWithError:)]) {
//        [self.fileDelegate KDCloudAPI:nil didFailedDownloadWithError:error];
//    }
    
    finishBlock block = request.userInfo[@"ResultHandler"];
    if (block) {
        block(request.userInfo[@"downloadUrl"], NO);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadShortVideoFileFail" object:error];
}




//下载文件
-(void)downLoadFileByFile:(FileModel *)file finishBlock:(finishBlock) finishBlk
{
    
//    FileModel *fileModel = file;
    NSString *requestUrl = [NSString stringWithFormat:@"%@/docrest/doc/user/downloadfile",[[KDWeiboServicesContext defaultContext] serverBaseURL]];
    BOSDEBUG(@"downLoadFileByFile:%@",requestUrl);
    requestUrl = [requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:requestUrl];
    ASIHTTPRequest *request = [ASIFormDataRequest requestWithURL:url];
    self.downloadPath = [[ContactUtils fileFilePath] stringByAppendingFormat:@"/%@.%@", file.fileId,file.ext];
    
    NSString *tempPath = [[ContactUtils fileTempFilePath] stringByAppendingFormat:@"/%@.%@", file.fileId,file.ext];
    [request setPostBody:[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:file.fileId,@"fileId",[[NSString alloc] initWithFormat:@"%@/%@;%@ %@;Apple;%@",XuntongAppClientId,[KDCommon clientVersion],[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion,[UIDevice platform]],@"ua",[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId,@"networkId", nil] options:NSJSONWritingPrettyPrinted error:nil]]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"openToken" value:[BOSConfig sharedConfig].user.token];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setTemporaryFileDownloadPath:tempPath];
    [request setDownloadProgressDelegate:self.progressDelegate];
    [request setDownloadDestinationPath:self.downloadPath];
    request.showAccurateProgress = YES;
    request.allowCompressedResponse = NO;
    [request setAllowResumeForFileDownloads:YES];
//  /  self.isDownloadingFile = YES;
//    self.requestType = @"downloadFile";
    
    if (finishBlk) {
        request.userInfo = @{@"ResultHandler" : [finishBlk copy], @"downloadUrl" : self.downloadPath};
    }
    [request setShowAccurateProgress:YES];
    [request setTimeOutSeconds:KDRequestTimeOut];
    
    [self addOperation:request];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        request.timeOutSeconds = KDRequestTimeOut;
////        [self.request setDelegate:self];
//        [self.request startAsynchronous];
//        
//    });
    
}

//- (void)setProgress:(float)newProgress
//{
//    NSLog(@"------------------%f-----------------------------",newProgress);
//}

@end
