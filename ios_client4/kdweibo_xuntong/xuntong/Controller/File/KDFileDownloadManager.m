//
//  KDFileDownloadManager.m
//  kdweibo
//
//  Created by fang.jiaxin on 2017/11/3.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDFileDownloadManager.h"
#import "XTCloudClient.h"

@interface KDFileDownloadManager ()
@property (nonatomic,strong) XTCloudClient *fileClient;
@property (nonatomic,strong) FileModel *fileModel;
@property (nonatomic,copy) void(^resultBlock)(BOOL success);
@end

@implementation KDFileDownloadManager
+(KDFileDownloadManager *)shareManager
{
    static KDFileDownloadManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[KDFileDownloadManager alloc] init];
    });
    return _instance;
}

-(void)downloadFile:(FileModel *)fileModel result:(void (^)(BOOL success))resultBlock
{
    self.fileModel = fileModel;
    self.resultBlock = resultBlock;
    
    if(self.fileClient)
    {
        [self.fileClient stopRequest];
        self.fileClient = nil;
    }
    
    //已经下载完成的不需要再下载
    if([fileModel isFinished])
    {
        if(self.resultBlock)
            self.resultBlock(YES);
        return;
    }
    
    self.fileClient = [[XTCloudClient alloc] init];
    self.fileClient.delegate = self;
    if(fileModel.fileId.length == 0){
        // 若三方轻应用的文件没有fileId，临时生成一个，用于拼接存储下载文件的地址
        fileModel.fileId = [[NSString stringWithFormat:@"%@_%@",fileModel.fileDownloadUrl,fileModel.name] MD5DigestKey];
        [self.fileClient downLoadFileByFileUrl:fileModel];
    }else{
        [self.fileClient downLoadFileByFile:fileModel];
    }
}


-(void)cancelDownload
{
    if(self.fileClient)
    {
        [self.fileClient stopRequest];
        self.fileClient = nil;
        self.fileModel = nil;
        self.resultBlock = nil;
    }
}

#pragma mark - KDCloudAPIDelegate
//下载文件完成
-(void)KDCloudAPI:(XTCloudClient *)api didFinishedDownloadWithDownloadPath:(NSString *)downloadPath
{
    if(self.resultBlock)
        self.resultBlock(YES);
    self.fileClient = nil;
}

//请求失败
-(void)KDCloudAPI:(XTCloudClient *)api didFailedDownloadWithError:(NSError *)error
{
    if(self.resultBlock)
        self.resultBlock(NO);
    self.fileClient = nil;
}

@end
