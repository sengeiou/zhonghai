//
//  KDMediaMessageHandler.h
//  kdweibo
//
//  Created by wenjie_lee on 16/8/23.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>






typedef void(^finishBlock)(NSString * downLoadUrl, BOOL success);

@interface KDMediaMessageHandler : ASINetworkQueue //<ASIHTTPRequestDelegate,ASIProgressDelegate>

//@property (nonatomic,weak) id delegate;
@property (nonatomic,strong) ASIHTTPRequest *request;//数据请求类
//@property (nonatomic,strong) ASINetworkQueue *uploadQueue;//上传队列
@property (nonatomic,strong) NSString *requestURL;//请求连接
@property (nonatomic,strong) NSString *requestType;//请求类型
@property (nonatomic,strong) NSString *code;//请求返回的代码
//@property (nonatomic,strong) NSString *description;//请求返回的描述
@property (nonatomic,strong) NSMutableData *resultData;
@property (nonatomic,assign) BOOL isDownloadingFile;//是否正在下载文件
@property (nonatomic,strong) NSString *downloadPath;

//进度条委托
@property (nonatomic,weak) id progressDelegate;
//调用数据
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *fileId;
@property (nonatomic,strong) NSString *folderId;
@property (nonatomic,strong) NSString *skey;
@property (nonatomic,strong) NSString *ext;
@property (nonatomic,strong) FileModel *fileModel;

+ (KDMediaMessageHandler*)sharedHandler;

-(void)downLoadFileByFile:(FileModel *)file finishBlock:(finishBlock) finishBlk;

@end
