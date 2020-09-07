//
//  XTmenuModel.m
//  XT
//
//  Created by mark on 14-1-6.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import "XTmenuModel.h"

@implementation XTmenuModel


- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id n_name = [dict objectForKey:@"name"];
        if (![n_name isKindOfClass:[NSNull class]] && n_name != nil) {
            self.name = n_name;
        }
        
        id n_ID = [dict objectForKey:@"id"];
        if (![n_ID isKindOfClass:[NSNull class]] && n_ID != nil) {
            self.ID = n_ID;
        }
        
        id n_key = [dict objectForKey:@"key"];
        if (![n_key isKindOfClass:[NSNull class]] && n_key != nil) {
            self.key = n_key;
        }
        
        id n_type = [dict objectForKey:@"type"];
        if (![n_type isKindOfClass:[NSNull class]] && n_type != nil) {
            self.type = n_type;
        }
        
        id n_url = [dict objectForKey:@"url"];
        if (![n_url isKindOfClass:[NSNull class]] && n_url != nil) {
            self.url = n_url;
        }
        
        id n_sub = [dict objectForKey:@"sub"];
        if (![n_sub isKindOfClass:[NSNull class]] && n_sub != nil) {
            self.sub = n_sub;
        }
        
        id n_ios = [dict objectForKey:@"ios"];
        if (![n_ios isKindOfClass:[NSNull class]] && n_ios != nil) {
            self.ios = n_ios;
        }
        
        id n_appId = [dict objectForKey:@"appid"];
        if (![n_appId isKindOfClass:[NSNull class]] && n_appId != nil) {
            self.appId = n_appId;
        }
    }
    return self;
}

@end
