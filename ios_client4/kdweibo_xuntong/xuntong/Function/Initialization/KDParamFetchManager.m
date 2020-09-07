//
//  KDParamFetchManager.m
//  kdweibo
//
//  Created by Gil on 14-10-15.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDParamFetchManager.h"
#import "MCloudClient.h"
#import "BOSSetting.h"

@interface KDParamFetchManager ()
@property (strong, nonatomic) KDParamFetchCompletionBlock completionBlock;
@property (assign, nonatomic) BOOL fetching;
@property (strong, nonatomic) MCloudClient *clientCloud;
@property (nonatomic, strong) MCloudClient *chatAppClientCloud;
@end

@implementation KDParamFetchManager

+ (instancetype)sharedParamFetchManager
{
    static dispatch_once_t pred;
    static KDParamFetchManager *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[KDParamFetchManager alloc] init];
    });
    return instance;
}

- (void)startParamFetchCompletionBlock:(KDParamFetchCompletionBlock)completionBlock
{
    if (self.fetching) {
        completionBlock(false);
    }
    
    self.fetching = true;
    self.completionBlock = completionBlock;
    [self.clientCloud getAppParamsWithCust3gNo:[BOSSetting sharedSetting].cust3gNo];
}

- (MCloudClient *)clientCloud
{
    if (_clientCloud == nil) {
        _clientCloud = [[MCloudClient alloc] initWithTarget:self action:@selector(getParamsCallback:result:)];
    }
    return _clientCloud;
}

-(void)getParamsCallback:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    self.fetching = false;
    
    if (client.hasError) {
        self.completionBlock(false);
        return;
    }
    
    if (result.success) {
        NSDictionary *params = result.data[@"params"];
        if (params && [params isKindOfClass:[NSDictionary class]]) {
            [BOSSetting sharedSetting].params = params;
            [[BOSSetting sharedSetting] saveSetting];
            // 群应用
            NSString *chatGroupAppids = [params objectForKey:@"chatGroupAPP"];
            if (![chatGroupAppids isKindOfClass:[NSNull class]] && chatGroupAppids.length > 0){
                [self.chatAppClientCloud getDefineLightAppsWithMid:[BOSConfig sharedConfig].user.eid appids:chatGroupAppids openToken:[BOSConfig sharedConfig].user.token urlParam:nil];
            }else{
                [BOSSetting sharedSetting].chatGroupAPPArr = nil;
                [[BOSSetting sharedSetting] saveSetting];
            }
            // 金格授权码
            NSString *copyright = [params objectForKey:@"copyright"];
            if (![copyright isKindOfClass:[NSNull class]] && copyright.length > 0){
                [[KDWeiboAppDelegate getAppDelegate] _registerIAppRevisionWithKey:copyright];
            }
            self.completionBlock(true);
            return;
        }
    }
    
    self.completionBlock(false);
}

- (MCloudClient *)chatAppClientCloud
{
    if (!_chatAppClientCloud) {
        _chatAppClientCloud = [[MCloudClient alloc] initWithTarget:self action:@selector(getLightAppParamDidReceived:result:)];
    }
    return _chatAppClientCloud;
}

- (void)getLightAppParamDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (result.success && result.data && [result.data isKindOfClass:[NSArray class]]){
        NSArray *data = (NSArray *)result.data;
        [BOSSetting sharedSetting].chatGroupAPPArr = data;
    }
    else {
        [BOSSetting sharedSetting].chatGroupAPPArr = nil;
    }
    
    [[BOSSetting sharedSetting] saveSetting];
}


@end
