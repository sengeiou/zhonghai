//
//  NSJSONSerialization+KDCategory.m
//  kdweibo
//
//  Created by Darren on 15/4/20.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "NSJSONSerialization+KDCategory.h"

@implementation NSJSONSerialization (KDCategory)

+ (id)JSONObjectWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    NSError *jsonError = nil;
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:NSJSONReadingMutableContainers
                                             error:&jsonError];
}

+ (id)JSONObjectWithString:(NSString *)jsonString {
    if (!jsonString || ![jsonString isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSError *jsonError = nil;
    return [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                           options:NSJSONReadingMutableContainers
                                             error:&jsonError];
}



+ (NSData *)dataWithJSONObject:(id)jsonObject {
    if (!jsonObject) {
        return nil;
    }
    NSError *jsonError = nil;
    return [NSJSONSerialization dataWithJSONObject:jsonObject
                                           options:kNilOptions
                                             error:&jsonError];
}

+ (NSString *)stringWithJSONObject:(id)jsonObject {
    if (!jsonObject) {
        return nil;
    }
    NSError *jsonError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                   options:kNilOptions
                                                     error:&jsonError];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}


@end
