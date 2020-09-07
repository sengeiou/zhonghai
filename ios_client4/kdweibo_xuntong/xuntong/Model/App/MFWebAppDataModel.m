//
//  MFWebAppDataModel.m
//  MobilePortal
//
//  Created by kingdee eas on 13-8-16.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import "MFWebAppDataModel.h"

@implementation MFWebAppDataModel
@synthesize webURL;

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if (self)
    {
        if ([dict isKindOfClass:[NSNull class]] && dict == nil)
        {
            return nil;
        }
        else
        {
            id WF_webURL = [dict objectForKey:@"webURL"];
            if (![WF_webURL isKindOfClass:[NSNull class]] && WF_webURL != nil)
            {
                self.webURL = WF_webURL;
            }
        }
    }
    return self;
}

@end
