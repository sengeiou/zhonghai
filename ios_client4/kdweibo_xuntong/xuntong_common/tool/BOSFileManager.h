//
//  BOSFileManager.h
//  Public
//
//  Created by Gil on 11-10-13.
//  Edited by Gil on 2012.09.11
//  Copyright 2011年 Kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//文件管理相关方法
@interface BOSFileManager : NSObject {
}

+ (NSString *)xuntongPath;
+ (BOOL)fileExistAtXuntongPath:(NSString *)fileName;
+ (NSString *)currentUserPathWithOpenId:(NSString *)openId;
+ (NSString *)xuntongDBPathWithOpenId:(NSString *)openId;

/*
 @desc 判断应用的Documents文件夹下是否存在某个文件;
 @param fileName_; -- 文件名
 @return BOOL;
 */
+(BOOL)fileExistAtDocumentsDirectory:(NSString *)fileName_;

/*
 @desc 获取Documents文件夹下某个文件的完整路径;
 @param fileName_; -- 文件名
 @return 文件的完整路径;
 */
+(NSString *)fileFullPathAtDocumentsDirectory:(NSString *)fileName_;


/*
 @desc 文件写入，路径默认为Documents文件夹下的完整路径;
 @param fileData_; -- 需要写入的文件数据,可以为NSString、NSData
 @param fileName_; -- 保存的文件名
 @return 是否成功;
 */
+(BOOL)writeToFile:(id)fileData_ fileName:(NSString *)fileName_;

/*
 @desc 写入照片至特定文件夹，并且修改最后更新时间;
 @param _image; -- 需要写入的照片数据
 @param _imageName; -- 保存的照片名,可以直接使用ID,保存时会先进行编码
 @param _imageFolder; -- 保存至文件夹,在Documents文件夹下
 @param updateTime; -- 修改的最后更新时间
 @return 是否成功;
 */
+(BOOL)writeImage:(NSData *)_image name:(NSString *)_imageName folder:(NSString *)_imageFolder updateTime:(NSString *)updateTime;

/*
 @desc 判断特定文件夹下是否存在某文件;
 @param _imageName; -- 照片名,可以直接使用ID,会先进行编码
 @param _imageFolder; -- 文件夹,在Documents文件夹下
 @return BOOL;
 */
+(BOOL)imageExist:(NSString *)_imageName folder:(NSString *)_imageFolder;

/*
 @desc 读取特定文件夹下的照片;
 @param _imageName; -- 照片名,可以直接使用ID,会先进行编码
 @param _imageFolder; -- 文件夹,在Documents文件夹下
 @return 照片对象;
 */
+(UIImage *)readImage:(NSString *)_imageName folder:(NSString *)_imageFolder;

/*
 @desc 获取文件的最后更新时间;
 @param _imageName; -- 照片名,可以直接使用ID,会先进行编码
 @param _imageFolder; -- 文件夹,在Documents文件夹下
 @return 最后更新时间;
 */
+(NSString *)imageModificationDate:(NSString *)_imageName folder:(NSString *)_imageFolder;

/*
 @desc 删除Documents文件夹下的某一文件;
 @param _fileName; -- 要删除的文件名
 @return 是否成功;
 */
+(BOOL)deleteFileAtDocumentsDirectory:(NSString *)_fileName;

/*
 @desc 删除Documents文件夹下的所有文件;
 @return 是否成功;
 */
+(BOOL)deleteAllFilesAtDocumentsDirectory;

/*
 @desc 拷贝工程中的文件夹至Documents下;
 @param folderName; -- 要拷贝的文件名或目录名
 @param skipBackup; -- 是否跳过iCloud备份
 @return 是否成功;
 */
+(BOOL)resourcePathToDocumentsPath:(NSString *)folderName skipBackup:(BOOL)skipBackup;

/*
 @desc 返回Documents目录下文件的大小;
 @param _fileName; -- 文件名
 @return 文件大小;
 */
+(long)sizeOfFile:(NSString *)_fileName;

/*
 @desc 将某目录设置为iCloud不同步;
 @param path; -- 目录名
 @return void;
 */
+(void)addSkipBackupAttributeToPath:(NSString*)path;

+(NSString *)getSignInInfoTxtPath;

@end
