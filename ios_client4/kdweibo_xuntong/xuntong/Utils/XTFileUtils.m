//
//  XTExtComparator.m
//  XT
//
//  Created by kingdee eas on 13-11-4.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTFileUtils.h"

@implementation XTFileUtils

+ (BOOL)canOpenFile:(NSString *)ext
{
    return [XTFileUtils isPhotoExt:ext] || [XTFileUtils isDocExt:ext] || [XTFileUtils isMusicExt:ext] ||
           [XTFileUtils isVideoExt:ext] || [XTFileUtils isTxtExt:ext] || [XTFileUtils isHtml:ext]? YES : NO;
}
static NSArray *useWPSOpenExts = nil;
+ (BOOL)isUseWPSOpenExt:(NSString *)ext
{
    if ([ext isKindOfClass:[NSNull class]] || ext.length == 0) {
        return NO;
    }
    if (useWPSOpenExts == nil) {
        useWPSOpenExts = @[@"dotx",@"dot",@"docm",@"dotm",@"xltx",@"xlt",@"xlsb",@"xlsm",@"xltm",@"xlam",@"xla",@"potx",@"pot",@"ppsx",@"pps",@"pptm",@"potm",@"ppsm",@"rtf"];
    }
    return [useWPSOpenExts containsObject:[ext lowercaseString]];
}
static NSArray *folderExts = nil;
+ (BOOL)isFolder:(NSString *)ext
{
    if ([ext isKindOfClass:[NSNull class]] || ext.length == 0) {
        return NO;
    }
    return [[ext lowercaseString] isEqualToString:@"folder"];
}

static NSArray *imageExts = nil;
+ (BOOL)isPhotoExt:(NSString *)ext
{
    if ([ext isKindOfClass:[NSNull class]] || ext.length == 0) {
        return NO;
    }
    if (imageExts == nil) {
        imageExts = @[@"png",@"jpeg",@"jpg",@"bmp",@"gif"];
    }
    return [imageExts containsObject:[ext lowercaseString]];
}

static NSArray *docExts = nil;
+ (BOOL)isDocExt:(NSString *)ext
{
    if ([ext isKindOfClass:[NSNull class]] || ext.length == 0) {
        return NO;
    }
    if (docExts == nil) {
        docExts = @[@"doc",@"docx",@"xls",@"xlsx",@"ppt",@"pptx",@"pdf",@"txt"];
    }
    return [docExts containsObject:[ext lowercaseString]];
}

static NSArray *wordExts = nil;
+ (BOOL)isWordExt:(NSString *)ext
{
    if ([ext isKindOfClass:[NSNull class]] || ext.length == 0) {
        return NO;
    }
    if (wordExts == nil) {
        wordExts = @[@"doc",@"docx"];
    }
    return [wordExts containsObject:[ext lowercaseString]];
}

static NSArray *excelExts = nil;
+ (BOOL)isExcelExt:(NSString *)ext
{
    if ([ext isKindOfClass:[NSNull class]] || ext.length == 0) {
        return NO;
    }
    if (excelExts == nil) {
        excelExts = @[@"xls",@"xlsx"];
    }
    return [excelExts containsObject:[ext lowercaseString]];
}

static NSArray *pptExts = nil;
+ (BOOL)isPPTExt:(NSString *)ext
{
    if ([ext isKindOfClass:[NSNull class]] || ext.length == 0) {
        return NO;
    }
    if (pptExts == nil) {
        pptExts = @[@"ppt",@"pptx"];
    }
    return [pptExts containsObject:[ext lowercaseString]];
}

+ (BOOL)isPDFExt:(NSString *)ext
{
    if ([ext isKindOfClass:[NSNull class]] || ext.length == 0) {
        return NO;
    }
    return [[ext lowercaseString] isEqualToString:@"pdf"];
}

static NSArray *zipExts = nil;
+ (BOOL)isZipExt:(NSString *)ext
{
    if ([ext isKindOfClass:[NSNull class]] || ext.length == 0) {
        return NO;
    }
    if (zipExts == nil) {
        zipExts = @[@"zip",@"rar"];
    }
    return [zipExts containsObject:[ext lowercaseString]];
}

static NSArray *musicExts = nil;
+ (BOOL)isMusicExt:(NSString *)ext
{
    if ([ext isKindOfClass:[NSNull class]] || ext.length == 0) {
        return NO;
    }
    if (musicExts == nil) {
        musicExts = @[@"mp3",@"wav"];
    }
    return [musicExts containsObject:[ext lowercaseString]];
}

static NSArray *videoExts = nil;
+ (BOOL)isVideoExt:(NSString *)ext
{
    if ([ext isKindOfClass:[NSNull class]] || ext.length == 0) {
        return NO;
    }
    if (videoExts == nil) {
        videoExts = @[@"mkv",@"mov",@"avi",@"wmv",@"mp4",@"rmvb",@"asf",@"swf",@"ts",@"mts",@"mpeg1",@"mpeg2",@"m4v",@"f4v",@"flv",@"3gp",@"rm"];
    }
    return [videoExts containsObject:[ext lowercaseString]];
}

+ (BOOL)isTxtExt:(NSString *)ext
{
    if ([ext isKindOfClass:[NSNull class]] || ext.length == 0) {
        return NO;
    }
    return [[ext lowercaseString] isEqualToString:@"txt"];
}

static NSString *htmlExts = nil;
+ (BOOL)isHtml:(NSString *)ext
{
    if ([ext isKindOfClass:[NSNull class]] || ext.length == 0) {
        return NO;
    }
    return [[ext lowercaseString] isEqualToString:@"html"];
}

//缩略图匹配
+ (NSString *)thumbnailImageWithExt:(NSString *)ext
{
    return [self fileTypeWithExt:ext needBig:NO];
}
+ (NSString *)fileTypeWithExt:(NSString *)ext needBig:(BOOL)big{

    NSString *imageName = nil;
    
    if ([ext isKindOfClass:[NSNull class]] || [ext isEqualToString:@""]) {
        imageName = @"file_icon_unknow_small";
    }
    else if ([XTFileUtils isTxtExt:ext]) {
        imageName = @"file_icon_text_small";
    }
    else if ([XTFileUtils isWordExt:ext]) {
        imageName = @"file_icon_doc_small";
    }
    else if ([XTFileUtils isExcelExt:ext]) {
        imageName = @"file_icon_xls_small";
    }
    else if ([XTFileUtils isPDFExt:ext]) {
        imageName = @"file_icon_pdf_small";
    }
    else if ([XTFileUtils isPPTExt:ext]) {
        imageName = @"file_icon_ppt_small";
    }
    else if ([XTFileUtils isZipExt:ext]) {
        imageName = @"file_icon_zip_small";
    }
    else if ([XTFileUtils isPhotoExt:ext]) {
        imageName = @"file_icon_img_small";
    }
    else if ([XTFileUtils isFolder:ext]) {
        imageName = @"doc_tip_file";
    }
    else if([XTFileUtils isMusicExt:ext]){
        imageName = @"file_icon_img_voice";
    }
    else if([XTFileUtils isVideoExt:ext]){
        imageName = @"file_icon_img_video";
    }
    else{
        imageName = @"file_icon_unknow_small";
    }
    
//    if (big) {
//        imageName = [imageName stringByAppendingString:@"_big"];
//    }
    imageName = [imageName stringByAppendingString:@".png"];
    return imageName;
}

+ (NSString *)encrytypeFileTypeWithExt:(NSString *)ext encryed:(float)encryed{
    
    NSString *imageName = nil;
    BOOL flag = YES;
    if ([ext isKindOfClass:[NSNull class]] || [ext isEqualToString:@""]) {
        imageName = @"file_icon_unknow_small";
        flag = NO;
    }
    else if ([XTFileUtils isWordExt:ext]) {
        imageName = @"file_icon_doc_small";
    }
    else if ([XTFileUtils isExcelExt:ext]) {
        imageName = @"file_icon_xls_small";
    }
    else if ([XTFileUtils isPDFExt:ext]) {
        imageName = @"file_icon_pdf_small";
    }
    else if ([XTFileUtils isPPTExt:ext]) {
        imageName = @"file_icon_ppt_small";
    }
    else if ([XTFileUtils isZipExt:ext]) {
        imageName = @"file_icon_zip_small";
    }
    else if ([XTFileUtils isPhotoExt:ext]) {
        imageName = @"file_icon_img_small";
        flag = NO;
    }
    else if ([XTFileUtils isFolder:ext]) {
        imageName = @"doc_tip_file";
        flag = NO;
    }
    else{
        imageName = @"file_icon_unknow_small";
        flag = NO;
    }
    
    if (encryed && flag) {
        imageName = [imageName stringByAppendingString:@"_lock"];
    }
    return imageName;
}


//文件夹
+ (NSString *)folderImage
{
    return @"doc_tip_file";
}

//文件大小
+ (NSString *)fileSize:(NSString *)size
{
    float fileSize = [size floatValue];
    NSArray *arr = @[@"B", @"K", @"M", @"G"];
    int i = 0;
    while(fileSize/1024.0 >= 1.0) {
        fileSize = fileSize / 1024.0;
        i++;
    }
    i = i > [arr count] ? (int)[arr count] : i;
    return [NSString stringWithFormat:@"%.2f %@", fileSize, arr[i]];
//    int sizeInteger = (int)[[NSString stringWithFormat:@"%.2f", fileSize] integerValue];
//    return [NSString stringWithFormat:fileSize - sizeInteger < 0.00001 ? @"%.0f %@" : @"%.2f %@", fileSize, arr[i]];
}

+(NSString *)fixFolder:(NSString *)ext
{
    if ([XTFileUtils isDocExt:ext]) {
        return @"1";
    }
    if ([XTFileUtils isPhotoExt:ext]) {
        return @"2";
    }
    if ([XTFileUtils isMusicExt:ext]) {
        return @"3";
    }
    if ([XTFileUtils isVideoExt:ext]) {
        return @"4";
    }
    return @"0";
}

@end
