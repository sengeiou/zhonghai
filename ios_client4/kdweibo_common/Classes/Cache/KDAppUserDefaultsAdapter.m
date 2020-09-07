//
//  KDAppUserDefaultsAdapter.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-29.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDAppUserDefaultsAdapter.h"

#import "KDAppUserDefaultsCache.h"

@interface KDAppUserDefaultsAdapter ()

@property (nonatomic, retain) id<KDAppUserDefaultsProtocol> appUserDefaultsImpl;

@end


@implementation KDAppUserDefaultsAdapter

@synthesize appUserDefaultsImpl=appUserDefaultsImpl;

- (id) init {
    self = [super init];
    if(self){
        appUserDefaultsImpl_ = [[KDAppUserDefaultsCache alloc] init];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////////

- (void) storeBool:(BOOL)value forKey:(NSString *)defaultName {
    [appUserDefaultsImpl_ storeBool:value forKey:defaultName];
}

- (void) storeInteger:(NSInteger)value forKey:(NSString *)defaultName {
    [appUserDefaultsImpl_ storeInteger:value forKey:defaultName];
}

- (void) storeFloat:(float)value forKey:(NSString *)defaultName {
    [appUserDefaultsImpl_ storeFloat:value forKey:defaultName];
}

- (void) storeDouble:(double)value forKey:(NSString *)defaultName {
    [appUserDefaultsImpl_ storeDouble:value forKey:defaultName];
}

- (void) storeObject:(id)value forKey:(NSString *)defaultName {
    [appUserDefaultsImpl_ storeObject:value forKey:defaultName];
}

////////////////////////////////////////////////////////////////////////////////////

- (BOOL) boolForKey:(NSString *)defaultName {
    return [appUserDefaultsImpl_ boolForKey:defaultName];
}

- (NSInteger) integerForKey:(NSString *)defaultName {
    return [appUserDefaultsImpl_ integerForKey:defaultName];
}

- (float) floatForKey:(NSString *)defaultName {
    return [appUserDefaultsImpl_ floatForKey:defaultName];
}

- (double) doubleForKey:(NSString *)defaultName {
    return [appUserDefaultsImpl_ doubleForKey:defaultName];
}

- (NSString *) stringForKey:(NSString *)defaultName {
    return [appUserDefaultsImpl_ stringForKey:defaultName];
}

- (NSData *) dataForKey:(NSString *)defaultName {
    return [appUserDefaultsImpl_ dataForKey:defaultName];
}

- (NSArray *) arrayForKey:(NSString *)defaultName {
    return [appUserDefaultsImpl_ arrayForKey:defaultName];
}

- (NSDictionary *) dictionaryForKey:(NSString *)defaultName {
    return [appUserDefaultsImpl_ dictionaryForKey:defaultName];
}

- (id) objectForKey:(NSString *)defaultName {
    return [appUserDefaultsImpl_ objectForKey:defaultName];
}


////////////////////////////////////////////////////////////////////////////////////

- (void)removeObjectForKey:(NSString *)defaultName {
    [appUserDefaultsImpl_ removeObjectForKey:defaultName];
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(appUserDefaultsImpl_);
    
    //[super dealloc];
}

@end
