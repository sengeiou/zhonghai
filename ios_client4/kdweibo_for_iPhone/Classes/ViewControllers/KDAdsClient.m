//
//  KDLaunchAdsClient.m
//  kdweibo
//
//  Created by lichao_liu on 16/1/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDAdsClient.h"
#import "BOSConfig.h"

//获取启动广告信息
#define OPENAPI_LAUNCHADS @"/adware/rest/ad/ads.json"

@implementation KDAdsClient

- (id)initWithTarget:(id)target action:(SEL)action
{
    BOSConnectFlags connectFlags = {BOSConnect4DirectURL,BOSConnectNotEncryption,BOSConnectResponseAllowCompressed,BOSConnectRequestBodyNotCompressed,NO};
    self = [super initWithTarget:target action:action connectionFlags:connectFlags];
    
    if (self)
    {
        [super setBaseUrlString:[[KDWeiboServicesContext defaultContext] serverBaseURL]];
    }
    return self;
}

- (NSDictionary *)wfHeader {
    NSString *openToken = [BOSConfig sharedConfig].user.token;
    if (!openToken) {
        openToken = @"";
    }
    return [NSDictionary dictionaryWithObject:openToken forKey:@"openToken"];
}

- (void)queryAdsWithLocationType:(KDAdsLocationType)locationType{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    
    UserDataModel *user = [BOSConfig sharedConfig].user;
    if(user && user.token && user.token.length>0)
    {
        [params setObject:[super checkNullOrNil:user.openId] forKey:@"openid"];
        [params setObject:[super checkNullOrNil:user.eid] forKey:@"eid"];
    }else{
        [params setObject:@"" forKey:@"openid"];
        [params setObject:@"" forKey:@"eid"];
    }
    NSString *location = @"";
    switch (locationType) {
        case KDAdsLocationType_message:
        {
            location = @"message";
        }
            break;
        case KDAdsLocationType_contact:
        {
            location = @"contact";
        }
            break;
        case KDAdsLocationType_application:
        {
            location = @"application";
        }
            break;
        case KDAdsLocationType_me:
        {
            location = @"me";
        }
            break;
        case KDAdsLocationType_pop:
        {
            location = @"pop";
        }
            break;
        case KDAdsLocationType_index:
        {
            location = @"index";
        }
        default:
            break;
    }
    [params setObject:location forKey:@"location"];
    
//    self.shouldSign = YES;
    self.bodyType = BOSConnectBodyWithParam;
    [super post:OPENAPI_LAUNCHADS body:params header:(user && user.token && user.token.length>0)?[self wfHeader]:nil];
}

@end
