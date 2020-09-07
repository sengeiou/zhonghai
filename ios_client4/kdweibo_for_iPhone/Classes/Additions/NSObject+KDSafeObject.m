//
//  NSObject+KDSafeObject.m
//  Pods
//
//  Created by Joyingx on 2017/1/3.
//
//

#import "NSObject+KDSafeObject.h"

@implementation NSObject (KDSafeObject)

#pragma mark - String

NSString *kd_safeString(NSObject *string) {
    if ([[string class] isSubclassOfClass:[NSString class]]) {
        return (NSString *)string;
    }
    
    if ([[string class] isSubclassOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@", string];
    }
    return @"";
}

NSMutableString *kd_safeMutableString(NSObject *mutableString) {
    if ([[mutableString class] isSubclassOfClass:[NSMutableString class]]) {
        return (NSMutableString *)mutableString;
    }
    
    if ([[mutableString class] isSubclassOfClass:[NSString class]]) {
        return [(NSString *)mutableString mutableCopy];
    }
    
    if ([[mutableString class] isSubclassOfClass:[NSNumber class]]) {
        return [NSMutableString stringWithFormat:@"%@", mutableString];
    }
    
    return [NSMutableString string];
}

#pragma mark - Array

NSArray *kd_safeArray(NSObject *array) {
    if ([[array class] isSubclassOfClass:[NSArray class]]) {
        return (NSArray *)array;
    }
    
    return @[];
}

NSMutableArray *kd_safeMutableArray(NSObject *mutableArray) {
    if ([[mutableArray class] isSubclassOfClass:[NSMutableArray class]]) {
        return (NSMutableArray *)mutableArray;
    }
    
    if ([[mutableArray class] isSubclassOfClass:[NSArray class]]) {
        return [(NSArray *)mutableArray mutableCopy];
    }
    
    return [NSMutableArray array];
}

#pragma mark - Dictionary

NSDictionary *kd_safeDictionary(NSObject *dictionary) {
    if ([[dictionary class] isSubclassOfClass:[NSDictionary class]]) {
        return (NSDictionary *)dictionary;
    }
    
    return @{};
}

NSMutableDictionary *kd_safeMutableDictionary(NSObject *mutableDictionary) {
    if ([[mutableDictionary class] isSubclassOfClass:[NSMutableDictionary class]]) {
        return (NSMutableDictionary *)mutableDictionary;
    }
    
    if ([[mutableDictionary class] isSubclassOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)mutableDictionary mutableCopy];
    }
    
    return [NSMutableDictionary dictionary];
}

#pragma mark - Number

NSNumber *kd_safeNumber(NSObject *number) {
    if ([[number class] isSubclassOfClass:[NSNumber class]]) {
        return (NSNumber *)number;
    }
    
    if ([[number class] isSubclassOfClass:[NSString class]]) {
        return @([(NSString *)number doubleValue]);
    }
    
    return @(0);
}

BOOL kd_safeBool(NSObject *number) {
    if ([[number class] isSubclassOfClass:[NSString class]]
        && ([(NSString *)number caseInsensitiveCompare:@"true"] == NSOrderedSame
            || [(NSString *)number caseInsensitiveCompare:@"yes"] == NSOrderedSame)) {
            return YES;
        }
    
    if ([number respondsToSelector:@selector(boolValue)]) {
        return [(id)number boolValue];
    }
    
    return NO;
}

NSInteger kd_safeInteger(NSObject *number) {
    if ([number respondsToSelector:@selector(integerValue)]) {
        return [(id)number integerValue];
    }
    
    return 0;
}

int kd_safeInt(NSObject *number) {
    if ([number respondsToSelector:@selector(intValue)]) {
        return [(id)number intValue];
    }
    
    return 0;
}

short kd_safeShort(NSObject *number) {
    if ([number respondsToSelector:@selector(shortValue)]) {
        return [(id)number shortValue];
    }
    
    return 0;
}

long kd_safeLong(NSObject *number) {
    if ([number respondsToSelector:@selector(longValue)]) {
        return [(id)number longValue];
    }
    
    return 0;
}

long long kd_safeLongLong(NSObject *number) {
    if ([number respondsToSelector:@selector(longLongValue)]) {
        return [(id)number longLongValue];
    }
    
    return 0;
}

double kd_safeDouble(NSObject *number) {
    if ([number respondsToSelector:@selector(doubleValue)]) {
        return [(id)number doubleValue];
    }
    
    return .0;
}

float kd_safeFloat(NSObject *number) {
    if ([number respondsToSelector:@selector(floatValue)]) {
        return [(id)number floatValue];
    }
    
    return .0f;
}

@end
