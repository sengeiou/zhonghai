//
//  KDPersonCache.m
//  kdweibo
//
//  Created by Gil on 15/3/27.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPersonCache.h"
#import "TMMemoryCache.h"
#import "XTDataBaseDao.h"
#import "KDPersonFetch.h"

@interface KDPersonCache ()
@property (nonatomic, strong) TMMemoryCache *memory;
@property (nonatomic, strong) KDPersonFetch *fetcher;
@end

@implementation KDPersonCache

+ (instancetype)sharedPersonCache
{
    static id cache;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        cache = [[self alloc] init];
    });
    
    return cache;
}

- (id)init {
    self = [super init];
    if (self) {
        self.memory = [[TMMemoryCache alloc] init];
        self.memory.costLimit = 500;
        self.memory.removeAllObjectsOnMemoryWarning = NO;
        self.memory.removeAllObjectsOnEnteringBackground = NO;
    }
    return self;
}

- (KDPersonFetch *)fetcher {
    if (_fetcher == nil) {
        _fetcher = [[KDPersonFetch alloc] init];
    }
    return _fetcher;
}

#pragma mark - Person Cache

- (PersonSimpleDataModel *)personForKey:(NSString *)key {
    if (key.length == 0) {
        return nil;
    }
    
    id person = [self.memory objectForKey:key];
    
    if (!person) {
        person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:key];
        if (person) {
            [self setPerson:person forKey:key];
        }
        else {
            [self.fetcher fetchWithPersonIds:@[key] completionBlock:nil];
        }
    }
    
    return person;
}

- (void)setPerson:(PersonSimpleDataModel *)person forKey:(NSString *)key {
    if (key.length == 0 || !person) {
        return;
    }
    
    [self.memory setObject:person forKey:key withCost:1];
}

- (void)removePersonForKey:(NSString *)key {
    if (key.length == 0) {
        return;
    }
    [self.memory removeObjectForKey:key];
}

- (void)removeAllPersons {
    [self.memory removeAllObjects];
}

@end
