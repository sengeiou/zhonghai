//
//  ContactUtils.h
//  ContactsLite
//
//  Created by Gil on 12-11-14.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOSFileManager.h"
#import "BOSSetting.h"

#define kRecorderDirectoryName @"speechs"
#define kFileDirectoryName @"files"

#define UserDefaults_FirstLogin @"isFirstLogin"

extern NSDateFormatter *fullDateFormatter;
extern NSDateFormatter *shortDateFormatter;
extern NSDateFormatter *lastDateFormatter;

@class GroupDataModel;
@interface ContactUtils : NSObject

+ (NSString *)recordPath;
+ (NSString *)recordFilePath;
+ (NSString *)recordTempFilePath;
+ (NSString *)recordFilePathWithGroupId:(NSString *)groupId;

+ (NSString *)fileFilePath;
+ (NSString *)fileFilePathWithFileId:(NSString *)fileId;
+ (NSString *)fileTempFilePath;

+(NSString *)uuid;

+(NSData *)XOR80:(NSData *)sourceData;

+(NSString *)xtDateFormatter:(NSString *)fullDateString;
+(NSString *)xtDateFormatterAtTimeline:(NSString *)fullDateString;
//该方法去掉了年，只在二维码邀请里面调用。by zhongweijie
+(NSString *)xtDateFormatterAtTimelineExYear:(NSString *)fullDateString;

+ (NSString *)formatDateString:(NSString *)strDate;


@end
