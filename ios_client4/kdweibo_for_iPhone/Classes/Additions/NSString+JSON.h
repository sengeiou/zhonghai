//
//  NSString+JSON.h
//  kdweibo
//
//  Created by AlanWong on 14/12/15.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSON)
//将Dic或者Array转为String
+ (NSString *)stringWithJSONObject:(id)jsonObject;

//将String转为将Dic或者Array
+ (id)jsonObjectWithString:(NSString *)jsonStr;
@end
