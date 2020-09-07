//
//  KDPersonFetchManager.h
//  kdweibo
//
//  Created by Gil on 15/3/27.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef void (^KDPersonFetchCompletionBlock) (BOOL success, NSArray *persons);
typedef void (^KDPersonFetchCompletionBlock)(BOOL success, NSArray *persons, BOOL isAdminRight);
@interface KDPersonFetch : NSObject

//获取人员信息，返回PersonDataModel对象的数组
- (void)fetchWithPersonIds:(NSArray *)personIds
           completionBlock:(KDPersonFetchCompletionBlock)completionBlock;

//获取人员信息，返回PersonDataModel对象的数组
+ (void)fetchWithPersonIds:(NSArray *)personIds
           completionBlock:(KDPersonFetchCompletionBlock)completionBlock;

@end
