//
//  KDCacheHelper.h
//  kdweibo
//
//  Created by Gil on 15/3/31.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersonSimpleDataModel.h"

@interface KDCacheHelper : NSObject

+ (PersonSimpleDataModel *)personForKey:(NSString *)key;

@end
