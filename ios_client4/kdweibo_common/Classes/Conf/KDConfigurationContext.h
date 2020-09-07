//
//  KDConfigurationContext.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-12.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDConfiguration.h"

@protocol KDConfigurationFactory;

@interface KDConfigurationContext : NSObject {
@private
    id<KDConfigurationFactory> currentConfigurationFactory_;
    NSMutableDictionary *cachedConfigurations_;
}

+ (KDConfigurationContext *) getCurrentConfigurationContext;
+ (void) setCurrentConfigurationContext:(KDConfigurationContext *)currentConfigurationContext;

// return the default configuration model and use KDConfigurationBase default initlization options to build 
- (id<KDConfiguration>) getInstance;

// return the configuration from parse kdweibo_conf.plist and this configuration model will cached
// Gene
- (id<KDConfiguration>) getDefaultPlistInstance;

// return the configuration model by parse the specific plist file
- (id<KDConfiguration>) getInstance:(NSString *)path shouldCache:(BOOL)shouldCache;

- (void) clearAllCachedConfigurations;

@end
