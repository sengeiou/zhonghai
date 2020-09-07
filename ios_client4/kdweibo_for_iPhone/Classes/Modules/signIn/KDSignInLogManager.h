//
//  KDSignInLogManager.h
//  kdweibo
//
//  Created by 张培增 on 2017/1/12.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//签到失败的类型
extern NSString *const KDSignInFailedTypeNormal;       //签到失败:内勤签到失败、自定义签到失败、外勤签到失败
extern NSString *const KDSignInFailedTypeLocation;     //定位失败
extern NSString *const KDSignInFailedTypePOIError;     //获取POI错误:获取POI超时、高德返回POI时出错、POI为空

@interface KDSignInLogManager : NSObject

/**
 记录签到失败的日志
 
 @param failureType 失败类型
 @param errorMessage 错误信息
 */
+ (void)sendSignInLogWithFailureType:(NSString *)failureType errorMessage:(NSString *)errorMessage;

@end
