//
//  FileModel.m
//  KingdeeCloudStorage
//
//  Created by Kingdee on 13-3-28.
//  Copyright (c) 2013年 Beny. All rights reserved.
//

#import "FileModel.h"
#import "ContactUtils.h"
#import "NSDictionary+Additions.h"
#import "NSDate+Additions.h"

@implementation FileModel

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id appId = [dict objectForKey:@"appId"];
        id name = [dict objectForKey:@"fileName"];
        id size = [dict objectForKey:@"length"];
        id ext = [dict objectForKey:@"fileExt"];
        id fileId = [dict objectForKey:@"id"];
        id uploadDate = [dict objectForKey:@"uploadDate"];
        id fileDownloadUrl = [dict objectForKey:@"fileDownloadUrl"];

        if (![appId isKindOfClass:[NSNull class]] && appId) {
            self.appId = appId;
        }
        if (![name isKindOfClass:[NSNull class]] && name) {
            self.name = name;
        }
        if (![size isKindOfClass:[NSNull class]] && size) {
            self.size = size;
        }
        if (![ext isKindOfClass:[NSNull class]] && ext) {
            self.ext = ext;
        }
        if (![fileId isKindOfClass:[NSNull class]] && fileId) {
            self.fileId = fileId;
        }
        if (![uploadDate isKindOfClass:[NSNull class]] && uploadDate) {
            self.uploadDate = [NSString stringWithFormat:@"%@", uploadDate];
        }
        
        if (![fileDownloadUrl isKindOfClass:[NSNull class]] && fileDownloadUrl) {
            self.fileDownloadUrl = fileDownloadUrl;
        }
        
    }
    return self;
}

- (NSDictionary *)dictionaryFromFileModel
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.fileId,@"file_id", self.name, @"name", self.size,@"size", self.ext,@"ext", self.uploadDate,@"uploadDate",self.fileDownloadUrl,@"fileDownloadUrl",nil];
    return dict;
}

- (MessageFileDataModel *)messageFileFromFileModel
{
    MessageFileDataModel *messageFile = [[MessageFileDataModel alloc] initWithDictionary:[self dictionaryFromFileModel]];
    return messageFile;
}

#pragma mark - Getter


-(BOOL)isFinished
{
    //第三方文件可能没fileid
    if (self.fileId.length == 0) {
        NSString *fileId = @"";
        fileId = [[NSString stringWithFormat:@"%@_%@",self.fileDownloadUrl,self.name] MD5DigestKey];
        NSString *filePath = [[ContactUtils fileFilePath] stringByAppendingFormat:@"/%@.%@", fileId,self.ext];
        BOOL isExit = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (isExit) {
            self.path = filePath;
        }
        return isExit;
    }
    
    NSString *path = [[ContactUtils fileFilePath] stringByAppendingFormat:@"/%@.%@", self.fileId,self.ext];;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        self.path = path;
        return YES;
    }
    return NO;
}

@end


@implementation FoldModel

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id name = [dict objectForKey:@"boxName"];
        id foldId = [dict objectForKey:@"id"];
        id fatherId = [dict objectForKey:@"fatherId"];
        id fileIds = [dict objectForKey:@"fileIds"];
        
        if (![name isKindOfClass:[NSNull class]] && name) {
            self.name = name;
        }
        if (![foldId isKindOfClass:[NSNull class]] && foldId) {
            self.foldId = foldId;
        }
        if (![fatherId isKindOfClass:[NSNull class]] && fatherId) {
            self.fatherId = fatherId;
        }
        if (![fileIds isKindOfClass:[NSNull class]] && fileIds) {
            self.fileIds = fileIds;
        }
        
    }
    return self;
}

@end

@implementation DocumentFileModel
- (id)initWithDictionary:(NSDictionary *)dict{

    return [self initWithDictionary:dict formType:0];
    
}

- (id)initWithDictionary:(NSDictionary *)dict formType:(int)type{
    
    self = [super init];
    
    if ([dict isKindOfClass:[NSNull class]] || dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    
    if (self) {
        self.fromType  = type;
        
        self.ownerName = [dict stringForKey:@"ownerName"];
        
        self.ownerId = [dict stringForKey:@"ownerId"];
        self.networkId = [dict stringForKey:@"networkId"];
        self.contentType = [dict stringForKey:@"contentType"];
        
        self.type = [dict stringForKey:@"type"];
        
        self.fileId = [dict stringForKey:@"fileId"];
        
        self.pkId = [dict stringForKey:@"id"];
        self.userId = [dict stringForKey:@"userId"];
        self.length = [dict uint64ForKey:@"length"];
        
        self.isDeleted = [dict boolForKey:@"delete"];
        
        self.fileName = [dict stringForKey:@"fileName"];
        self.fileExt = [dict stringForKey:@"fileExt"];
        self.time =[NSDate dateWithTimeIntervalSince1970:[dict doubleForKey:@"time"] / 1000];
        //A.wang uploadfile
        self.uploadDate =[dict objectForKey:@"uploadDate"];
        self.fileType = [dict stringForKey:@"fileType"];
        
        
    }
    
    return self;
}

- (NSDictionary *)dictionaryFromFileModel
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.fileId,@"file_id", self.fileName, @"name", [NSString stringWithFormat:@"%lu",(unsigned long)self.length],@"size", self.fileExt,@"ext", [self.time formatWithFormatter:KD_DATE_ISO_8601_LONG_FORMATTER],@"uploadDate", nil];
    return dict;
}
@end
