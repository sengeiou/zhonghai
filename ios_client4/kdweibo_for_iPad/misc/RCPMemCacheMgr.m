//
//  RCPMemCacheMgr.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/23/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "RCPMemCacheMgr.h"

@interface RCPMemCacheMgr ()

@property (retain) NSMutableDictionary *container;
@property (retain) NSMutableArray *keyQueue;

@end

@implementation RCPMemCacheMgr
{
    BOOL _isCropping;
}

@synthesize limit = _limit;
@synthesize keyQueue = _keyQueue;
@synthesize container = _container;

+ (RCPMemCacheMgr *)memCacheMgr
{
    return [self memCacheMgrWithLimit:0];
}

+ (RCPMemCacheMgr *)memCacheMgrWithLimit:(NSUInteger)limit
{
    return [[[self alloc] initWithLimit:limit] autorelease];
}

- (RCPMemCacheMgr *)initWithLimit:(NSUInteger)limit
{
    self = [super init];
    if (self) {
        self.limit = limit;
        if (0 == limit) {
            self.container = [NSMutableDictionary dictionary];
            self.keyQueue = [NSMutableArray array];
        } else {
            self.container = [NSMutableDictionary dictionaryWithCapacity:limit];
            self.keyQueue = [NSMutableArray arrayWithCapacity:limit];
        }
    }
    
    return self;
}

- (void)setObject:(id)object forKey:(id)key
{
    [self.container setObject:object forKey:key];
    [self.keyQueue addObject:key];
    [self performSelector:@selector(_cropCacheWithKey:) withObject:key afterDelay:0];
}

- (id)objectForKey:(id)key
{
    id obj = [self.container objectForKey:key];
    if (nil != obj) {
        [self performSelector:@selector(_hitKey:) withObject:key afterDelay:0];
    }
    return obj;
}

- (void)removeObjectForKey:(id)key
{
    [self.keyQueue removeObject:key];
    [self.container removeObjectForKey:key];
}

- (void)reset
{
    self.container = [NSMutableDictionary dictionary];
    self.keyQueue = [NSMutableArray array];
}

- (void)_cropCacheWithKey:(id)key
{
    if (_isCropping || 0 == self.limit) {
        return;
    }
    
    _isCropping = YES;
    
    while (self.limit < self.keyQueue.count) {
        id key2rm = [self.keyQueue objectAtIndex:0];
        [self.container removeObjectForKey:key2rm];
        [self.keyQueue removeObjectAtIndex:0];
    }
    
    _isCropping = NO;
}

/// move key to end of queue
- (void)_hitKey:(id)key
{
    [self.keyQueue removeObject:key];
    [self.keyQueue addObject:key];
}

@end
