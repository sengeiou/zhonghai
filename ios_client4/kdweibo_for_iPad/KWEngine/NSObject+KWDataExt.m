//
//  NSObject+KWDataExt.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/28/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "NSObject+KWDataExt.h"

#import "Logging.h"

#import "NSDate+KWDataExt.h"

@implementation NSObject (KWDataExt)

- (NSString *)kwStringForKey:(NSString *)key
{
    id tmp = [self _kwObjectForKey:key];
    if (!tmp || [(NSObject *)tmp kwIsBlank]) {
        return @"";
    } else {
        return (NSString *)tmp;
    }
}

- (NSArray *)kwArrayForKey:(NSString *)key
{
    id tmp = [self _kwObjectForKey:key];
    if (!tmp || [(NSObject *)tmp kwIsBlank]) {
        return [NSArray array];
    } else {
        return (NSArray *)tmp;
    }
}

- (NSDictionary *)kwDictForKey:(NSString *)key
{
    id tmp = [self _kwObjectForKey:key];
    if (!tmp || [(NSObject *)tmp kwIsBlank]) {
        return nil;
    } else {
        return (NSDictionary *)tmp;
    }
    
}

- (NSDate *)kwDateForKey:(NSString *)key
{
    id tmp = [self _kwObjectForKey:key];
    if (!tmp || [(NSObject *)tmp kwIsBlank]) {
        return nil;
    } else {
        return [NSDate dateFromString:tmp];
    }
}

- (BOOL)kwBoolForKey:(NSString *)key
{
    id tmp = [self _kwObjectForKey:key];
    if (!tmp || [(NSObject *)tmp kwIsBlank]) {
        return NO;
    } else if ([tmp isKindOfClass:NSString.class]) {
        return [(NSString *)tmp isEqualToString:@"true"] || [(NSString *)tmp isEqualToString:@"1"];
    } else if ([tmp isKindOfClass:NSNumber.class]) {
        return 0.0 != [(NSNumber *)tmp floatValue];
    } else {
        return (BOOL)tmp;
    }
}

- (NSNumber *)kwNumberForKey:(NSString *)key
{
    id tmp = [self _kwObjectForKey:key];
    if (!tmp || [(NSObject *)tmp kwIsBlank]) {
        return 0;
    } else {
        return (NSNumber *)tmp;
    }
}

- (NSDecimalNumber *)kwDecimalNumberForKey:(NSString *)key
{
    id tmp = [self _kwObjectForKey:key];
    if (!tmp || [(NSObject *)tmp kwIsBlank]) {
        return 0;
    } else {
        return (NSDecimalNumber *)tmp;
    }
}

- (id)_kwObjectForKey:(NSString *)key
{
    if ([self kwIsBlank]) {
        return nil;
    }
    
    SEL obj4k = @selector(objectForKey:);
    if ([self respondsToSelector:obj4k]) {
        return [self performSelector:obj4k withObject:key];
    } else {
        LogDebug(@"object [%@] cant responds to [objectForKey:]", self);
        return nil;
    }
}

- (BOOL)kwIsPresent
{
    return ![self kwIsBlank];
}

- (BOOL)kwIsBlank
{
    if (nil == self) {
        return YES;
    }
    
    if ([self isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([self isKindOfClass:[NSString class]]) {
        NSString *tmp = (NSString *)self;
        return [@"" isEqualToString:tmp];
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        NSArray *tmp = (NSArray *)self;
        return 0 == tmp.count;
    }
    
    return NO;
}

@end
