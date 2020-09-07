//
//  XTMenuEachModel.m
//  XT
//
//  Created by mark on 14-1-6.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import "XTMenuEachModel.h"

@implementation XTMenuEachModel

- (id)init {
    self = [super init];
    if (self) {
        _type = [[NSString alloc] init];
        _name = [[NSString alloc] init];
        _key = [[NSString alloc] init];
        _ID = [[NSString alloc] init];
        _url = [[NSString alloc] init];
        _ios = [[NSString alloc] init];
        _appId = [[NSString alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id n_type = [dict objectForKey:@"type"];
        if (![n_type isKindOfClass:[NSNull class]] && n_type != nil) {
            self.type = n_type;
        }
        
        id n_name = [dict objectForKey:@"name"];
        if (![n_name isKindOfClass:[NSNull class]] && n_name != nil) {
            self.name = n_name;
        }
        
        id n_key = [dict objectForKey:@"key"];
        if (![n_key isKindOfClass:[NSNull class]] && n_key != nil) {
            self.key = n_key;
        }
        
        id n_url = [dict objectForKey:@"url"];
        if (![n_url isKindOfClass:[NSNull class]] && n_url != nil) {
            self.url = n_url;
        }
        
        id n_id = [dict objectForKey:@"id"];
        if (![n_id isKindOfClass:[NSNull class]] && n_id != nil) {
            self.ID = n_id;
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