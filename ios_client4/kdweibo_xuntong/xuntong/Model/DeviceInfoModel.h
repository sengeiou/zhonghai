//
//  DeviceInfoModel.h
//  kdweibo
//
//  Created by kingdee on 2019/5/20.
//  Copyright © 2019 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfoModel : NSObject
@property (nonatomic, copy) NSString *brandName;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *osVersion;
@property (nonatomic, copy) NSString *lastUpdateTime;
- (id)initWithDictionary:(NSDictionary *)dict;
@end
