//
//  KDCacheHelper.m
//  kdweibo
//
//  Created by Gil on 15/3/31.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDCacheHelper.h"
#import "KDPublicAccountCache.h"
#import "KDPersonCache.h"

@implementation KDCacheHelper

+ (PersonSimpleDataModel *)personForKey:(NSString *)key {
    if (key.length == 0) {
        return nil;
    }
    
    if ([key isPublicAccount]) {
        return [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:key];
    }
    else {
        return [[KDPersonCache sharedPersonCache] personForKey:key];
    }
}

@end
