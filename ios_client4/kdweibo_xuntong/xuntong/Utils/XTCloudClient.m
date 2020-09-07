//
//  XTCloudClient.m
//  XT
//
//  Created by kingdee eas on 13-10-23.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTCloudClient.h"
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


@interface XTCloudClient()

@property (nonatomic,copy) NSString *baseURL;

@end

@implementation XTCloudClient

- (id)init
{
    self = [super init];
    if (self) {
        //要不要去掉networkId ?
        _baseURL = [NSString stringWithFormat:@"%@/%@", [KDWeiboServicesContext defaultContext].serverSNSBaseURL, [KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId];
//        _baseURL = [NSString stringWithFormat:@"%@", [KDWeiboServicesContext defaultContext].serverSNSBaseURL];
    }
    return self;
}

#pragma mark ASIHttpRequestDelegate

//开始执行异步请求
- (void)didStartASynchronousRequest
{
    self.request.timeOutSeconds = KDRequestTimeOut;
    [self.request setDelegate:self];
    [self.request setRequestMethod:@"GET"];
    //签名
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    id<KDConfiguration> conf = [[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance];
    [self.request signRequestWithClientIdentifier:[conf getOAuthConsumerKey]
                                           secret:[conf getOAuthConsumerSecret]
                                  tokenIdentifier:userManager.accessToken.keyToken
                                           secret:userManager.accessToken.secretToken
                                      usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];
    [self.request startAsynchronous];
}

- (void)didStartUploadQueue
{
    [self.uploadQueue setShowAccurateProgress:YES];
    self.uploadQueue.maxConcurrentOperationCount = 1;
    [self.uploadQueue go];
}

//终止请求
- (void)stopRequest
{
    [self.request clearDelegatesAndCancel];
}
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{

    if (self.isDownloadingFile) {
    }

}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.responseStatusCode != 200) {
        if ([self.requestType isEqualToString:@"getList"]) {
            [self alertFailedRequestWithErrorMsg:ASLocalizedString(@"XTCloudClient_GetInfo_Fail")];
        }
        else if ([self.requestType isEqualToString:@"collectFile"]) {
             [[NSNotificationCenter defaultCenter] postNotificationName:Notify_CollectFile object:Result_Fail];
        }
        else {
            if (self.isDownloadingFile) {
                if ([self.delegate respondsToSelector:@selector(KDCloudAPI:didFailedDownloadWithError:)]) {
                    [self.delegate KDCloudAPI:self didFailedDownloadWithError:nil];
                }
                
                if (request.downloadDestinationPath) {
                    [ASIHTTPRequest removeFileAtPath:request.downloadDestinationPath error:nil];
                }
            }
            else{
                [self alertFailedRequestWithErrorMsg:ASLocalizedString(@"XTCloudClient_Fail")];
            }
         
        }
        return;
    }
    if (self.isDownloadingFile) {
        if ([self.delegate respondsToSelector:@selector(KDCloudAPI:didFinishedDownloadWithDownloadPath:)]) {
            [self.delegate KDCloudAPI:self didFinishedDownloadWithDownloadPath:self.downloadPath];
        }else
        {
            finishBlock block = request.userInfo[@"ResultHandler"];
            if (block) {
                block(request.userInfo[@"downloadUrl"], YES);
            }

        }
    }
    else {
        BOSDEBUG(@"\nResponse:%@",[request responseString]);
        NSError *error;
        NSData *data = [[request responseString] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *responeData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:&error];
        
        //获取文件列表
        if ([self.requestType isEqualToString:@"getList"]) {
            NSArray *docBoxs = [responeData objectForKey:@"docBoxs"];
            NSArray *docInfos = [responeData objectForKey:@"docInfos"];
            NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[docBoxs,docInfos] forKeys:@[@"docBoxs",@"docInfos"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:Notify_FileList object:nil userInfo:dict];
        }
        //收藏文件
        else if ([self.requestType isEqualToString:@"collectFile"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:Notify_CollectFile object:Result_Success];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    BOSDEBUG(@"requestFailed:%@ - %d",error,error.code);
    if ([self.delegate respondsToSelector:@selector(KDCloudAPI:didFailedDownloadWithError:)]) {
        [self.delegate KDCloudAPI:self didFailedDownloadWithError:error];
    }
}

//根据目录ID获取其内容
-(void)getFileListByFolderId:(NSString *)folderId pageIndex:(int)pageIndex
{
    self.folderId = folderId;
    NSString *requestUrl = [NSString stringWithFormat:@"%@/document/myDocs.json?docBoxId=%@&sort=1&desc=true&pageSize=%d&pageIndex=%d",_baseURL,folderId,PageSize,pageIndex];
    BOSDEBUG(@"getFileListByFolderId:%@",requestUrl);
    NSURL *url = [NSURL URLWithString:requestUrl];
    self.request = [ASIHTTPRequest requestWithURL:url];
    self.isDownloadingFile = NO;
    self.requestType = @"getList";
    [self performSelectorOnMainThread:@selector(didStartASynchronousRequest) withObject:nil waitUntilDone:NO];
}

//收藏文件
-(void)collectFile:(NSString *)fileId andFoldId:(NSString *)foldId
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/document/myDoc/add.json?docId=%@&docBoxId=%@", _baseURL, fileId, foldId];
    BOSDEBUG(@"collectFile:%@",requestUrl);
    NSURL *url = [NSURL URLWithString:requestUrl];
    self.request = [ASIHTTPRequest requestWithURL:url];
    self.isDownloadingFile = NO;
    self.requestType = @"collectFile";
    [self performSelectorOnMainThread:@selector(didStartASynchronousRequest) withObject:nil waitUntilDone:NO];
}

//下载文件
-(void)downLoadFileByFile:(FileModel *)file
{
    self.fileModel = file;
    NSString *requestUrl = [NSString stringWithFormat:@"%@/docrest/doc/user/downloadfile",[[KDWeiboServicesContext defaultContext] serverBaseURL]];
    BOSDEBUG(@"downLoadFileByFile:%@",requestUrl);
    requestUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                       (CFStringRef)requestUrl,
                                                                                       (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                                                       NULL,
                                                                                       kCFStringEncodingUTF8));
    NSURL *url = [NSURL URLWithString:requestUrl];
    self.request = [ASIFormDataRequest requestWithURL:url];
    self.downloadPath = [[ContactUtils fileFilePath] stringByAppendingFormat:@"/%@.%@", file.fileId,file.ext];
    
    NSString *tempPath = [[ContactUtils fileTempFilePath] stringByAppendingFormat:@"/%@.%@", file.fileId,file.ext];
    [self.request setPostBody:[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:file.fileId,@"fileId",[[NSString alloc] initWithFormat:@"%@/%@;%@ %@;Apple;%@",XuntongAppClientId,[KDCommon clientVersion],[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion,[UIDevice platform]],@"ua",[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId,@"networkId", nil] options:NSJSONWritingPrettyPrinted error:nil]]];
    [self.request setRequestMethod:@"POST"];
    [self.request addRequestHeader:@"openToken" value:[BOSConfig sharedConfig].user.token];
    [self.request addRequestHeader:@"Content-Type" value:@"application/json"];
    [self.request setTemporaryFileDownloadPath:tempPath];
    [self.request setDownloadProgressDelegate:self.progressDelegate];
    [self.request setDownloadDestinationPath:self.downloadPath];
    self.request.showAccurateProgress = YES;
    self.request.allowCompressedResponse = NO;
    [self.request setAllowResumeForFileDownloads:YES];
    self.isDownloadingFile = YES;
    self.requestType = @"downloadFile";

    
    dispatch_async(dispatch_get_main_queue(), ^{
                      
        self.request.timeOutSeconds = KDRequestTimeOut;
        [self.request setDelegate:self];
        [self.request startAsynchronous];
        
    });
}


-(void)downLoadFileByFileUrl:(FileModel *)file
{
    self.fileModel = file;
    NSString *requestUrl =file.fileDownloadUrl;
    BOSDEBUG(@"downLoadFileByFile:%@",requestUrl);
    
    requestUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                (CFStringRef)requestUrl,
                                                                                (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                                                NULL,
                                                                                kCFStringEncodingUTF8));
    NSURL *url = [NSURL URLWithString:requestUrl];
    self.request = [ASIFormDataRequest requestWithURL:url];
    self.downloadPath = [[ContactUtils fileFilePath] stringByAppendingFormat:@"/%@.%@", file.fileId,file.ext];
    
    NSString *tempPath = [[ContactUtils fileTempFilePath] stringByAppendingFormat:@"/%@.%@", file.fileId,file.ext];
//    [self.request setPostBody:[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:file.fileId,@"fileId",[[NSString alloc] initWithFormat:@"%@/%@;%@ %@;Apple;%@",XuntongAppClientId,[KDCommon clientVersion],[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion,[UIDevice platform]],@"ua",[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId,@"networkId", nil] options:NSJSONWritingPrettyPrinted error:nil]]];
    [self.request setRequestMethod:@"GET"];
    [self.request addRequestHeader:@"openToken" value:[BOSConfig sharedConfig].user.token];
    [self.request addRequestHeader:@"Content-Type" value:@"application/json"];
    [self.request setTemporaryFileDownloadPath:tempPath];
    [self.request setDownloadProgressDelegate:self.progressDelegate];
    [self.request setDownloadDestinationPath:self.downloadPath];
    self.request.showAccurateProgress = YES;
    self.request.allowCompressedResponse = NO;
    [self.request setAllowResumeForFileDownloads:YES];
    self.isDownloadingFile = YES;
    self.requestType = @"downloadFile";
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.request.timeOutSeconds = KDRequestTimeOut;
        [self.request setDelegate:self];
        [self.request startAsynchronous];
        
    });
}



#pragma mark - Alert
- (void)alertFailedRequestWithErrorMsg:(NSString *)errorMsg
{
    BOSDEBUG(@"KDCloudAPI request failed.");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTCloudClient_Tip")message:errorMsg delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
}

@end

