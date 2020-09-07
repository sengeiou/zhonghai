//
//  KDExpressionCode.h
//  kdweibo_common
//
//  Created by shen kuikui on 13-2-26.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDExpressionCode : NSObject

+ (NSString *)imageNameToCodeString:(NSString *)imageName;

+ (NSString *)codeStringToImageName:(NSString *)codeStr;

+ (NSArray *)allCodeString;
@end
