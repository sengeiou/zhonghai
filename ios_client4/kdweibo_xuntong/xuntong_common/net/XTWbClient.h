//
//  XTWbClient.h
//  kdweibo
//
//  Created by bird on 14-10-15.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "MCloudClient.h"
#import "BOSConnect.h"

#define WB_DOC_DownLoadFile     @"docrest/doc/user/downloadfile"
#define WB_DOC_StowFile         @"/docrest/doc/user/stowfile"
#define WB_DOC_CancelStowFile   @"/docrest/doc/user/cancelStow"
#define WB_DOC_ShowMyDoc        @"/docrest/doc/user/showmydoc"
#define WB_DOC_MyDocs           @"/docrest/doc/user/myDocs"
#define WB_DOC_GetFileStowState @"/docrest/doc/user/isFileStowed"
#define WB_FILE_ListMessageFile    @"/docrest/doc/user/listmessagefile"
#define WB_FILE_ServenDayFile      @"/docrest/doc/user/servendayfile"
#define WB_DOC_ForwarDoc           @"/docrest/doc/user/forwardoc"
#define WB_FILE_MarkDocMessage     @"/docrest/doc/user/markdocmessgae"
#define WB_FILE_ShowAllUploadFile  @"/docrest/doc/user/showalluploadfile"
#define WB_FILE_ShowAllReadUsers   @"/docrest/doc/user/showallreadusers"
#define WB_FILE_FindDetailInfo     @"/docrest/doc/user/finddetailinfo"
#define WB_FILE_DeleteMyDoc        @"/docrest/doc/user/checkDelMyDoc"
#define WB_FILE_RemoveDownloadDoc  @"/docrest/doc/user/deldownload"

#define WB_FILE_UploadFile @"/docrest/doc/file/uploadfile"//上传文件url
//A.wang 获取文件url
#define WB_FILE_previewFile @"/docrest/doc/user/previewFile"

@interface XTWbClient : BOSConnect
- (void)stowFile:(NSString *)fileId networkId:(NSString *)networkId;
- (void)cancelStowFile:(NSString *)fileId;
- (void)getFileIsStow:(NSString *)fileId;
- (void)getFileListAtIndex:(NSInteger)index pageSize:(NSInteger)size type:(NSString *)type networkId:(NSString *)networkId isFromSharePlay:(BOOL)isFromSharePlay;
- (void)getMyFileAtIndex:(NSInteger)index pageSize:(NSInteger)size networkId:(NSString *)networkId docBox:(NSString *)docBox isFromSharePlay:(BOOL)isFromSharePlay;

//文件预览、下载、转发埋点 （针对消息里面的文件）
- (void)markDocMessageWithFileId:(NSString *)fileId
                          userId:(NSString *)userId
                       messageId:(NSString *)messageId
                       networkId:(NSString *)networkId
                        threadId:(NSString *)threadId;

//查询消息群组中该文件的查看次数和查看人列表
- (void)findDetailInfoWithFileId:(NSString *)fileId
                       networkId:(NSString *)networkId
                        threadId:(NSString *)threadId
                       messageId:(NSString *)messageId
                       pageIndex:(NSInteger)pageIndex
                        pageSize:(NSInteger)pageSize
                            desc:(BOOL)desc
                     dedicatorId:(NSString *)dedicatorId;

//查询 消息群组中某用户所有上传文件列表
- (void)showAllUploadFileWithNetworkId:(NSString *)networkId
                              threadId:(NSString *)threadId
                           dedicatorId:(NSString *)dedicatorId
                             pageIndex:(NSInteger)pageIndex
                              pageSize:(NSInteger)pageSize
;

//查询 消息群组中该文件的查看人员名单
- (void)showAllReadUsersWithFileId:(NSString *)fileId
                         networkId:(NSString *)networkId
                          threadId:(NSString *)threadId
                         pageIndex:(NSInteger)pageIndex
                          pageSize:(NSInteger)pageSize
                              desc:(NSString *)desc
                         messageId:(NSString *)messageId;


//消息里面跳转的文件界面借口
- (void)queryListMessageFileWithNetWorkId:(NSString *)networkId
                                 threadId:(NSString *)threadId
                                pageIndex:(NSInteger)pageIndex
                                 pageSize:(NSInteger)pageSize
                                  qryType:(NSInteger)type
                                     desc:(BOOL)desc;

- (void)querySevendayFileWithNetWorkId:(NSString *)networkId
                              threadId:(NSString *)threadId
                                  desc:(BOOL)desc;


-(void)makeDocWhenForwardDocWithFileId:(NSString *)fileId networkId:(NSString *)networkId threadId:(NSString *)threadId targetThreadId:(NSString *)targetId messageId:(NSString *)messageId;

// 删除我上传的文件
- (void)deleteMyDocWithDocId:(NSString *)docId
                    docTypes:(NSInteger)docType
                    docBoxId:(NSInteger)docBoxId
                   networkId:(NSString *)networkId
                      userId:(NSString *)userId;

// 移除我下载的文件
- (void)removeDownloadDocWithFileId:(NSString *)fileId
                          networkId:(NSString *)networkId
                             userId:(NSString *)userId;
//上传文件
// 可传[文件名: 二进制数据]
- (void)uploadFileWithNetworkId:(NSString *)networkId
                         userId:(NSString *)userId
                       fileDict:(NSDictionary *)fileDict;

//A.wang 在线预览
- (void)previewFile:(NSString *)fileId userId:(NSString *)userId;

@end
