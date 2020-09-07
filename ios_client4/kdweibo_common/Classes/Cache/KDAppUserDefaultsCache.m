//
//  KDAppUserDefaultsCache.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-29.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDAppUserDefaultsCache.h"

@implementation KDAppUserDefaultsCache

- (id) init {
    self = [super init];
    if(self){
        
    }
    
    return self;
}

//////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (void) synchronize {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Setter methods

- (void) storeBool:(BOOL)value forKey:(NSString *)defaultName {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:defaultName];
    [self synchronize];
}

- (void) storeInteger:(NSInteger)value forKey:(NSString *)defaultName {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:defaultName];
    [self synchronize];
}

- (void) storeFloat:(float)value forKey:(NSString *)defaultName {
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:defaultName];
    [self synchronize];
}

- (void) storeDouble:(double)value forKey:(NSString *)defaultName {
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:defaultName];
    [self synchronize];
}

- (void) storeObject:(id)value forKey:(NSString *)defaultName {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:defaultName];
    [self synchronize];
}


//////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Getter methods

- (BOOL) boolForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:defaultName];
}

- (NSInteger) integerForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] integerForKey:defaultName];
}

- (float) floatForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] floatForKey:defaultName];
}

- (double) doubleForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:defaultName];
}

- (NSString *) stringForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:defaultName];
}

- (NSData *) dataForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] dataForKey:defaultName];
}

- (NSArray *) arrayForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:defaultName];
}

- (NSDictionary *) dictionaryForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:defaultName];
}

- (id) objectForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:defaultName];
}


//////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark remove method

- (void) removeObjectForKey:(NSString *)defaultName {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:defaultName];
    [self synchronize];
}

- (void) dealloc {
    //[super dealloc];
}

@end
