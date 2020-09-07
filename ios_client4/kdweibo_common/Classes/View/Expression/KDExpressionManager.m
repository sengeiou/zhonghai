//
//  KDExpressionManager.m
//  kdweibo_common
//
//  Created by DarrenZheng on 14-8-25.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "KDExpressionManager.h"
#import "KDExpressionCodeXiaoluo.h"
#import "KDExpressionCodeYuki.h"

@implementation KDExpressionManager

+ (NSString *)fileNameOfFileId:(NSString *)fileId
{
    NSString *fileName = [KDExpressionCodeXiaoluo fileNameOfFileId:fileId];
    if (fileName) {
        return fileName;
    }
    
    fileName = [KDExpressionCodeYuki fileNameOfFileId:fileId];
    if (fileName) {
        return fileName;
    }

    return nil;
}

+ (NSString *)fileIdOfExpressionCode:(NSString *)code expresstionType:(KDExpresstionType)type
{
    NSString *strResult = nil;
    switch (type) {
        case KDExpresstionTypeXiaoluo:
            strResult = [KDExpressionCodeXiaoluo fileIdOfExpressionCode:code];
            break;
        case KDExpresstionTypeYuki:
            strResult = [KDExpressionCodeYuki fileIdOfExpressionCode:code];
            break;
        default:
            break;
    }
    
    return strResult;
}

+ (NSString *)fileNameOfExpressionCode:(NSString *)code expresstionType:(KDExpresstionType)type
{
    NSString *strResult = nil;
    switch (type) {
        case KDExpresstionTypeXiaoluo:
            strResult = [KDExpressionCodeXiaoluo fileNameOfExpressionCode:code];
            break;
        case KDExpresstionTypeYuki:
            strResult = [KDExpressionCodeYuki fileNameOfExpressionCode:code];
            break;
        default:
            break;
    }
    
    return strResult;
    
}

@end