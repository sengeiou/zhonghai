//
//  DeviceInfoModel.m
//  kdweibo
//
//  Created by kingdee on 2019/5/20.
//  Copyright © 2019 www.kingdee.com. All rights reserved.
//

#import "DeviceInfoModel.h"

@implementation DeviceInfoModel
- (id)initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];
    
    if ([dict isKindOfClass:[NSNull class]] || dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    
    if (self) {
        
        id brandName = [dict objectForKey:@"brandName"];
        id deviceId = [dict objectForKey:@"deviceId"];
        id model = [dict objectForKey:@"model"];
        id osVersion = [dict objectForKey:@"osVersion"];
        id lastUpdateTime = [dict objectForKey:@"lastUpdateTime"];
        
        if (![brandName isKindOfClass:[NSNull class]] && brandName) {
            self.brandName = brandName;
        }
        if (![deviceId isKindOfClass:[NSNull class]] && deviceId) {
            self.deviceId = deviceId;
        }
        if (![model isKindOfClass:[NSNull class]] && model) {
            self.model = model;
        }
        if (![osVersion isKindOfClass:[NSNull class]] && osVersion) {
            self.osVersion = osVersion;
        }
        if (![lastUpdateTime isKindOfClass:[NSNull class]] && lastUpdateTime) {
            self.lastUpdateTime = lastUpdateTime;
        }
        
    }
    
    return self;
}

@end
