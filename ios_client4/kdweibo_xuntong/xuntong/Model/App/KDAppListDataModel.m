//
//  KDAppListDataModel.m
//  kdweibo
//
//  Created by AlanWong on 14-9-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDAppListDataModel.h"
@implementation KDAppListDataModel

- (id)initWithDictionary:(NSDictionary *)dict{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id KD_total = [dict objectForKey:@"total"];
        id KD_end = [dict objectForKey:@"end"];
        id KD_list = [dict objectForKey:@"list"];
        if (![KD_total isKindOfClass:[NSNull class]] && KD_total) {
            self.total = [KD_total intValue];
        }
        if (![KD_end isKindOfClass:[NSNull class]] && KD_end) {
            self.end = [KD_end boolValue];
        }
        if (![KD_list isKindOfClass:[NSNull class]] && KD_list && [KD_list isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[(NSArray *)KD_list count]];
            for (id each in KD_list) {
                KDAppDataModel * appDM = [[KDAppDataModel alloc]initWithDictionary:each];
                if (appDM) {
                    [array addObject:appDM];
                }
            }
            self.list = array;
        }
        
    }
    return self;
}

@end
