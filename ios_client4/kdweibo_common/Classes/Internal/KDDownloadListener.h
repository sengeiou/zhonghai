//
//  KDDownloadListener.h
//  kdweibo
//
//  Created by Tan yingqi on 8/1/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDDownload.h"
#import "KDRequestProgressMonitor.h"
@protocol KDDownloadListener <NSObject>
@optional

- (void)downloadStateDidChange:(KDDownload *)download;
- (void)downloadProgressDidChange:(KDRequestProgressMonitor *)monitor;

@end
