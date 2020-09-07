//
//  KDEventAnalysis.h
//  kdweibo_common
//
//  Created by Gil on 14-9-19.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDEvent.h"

@interface KDEventAnalysis : NSObject

//设置分析环境 配了countly则countly 否则umeng
+ (void)setupAnalysis;
//设置分析环境 配了countly则countly 否则umeng
+ (void)setupCountlyAnalysis;

//自定义事件
//目前只使用最基本的事件，attributes可为nil
+ (void)event:(NSString *)eventId;
//countly
+ (void)eventCountly:(NSString *)eventId;


//umeng
+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes;
//countly
+ (void)eventCountly:(NSString *)eventId attributes:(NSDictionary *)attributes;



+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes counter:(int)number;

//页面路径 umeng
+ (void)beginLogPageView:(NSString *)pageName;
+ (void)endLogPageView:(NSString *)pageName;

// countly设置user ---- 切圈/登陆
+ (void)setUserIdAndEid;
+ (void)cleanUser;

// 自定义log
+ (void)crashLog:(NSString *)format, ...;

@end
