//
//  KDDownloadManager.h
//  kdweibo
//
//  Created by Tan yingqi on 8/1/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDRequestWrapper.h"
#import "KDMockDownloadListener.h"

@interface KDDownloadManager : NSObject<KDRequestWrapperDelegate> {
@private
    NSMutableArray *pendingDownloads_;
    NSMutableArray *runningDownloads_;
    NSMutableArray  *downloadProgressListeners_;    
}

+ (KDDownloadManager *) sharedDownloadManager;
- (void) addDownload:(KDDownload *)download;
- (void) cancleDownload:(KDDownload *)download;
- (void) addListener:(KDMockDownloadListener *)listener;
- (void) removeListener:(KDMockDownloadListener *)listener;
@end
