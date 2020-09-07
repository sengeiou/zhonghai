//
//  XTExtComparator.h
//  XT
//
//  Created by kingdee eas on 13-11-4.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTFileUtils : NSObject

//后缀检测
+ (BOOL)canOpenFile:(NSString *)ext;
+ (BOOL)isFolder:(NSString *)ext;
+ (BOOL)isPhotoExt:(NSString *)ext;
+ (BOOL)isDocExt:(NSString *)ext;
+ (BOOL)isWordExt:(NSString *)ext;
+ (BOOL)isExcelExt:(NSString *)ext;
+ (BOOL)isPPTExt:(NSString *)ext;
+ (BOOL)isPDFExt:(NSString *)ext;
+ (BOOL)isZipExt:(NSString *)ext;
+ (BOOL)isMusicExt:(NSString *)ext;
+ (BOOL)isVideoExt:(NSString *)ext;
+ (BOOL)isTxtExt:(NSString *)ext;
+ (BOOL)isUseWPSOpenExt:(NSString *)ext;
+ (BOOL)isHtml:(NSString *)ext;
//缩略图匹配
+ (NSString *)thumbnailImageWithExt:(NSString *)ext;
+ (NSString *)fileTypeWithExt:(NSString *)ext needBig:(BOOL)big;
//文件夹
+ (NSString *)folderImage;
//文件大小
+ (NSString *)fileSize:(NSString *)size;
//文件归档
+ (NSString *)fixFolder:(NSString *)ext;


+ (NSString *)encrytypeFileTypeWithExt:(NSString *)ext encryed:(float)encryed;
@end
