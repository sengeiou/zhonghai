//
//  KDEventAnalysis.m
//  kdweibo_common
//
//  Created by Gil on 14-9-19.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "KDEventAnalysis.h"
#import "MobClick.h"
#import "Countly.h"


// the app key for kdweibo in umeng platform

//key必须置空，否则构建脚本无法替换

#define KDWEIBO_UMENG_APP_KEY   @""
//kCountly_AppKey:5c5a9e18802653361e9a20c676fc945f66f34cdd,
//kCountly_Server:http://pm1.yunzhijia.com
//两者为固定值，不要修改。
#define kCountly_AppKey                         @"5c5a9e18802653361e9a20c676fc945f66f34cdd"
#define kCountly_Server                         [KDCommon getCountly_Server]
#define kCountly_UpdateSessionPeriod            60
#define kCountly_EventSendThreshold             10
#define kCountly_StoredRequestLimit             1000

@implementation KDEventAnalysis

+ (void)setupAnalysis
{
    //设置友盟统计key
    UMConfigInstance.appKey = KDWEIBO_UMENG_APP_KEY;
    UMConfigInstance.channelId = nil;
    
    [MobClick startWithConfigure:UMConfigInstance];
   
}

+ (void)setupCountlyAnalysis
{
    if(kCountly_AppKey.length == 0 || kCountly_Server.length == 0)
        return;
    
    CountlyConfig *config = [CountlyConfig new];
    
    // appkey & host
    config.appKey = kCountly_AppKey;
    config.host = kCountly_Server;
    
    // 检测类型（暂时去掉CLYAutoViewTracking, CLYCrashReporting）
    config.features = @[CLYAutoViewTracking];
    // devieceID
    config.deviceID = [UIDevice uniqueDeviceIdentifier];
    
    // 发送服务器间隔 默认60s
    config.updateSessionPeriod = kCountly_UpdateSessionPeriod;
    
    // 阈值   默认10
    config.eventSendThreshold = kCountly_EventSendThreshold;
    
    // 请求队列防御 默认1000  如果达到limit 踢出oldest request
    config.storedRequestsLimit = kCountly_StoredRequestLimit;
    
    // POST
    config.alwaysUsePOST = YES;
    
    // start
    [[Countly sharedInstance] startWithConfig:config];
}
//umeng
+ (void)event:(NSString *)eventId
{
    [MobClick event:eventId];
}
//countly
+ (void)eventCountly:(NSString *)eventId
{
    [[Countly sharedInstance] recordEvent:eventId];
}

+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes
{
    if (attributes == nil) {
        [self event:eventId];
    }
    else {
        [MobClick event:eventId attributes:attributes];
    }
    
}

+ (void)eventCountly:(NSString *)eventId attributes:(NSDictionary *)attributes
{
    if (attributes == nil) {
        [[Countly sharedInstance] recordEvent:eventId];
    }
    else {
        [[Countly sharedInstance] recordEvent:eventId segmentation:attributes];
    }
}


+ (void)beginLogPageView:(NSString *)pageName
{
    [MobClick beginLogPageView:pageName];
}
+ (void)endLogPageView:(NSString *)pageName
{
    [MobClick endLogPageView:pageName];
}

+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes counter:(int)number {
    [[Countly sharedInstance] recordEvent:eventId segmentation:attributes count:number];
}


//+ (void)setUserIdAndEid {
//    [[CountlyUserDetails sharedInstance] set:@"eid" value:[BOSConfig sharedConfig].user.eid];
//    [[CountlyUserDetails sharedInstance] set:@"userId" value:[BOSConfig sharedConfig].user.wbUserId];
//    [[CountlyUserDetails sharedInstance] save];
//}

+ (void)crashLog:(NSString *)format, ... {
    [[Countly sharedInstance] crashLog:@"%@", format];
}


+ (void)cleanUser {
    [[CountlyUserDetails sharedInstance] set:@"eid" value:nil];
    [[CountlyUserDetails sharedInstance] set:@"userId" value:nil];
    [[CountlyUserDetails sharedInstance] save];
}

@end
