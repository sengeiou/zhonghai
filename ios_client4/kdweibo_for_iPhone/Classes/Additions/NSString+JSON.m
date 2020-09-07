//
//  NSString+JSON.m
//  kdweibo
//
//  Created by AlanWong on 14/12/15.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)
+ (NSString *)stringWithJSONObject:(id)jsonObject {
    if (![NSJSONSerialization isValidJSONObject:jsonObject]) {
        return nil;
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        return nil;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
}

+ (id)jsonObjectWithString:(NSString *)jsonStr {
    if ([jsonStr length] == 0) {
        return nil;
    }

    NSData *strData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:strData];
    if (jsonObject) {
        return jsonObject;
    }

    return nil;
}


@end
