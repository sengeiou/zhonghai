//
//  KDConfigurationFactory.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KDConfiguration;

@protocol KDConfigurationFactory <NSObject>
@required

- (id<KDConfiguration>) getInstance;
- (id<KDConfiguration>) getInstance:(NSString *)path;

@end
