//
//  KDAppUserDefaultsProtocol.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-29.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KDWEIBO_USER_DEFAULTS_PREV_CLIENT_VERSION_KEY   @"kd:previousClientVersion"


@protocol KDAppUserDefaultsProtocol <NSObject>

@required

- (void) storeBool:(BOOL)value forKey:(NSString *)defaultName;

- (void) storeInteger:(NSInteger)value forKey:(NSString *)defaultName;
- (void) storeFloat:(float)value forKey:(NSString *)defaultName;
- (void) storeDouble:(double)value forKey:(NSString *)defaultName;

// The value parameter can be only property list objects: NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary. 
// For NSArray and NSDictionary objects, their contents must be property list objects. 
// See “What is a Property List?” in Property List Programming Guide.
- (void) storeObject:(id)value forKey:(NSString *)defaultName;


- (BOOL) boolForKey:(NSString *)defaultName;
- (NSInteger) integerForKey:(NSString *)defaultName;
- (float) floatForKey:(NSString *)defaultName;
- (double) doubleForKey:(NSString *)defaultName;

- (NSString *) stringForKey:(NSString *)defaultName;
- (NSData *) dataForKey:(NSString *)defaultName;
- (NSArray *) arrayForKey:(NSString *)defaultName;
- (NSDictionary *) dictionaryForKey:(NSString *)defaultName;
- (id) objectForKey:(NSString *)defaultName;

- (void)removeObjectForKey:(NSString *)defaultName;

@end
