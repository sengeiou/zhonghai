//
//  XTWbClient.m
//  kdweibo
//
//  Created by bird on 14-10-15.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTWbClient.h"
#import "KDWeiboServicesContext.h"
#import "BOSConfig.h"
#import "KDConfigurationContext.h"

@implementation XTWbClient

- (id)initWithTarget:(id)target action:(SEL)action
{
    BOSConnectFlags connectFlags = {BOSConnect4DirectURL,BOSConnectNotEncryption,BOSConnectResponseAllowCompressed,BOSConnectRequestBodyNotCompressed,NO};
    self = [super initWithTarget:target action:action connectionFlags:connectFlags];

    if (self)
    {
        [super setBaseUrlString:[[KDWeiboServicesContext defaultContext] serverBaseURL]];
    }
    return self;
//    self = [super initWithTarget:target action:action];
//    if (self) {
//        self.urlType = BOSConnectUrlTypeSNSAPI;
//    }
//    return self;
}

- (void)stowFile:(NSString *)fileId networkId:(NSString *)networkId{

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
	[params setObject:[super checkNullOrNil:fileId] forKey:@"fileId"];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    
	[super post:WB_DOC_StowFile body:params header:[NSDictionary dictionaryWithObject:[BOSConfig sharedConfig].user.token forKey:@"openToken"]];
}

- (void)cancelStowFile:(NSString *)fileId{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[super checkNullOrNil:fileId] forKey:@"fileId"];
    [params setObject:[super checkNullOrNil:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId] forKey:@"networkId"];
    
    [super post:WB_DOC_CancelStowFile body:params header:[NSDictionary dictionaryWithObject:[BOSConfig sharedConfig].user.token forKey:@"openToken"]];
}

- (void)getFileIsStow:(NSString *)fileId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[super checkNullOrNil:fileId] forKey:@"fileId"];
    [params setObject:[super checkNullOrNil:[KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId] forKey:@"networkId"];
    
    [super post:WB_DOC_GetFileStowState body:params header:[NSDictionary dictionaryWithObject:[BOSConfig sharedConfig].user.token forKey:@"openToken"]];
}

- (void)getFileListAtIndex:(NSInteger)index pageSize:(NSInteger)size type:(NSString *)type networkId:(NSString *)networkId isFromSharePlay:(BOOL)isFromSharePlay{

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
	[params setObject:[NSNumber numberWithInteger:index] forKey:@"pageIndex"];
    [params setObject:[NSNumber numberWithInteger:size] forKey:@"pageSize"];
    [params setObject:[super checkNullOrNil:type] forKey:@"type"];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    [params setObject:[NSNumber numberWithBool:true] forKey:@"desc"];
    if(isFromSharePlay)
        [params setObject:@"ppt" forKey:@"fileExt"];
    
	[super post:WB_DOC_ShowMyDoc body:params header:[NSDictionary dictionaryWithObject:[BOSConfig sharedConfig].user.token forKey:@"openToken"]];
}

- (void)getMyFileAtIndex:(NSInteger)index pageSize:(NSInteger)size networkId:(NSString *)networkId docBox:(NSString *)docBox isFromSharePlay:(BOOL)isFromSharePlay{

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
	[params setObject:[NSNumber numberWithInteger:index] forKey:@"pageIndex"];
    [params setObject:[NSNumber numberWithInteger:size] forKey:@"pageSize"];
    [params setObject:[super checkNullOrNil:docBox] forKey:@"docBoxId"];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    [params setObject:[NSNumber numberWithBool:true] forKey:@"desc"];
    if(isFromSharePlay)
        [params setObject:@"ppt" forKey:@"fileExt"];
	[super post:WB_DOC_MyDocs body:params header:[NSDictionary dictionaryWithObject:[BOSConfig sharedConfig].user.token forKey:@"openToken"]];
    
}

- (void)queryListMessageFileWithNetWorkId:(NSString *)networkId threadId:(NSString *)threadId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize qryType:(NSInteger)type desc:(BOOL)desc{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    [params setObject:[super checkNullOrNil:threadId] forKey:@"threadId"];
    [params setObject:[NSNumber numberWithInteger:pageIndex] forKey:@"pageIndex"];
    [params setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:type] forKey:@"qryType"];
    [params setObject:[NSNumber numberWithBool:desc] forKey:@"desc"];
    
    KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
    NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
    [self setBaseUrlString:baseURL];
    [super post:WB_FILE_ListMessageFile body:params header:[self fileHeader]];
}

-(void)querySevendayFileWithNetWorkId:(NSString *)networkId threadId:(NSString *)threadId desc:(BOOL)desc {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    [params setObject:[super checkNullOrNil:threadId] forKey:@"threadId"];
    [params setObject:[NSNumber numberWithBool:desc] forKey:@"desc"];
    
    KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
    NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
    [self setBaseUrlString:baseURL];
    [super post:WB_FILE_ServenDayFile body:params header:[self fileHeader]];
}

-(NSDictionary *)fileHeader
{
    return @{@"openToken":[BOSConfig sharedConfig].user.token,@"Accept":@"application/json",@"Content-Type":@"application/json;charset=UTF-8"};
}

- (void)markDocMessageWithFileId:(NSString *)fileId userId:(NSString *)userId messageId:(NSString *)messageId networkId:(NSString *)networkId threadId:(NSString *)threadId
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    [params setObject:[super checkNullOrNil:threadId] forKey:@"threadId"];
    [params setObject:[super checkNullOrNil:messageId] forKey:@"messageId"];
    [params setObject:[super checkNullOrNil:fileId] forKey:@"fileId"];
    [params setObject:[super checkNullOrNil:userId] forKey:@"userId"];
    
    KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
    NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
    [self setBaseUrlString:baseURL];
    [super post:WB_FILE_MarkDocMessage body:params header:[self fileHeader]];
}

- (void)findDetailInfoWithFileId:(NSString *)fileId networkId:(NSString *)networkId threadId:(NSString *)threadId messageId:(NSString *)messageId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize desc:(BOOL)desc dedicatorId:(NSString *)dedicatorId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:7];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    [params setObject:[super checkNullOrNil:threadId] forKey:@"threadId"];
    [params setObject:[super checkNullOrNil:messageId] forKey:@"messageId"];
    [params setObject:[super checkNullOrNil:fileId] forKey:@"fileId"];
    [params setObject:@(pageIndex) forKey:@"pageIndex"];
    [params setObject:@(pageSize) forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"desc"];
    [params setObject:[super checkNullOrNil:dedicatorId] forKey:@"dedicatorId"];
    
    KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
    NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
    [self setBaseUrlString:baseURL];
    [super post:WB_FILE_FindDetailInfo body:params header:[self fileHeader]];
}

- (void)showAllUploadFileWithNetworkId:(NSString *)networkId
                              threadId:(NSString *)threadId
                           dedicatorId:(NSString *)dedicatorId
                             pageIndex:(NSInteger)pageIndex
                              pageSize:(NSInteger)pageSize{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:7];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    [params setObject:[super checkNullOrNil:threadId] forKey:@"threadId"];
    [params setObject:[super checkNullOrNil:dedicatorId] forKey:@"dedicatorId"];
    [params setObject:@(pageIndex) forKey:@"pageIndex"];
    [params setObject:@(pageSize) forKey:@"pageSize"];
    
    
    KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
    NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
    [self setBaseUrlString:baseURL];
    [super post:WB_FILE_ShowAllUploadFile body:params header:[self fileHeader]];
}

- (void)showAllReadUsersWithFileId:(NSString *)fileId networkId:(NSString *)networkId threadId:(NSString *)threadId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize desc:(NSString *)desc messageId:(NSString *)messageId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:7];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    [params setObject:[super checkNullOrNil:threadId] forKey:@"threadId"];
    [params setObject:[super checkNullOrNil:fileId] forKey:@"fileId"];
    [params setObject:@(pageIndex) forKey:@"pageIndex"];
    [params setObject:@(pageSize) forKey:@"pageSize"];
    [params setObject:[super checkNullOrNil:desc] forKey:@"desc"];
    [params setObject:[super checkNullOrNil:messageId] forKey:@"messageId"];
    
    KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
    NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
    [self setBaseUrlString:baseURL];
    [super post:WB_FILE_ShowAllReadUsers body:params header:[self fileHeader]];
}

-(void)makeDocWhenForwardDocWithFileId:(NSString *)fileId networkId:(NSString *)networkId threadId:(NSString *)threadId targetThreadId:(NSString *)targetId messageId:(NSString *)messageId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:fileId] forKey:@"fileId"];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    [params setObject:[super checkNullOrNil:threadId] forKey:@"threadId"];
    [params setObject:[super checkNullOrNil:targetId] forKey:@"fthreadIds"];
    [params setObject:[super checkNullOrNil:messageId] forKey:@"messageId"];
    
    [super post:WB_DOC_ForwarDoc body:params header:[self fileHeader]];
}

// 删除我上传的文件
- (void)deleteMyDocWithDocId:(NSString *)docId docTypes:(NSInteger)docType docBoxId:(NSInteger)docBoxId networkId:(NSString *)networkId userId:(NSString *)userId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:docId] forKey:@"docId"];
    [params setObject:@(docType) forKey:@"docType"];
    [params setObject:@(docBoxId) forKey:@"docBoxId"];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    [params setObject:[super checkNullOrNil:userId] forKey:@"userId"];
    
    [super post:WB_FILE_DeleteMyDoc body:params header:[self fileHeader]];
}

// 移除我下载的文件
- (void)removeDownloadDocWithFileId:(NSString *)fileId networkId:(NSString *)networkId userId:(NSString *)userId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[super checkNullOrNil:fileId] forKey:@"fileId"];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    [params setObject:[super checkNullOrNil:userId] forKey:@"userId"];
    
    [super post:WB_FILE_RemoveDownloadDoc body:params header:[self fileHeader]];
}
- (void)uploadFileWithNetworkId:(NSString *)networkId userId:(NSString *)userId fileDict:(NSDictionary *)fileDict {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:7];
    [params setObject:[super checkNullOrNil:networkId] forKey:@"networkId"];
    [params setObject:[super checkNullOrNil:userId] forKey:@"userId"];
    for (NSString *key in fileDict.allKeys) {
        id value = fileDict[key];
        if ([value isKindOfClass: [NSData class]]) {
            NSData *data = value;
            [params setObject:data forKey:key];
        }
    }
    
    [super post:WB_FILE_UploadFile body:params header:[self fileHeader]];
}

//A.wang 在线预览
- (void)previewFile:(NSString *)fileId userId:(NSString *)userId {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[super checkNullOrNil:fileId] forKey:@"fileId"];
    [params setObject:[super checkNullOrNil:userId] forKey:@"userId"];
    
    [super post:WB_FILE_previewFile body:params header:[self fileHeader]];
}
@end
