//
//  XTFilePreviewViewController.h
//  XT
//
//  Created by kingdee eas on 13-11-7.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"
#import "XTDataBaseDao.h"
#import "XTCloudClient.h"
#import "KDProgressView.h"
#import "KDWpsTool.h"

@class XTFileDetailViewController;
@protocol XTFileDetailViewControllerDelegate <NSObject>

@optional
- (void)fileForwardFinish:(XTFileDetailViewController *)controller;
- (void)controller:(XTFileDetailViewController *)controller downloadFinishedWithModel:(FileModel *)model;
@end

typedef NS_ENUM(NSInteger, XTFileDetailFunctionType) {
    XTFileDetailFunctionType_nomal,
    XTFileDetailFunctionType_count
};

typedef NS_ENUM(NSInteger, XTFileDetailButtonType) {
    XTFileDetailButtonType_default,
    XTFileDetailButtonType_open,
    XTFileDetailButtonType_download,
    XTFileDetailButtonType_makeDownloadAction
};

typedef enum : NSUInteger {
    XTFileDetailSourceTypeChat,
    XTFileDetailSourceTypeSearch
} XTFileDetailSourceType;

@class KDWebViewController;
@interface XTFileDetailViewController : UIViewController
@property (nonatomic,weak) id<XTFileDetailViewControllerDelegate> delegate;

@property (nonatomic,strong) FileModel *file;
@property (nonatomic,strong) XTCloudClient *client;
@property (nonatomic,strong) UIImageView *thumbnailPic;
@property (nonatomic,strong) UILabel *fileName;
@property (nonatomic,strong) UILabel *fileSize;
@property (nonatomic,strong) UIButton *downloadBtn;
@property (nonatomic,strong) UIButton *openBtn;
@property (nonatomic,strong) KDProgressView *progressView;//进度条
@property (nonatomic,strong) UILabel *unSupportTip;
//A.wang  在线预览文字
@property (nonatomic,strong) UILabel *viewOnlineLable;

@property (nonatomic,assign) BOOL isDownloading;
@property (nonatomic,assign) BOOL bShouldNotPopToRootVC;
@property (nonatomic,assign) BOOL isFromJSBridge;

@property (nonatomic, strong) UILabel *percentLabel;


@property (nonatomic,strong) KDWpsTool *wpsTool;
@property (nonatomic,strong) KDWebViewController *webController;

@property (nonatomic, assign) XTFileDetailFunctionType fileDetailFunctionType;
@property (nonatomic, strong) NSString *threadId;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSString *dedicatorId;//文件发送者（贡献者）id
@property (nonatomic, strong) PersonSimpleDataModel *dedicator;//文件发送者
@property (nonatomic, strong) UIButton *cancelDownloadBtn;
@property (nonatomic, assign) XTFileDetailSourceType fileDetailSourceType;//文件来源方式

@property (nonatomic,assign) XTFileDetailButtonType needDownLoadWhenViewWillAppear;

@property (nonatomic,assign) BOOL isFromSharePlayWPS;

@property (nonatomic, assign) BOOL isReadOnly;//是否只读文件,只读文件屏蔽右上角按钮


@property (nonatomic, copy) NSString *pubAccId;

- (id)initWithFile:(FileModel *)file;

@end
