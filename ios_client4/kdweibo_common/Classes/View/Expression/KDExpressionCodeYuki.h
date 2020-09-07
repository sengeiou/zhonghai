//
//  KDExpressionCodeYuki.h
//  kdweibo
//
//  Created by DarrenZheng on 14-7-28.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDExpressionCodeYuki : NSObject
+ (NSString *)imageNameToCodeString:(NSString *)imageName;
+ (NSString *)codeStringToImageName:(NSString *)codeStr;
+ (NSArray *)allCodeString;
+ (NSArray *)allFileIds;

+ (NSString *)fileIdOfExpressionCode:(NSString *)code;
+ (NSString *)fileNameOfExpressionCode:(NSString *)code;
+ (NSString *)fileNameOfFileId:(NSString *)fileId;
@end
