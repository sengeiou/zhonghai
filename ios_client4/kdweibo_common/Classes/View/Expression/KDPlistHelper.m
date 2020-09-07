//
//  KDPlistHelper.m
//  kdweibo_common
//
//  Created by fang.jiaxin on 16/11/29.
//  Copyright © 2016年 kingdee. All rights reserved.
//

#import "KDPlistHelper.h"

@implementation KDPlistHelper
+(NSArray *)arrayWithPlistName:(NSString *)plistName
{
    NSArray *array = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    if(path)
    {
        NSArray *arrayValue = [NSArray arrayWithContentsOfFile:path];
        if(arrayValue)
            return arrayValue;
    }
    return array;
}
@end
