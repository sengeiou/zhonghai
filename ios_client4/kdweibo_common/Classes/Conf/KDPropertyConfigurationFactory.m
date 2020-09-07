//
//  KDPropertyConfigurationFactory.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDPropertyConfigurationFactory.h"

#import "KDPropertyConfiguration.h"

static KDPropertyConfiguration *DEFAULT_CONFIGURATION = nil;

@implementation KDPropertyConfigurationFactory

- (id) init {
    self = [super init];
    if(self){
        
    }
    
    return self;
}

- (id<KDConfiguration>) getInstance {
    if(DEFAULT_CONFIGURATION == nil){
        DEFAULT_CONFIGURATION = [[KDPropertyConfiguration alloc] init];
    }
    
    return DEFAULT_CONFIGURATION;
}

- (id<KDConfiguration>) getInstance:(NSString *)path {
    return [[KDPropertyConfiguration alloc] initWithPath:path];
}

- (void) dealloc {
    
    //[super dealloc];
}

@end
