//
//  NSNull+Dictionary.m
//  kdweibo_common
//
//  Created by shen kuikui on 13-9-17.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "NSNull+Dictionary.h"

@implementation NSNull (Dictionary)

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    
}

- (id)objectForKey:(id<NSCopying>)aKey {
    return nil;
}

- (BOOL)boolForKey:(NSString *)key {
    return NO;
}

- (int)intForKey:(NSString *)key {
    return 0;
}

- (NSInteger)integerForKey:(NSString *)key {
    return 0;
}

- (KDInt64)int64ForKey:(NSString *)key {
    return 0;
}

- (KDUInt64)uint64ForKey:(NSString *)key {
    return 0;
}

- (float)floatForKey:(NSString *)key {
    return 0.0f;
}

- (double)doubleForKey:(NSString *)key {
    return 0.0f;
}

- (NSString *)stringForKey:(NSString *)key {
    return nil;
}

- (NSDate *)ASCDatetimeForKey:(NSString *)key {
    return nil;
}

- (NSDate *)ASCDatetimeWithMillionSecondsForKey:(NSString *)key {
    return nil;
}

- (id)objectNotNSNullForKey:(NSString *)key {
    return nil;
}

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)value {
    return value;
}

- (int)intForKey:(NSString *)key defaultValue:(int)value {
    return value;
}

- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)value {
    return value;
}

- (KDInt64)int64ForKey:(NSString *)key defaultValue:(KDInt64)value {
    return value;
}

- (KDUInt64)uint64ForKey:(NSString *)key defaultValue:(KDUInt64)value {
    return value;
}

- (float)floatForKey:(NSString *)key defaultValue:(float)value {
    return value;
}

- (double)doubleForKey:(NSString *)key defaultValue:(double)value {
    return value;
}

- (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)value {
    return value;
}
@end
