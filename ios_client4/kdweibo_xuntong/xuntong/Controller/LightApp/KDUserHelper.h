//
//  KDUserHelper.h
//  kdweibo
//
//  Created by Gil on 14-7-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KDUserHelperCompletionBlock) (BOOL success, NSArray *persons, NSString *error);
typedef void (^KDUserHelperRelatedPersonCompletionBlock) (BOOL success, BOOL more, NSDictionary *personsDic, NSString *error);
typedef void (^KDUserHelperCloudCompletionBlock) (BOOL success, NSString *cloudPassport, NSString *error);
@interface KDUserHelper : NSObject

//通过oid换取用户信息 单个
- (void)exchangePersonWithOid:(NSString *)oid
                   completion:(KDUserHelperCompletionBlock)completionBlock;

//获取人员信息
- (void)getPersonInfoWithPersonId:(NSString *)personId
                       completion:(KDUserHelperCompletionBlock)completionBlock;

//通过oids换取用户信息 批量
- (void)exchangePersonsWithOids:(NSString *)oids
                     completion:(KDUserHelperCompletionBlock)completionBlock;
- (void)getCloudPassportWith:(NSString*)userId
                     completion:(KDUserHelperCloudCompletionBlock)completionBlock;

//获取相关人员信息
- (void)getRelatePersonWithScore:(NSString *)score
                      completion:(KDUserHelperRelatedPersonCompletionBlock)completionBlock;

//获取新增相关人员信息
- (void)getGroupUsersWithGroupId:(NSString *)groupId
                           Score:(NSString*)score
                      completion:(KDUserHelperRelatedPersonCompletionBlock)completionBlock;


@end
