//
//  BOSBaseDataModel.h
//  Public
//
//  Created by Gil on 12-4-26.
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 基础的数据模型类，以后的数据模型类皆继承于此类：
    提供一个基本的方法
    引入头文件BOSPublicConfig
 */

#import <Foundation/Foundation.h>
#import "BOSPublicConfig.h"

@interface BOSBaseDataModel : NSObject

-(id)initWithDictionary:(NSDictionary *)dict;

@end
