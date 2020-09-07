//
//  NSJSONSerialization+KDCategory.h
//  kdweibo
//
//  Created by Darren on 15/4/20.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (KDCategory)

+ (id)JSONObjectWithData:(NSData *)data;

+ (id)JSONObjectWithString:(NSString *)jsonString;

+ (NSData *)dataWithJSONObject:(id)jsonObject;
+ (NSString *)stringWithJSONObject:(id)jsonObject;

@end
