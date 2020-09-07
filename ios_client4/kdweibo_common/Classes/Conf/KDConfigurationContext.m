//
//  KDConfigurationContext.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-12.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"

#import "KDConfigurationContext.h"

#import "KDPropertyConfigurationFactory.h"
#import "KDPropertyConfiguration.h"

static KDConfigurationContext *currentConfigurationContext_ = nil;

@interface KDConfigurationContext ()

@property (nonatomic, retain) id<KDConfigurationFactory> currentConfigurationFactory;
@property (nonatomic, retain) NSMutableDictionary *cachedConfigurations;

@end


@implementation KDConfigurationContext

@synthesize currentConfigurationFactory=currentConfigurationFactory_;
@synthesize cachedConfigurations=cachedConfigurations_;

- (id) init {
    self = [super init];
    if(self){
        currentConfigurationFactory_ = [[KDPropertyConfigurationFactory alloc] init];
        cachedConfigurations_ = nil;
    }
    
    return self;
}

+ (KDConfigurationContext *) getCurrentConfigurationContext {
    if(currentConfigurationContext_ == nil){
        currentConfigurationContext_ = [[KDConfigurationContext alloc] init];
    }
    
    return currentConfigurationContext_;
}

+ (void) setCurrentConfigurationContext:(KDConfigurationContext *)currentConfigurationContext {
    if(currentConfigurationContext_ != currentConfigurationContext){
        currentConfigurationContext_ = currentConfigurationContext ;
    }
}

- (void) cacheConfiguration:(id<KDConfiguration>)configuration forKey:(NSString *)key {
    if(cachedConfigurations_ == nil){
        cachedConfigurations_ = [[NSMutableDictionary alloc] init];
    }
    
    [cachedConfigurations_ setObject:configuration forKey:key];
}

- (void) clearAllCachedConfigurations {
    if(cachedConfigurations_ != nil){

        cachedConfigurations_ = nil;
    }
}

- (id<KDConfiguration>) getInstance {
    return [currentConfigurationFactory_ getInstance];
}

- (id<KDConfiguration>) getDefaultPlistInstance {
    static NSString *path = nil;
    if(path == nil){
        path = [[NSBundle mainBundle] pathForResource:@"kdweibo_conf" ofType:@"plist"];
    }

    return [self getInstance:path shouldCache:YES];
}

- (id<KDConfiguration>) getInstance:(NSString *)path shouldCache:(BOOL)shouldCache {
    if(path == nil)
        return nil;
    
    if(shouldCache && cachedConfigurations_ != nil && [cachedConfigurations_ objectForKey:path] != nil){
        return [cachedConfigurations_ objectForKey:path];
    }
    
    id<KDConfiguration> configuration = [currentConfigurationFactory_ getInstance:path];
    
    if(shouldCache){
        // cache the configurations before return
        [self cacheConfiguration:configuration forKey:path];
    }
    
    return configuration;
} 

- (void) dealloc {
    //KD_RELEASE_SAFELY(currentConfigurationFactory_);
    //KD_RELEASE_SAFELY(cachedConfigurations_);
    
    //[super dealloc];
}

@end
