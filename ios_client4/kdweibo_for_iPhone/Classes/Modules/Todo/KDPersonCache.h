//
//  KDPersonCache.h
//  kdweibo
//
//  Created by Gil on 15/3/27.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersonDataModel.h"

@interface KDPersonCache : NSObject

+ (instancetype)sharedPersonCache;

//key is personId


/**
 *  从缓存中获取人员信息
 *
 *  @param key 人员ID personId
 *
 *  @return 人员信息
 */
- (PersonSimpleDataModel *)personForKey:(NSString *)key;

- (void)removePersonForKey:(NSString *)key;
- (void)removeAllPersons;

@end
