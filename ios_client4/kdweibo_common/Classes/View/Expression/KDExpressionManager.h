//
//  KDExpressionManager.h
//  kdweibo_common
//
//  Created by DarrenZheng on 14-8-25.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KDExpresstionType) {
    KDExpresstionTypeXiaoluo,
    KDExpresstionTypeYuki
};

@interface KDExpressionManager : NSObject

+ (NSString *)fileNameOfFileId:(NSString *)fileId;
+ (NSString *)fileIdOfExpressionCode:(NSString *)code expresstionType:(KDExpresstionType)type;
+ (NSString *)fileNameOfExpressionCode:(NSString *)code expresstionType:(KDExpresstionType)type;;

@end