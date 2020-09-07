//
//  NSDictionary+Additions.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-25.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDCommon.h"

@interface NSDictionary (KD_Additions)

- (BOOL)boolForKey:(NSString *)key;

- (int)intForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;

- (KDInt64)int64ForKey:(NSString *)key;
- (KDUInt64)uint64ForKey:(NSString *)key;

- (float)floatForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;

- (NSString *)stringForKey:(NSString *)key;

- (NSDate *)ASCDatetimeForKey:(NSString *)key;
- (NSDate *)ASCDatetimeWithMillionSecondsForKey:(NSString *)key;

- (id)objectNotNSNullForKey:(NSString *)key;

////////////////////////////////////////////////////////////////////////////////

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)value;

- (int)intForKey:(NSString *)key defaultValue:(int)value;
- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)value;

- (KDInt64)int64ForKey:(NSString *)key defaultValue:(KDInt64)value;
- (KDUInt64)uint64ForKey:(NSString *)key defaultValue:(KDUInt64)value;

- (float)floatForKey:(NSString *)key defaultValue:(float)value;
- (double)doubleForKey:(NSString *)key defaultValue:(double)value;

- (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)value;

@end
