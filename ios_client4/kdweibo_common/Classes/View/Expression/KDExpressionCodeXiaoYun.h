//
//  KDExpressionCodeXiaoYun.h
//  kdweibo
//
//  Created by Darren Zheng on 7/10/16.
//  Copyright © 2016 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDExpressionCodeXiaoYun : NSObject
+ (NSString *)imageNameToCodeString:(NSString *)imageName;
+ (NSString *)codeStringToImageName:(NSString *)codeStr;
+ (NSArray *)allCodeString;
+ (NSArray *)allFileIds;
+ (NSArray *)allValues;

+ (NSString *)fileIdOfExpressionCode:(NSString *)code;
+ (NSString *)fileNameOfExpressionCode:(NSString *)code;
+ (NSString *)fileNameOfFileId:(NSString *)fileId;
@end
