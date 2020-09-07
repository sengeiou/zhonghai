//
//  BaseAppDataModel.m
//  kdweibo
//
//  Created by stone on 14-4-19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "BaseAppDataModel.h"

@implementation BaseAppDataModel
@synthesize appID,appClientID,appName,appLogo,appType,appDescribe,data;

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        if ([dict isKindOfClass:[NSNull class]] && dict == nil)
        {
            return nil;
        }
        else
        {
            data = [[NSDictionary alloc] initWithDictionary:dict];
            id WF_appID = [dict objectForKey:@"appId"];
            id WF_appClientID = [dict objectForKey:@"appClientId"];
            id WF_appType = [dict objectForKey:@"appType"];
            id WF_appName = [dict objectForKey:@"appName"];
            id WF_appLogo = [dict objectForKey:@"appLogo"];
            id WF_appNote = [dict objectForKey:@"appDesc"];
            //@"newer"
            //@"detailURL"
            
            if (![WF_appID isKindOfClass:[NSNull class]] && WF_appID != nil)
            {
                self.appID = [NSString stringWithFormat:@"%.0f",[WF_appID doubleValue]];
            }
            if (![WF_appClientID isKindOfClass:[NSNull class]] && WF_appClientID != nil)
            {
                self.appClientID = [NSString stringWithFormat:@"%.0f",[WF_appClientID doubleValue]];
            }
            if (![WF_appType isKindOfClass:[NSNull class]] && WF_appType != nil)
            {
                self.appType = [WF_appType intValue];
            }
            if (![WF_appName isKindOfClass:[NSNull class]] && WF_appName != nil)
            {
                self.appName = WF_appName;
            }
            if (![WF_appLogo isKindOfClass:[NSNull class]] && WF_appLogo != nil)
            {
                self.appLogo = WF_appLogo;
            }
            if (![WF_appNote isKindOfClass:[NSNull class]] && WF_appNote != nil)
            {
                self.appDescribe = WF_appNote;
            }
        }
    }
    return self;
}

- (NSDictionary *)getData
{
    return data;
}

@end
