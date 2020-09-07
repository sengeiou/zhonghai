//
//  MFAppDataModel.m
//  MobileFamily
//
//  Created by kingdee eas on 13-5-16.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import "MFAppDataModel.h"


@implementation MFAppDataModel
@synthesize appStatus,appClientSchema,appDldURL,appVersion;

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self)
    {
        if ([dict isKindOfClass:[NSNull class]] && dict == nil)
        {
            return nil;
        }
        else
        {
            id WF_appStatus = [dict objectForKey:@"appStatus"];
            id WF_appClientSchema = [dict objectForKey:@"appClientSchema"];
            id WF_appDldURL = [dict objectForKey:@"downloadURL"];
            id WF_appClientVersion = [dict objectForKey:@"appClientVersion"];
            
            if (![WF_appStatus isKindOfClass:[NSNull class]] && WF_appStatus != nil)
            {
                self.appStatus = [WF_appStatus intValue];
            }
            if (![WF_appClientSchema isKindOfClass:[NSNull class]] && WF_appClientSchema != nil)
            {
                self.appClientSchema = WF_appClientSchema;
            }
            if (![WF_appDldURL isKindOfClass:[NSNull class]] && WF_appDldURL != nil)
            {
                self.appDldURL = WF_appDldURL;
            }
            if (![WF_appClientVersion isKindOfClass:[NSNull class]] && WF_appClientVersion != nil)
            {
                self.appVersion = WF_appClientVersion;
            }
        }
    }
    return self;
}

//第二种返回参数，太怪了。
- (id)initWithDictionary2:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self)
    {
        if ([dict isKindOfClass:[NSNull class]] && dict == nil)
        {
            return nil;
        }
        else
        {
            id WF_appStatus = [dict objectForKey:@"appStatus"];
            id WF_appClientSchema = [dict objectForKey:@"appClientSchema"];
            id WF_appDldURL = [dict objectForKey:@"appDldURL"];
            id WF_appClientVersion = [dict objectForKey:@"appClientVersion"];
            //这里返回的描述字段又不一样了，所以，特殊处理一下。
            id WF_appNote = [dict objectForKey:@"appNote"];
            if (![WF_appStatus isKindOfClass:[NSNull class]] && WF_appStatus != nil)
            {
                self.appStatus = [WF_appStatus intValue];
            }
            if (![WF_appClientSchema isKindOfClass:[NSNull class]] && WF_appClientSchema != nil)
            {
                self.appClientSchema = WF_appClientSchema;
            }
            if (![WF_appDldURL isKindOfClass:[NSNull class]] && WF_appDldURL != nil)
            {
                self.appDldURL = WF_appDldURL;
            }
            if (![WF_appClientVersion isKindOfClass:[NSNull class]] && WF_appClientVersion != nil)
            {
                self.appVersion = WF_appClientVersion;
            }
            if (![WF_appNote isKindOfClass:[NSNull class]] && WF_appNote != nil)
            {
                self.appDescribe = WF_appNote;
            }
            
        }
    }
    return self;
}


@end
