//
//  FileModel.h
//  KingdeeCloudStorage
//
//  Created by Kingdee on 13-3-28.
//  Copyright (c) 2013年 Beny. All rights reserved.
//  文件模型

#import <Foundation/Foundation.h>
#import "XTDataBaseDao.h"
#import "RecordDataModel.h"

@protocol FileModelDelegate;

@interface FileModel : NSObject

@property (nonatomic,strong) id delegate;
@property (nonatomic,copy) NSString *appId;//新添加 任务1266
@property (nonatomic,copy) NSString *fileId;//文件ID
@property (nonatomic,copy) NSString *size;//文件大小
@property (nonatomic,copy) NSString *name;//档案名称
@property (nonatomic,copy) NSString *ext;//文件扩展名
@property (nonatomic,copy) NSString *uploadDate;
@property (nonatomic,copy) NSString *path;//本地存储路径
@property (nonatomic,copy) NSString *fileDownloadUrl;//第三方下载url
@property (nonatomic,assign) BOOL isFinished;//是否已经存在本地
@property (nonatomic,copy) NSString *type;

- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryFromFileModel;
- (MessageFileDataModel *)messageFileFromFileModel;

@end

@interface DocumentFileModel : NSObject
@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) NSString *ownerId;
@property (nonatomic, strong) NSString *networkId;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *fileId;
@property (nonatomic, strong) NSString *pkId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) NSUInteger length;
@property (nonatomic, assign) BOOL isDeleted;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileExt;
@property (nonatomic, strong) NSDate *time;

@property (nonatomic, assign) int fromType;  //0：我的下载，我的收藏，最近浏览使用  1：我上传的

//A.wang 上传文件
@property (nonatomic, copy) NSString *uploadDate;
@property (nonatomic, strong) NSString *fileType;
- (id)initWithDictionary:(NSDictionary *)dict;

- (id)initWithDictionary:(NSDictionary *)dict formType:(int)type;

- (NSDictionary *)dictionaryFromFileModel;
@end


@protocol FileModelDelegate

@optional
-(void)fileModel:(FileModel *)fileModel didFinishedDownloadFileWithPath:(NSString *)path;
-(void)fileModel:(FileModel *)fileModel didFailedDownloadFileWithError:(NSString *)error;

-(void)fileModeldidFinishedDeleteFile;
-(void)fileModelDidFailedDeleteFileWithError:(NSString *)error;

@end

@interface FoldModel : NSObject

@property (nonatomic,copy) NSString *foldId;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *fatherId;
@property (nonatomic,strong) NSArray *fileIds;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
