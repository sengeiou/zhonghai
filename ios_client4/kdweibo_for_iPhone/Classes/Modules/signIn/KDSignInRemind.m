//
//  KDSignInRemind.m
//  kdweibo
//
//  Created by lichao_liu on 9/8/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDSignInRemind.h"

@implementation KDSignInRemind

//+ (JSONKeyMapper *)keyMapper {
//    
//    NSDictionary *dict = @{ @"remindId": @"id",
//                            @"repeatType": @"remindWeekDate"
//                            };
//    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:dict];
//    
//}

+(NSArray *)parseWithDicArray:(NSArray *)array
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    if(array)
    {
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            KDSignInRemind *remind = [[KDSignInRemind alloc] initWithDic:obj];
            if(remind)
                [resultArray addObject:remind];
        }];
    }
    return resultArray;
}

-(KDSignInRemind *)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if(self)
    {
        self.remindId = safeString([dic objectForKey:@"id"]);
        self.isRemind = [[dic objectForKey:@"isRemind"] boolValue];
        self.remindTime = safeString([dic objectForKey:@"remindTime"]);
        self.repeatType = [[dic objectForKey:@"remindWeekDate"] unsignedIntegerValue];
    }
    return self;
}

@end
