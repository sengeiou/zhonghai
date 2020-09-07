//
//  KDDownloadManager.m
//  kdweibo
//
//  Created by Tan yingqi on 8/1/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDDownloadManager.h"
#import "KDDownload.h"
#import "KDWeiboServices.h"
#import "KDWeiboServicesContext.h"

static const NSUInteger kKDDownloaderMaxConcurrencyCount = 0x01;
static KDDownloadManager *shareDownloadManager = nil;
@implementation KDDownloadManager

- (id) init {
    self = [super init];
    if (self) {
        pendingDownloads_ = [[NSMutableArray alloc] init];
        runningDownloads_ = [[NSMutableArray alloc] init];
    }
    return self;    
}

+ (KDDownloadManager *) sharedDownloadManager {
    @synchronized([KDDownloadManager class]){
        if(shareDownloadManager == nil) {
            shareDownloadManager = [[KDDownloadManager alloc] init];
        }
    }
    return shareDownloadManager;
}

-(BOOL) isRunningLoad:(KDDownload *)download {
    
    return runningDownloads_ && [runningDownloads_ count] >0 && [runningDownloads_ containsObject:download]; 
}

-(BOOL) isPendingLoad:(KDDownload *)download {
    
    return pendingDownloads_ && [pendingDownloads_ count] >0 && [pendingDownloads_ containsObject:download]; 
}

- (void)executeDownload:(KDDownload *)download {
        [runningDownloads_ addObject:download];
        id<KDWeiboServices> services = [[KDWeiboServicesContext defaultContext] getKDWeiboServices];
      [services startDownloadWithDownload:download delegate:self completionBlock:^(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed){
        if (failed) {
            [self downloadDidFaild:download];
        }else {
            [self downloadDidSuccess:download];
        }
        
    }];
        //[services startDownloadWithDownload:download delegate:self];
}

- (void) addDownload:(KDDownload *)download {
    if ([self isRunningLoad:download]) {
        return;
    } 
    if ([self isPendingLoad:download]) {
       //
        //放在队列最前面
//        download retain];
        [pendingDownloads_ removeObject:download];
        [pendingDownloads_ insertObject:download atIndex:0];
//        [download release];
        return;
    }
    if ([runningDownloads_ count] < kKDDownloaderMaxConcurrencyCount) {
        //[runningDownloads_ addObject:downloader];
        [self executeDownload:download];
    }else {
        [pendingDownloads_ addObject:download];
    }
}

- (KDDownload *)priorDownloader {
    if([pendingDownloads_ count] < 0x01) return nil;
    KDDownload *download = [pendingDownloads_ objectAtIndex:0x00];
    return download;
}

- (void)removeAll {
    [runningDownloads_ removeAllObjects];
    [pendingDownloads_ removeAllObjects];
}

//开始队列开始的download
- (void) startNextLoaderifNeed {
    KDDownload *download = [self priorDownloader];
    if(download != nil) {
        [self executeDownload:download];
        [pendingDownloads_ removeObject:download];  
    }else {
        [self removeAll];
    } 
}

- (void) removeDownloaderFromRunning:(KDDownload *)download {
    if ([self isRunningLoad:download]) {
        [runningDownloads_ removeObject:download];
    }
}

- (void) removeDownloaderFromPending:(KDDownload *)download {
    if ([self isPendingLoad:download]) {
        [pendingDownloads_ removeObject:download];
    }

}

//取消单个下载
- (void) cancleDownload:(KDDownload *)download {
    if ([self isRunningLoad:download ]) {
        id<KDWeiboServices> services = [[KDWeiboServicesContext defaultContext] getKDWeiboServices];
        [services cancleDownload:download];
        [self removeDownloaderFromRunning:download];
    }
    else if ([self isPendingLoad:download]) {
        [self removeDownloaderFromPending:download];

    }
    [download downloadCancled];
    [self NotifyListenerUpdateDownloadStateChange:download];
    
}

//取消所有下载
- (void) cancleAll {
     id<KDWeiboServices> services = [[KDWeiboServicesContext defaultContext] getKDWeiboServices];
    [services cancleAllDownloadWithDlegate:self];
    for (KDDownload * download in runningDownloads_) {
        //[downloader downloadDidCancled];
        [self cancleDownload:download];
    }
    for (KDDownload * download  in pendingDownloads_) {
        //[downloader downloadDidCancled];
        [self cancleDownload:download];
        
    }
    
    [self removeAll];
    
}

//暂停
- (void)pauseDownloader:(KDDownload *)downloader {
    
    
}

//暂停所有
- (void)pauseAllDownding {
    
    
}


//revoke listener 
- (void) NotifyListenerUpdateDownloadPrgress:(KDRequestProgressMonitor *) monitor {
    NSArray *tempArray = [NSArray arrayWithArray:downloadProgressListeners_];
    for (KDMockDownloadListener *mocklistener in tempArray) {
        if (mocklistener.listener && [mocklistener.listener respondsToSelector:@selector(downloadProgressDidChange:)]) {
            [mocklistener.listener performSelector:@selector(downloadProgressDidChange:) withObject:monitor];
        }
    }
}


- (void)NotifyListenerUpdateDownloadStateChange:(KDDownload *)download {
    NSArray *tempArray = [NSArray arrayWithArray:downloadProgressListeners_];
    for (KDMockDownloadListener *mocklistener in tempArray) {
        if (mocklistener.listener && [mocklistener.listener respondsToSelector:@selector(downloadStateDidChange:)]) {
            [mocklistener.listener performSelector:@selector(downloadStateDidChange:) withObject:download];
        }
    }
}


- (void)downloadDidFaild:(KDDownload *)download {
    [self removeDownloaderFromRunning:download];
    [download downloadFailed];
    [self NotifyListenerUpdateDownloadStateChange:download];
    [self startNextLoaderifNeed];
}

- (void)downloadDidSuccess:(KDDownload*)download {
    [self removeDownloaderFromRunning:download];
    [download downloadSucceed];
    [self NotifyListenerUpdateDownloadStateChange:download];
    [self startNextLoaderifNeed];
}

- (void)downloadRequestDidFailed:(KDRequestWrapper *)requestWrapper responseWrapper:(KDResponseWrapper *)responseWrapper {
    DLog(@"downloadFailed...");
    KDDownload *download = [[requestWrapper userInfo] objectForKey:kKDCustomUserInfoKey];
    [self downloadDidFaild:download];
    
}

- (void)downloadRequestDidCancled:(KDRequestWrapper *)requestWrapper {
    
    
}

- (void)downloadRequestSuccess:(KDRequestWrapper *)requestWrapper {
    KDDownload *download = [[requestWrapper userInfo] objectForKey:kKDCustomUserInfoKey];
    [self downloadDidSuccess:download];
  
}

#pragma mark - KDRequestWrapperDelegate 
- (void) didDropRequestWrapper:(KDRequestWrapper *)requestWrapper error:(NSError *)error {
  
}

- (void) requestWrapper:(KDRequestWrapper *)requestWrapper requestDidStart:(ASIHTTPRequest *)request {
   KDDownload *download = [[requestWrapper userInfo] objectForKey:kKDCustomUserInfoKey];
   // [downloader downloadDidStart];
    [download startDownload];
    [self NotifyListenerUpdateDownloadStateChange:download];
}

- (void) requestWrapper:(KDRequestWrapper *)requestWrapper request:(ASIHTTPRequest *)request didRecieveResponseHeaders:(NSDictionary *)responseHeaders{
    
}

- (void) requestWrapper:(KDRequestWrapper *)requestWrapper request:(ASIHTTPRequest *)request progressMonitor:(KDRequestProgressMonitor *)progressMonitor {
    
  
   // [downloader updateProgress:progressMonitor];
    [self NotifyListenerUpdateDownloadPrgress:progressMonitor];

}


//- (void) requestWrapper:(KDRequestWrapper *)requestWrapper responseWrapper:(KDResponseWrapper *)responseWrapper requestDidFinish:(ASIHTTPRequest *)request {
//    DLog(@"response code = %d requestCode == %d",responseWrapper.statusCode,[request responseStatusCode]);
//    if([responseWrapper isValidResponse]){
//        DLog(@"success...");
//        [self downloadRequestSuccess:requestWrapper];
//    } else {
//        [self downloadRequestDidFailed:requestWrapper responseWrapper:responseWrapper];
//    }
//}

#pragma mark - add & remove Listener
- (void)addListener:(KDMockDownloadListener *)listener {
    if (downloadProgressListeners_ == nil) {
        downloadProgressListeners_ = [[NSMutableArray alloc] init];
    }
    if (![downloadProgressListeners_ containsObject:listener]) {
        [downloadProgressListeners_ addObject:listener];
    }
}

- (void)removeListener:(KDMockDownloadListener *)listener {
    if (downloadProgressListeners_ != nil && listener!= nil) {
        if ([downloadProgressListeners_ containsObject:listener]) {
            [downloadProgressListeners_ removeObject:listener];
        }
    }
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(pendingDownloads_);
    //KD_RELEASE_SAFELY(runningDownloads_);
    //KD_RELEASE_SAFELY(downloadProgressListeners_);
    //[super dealloc];
}
@end
