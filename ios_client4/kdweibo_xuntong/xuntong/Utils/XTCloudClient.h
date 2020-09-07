//
//  XTCloudClient.h
//  XT
//
//  Created by kingdee eas on 13-10-23.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "FileModel.h"

#define KDThirdPartyRequestUrl2 @"http://cloud.kingdee.com/api/kdrive"

//广播名字
#define Notify_PutFile @"File_Notify_PutFile"
#define Notify_FileList @"File_Notify_FileList"
#define Notify_SubList @"File_Notify_SubList"
#define Notify_FileURL @"File_Notify_FileURL"
#define Notify_ShareFile @"File_Notify_ShareFile"
#define Notify_CollectFile @"File_Notify_CollectFile"
#define Notify_ForwardMessage @"File_Notify_ForwardMessage"
#define Notify_DeleteFile @"File_Notify_DeleteFile"

//收藏请求结果
#define Result_Success @"Success" 
#define Result_Fail @"Fail"

typedef void(^finishBlock)(NSString * downLoadUrl, BOOL success);

@interface XTCloudClient : NSObject <ASIHTTPRequestDelegate,ASIProgressDelegate>
@property (nonatomic,weak) id delegate;
@property (nonatomic,strong) ASIHTTPRequest *request;//数据请求类
@property (nonatomic,strong) ASINetworkQueue *uploadQueue;//上传队列
@property (nonatomic,strong) NSString *requestURL;//请求连接
@property (nonatomic,strong) NSString *requestType;//请求类型
@property (nonatomic,strong) NSString *code;//请求返回的代码
//@property (nonatomic,strong) NSString *description;//请求返回的描述
@property (nonatomic,strong) NSMutableData *resultData;
@property (nonatomic,assign) BOOL isDownloadingFile;//是否正在下载文件
@property (nonatomic,strong) NSString *downloadPath;

//进度条委托
@property (nonatomic,strong) id progressDelegate;
//调用数据
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *fileId;
@property (nonatomic,strong) NSString *folderId;
@property (nonatomic,strong) NSString *skey;
@property (nonatomic,strong) NSString *ext;
@property (nonatomic,strong) FileModel *fileModel;



//开始执行异步请求
-(void)didStartASynchronousRequest;
//开始上传队列
-(void)didStartUploadQueue;
//终止请求
-(void)stopRequest;


//根据目录ID获取其内容
-(void)getFileListByFolderId:(NSString *)folderId pageIndex:(int)pageIndex;
//收藏文件
-(void)collectFile:(NSString *)fileId andFoldId:(NSString *)foldId;
//下载文件
-(void)downLoadFileByFile:(FileModel *)file;
-(void)downLoadFileByFileUrl:(FileModel *)file;// 轻应用下载（如工作汇报附件）


@end

@protocol KDCloudAPIDelegate<NSObject>
//请求完成
-(void)KDCloudAPI:(XTCloudClient *)api didFinishedRequestWithResponeString:(NSString *)responeString;
//请求失败
-(void)KDCloudAPI:(XTCloudClient *)api didFailedRequestWithError:(NSError *)error;
@optional
//下载完成
-(void)KDCloudAPI:(XTCloudClient *)api didFinishedDownloadWithDownloadPath:(NSString *)downloadPath;
//请求失败
-(void)KDCloudAPI:(XTCloudClient *)api didFailedDownloadWithError:(NSError *)error;
@end
