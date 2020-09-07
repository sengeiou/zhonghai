//
//  KDProgressModalViewController.h
//  kdweibo
//
//  Created by Tan yingqi on 8/1/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDDownload.h"
#import "KDDownloadListener.h"
#import "KDProgressView.h"

@class KDRequestProgressMonitor;
@class KDMockDownloadListener;
@interface KDProgressModalViewController : UIViewController <KDDownloadListener,UIWebViewDelegate>{
 @private
    KDDownload *download_;
    UIView *backView_;
    UIImageView *fileTypeIconImageView_;
    UILabel *fileNameLabel_;
    KDProgressView *progressView_;
    UILabel *percentLabel_;
    UILabel *currentVolumeLabel_;
    UIButton *backBtn_;
    UIButton *openAsBtn_;
    UIWebView *webView_;
    UIView    *loadingView_;
//    KDMockDownloadListener *mockDownloadListener_;
    UIDocumentInteractionController *docInteractionController_;
    
    BOOL isDownLoaded_;
}

@property (nonatomic, assign)KDMockDownloadListener *mockDownloadListener;

- (id) initWithDownload:(KDDownload *)download;
- (id) initWithDownLoadedDownload:(KDDownload *)download;

- (void)dismissSelf;

@end
