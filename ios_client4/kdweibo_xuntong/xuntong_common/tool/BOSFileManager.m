//
//  BOSFileManager.m
//  Public
//
//  Created by Gil on 11-10-13.
//  Edited by Gil on 2012.09.11
//  Copyright 2011年 Kingdee.com. All rights reserved.
//

#import "BOSFileManager.h"
#import "BOSLogger.h"
#include <sys/xattr.h>

@implementation BOSFileManager

+ (NSString *)xuntongPath
{
    NSString *xuntongPath = [self fileFullPathAtDocumentsDirectory:@"xuntong"];
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    if (![defaultFileManager fileExistsAtPath:xuntongPath]) {
        [defaultFileManager createDirectoryAtPath:xuntongPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return xuntongPath;
}

+ (BOOL)fileExistAtXuntongPath:(NSString *)fileName
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[[self xuntongPath] stringByAppendingPathComponent:fileName]];
}

+ (NSString *)currentUserPathWithOpenId:(NSString *)openId
{
    NSParameterAssert(openId);
    NSString *userPath = [[self xuntongPath] stringByAppendingPathComponent:openId];
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    if (![defaultFileManager fileExistsAtPath:userPath]) {
        [defaultFileManager createDirectoryAtPath:userPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return userPath;
}

+ (NSString *)xuntongDBPathWithOpenId:(NSString *)openId
{
    return [[self currentUserPathWithOpenId:openId] stringByAppendingPathComponent:@"xt.db"];
}

+(BOOL)fileExistAtDocumentsDirectory:(NSString *)fileName_ {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	return [[NSFileManager defaultManager] fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:fileName_]];
}

+(NSString *)fileFullPathAtDocumentsDirectory:(NSString *)fileName_ {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName_];
}

+(BOOL)writeToFile:(id)fileData_ fileName:(NSString *)fileName_{
    if ([fileData_ isKindOfClass:[NSString class]]) {
        return [fileData_ writeToFile:[self fileFullPathAtDocumentsDirectory:fileName_] atomically:NO encoding:NSUTF8StringEncoding error:nil];
    }
    if ([fileData_ isKindOfClass:[NSData class]]) {
        return [fileData_ writeToFile:[self fileFullPathAtDocumentsDirectory:fileName_] atomically:NO];
    }
    return NO;
}

+(BOOL)writeImage:(NSData *)_image name:(NSString *)_imageName folder:(NSString *)_imageFolder updateTime:(NSString *)updateTime
{
    if (_imageFolder && ![self fileExistAtDocumentsDirectory:_imageFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[self fileFullPathAtDocumentsDirectory:_imageFolder] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *imageName = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)_imageName,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8 ));
	
    NSString *savedImagePath = nil;
    if (_imageFolder) {
        savedImagePath = [[self fileFullPathAtDocumentsDirectory:_imageFolder] stringByAppendingPathComponent:imageName];
    }else {
        savedImagePath = [self fileFullPathAtDocumentsDirectory:imageName];
    }
//    [imageName release];
    
    BOOL result = [_image writeToFile:savedImagePath atomically:NO];
    
    if (updateTime) {
        //修改最后修改时间
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [formatter dateFromString:updateTime];
        [[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:date,NSFileModificationDate,nil] ofItemAtPath:savedImagePath error:nil];
//        [formatter release];
    }
    
	return result;		
}

+(BOOL)imageExist:(NSString *)_imageName folder:(NSString *)_imageFolder
{
    NSString *imageName = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)_imageName,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8 ));
	NSString *savedImagePath = nil;
    if (_imageFolder) {
        savedImagePath = [[self fileFullPathAtDocumentsDirectory:_imageFolder] stringByAppendingPathComponent:imageName];
    }else {
        savedImagePath = [self fileFullPathAtDocumentsDirectory:imageName];
    }
//    [imageName release];
	return [[NSFileManager defaultManager] fileExistsAtPath:savedImagePath];
}

+(UIImage *)readImage:(NSString *)_imageName folder:(NSString *)_imageFolder
{
    NSString *imageName = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)_imageName,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8 ));
    NSString *imagePath = nil;
    if (_imageFolder) {
        imagePath = [[self fileFullPathAtDocumentsDirectory:_imageFolder] stringByAppendingPathComponent:imageName];
    }else {
        imagePath = [self fileFullPathAtDocumentsDirectory:imageName];
    }
//	[imageName release];
    
    return [[UIImage alloc] initWithContentsOfFile:imagePath];// autorelease];
}

+(NSString *)imageModificationDate:(NSString *)_imageName folder:(NSString *)_imageFolder
{
    if (![self imageExist:_imageName folder:_imageFolder]) {
        return @"1970-01-01 00:00:00";
    }
    
    NSString *imageName = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)_imageName,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8 ));
	NSString *savedImagePath = nil;
    if (_imageFolder) {
        savedImagePath = [[self fileFullPathAtDocumentsDirectory:_imageFolder] stringByAppendingPathComponent:imageName];
    }else {
        savedImagePath = [self fileFullPathAtDocumentsDirectory:imageName];
    }
//    [imageName release];
    
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:savedImagePath error:nil];
    
    //获取最后修改时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dict objectForKey:NSFileModificationDate];
    NSString *result = [formatter stringFromDate:date];
//    [formatter release];

    return result;
}

+(BOOL)deleteFileAtDocumentsDirectory:(NSString *)_fileName
{
    if ([self fileExistAtDocumentsDirectory:_fileName]) {
        return [[NSFileManager defaultManager] removeItemAtPath:[self fileFullPathAtDocumentsDirectory:_fileName] error:nil];
    }
    return NO;
}

+(BOOL)deleteAllFilesAtDocumentsDirectory
{
    BOOL result = YES;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (error == nil) {
        for (NSString *path in directoryContents) {
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
            BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
            if (!removeSuccess && result) {
                result = NO;
            }
        }
    } else {
        result = NO;
    }
    return result;
}

+(BOOL)resourcePathToDocumentsPath:(NSString *)folderName skipBackup:(BOOL)skipBackup
{
    NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:folderName];
    NSString *documentsPath = [self fileFullPathAtDocumentsDirectory:folderName];
    NSError *error = nil;
    
    if ([self fileExistAtDocumentsDirectory:folderName]) {//如果已存在此文件夹，则先备份至临时文件夹，拷贝新文件夹成功后删除备份。
        NSString *backupDocumentsPath = [self fileFullPathAtDocumentsDirectory:[NSString stringWithFormat:@"%@-backup",folderName]];//更改名称,作为临时备份
        [[NSFileManager defaultManager] moveItemAtPath:documentsPath toPath:backupDocumentsPath error:&error];
        if (error){
            BOSERROR(@"Error: %@", [error localizedDescription]);
            return NO;
        }
        //拷贝新文件夹
        [[NSFileManager defaultManager] copyItemAtPath:resourcePath toPath:documentsPath error:&error];
        if (skipBackup) {//设置文件夹的属性为不同步
            [self addSkipBackupAttributeToPath:documentsPath];
        }
        if (error){//失败时将临时文件夹改回来
            [[NSFileManager defaultManager] moveItemAtPath:backupDocumentsPath toPath:documentsPath error:nil];
            if (skipBackup) {//设置文件夹的属性为不同步
                [self addSkipBackupAttributeToPath:documentsPath];
            }
            BOSERROR(@"Error: %@", [error localizedDescription]);
            return NO;
        }
        //成功后，删除临时备份文件夹
        [[NSFileManager defaultManager] removeItemAtPath:backupDocumentsPath error:nil];
        return YES;
    }
    
    //如果不存在，则直接拷贝
    [[NSFileManager defaultManager] copyItemAtPath:resourcePath toPath:documentsPath error:&error];
    if (skipBackup) {//设置文件夹的属性为不同步
        [self addSkipBackupAttributeToPath:documentsPath];
    }
    if (error){
        BOSERROR(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    return YES;
}

+(long)sizeOfFile:(NSString *)_fileName
{
    if (![self fileExistAtDocumentsDirectory:_fileName]) {
        return 0;
    }
    
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self fileFullPathAtDocumentsDirectory:_fileName] error:&error];
    if (error) {
        BOSERROR(@"Error: %@", [error localizedDescription]);
        return 0;
    }
    BOSINFO(@"NSFileSize:%ld",[[attributes objectForKey:NSFileSize] longValue]);
    return [[attributes objectForKey:NSFileSize] longValue];
}

+(void)addSkipBackupAttributeToPath:(NSString*)path{
    u_int8_t b = 1;
    setxattr([path fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
}

+(NSString *)getSignInInfoTxtPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *xtPath = [BOSFileManager xuntongPath];
    NSString *filePath = [xtPath stringByAppendingPathComponent:@"signInInfo.txt"];;
    NSString *str = @"签到数据======\n";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    if (![fm fileExistsAtPath:filePath]) {
        // 新建
        [fm createFileAtPath:filePath contents:data attributes:nil];
    }
    
    return filePath;
}

@end
