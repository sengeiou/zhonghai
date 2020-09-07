//
//  NSDictionary+Additions.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-25.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "NSDictionary+Additions.h"

#import "NSDate+Additions.h"

@implementation NSDictionary (KD_Additions)

- (BOOL)boolForKey:(NSString *)key {
    return [self boolForKey:key defaultValue:NO];
}

- (int)intForKey:(NSString *)key {
    return [self intForKey:key defaultValue:0];
}

- (NSInteger)integerForKey:(NSString *)key {
    return [self integerForKey:key defaultValue:0];
}

- (KDInt64)int64ForKey:(NSString *)key {
    return [self int64ForKey:key defaultValue:0];
}

- (KDUInt64)uint64ForKey:(NSString *)key {
    return [self uint64ForKey:key defaultValue:0];
}

- (float)floatForKey:(NSString *)key {
    return [self floatForKey:key defaultValue:0.0];
}

- (double)doubleForKey:(NSString *)key {
    return [self doubleForKey:key defaultValue:0.0];
}

- (NSString *)stringForKey:(NSString *)key {
    return [self stringForKey:key defaultValue:nil];
}

- (NSDate *)ASCDatetimeForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if(KD_IS_NULL_JSON_OBJ(obj)) return nil;
    
    return [NSDate parseDateUsingASCTimeFormatter:obj hasMillionSeconds:NO];
}

- (NSDate *)ASCDatetimeWithMillionSecondsForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if(KD_IS_NULL_JSON_OBJ(obj)) return nil;
    
    return [NSDate parseDateUsingASCTimeFormatter:obj hasMillionSeconds:YES];
}

- (id)objectNotNSNullForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if(KD_IS_NULL_JSON_OBJ(obj)) return nil;
    
    return obj;
}

////////////////////////////////////////////////////////////////////////////////

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)value {
    id obj = [self objectForKey:key];
    if(KD_IS_NULL_JSON_OBJ(obj)) return value;
    
    return [obj boolValue];
}

- (int)intForKey:(NSString *)key defaultValue:(int)value {
    id obj = [self objectForKey:key];
    if(KD_IS_NULL_JSON_OBJ(obj)) return value;
    
    return [obj intValue];
}

- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)value {
    id obj = [self objectForKey:key];
    if(KD_IS_NULL_JSON_OBJ(obj)) return value;
    
    return [obj integerValue];
}

- (KDInt64)int64ForKey:(NSString *)key defaultValue:(KDInt64)value {
    id obj = [self objectForKey:key];
    if(KD_IS_NULL_JSON_OBJ(obj)) return value;
    
    return [obj longLongValue];
}

- (KDUInt64)uint64ForKey:(NSString *)key defaultValue:(KDUInt64)value {
    id obj = [self objectForKey:key];
    if(KD_IS_NULL_JSON_OBJ(obj)) return value;
    
    return [obj unsignedLongLongValue];
}

- (float)floatForKey:(NSString *)key defaultValue:(float)value {
    id obj = [self objectForKey:key];
    if(KD_IS_NULL_JSON_OBJ(obj)) return value;
    
    return [obj floatValue];
}

- (double)doubleForKey:(NSString *)key defaultValue:(double)value {
    id obj = [self objectForKey:key];
    if(KD_IS_NULL_JSON_OBJ(obj)) return value;
    
    return [obj doubleValue];
}

- (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)value {
    id obj = [self objectForKey:key];
    if(KD_IS_NULL_JSON_OBJ(obj)) return value;
    
    return obj;
}

@end
